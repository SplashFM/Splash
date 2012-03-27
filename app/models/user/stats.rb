class User
  module Stats
    extend ActiveSupport::Concern

    MAX_SCORE = 99

    included do
      sorted_set :sorted_following
      sorted_set :top_following

      redis_sorted_field :influence
      redis_counter :ripple_count
      redis_counter :splash_count
      redis_hash :splashed_tracks
      redis_hash :splashed_track_weeks
    end

    module ClassMethods
      def by_score
        scoped.sort_by(&:splash_score).reverse
      end

      def recompute_top_following
        User.find_each(:batch_size => 100) {|u| u.recompute_top_following }
      end

      def recompute_all_splashboards(users = [])
        reset_splashed_tracks = lambda { |u|
          u.reset_splashed_track_weeks
          u.reset_splashed_track_weeks_hash!
        }
        recompute_splashboard = lambda { |u| u.recompute_splashboard }

        if users.empty?
          User.find_each :batch_size => 100, &reset_splashed_tracks
          User.find_each :batch_size => 100, &recompute_splashboard
        else
         users.each &reset_splashed_tracks
         users.each &recompute_splashboard
        end
      end

      def recompute_influence
        reset_sorted_influence

        update_influences(select(:id).map(&:id))
      end

      def recompute_ripple_counts
        reset_ripple_counts

        find_each(:batch_size => 100) {|u|
          update_ripple_count u.id, u.slow_ripple_count
        }
      end

      def recompute_splash_counts
        reset_splash_counts

        find_each(:batch_size => 100) {|u|
          update_splash_count u.id, u.slow_splash_count
        }
      end

      def recompute_splashed_tracks
        reset_splashed_tracks
        reset_splashed_track_weeks

        find_each(:batch_size => 100) { |u|
          u.reset_splashed_tracks_hash!
          u.reset_splashed_track_weeks_hash!
        }

        find_each(:batch_size => 100) { |u|
          u.recompute_splashboard
        }
      end

      def top_splashers(page, num_records)
        # find featured splashers
        top_qry   = where('top_splasher_weight > 0')
        top_count = top_qry.count
        top_pages = (top_count / num_records.to_f).ceil
        top       = top_qry.page(page).per(num_records).
          order('top_splasher_weight desc')

        # complement results with actual top splashers if needed
        if top_pages > 0 && top.size < num_records
          page = page - top_pages + 1
        end

        # don't allow users to appear more than once
        inf  = sorted_by_influence(page, num_records)
        excl = top_qry.value_of(:id)
        hexc = Hash[*excl.zip(Array.new(excl.size, true)).flatten]

        top + inf.reject { |i| hexc[i.id] }
      end

      def update_influences(ids)
        scs    = splash_counts(ids) || []
        rcs    = ripple_counts(ids) || []
        ids.zip(scs, rcs).each { |(id, s, r)|
          update_sorted_influence(id, s.to_i + (r.to_i * 2))
        }
      end
    end
  end

  def influence_score
    total_users = User.count

    if influence_rank
      (90 * (((total_users - influence_rank) / total_users.to_f) ** 7)).floor
    else
      0
    end
  end

  def recompute_splashboard(operation = nil, followed = nil)
    # TODO: there is a more efficient way to add or subtract the other users history,
    # but this works for now.
    reset_top_tracks!
  end

  def recompute_top_following
    sorted_following.clear if sorted_following.exists?
    top_following.clear    if top_following.exists?

    sorted_following.add(id, 0)
    following.value_of(:id).each { |id| sorted_following.add(id, 0) }

    influence = Redis::SortedSet.new("#{Rails.env}/user/sorted_influence")

    puts top_following.key.inspect

    influence.interstore(top_following.key, sorted_following)
  end

  def reset_splashed_tracks_hash!
    Splash.for_users(id).select(:track_id).map(&:track_id).each{|i|
      record_splashed_track(i)
    }
  end

  def reset_splashed_track_weeks_hash!
    # TODO: this is slow and ugly
    Splash.
      for_users(id).
      where('created_at > ?', 7.days.ago).
      select(:track_id).
      map(&:track_id).
      each {|i| record_splashed_track_week(i) }
  end

  def reset_top_tracks!
    replace_summed_splashed_tracks(following_ids)
    replace_summed_splashed_track_weeks(following_ids)
  end

  def slow_ripple_count
    Splash.for_users(id).map(&:ripple_count).sum
  end

  def slow_splash_count
    Splash.for_users(id).count
  end

  def splash_score
    s = influence_score + 10 + top_splasher_weight.to_i

    s > MAX_SCORE ? MAX_SCORE : s
  end

  def splashed_tracks_hash
    splashed_tracks.inject({}) {|m, i| m[i.to_i] = true; m}
  end

  def top_tracks(following, page=1, num_records=20)
    scores = if following
               summed_splashed_track_weeks(page, num_records)
             else
               summed_splashed_tracks(page, num_records)
             end

    if scores.present?
      ids, _ = *scores.transpose
      cache = Track.where(:id => ids).hash_by(&:id)

      scores.map { |(id, score)|
        cache[id.to_i].tap { |t| t.scoped_splash_count = score }
      }
    else
      []
    end
  end

  def top_splashers(page, num_records)
    page  = page.to_i <= 1 ? 1 : page.to_i
    start = (page - 1) * num_records
    stop  = start + num_records - 1
    ids   = top_following.revrange(start, stop).map { |id| id.to_i }

    cache = self.class.where(:id => ids).index_by(&:id)

    ids.map { |id| cache[id] }
  end
end

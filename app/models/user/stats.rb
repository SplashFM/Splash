require 'new_relic/agent/method_tracer'

class User
  module Stats
    extend ActiveSupport::Concern

    MAX_SCORE = 99

    included do
      sorted_set :sorted_following
      sorted_set :top_following

      redis_sorted_field :influence
      redis_sorted_field :featured_influence
      redis_counter :ripple_count
      redis_counter :splash_count
      redis_hash :splashed_tracks
      redis_hash :splashed_track_weeks
      redis_hash :splashed_track_days

      before_update :check_featured
      after_update  :commit_featured
    end

    module ClassMethods
      def by_score
        scoped.sort_by(&:splash_score).reverse
      end

      def featured(page, num_records)
        sorted_by_featured_influence(page, num_records)
      end

      def recompute_top_following
        User.find_each(:batch_size => 100) { |u| u.recompute_top_following }
      end

      def recompute_all_splashboards(users = [])
        reset_splashed_tracks = lambda { |u|
          u.reset_splashed_track_weeks
          u.reset_splashed_track_weeks_hash!
          u.reset_splashed_track_days
          u.reset_splashed_track_days_hash!

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
        reset_splashed_track_days

        find_each(:batch_size => 100) { |u|
          u.reset_splashed_tracks_hash!
          u.reset_splashed_track_weeks_hash!
          u.reset_splashed_track_days_hash!
        }

        find_each(:batch_size => 100) { |u|
          u.recompute_splashboard
        }
      end

      def top_splashers(page, num_records)
        sorted_by_influence(page, num_records)
      end

      def update_influence(id, w, s, r)
        update_sorted_influence(id, s.to_i + (r.to_i * 2))

        update_sorted_featured_influence(id, s.to_i + (r.to_i * 2)) if w
      end

      def update_influences(ids)
        ids    = ids.map(&:to_i).sort
        scs    = splash_counts(ids) || []
        rcs    = ripple_counts(ids) || []
        iws    = where(id: ids).order(:id).values_of(:id, :top_splasher_weight)
        iws.zip(scs, rcs).each { |((id, w), s, r)|
          update_influence id, w, s, r
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

    influence.interstore(top_following.key, sorted_following)
  end

  def remove_track_from_splashboard(track_id)
    delete_splashed_track      track_id
    delete_splashed_track_week track_id
    delete_splashed_track_day track_id
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
  
  def reset_splashed_track_days_hash!
    # TODO: this is slow and ugly
    Splash.
      for_users(id).
      where('created_at > ?', 1.days.ago).
      select(:track_id).
      map(&:track_id).
      each {|i| record_splashed_track_day(i) }
  end

  def reset_top_tracks!
    replace_summed_splashed_tracks(following_ids)
    replace_summed_splashed_track_weeks(following_ids)
    replace_summed_splashed_track_days(following_ids)
  end

  def slow_ripple_count
    Splash.for_users(id).map(&:ripple_count).sum
  end

  def slow_splash_count
    Splash.for_users(id).count
  end

  def splash_score
    s = influence_score + 10

    s > MAX_SCORE ? MAX_SCORE : s
  end

  def splashed_tracks_hash
    splashed_tracks.inject({}) {|m, i| m[i.to_i] = true; m}
  end

  def top_tracks(following, page=1, num_records=20)
    scores = if following
#               summed_splashed_track_one_days(page, num_records)
               summed_splashed_track_weeks(page, num_records)
             else
             #  summed_splashed_track_weeks(page, num_records)
               summed_splashed_track_days(page, num_records)
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

  include NewRelic::Agent::MethodTracer

  add_method_tracer :recompute_top_following, 'Custom/recompute_top_following'
  add_method_tracer :recompute_splashboard, 'Custom/recompute_splashboard'
  add_method_tracer :remove_track_from_splashboard, 'Custom/remove_track_from_splashboard'
  add_method_tracer :reset_splashed_tracks_hash!, 'Custom/reset_splashed_tracks_hash!'
  add_method_tracer :reset_splashed_track_weeks_hash!, 'Custom/reset_splashed_track_weeks_hash!'
  add_method_tracer :reset_splashed_track_days_hash!, 'Custom/reset_splashed_track_days_hash!'
  add_method_tracer :reset_top_tracks!, 'Custom/reset_top_tracks!'

  private

  def check_featured
    if top_splasher_weight_changed?
      @featured_op = top_splasher_weight? ? :add : :delete
    end
  end

  def commit_featured
    case @featured_op
    when :add
      self.class.update_influence id,
                                  top_splasher_weight,
                                  splash_count,
                                  ripple_count
    when :delete
      reset_sorted_featured_influence
    end
  end
end

class User
  module Stats
    extend ActiveSupport::Concern

    MAX_SCORE = 99

    included do
      redis_sorted_field :influence
      redis_counter :ripple_count
      redis_counter :splash_count
      redis_hash :splashed_tracks
    end

    module ClassMethods
      def by_score
        scoped.sort_by(&:splash_score).reverse
      end

      def recompute_all_splashboards
        User.find_each(:batch_size => 100) {|u| u.recompute_splashboard }
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

        find_each(:batch_size => 100) { |u|
          u.reset_splashed_tracks_hash!
        }

        find_each(:batch_size => 100) { |u|
          u.recompute_splashboard
        }
      end

      def top_splashers(page, num_records)
        sorted_by_influence(page, num_records)
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
      (90 * (((total_users - influence_rank) / total_users.to_f) ** 4)).floor
    else
      0
    end
  end

  def recompute_splashboard(operation = nil, followed = nil)
    # TODO: there is a more efficient way to add or subtract the other users history,
    # but this works for now.
    reset_top_tracks!
  end

  def reset_splashed_tracks_hash!
    Splash.for_users(id).select(:track_id).map(&:track_id).each{|i|
      record_splashed_track(i)
    }
  end

  def reset_top_tracks!
    replace_summed_splashed_tracks(following_ids)
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

  def top_tracks(page=1, num_records=20)
    scores = summed_splashed_tracks(page, num_records)

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
end

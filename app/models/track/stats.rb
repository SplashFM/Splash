class Track
  module Stats
    extend ActiveSupport::Concern

    included do
      redis_base_key :track
      redis_counter :splash_count
      redis_counter :splash_count_week
    end

    module ClassMethods
      def recompute_splash_counts_time_bound
        reset_splash_count_weeks

        # TODO #splashed should take in a time period
        date = 7.days.ago

        splashed.where('splashes.created_at > ?', date).
          find_each(:batch_size => 100) { |t|
            t.recompute_splash_count_week(date)
        }
      end

      def recompute_splash_counts
        Track.reset_splash_counts

        splashed.find_each(:batch_size => 100) { |t| t.recompute_splash_count }
      end

      def top_splashed(week, page, num_records)
        if week
          tracks = sorted_by_splash_count_week(page, num_records)

          tracks.each { |t| t.scoped_splash_count = t.splash_count_week }
        else
          sorted_by_splash_count(page, num_records)
        end
      end
    end

    def recompute_splash_count
      self.class.update_splash_count(id, Splash.for_tracks(self).count)
    end

    def recompute_splash_count_week(date = 7.days.ago)
      count = Splash.where('created_at > ?', date).for_tracks(self).count

      self.class.update_splash_count_week(id, count)
    end

    private

    def clear_redis
      if @users_to_recompute
        Track.recompute_splash_counts
        Track.recompute_splash_counts_time_bound

        User.recompute_all_splashboards(@users_to_recompute)
      end
    end

    def prepare_clear_redis
      sv = splashes.value_of(:user_id)

      @users_to_recompute = User.find(sv) if sv.present?
    end
  end
end

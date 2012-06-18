class Track
  module Stats
    extend ActiveSupport::Concern

    included do
      redis_base_key :track
      redis_counter :splash_count
      redis_counter :splash_count_week
      redis_counter :splash_count_day
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
        
        reset_splash_count_days
        
        date = 1.days.ago
        splashed.where('splashes.created_at > ?', date).
          find_each(:batch_size => 100) { |t|
            t.recompute_splash_count_day(date)
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
          tracks = sorted_by_splash_count_day(page, num_records)

          tracks.each { |t| t.scoped_splash_count = t.splash_count_day }
         
         # sorted_by_splash_count(page, num_records)
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
    
    def recompute_splash_count_day(date = 1.days.ago)
      count = Splash.where('created_at > ?', date).for_tracks(self).count

      self.class.update_splash_count_day(id, count)
    end

    private

    def clear_redis
      if @users_to_recompute.present?
        delete_splash_count_instance
        delete_splash_count_week_instance
        delete_splash_count_day_instance

        @users_to_recompute.each { |u| u.remove_track_from_splashboard id  }
        @users_to_recompute.each { |u|
          u.followers.each { |f| f.remove_track_from_splashboard id }
        }
      end
    end

    def prepare_clear_redis
      sv = splashes.value_of(:user_id)

      @users_to_recompute = sv.present? ? User.includes(:followers).find(sv) : []
    end
  end
end

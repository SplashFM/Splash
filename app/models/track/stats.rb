class Track
  module Stats
    extend ActiveSupport::Concern

    included do
      redis_base_key :track
      redis_counter :splash_count
    end

    module ClassMethods
      def recompute_splash_counts
        Track.reset_splash_counts

        splashed.find_each(:batch_size => 100) { |t| t.recompute_splash_count }
      end

      def top_splashed(page, num_records)
        sorted_by_splash_count(page, num_records)
      end
    end

    def recompute_splash_count
      self.class.update_splash_count(id, Splash.for_tracks(self).count)
    end
  end
end

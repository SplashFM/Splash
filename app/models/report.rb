class Report
  def self.email
    reports = {}

    reports[:total_users]               = total_users = User.count
    reports[:total_splashes]            = Splash.count
    reports[:total_relationships]       = Relationship.count
    reports[:total_comments]            = Comment.count
    reports[:total_undiscovered_tracks] = UndiscoveredTrack.count

    reports[:percent_splashers] =
      pct(Splash.select('distinct user_id').count, total_users)
    reports[:percent_followers] =
      pct(Relationship.select('distinct follower_id').count, total_users)

    AdminMailer.daily_reports(reports).deliver
  end

  def self.pct(sample, total)
    (sample / total.to_f * 100).to_i
  end
end

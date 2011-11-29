Delayed::Worker.destroy_failed_jobs = false # don't delete failed jobs from the DB
Delayed::Worker.delay_jobs = Rails.env.production?

# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
set :output, "log/cron_log.log"
env :PATH, ENV["PATH"]

every 1.month do
  rake "increment_year:increment_one_year"
end

# every 1.month do
#   runner "MsrMailer.send_monthly_report(['hanis@uottawa.ca', 'bruno.mrlima@gmail.com']).deliver_now"
# end

every :hour, at: 50 do
  rake "popular_hours:calculate_popular_hours"
end

every 1.month do
  rake "confirmed_users:remind"
end

# At 7am of First day of every week
# every :monday, at: '7am' do
#   runner "MsrMailer.send_weekly_report(['hanis@uottawa.ca', 'bruno.mrlima@gmail.com']).deliver_now"
# end

every "0 11 1 9 *" do
  rake "update_profile:send_emails" if Time.now.year % 2 != 0
end

# At 7:30am of First day of every week
# every :monday, at: '7am' do
#   runner "MsrMailer.send_training_report(['hanis@uottawa.ca', 'bruno.mrlima@gmail.com','brunsfield@uottawa.ca', 'MTC@uottawa.ca']).deliver_now"
# end

every :sunday, at: "1am" do
  rake "active_volunteers:check_volunteers_status"
end

every :day, at: "2am" do
  rake "active_volunteers:check_volunteers_status"
end

every :day, at: "11:59pm" do
  rake "exams:check_expired_exams"
end

every :day, at: "3am" do
  rake "badge:get_data"
  rake "badge:get_and_update_badge_templates"
end

every :day, at: "9am" do
  rake "print_order_notifications:two_weeks_reminder"
  rake "users_inactive:check"
end

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

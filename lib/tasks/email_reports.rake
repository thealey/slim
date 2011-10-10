desc 'Update withings and send email reports'

namespace :slim do
  task :email_reports => :environment do
    while true
      Person.all.each do |person|
        new_measure_count = person.refresh
        puts person.username + ' got ' + new_measure_count.to_s + ' measures'
        ReportMailer.report_notification(person).deliver if person.send_email if new_measure_count > 0
      end
      puts Time.now.to_s(:long)
      sleep 60 * 30
    end
  end
end

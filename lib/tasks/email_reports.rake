desc 'Update withings and send email reports'

namespace :slim do
  task :email_reports => :environment do
    while true
      Person.all.each do |person|
        if person.withings_id and person.withings_id.size > 0
          new_measure_count = person.refresh
          puts person.username + ' got ' + new_measure_count.to_s + ' measures'
          if person.send_email and new_measure_count > 0
            ReportMailer.report_notification(person).deliver
          end
        else
          puts person.username + ' not a withings user'
        end
      end
      puts Time.now.to_s(:long)
      sleep 60 * 30
    end
  end
end

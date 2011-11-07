desc 'Update withings and send email reports'

namespace :slim do
  task :email_reports => :environment do

    people_changed_list = Array.new

    while true
      Person.all.each do |person|
        if person.withings_id and person.withings_id.size > 0
          begin
            latest_measure_date = person.current_measure.measure_date
            person.refresh
            puts person.username + ' refreshed'
            unless person.current_measure.measure_date == latest_measure_date
              people_changed_list << person
            end
          rescue 
            puts 'Error getting measures'
          end
        else
          puts person.username + ' not a withings user'
        end
      end

      if people_changed_list.size > 0
        puts 'Updating trend'
        Measure.update_trend
      end

      Person.all.each do |person|
        if people_changed_list.include? person and person.send_email
          puts 'Emailing ' + person.username
          ReportMailer.report_notification(person).deliver
        end
      end

      puts Time.now.to_s(:long)
      sleep 60 * 30
    end
  end
end

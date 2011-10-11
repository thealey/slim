desc 'Update withings and send email reports'

namespace :slim do
  task :email_reports => :environment do

    people_changed_list = Array.new

    while true
      Person.all.each do |person|
        if person.withings_id and person.withings_id.size > 0
          begin
            new_measure_count = person.refresh
            puts person.username + ' got ' + new_measure_count.to_s + ' measures'
            if new_measure_count > 0
              people_changed_list << person
            end
          rescue Error => error
            puts 'Error getting measures: ' + error
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
        #if person.send_email
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

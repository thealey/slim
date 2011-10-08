desc 'Update withings and send email reports'

namespace :slim do
  task :email_reports => :environment do
    Person.all.each do |person|
      #puts person.username + ' got ' + person.refresh.to_s + ' measures'
      ReportMailer.report_notification(person).deliver
    end
  end
end

class ReportMailer < ActionMailer::Base
  default from: "noreply@slim.flunkyism.com"

  def report_notification(person)
    subject = person.email_subject
    puts subject
    mail(:to => person.email, :subject => subject)
  end
end

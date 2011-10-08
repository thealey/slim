class ReportMailer < ActionMailer::Base
  default from: "noreply@slim.flunkyism.com"

  def report_notification(person)
    subject = 'Slim: Currently ' + person.current_measure.to_s + ' - '
    subject = subject + person.karma_grade(person.current_measure) + ' - '
    subject = subject + ' Rank: ' + person.karma_rank.to_s

    mail(:to => person.email, :subject => subject)
  end
end

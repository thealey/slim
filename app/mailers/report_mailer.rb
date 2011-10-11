class ReportMailer < ActionMailer::Base
  default from: "noreply@slim.flunkyism.com"

  def report_notification(person)
    subject = 'Slim: ' + Utility.floatformat % person.current_measure.karma + ' '
    subject = subject + person.karma_grade(person.current_measure) + ' '
    subject = subject + 'Rank: ' + person.karma_rank.to_s + '/' + person.measures.size.to_s + ' '  
    subject = subject + 'Now ' + Utility.floatformat % person.current_measure.item.to_s + ' ' 
    subject = subject + 'Trend ' + Utility.floatformat % person.current_measure.trend.to_s + ' ' 
    subject = subject + Utility.floatstringlbs(person.last(7).to_s) + ' '
    subject = subject + Utility.floatformat % person.in3months + ' in 3 months'
    puts subject
    mail(:to => person.email, :subject => subject)
  end
end

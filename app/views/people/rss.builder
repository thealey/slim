xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do

    xml.title       "Slim progress for " + @person.username
    #xml.description "bfirpd all updates"

    @reports.each do |measure_date, report|
        xml.title       @person.username 
        xml.link        'http://slim.flunkyism.com/people/' + @person.id.to_s
        xml.description report
        xml.author      @person.username
        xml.pub_date    measure_date.to_s(:rfc822)
        xml.image do
          #xml.url       @person.gravatar_url
          xml.url       @chart_url
      end
    end
  end
end

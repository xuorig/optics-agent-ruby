require 'net/http'

module OpticsAgent::Reporting
  class << self
    OPTICS_URL = 'https://optics-report.apollodata.com'
    private def send_message(message)

      req = Net::HTTP::Post.new('/api/ss/stats')
      req['x-api-key'] = ENV['API_KEY']
      req['user-agent'] = "optics-agent-rb"

      req.body = message.class.encode(message)

      uri = URI.parse(OPTICS_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res = http.request(req)
      p res
      p res.body
    end
  end
end

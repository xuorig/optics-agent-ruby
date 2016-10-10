require 'optics-agent/report'

module OpticsAgent
  class RackMiddleware
    def initialize(app, options={})
      @app = app
    end

    def call(env)
      begin
        report = OpticsAgent::Report.new
        # Attach so resolver middleware can access
        env["optics-agent.report"] = report
        result = @app.call(env)

        # XXX: move this out of band
        sleep 1
        report.send

        result
      rescue Exception => e
        puts "rescued"
        p e
      end
    end
  end
end

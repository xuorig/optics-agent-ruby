require 'optics-agent/agent'
require 'optics-agent/reporting/query'

module OpticsAgent
  class RackMiddleware
    def initialize(app, options={})
      @app = app
    end

    def call(env)
      begin
        start = Time.now

        # XXX: figure out a way to pass this in here
        agent = OpticsAgent::Agent.instance
        query = OpticsAgent::Reporting::Query.new

        # Attach so resolver middleware can access
        env[:optics_agent] = { agent: agent, query: query }
        result = @app.call(env)

        agent.current_report.add_query(query, Time.now - start)

        # XXX: this should happen on an interval, driven by the agent
        agent.send_report

        result
      rescue Exception => e
        puts "rescued"
        p e
      end
    end
  end
end

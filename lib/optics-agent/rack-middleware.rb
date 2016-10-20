require 'optics-agent/agent'
require 'optics-agent/reporting/query'

module OpticsAgent
  class RackMiddleware
    def initialize(app, options={})
      @app = app
    end

    def call(env)
      begin
        start_time = Time.now

        # Attach so resolver middleware can access
        env[:optics_agent] = OpticsAgent::Transaction.new

        result = @app.call(env)

        # XXX: this approach means if the user forgets to call with_document
        # we just never log queries. Can we detect if the request is a graphql one?
        if (query.document)
          agent.add_query(query, env, start_time, Time.now)
        end

        result
      rescue Exception => e
        puts "Rack Middleware Error: #{e}"
        puts e.backtrace
      end
    end
  end
end

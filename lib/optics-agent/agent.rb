require 'singleton'
require 'optics-agent/rack-middleware'
require 'optics-agent/graphql-middleware'
require 'optics-agent/reporting/report_job'
require 'optics-agent/reporting/schema'
require 'optics-agent/reporting/query-trace'

module OpticsAgent
  # XXX: this is a class but acts as a singleton right now.
  # Need to figure out how to pass the agent into the middleware
  #   (for instance we could dynamically generate a middleware class,
  #    or ask the user to pass the agent as an option) to avoid it
  class Agent
    include Singleton
    include OpticsAgent::Reporting

    attr_reader :schema

    def initialize
      @query_queue = []
      @semaphone = Mutex.new
      ReportJob.perform_in(60, self)
    end

    def instrument_schema(schema)
      @schema = schema
      # XXX: do this out of band and delay it
      report_schema(schema)
      schema.middleware << graphql_middleware
    end

    def report_schema(schema)
      schema_report = Schema.new(schema)
      schema_report.send
    end

    def add_query(query, rack_env, start_time, end_time)
      @semaphone.synchronize {
        @query_queue << [query, rack_env, start_time, end_time]
      }
    end

    def clear_query_queue
      @semaphone.synchronize {
        queue = @query_queue
        @query_queue = []
        queue
      }
    end

    def rack_middleware
      OpticsAgent::RackMiddleware
    end

    def graphql_middleware
      # graphql middleware doesn't seem to need the agent but certainly could have it
      OpticsAgent::GraphqlMiddleware.new
    end
  end
end

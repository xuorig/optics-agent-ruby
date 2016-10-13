require 'singleton'
require 'optics-agent/rack-middleware'
require 'optics-agent/graphql-middleware'
require 'optics-agent/reporting/report'
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

    attr_accessor :current_report

    def initialize
      @current_report = Report.new
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

    def add_query(query, start_time, end_time)
      @current_report.add_query(query, start_time, end_time)

      # for now, we are very naive about this, but we should really
      # just be sending one per latency bucket or something
      send_trace(query, start_time, end_time)
    end

    def send_report
      @current_report.decorate_from_schema(@schema)
      @current_report.send
      @current_report = Report.new
    end

    def send_trace(query, start_time, end_time)
      query_trace = QueryTrace.new(query, start_time, end_time)
      query_trace.send
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

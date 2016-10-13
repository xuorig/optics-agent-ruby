require 'singleton'
require 'optics-agent/rack-middleware'
require 'optics-agent/graphql-middleware'
require 'optics-agent/reporting/report'
require 'optics-agent/reporting/schema'

module OpticsAgent
  # XXX: this is a class but acts as a singleton right now.
  # Need to figure out how to pass the agent into the middleware
  #   (for instance we could dynamically generate a middleware class,
  #    or ask the user to pass the agent as an option) to avoid it
  class Agent
    include Singleton

    attr_accessor :current_report

    def initialize
      @current_report = OpticsAgent::Reporting::Report.new
    end

    def instrument_schema(schema)
      # XXX: do this out of band and delay it
      report_schema(schema)
      schema.middleware << graphql_middleware
    end

    def report_schema(schema)
      schema_report = OpticsAgent::Reporting::Schema.new(schema)
      schema_report.send
    end

    def send_report
      @current_report.send
      @current_report = OpticsAgent::Reporting::Report.new
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

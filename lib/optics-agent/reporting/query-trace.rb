require 'apollo/optics/proto/reports_pb'
require 'optics-agent/reporting/helpers'
require 'optics-agent/reporting/send-message'

module OpticsAgent::Reporting
  # A trace is just a different view of a single query report, with full
  # information about start and end times
  class QueryTrace
    include OpticsAgent::Reporting
    include Apollo::Optics::Proto

    attr_accessor :report

    def initialize(query, rack_env, start_time, end_time)
      trace = Trace.new({
        start_time: generate_timestamp(start_time),
        signature: query.signature
      })

      # XXX: report trace details (not totally clear yet from the JS agent what should be here)
      trace.details = Trace::Details.new({})

      info = client_info(rack_env)
      trace.client_name = info[:client_name]
      trace.client_version = info[:client_version]
      trace.client_address = info[:client_address]
      trace.http = Trace::HTTPInfo.new({
        host: "localhost:8080",
        path: "/graphql"
      })

      nodes = []
      query.each_report do |type_name, field_name, field_start_time, field_end_time|
        nodes << Trace::Node.new({
          field_name: "#{type_name}.#{field_name}",
          start_time: ((field_start_time - start_time) * 1e9).to_i,
          end_time: ((field_end_time - start_time) * 1e9).to_i
        })
      end
      trace.execute = Trace::Node.new({
        child: nodes
      })

      @report = TracesReport.new({
        header: generate_report_header,
        trace: [trace]
      })
    end

    def send
      send_message('/api/ss/traces', @report)
    end
  end
end

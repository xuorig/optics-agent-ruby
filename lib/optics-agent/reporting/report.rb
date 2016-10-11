require 'apollo/optics/proto/reports_pb'
require 'optics-agent/reporting/send-message'

module OpticsAgent::Reporting
  # This class represents a complete report that we send to the optics server
  # It pretty closely wraps the StatsReport protobuf message with a few
  # convenience methods
  class Report
    include Apollo::Optics::Proto

    attr_accessor :report

    def initialize
      # internal report that we encapsulate
      @report = StatsReport.new({
        header: ReportHeader.new({
          agent_version: '1'
        }),
        start_time: Timestamp.new({
          # XXX pass this in?
          seconds: Time.now.to_i,
          nanos: 0
        })
      })
    end

    def finish!
      @report.end_time ||= Timestamp.new({
        # XXX pass this in?
        seconds: Time.now.to_i,
        nanos: 0
      })
    end

    def send
      self.finish!
      OpticsAgent::Reporting.send_message(@report)
    end

    def add_query(query, micros)
      # XXX: what should the queryKey be and where do we get it from?
      queryKey = '{ posts { author { firstName } } }'

      # XXX: we'll need to either merge this with our stats_per_signature
      # for this queryKey or store Queries in a different format
      @report.per_signature[queryKey] = query.stats_per_signature
    end
  end
end

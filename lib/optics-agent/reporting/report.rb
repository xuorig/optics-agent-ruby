require 'apollo/optics/proto/reports_pb'
require 'optics-agent/reporting/send-message'

module OpticsAgent::Reporting
  # This class represents a complete report that we send to the optics server
  # It pretty closely wraps the StatsReport protobuf message with a few
  # convenience methods
  class Report
    include Apollo::Optics::Proto
    include OpticsAgent::Reporting

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
      send_message('/api/ss/stats', @report)
    end

    # XXX: record timing / client
    def add_query(query, start_time, end_time)
      @report.per_signature[query.signature] ||= StatsPerSignature.new

      query.add_to_stats @report.per_signature[query.signature]
    end

    # take a graphql schema and add returnTypes to all the fields on our report
    def decorate_from_schema(schema)
      each_field do |type_stat, field_stat|
        type = schema.types[type_stat.name]
        throw "Type #{type_stat.name} not found!" unless type

        field = type.fields[field_stat.name]
        throw "Field #{type_stat.name}.#{field_stat.name} not found!" unless field

        field_stat.returnType = field.type.to_s
      end
    end

    # do something once per field we've collected
    def each_field
      @report.per_signature.values.each do |sps|
        sps.per_type.each do |type|
          type.field.each do |field|
            yield type, field
          end
        end
      end
    end
  end
end

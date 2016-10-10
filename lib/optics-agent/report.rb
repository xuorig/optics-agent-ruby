require 'apollo/optics/proto/reports_pb'
require 'optics-agent/reporting/send-message'

module OpticsAgent
  # this is a convenience class that enables us to fairly blindly
  # pass in data as we resolve a query
  class Report
    include Apollo::Optics::Proto

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

      ## XXX: what should the queryKey be and where do we get it from?
      queryKey = '{ posts { author { firstName } } }'
      @stats_per_signature = StatsPerSignature.new
      @report.per_signature[queryKey] = @stats_per_signature

      # a map type_name => TypeStat
      @type_stats = {}

      # a map type_name => field_name => FieldStat
      @field_stats = {}
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

    def report_field(type_name, field_name, nanos)
      unless @type_stats[type_name]
        @field_stats[type_name] = {}

        type_stat = TypeStat.new({name: type_name})
        @type_stats[type_name] = type_stat

        @stats_per_signature.per_type << type_stat
      end

      unless @field_stats[type_name][field_name]
        field_stat = FieldStat.new({
          name: field_name,
          # XXX: look up returnType from schema or pass it in?
          returnType: 'String',
          latency_count: Array.new(256) { 0 }
        })
        @field_stats[type_name][field_name] = field_stat
        @type_stats[type_name].field << field_stat
      end

      bucket = self.latency_bucket(nanos)
      @field_stats[type_name][field_name].latency_count[bucket] += 1
    end

    # see https://github.com/apollostack/optics-agent/blob/master/docs/histograms.md
    def latency_bucket(nanos)
      micros = nanos / 1000
      bucket = Math.log(micros) / Math.log(1.1);

      [255, [0, bucket].max].min.ceil.to_i
    end
  end
end

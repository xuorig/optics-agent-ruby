require 'apollo/optics/proto/reports_pb'
require 'optics-agent/normalization/latency'

module OpticsAgent::Reporting
  # this is a convenience class that enables us to fairly blindly
  # pass in data as we resolve a query
  class Query
    include Apollo::Optics::Proto
    include OpticsAgent::Normalization

    attr_accessor :stats_per_signature

    def initialize
      @stats_per_signature = StatsPerSignature.new

      # a map type_name => TypeStat
      @type_stats = {}

      # a map type_name => field_name => FieldStat
      @field_stats = {}
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
          latency_count: empty_latency_count
        })
        @field_stats[type_name][field_name] = field_stat
        @type_stats[type_name].field << field_stat
      end

      bucket = self.latency_bucket(nanos)
      @field_stats[type_name][field_name].latency_count[bucket] += 1
    end
  end
end

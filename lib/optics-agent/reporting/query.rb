require 'apollo/optics/proto/reports_pb'

module OpticsAgent::Reporting
  # This is a convenience class that enables us to fairly blindly
  # pass in data as we resolve a query
  class Query
    include Apollo::Optics::Proto

    def initialize
      @reports = []
    end

    # we do nothing when reporting to minimize impact
    def report_field(type_name, field_name, micros)
      @reports << [type_name, field_name, micros]
    end

    # generate a StatsPerSignature representing our reports
    def stats_per_signature
      stats_per_signature = StatsPerSignature.new

      # a map type_name => TypeStat
      type_stats = {}

      # a map type_name => field_name => FieldStat
      field_stats = {}

      @reports.each do |report|
        type_name, field_name, micros = report

        unless type_stats[type_name]
          field_stats[type_name] = {}

          type_stat = TypeStat.new({name: type_name})
          type_stats[type_name] = type_stat

          stats_per_signature.per_type << type_stat
        end

        unless field_stats[type_name][field_name]
          field_stat = FieldStat.new({
            name: field_name,
            # XXX: look up returnType from schema or pass it in?
            returnType: 'String',
            latency_count: empty_latency_count
          })
          field_stats[type_name][field_name] = field_stat
          type_stats[type_name].field << field_stat
        end

        bucket = latency_bucket(micros)
        field_stats[type_name][field_name].latency_count[bucket] += 1
      end

      stats_per_signature
    end
  end
end

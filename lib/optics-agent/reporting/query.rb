require 'apollo/optics/proto/reports_pb'

module OpticsAgent::Reporting
  # This is a convenience class that enables us to fairly blindly
  # pass in data as we resolve a query
  class Query
    include Apollo::Optics::Proto

    attr_accessor :query_key

    def initialize
      @reports = []

      # TODO: take query as arg, normalize
      @query_key = '{ posts { author { firstName } } }'
    end

    # we do nothing when reporting to minimize impact
    def report_field(type_name, field_name, micros)
      @reports << [type_name, field_name, micros]
    end

    # add our results to an existing StatsPerSignature
    def add_to_stats(stats_per_signature)
      @reports.each do |report|
        type_name, field_name, micros = report

        type_stat = stats_per_signature.per_type.find { |ts| ts.name == type_name }
        unless type_stat
          type_stat = TypeStat.new({ name: type_name })
          stats_per_signature.per_type << type_stat
        end

        field_stat = type_stat.field.find { |fs| fs.name == field_name }
        unless field_stat
          field_stat = FieldStat.new({
            name: field_name,
            # XXX: look up returnType from schema or pass it in?
            returnType: 'String',
            latency_count: empty_latency_count
          })
          type_stat.field << field_stat
        end

        bucket = latency_bucket(micros)
        field_stat.latency_count[bucket] += 1
      end
    end
  end
end

require 'apollo/optics/proto/reports_pb'
require_relative './send-message'

module OpticsAgent::Reporting
  include Apollo::Optics::Proto

  def self.send_report
    # just a made up query for now
    queryKey = '{ posts { title } }'

    # basic stuff about the trace
    report = StatsReport.new({
      header: ReportHeader.new({
        agent_version: '1'
      }),
      start_time: Timestamp.new({
        seconds: Time.now.to_i / 1000,
        nanos: 0
      }),
      end_time: Timestamp.new({
        seconds: Time.now.to_i / 1000 + 5,
        nanos: 0
      })
    })

    # now query stats
    stats_per_signature = StatsPerSignature.new
    stats_per_signature.per_type << TypeStat.new({
      name: 'Query',
      field: [
        FieldStat.new({
          name: 'posts',
          returnType: '[Post]'
        })
      ]
    })
    stats_per_signature.per_type << TypeStat.new({
      name: 'Post',
      field: [
        FieldStat.new({
          name: 'title',
          returnType: 'String'
        })
      ]
    })
    stats_per_signature.per_type << TypeStat.new({
      name: 'String'
    })
    report.per_signature[queryKey] = stats_per_signature

    send_message report
  end
end

require 'optics-agent/proto/reports_pb'
require_relative './send-message'

module OpticsAgent::Reporting
  def self.send_report
    # just a made up query for now
    queryKey = '{ posts { title } }'

    # basic stuff about the trace
    report = OpticsAgent::Proto::StatsReport.new({
      header: OpticsAgent::Proto::ReportHeader.new({
        agent_version: '1'
      }),
      start_time: OpticsAgent::Proto::Timestamp.new({
        seconds: Time.now.to_i / 1000,
        nanos: 0
      }),
      end_time: OpticsAgent::Proto::Timestamp.new({
        seconds: Time.now.to_i / 1000 + 5,
        nanos: 0
      })
    })

    # now query stats
    stats_per_signature = OpticsAgent::Proto::StatsPerSignature.new
    stats_per_signature.per_type << OpticsAgent::Proto::TypeStat.new({
      name: 'Query',
      field: [
        OpticsAgent::Proto::FieldStat.new({
          name: 'posts',
          returnType: '[Post]'
        })
      ]
    })
    stats_per_signature.per_type << OpticsAgent::Proto::TypeStat.new({
      name: 'Post',
      field: [
        OpticsAgent::Proto::FieldStat.new({
          name: 'title',
          returnType: 'String'
        })
      ]
    })
    stats_per_signature.per_type << OpticsAgent::Proto::TypeStat.new({
      name: 'String'
    })
    report.per_signature[queryKey] = stats_per_signature

    send_message report
  end
end

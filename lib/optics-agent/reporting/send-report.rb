require 'optics-agent/proto/reports_pb'
require_relative './send-message'

module OpticsAgent::Reporting
  def self.send_report
    report = OpticsAgent::Proto::StatsReport.new({
      header: OpticsAgent::Proto::ReportHeader.new({
        agent_version: '1'
      }),
      start_time: OpticsAgent::Proto::Timestamp.new({
        seconds: 1,
        nanos: 0
      }),
      end_time: OpticsAgent::Proto::Timestamp.new({
        seconds: 1,
        nanos: 0
      })
    })

    send_message report
  end
end

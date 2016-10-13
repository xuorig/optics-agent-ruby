require 'apollo/optics/proto/reports_pb'

module OpticsAgent::Reporting
  def generate_report_header
    # XXX: fill out
    Apollo::Optics::Proto::ReportHeader.new({
      agent_version: '0'
    })
  end

  def generate_timestamp(time)
    Apollo::Optics::Proto::Timestamp.new({
      seconds: time.to_i,
      nanos: time.to_i % 1 * 1e9
    });
  end
end

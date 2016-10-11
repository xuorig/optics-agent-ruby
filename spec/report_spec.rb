require 'optics-agent/reporting/report'
require 'optics-agent/reporting/query'
require 'apollo/optics/proto/reports_pb'

include OpticsAgent::Reporting
include Apollo::Optics::Proto

describe Report do
  it "can represent a simple query" do
    query = Query.new
    query.report_field 'Person', 'firstName', 1000
    query.report_field 'Person', 'lastName', 1000
    query.report_field 'Query', 'person', 2200

    report = Report.new
    report.add_query query, 2500
    report.finish!

    expect(report.report).to be_an_instance_of(StatsReport)
    stats_report = report.report
    expect(stats_report.per_signature.keys.length).to equal(1)

    signature_stats = stats_report.per_signature.values.first
    expect(signature_stats.per_type.length).to equal(2)
    expect(signature_stats.per_type.map &:name).to match_array(['Person', 'Query'])

    person_stats = signature_stats.per_type.find { |s| s.name === 'Person' }
    expect(person_stats.field.length).to equal(2)
    expect(person_stats.field.map &:name).to match_array(['firstName', 'lastName'])

    firstName_stats = person_stats.field.find { |s| s.name === 'firstName' }
    expect(firstName_stats.latency_count.length).to eq(256)
    expect(firstName_stats.latency_count.reduce(&:+)).to eq(1)
    expect(firstName_stats.latency_count[145]).to eq(1)
  end
end

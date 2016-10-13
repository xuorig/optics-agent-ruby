require 'optics-agent/reporting/query-trace'
require 'optics-agent/reporting/query'
require 'apollo/optics/proto/reports_pb'
require 'graphql'

include Apollo::Optics::Proto
include OpticsAgent::Reporting

class DocumentMock
  def initialize(key)
    @key = key
  end

  def [](name) # used for [:query]
    @key
  end
end


describe QueryTrace do
  it "can represent a simple query" do
    query = Query.new
    query.report_field 'Person', 'firstName', 1, 1.1
    query.report_field 'Person', 'lastName', 1, 1.1
    query.report_field 'Query', 'person', 1, 1.22
    query.document = DocumentMock.new('key')

    trace = QueryTrace.new(query, {}, 1, 1.25)

    expect(trace.report).to be_instance_of(TracesReport)
    expect(trace.report.trace.length).to eq(1)

    trace_obj = trace.report.trace.first
    nodes = trace_obj.execute.child
    expect(nodes.length).to eq(3)
    expect(nodes.map(&:field_name)).to \
      match_array(['Query.person', 'Person.firstName', 'Person.lastName'])

    firstName_node = nodes.find { |n| n.field_name == 'Person.firstName' }
    expect(firstName_node.start_time).to eq(0)
    expect(firstName_node.end_time).to eq(0.1 * 1e9)
  end
end

require 'optics-agent/reporting/report'
require 'optics-agent/reporting/query'
require 'apollo/optics/proto/reports_pb'
require 'graphql'

include OpticsAgent::Reporting
include Apollo::Optics::Proto

class DocumentMock
  def initialize(key)
    @key = key
  end

  def [](name) # used for [:query]
    @key
  end
end


describe Report do
  it "can represent a simple query" do
    query = Query.new
    query.report_field 'Person', 'firstName', 1, 1.1
    query.report_field 'Person', 'lastName', 1, 1.1
    query.report_field 'Query', 'person', 1, 1.22
    query.document = DocumentMock.new('key')

    report = Report.new
    report.add_query query, {}, 1, 1.25
    report.finish!

    expect(report.report).to be_an_instance_of(StatsReport)
    stats_report = report.report
    expect(stats_report.per_signature.keys).to match_array(['key'])

    signature_stats = stats_report.per_signature.values.first
    expect(signature_stats.per_type.length).to equal(2)
    expect(signature_stats.per_type.map &:name).to match_array(['Person', 'Query'])

    person_stats = signature_stats.per_type.find { |s| s.name === 'Person' }
    expect(person_stats.field.length).to equal(2)
    expect(person_stats.field.map &:name).to match_array(['firstName', 'lastName'])

    firstName_stats = person_stats.field.find { |s| s.name === 'firstName' }
    expect(firstName_stats.latency_count.length).to eq(256)
    expect(firstName_stats.latency_count.reduce(&:+)).to eq(1)
    expect(firstName_stats.latency_count[121]).to eq(1)
  end

  it "can aggregate the results of multiple queries with the same shape" do
    queryOne = Query.new
    queryOne.report_field 'Person', 'firstName', 1, 1.1
    queryOne.report_field 'Person', 'lastName', 1, 1.1
    queryOne.report_field 'Query', 'person', 1, 1.22
    queryOne.document = DocumentMock.new('key')

    queryTwo = Query.new
    queryTwo.report_field 'Person', 'firstName', 1, 1.05
    queryTwo.report_field 'Person', 'lastName', 1, 1.05
    queryTwo.report_field 'Query', 'person', 1, 1.2
    queryTwo.document = DocumentMock.new('key')

    report = Report.new
    report.add_query queryOne, {}, 1, 1.1
    report.add_query queryTwo, {}, 1, 1.1
    report.finish!

    expect(report.report).to be_an_instance_of(StatsReport)
    stats_report = report.report
    expect(stats_report.per_signature.keys).to match_array(['key'])

    signature_stats = stats_report.per_signature.values.first
    expect(signature_stats.per_type.length).to equal(2)
    expect(signature_stats.per_type.map &:name).to match_array(['Person', 'Query'])

    person_stats = signature_stats.per_type.find { |s| s.name === 'Person' }
    expect(person_stats.field.length).to equal(2)
    expect(person_stats.field.map &:name).to match_array(['firstName', 'lastName'])

    firstName_stats = person_stats.field.find { |s| s.name === 'firstName' }
    expect(firstName_stats.latency_count.reduce(&:+)).to eq(2)
    expect(firstName_stats.latency_count[114]).to eq(1)
    expect(firstName_stats.latency_count[121]).to eq(1)
  end

  it "can aggregate the results of multiple queries with a different shape" do
    queryOne = Query.new
    queryOne.report_field 'Person', 'firstName', 1, 1.1
    queryOne.report_field 'Person', 'lastName', 1, 1.1
    queryOne.report_field 'Query', 'person', 1, 1.22
    queryOne.document = DocumentMock.new('keyOne')

    queryTwo = Query.new
    queryTwo.report_field 'Person', 'firstName', 1, 1.05
    queryTwo.report_field 'Person', 'lastName', 1, 1.05
    queryTwo.report_field 'Query', 'person', 1, 1.02
    queryTwo.document = DocumentMock.new('keyTwo')

    report = Report.new
    report.add_query queryOne, {}, 1, 1.1
    report.add_query queryTwo, {}, 1, 1.1
    report.finish!

    expect(report.report).to be_an_instance_of(StatsReport)
    stats_report = report.report
    expect(stats_report.per_signature.keys).to match_array(['keyOne', 'keyTwo'])

    signature_stats = stats_report.per_signature['keyOne']
    expect(signature_stats.per_type.length).to equal(2)
    expect(signature_stats.per_type.map &:name).to match_array(['Person', 'Query'])

    person_stats = signature_stats.per_type.find { |s| s.name === 'Person' }
    expect(person_stats.field.length).to equal(2)
    expect(person_stats.field.map &:name).to match_array(['firstName', 'lastName'])

    firstName_stats = person_stats.field.find { |s| s.name === 'firstName' }
    expect(firstName_stats.latency_count.reduce(&:+)).to eq(1)
    expect(firstName_stats.latency_count[121]).to eq(1)
  end


  it "can decorate it's fields with resultTypes from a schema" do
    query = Query.new
    query.report_field 'Person', 'firstName', 1, 1.1
    query.report_field 'Person', 'age', 1, 1.1
    query.document = DocumentMock.new('key')

    report = Report.new
    report.add_query query, {}, 1, 1.25
    report.finish!

    person_type = GraphQL::ObjectType.define do
      name 'Person'
      field :firstName, types.String
      field :age, !types.Int
    end
    query_type = GraphQL::ObjectType.define do
      name 'Query'
      field :person, person_type
    end

    schema = GraphQL::Schema.define do
      query query_type
    end

    report.decorate_from_schema(schema)

    stats_report = report.report
    signature_stats = stats_report.per_signature.values.first
    person_stats = signature_stats.per_type.find { |s| s.name === 'Person' }

    firstName_stats = person_stats.field.find { |s| s.name === 'firstName' }
    expect(firstName_stats.returnType).to eq('String')

    age_stats = person_stats.field.find { |s| s.name === 'age' }
    expect(age_stats.returnType).to eq('Int!')
  end
end

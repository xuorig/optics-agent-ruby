require 'optics-agent/reporting/schema'
require 'graphql'

include OpticsAgent::Reporting

describe Schema do
  it "can collect the correct types from a schema" do
    person_type = GraphQL::ObjectType.define do
      name 'Person'
      field :firstName, types.String
      field :lastName, types.String
    end
    query_type = GraphQL::ObjectType.define do
      name 'Query'
      field :person, person_type
    end

    schema = GraphQL::Schema.define do
      query query_type
    end

    schema_report = Schema.new(schema).message

    type = schema_report.type
    expect(type.map &:name).to match_array(['Person', 'Query'])

    person_type = type.find { |t| t.name == 'Person' }
    expect(person_type.field.map &:name).to match_array(['firstName', 'lastName'])

    firstName_field = person_type.field.find { |f| f.name === 'firstName' }
    expect(firstName_field.returnType).to eq('String')
  end
end

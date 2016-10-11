require 'optics-agent/instrumentation/query-schema'
require 'graphql'

include OpticsAgent::Instrumentation

describe 'introspect_schema' do
  it 'returns the right basic shape' do
    person_type = GraphQL::ObjectType.define do
      name "Person"
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

    result = introspect_schema(schema)

    expect(result.keys).to \
      match_array(["directives", "mutationType", "queryType", "subscriptionType", "types"])
  end
end

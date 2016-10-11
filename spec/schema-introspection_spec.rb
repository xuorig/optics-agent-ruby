require 'optics-agent/instrumentation/query-schema'
require 'graphql'

include OpticsAgent::Instrumentation
include GraphQL

describe 'query_schema' do
  it 'returns the right basic shape' do
    person_type = ObjectType.define do
      name "Person"
      field :firstName, types.String
      field :lastName, types.String
    end
    query_type = ObjectType.define do
      name 'Query'
      field :person, person_type
    end

    schema = Schema.define do
      query query_type
    end

    result = query_schema(schema)

    expect(result.keys).to \
      match_array(["directives", "mutationType", "queryType", "subscriptionType", "types"])
  end
end

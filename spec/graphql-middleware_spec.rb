require 'optics-agent/graphql-middleware'
require 'graphql'

include OpticsAgent
include GraphQL

describe GraphqlMiddleware do
  it 'collects the correct query stats' do
    person_type = ObjectType.define do
      name "Person"
      field :firstName do
        type types.String
        resolve -> (obj, args, ctx) { sleep(0.100); return 'Tom' }
      end
      field :lastName do
        type types.String
        resolve -> (obj, args, ctx) { sleep(0.100); return 'Coleman' }
      end
    end
    query_type = ObjectType.define do
      name 'Query'
      field :person do
        type person_type
        resolve -> (obj, args, ctx) { sleep(0.050); return {} }
      end
    end

    schema = Schema.define do
      query query_type
    end

    schema.middleware << GraphqlMiddleware.new

    query = spy("query")
    schema.execute('{ person { firstName lastName } }', {
      context: { optics_agent: { query: query } }
    })

    expect(query).to have_received(:report_field).exactly(3).times
    expect(query).to have_received(:report_field)
      .with('Query', 'person', be_within(50000).of(50 * 1000))
    expect(query).to have_received(:report_field)
      .with('Person', 'firstName', be_within(50000).of(100 * 1000))
    expect(query).to have_received(:report_field)
      .with('Person', 'lastName', be_within(50000).of(100 * 1000))
  end
end

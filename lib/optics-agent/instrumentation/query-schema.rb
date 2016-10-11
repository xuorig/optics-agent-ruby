require 'graphql'

module OpticsAgent
  module Instrumentation
    include GraphQL

    INTROSPECTION_QUERY = IO.read("#{File.dirname(__FILE__)}/introspection-query.graphql")

    def query_schema(schema)
      schema.execute(INTROSPECTION_QUERY)['data']['__schema']
    end
  end
end

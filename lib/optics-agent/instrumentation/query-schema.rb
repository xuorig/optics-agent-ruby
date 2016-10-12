module OpticsAgent
  module Instrumentation
    INTROSPECTION_QUERY ||= IO.read("#{File.dirname(__FILE__)}/introspection-query.graphql")

    def introspect_schema(schema)
      schema.execute(INTROSPECTION_QUERY)['data']['__schema']
    end
  end
end

require 'graphql'

module OpticsAgent
  module Normalization
    module Query
      # query is a query string
      def normalize(query_string)
        document = GraphQL.parse(query_string)

        output = ''
        visitor = GraphQL::Language::Visitor.new(document)

        visitor[GraphQL::Language::Nodes::Field].leave << -> (node, parent) do
          parent.selection_set ||= []
          parent.selection_set << node.name
        end
        visitor[GraphQL::Language::Nodes::Document].leave << -> (node, parent) do
          output = "{#{node.selection_set}}"
        end
        visitor.visit

        output
      end
    end
  end
end

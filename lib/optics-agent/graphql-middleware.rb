module OpticsAgent
  class GraphqlMiddleware
    def call(parent_type, parent_object, field_definition, field_args, query_context, next_middleware)
      start_time = Time.now
      result = next_middleware.call
      end_time = Time.now

      query = query_context[:optics_agent][:query]
      query.report_field(parent_type.to_s, field_definition.name, start_time, end_time)

      result
    end
  end
end

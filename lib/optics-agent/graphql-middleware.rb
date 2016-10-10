module OpticsAgent
  class GraphqlMiddleware
    def call(parent_type, parent_object, field_definition, field_args, query_context, next_middleware)
      start = Time.now
      result = next_middleware.call

      nanos = (Time.now - start) * 1000 * 1000

      optics_report = query_context['optics-agent.report']
      optics_report.report_field(parent_type.to_s, field_definition.name, nanos)

      result
    end
  end
end

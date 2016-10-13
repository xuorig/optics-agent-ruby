module OpticsAgent
  class GraphqlMiddleware
    def call(parent_type, parent_object, field_definition, field_args, query_context, next_middleware)
      start = Time.now
      result = next_middleware.call

      args = ''
      unless field_args.to_h.empty?
        args = "(#{field_args.to_h.keys.map {|k| "#{k}: #{field_args[k]}"}})"
      end

      resolver_str = "#{parent_type}.#{field_definition.name}#{args}"

      puts "#{resolver_str} took #{((Time.now - start) * 1000 * 1000).to_i}ns"
      result
    end
  end
end

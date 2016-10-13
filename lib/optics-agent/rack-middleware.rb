module OpticsAgent
  class RackMiddleware
    def initialize(app, options={})
      @app = app
    end

    def call(env)
      start = Time.now
      result = @app.call(env)
      puts "Request took #{Time.now - start}ns"
      result;
    end
  end
end

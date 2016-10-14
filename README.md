# optics-agent-ruby
Optics Agent for GraphQL Monitoring in Ruby

## Installing

Add

```ruby
gem 'optics-agent'
```

To your `Gemfile`

## Setup

Create an agent

```ruby
# we expect one day there'll be some options
agent = OpticsAgent::Agent.instance
```

Register the Rack middleware (say in a `config.ru`):

```ruby
use agent.rack_middleware
```

Register the Graphql middleware:

```ruby
agent.instrument_schema(YourSchema)
```

Add something like this to your route:

```ruby
post '/graphql' do
  request.body.rewind
  document = JSON.parse request.body.read
  result = Schema.execute(document["query"],
    variables: document["variables"],
    context: { optics_agent: env[:optics_agent].with_document(document) }
  )
  JSON.generate(result)
end
```

## Setup, Rails

The equivalent of the above for Rails is (I welcome better solutions!)

Create an agent in `config/apllication.rb`, and register the rack middleware:

```ruby
module XXXRails
  class Application < Rails::Application
    # ...

    config.optics_agent = OpticsAgent::Agent.instance
    config.middleware.use config.optics_agent.rack_middleware
  end
end

```

Register the Graphql middleware when you create your schema:

```ruby
Rails.application.config.optics_agent.instrument_schema(YourSchema)
```

Add something like this to your `graphql` action:

```ruby
def create
  query_string = params[:query]
  query_variables = ensure_hash(params[:variables])
  result = YourSchema.execute(query_string,
    variables: query_variables,
    context: {
      optics_agent: env[:optics_agent].with_document(params)
    }
  )
  render json: result
end
```

You can check out the GitHunt Rails API server example here: https://github.com/apollostack/githunt-api-rails


## Development

### Building protobuf definitions

Ensure you've installed `protobuf` and development dependencies.

```bash
# this works on OSX
brew install protobuf

# ensure it's version 3
protoc --version

bundle install
````

Compile the `.proto` definitions with

```bash
bundle exec rake proto:compile
```

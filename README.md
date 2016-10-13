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

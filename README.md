# optics-agent-ruby
Optics Agent for GraphQL Monitoring in Ruby

## Installing

Add

```ruby
gem 'optics-agent'
```

To your `Gemfile`

## Setup

Register the Rack middleware (say in a `config.ru`):

```ruby
use OpticsAgent::RackMiddleware
```

Register the Graphql middleware

```ruby
Schema.middleware << OpticsAgent::GraphqlMiddleware.new
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

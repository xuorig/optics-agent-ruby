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

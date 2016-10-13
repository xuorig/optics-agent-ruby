Gem::Specification.new do |s|
  s.name        = 'optics-agent'
  s.version     = '0.0.0'
  s.date        = '2016-10-06'
  s.summary     = "An Agent for Apollo Optics"
  s.description = "An Agent for Apollo Optics, http://optics.apollodata.com"
  s.authors     = ["Tom Coleman "]
  s.email       = 'tom@meteor.com'
  s.files       = [
    "lib/optics-agent.rb",
    "lib/optics-agent/rack-middleware.rb",
    "lib/optics-agent/graphql-middleware.rb"
  ]
  s.homepage    =
    'http://rubygems.org/gems/optics-agent'
  s.license     = 'MIT'

  s.add_runtime_dependency 'graphql', '~> 0.19.0'
end

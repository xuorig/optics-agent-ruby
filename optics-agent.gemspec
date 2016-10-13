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
    "lib/optics-agent/graphql-middleware.rb",
    "lib/optics-agent/proto/reports_pb.rb"
  ]
  s.homepage    =
    'http://rubygems.org/gems/optics-agent'
  s.license     = 'MIT'

  s.add_runtime_dependency 'graphql', '~> 0.19.0'

  s.add_development_dependency 'rake', '~> 11.3.0'
  s.add_development_dependency 'google-protobuf', '~> 3.1.0'
end

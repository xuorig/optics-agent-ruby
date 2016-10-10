namespace :protobuf do
  task :compile do
    `protoc -Iresources/proto resources/proto/reports.proto --ruby_out lib/apollo/optics/proto/`
  end
end

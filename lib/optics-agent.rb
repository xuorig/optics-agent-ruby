require 'optics-agent/rack-middleware'
require 'optics-agent/graphql-middleware'
require 'optics-agent/reporting/send-report.rb'

OpticsAgent::Reporting.send_report

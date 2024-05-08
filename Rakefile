require_relative 'lib/audit_group'

require 'rake'

task :spec do
  sh 'bundle exec rspec'
end

task :build do
  sh 'gem build audit_group.gemspec'
end

task :push do
  sh "gem push omg-audit-group-#{AuditGroup::VERSION}.gem"
end

task :publish => :push

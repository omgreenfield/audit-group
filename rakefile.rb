require 'rake'
require 'yaml'

def config
  @config ||= YAML.load_file(File.join(__dir__, './config.yml'))
end

desc 'Increments version in `config.yml`'
task :bump do
  versions = config['version'].split('.')
  versions[-1] = versions[-1].to_i + 1
  config['version'] = versions.join('.')
  File.write(File.join(__dir__, './config.yml'), config.to_yaml)
  puts "Bumped version to #{config['version']}"
end

desc 'Runs specs'
task :spec do
  sh 'bundle exec rspec'
end

desc 'Builds gem'
task :build do
  sh "gem build #{config['name']}.gemspec"
end

desc 'Publishes/pushes gem to RubyGems'
task push: :build do
  sh "gem push #{config['name']}-#{config['version']}.gem"
end
task publish: :push

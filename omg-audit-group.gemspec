# frozen_string_literal: true

require 'yaml'
config = YAML.load_file(File.join(__dir__, './config.yml'))

Gem::Specification.new do |spec|
  config.each do |key, value|
    if spec.respond_to?("#{key}=")
      spec.send("#{key}=", value)
    else
      spec.metadata[key.to_s] = value
    end
  end

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.add_dependency 'activerecord', '>= 5.2', '< 7.2'
  spec.add_dependency 'audited', '>= 4.9', '< 6.0'
end

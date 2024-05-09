# frozen_string_literal: true

require_relative 'lib/audit_group'

Gem::Specification.new do |spec|
  spec.name = 'omg-audit-group'
  spec.version = AuditGroup::VERSION
  spec.authors = ['Matthew Greenfield']
  spec.email = ['mattgreenfield1@gmail.com']

  spec.summary = 'Groups transactions from the `audited` gem into a single request_uuid'
  spec.description = 'Create, update, and delete records within a block, assign ' \
                     'the same request_uuid to them, and be able to easily view ' \
                     'and undo them'

  spec.homepage = 'https://github.com/omgreenfield/audit-group/tree/main'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = ['lib/audit_group.rb']
  spec.require_paths = ['lib']

  # spec.add_dependency 'activerecord', '>= 6.0', '< 8.0'
  # spec.add_dependency 'activesupport', '>= 6.0', '< 8.0'
  # spec.add_dependency 'audited', '>= 4.9', '< 6.0'
end

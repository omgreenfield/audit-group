# AuditGroup

Group ActiveRecord operations together by assigning all of their audits the same `request_uuid`.

## TODO

- [ ] Figure out a way to expect gem users to have `audited`, `activesupport`, and `activerecord` without requiring them to run specs or build gem
  - See how `audited` gem works
- [ ] Test `dry_run` method in `medely`
  - Currently, I get this stupid error:
  ```
  /home/omgreenfield/.rvm/gems/ruby-2.7.8@medely/gems/railties-6.0.6.1/exe/rails:10:in `require': cannot load such file -- rails/cli (LoadError)
  ```
- Figure out how to get rid of all of those `WARN: Unresolved or ambiguous specs during Gem::Specification.reset:` errors

## Requirements

- [Audited](https://github.com/collectiveidea/audited) gem

## Installation

### From RubyGems.org

#### Globally

```sh
gem i omg-audit-group
```

#### In `Gemfile`

```ruby
gem 'omg-audit-group'
```

### Testing locally
```sh
# Build gem
rake build

# Install gem
## From this directory
rake install

## From other directory
gem i -l /path/to/this/folder/omg-audit-group-0.1.0.gem
```

## Usage

### Load the gem

```ruby
require 'audit_group'
```

### Using class methods

```ruby
# Group operations under the same request_uuid
AuditGroup.request { perform_some_operations }

# View the last request_uuid
AuditGroup.request_uuid

# View the audits from the last request
AuditGroup.audits
```

### Saving Request object for later use

```ruby
# Group operations under the same request_uuid
request = AuditGroup.request { perform_some_operations }

# View the last request_uuid
request.request_uuid

# View the audits from the last request
request.audits
```

### Instantiating a group

You can also create separate `AuditGroup::Request` objects to reuse.

```ruby
group = AuditGroup.new
group.request { perform_some_operations }
...
group.request { perform_more_operations }
group.audits
```

## Running tests

```ruby
rspec

# or
bundle exec rspec
```

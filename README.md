# AuditGroup

Group ActiveRecord operations together by assigning all of their audits the same `request_uuid`.

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

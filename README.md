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

# Save the AuditGroup instance for later
audit_group = AuditGroup.current
```

### Saving Request object for later use

```ruby
# Group operations under the same request_uuid
audit_group = AuditGroup.request { perform_some_operations }

# View the last request_uuid
audit_group.request_uuid

# View the audits from the last request
audit_group.audits
```

### Passing in a request_uuid

```ruby
AuditGroup.request(request_uuid: some_record.audits.last.request_uuid)
```

### Performing a dry run

View how records would change without committing the transaction

```ruby
audit_group = AuditGroup.request(dry_run: true) { perform_some_operations }
audit_group.audits
```

## Running tests

```ruby
bundle exec rspec # option 1
rake spec         # option 2
rspec             # option 3
```

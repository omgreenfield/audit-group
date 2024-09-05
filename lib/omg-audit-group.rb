# frozen_string_literal: true

require 'audited'

class AuditGroup
  class LockError < StandardError
    def initialize
      super('Request is locked and cannot be run again. If you want to add operations to an existing request_uuid, create a new instance')
    end
  end

  class << self
    attr_accessor :current

    ##
    # Updates `audited` gem to make every operation use the same `request_uuid`.
    #
    # @param request_uuid [String] The `request_uuid` to use for all operations within the block.
    def set_request_uuid(request_uuid = SecureRandom.uuid)
      Audited.store[:current_request_uuid] = request_uuid
    end

    ##
    # Resets `audited` gem to generate a new `request_uuid` for each operation.
    def unset_request_uuid
      Audited.store.delete(:current_request_uuid)
    end

    ##
    # Clears out any current `request_uuid` or AuditGroup request.
    def reset
      unset_request_uuid
      @current = nil
    end

    ##
    # Creates a new AuditGroup and runs operations to be all given the same `request_uuid`
    #
    # @yield operations whose audits should be associated with the same request_uuid.
    def request(dry_run: false, &block)
      new(dry_run: dry_run).request(&block)
    end

    def request_uuid
      current.request_uuid
    end

    def audits
      current.audits
    end
  end

  attr_reader :block, :request_uuid, :dry_run, :locked

  ##
  # Creates a new AuditGroup instance and updates `AuditGroup.current` to it.
  #
  # @param request_uuid [String] What all audits within the group will have assigned as their request_uuid.
  #   Useful if you want to group additional operations under a `request_uuid` that already exists in the DB.
  # @param dry_run [Boolean] If true, the transaction will be rolled back after the block is executed.
  # @yield operations whose audits should be associated with the same request_uuid.
  def initialize(request_uuid = SecureRandom.uuid, dry_run: false, &block)
    @request_uuid = request_uuid
    @dry_run = dry_run
    @locked = false

    self.class.current = self

    request(&block) if block_given?
  end

  ##
  # Sets the `request_uuid` used by the `audited` store, runs the passed in block, then clears the `request_uuid`.
  #   Subsequent `request` calls will also be given the same `request_uuid`.
  #
  # @yield operations whose audits should be associated with the same request_uuid.
  # @return [AuditGroup] itself
  def request(&block)
    raise ArgumentError, 'No block given' unless block_given?
    raise LockError if locked?

    set_request_uuid

    if dry_run?
      ActiveRecord::Base.transaction do
        block.call

        # Calls .to_a to keep records in memory after rollback
        @audits = audits.to_a

        raise ActiveRecord::Rollback
      end
    else
      block.call
    end

    lock!

    self
  ensure
    unset_request_uuid
  end

  ##
  # @return [Boolean] whether this request is a dry run and will therefore not persist changes.
  def dry_run?
    dry_run
  end

  ##
  # @return [Boolean] whether this request has already been run and is therefore locked.
  def locked?
    locked
  end

  def lock!
    @locked = true
  end

  ##
  # Returns all associated audits. If `dry_run` is true, these will not be persistent in DB.
  #
  # @return [ActiveRecord::Relation] all audits associated with the request.
  def audits
    Audited::Audit.where(request_uuid: request_uuid)
  end

  def set_request_uuid
    self.class.set_request_uuid(request_uuid)
  end

  def unset_request_uuid
    self.class.unset_request_uuid
  end

  def current
    self.class.current
  end
end

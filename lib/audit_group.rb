# frozen_string_literal: true

require 'active_support/all'
require 'audited'

class AuditGroup
  VERSION = '0.1.2'

  attr_reader :block, :request_uuid

  delegate :current, :unset_request_uuid, to: :class

  class << self
    attr_accessor :current

    delegate :request_uuid, :audits, to: :current

    def set_request_uuid(request_uuid = SecureRandom.uuid)
      Audited.store[:current_request_uuid] = request_uuid
    end

    def unset_request_uuid
      Audited.store.delete(:current_request_uuid)
    end

    def reset
      unset_request_uuid
      @current = nil
    end

    def request(&block)
      raise ArgumentError, 'No block given and no active group' unless block_given?

      new.request(&block)
    end
  end

  def initialize(request_uuid = SecureRandom.uuid)
    @request_uuid = request_uuid
    self.class.current = self
  end

  def request(&block)
    set_request_uuid

    block.call if block.present?

    self
  ensure
    unset_request_uuid
  end

  def set_request_uuid
    self.class.set_request_uuid(request_uuid)
  end

  def audits
    Audited::Audit.where(request_uuid: request_uuid)
  end
end

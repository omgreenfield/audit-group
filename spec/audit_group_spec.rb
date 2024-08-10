require 'spec_helper'

RSpec.describe AuditGroup do
  before do
    audited_audit = class_double('Audited::Audit').as_stubbed_const
    allow(audited_audit).to receive(:where).with(request_uuid: '123').and_return(['some', 'audits'])
    stub_const('Audited::Audit::Rails', Module.new)

    class_double('ActiveRecord').as_stubbed_const
    class_double('ActiveRecord::Base').as_stubbed_const
    class_double('ActiveRecord::Rollback').as_stubbed_const
    stub_const('ActiveRecord::Rollback', Class.new(StandardError))
  end

  describe 'class methods' do
    describe '.current' do
      it 'returns the last request created' do
        request = described_class.request {}
        expect(described_class.current).to eq(request)
      end
    end

    describe '.set_request_uuid' do
      it "sets the Audit store's current_request_uuid" do
        described_class.set_request_uuid('123')
        expect(Audited.store[:current_request_uuid]).to eq('123')

        described_class.set_request_uuid
        expect(Audited.store[:current_request_uuid]).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      end
    end

    describe '.unset_request_uuid' do
      it "resets the Audit store's current_request_uuid" do
        Audited.store[:current_request_uuid] = '123'
        described_class.unset_request_uuid
        expect(Audited.store[:current_request_uuid]).to be_nil
      end
    end

    describe '.reset' do
      it 'unsets the request_uuid and current request' do
        described_class.set_request_uuid('123')
        described_class.current = 'some request'

        expect(Audited.store[:current_request_uuid]).to eq('123')
        expect(described_class.current).to eq('some request')

        described_class.reset

        expect(Audited.store[:current_request_uuid]).to be_nil
        expect(described_class.current).to be_nil
      end
    end

    describe '.request' do
      it 'raises an ArgumentError when no block is given' do
        expect { described_class.request }.to raise_error(ArgumentError, 'No block given')
      end

      it 'creates a new request when block is given' do
        expect { |block| described_class.request(&block) }.to yield_control
      end
    end

    describe '.request_uuid' do
      it 'delegates to current' do
        described_class.request {}
        expect(described_class.request_uuid).to eq(described_class.current.request_uuid)
      end
    end

    describe '.audits' do
      it 'delegates to current' do
        described_class.new('123')
        expect(described_class.audits).to contain_exactly('some', 'audits')
      end
    end
  end

  describe 'instance methods' do
    describe '#initialize' do
      it 'sets the request_uuid and current request' do
        request = described_class.new('123')
        expect(request.request_uuid).to eq('123')
        expect(described_class.current).to eq(request)
      end

      it 'calls request when passing in a block' do
        # Using a hash to pass by reference
        context = { block_called: false }

        expect_any_instance_of(described_class).to receive(:request).and_call_original

        described_class.new('123') { context[:block_called] = true }

        expect(context[:block_called]).to be(true)
      end
    end

    describe '#request' do
      it 'sets the current_request_uuid, calls the block, then resets current_request_uuid' do
        request = described_class.new('123')

        request.request do
          expect(Audited.store[:current_request_uuid]).to eq('123')
        end

        expect(Audited.store[:current_request_uuid]).to be_nil
      end

      it 'raises an ArgumentError if no block is given' do
        request = described_class.new('123')
        expect { request.request }.to raise_error(ArgumentError, 'No block given')
      end

      it 'raises a LockError if locked' do
        request = described_class.new('123')
        request.request {}

        expect(request.locked?).to be(true)

        expect { request.request {} }.to raise_error(AuditGroup::LockError)
      end
    end

    describe '#set_request_uuid' do
      it 'delegates to class' do
        request = described_class.new('123')
        expect(AuditGroup).to receive(:set_request_uuid)
        request.send(:set_request_uuid)
      end
    end

    describe '#audits' do
      it 'returns audits with request_uuid' do
        request = described_class.new('123')
        expect(request.audits).to contain_exactly('some', 'audits')
      end
    end

    describe 'dry_run' do
      it 'runs block within a transaction, rolls it back, but still returns audits' do
        expect(ActiveRecord::Base).to receive(:transaction).and_yield

        @request_run = false
        request = described_class.new('123', dry_run: true)

        expect { 
          request.request do
            @request_run = true
          end
        }.to raise_error(ActiveRecord::Rollback)

        expect(@request_run).to be(true)
        expect(request.audits).to contain_exactly('some', 'audits')
      end
    end
  end
end

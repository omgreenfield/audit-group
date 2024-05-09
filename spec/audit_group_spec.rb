RSpec.describe AuditGroup do
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
      it 'raises an ArgumentError if no block is given and no active group' do
        expect { described_class.request }.to raise_error(ArgumentError, 'No block given and no active group')
      end

      it 'creates a new request if block is given' do
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
        audited_audit = class_double('Audited::Audit').as_stubbed_const
        expect(audited_audit).to receive(:where).with(request_uuid: '123').and_return('some audits')
        expect(described_class.audits).to eq('some audits')
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
    end

    describe '#request' do
      it 'sets the current_request_uuid, calls the block, then resets current_request_uuid' do
        request = described_class.new('123')

        request.request do
          expect(Audited.store[:current_request_uuid]).to eq('123')
        end

        expect(Audited.store[:current_request_uuid]).to be_nil
      end
    end

    describe '#dry_run' do
      it 'saves a list of audits, rolls back the transaction, then returns the audits' do
        # 
        rails = class_double('Rails').as_stubbed_const
        expect(rails).to receive(:gem_version).and_return('123')

        request = described_class.new('123')
        rolled_back = false

        expect_any_instance_of(AuditGroup).to receive(:audits).and_return(%w[audit1 audit2])

        expect(ActiveRecord::Base).to receive(:transaction).and_wrap_original do |_m, *_args, &block|
          block.call
        rescue ActiveRecord::Rollback
          rolled_back = true
        end

        expect(request.dry_run).to contain_exactly('audit1', 'audit2')
        expect(rolled_back).to be(true)
      end
    end

    describe '#set_request_uuid' do
      it 'delegates to class' do
        request = described_class.new('123')
        expect(request).to receive(:set_request_uuid)
        request.set_request_uuid
      end
    end

    describe '#audits' do
      it 'returns audits with request_uuid' do
        request = described_class.new('123')
        audited_audit = class_double('Audited::Audit').as_stubbed_const
        expect(audited_audit).to receive(:where).with(request_uuid: '123').and_return('some audits')
        expect(request.audits).to eq('some audits')
      end
    end
  end
end

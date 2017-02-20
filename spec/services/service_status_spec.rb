# frozen_string_literal: true

require 'rails_helper'

class ModuleTester
  include ServiceStatus

  def initialize
    @x = 2
    super
  end
end

describe 'ServiceStatus' do
  it 'tracks errors' do
    x = ModuleTester.new
    x.add_error('message')
    x.add_errors(['multiple','messages'])
    expect(x.errors?).to be true
    expect(x.errors.length).to eq(3)
  end

  it 'tracks warnings' do
    x = ModuleTester.new
    x.add_warning('message')
    expect(x.warnings?).to be true
    expect(x.warnings.length).to eq(1)
  end

  it 'ignores duplicate messages' do
    x = ModuleTester.new
    x.add_error('the same thing')
    x.add_error('the same thing')
    expect(x.errors.length).to eq(1)
  end

  it 'raises error if *run* is not implemented' do
    x = ModuleTester.new
    expect { x.run }.to raise_error(RuntimeError)
  end

  describe 'absorb_status' do
    let(:parent) { ModuleTester.new }
    let(:child) { ModuleTester.new }

    it 'adds errors/warnings from service into itself' do
      child.add_error('test')
      child.add_warning('test')
      parent.absorb_status(child)
      expect(parent.errors?).to be true
      expect(parent.warnings?).to be true
    end
    it 'it always returns true if action==NEVER_FAIL' do
      child.add_error('test')
      child.add_warning('test')
      expect(
        parent.absorb_status(child,
                             action: ServiceStatus::NEVER_FAIL)
      ).to be true
    end

    it 'fails on errors and warnings with FAIL_ON_WARNING' do
      child.add_warning('test')
      expect(
        parent.absorb_status(child,
                             action: ServiceStatus::FAIL_ON_WARNING)
      ).to be false
    end
    it 'fails on errors with FAIL_ON_ERROR' do
      child.add_error('test')
      # default action
      expect(parent.absorb_status(child)).to be false
    end
  end
end

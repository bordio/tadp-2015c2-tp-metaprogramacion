require 'rspec'
require_relative '../src/domain_mock'
require_relative '../src/transformers/inject'
require_relative '../src/aspects'

describe 'Inject' do

  include Inject

  context 'When inject is used on a crazy_method with a single p1 param' do

    let(:instance) {
      instance = TestClass.new
    }

    let(:method) {
      instance.method(:crazy_method).unbind
    }

    it 'should return This is a boring method if not transformed' do
      ret = instance.crazy_method('boring')
      expect(ret).to eq('This is a boring method')
    end

    it 'should raise an ArgumentError Wrong number of arguments (0 for 1) if used without args' do
      expect { inject }.to raise_error ArgumentError, 'wrong number of arguments (0 for 1)'
    end

    it 'should raise an ArgumentError Empty hash if an empty hash is used' do
      expect { inject({}) }.to raise_error ArgumentError, 'empty hash'
    end

    it 'should return This is a crazy method if p1 is injected' do
      @methods = {method => instance.singleton_class}
      inject({p1: 'crazy'})
      expect(instance.crazy_method('boring')).to eq('This is a crazy method')
    end

    it 'should return This is a boring method if p2 is injected' do
      @methods = {method => instance.singleton_class}
      inject({p2: 'crazy'})
      expect(instance.crazy_method('boring')).to eq('This is a boring method')
    end

    it 'should return This is a crazy(crazy_method->boring) method if a a proc is injected' do
      @methods = {method => instance.singleton_class}
      inject({p1: proc { |receptor, mensaje, arg_anterior|
                        "crazy(#{mensaje}->#{arg_anterior})" }})
      expect(instance.crazy_method('boring')).to eq('This is a crazy(crazy_method->boring) method')
    end

  end

  context 'When inject is used on a crazy_method with a single p1 param and on a super_crazy_method with a p2 param' do

    let(:instance) {
      instance = TestClass.new
    }

    let(:crazy_method) {
      instance.method(:crazy_method).unbind
    }

    let(:super_crazy_method) {
      instance.extend(TestModule)
      instance.method(:super_crazy_method).unbind
    }

    it 'should transform both methods' do
      @methods = {crazy_method => instance.singleton_class, super_crazy_method => instance.singleton_class }
      inject({p1: 'crazy', p2: 'crazier'})
      expect(instance.crazy_method('boring')).to eq('This is a crazy method')
      expect(instance.super_crazy_method('borier')).to eq('This is by far a crazier method')
    end

  end

end
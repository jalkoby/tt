require 'test_helper'

describe "the module for services" do
  it 'uses the current class name as namespace' do
    TestClass = Class.new do
      include TT::Model

      def label
        tt.attr(:label)
      end

      def human_name
        tt.r
      end
    end
    load_i18n(activerecord: { attributes: { test_class: { label: 'Label' } }, models: { test_class: { one: 'HumanKlass' } } })
    instance = TestClass.new
    assert_equal 'Label', instance.label
    assert_equal 'HumanKlass', instance.human_name
  end
end

require 'test_helper'

describe 'methods related to views' do
  before do
    @tt = ViewTranslator.new("tt", "spec")
  end

  describe '#t' do
    before do
      load_i18n(tt: {
        common: { too: "namespace_too" },
        spec: { foo: "spec_foo" }
      })
    end

    it "looks for a section translation first" do
      assert_equal @tt.t(:foo), "spec_foo"
    end

    it "looks into the section commons" do
      assert_equal @tt.t(:too), "namespace_too"
    end

    it "allows a custom options" do
      assert_equal @tt.t(:tar, default: "default_tar"), "default_tar"
    end
  end

  describe '#c' do
    before do
      load_i18n(
        common: { tar: 'global_tar' },
        tt: { common: { foo: "namespace_foo" }, }
      )
    end

    it "looks for a namespace translation first" do
      assert_equal @tt.c(:foo), "namespace_foo"
    end

    it "falls back to a global translation" do
      assert_equal @tt.c(:tar), "global_tar"
    end

    it "allows a custom options" do
      assert_equal @tt.c(:car, default: "default_car"), 'default_car'
    end
  end

  describe '#f' do
    before do
      load_i18n(
        form: { edit: "global_edit", save: "global_save" },
        tt: { form: { edit: "namespace_edit" } }
      )
    end

    it "looks for a namespace translation first" do
      assert_equal @tt.f(:edit), "namespace_edit"
    end

    it "falls back to a global translation" do
      assert_equal @tt.f(:save), "global_save"
    end

    it "allows a custom options" do
      assert_equal @tt.f(:commit, default: "default_commit"), "default_commit"
    end
  end
end

require "minitest/autorun"
require "minitest/mock"
require "rack/test"
require "action_controller"
require "t_t"

ViewTranslator = Class.new(TT::Translator) do
  lookup_key_method :f, :form
end

ModelTranslator = Class.new(TT::Translator)

I18n.backend = I18n::Backend::Simple.new
I18n.backend.store_translations(:en, {
  common: {
    tar: 'global_tar'
  },
  form: {
    edit: "global_edit",
    save: "global_save"
  },
  tt: {
    common: {
      foo: "namespace_foo"
    },
    form: {
      edit: "namespace_edit"
    },
    spec: {
      foo: "spec_foo"
    }
  }
})

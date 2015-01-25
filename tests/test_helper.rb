require "minitest/autorun"
require "minitest/mock"
require "rack/test"
require "action_controller"
require "t_t"

I18n.backend = I18n::Backend::Simple.new
I18n.backend.store_translations(:en, {
  common: {
    tar: 'global_tar'
  },
  crumbs: {
    index: 'global_index',
    new: 'global_new'
  },
  form: {
    edit: "global_edit",
    save: "global_save"
  },
  tooltip: {
    info: "global_info",
    notice: "global_notice"
  },
  tt: {
    common: {
      foo: "namespace_foo",
      bar: "namespace_bar"
    },
    crumbs: {
      new: 'namespace_new'
    },
    form: {
      edit: "namespace_edit"
    },
    spec: {
      foo: "spec_foo"
    },
    tooltip: {
      info: "namespace_info"
    }
  }
})

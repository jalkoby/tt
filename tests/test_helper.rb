require "minitest/autorun"
require "minitest/mock"
require "rack/test"
require "action_controller"
require "t_t"
require "t_t/action_factory"
require "t_t/action_macros"

ViewTranslator = TT.fork do
  lookup_key_method :f, :form
end

ARTranslator = TT.fork do
  settings prefix: :activerecord
end

I18n.backend = I18n::Backend::Simple.new

class Minitest::Spec
  after :each do
    I18n.backend.reload!
  end

  def load_i18n(data)
    I18n.backend.store_translations(:en, data)
  end
end

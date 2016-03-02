require "minitest/autorun"
require "minitest/mock"
require "rack/test"
require "action_controller/railtie"
require "active_record/railtie"
require "t_t"
require "t_t/i18n_sync"

ViewTranslator = TT.fork do
  lookup_key_method :f, :form
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

class << Minitest::Spec
  alias :focus :it

  if ENV.has_key?('FOCUS')
    def it(*args, &block)
    end
  end
end

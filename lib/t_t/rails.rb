options = {}
if defined?(ActiveRecord)
  options[:prefix] = :activerecord
elsif defined?(Mongoid)
  options[:prefix] = :mongoid
end

TT.base = TT::Rails = TT.fork(options) do
  def self.sync
    @sync
  end

  def self.sync_files(*locales)
    require 't_t/i18n_sync'
    options = locales.last.is_a?(Hash) ? locales.pop : {}
    files = Dir.glob(options.fetch(:path, 'config/locales/**/*.yml'))
    @sync = ::TT::I18nSync.new(locales.map(&:to_s), files)
    checker = @sync.checker
    ::Rails.application.reloaders << checker
    ActionDispatch::Reloader.to_prepare { checker.execute_if_updated }
  end
end

module TT
  module Helper
    extend ::ActiveSupport::Concern

    included do
      helper_method :tt

      prepend_before_filter { instance_variable_set(:@tt, ::TT::Rails.new(controller_path, action_name)) }
    end

    private

    def tt(*args)
      args.empty? ? @tt : @tt.t(*args)
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include ::TT::Helper
end

ActiveSupport.on_load(:action_mailer) do
  include ::TT::Helper
end

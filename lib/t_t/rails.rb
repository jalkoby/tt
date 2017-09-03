options = {}
if defined?(Mongoid)
  options[:prefix] = :mongoid
elsif defined?(ActiveRecord)
  options[:prefix] = :activerecord
end

TT.base = TT::Rails = TT.fork(options) do
  def self.sync(value = nil)
    @sync = value unless value.nil?
    @sync
  end
end

module TT
  module Helper
    extend ::ActiveSupport::Concern

    included do
      helper_method(:tt) if respond_to?(:helper_method)

      meth_name = respond_to?(:prepend_before_action) ? :prepend_before_action : :prepend_before_filter
      public_send(meth_name) { instance_variable_set(:@tt, ::TT::Rails.new(controller_path, action_name)) }
    end

    private

    def tt(*args)
      args.empty? ? @tt : @tt.t(*args)
    end
  end

  class Railtie < ::Rails::Railtie
    config.tt = ActiveSupport::OrderedOptions.new

    config.after_initialize do |app|
      if options = app.config.tt.sync
        require 't_t/i18n_sync'

        locale = :en
        glob = 'config/locales/**/*.yml'
        mark = ':t_t: '
        if options.is_a?(Symbol) || options.is_a?(String)
          locale = options
        elsif options.is_a?(Hash)
          locale = options[:locale] if options.has_key?(:locale)
          glob = options[:glob] if options.has_key?(:glob)
          if options[:mark]
            mark = (options[:mark] == :space) ? "\u200B" : options[:mark]
          end
        end

        file_sync = ::TT::I18nSync.new(locale.to_s, Dir.glob(glob), mark)
        TT::Rails.sync(file_sync)
        ::Rails.application.reloaders << file_sync.checker
        ActionDispatch::Reloader.to_prepare { file_sync.checker.execute_if_updated }
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include ::TT::Helper
end

ActiveSupport.on_load(:action_mailer) do
  include ::TT::Helper
end

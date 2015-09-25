require "active_support/lazy_load_hooks"
require "i18n"

module TT
  class Translator
    class << self
      def lookup_key_method(meth_name, path)
        class_eval <<-RUBY
          def #{ meth_name }(key, options = {})
            I18n.t "\#{ _config.fetch(:ns) }.#{ path }.\#{ key }",
              { default: [:"#{ path }.\#{ key }"] }.merge(options)
          end
        RUBY
      end

      def config(&block)
        @config ||= { orm: :activerecord }

        if block_given?
          yield @config
        else
          @config
        end
      end
    end

    lookup_key_method :c, :common

    def initialize(ns, section = nil)
      @config = {
        ns: ns,
        root: (section ? "#{ ns }.#{ section }" : ns)
      }

      [:attributes, :enums, :errors, :models].each do |i|
        @config[i] = _build_lookup(ns, i)
      end
    end

    def attr(name, model_name = nil)
      path, defaults = _resolve_lookup(model_name, :attributes, name)
      I18n.t path, default: defaults
    end

    def enum(name, kind, model_name = nil)
      path, defaults = _resolve_lookup(model_name, :enums, "#{name}.#{kind}")
      I18n.t path, default: defaults
    end

    def e(attr_name, error_name, *args)
      options = args.extract_options!
      model_name = args.first
      key = (attr_name == :base) ? error_name : "#{ attr_name }.#{ error_name }"
      path, defaults = _resolve_lookup(model_name, :errors, key)
      I18n.t path, { default: defaults }.merge(options)
    end

    def r(model_name = nil)
      rs(model_name, 1)
    end

    def rs(model_name = nil, count = 10)
      path, defaults = _resolve_lookup(model_name, :models)
      I18n.t path, default: defaults, count: count
    end

    def t(key, options = {})
      I18n.t "#{ _config.fetch(:root) }.#{ key  }", options
    end

    private

    def _config
      @config
    end

    def _build_lookup(ns, type)
      orm = self.class.config.fetch(:orm)
      parts = ns.to_s.underscore.split('/')
      model_path = parts.join('.')

      root = "#{ orm }.#{ type }.#{ model_path }"
      defaults = [:"#{ type }.#{ model_path }"]

      if parts.length > 1
        pure_model = parts.last
        defaults << :"#{ orm }.#{ type }.#{ pure_model }"
        defaults << :"#{ type }.#{ pure_model }"
      end

      [root, defaults]
    end

    def _resolve_lookup(model_name, type, key = nil)
      lookup = model_name ? _build_lookup(model_name, type) : _config.fetch(type)
      if key
        return "#{ lookup.first }.#{ key }", lookup.last.map { |i| :"#{ i }.#{ key }" }
      else
        return *lookup
      end
    end

    ActiveSupport.run_load_hooks(:tt, self)
  end
end

if defined?(ActionPack) || defined?(ActionMailer)
  module TT::Helper
    extend ::ActiveSupport::Concern

    included do
      helper_method :tt
    end

    private

    def tt(*args)
      @tt ||= ::TT::Translator.new(controller_path, action_name)
      args.empty? ? @tt : @tt.t(*args)
    end
  end

  ActiveSupport.on_load(:action_controller) do
    include ::TT::Helper
  end

  ActiveSupport.on_load(:action_mailer) do
    include ::TT::Helper
  end
end

require "active_support/inflector"
require "active_support/lazy_load_hooks"
require "active_support/multibyte/chars"
require "i18n"

module TT
  module Utils
    extend self

    DOWNCASE = lambda { |str, locale| (locale == :en) ? str.downcase : str.mb_chars.downcase.to_s }

    def lookup(prefix, base_suffix = :base)
      prefix ? prefix_lookup(prefix, base_suffix) : simple_lookup(base_suffix)
    end

    def to_parts(str)
      str.to_s.underscore.split(/\.|\//)
    end

    private

    def simple_lookup(base_suffix)
      lambda do |ns, type|
        parts = to_parts(ns)
        model_path = parts.join('.')

        root = "#{ type }.#{ model_path }"

        defaults = []
        defaults << :"#{ type }.#{ parts.last }" if parts.length > 1
        defaults << :"#{ type }.#{ base_suffix }"

        [root, defaults]
      end
    end

    def prefix_lookup(prefix, base_suffix)
      lambda do |ns, type|
        parts = to_parts(ns)
        model_path = parts.join('.')

        root = "#{ prefix }.#{ type }.#{ model_path }"
        defaults = [:"#{ type }.#{ model_path }"]

        if parts.length > 1
          pure_model = parts.last
          defaults << :"#{ prefix }.#{ type }.#{ pure_model }"
          defaults << :"#{ type }.#{ pure_model }"
        end
        defaults << :"#{ prefix }.#{ type }.#{ base_suffix }"
        defaults << :"#{ type }.#{ base_suffix }"

        [root, defaults]
      end
    end
  end

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

      def settings(custom = nil)
        @settings ||= {}

        if custom
          unknown = custom.keys.detect { |key| ![:downcase, :prefix].include?(key) }
          if unknown
            raise ArgumentError, "TT doesn't know `#{ unknown }` option in the configuration"
          else
            @settings.merge!(custom)
          end
        end

        @settings
      end
    end

    lookup_key_method :c, :common

    def initialize(ns, section = nil)
      @lookup = Utils.lookup(self.class.settings[:prefix])
      @err_lookup = Utils.lookup(self.class.settings[:prefix], :messages)

      ns = Utils.to_parts(ns).join('.')
      @config = { ns: ns, root: (section ? "#{ ns }.#{ section }" : ns) }
      default_model = ns.to_s.singularize
      [:actions, :attributes, :enums, :models].each do |i|
        @config[i] = @lookup.call(default_model, i)
      end
      @config[:errors] = @err_lookup.call(default_model, :errors)

      @downcase = self.class.settings.fetch(:downcase, Utils::DOWNCASE)
    end

    def a(name, model_name = nil, custom = {})
      path, defaults = _resolve(model_name, :actions, name)

      resource = r(model_name)
      resources = rs(model_name)
      I18n.t path, {
        default: defaults, r: @downcase.call(resource, I18n.locale), R: resource,
        rs: @downcase.call(resources, I18n.locale), RS: resources
      }.merge!(custom)
    end

    def attr(name, model_name = nil)
      path, defaults = _resolve(model_name, :attributes, name)
      I18n.t path, default: defaults
    end

    def enum(name, kind, model_name = nil)
      path, defaults = _resolve(model_name, :enums, "#{ name }.#{ kind }")
      I18n.t path, default: defaults
    end

    def e(attr_name, error_name, *args)
      custom = args.last.is_a?(Hash) ? args.pop : {}
      model_name = args.first
      path, defaults = _resolve_errors(model_name, attr_name, error_name)
      I18n.t path, { default: defaults }.merge!(custom)
    end

    def r(model_name = nil)
      rs(model_name, 1)
    end

    def rs(model_name = nil, count = 10)
      path, defaults = _resolve(model_name, :models)
      I18n.t path, default: defaults, count: count
    end

    def t(key, custom = {})
      defaults = [:"#{ _config.fetch(:ns) }.common.#{ key }"].concat(Array(custom[:default]))
      I18n.t "#{ _config.fetch(:root) }.#{ key  }", custom.merge(default: defaults)
    end

    private

    def _config
      @config
    end

    def _resolve(model_name, type, key = nil)
      _resolve_with_lookup(@lookup, model_name, type, key)
    end

    def _resolve_errors(model_name, attr_name, error_name)
      if attr_name == :base
        _resolve_with_lookup(@err_lookup, model_name, :errors, error_name)
      else
        path, _defaults = _resolve(model_name, :errors, "#{ attr_name }.#{ error_name }")
        defaults = _defaults + ["errors.messages.#{ error_name }".to_sym]
        return path, defaults
      end
    end

    def _resolve_with_lookup(lookup, model_name, type, key)
      paths = model_name ? lookup.call(model_name, type) : _config.fetch(type)
      if key
        return "#{ paths.first }.#{ key }", paths.last.map { |i| :"#{ i }.#{ key }" }
      else
        return *paths
      end
    end

    ActiveSupport.run_load_hooks(:tt, self)
  end

  def self.fork(&block)
    Class.new(Translator, &block)
  end

  def self.config(options = {}, &block)
    Translator.settings(options)
    Translator.instance_exec(&block) if block_given?
  end
end

if defined?(ActionPack) || defined?(ActionMailer)
  module TT::Helper
    extend ::ActiveSupport::Concern

    included do
      helper_method :tt

      prepend_before_filter { instance_variable_set(:@tt, ::TT::Translator.new(controller_path, action_name)) }
    end

    private

    def tt(*args)
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

if defined?(ActiveRecord)
  ActiveSupport.on_load(:active_record) do
    TT.config(prefix: :activerecord)
  end
end

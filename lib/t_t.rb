require "active_support/lazy_load_hooks"
require "i18n"

module TT
  class Translator
    def self.shortcut(meth_name, section)
      class_eval <<-RUBY
        def #{ meth_name }(key, options = {})
          I18n.t "\#{ ns }.#{ section }.\#{ key }",
            { default: :"#{ section }.\#{ key }" }.merge(options)
        end
      RUBY
    end

    def initialize(ns, section)
      @ns = ns
      @section = section
    end

    def t(key, options = {})
      I18n.t "#{ ns }.#{ section }.#{ key  }",
        { default: :"#{ ns }.common.#{ key  }" }.merge(options)
    end

    shortcut :c, :common
    shortcut :f, :form

    def attr(name, klass = context_klass)
      klass.human_attribute_name(name)
    end

    def enum(name, kind, klass = context_klass)
      klass.human_attribute_name("#{ name }_#{ kind }")
    end

    def resource(klass = context_klass)
      klass.model_name.human(count: 1)
    end
    alias_method :record, :resource

    def resources(klass = context_klass)
      klass.model_name.human(count: 10)
    end
    alias_method :records, :resources

    def no_resources(klass = context_klass)
      klass.model_name.human(count: 0)
    end
    alias_method :no_records, :no_resources

    private

    attr_reader :ns, :section

    def context_klass
      return @context_klass if @context_klass

      @context_klass = ns.split('.').map(&:classify).join('::').singularize.constantize
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
      @tt ||= ::TT::Translator.new(controller_path.gsub('/', '.'), action_name)
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

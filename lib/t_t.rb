require "i18n"

module TT
  class Translator
    def initialize(ns, section)
      @ns = ns
      @section = section
    end

    def t(key, options = {})
      I18n.t "#{ ns }.#{ section }.#{ key  }",
        { default: :"#{ ns }.common.#{ key  }" }.merge(options)
    end

    def c(key, options = {})
      I18n.t "#{ ns }.common.#{ key }",
        { default: :"common.#{ key }" }.merge(options)
    end

    def f(key, options = {})
      I18n.t "#{ ns }.form.#{ key }",
        { default: :"form.#{ key }" }.merge(options)
    end

    def tip(key, options = {})
      I18n.t "#{ ns }.tooltip.#{ key }",
        { default: :"tooltip.#{ key }" }.merge(options)
    end

    def crumb(key, options = {})
      I18n.t "#{ ns }.crumbs.#{ key }",
        { default: :"crumbs.#{ key }" }.merge(options)
    end

    def attr(name, klass = context_klass)
      klass.human_attribute_name(name)
    end

    def enum(name, kind, klass = context_klass)
      klass.human_attribute_name("#{ name }_#{ kind }")
    end

    def resource(klass = context_klass)
      klass.model_name.human(count: 1)
    end

    def resources(klass = context_klass)
      klass.model_name.human(count: 10)
    end

    def no_resources(klass = context_klass)
      klass.model_name.human(count: 0)
    end

    private

    attr_reader :ns, :section

    def context_klass
      return @context_klass if @context_klass

      @context_klass = ns.split('.').map(&:classify).join('::').singularize.constantize
    end
  end
end

if defined?(ActionPack)
  module ::TT::ActionPack
    extend ActiveSupport::Concern

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
    include ::TT::ActionPack
  end
end

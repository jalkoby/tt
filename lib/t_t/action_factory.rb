require 't_t/action_macros'

module TT
  class ActionFactory
    class Locale
      def initialize
        @rules = {}
        @list  = {}
        @meta  = {}
      end

      def set_rule(k, &block)
        @rules[k] = block
        @list[k]  = []
        @meta[k]  = {}
      end

      def use_rule_for(k, data)
        if data.is_a?(Hash)
          @meta[k] = @meta.fetch(k).merge(data)
          @list[k].concat(data.keys)
        else
          @list[k].concat(data)
        end
      end

      def generate(rkey, config)
        rule = @rules.fetch(rkey)

        @list.fetch(rkey).inject({}) do |r, mkey|
          r[mkey] = rule.call(config, @meta.fetch(rkey).fetch(mkey, {}))
          r
        end
      end
    end

    def initialize(*locales)
      @actions = {}
      @locales = {}
      @macro = {}
      @exceptions = {}

      locales.each do |l|
        @actions[l] = {}
        @exceptions[l] = {}
        @locales[l] = Locale.new
      end
    end

    def action(key, list)
      list.each do |locale, config|
        config = { base: config } if config.is_a?(String)
        @actions[locale][key] = config
      end
    end

    def add_macro(key, &block)
      @macro[key] = block
    end

    def add_exception(mkey, schema)
      schema.each do |key, list|
        list.each do |lkey, text|
          @exceptions[lkey][key] ||= {}
          @exceptions[lkey][key][mkey] = text
        end
      end
    end

    def macro(key, *args)
      @macro.fetch(key).call(*args)
    end

    def set_rule(lkey, *args, &block)
      @locales.fetch(lkey).set_rule(*args, &block)
    end

    def use_rule_for(lkey, *args, &block)
      @locales.fetch(lkey).use_rule_for(*args, &block)
    end

    def as_hash
      @actions.inject({}) do |hash, (lkey, list)|
        locale = @locales.fetch(lkey)

        actions = list.inject({}) do |ra, (key, config)|
          base = config.fetch(:base)
          action = Array(config[:rules]).inject(base: base) { |r, rkey| r.merge(locale.generate(rkey, config)) }
          ra[key] = action.merge(@exceptions[lkey].fetch(key, {}))
          ra
        end

        hash[lkey] = { actions: actions }
        hash
      end
    end
  end

  def self.define_actions(*args)
    @action_factory ||= ActionFactory.new(*args)
    yield @action_factory
    @action_factory.as_hash.each { |locale, data| I18n.backend.store_translations(locale, data) }
  end
end

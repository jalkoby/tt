require 't_t/builtin_rules'

module TT
  class ActionFactory
    Action = Struct.new(:base, :rules)
    Option = Struct.new(:key, :meta) do
      def self.parse(list)
        list.flat_map do |item|
          item.respond_to?(:map) ? item.map { |key, meta| new(key, meta) } : new(item)
        end
      end
    end

    class Locale
      def initialize
        @rules = {}
        @list  = {}
      end

      def rule(key, &block)
        @rules[key] = block
        @list[key]  = []
      end

      def use_rule_for(key, *list)
        @list[key].concat(Option.parse(list))
      end

      def knows_rule?(key)
        @rules.has_key?(key)
      end

      def compile(action)
        action.rules.inject(base: action.base) do |result, a_option|
          rule = @rules.fetch(a_option.key)

          @list.fetch(a_option.key).each do |r_option|
            base = result.fetch(r_option.key, action.base)
            result[r_option.key] = rule.call(base, a_option.meta, r_option.meta)
          end

          result
        end
      end
    end

    def initialize(*locales)
      @actions = {}
      @locales = {}
      @exceptions = {}

      locales.each do |lkey|
        @actions[lkey]    = {}
        @exceptions[lkey] = {}
        @locales[lkey]    = Locale.new
      end
    end

    def for(key, &block)
      yield @locales.fetch(key) { raise_error "`#{ key }` is unknown" }
    end

    def activate_rules(*list)
      list.each { |rkey| BuiltinRules.send(rkey, self) }
    end

    def add(akey, list)
      @locales.each do |lkey, locale|
        unless action = list[lkey]
          raise_error "action `#{ akey }` is missing for `#{ lkey }` locale"
        end

        action = Action.new(action, []) if action.is_a?(String)

        if action.is_a?(Action)
          action.rules.each do |rule|
            next if locale.knows_rule?(rule.key)
            raise_error "`#{ rule.key }` is an unknown rule for `#{ lkey }` locale"
          end
        else
          raise_error "the value of `#{ akey }` action for `#{ lkey }` locale has a wrong type"
        end

        @actions[lkey][akey] = action
      end
    end

    def with_rules(base, *list)
      Action.new(base, Option.parse(list))
    end

    def add_exception(mkey, schema)
      schema.each do |lkey, list|
        raise_error("`#{ lkey }` is an unknown locale") unless @locales.has_key?(lkey)

        list.each do |akey, str|
          unless @actions[lkey].has_key?(akey)
            raise_error "`#{ akey }` action is not specified. Do it before add an exception"
          end

          @exceptions[lkey][akey] ||= {}
          @exceptions[lkey][akey][mkey] = str
        end
      end
    end

    def as_hash
      @actions.inject({}) do |hash, (lkey, list)|
        locale = @locales.fetch(lkey)

        actions = list.inject({}) do |result, (akey, action)|
          keys = locale.compile(action).merge!(@exceptions[lkey].fetch(akey, {}))
          keys.each do |mkey, str|
            result[mkey] = {} unless result.has_key?(mkey)
            result[mkey][akey] = str
          end

          result
        end

        hash.merge!(lkey => { actions: actions })
      end
    end

    private

    def raise_error(base)
      raise ArgumentError, "t_t: #{ base }"
    end
  end

  def self.define_actions(*args)
    f = ActionFactory.new(*args)
    yield f
    f.as_hash
  end
end

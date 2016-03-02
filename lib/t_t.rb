require 't_t/base'

module TT
  def self.fork(*args, &block)
    klass = Class.new(Base)
    klass.config(*args, &block)
    klass
  end

  def self.config(*args, &block)
    base.config(*args, &block)
  end

  def self.base(value = nil)
    @base || Base
  end

  def self.base=(value)
    @base = value
  end

  def self.raise_error(base)
    raise ArgumentError, "t_t: #{ base }"
  end

  def self.define_actions(*args)
    require "t_t/action_factory"
    f = ActionFactory.new(*args)
    yield f
    f.as_hash
  end

  def self.const_missing(name)
    super unless name.to_s == 'Translator'
    puts ""
    puts "t_t: TT::Translator is deprecated. Please, use #{ base } instead"
    base
  end
end

if defined?(ActionPack)
  require 't_t/rails'
end

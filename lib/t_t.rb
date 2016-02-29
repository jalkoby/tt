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
end

if defined?(ActionPack)
  require 't_t/rails'
end

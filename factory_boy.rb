require "pry"

class FactoryBoy
  @@factories = {}

  class << self
    def define_factory(class_name, &block)
      unless @@factories[class_name.name]
        attribute_hash = if block_given?
          DSL.run(block).attribute_hash
        else
          {}
        end
        @@factories[class_name.name] = attribute_hash
        "defined factory"
      else
        "factory already defined"
      end
    end

    def build class_name, options={}
      if @@factories[class_name.name]
        inst = class_name.new
        options = @@factories[class_name.name].merge options
        options.each do |attr, value|
          attr = (attr.to_s + "=").to_sym
          if class_name.instance_methods.include? attr
            inst.public_send attr, value
          end
        end
        inst
      else
        "factory not defined"
      end
    end
  end
end

class DSL
  attr_accessor :attribute_hash

  def initialize
    @attribute_hash = {}
  end

  def self.run block
    dsl = new
    dsl.instance_eval &block
    dsl
  end

  def method_missing method_sym, argument, &block
    attribute_hash[method_sym] = argument
  end
end

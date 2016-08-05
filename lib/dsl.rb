class FactoryBoy
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
end

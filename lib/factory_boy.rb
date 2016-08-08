require_relative "dsl"

class FactoryBoy
  @@factories = {}

  class << self
    def define_factory(factory_name, &block)
      factory_name = tokenize_factory_name factory_name
      unless @@factories[factory_name]
        attribute_hash = if block_given?
          DSL.run(block).attribute_hash
        else
          {}
        end
        @@factories[factory_name] = attribute_hash
        "defined factory"
      else
        "factory already defined"
      end
    end

    def build factory_name, options={}

      factory_name = tokenize_factory_name factory_name
      if @@factories[factory_name]
        inst = Object.const_get(camelize factory_name).new
        options = @@factories[factory_name].merge options
        options.each do |attr, value|
          attr = (attr.to_s + "=").to_sym
          if inst.class.instance_methods.include? attr
            inst.public_send attr, value
          end
        end
        inst
      else
        "factory not defined"
      end
    end

    private

    def tokenize_factory_name factory_name
      factory_name = factory_name.name if factory_name.is_a? Class
      (underscore factory_name).to_sym
    end

    def underscore str
      str.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

    def camelize str
      str = str.to_s if str.is_a? Symbol
      str.split('_').collect(&:capitalize).join
    end
  end
end


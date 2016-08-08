require_relative "dsl"

class FactoryBoy
  @@factories = {}

  class << self
    def define_factory(class_name, &block)
      class_name = tokenize_class_name class_name
      unless @@factories[class_name]
        attribute_hash = if block_given?
          DSL.run(block).attribute_hash
        else
          {}
        end
        @@factories[class_name] = attribute_hash
        "defined factory"
      else
        "factory already defined"
      end
    end

    def build class_name, options={}
      class_name = tokenize_class_name class_name
      if @@factories[class_name]
        inst = Object.const_get(camelize class_name).new
        options = @@factories[class_name].merge options
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

    def tokenize_class_name class_name
      class_name = class_name.name if class_name.is_a? Class
      (underscore class_name).to_sym
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


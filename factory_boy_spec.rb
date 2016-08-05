require "rspec"
require "./factory_boy"

class User; attr_accessor :name; end
class SlightlyAppearingInThisMovie; end

RSpec.configure do |config|
  config.after(:each) do
    FactoryBoy.class_variable_set :@@factories, {}
  end
end

RSpec.describe "FactoryBoy" do
  it "defines FactoryBoy" do
    expect(defined? FactoryBoy).to be_truthy
  end

  context ".define_factory" do
    it "defines factory if given an existing model" do
      expect(FactoryBoy.define_factory User).to eq "defined factory"
    end

    it "raises error if given an undefined constant" do
      expect { FactoryBoy.define_factory NotAppearingInThisMovie }.to raise_error NameError
    end

    it "ignores factory if already defined" do
      FactoryBoy.define_factory User
      expect(FactoryBoy.define_factory User).to eq "factory already defined"
    end
  end

  context "factories with no defaults" do
    context ".build" do
      before { FactoryBoy.define_factory User }

      let(:build_with_arguments) { FactoryBoy.build User, name: "foobar" }

      it "ignores builds for nonexisting factories" do
        expect(FactoryBoy.build SlightlyAppearingInThisMovie).to eq "factory not defined"
      end

      it "builds a bare instance when not given any arguments" do
        expect(FactoryBoy.build User).to be_an_instance_of(User)
      end

      it "builds instance with arguments when given proper ones" do
        expect(build_with_arguments).to be_an_instance_of(User)
        expect(build_with_arguments.name).to eq "foobar"
      end

      it "ignores mismatched attributes" do
        expect(FactoryBoy.build User, foo: "bar").to be_an_instance_of(User)
      end
    end
  end

  context "factories with default values" do
    before do
      FactoryBoy.define_factory User do
        name "Christie"
      end
    end

    context "no arguments given" do
      subject {FactoryBoy.build User}
      it "builds with default values" do
        expect(subject).to be_an_instance_of(User)
        expect(subject.name).to eq "Christie"
      end
    end

    context "overriding arguments given" do
      subject {FactoryBoy.build User, name: "Jesse"}
      it "builds with given arguments, overriding defaults" do
        expect(subject).to be_an_instance_of(User)
        expect(subject.name).to eq "Jesse"
      end
    end
  end
end

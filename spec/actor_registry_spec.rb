require File.dirname(__FILE__) + '/spec_helper'
require 'nanite'


describe Nanite::ActorRegistry do
  
  before(:all) do
    class WebDocumentImporter
      include Nanite::Actor
      expose :import, :cancel

      def import
        1
      end
      def cancel
        0
      end
    end

    module Actors
      class ComedyActor
        include Nanite::Actor
        expose :fun_tricks
        def fun_tricks
          :rabbit_in_the_hat
        end
      end
    end
  end
  
  before(:each) do
    log = mock('log', :info => nil)
    @registry = Nanite::ActorRegistry.new(log)
  end

  it "should know about all services" do
    @registry.register(WebDocumentImporter.new, nil)
    @registry.register(Actors::ComedyActor.new, nil)
    @registry.services.should == ["/actors/comedy_actor/fun_tricks", "/web_document_importer/import", "/web_document_importer/cancel"]
  end

  it "should not register anything except Nanite::Actor" do
    lambda{@registry.register(String.new, nil)}.should raise_error(ArgumentError)
  end

  it "should register an actor" do
    importer = WebDocumentImporter.new
    @registry.register(importer, nil)
    @registry.actors['web_document_importer'].should == importer
  end

  it "should handle actors registered with a custom prefix" do
    importer = WebDocumentImporter.new
    @registry.register(importer, 'monkey')
    @registry.actors['monkey'].should == importer
  end
end
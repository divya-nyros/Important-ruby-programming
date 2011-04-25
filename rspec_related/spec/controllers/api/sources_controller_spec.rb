require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')



describe Api::SourcesController do
  context "GET: index" do
   before :each do
      @sources = Array.new { mock_model(Source) }
      Source.stub!(:find).and_return(@sources)
    end
    
     it "should be successful" do
       get :index,:format=>:xml
       response.should be_true
     end
    
    it "should load a list of all sources" do
      Source.should_receive(:find).with(:all).and_return(@sources)
      get :index,:format=>:xml
    end

    it "should assign a sources" do
      get :index,valid_params_with_source
    end

  end
end
def valid_params_with_source
    {
      "sources" => Factory.attributes_for(:source).stringify_keys!
    }
end
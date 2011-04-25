class Api::SourcesController < Api::ApiController
  skip_before_filter :authenticate_user!

  def index
    sources = Source.all

    respond_to do |format|
      format.xml { render :xml => sources.to_xml }
      format.json { render :json => sources.to_json }
      format.html { }
    end
  end
end
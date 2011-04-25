class Api::ApiController < ApplicationController
  layout 'api'
  skip_before_filter :verify_authenticity_token
  
  def determine_source
    @source ||= case
      when params["Signature"] =~ /infusion/ then :infusion_soft
      else :unknown
    end
  end
end
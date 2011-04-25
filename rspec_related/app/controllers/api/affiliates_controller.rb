class Api::AffiliatesController < Api::ApiController
  # TODO: secure this with API keys or something
  skip_before_filter :authenticate_user!, :only => [ :create ]
  
  def create
    @affiliate = Affiliate.new(params[:affiliate])
    
    if params[:promoter_id]
      begin
        @affiliate.promoter = Affiliate.find(params[:promoter_id])
      rescue Exception => e
        logger.error e
        # TODO: notify/track invalid promoter codes
      end
    end
    
    @phone = @affiliate.phone_numbers.build(params[:phone_number])
    if @phone.valid?
      @affiliate.phone_numbers << @phone
    end
    
    @address = @affiliate.addresses.build(params[:address])
    if @address.valid?
      @affiliate.addresses << @address
    end
    
    if @affiliate.save
      if params[:redirect_url]
        redirect_to params[:redirect_url]
      end
    else
      render :action => :oops
    end
  end
end

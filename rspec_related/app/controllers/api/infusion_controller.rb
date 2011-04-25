class Api::InfusionController < Api::ApiController
  # TODO: secure this with API keys or something
  skip_before_filter :authenticate_user! #, :only => [ :create ]
  
  def create_affiliate
    if request.post?
      logger.info params.to_yaml
      
      # build the primary affiliate data
      @affiliate = Affiliate.new
      @affiliate.first_name     = params[:FirstName]
      @affiliate.last_name      = params[:LastName]
      @affiliate.email          = params[:Email]
      @affiliate.affiliate_code = params[:Id]
      
      if @affiliate.valid?
        # build contact method associations
        @address = @affiliate.addresses.build(
          :street   => params[:StreetAddress1],
          :unit     => params[:StreetAddress2],
          :city     => params[:City],
          :state    => params[:State],
          :zip      => params[:PostalCode],
          :category => params[:Address1Type].to_s.downcase
        )
        @affiliate.addresses << @address if @address.valid?
      
        5.times do |i|
          unless params["Phone#{i}"].blank?
            @phone_number = @affiliate.phone_numbers.build(
              :data     => params["Phone#{i}"],
              :category => params["Phone#{i}Type"].to_s.downcase
            )
            @affiliate.phone_numbers << @phone_number if @phone_number.valid?
          end
        end
      
        unless params[:Website].blank?
          @affiliate.websites << @affiliate.websites.build(:data => params[:Website])
        end

        @affiliate.save
      end
      
      render :nothing => true, :status => 200
    end
    
    # renders instructions by default
  end

=begin #Expected POST Params
--- !map:HashWithIndifferentAccess 
AffiliateTermsandConditions: Yes I agree to the Affiliate Terms and Conditions
City: Davenport
StreetAddress1: 133 Sweet Bay St.
Groups: "176"
Signature: "NSM Error getting value: com.infusion.crm.modules.contact.Contact.getSignature()"
SSNTID: 430-39-1837
OwnerID: "0"
LastName: Cartwright
PostalCode: "33837"
DateCreated: 2010-09-02 21:45:11.0
HTMLSignature: "NSM Error getting value: com.infusion.crm.modules.contact.Contact.getHTMLSignature()"
Address2Street1: 133 Sweet Bay St.
FirstName: Jason
State2: FL
Id: "114"
CompanyID: "0"
PostalCode2: "33837"
Website: www.yoursitedonerightnow.com
LastUpdated: 2010-09-02 21:47:32.0
Company: Enspired Software
City2: Davenport
Phone1: (863) 438-1844
State: FL
Email: jason@enspiredsoftware.com
CreatedBy: "5"
AssistantName: Fatima
AssistantEmail: fatima@enspiredsoftware.com
LastUpdatedBy: "5"
=end

=begin #Possible Infusion POST Params
  Address1Type
  Address2Street1
  Address2Street2
  Address2Type
  Address3Street1
  Address3Street2
  Address3Type
  Anniversary
  AssistantName
  AssistantPhone
  BillingInformation
  Birthday
  City
  City2
  City3
  Company
  CompanyID
  ContactNotes
  ContactType
  Country
  Country2
  Country3
  CreatedBy
  DateCreated
  Email
  EmailAddress2
  EmailAddress3
  Fax1
  Fax1Type
  Fax2
  Fax2Type
  FirstName
  Groups
  HTMLSignature
  Id
  JobTitle
  LastName
  LastUpdated
  LastUpdatedBy
  Leadsource
  MiddleName
  Nickname
  OwnerID
  Phone1
  Phone1Ext
  Phone1Type
  Phone2
  Phone2Ext
  Phone2Type
  Phone3
  Phone3Ext
  Phone3Type
  Phone4
  Phone4Ext
  Phone4Type
  Phone5
  Phone5Ext
  Phone5Type
  PostalCode
  PostalCode2
  PostalCode3
  ReferralCode
  Signature
  SpouseName
  State
  State2
  State3
  StreetAddress1
  StreetAddress2
  Suffix
  Title
  Website
  ZipFour1
  ZipFour2
  ZipFour3
=end  

end

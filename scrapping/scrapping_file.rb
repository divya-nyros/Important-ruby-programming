require 'rubygems'
require 'mysql'

require 'mechanize'
require 'hpricot'
  
  
  auth = {'email' => 'justyna.sosinska@workforcesolution.co.uk', 'password' => 'workforce'}
  @auth = auth
  @agent = Mechanize.new
  @agent.user_agent_alias = 'Mac FireFox'
  #~ @keep_alive_time  = 300
  @page = @agent.get('http://www.seriousteachers.com/views/upgrade_posting.asp')
  login_form = @page.forms.first
  login_form.email= @auth['email']
  login_form.password = @auth['password']
  @page = @agent.submit(login_form)
   user=Mysql.new('localhost','root','root','teachers_rec_development')




100.times do |i|
   i = 25701+ i
#~ i=2345
 puts i

  begin
 @page = @agent.get("http://www.seriousteachers.com/te2/resume.asp?idteacher=676338&idresume=#{i}&idemployer=7214&idjob=180657")
  result_name = (@page/"table[1]/tr[2]/td").inner_text

results = user.query("SELECT id from scrap_users ORDER BY id DESC limit 0,1;")

if results.nil?
   @row = 1
else
     results.each do |row|
           myid = row.to_s
          @row = myid.to_i + 1
          break
     end
end



     if @page.link_with(:text => /Personal CV/)
       begin
            result_cv_val= @agent.click(@page.link_with(:text => /Personal CV/))           
              FileUtils.mkdir_p "resume/#{@row}"
              doc = (result_cv_val/"div/iframe").attribute("src").value
              cv_url = doc
              if doc.include? ".DOC"
                 @agent.get(doc).save("resume/#{@row}/#{@row}.DOC")
                 mycv = "#{@row}.DOC"
              elsif doc.include? ".PDF"
                  @agent.get(doc).save("resume/#{@row}/#{@row}.PDF")
                   mycv = "#{@row}.PDF"
              else            
                  mycv = " "  
                  cv_url = " "              
                end
           rescue 
                 mycv = " "  
                cv_url = " " 
             end
      end
  

if @page.link_with(:text => /My Certificate/)
  begin
          result_certificate_val=@agent.click(@page.link_with(:text => /My Certificate/))
          FileUtils.mkdir_p "certificates/#{@row}"
          result_certificate_val.save_as("certificates/#{@row}/#{result_certificate_val.filename}")
          mycertificate = result_certificate_val.filename
    rescue
     mycertificate = " "
    end
else  
     mycertificate = " "

end
   
   
result_image = @page.search("img[@src]").map {|src| src['src']}

if result_image
 
                  result_image.each do |image| 

                              if image.match("../upload_teacher/imageteacher/")
                                    begin
                                        FileUtils.mkdir_p "profile_images/#{@row}"                                    
                                        @userimage = "#{File.basename image}"
                                         result_image_val=@agent.get("http://www.seriousteachers.com/upload_teacher/imageteacher/#{File.basename image}").save_as("profile_images/#{@row}/#{File.basename image}")
                                         break
                                     rescue
                                          puts "http://www.seriousteachers.com/upload_teacher/imageteacher/#{File.basename image}"
                                          @userimage = " "
                                     end
                                else                                   
                                    @userimage = " "                              
                                end
                          end
        else        
           @userimage = " "
  end

result_profile_url="http://www.seriousteachers.com/te2/resume.asp?idteacher=676338&idresume=#{i}&idemployer=7214&idjob=180657"

result_cv_url= cv_url

if mycertificate != " "
result_certificate_url="http://www.seriousteachers.com/certificate/#{mycertificate}"
else
result_certificate_url =" "
end
  
if @userimage != " "
result_image_url= "http://www.seriousteachers.com/upload_teacher/imageteacher/#{@userimage}"
else
result_image_url =" "
end


#~ puts result_profile_url
#~ puts result_cv_url
#~ puts result_certificate_url
#~ puts result_image_url

result_birth_val = (@page/"table[1]/tr/td").inner_text.match(/\d{2}\D{4}\/(\d{4})\b/).to_s
result_email = (@page/"table[1]/tr").inner_text.match(/(\w+?@\w+?\x2E.+)/).to_s
result_telephone_val = (@page/"table[1]/tr/td").inner_text.match(/(\+)?([-\._\(\) ]?[\d]{3,20}[-\._\(\) ]?){2,10}/).to_s
@result_profile_title = (@page/"table[2]").inner_text.match('Introduction').to_s

if  @result_profile_title == 'Introduction'
result_Introduction = (@page/"table[2]/tr[2]/td[1]/p/font").inner_text.gsub(/'/,'')
result_field = (@page/"table[2]/tr[4]/td[2]").inner_text
result_year_of_exp_value = (@page/"table[2]/tr[5]/td[2]").inner_text
result_current_res_val = (@page/"table[2]/td").inner_text
result_native_val = (@page/"table[2]/tr[8]/td[2]").inner_text
result_counties_inte_val= (@page/"table[2]/tr[9]/td[2]").inner_text
result_education_val= (@page/"table[2]/tr[10]/td[2]").inner_text
result_memberships_val= (@page/"table[2]/tr[11]/td[2]").inner_text
result_achievements_val= (@page/"table[2]/tr[12]/td[2]").inner_text
result_skills_val= (@page/"table[2]/tr[13]/td[2]").inner_text
result_exp_val= (@page/"table[2]/tr[14]/td[2]").inner_text
result_lang_val= (@page/"table[2]/tr[15]/td[2]").inner_text
result_reference_val= (@page/"table[2]/tr[16]/td[2]").inner_text
result_refe_val1= (@page/"table[2]/tr[17]/td[1]").inner_text
else
result_Introduction= " "
result_field = (@page/"table[2]/tr[2]/td[2]").inner_text
result_year_of_exp_value = (@page/"table[2]/tr[3]/td[2]").inner_text
result_current_res_val = (@page/"table[2]/td").inner_text
result_native_val = (@page/"table[2]/tr[6]/td[2]").inner_text
result_counties_inte_val= (@page/"table[2]/tr[7]/td[2]").inner_text
result_education_val= (@page/"table[2]/tr[8]/td[2]").inner_text
result_memberships_val= (@page/"table[2]/tr[9]/td[2]").inner_text
result_achievements_val= (@page/"table[2]/tr[10]/td[2]").inner_text
result_skills_val= (@page/"table[2]/tr[11]/td[2]").inner_text
result_exp_val= (@page/"table[2]/tr[12]/td[2]").inner_text
result_lang_val= (@page/"table[2]/tr[13]/td[2]").inner_text
result_reference_val= (@page/"table[2]/tr[14]/td[2]").inner_text
result_refe_val= (@page/"table[2]/tr[15]/td[2]").inner_text
result_refe_val1= (@page/"table[2]/tr[16]/td[2]").inner_text
end



user.query("INSERT INTO scrap_users (name,\
dob,email,telephone,introduction,fields_of_expertise,\
years_of_experience,current_residence,native_of,\
countries_interested,education_degrees,membership,\
achievement,skills_interests,related_experience,\
languages_spoken,refer,personal_cv,certificate,candidate_image,\
profile_url,cv_url,certificate_url,candidate_image_url) VALUES ('#{result_name}', '#{ result_birth_val}', \
'#{ result_email}', '#{ result_telephone_val}', '#{result_Introduction}', '#{result_field}',
'#{result_year_of_exp_value}', '#{result_current_res_val}', '#{result_native_val}',
'#{result_counties_inte_val}', '#{result_education_val}', '#{result_memberships_val}', \
'#{result_achievements_val}', '#{result_skills_val}', '#{result_exp_val}', '#{result_lang_val}', \
'#{result_reference_val}', '#{mycv}','#{mycertificate}','#{@userimage}', \
'#{result_profile_url}','#{result_cv_url}','#{result_certificate_url}','#{result_image_url}')");


   rescue Mechanize::ResponseCodeError
    puts $!.response_code
  end

 end
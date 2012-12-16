def prowl_message event, description, url=nil, api_key=nil
  require 'prowl'
 
  prowl_config_file = File.join  'prowl.yml'
  if File.exists? prowl_config_file
    prowl_config = YAML.load File.open(prowl_config_file).read
    api_key ||= prowl_config["api_key"] 

    if prowl_config["active"]
      Prowl.add(
        :apikey => api_key,
        :application => "CraigsWarn",
        :event => event,
        :description => description,
        :url => url
      )
    end
  end
  puts "Prowl notification sent '#{event}'"
end

def brittany_prowl_message event, description, url=nil
  prowl_message event, description, url, "api_key_goes_here!"
end

def send_email event, description, url=nil
  Pony.mail(:to => 'bsoch0um@gmail.com', :from => 'notifications@hjhart.com', :subject => "#{event}", :body => "#{event}\n#{description}\n#{url}")
 #Pony.mail(:to => 'hjhart@gmail.com', :from => 'notifications@hjhart.com', :subject => "#{event}", :body => "#{event}\n#{description}\n#{url}")
end

require 'rubygems'
require 'yaml'
require 'vendor/json/lib/json'
require 'open-uri'

helpers do
  def get_email_list(name)
    email_lists = get_email_lists_file
    throw :halt, "Couldn't find email list: #{params[:list]}" if email_lists[name].nil?
    email_lists[name]
  end
  
  def get_email_lists_file
    email_lists_file = File.dirname(__FILE__) + '/config/email_lists.yml'
    throw :halt, "Couldn't find email list config file: #{email_lists_file}" unless File.exist?(email_lists_file)
    YAML::load(File.read(email_lists_file)) 
  end
  
  def generate_email(to_emails, bcc_emails, json)
    commits = JSON.parse(json)
    body = <<-EOM
From: 'Git Email Bot c/o #{commits['repository']['owner']['name']}' <#{commits['repository']['owner']['email']}>
Bcc: #{bcc_emails}
Subject: [git receive] Commit in #{commits['repository']['name']} to #{commits['after'][0..7]}

EOM
    commits['commits'].each do |commit|
      body << <<-EOM
#{commit['message']}

SHA1: #{commit['id']}
Author: #{commit['author']['name']} (#{commit['author']['email']})
Time: #{commit['timestamp']}
URL: #{commit['url']}
 
EOM
      begin
        open(commit['url'] + ".diff") do |f|
          body << <<-EOM
Diff:

EOM
          f.each do |line|
            body << line + "\n\n"
          end
        end
      rescue
        body << "Couldn't fetch diff @ #{commit['url']}.diff\n\n"
      end
    end
    
    last_email = File.dirname(__FILE__) + '/tmp/last_email.txt'
    File.open(last_email, 'w') {|f| f.write(body) }
    
    `cat #{last_email} | sendmail -t #{to_emails}`
  end
end


get '/' do
  '<h1>Try a post instead</h1>'
end

post '/' do
  throw :halt, '<h1>Requires an email list, sorry!</h1>'
end

post '/:list' do
  email_list = get_email_list(params[:list])
  generate_email(email_list['to_emails'], email_list['bcc_emails'], params[:payload])
  
  '<h1>OMG PONIES!!11!</h1>'
end

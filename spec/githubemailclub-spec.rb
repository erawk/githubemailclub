require 'rubygems'
require 'spec'
require 'vendor/sinatra/lib/sinatra'
require 'vendor/sinatra/lib/sinatra/test/rspec'
require 'githubemailclub'

describe 'GitHub Email Club' do
  it 'should show a default page' do
    get_it '/'
    @response.should be_ok
    @response.body.should =~ /Try a post instead/
  end

  it 'should show an error with no post data' do
    post_it '/'
    @response.should be_ok
    @response.body.should =~ /Requires an email list, sorry!/
  end

  it 'should show an error with no email list find' do
    post_it '/foo'
    @response.should be_ok
    @response.body.should =~ /Couldn't find email list/
  end

  it 'should show a page with OMG PONIES!' do
    @json = File.read(File.dirname(__FILE__) + "/fixtures/github_commit_payload.json")
    @email_list = YAML::load(File.read(File.dirname(__FILE__) + "/fixtures/email_lists.yml"))
    
    post_it "/#{@email_list.keys.first}", {'payload' => @json}
    @response.should be_ok
    @response.body.should =~ /OMG PONIES/
  end

end
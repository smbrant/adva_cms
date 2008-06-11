require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::SitesController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :article, :user, :comment
    set_resource_paths :site, '/admin/'
    
    stub_comment.stub!(:commentable).and_return @article
    @site.activities.stub!(:find_coinciding_grouped_by_dates).and_return []
    Site.stub!(:new).and_return @site
    
    @controller.stub! :require_authentication
    @controller.stub! :protect_single_site_mode
    @controller.stub! :guard_permission
    
    @controller.stub!(:current_user).and_return @user
  end
  
  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "routing" do
    with_options :path_prefix => '/admin/' do |route|
      route.it_maps :get, "sites", :index
      route.it_maps :get, "sites/1", :show, :id => '1'
      route.it_maps :get, "sites/new", :new
      route.it_maps :post, "sites", :create
      route.it_maps :get, "sites/1/edit", :edit, :id => '1'
      route.it_maps :put, "sites/1", :update, :id => '1'
      route.it_maps :delete, "sites/1", :destroy, :id => '1'
    end
  end
  
  describe "GET to :index" do
    act! { request_to :get, @collection_path }    
    it_assigns :sites
    it_renders_template :index
  end
   
  describe "GET to :show" do
    act! { request_to :get, @member_path }    
    it_assigns :site
    it_renders_template :show
    
    it "fetches a site from Site" do
      Site.should_receive(:find).and_return @site
      act!
    end
  end 
  
  describe "GET to :new" do
    act! { request_to :get, @new_member_path }    
    it_assigns :site
    it_renders_template :new
    
    it "instantiates a new site from site.sites" do
      Site.should_receive(:new).and_return @site
      act!
    end    
  end
  
  describe "POST to :create" do
    act! { request_to :post, @collection_path }    
    it_assigns :site
    
    it "instantiates a new site from site.sites" do
      Site.should_receive(:new).and_return @site
      act!
    end
    
    describe "given valid site params" do
      it_redirects_to { @member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid site params" do
      before :each do @site.stub!(:save).and_return false end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end    
  end
   
  describe "GET to :edit" do
    act! { request_to :get, @edit_member_path }    
    it_assigns :site
    it_renders_template :edit
    
    it "fetches a site from site.sites" do
      Site.should_receive(:find).and_return @site
      act!
    end
  end 
  
  describe "PUT to :update" do
    act! { request_to :put, @member_path }    
    it_assigns :site    
    
    it "fetches a site from site.sites" do
      Site.should_receive(:find).and_return @site
      act!
    end  
    
    it "updates the site with the site params" do
      @site.should_receive(:update_attributes).and_return true
      act!
    end
    
    describe "given valid site params" do
      it_redirects_to { @edit_member_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid site params" do
      before :each do @site.stub!(:update_attributes).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path }    
    it_assigns :site
    
    it "fetches a site from site.sites" do
      Site.should_receive(:find).and_return @site
      act!
    end 
    
    it "should try to destroy the site" do
      @site.should_receive :destroy
      act!
    end 
    
    describe "when destroy succeeds" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "when destroy fails" do
      before :each do @site.stub!(:destroy).and_return false end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end
    
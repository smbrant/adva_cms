class Admin::PhotosController < Admin::BaseController
  layout 'admin'
  helper 'admin/comments'
  before_filter :set_section
  before_filter :params_author,       :only => :create
  before_filter :params_draft,        :only => :create
  before_filter :params_published_at, :only => :create
  
  def index
    @photos = @section.photos.paginate photo_paginate_options
  end
  
  def new
    @photo = @section.photos.build :comment_age => @section.comment_age, :filter => @section.content_filter
  end
  
  def create
    @photo = @section.photos.build params[:photo]
    
    if @photo.save
      flash[:notice] = "Photo was uploaded successfully."
      redirect_to edit_admin_photo_path(@site, @section, @photo)
    else
      flash[:error] = "Photo upload failed."
      render :action => 'new'
    end
  end
  
  protected
    def photo_paginate_options
      {:page => params[:page], :order => 'created_at DESC'}
    end
    
    def params_author
      author = User.find(params[:photo][:author]) || current_user
      set_photo_param(:author, author) or raise "author and current_user not set"
    end

    def params_draft
      set_photo_param :published_at, nil if save_draft?
    end

    def params_published_at
      date = Time.extract_from_attributes!(params[:photo], :published_at, :local)
      set_photo_param :published_at, date if date && !save_draft?
    end

    def save_draft?
      params[:draft] == '1'
    end

    def set_photo_param(key, value)
      params[:photo] ||= {}
      params[:photo][key] = value
    end
end
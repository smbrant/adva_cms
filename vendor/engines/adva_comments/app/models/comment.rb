class Comment < ActiveRecord::Base
  class CommentNotAllowed < StandardError; end  
  
  class Jail < Safemode::Jail
    allow :new_record?
  end  

  acts_as_role_context :roles => :author  
  filters_attributes :sanitize => :body_html
  filtered_column :body  

  belongs_to :site
  belongs_to :section
  belongs_to :commentable, :polymorphic => true
  belongs_to_author

  validates_presence_of :body, :commentable
  
  before_validation  :set_owners
  before_create :authorize_commenting!
  after_create  :update_commentable
  after_destroy :update_commentable
  
  def owner
    commentable
  end
  
  def filter
    commentable.comment_filter
  end
  
  # def approved?
  #   approved.to_s == '1'
  # end

  def unapproved?
    !approved?
  end

  def authorize_commenting!
    unless commentable.accept_comments?
      raise CommentNotAllowed, "Comments are not allowed for this #{commentable.class.name.demodulize.humanize.downcase}." 
    end
  end   
  
  private
    def set_owners
      if commentable # TODO in what cases would commentable be nil here?
        self.site = commentable.site 
        self.section = commentable.section
      end
    end
  
    def update_commentable
      commentable.after_comment_update(self) if commentable && commentable.respond_to?(:after_comment_update)
    end  
  
end
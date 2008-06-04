class CreateContentsTable < ActiveRecord::Migration
  def self.up
    create_table :contents, :force => true do |t|
      t.references :site
      t.references :section
      t.string     :type, :limit => 20
      t.integer    :position

      t.string     :title
      t.string     :permalink
      t.text       :excerpt
      t.text       :excerpt_html
      t.text       :body
      t.text       :body_html

      t.references :author, :polymorphic => true
      t.string     :author_name, :limit => 40
      t.string     :author_email, :limit => 40
      t.string     :author_homepage      

      t.string     :state # TODO do we need this?
      t.integer    :version 
      t.string     :filter
      t.integer    :comment_age, :default => 0
      t.integer    :comments_count, :default => 0
      t.string     :cached_tag_list, :string   
      t.integer    :assets_count, :default => 0
      # t.integer  :updater_id

      t.timestamps
      t.datetime   :published_at
    end    
    Content.create_versioned_table
  end

  def self.down
    drop_table :contents    
    Content.drop_versioned_table
  end
end

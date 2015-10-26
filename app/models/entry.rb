class Entry
  include Mongoid::Document
  include Mongoid::Timestamps
  validates :link, uniqueness: true
  field :title, type: String
  field :link, type: String
  field :description, type: String
  field :content_encoded, type: String
  field :screenshot, type: String
  field :count, type: String
  field :tags, type: String
end

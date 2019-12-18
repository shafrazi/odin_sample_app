class Micropost < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  validate :picture_size

  mount_uploader :picture, PictureUploader

  def self.default_scope
    order(created_at: :desc)
  end

  private

  # validate the size of an uploaded image
  def picture_size
    if self.picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
    end
  end
end

class Event < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :invitations, foreign_key: :event_id
  has_many :attendees, through: :invitations, source: :attendee

  validates :date, presence: true
  validates :location, presence: true
  validates :name, presence: true
  validates :description, presence: true, length: { maximum: 340 }

  scope :upcoming, lambda { where('date >= ?', DateTime.now)}
  scope :past, lambda { where('date < ?', DateTime.now)}
end


class Swimlane < ApplicationRecord
    belongs_to :board
    has_many :items, dependent: :destroy
    default_scope { order(:ordering) }
end

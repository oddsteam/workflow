class Swimlane < ApplicationRecord
    has_many :items, dependent: :destroy
end

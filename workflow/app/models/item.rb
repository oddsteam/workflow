class Item < ApplicationRecord
    belongs_to :swimlane
    default_scope { order(:ordering) }
end

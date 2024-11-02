class Board < ApplicationRecord
    has_many :swimlanes, dependent: :destroy
end

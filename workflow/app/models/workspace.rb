class Workspace < ApplicationRecord
    has_many :boards, dependent: :destroy
end

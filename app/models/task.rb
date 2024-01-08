class Task < ApplicationRecord
    belongs_to :user

    has_many :status, dependent: :destroy
    has_many :tag, dependent: :destroy
end

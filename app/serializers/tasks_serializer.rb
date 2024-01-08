class TasksSerializer
  include FastJsonapi::ObjectSerializer
  attributes :title, :description, :due_date, :priority, :remainder, :attachment, :group, :created_at, :updated_at

  attribute :status do |task|
    latest_status = task.status.order(created_at: :desc).first
    latest_status&.status
  end

  attribute :tags do |task|
    task.tag
  end

  belongs_to :user
  has_many :status
end

class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :description
      t.date :due_date
      t.string :priority
      t.date :remainder
      t.string :attachment
      t.string :group

      t.timestamps
    end
  end
end

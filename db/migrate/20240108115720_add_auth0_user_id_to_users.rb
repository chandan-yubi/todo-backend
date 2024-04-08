class AddAuth0UserIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :auth0_user_id, :string
  end
end

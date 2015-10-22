class AddAuthTokenToAdministrators < ActiveRecord::Migration
  def change
    add_column :administrators, :auth_token, :string
  end
end

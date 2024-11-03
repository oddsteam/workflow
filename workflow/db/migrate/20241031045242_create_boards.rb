class CreateBoards < ActiveRecord::Migration[7.2]
  def change
    create_table :boards do |t|
      t.references :user

      t.string :title

      t.timestamps
    end
  end
end

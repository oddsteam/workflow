class CreateBoardKey < ActiveRecord::Migration[7.2]
  def change
    add_column :boards, :key, :string
    add_index :boards, :key, unique: true
  end
end

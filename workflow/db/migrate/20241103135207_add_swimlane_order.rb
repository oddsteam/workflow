class AddSwimlaneOrder < ActiveRecord::Migration[7.2]
  def change
    add_column :swimlanes, :ordering, :integer
  end
end

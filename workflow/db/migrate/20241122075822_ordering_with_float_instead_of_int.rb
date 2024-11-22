class OrderingWithFloatInsteadOfInt < ActiveRecord::Migration[7.2]
  def change
    change_column :swimlanes, :ordering, :float
    add_column :items, :ordering, :float
  end
end

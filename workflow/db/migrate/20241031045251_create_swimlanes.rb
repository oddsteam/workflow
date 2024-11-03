class CreateSwimlanes < ActiveRecord::Migration[7.2]
  def change
    create_table :swimlanes do |t|
      t.references :board

      t.string :title

      t.timestamps
    end
  end
end

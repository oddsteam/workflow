class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.references :swimlane
      t.references :user

      t.string :title

      t.timestamps
    end
  end
end

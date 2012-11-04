class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :answer_id
      t.integer :pattern_id
      t.string :result
      t.string :diff
      t.timestamps
    end
  end
end

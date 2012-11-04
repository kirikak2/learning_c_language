class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :probrem

      t.timestamps
    end
  end
end

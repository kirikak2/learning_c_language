class CreateAnswerPatterns < ActiveRecord::Migration
  def change
    create_table :answer_patterns do |t|
      t.integer :question_id
      t.string :input
      t.string :expect_answer

      t.timestamps
    end
  end
end

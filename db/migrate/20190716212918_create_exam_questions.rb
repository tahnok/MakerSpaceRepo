# frozen_string_literal: true

class CreateExamQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :exam_questions do |t|
      t.integer :exam_id
      t.integer :question_id

      t.timestamps null: false
    end
  end
end

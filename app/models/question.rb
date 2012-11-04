class Question < ActiveRecord::Base
  has_many :answers
  has_many :answer_patterns
  accepts_nested_attributes_for :answer_patterns
end

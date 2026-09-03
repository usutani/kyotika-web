class Quiz::ResultsController < ApplicationController
  def show
    @page_title = "クイズ結果"
    raw_answers = session[:quiz_answers] || []
    redirect_to quiz_path and return if raw_answers.empty?

    @score = session[:quiz_score] || 0
    @total = raw_answers.size

    landmark_ids = raw_answers.map { |a| a["landmark_id"] }
    landmarks = Landmark.where(id: landmark_ids).index_by(&:id)

    @answers = raw_answers.map do |answer|
      landmark = landmarks[answer["landmark_id"]]
      {
        landmark_id: answer["landmark_id"],
        name: landmark&.name,
        selected: answer["selected"],
        answer_text: landmark&.send("answer#{answer["selected"]}"),
        correct_answer_text: landmark ? landmark.send("answer#{landmark.correct}") : nil,
        correct?: answer["selected"] == landmark&.correct
      }
    end
  end
end

class LandmarksController < ApplicationController
  def index
    @landmarks = Landmark.order(:hiragana)
  end
end

class RegionsController < ApplicationController
  before_action :ensure_administrator, only: :destroy

  def index
    @page_title = "地域一覧"
    @regions = Region.includes(:landmarks).order(:hiragana)
  end

  def new
    @page_title = "地域追加"
    @region = Region.new
  end

  def create
    @region = Region.new(region_params)
    if @region.save
      respond_to do |format|
        format.html { redirect_to regions_path, notice: "地域を追加しました" }
        format.json { render json: { id: @region.id, name: @region.name }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @region.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @page_title = "地域編集"
    @region = Region.find(params[:id])
  end

  def update
    @region = Region.find(params[:id])
    if @region.update(region_params)
      redirect_to regions_path, notice: "地域を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @region = Region.find(params[:id])
    if @region.destroy
      redirect_to regions_path, notice: "地域を削除しました"
    else
      redirect_to regions_path, alert: @region.errors.full_messages.to_sentence
    end
  end

  private

  def region_params
    params.require(:region).permit(:name, :hiragana)
  end
end

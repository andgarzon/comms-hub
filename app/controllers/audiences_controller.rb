class AudiencesController < ApplicationController
  before_action :set_audience, only: %i[ show edit update destroy ]

  # GET /audiences or /audiences.json
  def index
    @audiences = Audience.all
  end

  # GET /audiences/1 or /audiences/1.json
  def show
  end

  # GET /audiences/new
  def new
    @audience = Audience.new
  end

  # GET /audiences/1/edit
  def edit
  end

  # POST /audiences or /audiences.json
  def create
    @audience = Audience.new(audience_params)

    respond_to do |format|
      if @audience.save
        format.html { redirect_to @audience, notice: "Audience was successfully created." }
        format.json { render :show, status: :created, location: @audience }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @audience.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /audiences/1 or /audiences/1.json
  def update
    respond_to do |format|
      if @audience.update(audience_params)
        format.html { redirect_to @audience, notice: "Audience was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @audience }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @audience.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /audiences/1 or /audiences/1.json
  def destroy
    @audience.destroy!

    respond_to do |format|
      format.html { redirect_to audiences_path, notice: "Audience was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_audience
      @audience = Audience.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def audience_params
      params.expect(audience: [ :name, :description, :slack_channel ])
    end
end

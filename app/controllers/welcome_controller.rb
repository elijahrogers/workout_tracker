class WelcomeController < ApplicationController
  def index
  end

  def create
    @maxes = []
    @maxes << params[:bw]
    @maxes << params[:b]
    @maxes << params[:s]
    @maxes << params[:d]
    @maxes << params[:o]
    @maxes.map! { |max| max.to_i }
    report = WorkoutReport.new(@maxes)
    output = report.to_pdf
    send_data output, filename: 'workout_report.pdf', type: 'application/pdf'
  end

  private

  def workout_params
    params.permit(:bw, :b, :s, :d, :o)
  end

end

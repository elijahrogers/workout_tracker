require 'prawn'
require 'prawn/icon'
require 'combine_pdf'
require 'gruff'
require 'stringio'
require 'open-uri'

class WorkoutReport < Prawn::Document
  include Common::CombinePdf
  include Common::ColorTheme
  include Common::IncludeFont

  def initialize(_data)
    super()
    @maxes = _data
    @template = "#{Rails.root}/app/pdf_templates/workout_template.pdf"
  end

  private

  def init_pdf
    draw_page_one
  end

  def draw_page_one
    add_orm_graph
    add_workout_template
  end

  def add_orm_graph
    text_box "Estimated One Rep Maximum (bodyweight)", :at => [0,660], :width => 550, :align => :center
    create_graph
    image "#{Rails.root}/app/assets/images/orm.png", :scale => 0.45, :at => [0, 635]

  end

  def add_workout_template
    text_box "Four Week Schedule", :at => [200,350], :width => 300, :position => :center
    stroke_horizontal_line 170, 340, :at => 335
    create_charts([250, 100, 600, 450], [*1..4])
    populate_charts_warmups([250, 100, 600, 450])
    populate_charts_workouts([250, 100, 600, 450])
  end

  def convert_to_bodyweight
    @bw = @maxes.shift + 0.00
    @bw_maxes = @maxes.map {|max| (max / @bw).round(2) }
    @m = @bw_maxes.max
  end

  def create_graph
    @theme = gruff_theme
    convert_to_bodyweight
    g = Gruff::SideBar.new('1200x400')
    g.bar_spacing = 0.5
    g.minimum_value = 0
    g.maximum_value = @m
    g.data("Bench", [@bw_maxes.shift])
    g.data("Squat", [@bw_maxes.shift])
    g.data("Deadlift", [@bw_maxes.shift])
    g.data("OHP", [@bw_maxes.shift])
    g.y_axis_increment = 0.5
    g.labels = {0 => " "}
    g.theme = @theme
    g.write("#{Rails.root}/app/assets/images/orm.png")
  end

  def create_charts(positions, weeks)
    colors = %w( FAFF00 FF2E2E 47F600 05ADFF )
    for i in 0..3
      if i == 2
        start_new_page
      end
      stroke_color colors[i]
      text_box "Week #{weeks[i]}", :at => [0, (positions[i] + 50)], :width => 300
       stroke do
         x = positions[i]
         3.times {
           horizontal_line 0, 455, :at => x
           x -= 20
         }
         x = 65
         6.times {
           vertical_line positions[i] + 15, positions[i] - 55, :at => x
           x += 65
         }
       end
    end
  end

  def populate_charts_warmups(positions)
    positions.each_with_index do |pos, index|
      get_page(index)
      bounding_box([5, (pos + 15)], :width => 65, :height => 80) do
        lifts = ["Bench", "Squat","Deadlift","OHP"]
          lifts.each do |lift|
            text lift
            move_down 6
          end
      end
      x_position = 65
      pct = 0.4
      for i in 0..2
        x = 15
        i == 2 ? sffx = " x 3" : sffx = " x 5"
        for n in 0..3
          bounding_box([x_position, (pos + x)], :width => 55, :height => 15) do
            line = (@maxes[n] * pct ).round.to_s + sffx
            text line, :align => :right
          end
          x -= 20
        end
        x_position += 65
        pct += 0.1
      end
  end

  def populate_charts_workouts(positions)
    positions.each_with_index do |pos, index|
      get_page(index)
      params =[[0.65, " x 5"],[0.7, " x 3"],[0.75, [" x 5", " x 3", " x 1"]],[0.4, " x 5"]]
      x_position = 260
      pct = params[index][0]
      for i in 0..2
        x = 15
        params[index][1].is_a?(Array) ? sffx = params[index][1][i] : sffx = params[index][1]
        for n in 0..3
          bounding_box([x_position, (pos + x)], :width => 55, :height => 15) do
            line = (@maxes[n] * pct ).round.to_s + sffx
            text line, :align => :right
          end
          x -= 20
        end
        x_position += 65
        pct += 0.1
        end
      end
    end
  end

  def get_page(index)
    if index > 1
      go_to_page 2
    else
      go_to_page 1
    end
  end

end

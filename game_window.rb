require 'gosu'
require_relative 'models/the_world'

class GameWindow < Gosu::Window

  TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
  BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)
  CELL_TOP_COLOR = Gosu::Color.new(0xEEEEEEEE)
  CELL_BOTTOM_COLOR = Gosu::Color.new(0xAAAAAAAA)
  CELL_TOP_RIGHT_COLOR = Gosu::Color.new(0xAAAAAAAA)
  CELL_BOTTOM_RIGHT_COLOR = Gosu::Color.new(0xEEEEEEEE)

  def initialize
    super 640, 480, false
    self.caption = "Game of Life"
    @speed_of_simulation = 100
    @last_frame = Gosu::milliseconds
    @time_to_age_world = @last_frame
    @update_fps = @last_frame
    initialize_world
  end

  def update
    @this_frame = Gosu::milliseconds
    @delta = (@this_frame - @last_frame) / 1000.0
    @fps = 1000 / (@this_frame - @last_frame + 1)
    @last_frame = @this_frame

    if @this_frame > @time_to_age_world
      @generation += 1
      self.caption = "game of Life (FPS =#{(@fps).to_s.rjust(3)}.#{(@fps%100).to_s.ljust(2)} Population = #{TheWorld.world.population} Generation = #{@generation}" and @update_fps += 2 if @this_frame > @update_fps
      TheWorld.world.age_world
      @time_to_age_world = @this_frame + @speed_of_simulation
    end

  end

  def draw
    erase_background
    draw_cells
  end

  def initialize_world
    TheWorld.new({:width => 640/4, :height => 440/4})
    TheWorld.world.seed_world(10, 3, 5)
    @generation = 1
  end

  private

  def draw_cells
    TheWorld.world.cells.each do |cell|
      draw_quad(
          cell.x_pos*4,     cell.y_pos*4+40,      CELL_TOP_COLOR,
          cell.x_pos*4+4,   cell.y_pos*4+40,      CELL_TOP_RIGHT_COLOR,
          cell.x_pos*4,     cell.y_pos*4+4+40,    CELL_BOTTOM_COLOR,
          cell.x_pos*4+4,   cell.y_pos*4+4+40,    CELL_BOTTOM_RIGHT_COLOR,
          0)
    end

  end

  def erase_background
    draw_quad(
        0,     36,      TOP_COLOR,
        TheWorld.world.width*4, 36,      TOP_COLOR,
        0,     TheWorld.world.height*4+46, BOTTOM_COLOR,
        TheWorld.world.width*4, TheWorld.world.height*4+40, BOTTOM_COLOR,
        0)
  end

  def button_down(id)
    case id
      when Gosu::KbEscape
        close
      when Gosu::KbEnter, Gosu::KbReturn
        TheWorld.armageddon
        initialize_world
    end
  end
end

window = GameWindow.new
window.show
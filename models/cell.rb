class Cell
  attr_accessor :x_pos, :y_pos, :dead

  def initialize(options)
    raise "options must be set" unless options
    @x_pos = options[:x_pos]
    @y_pos = options[:y_pos]
    @dead = false
    TheWorld.world.add_cell(self)
  end

  def age
    @neighbors = TheWorld.world.find_neighbors(self)
    @dead = true if @neighbors.length < 2
    @dead = true if @neighbors.length > 3
    @dead = true if @x_pos < 0 || @y_pos < 0 || @x_pos > TheWorld.world.width || @y_pos > TheWorld.world.height
    return self
  end

  def breed
    TheWorld.world.breed(self)
  end

  def die
    TheWorld.world.remove_cell(self)
  end

end
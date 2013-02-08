require_relative 'cell'

class TheWorld
  #creating a singleton instance so we can access the world anytime without passing the instance around

  attr_accessor :width, :height, :cells, :cells_h

  @@world = nil

  def initialize(options = {})
    raise "You can only create one world" unless @@world.nil?
    @width = options[:width] || 10
    @height = options[:height] || 10
    @cells = []
    @cells_h = {}
    @@world = self
  end

  def population
    return @cells.length
  end

  def self.world
    @@world ||= self.new
    @@world
  end

  def self.armageddon
    @@world = nil
  end

  def add_cell(cell)
    unless has_cell?(cell)
      @cells_h[cell.x_pos]={} if @cells_h[cell.x_pos].nil?
      raise "Can't add a new cell on top of an existing cell's location" unless @cells_h[cell.x_pos][cell.y_pos].nil?
      @cells_h[cell.x_pos][cell.y_pos] = cell
      @cells << cell
    end
  end

  def remove_cell(cell)
    @cells_h[cell.x_pos].delete(cell.y_pos)
    @cells.delete(cell)
  end

  def has_cell?(cell)
    @cells.include?(cell)
  end

  def locate_cell(x_pos, y_pos)
    @cells_h[x_pos][y_pos]
  end

  def breed(cell)
    Cell.new(find_empty_loc(cell))
  end

  def age_world
    new_births = spontaneous_generation
    age_cells
    birth_new_generation(new_births)
  end

  def spontaneous_generation
    #store valid locations for a birth instead of adding them on the fly so that new births won't affect the last generation
    breeding_farm = []
    @cells.each do |cell|
      find_all_empty_locs(cell).each do |empty_loc|
        unless breeding_farm.include? empty_loc
          if 3 == find_number_of_neighbors_around_location(empty_loc[:x_pos], empty_loc[:y_pos])
            breeding_farm << empty_loc
          end
        end
      end
    end
    return breeding_farm
  end

  def find_number_of_neighbors_around_location(x_pos, y_pos)
    total = 0
    [x_pos - 1, x_pos, x_pos + 1].each do |x|
      [y_pos - 1, y_pos, y_pos + 1].each do |y|
        total += 1 unless @cells_h[x].nil? || @cells_h[x][y].nil?
      end
    end
    return total
  end

  def find_cell_by_loc(x_pos, y_pos)
    return @cells_h[x_pos][y_pos] unless @cells_h[x_pos].nil? || @cells_h[x_pos][y_pos].nil?
    return nil
  end

  def find_neighbors(cell)
    x_pos = cell.x_pos
    y_pos = cell.y_pos
    neighbors = []
    [x_pos - 1, x_pos, x_pos + 1].each do |x|
      [y_pos - 1, y_pos, y_pos + 1].each do |y|
        if x != x_pos || y != y_pos
          neighbors << @cells_h[x][y] unless @cells_h[x].nil? || @cells_h[x][y].nil?
        end
      end
    end
    return neighbors
  end

  def birth_new_generation(breeding_farm)
    breeding_farm.each do |birth_loc|
      Cell.new(birth_loc)
    end
  end

  def age_cells
    dead_cells = []
    @cells.each do |cell|
      dead_cells << cell if cell.age.dead == true
    end
    dead_cells.each{|cell| remove_cell(cell)}
  end

  def seed_world(amount, neighbors_min, neighbors_max)
    raise "seed amount is too great" if amount > (width * height / 3)
    amount.times do |a|
      seeded = false
      while(seeded == false)
        x = rand(width/2)+width/4
        y = rand(height/2)+height/4
        cell = Cell.new({:x_pos => x, :y_pos => y}) and seeded = true if @cells_h[x].nil? || @cells_h[x][y].nil?
        (rand(neighbors_max)+neighbors_min).to_i.times {|i|cell.breed}
      end
    end
  end

  private

  def find_empty_loc(cell)
    empty_locs = find_all_empty_locs(cell)
    return empty_locs[rand(empty_locs.length)]
  end

  def find_all_empty_locs(cell)
    x_pos = cell.x_pos
    y_pos = cell.y_pos
    empty_locs = []
    [x_pos - 1, x_pos, x_pos + 1].each do |x|
      [y_pos -1, y_pos, y_pos + 1].each do |y|
        empty_locs << {:x_pos => x, :y_pos => y} if @cells_h[x].nil? || @cells_h[x][y].nil?
      end
    end
    return empty_locs
  end


end
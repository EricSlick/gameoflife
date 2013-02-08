require 'spec_helper'

describe TheWorld do

  before :each do
    TheWorld.armageddon
    @world = TheWorld.new({:width => 10, :height=> 10})
  end

  it 'exists as a singleton' do
    TheWorld.world.should eq(@world)
  end

  it 'can only have one world (singleton)' do
    expect{TheWorld.new({:width => 10, :height=> 10})}.to raise_error
  end

  it 'can be destroyed and re-created' do
    old_world = TheWorld.world
    TheWorld.armageddon
    expect{TheWorld.new({:width => 10, :height=> 10})}.to_not raise_error
    TheWorld.world.should_not eq(old_world)
  end

  it 'has a playing board' do
    TheWorld.world.width.should be(10)
    TheWorld.world.height.should be(10)
  end

  it 'can add a cell to the world' do
    cell = Cell.new(:x_pos => 1, :y_pos => 2)
    TheWorld.world.add_cell(cell)
    TheWorld.world.has_cell?(cell).should be_true
  end

  it 'can remove a cell from the world' do
    cell = Cell.new(:x_pos => 1, :y_pos => 2)
    TheWorld.world.add_cell(cell)
    TheWorld.world.remove_cell(cell)
    TheWorld.world.has_cell?(cell).should be_false
  end

  it 'will not add the same cell twice' do
    cell = Cell.new(:x_pos => 1, :y_pos => 2)
    TheWorld.world.add_cell(cell)
    TheWorld.world.add_cell(cell)
    TheWorld.world.remove_cell(cell)
    TheWorld.world.has_cell?(cell).should be_false
  end

  it 'can find cell via its location' do
    cell = Cell.new(:x_pos => 1, :y_pos => 2)
    TheWorld.world.add_cell(cell)
    cell_by_location = TheWorld.world.locate_cell(1, 2)
    cell.should eq(cell_by_location)
  end

  it 'will not add a new cell on top of a cell in an existing location' do
    cell = Cell.new(:x_pos => 1, :y_pos => 2)
    TheWorld.world.add_cell(cell)
    expect{new_cell = Cell.new(:x_pos => 1, :y_pos => 2)}.to raise_error
    expect{TheWorld.world.add_cell(new_cell)}.to raise_error
  end

  it 'will breed a cell next to the parent cell' do
    cell = Cell.new(:x_pos => 5, :y_pos => 5)
    child_cell = TheWorld.world.breed(cell)
    TheWorld.world.has_cell?(child_cell).should be_true
    TheWorld.world.population.should eq(2)
  end

  it 'will return the neighbors to a cell' do
    cell = Cell.new(:x_pos => 5, :y_pos => 5)
    cell.breed
    cell.breed
    neighbor_cells = TheWorld.world.find_neighbors(cell)
    neighbor_cells.length.should == 2
    TheWorld.world.population.should eq(3)
  end

  it 'will not breed when there are no empty locations around it' do
    cell = Cell.new(:x_pos => 5, :y_pos => 5)
    8.times{cell.breed}
    expect{cell.breed}.to raise_error
    TheWorld.world.find_neighbors(cell).length.should == 8
  end

  it 'will spontaneously generate cells in empty cells where there are exactly three neighbors' do
    #see cell_spec for other rule tests
    top_cell = Cell.new(:x_pos => 5, :y_pos => 4)
    middle_cell = Cell.new(:x_pos => 5, :y_pos => 5)
    bottom_cell = Cell.new(:x_pos => 5, :y_pos => 6)
    new_cells = TheWorld.world.spontaneous_generation
    TheWorld.world.birth_new_generation(new_cells)
    new_cells.length.should == 2
    TheWorld.world.find_neighbors(top_cell).length.should eq(3)
    TheWorld.world.find_neighbors(middle_cell).length.should eq(4)
    TheWorld.world.find_neighbors(bottom_cell).length.should eq(3)
  end

  # 0X0         000          0X0
  # 0X0 becomes XXX  becomes 0X0
  # 0X0         000          0X0
  it 'will update cells from column of three to row of three when they are aged' do
    top_cell = Cell.new(:x_pos => 5, :y_pos => 4)
    middle_cell = Cell.new(:x_pos => 5, :y_pos => 5)
    bottom_cell = Cell.new(:x_pos => 5, :y_pos => 6)
    TheWorld.world.age_world
    TheWorld.world.find_neighbors(top_cell).length.should eq(3)
    TheWorld.world.find_neighbors(middle_cell).length.should eq(2)

    TheWorld.world.find_cell_by_loc(4, 5).should_not be_nil
    TheWorld.world.find_cell_by_loc(6, 5).should_not be_nil

    TheWorld.world.find_neighbors(bottom_cell).length.should eq(3)

    TheWorld.world.age_cells
    TheWorld.world.find_neighbors(top_cell).length.should eq(1)
    TheWorld.world.find_cell_by_loc(4, 5).should be_nil
    TheWorld.world.find_cell_by_loc(6, 5).should be_nil
  end

  # X0X            000
  # X0X  becomes  XX0XX
  # X0X            000
  it 'will update to above diagram (two vertical to two horizontal, same line) when they are aged' do
    top_left = Cell.new(:x_pos => 4, :y_pos => 4)
    middle_left = Cell.new(:x_pos => 4, :y_pos => 5)
    bottom_left = Cell.new(:x_pos => 4, :y_pos => 6)
    top_right = Cell.new(:x_pos => 6, :y_pos => 4)
    middle_right = Cell.new(:x_pos => 6, :y_pos => 5)
    bottom_right = Cell.new(:x_pos => 6, :y_pos => 6)
    TheWorld.world.age_world
    TheWorld.world.find_neighbors(top_left).length.should eq(2)
    TheWorld.world.find_neighbors(middle_left).length.should eq(1)
    TheWorld.world.find_neighbors(bottom_left).length.should eq(2)

    TheWorld.world.find_neighbors(top_right).length.should eq(2)
    TheWorld.world.find_neighbors(middle_right).length.should eq(1)
    TheWorld.world.find_neighbors(bottom_right).length.should eq(2)

    TheWorld.world.find_cell_by_loc(3, 5).should_not be_nil
    TheWorld.world.find_cell_by_loc(7, 5).should_not be_nil

  end

  #                X             X
  # XXX           X0X           XXX
  # XXX  becomes X000X becomes XX0XX
  # XXX           X0X           XXX
  #                X             X
  it 'will end up with diamond shape if aged when all 8 locations around a live cell are filled in' do
    top_left = Cell.new(:x_pos => 4, :y_pos => 4)
    top_cell = Cell.new(:x_pos => 5, :y_pos => 4)
    top_right = Cell.new(:x_pos => 6, :y_pos => 4)
    middle_left = Cell.new(:x_pos => 4, :y_pos => 5)
    middle_cell = Cell.new(:x_pos => 5, :y_pos => 5)
    middle_right = Cell.new(:x_pos => 6, :y_pos => 5)
    bottom_left = Cell.new(:x_pos => 4, :y_pos => 6)
    bottom_cell = Cell.new(:x_pos => 5, :y_pos => 6)
    bottom_right = Cell.new(:x_pos => 6, :y_pos => 6)
    TheWorld.world.age_world
    TheWorld.world.find_neighbors(top_left).length.should eq(2)
    TheWorld.world.find_neighbors(top_cell).length.should eq(3)
    TheWorld.world.find_neighbors(top_right).length.should eq(2)
    TheWorld.world.find_neighbors(middle_left).length.should eq(3)
    TheWorld.world.find_neighbors(middle_cell).length.should eq(4)
    TheWorld.world.find_neighbors(middle_right).length.should eq(3)
    TheWorld.world.find_neighbors(bottom_left).length.should eq(2)
    TheWorld.world.find_neighbors(bottom_cell).length.should eq(3)
    TheWorld.world.find_neighbors(bottom_right).length.should eq(2)
    #    X             X
    #   X0X           XXX
    #  X000X becomes XX0XX
    #   X0X           XXX
    #    X             X
    TheWorld.world.age_world
    TheWorld.world.find_neighbors(top_left).length.should eq(4)
    TheWorld.world.find_neighbors(top_cell).length.should eq(5)
    TheWorld.world.find_neighbors(top_right).length.should eq(4)
    TheWorld.world.find_neighbors(middle_left).length.should eq(5)
    TheWorld.world.find_neighbors(middle_cell).length.should eq(8)
    TheWorld.world.find_neighbors(middle_right).length.should eq(5)
    TheWorld.world.find_neighbors(bottom_left).length.should eq(4)
    TheWorld.world.find_neighbors(bottom_cell).length.should eq(5)
    TheWorld.world.find_neighbors(bottom_right).length.should eq(4)
  end

  it 'will be able to be seeded with cells' do
    TheWorld.world.seed_world(5, 0, 0)
    TheWorld.world.cells.length.should eq(5)
  end

  it 'will be able to be seeded with cells and neighbors' do
    TheWorld.world.seed_world(5, 3, 0)
    (TheWorld.world.cells.length > 5).should be_true
    (TheWorld.world.cells.length < 21).should be_true
  end

end
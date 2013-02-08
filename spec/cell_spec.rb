require 'spec_helper.rb'

describe Cell do

  let(:cell) { Cell.new({:x_pos => 5, :y_pos => 3}) }
  before :each do
    TheWorld.armageddon
    TheWorld.new({:width => 10, :height=> 10})
  end

  it "lives" do
    cell.should_not be_nil
  end

  it "lives in a world" do
    TheWorld.world.has_cell?(cell).should be_true
  end

  it "has a position in the world" do
    cell.x_pos.should > -1
    cell.y_pos.should > -1
    cell.x_pos.should < TheWorld.world.width
    cell.y_pos.should < TheWorld.world.height
  end

  it 'will breed when told to breed' do
    new_cell = cell.breed
    TheWorld.world.has_cell?(new_cell).should be_true
  end

  it 'will die when told to die' do
    TheWorld.world.has_cell?(cell).should be_true
    cell.die
    TheWorld.world.has_cell?(cell).should be_false
  end

  it "Any live cell with fewer than two live neighbours dies, as if caused by under-population." do
    cell.breed
    cell.age.dead.should be_true
  end

  it "Any live cell with two or three live neighbours lives on to the next generation." do
    [2, 1].each do |i|
      i.times{cell.breed}
      cell.age
      TheWorld.world.has_cell?(cell).should be_true
    end
  end

  it "Any live cell with more than three live neighbours dies, as if by overcrowding" do
    4.times{cell.breed}
    cell.age
    cell.dead.should be_true
  end

  it "Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction." do
    #see the_world_spec for test on this rule
  end


end
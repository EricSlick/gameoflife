Game Of Life v 0.1 (a Ruby implementation of Conway's Game of Life)
============

by Eric Slick
email gameoflife@slickfamily.net
Feb 8, 2013
Time Spent: 10-12 hours (guesstimate)

Run game_window.rb
  * It will seed up to 10 colonies with a random number of life forms
  * Esc will close the game
  * Enter/Return will reset the simulation

Thoughts on Implementation of Rules
  * births and deaths are calculated before they are actually added or removed from the list of cells/lifeforms to
    simulate a full generation passage (the birth of a child should not affect the current cells/lifeforms in the
    current generation
  * births are calculated before deaths to simulate the effects of current cells/lifeforms before they potentially die

Getting Up and Running
  * Written using Ruby 1.9.3
  * IDE used: RubyMine 5.0
  * bundle install from project directory (or rubymine/tools/bundler/install)
  * from terminal or command window
    * ruby game_window.rb
  * from RubyMine
    * right click file and select run

Tests / TDD
  * TDD approach was used (except for game_window.rb) for this project using Rspec
  * Rspec tests are provided for the backend but not the front end (game_window.rb)
  * Run Tests from command line...
    *  rspec spec
  * Run Tests From RubyMine
    * right click on spec folder and choose Run/All specs in: spec

IDE
  * Written using RubyMine 5.0 and included in zip is the .idea project files
  * Unzip contents (will create project folder)
  * Run RubyMine and then open this project folder

Uses Gosu for displaying the life forms in a window

Issues and Thoughts
  * Optimization Ideas
    * Will get slow with a lot of birthing (constructing new cells).
      * Don't delete cells, but re-use
    * It appears GC is slowing things way down when it kicks in...above should mostly fix
    * Algorithm to find neighbors is brute force
      * should be able to eliminate overlapping checks
    * Currently uses array and hash map...explore custom collection type/s
  * Needs proper inputs (buttons and inputs to aid user exploration



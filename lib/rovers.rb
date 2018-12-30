class PlanetObject

  attr_reader :planet

    def initialize(planet)
      @planet = planet
    end
  
    def position
      @planet.position(self)
    end
  
    def move(position)
      @planet.move(self, position)
    end
  end
  
  class Rover < PlanetObject
  
    attr_accessor :direction
  
    def initialize(planet, direction)
      @direction = direction
      super(planet)
    end
  
    def go
      current_position = position
      case @direction
        when "N" then new_position = {:x => current_position[:x], :y => current_position[:y] + 1}
        when "S" then new_position = {:x => current_position[:x], :y => current_position[:y] - 1}
        when "E" then new_position = {:x => current_position[:x] + 1, :y => current_position[:y]}
        when "W" then new_position = {:x => current_position[:x] - 1, :y => current_position[:y]}
      end
      move(new_position)
    end
  
    DIRECTIONS = ["N", "E", "S", "W"].freeze
    def turn_right
      @direction = DIRECTIONS[(DIRECTIONS.index(@direction) + 1) % DIRECTIONS.size]
    end
  
    def turn_left
      @direction = DIRECTIONS[(DIRECTIONS.index(@direction) - 1) % DIRECTIONS.size]
    end

    def receive_command(command)
      command.each_char do |command|
        case
          when command == 'L'
            turn_left
          when command == 'R'
            turn_right
          when command == 'M'
            go
        end
      end
    end 

  end
  
  class Plateau

    attr_accessor :width, :height
    attr_reader :grid, :occupied_spots

    def initialize(width, height)
      @height = height
      @width = width
      @grid = Array.new(width) { Array.new(height) }
      @occupied_spots = {}
    end
  
    def land(rover, position)
      if available?(position)
        @grid[position[:x]][position[:y]] = rover
        @occupied_spots[rover] = position
      else
        raise "Spot on Plateau unavailable!"
      end
    end
  
    def position(rover)
      object_position = @occupied_spots[rover]
      raise "Object in question not on Plateau!" unless object_position
      object_position
    end
  
    def available?(position)
      unless on_planet?(position)
        raise "Out of bounds!"
      end
      @grid[position[:x]][position[:y]].nil?
    end
  
    def on_planet?(position)
      position[:x].between?(0, @width - 1) and position[:y].between?(0, @height - 1)
    end
  
    def move(rover, position)
      unless on_planet?(position)
        raise "Out of bounds!"
      end
      unless available?(position)
        raise "Collision with another rover!"
      end
  
      current_position = @occupied_spots[rover]
  
      @grid[current_position[:x]][current_position[:y]] = nil
      @grid[position[:x]][position[:y]] = rover
      @occupied_spots[rover] = position
    end
  end
  
  def execute(input)
    raise "Must provide input!" unless input != ""
    input_lines = split_on_newline(input)
    grid_dimensions = input_lines[0]
    raise "Invalid grid data provided, please check your input." unless valid_grid_data?(grid_dimensions) 
     
    width = split_on_spaces(grid_dimensions)[0].to_i + 1
    height = split_on_spaces(grid_dimensions)[1].to_i + 1
  
    plateau = Plateau.new(width, height)
  
    line = 1
    while line < input_lines.size do
      rover_line = input_lines[line]
      raise "Invalid rover data provided. Please check yout input." unless valid_rover_data?(rover_line)
      rover_params = split_on_spaces(rover_line)
      rover = Rover.new(plateau, rover_params[2])
      plateau.land(rover, {x: rover_params[0].to_i, y: rover_params[1].to_i})
      line += 1
  
      moves = input_lines[line]
      raise "Invalid command string, please check your input" unless valid_command_string?(moves)
      moves.split("").each do |command|
      case command
        when 'R' then rover.turn_right
        when 'L' then rover.turn_left
        when 'M' then rover.go
      end
    end
    puts "#{rover.position[:x]} #{rover.position[:y]} #{rover.direction}"
    line += 1
  end
end

def split_on_newline(input)
  return input.split("\n")
end 

def split_on_spaces(input)
  return input.split(" ")
end 

def valid_grid_data?(grid_data)
  return grid_data.match?(/^\d\s\d$/)
end 

def valid_rover_data?(rover_data)
  return rover_data.match?(/^(\d+)\s(\d+)\s([NSEW])$/)
end 

def valid_command_string?(commands)
  return commands.match?(/^[LMR]+$/)
end

def valid_parser_string?(string_for_parser)
  return string_for_parser.match?(/^(\d+)\s(\d+)([\n](\d+)\s(\d+)\s([NSEW])[\n]([LMR]+))+$/)
end 

input = ""
File.open("sample-input.in").each do |line|
  input.concat(line)
end 
execute(input)


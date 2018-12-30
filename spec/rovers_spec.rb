require "spec_helper"

describe PlanetObject do 
    context "keeps track of rovers on grid" do 
        let(:plateau) {Plateau.new(6,6)}
        let(:rover) {Rover.new(plateau,"E")}
        let(:two_by_two_plateau) {Plateau.new(2,2)}
        let(:rover1) {Rover.new(two_by_two_plateau,"N")}
        let(:rover2) {Rover.new(two_by_two_plateau,"N")}
        let(:rover3) {Rover.new(two_by_two_plateau,"N")}
        let(:rover4) {Rover.new(two_by_two_plateau,"N")}
        let(:valid_input) {"5 7\n1 2 N\nLMLMLMLMM\n1 2 N\nLMLMLMLM\n3 3 E\nMMRMMRMRRM"}
        let(:invalid_plateau) {"y 7\n1 2 N\nLMLMLMLMM\n1 2 N\nLMLMLMLM\n3 3 E\nMMRMMRMRRM"}
        let(:blank_input) {""}
        let(:invalid_rover_direction) {"5 7\n1 2 :)\nLMLMMLMM\n1 2 :\nLMLMLMLM\n3 3 E\nMMRMMRMRRM"}
        let(:invalid_rover_coordinates) {"5 7\n1 :)\nLMLMLMLMM\n1 2 N\nLMLMLMLM\n3 3 E\nMMRMMRMRRM"}
        let(:invalid_commands) {"5 7\n1 2 N\nLMLMLMLMM\n1 2 N\nLMLMLMLM\n3 3 E\nMMRheloooooooooMRRM"}
        let(:invalid_parser_string) {"5 7\n1 2\n\n\n\n\n invalid parser string"}

        describe "initialization" do 

            it "is able to initialize new plateau" do 
                expect(plateau).to be_instance_of(Plateau)
            end

            it "sets up plateau attributes properly" do 
                expect(plateau.height).eql?(6)
                expect(plateau.width).eql?(6)
            end

            it "is able to initialize new rover" do 
                expect(rover).to be_instance_of(Rover)
            end

            it "initializes object to store occupied spots on grid" do 
                expect(plateau.occupied_spots).to be_kind_of(Object)
            end

            it "initializes starter grid full of nil elements" do 
                expect(plateau.grid).to be_kind_of(Array)
                expect(plateau.grid).to eq([[nil, nil, nil, nil, nil, nil],
                                            [nil, nil, nil, nil, nil, nil],
                                            [nil, nil, nil, nil, nil, nil],
                                            [nil, nil, nil, nil, nil, nil],
                                            [nil, nil, nil, nil, nil, nil],
                                            [nil, nil, nil, nil, nil, nil]
                                        ])
            end
        end 

        describe "land rover" do
            it "lands rover" do 
                plateau.land(rover, {x: 0, y: 0})
                expect(plateau.occupied_spots).to include(rover)
            end 

            it "rover facing correct direction" do 
                plateau.land(rover, {x: 0, y: 0})
                expect(rover.direction).to eq("E")
            end 

            it "doesn't land rover on unavailable spot" do 
            plateau.land(rover, {x: 1, y: 1})
            expect { plateau.land(rover, {x: 1, y: 1}) }.to raise_error("Spot on Plateau unavailable!")
            expect(plateau.occupied_spots.length).to eq(1)
            end
            
            it "lands multiple rovers" do 
                plateau.land(rover, {x: 2, y: 2})
                plateau.land(rover1, {x: 4, y: 0})
                expect(plateau.occupied_spots.length).to eq(2)
            end 

            it "doesn't allow landing when out of grid bounds" do 
                plateau.land(rover, {x: 2, y: 2})
                expect { plateau.land(rover, {x: 7, y: 7}) }.to raise_error("Out of bounds!")
                expect(plateau.occupied_spots.length).to eq(1)
            end 

            it "rover occupies a specific spot on the grid" do 
                plateau.land(rover, {x: 2, y: 2})
                expect(plateau.grid[2][2]).eql?(rover)
            end 

            it "once entire grid is filled, no more rovers can land" do 
                two_by_two_plateau.land(rover1, {x: 0, y: 0})
                two_by_two_plateau.land(rover2, {x: 0, y: 1})
                two_by_two_plateau.land(rover3, {x: 1, y: 0})
                two_by_two_plateau.land(rover4, {x: 1, y: 1})
                expect(two_by_two_plateau.occupied_spots.length).to eq(4)
                expect { two_by_two_plateau.land(rover2, {x: 1, y: 2}) }.to raise_error("Out of bounds!")
                expect { two_by_two_plateau.land(rover2, {x: 1, y: 1}) }.to raise_error("Spot on Plateau unavailable!")
            end 
        end 

        describe "rover moving on grid" do 
            before :each do
                plateau.land(rover, {x: 2, y: 2})
                plateau.land(rover2, {x: 0, y: 0})
            end

            it "moves to final destination specified" do 
               rover.move({x: 4, y: 4})
               expect(rover.position[:x]).to eq(4)
               expect(rover.position[:y]).to eq(4)
            end 

            it "doesn't move rover if anticipated final position out of bounds" do 
                expect { rover.move({x: 8, y: 8}) }.to raise_error("Out of bounds!")
                expect(rover.position[:x]).to eq(2)
                expect(rover.position[:y]).to eq(2)
            end

            it "doesn't move rover in case of possible collision with another rover" do 
                expect { rover.move({x: 0, y: 0}) }.to raise_error("Collision with another rover!")
                expect(rover.position[:x]).to eq(2)
                expect(rover.position[:y]).to eq(2)
            end
        end 

        describe "execute" do 

            it "executes with valid commands" do 
                expect { execute(valid_input) }.to output("1 3 N\n1 2 N\n5 1 E\n").to_stdout
            end 

            it "throws an error for blank command " do 
                expect { execute(blank_input) }.to raise_error("Must provide input!")
            end 

            it "throws an error for invalid plateau coordinates " do 
                expect { execute(invalid_plateau) }.to raise_error("Invalid grid data provided, please check your input.")
            end 

            it "throws an error when it receives invalid rover coordinates " do 
                expect { execute(invalid_rover_coordinates) }.to raise_error("Invalid rover data provided. Please check yout input.")
            end 

            it "throws an error for invalid rover direction " do 
                expect { execute(invalid_rover_direction) }.to raise_error("Invalid rover data provided. Please check yout input.")
            end 

            it "throws an error for invalid commands " do 
                expect { execute(invalid_commands) }.to raise_error("Invalid command string, please check your input")
            end 

            it "raises error for invalid parser string" do 
                expect { execute(invalid_parser_string) }.to raise_error(RuntimeError)
            end
        end

    end 

end 
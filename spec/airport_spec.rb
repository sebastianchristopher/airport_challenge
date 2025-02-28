require 'airport'

describe Airport do
  let(:plane) { double(:plane, flying?: true) }
  let(:weather) { double(:weather) }
  before(:each) { allow(plane).to receive(:land) }

  context 'airport capcity' do # this is contingent on instruct_plane_to_land as I don't want a getter method for capacity
    let(:weather) { double(:weather, stormy?: false) }

    it 'has a default capacity' do
      Airport::DEFAULT_CAPACITY.times { subject.instruct_plane_to_land(plane, weather) }
      expect { subject.instruct_plane_to_land(plane, weather) }.to raise_error("Cannot land - airport is full!")
    end
    it 'has a variable capacity' do
      variable_capacity = 25
      bigger_airport = Airport.new(variable_capacity)
      variable_capacity.times { bigger_airport.instruct_plane_to_land(plane, weather) }
      expect { bigger_airport.instruct_plane_to_land(plane, weather) }.to raise_error("Cannot land - airport is full!")
    end
  end

  context 'when weather is stormy' do
    it 'can prevent landing when stormy' do
      allow(weather).to receive(:stormy?).and_return(true)
      expect { subject.instruct_plane_to_land(plane, weather) }.to raise_error("Cannot land - severe weather warning!")
      expect(subject.planes).to_not include(plane)
    end
    it 'can prevent planes from taking off when stormy' do
      allow(weather).to receive(:stormy?).and_return(false)
      subject.instruct_plane_to_land(plane, weather)
      allow(weather).to receive(:stormy?).and_return(true)
      expect { subject.instruct_plane_to_take_off(plane, weather) }.to raise_error("Cannot take off - severe weather warning!")
      expect(subject.planes).to include(plane)
    end
  end

  context 'when weather is not stormy' do
    let(:weather) { double(:weather, stormy?: false) }

    context 'when plane is flying' do
      it 'can intruct planes to land' do
        subject.instruct_plane_to_land(plane, weather)
        expect(subject.planes).to include(plane)
      end
      it 'can prevent landing when full' do
        full_airport = Airport.new(0)
        expect { full_airport.instruct_plane_to_land(plane, weather) }.to raise_error("Cannot land - airport is full!")
        expect(full_airport.planes).to_not include(plane)
      end
      it 'can confirm a plane is or isn\'t in the airport' do
        expect(subject.in_airport?(plane)).to_not be(true)
        subject.instruct_plane_to_land(plane, weather)
        expect(subject.in_airport?(plane)).to be(true)
      end
      it 'a plane that\'s flying can\'t take off' do
        expect { subject.instruct_plane_to_take_off(plane, weather) }.to raise_error("This plane is not in your airport!")
      end
      it 'a plane lands when it enters the airport' do
        expect(plane).to receive(:land)
        subject.instruct_plane_to_land(plane, weather)
      end
    end

    context 'when plane is not flying' do
      before(:each) { subject.instruct_plane_to_land(plane, weather) }
      before(:each) { allow(plane).to receive(:take_off) }
      it 'can instruct planes to take off' do
        expect(subject.planes).to include(plane)
        subject.instruct_plane_to_take_off(plane, weather)
        expect(subject.planes).to_not include(plane)
      end
      it 'a plane can\'t land if it\'s already at an airport' do
        airport_2 = Airport.new
        allow(plane).to receive(:flying?).and_return(false)
        expect(subject.planes).to include(plane)
        expect { airport_2.instruct_plane_to_land(plane, weather) }.to raise_error("This plane is not in flight!")
        expect(airport_2.planes).to_not include(plane)
      end
      it 'a plane can\'t land if it\'s not flying' do
        allow(plane).to receive(:flying?).and_return(false)
        expect { subject.instruct_plane_to_land(plane, weather) }.to raise_error("This plane is not in flight!")
      end
      it 'a plane can only take off from an airport it is in' do
        airport_2 = Airport.new
        expect { airport_2.instruct_plane_to_take_off(plane, weather) }.to raise_error("This plane is not in your airport!")
        expect(subject.planes).to include(plane)
      end
      it 'a plane takes off when it leaves the airport' do
        expect(plane).to receive(:take_off)
        subject.instruct_plane_to_take_off(plane, weather)
      end
    end
  end
end

require 'airport'

describe Airport do
  let(:plane) { double(:plane) }
  let(:weather) { double(:weather) }

  it 'has a default capacity' do
    expect(subject.capacity).to eq(Airport::DEFAULT_CAPACITY)
  end
  it 'has a variable capacity' do
    airport = Airport.new(20)
    expect(airport.capacity).to eq(20)
  end
  it 'can intruct planes to land' do
    allow(weather).to receive(:stormy?).and_return(false)
    subject.instruct_plane_to_land(plane, weather)
    expect(subject.planes).to include(plane)
  end
  xit 'cannot store more planes than capacity' do #this is tested with prevent landing when full I think?
  end
  it 'can confirm a plane is or isn\'t in the airport' do
    allow(weather).to receive(:stormy?).and_return(false)
    expect(subject.in_airport?(plane)).to_not be(true)
    subject.instruct_plane_to_land(plane, weather)
    expect(subject.in_airport?(plane)).to be(true)
  end
  it 'can prevent landing when stormy' do
    allow(weather).to receive(:stormy?).and_return(true)
    expect { subject.instruct_plane_to_land(plane, weather) }.to raise_error("Cannot land - severe weather warning!")
    expect(subject.planes).to_not include(plane)
  end
  it 'can prevent landing when full' do
    allow(weather).to receive(:stormy?).and_return(false)
    full_airport = Airport.new(0)
    expect { full_airport.instruct_plane_to_land(plane, weather) }.to raise_error("Cannot land - airport is full!")
    expect(full_airport.planes).to_not include(plane)
  end
  it 'can instruct planes to take off' do
    allow(weather).to receive(:stormy?).and_return(false)
    subject.instruct_plane_to_land(plane, weather)
    subject.instruct_plane_to_take_off(plane, weather)
    expect(subject.planes).to_not include(plane)
  end
end

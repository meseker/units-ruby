require 'matrix'
require 'minitest/autorun'
require 'units/numeric'

describe Units::Numeric do
    let(:one)	{ Units::Numeric.new(1) }
    let(:three)	{ Units::Numeric.new(3) }
    let(:four)	{ Units::Numeric.new(4) }
    let(:seven)	{ Units::Numeric.new(7) }
    let(:twelve){ Units::Numeric.new(12) }

    let(:three_inches)	{ Units::Numeric.new(3, :inches) }
    let(:four_inches)	{ Units::Numeric.new(4, :inches) }

    let(:one_meter)	{ Units::Numeric.new(1, :meter) }
    let(:three_meters)	{ Units::Numeric.new(3, :meters) }
    let(:four_meters)	{ Units::Numeric.new(4, :meters) }
    let(:six_meters)	{ Units::Numeric.new(6, :meters) }
    let(:seven_meters)	{ Units::Numeric.new(7, :meters) }
    let(:twelve_meters)	{ Units::Numeric.new(12, :meters) }

    let(:twelve_meters2)    { Units::Numeric.new(12, Units.new(:meters, :meters)) }

    it "should claim to be a Numeric" do
	one.must_be_kind_of Numeric
    end

    describe "when constructing" do
	it "should require a value" do
	    lambda { Units::Numeric.new }.must_raise(ArgumentError)
	end

	it "should accept a Unit, but not require it" do
	    Units::Numeric.new(1).must_equal 1
	    Units::Numeric.new(1, :meter).must_equal one_meter
	end
    end

    describe "equality" do
	let(:three_inches)	{ Units::Numeric.new(3, :inches) }
	let(:three_meters)	{ Units::Numeric.new(3, :meters) }

	it "must equate zero-with-units and zero" do
	    0.meters.must_equal 0
	end

	it "should not equate a literal with units and a literal without units" do
	    three_meters.wont_equal 3
	end

	it "should not equate meters with inches" do
	    three_meters.wont_equal three_inches
	    three_inches.wont_equal three_meters
	end

	it "should preserve normal equality for literals without units" do
	    three.must_equal three
	    Units::Numeric.new(3).must_equal 3
	    Units::Numeric.new(3.5).must_equal 3.5
	end
    end

    describe "arithmetic without units" do
	it "should preserve integer addition" do
	    (three + four).must_equal seven
	end

	it "should preserve integer subtraction" do
	    (four - three).must_equal one
	    (three - four).must_equal -one
	end

	it "should preserve integer multiplication" do
	    (three * four).must_equal twelve
	end

	it "should preserve integer division" do
	    (twelve/four).must_equal three
	end
    end

    describe "arithmetic with like units" do
	it "should support addition" do
	    (three_meters + four_meters).must_equal seven_meters
	end

	it "should support subtraction" do
	    (four_meters - three_meters).must_equal one_meter
	    (0.meters - four_meters).must_equal -four_meters
	end

	it "should support multiplication" do
	    (3.meters * 4.meters).must_equal twelve_meters2
	end

	it "should support division" do
	    (twelve_meters / three_meters).must_equal 4
	    (0.meters / 3.meters).must_equal 0
	end

	it 'must support exponentiation' do
	    (3.meters**2).must_equal 9.meters(2)
	    (Rational(3,1).meters**2).must_equal Rational(9,1).meters(2)
	end
    end

    describe "coerced arithmetic" do
	it "addition" do
	    (4 + three_meters).must_equal seven_meters
	end

	it "subtraction" do
	    (4 - three_meters).must_equal one_meter
	    (0 - four_meters).must_equal -four_meters
	end

	it "multiplication" do
	    (4 * three_meters).must_equal twelve_meters
	end

	it "division" do
	    (0 / one_meter).must_equal 0
	    (0 / three_meters).must_equal 0
	    (4 / three_meters).must_equal one_meter
	    (12.0 / three_meters).must_equal four_meters
	end

	it "must divide a Rational" do
	    (Rational(2,1) / one_meter).must_equal Rational(2,1).meters(-1)
	end

    end

    describe "integer arithmetic with normal literals" do
	it "should support multiplication" do
	    (three_meters * 4).must_equal twelve_meters
	    (three_meters * four).must_equal twelve_meters
	end

	it "support division" do
	    (twelve_meters / 3).must_equal four_meters
	    (one_meter / 2).must_equal 0.meters
	end
    end

    describe "arithmetic with mixed units" do
	it "should allow addition of valid units and no units" do
	    (three_meters + four).must_equal seven_meters
	    (four + three_meters).must_equal seven_meters
	end

	it "should allow subtraction of valid units and no units" do
	    (three_meters - three).must_equal 0.meters
	    (three - three_meters).must_equal 0.meters
	end

	it "should reject mixed units when adding" do
	    lambda { three_meters + three_inches }.must_raise UnitsError
	end

	it "should reject mixed units when subtracting" do
	    lambda { three_meters - four_inches }.must_raise UnitsError
	end

	it "must return a Vector when multiplying a Vector" do
	    v = (three_meters * Vector[1,2])
	    v.must_be_kind_of Vector
	    v[0].must_equal three_meters
	    v[1].must_equal six_meters
	end
    end

    describe "comparison" do
	describe "spaceship" do
	    it "must spaceship with like units" do
		(three_meters <=> four_meters).must_equal -1
		(three_meters <=> three_meters).must_equal 0
		(four_meters <=> three_meters).must_equal 1
	    end

	    it "must not spaceship with unlike units" do
		(three_meters <=> three_inches).must_be_nil
	    end

	    it "must spaceship with unitless literals" do
		(three_meters <=> 4).must_equal -1
		(three_meters <=> 3).must_equal 0
		(four_meters <=> 3).must_equal 1
	    end

	    it "must reverse spaceship with unitless literals" do
		(3 <=> four_meters).must_equal -1
		(3 <=> three_meters).must_equal 0
		(4 <=> three_meters).must_equal 1
	    end
	end
    end

    it "must square root" do
	Math.sqrt(three_meters*three_meters).must_equal three_meters
    end

    it "should have an inspect method" do
	assert_equal('1 meter', one_meter.inspect)
	assert_equal(1, one);
    end
    it "should have a to_s method that returns only the literal's to_s" do
	assert_equal('1', one_meter.to_s)
    end

    describe "when converting to other units" do
	it "must convert to different units" do
	    one_meter.to_inches.must_equal 39.3701.inches
	end

	it "must do nothing when converting to identical units" do
	    one_meter.to_meters.must_equal one_meter
	end

	it "must handle prefix-only conversions" do
	    one_meter.to_millimeters.must_equal 1000.mm
	end

	it "must handle mixed prefix conversions" do
	    100.cm.to_inches.must_equal 39.3701.inches
	    100.inches.to_centimeters.must_equal 254.cm
	end

	it "must handle converting to abbreviated units" do
	    100.cm.to_mm.must_equal 1000.mm
	end

	it "must reject invalid target units" do
	    -> { 100.cm.to_foo }.must_raise NoMethodError
	end
    end

    describe 'when converting to other units without the to_ prefix' do
	it 'must convert to different units' do
	    one_meter.inches.must_equal 39.3701.inches
	end

	it 'must do nothing when converting to identical units' do
	    one_meter.meters.must_equal one_meter
	end

	it 'must handle prefix-only conversions' do
	    one_meter.millimeters.must_equal 1000.mm
	end

	it 'must handle mixed prefix conversions' do
	    100.cm.inches.must_equal 39.3701.inches
	    100.inches.centimeters.must_equal 254.cm
	end

	it 'must handle converting to abbreviated units' do
	    100.cm.mm.must_equal 1000.mm
	end

	it 'must reject invalid target units' do
	    -> { 100.cm.foo }.must_raise NoMethodError
	end
    end

    describe 'when asked about its units' do
	it 'must be degrees' do
	    90.degrees.degrees?.must_equal true
	end

	it 'must be meters' do
	    1.meter.meters?.must_equal true
	end

	it 'must be inches' do
	    1.inch.inch?.must_equal true
	end
    end
end

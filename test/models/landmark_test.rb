require "test_helper"

class LandmarkTest < ActiveSupport::TestCase
  def valid_attributes
    {
      name: "金閣寺",
      hiragana: "きんかくじ",
      question: "これは何の寺ですか？",
      answer1: "金閣寺",
      answer2: "清水寺",
      answer3: "東寺",
      correct: 1
    }
  end

  test "valid with all required attributes" do
    assert Landmark.new(valid_attributes).valid?
  end

  test "requires name, hiragana, question and answers" do
    %i[name hiragana question answer1 answer2 answer3].each do |attribute|
      landmark = Landmark.new(valid_attributes.merge(attribute => ""))
      assert_not landmark.valid?, "expected #{attribute} to be required"
      assert_includes landmark.errors.attribute_names, attribute
    end
  end

  test "requires correct within 1 to 3" do
    [ nil, 0, 4 ].each do |value|
      landmark = Landmark.new(valid_attributes.merge(correct: value))
      assert_not landmark.valid?, "expected correct=#{value.inspect} to be invalid"
      assert_includes landmark.errors.attribute_names, :correct
    end
  end

  test "latitude, longitude, url and author remain optional" do
    landmark = Landmark.new(valid_attributes.merge(latitude: nil, longitude: nil, url: nil, author: nil))
    assert landmark.valid?
  end
end

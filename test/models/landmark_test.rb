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
      correct: 1,
      region: regions(:kyoto)
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

  test "hiragana allows hiragana and long vowel mark" do
    %w[きんかくじ じぇーあーるきょうとえき].each do |value|
      assert Landmark.new(valid_attributes.merge(hiragana: value)).valid?, "expected #{value} to be valid"
    end
  end

  test "hiragana rejects non-hiragana" do
    [ "キンカクジ", "金閣寺", "kinkakuji", "きんかくじ!", "きんかくじ " ].each do |value|
      landmark = Landmark.new(valid_attributes.merge(hiragana: value))
      assert_not landmark.valid?, "expected #{value} to be invalid"
      assert_includes landmark.errors.attribute_names, :hiragana
    end
  end

  test "latitude, longitude and url remain optional" do
    landmark = Landmark.new(valid_attributes.merge(latitude: nil, longitude: nil, url: nil))
    assert landmark.valid?
  end

  test "requires region" do
    landmark = Landmark.new(valid_attributes.merge(region: nil))
    assert_not landmark.valid?
    assert_includes landmark.errors.attribute_names, :region
  end
end

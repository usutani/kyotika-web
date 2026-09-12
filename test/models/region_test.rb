require "test_helper"

class RegionTest < ActiveSupport::TestCase
  test "valid with name and hiragana" do
    assert Region.new(name: "嵐山", hiragana: "あらしやま").valid?
  end

  test "requires name and hiragana" do
    assert_not Region.new(name: "", hiragana: "あらしやま").valid?
    assert_not Region.new(name: "嵐山", hiragana: "").valid?
  end

  test "requires unique name" do
    assert_not Region.new(name: regions(:kyoto).name, hiragana: "きょうと").valid?
  end

  test "hiragana rejects non-hiragana" do
    assert_not Region.new(name: "嵐山", hiragana: "アラシヤマ").valid?
  end

  test "orders by hiragana" do
    assert_equal %w[きょうと こうべしちゅうおうく], Region.order(:hiragana).pluck(:hiragana)
  end
end

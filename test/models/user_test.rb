require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "role defaults to member and status defaults to active" do
    user = User.create!(name: "利用者", email_address: "user@example.com",
      password: "password123", password_confirmation: "password123")
    assert user.member?
    assert user.active?
  end

  test "email uniqueness is case insensitive" do
    User.create!(name: "一人目", email_address: "user@example.com",
      password: "password123", password_confirmation: "password123")
    other = User.new(name: "二人目", email_address: "USER@example.com",
      password: "password123", password_confirmation: "password123")
    assert_not other.valid?
  end

  test "deactivate keeps email and destroys sessions" do
    user = User.create!(name: "利用者", email_address: "user@example.com",
      password: "password123", password_confirmation: "password123")
    user.sessions.create!(last_active_at: Time.now)
    landmark = Landmark.create!(name: "寺", hiragana: "てら", creator: user)

    user.deactivate!

    assert user.deactivated?
    assert_equal "user@example.com", user.reload.email_address
    assert_equal 0, user.sessions.count
    assert_equal user, landmark.reload.creator

    user.reactivate!
    assert user.active?
  end
end

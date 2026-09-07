class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user

  def session=(value)
    super

    self.user = value&.user
  end
end

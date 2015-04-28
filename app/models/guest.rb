class Guest
  def admin?
    false
  end

  def role
    "guest"
  end

  def name
    "guest"
  end

  def guest?
    true
  end

  def image_link
    '/assets/images/profile_default.png'
  end
end

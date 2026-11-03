module BriefingsHelper
  def greeting(now = Time.current)
    return "Good morning, Natalia." if now.hour < 12
    return "Good afternoon, Natalia." if now.hour < 18

    "Good evening, Natalia."
  end
end

module BriefingsHelper
  def greeting(now = Time.current)
    return "Good morning, Natalia." if now.hour < 12
    return "Good afternoon, Natalia." if now.hour < 18

    "Good evening, Natalia."
  end

  def section_bar(story)
    { "must_know" => "border-l-accent", "for_you" => "border-l-success", "one_new_thing" => "border-l-warning" }.fetch(story.section)
  end
end

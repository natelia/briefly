module BriefingsHelper
  def missed_day_briefing(briefing)
    day = Briefing.for_date(briefing.date - 1.day)
    return nil if day.nil?
    return nil if day.stories.unread.empty?

    day
  end

  def greeting(now = Time.current)
    return "Good morning, Natalia." if now.hour < 12
    return "Good afternoon, Natalia." if now.hour < 18

    "Good evening, Natalia."
  end

  def section_bar(story)
    { "must_know" => "border-l-accent", "for_you" => "border-l-success", "one_new_thing" => "border-l-warning" }.fetch(story.section)
  end
end

  def section_hue(record)
    key = record.is_a?(Story) ? record.section.to_s : record.to_s
    { "must_know" => "s1", "for_you" => "s2", "one_new_thing" => "s3" }.fetch(key, "s4")
  end

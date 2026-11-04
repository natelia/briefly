# Seeds build a complete demo day: today's full briefing, yesterday with one
# unread story (the missed-day band), and the four-card "How LLMs work" series
# across four consecutive briefings. Idempotent: skips entirely once today
# exists, so re-running is always a no-op.

return if Briefing.for_date(Date.current)

def seed_briefing(date, stories, quiz: nil, card: nil)
  briefing = Briefing.create!(date: date)
  stories.each { |attrs| Story.create!(attrs.merge(briefing: briefing)) }
  QuizQuestion.create!(quiz.merge(briefing: briefing)) if quiz
  ConceptCard.create!(card.merge(briefing: briefing)) if card
  briefing
end

read = { read_at: 1.day.ago }

# Three days ago — series part 1, all handled.
seed_briefing(Date.current - 3.days, [
  { section: :must_know, title: "Kubernetes drops support for old dockers", source_name: "kubernetes.io",
    url: "https://kubernetes.io/blog/", summary: "The kubelet stops talking to ancient container runtimes.",
    published_at: 4.days.ago }.merge(read),
  { section: :one_new_thing, title: "Local-first software: your data, your disk", source_name: "inkandswitch.com",
    url: "https://www.inkandswitch.com/local-first/",
    summary: "Apps that work offline first and sync when they can. No spinner, no lock-in.",
    published_at: 4.days.ago }.merge(read)
], card: {
  title: "How LLMs work", domain: "llms", series_name: "How LLMs work", series_position: 1,
  what_it_is: "A model that predicts the next word, trained on a huge slice of written text.",
  how_it_works: "Text becomes numbers. The model learns which numbers tend to follow which. Generation repeats that guess, one token at a time.",
  why_you_care: "Every AI feature you meet is this loop wearing a different coat.",
  deeper_link: "https://en.wikipedia.org/wiki/Large_language_model"
})

# Two days ago — series part 2.
seed_briefing(Date.current - 2.days, [
  { section: :must_know, title: "Passkeys cross a billion accounts", source_name: "passkeys.dev",
    url: "https://www.passkeys.dev/", summary: "The passwordless login standard hits mainstream adoption.",
    published_at: 3.days.ago }.merge(read)
], card: {
  title: "RAG", domain: "llms", series_name: "How LLMs work", series_position: 2,
  what_it_is: "Retrieval-Augmented Generation: the model answers from your documents, not from memory.",
  how_it_works: "Your text is fetched first, then handed to the model with the question. The model writes over what it was given.",
  why_you_care: "It is why an AI tool can quote your handbook instead of inventing one.",
  deeper_link: "https://en.wikipedia.org/wiki/Retrieval-augmented_generation"
})

# Yesterday — series part 3, one story left unread so the band shows.
seed_briefing(Date.yesterday, [
  { section: :must_know, title: "EU AI Act enforcement begins", source_name: "wikipedia.org",
    url: "https://en.wikipedia.org/wiki/Artificial_Intelligence_Act", summary: "First fines land under the new transparency rules.",
    published_at: 2.days.ago }.merge(read),
  { section: :for_you, title: "Ruby 3.5 preview: YJIT on by default", source_name: "ruby-lang.org",
    url: "https://www.ruby-lang.org/en/news/",
    summary: "The next Ruby ships with the JIT enabled out of the box.", published_at: 2.days.ago }
], card: {
  title: "Vector databases", domain: "databases", series_name: "How LLMs work", series_position: 3,
  what_it_is: "A store that searches by meaning, not exact match.",
  how_it_works: "Text becomes a list of numbers. Nearby numbers mean nearby ideas. Search asks for neighbours.",
  why_you_care: "It is the shelf RAG reads from. No shelf, no quotes.",
  deeper_link: "https://en.wikipedia.org/wiki/Vector_database"
})

# Today — the full demo day.
seed_briefing(Date.current, [
  { section: :must_know, title: "npm supply-chain attack hits popular packages", source_name: "wikipedia.org",
    url: "https://en.wikipedia.org/wiki/Supply_chain_attack",
    summary: "Attackers hijacked maintainer accounts and shipped malicious versions overnight.",
    published_at: 1.day.ago },
  { section: :must_know, title: "Cloudflare outage takes down half the indie web", source_name: "blog.cloudflare.com",
    url: "https://blog.cloudflare.com/cloudflare-outage/",
    summary: "A bad config push broke DNS for an hour. Small sites felt it first.", published_at: 1.day.ago },
  { section: :must_know, title: "GitHub requires 2FA for all contributors", source_name: "docs.github.com",
    url: "https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa",
    summary: "The last holdouts get locked out of pushing code.", published_at: 1.day.ago },
  { section: :for_you, title: "CSS container queries land everywhere", source_name: "developer.mozilla.org",
    url: "https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment",
    summary: "All evergreen browsers now ship container queries.", published_at: 1.day.ago, stretch: true,
    why_it_matters: "A stretch pick: container queries change how components size themselves in CSS. You don't write frontend — but this pattern shows up in component design everywhere." },
  { section: :for_you, title: "SQLite everywhere: the database that stayed boring", source_name: "sqlite.org",
    url: "https://www.sqlite.org/mostdeployed.html", summary: "The fastest deployment path is now a file. Boring won again.",
    published_at: 1.day.ago },
  { section: :for_you, title: "Tailscale made the office VPN obsolete", source_name: "tailscale.com",
    url: "https://tailscale.com/blog/how-tailscale-works",
    summary: "Your devices find each other anywhere. No VPN concentrator, no ticket.", published_at: 1.day.ago },
  { section: :one_new_thing, title: "CRDTs: the idea behind realtime collaboration", source_name: "wikipedia.org",
    url: "https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type",
    summary: "Conflict-free Replicated Data Types let edits merge without a server choosing winners.",
    published_at: 1.day.ago }
], quiz: {
  question: "What makes an attack a supply-chain attack?",
  options: [ "It hides inside software you already trust", "It needs a leaked password list", "It only targets big companies" ],
  answer_index: 0,
  explanation: "You install packages you trust every day. A poisoned version of one rides that trust straight in."
}, card: {
  title: "Tool use", domain: "llms", series_name: "How LLMs work", series_position: 4,
  what_it_is: "The model calls your tools: search, calendar, code. It acts, not just answers.",
  how_it_works: "The model writes a call. Your code runs it. The result goes back in as context, and the loop continues.",
  why_you_care: "This is how assistants stop being chatbots.",
  deeper_link: "https://en.wikipedia.org/wiki/Tool_use"
})

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
    digest: <<~DIGEST,
      The kubelet no longer talks to ancient container runtimes: deprecated dockershim-era paths are gone, and clusters must speak containerd or CRI-O.

      For most operators this changes nothing — the migration finished years ago. The stragglers are the ones running custom images or ancient clusters that never rebooted.

      The pattern is the story: Kubernetes keeps its surface small by cutting old doors. Upgrades are boring exactly because deprecations are enforced.

      If your cluster still says docker somewhere in the stack, this release is your deadline, not your warning.
    DIGEST
    published_at: 4.days.ago }.merge(read),
  { section: :one_new_thing, title: "Local-first software: your data, your disk", source_name: "inkandswitch.com",
    url: "https://www.inkandswitch.com/local-first/",
    digest: <<~DIGEST,
      Local-first software inverts the cloud default: the app works offline on a file you own, and the network is an enhancement, not a requirement.

      The seven ideals from the Ink & Switch essay: fast by default, multi-device, offline, collaborative, longevity of data, privacy by architecture, and user ownership. No spinner, because there's no server round-trip.

      The technology exists: CRDTs handle merging, and SQLite on device handles storage. What's missing is the ecosystem push — sync infrastructure that doesn't demand your data live in someone else's database.

      It's the strongest current answer to "what happens to my notes when your company dies": nothing, because they're on your disk.
    DIGEST
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
    digest: <<~DIGEST,
      Passkeys replaced the password with a key pair: the private half lives in your device, the public half sits on the server. Nothing secret is ever transmitted, so there is nothing to phish.

      Cross-device sync — Apple, Google, and password managers all ship it — solved the thing that killed every previous attempt: losing your keys when you lose your phone.

      The billion-account mark is the ecosystem tipping point: banks and governments now ship passkey login, not as a novelty but as the primary flow.

      Passwords don't die overnight, but the default flipped. New services launch passkey-first and treat passwords as legacy import.
    DIGEST
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
    digest: <<~DIGEST,
      The EU's AI Act moved from text to teeth: obligations now apply in phases, with transparency duties for general-purpose models among the first enforced.

      For developers the concrete requirements are documentation: what the model was trained on, what it can do, how it was evaluated. Deployers of "high-risk" systems face audits and registration.

      Fines scale like GDPR — up to a slice of global turnover — but the more interesting lever is market access. Selling AI into the EU without paperwork stops being possible.

      Expect the same pattern as privacy law: Brussels writes, the world complies, because nobody builds two products.
    DIGEST
    published_at: 2.days.ago }.merge(read),
  { section: :for_you, title: "Ruby 3.5 preview: YJIT on by default", source_name: "ruby-lang.org",
    url: "https://www.ruby-lang.org/en/news/",
    digest: <<~DIGEST,
      Ruby's just-in-time compiler, YJIT, ships enabled by default in the 3.5 preview — the first Ruby where fast is the factory setting.

      YJIT compiles hot paths to machine code while the program runs. It was built by Shopify for their Rails traffic, where it cut latency and server count in production for years.

      The default flip matters for everyone who never benchmarked anything: Rails apps get faster without touching a line. The interpreter stays as the fallback path.

      For a language long mocked for speed, this is the quietest big change in years.
    DIGEST
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
    digest: <<~DIGEST,
      The attack worked from the inside. Someone took over maintainer accounts on popular npm packages and published new versions that looked normal but carried an install script.

      Anyone who ran npm install pulled the poisoned version. The malicious code ran with full user permissions, could read environment variables, and could ship credentials home. Most victims never opened the file that hurt them.

      The hard part is structural: package registries run on trust in names, not people. When a maintainer hands over a package, or their token leaks, the package keeps its reputation and loses its safety.

      Defences that actually helped: lockfiles pinned to known versions, automatic review of install scripts, and registries flagging version bumps that ship minutes after an account changes hands.
    DIGEST
    summary: "Attackers hijacked maintainer accounts and shipped malicious versions overnight.",
    published_at: 1.day.ago },
  { section: :must_know, title: "Cloudflare outage takes down half the indie web", source_name: "blog.cloudflare.com",
    url: "https://blog.cloudflare.com/cloudflare-outage/",
    digest: <<~DIGEST,
      A single bad regular expression in a WAF rule took Cloudflare's edge down worldwide. Traffic kept arriving; the regex ran on every request and exhausted CPU.

      The failure was amplification: one rule, applied globally, in seconds. Routers marked nodes unhealthy, traffic shifted to neighbours, and those died the same way — a wave, not a spike.

      The postmortem is honest and worth reading. Cloudflare published the regex, the timeline, and the safeguards added since: global kill switches for rules, staged rollouts, and CPU guards that drop rules before they drop the network.

      Small sites felt it first because large ones had fallbacks. If your project lives on one edge, this is your reminder: an outage page you control beats an error you don't.
    DIGEST
    summary: "A bad config push broke DNS for an hour. Small sites felt it first.", published_at: 1.day.ago },
  { section: :must_know, title: "GitHub requires 2FA for all contributors", source_name: "docs.github.com",
    url: "https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa",
    digest: <<~DIGEST,
      GitHub finished rolling out mandatory two-factor authentication for everyone who contributes code. The holdouts are locked out of pushing until they enroll.

      The motivation is account takeover: leaked passwords from other sites still open GitHub accounts, and one compromised maintainer can ship malware to millions of installs — the supply-chain story above is the same wound.

      Passkeys count as 2FA and are the recommended path: nothing to phish, nothing to type. TOTP apps still work; SMS is the last resort.

      The ecosystem effect matters more than the enforcement. Package registries inherit identity from GitHub logins, so this hardens npm, PyPI and RubyGems at the root instead of at every leaf.
    DIGEST
    summary: "The last holdouts get locked out of pushing code.", published_at: 1.day.ago },
  { section: :for_you, title: "CSS container queries land everywhere", source_name: "developer.mozilla.org",
    url: "https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment",
    digest: <<~DIGEST,
      Container queries answer a question media queries never could: not "how wide is the screen?" but "how wide is the box this component lives in?"

      The mechanics are two parts. A parent declares itself a container. Children then write rules against that container's size, and the same card can be three columns in a main area and a stack in a sidebar — with zero JavaScript.

      Design systems wanted this for a decade. Components finally own their own responsive behaviour, which means a component built once adapts wherever it's dropped.

      Support is now universal in evergreen browsers, so the polyfills are retiring.
    DIGEST
    summary: "All evergreen browsers now ship container queries.", published_at: 1.day.ago, stretch: true,
    why_it_matters: "A stretch pick: container queries change how components size themselves in CSS. You don't write frontend — but this pattern shows up in component design everywhere." },
  { section: :for_you, title: "SQLite everywhere: the database that stayed boring", source_name: "sqlite.org",
    url: "https://www.sqlite.org/mostdeployed.html", summary: "The fastest deployment path is now a file. Boring won again.",
    digest: <<~DIGEST,
      SQLite is the most deployed database in the world by a distance no one can measure: phones, browsers, planes, and now a growing slice of web apps.

      The arguments that kept it out of servers — one writer at a time, no network protocol — turned out to be features. Embedded in the app process, it has no connection latency, no auth layer to misconfigure, and a whole database in one file you can copy.

      The modern pattern: run SQLite on the edge or a small VM, replicate the file, take snapshots by copying bytes. For read-heavy apps it's faster than a networked database at a fraction of the operations cost.

      Boring won because boring is a file.
    DIGEST
    published_at: 1.day.ago },
  { section: :for_you, title: "Tailscale made the office VPN obsolete", source_name: "tailscale.com",
    url: "https://tailscale.com/blog/how-tailscale-works",
    digest: <<~DIGEST,
      Tailscale builds a private mesh over the internet: your devices find each other, authenticate with your existing identity provider, and talk directly — no VPN concentrator, no port forwarding.

      Underneath it's WireGuard: each node gets a key pair, and traffic moves point to point, encrypted. A coordination server only introduces peers and hands out keys; it never sees your packets.

      What it removes is the ticket culture: no firewall change requests to reach a staging box, no shared VPN credentials, no "are you on the network?" The network is wherever your laptop is.

      The mental shift: access control moves from the perimeter to the device. ACLs say which machine may talk to which service — identity all the way down.
    DIGEST
    summary: "Your devices find each other anywhere. No VPN concentrator, no ticket.", published_at: 1.day.ago },
  { section: :one_new_thing, title: "CRDTs: the idea behind realtime collaboration", source_name: "wikipedia.org",
    url: "https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type",
    digest: <<~DIGEST,
      When two people type in the same document at once, someone has to decide whose keystroke wins. CRDTs — conflict-free replicated data types — make that decision unnecessary.

      Each edit carries enough information to merge deterministically: every replica applies the same edits in any order and lands on the same result. No central judge, no locking, no "user B is editing".

      The cost is metadata — the document carries history — and the hard part is garbage-collecting it. But the payoff is offline-first collaboration: edit on a plane, merge on landing.

      Google Docs and Figma popularised the operational-transform alternative; CRDTs are what made open-source and local-first editors possible without a proprietary server choosing winners.
    DIGEST
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

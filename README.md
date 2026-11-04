# Briefly

A personal daily tech briefing. Three sections, one quiz question, one concept card. Read it, mark stories read, close the tab — when the bar is full, you're caught up. That's the whole internet.

## Quickstart

```bash
bin/setup          # installs gems, prepares the database, seeds a full demo day
bin/dev            # starts the server (Procfile.dev)
```

Open http://localhost:3000. Seeded demo content:

- **Today** — 3 Must Know, 3 For You (one stretch with a why-box), 1 One New Thing, one quiz question, one concept card (the last card of the "How LLMs work" series).
- **Yesterday** — one story left unread, so the missed-day band shows: *"You skipped … Nothing stacked — one thing mattered: …"*
- **Three days of history** — all read, carrying the four-card "How LLMs work" series (LLMs → RAG → vector databases → tool use).

Seeds are idempotent: `bin/rails db:seed` again is a no-op. To rebuild the demo from scratch: `bin/rails db:reset`.

## Requirements

- Ruby 3.4 (`mise` or `rbenv`)
- PostgreSQL (or set `DATABASE_URL`)

## Tests

```bash
bin/rails test             # unit
bin/rails test test/system  # system (headless Chrome)
```

## The design

The briefing page runs a warm, slightly technical system: warm-white paper, one hue per section (coral Must Know, teal For You, violet One New Thing, gold Check-in), amber for the reading rule. Dark mode follows your system. Copy is governed by `docs/writing-style.md`: one idea per sentence, no school language, the quiz checks concepts — never story recall.

## Layout

- `app/models/briefing.rb` — one briefing per day, `read_fraction` drives the progress rule
- `app/models/story.rb` — sections, read/unread (`mark_read!` / `mark_unread!`)
- `app/models/quiz_question.rb` — one check-in question, gentle answers
- `app/models/concept_card.rb` — the concept of the day, series-aware
- `docs/writing-style.md` — how the app writes

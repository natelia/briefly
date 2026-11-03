# M1 — Seeded Reader Implementation Plan

> **For agentic workers:** Read this plan and its spec. Implement tasks in order, track steps with checkboxes (`- [ ]`), and run each task's checks before proceeding. Delegate only when the user explicitly authorizes it.
>
> **Mentor mode v2 (2026-11-03):** pi implements every task; before each change it explains what and why, after each commit it walks Natalia through the code. One task = one commit. Natalia reviews before the next task starts.

**Goal:** A working daily-briefing reader with seed content — openable in a browser, zero AI, zero fetching.

**Architecture:** Rails 8 monolith, server-rendered ERB + Turbo, PostgreSQL. M1 builds the read path only. Content arrives via `db/seeds.rb`.

**Tech stack:** Ruby 3.4.10, Rails 8.1.4, PostgreSQL 18, minitest, Rails defaults (importmap, propshaft). Solid Queue stays configured but unused until M6.

**Spec:** `docs/writing-style.md` (all copy), `docs/design/briefing-v3.html` (visual target).

## Global Constraints

- Approved additions only: `factory_bot_rails` (Task 4), `tailwindcss-rails` (Task 5). Nothing else without discussion.
- Tests: minitest. Every task: failing test → code → passing test → commit.
- Every user-facing string follows `docs/writing-style.md` — including seed content.
- Single user: no authentication, no user columns anywhere.
- Section names pinned: `must_know`, `for_you`, `one_new_thing`.
- Commit style: `feat:` / `test:` / `chore:` + imperative subject.

## Review Focus

1. Fresh database, visitor opens `/` → friendly empty state, not a 404 or 500. (T3)
2. Two briefings created for the same date → the second is invalid. (T1)
3. Quiz answered wrong → explanation appears, no error, no school language. (T7)
4. Yesterday's briefing fully read → no missed-day band; unread → band with a link to yesterday. (T9)
5. Story marked read → progress updates and survives a reload (persisted, not JS-only). (T6)

---

### Task 0: Scaffold ✅ (2026-11-03, clean restart)

Rails 8.1.4 app at `~/Projects/briefly` on mise-managed Ruby 3.4.12, clean git history, fresh GitHub repo. `docs/` carries the writing spec and the v3 mockup. PostgreSQL 18 installed and running; role `natalia` exists.

### Task 1: Briefing model

**Files:** Create `app/models/briefing.rb`, `db/migrate/*_create_briefings.rb`; Test `test/models/briefing_test.rb`.

**Interfaces:**
- Produces: `Briefing(date: date, created_at, updated_at)`, uniqueness on `date`; `Briefing.for_date(Date)` → first match or nil; `Briefing#stories`, `#quiz_questions` (later tasks add these).

- [ ] Step 1: Failing tests — `test_valid_briefing` (valid with a date), `test_date_must_be_unique` (second same-date briefing invalid), `test_for_date_finds_briefing` (creates + fetches by date, nil when absent).
- [ ] Step 2: `bin/rails test test/models/briefing_test.rb` → FAIL (NameError).
- [ ] Step 3: `rails g model Briefing date:date` + unique index, add validation `validates :date, presence: true, uniqueness: true`, `def self.for_date(d) = find_by(date: d)`.
- [ ] Step 4: Run → PASS.
- [ ] Step 5: Commit `feat: Briefing model with unique date`.

### Task 2: Story model

**Files:** Create `app/models/story.rb` + migration; Test `test/models/story_test.rb`.

**Interfaces:**
- Consumes: `Briefing` (T1).
- Produces: `Story(briefing:references, section:integer, title:string, source_name:string, url:string, summary:text, why_it_matters:text, stretch:boolean, read_at:datetime, published_at:datetime)`. Enum: `section: { must_know: 0, for_you: 1, one_new_thing: 2 }`. Instance: `#read?`, `#mark_read!` (sets `read_at`), scope `:unread`.

- [ ] Step 1: Failing tests — `test_section_enum_values`, `test_invalid_without_title_and_summary`, `test_read_state` (new story unread; `mark_read!` makes it read), `test_belongs_to_briefing`.
- [ ] Step 2: Run → FAIL.
- [ ] Step 3: `rails g model Story briefing:references section:integer title:string source_name:string url:string summary:text why_it_matters:text stretch:boolean read_at:datetime published_at:datetime` + enum + validations (`title`, `summary`, `section` presence) + `read?`/`mark_read!`/`unread`.
- [ ] Step 4: Run → PASS.
- [ ] Step 5: Commit `feat: Story model with sections and read state`.

### Task 3: Briefing page + empty state

**Files:** Create `app/controllers/briefings_controller.rb`, `app/views/briefings/show.html.erb`; Modify `config/routes.rb`; Test `test/controllers/briefings_controller_test.rb`.

**Interfaces:**
- Consumes: `Briefing.for_date` (T1).
- Produces: `root "briefings#show"`; `resources :briefings, only: :show, param: :date` → `briefing_path(date)`. Controller: `#show` assigns `@briefing = Briefing.for_date(params[:date] || Date.current)`.

- [ ] Step 1: Failing request tests — `test_show_renders_todays_briefing` (seeded briefing date shown), `test_missing_briefing_shows_empty_state` (asserts exact copy: "Nothing here yet. Tomorrow's briefing builds overnight.").
- [ ] Step 2: Run → FAIL.
- [ ] Step 3: Route, controller, minimal view: date heading + empty-state branch.
- [ ] Step 4: Run → PASS.
- [ ] Step 5: Commit `feat: briefing page with empty state`.

### Task 4: Story sections

**Files:** Create `app/views/briefings/_story.html.erb` + `_section.html.erb`; Modify `show.html.erb`; Test `test/system/briefing_sections_test.rb`.

**Interfaces:**
- Consumes: Story fields (T2). Page order pinned: Must Know → For You → One New Thing.
- Produces: partials `_section` (header + stories) and `_story` (title linked to `url`, source, summary, `why_it_matters` when `stretch`, section headers exact: "Must Know", "For You", "One New Thing").

- [ ] Step 1: Failing system test — `test_all_sections_render_their_stories` (visits root, asserts three headers, one story title per section, stretch story shows its why-line, non-stories don't).
- [ ] Step 2: `bin/rails test:system` → FAIL.
- [ ] Step 3: Partials + sections in `show.html.erb`.
- [ ] Step 4: Run → PASS.
- [ ] Step 5: Commit `feat: story sections on briefing page`.

### Task 5: Design port

**Files:** Modify `app/views/layouts/application.html.erb`, `app/views/briefings/show.html.erb`, `_section.html.erb`, `_story.html.erb`; Create `app/assets/tailwind/application.css` (theme tokens), `app/helpers/briefings_helper.rb`; Gemfile (`tailwindcss-rails`).

**Interfaces:**
- Consumes: `docs/design/briefing-v3.html`.
- Produces: greeting block ("Good morning." + date), chips row (static in M1), progress bar placeholder, dark theme from the mockup.

- [ ] Step 1: No new test — T4's system test still passes after the port.
- [ ] Step 2: Port layout from the mockup into ERB with Tailwind utilities; palette (gruvbox-dark, mockup's role colors) as `@theme` tokens in `app/assets/tailwind/application.css`; build with `bin/rails tailwindcss:build`.
- [ ] Step 3: Run full system tests → PASS.
- [ ] Step 4: Human check — `bin/dev`, open `http://localhost:3000`, compare against the mockup.
- [ ] Step 5: Commit `feat: port v3 design to briefing page`.

### Task 6: Mark-read + progress bar

**Files:** Create `app/controllers/stories_controller.rb`; Modify `_story.html.erb`, `_section.html.erb` or `show.html.erb`, routes; Test `test/system/progress_test.rb` + `test/models/briefing_test.rb` (added cases).

**Interfaces:**
- Consumes: `Story#mark_read!` (T2).
- Produces: `PATCH "stories/:id/mark_read" => "stories#mark_read"`, as `mark_read_story`. `Briefing#read_fraction` → Rational of read stories. Progress copy: "{read} of {total} read".

- [ ] Step 1: Failing tests — model: `test_read_fraction`; system: `test_marking_read_updates_progress_and_persists` (click "Mark read", bar/text updates, `visit current_path` → still read).
- [ ] Step 2: Run → FAIL.
- [ ] Step 3: Route + controller action (`head :no_content` after `mark_read!`), Turbo-powered button, bar width + count bound to `read_fraction`.
- [ ] Step 4: Run → PASS.
- [ ] Step 5: Commit `feat: mark stories read with live progress bar`.

### Task 7: Quiz flow

**Files:** Create `app/models/quiz_question.rb` + migration, `app/controllers/quiz_questions_controller.rb`, views `app/views/quiz_questions/` (answer partial); Modify routes, briefing show; Test `test/models/quiz_question_test.rb`, `test/system/quiz_test.rb`.

**Interfaces:**
- Consumes: `Briefing` (T1).
- Produces: `QuizQuestion(briefing:references, question:text, options:jsonb, answer_index:integer, explanation:text)`; validation `options` length 2–4 and `answer_index` within range. `POST "quiz_questions/:id/answer" => "quiz_questions#answer"` with `params[:choice]`. Answer partial shows: correct pick → "Right." + explanation; wrong pick → "Not quite — {explanation}" (no "fail"/"score"/"wrong answer" strings anywhere).

- [ ] Step 1: Failing tests — model: `test_options_size_validation`, `test_answer_index_in_range`; system: `test_correct_answer_shows_explanation`, `test_wrong_answer_is_gentle` (asserts "Not quite" copy and absence of banned words).
- [ ] Step 2: Run → FAIL.
- [ ] Step 3: Model + migration, controller action rendering answer partial in a Turbo frame, quiz form on the briefing page.
- [ ] Step 4: Run → PASS.
- [ ] Step 5: Commit `feat: quiz with gentle answer flow`.

### Task 8: Concept cards

**Files:** Create `app/models/concept_card.rb` + migration, `app/controllers/concept_cards_controller.rb`, `app/views/concept_cards/show.html.erb`, `app/views/briefings/_concept_card.html.erb`; Modify routes, briefing show; Test `test/models/concept_card_test.rb`, `test/system/concept_card_test.rb`.

**Interfaces:**
- Consumes: `Briefing` (T1).
- Produces: `ConceptCard(briefing:references, title:string, domain:string, what_it_is:text, how_it_works:text, why_you_care:text, deeper_link:string, series_name:string, series_position:integer)`. `resources :concept_cards, only: :show`. Briefing strip shows today's card title + domain; show page shows the four blocks in order + external deeper link.

- [ ] Step 1: Failing tests — model: `test_invalid_without_title_and_what_it_is`; system: `test_card_strip_links_to_card_page` (click title → page shows what/how/why blocks and deeper link).
- [ ] Step 2: Run → FAIL.
- [ ] Step 3: Model + migration, strip partial, show page.
- [ ] Step 4: Run → PASS.
- [ ] Step 5: Commit `feat: concept cards with full page`.

### Task 9: Missed-day band

**Files:** Create `app/views/briefings/_missed_day.html.erb`, helper method; Modify `show.html.erb`; Test `test/system/missed_day_test.rb`.

**Interfaces:**
- Consumes: `Briefing.for_date` (T1), `Story#read?` (T2).
- Produces: `BriefingsHelper#missed_day_briefing` → yesterday's briefing if it exists and has unread stories, else nil. Band copy: "You skipped {weekday}. Nothing stacked — one thing mattered: {first unread story title}" + link to `briefing_path(Date.yesterday)`.

- [ ] Step 1: Failing system tests — `test_band_shown_when_yesterday_unread`, `test_band_hidden_when_yesterday_read_or_missing`.
- [ ] Step 2: Run → FAIL.
- [ ] Step 3: Helper + band partial at top of `show.html.erb`.
- [ ] Step 4: Run → PASS.
- [ ] Step 5: Commit `feat: missed-day band`.

### Task 10: Seeds + quickstart

**Files:** Rewrite `db/seeds.rb`; Modify `README.md`.

**Interfaces:**
- Produces: today's briefing (3 must_know, 3 for_you with one stretch, 1 one_new_thing, 1 quiz question, 1 concept card) mirroring the v3 mockup content, copy polished per `docs/writing-style.md`; yesterday's briefing with one unread story; one 4-card series ("How LLMs work" → RAG → vector databases → tool use) on four consecutive briefings. README: setup + `bin/dev` steps.

- [ ] Step 1: Write seeds (idempotent: skip if `Briefing.for_date(Date.current)` exists).
- [ ] Step 2: `bin/rails db:seed` twice → second run is a no-op.
- [ ] Step 3: Full suite `bin/rails test test:system` → PASS.
- [ ] Step 4: Human check with `bin/dev`: all sections, quiz, band, progress.
- [ ] Step 5: Commit `feat: seed content and quickstart`.

---

## Environment notes

Ruby: mise-managed 3.4.12 (`mise.toml` committed). Gems install to user space — never inside the repo.
PostgreSQL: native package, `postgresql.service` enabled, role `natalia` (superuser), trust auth on local socket.

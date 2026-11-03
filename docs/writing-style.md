# Writing Style Spec

How the app writes: every summary, concept card, and quiz question.

**One line:** ASD-STE100 clarity rules as the foundation, a slightly conversational voice on top. Never robotic, never a textbook.

## Foundation — hard rules for all content

Constraints, not suggestions. Borrowed from ASD-STE100, adapted for tech.

1. **One word, one meaning.** Each concept has one name, used everywhere. If today's card says "request", tomorrow's summary cannot say "call" for the same thing.
2. **Simple tenses, active voice.** Name the actor. "AWS announces", "the migration locks the table". Not "the table was being locked".
3. **Short sentences.** ~20 words for summaries, ~25 for explanations. One idea per sentence.
4. **One instruction per sentence.** Quiz questions and card steps.
5. **Define once.** Expand the acronym on first mention, use the short form after.
6. **No noun clusters over three words.** "The handler that sets task-queue priority", not "the task queue priority handler".
7. **No hedging.** "Perhaps", "arguably", "somewhat" carry no information. Delete them. State uncertainty in plain words: "the cause is not confirmed".
8. **Keep technical terms.** Jargon is precision, not the enemy. Use it, define it once.
9. **Separate fact from speculation.** State what is known. Mark rumor as rumor. Trust is the product.

## What we drop from STE

- **The approved-word dictionary.** Built for aircraft maintenance manuals. We need Postgres, mutex, idempotent.
- **Absolute verb bans.** Judgment over letter. An occasional "-ing" form is fine if it reads well.

## Voice — a dial, not a switch

Mostly neutral, slightly conversational. Enjoyable every morning, still clear and trustworthy.

Personality comes from **word choice and rhythm**: plain verbs, short sentences, a light touch of "you". Never from hedging, jokes, slang, or broken clarity rules.

## By content type

### Must Know — neutral, factual, direct
- ~40 words, present tense, no editorializing, no alarm.
- The voice of a colleague who knows the facts.

### For You — a notch warmer
- Same rules, slightly more personal.
- The "Why this matters for you" line is explicitly personal: one sentence that connects the story to the reader's world.
- Example: "A stretch pick: container queries change how components size themselves in CSS. You don't write frontend — but this pattern shows up in component design everywhere."

### Concept cards — friendly, patient teacher
- Numbered steps, one concept per sentence, a 3-minute read.
- Complex without condescension. Never "simply", never "obviously".
- Structure: what it is → how it works → why you care → one go-deeper link.

### Quiz — light, no pressure
- One instruction per sentence.
- No school language: no "fail", no "score", no "wrong answer".
- A miss teaches. Wrong answers explain themselves; they never scold.

## Do / don't

**Don't** (robotic): "The utilization of connection pooling facilitates the mitigation of database latency."

**Do** (right): "Connection pooling cuts database latency. The pool keeps connections open, so requests skip the handshake."

## How adherence is checked

Mechanically checkable: sentence length, passive constructions, term consistency, hedging adverbs, acronym expansion. A content linter runs on every generated piece before it ships — and doubles as an early learning-project PR.

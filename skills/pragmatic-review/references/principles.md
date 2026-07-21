# Review checklist: DRY, YAGNI, SOLID, Pragmatic Programmer

How to spot violations of each principle during review. Each entry lists what to
look for, the red flags, and the question a senior engineer asks. Cite the
specific principle in every finding.

## Contents

- DRY
- YAGNI
- SOLID — SRP
- SOLID — OCP
- SOLID — LSP
- SOLID — ISP
- SOLID — DIP
- Pragmatic Programmer

## DRY (Don't Repeat Yourself)

Every piece of knowledge has one authoritative representation.

- **Red flags:** copy-pasted blocks; the same constant/string/regex in several
  places; parallel `switch`/`if` ladders that must change together; logic
  duplicated between client and server; the same validation re-implemented.
- **Not DRY-worthy:** two snippets that look alike but change for different
  reasons — forcing them together is a false abstraction (see YAGNI/OCP).
- **Ask:** "If this rule changed, how many places would I have to edit?"

## YAGNI (You Aren't Gonna Need It)

Build for today's requirements, not imagined ones.

- **Red flags:** unused parameters, config flags, or `options` objects; abstract
  base classes / interfaces with one implementation; generic "manager"/"helper"
  layers with no second caller; commented-out or dead code; premature caching or
  optimization without evidence.
- **Ask:** "Is anything in this change here only because it *might* be needed
  later?" If yes, cut it.

## SOLID — Single Responsibility (SRP)

A module has one reason to change.

- **Red flags:** a function/component that fetches, transforms, *and* renders; a
  file mixing unrelated concerns; a class that grows a new method every feature;
  a React component holding business logic, data fetching, and presentation.
- **Ask:** "Who would request a change to this, and would two different roles
  ever request changes to the *same* unit?"

## SOLID — Open/Closed (OCP)

Open for extension, closed for modification.

- **Red flags:** a growing `switch`/`if-else` on a type/enum that must be edited
  for every new case; adding a feature forces edits scattered across the module.
- **Ask:** "To add the next variant, do I extend or do I reopen and edit
  existing, tested code?"

## SOLID — Liskov Substitution (LSP)

Subtypes must be usable wherever the base type is.

- **Red flags:** an override that throws "not supported"; a subclass that
  narrows accepted inputs or weakens guarantees; `instanceof` checks to special-
  case a subtype; a hook/implementation that violates the contract callers rely
  on.
- **Ask:** "Can any implementation stand in for the interface without callers
  knowing which one they got?"

## SOLID — Interface Segregation (ISP)

Don't force clients to depend on methods they don't use.

- **Red flags:** fat interfaces / prop bags where callers use a fraction; a
  component taking 15 props because it does five jobs; a dependency requiring a
  huge object when it needs one field.
- **Ask:** "Does every consumer need every part of this interface?"

## SOLID — Dependency Inversion (DIP)

Depend on abstractions, not concretions.

- **Red flags:** high-level logic importing a concrete client (SDK, `fetch`, DB
  driver) directly; hard-to-test units because a dependency can't be swapped;
  business rules reaching into framework details.
- **Ask:** "Can I test this without the real network/DB/clock? If not, what
  concrete dependency is baked in?"

## Pragmatic Programmer

Cross-cutting habits of durable code.

- **Orthogonality / decoupling** — unrelated things stay independent. Red flag:
  a change here forces an unexpected change there; shotgun surgery.
- **ETC ("Easier To Change")** — the tie-breaker for design choices. Ask: "Does
  this make the code easier or harder to change next month?"
- **No broken windows** — don't let small rot land. Flag introduced-but-ignored
  TODOs, disabled tests, swallowed errors, `any` escapes.
- **DRY of knowledge** — not just code: duplicated docs, schemas, or magic
  numbers that must stay in sync.
- **Design by contract** — clear pre/postconditions. Flag missing input
  validation at boundaries and unchecked assumptions.
- **Crash early / fail fast** — surface errors at the source, don't limp on with
  bad state. Flag empty `catch` blocks and silent fallbacks that hide bugs.
- **Avoid global mutable state** — flag new singletons/module-level mutables that
  create hidden coupling and test flakiness.
- **Tracer bullets over gold-plating** — flag elaborate abstractions built ahead
  of a proven need (ties back to YAGNI).

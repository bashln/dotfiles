# Write Simple Software

Use this lens when a change feels over-designed, when the repository has too many abstractions, or when choosing between a direct solution and a framework-heavy one.

The goal is not the fewest lines. The goal is the smallest understandable system that satisfies the real requirement and remains easy to change.

## Operating principles

- **Start with the real behavior.** Name the user-visible result before choosing modules, patterns, or dependencies.
- **Prefer the direct path.** Keep control flow, data flow, and ownership visible. Add indirection only when it removes more complexity than it introduces.
- **Make one thing responsible.** A module should own one coherent decision and hide the details behind a small interface.
- **Delay abstraction.** Do not generalize a single use case. Wait for a second real variation, then abstract the repeated decision—not merely the repeated syntax.
- **Delete before adding.** Remove dead code, wrappers, flags, configuration, and concepts before introducing another layer.
- **Keep state local.** Prefer local data and explicit transitions over shared mutable state, implicit lifecycle rules, and global coordination.
- **Make invalid states hard to represent.** Validate at boundaries and use types or constructors that encode meaningful invariants.
- **Choose boring dependencies.** A dependency must earn its cost in installation, configuration, upgrade surface, and cognitive load.
- **Test the behavior seam.** A small, stable test at the highest useful interface is better than many tests coupled to implementation details.
- **Stop when the requirement is met.** Do not add speculative flexibility, polish, or architecture without a concrete current need.

## Decision loop

1. State the smallest behavior that must change.
2. Identify the simplest existing seam that can own it.
3. List the new concepts, files, dependencies, and branches the change would add.
4. Remove anything not required by the behavior or its safety properties.
5. Implement the direct version first.
6. Validate the behavior, then check whether duplication or coupling is actually painful.
7. Abstract only the pressure that remains.

## Review questions

- Can a new maintainer explain the path from input to outcome without opening many files?
- Does each new abstraction hide a real decision, or only rename plumbing?
- What can be deleted while preserving the requirement?
- Is the proposed flexibility needed now, or merely imaginable?
- Does the test prove behavior through the same seam callers use?

## Guardrails

Simple does not mean careless: preserve security, correctness, observability, accessibility, and required compatibility. Reject simplicity that merely moves complexity into callers, users, operations, or future migrations.

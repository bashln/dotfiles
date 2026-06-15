---
name: test-suite
description: Suite de testes (Unitário, Integração, Componente e E2E).
---

## Unit Tests (Jest)


## Objective

Create and run unit tests for isolated functions and rules.

## When to use

- Pure helpers or utilities need coverage
- Business rules are isolated from IO

## Scope

Does:

- Test pure behavior
- Cover happy path, edge cases, and failures

Does not:

- Cover cross-layer behavior
- Replace integration or E2E tests

## Workflow

1. Identify the unit and its behavior
2. Add focused cases
3. Run the targeted test command
4. Report results and gaps


## Integration Tests (Jest)


## Objective

Create and run integration tests for flows that cross module or layer boundaries.

## When to use

- Behavior depends on more than one unit
- A service boundary or module interaction changed

## Scope

Does:

- Cover module interactions
- Validate integration boundaries

Does not:

- Replace unit tests for pure logic
- Replace E2E UI coverage

## Workflow

1. Identify the interaction boundary
2. Add the smallest valuable integration cases
3. Run the relevant Jest command
4. Report results and coverage gaps


## Component Tests


## Objective

Create or update component tests for UI behavior that can be verified in isolation.

## When to use

- React or React Native component behavior needs coverage
- A UI interaction changed and should be protected with tests

## Scope

Does:

- Test component behavior
- Cover happy path, edge cases, and error states

Does not:

- Cover cross-layer integration
- Replace end-to-end tests

## Workflow

1. Identify the component and behavior
2. Add the smallest credible test cases
3. Run the focused test command
4. Report results and remaining gaps


## E2E Tests (Maestro)


## Objective

Create and run end-to-end tests for mobile or app flows that require Maestro.

## When to use

- A user flow spans multiple screens or services
- Real device or app-level behavior needs coverage

## Scope

Does:

- Create or update Maestro flows
- Run the relevant E2E checks

Does not:

- Replace unit or integration tests
- Refactor application logic broadly

## Workflow

1. Identify the user flow
2. Write the smallest useful scenario
3. Run the E2E command
4. Report results and gaps

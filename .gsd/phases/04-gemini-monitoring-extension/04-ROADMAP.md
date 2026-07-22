# M004: Gemini monitoring extension

**Vision:** Add Gemini usage monitoring as a first-class provider in the same product family as Claude and ChatGPT, preserving secure credential boundaries, provider-aware UI patterns, and testable multi-provider behavior.

## Success Criteria

- Gemini has an explicit provider identity, credential state, storage boundary, and settings/setup presentation consistent with existing providers.
- Gemini usage acquisition is implemented through actor service and repository seams with sanitized diagnostics and no secret persistence outside the credential boundary.
- Menu bar and settings surfaces represent Gemini alongside Claude and ChatGPT, including partial configuration, loading, errors, and refresh behavior.
- Automated tests and UAT evidence cover Gemini setup, refresh, error, clear/reconnect, and coexistence with other providers.

## Slices

- [x] **S01: Gemini provider contract** `risk:high` `depends:[]`
  > After this: The app has a Gemini provider identity, model contract, and failing tests that define credential and usage states.

- [x] **S02: Gemini credential and usage service** `risk:high` `depends:[S01]`
  > After this: A Gemini service can acquire or consume credential material through a secure boundary and return normalized usage or sanitized errors under tests.

- [x] **S03: Gemini setup and settings UI** `risk:medium` `depends:[S02]`
  > After this: Settings and setup display Gemini status and actions beside Claude and ChatGPT.

- [x] **S04: Gemini menu usage integration** `risk:medium` `depends:[S02,S03]`
  > After this: The menu bar popover refreshes and displays Gemini usage alongside other configured providers.

- [x] **S05: Gemini workflow UAT** `risk:medium` `depends:[S04]`
  > After this: A repeatable UAT proves Gemini setup, refresh, recovery, and coexistence with Claude and ChatGPT.

## Boundary Map

Not provided.

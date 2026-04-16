# Chat Notes: Feature Intake

## Current Implementation Summary

- **World state model:** dynamic predicates (`i_am_at/1`, `at/2`, `holding/1`) hold player location, room items, and inventory.
- **Movement flow:** `go(Direction)` checks `path/3`, updates `i_am_at/1`, then calls `look/0`.
- **Look flow:** `look/0` calls `describe(Room)` and then `notice_objects_at(Room)` to list visible objects.
- **Inventory model:** currently represented by `holding/1`; `take/1` and `drop/1` mutate it via `retract/1` + `assert/1`.

## Feature Request

### Describe the feature you want in plain language:

Lets implemet the apple juice system.

- Player-visible behavior:

The player should at all times be able to check his apple juice level which can be at 100, 75, 60, 40, 25, 0. When the level is at zero the player gets 2 moves to refill his meter or else he dies the apple-death.
The Player should be warned when the mether tips below 60.

## Clarifications (please answer below each question)

1. **Decrease rule:** What exactly lowers apple juice?

Apple Juice decreases at every movement or after a fight.

2. **Decrease steps:** Your allowed levels are `100, 75, 60, 40, 25, 0`.

The meter has to move through these steps, it is possible to move up and down.

3. **Refill behavior at 0:** How can the player refill when meter is 0?

By using the drink/0 command, if the player has apple juice in his inventory, he can drink and each individal apple juice item increases the apple juice meter by one step.

if he has no apple juice item, there should be an angry remark by the major mountaineer.

4. **Refill amount:** When refilling, should apple juice go to:
   - Option A: always back to `100`
   - Option B: increase one step
   - Option C: custom amount/rule
   - **Your answer:**

   Option B

5. **Two-move death window:** At 0, player gets 2 moves before death.

Any command counts as a move.

6. **Warning rule below 60:** You said warn when meter tips below 60.

There should always be a little update text below every system prompt updating the player when the meter is below or exactly 60.

7. **Meter visibility command:** What command should show current juice level?

juicy()

8. **Initial state:** Should a new game always start at `apple_juice = 100`?

Yes.

9. **Death behavior:** On apple-death, should we reuse existing `die/0 -> finish/0`, or show custom death text before finishing?

Show a custom message.

10. **Persistence on start/reset:** If `start.` is run again in the same Prolog session, should apple juice/death countdown fully reset?

The current level will be saved and persisted.

## Follow-up Clarifications Needed

1. **Command name syntax:** You wrote `juicy()`. Should the playable command be exactly `juicy.` (standard Prolog style) or do you explicitly want `juicy().`?

prolog style - juicy.

2. **Low-meter status message scope:** You asked for a status line when meter is `<= 60`.
   - Should this line print after **every command** (including invalid commands), or only after successful game actions?

after succesful game actions that influence the meter.

3. **0-meter countdown order:** At meter `0`, there are 2 commands before death.
   - On the second command, should death check happen **after** command effects (so `drink` can still save you) or **before** command effects?

After, you should still be able to safe ypurself.

4. **Drinking at full meter:** If meter is already `100` and player runs `drink`, should:
   - item still be consumed, or
   - command fail with message and keep the item?

item should be consumed.

5. **Apple juice item identity:** What atom name should represent an inventory juice item for `take/drop/drink`?
   - Example options: `apple_juice`, `juice_box`, `applejuice_item`

apple_juice

6. **Fight hook behavior:** You said meter drops after fights too, but fight mechanics are not yet in this file.
   - Do you want me to add a reusable predicate (e.g., `apple_juice_after_fight/0`) now so future fight code can call it?

make it as easy as possible for future development.

## Honor System: Clarifications Needed

1. **Honor scale:** Should honor use the same discrete steps as apple juice (`100, 75, 60, 40, 25, 0`)?

Yes, we will define "high honor" as 100 everything below is "low honor" 

2. **Initial honor value:** What should honor start at on a fresh run?

honor starts at 25

3. **Honor command:** What command should show honor meter?
   - Suggested default: `honor.`

Honor is a hidden stat, the player does not see his honbor stat

4. **What changes honor up/down right now?**
   - Since no quest/fight system is implemented yet, should I add reusable hooks (e.g., `honor_up/0`, `honor_down/0`) and not auto-trigger them yet?

Yes, make thos 2 functions.

5. **Threshold behavior:** Do you want warnings like apple juice?
   - If yes: at which threshold(s), and should it print once on crossing or after each relevant action?

No warnings.

6. **Failure consequence:** Should honor reaching `0` kill the player, lock commands, or only affect narrative text?

no, we will check the honor level to determen dialog options when we add that

7. **Persistence behavior:** Should honor persist across repeated `start.` calls in the same session (same as apple juice)?
yes.

8. **Interaction with apple juice:** Any combined rules (example: low honor increases juice drain, or vice versa)?

no, we will decrease/increase honor depending on choices the player makes though out the game.
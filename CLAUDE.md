# ALU Bug Bounty - Flutter Project

## Architecture
- **State management:** Riverpod (prefer `ref.watch` over `ref.read` in build methods)
- **Navigation:** GoRouter with typed routes
- **Platform priority:** iOS first — test on iOS simulator before Android

## UI / Design System
- **Icons:** HugeIcons (`hugeicons` package) — never use Material Icons or Cupertino Icons
- **Colors & Typography:** Use `Theme.of(context)` and the app's `AppColors` / `AppTextStyles` constants — never inline `Color(0x...)` or `TextStyle(...)` literals
- **Animations:** Smooth, custom animations — prefer `AnimatedContainer`, `Hero`, implicit animations, and `flutter_animate` where appropriate. No janky default transitions
- **Widgets:** Build reusable widgets in `lib/widgets/` before writing screen-specific code. Check existing widgets first — duplicate widgets are bugs
- **Spacing & Layout:** Use the app's spacing constants (`AppSpacing`) — no magic numbers for padding/margin

## File Structure
```
lib/
  core/           # theme, constants, utils, extensions
  models/         # data models
  providers/      # Riverpod providers
  services/       # API, storage, auth services
  widgets/        # reusable widgets (buttons, cards, inputs, etc.)
  features/       # feature screens organized by feature name
    home/
    report/
    profile/
```

## Code Rules
- Reusable widget first, screen second — always check `lib/widgets/` before creating inline widgets
- All colors from `AppColors`, all text styles from `AppTextStyles`, all spacing from `AppSpacing`
- No `any` casts, no `dynamic` without validation at boundaries
- Validate all external data (API responses, user input) at the boundary
- Prefer `const` constructors wherever possible
- Use `part` files sparingly — prefer separate files

## Commits
- **Commit after every working feature or fix** — don't batch unrelated changes
- Conventional Commits: `feat(scope): subject`, `fix(scope): subject`
- No AI co-author lines

## Testing
- Test on iOS simulator before reporting a feature as done
- Verify animations are smooth (no frame drops)

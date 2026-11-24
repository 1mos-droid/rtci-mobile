# RTCI Connect design

RTCI Connect should feel like a welcoming church community: warm, calm and easy to read. The visual system uses warm ivory, burgundy, muted brass and charcoal. Color emphasizes actions and hierarchy; the content carries the personality.

## Shared rules

- Bundle Inter with its OFL license. All screens use the same family in debug and release, including offline startup.
- Use the theme's semantic foreground/background pairs. A selected control uses `onPrimary` on `primary`, including dark mode.
- Use 4/8px spacing increments; default page gutters are 24px. Account flows cap at 520px, giving at 640px, Explore at 760px, and the dashboard at 1060px.
- Keep surfaces solid and borders quiet. Avoid nested glass, animated backgrounds, decorative glow and multiple competing accent colors.
- Use native buttons, form controls and navigation for focus, keyboard, screen readers, disabled states and touch feedback. Existing `GradientButton` callers use the same native button system.
- Let labels wrap and controls grow with text. Keep tap targets at least 48px. Metadata should not depend on tiny uppercase type.
- The seal loader communicates waiting with one orbit; respect reduced motion. Skeletons stop when motion is disabled or the containing tab is inactive.
- Show a useful empty state separately from a failed fetch. Offer a recovery action where the operation can be retried. Never substitute invented church content for real data.
- Church announcements use the Firestore broadcast provider, reports copy actual loaded records as CSV, and event responses save to `events/{eventId}/rsvps/{uid}` with an idempotent member document ID. No simulated deliveries or export-success screens remain.
- Keep pending checkout distinct from confirmed giving. Returning from the payment page is not proof of payment.

## Library assessment

Research checked against upstream sites during this redesign. These libraries have not been installed unless stated below.

| Tool | Assessment | Decision |
| --- | --- | --- |
| [TUIOS](https://tuios.dev/docs) | Terminal window manager, not a Flutter UI library | No runtime dependency; unrelated to the member experience |
| [Sileo](https://sileo.aaryan.design/) | React toast system | Inspiration for concise feedback; retain native accessible SnackBars |
| [Sileo Flutter port](https://pub.dev/packages/sileo_toast) | Flutter implementation of Sileo-style physics toasts | Candidate only; no need to add gooey notification motion to every action |
| [Rare UI](https://www.rareui.com/) | Animated React components; a second project also uses [RareUI](https://rareui.in/) | Inspiration only; do not introduce a second UI runtime |
| [SmoothUI](https://smoothui.dev/) | React/Motion/Tailwind components | Borrow restraint and reduced-motion principles; implement natively |
| [Watermelon UI](https://ui.watermelon.sh/) | React component and layout collection | Reference for hierarchy and grouping, not direct Flutter installation |
| [Kokonut UI](https://kokonutui.com/) | React/Tailwind/Motion component registry | Reference for cards, inputs and feedback; no source copied |
| oooh | Could not identify an authoritative matching UI product | Await exact link before evaluating or installing |
| Open Motion | Name matches several video/motion editors, including [OpenMotion](https://openmotion.design/) and [Open Motion](https://github.com/Hada45/Open-Motion) | Await exact link; no verified Flutter UI dependency |
| [Flutter Material 3](https://api.flutter.dev/flutter/material/) | Native UI toolkit already in this project | Use its focus, semantics, forms, navigation, chips and surfaces |
| [Flutter animation primitives](https://api.flutter.dev/flutter/animation/) | Native controllers, curves and transitions | Use for the seal loader and quiet placeholder pulse |
| [Inter](https://github.com/google/fonts/tree/main/ofl/inter) | Open font with variable weight support | Bundled in `assets/fonts`, license included |

## Verification and review artifacts

Run `flutter analyze` and `flutter test`. Responsive tests cover narrow phone and wide layouts, light/dark themes, enlarged text, account validation, keyboard activation and reduced motion.

For review PNGs using the bundled font and Material icons:

```sh
flutter test --dart-define=CAPTURE_UI=true test/design_system_test.dart
```

Captures are written to `/tmp/rtci-design`, outside the repository. Routine test runs do not render screenshots. These are deterministic widget captures using test fixtures, not evidence of a real Firebase account or payment succeeding.

# Decision Log: Basic Color Lamp Feature

**Date:** 2026-02-02  
**Status:** Implemented  
**Participants:** AI Agent, Development Team

---

## What

A Flutter mobile application that transforms the phone screen into a customizable lamp/light. The app provides a full-screen color display that mimics a bedside lamp or ambient lighting device.

### User Stories

1. **As a user**, I want to see a full-screen color that can serve as a bedside lamp
2. **As a user**, I want to swipe left/right to navigate through predefined colors smoothly
3. **As a user**, I want to tap color chips to jump directly to a specific color
4. **As a user**, I want smooth animated transitions between color changes

### Core Features

- **12 Predefined Colors**: Red, Purple, Teal, Green, Blue, Orange, Amber, Yellow, White, Grey, Indigo, Black
- **Swipe Navigation**: Horizontal swipe (left/right) cycles through colors
- **Tap Selection**: Color chips at bottom allow direct selection
- **Smooth Animations**: 300ms animated transition when changing colors
- **Visual Feedback**: Current color chip shows a white border indicator

### Supported Platforms

- **Android** (SDK 21+)
- **iOS** (iOS 11+)

---

## Why

- **Use Case**: Bedside lamp replacement — reduces blue light strain, customizable colors
- **Simplicity**: Single-feature MVP allows rapid iteration and testing
- **Platform Support**: Works across Android, iOS, Linux, macOS, Windows, and Web
- **Accessibility**: Large touch targets and clear visual feedback

---

## How

### User Interactions

1. **Swipe Left**: Move to previous color (wraps around from first to last)
2. **Swipe Right**: Move to next color (wraps around from last to first)
3. **Tap Color Chip**: Immediately jump to that color
4. **Visual Feedback**: Current color chip displays white border; smooth color transition via AnimatedContainer

### Color Palette

```dart
[
  Colors.red,      // 0
  Colors.purple,   // 1
  Colors.teal,     // 2
  Colors.green,    // 3
  Colors.blue,     // 4
  Colors.orange,   // 5
  Colors.amber,    // 6
  Colors.yellow,   // 7
  Colors.white,    // 8
  Colors.grey,     // 9
  Colors.indigo,   // 10
  Colors.black,    // 11
]
```

### Layout

- **Main Area**: Full-screen AnimatedContainer with current color
- **Bottom Bar**: Black container (height 60) with color chips (60x60 each, circular)
- **Color Chips**: Horizontal ListView with all 12 colors, white border on selected
- **Helper Text**: "Swipe left or right" at bottom center

### Technical Approach

- **State Management**: Riverpod (StateNotifier for color index)
- **Architecture**: Feature-based structure with separated concerns (models, view models, widgets)
- **Animation**: AnimatedContainer with 300ms duration for smooth transitions
- **UI**: Material 3 design system with centralized theming
- **Code Organization**: Business logic in ViewModels, UI components in widgets

---

## Implementation Timeline

1. ✅ Created decision log
2. ✅ Add Riverpod dependency
3. ✅ Create centralized theme structure
4. ✅ Organize into feature-based structure
5. ✅ Create Riverpod providers and ViewModels
6. ✅ Refactor UI to use ConsumerWidget
7. ✅ Extract sub-widgets for maintainability
8. ⏳ Add unit & widget tests

---

## Notes

- The color palette was chosen for variety and visual distinctness
- 300ms animation duration provides smooth feedback without feeling slow
- Wrapping navigation (circular list) is intuitive for cycling through colors
- Bottom bar design allows quick access to any color without scrolling

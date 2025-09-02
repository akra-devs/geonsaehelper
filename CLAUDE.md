# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is "geonsaehelper" (전세자금대출 도우미) - a Flutter application that helps users determine their eligibility for HUG (Korea Housing & Urban Guarantee Corporation) rental deposit loans through an interactive questionnaire and AI-powered Q&A system.
 
## Common Development Commands

### Dependencies and Setup
```bash
flutter pub get                                    # Install dependencies
dart run build_runner build --delete-conflicting-outputs  # Generate Freezed/JSON code
```

### Development
```bash
flutter run                                        # Run on connected device
flutter run -d chrome                             # Run in Chrome (web)
flutter analyze                                   # Static analysis
dart format .                                     # Format code
flutter test                                      # Run tests
```

### Code Generation
The project uses Freezed for immutable models and JSON serialization. After modifying any `@freezed` classes or adding `@JsonSerializable` annotations, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Architecture Overview

### Directory Structure
```
lib/
  main.dart                    # App entry point, theme setup
  ui/
    theme/app_theme.dart       # Material 3 theme with custom extensions
    components/                # Reusable UI components
      intake_question.dart
      result_card.dart
      chat_bubble.dart
    demo/demo_gallery.dart     # Component showcase
```

### Planned Architecture (per docs/ARCHITECTURE.md)
The project is designed to scale with a feature-based structure:
```
lib/features/
  <feature>/
    ui/     # Screens and widgets
    bloc/   # BLoC state management
    data/   # Repository, models, mappers
```

### Key Technical Decisions
- **State Management**: flutter_bloc with BLoC pattern
- **Models**: Freezed for immutable models with JSON serialization
- **Theme**: Material 3 with custom ThemeExtensions (Spacing, Corners)
- **Architecture**: Repository pattern with separation of UI → BLoC → Service/Repository → Data
- **Data Flow**: Unidirectional dependency (UI depends on BLoC, BLoC depends on Repository, etc.)

### Theme System
The app uses a custom theme system with:
- Material 3 ColorScheme from seed color `#3B6EF5`
- Custom Spacing extension (x1=4, x2=8, x3=12, x4=16, x6=24)
- Custom Corners extension (sm=8, md=12)
- Access via `context.spacing.x4` and `context.corners.md`

## Key Features (from PRD)
1. **Eligibility Assessment**: 10-12 question interactive flow to determine HUG rental deposit loan eligibility
2. **Instant Results**: Immediate qualification determination with detailed reasoning
3. **AI Q&A**: Follow-up questions answered using internal documentation
4. **Local Storage**: Temporary storage of assessment results and user responses

## Dependencies
Core libraries in use:
- `flutter_bloc`: State management
- `freezed`: Immutable models and unions
- `json_annotation`/`json_serializable`: JSON serialization
- `build_runner`: Code generation
- `flutter_lints`: Linting rules
- `cupertino_icons`: iOS-style icons

## Development Guidelines
- Use Freezed for all data models with JSON serialization
- Follow BLoC pattern for state management
- Maintain unidirectional data flow
- Use the custom theme extensions for consistent spacing and styling
- Generate code after model changes with build_runner
- Follow Korean localization needs (app title: "전세자금대출 도우미")

## Project Context
This is currently a new/empty Flutter project with extensive planning documentation in `docs/docs/`. The project aims to help Korean users navigate HUG rental deposit loan eligibility through a user-friendly mobile interface.
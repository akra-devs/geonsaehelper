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

## Planning Documentation
The `docs/docs/` directory contains comprehensive planning materials:

### Product Requirements & Strategy
- **PRD_v1.md**: Core product requirements with eligibility assessment flow (10-12 questions), instant results, and AI Q&A system
- **PRODUCT_BRIEF.md**: Executive summary covering JTBD, target users (20-40s preparing for 전세), MVP scope, and success metrics
- **INTAKE_FLOW.md**: Detailed conversational questionnaire design with 14 questions covering applicant info (A1-A7), property details (P1-P7), and special eligibility (S1)

### Business Rules & Logic
- **RULES_HUG_v1.md**: HUG qualification rules engine with three categories:
  - C1: Instant disqualifiers (무주택 requirement, credit issues, property limits)  
  - C2: Required confirmations (income, employment, property details)
  - C3: Conditional warnings (pre-contract status, encumbrances)
- **RULES_HUG_mapping.yaml**: Internal document mapping for rule thresholds and values

### Design & User Experience
- **DESIGN_TOKENS.yaml**: Design system tokens including:
  - Colors: Seed #3B6EF5, semantic colors (success/warning/error)
  - Typography: 5-level scale (display/headline/title/body/label)
  - Spacing: [4,8,12,16,24,32], Radius: sm=8, md=12
- **COMPONENT_SPECS.md**: Flutter widget specifications for IntakeQuestion, ResultCard, and ChatBubble components
- **UI_BLUEPRINT.yaml**: Detailed screen layouts and interaction patterns

### Key Business Rules
- **Eligibility Logic**: Any "모름" (don't know) response results in "불가(정보 부족)" status
- **Result Format**: TL;DR summary + detailed reasons (충족/미충족/확인불가) + next steps + last verification date
- **Data Policy**: No external links exposed, internal documentation only, temporary local storage
- **Success Metrics**: ≥70% completion rate, ≤90s average time to result, ≥70% satisfaction

### Additional Documentation
- **ARCHITECTURE.md**: Technical architecture with feature-based structure and BLoC pattern
- **COPY_GUIDE.md**: Korean language copy guidelines and messaging tone
- **QNA_TEMPLATES.md**: AI Q&A response templates for common follow-up questions
- **MEASUREMENT_PLAN.md**: Analytics and KPI tracking specifications
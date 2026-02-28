# 🎨 Fast Truck - shadcn UI Components

The app now uses **shadcn-inspired UI components** with a clean, modern design system.

## Color Scheme

- **Primary**: `#FF6B35` (Vibrant Orange)
- **Background**: `#FAFAFA` (Light Gray) and White
- **Foreground**: Gray shades for text and borders
- **Accent**: Orange for interactive elements

## Components

### Button (`lib/ui/button.dart`)

Flexible button component with multiple variants and sizes:

```dart
Button(
  onPressed: () {},
  child: Text('Click me'),
  variant: ButtonVariant.primary, // primary, secondary, outline, ghost
  size: ButtonSize.md,             // sm, md, lg
  isLoading: false,
)
```

**Variants:**
- `primary` - Orange background, white text
- `secondary` - Gray background, dark text
- `outline` - Transparent with border
- `ghost` - Transparent, no border

**Sizes:**
- `sm` - Small (36px height)
- `md` - Medium (40px height)
- `lg` - Large (48px height)

### Input (`lib/ui/input.dart`)

Clean input fields with labels and validation:

```dart
Input(
  controller: _controller,
  label: 'Email',
  placeholder: 'name@example.com',
  prefixIcon: Icon(Icons.mail_outline),
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
)
```

**Features:**
- Labels and placeholders
- Prefix and suffix icons
- Built-in validation
- Focus states with orange highlight
- Clean borders and rounded corners

### Card (`lib/ui/card.dart`)

Elegant card component with optional header:

```dart
CardWidget(
  child: Column(
    children: [
      CardHeader(
        title: Text('Title'),
        description: Text('Description'),
      ),
      // Content
    ],
  ),
)
```

**Features:**
- Clean white background
- Subtle border
- Optional padding
- Optional onTap handler
- Composable with CardHeader

## Design Principles

Following shadcn/ui philosophy:

1. **Subtle by default** - Clean borders, minimal shadows
2. **Accessible** - Proper contrast, focus states
3. **Composable** - Components work together seamlessly
4. **Consistent** - Unified spacing and styling
5. **Flexible** - Easy to customize and extend

## Screen Examples

### Login Screen
- Card-based layout
- Form with Input components
- Button variants for different actions
- Clean dividers and spacing

### Home Screen  
- Feature list with icons
- Card layout for content
- Consistent spacing and hierarchy

## Migration from Default Flutter

The app uses these custom components instead of:
- `ElevatedButton` → `Button(variant: ButtonVariant.primary)`
- `OutlinedButton` → `Button(variant: ButtonVariant.outline)`
- `TextFormField` → `Input`
- `Card` → `CardWidget`

## Future Enhancements

- Badge component
- Dialog component
- Dropdown/Select component
- Tabs component
- Toast/Snackbar component

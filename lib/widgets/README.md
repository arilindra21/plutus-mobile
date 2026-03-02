# Widget Library

## Overview
This library provides reusable, consistent UI components for the mobile paper application.

## Design Principles
- **Single Responsibility**: Each widget has one clear purpose
- **Consistency**: Follows design tokens and app-wide patterns
- **Reusability**: Generic where possible, configurable for variations
- **Maintainability**: Clear separation of concerns, minimal dependencies

## Component Categories

### 1. Buttons (`lib/widgets/buttons/buttons.dart`)

#### AppButton
Unified button system supporting multiple design systems:
- **Variants**: `ButtonStyle.primary`, `.secondary`, `.danger`, `.ghost`, `.success`
- **Design Systems**: `ButtonVariant.fintech`, `.paper`, `.common`
- **Features**:
  - Loading state support
  - Icon support
  - Full width option
  - Small variant

**Usage**:
```dart
AppButton(
  label: 'Save',
  onPressed: () {},
  style: ButtonStyle.primary,
  variant: ButtonVariant.fintech,
  isLoading: _isSaving,
)

AppButton(
  label: 'Cancel',
  onPressed: () {},
  style: ButtonStyle.ghost,
)
```

#### AppIconButton
Icon-only button for secondary actions:
- Square or circular shape
- Tooltip support
- Disabled state styling

**Usage**:
```dart
AppIconButton(
  icon: CupertinoIcons.delete,
  onPressed: () {},
  iconColor: AppColors.statusRejected,
  backgroundColor: AppColors.surfaceVariant,
)
```

### 2. Status Components (`lib/widgets/status/status_widgets.dart`)

#### StatusBadge
Unified status badge with multiple styles:
- **Styles**: `StatusStyle.pill`, `.badge`, `.tag`, `.dot`
- **8 Status Configurations**: Draft (0), Pending (1), Submitted (2), Pending Approval (3), Approved (4), Completed (5), Rejected (6), Returned (7)

**Usage**:
```dart
StatusBadge(status: 4) // Approved

StatusBadge(
  status: 4,
  customLabel: 'Custom',
  style: StatusStyle.tag,
  isCompact: true,
)
```

### 3. Screen Components (`lib/widgets/screen/screen_widgets.dart`)

#### ScreenHeader
Consistent screen header with gradient:
- Back button support
- Action buttons support
- Customizable gradient background
- Safe area handling

**Usage**:
```dart
ScreenHeader(
  title: 'Expense Details',
  onBackPressed: () => context.pop(),
  actions: [
    AppIconButton(icon: CupertinoIcons.ellipsis),
  ],
)
```

#### AppLoadingIndicator
Loading indicator with 3 types:
- `LoadingType.circular`: Standard circular progress
- `LoadingType.linear`: Horizontal progress bar
- `LoadingType.shimmer`: Animated gradient placeholder

**Usage**:
```dart
AppLoadingIndicator(type: LoadingType.circular)

AppLoadingIndicator(
  type: LoadingType.shimmer,
  message: 'Loading expenses...',
)
```

#### AppEmptyState
Consistent empty state with:
- Icon display
- Title and subtitle
- Optional action button
- Customizable colors

**Usage**:
```dart
AppEmptyState(
  icon: CupertinoIcons.tray,
  title: 'No Expenses Yet',
  subtitle: 'Tap the + button to add your first expense',
  onAction: () => context.navigateTo(AppRoutes.newExpense),
  actionLabel: 'Add Expense',
)
```

#### AppRefreshIndicator
Pull-to-refresh wrapper with consistent styling:
- Custom refresh text
- Custom color
- Standard RefreshIndicator behavior

**Usage**:
```dart
AppRefreshIndicator(
  onRefresh: _refreshData,
  refreshText: 'Pull to refresh',
)
```

### 4. Form Components (`lib/widgets/form/form_widgets.dart`)

#### AppInputField
Standardized input field with:
- Multiple input types (text, number, amount, date, select, search)
- Validation support
- Helper text
- Suffix icons
- Read-only mode

**Usage**:
```dart
AppInputField(
  label: 'Amount',
  controller: _amountController,
  validator: (value) => value?.isEmpty ?? true : null,
  type: InputType.amount,
  required: true,
)

AppInputField(
  label: 'Description',
  maxLines: 3,
  validator: (value) => value?.length ?? 0 > 0 ? null : null,
)
```

#### AppDatePicker
Date picker with Cupertino-style modal:
- Date range support (firstDate, lastDate)
- Custom label
- Required validation
- Consistent styling

**Usage**:
```dart
AppDatePicker(
  label: 'Expense Date',
  value: _selectedDate,
  firstDate: DateTime(2020),
  lastDate: DateTime.now(),
  onChanged: (date) => setState(() => _selectedDate = date),
  required: true,
)
```

#### AppDropdown
Generic dropdown with custom display:
- Generic type support
- Custom display string function
- Empty text support
- Hint text
- Required validation

**Usage**:
```dart
AppDropdown<Category>(
  value: _selectedCategory,
  items: _categories,
  displayString: (cat) => cat.name,
  onChanged: (category) => setState(() => _selectedCategory = category),
  hintText: 'Select category',
)
```

#### AppAmountInput
Formatted amount input with currency:
- Currency prefix display (tap to change)
- Thousands separator formatting
- Decimal support
- Validation support

**Usage**:
```dart
AppAmountInput(
  label: 'Amount',
  currency: 'IDR',
  controller: _amountController,
  validator: (value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    if (double.tryParse(value!) == null || double.parse(value!) <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  },
  onCurrencyTap: _showCurrencyPicker,
)
```

### 5. Navigation (`lib/core/navigation/app_routes.dart`)

#### AppRoutes
Type-safe route constants:
```dart
// Navigation
context.navigateTo(AppRoutes.expenseDetail, arguments: expenseId);

// With replacement
context.navigateReplacement(AppRoutes.login);

// Pop all routes
context.popToRoot();
```

#### NavigationHelper
Helper methods on BuildContext extension:
```dart
// Concise navigation
context.navigateTo(AppRoutes.expenses);

// Get arguments
final expenseId = context.getArgument<String>();
```

### 6. Error Handling (`lib/core/errors/app_error.dart`)

#### AppException
Type-safe exception class:
- 8 error types (network, authentication, validation, notFound, server, unknown, permissionDenied, timeout, parsing)
- User-friendly messages via `AppErrorMessages`
- Optional status code and details

**Usage**:
```dart
throw AppException.network();

try {
  // Some operation
} on AppException catch (e) {
  ErrorHelper.showErrorSnackbar(context, e);
}
```

#### ErrorHelper
Centralized error handling utilities:
- `showErrorSnackbar()`: Error snackbar
- `showSuccessSnackbar()`: Success snackbar
- `showInfoSnackbar()`: Info snackbar
- `getMessage()`: Get user-friendly message from any error type

**Usage**:
```dart
ErrorHelper.showErrorSnackbar(context, error);

ErrorHelper.showSuccessSnackbar(context, 'Expense saved successfully!');
```

### 7. Provider Base (`lib/providers/base/base_provider.dart`)

#### BaseProvider
Abstract base class with common functionality:
- Loading states: `isLoading`, `isSubmitting`
- Error handling: `_error`, `setError()`, `clearError()`
- API result handling: `handleApiResult()`

**Usage**:
```dart
class ExpenseProvider extends BaseProvider {
  // Use inherited methods
  setLoading(true);

  // Custom logic
  setError('Custom error message');
}

void handleApiResult(ApiResult result) {
  if (result.isSuccess) {
    // Success logic
  } else {
    setError(result.error?.toString());
  }
}
```

### 8. Service Base (`lib/services/api/base/base_service.dart`)

#### BaseService
Abstract service with standard HTTP methods:
- `get<T>()`: Standardized GET with optional parser
- `post<T>()`: Standardized POST with optional parser
- `put<T>()`: Standardized PUT with optional parser
- `delete()`: Standardized DELETE
- `patch<T>()`: Standardized PATCH with optional parser
- `upload<T>()`: File upload with progress callback

**Usage**:
```dart
class ExpenseService extends BaseService {
  ExpenseService(DioClient dioClient);

  Future<List<ExpenseDTO>> fetchExpenses() async {
    return get<List<ExpenseDTO>>(
      '/expenses',
      parser: (data) => (data as List)
          .map((json) => ExpenseDTO.fromJson(json))
          .toList(),
    );
  }

  Future<ExpenseDTO?> createExpense(CreateExpenseRequest request) async {
    return post<ExpenseDTO>(
      '/expenses',
      body: request.toJson(),
      parser: (data) => ExpenseDTO.fromJson(data),
    );
  }
}
```

## Design Tokens Reference
All widgets reference these design tokens from `lib/core/design_tokens.dart`:
- `AppColors.primary` - Primary brand color
- `AppColors.textPrimary` - Primary text color
- `AppColors.textMuted` - Muted text color
- `AppColors.border` - Border color
- `FintechColors.*` - Category colors
- `AppRadius.*` - Border radius values
- `AppShadows.*` - Shadow definitions

## Migration Guide

### Existing Components to Replace
These components can be gradually replaced with new ones:

| Old Component | New Component | Priority |
|---------------|---------------|----------|
| `app_button.dart` | `AppButton` | High |
| `fintech_widgets.dart` - FintechCard | Keep (existing) |
| `paper_button.dart` | `AppButton` | High |
| `status_badge.dart` | `StatusBadge` | Medium |
| Manual status badges | `StatusBadge` | Medium |
| Manual loading indicators | `AppLoadingIndicator` | High |
| Manual empty states | `AppEmptyState` | High |
| Form fields | `AppInputField` | High |
| Date pickers | `AppDatePicker` | Medium |
| Dropdowns | `AppDropdown` | Medium |
| Manual navigation strings | `AppRoutes.navigateTo()` | High |

### Code Style Guidelines

1. **Single Responsibility**: Each widget does one thing well
2. **Composition over Inheritance**: Prefer composition over deep widget trees
3. **Const First**: Use `const` for immutable values
4. **Null Safety**: Use `?`, `!`, `??` appropriately
5. **Widget Type**: Prefer `StatelessWidget` when state is simple
6. **Named Parameters**: Use named parameters for clarity
7. **Documentation**: Add doc comments for public APIs

### Testing

```dart
// Widget test example
testWidgets('AppButton displays correctly', (WidgetTester tester) async {
  await tester.pumpWidget(
    AppButton(label: 'Test', onPressed: () {}),
  );

  expect(find.text('Test'), findsOneWidget);
});
```

## Accessibility

All components support:
- High contrast colors (minimum 4.5:1 ratio)
- Semantic labels via semantic properties
- Tap target size (minimum 44x44 for buttons)

## Performance Considerations

- Use `const` constructors for stateless widgets
- Use `TextSpan` for complex text styling
- Avoid `const` in build methods of complex widgets
- Prefer `ListView.builder` over `Column` of many children

# Search TextField

A customizable Flutter widget that provides a search text field with dropdown suggestions. This package allows users to input text and see live search suggestions in a dropdown menu as they type.

## Features

- **Live Search**: Shows dropdown suggestions as users type
- **Customizable Appearance**: Full control over text field decoration and styling
- **Debounced Search**: Configurable delay to avoid excessive API calls
- **Generic Type Support**: Works with any data type for search results
- **Flexible Positioning**: Configurable popup position (above or below)
- **Loading States**: Built-in loading indicator support
- **Keyboard Handling**: Comprehensive keyboard input customization
- **Focus Management**: Proper focus handling for better UX
- **Selection Callbacks**: Handle item selection with custom logic

## Getting Started

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  search_textfield: ^0.0.2
```

Then import the package in your Dart code:

```dart
import 'package:search_textfield/search_textfield.dart';
```

## Usage

### Basic Example

```dart
SearchTextfield<String>(
  future: (context, query) async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 300));
    return ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry']
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  },
  itemBuilder: (context, item) {
    return ListTile(
      title: Text(item),
      leading: Icon(Icons.search),
    );
  },
  menuConstraints: BoxConstraints(maxHeight: 200),
  decoration: InputDecoration(
    hintText: 'Search fruits...',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.search),
  ),
  onSelected: (context, item) {
    return item; // Return the selected item text
  },
)
```

### Advanced Example with Custom Objects

```dart
class User {
  final String name;
  final String email;
  final String avatar;
  
  User({required this.name, required this.email, required this.avatar});
}

SearchTextfield<User>(
  future: (context, query) async {
    // Your API call here
    final response = await apiService.searchUsers(query);
    return response.map((json) => User.fromJson(json)).toList();
  },
  itemBuilder: (context, user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.avatar),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
    );
  },
  menuConstraints: BoxConstraints(maxHeight: 300),
  decoration: InputDecoration(
    hintText: 'Search users...',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    prefixIcon: Icon(Icons.person_search),
  ),
  onSelected: (context, user) {
    return user.name; // Display user name in text field
  },
  onLoading: (context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  },
)
```

## API Reference

### SearchTextfield Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `future` | `Future<List<T>> Function(BuildContext, String)` | Function that returns search results based on query | **Required** |
| `itemBuilder` | `Widget Function(BuildContext, T)` | Builder function for each search result item | **Required** |
| `menuConstraints` | `BoxConstraints` | Constraints for the dropdown menu | **Required** |
| `initialData` | `List<T>?` | Initial data to display before search | `[]` |
| `onSelected` | `String? Function(BuildContext, T)?` | Callback when an item is selected | `null` |
| `onLoading` | `Widget Function(BuildContext)?` | Widget to show during loading | `null` |
| `decoration` | `InputDecoration?` | Decoration for the text field | `null` |
| `popupPosition` | `PopupMenuPosition` | Position of the dropdown menu | `PopupMenuPosition.under` |
| `popupOffset` | `Offset?` | Additional offset for popup positioning | `null` |
| `focusNode` | `FocusNode?` | Focus node for the text field | `null` |
| `controller` | `TextEditingController?` | Controller for the text field | `null` |
| `keyboardType` | `TextInputType?` | Type of keyboard to display | `null` |
| `textInputAction` | `TextInputAction?` | Action button for the keyboard | `null` |
| `textAlign` | `TextAlign` | Text alignment | `TextAlign.start` |
| `maxLines` | `int` | Maximum number of lines | `1` |
| `minLines` | `int?` | Minimum number of lines | `1` |
| `maxLength` | `int?` | Maximum character length | `null` |
| `keyboardAppearance` | `Brightness?` | Keyboard appearance | `null` |
| `inputFormatters` | `List<TextInputFormatter>?` | Input formatters | `null` |
| `onSubmitted` | `Function(String)?` | Callback when form is submitted | `null` |

### PopupMenuPosition Enum

- `PopupMenuPosition.above`: Dropdown appears above the text field
- `PopupMenuPosition.under`: Dropdown appears below the text field

## Tips and Best Practices

1. **Debouncing**: The widget includes built-in debouncing (300ms) to prevent excessive API calls
2. **Loading States**: Always provide an `onLoading` widget for better user experience
3. **Error Handling**: Handle errors in your `future` function to prevent crashes
4. **Performance**: Use `menuConstraints` to limit dropdown height for large result sets
5. **Accessibility**: Ensure your `itemBuilder` widgets are accessible with proper semantics

## Examples

For more detailed examples, check out the [example directory](./example/example.md).

## Contributing

We welcome contributions! Please feel free to submit issues, feature requests, or pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

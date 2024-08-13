import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:libraryapp/screens/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            bool isDarkMode = themeProvider.isDarkMode;
            String modeText = isDarkMode ? 'Dark Mode' : 'Light Mode';
            String currentSorting = themeProvider.sortingPreference;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modeText,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.0),
                SwitchListTile(
                  title: Text(modeText),
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
                SizedBox(height: 24.0),
                Text(
                  'Sort by:',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                RadioListTile<String>(
                  title: Text('Title'),
                  value: 'title',
                  groupValue: currentSorting,
                  onChanged: (value) {
                    themeProvider.setSortingPreference('title');
                  },
                ),
                RadioListTile<String>(
                  title: Text('Author'),
                  value: 'author',
                  groupValue: currentSorting,
                  onChanged: (value) {
                    themeProvider.setSortingPreference('author');
                  },
                ),
                RadioListTile<String>(
                  title: Text('Rating'),
                  value: 'rating',
                  groupValue: currentSorting,
                  onChanged: (value) {
                    themeProvider.setSortingPreference('rating');
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

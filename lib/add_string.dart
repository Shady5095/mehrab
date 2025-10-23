import 'dart:io';
import 'dart:convert';

void main() async {
  // Ask for key name
  stdout.write('Enter the key name (example: openSettings): ');
  final key = stdin.readLineSync()?.trim();

  if (key == null || key.isEmpty) {
    print('❌ You must enter a key name.');
    exit(1);
  }

  // Validate key format (camelCase)
  if (!RegExp(r'^[a-z][a-zA-Z0-9]*$').hasMatch(key)) {
    print('⚠️  Warning: The key should be in camelCase format.');
  }

  // List of language files
  final langFiles = [
    'assets/lang/ar.json',
    'assets/lang/en.json',
    'assets/lang/tr.json',
    'assets/lang/de.json',
  ];

  final stringsFile = 'lib/core/utilities/resources/strings.dart';

  print('\n📝 The key "$key" will be added to the following files:');

  // Add to JSON files
  for (final filePath in langFiles) {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        print('❌ File not found: $filePath');
        continue;
      }

      // Read file
      final content = await file.readAsString();
      final jsonData = jsonDecode(content) as Map<String, dynamic>;

      // Check if key already exists
      if (jsonData.containsKey(key)) {
        print('⚠️  "$key" already exists in $filePath');
        continue;
      }

      // Add new key
      jsonData[key] = key;

      // Convert to formatted JSON
      final encoder = JsonEncoder.withIndent('  ');
      String newContent = encoder.convert(jsonData);

      // Write updated file
      await file.writeAsString(newContent);

      print('✅ Added "$key" to $filePath');
    } catch (e) {
      print('❌ Error processing $filePath: $e');
    }
  }

  // Add to strings.dart
  try {
    final file = File(stringsFile);

    if (!await file.exists()) {
      print('❌ Strings file not found: $stringsFile');
    } else {
      final content = await file.readAsString();

      // Check if key already exists
      if (content.contains("static const String $key =")) {
        print('⚠️  "$key" already exists in $stringsFile');
      } else {
        // Find the last static const String line
        final lines = content.split('\n');
        int lastConstIndex = -1;

        for (int i = lines.length - 1; i >= 0; i--) {
          if (lines[i].trim().startsWith('static const String')) {
            lastConstIndex = i;
            break;
          }
        }

        if (lastConstIndex != -1) {
          // Insert new key after the last one
          lines.insert(
              lastConstIndex + 1,
              "  static const String $key = '$key';"
          );

          await file.writeAsString(lines.join('\n'));
          print('✅ Added "$key" to $stringsFile');
        } else {
          print('⚠️  Could not find a suitable place to add the key in $stringsFile');
        }
      }
    }
  } catch (e) {
    print('❌ Error processing $stringsFile: $e');
  }

  print('\n✨ Done! You can now manually translate the values in the JSON files.');
  print('📌 Note: All values are currently set to "$key" (temporarily).');
}

import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

// Handling of the CSV functionality
// TODO: implement airplane mode fallback method
const String csvUrl =
    'https://raw.githubusercontent.com/stopipv/isdi/main/static_data/app-flags.csv';

Future<List<List>> fetchRemoteCSVData() async {
  final response = await http.get(Uri.parse(csvUrl));

  if (response.statusCode == 200) {
    final rawCSVData = utf8.decode(response.bodyBytes);
    final lines = const LineSplitter().convert(rawCSVData);
    print("Parsed remote CSV data: ${lines.length} records found.");
    return lines
        .map((line) => const CsvToListConverter().convert(line).first)
        .toList();
  } else {
    throw Exception(
        'Failed to load CSV data: ${response.statusCode} ${response.reasonPhrase}');
  }
}

Future<List<List<dynamic>>> loadLocalCSVData() async {
  final Directory documentsDirectory = await getApplicationDocumentsDirectory();
  final String path = '${documentsDirectory.path}/app-ids-research.csv';
  final File file = File(path);

  if (!file.existsSync()) {
    throw Exception("Local CSV file not found.");
  }

  final String csvString = await file.readAsString();
  final List<List<dynamic>> csvData =
      const CsvToListConverter().convert(csvString);
  return csvData;
}

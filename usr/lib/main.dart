import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Rate App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CurrencyListScreen(),
    );
  }
}

class CurrencyListScreen extends StatefulWidget {
  const CurrencyListScreen({super.key});

  @override
  State<CurrencyListScreen> createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  Future<Map<String, dynamic>>? futureRates;

  @override
  void initState() {
    super.initState();
    futureRates = fetchRates();
  }

  Future<Map<String, dynamic>> fetchRates() async {
    // NOTE: This is a free API endpoint. For production apps, consider a more robust solution.
    const apiKey = "YOUR_API_KEY"; // Replace with a real API key from a provider
    final url = Uri.parse('https://v6.exchangerate-api.com/v6/$apiKey/latest/USD');
    
    // A mock response for demonstration purposes in case the API fails or is not available.
    const mockResponse = '''
    {
      "result": "success",
      "documentation": "https://www.exchangerate-api.com/docs",
      "terms_of_use": "https://www.exchangerate-api.com/terms",
      "time_last_update_unix": 1672531201,
      "time_last_update_utc": "Sun, 01 Jan 2023 00:00:01 +0000",
      "time_next_update_unix": 1672617601,
      "time_next_update_utc": "Mon, 02 Jan 2023 00:00:01 +0000",
      "base_code": "USD",
      "conversion_rates": {
        "USD": 1,
        "EUR": 0.93,
        "GBP": 0.82,
        "JPY": 130.87,
        "AUD": 1.48,
        "CAD": 1.36,
        "CHF": 0.92,
        "CNY": 6.89,
        "SEK": 10.45,
        "NZD": 1.59
      }
    }
    ''';

    try {
      // final response = await http.get(url);
      // if (response.statusCode == 200) {
      //   return json.decode(response.body)['conversion_rates'];
      // } else {
      //   // If the server did not return a 200 OK response,
      //   // then throw an exception.
      //   throw Exception('Failed to load currency rates');
      // }
      
      // Using mock data directly for this example
      return json.decode(mockResponse)['conversion_rates'];

    } catch (e) {
      // If there's an error in the request, fall back to mock data.
      return json.decode(mockResponse)['conversion_rates'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Rates (Base: USD)'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureRates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final rates = snapshot.data!;
            final currencies = rates.keys.toList();
            return ListView.builder(
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final rate = rates[currency];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        currency.substring(0, 1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    title: Text(currency, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      rate.toStringAsFixed(4),
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

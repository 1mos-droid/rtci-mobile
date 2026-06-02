import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://inqeckqjjdfjxdxftfok.supabase.co';
  // TODO: Replace with the actual anon key from .env
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlucWVja3FqamRmanhkeGZ0Zm9rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyODczODcsImV4cCI6MjA5Mjg2MzM4N30.BHMRqyemXp00z8K8z2wLfy3Y9t4BXzMwGa50Yv6uWi8'; 

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: kDebugMode,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

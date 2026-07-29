package com.example.network_editor_example

import com.elfsm.smre_network_client.SmreNetworkClientPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (!flutterEngine.plugins.has(SmreNetworkClientPlugin::class.java)) {
            flutterEngine.plugins.add(SmreNetworkClientPlugin())
        }
    }
}

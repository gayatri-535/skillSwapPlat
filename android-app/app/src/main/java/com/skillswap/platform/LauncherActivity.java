package com.skillswap.platform;

import android.content.Intent;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

/**
 * LauncherActivity - Entry point for the SkillSwap TWA application.
 * This activity launches the TWA which displays the web content in a full-screen WebView.
 */
public class LauncherActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Launch the TWA
        launchTwa();
    }

    private void launchTwa() {
        // The TWA is defined in AndroidManifest.xml via intent filters
        // This activity simply triggers the intent to start the full-screen TWA
        
        Intent twaIntent = new Intent();
        twaIntent.setAction("android.intent.action.MAIN");
        twaIntent.addCategory("android.intent.category.LAUNCHER");
        twaIntent.setData(android.net.Uri.parse("https://skillswapplat-1.onrender.com/"));
        
        if (twaIntent.resolveActivity(getPackageManager()) != null) {
            startActivity(twaIntent);
            finish();
        } else {
            // Fallback if Custom Tab intent fails
            Intent fallbackIntent = new Intent(Intent.ACTION_VIEW);
            fallbackIntent.setData(android.net.Uri.parse("https://skillswapplat-1.onrender.com/"));
            startActivity(fallbackIntent);
            finish();
        }
    }
}

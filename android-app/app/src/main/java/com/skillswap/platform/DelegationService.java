package com.skillswap.platform;

import android.content.Intent;
import com.google.androidbrowserhelper.trusted.TrustedWebActivityService;

/**
 * DelegationService - Handles the TWA delegation for Custom Tabs.
 * This service enables the TWA to handle various app intents and configurations.
 */
public class DelegationService extends TrustedWebActivityService {
    @Override
    protected void onCreate() {
        // This service is required for TWA functionality
        // It handles the delegation between the Android app and the web content
    }
}

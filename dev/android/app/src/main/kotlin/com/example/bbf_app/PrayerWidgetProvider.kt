package com.example.bbf_app // <--- MAKE SURE THIS MATCHES YOUR PACKAGE NAME

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            // "prayer_widget" must match your XML filename in res/layout
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {
                
                // Get data from Flutter. The keys ("fajr", "dhur", etc.) 
                // must match what you used in HomeWidget.saveWidgetData
                setTextViewText(R.id.fajr_text, widgetData.getString("fajr", "--:--"))
                setTextViewText(R.id.dhur_text, widgetData.getString("dhur", "--:--"))
                setTextViewText(R.id.asr_text, widgetData.getString("asr", "--:--"))
                setTextViewText(R.id.maghrib_text, widgetData.getString("maghrib", "--:--"))
                setTextViewText(R.id.isha_text, widgetData.getString("isha", "--:--"))
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
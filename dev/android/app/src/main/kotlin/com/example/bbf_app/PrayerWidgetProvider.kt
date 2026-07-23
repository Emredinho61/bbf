package com.example.bbf_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP }
            ?: Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val fajr    = widgetData.getString("fajr",    "--:--") ?: "--:--"
        val dhur    = widgetData.getString("dhur",    "--:--") ?: "--:--"
        val asr     = widgetData.getString("asr",     "--:--") ?: "--:--"
        val maghrib = widgetData.getString("maghrib", "--:--") ?: "--:--"
        val isha    = widgetData.getString("isha",    "--:--") ?: "--:--"

        val nextName  = widgetData.getString("next_prayer_name", "---")   ?: "---"
        val nextTime  = widgetData.getString("next_prayer_time", "--:--") ?: "--:--"
        val date      = widgetData.getString("date",             "--. ---")  ?: "--. ---"

        val green = Color.parseColor("#4CAF50")
        val white = Color.parseColor("#FFFFFF")
        val grey  = Color.parseColor("#9CA3AF")

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {

                setTextViewText(R.id.widget_date, date)

                setTextViewText(R.id.next_name, nextName)
                setTextViewText(R.id.next_time, nextTime)

                setTextViewText(R.id.fajr_time,    fajr)
                setTextViewText(R.id.dhur_time,    dhur)
                setTextViewText(R.id.asr_time,     asr)
                setTextViewText(R.id.maghrib_time, maghrib)
                setTextViewText(R.id.isha_time,    isha)

                val prayers = listOf(
                    Triple("Fajr",    R.id.fajr_label,    R.id.fajr_time),
                    Triple("Dhuhr",   R.id.dhur_label,    R.id.dhur_time),
                    Triple("Asr",     R.id.asr_label,     R.id.asr_time),
                    Triple("Maghrib", R.id.maghrib_label, R.id.maghrib_time),
                    Triple("Isha",    R.id.isha_label,    R.id.isha_time)
                )
                for ((name, labelId, timeId) in prayers) {
                    val isNext = name == nextName
                    setTextColor(labelId, if (isNext) green else grey)
                    setTextColor(timeId,  if (isNext) green else white)
                }

                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
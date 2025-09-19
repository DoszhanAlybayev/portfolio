package com.example.finnapp; // <-- замени, если у тебя другое applicationId

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;

public class ExampleWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        SharedPreferences prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE);
        String profit = prefs.getString("profit", "0 ₸");

        for (int appWidgetId : appWidgetIds) {
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.example_widget);
            views.setTextViewText(R.id.widget_profit, profit);
            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }
}

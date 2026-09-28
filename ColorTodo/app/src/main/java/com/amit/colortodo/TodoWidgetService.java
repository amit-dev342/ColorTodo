package com.amit.colortodo;
import android.content.*;import android.graphics.*;import android.widget.*;import java.util.*;
public class TodoWidgetService extends RemoteViewsService {
 @Override public RemoteViewsFactory onGetViewFactory(Intent intent){return new Factory(getApplicationContext());}
 static class Factory implements RemoteViewsFactory {
  final Context c;ArrayList<TaskStore.Task> tasks=new ArrayList<>();ArrayList<TaskStore.Task> missed=new ArrayList<>();
  Factory(Context c){this.c=c;}public void onCreate(){}
  public void onDataSetChanged(){tasks=TaskStore.load(c);tasks.sort(Comparator.comparingLong(TaskStore::weekStartFor).thenComparing(t->t.done));missed.clear();for(TaskStore.Task t:tasks)if(TaskStore.isMissed(t))missed.add(t);}
  public void onDestroy(){}
  public int getCount(){return tasks.size()+(missed.isEmpty()?0:1);}
  public RemoteViews getViewAt(int p){
   if(p<0||p>=getCount())return null;
   if(!missed.isEmpty()&&p==0){RemoteViews v=new RemoteViews(c.getPackageName(),R.layout.widget_missed_item);v.setTextViewText(R.id.widgetMissedCount,missed.size()==1?"1 MISSED TASK":missed.size()+" MISSED TASKS");v.setTextViewText(R.id.widgetMissedPreview,missedPreview());return v;}
   int taskIndex=p-(missed.isEmpty()?0:1);TaskStore.Task t=tasks.get(taskIndex);RemoteViews v=new RemoteViews(c.getPackageName(),R.layout.widget_task_item);v.setTextViewText(R.id.widgetTaskTitle,t.text);v.setTextViewText(R.id.widgetTaskStatus,t.done?"COMPLETED":"ACTIVE");v.setTextViewText(R.id.widgetTaskDate,t.due.isEmpty()?"No due date":TaskStore.displayDate(t.due));v.setTextViewText(R.id.widgetTaskPriority,t.priority.toUpperCase()+" PRIORITY");v.setTextViewText(R.id.widgetTaskTag,t.tag.isEmpty()?"UNTAGGED":t.tag.toUpperCase());v.setTextViewText(R.id.widgetTaskNotes,t.notes.isEmpty()?"No notes":t.notes);v.setTextViewText(R.id.widgetTaskWeek,TaskStore.weekLabel(TaskStore.weekStartFor(t)));v.setTextViewText(R.id.widgetTaskAction,t.done?"✓  MARK ACTIVE":"○  MARK COMPLETE");v.setTextColor(R.id.widgetTaskTitle,c.getColor(R.color.card_text));v.setInt(R.id.widgetTaskTitle,"setPaintFlags",t.done?Paint.STRIKE_THRU_TEXT_FLAG:0);v.setImageViewBitmap(R.id.widgetTaskBackground,background(t));Intent fill=new Intent();fill.putExtra(TodoWidget.EXTRA_ID,t.id);v.setOnClickFillInIntent(R.id.widgetTaskAction,fill);return v;
  }
  String missedPreview(){StringBuilder s=new StringBuilder("Needs attention");int limit=Math.min(3,missed.size());for(int i=0;i<limit;i++)s.append(i==0?"\n":"  •  ").append(missed.get(i).text);if(missed.size()>limit)s.append("\n+").append(missed.size()-limit).append(" more");return s.toString();}
  Bitmap background(TaskStore.Task t){int a,b;if(t.done){a=c.getColor(R.color.done_start);b=c.getColor(R.color.done_end);}else if("high".equals(t.priority)){a=c.getColor(R.color.high_start);b=c.getColor(R.color.high_end);}else if("low".equals(t.priority)){a=c.getColor(R.color.low_start);b=c.getColor(R.color.low_end);}else{a=c.getColor(R.color.medium_start);b=c.getColor(R.color.medium_end);}int w=1000,h=620;Bitmap bm=Bitmap.createBitmap(w,h,Bitmap.Config.ARGB_8888);Canvas canvas=new Canvas(bm);Paint paint=new Paint(Paint.ANTI_ALIAS_FLAG);paint.setShader(new LinearGradient(0,0,w,h,a,b,Shader.TileMode.CLAMP));canvas.drawRoundRect(3,3,w-3,h-3,58,58,paint);paint.setShader(null);paint.setStyle(Paint.Style.STROKE);paint.setStrokeWidth(3);paint.setColor(c.getColor(R.color.card_highlight));canvas.drawRoundRect(5,5,w-5,h-5,58,58,paint);return bm;}
  public RemoteViews getLoadingView(){return null;}public int getViewTypeCount(){return 2;}public long getItemId(int p){if(!missed.isEmpty()&&p==0)return Long.MIN_VALUE;int taskIndex=p-(missed.isEmpty()?0:1);return tasks.get(taskIndex).id;}public boolean hasStableIds(){return true;}
 }
}
package com.amit.colortodo;
import android.content.*; import org.json.*; import java.util.*;
public class TaskStore {
 public static class Task {
  public long id; public String text,priority,due,tag,notes; public boolean done;
  Task(long i,String t,String p,boolean d){this(i,t,p,d,"","","");}
  Task(long i,String t,String p,boolean d,String due,String tag,String notes){id=i;text=t;priority=p;done=d;this.due=due;this.tag=tag;this.notes=notes;}
 }
 static ArrayList<Task> load(Context c){ArrayList<Task> out=new ArrayList<>();String s=c.getSharedPreferences("todo",0).getString("tasks","[]");try{JSONArray a=new JSONArray(s);for(int i=0;i<a.length();i++){JSONObject o=a.getJSONObject(i);out.add(new Task(o.getLong("id"),o.getString("text"),o.optString("priority","medium"),o.optBoolean("done",false),o.optString("due",""),o.optString("tag",""),o.optString("notes","")));}}catch(Exception ignored){}return out;}
 static void save(Context c,List<Task> ts){JSONArray a=new JSONArray();try{for(Task t:ts){JSONObject o=new JSONObject();o.put("id",t.id);o.put("text",t.text);o.put("priority",t.priority);o.put("done",t.done);o.put("due",t.due);o.put("tag",t.tag);o.put("notes",t.notes);a.put(o);}}catch(Exception ignored){}c.getSharedPreferences("todo",0).edit().putString("tasks",a.toString()).apply();TodoWidget.refresh(c);}
 static String pref(Context c,String key,String fallback){return c.getSharedPreferences("todo",0).getString(key,fallback);}
 static void setPref(Context c,String key,String value){c.getSharedPreferences("todo",0).edit().putString(key,value).apply();TodoWidget.refresh(c);}
}

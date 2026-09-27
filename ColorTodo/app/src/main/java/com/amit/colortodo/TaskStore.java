package com.amit.colortodo;
import android.content.*; import org.json.*; import java.util.*;
public class TaskStore {
 public static class Task { public long id; public String text, priority; public boolean done; Task(long i,String t,String p,boolean d){id=i;text=t;priority=p;done=d;} }
 static ArrayList<Task> load(Context c){ ArrayList<Task> out=new ArrayList<>(); String s=c.getSharedPreferences("todo",0).getString("tasks","[]"); try{JSONArray a=new JSONArray(s); for(int i=0;i<a.length();i++){JSONObject o=a.getJSONObject(i);out.add(new Task(o.getLong("id"),o.getString("text"),o.getString("priority"),o.getBoolean("done")));}}catch(Exception ignored){} return out; }
 static void save(Context c,List<Task> ts){JSONArray a=new JSONArray();try{for(Task t:ts){JSONObject o=new JSONObject();o.put("id",t.id);o.put("text",t.text);o.put("priority",t.priority);o.put("done",t.done);a.put(o);}}catch(Exception ignored){} c.getSharedPreferences("todo",0).edit().putString("tasks",a.toString()).apply(); TodoWidget.refresh(c);}
}

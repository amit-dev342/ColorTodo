package com.amit.colortodo;
import android.app.*; import android.os.*; import android.graphics.Paint; import android.view.*; import android.widget.*; import java.util.*;
public class MainActivity extends Activity {
 LinearLayout list; EditText input; RadioGroup priority; ArrayList<TaskStore.Task> tasks;
 @Override public void onCreate(Bundle b){super.onCreate(b);setContentView(R.layout.activity_main);list=findViewById(R.id.list);input=findViewById(R.id.input);priority=findViewById(R.id.priority);findViewById(R.id.add).setOnClickListener(v->add());render();}
 @Override protected void onResume(){super.onResume();render();}
 void add(){String text=input.getText().toString().trim();if(text.isEmpty())return;String p=priority.getCheckedRadioButtonId()==R.id.high?"high":priority.getCheckedRadioButtonId()==R.id.low?"low":"medium";tasks=TaskStore.load(this);tasks.add(new TaskStore.Task(System.currentTimeMillis(),text,p,false));TaskStore.save(this,tasks);input.setText("");render();}
 void render(){tasks=TaskStore.load(this);list.removeAllViews();tasks.sort((a,b)->Boolean.compare(a.done,b.done));for(TaskStore.Task t:tasks){TextView card=new TextView(this);card.setText(t.done?"✓  "+t.text:t.text);card.setTextSize(18);card.setTextColor(0xff111111);card.setGravity(Gravity.CENTER_VERTICAL);card.setBackgroundResource(t.done?R.drawable.bg_done:t.priority.equals("high")?R.drawable.bg_high:t.priority.equals("low")?R.drawable.bg_low:R.drawable.bg_medium);if(t.done)card.setPaintFlags(card.getPaintFlags()|Paint.STRIKE_THRU_TEXT_FLAG);LinearLayout.LayoutParams lp=new LinearLayout.LayoutParams(-1,dp(64));lp.setMargins(0,0,0,10);card.setLayoutParams(lp);final long[] last={0};card.setOnClickListener(v->{long now=System.currentTimeMillis();if(now-last[0]<350){toggle(t.id);last[0]=0;}else last[0]=now;});card.setOnLongClickListener(v->{tasks.removeIf(x->x.id==t.id);TaskStore.save(this,tasks);render();return true;});list.addView(card);}}
 void toggle(long id){for(TaskStore.Task t:tasks)if(t.id==id)t.done=!t.done;TaskStore.save(this,tasks);render();}
 int dp(int x){return (int)(x*getResources().getDisplayMetrics().density+.5f);}
}

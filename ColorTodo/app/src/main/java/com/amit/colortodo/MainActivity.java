package com.amit.colortodo;

import android.app.*;
import android.os.*;
import android.graphics.Paint;
import android.graphics.drawable.GradientDrawable;
import android.view.*;
import android.widget.*;
import java.util.*;

public class MainActivity extends Activity {
    LinearLayout list;
    EditText input, dueInput, tagInput, notesInput;
    RadioGroup priority;
    Spinner sizeSpinner, styleSpinner;
    ArrayList<TaskStore.Task> tasks;
    String size, style;

    @Override public void onCreate(Bundle b) {
        super.onCreate(b);
        setContentView(R.layout.activity_main);
        list=findViewById(R.id.list); input=findViewById(R.id.input); dueInput=findViewById(R.id.dueInput);
        tagInput=findViewById(R.id.tagInput); notesInput=findViewById(R.id.notesInput); priority=findViewById(R.id.priority);
        sizeSpinner=findViewById(R.id.sizeSpinner); styleSpinner=findViewById(R.id.styleSpinner);
        ArrayAdapter<String> sizes=new ArrayAdapter<>(this,android.R.layout.simple_spinner_dropdown_item,new String[]{"Compact","Default","Expanded"});
        ArrayAdapter<String> styles=new ArrayAdapter<>(this,android.R.layout.simple_spinner_dropdown_item,new String[]{"Card","List","Board"});
        sizeSpinner.setAdapter(sizes); styleSpinner.setAdapter(styles);
        size=TaskStore.pref(this,"size","default"); style=TaskStore.pref(this,"style","card");
        sizeSpinner.setSelection(size.equals("compact")?0:size.equals("expanded")?2:1);
        styleSpinner.setSelection(style.equals("list")?1:style.equals("board")?2:0);
        AdapterView.OnItemSelectedListener configListener=new AdapterView.OnItemSelectedListener(){
            public void onNothingSelected(AdapterView<?> p){}
            public void onItemSelected(AdapterView<?> p,View v,int pos,long id){
                size=sizeSpinner.getSelectedItem().toString().toLowerCase();
                String s=styleSpinner.getSelectedItem().toString().toLowerCase();
                style=s.equals("board")?"board":s;
                TaskStore.setPref(MainActivity.this,"size",size); TaskStore.setPref(MainActivity.this,"style",style); render();
            }};
        sizeSpinner.setOnItemSelectedListener(configListener); styleSpinner.setOnItemSelectedListener(configListener);
        findViewById(R.id.add).setOnClickListener(v->add());
        render();
    }

    @Override protected void onResume(){super.onResume();render();}

    void add(){
        String text=input.getText().toString().trim(); if(text.isEmpty())return;
        String p=priority.getCheckedRadioButtonId()==R.id.high?"high":priority.getCheckedRadioButtonId()==R.id.low?"low":"medium";
        tasks=TaskStore.load(this);
        tasks.add(new TaskStore.Task(System.currentTimeMillis(),text,p,false,dueInput.getText().toString().trim(),tagInput.getText().toString().trim(),notesInput.getText().toString().trim()));
        TaskStore.save(this,tasks);
        input.setText(""); dueInput.setText(""); tagInput.setText(""); notesInput.setText("");
        render();
    }

    void render(){
        if(list==null)return;
        tasks=TaskStore.load(this); list.removeAllViews();
        tasks.sort((a,b)->Boolean.compare(a.done,b.done));
        if(tasks.isEmpty()){TextView empty=text("Nothing here yet\nAdd a task and give your day a little structure.",16,R.color.text_muted);empty.setGravity(Gravity.CENTER);empty.setPadding(dp(20),dp(64),dp(20),dp(64));list.addView(empty);return;}
        if("board".equals(style)){renderBoard();return;}
        for(TaskStore.Task t:tasks) list.addView(taskView(t));
    }

    void renderBoard(){
        HorizontalScrollView scroll=new HorizontalScrollView(this); LinearLayout columns=new LinearLayout(this); columns.setOrientation(LinearLayout.HORIZONTAL);
        LinearLayout active=column("TO DO"); LinearLayout done=column("COMPLETED");
        for(TaskStore.Task t:tasks)(t.done?done:active).addView(taskView(t));
        columns.addView(active); columns.addView(done); scroll.addView(columns); list.addView(scroll);
    }

    LinearLayout column(String title){
        LinearLayout c=new LinearLayout(this); c.setOrientation(LinearLayout.VERTICAL); c.setPadding(0,0,dp(12),0);
        c.setLayoutParams(new LinearLayout.LayoutParams(dp(300),LinearLayout.LayoutParams.WRAP_CONTENT));
        TextView h=text(title,12,R.color.text_muted); h.setAllCaps(true); h.setLetterSpacing(.12f); h.setPadding(dp(4),dp(8),0,dp(10)); c.addView(h); return c;
    }

    View taskView(TaskStore.Task t){
        LinearLayout row=new LinearLayout(this); row.setOrientation(LinearLayout.HORIZONTAL); row.setGravity(Gravity.TOP); int pad=size.equals("compact")?10:size.equals("expanded")?16:14; row.setPadding(dp(pad),dp(pad),dp(pad),dp(pad));
        LinearLayout.LayoutParams lp=new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.WRAP_CONTENT); lp.setMargins(0,0,0,dp(style.equals("list")?1:10)); row.setLayoutParams(lp);
        if(style.equals("card")){row.setElevation(dp(2)); row.setBackground(cardBackground(t));} else if(style.equals("list")) row.setBackgroundColor(getColor(R.color.surface));
        else row.setBackground(cardBackground(t));

        CheckBox check=new CheckBox(this); check.setChecked(t.done); check.setContentDescription(t.done?"Mark task active":"Mark task complete"); check.setOnClickListener(v->toggle(t.id)); row.addView(check,new LinearLayout.LayoutParams(dp(44),dp(44)));

        LinearLayout body=new LinearLayout(this); body.setOrientation(LinearLayout.VERTICAL); body.setPadding(dp(4),0,0,0);
        TextView title=text(t.text,size.equals("compact")?15:17,t.done?R.color.text_muted:R.color.text_primary); title.setTypeface(null,1);
        if(t.done) title.setPaintFlags(title.getPaintFlags()|Paint.STRIKE_THRU_TEXT_FLAG);
        body.addView(title);
        if(!size.equals("compact")){
            String meta=(t.due.isEmpty()?"":("Due "+t.due+"  •  "))+(t.tag.isEmpty()?"":("#"+t.tag+"  •  "))+cap(t.priority);
            TextView m=text(meta,12,R.color.text_muted); m.setPadding(0,dp(5),0,0); body.addView(m);
        }
        if(size.equals("expanded")&&!t.notes.isEmpty()){TextView n=text(t.notes,14,R.color.text_secondary);n.setPadding(0,dp(8),0,0);n.setMaxLines(3);body.addView(n);}
        row.addView(body,new LinearLayout.LayoutParams(0,LinearLayout.LayoutParams.WRAP_CONTENT,1));

        final long[] last={0}; row.setOnClickListener(v->{long now=System.currentTimeMillis();if(now-last[0]<350){toggle(t.id);last[0]=0;}else last[0]=now;});
        row.setOnLongClickListener(v->{row.animate().alpha(0f).translationX(dp(40)).setDuration(160).withEndAction(()->{tasks.removeIf(x->x.id==t.id);TaskStore.save(this,tasks);render();}).start();return true;});
        return row;
    }

    GradientDrawable cardBackground(TaskStore.Task t){
        int color=t.done?getColor(R.color.task_done):t.priority.equals("high")?getColor(R.color.priority_high_surface):t.priority.equals("low")?getColor(R.color.priority_low_surface):getColor(R.color.priority_medium_surface);
        GradientDrawable g=new GradientDrawable();g.setColor(color);g.setCornerRadius(dp(12));g.setStroke(dp(1),getColor(R.color.border));return g;
    }
    TextView text(String s,int sp,int color){TextView v=new TextView(this);v.setText(s);v.setTextSize(sp);v.setTextColor(getColor(color));return v;}
    void toggle(long id){for(TaskStore.Task t:tasks)if(t.id==id)t.done=!t.done;TaskStore.save(this,tasks);render();}
    String cap(String s){return s.substring(0,1).toUpperCase()+s.substring(1)+" priority";}
    int dp(int x){return (int)(x*getResources().getDisplayMetrics().density+.5f);}
}

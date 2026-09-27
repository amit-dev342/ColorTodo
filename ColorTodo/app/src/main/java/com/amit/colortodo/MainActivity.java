package com.amit.colortodo;

import android.app.*;
import android.os.*;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.content.*;
import android.view.*;
import android.widget.*;
import java.util.*;

public class MainActivity extends Activity {
    LinearLayout list;
    ArrayList<TaskStore.Task> tasks;
    String size, style;

    @Override public void onCreate(Bundle b){
        super.onCreate(b); setContentView(R.layout.activity_main);
        list=findViewById(R.id.list);
        size=TaskStore.pref(this,"size","default"); style=TaskStore.pref(this,"style","card");
        findViewById(R.id.addFab).setOnClickListener(v->showAddDialog());
        findViewById(R.id.viewButton).setOnClickListener(v->showViewDialog());
        render();
    }
    @Override protected void onResume(){super.onResume();render();}

    void showAddDialog(){
        LinearLayout form=new LinearLayout(this); form.setOrientation(LinearLayout.VERTICAL); form.setPadding(dp(22),dp(8),dp(22),0);
        EditText title=input("Task title"); EditText due=input("Due date (e.g. Tomorrow)"); EditText tag=input("Tag (e.g. Personal)"); EditText notes=input("Notes (optional)");
        RadioGroup priorities=new RadioGroup(this); priorities.setOrientation(LinearLayout.HORIZONTAL);
        RadioButton high=radio("High"), medium=radio("Medium"), low=radio("Low"); medium.setChecked(true);
        priorities.addView(high);priorities.addView(medium);priorities.addView(low);
        form.addView(title);form.addView(due);form.addView(tag);form.addView(notes);form.addView(priorities);
        AlertDialog d=new AlertDialog.Builder(this).setTitle("New task").setView(form).setNegativeButton("Cancel",null).setPositiveButton("Add",null).create();
        d.setOnShowListener(x->d.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v->{
            String text=title.getText().toString().trim(); if(text.isEmpty()){title.setError("Add a title");return;}
            String p=high.isChecked()?"high":low.isChecked()?"low":"medium"; tasks=TaskStore.load(this);
            tasks.add(new TaskStore.Task(System.currentTimeMillis(),text,p,false,due.getText().toString().trim(),tag.getText().toString().trim(),notes.getText().toString().trim()));
            TaskStore.save(this,tasks); d.dismiss(); render();
        })); d.show();
    }

    void showViewDialog(){
        String[] sizes={"Compact","Default","Expanded"}, styles={"Card","List","Board"};
        LinearLayout box=new LinearLayout(this);box.setOrientation(LinearLayout.VERTICAL);box.setPadding(dp(22),0,dp(22),0);
        TextView a=label("Task size"); Spinner sizePick=new Spinner(this); sizePick.setAdapter(spinnerAdapter(sizes)); sizePick.setSelection(size.equals("compact")?0:size.equals("expanded")?2:1);
        TextView b=label("Layout"); Spinner stylePick=new Spinner(this); stylePick.setAdapter(spinnerAdapter(styles)); stylePick.setSelection(style.equals("list")?1:style.equals("board")?2:0);
        box.addView(a);box.addView(sizePick);box.addView(b);box.addView(stylePick);
        new AlertDialog.Builder(this).setTitle("View options").setView(box).setNegativeButton("Cancel",null).setPositiveButton("Apply",(d,w)->{
            size=sizePick.getSelectedItem().toString().toLowerCase(); style=stylePick.getSelectedItem().toString().toLowerCase();
            TaskStore.setPref(this,"size",size);TaskStore.setPref(this,"style",style);render();
        }).show();
    }

    ArrayAdapter<String> spinnerAdapter(String[] values){ArrayAdapter<String>a=new ArrayAdapter<String>(this,android.R.layout.simple_spinner_dropdown_item,values);return a;}
    EditText input(String hint){EditText e=new EditText(this);e.setHint(hint);e.setTextColor(getColor(R.color.text_primary));e.setHintTextColor(getColor(R.color.text_muted));e.setSingleLine(true);e.setPadding(dp(12),0,dp(12),0);e.setBackgroundResource(R.drawable.input_bg);LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,dp(50));p.setMargins(0,0,0,dp(10));e.setLayoutParams(p);return e;}
    RadioButton radio(String s){RadioButton r=new RadioButton(this);r.setText(s);r.setTextColor(getColor(R.color.text_primary));return r;}
    TextView label(String s){TextView t=text(s,12,R.color.text_muted);t.setTypeface(null,Typeface.BOLD);t.setPadding(0,dp(12),0,dp(4));return t;}

    void render(){
        tasks=TaskStore.load(this); list.removeAllViews(); tasks.sort((a,b)->Boolean.compare(a.done,b.done));
        TextView count=findViewById(R.id.taskCount);int open=0;for(TaskStore.Task t:tasks)if(!t.done)open++;
        count.setText(open==1?"1 task remaining":open+" tasks remaining");
        if(tasks.isEmpty()){LinearLayout empty=new LinearLayout(this);empty.setOrientation(LinearLayout.VERTICAL);empty.setGravity(Gravity.CENTER);empty.setPadding(dp(20),dp(90),dp(20),dp(40));
            TextView icon=text("✓",30,R.color.accent);icon.setGravity(Gravity.CENTER);empty.addView(icon);
            TextView h=text("All clear",20,R.color.text_primary);h.setTypeface(null,Typeface.BOLD);h.setGravity(Gravity.CENTER);h.setPadding(0,dp(12),0,dp(5));empty.addView(h);
            TextView sub=text("Add a task when something needs your attention.",14,R.color.text_muted);sub.setGravity(Gravity.CENTER);empty.addView(sub);list.addView(empty);return;}
        if(style.equals("board")){renderBoard();return;} for(TaskStore.Task t:tasks)list.addView(taskView(t));
    }

    void renderBoard(){
        HorizontalScrollView scroll=new HorizontalScrollView(this);scroll.setHorizontalScrollBarEnabled(false);LinearLayout cols=new LinearLayout(this);cols.setOrientation(LinearLayout.HORIZONTAL);
        LinearLayout todo=column("TO DO"), done=column("DONE");for(TaskStore.Task t:tasks)(t.done?done:todo).addView(taskView(t));cols.addView(todo);cols.addView(done);scroll.addView(cols);list.addView(scroll);
    }
    LinearLayout column(String title){LinearLayout c=new LinearLayout(this);c.setOrientation(LinearLayout.VERTICAL);c.setPadding(0,0,dp(12),0);c.setLayoutParams(new LinearLayout.LayoutParams(dp(300),-2));TextView h=label(title);h.setLetterSpacing(.12f);h.setPadding(dp(4),dp(8),0,dp(12));c.addView(h);return c;}

    View taskView(TaskStore.Task t){
        LinearLayout row=new LinearLayout(this);row.setOrientation(LinearLayout.HORIZONTAL);row.setGravity(Gravity.CENTER_VERTICAL);
        int vertical=size.equals("compact")?9:size.equals("expanded")?16:13;row.setPadding(dp(10),dp(vertical),dp(12),dp(vertical));
        LinearLayout.LayoutParams lp=new LinearLayout.LayoutParams(-1,-2);lp.setMargins(0,0,0,dp(style.equals("list")?1:10));row.setLayoutParams(lp);
        if(style.equals("list"))row.setBackgroundColor(getColor(R.color.surface));else{row.setBackground(cardBackground(t));row.setElevation(dp(2));}

        View bar=new View(this);GradientDrawable bg=new GradientDrawable();bg.setColor(priorityColor(t));bg.setCornerRadius(dp(4));bar.setBackground(bg);LinearLayout.LayoutParams bp=new LinearLayout.LayoutParams(dp(4),size.equals("expanded")?dp(78):dp(48));bp.setMargins(0,0,dp(8),0);row.addView(bar,bp);
        CheckBox check=new CheckBox(this);check.setChecked(t.done);check.setButtonTintList(android.content.res.ColorStateList.valueOf(getColor(R.color.accent)));check.setOnClickListener(v->toggle(t.id));row.addView(check,new LinearLayout.LayoutParams(dp(42),dp(42)));

        LinearLayout body=new LinearLayout(this);body.setOrientation(LinearLayout.VERTICAL);
        TextView title=text(t.text,size.equals("compact")?15:16,t.done?R.color.text_muted:R.color.text_primary);title.setTypeface(null,Typeface.BOLD);if(t.done)title.setPaintFlags(title.getPaintFlags()|Paint.STRIKE_THRU_TEXT_FLAG);body.addView(title);
        if(!size.equals("compact")){LinearLayout meta=new LinearLayout(this);meta.setOrientation(LinearLayout.HORIZONTAL);meta.setPadding(0,dp(5),0,0);
            if(!t.due.isEmpty())meta.addView(chip("◷  "+t.due,R.color.surface_alt));if(!t.tag.isEmpty())meta.addView(chip(t.tag,R.color.tag_surface));meta.addView(chip(cap(t.priority),prioritySurface(t)));body.addView(meta);}
        if(size.equals("expanded")&&!t.notes.isEmpty()){TextView n=text(t.notes,13,R.color.text_secondary);n.setPadding(0,dp(9),0,0);n.setMaxLines(2);body.addView(n);}
        row.addView(body,new LinearLayout.LayoutParams(0,-2,1));
        TextView more=text("⋮",24,R.color.text_muted);more.setGravity(Gravity.CENTER);row.addView(more,new LinearLayout.LayoutParams(dp(34),dp(44)));
        final long[] last={0};row.setOnClickListener(v->{long now=System.currentTimeMillis();if(now-last[0]<350){toggle(t.id);last[0]=0;}else last[0]=now;});
        View.OnLongClickListener del=v->{row.animate().alpha(0).translationX(dp(48)).setDuration(160).withEndAction(()->{tasks.removeIf(x->x.id==t.id);TaskStore.save(this,tasks);render();}).start();return true;};row.setOnLongClickListener(del);more.setOnLongClickListener(del);return row;
    }

    TextView chip(String s,int color){TextView v=text(s,11,R.color.text_secondary);v.setText(s);v.setBackground(round(color,20));v.setPadding(dp(8),dp(3),dp(8),dp(3));LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-2,-2);p.setMargins(0,0,dp(6),0);v.setLayoutParams(p);return v;}
    GradientDrawable cardBackground(TaskStore.Task t){GradientDrawable g=round(t.done?R.color.task_done:R.color.surface,12);g.setStroke(dp(1),getColor(R.color.border));return g;}
    GradientDrawable round(int color,int radius){GradientDrawable g=new GradientDrawable();g.setColor(getColor(color));g.setCornerRadius(dp(radius));return g;}
    int priorityColor(TaskStore.Task t){return getColor(t.priority.equals("high")?R.color.priority_high:t.priority.equals("low")?R.color.priority_low:R.color.priority_medium);}
    int prioritySurface(TaskStore.Task t){return t.priority.equals("high")?R.color.priority_high_surface:t.priority.equals("low")?R.color.priority_low_surface:R.color.priority_medium_surface;}
    TextView text(String s,int sp,int color){TextView v=new TextView(this);v.setText(s);v.setTextSize(sp);v.setTextColor(getColor(color));return v;}
    void toggle(long id){for(TaskStore.Task t:tasks)if(t.id==id)t.done=!t.done;TaskStore.save(this,tasks);render();}
    String cap(String s){return s.substring(0,1).toUpperCase()+s.substring(1);}
    int dp(int x){return(int)(x*getResources().getDisplayMetrics().density+.5f);}
}

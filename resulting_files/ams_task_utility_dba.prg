CREATE PROGRAM ams_task_utility:dba
 PAINT
 SET modify = predeclare
 DECLARE clearscreen(null) = null WITH protect
 DECLARE displaytaskstoupdate(null) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE getcopytask(null) = null WITH protect
 DECLARE displaytasksettings(null) = null WITH protect
 DECLARE drawscrollbox(begrow=i4,begcol=i4,endrow=i4,endcol=i4) = null WITH protect
 DECLARE downarrow(newrow=c75) = null WITH protect
 DECLARE uparrow(newrow=c75) = null WITH protect
 DECLARE buildrowstr(i=i4) = c75 WITH protect
 DECLARE buildpositionrowstr(i=i4) = c75 WITH protect
 DECLARE lookupprsnlid(susername=vc) = f8 WITH protect
 DECLARE determineupdates(null) = null WITH protect
 DECLARE incrementtaskcount(inccnt=i4) = i2 WITH protect
 DECLARE last_mod = vc WITH protect
 DECLARE cdtypemed = f8 WITH constant(uar_get_code_by("MEANING",6026,"MED")), protect
 DECLARE debugind = i2 WITH protect
 DECLARE errorind = i2 WITH protect
 DECLARE errorstr = vc WITH protect
 DECLARE numrows = i4 WITH constant(20), protect
 DECLARE numcols = i4 WITH constant(75), protect
 DECLARE soffrow = i4 WITH constant(6), protect
 DECLARE soffcol = i4 WITH constant(3), protect
 DECLARE searchdttm = dq8 WITH protect
 DECLARE copytask = vc WITH protect
 DECLARE selectedtask = vc WITH protect
 DECLARE i = i4 WITH protect
 DECLARE poscnt = i4 WITH protect
 DECLARE micheckallusers = i2 WITH protect
 DECLARE mfuserprsnlid = f8 WITH protect
 DECLARE script_name = c16 WITH protect, constant("AMS_TASK_UTILITY")
 FREE RECORD tasks
 RECORD tasks(
   1 list_sz = i4
   1 list[*]
     2 ref_task_id = f8
     2 task_desc = vc
     2 positions[*]
       3 action_flag = i4
       3 position_cd = f8
       3 position_disp = vc
 )
 FREE RECORD copy_task
 RECORD copy_task(
   1 task_id = f8
   1 chart_done = i2
   1 quick_chart = i2
   1 overdue_time = i4
   1 overdue_unit = i2
   1 retention_time = i4
   1 retention_unit = i2
   1 reschedule_hours = i4
   1 grace_mins = i4
   1 all_positions_chart = i2
   1 position_sz = i4
   1 positions[*]
     2 position_cd = f8
 )
 EXECUTE cclseclogin
 IF ((xxcclseclogin->loggedin != 1))
  SET errorind = 1
  SET errorstr = "You must be logged in securely. Please run the program again."
  GO TO exit_script
 ENDIF
 IF (validate(debug,0)=1)
  CALL echo("Debug Mode Enabled")
  SET debugind = 1
 ELSE
  SET trace = callecho
  SET trace = notest
  SET trace = noechoinput
  SET trace = noechoinput2
  SET trace = noechorecord
  SET trace = noshowuar
  SET message = noinformation
  SET trace = nocost
 ENDIF
#main_menu
 SET stat = initrec(tasks)
 CALL clear(1,1)
 CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
 CALL video(r)
 CALL text((soffrow - 4),soffcol,
  "                            AMS Task Utility                               ")
 CALL text((soffrow - 3),soffcol,
  "      Copy Task Settings From One Medication Task To Selected Others       ")
 CALL video(n)
 CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
 CALL text((soffrow+ 4),(soffcol+ 8),"Search for tasks by:")
 CALL text((soffrow+ 5),(soffcol+ 28),"1 Date Range")
 CALL text((soffrow+ 6),(soffcol+ 28),"2 Specific Tasks")
 CALL text((soffrow+ 7),(soffcol+ 28),"3 Exit")
 CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
 CALL text((soffrow+ 16),soffcol,"Choose mode:")
 CALL accept((soffrow+ 16),(soffcol+ 13),"9;",3
  WHERE curaccept IN (1, 2, 3))
 CASE (curaccept)
  OF 1:
   CALL clearscreen(null)
   EXECUTE FROM date TO end_date
  OF 2:
   CALL clearscreen(null)
   EXECUTE FROM pick TO end_pick
  OF 3:
   GO TO exit_script
 ENDCASE
#date
 CALL getcopytask(null)
 CALL text((soffrow+ 2),soffcol,"Enter date of when tasks were last updated:")
 CALL accept((soffrow+ 2),(soffcol+ 44),"NNDNNDNNNN;C",format(curdate,"MM/DD/YYYY;;D")
  WHERE format(cnvtdate(cnvtalphanum(curaccept)),"MM/DD/YYYY;;D")=curaccept)
 SET searchdttm = cnvtdatetime(cnvtdate(cnvtalphanum(curaccept)),0000)
#invalid_user
 CALL text((soffrow+ 3),soffcol,"Enter username who updated the tasks last (or ALL):")
 CALL accept((soffrow+ 3),(soffcol+ 52),"P(21);CU","ALL")
 IF (curaccept="ALL")
  SET micheckallusers = 1
 ELSE
  SET mfuserprsnlid = lookupprsnlid(curaccept)
 ENDIF
 CALL clear((soffrow+ 4),soffcol,numcols)
 SELECT INTO "nl:"
  ot.reference_task_id, ot.task_description
  FROM order_task ot,
   order_task_position_xref pos
  PLAN (ot
   WHERE ot.task_type_cd=cdtypemed
    AND ot.active_ind=1
    AND ot.updt_dt_tm >= cnvtdatetime(searchdttm)
    AND ((ot.updt_id=mfuserprsnlid) OR (micheckallusers=1))
    AND ((ot.reference_task_id+ 0) != copy_task->task_id))
   JOIN (pos
   WHERE pos.reference_task_id=outerjoin(ot.reference_task_id))
  ORDER BY ot.task_description_key, pos.position_cd
  HEAD REPORT
   i = 0
  HEAD ot.task_description_key
   i = (i+ 1), poscnt = 0
   IF (mod(i,10)=1)
    stat = alterlist(tasks->list,(i+ 9))
   ENDIF
   tasks->list[i].ref_task_id = ot.reference_task_id, tasks->list[i].task_desc = ot.task_description
  DETAIL
   IF (pos.position_cd > 0)
    poscnt = (poscnt+ 1)
    IF (mod(poscnt,10)=1)
     stat = alterlist(tasks->list[i].positions,(poscnt+ 9))
    ENDIF
    tasks->list[i].positions[poscnt].position_cd = pos.position_cd, tasks->list[i].positions[poscnt].
    position_disp = trim(uar_get_code_display(pos.position_cd))
   ENDIF
  FOOT  ot.task_description_key
   IF (mod(poscnt,10) != 0)
    stat = alterlist(tasks->list[i].positions,poscnt)
   ENDIF
  FOOT REPORT
   tasks->list_sz = i
   IF (mod(i,10) != 0)
    stat = alterlist(tasks->list,i)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text((soffrow+ 14),soffcol,"No tasks found using search parameters")
  CALL text((soffrow+ 16),soffcol,"Search again? (Y)es (N)o:")
  CALL accept((soffrow+ 16),(soffcol+ 26),"A;CU","Y"
   WHERE curaccept IN ("Y", "N"))
  IF (curaccept="N")
   GO TO main_menu
  ELSEIF (curaccept="Y")
   CALL clearscreen(null)
   GO TO date
  ENDIF
 ENDIF
 IF (debugind=1)
  CALL echo("tasks rec after being populated")
  CALL echorecord(tasks)
 ENDIF
 CALL displaytasksettings(null)
 GO TO main_menu
#end_date
#pick
 CALL getcopytask(null)
#next_task
 CALL text((soffrow+ 2),soffcol,"Enter task to copy to (Shift+F5 to select):")
 SET help = promptmsg("Task starts with:")
 SET help =
 SELECT INTO "nl:"
  ot.task_description_key, ot.reference_task_id
  FROM order_task ot
  PLAN (ot
   WHERE ot.task_type_cd=cdtypemed
    AND ot.active_ind=1
    AND ot.task_description_key >= cnvtupper(curaccept))
  ORDER BY ot.task_description_key
 ;end select
 CALL accept((soffrow+ 3),(soffcol+ 3),"P(70);CUP")
 SET selectedtask = curaccept
 SET help = off
 SELECT INTO "nl:"
  ot.reference_task_id, ot.task_description
  FROM order_task ot,
   order_task_position_xref pos
  PLAN (ot
   WHERE ot.task_description_key=selectedtask
    AND ((ot.task_type_cd+ 0)=cdtypemed)
    AND ot.active_ind=1
    AND ((ot.reference_task_id+ 0) != copy_task->task_id))
   JOIN (pos
   WHERE pos.reference_task_id=outerjoin(ot.reference_task_id))
  ORDER BY ot.task_description_key, pos.position_cd
  HEAD REPORT
   i = tasks->list_sz
  HEAD ot.task_description_key
   i = (i+ 1), poscnt = 0, stat = alterlist(tasks->list,i),
   tasks->list[i].ref_task_id = ot.reference_task_id, tasks->list[i].task_desc = ot.task_description
  DETAIL
   IF (pos.position_cd > 0)
    poscnt = (poscnt+ 1)
    IF (mod(poscnt,10)=1)
     stat = alterlist(tasks->list[i].positions,(poscnt+ 9))
    ENDIF
    tasks->list[i].positions[poscnt].position_cd = pos.position_cd, tasks->list[i].positions[poscnt].
    position_disp = trim(uar_get_code_display(pos.position_cd))
   ENDIF
  FOOT  ot.task_description_key
   IF (mod(poscnt,10) != 0)
    stat = alterlist(tasks->list[i].positions,poscnt)
   ENDIF
  FOOT REPORT
   tasks->list_sz = i
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text((soffrow+ 4),soffcol,"No task found! Enter valid task")
  GO TO next_task
 ENDIF
 CALL clear((soffrow+ 4),soffcol,numcols)
 CALL text((soffrow+ 4),soffcol,"Enter another task?:")
 CALL accept((soffrow+ 4),(soffcol+ 21),"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  GO TO next_task
 ENDIF
 IF (debugind=1)
  CALL echo("tasks rec after being populated")
  CALL echorecord(tasks)
 ENDIF
 CALL displaytasksettings(null)
 GO TO main_menu
#end_pick
 SUBROUTINE getcopytask(null)
   SET stat = initrec(tasks)
   CALL text(soffrow,soffcol,"Enter task to copy from (Shift+F5 to select):")
   SET help = promptmsg("Task starts with:")
   SET help =
   SELECT INTO "nl:"
    ot.task_description_key, ot.reference_task_id
    FROM order_task ot
    PLAN (ot
     WHERE ot.task_type_cd=cdtypemed
      AND ot.active_ind=1
      AND ot.task_description_key >= cnvtupper(curaccept))
    ORDER BY ot.task_description_key
   ;end select
   CALL accept((soffrow+ 1),(soffcol+ 3),"P(70);CUP","MLTMAUTOTEST")
   SET copytask = trim(cnvtupper(curaccept))
   SET help = off
   SELECT INTO "nl:"
    ot.reference_task_id, ot.task_description_key, position = uar_get_code_display(pos.position_cd)
    FROM order_task ot,
     order_task_position_xref pos
    PLAN (ot
     WHERE ot.task_description_key=copytask
      AND ((ot.task_type_cd+ 0)=cdtypemed)
      AND ot.active_ind=1)
     JOIN (pos
     WHERE pos.reference_task_id=outerjoin(ot.reference_task_id))
    ORDER BY ot.task_description_key, position
    HEAD REPORT
     i = 0
    HEAD ot.task_description_key
     copy_task->task_id = ot.reference_task_id, copy_task->quick_chart = ot.quick_chart_ind,
     copy_task->chart_done = ot.quick_chart_done_ind,
     copy_task->retention_time = ot.retain_time, copy_task->retention_unit = ot.retain_units,
     copy_task->overdue_time = ot.overdue_min,
     copy_task->overdue_unit = ot.overdue_units, copy_task->reschedule_hours = ot.reschedule_time,
     copy_task->grace_mins = ot.grace_period_mins,
     copy_task->all_positions_chart = ot.allpositionchart_ind
    DETAIL
     IF (pos.position_cd > 0)
      i = (i+ 1)
      IF (mod(i,10)=1)
       stat = alterlist(copy_task->positions,(i+ 9))
      ENDIF
      copy_task->positions[i].position_cd = pos.position_cd
     ENDIF
    FOOT REPORT
     copy_task->position_sz = i
     IF (mod(i,10) != 0)
      stat = alterlist(copy_task->positions,i)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL text((soffrow+ 2),soffcol,"No task found! Enter valid task")
    CALL getcopytask(null)
   ENDIF
   IF (debugind=1)
    CALL echo("copy_task rec after being populated")
    CALL echorecord(copy_task)
   ENDIF
   CALL clear((soffrow+ 2),soffcol,numcols)
 END ;Subroutine
 SUBROUTINE displaytasksettings(null)
   DECLARE maxrows = i4 WITH noconstant(7), protect
   DECLARE cnt = i4 WITH protect
   DECLARE arow = i4 WITH protect
   DECLARE str = c75 WITH protect
   DECLARE pick = i2 WITH protect
   IF ((copy_task->all_positions_chart=1))
    CALL text((soffrow+ 6),(soffcol+ 29),"New Task Settings")
    CALL text((soffrow+ 7),(soffcol+ 20),"Chart as done:")
    CALL text((soffrow+ 7),(soffcol+ 45),
     IF ((copy_task->chart_done=1)) "Yes"
     ELSE "No"
     ENDIF
     )
    CALL text((soffrow+ 8),(soffcol+ 20),"Quick Chart:")
    CALL text((soffrow+ 8),(soffcol+ 45),
     IF ((copy_task->quick_chart=1)) "Yes"
     ELSE "No"
     ENDIF
     )
    CALL text((soffrow+ 9),(soffcol+ 20),"Overdue Time:")
    CALL text((soffrow+ 9),(soffcol+ 45),build2(trim(cnvtstring(copy_task->overdue_time))," ",
      IF ((copy_task->overdue_unit=1)) "Minutes"
      ELSE "Hours"
      ENDIF
      ))
    CALL text((soffrow+ 10),(soffcol+ 20),"Retained time frame:")
    CALL text((soffrow+ 10),(soffcol+ 45),build2(trim(cnvtstring(copy_task->retention_time))," ",
      IF ((copy_task->retention_unit=0)) ""
      ELSEIF ((copy_task->retention_unit=1)) "Minutes"
      ELSEIF ((copy_task->retention_unit=2)) "Hours"
      ELSEIF ((copy_task->retention_unit=3)) "Days"
      ELSEIF ((copy_task->retention_unit=4)) "Weeks"
      ELSEIF ((copy_task->retention_unit=5)) "Months"
      ENDIF
      ))
    CALL text((soffrow+ 11),(soffcol+ 20),"Allow to be rescheduled:")
    CALL text((soffrow+ 11),(soffcol+ 45),build2(
      IF ((copy_task->reschedule_hours=999)) "No"
      ELSE build2(trim(cnvtstring(copy_task->reschedule_hours))," Hours")
      ENDIF
      ))
    CALL text((soffrow+ 12),(soffcol+ 20),"Grace period:")
    CALL text((soffrow+ 12),(soffcol+ 45),build2(
      IF ((((copy_task->grace_mins > 60)
       AND mod(copy_task->grace_mins,60)=0) OR ((copy_task->grace_mins=0))) ) build2(trim(cnvtstring(
          (copy_task->grace_mins/ 60)))," Hours")
      ELSE build2(trim(cnvtstring(copy_task->grace_mins))," Minutes")
      ENDIF
      ))
    CALL text((soffrow+ 13),(soffcol+ 20),"All positions chart:")
    CALL text((soffrow+ 13),(soffcol+ 45),
     IF ((copy_task->all_positions_chart=1)) "Yes"
     ELSE "No"
     ENDIF
     )
    CALL text((soffrow+ 16),soffcol,"Continue? (Y)es (N)o:")
    CALL accept((soffrow+ 16),(soffcol+ 22),"A;CUS","Y"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     IF ((tasks->list_sz > 0))
      CALL clearscreen(null)
      CALL displaytaskstoupdate(null)
     ELSE
      GO TO main_menu
     ENDIF
    ELSEIF (curaccept="N")
     SET stat = initrec(tasks)
     CALL clearscreen(null)
     CALL text(soffrow,soffcol,"Tasks were not updated")
     CALL text((soffrow+ 16),soffcol,"Continue?:")
     CALL accept((soffrow+ 16),(soffcol+ 11),"A;CU","Y"
      WHERE curaccept IN ("Y"))
     GO TO main_menu
    ENDIF
   ELSE
    CALL clearscreen(null)
    CALL text((soffrow+ 0),(soffcol+ 29),"New Task Settings")
    CALL line((soffrow+ 1),(soffcol+ 19),37)
    CALL text((soffrow+ 2),(soffcol+ 5),"Chart as done:")
    CALL text((soffrow+ 2),(soffcol+ 20),
     IF ((copy_task->chart_done=1)) "Yes"
     ELSE "No"
     ENDIF
     )
    CALL text((soffrow+ 3),(soffcol+ 5),"Quick Chart:")
    CALL text((soffrow+ 3),(soffcol+ 20),
     IF ((copy_task->quick_chart=1)) "Yes"
     ELSE "No"
     ENDIF
     )
    CALL text((soffrow+ 4),(soffcol+ 5),"Overdue Time:")
    CALL text((soffrow+ 4),(soffcol+ 20),build2(trim(cnvtstring(copy_task->overdue_time))," ",
      IF ((copy_task->overdue_unit=1)) "Minutes"
      ELSE "Hours"
      ENDIF
      ))
    CALL text((soffrow+ 2),(soffcol+ 40),"Retained time frame:")
    CALL text((soffrow+ 2),(soffcol+ 65),build2(trim(cnvtstring(copy_task->retention_time))," ",
      IF ((copy_task->retention_unit=0)) ""
      ELSEIF ((copy_task->retention_unit=1)) "Minutes"
      ELSEIF ((copy_task->retention_unit=2)) "Hours"
      ELSEIF ((copy_task->retention_unit=3)) "Days"
      ELSEIF ((copy_task->retention_unit=4)) "Weeks"
      ELSEIF ((copy_task->retention_unit=5)) "Months"
      ENDIF
      ))
    CALL text((soffrow+ 3),(soffcol+ 40),"Allow to be rescheduled:")
    CALL text((soffrow+ 3),(soffcol+ 65),build2(
      IF ((copy_task->reschedule_hours=999)) "No"
      ELSE build2(trim(cnvtstring(copy_task->reschedule_hours))," Hours")
      ENDIF
      ))
    CALL text((soffrow+ 4),(soffcol+ 40),"Grace period:")
    CALL text((soffrow+ 4),(soffcol+ 65),build2(
      IF ((((copy_task->grace_mins > 60)
       AND mod(copy_task->grace_mins,60)=0) OR ((copy_task->grace_mins=0))) ) build2(trim(cnvtstring(
          (copy_task->grace_mins/ 60)))," Hours")
      ELSE build2(trim(cnvtstring(copy_task->grace_mins))," Minutes")
      ENDIF
      ))
    CALL drawscrollbox((soffrow+ 6),(soffcol+ 1),numrows,(numcols+ 1))
    CALL text((soffrow+ 6),(soffcol+ 7),"Positions to chart")
    CALL text((soffrow+ 6),(soffcol+ 60),"Total:")
    CALL text((soffrow+ 6),(soffcol+ 67),trim(cnvtstring(copy_task->position_sz,4,0)))
    WHILE (cnt < maxrows
     AND (cnt < copy_task->position_sz))
      SET cnt = (cnt+ 1)
      SET str = buildpositionrowstr(cnt)
      CALL scrolltext(cnt,str)
    ENDWHILE
    SET cnt = 1
    SET arow = 1
    SET pick = 0
    WHILE (pick=0)
      CALL text((soffrow+ 16),soffcol,"Continue? (Y)es (N)o:")
      CALL accept((soffrow+ 16),(soffcol+ 22),"A;CUS","Y"
       WHERE curaccept IN ("Y", "N"))
      CASE (curscroll)
       OF 0:
        IF (curaccept="Y")
         IF ((tasks->list_sz > 0))
          CALL clearscreen(null)
          CALL displaytaskstoupdate(null)
         ELSE
          GO TO main_menu
         ENDIF
        ELSEIF (curaccept="N")
         SET stat = initrec(tasks)
         CALL clearscreen(null)
         CALL text(soffrow,soffcol,"Tasks were not updated")
         CALL text((soffrow+ 16),soffcol,"Continue?:")
         CALL accept((soffrow+ 16),(soffcol+ 11),"A;CU","Y"
          WHERE curaccept IN ("Y"))
         GO TO main_menu
        ENDIF
        SET pick = 1
       OF 1:
        IF ((cnt < copy_task->position_sz))
         SET cnt = (cnt+ 1)
         SET str = buildpositionrowstr(cnt)
         CALL downarrow(str)
        ENDIF
       OF 2:
        IF (cnt > 1)
         SET cnt = (cnt - 1)
         SET str = buildpositionrowstr(cnt)
         CALL uparrow(str)
        ENDIF
      ENDCASE
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE displaytaskstoupdate(null)
   DECLARE maxrows = i4 WITH noconstant(13), protect
   DECLARE cnt = i4 WITH protect
   DECLARE arow = i4 WITH protect
   DECLARE str = c75 WITH protect
   CALL drawscrollbox(soffrow,(soffcol+ 1),numrows,(numcols+ 1))
   CALL text(soffrow,(soffcol+ 7),"Task")
   CALL text(soffrow,(soffcol+ 60),"Total:")
   CALL text(soffrow,(soffcol+ 67),trim(cnvtstring(tasks->list_sz,4,0)))
   WHILE (cnt < maxrows
    AND (cnt < tasks->list_sz))
     SET cnt = (cnt+ 1)
     SET str = buildrowstr(cnt)
     CALL scrolltext(cnt,str)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   SET pick = 0
   WHILE (pick=0)
     CALL text((soffrow+ 16),soffcol,"Update all? (Y)es (N)o:")
     CALL accept((soffrow+ 16),(soffcol+ 24),"A;CUS","Y"
      WHERE curaccept IN ("Y", "N"))
     CASE (curscroll)
      OF 0:
       IF (curaccept="Y")
        IF ((tasks->list_sz > 0))
         CALL performupdates(null)
        ENDIF
       ELSEIF (curaccept="N")
        SET stat = initrec(tasks)
        CALL clearscreen(null)
        CALL text(soffrow,soffcol,"Tasks were not updated")
        CALL text((soffrow+ 16),soffcol,"Continue?:")
        CALL accept((soffrow+ 16),(soffcol+ 11),"A;CU","Y"
         WHERE curaccept IN ("Y"))
        GO TO main_menu
       ENDIF
       SET pick = 1
      OF 1:
       IF ((cnt < tasks->list_sz))
        SET cnt = (cnt+ 1)
        SET str = buildrowstr(cnt)
        CALL downarrow(str)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET str = buildrowstr(cnt)
        CALL uparrow(str)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE determineupdates(null)
   DECLARE i = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE k = i4 WITH protect
   DECLARE pos = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   FOR (i = 1 TO copy_task->position_sz)
     FOR (j = 1 TO tasks->list_sz)
      SET pos = locateval(k,1,size(tasks->list[j].positions,5),copy_task->positions[i].position_cd,
       tasks->list[j].positions[k].position_cd)
      IF (pos=0)
       SET cnt = (size(tasks->list[j].positions,5)+ 1)
       SET stat = alterlist(tasks->list[j].positions,cnt)
       SET tasks->list[j].positions[cnt].action_flag = 1
       SET tasks->list[j].positions[cnt].position_cd = copy_task->positions[i].position_cd
       SET tasks->list[j].positions[cnt].position_disp = trim(uar_get_code_display(copy_task->
         positions[i].position_cd))
      ELSE
       SET tasks->list[j].positions[pos].action_flag = 0
      ENDIF
     ENDFOR
   ENDFOR
   FOR (i = 1 TO tasks->list_sz)
     FOR (j = 1 TO size(tasks->list[i].positions,5))
      SET pos = locateval(k,1,copy_task->position_sz,tasks->list[i].positions[j].position_cd,
       copy_task->positions[k].position_cd)
      IF (pos=0)
       SET tasks->list[i].positions[j].action_flag = 3
      ENDIF
     ENDFOR
   ENDFOR
   IF (debugind=1)
    CALL echo("tasks rec after setting action_flag")
    CALL echorecord(tasks)
   ENDIF
 END ;Subroutine
 SUBROUTINE performupdates(null)
   DECLARE i = i4 WITH protect
   DECLARE j = i4 WITH protect
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"Performing updates")
   CALL determineupdates(null)
   SELECT INTO "nl:"
    ot.reference_task_id
    FROM order_task ot
    PLAN (ot
     WHERE expand(i,1,tasks->list_sz,ot.reference_task_id,tasks->list[i].ref_task_id))
    WITH nocounter, forupdate(ot)
   ;end select
   SELECT INTO "nl:"
    pos.reference_task_id, pos.position_cd
    FROM (dummyt d1  WITH seq = tasks->list_sz),
     (dummyt d2  WITH seq = 1),
     order_task_position_xref pos
    PLAN (d1
     WHERE maxrec(d2,size(tasks->list[d1.seq].positions,5)))
     JOIN (d2
     WHERE (tasks->list[d1.seq].positions[d2.seq].action_flag > 0))
     JOIN (pos
     WHERE (pos.reference_task_id=tasks->list[d1.seq].ref_task_id)
      AND (pos.position_cd=tasks->list[d1.seq].positions[d2.seq].position_cd))
    WITH nocounter, forupdate(pos)
   ;end select
   INSERT  FROM (dummyt d1  WITH seq = tasks->list_sz),
     (dummyt d2  WITH seq = 1),
     order_task_position_xref pos
    SET pos.position_cd = tasks->list[d1.seq].positions[d2.seq].position_cd, pos.reference_task_id =
     tasks->list[d1.seq].ref_task_id, pos.updt_applctx = 0,
     pos.updt_cnt = 0, pos.updt_dt_tm = cnvtdatetime(curdate,curtime3), pos.updt_id = reqinfo->
     updt_id,
     pos.updt_task = - (267)
    PLAN (d1
     WHERE maxrec(d2,size(tasks->list[d1.seq].positions,5)))
     JOIN (d2
     WHERE (tasks->list[d1.seq].positions[d2.seq].action_flag=1))
     JOIN (pos)
    WITH nocounter
   ;end insert
   DELETE  FROM (dummyt d1  WITH seq = tasks->list_sz),
     (dummyt d2  WITH seq = 1),
     order_task_position_xref pos
    SET pos.seq = 1
    PLAN (d1
     WHERE maxrec(d2,size(tasks->list[d1.seq].positions,5)))
     JOIN (d2
     WHERE (tasks->list[d1.seq].positions[d2.seq].action_flag=3))
     JOIN (pos
     WHERE (pos.reference_task_id=tasks->list[d1.seq].ref_task_id)
      AND (pos.position_cd=tasks->list[d1.seq].positions[d2.seq].position_cd))
    WITH nocounter
   ;end delete
   UPDATE  FROM order_task ot
    SET ot.quick_chart_ind = copy_task->quick_chart, ot.quick_chart_done_ind = copy_task->chart_done,
     ot.retain_time = copy_task->retention_time,
     ot.retain_units = copy_task->retention_unit, ot.overdue_min = copy_task->overdue_time, ot
     .overdue_units = copy_task->overdue_unit,
     ot.reschedule_time = copy_task->reschedule_hours, ot.grace_period_mins = copy_task->grace_mins,
     ot.allpositionchart_ind = copy_task->all_positions_chart,
     ot.updt_applctx = 0, ot.updt_cnt = (ot.updt_cnt+ 1), ot.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     ot.updt_id = reqinfo->updt_id, ot.updt_task = - (267)
    WHERE expand(i,1,tasks->list_sz,ot.reference_task_id,tasks->list[i].ref_task_id)
    WITH nocounter
   ;end update
   SET stat = incrementtaskcount(tasks->list_sz)
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"Updates complete")
   CALL text((soffrow+ 16),soffcol,"Commit?:")
   CALL accept((soffrow+ 16),(soffcol+ 9),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    COMMIT
   ELSE
    ROLLBACK
   ENDIF
 END ;Subroutine
 SUBROUTINE drawscrollbox(begrow,begcol,endrow,endcol)
  CALL box(begrow,begcol,endrow,endcol)
  CALL scrollinit((begrow+ 1),(begcol+ 1),(endrow - 1),(endcol - 1))
 END ;Subroutine
 SUBROUTINE downarrow(newrow)
   IF (arow=maxrows)
    CALL scrolldown(maxrows,maxrows,newrow)
   ELSE
    SET arow = (arow+ 1)
    CALL scrolldown((arow - 1),arow,newrow)
   ENDIF
 END ;Subroutine
 SUBROUTINE uparrow(newrow)
   IF (arow=1)
    CALL scrollup(arow,arow,str)
   ELSE
    SET arow = (arow - 1)
    CALL scrollup((arow+ 1),arow,str)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildrowstr(i)
   DECLARE rstr = c75 WITH protect
   SET rstr = build2(cnvtstring(i,4,0,r)," ",substring(1,70,tasks->list[i].task_desc))
   RETURN(rstr)
 END ;Subroutine
 SUBROUTINE buildpositionrowstr(i)
   DECLARE rstr = c75 WITH protect
   SET rstr = build2(cnvtstring(i,4,0,r)," ",substring(1,70,uar_get_code_display(copy_task->
      positions[i].position_cd)))
   RETURN(rstr)
 END ;Subroutine
 SUBROUTINE clearscreen(null)
   DECLARE i = i4 WITH protect
   SET i = soffrow
   WHILE (i <= numrows)
    CALL clear(i,soffcol,numcols)
    SET i = (i+ 1)
   ENDWHILE
   CALL clear((numrows+ 2),soffcol,numcols)
 END ;Subroutine
 SUBROUTINE lookupprsnlid(susername)
   DECLARE iprsnlid = f8 WITH protect
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.username=cnvtupper(trim(susername,3))
     AND ((p.active_ind+ 0)=1)
    DETAIL
     iprsnlid = p.person_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL text((soffrow+ 4),soffcol,"User not found. Please enter valid, active username.")
    GO TO invalid_user
   ENDIF
   RETURN(iprsnlid)
 END ;Subroutine
 SUBROUTINE incrementtaskcount(inccnt)
   DECLARE pref_domain = c11 WITH protect, constant("AMS_TOOLKIT")
   DECLARE retval = i2 WITH noconstant(0), protect
   DECLARE found = i2 WITH noconstant(0), protect
   DECLARE infonbr = i4 WITH protect
   DECLARE lastupdt = dq8 WITH protect
   DECLARE infodetail = vc WITH protect, constant("Total number of tasks that have been updated:")
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=pref_domain
     AND d.info_name=script_name
    DETAIL
     found = 1, infonbr = (d.info_number+ inccnt), lastupdt = d.updt_dt_tm
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = pref_domain, d.info_name = script_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = inccnt, d.info_char = trim(infodetail), d.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WITH nocounter
    ;end insert
    IF (curqual=1)
     SET retval = 1
    ENDIF
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = infonbr, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WHERE d.info_domain=pref_domain
      AND d.info_name=script_name
     WITH nocounter
    ;end update
    IF (curqual=1)
     SET retval = 1
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 IF (errorind=1)
  SET message = nowindow
  CALL echo(errorstr)
 ENDIF
 SET last_mod = "003"
END GO

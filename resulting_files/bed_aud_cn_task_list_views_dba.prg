CREATE PROGRAM bed_aud_cn_task_list_views:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 tcnt = i2
   1 tqual[*]
     2 tl_tab_id = f8
     2 position = vc
     2 subtab = vc
     2 allstatus_ind = i2
     2 complete_ind = i2
     2 overdue_ind = i2
     2 pending_ind = i2
     2 inprocess_ind = i2
     2 discontinued_ind = i2
     2 suspend_ind = i2
     2 pendingval_ind = i2
     2 alltimeparam_ind = i2
     2 scheduled_ind = i2
     2 prn_ind = i2
     2 continuous_ind = i2
     2 task_types[*]
       3 task_name = vc
     2 columns[*]
       3 column_meaning = vc
     2 locations[*]
       3 display = vc
 )
 DECLARE string_text = vc
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM tl_tab_position_xref psn,
    tl_tab_content subtab
   PLAN (psn
    WHERE psn.position_cd > 0
     AND psn.active_ind=1)
    JOIN (subtab
    WHERE subtab.tl_tab_id=psn.tl_tab_id)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM tl_tab_position_xref psn,
   code_value cv1,
   tl_tab_content subtab,
   tl_column_content cols
  PLAN (psn
   WHERE psn.position_cd > 0
    AND psn.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=psn.position_cd
    AND cv1.active_ind=1)
   JOIN (subtab
   WHERE subtab.tl_tab_id=psn.tl_tab_id)
   JOIN (cols
   WHERE cols.tl_tab_id=subtab.tl_tab_id)
  ORDER BY cv1.display, subtab.tab_name, cols.column_nbr
  HEAD subtab.tab_name
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].tl_tab_id = psn.tl_tab_id,
   temp->tqual[tcnt].position = cv1.display, temp->tqual[tcnt].subtab = subtab.tab_name, temp->tqual[
   tcnt].allstatus_ind = subtab.allstatus_ind,
   temp->tqual[tcnt].complete_ind = subtab.complete_ind, temp->tqual[tcnt].overdue_ind = subtab
   .overdue_ind, temp->tqual[tcnt].pending_ind = subtab.pending_ind,
   temp->tqual[tcnt].inprocess_ind = subtab.inprocess_ind, temp->tqual[tcnt].discontinued_ind =
   subtab.discontinued_ind, temp->tqual[tcnt].suspend_ind = subtab.suspend_ind,
   temp->tqual[tcnt].pendingval_ind = subtab.pendingvalidation_ind, temp->tqual[tcnt].
   alltimeparam_ind = subtab.alltimeparam_ind, temp->tqual[tcnt].scheduled_ind = subtab.scheduled_ind,
   temp->tqual[tcnt].prn_ind = subtab.prn_ind, temp->tqual[tcnt].continuous_ind = subtab
   .continuous_ind, ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(temp->tqual[tcnt].columns,ccnt)
   IF (cols.column_meaning="STATUS")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Task Status"
   ELSEIF (cols.column_meaning="SCHEDDTTM")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Scheduled Date and Time"
   ELSEIF (cols.column_meaning="TASKDESC")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Task Description"
   ELSEIF (cols.column_meaning="ORDDET")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Order Details"
   ELSEIF (cols.column_meaning="ORDSTATUS")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Order Status"
   ELSEIF (cols.column_meaning="PROVNAME")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Provider Name"
   ELSEIF (cols.column_meaning="MNEMONIC")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Mnemonic"
   ELSEIF (cols.column_meaning="FINBR")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Financial Number"
   ELSEIF (cols.column_meaning="ALTWITH")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Alternate With"
   ELSEIF (cols.column_meaning="BAGSTAT")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Bag Status"
   ELSEIF (cols.column_meaning="UPDTUSERNAME")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Charted By"
   ELSEIF (cols.column_meaning="CLINICIAN")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Clinician"
   ELSEIF (cols.column_meaning="COMPLTDT")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Completed Date and Time"
   ELSEIF (cols.column_meaning="DEPT")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Department"
   ELSEIF (cols.column_meaning="FREQ")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Frequency"
   ELSEIF (cols.column_meaning="FROM")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "From"
   ELSEIF (cols.column_meaning="INGREDS")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Ingredients"
   ELSEIF (cols.column_meaning="ISOLATION")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Isolation"
   ELSEIF (cols.column_meaning="LASTDONEDT")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Last Done Date and Time"
   ELSEIF (cols.column_meaning="LASTDOSE")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Last Dose Given"
   ELSEIF (cols.column_meaning="LASTSITE")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Last Site Given"
   ELSEIF (cols.column_meaning="PRIO")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Priority"
   ELSEIF (cols.column_meaning="REASONGIVE")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Reason for Giving"
   ELSEIF (cols.column_meaning="RECEIVED")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Received"
   ELSEIF (cols.column_meaning="RESPONSEREQ")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Response Required"
   ELSEIF (cols.column_meaning="ROUTE")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Route"
   ELSEIF (cols.column_meaning="STOPDT")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Stop Date and Time"
   ELSEIF (cols.column_meaning="STRENGTH")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Strength"
   ELSEIF (cols.column_meaning="SUBJECT")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Subject"
   ELSEIF (cols.column_meaning="TO")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "To"
   ELSEIF (cols.column_meaning="TYPE")
    temp->tqual[tcnt].columns[ccnt].column_meaning = "Type"
   ELSE
    temp->tqual[tcnt].columns[ccnt].column_meaning = cols.column_meaning
   ENDIF
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tcnt),
    tl_eligible_task_code tasks,
    code_value cv1
   PLAN (d)
    JOIN (tasks
    WHERE (tasks.tl_tab_id=temp->tqual[d.seq].tl_tab_id))
    JOIN (cv1
    WHERE cv1.code_value=tasks.task_type_cd
     AND cv1.active_ind=1)
   ORDER BY d.seq, cv1.display
   HEAD d.seq
    scnt = 0
   DETAIL
    scnt = (scnt+ 1), stat = alterlist(temp->tqual[d.seq].task_types,scnt), temp->tqual[d.seq].
    task_types[scnt].task_name = cv1.display
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tcnt),
    name_value_prefs nvp,
    code_value cv
   PLAN (d)
    JOIN (nvp
    WHERE nvp.parent_entity_name="TL_TAB_CONTENT"
     AND (nvp.parent_entity_id=temp->tqual[d.seq].tl_tab_id)
     AND nvp.pvc_name="TL_PERSONAL_LOC_FILTER"
     AND nvp.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=cnvtreal(nvp.pvc_value)
     AND cv.active_ind=1)
   ORDER BY d.seq, cv.display
   HEAD d.seq
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1), stat = alterlist(temp->tqual[d.seq].locations,lcnt), temp->tqual[d.seq].
    locations[lcnt].display = cv.display
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Position"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Subtab"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Task Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Column"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Tab Status"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Tab Time Parameters"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Tab Location Filters"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].position
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].subtab
   IF ((temp->tqual[x].allstatus_ind=1))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "All"
   ELSE
    SET string_text = " "
    SET first_one = 1
    IF ((temp->tqual[x].complete_ind=1))
     SET string_text = build2(string_text,"Completed")
     SET first_one = 0
    ENDIF
    IF ((temp->tqual[x].overdue_ind=1))
     IF (first_one=1)
      SET first_one = 0
     ELSE
      SET string_text = build2(string_text,", ")
     ENDIF
     SET string_text = build2(string_text,"Overdue")
    ENDIF
    IF ((temp->tqual[x].pending_ind=1))
     IF (first_one=1)
      SET first_one = 0
     ELSE
      SET string_text = build2(string_text,", ")
     ENDIF
     SET string_text = build2(string_text,"Pending")
    ENDIF
    IF ((temp->tqual[x].inprocess_ind=1))
     IF (first_one=1)
      SET first_one = 0
     ELSE
      SET string_text = build2(string_text,", ")
     ENDIF
     SET string_text = build2(string_text,"In Process")
    ENDIF
    IF ((temp->tqual[x].discontinued_ind=1))
     IF (first_one=1)
      SET first_one = 0
     ELSE
      SET string_text = build2(string_text,", ")
     ENDIF
     SET string_text = build2(string_text,"Discontinued/Canceled")
    ENDIF
    IF ((temp->tqual[x].suspend_ind=1))
     IF (first_one=1)
      SET first_one = 0
     ELSE
      SET string_text = build2(string_text,", ")
     ENDIF
     SET string_text = build2(string_text,"Suspended")
    ENDIF
    IF ((temp->tqual[x].pendingval_ind=1))
     IF (first_one=1)
      SET first_one = 0
     ELSE
      SET string_text = build2(string_text,", ")
     ENDIF
     SET string_text = build2(string_text,"Pending Validation")
    ENDIF
    SET reply->rowlist[row_nbr].celllist[5].string_value = string_text
   ENDIF
   IF ((temp->tqual[x].alltimeparam_ind=1))
    SET reply->rowlist[row_nbr].celllist[6].string_value = "All"
   ELSE
    SET string_text = " "
    SET first_one = 1
    IF ((temp->tqual[x].scheduled_ind=1))
     SET string_text = build2(string_text,"Scheduled")
     SET first_one = 0
    ENDIF
    IF ((temp->tqual[x].prn_ind=1))
     IF (first_one=1)
      SET first_one = 0
     ELSE
      SET string_text = build2(string_text,", ")
     ENDIF
     SET string_text = build2(string_text,"PRN")
    ENDIF
    IF ((temp->tqual[x].continuous_ind=1))
     IF (first_one=1)
      SET first_one = 0
     ELSE
      SET string_text = build2(string_text,", ")
     ENDIF
     SET string_text = build2(string_text,"Constant")
    ENDIF
    SET reply->rowlist[row_nbr].celllist[6].string_value = string_text
   ENDIF
   SET string_text = " "
   SET lcnt = size(temp->tqual[x].locations,5)
   FOR (l = 1 TO lcnt)
    SET string_text = build2(string_text,temp->tqual[x].locations[l].display)
    IF (l < lcnt)
     SET string_text = build2(string_text,", ")
    ENDIF
   ENDFOR
   SET reply->rowlist[row_nbr].celllist[7].string_value = string_text
   SET taskcnt = size(temp->tqual[x].task_types,5)
   SET colcnt = size(temp->tqual[x].columns,5)
   SET c = 0
   IF (taskcnt > 0)
    FOR (t = 1 TO taskcnt)
      SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].task_types[t].task_name
      SET c = (c+ 1)
      IF (((c < colcnt) OR (c=colcnt)) )
       SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].columns[c].
       column_meaning
      ENDIF
      IF (t < taskcnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
      ENDIF
    ENDFOR
    IF (c < colcnt)
     SET c = (c+ 1)
     FOR (c = c TO colcnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
       SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].columns[c].
       column_meaning
     ENDFOR
    ENDIF
   ELSEIF (colcnt > 0)
    FOR (c = 1 TO colcnt)
     SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].columns[c].column_meaning
     IF (c < colcnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
     ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_task_list_views.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO

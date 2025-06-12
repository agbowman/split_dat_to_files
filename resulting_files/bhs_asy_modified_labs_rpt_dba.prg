CREATE PROGRAM bhs_asy_modified_labs_rpt:dba
 FREE RECORD t_record
 RECORD t_record(
   1 rec_cnt = i4
   1 rec_qual[*]
     2 encntr_id = f8
     2 fire_dt_tm = dq8
   1 phys_cnt = i4
   1 phys_qual[*]
     2 phys = vc
     2 fire_dt_tm = dq8
     2 relationship = vc
     2 activity = vc
     2 activity_dt_tm = dq8
     2 pid = f8
     2 fin = vc
     2 days_unread = vc
     2 text = vc
     2 mrn = vc
     2 pat_name = vc
     2 test = vc
   1 day_cnt = i4
   1 three_day_cnt = i4
   1 week_cnt = i4
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 EXECUTE bhs_sys_stand_subroutine:dba
 IF (validate(request->batch_selection))
  SET email_list =  $1
 ENDIF
 DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"CORPORATEMEDICALRECORDNUMBER"))
 DECLARE fin_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"PENDING"))
 DECLARE t_line = vc
 DECLARE t_string = vc
 SELECT INTO "nl:"
  FROM eks_module_audit ema,
   eks_module_audit_det emad
  PLAN (ema
   WHERE ema.begin_dt_tm >= cnvtdatetime(datetimefind(datetimeadd(sysdate,- (16)),"D","B","B"))
    AND ema.end_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ema.module_name="BHS_ASY_MODIFIED_LABS"
    AND ema.conclude=2)
   JOIN (emad
   WHERE emad.module_audit_id=ema.rec_id
    AND ((emad.encntr_id+ 0) > 0)
    AND emad.order_id > 0)
  ORDER BY ema.rec_id
  HEAD ema.rec_id
   t_record->rec_cnt = (t_record->rec_cnt+ 1), stat = alterlist(t_record->rec_qual,t_record->rec_cnt),
   t_record->rec_qual[t_record->rec_cnt].encntr_id = emad.encntr_id,
   t_record->rec_qual[t_record->rec_cnt].fire_dt_tm = ema.begin_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->rec_cnt),
   task_activity ta,
   task_activity_assignment taa,
   prsnl p,
   encntr_prsnl_reltn epr,
   long_text l,
   encntr_alias ea,
   encounter e,
   person pr,
   person_alias pa
  PLAN (d)
   JOIN (ta
   WHERE (ta.encntr_id=t_record->rec_qual[d.seq].encntr_id)
    AND ta.msg_subject="Modified Laboratory Result Alert"
    AND ta.active_status_dt_tm >= cnvtdatetime(t_record->rec_qual[d.seq].fire_dt_tm))
   JOIN (taa
   WHERE taa.task_id=ta.task_id)
   JOIN (p
   WHERE p.person_id=taa.assign_prsnl_id
    AND ((p.physician_ind+ 0)=1))
   JOIN (epr
   WHERE epr.encntr_id=ta.encntr_id
    AND ((epr.prsnl_person_id+ 0)=p.person_id))
   JOIN (l
   WHERE l.long_text_id=ta.msg_text_id)
   JOIN (ea
   WHERE ea.encntr_id=ta.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (pr
   WHERE pr.person_id=e.person_id
    AND pr.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=outerjoin(pr.person_id)
    AND pa.person_alias_type_cd=outerjoin(mrn_cd)
    AND pa.active_ind=outerjoin(1))
  ORDER BY ta.task_id, epr.encntr_prsnl_reltn_id
  HEAD ta.task_id
   t_record->phys_cnt = (t_record->phys_cnt+ 1), stat = alterlist(t_record->phys_qual,t_record->
    phys_cnt), t_record->phys_qual[t_record->phys_cnt].fire_dt_tm = ta.active_status_dt_tm,
   t_record->phys_qual[t_record->phys_cnt].phys = p.name_full_formatted, t_record->phys_qual[t_record
   ->phys_cnt].activity = uar_get_code_display(taa.task_status_cd), t_record->phys_qual[t_record->
   phys_cnt].activity_dt_tm = taa.updt_dt_tm,
   t_record->phys_qual[t_record->phys_cnt].fin = ea.alias, t_record->phys_qual[t_record->phys_cnt].
   text = l.long_text, t_record->phys_qual[t_record->phys_cnt].pat_name = pr.name_full_formatted,
   t_record->phys_qual[t_record->phys_cnt].mrn = pa.alias, t_pos = findstring(".",l.long_text,1,0),
   t_string = substring((t_pos+ 2),textlen(l.long_text),l.long_text),
   t_pos = findstring(" ",t_string,1,0), t_pos2 = findstring("previously",t_string,1,0), t_string =
   substring((t_pos+ 1),((t_pos2 - 1) - (t_pos+ 1)),t_string),
   t_record->phys_qual[t_record->phys_cnt].test = t_string, first_ind = 0
  HEAD epr.encntr_prsnl_reltn_id
   IF (first_ind=0)
    t_line = uar_get_code_display(epr.encntr_prsnl_r_cd), first_ind = 1
   ELSE
    t_line = concat(t_line,",",uar_get_code_display(epr.encntr_prsnl_r_cd))
   ENDIF
  FOOT  ta.task_id
   t_record->phys_qual[t_record->phys_cnt].relationship = t_line
   IF (taa.task_status_cd=pending_cd)
    time = datetimediff(cnvtdatetime(curdate,curtime3),t_record->phys_qual[t_record->phys_cnt].
     fire_dt_tm,3)
    IF (time > 24)
     t_record->day_cnt = (t_record->day_cnt+ 1)
    ENDIF
    IF (time > 72)
     t_record->three_day_cnt = (t_record->three_day_cnt+ 1)
    ENDIF
    IF (time > 168)
     t_record->week_cnt = (t_record->week_cnt+ 1)
    ENDIF
    days = datetimediff(cnvtdatetime(curdate,curtime3),t_record->phys_qual[t_record->phys_cnt].
     fire_dt_tm), t_record->phys_qual[t_record->phys_cnt].days_unread = trim(cnvtstring(days))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "modified_labs_rpt.xls"
  phys = t_record->phys_qual[d.seq].phys
  FROM (dummyt d  WITH seq = t_record->phys_cnt)
  ORDER BY phys
  HEAD REPORT
   t_line = "Modified Labs Report for the Previous 16 days", col 0, t_line,
   row + 1, t_line = format(cnvtdatetime(curdate,curtime3),"MM-DD-YYYY HH:MM;;Q"), col 0,
   t_line, row + 1, t_line = concat("Physician",char(9),"Patient",char(9),"MRN",
    char(9),"FIN",char(9),"Relationship to Patient",char(9),
    "Test",char(9),"Message",char(9),"Time of Rule Firing",
    char(9),"Last Activity on Message",char(9),"Time of Last Activity",char(9),
    "Days Unread",char(9)),
   col 0, t_line, row + 1
  DETAIL
   t_line = concat(t_record->phys_qual[d.seq].phys,char(9),t_record->phys_qual[d.seq].pat_name,char(9
     ),t_record->phys_qual[d.seq].mrn,
    char(9),t_record->phys_qual[d.seq].fin,char(9),t_record->phys_qual[d.seq].relationship,char(9),
    t_record->phys_qual[d.seq].test,char(9),trim(t_record->phys_qual[d.seq].text),char(9),format(
     t_record->phys_qual[d.seq].fire_dt_tm,"MM-DD-YYYY HH:MM;;Q"),
    char(9),t_record->phys_qual[d.seq].activity,char(9),format(t_record->phys_qual[d.seq].
     activity_dt_tm,"MM-DD-YYYY HH:MM;;Q"),char(9),
    t_record->phys_qual[d.seq].days_unread,char(9)), col 0, t_line,
   row + 1
  FOOT REPORT
   row + 1, t_line = concat("Number of unread messages after 24 hours ",trim(cnvtstring(t_record->
      day_cnt))), col 0,
   t_line, row + 1, t_line = concat("Number of unread messages after 72 hours ",trim(cnvtstring(
      t_record->three_day_cnt))),
   col 0, t_line, row + 1,
   t_line = concat("Number of unread messages after 1 week ",trim(cnvtstring(t_record->week_cnt))),
   col 0, t_line,
   row + 1
  WITH nocounter, maxcol = 1000, formfeed = none
 ;end select
 IF (findfile("modified_labs_rpt.xls")=1)
  CALL emailfile("modified_labs_rpt.xls","modified_labs_rpt.xls",email_list,"Modified Labs Report",1)
 ENDIF
#exit_script
 SET reply->status_data[1].status = "S"
END GO

CREATE PROGRAM bhs_pt_task_completion_rpt:dba
 FREE RECORD t_record
 RECORD t_record(
   1 beg_date = dq8
   1 end_date = dq8
   1 action_dt_tm = dq8
   1 nurse_unit_cnt = i4
   1 nurse_unit_qual[*]
     2 unit_cd = f8
   1 task_cnt = i4
   1 task_qual[*]
     2 task_id = f8
     2 cat_cd = f8
     2 loc_cd = f8
     2 create_dt_tm = dq8
     2 perform_dt_tm = dq8
     2 task_status_cd = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE complete_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE pt_t_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"PTTREATMENT"))
 DECLARE pt_e_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"PTEVALTREAT"))
 DECLARE ot_t_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"OTTREATMENT"))
 DECLARE ot_e_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"OTEVALTREAT"))
 DECLARE st_t_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"STTREATMENT"))
 DECLARE st_e_bed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"STEVALTREATBEDSIDESWALLOW")
  )
 DECLARE st_e_speech_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "STEVALTREATSPEECHLANGUAGECOGNITIVE"))
 DECLARE indx = i4
 DECLARE t_line = vc
 IF (validate(request->batch_selection))
  SET t_record->action_dt_tm = cnvtdatetime(request->ops_date)
  IF ((t_record->action_dt_tm <= 0))
   SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
  ENDIF
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (2))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"W","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"W","E","E")
  SET email_list = trim( $1)
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c,
   nurse_unit n
  PLAN (c
   WHERE c.code_set=220
    AND c.cdf_meaning="NURSEUNIT"
    AND c.display_key IN ("APTU", "C5A", "C6A", "C6B", "CICU",
   "ICU", "PICU", "S1", "S2", "S3",
   "S3ONC", "S3ONC1", "S4", "S4ADO", "S5",
   "S64", "S66", "W3", "W4")
    AND c.active_ind=1)
   JOIN (n
   WHERE n.location_cd=c.code_value
    AND n.active_ind=1)
  ORDER BY c.display_key
  HEAD c.display_key
   t_record->nurse_unit_cnt = (t_record->nurse_unit_cnt+ 1)
   IF (mod(t_record->nurse_unit_cnt,100)=1)
    stat = alterlist(t_record->nurse_unit_qual,(t_record->nurse_unit_cnt+ 99))
   ENDIF
   t_record->nurse_unit_qual[t_record->nurse_unit_cnt].unit_cd = c.code_value
  FOOT REPORT
   stat = alterlist(t_record->nurse_unit_qual,t_record->nurse_unit_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM task_activity ta,
   order_action oa
  PLAN (ta
   WHERE expand(indx,1,t_record->nurse_unit_cnt,ta.location_cd,t_record->nurse_unit_qual[indx].
    unit_cd)
    AND ta.catalog_cd IN (pt_t_cd, pt_e_cd, ot_t_cd, ot_e_cd, st_t_cd,
   st_e_bed_cd, st_e_speech_cd)
    AND ta.task_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND ta.task_dt_tm <= cnvtdatetime(t_record->end_date))
   JOIN (oa
   WHERE oa.order_id=outerjoin(ta.order_id)
    AND oa.order_status_cd=outerjoin(complete_cd))
  ORDER BY ta.task_id
  HEAD ta.task_id
   t_record->task_cnt = (t_record->task_cnt+ 1)
   IF (mod(t_record->task_cnt,1000)=1)
    stat = alterlist(t_record->task_qual,(t_record->task_cnt+ 999))
   ENDIF
   idx = t_record->task_cnt, t_record->task_qual[idx].task_id = ta.task_id, t_record->task_qual[idx].
   loc_cd = ta.location_cd,
   t_record->task_qual[idx].cat_cd = ta.catalog_cd, t_record->task_qual[idx].create_dt_tm = ta
   .task_dt_tm, t_record->task_qual[idx].perform_dt_tm = oa.action_dt_tm,
   t_record->task_qual[idx].task_status_cd = ta.task_status_cd
  FOOT REPORT
   stat = alterlist(t_record->task_qual,t_record->task_cnt)
  WITH orahint("index(ta XIE3TASK_ACTIVITY)")
 ;end select
 SELECT INTO "pt_evals.xls"
  unit = uar_get_code_display(t_record->task_qual[d.seq].loc_cd), task_id = t_record->task_qual[d.seq
  ].task_id
  FROM (dummyt d  WITH seq = t_record->task_cnt)
  PLAN (d
   WHERE (t_record->task_qual[d.seq].cat_cd IN (pt_e_cd, ot_e_cd, st_e_bed_cd, st_e_speech_cd)))
  ORDER BY unit, task_id
  HEAD REPORT
   pt_t = 0, pt_c_t = 0, pt_nc_t = 0,
   ot_t = 0, ot_c_t = 0, ot_nc_t = 0,
   slp_t = 0, slp_c_t = 0, slp_nc_t = 0,
   t_line = "Adult Inpatient PT Eval Completion by Nursing Unit", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q")), col 0,
   t_line, row + 1, t_line = concat("Unit",char(9),"PT Evals Completed Within 24 Hours",char(9),
    "PT Evals Not Completed Within 24 Hours",
    char(9),"OT Evals Completed Within 24 Hours",char(9),"OT Evals Not Completed Within 24 Hours",
    char(9),
    "SLP Evals Completed Within 24 Hours",char(9),"SLP Evals Not Completed Within 24 Hours"),
   col 0, t_line, row + 1
  HEAD unit
   pt_c = 0, pt_nc = 0, ot_c = 0,
   ot_nc = 0, slp_c = 0, slp_nc = 0
  HEAD task_id
   IF ((t_record->task_qual[d.seq].cat_cd=pt_e_cd))
    pt_t = (pt_t+ 1)
    IF (datetimediff(t_record->task_qual[d.seq].perform_dt_tm,t_record->task_qual[d.seq].create_dt_tm,
     3) <= 24)
     pt_c_t = (pt_c_t+ 1), pt_c = (pt_c+ 1)
    ELSE
     pt_nc_t = (pt_nc_t+ 1), pt_nc = (pt_nc+ 1)
    ENDIF
   ELSEIF ((t_record->task_qual[d.seq].cat_cd=ot_e_cd))
    ot_t = (ot_t+ 1)
    IF (datetimediff(t_record->task_qual[d.seq].perform_dt_tm,t_record->task_qual[d.seq].create_dt_tm,
     3) <= 24)
     ot_c_t = (ot_c_t+ 1), ot_c = (ot_c+ 1)
    ELSE
     ot_nc_t = (ot_nc_t+ 1), ot_nc = (ot_nc+ 1)
    ENDIF
   ELSEIF ((((t_record->task_qual[d.seq].cat_cd=st_e_bed_cd)) OR ((t_record->task_qual[d.seq].cat_cd=
   st_e_speech_cd))) )
    slp_t = (slp_t+ 1)
    IF (datetimediff(t_record->task_qual[d.seq].perform_dt_tm,t_record->task_qual[d.seq].create_dt_tm,
     3) <= 24)
     slp_c_t = (slp_c_t+ 1), slp_c = (slp_c+ 1)
    ELSE
     slp_nc_t = (slp_nc_t+ 1), slp_nc = (slp_nc+ 1)
    ENDIF
   ENDIF
  FOOT  unit
   t_line = concat(unit,char(9),trim(cnvtstring(pt_c)),char(9),trim(cnvtstring(pt_nc)),
    char(9),trim(cnvtstring(ot_c)),char(9),trim(cnvtstring(ot_nc)),char(9),
    trim(cnvtstring(slp_c)),char(9),trim(cnvtstring(slp_nc))), col 0, t_line,
   row + 1
  FOOT REPORT
   t_line = concat("Totals:",char(9),trim(cnvtstring(pt_c_t)),char(9),trim(cnvtstring(pt_nc_t)),
    char(9),trim(cnvtstring(ot_c_t)),char(9),trim(cnvtstring(ot_nc_t)),char(9),
    trim(cnvtstring(slp_c_t)),char(9),trim(cnvtstring(slp_nc_t))), col 0, t_line,
   row + 1, t_line = concat(char(9),"PT Compl. Rate:",char(9),trim(cnvtstring(((cnvtreal(pt_c_t)/
      pt_t) * 100))),"%",
    char(9),"OT Compl. Rate:",char(9),trim(cnvtstring(((cnvtreal(ot_c_t)/ ot_t) * 100))),"%",
    char(9),"SLP Compl. Rate:",char(9),trim(cnvtstring(((cnvtreal(slp_c_t)/ slp_t) * 100))),"%"),
   col 0,
   t_line
  WITH nocounter, maxcol = 1000
 ;end select
 SELECT INTO "pt_treatments.xls"
  unit = uar_get_code_display(t_record->task_qual[d.seq].loc_cd), task_id = t_record->task_qual[d.seq
  ].task_id
  FROM (dummyt d  WITH seq = t_record->task_cnt)
  PLAN (d
   WHERE (t_record->task_qual[d.seq].cat_cd IN (pt_t_cd, ot_t_cd, st_t_cd)))
  ORDER BY unit, task_id
  HEAD REPORT
   pt_t = 0, pt_c_t = 0, pt_nc_t = 0,
   ot_t = 0, ot_c_t = 0, ot_nc_t = 0,
   st_t = 0, st_c_t = 0, st_nc_t = 0,
   t_line = "Adult Inpatient PT Treatment Completion by Nursing Unit", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q")), col 0,
   t_line, row + 1, t_line = concat("Unit",char(9),"PT Rx's Completed Within 24 Hours",char(9),
    "PT Rx's Not Completed Within 24 Hours",
    char(9),"OT Rx's Completed Within 24 Hours",char(9),"OT Rx's Not Completed Within 24 Hours",char(
     9),
    "SLP Rx's Completed Within 24 Hours",char(9),"SLP Rx's Not Completed Within 24 Hours"),
   col 0, t_line, row + 1
  HEAD unit
   pt_c = 0, pt_nc = 0, ot_c = 0,
   ot_nc = 0, st_c = 0, st_nc = 0
  HEAD task_id
   IF ((t_record->task_qual[d.seq].cat_cd=pt_t_cd))
    pt_t = (pt_t+ 1)
    IF (datetimediff(t_record->task_qual[d.seq].perform_dt_tm,t_record->task_qual[d.seq].create_dt_tm,
     3) <= 24)
     pt_c_t = (pt_c_t+ 1), pt_c = (pt_c+ 1)
    ELSE
     pt_nc_t = (pt_nc_t+ 1), pt_nc = (pt_nc+ 1)
    ENDIF
   ELSEIF ((t_record->task_qual[d.seq].cat_cd=ot_t_cd))
    ot_t = (ot_t+ 1)
    IF (datetimediff(t_record->task_qual[d.seq].perform_dt_tm,t_record->task_qual[d.seq].create_dt_tm,
     3) <= 24)
     ot_c_t = (ot_c_t+ 1), ot_c = (ot_c+ 1)
    ELSE
     ot_nc_t = (ot_nc_t+ 1), ot_nc = (ot_nc+ 1)
    ENDIF
   ELSEIF ((t_record->task_qual[d.seq].cat_cd=st_t_cd))
    st_t = (st_t+ 1)
    IF (datetimediff(t_record->task_qual[d.seq].perform_dt_tm,t_record->task_qual[d.seq].create_dt_tm,
     3) <= 24)
     st_c_t = (st_c_t+ 1), st_c = (st_c+ 1)
    ELSE
     st_nc_t = (st_nc_t+ 1), st_nc = (st_nc+ 1)
    ENDIF
   ENDIF
  FOOT  unit
   t_line = concat(unit,char(9),trim(cnvtstring(pt_c)),char(9),trim(cnvtstring(pt_nc)),
    char(9),trim(cnvtstring(ot_c)),char(9),trim(cnvtstring(ot_nc)),char(9),
    trim(cnvtstring(st_c)),char(9),trim(cnvtstring(st_nc))), col 0, t_line,
   row + 1
  FOOT REPORT
   t_line = concat("Totals:",char(9),trim(cnvtstring(pt_c_t)),char(9),trim(cnvtstring(pt_nc_t)),
    char(9),trim(cnvtstring(ot_c_t)),char(9),trim(cnvtstring(ot_nc_t)),char(9),
    trim(cnvtstring(st_c_t)),char(9),trim(cnvtstring(st_nc_t))), col 0, t_line,
   row + 1, t_line = concat(char(9),"PT Compl. Rate:",char(9),trim(cnvtstring(((cnvtreal(pt_c_t)/
      pt_t) * 100))),"%",
    char(9),"OT Compl. Rate:",char(9),trim(cnvtstring(((cnvtreal(ot_c_t)/ ot_t) * 100))),"%",
    char(9),"SLP Compl. Rate:",char(9),trim(cnvtstring(((cnvtreal(st_c_t)/ st_t) * 100))),"%"), col
   0,
   t_line
  WITH nocounter, maxcol = 1000
 ;end select
 IF (findfile("pt_evals.xls")=1
  AND findfile("pt_treatments.xls")=1)
  SET subject_line = concat("PT Completion Report ",format(t_record->beg_date,"DD-MMM-YYYY;;Q"),
   " to ",format(t_record->end_date,"DD-MMM-YYYY;;Q"))
  SET dclcom = concat('echo " " | mailx -s "',subject_line,'" ','-a "pt_evals.xls" ',
   '-a "pt_treatments.xls" ',
   email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("pt_evals.xls")
  SET stat = remove("pt_treatments.xls")
 ENDIF
#exit_script
 SET reply->status_data[1].status = "S"
END GO

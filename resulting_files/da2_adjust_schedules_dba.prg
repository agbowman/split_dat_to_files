CREATE PROGRAM da2_adjust_schedules:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Option" = 1
  WITH outdev, adjust_option
 DECLARE adjustopt = i4 WITH protect, noconstant(cnvtint( $ADJUST_OPTION))
 DECLARE hiddenparam = i4 WITH protect, noconstant(0)
 DECLARE errormessage = vc WITH protect, noconstant("")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE emailcount = i4 WITH protect, noconstant(0)
 DECLARE reportcount = i4 WITH protect, noconstant(0)
 DECLARE querycount = i4 WITH protect, noconstant(0)
 DECLARE line_msg = vc WITH noconstant("")
 DECLARE xmlstring = vc WITH protect, noconstant("")
 FREE RECORD qualifiedschedules
 RECORD qualifiedschedules(
   1 batchsched[*]
     2 schedule_id = f8
   1 batchreport[*]
     2 schedule_id = f8
   1 batchquery[*]
     2 schedule_id = f8
 )
 FREE RECORD email_update
 RECORD email_update(
   1 email_update_items[*]
     2 long_text_id = f8
     2 long_text = vc
     2 isexecute = i4
 )
 SET hiddenparam = parameter(3,0)
 IF (hiddenparam=1)
  SET line_msg = "User opted to cancel; no action taken."
  GO TO end_now
 ENDIF
 IF (((adjustopt <= 0) OR (adjustopt > 4)) )
  SET line_msg = concat("User selected an invalid option: ",build(adjustopt))
  GO TO end_now
 ENDIF
 SELECT
  IF (((adjustopt=1) OR (((adjustopt=2) OR (adjustopt=4)) )) )
   WHERE s.active_ind=1
    AND ((cnvtdatetime(sysdate) BETWEEN s.begin_effective_dt_tm AND s.end_effective_dt_tm) OR (s
   .begin_effective_dt_tm >= cnvtdatetime(sysdate)
    AND s.end_effective_dt_tm >= cnvtdatetime(sysdate)))
  ELSEIF (adjustopt=3)
   WHERE s.active_ind=1
  ELSE
  ENDIF
  INTO "nl:"
  s.da_batch_sched_id, s.active_ind, s.da_sched_type_flag
  FROM da_batch_sched s
  HEAD REPORT
   stat = alterlist(qualifiedschedules->batchsched,10), stat = alterlist(qualifiedschedules->
    batchreport,10), stat = alterlist(qualifiedschedules->batchquery,10),
   count = 0, reportcount = 0, querycount = 0
  DETAIL
   count += 1
   IF (mod(count,10)=0)
    stat = alterlist(qualifiedschedules->batchsched,(count+ 10))
   ENDIF
   qualifiedschedules->batchsched[count].schedule_id = s.da_batch_sched_id
   IF (s.da_sched_type_flag=0)
    reportcount += 1
    IF (mod(reportcount,10)=0)
     stat = alterlist(qualifiedschedules->batchreport,(reportcount+ 10))
    ENDIF
    qualifiedschedules->batchreport[reportcount].schedule_id = qualifiedschedules->batchsched[count].
    schedule_id
   ELSEIF (s.da_sched_type_flag=1)
    querycount += 1
    IF (mod(querycount,10)=0)
     stat = alterlist(qualifiedschedules->batchquery,(querycount+ 10))
    ENDIF
    qualifiedschedules->batchquery[querycount].schedule_id = qualifiedschedules->batchsched[count].
    schedule_id
   ENDIF
  FOOT REPORT
   stat = alterlist(qualifiedschedules->batchsched,count), stat = alterlist(qualifiedschedules->
    batchreport,reportcount), stat = alterlist(qualifiedschedules->batchquery,querycount)
  WITH nocounter
 ;end select
 IF (error(errormessage,0) != 0)
  CALL appendmessage(concat("Error when selecting from DA_BATCH_SCHED:",char(13),char(10),
    errormessage))
  GO TO end_now
 ELSE
  CALL appendmessage(concat("Found ",build(size(qualifiedschedules->batchsched,5)),
    " schedules to modify."))
 ENDIF
 IF (((adjustopt=1) OR (adjustopt=4))
  AND size(qualifiedschedules->batchsched,5) > 0)
  UPDATE  FROM da_batch_sched s,
    (dummyt d  WITH seq = size(qualifiedschedules->batchsched,5))
   SET s.end_effective_dt_tm = cnvtdatetime((curdate - 1),curtime3), s.updt_cnt = (s.updt_cnt+ 1), s
    .updt_applctx = reqinfo->updt_applctx,
    s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->
    updt_task
   PLAN (d)
    JOIN (s
    WHERE (s.da_batch_sched_id=qualifiedschedules->batchsched[d.seq].schedule_id)
     AND (qualifiedschedules->batchsched[d.seq].schedule_id > 0))
   WITH nocounter
  ;end update
  IF (error(errormessage,0) != 0)
   CALL appendmessage(concat("Error updating DA_BATCH_SCHED to expire schedules:",char(13),char(10),
     errormessage))
   GO TO end_now
  ELSE
   CALL appendmessage(concat("Successfully expired ",build(size(qualifiedschedules->batchsched,5)),
     " schedules (current and future)."))
   COMMIT
  ENDIF
 ENDIF
 IF (((adjustopt=2) OR (((adjustopt=3) OR (adjustopt=4)) ))
  AND size(qualifiedschedules->batchsched,5) > 0)
  IF (size(qualifiedschedules->batchreport,5) > 0)
   SELECT INTO "nl:"
    r.da_batch_sched_id, r.additional_parameter_txt_id, l.long_text_id,
    l.long_text
    FROM da_batch_report r,
     long_text_reference l,
     (dummyt d  WITH seq = size(qualifiedschedules->batchreport,5))
    PLAN (d)
     JOIN (r
     WHERE (r.da_batch_sched_id=qualifiedschedules->batchreport[d.seq].schedule_id))
     JOIN (l
     WHERE r.additional_parameter_txt_id=l.long_text_id)
    HEAD REPORT
     stat = alterlist(email_update->email_update_items,10), count = 0
    DETAIL
     count += 1
     IF (mod(count,10)=0)
      stat = alterlist(email_update->email_update_items,(count+ 10))
     ENDIF
     email_update->email_update_items[count].long_text_id = l.long_text_id, email_update->
     email_update_items[count].long_text = l.long_text, email_update->email_update_items[count].
     isexecute = 0
    FOOT REPORT
     stat = alterlist(email_update->email_update_items,count)
    WITH nocounter
   ;end select
  ENDIF
  IF (error(errormessage,0) != 0)
   CALL appendmessage(concat("Error encountered when looking up batch reports:",char(13),char(10),
     errormessage))
   GO TO end_now
  ENDIF
  IF (size(qualifiedschedules->batchquery,5) > 0)
   SELECT INTO "nl:"
    q.da_batch_sched_id, q.additional_parameter_txt_id, l.long_text_id,
    l.long_text
    FROM da_batch_query q,
     long_text_reference l,
     (dummyt d  WITH seq = size(qualifiedschedules->batchquery,5))
    PLAN (d)
     JOIN (q
     WHERE (qualifiedschedules->batchquery[d.seq].schedule_id=q.da_batch_sched_id))
     JOIN (l
     WHERE q.additional_parameter_txt_id=l.long_text_id)
    HEAD REPORT
     count = size(email_update->email_update_items,5)
    DETAIL
     IF (size(email_update->email_update_items,5)=count)
      stat = alterlist(email_update->email_update_items,(count+ 10))
     ENDIF
     count += 1, email_update->email_update_items[count].long_text_id = l.long_text_id, email_update
     ->email_update_items[count].long_text = l.long_text,
     email_update->email_update_items[count].isexecute = 0
    FOOT REPORT
     stat = alterlist(email_update->email_update_items,count)
    WITH nocounter
   ;end select
  ENDIF
  IF (error(errormessage,0) != 0)
   CALL appendmessage(concat("Error encountered when looking up batch queries:",char(13),char(10),
     errormessage))
   GO TO end_now
  ENDIF
  CALL appendmessage(concat("Found ",build(size(email_update->email_update_items,5)),
    " batch queries and reports to check for email addresses."))
  SET emailcount = 0
  FOR (count = 1 TO size(email_update->email_update_items,5))
    SET xmlstring = email_update->email_update_items[count].long_text
    SET fstemailidx = findstring("<emails ",xmlstring,1,0)
    IF (fstemailidx=0)
     SET fstemailidx = findstring("<emails>",xmlstring,1,0)
    ENDIF
    SET lstemailidx = findstring("</emails>",xmlstring,1,0)
    IF (fstemailidx > 0
     AND lstemailidx > 0)
     SET tagidx = (lstemailidx+ 8)
     SET len = textlen(xmlstring)
     SET email_update->email_update_items[count].long_text = build2(substring(1,(fstemailidx - 1),
       xmlstring),substring((tagidx+ 1),(len - tagidx),xmlstring))
     SET email_update->email_update_items[count].isexecute = 1
     SET emailcount += 1
    ENDIF
  ENDFOR
  IF (error(errormessage,0) != 0)
   CALL appendmessage(concat("Error encountered when removing email information:",char(13),char(10),
     errormessage))
   GO TO end_now
  ENDIF
  IF (size(email_update->email_update_items,5) > 0)
   UPDATE  FROM long_text_reference ltr,
     (dummyt d  WITH seq = size(email_update->email_update_items,5))
    SET ltr.long_text = email_update->email_update_items[d.seq].long_text, ltr.updt_applctx = reqinfo
     ->updt_applctx, ltr.updt_cnt = (ltr.updt_cnt+ 1),
     ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id = reqinfo->updt_id, ltr.updt_task = reqinfo
     ->updt_task
    PLAN (d)
     JOIN (ltr
     WHERE (ltr.long_text_id=email_update->email_update_items[d.seq].long_text_id)
      AND (email_update->email_update_items[d.seq].long_text_id > 0)
      AND (email_update->email_update_items[d.seq].isexecute=1))
    WITH nocounter
   ;end update
   IF (error(errormessage,0) != 0)
    CALL appendmessage(concat("Error encountered when updating batch query and report parameters:",
      char(13),char(10),errormessage))
    GO TO end_now
   ELSE
    CALL appendmessage(concat("Email information successfully removed from ",build(emailcount),
      " batch queries and/or reports."))
    COMMIT
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE (appendmessage(msg=vc) =vc WITH protect)
   IF (textlen(line_msg) > 0)
    SET line_msg = concat(line_msg,char(13),char(10))
   ENDIF
   SET line_msg = concat(line_msg,msg)
   RETURN(line_msg)
 END ;Subroutine
#end_now
 SELECT INTO  $OUTDEV
  1
  FROM dummyt
  DETAIL
   col 0, line_msg
  WITH nocounter, maxcol = 1000
 ;end select
 FREE RECORD qualifiedschedules
 FREE RECORD email_update
 ROLLBACK
END GO

CREATE PROGRAM bed_imp_sch_slottypes:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 tlist[*]
     2 slot_type = vc
     2 contiguous_ind = i2
     2 interval = i4
     2 def_duration = i4
     2 display_scheme = vc
     2 display_scheme_id = f8
     2 priority = vc
     2 priority_cd = f8
     2 flex_rule = vc
     2 flex_rule_id = f8
     2 dup_ind = i2
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
 SET reply->status_data.status = "F"
 DECLARE log_msg = vc
 DECLARE log_temp = vc
 SET lstat = 0.0
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET nbr_rows = size(requestin->list_0,5)
 CALL echo(build("nbr rows:",nbr_rows))
 SET tcnt = 0
 DECLARE logfilename = vc
 SET logfilename = "schslottype_imp_"
 SET logfilename = concat(logfilename,format(curdate,"MMDDYYYY;;D"),format(curtime,"HHMM;;M"))
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 SET slot_flex_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=16162
    AND c.cdf_meaning="SLOTTYPE")
  DETAIL
   slot_flex_cd = c.code_value
  WITH nocounter
 ;end select
 IF (nbr_rows=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  st_name = trim(requestin->list_0[d.seq].slot_type)
  FROM (dummyt d  WITH seq = nbr_rows)
  PLAN (d
   WHERE trim(requestin->list_0[d.seq].slot_type) > " ")
  HEAD REPORT
   tcnt = 0
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tlist,tcnt), temp->tlist[tcnt].slot_type = trim(requestin
    ->list_0[d.seq].slot_type)
   IF (cnvtupper(requestin->list_0[d.seq].contig_or_discrete)="CONTIG*")
    temp->tlist[tcnt].contiguous_ind = 1, temp->tlist[tcnt].interval = cnvtint(requestin->list_0[d
     .seq].slot_start_time_int)
   ELSE
    temp->tlist[tcnt].contiguous_ind = 0, temp->tlist[tcnt].interval = - (1)
   ENDIF
   temp->tlist[tcnt].def_duration = cnvtint(requestin->list_0[d.seq].default_slot_dur), temp->tlist[
   tcnt].display_scheme = trim(requestin->list_0[d.seq].display_scheme), temp->tlist[tcnt].priority
    = trim(requestin->list_0[d.seq].priority),
   temp->tlist[tcnt].flex_rule = trim(requestin->list_0[d.seq].flex_rule), temp->tlist[tcnt].dup_ind
    = 0, temp->tlist[tcnt].display_scheme_id = 0
  WITH nocounter, check
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   sch_slot_type sst
  PLAN (d)
   JOIN (sst
   WHERE sst.mnemonic_key=cnvtupper(temp->tlist[d.seq].slot_type))
  DETAIL
   temp->tlist[d.seq].dup_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   sch_disp_scheme sds
  PLAN (d
   WHERE (temp->tlist[d.seq].dup_ind=0))
   JOIN (sds
   WHERE sds.mnemonic_key=cnvtupper(temp->tlist[d.seq].display_scheme)
    AND sds.scheme_type_flag=0)
  DETAIL
   temp->tlist[d.seq].display_scheme_id = sds.disp_scheme_id
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   sch_flex_string sfs
  PLAN (d
   WHERE (temp->tlist[d.seq].dup_ind=0))
   JOIN (sfs
   WHERE sfs.mnemonic_key=cnvtupper(temp->tlist[d.seq].flex_rule)
    AND sfs.active_ind=1
    AND sfs.flex_type_cd=slot_flex_cd)
  DETAIL
   temp->tlist[d.seq].flex_rule_id = sfs.sch_flex_id
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   code_value c
  PLAN (d
   WHERE (temp->tlist[d.seq].dup_ind=0))
   JOIN (c
   WHERE c.code_set=23031
    AND c.active_ind=1
    AND c.display_key=cnvtupper(temp->tlist[d.seq].priority))
  DETAIL
   temp->tlist[d.seq].priority_cd = c.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO tcnt)
   IF ((temp->tlist[x].dup_ind != 1))
    IF ((temp->tlist[x].display_scheme_id > 0))
     IF ((temp->tlist[x].priority_cd=0))
      INSERT  FROM sch_slot_type sst
       SET sst.slot_type_id = seq(sched_reference_seq,nextval), sst.version_dt_tm = cnvtdatetime(
         "31-DEC-2100 00:00:00.00"), sst.mnemonic = trim(temp->tlist[x].slot_type),
        sst.mnemonic_key = trim(cnvtupper(temp->tlist[x].slot_type)), sst.description = trim(temp->
         tlist[x].slot_type), sst.info_sch_text_id = 0,
        sst.disp_scheme_id = temp->tlist[x].display_scheme_id, sst.def_duration = temp->tlist[x].
        def_duration, sst.null_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
        sst.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sst.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100 00:00:00.00"), sst.active_ind = 1,
        sst.active_status_cd = active_cd, sst.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        sst.active_status_prsnl_id = 0,
        sst.updt_dt_tm = cnvtdatetime(curdate,curtime3), sst.updt_applctx = 0, sst.updt_id = 0,
        sst.updt_cnt = 0, sst.updt_task = 0, sst.candidate_id = seq(sch_candidate_seq,nextval),
        sst.contiguous_ind = temp->tlist[x].contiguous_ind, sst.sch_flex_id = temp->tlist[x].
        flex_rule_id, sst.interval = temp->tlist[x].interval
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET log_temp = temp->tlist[x].slot_type
       SET log_msg = "Error writing sch_slot_type entry. Slot type not added."
       SET stat = log_message(x)
      ELSE
       SET log_temp = temp->tlist[x].slot_type
       SET log_msg = "Slot type successfully added."
       SET stat = log_message(x)
      ENDIF
     ELSE
      INSERT  FROM sch_slot_type sst
       SET sst.slot_type_id = seq(sched_reference_seq,nextval), sst.version_dt_tm = cnvtdatetime(
         "31-DEC-2100 00:00:00.00"), sst.mnemonic = trim(temp->tlist[x].slot_type),
        sst.mnemonic_key = trim(cnvtupper(temp->tlist[x].slot_type)), sst.description = trim(temp->
         tlist[x].slot_type), sst.info_sch_text_id = 0,
        sst.disp_scheme_id = temp->tlist[x].display_scheme_id, sst.def_duration = temp->tlist[x].
        def_duration, sst.null_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
        sst.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sst.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100 00:00:00.00"), sst.active_ind = 1,
        sst.active_status_cd = active_cd, sst.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        sst.active_status_prsnl_id = 0,
        sst.updt_dt_tm = cnvtdatetime(curdate,curtime3), sst.updt_applctx = 0, sst.updt_id = 0,
        sst.updt_cnt = 0, sst.updt_task = 0, sst.candidate_id = seq(sch_candidate_seq,nextval),
        sst.contiguous_ind = temp->tlist[x].contiguous_ind, sst.priority_cd = temp->tlist[x].
        priority_cd, sst.sch_flex_id = temp->tlist[x].flex_rule_id,
        sst.interval = temp->tlist[x].interval
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET log_temp = temp->tlist[x].slot_type
       SET log_msg = "Error writing sch_slot_type entry. Slot type not added."
       SET stat = log_message(x)
      ELSE
       SET log_temp = temp->tlist[x].slot_type
       SET log_msg = "Slot type successfully added."
       SET stat = log_message(x)
      ENDIF
     ENDIF
    ELSE
     SET log_temp = temp->tlist[x].slot_type
     SET log_msg = concat("Display scheme ",trim(temp->tlist[x].display_scheme),
      " not found. Slot type not added.")
     SET stat = log_message(x)
    ENDIF
   ELSE
    SET log_temp = temp->tlist[x].slot_type
    SET log_msg = "Slot type already exists on sch_slot_type table. Slot type not added."
    SET stat = log_message(x)
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE log_message(t)
  SELECT INTO value(logfilename)
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    log_temp, col 40, log_msg,
    row + 1
   WITH nocounter, append
  ;end select
  RETURN(1.0)
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_SCH_SLOTTYPES","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 CALL echo("==========================================================")
 CALL echo(build("==  LOG FILE CREATED IN CCLUSERDIR:",logfilename))
 CALL echo("==========================================================")
END GO

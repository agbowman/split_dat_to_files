CREATE PROGRAM bed_imp_sch_res:dba
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
     2 resource = vc
     2 booking_limit = i4
     2 dup_ind = i2
 )
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
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
 SET logfilename = "schres_imp_"
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
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbr_rows)
  PLAN (d
   WHERE trim(requestin->list_0[d.seq].resource) > " ")
  ORDER BY requestin->list_0[d.seq].resource
  HEAD REPORT
   tcnt = 0, res_name = fillstring(100," ")
  DETAIL
   IF (trim(requestin->list_0[d.seq].resource) != res_name)
    tcnt = (tcnt+ 1), stat = alterlist(temp->tlist,tcnt), temp->tlist[tcnt].resource = trim(requestin
     ->list_0[d.seq].resource),
    res_name = trim(requestin->list_0[d.seq].resource), temp->tlist[tcnt].booking_limit = cnvtint(
     requestin->list_0[d.seq].booking_limit)
   ENDIF
  WITH nocounter, check
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   sch_resource sr
  PLAN (d)
   JOIN (sr
   WHERE sr.mnemonic_key=cnvtupper(temp->tlist[d.seq].resource))
  DETAIL
   temp->tlist[d.seq].dup_ind = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO tcnt)
   IF ((temp->tlist[x].dup_ind != 1))
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 14231
    SET request_cv->cd_value_list[1].display = temp->tlist[x].resource
    SET request_cv->cd_value_list[1].description = temp->tlist[x].resource
    SET request_cv->cd_value_list[1].definition = temp->tlist[x].resource
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    SET next_code = 0.0
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET next_code = reply_cv->qual[1].code_value
     INSERT  FROM sch_resource sr
      SET sr.resource_cd = next_code, sr.version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), sr
       .res_type_flag = 1,
       sr.mnemonic = temp->tlist[x].resource, sr.mnemonic_key = cnvtupper(temp->tlist[x].resource),
       sr.description = temp->tlist[x].resource,
       sr.null_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), sr.candidate_id = seq(
        sch_candidate_seq,nextval), sr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       sr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), sr.active_ind = 1, sr
       .active_status_cd = active_cd,
       sr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), sr.active_status_prsnl_id = 0, sr
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       sr.updt_applctx = 0, sr.updt_id = 0, sr.updt_cnt = 0,
       sr.updt_task = 0, sr.quota = temp->tlist[x].booking_limit
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET log_temp = temp->tlist[x].resource
      SET log_msg = "Error writing sch_resource entry. Resource not added."
      SET stat = log_message(x)
     ELSE
      SET log_temp = temp->tlist[x].resource
      SET log_msg = "Resource successfully added."
      SET stat = log_message(x)
     ENDIF
    ELSE
     SET log_temp = temp->tlist[x].resource
     SET log_msg = "Unable to add code value, possible dup. Resource not added."
     SET stat = log_message(x)
    ENDIF
   ELSE
    SET log_temp = temp->tlist[x].resource
    SET log_msg = "Resource already exists on sch_resource table. Resource not added."
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_SCH_RES","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 CALL echo("==========================================================")
 CALL echo(build("==  LOG FILE CREATED IN CCLUSERDIR:",logfilename))
 CALL echo("==========================================================")
END GO

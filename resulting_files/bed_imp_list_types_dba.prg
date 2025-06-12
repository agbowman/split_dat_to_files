CREATE PROGRAM bed_imp_list_types:dba
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
 FREE SET reply_cv
 RECORD reply_cv(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE title_txt = vc
 DECLARE error_txt = vc
 DECLARE req_cnt = i4
 DECLARE i_name = vc
 DECLARE i_name_key = vc
 DECLARE i_parent = vc
 DECLARE i_parent_key = vc
 DECLARE i_wait_time = vc
 DECLARE active_cd = f8
 DECLARE t_cdval = f8
 DECLARE skip_flag = i4
 DECLARE cv_34 = f8
 DECLARE cv_3394 = f8
 DECLARE cv_18529 = f8
 DECLARE add_cnt = i4
 DECLARE error_cnt = i4
 SET title_txt = "Correspondence List Types Import"
 SET logfilename = "CCLUSERDIR:bed_imp_list_type.log"
 SELECT INTO value(logfilename)
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, title_txt, row + 2,
   col 2, "Name", col + 50,
   "Wait Time", col + 7, "Status",
   row + 1
  WITH nocounter
 ;end select
 SET reply->status_data.status = "F"
 SET req_cnt = 0
 SET req_cnt = size(requestin->list_0,5)
 SET error_cnt = 0
 SET error_txt = fillstring(60," ")
 SET t_cdval = 0
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
 SET i_name = fillstring(40," ")
 SET i_wait_time = fillstring(40," ")
 FOR (ii = 1 TO req_cnt)
   SET skip_flag = 0
   SET i_name = requestin->list_0[ii].name
   SET i_name_key = cnvtupper(cnvtalphanum(i_name))
   SET i_parent = requestin->list_0[ii].parent
   SET i_parent_key = cnvtupper(cnvtalphanum(requestin->list_0[ii].parent))
   SET i_wait_time = requestin->list_0[ii].wait_time
   IF (((i_name <= " ") OR (((i_parent <= " ") OR (i_wait_time <= " ")) )) )
    SET skip_flag = 10
   ENDIF
   IF (skip_flag=0)
    SET t_cdval = 0.0
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=34
       AND cv.display_key=i_parent_key)
     DETAIL
      t_cdval = cv.code_value
     WITH nocounter
    ;end select
    IF (t_cdval=0.0)
     SET skip_flag = 1
    ELSE
     SET cv_34 = t_cdval
    ENDIF
    SET t_cdval = 0.0
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=3394
       AND cv.display_key=i_parent_key)
     DETAIL
      t_cdval = cv.code_value
     WITH nocounter
    ;end select
    IF (t_cdval=0.0)
     SET skip_flag = 2
    ELSE
     SET cv_3394 = t_cdval
    ENDIF
    SET t_cdval = 0.0
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=18529
       AND cv.display_key=i_name_key)
     DETAIL
      t_cdval = cv.code_value
     WITH nocounter
    ;end select
    IF (t_cdval > 0.0)
     SET skip_flag = 3
    ENDIF
   ENDIF
   IF (skip_flag=0)
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 18529
    SET request_cv->cd_value_list[1].display = i_name
    SET request_cv->cd_value_list[1].description = i_name
    SET request_cv->cd_value_list[1].definition = i_name
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((((reply_cv->status_data.status != "S")) OR ((reply_cv->qual[1].code_value <= 0))) )
     SET error_flag = "Y"
     SET error_msg = concat("Error inserting code_value 18529 row for: ",i_name,".")
     SET skip_flag = 6
    ELSE
     SET cv_18529 = reply_cv->qual[1].code_value
    ENDIF
   ENDIF
   IF (skip_flag=0)
    INSERT  FROM code_value_group cvg
     SET cvg.parent_code_value = cv_34, cvg.child_code_value = cv_18529, cvg.updt_applctx = reqinfo->
      updt_applctx,
      cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvg.updt_cnt = 0, cvg.updt_id = reqinfo->
      updt_id,
      cvg.updt_task = reqinfo->updt_task, cvg.collation_seq = 0, cvg.code_set = 34
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET skip_flag = 7
    ENDIF
    INSERT  FROM code_value_group cvg
     SET cvg.parent_code_value = cv_3394, cvg.child_code_value = cv_18529, cvg.updt_applctx = reqinfo
      ->updt_applctx,
      cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvg.updt_cnt = 0, cvg.updt_id = reqinfo->
      updt_id,
      cvg.updt_task = reqinfo->updt_task, cvg.collation_seq = 0, cvg.code_set = 3394
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET skip_flag = 8
    ENDIF
   ENDIF
   IF (skip_flag=0)
    IF (i_wait_time > " ")
     INSERT  FROM code_value_extension cve
      SET cve.code_value = cv_18529, cve.field_name = "PASWAITTIME", cve.code_set = 18529,
       cve.updt_applctx = reqinfo->updt_applctx, cve.updt_id = reqinfo->updt_id, cve.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task, cve.field_type = 1,
       cve.field_value = i_wait_time
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET skip_flag = 9
     ENDIF
    ENDIF
   ENDIF
   IF (skip_flag=0)
    SELECT INTO value(logfilename)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      col 2, "Successfully added:", col + 1,
      requestin->list_0[ii].name, col + 1, "to",
      col + 1, requestin->list_0[ii].parent, col + 5,
      requestin->list_0[ii].wait_time, row + 1
     WITH nocounter, append
    ;end select
   ELSE
    CASE (skip_flag)
     OF 1:
      SET error_txt = "No display found on code set 34 for: "
     OF 2:
      SET error_txt = "No display found on code set 3394 for: "
     OF 3:
      SET error_txt = "Duplicate display found on code set 18529 for: "
     OF 6:
      SET error_txt = "Error inserting new code value for code set 18529 for: "
     OF 7:
      SET error_txt = "Error creating code value group for code set 34 for: "
     OF 8:
      SET error_txt = "Error creating code value group for code set 3394 for: "
     OF 9:
      SET error_txt = "Error adding code_value_extension for :"
     OF 10:
      SET error_txt = "Blank name, parent, or wait time for: "
    ENDCASE
    SELECT INTO value(logfilename)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      col 2, "Error: Skipped row because ", col + 1,
      error_txt, col + 1, requestin->list_0[ii].name,
      row + 1
     WITH nocounter, append
    ;end select
   ENDIF
   IF (skip_flag=0)
    SET add_cnt = (add_cnt+ 1)
   ELSE
    SET error_cnt = (error_cnt+ 1)
   ENDIF
 ENDFOR
 SELECT INTO value(logfilename)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row + 2, col 1, "Total Number of Rows Added:",
   add_cnt"####", row + 2, col 1,
   "Total Number of Rows Skipped: ", error_cnt"####", row + 2,
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, title_txt, col + 1,
   "Finished"
  WITH nocounter, append
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 CALL echo("==========================================================")
 CALL echo(build("==  LOG FILE CREATED IN ",logfilename))
 CALL echo("==========================================================")
END GO

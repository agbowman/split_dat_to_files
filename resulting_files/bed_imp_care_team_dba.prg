CREATE PROGRAM bed_imp_care_team:dba
 RECORD requestin(
   1 list_0[*]
     2 treatment_function = vc
     2 care_team = vc
     2 person_id = vc
 )
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
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
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE logfilename = vc WITH noconstant(""), protect
 SET logfilename = "br_care_team_imp.log"
 DECLARE contrib_code = f8 WITH noconstant(0.0), protect
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=89
    AND cv.cdf_meaning="POWERCHART"
    AND cv.active_ind=1)
  DETAIL
   contrib_code = cv.code_value
  WITH nocounter
 ;end select
 DECLARE auth_code = f8 WITH noconstant(0.0), protect
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH"
    AND cv.active_ind=1)
  DETAIL
   auth_code = cv.code_value
  WITH nocounter
 ;end select
 DECLARE active_code = f8 WITH noconstant(0.0), protect
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1)
  DETAIL
   active_code = cv.code_value
  WITH nocounter
 ;end select
 DECLARE careteam_code = f8 WITH noconstant(0.0), protect
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=19189
    AND cv.cdf_meaning="CARETEAM"
    AND cv.display_key="CARETEAM"
    AND cv.active_ind=1)
  DETAIL
   careteam_code = cv.code_value
  WITH nocounter
 ;end select
 DECLARE prov_group_code = f8 WITH noconstant(0.0), protect
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=19189
    AND cv.cdf_meaning="DCPTEAM"
    AND cv.display_key="PROVIDERGROUP"
    AND cv.active_ind=1)
  DETAIL
   prov_group_code = cv.code_value
  WITH nocounter
 ;end select
 SET begin_dt_tm = cnvtdatetime(curdate,curtime3)
 SELECT INTO value(logfilename)
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
   col + 1, "Bedrock Care Team Import Start", row + 1,
   col_tf = 0, col_ct = (col_tf+ 45), col_pid = (col_ct+ 45),
   col_rsn = (col_pid+ 25)
  DETAIL
   row + 2, col col_tf, "TREATMENT FUNCTION",
   col col_ct, "CARE TEAM", col col_pid,
   "PERSON ID", col col_rsn, "FAILURE REASON",
   row + 1
  WITH nocounter, format = variable, noformfeed,
   maxcol = 170, maxrow = 1
 ;end select
 DECLARE fail_cnt = i4 WITH noconstant(0), protect
 DECLARE overall_fail = i2 WITH noconstant(0), protect
 DECLARE tf_code = f8 WITH noconstant(0.0), protect
 DECLARE tf_error_ind = i2 WITH noconstant(0), protect
 SET req_cnt = size(requestin->list_0,5)
 DECLARE persn_id = f8 WITH noconstant(0.0), protect
 FOR (x = 1 TO req_cnt)
   DECLARE tf_fail_txt = vc WITH noconstant(""), protect
   DECLARE tf_prsnl_grp_id = f8 WITH noconstant(0.0), protect
   DECLARE ct_cs357_code = f8 WITH noconstant(0.0), protect
   IF ((requestin->list_0[x].treatment_function > " "))
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=357
       AND cv.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,requestin->list_0[x].
          treatment_function))))
       AND (cv.display=requestin->list_0[x].treatment_function))
     HEAD REPORT
      found = 0
     DETAIL
      IF (cv.active_ind=1)
       IF (found=0)
        found = 1, tf_code = cv.code_value, tf_error_ind = 0
       ELSE
        tf_fail_txt = "Multiple rows found for treatment function.", tf_error_ind = 1
       ENDIF
      ELSE
       IF (found=0)
        tf_fail_txt = "Existing treatment function is inactive on cs 357.", tf_error_ind = 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tf_fail_txt = "Treatment function was not found on cs 357."
     SET tf_error_ind = 1
    ENDIF
   ELSE
    SET tf_fail_txt = "Treatment function was not defined."
    SET tf_error_ind = 1
   ENDIF
   IF (tf_error_ind=0)
    SELECT INTO "nl:"
     FROM prsnl_group p
     PLAN (p
      WHERE p.prsnl_group_type_cd=tf_code
       AND (p.prsnl_group_name=requestin->list_0[x].treatment_function)
       AND p.prsnl_group_class_cd=prov_group_code
       AND p.active_ind=1)
     HEAD REPORT
      tf_cnt = 0
     DETAIL
      tf_cnt = (tf_cnt+ 1), tf_prsnl_grp_id = p.prsnl_group_id
     FOOT REPORT
      IF (tf_cnt > 1)
       tf_fail_txt = "Multiple provider groups found for treament function.", tf_error_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tf_fail_txt = "Treatment function's provider group not found."
     SET tf_error_ind = 1
    ENDIF
   ENDIF
   IF (tf_error_ind=1)
    SELECT INTO value(logfilename)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      row + 1, col 0, requestin->list_0[x].treatment_function,
      col 45, requestin->list_0[x].care_team, col 90,
      requestin->list_0[x].person_id, col 115, tf_fail_txt
     WITH nocounter, append, format = variable,
      noformfeed, maxcol = 350, maxrow = 1
    ;end select
    SET fail_cnt = (fail_cnt+ 1)
    SET overall_fail = 1
   ELSE
    SET cs34_code = 0.0
    SET cs34_error_ind = 0
    DECLARE cs34_fail_txt = vc
    SELECT INTO "nl:"
     FROM code_value_group cvg
     PLAN (cvg
      WHERE cvg.parent_code_value=tf_code
       AND cvg.code_set=357)
     DETAIL
      cs34_code = cvg.child_code_value
     WITH nocounter
    ;end select
    IF (curqual > 1)
     SET cs34_code = 1
     SET cs34_fail_txt = "Multiple code set 34 values grouped to treatment function."
    ELSEIF (cs34_code=0)
     SET cs34_error_ind = 1
     SET cs34_fail_txt = "Unable to find code set 34 value grouped to treatment function."
    ENDIF
    IF (cs34_error_ind=1)
     SELECT INTO value(logfilename)
      FROM (dummyt d  WITH seq = 1)
      DETAIL
       row + 1, col 0, requestin->list_0[x].treatment_function,
       col 45, requestin->list_0[x].care_team, col 90,
       requestin->list_0[x].person_id, col 115, cs34_fail_txt
      WITH nocounter, append, format = variable,
       noformfeed, maxcol = 350, maxrow = 1
     ;end select
     SET fail_cnt = (fail_cnt+ 1)
     SET overall_fail = 1
    ELSE
     SET cs100006_code = 0.0
     SET prsnl_grp_id = 0.0
     SET ct_error_ind = 0
     DECLARE ct_fail_txt = vc
     IF ((requestin->list_0[x].care_team > " "))
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=100006
         AND cv.display=trim(substring(1,40,requestin->list_0[x].care_team)))
       DETAIL
        cs100006_code = cv.code_value
        IF (cv.active_ind=0)
         ct_fail_txt = "Existing care team is inactive on cs 100006.", ct_error_ind = 1
        ENDIF
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=357
         AND cv.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,requestin->list_0[x].care_team
            )))))
       HEAD REPORT
        found = 0
       DETAIL
        IF (cv.active_ind=1)
         IF (found=0)
          found = 1, ct_cs357_code = cv.code_value, ct_error_ind = 0
         ELSE
          ct_fail_txt = "Multiple cs 357 rows found for care team.", ct_error_ind = 1
         ENDIF
        ELSE
         IF (found=0)
          ct_fail_txt = "Existing care team is inactive on cs 357.", ct_error_ind = 1
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET request_cv->cd_value_list[1].action_flag = 1
       SET request_cv->cd_value_list[1].code_set = 357
       SET request_cv->cd_value_list[1].cdf_meaning = "CARETEAM"
       SET request_cv->cd_value_list[1].display = requestin->list_0[x].care_team
       SET request_cv->cd_value_list[1].description = requestin->list_0[x].care_team
       SET request_cv->cd_value_list[1].definition = requestin->list_0[x].care_team
       SET request_cv->cd_value_list[1].active_ind = 1
       SET request_cv->cd_value_list[1].collation_seq = 0
       SET trace = recpersist
       EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
       IF ((((reply_cv->status_data.status != "S")) OR ((reply_cv->qual[1].code_value <= 0))) )
        SET error_flag = "Y"
        SET error_msg = concat("Error inserting code_value row for cs 357: ",trim(requestin->list_0[x
          ].care_team),".")
        GO TO exit_script
       ENDIF
       SET ct_cs357_code = reply_cv->qual[1].code_value
      ENDIF
      SELECT INTO "nl:"
       FROM prsnl_group p
       PLAN (p
        WHERE p.prsnl_group_type_cd=ct_cs357_code
         AND (p.prsnl_group_name=requestin->list_0[x].care_team)
         AND p.prsnl_group_class_cd=careteam_code
         AND p.active_ind=1)
       DETAIL
        prsnl_grp_id = p.prsnl_group_id
       WITH nocounter
      ;end select
     ELSE
      SET ct_fail_txt = "Care team is not defined."
      SET ct_error_ind = 1
     ENDIF
     IF (ct_error_ind=0)
      IF (cs100006_code=0)
       SET request_cv->cd_value_list[1].action_flag = 1
       SET request_cv->cd_value_list[1].code_set = 100006
       SET request_cv->cd_value_list[1].cdf_meaning = ""
       SET request_cv->cd_value_list[1].display = requestin->list_0[x].care_team
       SET request_cv->cd_value_list[1].description = requestin->list_0[x].care_team
       SET request_cv->cd_value_list[1].definition = requestin->list_0[x].care_team
       SET request_cv->cd_value_list[1].active_ind = 1
       SET request_cv->cd_value_list[1].collation_seq = 0
       SET trace = recpersist
       EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
       IF ((((reply_cv->status_data.status != "S")) OR ((reply_cv->qual[1].code_value <= 0))) )
        SET error_flag = "Y"
        SET error_msg = concat("Error inserting code_value row for cs 100006: ",trim(requestin->
          list_0[x].care_team),".")
        GO TO exit_script
       ENDIF
       SET cs100006_code = reply_cv->qual[1].code_value
      ENDIF
      IF (prsnl_grp_id=0
       AND error_flag != "Y")
       SELECT INTO "nl:"
        number = seq(prsnl_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         prsnl_grp_id = cnvtreal(number)
        WITH format, counter
       ;end select
       SET ierrcode = 0
       INSERT  FROM prsnl_group p
        SET p.prsnl_group_id = prsnl_grp_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
         p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
         reqinfo->updt_task,
         p.active_ind = 1, p.active_status_cd = active_code, p.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         p.data_status_cd = auth_code, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
         .contributor_system_cd = contrib_code,
         p.prsnl_group_type_cd = ct_cs357_code, p.prsnl_group_name = requestin->list_0[x].care_team,
         p.prsnl_group_desc = requestin->list_0[x].care_team,
         p.service_resource_cd = 0, p.prsnl_group_class_cd = careteam_code, p.prsnl_group_name_key =
         cnvtupper(requestin->list_0[x].care_team),
         p.prsnl_group_name_key_nls = null
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET error_msg = concat("Failure inserting prsnl_group rows: ",serrmsg)
        GO TO exit_script
       ENDIF
      ENDIF
      SET group_ind = 0
      SELECT INTO "nl:"
       FROM code_value_group cvg
       PLAN (cvg
        WHERE cvg.parent_code_value=cs34_code
         AND cvg.child_code_value=cs100006_code
         AND cvg.code_set=100006)
       DETAIL
        group_ind = 1
       WITH nocounter
      ;end select
      IF (group_ind=0
       AND error_flag != "Y")
       SET ierrcode = 0
       INSERT  FROM code_value_group cvg
        SET cvg.parent_code_value = cs34_code, cvg.child_code_value = cs100006_code, cvg
         .collation_seq = 0,
         cvg.code_set = 100006, cvg.updt_applctx = reqinfo->updt_applctx, cvg.updt_cnt = 0,
         cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvg.updt_id = reqinfo->updt_id, cvg
         .updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET error_msg = concat("Failure grouping 34/100006: ",serrmsg)
        GO TO exit_script
       ENDIF
      ENDIF
      SET group_ind = 0
      SELECT INTO "nl:"
       FROM code_value_group cvg
       PLAN (cvg
        WHERE cvg.parent_code_value=cs100006_code
         AND cvg.child_code_value=ct_cs357_code
         AND cvg.code_set=357)
       DETAIL
        group_ind = 1
       WITH nocounter
      ;end select
      IF (group_ind=0
       AND error_flag != "Y")
       SET ierrcode = 0
       INSERT  FROM code_value_group cvg
        SET cvg.parent_code_value = cs100006_code, cvg.child_code_value = ct_cs357_code, cvg
         .collation_seq = 0,
         cvg.code_set = 357, cvg.updt_applctx = reqinfo->updt_applctx, cvg.updt_cnt = 0,
         cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvg.updt_id = reqinfo->updt_id, cvg
         .updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET error_msg = concat("Failure grouping 100006/357: ",serrmsg)
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
     IF (((ct_error_ind=1) OR (error_flag="Y")) )
      DECLARE err_txt = vc
      IF (error_flag="Y")
       SET err_txt = error_msg
       SET error_flag = "N"
      ELSE
       SET err_txt = ct_fail_txt
      ENDIF
      SELECT INTO value(logfilename)
       FROM (dummyt d  WITH seq = 1)
       DETAIL
        row + 1, col 0, requestin->list_0[x].treatment_function,
        col 45, requestin->list_0[x].care_team, col 90,
        requestin->list_0[x].person_id, col 115, err_txt
       WITH nocounter, append, format = variable,
        noformfeed, maxcol = 170, maxrow = 1
      ;end select
      SET fail_cnt = (fail_cnt+ 1)
      SET overall_fail = 1
     ELSE
      SET persn_id = cnvtreal(requestin->list_0[x].person_id)
      DECLARE persn_fail_txt = vc
      IF (persn_id > 0)
       SET persn_error_ind = 0
       SELECT INTO "nl:"
        FROM prsnl p
        PLAN (p
         WHERE p.person_id=persn_id)
        DETAIL
         IF (p.active_ind=0)
          persn_fail_txt = "Person ID is inactive on the prsnl table.", persn_error_ind = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET persn_fail_txt = "Person ID not found on the prsnl table."
        SET persn_error_ind = 1
       ENDIF
      ELSE
       SET persn_fail_txt = "Person ID was not defined."
       SET persn_error_ind = 1
      ENDIF
      IF (persn_error_ind=0)
       SET found = 0
       SELECT INTO "nl:"
        FROM prsnl_group_reltn p
        PLAN (p
         WHERE p.prsnl_group_id=prsnl_grp_id
          AND p.person_id=persn_id)
        DETAIL
         found = 1
        WITH nocounter
       ;end select
       IF (found=0)
        INSERT  FROM prsnl_group_reltn p
         SET p.prsnl_group_reltn_id = seq(prsnl_seq,nextval), p.prsnl_group_id = prsnl_grp_id, p
          .prsnl_group_r_cd = 0,
          p.person_id = persn_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
          p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
          reqinfo->updt_task,
          p.active_ind = 1, p.active_status_cd = active_code, p.active_status_dt_tm = cnvtdatetime(
           curdate,curtime3),
          p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
           curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          p.data_status_cd = auth_code, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
          .data_status_prsnl_id = reqinfo->updt_id,
          p.contributor_system_cd = contrib_code, p.primary_ind = 0
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET error_msg = concat("Failure inserting 1st prsnl_group_reltn row: ",serrmsg)
         GO TO exit_script
        ENDIF
       ENDIF
       SET found = 0
       SELECT INTO "nl:"
        FROM prsnl_group_reltn p
        PLAN (p
         WHERE p.prsnl_group_id=tf_prsnl_grp_id
          AND p.person_id=persn_id)
        DETAIL
         found = 1
        WITH nocounter
       ;end select
       IF (found=0)
        INSERT  FROM prsnl_group_reltn p
         SET p.prsnl_group_reltn_id = seq(prsnl_seq,nextval), p.prsnl_group_id = tf_prsnl_grp_id, p
          .prsnl_group_r_cd = 0,
          p.person_id = persn_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
          p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
          reqinfo->updt_task,
          p.active_ind = 1, p.active_status_cd = active_code, p.active_status_dt_tm = cnvtdatetime(
           curdate,curtime3),
          p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
           curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          p.data_status_cd = auth_code, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
          .data_status_prsnl_id = reqinfo->updt_id,
          p.contributor_system_cd = contrib_code, p.primary_ind = 0
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET error_msg = concat("Failure inserting 2nd prsnl_group_reltn row: ",serrmsg)
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      IF (((persn_error_ind=1) OR (error_flag="Y")) )
       DECLARE err_txt = vc
       IF (error_flag="Y")
        SET err_txt = error_msg
        SET error_flag = "N"
       ELSE
        SET err_txt = persn_fail_txt
       ENDIF
       SELECT INTO value(logfilename)
        FROM (dummyt d  WITH seq = 1)
        DETAIL
         row + 1, col 0, requestin->list_0[x].treatment_function,
         col 45, requestin->list_0[x].care_team, col 90,
         requestin->list_0[x].person_id, col 115, err_txt
        WITH nocounter, append, format = variable,
         noformfeed, maxcol = 170, maxrow = 1
       ;end select
       SET fail_cnt = (fail_cnt+ 1)
       SET overall_fail = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (overall_fail=1)
    ROLLBACK
    SET overall_fail = 0
   ELSE
    COMMIT
   ENDIF
 ENDFOR
 SET end_dt_tm = cnvtdatetime(curdate,curtime3)
 SELECT INTO value(logfilename)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row + 5, col 0, "Number of failures: ",
   fail_cnt, row + 5, end_dt_tm"dd-mmm-yyyy;;d",
   "-", end_dt_tm"hh:mm:ss;;m", col + 1,
   "Bedrock Care Team Import End"
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 170, maxrow = 1
 ;end select
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 CALL echo("==========================================================")
 CALL echo(build("==  LOG FILE CREATED IN CCLUSERDIR:",logfilename))
 CALL echo("==========================================================")
END GO

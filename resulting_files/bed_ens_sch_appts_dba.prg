CREATE PROGRAM bed_ens_sch_appts:dba
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET 14230_cd = 0.0
 SET 14249_cd = 0.0
 SET acnt = 0
 DECLARE active_cd = f8 WITH public, noconstant(0.0)
 DECLARE inactive_cd = f8 WITH public, noconstant(0.0)
 DECLARE required_cd = f8 WITH public, noconstant(0.0)
 DECLARE 16109_optional_cd = f8 WITH public, noconstant(0.0)
 DECLARE apptbook_cd = f8 WITH public, noconstant(0.0)
 DECLARE 23000_optional_cd = f8 WITH public, noconstant(0.0)
 DECLARE 23000_required_cd = f8 WITH public, noconstant(0.0)
 DECLARE notdelete_cd = f8 WITH public, noconstant(0.0)
 DECLARE minutes_cd = f8 WITH public, noconstant(0.0)
 SET acnt = size(request->appt_types,5)
 IF (acnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1)
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE"
    AND cv.active_ind=1)
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=16109
    AND cv.cdf_meaning="REQUIRED"
    AND cv.active_ind=1)
  DETAIL
   required_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=16109
    AND cv.cdf_meaning="OPTIONAL"
    AND cv.active_ind=1)
  DETAIL
   16109_optional_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=23026
    AND cv.cdf_meaning="APPTBOOK"
    AND cv.active_ind=1)
  DETAIL
   apptbook_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=23000
    AND cv.cdf_meaning="OPTIONAL"
    AND cv.active_ind=1)
  DETAIL
   23000_optional_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=23000
    AND cv.cdf_meaning="REQUIRED"
    AND cv.active_ind=1)
  DETAIL
   23000_required_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=23013
    AND cv.cdf_meaning="NOTDELETE"
    AND cv.active_ind=1)
  DETAIL
   notdelete_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=54
    AND cv.cdf_meaning="MINUTES"
    AND cv.active_ind=1)
  DETAIL
   minutes_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO acnt)
   SET 14230_cd = 0
   SET 14249_cd = 0
   DECLARE appt_type_disp = vc
   SET add_appt_type = 1
   SET activate_appt_type = 0
   SET ocnt = 0
   FREE SET ord
   RECORD ord(
     1 qual[*]
       2 cd = f8
       2 duration = i4
   )
   IF ((request->appt_types[x].action_flag=1))
    IF ((request->appt_types[x].code_value > 0))
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE (c.code_value=request->appt_types[x].code_value))
      DETAIL
       appt_type_disp = c.display, add_appt_type = 0, 14230_cd = c.code_value
      WITH nocounter
     ;end select
    ENDIF
    IF ((request->appt_types[x].appt_type_id > 0)
     AND appt_type_disp=" ")
     SELECT INTO "nl:"
      FROM br_sched_appt_type b
      PLAN (b
       WHERE (b.appt_type_id=request->appt_types[x].appt_type_id))
      DETAIL
       appt_type_disp = b.appt_type_display
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=14230
        AND c.display=appt_type_disp)
      DETAIL
       IF (c.active_ind=1)
        add_appt_type = 0
       ELSE
        activate_appt_type = 1, add_appt_type = 0
       ENDIF
       14230_cd = c.code_value
      WITH nocounter
     ;end select
    ENDIF
    SELECT INTO "nl:"
     FROM br_sched_appt_type_ord b,
      order_catalog o
     PLAN (b
      WHERE (b.appt_type_id=request->appt_types[x].appt_type_id))
      JOIN (o
      WHERE o.concept_cki=b.concept_cki
       AND o.active_ind=1)
     DETAIL
      ocnt = (ocnt+ 1), stat = alterlist(ord->qual,ocnt), ord->qual[ocnt].cd = o.catalog_cd,
      ord->qual[ocnt].duration = b.duration
     WITH nocounter
    ;end select
    IF (curqual=0
     AND 14230_cd > 0)
     SELECT INTO "nl:"
      FROM sch_order_appt s
      PLAN (s
       WHERE s.appt_type_cd=14230_cd)
      DETAIL
       ocnt = (ocnt+ 1), stat = alterlist(ord->qual,ocnt), ord->qual[ocnt].cd = s.catalog_cd
      WITH nocounter
     ;end select
    ENDIF
    IF (add_appt_type=1)
     SET stat = add_appt_type(x)
     SET stat = add_appt_ord(x)
     SET stat = add_loc_ord(x)
    ENDIF
    IF (activate_appt_type=1)
     SET stat = updt_appt_type(x)
     SET stat = add_appt_ord(x)
     SET stat = add_loc_ord(x)
    ENDIF
    SET updt_syn = 0
    SELECT INTO "nl:"
     FROM sch_appt_syn s
     PLAN (s
      WHERE s.appt_type_cd=14230_cd
       AND s.primary_ind=1)
     DETAIL
      14249_cd = s.appt_synonym_cd
      IF (s.active_ind=0)
       updt_syn = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_appt_syn(x)
    ENDIF
    IF (updt_syn=1)
     SET stat = updt_appt_syn(x)
    ENDIF
    SET updt_product = 0
    SELECT INTO "nl:"
     FROM sch_appt_product s
     PLAN (s
      WHERE s.appt_type_cd=14230_cd)
     DETAIL
      IF (s.active_ind=0)
       updt_product = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_appt_product(x)
    ENDIF
    IF (updt_product=1)
     SET stat = updt_appt_product(x)
    ENDIF
    SET updt_loc = 0
    SELECT INTO "nl:"
     FROM sch_appt_loc s
     PLAN (s
      WHERE s.appt_type_cd=14230_cd
       AND (s.location_cd=request->dept_code_value))
     DETAIL
      IF (s.active_ind=0)
       updt_loc = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_appt_loc(x)
     IF (add_appt_type=0)
      SET stat = add_loc_ord(x)
     ENDIF
    ENDIF
    IF (updt_loc=1)
     SET stat = updt_appt_loc(x)
     IF (add_appt_type=0)
      SET stat = add_loc_ord(x)
     ENDIF
    ENDIF
   ELSEIF ((request->appt_types[x].action_flag=3))
    SET 14230_cd = request->appt_types[x].code_value
    SELECT INTO "nl:"
     FROM sch_appt_syn s
     PLAN (s
      WHERE s.appt_type_cd=14230_cd
       AND s.primary_ind=1
       AND s.active_ind=1)
     DETAIL
      14249_cd = s.appt_synonym_cd
     WITH nocounter
    ;end select
    SET stat = del_appt_type(x)
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE add_appt_type(x)
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].active_ind = 1
   SET request_cv->cd_value_list[1].code_set = 14230
   SET request_cv->cd_value_list[1].cdf_meaning = ""
   SET request_cv->cd_value_list[1].display = appt_type_disp
   SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(appt_type_disp))
   SET request_cv->cd_value_list[1].definition = appt_type_disp
   SET request_cv->cd_value_list[1].description = appt_type_disp
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET 14230_cd = reply_cv->qual[1].code_value
   ELSE
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   INSERT  FROM sch_appt_type s
    SET s.appt_type_cd = 14230_cd, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.oe_format_id = 0,
     s.description = appt_type_disp, s.info_sch_text_id = 0, s.null_dt_tm = cnvtdatetime(
      "31-DEC-2100"),
     s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime), s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(curdate,
      curtime),
     s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
     .updt_applctx = reqinfo->updt_applctx,
     s.updt_id = reqinfo->updt_id, s.updt_cnt = 0, s.updt_task = reqinfo->updt_task,
     s.appt_type_flag = 0, s.person_accept_cd = required_cd, s.person_accept_meaning = "REQUIRED",
     s.recur_cd = 16109_optional_cd, s.recur_meaning = "OPTIONAL", s.grp_resource_cd = 0,
     s.grp_prompt_cd = 0, s.grp_prompt_meaning = null
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_appt_syn(x)
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].active_ind = 1
   SET request_cv->cd_value_list[1].code_set = 14249
   SET request_cv->cd_value_list[1].cdf_meaning = ""
   SET request_cv->cd_value_list[1].display = appt_type_disp
   SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(appt_type_disp))
   SET request_cv->cd_value_list[1].definition = appt_type_disp
   SET request_cv->cd_value_list[1].description = appt_type_disp
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET 14249_cd = reply_cv->qual[1].code_value
   ELSE
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   INSERT  FROM sch_appt_syn s
    SET s.appt_synonym_cd = 14249_cd, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.mnemonic =
     appt_type_disp,
     s.mnemonic_key = cnvtupper(appt_type_disp), s.allow_selection_flag = 1, s.info_sch_text_id = 0,
     s.appt_type_cd = 14230_cd, s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.oe_format_id = 0,
     s.primary_ind = 1, s.order_sentence_id = 0, s.candidate_id = seq(sch_candidate_seq,nextval),
     s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), s.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), s.active_ind = 1,
     s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s
     .active_status_prsnl_id = reqinfo->updt_id,
     s.updt_dt_tm = cnvtdatetime(curdate,curtime), s.updt_applctx = reqinfo->updt_applctx, s.updt_id
      = reqinfo->updt_id,
     s.updt_cnt = 0, s.updt_task = reqinfo->updt_task, s.appt_type_flag = 0,
     s.mnemonic_key_nls = null
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_appt_product(x)
   SET ierrcode = 0
   INSERT  FROM sch_appt_product s
    SET s.appt_type_cd = 14230_cd, s.product_cd = apptbook_cd, s.version_dt_tm = cnvtdatetime(
      "31-DEC-2100"),
     s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,nextval), s
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
     s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd =
     active_cd,
     s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s.active_status_prsnl_id = reqinfo->
     updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime),
     s.updt_applctx = reqinfo->updt_applctx, s.updt_id = reqinfo->updt_id, s.updt_cnt = 0,
     s.updt_task = reqinfo->updt_task, s.product_meaning = "APPTBOOK"
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_appt_loc(x)
   SET ierrcode = 0
   INSERT  FROM sch_appt_loc s
    SET s.appt_type_cd = 14230_cd, s.location_cd = request->dept_code_value, s.version_dt_tm =
     cnvtdatetime("31-DEC-2100"),
     s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,nextval), s
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
     s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd =
     active_cd,
     s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s.active_status_prsnl_id = reqinfo->
     updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime),
     s.updt_applctx = reqinfo->updt_applctx, s.updt_id = reqinfo->updt_id, s.updt_cnt = 0,
     s.updt_task = reqinfo->updt_task, s.res_list_id = 0, s.sch_flex_id = 0,
     s.grp_res_list_id = 0
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updt_appt_type(x)
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].active_ind = 1
   SET request_cv->cd_value_list[1].code_value = 14230_cd
   SET request_cv->cd_value_list[1].code_set = 14230
   SET request_cv->cd_value_list[1].cdf_meaning = ""
   SET request_cv->cd_value_list[1].display = appt_type_disp
   SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(appt_type_disp))
   SET request_cv->cd_value_list[1].definition = appt_type_disp
   SET request_cv->cd_value_list[1].description = appt_type_disp
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET 14230_cd = reply_cv->qual[1].code_value
   ELSE
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   UPDATE  FROM sch_appt_type s
    SET s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(
      curdate,curtime),
     s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
     .updt_applctx = reqinfo->updt_applctx,
     s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task
    PLAN (s
     WHERE s.appt_type_cd=14230_cd)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updt_appt_syn(x)
   SET request_cv->cd_value_list[1].action_flag = 2
   SET request_cv->cd_value_list[1].active_ind = 1
   SET request_cv->cd_value_list[1].code_value = 14249_cd
   SET request_cv->cd_value_list[1].code_set = 14249
   SET request_cv->cd_value_list[1].cdf_meaning = ""
   SET request_cv->cd_value_list[1].display = appt_type_disp
   SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(appt_type_disp))
   SET request_cv->cd_value_list[1].definition = appt_type_disp
   SET request_cv->cd_value_list[1].description = appt_type_disp
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET 14249_cd = reply_cv->qual[1].code_value
   ELSE
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   UPDATE  FROM sch_appt_syn s
    SET s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(
      curdate,curtime),
     s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
     .updt_applctx = reqinfo->updt_applctx,
     s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task
    PLAN (s
     WHERE s.appt_synonym_cd=14249_cd)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updt_appt_product(x)
   SET ierrcode = 0
   UPDATE  FROM sch_appt_product s
    SET s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(
      curdate,curtime),
     s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
     .updt_applctx = reqinfo->updt_applctx,
     s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task
    PLAN (s
     WHERE s.appt_type_cd=14230_cd)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updt_appt_loc(x)
   SET ierrcode = 0
   UPDATE  FROM sch_appt_loc s
    SET s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(
      curdate,curtime),
     s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
     .updt_applctx = reqinfo->updt_applctx,
     s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task
    PLAN (s
     WHERE s.appt_type_cd=14230_cd
      AND (s.location_cd=request->dept_code_value))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_appt_ord(x)
   FOR (y = 1 TO ocnt)
     SET ord_seq = 0
     SET ord_found = 0
     SET activate_ord = 0
     SELECT INTO "nl:"
      FROM sch_order_appt s
      PLAN (s
       WHERE (s.catalog_cd=ord->qual[y].cd)
        AND s.appt_type_cd=14230_cd)
      DETAIL
       ord_found = 1
       IF (s.active_ind=0)
        activate_ord = 1
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM sch_order_appt s
      PLAN (s
       WHERE (s.catalog_cd=ord->qual[y].cd))
      ORDER BY s.display_seq_nbr
      DETAIL
       ord_seq = s.display_seq_nbr
      WITH nocounter
     ;end select
     IF (ord_found=0)
      SET ierrcode = 0
      INSERT  FROM sch_order_appt s
       SET s.catalog_cd = ord->qual[y].cd, s.appt_type_cd = 14230_cd, s.version_dt_tm = cnvtdatetime(
         "31-dec-2100 00:00:00.00"),
        s.seq_nbr = 0, s.proc_spec_cd = 23000_optional_cd, s.proc_spec_meaning = "OPTIONAL",
        s.sch_flex_id = 0, s.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), s.candidate_id =
        seq(sch_candidate_seq,nextval),
        s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
         "31-dec-2100 00:00:00.00"), s.active_ind = 1,
        s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s
        .active_status_prsnl_id = reqinfo->updt_id,
        s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_applctx = reqinfo->updt_applctx, s
        .updt_id = reqinfo->updt_id,
        s.updt_cnt = 0, s.updt_task = reqinfo->updt_task, s.del_appt_cd = notdelete_cd,
        s.del_appt_meaning = "NOTDELETE", s.display_seq_nbr = (ord_seq+ 1), s.event_concurrent_ind =
        0,
        s.child_appt_type_cd = 0
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
     IF (activate_ord=1)
      SET ierrcode = 0
      UPDATE  FROM sch_order_appt s
       SET s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(
         curdate,curtime),
        s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
        .updt_applctx = reqinfo->updt_applctx,
        s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task
       PLAN (s
        WHERE (s.catalog_cd=ord->qual[y].cd)
         AND s.appt_type_cd=14230_cd)
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
     SET duration_found = 0
     SET activate_duration = 0
     SELECT INTO "nl:"
      FROM sch_order_duration s
      PLAN (s
       WHERE (s.catalog_cd=ord->qual[y].cd)
        AND s.location_cd=0)
      DETAIL
       duration_found = 1
       IF (s.active_ind=0)
        activate_duration = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (duration_found=0)
      SET ierrcode = 0
      INSERT  FROM sch_order_duration s
       SET s.catalog_cd = ord->qual[y].cd, s.location_cd = 0, s.seq_nbr = 0,
        s.sch_flex_id = 0, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.setup_units = 0,
        s.setup_units_cd = minutes_cd, s.setup_units_meaning = "MINUTES", s.duration_units = ord->
        qual[y].duration,
        s.duration_units_cd = minutes_cd, s.duration_units_meaning = "MINUTES", s.cleanup_units = 0,
        s.cleanup_units_cd = minutes_cd, s.cleanup_units_meaning = "MINUTES", s.offset_type_cd = 0,
        s.offset_type_meaning = null, s.offset_beg_units = 0, s.offset_beg_units_cd = 0,
        s.offset_beg_units_meaning = null, s.offset_end_units = 0, s.offset_end_units_cd = 0,
        s.offset_end_units_meaning = null, s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id
         = seq(sch_candidate_seq,nextval),
        s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), s.end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100"), s.active_ind = 1,
        s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s
        .active_status_prsnl_id = reqinfo->updt_id,
        s.updt_dt_tm = cnvtdatetime(curdate,curtime), s.updt_applctx = reqinfo->updt_applctx, s
        .updt_id = reqinfo->updt_id,
        s.updt_cnt = 0, s.updt_task = reqinfo->updt_task, s.arrival_units = 0,
        s.arrival_units_cd = minutes_cd, s.arrival_units_meaning = "MINUTES", s.recovery_units = 0,
        s.recovery_units_cd = minutes_cd, s.recovery_units_meaning = "MINUTES"
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
     IF (activate_duration=1)
      SET ierrcode = 0
      UPDATE  FROM sch_order_duration s
       SET s.duration_units = ord->qual[y].duration, s.duration_units_cd = minutes_cd, s
        .duration_units_meaning = "MINUTES",
        s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(
         curdate,curtime),
        s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
        .updt_applctx = reqinfo->updt_applctx,
        s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task
       PLAN (s
        WHERE (s.catalog_cd=ord->qual[y].cd)
         AND s.location_cd=0)
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   SET ord_cnt = 0
   SELECT INTO "nl:"
    FROM sch_order_appt s
    PLAN (s
     WHERE s.appt_type_cd=14230_cd
      AND s.active_ind=1)
    DETAIL
     ord_cnt = (ord_cnt+ 1)
    WITH nocounter
   ;end select
   IF (ord_cnt=1)
    UPDATE  FROM sch_order_appt s
     SET s.proc_spec_cd = 23000_required_cd, s.proc_spec_meaning = "REQUIRED", s.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      s.updt_applctx = reqinfo->updt_applctx, s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt
      + 1),
      s.updt_task = reqinfo->updt_task
     PLAN (s
      WHERE s.appt_type_cd=14230_cd
       AND s.active_ind=1)
     WITH nocounter
    ;end update
   ENDIF
   IF (ord_cnt > 1)
    UPDATE  FROM sch_order_appt s
     SET s.proc_spec_cd = 23000_optional_cd, s.proc_spec_meaning = "OPTIONAL", s.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      s.updt_applctx = reqinfo->updt_applctx, s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt
      + 1),
      s.updt_task = reqinfo->updt_task
     PLAN (s
      WHERE s.appt_type_cd=14230_cd)
     WITH nocounter
    ;end update
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_loc_ord(x)
  FOR (y = 1 TO ocnt)
    SET loc_found = 0
    SET activate_loc = 0
    SELECT INTO "nl:"
     FROM sch_order_loc s
     PLAN (s
      WHERE (s.catalog_cd=ord->qual[y].cd)
       AND (s.location_cd=request->dept_code_value))
     DETAIL
      loc_found = 1
      IF (s.active_ind=0)
       activate_loc = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (loc_found=0)
     SET ierrcode = 0
     INSERT  FROM sch_order_loc s
      SET s.catalog_cd = ord->qual[y].cd, s.location_cd = request->dept_code_value, s.version_dt_tm
        = cnvtdatetime("31-DEC-2100"),
       s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,nextval), s
       .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
       s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd =
       active_cd,
       s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s.active_status_prsnl_id = reqinfo->
       updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime),
       s.updt_applctx = reqinfo->updt_applctx, s.updt_id = reqinfo->updt_id, s.updt_cnt = 0,
       s.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = "Y"
      GO TO exit_script
     ENDIF
    ENDIF
    IF (activate_loc=0)
     SET ierrcode = 0
     UPDATE  FROM sch_order_loc s
      SET s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(
        curdate,curtime),
       s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
       .updt_applctx = reqinfo->updt_applctx,
       s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task
      PLAN (s
       WHERE (s.catalog_cd=ord->qual[y].cd)
        AND (s.location_cd=request->dept_code_value))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = "Y"
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
  RETURN(1)
 END ;Subroutine
 SUBROUTINE del_appt_type(x)
   SET inactivate_ind = 1
   SET scnt = 0
   SELECT INTO "nl:"
    FROM sch_appt_loc s
    PLAN (s
     WHERE s.appt_type_cd=14230_cd
      AND s.active_ind=1)
    DETAIL
     scnt = (scnt+ 1)
    WITH nocounter
   ;end select
   IF (scnt > 1)
    SET ierrcode = 0
    DELETE  FROM sch_appt_loc s
     WHERE s.appt_type_cd=14230_cd
      AND (s.location_cd=request->dept_code_value)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
    SET inactivate_ind = 0
   ENDIF
   IF (inactivate_ind=1)
    SET request_cv->cd_value_list[1].action_flag = 3
    SET request_cv->cd_value_list[1].active_ind = 0
    SET request_cv->cd_value_list[1].code_value = 14230_cd
    SET request_cv->cd_value_list[1].code_set = 14230
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_value=14230_cd)
     DETAIL
      request_cv->cd_value_list[1].cdf_meaning = c.cdf_meaning, request_cv->cd_value_list[1].display
       = c.display, request_cv->cd_value_list[1].display_key = c.display_key,
      request_cv->cd_value_list[1].description = c.description
     WITH nocounter
    ;end select
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET 14230_cd = reply_cv->qual[1].code_value
    ELSE
     SET failed = "Y"
     GO TO exit_script
    ENDIF
    SET request_cv->cd_value_list[1].action_flag = 3
    SET request_cv->cd_value_list[1].active_ind = 0
    SET request_cv->cd_value_list[1].code_value = 14249_cd
    SET request_cv->cd_value_list[1].code_set = 14249
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_value=14249_cd)
     DETAIL
      request_cv->cd_value_list[1].cdf_meaning = c.cdf_meaning, request_cv->cd_value_list[1].display
       = c.display, request_cv->cd_value_list[1].display_key = c.display_key,
      request_cv->cd_value_list[1].description = c.description
     WITH nocounter
    ;end select
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET 14249_cd = reply_cv->qual[1].code_value
    ELSE
     SET failed = "Y"
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM sch_appt_type s
     SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_dt_tm = cnvtdatetime(
       curdate,curtime),
      s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
      .updt_id = reqinfo->updt_id,
      s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
      updt_applctx
     PLAN (s
      WHERE s.appt_type_cd=14230_cd)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM sch_appt_syn s
     SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_dt_tm = cnvtdatetime(
       curdate,curtime),
      s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
      .updt_id = reqinfo->updt_id,
      s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
      updt_applctx
     PLAN (s
      WHERE s.appt_synonym_cd=14249_cd)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM sch_appt_product s
     SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_dt_tm = cnvtdatetime(
       curdate,curtime),
      s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
      .updt_id = reqinfo->updt_id,
      s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
      updt_applctx
     PLAN (s
      WHERE s.appt_type_cd=14230_cd)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

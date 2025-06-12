CREATE PROGRAM bed_ens_rli_cd_value:dba
 RECORD reply(
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
 DECLARE build_wherestr(aidx=i4) = null
 DECLARE insert_cd_value(aidx=i4) = null
 DECLARE update_cd_value(aidx=i4) = null
 DECLARE get_next_seq(seq_name=vc) = f8
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE req_cnt = i4 WITH public, noconstant(size(request->cd_value_list,5))
 DECLARE xvar = i4 WITH public, noconstant(0)
 DECLARE add_access_ind = i2 WITH public, noconstant(0)
 DECLARE chg_access_ind = i2 WITH public, noconstant(0)
 DECLARE del_access_ind = i2 WITH public, noconstant(0)
 DECLARE active = f8 WITH public, noconstant(0.0)
 DECLARE inactive = f8 WITH public, noconstant(0.0)
 DECLARE auth = f8 WITH public, noconstant(0.0)
 DECLARE unauth = f8 WITH public, noconstant(0.0)
 DECLARE wherestr = vc WITH public, noconstant(" ")
 DECLARE dup_ind = i2 WITH public, noconstant(0)
 DECLARE old_active_ind = i2 WITH public, noconstant(0)
 DECLARE new_cd_value = f8 WITH public, noconstant(0.0)
 DECLARE errmsg = vc WITH public, noconstant(fillstring(132," "))
 DECLARE display_key = vc WITH public, noconstant(" ")
 DECLARE dup_cnt = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,req_cnt)
 SET reply->curqual = req_cnt
 SET add_access_ind = 1
 SET chg_access_ind = 1
 IF ((reqdata->active_status_cd <= 0.0))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="ACTIVE"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    active = cv.code_value
   WITH nocounter
  ;end select
 ELSE
  SET active = reqdata->active_status_cd
 ENDIF
 IF ((reqdata->inactive_status_cd <= 0.0))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="INACTIVE"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    inactive = cv.code_value
   WITH nocounter
  ;end select
 ELSE
  SET inactive = reqdata->inactive_status_cd
 ENDIF
 IF ((reqdata->data_status_cd <= 0.0))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=8
     AND cv.cdf_meaning="AUTH"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    auth = cv.code_value
   WITH nocounter
  ;end select
 ELSE
  SET auth = reqdata->data_status_cd
 ENDIF
 IF (unauth <= 0.0)
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=8
     AND cv.cdf_meaning="UNAUTH"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    unauth = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 FOR (xvar = 1 TO req_cnt)
   IF ((request->cd_value_list[xvar].action_flag=0))
    SET reply->qual[xvar].code_value = request->cd_value_list[xvar].code_value
   ELSE
    IF (validate(request->cd_value_list[xvar].display_key,"") > " ")
     SET display_key = trim(substring(1,40,request->cd_value_list[xvar].display_key))
    ELSE
     SET display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->cd_value_list[xvar].
         display))))
    ENDIF
    CALL build_wherestr(xvar)
    CASE (request->cd_value_list[xvar].action_flag)
     OF 1:
      CALL insert_cd_value(xvar)
     OF 2:
      CALL update_cd_value(xvar)
     OF 3:
      CALL inactivate_cd_value(xvar)
     ELSE
      SET failed = "T"
      SET stat = alterlist(reply->qual,xvar)
      SET reply->qual[xvar].status = 0
      SET reply->error_msg = build("Could not recognize"," action_flag:",request->cd_value_list[xvar]
       .action_flag,".")
      SET reply->qual[xvar].code_value = request->cd_value_list[xvar].code_value
      GO TO exit_script
    ENDCASE
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE build_wherestr(aidx)
   SET wherestr = fillstring(255," ")
   DECLARE cv_parse = cv
   IF (curclientid > 0)
    SELECT INTO "nl:"
     cvs.active_ind_dup_ind, cvs.add_access_ind, cvs.chg_access_ind,
     cvs.del_access_ind, cvs.cdf_meaning_dup_ind, cvs.display_dup_ind,
     cvs.display_key_dup_ind, cvs.definition_dup_ind
     FROM code_value_set cvs
     WHERE (cvs.code_set=request->cd_value_list[aidx].code_set)
     DETAIL
      IF (cvs.del_access_ind=1)
       del_access_ind = 1
      ENDIF
      IF (cvs.active_ind_dup_ind=1)
       IF ((((request->cd_value_list[aidx].active_ind > 1)) OR ((request->cd_value_list[aidx].
       active_ind < 0))) )
        failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
        reply->error_msg = "Active indicator must be valid"
       ELSE
        IF (wherestr > " ")
         wherestr = concat(wherestr," and cv.active_ind = ",trim(cnvtstring(request->cd_value_list[
            aidx].active_ind)))
        ELSE
         wherestr = concat("cv.active_ind = ",trim(cnvtstring(request->cd_value_list[aidx].active_ind
            )))
        ENDIF
       ENDIF
      ENDIF
      IF (cvs.cdf_meaning_dup_ind=1)
       IF (wherestr > " ")
        IF (trim(substring(1,12,request->cd_value_list[aidx].cdf_meaning)) > " ")
         wherestr = concat(wherestr," and cv.cdf_meaning = ",'"',request->cd_value_list[aidx].
          cdf_meaning,'"')
        ELSE
         failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
         reply->error_msg = "CDF Meaning must be valid"
        ENDIF
       ELSE
        IF (trim(substring(1,12,request->cd_value_list[aidx].cdf_meaning)) > " ")
         wherestr = concat("cv.cdf_meaning = ",'"',request->cd_value_list[aidx].cdf_meaning,'"')
        ELSE
         failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
         reply->error_msg = "CDF Meaning must be valid"
        ENDIF
       ENDIF
      ENDIF
      IF (cvs.display_dup_ind=1)
       IF ( NOT (trim(substring(1,40,request->cd_value_list[aidx].display)) > " "))
        failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
        reply->error_msg = "Display must be valid"
       ELSE
        IF (wherestr > " ")
         wherestr = concat(wherestr," and cv.display = ",'"',request->cd_value_list[aidx].display,'"'
          )
        ELSE
         wherestr = concat("cv.display = ",'"',request->cd_value_list[aidx].display,'"')
        ENDIF
       ENDIF
      ENDIF
      IF (cvs.display_key_dup_ind=1)
       IF ( NOT (display_key > " "))
        failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
        reply->error_msg = "Display_key must be valid"
       ELSE
        IF (wherestr > " ")
         wherestr = concat(wherestr," and cv.display_key = display_key")
        ELSE
         wherestr = concat("cv.display_key = display_key")
        ENDIF
       ENDIF
      ENDIF
      IF (cvs.definition_dup_ind=1)
       IF ( NOT (trim(request->cd_value_list[aidx].definition,3) > " "))
        failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
        reply->error_msg = "Definition must be valid"
       ELSE
        IF (wherestr > " ")
         wherestr = concat(wherestr," and cv.definition = ",'"',request->cd_value_list[aidx].
          definition,'"')
        ELSE
         wherestr = concat("cv.definition = ",'"',request->cd_value_list[aidx].definition,'"')
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     cvs.active_ind_dup_ind, cvs.add_access_ind, cvs.chg_access_ind,
     cvs.del_access_ind, cvs.cdf_meaning_dup_ind, cvs.display_dup_ind,
     cvs.display_key_dup_ind, cvs.definition_dup_ind
     FROM code_value_set cvs
     WHERE (cvs.code_set=request->cd_value_list[aidx].code_set)
     DETAIL
      IF (cvs.del_access_ind=1)
       del_access_ind = 1
      ENDIF
      IF (cvs.active_ind_dup_ind=1)
       IF ((((request->cd_value_list[aidx].active_ind > 1)) OR ((request->cd_value_list[aidx].
       active_ind < 0))) )
        failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
        reply->error_msg = "Active indicator must be valid"
       ELSE
        IF (wherestr > " ")
         wherestr = concat(wherestr," and cv.active_ind = ",trim(cnvtstring(request->cd_value_list[
            aidx].active_ind)))
        ELSE
         wherestr = concat("cv.active_ind = ",trim(cnvtstring(request->cd_value_list[aidx].active_ind
            )))
        ENDIF
       ENDIF
      ENDIF
      IF (cvs.cdf_meaning_dup_ind=1)
       IF (wherestr > " ")
        IF (trim(substring(1,12,request->cd_value_list[aidx].cdf_meaning)) > " ")
         wherestr = concat(wherestr," and cv.cdf_meaning = ",'"',request->cd_value_list[aidx].
          cdf_meaning,'"')
        ELSE
         failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
         reply->error_msg = "CDF Meaning must be valid"
        ENDIF
       ELSE
        IF (trim(substring(1,12,request->cd_value_list[aidx].cdf_meaning)) > " ")
         wherestr = concat("cv.cdf_meaning = ",'"',request->cd_value_list[aidx].cdf_meaning,'"')
        ELSE
         failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
         reply->error_msg = "CDF Meaning must be valid"
        ENDIF
       ENDIF
      ENDIF
      IF (cvs.display_dup_ind=1)
       IF ( NOT (trim(substring(1,40,request->cd_value_list[aidx].display)) > " "))
        failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
        reply->error_msg = "Display must be valid"
       ELSE
        IF (wherestr > " ")
         wherestr = concat(wherestr," and cv.display = ",'"',request->cd_value_list[aidx].display,'"'
          )
        ELSE
         wherestr = concat("cv.display = ",'"',request->cd_value_list[aidx].display,'"')
        ENDIF
       ENDIF
      ENDIF
      IF (cvs.display_key_dup_ind=1)
       IF ( NOT (display_key > " "))
        failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
        reply->error_msg = "Display_key must be valid"
       ELSE
        IF (wherestr > " ")
         wherestr = concat(wherestr," and cv.display_key = display_key")
        ELSE
         wherestr = concat("cv.display_key = display_key")
        ENDIF
       ENDIF
      ENDIF
      IF (cvs.definition_dup_ind=1)
       IF ( NOT (trim(request->cd_value_list[aidx].definition,3) > " "))
        failed = "T", stat = alterlist(reply->qual,aidx), reply->qual[aidx].status = 0,
        reply->error_msg = "Definition must be valid"
       ELSE
        IF (wherestr > " ")
         wherestr = concat(wherestr," and cv.definition = ",'"',request->cd_value_list[aidx].
          definition,'"')
        ELSE
         wherestr = concat("cv.definition = ",'"',request->cd_value_list[aidx].definition,'"')
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (failed="T")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_cd_value(aidx)
   IF (add_access_ind=0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    SET reply->error_msg = concat("Code value could not be ",
     "inserted because this code set does not allow inserts.")
    GO TO exit_script
   ENDIF
   IF (wherestr > " ")
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     PLAN (cv
      WHERE parser(wherestr)
       AND (cv.code_set=request->cd_value_list[aidx].code_set))
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET failed = "T"
     SET stat = alterlist(reply->qual,aidx)
     SET reply->qual[aidx].status = 0
     SET reply->error_msg = concat("Code value could not be ",
      "inserted because this code value violates a dup indicator for ","this code set.")
     GO TO exit_script
    ENDIF
   ENDIF
   SET new_cd_value = get_next_seq("REFERENCE_SEQ")
   INSERT  FROM code_value cv
    SET cv.active_dt_tm =
     IF ((request->cd_value_list[aidx].active_ind=1)) cnvtdatetime(curdate,curtime3)
     ELSE null
     ENDIF
     , cv.active_ind = request->cd_value_list[aidx].active_ind, cv.active_status_prsnl_id = reqinfo->
     updt_id,
     cv.active_type_cd =
     IF ((request->cd_value_list[aidx].active_ind=1)) active
     ELSE inactive
     ENDIF
     , cv.begin_effective_dt_tm =
     IF ((request->cd_value_list[aidx].begin_effective_dt_tm <= 0)) cnvtdatetime(curdate,curtime3)
     ELSE cnvtdatetime(request->cd_value_list[aidx].begin_effective_dt_tm)
     ENDIF
     , cv.cdf_meaning =
     IF ((request->cd_value_list[aidx].cdf_meaning='""')) null
     ELSE trim(cnvtupper(substring(1,12,request->cd_value_list[aidx].cdf_meaning)),3)
     ENDIF
     ,
     cv.code_set = request->cd_value_list[aidx].code_set, cv.code_value = new_cd_value, cv
     .collation_seq =
     IF ((request->cd_value_list[aidx].collation_seq <= 0)) 0
     ELSE request->cd_value_list[aidx].collation_seq
     ENDIF
     ,
     cv.concept_cki =
     IF ((request->cd_value_list[aidx].concept_cki='""')) null
     ELSE trim(request->cd_value_list[aidx].concept_cki,3)
     ENDIF
     , cv.cki =
     IF ((request->cd_value_list[aidx].cki > " ")) request->cd_value_list[aidx].cki
     ENDIF
     , cv.data_status_cd = auth,
     cv.data_status_dt_tm = cnvtdatetime(curdate,curtime3), cv.data_status_prsnl_id = reqinfo->
     updt_id, cv.definition =
     IF ((request->cd_value_list[aidx].definition='""')) null
     ELSE trim(request->cd_value_list[aidx].definition,3)
     ENDIF
     ,
     cv.description =
     IF ((request->cd_value_list[aidx].description='""')) null
     ELSE trim(substring(1,60,request->cd_value_list[aidx].description),3)
     ENDIF
     , cv.display =
     IF ((request->cd_value_list[aidx].display='""')) null
     ELSE trim(substring(1,40,request->cd_value_list[aidx].display),3)
     ENDIF
     , cv.display_key =
     IF (display_key='""') null
     ELSE display_key
     ENDIF
     ,
     cv.end_effective_dt_tm =
     IF ((request->cd_value_list[aidx].end_effective_dt_tm <= 0)) cnvtdatetime("31-DEC-2100")
     ELSE cnvtdatetime(request->cd_value_list[aidx].end_effective_dt_tm)
     ENDIF
     , cv.inactive_dt_tm =
     IF ((request->cd_value_list[aidx].active_ind=0)) cnvtdatetime(curdate,curtime3)
     ELSE null
     ENDIF
     , cv.updt_applctx = reqinfo->updt_applctx,
     cv.updt_cnt = 0, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
     cv.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET errorcode = error(errmsg,0)
   IF (errorcode != 0)
    SET reply->qual[aidx].status = 0
    SET reply->qual[aidx].error_num = errorcode
    CALL echo(build("error = ",cnvtstring(errorcode)))
    SET reply->error_msg = errmsg
    SET reply->qual[aidx].code_value = 0.0
    SET reply->status_data.status = "F"
    GO TO exit_script
   ELSE
    SET reply->qual[aidx].status = curqual
    SET reply->qual[aidx].error_num = 0
    SET reply->qual[aidx].error_msg = ""
    SET reply->qual[aidx].code_value = new_cd_value
    SET reply->status_data.status = "S"
   ENDIF
   SELECT INTO "nl:"
    cv.cki
    FROM code_value cv
    PLAN (cv
     WHERE (cv.code_set=request->cd_value_list[aidx].code_set)
      AND (cv.code_value=reply->qual[aidx].code_value)
      AND (reply->qual[aidx].code_value > 0.0))
    DETAIL
     reply->qual[aidx].cki = cv.cki
    WITH nocounter
   ;end select
   IF ((reply->status_data.status="F"))
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE update_cd_value(aidx)
   IF (chg_access_ind=0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    SET reply->error_msg = concat("Code value could not be ",
     "updated because this code set does not allow updates.")
    GO TO exit_script
   ENDIF
   IF (wherestr > " ")
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     PLAN (cv
      WHERE parser(wherestr)
       AND (cv.code_set=request->cd_value_list[aidx].code_set))
     HEAD REPORT
      dup_ind = 0, dup_cnt = 0
     DETAIL
      dup_cnt = (dup_cnt+ 1)
      IF ((cv.code_value=request->cd_value_list[aidx].code_value))
       dup_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (((curqual > 0
     AND dup_ind=0) OR (dup_cnt > 1
     AND dup_ind=1)) )
     SET failed = "T"
     SET stat = alterlist(reply->qual,aidx)
     SET reply->qual[aidx].status = 0
     SET reply->error_msg = concat("Code value could not be ",
      "updated because this code value violates a dup indicator for ","this code set.")
     GO TO exit_script
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    PLAN (cv
     WHERE (cv.code_value=request->cd_value_list[aidx].code_value)
      AND (cv.code_set=request->cd_value_list[aidx].code_set))
    DETAIL
     old_active_ind = cv.active_ind
    WITH nocounter
   ;end select
   UPDATE  FROM code_value cv
    SET cv.active_dt_tm =
     IF ((request->cd_value_list[aidx].active_ind != old_active_ind)
      AND (request->cd_value_list[aidx].active_ind=1)) cnvtdatetime(curdate,curtime3)
     ELSEIF ((request->cd_value_list[aidx].active_ind != old_active_ind)
      AND (request->cd_value_list[aidx].active_ind=0)) null
     ELSE cv.active_dt_tm
     ENDIF
     , cv.active_ind = request->cd_value_list[aidx].active_ind, cv.active_status_prsnl_id =
     IF ((request->cd_value_list[aidx].active_ind != old_active_ind)) reqinfo->updt_id
     ELSE cv.active_status_prsnl_id
     ENDIF
     ,
     cv.active_type_cd =
     IF ((request->cd_value_list[aidx].active_ind=1)) active
     ELSE inactive
     ENDIF
     , cv.begin_effective_dt_tm =
     IF ((request->cd_value_list[aidx].begin_effective_dt_tm <= 0)) cv.begin_effective_dt_tm
     ELSE cnvtdatetime(request->cd_value_list[aidx].begin_effective_dt_tm)
     ENDIF
     , cv.cdf_meaning =
     IF ((request->cd_value_list[aidx].cdf_meaning='""')) null
     ELSE trim(cnvtupper(substring(1,12,request->cd_value_list[aidx].cdf_meaning)),3)
     ENDIF
     ,
     cv.collation_seq =
     IF ((request->cd_value_list[aidx].collation_seq <= 0)) 0
     ELSE request->cd_value_list[aidx].collation_seq
     ENDIF
     , cv.concept_cki =
     IF ((request->cd_value_list[aidx].concept_cki='""')) null
     ELSE trim(request->cd_value_list[aidx].concept_cki,3)
     ENDIF
     , cv.cki = request->cd_value_list[aidx].cki,
     cv.definition =
     IF ((request->cd_value_list[aidx].definition='""')) null
     ELSE trim(request->cd_value_list[aidx].definition,3)
     ENDIF
     , cv.description =
     IF ((request->cd_value_list[aidx].description='""')) null
     ELSE trim(substring(1,60,request->cd_value_list[aidx].description),3)
     ENDIF
     , cv.display =
     IF ((request->cd_value_list[aidx].display='""')) null
     ELSE trim(substring(1,40,request->cd_value_list[aidx].display),3)
     ENDIF
     ,
     cv.display_key =
     IF (display_key='""') null
     ELSE display_key
     ENDIF
     , cv.end_effective_dt_tm =
     IF ((request->cd_value_list[aidx].end_effective_dt_tm <= 0)) cv.end_effective_dt_tm
     ELSE cnvtdatetime(request->cd_value_list[aidx].end_effective_dt_tm)
     ENDIF
     , cv.inactive_dt_tm =
     IF ((request->cd_value_list[aidx].active_ind != old_active_ind)
      AND (request->cd_value_list[aidx].active_ind=0)) cnvtdatetime(curdate,curtime3)
     ELSEIF ((request->cd_value_list[aidx].active_ind != old_active_ind)
      AND (request->cd_value_list[aidx].active_ind=1)) null
     ELSE cv.inactive_dt_tm
     ENDIF
     ,
     cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task
    WHERE (cv.code_value=request->cd_value_list[aidx].code_value)
     AND (cv.code_set=request->cd_value_list[aidx].code_set)
    WITH nocounter
   ;end update
   SET errorcode = error(errmsg,0)
   IF (errorcode != 0)
    SET reply->qual[aidx].status = 0
    SET reply->qual[aidx].error_num = errorcode
    SET reply->error_msg = errmsg
    SET reply->qual[aidx].code_value = request->cd_value_list[aidx].code_value
    SET reply->status_data.status = "F"
    GO TO exit_script
   ELSE
    SET reply->qual[aidx].status = curqual
    SET reply->qual[aidx].error_num = 0
    SET reply->qual[aidx].error_msg = ""
    SET reply->qual[aidx].code_value = request->cd_value_list[aidx].code_value
    SET reply->status_data.status = "S"
   ENDIF
   IF ((reply->status_data.status="F"))
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivate_cd_value(aidx)
   IF (chg_access_ind=0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    SET reply->error_msg = concat("Code value could not be ",
     "updated because this code set does not allow updates.")
    GO TO exit_script
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.active_ind = 0, cv.active_type_cd = inactive, cv.inactive_dt_tm = cnvtdatetime(curdate,
      curtime3),
     cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task
    WHERE (cv.code_value=request->cd_value_list[aidx].code_value)
     AND (cv.code_set=request->cd_value_list[aidx].code_set)
    WITH nocounter
   ;end update
   SET errorcode = error(errmsg,0)
   IF (errorcode != 0)
    SET reply->qual[aidx].status = 0
    SET reply->qual[aidx].error_num = errorcode
    SET reply->error_msg = errmsg
    SET reply->qual[aidx].code_value = request->cd_value_list[aidx].code_value
    SET reply->status_data.status = "F"
   ELSE
    SET reply->qual[aidx].status = curqual
    SET reply->qual[aidx].error_num = 0
    SET reply->qual[aidx].error_msg = ""
    SET reply->qual[aidx].code_value = request->cd_value_list[aidx].code_value
    SET reply->status_data.status = "S"
   ENDIF
   IF ((reply->status_data.status="F"))
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE get_next_seq(seq_name)
   SET next_seq = 0.0
   SET seq_string = concat("seq(",seq_name,", nextval)")
   SELECT INTO "nl:"
    number = parser(seq_string)"##################;rp0"
    FROM dual
    DETAIL
     next_seq = cnvtreal(number)
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.status = "F"
    SET reply->error_msg = "Unable to generate a sequence number."
    GO TO exit_script
   ELSE
    RETURN(next_seq)
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  CALL echo("Failing")
  CALL echorecord(reply)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "004 01/20/04 JF8275"
END GO

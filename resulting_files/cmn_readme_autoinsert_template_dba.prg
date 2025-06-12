CREATE PROGRAM cmn_readme_autoinsert_template:dba
 DECLARE PUBLIC::errorcheck(replystructure=vc(ref),operation=vc) = null
 SUBROUTINE PUBLIC::errorcheck(replystructure,operation)
   DECLARE errormsg = c255 WITH protect, noconstant("")
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    WHILE (errorcode != 0)
      SET replystructure->status_data.subeventstatus[1].operationname = operation
      SET replystructure->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode,10)
      SET replystructure->status_data.subeventstatus[1].targetobjectvalue = errormsg
      SET replystructure->status_data.status = "F"
      IF ((reqdata->loglevel >= 4))
       CALL echo(errormsg)
      ENDIF
      SET errorcode = error(errormsg,0)
    ENDWHILE
    GO TO exit_script
   ENDIF
 END ;Subroutine
 DECLARE reply_status_success = vc WITH protect, constant("S")
 DECLARE code_set_16529 = i4 WITH protect, constant(16529)
 DECLARE cv_active_ind = i2 WITH protect, constant(1)
 DECLARE layout_flag_stw = i4 WITH protect, constant(2)
 DECLARE PUBLIC::main(null) = null WITH protect
 DECLARE PUBLIC::set_reply_status(status=c1,ostatus=c1,oname=vc,toname=vc,tovalue=vc,
  rep=vc(ref)) = null WITH protect
 DECLARE PUBLIC::build_template_cki(smart_template_str=vc) = vc WITH protect
 DECLARE PUBLIC::get_code_value_and_cki(code_set=i4,definition=vc,cdf_meaning=vc,smart_template_cki=
  vc(ref),st_active_ind=i2(ref)) = f8 WITH protect
 DECLARE PUBLIC::verify_layout_type(bridentifier=vc) = i2 WITH protect
 DECLARE PUBLIC::update_code_value(ucv_rec=vc(ref)) = null WITH protect
 DECLARE PUBLIC::ensure_clinical_note_temp(ecn_disp=vc,ecn_code_value=f8,ecn_cki=vc) = null
 FREE RECORD request
 RECORD request(
   1 cdf_meaning = vc
   1 cki = vc
   1 code_set = i4
   1 code_value = f8
   1 definition = vc
   1 description = vc
   1 display = vc
   1 active_ind = i2
   1 display_key = vc
 )
 IF (validate(crat_reply->status_data.status,"X")="X"
  AND validate(crat_reply->status_data.status,"A")="A")
  RECORD crat_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(crat_request->display,"ABC")="ABC"
  AND validate(crat_request->display,"XYZ")="XYZ")
  CALL set_reply_status("F","F","Before Main",curprog,
   "The CRAT_REQUEST record structure is not declared.",
   crat_reply)
 ENDIF
 IF (verify_layout_type(crat_request->identifier))
  CALL main(null)
 ELSE
  CALL set_reply_status("F","F","Before Main",curprog,
   "The requested action is not for a smart template.",
   crat_reply)
 ENDIF
 SUBROUTINE PUBLIC::main(null)
   DECLARE smart_template_cki = vc WITH protect, noconstant("")
   DECLARE smart_template_code = f8 WITH protect, noconstant(0.0)
   DECLARE cv_display = vc WITH public, noconstant(trim(substring(1,40,crat_request->display)))
   DECLARE stw_template_identifier = vc WITH public, noconstant(trim(substring(1,40,crat_request->
      identifier)))
   DECLARE cv_display_key = vc WITH public, noconstant(trim(cnvtupper(cnvtalphanum(substring(1,40,
        cv_display)))))
   DECLARE cv_cdf_meaning = vc WITH protect, constant("CLINNOTETEMP")
   DECLARE cv_definition = vc WITH protect, constant(trim(concat("smart_template_wizard__driver_",
      stw_template_identifier)))
   DECLARE cv_description = vc WITH protect, constant("VISIT")
   DECLARE st_active_ind = i2 WITH protect, noconstant(1)
   SET smart_template_code = get_code_value_and_cki(code_set_16529,cv_definition,cv_cdf_meaning,
    smart_template_cki,st_active_ind)
   IF (textlen(trim(smart_template_cki,3))=0)
    SET smart_template_cki = build_template_cki(cv_display)
   ENDIF
   SET request->cdf_meaning = cv_cdf_meaning
   SET request->code_set = code_set_16529
   SET request->definition = cv_definition
   SET request->description = cv_description
   SET request->display = cv_display
   SET request->active_ind = cv_active_ind
   SET request->display_key = cv_display_key
   SET request->cki = smart_template_cki
   SET request->code_value = smart_template_code
   CALL update_code_value(request)
   CALL ensure_clinical_note_temp(cv_display,smart_template_code,smart_template_cki)
   SET crat_reply->status_data.status = reply_status_success
 END ;Subroutine
 SUBROUTINE PUBLIC::verify_layout_type(bridentifier)
   DECLARE layout_flag = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category bc
    WHERE bc.category_mean=bridentifier
    DETAIL
     layout_flag = bc.layout_flag
    WITH nocounter
   ;end select
   CALL errorcheck(crat_reply,"Verify_Layout_Type")
   IF (layout_flag=layout_flag_stw)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE PUBLIC::get_code_value_and_cki(code_set,definition,cdf_meaning,smart_template_cki,
  st_active_ind)
   DECLARE return_code_value = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=code_set
     AND cnvtupper(trim(cv.definition))=cnvtupper(trim(definition))
     AND cv.cdf_meaning=cdf_meaning
    DETAIL
     return_code_value = cv.code_value, smart_template_cki = cv.cki, st_active_ind = cv.active_ind
    WITH nocounter
   ;end select
   CALL errorcheck(crat_reply,"Get_Code_Value_And_Cki")
   RETURN(return_code_value)
 END ;Subroutine
 SUBROUTINE PUBLIC::build_template_cki(smart_template_str)
   DECLARE cki_str = vc WITH private, noconstant("CKI.SMARTTEMP.CODEVALUE!")
   SET smart_template_str = replace(smart_template_str," ","",0)
   SET cki_str = concat(cki_str,smart_template_str)
   RETURN(cki_str)
 END ;Subroutine
 SUBROUTINE PUBLIC::set_reply_status(status,ostatus,oname,toname,tovalue,rep)
   SET rep->status_data.status = status
   SET rep->status_data.subeventstatus[1].operationstatus = ostatus
   SET rep->status_data.subeventstatus[1].operationname = oname
   SET rep->status_data.subeventstatus[1].targetobjectname = toname
   SET rep->status_data.subeventstatus[1].targetobjectvalue = tovalue
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE PUBLIC::update_code_value(ucv_rec)
   DECLARE ucv_active_cd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="ACTIVE"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     ucv_active_cd = cv.code_value
    WITH nocounter
   ;end select
   CALL errorcheck(crat_reply,"Querying for ACTIVE_STATUS_CD")
   UPDATE  FROM code_value cv
    SET cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_ind = ucv_rec->active_ind, cv
     .active_status_prsnl_id = reqinfo->updt_id,
     cv.active_type_cd = ucv_active_cd, cv.cdf_meaning = trim(cnvtupper(substring(1,12,ucv_rec->
        cdf_meaning)),3), cv.cki = ucv_rec->cki,
     cv.definition = trim(ucv_rec->definition,3), cv.description = trim(substring(1,60,ucv_rec->
       description),3), cv.display = trim(substring(1,40,ucv_rec->display),3),
     cv.display_key = trim(substring(1,40,ucv_rec->display_key),3), cv.updt_applctx = reqinfo->
     updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1),
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
     reqinfo->updt_task
    WHERE (cv.code_value=ucv_rec->code_value)
     AND (cv.code_set=ucv_rec->code_set)
    WITH nocounter
   ;end update
   CALL errorcheck(crat_reply,"Updating CODE_VALUE")
   RETURN(null)
 END ;Subroutine
 SUBROUTINE PUBLIC::ensure_clinical_note_temp(ecn_disp,ecn_code_value,ecn_cki)
   DECLARE ecn_template_id = f8 WITH protect, noconstant(0.0)
   DECLARE ecn_active_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM clinical_note_template cn
    WHERE cn.smart_template_cd=ecn_code_value
     AND cn.smart_template_ind=1
    DETAIL
     ecn_template_id = cn.template_id, ecn_active_ind = cn.template_active_ind
    WITH nocounter
   ;end select
   CALL errorcheck(crat_reply,"Querying CLINICAL_NOTE_TEMPLATE")
   IF (ecn_template_id > 0)
    UPDATE  FROM clinical_note_template nt
     SET nt.template_name = ecn_disp, nt.template_active_ind = 1, nt.owner_type_flag = 0,
      nt.prsnl_id = reqinfo->updt_id, nt.cki = ecn_cki, nt.updt_dt_tm = cnvtdatetime(curdate,curtime),
      nt.updt_id = reqinfo->updt_id, nt.updt_task = reqinfo->updt_task, nt.updt_applctx = reqinfo->
      updt_applctx,
      nt.updt_cnt = (nt.updt_cnt+ 1)
     WHERE nt.template_id=ecn_template_id
     WITH nocounter
    ;end update
    CALL errorcheck(crat_reply,"Updating CLINICAL_NOTE_TEMPLATE")
   ELSE
    SELECT INTO "nl:"
     j = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      ecn_template_id = j
     WITH nocounter
    ;end select
    CALL errorcheck(crat_reply,"Creating new PK value for CLINICAL_NOTE_TEMPLATE")
    INSERT  FROM clinical_note_template nt
     SET nt.smart_template_ind = 1, nt.smart_template_cd = ecn_code_value, nt.template_id =
      ecn_template_id,
      nt.template_name = ecn_disp, nt.cki = ecn_cki, nt.template_active_ind = 1,
      nt.long_blob_id = 0, nt.owner_type_flag = 0, nt.prsnl_id = reqinfo->updt_id,
      nt.updt_dt_tm = cnvtdatetime(curdate,curtime), nt.updt_id = reqinfo->updt_id, nt.updt_task =
      reqinfo->updt_task,
      nt.updt_applctx = reqinfo->updt_applctx, nt.updt_cnt = 0
     WITH nocounter
    ;end insert
    CALL errorcheck(crat_reply,"Inserting CLINICAL_NOTE_TEMPLATE")
   ENDIF
   RETURN(null)
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(crat_reply)
  CALL echorecord(request)
  CALL echorecord(cecv_reply)
 ENDIF
END GO

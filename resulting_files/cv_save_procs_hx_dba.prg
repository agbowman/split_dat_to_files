CREATE PROGRAM cv_save_procs_hx:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 FREE RECORD addcvprochx
 RECORD addcvprochx(
   1 objarray[*]
     2 cv_proc_hx_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 order_catalog_cd = f8
     2 frgn_sys_order_reference = vc
     2 frgn_sys_accession_reference = vc
     2 activity_subtype_cd = f8
     2 completed_location_cd = f8
     2 contributor_system_cd = f8
     2 reference_txt = vc
     2 completed_dt_tm = dq8
     2 completed_tz = i4
 )
 FREE RECORD updcvprochx
 RECORD updcvprochx(
   1 objarray[*]
     2 cv_proc_hx_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 order_catalog_cd = f8
     2 frgn_sys_order_reference = vc
     2 frgn_sys_accession_reference = vc
     2 activity_subtype_cd = f8
     2 completed_location_cd = f8
     2 contributor_system_cd = f8
     2 reference_txt = vc
     2 completed_dt_tm = dq8
     2 completed_tz = i4
 )
 IF (validate(reply) != 1)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD cvaddimstudy
 RECORD cvaddimstudy(
   1 qual[*]
     2 entity_id = f8
     2 entity_name = c32
     2 study_uid = vc
 )
 FREE RECORD cvupdimstudy
 RECORD cvupdimstudy(
   1 qual[*]
     2 entity_id = f8
     2 entity_name = c32
     2 study_uid = vc
 )
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REPLY","")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (size(request->cvprochx,5)=0)
  CALL cv_log_stat(cv_audit,"SIZE","Z","reequest","")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 DECLARE naddsize = i4 WITH constant(size(request->cvprochx,5)), protect
 DECLARE addproccnt = i4 WITH noconstant(0), protect
 DECLARE uptproccnt = i4 WITH noconstant(0), protect
 DECLARE cvprocidhx = f8 WITH protect, noconstant(0.0)
 DECLARE updateimstudy = i4 WITH noconstant(0), protect
 DECLARE imstudyuid = vc WITH protect
 DECLARE activitysubtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE procidx = i4 WITH protect
 DECLARE uptimstudycnt = i4 WITH protect
 FOR (procidx = 1 TO naddsize)
   SET cvprocidhx = 0.0
   SET updateimstudy = 0
   SET imstudyuid = null
   SET activitysubtypecd = 0.0
   IF ((request->cvprochx[procidx].frgn_sys_siuid_reference != null))
    SELECT INTO "n1:"
     FROM im_study i
     WHERE (i.study_uid=request->cvprochx[procidx].frgn_sys_siuid_reference)
     DETAIL
      imstudyuid = i.study_uid, cvprocidhx = i.orig_entity_id
     WITH nocounter, separator = " ", format
    ;end select
    IF (imstudyuid=null)
     SET updateimstudy = 1
    ENDIF
   ENDIF
   IF (cvprocidhx=0.0)
    IF ((request->cvprochx[procidx].frgn_sys_accession_reference != null))
     SELECT INTO "n1:"
      FROM cv_proc_hx c
      WHERE (c.frgn_sys_accession_reference=request->cvprochx[procidx].frgn_sys_accession_reference)
      DETAIL
       cvprocidhx = c.cv_proc_hx_id
      WITH nocounter, separator = " ", format
     ;end select
    ENDIF
   ENDIF
   IF (cvprocidhx=0.0)
    IF ((request->cvprochx[procidx].frgn_sys_order_reference != null))
     SELECT INTO "n1:"
      FROM cv_proc_hx c
      WHERE (c.frgn_sys_order_reference=request->cvprochx[procidx].frgn_sys_order_reference)
      DETAIL
       cvprocidhx = c.cv_proc_hx_id
      WITH nocounter, separator = " ", format
     ;end select
    ENDIF
   ENDIF
   IF ((request->cvprochx[procidx].order_catalog_cd != 0.0))
    SELECT INTO "n1:"
     FROM order_catalog oc
     WHERE (oc.catalog_cd=request->cvprochx[procidx].order_catalog_cd)
     DETAIL
      activitysubtypecd = oc.activity_subtype_cd
     WITH nocounter, separator = " ", format
    ;end select
   ENDIF
   IF (cvprocidhx=0.0)
    SET addproccnt += 1
    SET stat = alterlist(addcvprochx->objarray,addproccnt)
    SET stat = alterlist(cvaddimstudy->qual,addproccnt)
    SELECT INTO "nl:"
     proc_seq = seq(card_vas_seq,nextval)
     FROM dual d
     DETAIL
      addcvprochx->objarray[addproccnt].cv_proc_hx_id = proc_seq, cvaddimstudy->qual[addproccnt].
      entity_id = proc_seq
     WITH format, counter
    ;end select
    SET addcvprochx->objarray[addproccnt].encntr_id = request->cvprochx[procidx].encntr_id
    SET addcvprochx->objarray[addproccnt].person_id = request->cvprochx[procidx].person_id
    SET addcvprochx->objarray[addproccnt].order_id = request->cvprochx[procidx].order_id
    SET addcvprochx->objarray[addproccnt].order_catalog_cd = request->cvprochx[procidx].
    order_catalog_cd
    SET addcvprochx->objarray[addproccnt].frgn_sys_order_reference = request->cvprochx[procidx].
    frgn_sys_order_reference
    SET addcvprochx->objarray[addproccnt].frgn_sys_accession_reference = request->cvprochx[procidx].
    frgn_sys_accession_reference
    SET addcvprochx->objarray[addproccnt].activity_subtype_cd = activitysubtypecd
    SET addcvprochx->objarray[addproccnt].completed_location_cd = request->cvprochx[procidx].
    completed_location_cd
    SET addcvprochx->objarray[addproccnt].reference_txt = request->cvprochx[procidx].reference_txt
    SET addcvprochx->objarray[addproccnt].contributor_system_cd = request->cvprochx[procidx].
    contributor_system_cd
    SET addcvprochx->objarray[addproccnt].completed_dt_tm = request->cvprochx[procidx].
    completed_dt_tm
    SET addcvprochx->objarray[addproccnt].completed_tz = request->cvprochx[procidx].completed_tz
    SET cvaddimstudy->qual[addproccnt].entity_name = "CV_PROC_HX"
    SET cvaddimstudy->qual[addproccnt].study_uid = request->cvprochx[procidx].
    frgn_sys_siuid_reference
   ELSE
    SET uptproccnt += 1
    SET stat = alterlist(updcvprochx->objarray,uptproccnt)
    SET updcvprochx->objarray[uptproccnt].cv_proc_hx_id = cvprocidhx
    SET updcvprochx->objarray[uptproccnt].encntr_id = request->cvprochx[procidx].encntr_id
    SET updcvprochx->objarray[uptproccnt].person_id = request->cvprochx[procidx].person_id
    SET updcvprochx->objarray[uptproccnt].order_id = request->cvprochx[procidx].order_id
    SET updcvprochx->objarray[uptproccnt].order_catalog_cd = request->cvprochx[procidx].
    order_catalog_cd
    SET updcvprochx->objarray[uptproccnt].frgn_sys_order_reference = request->cvprochx[procidx].
    frgn_sys_order_reference
    SET updcvprochx->objarray[uptproccnt].frgn_sys_accession_reference = request->cvprochx[procidx].
    frgn_sys_accession_reference
    SET updcvprochx->objarray[uptproccnt].activity_subtype_cd = activitysubtypecd
    SET updcvprochx->objarray[uptproccnt].completed_location_cd = request->cvprochx[procidx].
    completed_location_cd
    SET updcvprochx->objarray[uptproccnt].reference_txt = request->cvprochx[procidx].reference_txt
    SET updcvprochx->objarray[uptproccnt].contributor_system_cd = request->cvprochx[procidx].
    contributor_system_cd
    SET updcvprochx->objarray[uptproccnt].completed_dt_tm = request->cvprochx[procidx].
    completed_dt_tm
    SET updcvprochx->objarray[uptproccnt].completed_tz = request->cvprochx[procidx].completed_tz
    IF (updateimstudy=1)
     SET uptimstudycnt += 1
     SET stat = alterlist(cvupdimstudy->qual,uptimstudycnt)
     SET cvupdimstudy->qual[uptimstudycnt].entity_name = "CV_PROC_HX"
     SET cvupdimstudy->qual[uptimstudycnt].entity_id = cvprocidhx
     SET cvupdimstudy->qual[uptimstudycnt].study_uid = request->cvprochx[procidx].
     frgn_sys_siuid_reference
    ENDIF
   ENDIF
 ENDFOR
 IF (size(addcvprochx->objarray,5) > 0)
  CALL cv_log_msg(cv_debug,"ADDING to CV_PROC_HX...")
  EXECUTE cv_da_add_cv_proc_hx  WITH replace("REQUEST",addcvprochx), replace("REPLY",reply)
  CALL echorecord(addcvprochx)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"cv_da_add_cv_proc_hx","")
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_info,"Nothing to ADD to cv_proc_hx")
 ENDIF
 IF (size(updcvprochx->objarray,5) > 0)
  CALL cv_log_msg(cv_debug,"UPDATING TO CV_PROC_HX...")
  EXECUTE cv_da_upd_cv_proc_hx  WITH replace("REQUEST",updcvprochx), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"cv_da_upd_cv_proc_hx","")
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_info,"Nothing to Update to cv_proc_hx")
 ENDIF
 IF (size(cvaddimstudy->qual,5) > 0)
  CALL cv_log_msg(cv_debug,"ADDING IM_STUDY_UID...")
  EXECUTE cv_da_add_im_study_uid  WITH replace("REQUEST",cvaddimstudy), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"cv_da_add_im_study_uid","")
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_info,"Nothing to add to im_study")
 ENDIF
 IF (size(cvupdimstudy->qual,5) > 0)
  CALL cv_log_msg(cv_debug,"UPDATE IM_STUDY_UID...")
  EXECUTE cv_da_upd_im_study_uid  WITH replace("REQUEST",cvupdimstudy), replace("REPLY",reply)
  IF ((reply->status_data.status != "S"))
   CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"cv_da_upd_im_study_uid","")
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_msg(cv_info,"Nothing to Update to im_study")
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_SAVE_PROCS_HX FAILED!")
  CALL echorecord(request)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("MOD 000 12/03/18 AS043139")
END GO

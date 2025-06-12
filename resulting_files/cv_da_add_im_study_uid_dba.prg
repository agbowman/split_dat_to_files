CREATE PROGRAM cv_da_add_im_study_uid:dba
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
 DECLARE cv_da_add_im_study_uid_vrsn = vc WITH private, constant("20180303")
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
 FREE RECORD toadd
 RECORD toadd(
   1 qual[*]
     2 im_study_parent_id = f8
     2 im_study_id = f8
     2 study_uid = vc
     2 created_study_uid = vc
     2 study_state_cd = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
 )
 DECLARE next_im_code = f8 WITH protect, noconstant(0.0)
 DECLARE naddsize = i4 WITH protect
 DECLARE count = i4 WITH protect
 DECLARE parameter1 = c30 WITH protect
 DECLARE parameter2 = c30 WITH protect
 DECLARE mydate = c8 WITH protect
 DECLARE mytime = c6 WITH protect
 DECLARE studystatecd = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"N"))
 DECLARE dicom_implementation_prefix = vc WITH protect, constant("DICOM_IMPLEMENTATION_UID")
 DECLARE database_dicom_prefix = vc WITH protect, constant("DATABASE_DICOM_PREFIX")
 SET count = 0
 SET naddsize = size(cvaddimstudy->qual,5)
 SET stat = alterlist(toadd->qual,value(naddsize))
 SET mydate = format(curdate,"YYYYMMDD;;D")
 SET mytime = format(curtime3,"HHMMSS;;M")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  imc.value_char, imc2.value_char
  FROM im_configuration imc,
   im_configuration imc2
  PLAN (imc
   WHERE imc.parameter_name=dicom_implementation_prefix)
   JOIN (imc2
   WHERE imc2.parameter_name=database_dicom_prefix)
  DETAIL
   parameter1 = imc.value_char, parameter2 = imc2.value_char
  WITH nocounter
 ;end select
 FOR (count = 1 TO naddsize)
   EXECUTE im_next_code
   SET toadd->qual[count].im_study_id = next_im_code
   SET toadd->qual[count].parent_entity_name = cvaddimstudy->qual[count].entity_name
   SET toadd->qual[count].parent_entity_id = cvaddimstudy->qual[count].entity_id
   SET toadd->qual[count].study_state_cd = studystatecd
   IF ((cvaddimstudy->qual[count].study_uid=""))
    SET toadd->qual[count].study_uid = concat(trim(parameter1),".",trim(parameter2),".",trim(
      cnvtstring(toadd->qual[count].im_study_id)),
     ".",trim(mydate),".1",trim(mytime))
    SET toadd->qual[count].created_study_uid = toadd->qual[count].study_uid
   ELSE
    SET toadd->qual[count].study_uid = cvaddimstudy->qual[count].study_uid
    SET toadd->qual[count].created_study_uid = cvaddimstudy->qual[count].study_uid
   ENDIF
   EXECUTE im_next_code
   SET toadd->qual[count].im_study_parent_id = next_im_code
 ENDFOR
 INSERT  FROM im_study im,
   (dummyt d  WITH seq = value(naddsize))
  SET im.im_study_id = toadd->qual[d.seq].im_study_id, im.study_uid = toadd->qual[d.seq].study_uid,
   im.created_study_uid = toadd->qual[d.seq].created_study_uid,
   im.study_state_cd = toadd->qual[d.seq].study_state_cd, im.orig_entity_name = toadd->qual[d.seq].
   parent_entity_name, im.orig_entity_id = toadd->qual[d.seq].parent_entity_id,
   im.updt_dt_tm = cnvtdatetime(sysdate), im.updt_id = reqinfo->updt_id, im.updt_task = reqinfo->
   updt_task,
   im.updt_applctx = reqinfo->updt_applctx, im.updt_cnt = 0
  PLAN (d)
   JOIN (im)
  WITH nocounter
 ;end insert
 INSERT  FROM im_study_parent_r im,
   (dummyt d  WITH seq = value(naddsize))
  SET im.im_study_id = toadd->qual[d.seq].im_study_id, im.im_study_parent_id = toadd->qual[d.seq].
   im_study_parent_id, im.parent_entity_name = toadd->qual[d.seq].parent_entity_name,
   im.parent_entity_id = toadd->qual[d.seq].parent_entity_id, im.updt_dt_tm = cnvtdatetime(sysdate),
   im.updt_id = reqinfo->updt_id,
   im.updt_task = reqinfo->updt_task, im.updt_applctx = reqinfo->updt_applctx, im.updt_cnt = 0
  PLAN (d)
   JOIN (im)
  WITH nocounter
 ;end insert
 IF (curqual != value(naddsize))
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = false
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
 CALL cv_log_msg_post("000 25/03/2018 AS043139")
END GO

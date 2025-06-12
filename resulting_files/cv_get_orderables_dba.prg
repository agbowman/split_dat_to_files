CREATE PROGRAM cv_get_orderables:dba
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
 DECLARE m_ngonum = i4 WITH noconstant(0), protect
 DECLARE m_ngoidx = i4 WITH noconstant(0), protect
 DECLARE m_nrequestsize = i4 WITH noconstant(0), protect
 DECLARE cardiovascul_mean_var = f8 WITH constant(uar_get_code_by("MEANING",6000,"CARDIOVASCUL")),
 protect
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 IF (validate(reply) != 1)
  RECORD reply(
    1 orderables[*]
      2 catalog_cd = f8
      2 catalog_disp = vc
      2 catalog_mean = vc
      2 catalog_type_cd = f8
      2 catalog_type_disp = vc
      2 catalog_type_mean = vc
      2 description = vc
      2 activity_subtype_cd = f8
      2 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_msg(cv_error,"VALIDATE","F","REPLY"," ")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET m_nrequestsize = size(request->order_catalog,5)
 SET m_nreplysize = size(reply->orderables,5)
 CALL echo(build2("m_nRequestSize",m_nrequestsize))
 SELECT
  IF (m_nrequestsize > 0)
   WHERE expand(m_ngonum,1,m_nrequestsize,oc.catalog_cd,request->order_catalog[m_ngonum].catalog_cd)
    AND oc.catalog_type_cd=cardiovascul_mean_var
  ELSE
  ENDIF
  INTO "NL:"
  FROM order_catalog oc
  WHERE oc.catalog_type_cd=cardiovascul_mean_var
  HEAD REPORT
   m_ngoidx = 0
  DETAIL
   m_ngoidx += 1
   IF (mod(m_ngoidx,10)=1)
    stat = alterlist(reply->orderables,(m_ngoidx+ 9))
   ENDIF
   reply->orderables[m_ngoidx].catalog_cd = oc.catalog_cd, reply->orderables[m_ngoidx].
   catalog_type_cd = oc.catalog_type_cd, reply->orderables[m_ngoidx].activity_subtype_cd = oc
   .activity_subtype_cd,
   reply->orderables[m_ngoidx].description = oc.description, reply->orderables[m_ngoidx].active_ind
    = oc.active_ind
  FOOT REPORT
   stat = alterlist(reply->orderables,m_ngoidx)
  WITH nocounter
 ;end select
 IF (m_ngoidx < 1)
  CALL cv_log_stat(cv_warning,"SELECT","Z","ORDER_CATALOG","")
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_GET_ORDERABLES failed")
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 CALL cv_log_msg_post("001  07/15/06 Adilson M. Ribeiro")
END GO

CREATE PROGRAM cv_load_order_category:dba
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
 DECLARE nparentcnt = i4 WITH protect, noconstant(0)
 DECLARE nchildcnt = i4 WITH protect, noconstant(0)
 DECLARE nsectionenum = i4 WITH protect, noconstant(0)
 DECLARE cardiovascul_mean_var = f8 WITH constant(uar_get_code_by("MEANING",6000,"CARDIOVASCUL")),
 protect
 IF (validate(reply) != 1)
  RECORD reply(
    1 order_category[*]
      2 cv_order_category_id = f8
      2 category_name = c40
      2 category_limit = i4
      2 collation_seq = i4
      2 section_enum = i4
      2 updt_cnt = i4
      2 order_category_r[*]
        3 cv_order_category_r_id = f8
        3 catalog_cd = f8
        3 catalog_type_cd = f8
        3 detail_txt = vc
        3 cv_orderable_ind = i2
        3 updt_cnt = i4
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
  CALL cv_log_msg(cv_error,"reply doesn't contain status block")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->section_flag > 0))
   PLAN (c
    WHERE c.cv_order_category_id != 0.0
     AND (c.section_enum=request->section_flag))
    JOIN (cr
    WHERE (cr.cv_order_category_id= Outerjoin(c.cv_order_category_id)) )
    JOIN (oc
    WHERE (oc.catalog_cd= Outerjoin(cr.catalog_cd)) )
  ELSE
  ENDIF
  INTO "nl:"
  FROM cv_order_category c,
   cv_order_category_r cr,
   order_catalog oc
  PLAN (c
   WHERE c.cv_order_category_id != 0.0)
   JOIN (cr
   WHERE (cr.cv_order_category_id= Outerjoin(c.cv_order_category_id)) )
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(cr.catalog_cd)) )
  ORDER BY c.section_enum, c.collation_seq, c.cv_order_category_id
  HEAD REPORT
   nparentcnt = 0
  HEAD c.cv_order_category_id
   nchildcnt = 0, nparentcnt += 1
   IF (mod(nparentcnt,10)=1)
    stat = alterlist(reply->order_category,(nparentcnt+ 9))
   ENDIF
   reply->order_category[nparentcnt].cv_order_category_id = c.cv_order_category_id, reply->
   order_category[nparentcnt].category_name = c.category_name, reply->order_category[nparentcnt].
   category_limit = c.category_limit,
   reply->order_category[nparentcnt].collation_seq = c.collation_seq, reply->order_category[
   nparentcnt].section_enum = c.section_enum, reply->order_category[nparentcnt].updt_cnt = c.updt_cnt
  DETAIL
   nchildcnt += 1
   IF (mod(nchildcnt,10)=1)
    stat = alterlist(reply->order_category[nparentcnt].order_category_r,(nchildcnt+ 9))
   ENDIF
   reply->order_category[nparentcnt].order_category_r[nchildcnt].cv_order_category_r_id = cr
   .cv_order_category_r_id, reply->order_category[nparentcnt].order_category_r[nchildcnt].catalog_cd
    = cr.catalog_cd, reply->order_category[nparentcnt].order_category_r[nchildcnt].detail_txt = cr
   .detail_txt,
   reply->order_category[nparentcnt].order_category_r[nchildcnt].updt_cnt = cr.updt_cnt, reply->
   order_category[nparentcnt].order_category_r[nchildcnt].catalog_type_cd = oc.catalog_type_cd
   IF (oc.catalog_type_cd=cardiovascul_mean_var)
    reply->order_category[nparentcnt].order_category_r[nchildcnt].cv_orderable_ind = 1
   ENDIF
  FOOT  c.cv_order_category_id
   stat = alterlist(reply->order_category[nparentcnt].order_category_r,nchildcnt)
  FOOT REPORT
   stat = alterlist(reply->order_category,nparentcnt)
  WITH nocounter
 ;end select
 IF (nparentcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_info,"CV_LOAD_ORDER_CATEGORY returned status = 'Z'")
 ELSEIF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_LOAD_ORDER_CATEGORY failed")
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 CALL cv_log_msg_post("MOD 001 5/30/2008 AR012547")
END GO

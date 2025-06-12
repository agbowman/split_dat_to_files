CREATE PROGRAM cv_save_acronyms:dba
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
 FREE RECORD addacronym
 RECORD addacronym(
   1 objarray[*]
     2 cv_acronym_id = f8
     2 provider_id = f8
     2 acronym_str = vc
     2 replacement_str = vc
     2 collation_seq = i4
     2 category_cd = f8
 )
 FREE RECORD uptacronym
 RECORD uptacronym(
   1 objarray[*]
     2 cv_acronym_id = f8
     2 provider_id = f8
     2 acronym_str = vc
     2 replacement_str = vc
     2 collation_seq = i4
     2 category_cd = f8
     2 updt_cnt = i4
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
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REPLY","")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 DECLARE ndeletesize = i4 WITH constant(size(request->deleteacronym,5)), protect
 IF (ndeletesize > 0)
  DELETE  FROM cv_acronym c,
    (dummyt d1  WITH seq = value(ndeletesize))
   SET c.seq = 1
   PLAN (d1)
    JOIN (c
    WHERE (c.cv_acronym_id=request->deleteacronym[d1.seq].cv_acronym_id))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   CALL cv_log_stat(cv_error,"DELETE","F","CV_ACRONYM",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE nupdatesize = i4 WITH constant(size(request->updateacronym,5)), protect
 IF (nupdatesize > 0)
  SET stat = alterlist(uptacronym->objarray,nupdatesize)
  FOR (i = 1 TO nupdatesize)
    SET uptacronym->objarray[i].cv_acronym_id = request->updateacronym[i].cv_acronym_id
    SET uptacronym->objarray[i].provider_id = request->updateacronym[i].provider_id
    SET uptacronym->objarray[i].acronym_str = request->updateacronym[i].acronym_str
    SET uptacronym->objarray[i].replacement_str = request->updateacronym[i].replacement_str
    SET uptacronym->objarray[i].collation_seq = request->updateacronym[i].collation_seq
    SET uptacronym->objarray[i].category_cd = request->updateacronym[i].category_cd
    SET uptacronym->objarray[i].updt_cnt = request->updateacronym[i].updt_cnt
  ENDFOR
  IF (size(uptacronym->objarray,5) > 0)
   CALL cv_log_msg(cv_debug,"UPDATING into CV_ACRONYM...")
   EXECUTE cv_da_upt_cv_acronym  WITH replace("REQUEST",uptacronym), replace("REPLY",reply)
   IF ((reply->status_data.status != "S"))
    CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"cv_da_upt_cv_acronym","")
    CALL echorecord(uptacronym)
    GO TO exit_script
   ENDIF
  ELSE
   CALL cv_log_msg(cv_info,"Nothing to UPDATE into cv_acronym")
  ENDIF
 ENDIF
 DECLARE naddsize = i4 WITH constant(size(request->addacronym,5)), protect
 IF (naddsize > 0)
  SET stat = alterlist(addacronym->objarray,naddsize)
  FOR (i = 1 TO naddsize)
    SET addacronym->objarray[i].provider_id = request->addacronym[i].provider_id
    SET addacronym->objarray[i].acronym_str = request->addacronym[i].acronym_str
    SET addacronym->objarray[i].replacement_str = request->addacronym[i].replacement_str
    SET addacronym->objarray[i].collation_seq = request->addacronym[i].collation_seq
    SET addacronym->objarray[i].category_cd = request->addacronym[i].category_cd
  ENDFOR
  IF (size(addacronym->objarray,5) > 0)
   CALL cv_log_msg(cv_debug,"ADDING to CV_ACRONYM...")
   EXECUTE cv_da_add_cv_acronym  WITH replace("REQUEST",addacronym), replace("REPLY",reply)
   IF ((reply->status_data.status != "S"))
    CALL cv_log_stat(cv_error,"SCRIPT",reply->status_data.status,"cv_da_add_cv_acronym","")
    CALL echorecord(addacronym)
    GO TO exit_script
   ENDIF
  ELSE
   CALL cv_log_msg(cv_info,"Nothing to ADD to cv_acronym")
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_SAVE_ACRONYM FAILED!")
  CALL echorecord(request)
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cv_log_msg_post("MOD 000 10/31/08 AR012547")
END GO

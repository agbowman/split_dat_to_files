CREATE PROGRAM cv_get_privs:dba
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
 IF (validate(reply) != 1)
  RECORD reply(
    1 prsnl[*]
      2 person_id = f8
      2 position_cd = f8
      2 name_full_formatted = vc
      2 privs[*]
        3 privilege_id = f8
        3 privilege_cd = f8
        3 privilege_disp = vc
        3 privilege_desc = vc
        3 privilege_mean = vc
        3 priv_value_cd = f8
        3 priv_value_disp = vc
        3 priv_value_desc = vc
        3 priv_value_mean = vc
        3 exceptionlist[*]
          4 privilegeexceptionid = f8
          4 exception_type_cd = f8
          4 exception_type_disp = vc
          4 exception_type_desc = vc
          4 exception_type_mean = vc
          4 exceptionid = f8
          4 exceptionentityname = vc
          4 eventsetname = vc
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
  CALL cv_log_msg(cv_error,"Reply doesn't contain status block")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 DECLARE mnreqcnt = i4 WITH protect, constant(size(request->privs,5))
 DECLARE mnreqidx = i4 WITH protect, noconstant(0)
 DECLARE mnprsnlcnt = i4 WITH protect, noconstant(0)
 DECLARE mnprivcnt = i4 WITH protect, noconstant(0)
 DECLARE mnexceptcnt = i4 WITH protect, noconstant(0)
 DECLARE exception_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6015,"CVPROCCAT"))
 DECLARE privilege_value_cd = f8 WITH constant(uar_get_code_by("MEANING",6017,"INCLUDE"))
 IF (0=mnreqcnt)
  CALL cv_log_stat(cv_warning,"EMPTY REQUEST","Z","REQUEST","")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT
  IF ((request->position_cd > 0.0)
   AND (request->person_id=0.0))
   person_id = prsnl.person_id, position_cd = prsnl.position_cd, name_full_formatted = prsnl
   .name_full_formatted,
   privilege_id = pr.privilege_id, privilege_cd = pr.privilege_cd, priv_value_cd = pr.priv_value_cd,
   privilege_exception_id = pe.privilege_exception_id, exception_type_cd = pe.exception_type_cd,
   exception_id = pe.exception_id,
   exception_entity_name = pe.exception_entity_name, event_set_name = pe.event_set_name
   FROM privilege pr,
    priv_loc_reltn plr,
    privilege_exception pe,
    prsnl prsnl
   PLAN (pr
    WHERE expand(mnreqidx,1,mnreqcnt,pr.privilege_cd,request->privs[mnreqidx].privilege_cd)
     AND pr.priv_value_cd=privilege_value_cd
     AND pr.active_ind=1)
    JOIN (pe
    WHERE pe.privilege_id=pr.privilege_id
     AND pe.exception_type_cd=exception_type_cd
     AND pe.active_ind=1)
    JOIN (plr
    WHERE plr.priv_loc_reltn_id=pr.priv_loc_reltn_id
     AND (plr.position_cd=request->position_cd)
     AND plr.active_ind=1)
    JOIN (prsnl
    WHERE (prsnl.position_cd=request->position_cd)
     AND prsnl.active_ind=1
     AND prsnl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND prsnl.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ELSEIF ((request->position_cd=0.0)
   AND (request->person_id > 0.0))
   person_id = prsnl.person_id, position_cd = prsnl.position_cd, name_full_formatted = prsnl
   .name_full_formatted,
   privilege_id = pr.privilege_id, privilege_cd = pr.privilege_cd, priv_value_cd = pr.priv_value_cd,
   privilege_exception_id = pe.privilege_exception_id, exception_type_cd = pe.exception_type_cd,
   exception_id = pe.exception_id,
   exception_entity_name = pe.exception_entity_name, event_set_name = pe.event_set_name
   FROM privilege pr,
    priv_loc_reltn plr,
    privilege_exception pe,
    prsnl prsnl
   PLAN (pr
    WHERE expand(mnreqidx,1,mnreqcnt,pr.privilege_cd,request->privs[mnreqidx].privilege_cd)
     AND pr.priv_value_cd=privilege_value_cd
     AND pr.active_ind=1)
    JOIN (pe
    WHERE pe.privilege_id=pr.privilege_id
     AND pe.exception_type_cd=exception_type_cd
     AND pe.active_ind=1)
    JOIN (plr
    WHERE plr.priv_loc_reltn_id=pr.priv_loc_reltn_id
     AND (plr.person_id=request->person_id)
     AND plr.active_ind=1)
    JOIN (prsnl
    WHERE prsnl.person_id=plr.person_id
     AND prsnl.active_ind=1
     AND prsnl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND prsnl.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ELSEIF ((request->position_cd=0.0)
   AND (request->person_id=0.0))
   person_id = prsnl.person_id, position_cd = prsnl.position_cd, name_full_formatted = prsnl
   .name_full_formatted,
   privilege_id = pr.privilege_id, privilege_cd = pr.privilege_cd, priv_value_cd = pr.priv_value_cd,
   privilege_exception_id = pe.privilege_exception_id, exception_type_cd = pe.exception_type_cd,
   exception_id = pe.exception_id,
   exception_entity_name = pe.exception_entity_name, event_set_name = pe.event_set_name
   PLAN (pr
    WHERE expand(mnreqidx,1,mnreqcnt,pr.privilege_cd,request->privs[mnreqidx].privilege_cd)
     AND pr.priv_value_cd=privilege_value_cd
     AND pr.active_ind=1)
    JOIN (pe
    WHERE pe.privilege_id=pr.privilege_id
     AND pe.exception_type_cd=exception_type_cd
     AND pe.active_ind=1)
    JOIN (plr
    WHERE plr.priv_loc_reltn_id=pr.priv_loc_reltn_id
     AND plr.position_cd > 0
     AND plr.active_ind=1)
    JOIN (prsnl
    WHERE prsnl.position_cd=plr.position_cd
     AND prsnl.active_ind=1
     AND ((prsnl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND prsnl.end_effective_dt_tm >= cnvtdatetime(sysdate)) UNION (
    (SELECT
     person_id = prsnl.person_id, position_cd = prsnl.position_cd, name_full_formatted = prsnl
     .name_full_formatted,
     privilege_id = pr.privilege_id, privilege_cd = pr.privilege_cd, priv_value_cd = pr.priv_value_cd,
     privilege_exception_id = pe.privilege_exception_id, exception_type_cd = pe.exception_type_cd,
     exception_id = pe.exception_id,
     exception_entity_name = pe.exception_entity_name, event_set_name = pe.event_set_name
     FROM privilege pr,
      priv_loc_reltn plr,
      prsnl prsnl,
      privilege_exception pe
     WHERE expand(mnreqidx,1,mnreqcnt,pr.privilege_cd,request->privs[mnreqidx].privilege_cd)
      AND pr.active_ind=1
      AND pr.priv_value_cd=privilege_value_cd
      AND plr.priv_loc_reltn_id=pr.priv_loc_reltn_id
      AND plr.person_id > 0
      AND prsnl.person_id=plr.person_id
      AND prsnl.active_ind=1
      AND prsnl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND prsnl.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND pe.privilege_id=pr.privilege_id
      AND pe.exception_type_cd=exception_type_cd))) )
  ELSE
  ENDIF
  INTO "nl"
  person_id = prsnl.person_id, position_cd = prsnl.position_cd, name_full_formatted = prsnl
  .name_full_formatted,
  privilege_id = pr.privilege_id, privilege_cd = pr.privilege_cd, priv_value_cd = pr.priv_value_cd,
  privilege_exception_id = pe.privilege_exception_id, exception_type_cd = pe.exception_type_cd,
  exception_id = pe.exception_id,
  exception_entity_name = pe.exception_entity_name, event_set_name = pe.event_set_name
  FROM privilege pr,
   priv_loc_reltn plr,
   prsnl prsnl,
   privilege_exception pe
  PLAN (pr
   WHERE expand(mnreqidx,1,mnreqcnt,pr.privilege_cd,request->privs[mnreqidx].privilege_cd)
    AND pr.priv_value_cd=privilege_value_cd
    AND pr.active_ind=1)
   JOIN (pe
   WHERE pe.privilege_id=pr.privilege_id
    AND pe.exception_type_cd=exception_type_cd
    AND pe.active_ind=1)
   JOIN (plr
   WHERE plr.priv_loc_reltn_id=pr.priv_loc_reltn_id
    AND (plr.position_cd=request->position_cd)
    AND plr.active_ind=1)
   JOIN (prsnl
   WHERE (prsnl.position_cd=request->position_cd)
    AND prsnl.active_ind=1
    AND ((prsnl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND prsnl.end_effective_dt_tm >= cnvtdatetime(sysdate)) UNION (
   (SELECT
    person_id = prsnl.person_id, position_cd = prsnl.position_cd, name_full_formatted = prsnl
    .name_full_formatted,
    privilege_id = pr.privilege_id, privilege_cd = pr.privilege_cd, priv_value_cd = pr.priv_value_cd,
    privilege_exception_id = pe.privilege_exception_id, exception_type_cd = pe.exception_type_cd,
    exception_id = pe.exception_id,
    exception_entity_name = pe.exception_entity_name, event_set_name = pe.event_set_name
    FROM privilege pr,
     priv_loc_reltn plr,
     prsnl prsnl,
     privilege_exception pe
    WHERE expand(mnreqidx,1,mnreqcnt,pr.privilege_cd,request->privs[mnreqidx].privilege_cd)
     AND pr.active_ind=1
     AND pr.priv_value_cd=privilege_value_cd
     AND plr.priv_loc_reltn_id=pr.priv_loc_reltn_id
     AND (plr.person_id=request->person_id)
     AND (prsnl.person_id=request->person_id)
     AND prsnl.active_ind=1
     AND prsnl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND prsnl.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND pe.privilege_id=pr.privilege_id
     AND pe.exception_type_cd=exception_type_cd))) )
  HEAD REPORT
   mnprsnlcnt = 0
  HEAD person_id
   mnprsnlcnt += 1, mnprivcnt = 0
   IF (mod(mnprsnlcnt,10)=1)
    stat = alterlist(reply->prsnl,(mnprsnlcnt+ 9))
   ENDIF
   reply->prsnl[mnprsnlcnt].person_id = person_id, reply->prsnl[mnprsnlcnt].position_cd = position_cd,
   reply->prsnl[mnprsnlcnt].name_full_formatted = name_full_formatted
  HEAD privilege_id
   mnprivcnt += 1, mnexceptcnt = 0
   IF (mod(mnprivcnt,10)=1)
    stat = alterlist(reply->prsnl[mnprsnlcnt].privs,(mnprivcnt+ 9))
   ENDIF
   reply->prsnl[mnprsnlcnt].privs[mnprivcnt].privilege_id = privilege_id, reply->prsnl[mnprsnlcnt].
   privs[mnprivcnt].privilege_cd = privilege_cd, reply->prsnl[mnprsnlcnt].privs[mnprivcnt].
   priv_value_cd = priv_value_cd
  DETAIL
   mnexceptcnt += 1
   IF (mod(mnexceptcnt,10)=1)
    stat = alterlist(reply->prsnl[mnprsnlcnt].privs[mnprivcnt].exceptionlist,(mnexceptcnt+ 9))
   ENDIF
   reply->prsnl[mnprsnlcnt].privs[mnprivcnt].exceptionlist[mnexceptcnt].privilegeexceptionid =
   privilege_exception_id, reply->prsnl[mnprsnlcnt].privs[mnprivcnt].exceptionlist[mnexceptcnt].
   exception_type_cd = exception_type_cd, reply->prsnl[mnprsnlcnt].privs[mnprivcnt].exceptionlist[
   mnexceptcnt].exceptionid = exception_id,
   reply->prsnl[mnprsnlcnt].privs[mnprivcnt].exceptionlist[mnexceptcnt].exceptionentityname =
   exception_entity_name, reply->prsnl[mnprsnlcnt].privs[mnprivcnt].exceptionlist[mnexceptcnt].
   eventsetname = event_set_name
  FOOT  privilege_id
   stat = alterlist(reply->prsnl[mnprsnlcnt].privs[mnprivcnt].exceptionlist,mnexceptcnt)
  FOOT  person_id
   stat = alterlist(reply->prsnl[mnprsnlcnt].privs,mnprivcnt)
  FOOT REPORT
   stat = alterlist(reply->prsnl,mnprsnlcnt)
  WITH nocounter, rdbunion
 ;end select
 IF (mnprsnlcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="Z"))
  CALL cv_log_msg(cv_audit,"No records found for privileges.")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="F"))
  CALL cv_log_msg(cv_error,"Privileges retrieval failed.")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="S"))
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 1
 ELSE
  CALL cv_log_msg(cv_warning,"Unrecognized reply status")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL cv_log_msg_post("003 04/20/16 MG023115")
END GO

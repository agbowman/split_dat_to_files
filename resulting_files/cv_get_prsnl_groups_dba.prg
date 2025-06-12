CREATE PROGRAM cv_get_prsnl_groups:dba
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
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
    1 prsnl_group[*]
      2 prsnl_group_id = f8
      2 prsnl_group_name = vc
      2 prsnl_group_desc = vc
      2 active_ind = i2
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 prsnl_qual[*]
        3 prsnl_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 RECORD types(
   1 type[*]
     2 prsnl_group_type_cd = f8
 ) WITH protect
 DECLARE c_block_size = i4 WITH protect, constant(20)
 DECLARE g_type_cd = f8 WITH protect
 DECLARE type_cnt = i4 WITH protect
 DECLARE type_idx = i4 WITH protect
 DECLARE padded_type_cnt = i4 WITH protect
 DECLARE group_cnt = i4 WITH protect
 SET stat = uar_get_meaning_by_codeset(357,"CARDIOVASCUL",1,g_type_cd)
 WHILE (g_type_cd > 0.0)
   SET type_cnt += 1
   IF (type_cnt > padded_type_cnt)
    SET padded_type_cnt += c_block_size
    SET stat = alterlist(types->type,padded_type_cnt)
   ENDIF
   SET types->type[type_cnt].prsnl_group_type_cd = g_type_cd
   SET stat = uar_get_meaning_by_codeset(357,"CARDIOVASCUL",(type_cnt+ 1),g_type_cd)
 ENDWHILE
 IF (type_cnt=0)
  CALL cv_log_stat(cv_audit,"UAR_GET_MEANING_BY_CODESET","F","CODE_SET=357","CARDIOVASCUL")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 FOR (type_idx = (type_cnt+ 1) TO padded_type_cnt)
   SET types->type[type_idx].prsnl_group_type_cd = types->type[type_cnt].prsnl_group_type_cd
 ENDFOR
 SELECT INTO "nl"
  FROM (dummyt d  WITH seq = value((padded_type_cnt/ c_block_size))),
   prsnl_group pg
  PLAN (d
   WHERE d.seq > 0)
   JOIN (pg
   WHERE expand(type_idx,(((d.seq - 1) * c_block_size)+ 1),(d.seq * c_block_size),pg
    .prsnl_group_type_cd,types->type[type_idx].prsnl_group_type_cd,
    c_block_size))
  DETAIL
   group_cnt += 1
   IF (group_cnt > size(reply->prsnl_group,5))
    stat = alterlist(reply->prsnl_group,(group_cnt+ 10))
   ENDIF
   reply->prsnl_group[group_cnt].prsnl_group_name = pg.prsnl_group_name, reply->prsnl_group[group_cnt
   ].prsnl_group_desc = pg.prsnl_group_desc, reply->prsnl_group[group_cnt].prsnl_group_id = pg
   .prsnl_group_id,
   reply->prsnl_group[group_cnt].active_ind = pg.active_ind, reply->prsnl_group[group_cnt].
   beg_effective_dt_tm = pg.beg_effective_dt_tm, reply->prsnl_group[group_cnt].end_effective_dt_tm =
   pg.end_effective_dt_tm
  FOOT REPORT
   stat = alterlist(reply->prsnl_group,group_cnt)
  WITH nocounter
 ;end select
 IF (group_cnt=0)
  CALL cv_log_stat(cv_audit,"SELECT","Z","PRSNL_GROUP","")
  CALL echorecord(types)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (validate(request->retrieve_prsnl_ind,0)=1)
  DECLARE padded_group_size = i4 WITH protect, noconstant(c_block_size)
  DECLARE group_idx = i4 WITH protect, noconstant(0)
  DECLARE prsnl_cnt = i4 WITH protect, noconstant(1)
  IF (group_cnt > c_block_size)
   SET padded_group_size = (((group_cnt/ c_block_size) * c_block_size)+ c_block_size)
  ENDIF
  SET stat = alterlist(reply->prsnl_group,padded_group_size)
  FOR (group_idx = (group_cnt+ 1) TO padded_group_size)
    SET reply->prsnl_group[group_idx].prsnl_group_id = reply->prsnl_group[group_cnt].prsnl_group_id
  ENDFOR
  SELECT INTO "nl"
   FROM (dummyt d  WITH seq = value((padded_group_size/ c_block_size))),
    prsnl_group_reltn pgr
   PLAN (d
    WHERE d.seq > 0)
    JOIN (pgr
    WHERE expand(group_idx,(((d.seq - 1) * c_block_size)+ 1),(d.seq * c_block_size),pgr
     .prsnl_group_id,reply->prsnl_group[group_idx].prsnl_group_id,
     c_block_size)
     AND pgr.active_ind=1
     AND pgr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pgr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ORDER BY pgr.prsnl_group_id
   HEAD pgr.prsnl_group_id
    prsnl_cnt = 0, group_idx = locateval(group_idx,(((d.seq - 1) * c_block_size)+ 1),(d.seq *
     c_block_size),pgr.prsnl_group_id,reply->prsnl_group[group_idx].prsnl_group_id)
    IF (group_idx=0)
     CALL cv_log_stat(cv_error,"LOCATEVAL","F","REPLY",build("PRSNL_GROUP_ID=",pgr.prsnl_group_id))
    ENDIF
   DETAIL
    prsnl_cnt += 1
    IF (size(reply->prsnl_group[group_idx].prsnl_qual,5) < prsnl_cnt)
     stat = alterlist(reply->prsnl_group[group_idx].prsnl_qual,(prsnl_cnt+ 10))
    ENDIF
    reply->prsnl_group[group_idx].prsnl_qual[prsnl_cnt].prsnl_id = pgr.person_id
   FOOT  pgr.prsnl_group_id
    stat = alterlist(reply->prsnl_group[group_idx].prsnl_qual,prsnl_cnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->prsnl_group,group_cnt)
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL cv_log_msg_post("003 04/29/2011 FE2417")
END GO

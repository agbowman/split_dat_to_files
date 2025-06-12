CREATE PROGRAM cv_get_study_uid_hx:dba
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
 IF (validate(reply)=0)
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
 DECLARE c_block_size = i4 WITH protect, constant(20)
 DECLARE study_state_mv = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"MV"))
 DECLARE study_state_mvu = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"MVU"))
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE proc_cnt = i4 WITH protect, noconstant(size(request->cv_historical_procs,5))
 DECLARE proc_idx = i4 WITH protect
 DECLARE proc_pad = i4 WITH protect
 DECLARE match_cnt = i4 WITH protect
 DECLARE match_idx = i4 WITH protect
 DECLARE match_pad = i4 WITH protect
 IF (proc_cnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 FREE RECORD matched
 RECORD matched(
   1 qual[*]
     2 im_study_id = f8
     2 procs[*]
       3 proc_idx = i4
 )
 SET proc_pad = (proc_cnt+ ((c_block_size - 1) - mod((proc_cnt - 1),c_block_size)))
 SET stat = alterlist(request->cv_historical_procs,proc_pad)
 FOR (proc_idx = (proc_cnt+ 1) TO proc_pad)
   SET request->cv_historical_procs[proc_idx].cv_proc_hx_id = request->cv_historical_procs[proc_cnt].
   cv_proc_hx_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((proc_pad/ c_block_size))),
   im_study_parent_r imspr,
   im_study ims
  PLAN (d
   WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ c_block_size))))
   JOIN (imspr
   WHERE expand(proc_idx,nstart,((nstart+ c_block_size) - 1),imspr.parent_entity_id,request->
    cv_historical_procs[proc_idx].cv_proc_hx_id)
    AND imspr.parent_entity_name="CV_PROC_HX")
   JOIN (ims
   WHERE ims.im_study_id=imspr.im_study_id)
  ORDER BY ims.im_study_id
  HEAD REPORT
   stat = alterlist(request->cv_historical_procs,proc_cnt)
  HEAD ims.im_study_id
   IF (ims.study_state_cd IN (study_state_mv, study_state_mvu))
    match_cnt += 1
    IF (match_cnt > match_pad)
     match_pad += c_block_size, stat = alterlist(matched->qual,match_pad)
    ENDIF
    matched->qual[match_cnt].im_study_id = ims.im_study_id, l_matched_p_ind = 1
   ELSE
    l_matched_p_ind = 0
   ENDIF
   l_matched_p_cnt = 0
  DETAIL
   proc_idx = locateval(proc_idx,(1+ ((d.seq - 1) * c_block_size)),proc_cnt,imspr.parent_entity_id,
    request->cv_historical_procs[proc_idx].cv_proc_hx_id), request->cv_historical_procs[proc_idx].
   created_study_uid = ims.created_study_uid, request->cv_historical_procs[proc_idx].study_uid = ims
   .study_uid,
   request->cv_historical_procs[proc_idx].study_state_cd = ims.study_state_cd,
   CALL cv_log_msg(cv_debug,build("proc_idx =",proc_idx))
   IF (l_matched_p_ind=1)
    l_matched_p_cnt += 1, stat = alterlist(matched->qual[match_cnt].procs,l_matched_p_cnt), matched->
    qual[match_cnt].procs[l_matched_p_cnt].proc_idx = proc_idx
   ENDIF
  FOOT REPORT
   col 0
  WITH nocounter
 ;end select
 IF (match_cnt > 0)
  FOR (match_idx = (match_cnt+ 1) TO match_pad)
    SET matched->qual[match_idx].im_study_id = matched->qual[match_cnt].im_study_id
  ENDFOR
  SELECT DISTINCT INTO "nl:"
   imas.matched_study_id
   FROM (dummyt d  WITH seq = value((match_pad/ c_block_size))),
    im_acquired_study imas,
    im_device imd
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ c_block_size))))
    JOIN (imas
    WHERE expand(match_idx,nstart,((nstart+ c_block_size) - 1),imas.matched_study_id,matched->qual[
     match_idx].im_study_id))
    JOIN (imd
    WHERE imd.im_device_id=imas.im_device_id)
   DETAIL
    match_idx = locateval(match_idx,(1+ ((d.seq - 1) * c_block_size)),match_cnt,imas.matched_study_id,
     matched->qual[match_idx].im_study_id), l_matched_p_cnt = size(matched->qual[match_idx].procs,5)
    FOR (l_matched_p_idx = 1 TO l_matched_p_cnt)
      proc_idx = matched->qual[match_idx].procs[l_matched_p_idx].proc_idx, request->
      cv_historical_procs[proc_idx].device_name = imd.device_name, request->cv_historical_procs[
      proc_idx].ip_address = imd.ip_address,
      request->cv_historical_procs[proc_idx].station_name = imas.station_name
    ENDFOR
   WITH nocounter
  ;end select
 ELSE
  CALL cv_log_msg(cv_debug,"No matched studies found in worklist")
 ENDIF
 FREE RECORD matched
 SET stat = alterlist(request->cv_historical_procs,proc_cnt)
 SET reply->status_data.status = "S"
#exit_script
 CALL cv_log_msg_post("000 08/20/18 PK035073")
END GO

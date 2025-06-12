CREATE PROGRAM cv_utl_clear_dup_event:dba
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
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD events
 RECORD events(
   1 total_cnt = i4
   1 list[*]
     2 group_event_id = f8
     2 found_ind = f8
     2 proc_cnt = i4
     2 procs[*]
       3 proc_idx = i4
 )
 FREE RECORD procs
 RECORD procs(
   1 total_cnt = i4
   1 list[*]
     2 event_idx = i4
     2 cv_proc_id = f8
     2 ref_nbr = vc
     2 keep_ind = i2
 )
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REPLY","Reply doesn't contain status block")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 DECLARE event_idx = i4 WITH protect
 DECLARE proc_idx = i4 WITH protect
 DECLARE event_cnt = i4 WITH protect
 DECLARE proc_cnt = i4 WITH prortect
 DECLARE err_string = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE err_code = i2 WITH protect, noconstant(error(err_string,1))
 DECLARE cur_list_size = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 DECLARE new_list_size = i4 WITH protect
 DECLARE nstart = i4 WITH protect
 DECLARE batch_size = i4 WITH protect, constant(20)
 SELECT INTO "nl:"
  cp.group_event_id
  FROM cv_proc cp
  WHERE cp.group_event_id != 0.0
  GROUP BY cp.group_event_id
  HAVING count(*) > 1
  ORDER BY cp.group_event_id
  HEAD REPORT
   event_cnt = 0
  DETAIL
   event_cnt += 1
   IF (event_cnt > size(events->list,5))
    stat = alterlist(events->list,(event_cnt+ 10))
   ENDIF
   events->list[event_cnt].group_event_id = cp.group_event_id
  FOOT REPORT
   stat = alterlist(events->list,event_cnt), cur_list_size = event_cnt, events->total_cnt = event_cnt
  WITH nocounter
 ;end select
 IF ((events->total_cnt=0))
  CALL cv_log_stat(cv_info,"SELECT","Z","CV_PROC","No duplicate group_event_ids found")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(events->list,new_list_size)
 SET nstart = 1
 FOR (event_idx = (cur_list_size+ 1) TO new_list_size)
   SET events->list[event_idx].group_event_id = events->list[cur_list_size].group_event_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   cv_proc cp
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cp
   WHERE expand(event_idx,nstart,(nstart+ (batch_size - 1)),cp.group_event_id,events->list[event_idx]
    .group_event_id))
  ORDER BY cp.group_event_id
  HEAD REPORT
   proc_cnt = 0
  HEAD cp.group_event_id
   event_idx = locateval(event_idx,1,cur_list_size,cp.group_event_id,events->list[event_idx].
    group_event_id), stat = alterlist(events->list[event_idx].procs,10), event_proc_cnt = 0
  DETAIL
   proc_cnt += 1, event_proc_cnt += 1
   IF (proc_cnt > size(procs->list,5))
    stat = alterlist(procs->list,(proc_cnt+ 10))
   ENDIF
   procs->list[proc_cnt].event_idx = event_idx, procs->list[proc_cnt].cv_proc_id = cp.cv_proc_id,
   procs->list[proc_cnt].ref_nbr = concat("CV_PROC:",trim(cnvtstring(cp.cv_proc_id))),
   events->list[event_idx].procs[event_proc_cnt].proc_idx = proc_cnt
  FOOT  cp.group_event_id
   events->list[event_idx].proc_cnt = event_proc_cnt
  FOOT REPORT
   stat = alterlist(procs->list,proc_cnt), procs->total_cnt = proc_cnt
  WITH nocounter, forupdate(cp)
 ;end select
 SET stat = alterlist(events->list,cur_list_size)
 IF (curqual=0)
  CALL cv_log_msg(cv_error,"CV_PROC rows are locked. Cannot update.")
  GO TO exit_script
 ENDIF
 SET cur_list_size = procs->total_cnt
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(procs->list,new_list_size)
 SET nstart = 1
 FOR (proc_idx = (cur_list_size+ 1) TO new_list_size)
   SET procs->list[proc_idx].cv_proc_id = procs->list[cur_list_size].cv_proc_id
 ENDFOR
 SELECT INTO "nl:"
  ce.event_id
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   clinical_event ce
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (ce
   WHERE expand(proc_idx,nstart,(nstart+ (batch_size - 1)),ce.reference_nbr,procs->list[proc_idx].
    ref_nbr)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
  ORDER BY ce.event_id
  HEAD ce.event_id
   proc_idx = locateval(proc_idx,1,cur_list_size,ce.reference_nbr,procs->list[proc_idx].ref_nbr),
   events->list[procs->list[proc_idx].event_idx].found_ind = 1, procs->list[proc_idx].keep_ind = 1
  WITH nocounter
 ;end select
 SET stat = alterlist(procs->list,procs->total_cnt)
 FOR (event_idx = 1 TO events->total_cnt)
   IF ((events->list[event_idx].found_ind=0))
    FOR (proc_idx = 1 TO events->list[event_idx].proc_cnt)
      SET procs->list[events->list[event_idx].procs[proc_idx].proc_idx].keep_ind = 1
    ENDFOR
   ENDIF
 ENDFOR
 UPDATE  FROM (dummyt d1  WITH seq = value(procs->total_cnt)),
   cv_proc cp
  SET cp.group_event_id = 0.0, cp.updt_applctx = reqinfo->updt_applctx, cp.updt_cnt = (cp.updt_cnt+ 1
   ),
   cp.updt_dt_tm = cnvtdatetime(sysdate), cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->
   updt_task
  PLAN (d1
   WHERE (procs->list[d1.seq].keep_ind=0))
   JOIN (cp
   WHERE (cp.cv_proc_id=procs->list[d1.seq].cv_proc_id))
  WITH nocounter
 ;end update
 IF (error(err_string,0))
  CALL cv_log_stat(cv_error,"UPDATE","F","CV_PROC",err_string)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  CALL echo("All results updated successfully! Please commit results by running COMMIT GO")
 ELSEIF ((reply->status_data.status="Z"))
  CALL echo("No procs to update.")
 ELSE
  CALL echorecord(procs)
  CALL echorecord(events)
  CALL echo("Update was unsuccessful. Rolling back changes.")
  ROLLBACK
 ENDIF
 CALL cv_log_msg_post("MOD 001 BM9013 11/05/2007")
END GO

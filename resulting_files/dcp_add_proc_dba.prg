CREATE PROGRAM dcp_add_proc:dba
 RECORD reply(
   1 procedure_id = f8
   1 proc_prsnl_reltn_id = f8
   1 long_text_id = f8
   1 proc_prsnl_reltn_ids[*]
     2 proc_prsnl_reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET procedure_id = 0.0
 SET proc_prsnl_reltn_id = 0.0
 SET msg_text_id = 0.0
 SET active_ind = 1
 IF ((request->use_active_ind=1))
  SET active_ind = request->active_ind
 ENDIF
 SET comment_ind = 0
 IF ((request->comment_ind=1)
  AND (request->text > " "))
  SET comment_ind = 1
 ELSE
  SET comment_ind = 0
 ENDIF
 SET ft_prsnl = 0
 SET proc_prsnl_id = 0
 IF ((request->proc_prsnl_ft_ind=1)
  AND (request->proc_ft_prsnl > " "))
  SET ft_prsnl = 1
  SET proc_prsnl_id = 0
 ELSE
  SET proc_prsnl_id = request->proc_prsnl_id
 ENDIF
 SELECT INTO "nl:"
  j = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   procedure_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 INSERT  FROM procedure p
  SET p.procedure_id = procedure_id, p.encntr_id = request->encntr_id, p.nomenclature_id = request->
   nomenclature_id,
   p.proc_ftdesc = request->proc_ft_nomen, p.proc_dt_tm = cnvtdatetime(request->proc_dt_tm), p
   .proc_ft_dt_tm_ind = request->proc_ft_dt_tm_ind,
   p.proc_ft_time_frame = request->proc_ft_time_frame, p.proc_loc_cd = request->proc_loc_cd, p
   .proc_loc_ft_ind = request->proc_loc_ft_ind,
   p.proc_ft_loc = request->proc_ft_loc, p.comment_ind = comment_ind, p.active_ind = active_ind,
   p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), p.active_status_prsnl_id = reqinfo->updt_id,
   p.contributor_system_cd = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->
   updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
   p.proc_type_flag = 2
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "procedure table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (((ft_prsnl=1) OR ((request->proc_prsnl_id > 0))) )
  SELECT INTO "nl:"
   j = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    proc_prsnl_reltn_id = cnvtreal(j)
   WITH format, nocounter
  ;end select
  INSERT  FROM proc_prsnl_reltn p
   SET p.proc_prsnl_reltn_id = proc_prsnl_reltn_id, p.prsnl_person_id = proc_prsnl_id, p
    .proc_prsnl_ft_ind = ft_prsnl,
    p.proc_ft_prsnl = request->proc_ft_prsnl, p.proc_prsnl_reltn_cd = request->proc_prsnl_reltn_cd, p
    .procedure_id = procedure_id,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
    reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0, p.active_ind = 1,
    p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), p.active_status_prsnl_id = reqinfo->updt_id,
    p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
     "31-Dec-2100"), p.contributor_system_cd = 0,
    p.free_text_cd = 0, p.ft_prsnl_name = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET reltns_count = 0
 SET request_reltns = size(request->proc_prsnl_reltns,5)
 SET stat = alterlist(reply->proc_prsnl_reltn_ids,request_reltns)
 FOR (x = 1 TO request_reltns)
   IF ((((request->proc_prsnl_reltns[x].proc_ft_prsnl > " ")) OR ((request->proc_prsnl_reltns[x].
   proc_prsnl_id > 0))) )
    SELECT INTO "nl:"
     j = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      proc_prsnl_reltn_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    INSERT  FROM proc_prsnl_reltn p
     SET p.proc_prsnl_reltn_id = proc_prsnl_reltn_id, p.prsnl_person_id = request->proc_prsnl_reltns[
      x].proc_prsnl_id, p.proc_prsnl_ft_ind =
      IF ((request->proc_prsnl_reltns[x].proc_ft_prsnl > " ")) 1
      ELSE 0
      ENDIF
      ,
      p.proc_ft_prsnl = request->proc_prsnl_reltns[x].proc_ft_prsnl, p.proc_prsnl_reltn_cd = request
      ->proc_prsnl_reltns[x].proc_prsnl_reltn_cd, p.procedure_id = procedure_id,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
      reqinfo->updt_task,
      p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0, p.active_ind = 1,
      p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), p.active_status_prsnl_id = reqinfo->updt_id,
      p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
       "31-Dec-2100"), p.contributor_system_cd = 0,
      p.free_text_cd = 0, p.ft_prsnl_name = 0
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET reltns_count = (reltns_count+ 1)
     SET reply->proc_prsnl_reltn_ids[reltns_count].proc_prsnl_reltn_id = proc_prsnl_reltn_id
    ELSE
     SET reply->status_data.subeventstatus[1].targetobjectname = "proc_prsnl_reltn table"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Unable to insert into proc_prsnl_reltn."
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->proc_prsnl_reltn_ids,reltns_count)
 IF (comment_ind=1)
  SET msg_text_id = 0.0
  SELECT INTO "nl:"
   nextseqnum = seq(long_data_seq,nextval)"#################;rp0"
   FROM dual
   DETAIL
    msg_text_id = cnvtreal(nextseqnum)
   WITH format
  ;end select
  IF (msg_text_id=0.0)
   GO TO exit_script
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = msg_text_id, lt.parent_entity_name = "PROCEDURE", lt.parent_entity_id =
    procedure_id,
    lt.long_text = request->text, lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   GO TO exit_script
  ENDIF
  UPDATE  FROM procedure p
   SET p.long_text_id = msg_text_id
   WHERE p.procedure_id=procedure_id
   WITH nocounter
  ;end update
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->procedure_id = procedure_id
  SET reply->proc_prsnl_reltn_id = proc_prsnl_reltn_id
  SET reply->long_text_id = msg_text_id
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 SET script_ver = "006 03/08/05 SF3151"
END GO

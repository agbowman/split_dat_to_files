CREATE PROGRAM cqm_upt_fsieso_que:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 cqm_fsieso_que_qual = i2
    1 cqm_fsieso_que[10]
      2 queue_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  IF ((request->cqm_fsieso_que_qual=0))
   SET request->cqm_fsieso_que_qual = size(request->cqm_fsieso_que,5)
  ENDIF
  SET action_begin = 1
  SET action_end = request->cqm_fsieso_que_qual
  SET reply->cqm_fsieso_que_qual = request->cqm_fsieso_que_qual
  SET stat = alter(reply->cqm_fsieso_que,request->cqm_fsieso_que_qual)
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "CQM_FSIESO_QUE"
 CALL upt_cqm_fsieso_que(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE upt_cqm_fsieso_que(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET active_status_code = 0
     SELECT INTO "nl:"
      c.queue_id
      FROM cqm_fsieso_que c
      WHERE (c.queue_id=request->cqm_fsieso_que[x].queue_id)
      WITH forupdate(c)
     ;end select
     IF (curqual=0)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM cqm_fsieso_que c
      SET c.contributor_id = evaluate(request->cqm_fsieso_que[x].contributor_id,0.0,c.contributor_id,
        - (1.0),0.0,
        request->cqm_fsieso_que[x].contributor_id), c.contributor_refnum = evaluate(request->
        cqm_fsieso_que[x].contributor_refnum," ",c.contributor_refnum,'""',null,
        request->cqm_fsieso_que[x].contributor_refnum), c.contributor_event_dt_tm = evaluate(request
        ->cqm_fsieso_que[x].contributor_event_dt_tm,0.0,c.contributor_event_dt_tm,blank_date,null,
        cnvtdatetime(request->cqm_fsieso_que[x].contributor_event_dt_tm)),
       c.process_status_flag = evaluate(request->cqm_fsieso_que[x].process_status_flag_ind,0,c
        .process_status_flag,1,request->cqm_fsieso_que[x].process_status_flag,
        c.process_status_flag), c.priority = evaluate(request->cqm_fsieso_que[x].priority,0,c
        .priority,- (1),0.0,
        request->cqm_fsieso_que[x].priority), c.trig_module_identifier = evaluate(request->
        cqm_fsieso_que[x].trig_module_identifier," ",c.trig_module_identifier,'""',null,
        request->cqm_fsieso_que[x].trig_module_identifier),
       c.trig_create_start_dt_tm = evaluate(request->cqm_fsieso_que[x].trig_create_start_dt_tm,0.0,c
        .trig_create_start_dt_tm,blank_date,null,
        cnvtdatetime(request->cqm_fsieso_que[x].trig_create_start_dt_tm)), c.trig_create_end_dt_tm =
       evaluate(request->cqm_fsieso_que[x].trig_create_end_dt_tm,0.0,c.trig_create_end_dt_tm,
        blank_date,null,
        cnvtdatetime(request->cqm_fsieso_que[x].trig_create_end_dt_tm)), c.class = evaluate(request->
        cqm_fsieso_que[x].class," ",c.class,'""',null,
        request->cqm_fsieso_que[x].class),
       c.type = evaluate(request->cqm_fsieso_que[x].type," ",c.type,'""',null,
        request->cqm_fsieso_que[x].type), c.subtype = evaluate(request->cqm_fsieso_que[x].subtype," ",
        c.subtype,'""',null,
        request->cqm_fsieso_que[x].subtype), c.subtype_detail = evaluate(request->cqm_fsieso_que[x].
        subtype_detail," ",c.subtype_detail,'""',null,
        request->cqm_fsieso_que[x].subtype_detail),
       c.debug_ind = evaluate(request->cqm_fsieso_que[x].debug_ind_ind,0,c.debug_ind,1,request->
        cqm_fsieso_que[x].debug_ind,
        c.debug_ind), c.verbosity_flag = evaluate(request->cqm_fsieso_que[x].verbosity_flag_ind,0,c
        .verbosity_flag,1,request->cqm_fsieso_que[x].verbosity_flag,
        c.verbosity_flag), c.updt_cnt = (c.updt_cnt+ 1),
       c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->
       updt_applctx,
       c.updt_task = reqinfo->updt_task
      WHERE (c.queue_id=request->cqm_fsieso_que[x].queue_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->cqm_fsieso_que[x].queue_id = request->cqm_fsieso_que[x].queue_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO

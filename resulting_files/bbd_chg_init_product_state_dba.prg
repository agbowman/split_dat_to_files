CREATE PROGRAM bbd_chg_init_product_state:dba
 RECORD reply(
   1 qual[*]
     2 initial_product_state_id = f8
     2 state_cd = f8
     2 state_cd_disp = vc
     2 updt_cnt = i4
     2 add_row = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET count1 = 0
 SET y = 0
 SET state_id = 0.0
 SET reply->status_data.status = "F"
 SET failed = "F"
 FOR (y = 1 TO request->state_count)
   IF ((request->qual[y].add_row=1))
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_pathnet_seq = cnvtint(seqn)
     WITH format, nocounter
    ;end select
    SET state_id = new_pathnet_seq
    INSERT  FROM initial_product_state i
     SET i.initial_product_state_id = state_id, i.procedure_cd = request->procedure_cd, i.outcome_cd
       = request->outcome_cd,
      i.state_cd = request->qual[y].state_cd, i.active_ind = 1, i.active_type_cd = reqdata->
      active_status_cd,
      i.active_dt_tm = cnvtdatetime(curdate,curtime3), i.inactive_dt_tm = null, i.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      i.updt_id = reqinfo->updt_id, i.updt_cnt = 0, i.updt_task = reqinfo->updt_task,
      i.updt_applctx = reqinfo->updt_applctx, i.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_init_product_state"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "initial_product_state"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "state insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].initial_product_state_id = state_id
     SET reply->qual[y].state_cd = request->qual[y].state_cd
     SET reply->qual[y].add_row = 1
     SET reply->qual[y].updt_cnt = 0
    ENDIF
   ELSE
    SELECT INTO "nl:"
     i.*
     FROM initial_product_state i
     WHERE (i.initial_product_state_id=request->qual[y].initial_product_state_id)
      AND (i.updt_cnt=request->qual[y].updt_cnt)
     WITH counter, forupdate(i)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_init_product_state"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "initial_product_state"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "initial product state lock"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ENDIF
    UPDATE  FROM initial_product_state i
     SET i.active_ind = 0, i.active_type_cd = reqdata->inactive_status_cd, i.inactive_dt_tm =
      cnvtdatetime(curdate,curtime3),
      i.updt_dt_tm = cnvtdatetime(curdate,curtime3), i.updt_id = reqinfo->updt_id, i.updt_cnt = (
      request->qual[y].updt_cnt+ 1),
      i.updt_task = reqinfo->updt_task, i.updt_applctx = reqinfo->updt_applctx
     WHERE (i.initial_product_state_id=request->qual[y].initial_product_state_id)
      AND (i.updt_cnt=request->qual[y].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_init_product_state"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "initial_product_state"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "intial_product_state"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].initial_product_state_id = request->qual[y].initial_product_state_id
     SET reply->qual[y].state_cd = request->qual[y].state_cd
     SET reply->qual[y].add_row = 1
     SET reply->qual[y].updt_cnt = (request->qual[y].updt_cnt+ 1)
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO

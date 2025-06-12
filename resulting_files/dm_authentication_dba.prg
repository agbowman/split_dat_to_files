CREATE PROGRAM dm_authentication:dba
 SUBROUTINE delete_transaction_data(delete_cv)
   SET trans_cnt = 0
   FREE DEFINE trans
   RECORD trans(
     1 list[*]
       2 transaction_activity_id = f8
   )
   SELECT INTO "nl:"
    d.seq
    FROM dm_transaction_data d
    WHERE d.field_num_value=delete_cv
    DETAIL
     trans_cnt = (trans_cnt+ 1), stat = alterlist(trans->list,trans_cnt), trans->list[trans_cnt].
     transaction_activity_id = d.transaction_activity_id
    WITH nocounter
   ;end select
   DELETE  FROM dm_transaction_data dm
    WHERE dm.field_num_value=delete_cv
    WITH nocounter
   ;end delete
   FOR (x = 1 TO trans_cnt)
    SELECT INTO "nl:"
     dm.seq
     FROM dm_transaction_data dm
     WHERE (dm.transaction_activity_id=trans->list[x].transaction_activity_id)
     WITH nocounter
    ;end select
    IF (curqual=0)
     DELETE  FROM dm_transaction_key dm
      WHERE (dm.transaction_activity_id=trans->list[x].transaction_activity_id)
      WITH nocounter
     ;end delete
     DELETE  FROM dm_transaction_activity dm
      WHERE (dm.transaction_activity_id=trans->list[x].transaction_activity_id)
      WITH nocounter
     ;end delete
    ENDIF
   ENDFOR
 END ;Subroutine
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 UPDATE  FROM code_value c
  SET c.active_ind = true, c.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), c
   .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
   c.active_type_cd = request->active_cd, c.inactive_dt_tm = null, c.data_status_cd = request->
   auth_cd,
   c.data_status_prsnl_id = request->current_user_id, c.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3), c.updt_id = request->current_user_id,
   c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = 2218, c.updt_applctx = 2218,
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE (c.code_value=request->code_value)
  WITH nocounter
 ;end update
 CALL delete_transaction_data(request->code_value)
 SET reply->status_data.status = "S"
 COMMIT
END GO

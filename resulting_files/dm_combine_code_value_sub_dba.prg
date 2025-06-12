CREATE PROGRAM dm_combine_code_value_sub:dba
 SET reply->status_data.status = "F"
 SET parser_buffer[10] = fillstring(132," ")
 SET pn = 0
 SET ccv_err_ind = 0
 SET ccv_err_msg = fillstring(132," ")
 SET cec_p = 0
 FREE DEFINE cmb
 RECORD cmb(
   1 data[*]
     2 transaction_activity_id = f8
     2 field_name = c32
     2 ky_cnt = i4
     2 ky[*]
       3 field_name = c32
       3 field_num_value = f8
       3 entity_name = c32
 )
 SET data_cnt = 0
 IF (more_combine_rows=1)
  SET more_combine_rows = 0
  SELECT INTO "nl:"
   dm.transaction_activity_id, dm.field_name
   FROM dm_transaction_data dm
   WHERE (dm.field_num_value=request->code_value)
    AND sqlpassthru("rownum<501")
   DETAIL
    data_cnt = (data_cnt+ 1), stat = alterlist(cmb->data,data_cnt), cmb->data[data_cnt].
    transaction_activity_id = dm.transaction_activity_id,
    cmb->data[data_cnt].field_name = dm.field_name
   WITH nocounter
  ;end select
  CALL ccv_err_chk(0)
  IF (data_cnt=500)
   SET more_combine_rows = 1
  ENDIF
 ENDIF
 FOR (x = 1 TO data_cnt)
   SET ky_cnt = 0
   SELECT INTO "nl:"
    dm1.seq
    FROM dm_transaction_key dm1,
     dm_transaction_activity dm2
    PLAN (dm1
     WHERE (dm1.transaction_activity_id=cmb->data[x].transaction_activity_id))
     JOIN (dm2
     WHERE dm2.transaction_activity_id=dm1.transaction_activity_id)
    DETAIL
     ky_cnt = (ky_cnt+ 1), stat = alterlist(cmb->data[x].ky,ky_cnt), cmb->data[x].ky[ky_cnt].
     field_name = dm1.field_name,
     cmb->data[x].ky[ky_cnt].field_num_value = dm1.field_num_value, cmb->data[x].ky[ky_cnt].
     entity_name = dm2.entity_name
    WITH nocounter
   ;end select
   CALL ccv_err_chk(0)
   SET cmb->data[x].ky_cnt = ky_cnt
 ENDFOR
 FOR (x = 1 TO data_cnt)
   SET alias = substring(1,1,cmb->data[x].ky[1].entity_name)
   SET parser_buffer[1] = concat("update into ",trim(cmb->data[x].ky[1].entity_name)," ",alias)
   SET parser_buffer[2] = concat("set ",alias,".",trim(cmb->data[x].field_name)," = ",
    cnvtstring(request->to_cv),",")
   SET parser_buffer[3] = concat("    ",alias,".updt_dt_tm = cnvtdatetime(curdate, curtime3),")
   SET parser_buffer[4] = concat("    ",alias,".updt_id = request->current_user_id,")
   SET parser_buffer[5] = concat("    ",alias,".updt_task = 2218,")
   SET parser_buffer[6] = concat("    ",alias,".updt_applctx = 2218,")
   SET parser_buffer[7] = concat("    ",alias,".updt_cnt = ",alias,".updt_cnt+1")
   SET pn = 7
   FOR (y = 1 TO cmb->data[x].ky_cnt)
    SET pn = (pn+ 1)
    IF (pn=8)
     SET parser_buffer[pn] = concat("where ",alias,".",trim(cmb->data[x].ky[y].field_name)," = ",
      cnvtstring(cmb->data[x].ky[y].field_num_value))
    ELSE
     SET parser_buffer[pn] = concat("and ",alias,".",trim(cmb->data[x].ky[y].field_name)," = ",
      cnvtstring(cmb->data[x].ky[y].field_num_value))
    ENDIF
   ENDFOR
   SET pn = (pn+ 1)
   SET parser_buffer[pn] = concat("and ",alias,".",trim(cmb->data[x].field_name),"+0 = ",
    cnvtstring(request->from_cv))
   SET pn = (pn+ 1)
   SET parser_buffer[pn] = "go"
   SET z = 1
   SET stat = alterlist(reply->sql,pn)
   FOR (z = 1 TO pn)
     SET reply->sql[z].line = parser_buffer[z]
   ENDFOR
   FOR (z = 1 TO pn)
     CALL parser(parser_buffer[z],1)
   ENDFOR
   CALL ccv_err_chk(0)
 ENDFOR
 FOR (x = 1 TO data_cnt)
  DELETE  FROM dm_transaction_data dm
   WHERE (dm.transaction_activity_id=cmb->data[x].transaction_activity_id)
    AND (dm.field_name=cmb->data[x].field_name)
   WITH nocounter
  ;end delete
  CALL ccv_err_chk(0)
 ENDFOR
 FOR (x = 1 TO data_cnt)
   SELECT INTO "nl:"
    dm.seq
    FROM dm_transaction_data dm
    WHERE (dm.transaction_activity_id=cmb->data[x].transaction_activity_id)
    WITH nocounter
   ;end select
   CALL ccv_err_chk(0)
   IF (curqual=0)
    DELETE  FROM dm_transaction_key dm
     WHERE (dm.transaction_activity_id=cmb->data[x].transaction_activity_id)
     WITH nocounter
    ;end delete
    CALL ccv_err_chk(0)
    DELETE  FROM dm_transaction_activity dm
     WHERE (dm.transaction_activity_id=cmb->data[x].transaction_activity_id)
     WITH nocounter
    ;end delete
    CALL ccv_err_chk(0)
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 COMMIT
 SUBROUTINE ccv_err_chk(cec_p)
  SET ccv_err_ind = error(ccv_err_msg,1)
  IF (ccv_err_ind > 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
END GO

CREATE PROGRAM dm_housekeepingb:dba
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
 FREE DEFINE cv2
 RECORD cv2(
   1 list[*]
     2 code_value = f8
 )
 SET cv2_cnt = 0
 SELECT DISTINCT INTO "nl:"
  dtd.field_num_value
  FROM dm_transaction_data dtd
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM code_value cv
   WHERE dtd.field_num_value=cv.code_value)))
  DETAIL
   cv2_cnt = (cv2_cnt+ 1), stat = alterlist(cv2->list,cv2_cnt), cv2->list[cv2_cnt].code_value = dtd
   .field_num_value
  WITH nocounter
 ;end select
 FOR (i = 1 TO cv2_cnt)
  CALL delete_transaction_data(cv2->list[i].code_value)
  COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
END GO

CREATE PROGRAM bmdi_get_result_seq:dba
 RECORD reply(
   1 first_result_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE first_resultid = f8
 DECLARE id_cnt = i4
 DECLARE i = i4
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  nextseqnum = seq(bmdi_seq,nextval)"#################;RP0"
  FROM dual
  DETAIL
   first_resultid = nextseqnum
  WITH nocounter
 ;end select
 SET reply->first_result_id = first_resultid
 SELECT INTO "nl:"
  FROM user_sequences us
  WHERE us.sequence_name="BMDI_SEQ"
   AND increment_by > 1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET id_cnt = 0
 ELSE
  SET id_cnt = (request->resultid_cnt - 1)
 ENDIF
 IF (id_cnt > 0)
  FOR (i = 1 TO id_cnt)
    SELECT INTO "nl:"
     nextseqnum = seq(bmdi_seq,nextval)"#################;RP0"
     FROM dual
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
END GO

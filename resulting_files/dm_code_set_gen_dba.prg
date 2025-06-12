CREATE PROGRAM dm_code_set_gen:dba
 RECORD reply(
   1 code_set = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET next_code_set = 0
 SELECT INTO "NL:"
  temp_code_set = seq(code_set_seq,nextval)
  FROM dual
  DETAIL
   next_code_set = temp_code_set
  WITH nocounter
 ;end select
 IF (next_code_set > 0)
  SET reply->status_data.status = "S"
  SET reply->code_set = next_code_set
 ELSE
  SET reply->status_data.status = "F"
  SET reply->code_set = 0
 ENDIF
END GO

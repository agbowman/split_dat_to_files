CREATE PROGRAM act_get_space_seq:dba
 RECORD reply(
   1 space_seq = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SELECT INTO "nl:"
  y = seq(object_space_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   cnt = (cnt+ 1), entryid = cnvtreal(y), reply->space_seq = entryid
  WITH format, nocounter
 ;end select
#exit_program
 IF (cnt=0)
  SET reply->status_data.status = "Z"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO

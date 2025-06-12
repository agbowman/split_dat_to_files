CREATE PROGRAM dm_ccb_set_collation_seq:dba
 IF (validate(reply)=0)
  FREE RECORD reply
  RECORD reply(
    1 curqual = i4
    1 qual[*]
      2 status = i2
      2 error_num = i4
      2 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE errorcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE cv_list_size = i4 WITH protect, noconstant(0)
 IF (size(request->cv_list,5) < 1)
  SET failed = "T"
  SET stat = alterlist(reply->qual,1)
  SET reply->qual[1].status = 0
  SET reply->qual[1].error_msg = "List of code values is empty"
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSE
  SET cv_list_size = size(request->cv_list,5)
  SET stat = alterlist(reply->qual,1)
  UPDATE  FROM code_value cv,
    (dummyt d  WITH seq = cv_list_size)
   SET cv.collation_seq = request->cv_list[d.seq].seq_num
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=request->cv_list[d.seq].code_value))
   WITH nocounter, rdbarrayinsert = 1
  ;end update
  SET reply->curqual = curqual
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->qual[1].status = 0
   SET reply->qual[1].error_num = errorcode
   SET reply->qual[1].error_msg = errmsg
   SET reply->status_data.status = "F"
  ELSE
   SET reply->qual[1].status = 1
   SET reply->qual[1].error_num = 0
   SET reply->qual[1].error_msg = ""
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 IF (failed != "T")
  COMMIT
 ENDIF
END GO

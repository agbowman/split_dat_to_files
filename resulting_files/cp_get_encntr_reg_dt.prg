CREATE PROGRAM cp_get_encntr_reg_dt
 RECORD reply(
   1 reg_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "NL:"
  e.reg_dt_tm
  FROM encounter e
  WHERE (e.encntr_id=request->encntr_id)
  DETAIL
   reply->reg_dt_tm = e.reg_dt_tm
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo(build("status = ",reply->status_data.status))
 CALL echo(build("reg_dt_tm = ",reply->reg_dt_tm))
END GO

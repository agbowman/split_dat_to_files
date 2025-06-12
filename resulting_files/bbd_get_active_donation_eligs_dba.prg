CREATE PROGRAM bbd_get_active_donation_eligs:dba
 RECORD reply(
   1 qual[*]
     2 procedure_cd = f8
     2 prev_procedure_cd = f8
     2 days_until_eligible = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  p.*
  FROM procedure_eligibility_r p
  WHERE (p.procedure_cd=request->procedure_cd)
   AND cnvtdatetime(curdate,curtime3) >= p.begin_effective_dt_tm
   AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
   AND p.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].procedure_cd = p
   .procedure_cd,
   reply->qual[count].prev_procedure_cd = p.prev_procedure_cd, reply->qual[count].days_until_eligible
    = p.days_until_eligible
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO

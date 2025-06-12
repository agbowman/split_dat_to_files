CREATE PROGRAM bbd_get_donation_elig:dba
 RECORD reply(
   1 qual[*]
     2 procedure_eligibility_id = f8
     2 procedure_cd = f8
     2 prev_procedure_cd = f8
     2 prev_procedure_cd_disp = vc
     2 days_until_eligible = i4
     2 active_ind = i2
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
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
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].
   procedure_eligibility_id = p.procedure_eligibility_id,
   reply->qual[count].procedure_cd = p.procedure_cd, reply->qual[count].prev_procedure_cd = p
   .prev_procedure_cd, reply->qual[count].days_until_eligible = p.days_until_eligible,
   reply->qual[count].active_ind = p.active_ind, reply->qual[count].begin_effective_dt_tm = p
   .begin_effective_dt_tm, reply->qual[count].end_effective_dt_tm = p.end_effective_dt_tm,
   reply->qual[count].updt_cnt = p.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO

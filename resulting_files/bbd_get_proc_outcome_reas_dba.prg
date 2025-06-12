CREATE PROGRAM bbd_get_proc_outcome_reas:dba
 RECORD reply(
   1 qual[*]
     2 proc_outcm_reason_id = f8
     2 reason_cd = f8
     2 reason_cd_disp = vc
     2 calc_deferral_cd = f8
     2 calc_deferral_cd_disp = vc
     2 calc_deferral_cd_mean = vc
     2 days_ineligible = i4
     2 hours_ineligible = i4
     2 same_day_ind = i2
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
  bor.outcome_reason_id, bor.reason_cd, bor.deferral_expire_cd,
  bor.days_ineligible, bor.hours_ineligible, bor.updt_cnt
  FROM bbd_donation_procedure bdp,
   bbd_procedure_outcome bpo,
   bbd_outcome_reason bor
  PLAN (bdp
   WHERE (bdp.procedure_cd=request->procedure_cd)
    AND bdp.active_ind=1)
   JOIN (bpo
   WHERE bpo.procedure_id=bdp.procedure_id
    AND (bpo.outcome_cd=request->outcome_cd)
    AND bpo.active_ind=1)
   JOIN (bor
   WHERE bor.procedure_outcome_id=bpo.procedure_outcome_id
    AND bor.active_ind=1)
  HEAD REPORT
   stat = alterlist(reply->qual,10), count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].proc_outcm_reason_id = bor.outcome_reason_id, reply->qual[count].reason_cd =
   bor.reason_cd, reply->qual[count].calc_deferral_cd = bor.deferral_expire_cd,
   reply->qual[count].days_ineligible = bor.days_ineligible, reply->qual[count].hours_ineligible =
   bor.hours_ineligible, reply->qual[count].same_day_ind = 0,
   reply->qual[count].updt_cnt = bor.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,count)
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO

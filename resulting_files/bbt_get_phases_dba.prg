CREATE PROGRAM bbt_get_phases:dba
 RECORD reply(
   1 qual[*]
     2 phase_cd = f8
     2 phase_disp = c40
     2 phase_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET hold_task_assay = 0.0
 SELECT INTO "nl:"
  p.*
  FROM phase_group p,
   discrete_task_assay dta,
   assay_processing_r apr
  PLAN (p
   WHERE (p.phase_group_cd=request->phase_group_cd)
    AND p.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=p.task_assay_cd)
   JOIN (apr
   WHERE apr.task_assay_cd=dta.task_assay_cd
    AND apr.active_ind=1)
  HEAD REPORT
   count1 = 0
  DETAIL
   IF (hold_task_assay != apr.task_assay_cd)
    hold_task_assay = apr.task_assay_cd, count1 = (count1+ 1), stat = alterlist(reply->qual,count1),
    reply->qual[count1].phase_cd = dta.task_assay_cd, reply->qual[count1].phase_disp = dta.mnemonic
   ENDIF
  WITH counter
 ;end select
 IF (((curqual != 0) OR (count1 > 0)) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO

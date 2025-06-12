CREATE PROGRAM bbt_get_tasks_trans_comm:dba
 RECORD reply(
   1 qual[10]
     2 task_cd = f8
     2 task_disp = vc
     2 meaning = vc
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
 SELECT INTO "nl:"
  dta.task_assay_cd, dta.mnemonic, c.display
  FROM code_value c,
   discrete_task_assay dta
  PLAN (dta
   WHERE dta.active_ind=1)
   JOIN (c
   WHERE c.code_value=dta.activity_type_cd
    AND c.code_set=106
    AND ((c.cdf_meaning="BB") OR (c.cdf_meaning="GLB"))
    AND c.active_ind=1)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].task_cd = dta.task_assay_cd, reply->qual[count1].task_disp = dta.mnemonic
  WITH counter
 ;end select
 IF (((curqual != 0) OR (count1 > 0)) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alter(reply->qual,count1)
#stop
END GO

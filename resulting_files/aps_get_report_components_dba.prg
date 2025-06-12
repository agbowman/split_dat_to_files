CREATE PROGRAM aps_get_report_components:dba
 RECORD reply(
   1 task_qual[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  dta.task_assay_cd
  FROM discrete_task_assay dta,
   profile_task_r ptr
  PLAN (ptr
   WHERE (ptr.catalog_cd=request->catalog_cd)
    AND ptr.active_ind=1
    AND ptr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ((ptr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (ptr.end_effective_dt_tm=null
   )) )
   JOIN (dta
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND dta.active_ind=1
    AND dta.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ((dta.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (dta.end_effective_dt_tm=null
   )) )
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->task_qual,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->task_qual,(cnt+ 9))
   ENDIF
   reply->task_qual[cnt].task_assay_cd = dta.task_assay_cd
  FOOT REPORT
   stat = alterlist(reply->task_qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DISCRETE_TASK_ASSAY"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

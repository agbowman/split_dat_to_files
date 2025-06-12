CREATE PROGRAM dodfr_get_dta_from_concept_cki:dba
 RECORD reply(
   1 qual[*]
     2 concept_cki = vc
     2 task_assay_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count = i2 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM discrete_task_assay dta,
   (dummyt d  WITH seq = size(request->qual,5))
  PLAN (d)
   JOIN (dta
   WHERE (dta.concept_cki=request->qual[d.seq].concept_cki)
    AND dta.active_ind=1
    AND dta.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND dta.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->qual,5))
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].concept_cki = dta.concept_cki, reply->qual[count].task_assay_cd = dta
   .task_assay_cd
  WITH nocounter
 ;end select
 SET reply->status_data.status = "Z"
 SET stat = alterlist(reply->qual,count)
END GO

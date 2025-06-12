CREATE PROGRAM afc_get_bill_code_schedules:dba
 RECORD reply(
   1 sched_cpt4_qual = i2
   1 cpt4_qual[*]
     2 cpt4_code_value = f8
     2 cpt4_meaning = vc
     2 cpt4_display = vc
   1 sched_cdm_qual = i2
   1 cdm_qual[*]
     2 cdm_code_value = f8
     2 cdm_meaning = vc
     2 cdm_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET bill_code_set = 14002
 SET cpt4_meaning = "CPT4"
 SET cdm_meaning = "CDM_SCHED"
 SET stat = alterlist(reply->cpt4_qual,(count1+ 10))
 SET stat = alterlist(reply->cdm_qual,(count1+ 10))
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=bill_code_set
   AND cv.cdf_meaning=cpt4_meaning
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->cpt4_qual,(count1+ 10))
   ENDIF
   reply->cpt4_qual[count1].cpt4_code_value = cv.code_value, reply->cpt4_qual[count1].cpt4_meaning =
   cv.cdf_meaning, reply->cpt4_qual[count1].cpt4_display = cv.display
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->cpt4_qual,count1)
 SET reply->sched_cpt4_qual = count1
 SET count1 = 0
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=bill_code_set
   AND cv.cdf_meaning=cdm_meaning
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->cdm_qual,(count1+ 10))
   ENDIF
   reply->cdm_qual[count1].cdm_code_value = cv.code_value, reply->cdm_qual[count1].cdm_meaning = cv
   .cdf_meaning, reply->cdm_qual[count1].cdm_display = cv.display
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->cdm_qual,count1)
 SET reply->sched_cdm_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORGANIZATION"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

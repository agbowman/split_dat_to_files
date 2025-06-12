CREATE PROGRAM dcp_get_dta_version_list:dba
 RECORD reply(
   1 list_versions[*]
     2 version_number = f8
     2 valid_from_dt_tm = dq8
     2 valid_until_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE failed = c1 WITH private, noconstant(" ")
 DECLARE stat = i2 WITH private, noconstant(0)
 DECLARE count1 = i4 WITH noconstant(0)
 SET failed = "F"
 SELECT INTO "nl:"
  dtav.task_assay_cd
  FROM dta_version dtav
  WHERE (dtav.task_assay_cd=request->task_assay_cd)
  ORDER BY dtav.version_number DESC
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->list_versions,(count1+ 10))
   ENDIF
   reply->list_versions[count1].version_number = dtav.version_number, reply->list_versions[count1].
   valid_from_dt_tm = cnvtdatetime(dtav.valid_from_dt_tm), reply->list_versions[count1].
   valid_until_dt_tm = cnvtdatetime(dtav.valid_until_dt_tm)
  FOOT REPORT
   stat = alterlist(reply->list_versions,count1)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

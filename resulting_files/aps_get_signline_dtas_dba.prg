CREATE PROGRAM aps_get_signline_dtas:dba
 RECORD reply(
   1 task_qual[*]
     2 mnemonic = c50
     2 task_assay_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT
  IF ((request->activity_subtype_cd=- (1))
   AND (request->status_flag=- (1)))INTO "nl:"
   dta.mnemonic, dta.task_assay_cd
   FROM sign_line_dta_r sldr,
    discrete_task_assay dta
   PLAN (sldr
    WHERE (sldr.format_id=request->format_id))
    JOIN (dta
    WHERE sldr.task_assay_cd=dta.task_assay_cd)
  ELSE INTO "nl:"
   dta.mnemonic, dta.task_assay_cd
   FROM sign_line_dta_r sldr,
    discrete_task_assay dta
   PLAN (sldr
    WHERE (sldr.activity_subtype_cd=request->activity_subtype_cd)
     AND (sldr.status_flag=request->status_flag)
     AND (sldr.format_id=request->format_id))
    JOIN (dta
    WHERE sldr.task_assay_cd=dta.task_assay_cd)
  ENDIF
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->task_qual,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->task_qual,(cnt+ 9))
   ENDIF
   reply->task_qual[cnt].mnemonic = dta.mnemonic, reply->task_qual[cnt].task_assay_cd = dta
   .task_assay_cd
  FOOT REPORT
   stat = alterlist(reply->task_qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->task_qual,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

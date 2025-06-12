CREATE PROGRAM bbt_get_anti_screen:dba
 RECORD reply(
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
 SET cv_cnt = 1
 SET absc_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1635,"ANTIBDY SCRN",cv_cnt,absc_cd)
 SELECT INTO "nl:"
  s.bb_processing_cd
  FROM profile_task_r ptr,
   service_directory s
  PLAN (s
   WHERE s.bb_processing_cd=absc_cd)
   JOIN (ptr
   WHERE ptr.catalog_cd=s.catalog_cd
    AND (ptr.task_assay_cd=request->task_assay_cd))
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO

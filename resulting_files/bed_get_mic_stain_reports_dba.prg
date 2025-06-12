CREATE PROGRAM bed_get_mic_stain_reports:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 task_cd = f8
     2 task_disp = vc
     2 task_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM mic_task mt,
   code_value cv
  PLAN (mt
   WHERE mt.task_type_flag=1
    AND mt.task_class_flag=5
    AND mt.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=mt.task_assay_cd
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY mt.task_assay_cd
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].task_cd = mt.task_assay_cd
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
#exit_script
 SET error_check = error(error_msg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
 ELSEIF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET modify = nopredeclare
END GO

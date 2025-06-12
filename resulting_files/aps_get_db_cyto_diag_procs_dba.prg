CREATE PROGRAM aps_get_db_cyto_diag_procs:dba
 RECORD reply(
   1 rpt_qual[10]
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 task_assay_desc = vc
     2 report_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rpt_cnt = 0
 SET report_type_where = fillstring(500," ")
 IF ((request->report_type_flag > 0))
  SET report_type_where = build("cr.report_type_flag = ",request->report_type_flag)
 ELSE
  SET report_type_where = " 1 = 1"
 ENDIF
 SELECT INTO "nl:"
  cr.diagnosis_task_assay_cd
  FROM cyto_report_control cr
  PLAN (cr
   WHERE parser(trim(report_type_where))
    AND cr.catalog_cd != 0.0)
  ORDER BY cr.diagnosis_task_assay_cd
  HEAD REPORT
   rpt_cnt = 0
  HEAD cr.diagnosis_task_assay_cd
   rpt_cnt = (rpt_cnt+ 1)
   IF (mod(rpt_cnt,10)=1
    AND rpt_cnt != 1)
    stat = alter(reply->rpt_qual,(rpt_cnt+ 9))
   ENDIF
   reply->rpt_qual[rpt_cnt].task_assay_cd = cr.diagnosis_task_assay_cd, reply->rpt_qual[rpt_cnt].
   report_type_flag = cr.report_type_flag
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CYTO_REPORT_CONTROL"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->rpt_qual,rpt_cnt)
END GO

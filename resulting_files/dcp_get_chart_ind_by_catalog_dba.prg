CREATE PROGRAM dcp_get_chart_ind_by_catalog:dba
 RECORD reply(
   1 chart_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->chart_ind = 0
 IF ((request->catalog_cd=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_task_xref otx,
   order_task ot
  PLAN (otx
   WHERE (otx.catalog_cd=request->catalog_cd))
   JOIN (ot
   WHERE ot.reference_task_id=otx.reference_task_id
    AND ((ot.allpositionchart_ind=1) OR ((ot.reference_task_id=
   (SELECT
    otpx.reference_task_id
    FROM order_task_position_xref otpx
    WHERE otpx.reference_task_id > 0
     AND (otpx.position_cd=reqinfo->position_cd))))) )
  HEAD otx.catalog_cd
   reply->chart_ind = 1
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO

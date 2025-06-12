CREATE PROGRAM bed_get_datamart_rpt_by_filter:dba
 FREE SET reply
 RECORD reply(
   1 reports[*]
     2 br_datamart_report_id = f8
     2 report_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM br_datamart_report_filter_r r,
   br_datamart_report b
  PLAN (r
   WHERE (r.br_datamart_filter_id=request->br_datamart_filter_id))
   JOIN (b
   WHERE b.br_datamart_report_id=r.br_datamart_report_id)
  ORDER BY b.report_name
  HEAD b.report_name
   rcnt = (rcnt+ 1), stat = alterlist(reply->reports,rcnt), reply->reports[rcnt].
   br_datamart_report_id = b.br_datamart_report_id,
   reply->reports[rcnt].report_name = b.report_name
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

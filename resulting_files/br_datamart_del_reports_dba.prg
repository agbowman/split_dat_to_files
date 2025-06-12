CREATE PROGRAM br_datamart_del_reports:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE req_size = i4 WITH protect, constant(size(request->reports,5))
 DECLARE filtercnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE delreportfilters(null) = i2
 DECLARE delreportlayouts(null) = i2
 DECLARE delreporttext(null) = i2
 DECLARE delreportdefaults(null) = i2
 DECLARE delreports(null) = i2
 IF (req_size=0)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 CALL delreportfilters(null)
 CALL delreportlayouts(null)
 CALL delreporttext(null)
 CALL delreportdefaults(null)
 CALL delreports(null)
 SET reply->status_data.status = "S"
 SUBROUTINE delreportfilters(null)
   FREE RECORD delfilterrequest
   RECORD delfilterrequest(
     1 filters[*]
       2 br_datamart_filter_id = f8
       2 reports[*]
         3 br_datamart_report_id = f8
       2 preserve_shared_filters_ind = i2
   )
   FREE RECORD delfilterreply
   RECORD delfilterreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(req_size)),
     br_datamart_report_filter_r r
    PLAN (d)
     JOIN (r
     WHERE (r.br_datamart_report_id=request->reports[d.seq].br_datamart_report_id))
    ORDER BY r.br_datamart_filter_id
    HEAD r.br_datamart_filter_id
     filtercnt += 1, stat = alterlist(delfilterrequest->filters,filtercnt), delfilterrequest->
     filters[filtercnt].br_datamart_filter_id = r.br_datamart_filter_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
     "Failed to get filter ids >> ",errmsg)
    GO TO exit_script
   ENDIF
   EXECUTE br_datamart_del_filters  WITH replace("REQUEST",delfilterrequest), replace("REPLY",
    delfilterreply)
   IF ((delfilterreply->status_data.status="F"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = delfilterreply->status_data.
    subeventstatus.targetobjectvalue
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE delreportlayouts(null)
  DELETE  FROM br_datam_report_layout b,
    (dummyt d  WITH seq = value(req_size))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_report_id=request->reports[d.seq].br_datamart_report_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Error deleting from br_datam_report_layout table >> ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE delreporttext(null)
  DELETE  FROM br_datamart_text b,
    (dummyt d  WITH seq = value(req_size))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_report_id=request->reports[d.seq].br_datamart_report_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Error deleting from br_datamart_text table >> ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE delreportdefaults(null)
  DELETE  FROM br_datamart_report_default b,
    (dummyt d  WITH seq = value(req_size))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_report_id=request->reports[d.seq].br_datamart_report_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Error deleting from br_datamart_report_default table >> ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE delreports(null)
  DELETE  FROM br_datamart_report b,
    (dummyt d  WITH seq = value(req_size))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_report_id=request->reports[d.seq].br_datamart_report_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Error deleting from br_datamart_report table >> ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD delfilterrequest
 FREE RECORD delfilterreply
END GO

CREATE PROGRAM br_datamart_del_filters:dba
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
 DECLARE req_size = i4 WITH protect, constant(size(request->filters,5))
 SET reply->status_data.status = "F"
 DECLARE delreportfilterreltns(null) = i2
 DECLARE delfilterdefaults(null) = i2
 DECLARE delsavedvalues(null) = i2
 DECLARE delfiltertext(null) = i2
 DECLARE delfilterdetails(null) = i2
 DECLARE delfilters(null) = i2
 IF (req_size=0)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 CALL delreportfilterreltns(null)
 CALL delfilterdefaults(null)
 CALL delsavedvalues(null)
 CALL delfiltertext(null)
 CALL delfilterdetails(null)
 CALL delfilters(null)
 SET reply->status_data.status = "S"
 SUBROUTINE delreportfilterreltns(null)
   FOR (x = 1 TO req_size)
     IF ((request->filters[x].preserve_shared_filters_ind=1))
      FOR (y = 1 TO size(request->filters[x].reports,5))
        IF ((request->filters[x].reports[y].br_datamart_report_id > 0.0))
         DELETE  FROM br_datamart_report_filter_r b
          PLAN (b
           WHERE (b.br_datamart_filter_id=request->filters[x].br_datamart_filter_id)
            AND (b.br_datamart_report_id=request->filters[x].reports[y].br_datamart_report_id))
          WITH nocounter
         ;end delete
         IF (error(errmsg,0) > 0)
          SET reply->status_data.status = "F"
          SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
           "Error deleting from br_datamart_report_filter_r table >> ",errmsg)
          GO TO exit_script
         ENDIF
        ENDIF
      ENDFOR
     ELSE
      DELETE  FROM br_datamart_report_filter_r b
       PLAN (b
        WHERE (b.br_datamart_filter_id=request->filters[x].br_datamart_filter_id))
       WITH nocounter
      ;end delete
      IF (error(errmsg,0) > 0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
        "Error deleting from br_datamart_report_filter_r table >> ",errmsg)
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE delfilterdefaults(null)
  DELETE  FROM br_datamart_default b,
    (dummyt d  WITH seq = value(req_size))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=request->filters[d.seq].br_datamart_filter_id)
     AND (request->filters[d.seq].preserve_shared_filters_ind=0))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Error deleting from br_datamart_default table >> ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE delsavedvalues(null)
  DELETE  FROM br_datamart_value b,
    (dummyt d  WITH seq = value(req_size))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=request->filters[d.seq].br_datamart_filter_id)
     AND (request->filters[d.seq].preserve_shared_filters_ind=0))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Error deleting from br_datamart_value table >> ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE delfiltertext(null)
  DELETE  FROM br_datamart_text b,
    (dummyt d  WITH seq = value(req_size))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=request->filters[d.seq].br_datamart_filter_id)
     AND (request->filters[d.seq].preserve_shared_filters_ind=0))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Error deleting from br_datamart_text table >> ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE delfilterdetails(null)
  DELETE  FROM br_datamart_filter_detail b,
    (dummyt d  WITH seq = value(req_size))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=request->filters[d.seq].br_datamart_filter_id)
     AND (request->filters[d.seq].preserve_shared_filters_ind=0))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Error deleting from br_datamart_filter_detail table >> ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE delfilters(null)
  DELETE  FROM br_datamart_filter b,
    (dummyt d  WITH seq = value(req_size))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=request->filters[d.seq].br_datamart_filter_id)
     AND (request->filters[d.seq].preserve_shared_filters_ind=0))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Error deleting from br_datamart_filter table >> ",errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
END GO

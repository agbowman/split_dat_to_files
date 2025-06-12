CREATE PROGRAM cr_del_report_request:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD long_text_ids(
   1 qual[*]
     2 id = f8
 )
 RECORD long_blob_ids(
   1 qual[*]
     2 id = f8
 )
 SET request_cnt = size(request->report_requests,5)
 SELECT INTO "nl:"
  FROM cr_report_request crr,
   (dummyt d  WITH seq = value(request_cnt))
  PLAN (d)
   JOIN (crr
   WHERE (crr.report_request_id=request->report_requests[d.seq].id))
  HEAD REPORT
   long_text_cnt = 0, long_blob_cnt = 0
  DETAIL
   IF (crr.request_xml_id > 0)
    long_text_cnt += 1
    IF (mod(long_text_cnt,10)=1)
     stat = alterlist(long_text_ids->qual,(long_text_cnt+ 9))
    ENDIF
    long_text_ids->qual[long_text_cnt].id = crr.request_xml_id
   ENDIF
   IF (crr.summary_report_xml_id > 0)
    long_text_cnt += 1
    IF (mod(long_text_cnt,10)=1)
     stat = alterlist(long_text_ids->qual,(long_text_cnt+ 9))
    ENDIF
    long_text_ids->qual[long_text_cnt].id = crr.summary_report_xml_id
   ENDIF
   IF (crr.debug_zip_id > 0)
    long_blob_cnt += 1
    IF (mod(long_blob_cnt,10)=1)
     stat = alterlist(long_blob_ids->qual,(long_blob_cnt+ 9))
    ENDIF
    long_blob_ids->qual[long_blob_cnt].id = crr.debug_zip_id
   ENDIF
  FOOT REPORT
   stat = alterlist(long_text_ids->qual,long_text_cnt), stat = alterlist(long_blob_ids->qual,
    long_blob_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(long_text_ids)
 CALL echorecord(long_blob_ids)
 DELETE  FROM cr_printed_sections crprintsec,
   (dummyt d  WITH seq = value(request_cnt))
  SET crprintsec.seq = 1
  PLAN (d)
   JOIN (crprintsec
   WHERE (crprintsec.report_request_id=request->report_requests[d.seq].id))
  WITH nocounter
 ;end delete
 DELETE  FROM cr_report_request_encntr crrencntr,
   (dummyt d  WITH seq = value(request_cnt))
  SET crrencntr.seq = 1
  PLAN (d)
   JOIN (crrencntr
   WHERE (crrencntr.report_request_id=request->report_requests[d.seq].id))
  WITH nocounter
 ;end delete
 DELETE  FROM cr_report_request_event crre,
   (dummyt d  WITH seq = value(request_cnt))
  SET crre.seq = 1
  PLAN (d)
   JOIN (crre
   WHERE (crre.report_request_id=request->report_requests[d.seq].id))
  WITH nocounter
 ;end delete
 DELETE  FROM cr_report_request_section crrs,
   (dummyt d  WITH seq = value(request_cnt))
  SET crrs.seq = 1
  PLAN (d)
   JOIN (crrs
   WHERE (crrs.report_request_id=request->report_requests[d.seq].id))
  WITH nocounter
 ;end delete
 DELETE  FROM cr_report_request crr,
   (dummyt d  WITH seq = value(request_cnt))
  SET crr.seq = 1
  PLAN (d)
   JOIN (crr
   WHERE (crr.report_request_id=request->report_requests[d.seq].id))
  WITH nocounter
 ;end delete
 IF (size(long_text_ids->qual,5) > 0)
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(size(long_text_ids->qual,5)))
   SET lt.seq = 1
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=long_text_ids->qual[d.seq].id))
  ;end delete
 ENDIF
 IF (size(long_blob_ids->qual,5) > 0)
  DELETE  FROM long_blob lb,
    (dummyt d  WITH seq = value(size(long_blob_ids->qual,5)))
   SET lb.seq = 1
   PLAN (d)
    JOIN (lb
    WHERE (lb.long_blob_id=long_blob_ids->qual[d.seq].id))
  ;end delete
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO

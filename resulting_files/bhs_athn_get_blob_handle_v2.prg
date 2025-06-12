CREATE PROGRAM bhs_athn_get_blob_handle_v2
 DECLARE eventid = f8 WITH protect, constant( $2)
 DECLARE bhandle = vc
 SELECT INTO "nl:"
  blob_handle = trim(b.blob_handle,3)
  FROM clinical_event c,
   result r,
   blob_reference b
  PLAN (c
   WHERE c.event_id=eventid)
   JOIN (r
   WHERE r.order_id=c.order_id
    AND r.task_assay_cd=c.task_assay_cd)
   JOIN (b
   WHERE b.parent_entity_id=r.result_id
    AND b.parent_entity_name="RESULT")
  DETAIL
   IF (blob_handle > "")
    bhandle = blob_handle
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  blob_handle = trim(cb.blob_handle,3)
  FROM ce_blob_result cb
  WHERE cb.event_id=eventid
  DETAIL
   IF (blob_handle > "")
    bhandle = blob_handle
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  blob_handle = trim(ct.blob_handle,3)
  FROM cdi_trans_log ct,
   clinical_event ce
  WHERE ce.event_id=eventid
   AND ce.encntr_id=ct.encntr_id
   AND ce.event_id=ct.event_id
  DETAIL
   IF (blob_handle > "")
    bhandle = blob_handle
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SELECT INTO  $1
  bhandle
  FROM dummyt d1
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  DETAIL
   bh = build("<BlobHandle>",bhandle,"</BlobHandle>"), col + 1, bh,
   row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 1000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO

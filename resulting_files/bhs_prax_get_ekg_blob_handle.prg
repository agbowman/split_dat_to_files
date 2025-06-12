CREATE PROGRAM bhs_prax_get_ekg_blob_handle
 SELECT INTO  $1
  ce.parent_event_id, ce.event_id, blob_handle = trim(cbr.blob_handle,3)
  FROM clinical_event ce,
   ce_blob_result cbr
  PLAN (ce
   WHERE ce.parent_event_id=cnvtint( $2)
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (cbr
   WHERE cbr.event_id=ce.event_id
    AND cbr.valid_until_dt_tm > sysdate)
  ORDER BY ce.parent_event_id, ce.event_id
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  DETAIL
   v1 = build("<RemoteBodyHandle>",blob_handle,"</RemoteBodyHandle>"), col + 1, v1,
   row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 1000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO

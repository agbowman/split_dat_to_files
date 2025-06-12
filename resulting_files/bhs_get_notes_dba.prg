CREATE PROGRAM bhs_get_notes:dba
 SET cid = link_clineventid
 DECLARE log_message = vc
 DECLARE log_misc1 = vc
 DECLARE ecode = vc
 DECLARE pname = vc
 DECLARE status = vc
 DECLARE notedate = vc
 SET retval = 0
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.clinical_event_id=cid)
  HEAD REPORT
   cclprogram_message = trim(ce.event_title_text,3), cclprogram_status = 1
  WITH nocounter
 ;end select
 IF (cclprogram_status != 1)
  SET cclprogram_message = "Unknown Document"
  SET cclprogram_status = 1
 ENDIF
END GO

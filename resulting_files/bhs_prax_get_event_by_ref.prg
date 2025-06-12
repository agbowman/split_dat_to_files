CREATE PROGRAM bhs_prax_get_event_by_ref
 FREE RECORD result
 RECORD result(
   1 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE getevent(null) = i2
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 SET stat = getevent(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  IF ((result->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, v1 = build("<EventId>",cnvtlong(result->event_id),"</EventId>"), col + 1,
     v1, row + 1, col + 1,
     "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 SUBROUTINE getevent(null)
  SELECT INTO "NL:"
   FROM clinical_event ce
   PLAN (ce
    WHERE (ce.reference_nbr= $2))
   HEAD ce.event_id
    result->event_id = ce.event_id
   WITH nocounter, time = 30
  ;end select
  RETURN(success)
 END ;Subroutine
END GO

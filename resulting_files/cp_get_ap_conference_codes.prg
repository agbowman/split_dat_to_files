CREATE PROGRAM cp_get_ap_conference_codes
 RECORD reply(
   1 code_qual[*]
     2 source_identifier = vc
     2 source_string = vc
   1 collected_dt_tm = dq8
   1 collected_tz = i4
   1 received_dt_tm = dq8
   1 received_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET x = 0
 SET v_until_dt = cnvtdatetime("31-Dec-2100 00:00:00.00")
 DECLARE ssummary = c7 WITH protect, constant("SUMMARY")
 IF ((request->conf_cd_ind=1))
  SELECT INTO "nl:"
   c1.event_id, c1.parent_event_id, c2.event_id
   FROM clinical_event c1,
    clinical_event c2,
    ce_coded_result cr,
    nomenclature n
   PLAN (c1
    WHERE (c1.event_id=request->event_id)
     AND c1.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
    JOIN (c2
    WHERE c2.event_id=c1.parent_event_id
     AND c2.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
    JOIN (cr
    WHERE cr.event_id=c2.event_id
     AND cr.valid_until_dt_tm >= cnvtdatetime(v_until_dt)
     AND cr.descriptor != ssummary)
    JOIN (n
    WHERE n.nomenclature_id=cr.nomenclature_id)
   HEAD REPORT
    x = 0
   DETAIL
    x = (x+ 1), stat = alterlist(reply->code_qual,x), reply->code_qual[x].source_identifier = n
    .source_identifier,
    reply->code_qual[x].source_string = n.source_string
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  c1.event_id, c1.parent_event_id, c2.event_id
  FROM clinical_event c1,
   clinical_event c2
  PLAN (c1
   WHERE (c1.event_id=request->event_id)
    AND c1.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
   JOIN (c2
   WHERE c2.event_id=c1.parent_event_id
    AND c2.valid_until_dt_tm >= cnvtdatetime(v_until_dt))
  DETAIL
   reply->collected_dt_tm = c2.event_start_dt_tm, reply->collected_tz = validate(c2.event_start_tz,0),
   reply->received_dt_tm = c2.event_end_dt_tm,
   reply->received_tz = validate(c2.event_end_tz,0)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET failed = "S"
 ELSE
  SET failed = "Z"
 ENDIF
#exit_script
 SET reply->status_data.status = failed
END GO

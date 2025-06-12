CREATE PROGRAM aps_get_case_event_id:dba
 SET called_standalone = 0
 IF (textlen(trim(validate(case_event->accession_nbr," ")))=0
  AND textlen(trim(validate(request->accession_nbr," "))) > 0)
  RECORD case_event(
    1 accession_nbr = c20
    1 event_id = f8
  )
  RECORD reply(
    1 event_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET reply->status_data.status = "F"
  SET called_standalone = 1
  SET case_event->accession_nbr = request->accession_nbr
 ENDIF
 SELECT INTO "nl:"
  cv.code_value, ce.event_id
  FROM code_value cv,
   clinical_event ce
  PLAN (cv
   WHERE cv.code_set=53
    AND cv.cdf_meaning="AP"
    AND cv.active_ind=1)
   JOIN (ce
   WHERE cv.code_value=ce.event_class_cd
    AND (case_event->accession_nbr=ce.accession_nbr)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   case_event->event_id = ce.event_id
  WITH nocounter
 ;end select
 IF (called_standalone=1)
  SET reply->status_data.status = "S"
  SET reply->event_id = case_event->event_id
 ENDIF
END GO

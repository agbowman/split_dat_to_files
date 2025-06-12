CREATE PROGRAM cv_get_cl_clin_event:dba
 SELECT INTO "NL:"
  FROM code_value_alias cv,
   (dummyt d  WITH seq = value(size(cv_cl_internal->events,5)))
  PLAN (d
   WHERE trim(cv_cl_internal->events[d.seq].mnemonic) > "")
   JOIN (cv
   WHERE cv.code_set=72
    AND (cv.alias=cv_cl_internal->events[d.seq].mnemonic))
  DETAIL
   cv_cl_internal->events[d.seq].event_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   (dummyt d  WITH seq = value(size(cv_cl_internal->events,5)))
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=cv_cl_internal->person_id)
    AND (ce.encntr_id=cv_cl_internal->encntr_id)
    AND (ce.event_cd=cv_cl_internal->events[d.seq].event_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  DETAIL
   cv_cl_internal->events[d.seq].result_val = ce.result_val
  WITH nocounter
 ;end select
END GO

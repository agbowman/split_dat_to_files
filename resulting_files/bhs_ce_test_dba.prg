CREATE PROGRAM bhs_ce_test:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "reference_nbr:" = ""
  WITH outdev, prompt1
 FREE RECORD request
 RECORD request(
   1 class = vc
   1 stype = vc
   1 subtype = vc
   1 subtype_detail = vc
   1 event_id = f8
   1 valid_from_dt_tm = dq8
   1 event_cd = f8
   1 result_status_cd = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
 )
 SELECT INTO "nl:"
  ce.event_cd, ce.result_status_cd, ce.contributor_system_cd,
  ce.reference_nbr
  FROM clinical_event ce
  WHERE ce.reference_nbr=cnvtupper(trim( $2,3))
   AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
  DETAIL
   request->result_status_cd = ce.result_status_cd, request->event_id = ce.event_id, request->
   event_cd = ce.event_cd,
   request->contributor_system_cd = ce.contributor_system_cd, request->class = "CE", request->stype
    = trim(cnvtupper(uar_get_code_display(ce.event_class_cd)),4),
   request->subtype = trim(cnvtupper(uar_get_code_display(ce.entry_mode_cd)),4)
  WITH nocounter
 ;end select
 CALL echorecord(request)
 CALL echo("calling eso_get_ce_selection")
 EXECUTE eso_get_ce_selection
END GO

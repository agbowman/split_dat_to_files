CREATE PROGRAM bhs_sn_case_track_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Surgical Case Number" = ""
  WITH outdev, surg_case_nbr
 SELECT INTO "nl:"
  FROM surgical_case sc
  WHERE sc.surg_case_nbr_formatted=cnvtupper(trim( $SURG_CASE_NBR,3))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dual
   DETAIL
    col 0, "Invalid surgical case number entered: ", col + 1,
     $SURG_CASE_NBR
   WITH nocounter
  ;end select
  GO TO exit_program
 ENDIF
 SELECT INTO  $OUTDEV
  time_set = format(te.requested_dt_tm,";;q"), event_name = tre.display, set_by = p
  .name_full_formatted
  FROM surgical_case sc,
   tracking_checkin tc,
   tracking_event te,
   person p,
   track_event tre
  PLAN (sc
   WHERE sc.surg_case_nbr_formatted=cnvtupper(trim( $SURG_CASE_NBR,3)))
   JOIN (tc
   WHERE sc.surg_case_id=tc.parent_entity_id)
   JOIN (te
   WHERE tc.tracking_id=te.tracking_id)
   JOIN (p
   WHERE te.updt_id=p.person_id)
   JOIN (tre
   WHERE te.track_event_id=tre.track_event_id)
  ORDER BY te.requested_dt_tm
  WITH format, separator = " "
 ;end select
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dual
   DETAIL
    col 0, "No data found for surgical case number entered: ", col + 1,
     $SURG_CASE_NBR
   WITH nocounter
  ;end select
 ENDIF
#exit_program
END GO

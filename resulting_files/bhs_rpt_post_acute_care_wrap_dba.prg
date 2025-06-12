CREATE PROGRAM bhs_rpt_post_acute_care_wrap:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "FIN:" = ""
  WITH outdev, s_fin
 FREE RECORD request
 RECORD request(
   1 output_device = vc
   1 visit[1]
     2 encntr_id = f8
 )
 SELECT INTO "nl:"
  e.encntr_id
  FROM encntr_alias ea,
   encounter e
  PLAN (ea
   WHERE ea.encntr_alias_type_cd=1077
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.alias=trim(cnvtupper( $S_FIN),3))
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
  HEAD REPORT
   request->visit[1].encntr_id = e.encntr_id
  WITH nocounter
 ;end select
 SET request->output_device =  $OUTDEV
 IF ((request->visit[1].encntr_id > 0.0))
  SET trace = recpersist
  EXECUTE bhs_rpt_post_acute_care_disch
  SET trace = norecpersist
 ELSE
  SELECT INTO "nl:"
   FROM dummyt d
   HEAD REPORT
    col 0, "Encounter ID not found"
   WITH nocounter
  ;end select
 ENDIF
END GO

CREATE PROGRAM bhs_athn_get_pat_dosingbodywt
 DECLARE per_id = f8 WITH protect, constant( $2)
 DECLARE enc_id = f8 WITH protect, constant( $3)
 DECLARE f_body_wt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DRYWEIGHT"))
 DECLARE f_body_ht_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 FREE RECORD oreply
 RECORD oreply(
   1 body_weight = vc
   1 body_weight_unit = vc
   1 height = vc
   1 height_unit = vc
 )
 SELECT INTO "NL:"
  c.result_val
  FROM clinical_event c
  WHERE c.person_id=per_id
   AND c.encntr_id=enc_id
   AND c.event_cd IN (f_body_wt_cd, f_body_ht_cd)
   AND c.result_status_cd=25
   AND c.valid_from_dt_tm <= sysdate
   AND c.valid_until_dt_tm > sysdate
  ORDER BY c.event_cd, c.event_id DESC
  HEAD c.event_cd
   IF (c.event_cd=f_body_wt_cd)
    oreply->body_weight = trim(c.result_val,3), oreply->body_weight_unit = trim(cnvtstring(c
      .result_units_cd),3)
   ENDIF
   IF (c.event_cd=f_body_ht_cd)
    oreply->height = trim(c.result_val,3), oreply->height_unit = trim(cnvtstring(c.result_units_cd),3
     )
   ENDIF
  WITH nocounter, time = 10
 ;end select
 IF ((oreply->body_weight=" "))
  SET oreply->body_weight = "0"
  SET oreply->body_weight_unit = "0"
 ENDIF
 IF ((oreply->height=" "))
  SET oreply->height = "0"
  SET oreply->height_unit = "0"
 ENDIF
 CALL echojson(oreply, $1)
END GO

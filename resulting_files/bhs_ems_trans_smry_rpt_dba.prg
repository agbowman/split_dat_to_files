CREATE PROGRAM bhs_ems_trans_smry_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "FIN:" = ""
  WITH outdev, s_fin
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_fin_nbr = vc WITH protect, noconstant( $S_FIN)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 IF (validate(request->output_device,"X") != "X")
  IF ((request->output_device != "MINE"))
   SET ms_output = request->output_device
  ENDIF
 ENDIF
 IF (validate(request->visit[1].encntr_id,999) != 999)
  SET mf_encntr_id = request->visit[1].encntr_id
 ELSE
  IF ( NOT (trim(ms_fin_nbr) IN ("", " ", null)))
   CALL echo("get encounter id")
   SELECT INTO "nl:"
    FROM encntr_alias ea
    PLAN (ea
     WHERE ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.alias=ms_fin_nbr)
    DETAIL
     mf_encntr_id = ea.encntr_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 CALL echo(concat("ms_output: ",ms_output))
 CALL echo(concat("ms_fin_nbr: ",ms_fin_nbr))
 CALL echo(concat("encntr_id: ",trim(cnvtstring(mf_encntr_id))))
 IF (mf_encntr_id <= 0)
  GO TO exit_script
 ENDIF
 EXECUTE bhs_ems_trans_smry_encntr_rpt value(ms_output), mf_encntr_id
#exit_script
END GO

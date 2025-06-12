CREATE PROGRAM bhs_gen_last_glucose_result
 DECLARE var_output = vc
 DECLARE var_encntr_id = f8
 IF (reflect(parameter(1,0)) > " ")
  SET var_output = trim(build( $1),3)
 ENDIF
 IF (reflect(parameter(2,0)) > " ")
  SET var_encntr_id = cnvtreal( $2)
 ELSEIF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET var_encntr_id = request->visit[1].encntr_id
 ELSE
  CALL echo("no encntr_id given. exiting script")
  GO TO exit_script
 ENDIF
 IF (validate(reply->text,"A")="A"
  AND validate(reply->text,"Z")="Z")
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
  )
 ENDIF
 SET rhead = "{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Tahoma;}}\f0\fs20"
 SET rtfeof = "}"
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs72_glucose_poc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"GLUCOSEPOC"))
 DECLARE cs72_poc_glucose_results_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "POCGLUCOSERESULTS"))
 SET reply->text = rhead
 SELECT INTO "nl:"
  ce_event_disp = uar_get_code_display(ce.event_cd), result_units_disp = uar_get_code_display(ce
   .result_units_cd), normalcy_disp = uar_get_code_display(ce.normalcy_cd),
  date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d")
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.encntr_id=var_encntr_id
    AND ce.event_cd IN (cs72_glucose_poc_cd, cs72_poc_glucose_results_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_modified_cd, cs8_altered_cd))
  ORDER BY ce.event_end_dt_tm DESC, ce.parent_event_id
  HEAD REPORT
   reply->text = build2(reply->text," ",date,"  \b ",trim(ce_event_disp),
    "\b0 ","  ",trim(ce.result_val)," ",trim(result_units_disp),
    "  ",trim(normalcy_disp),rtfeof)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->text = build2(reply->text,"\b No Glucose result found\b0",rtfeof)
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF (trim(var_output,3) > " ")
  CALL echo(build2('var_output: "',trim(var_output,3),'"'))
  CALL echo(build2('var_encntr_id: "',trim(build2(var_encntr_id),3),'"'))
  CALL echo(build2("reply->text:",char(10),reply->text))
 ENDIF
END GO

CREATE PROGRAM bhs_rw_check_pt_forward
 PROMPT
  "Enter PowerForm CLINICAL_EVENT_ID: " = 0.00
 SET retval = 0
 IF (cnvtreal( $1) <= 0.00)
  SET log_message = build("CLINICAL_EVENT_ID of ",trim( $1)," not valid")
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 DECLARE tmp_ref_nbr = vc
 SELECT INTO "NL:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.clinical_event_id=cnvtreal( $1))
  DETAIL
   tmp_ref_nbr = build(substring(1,(findstring("!",ce.reference_nbr) - 1),ce.reference_nbr),"*")
  WITH nocounter
 ;end select
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_mod1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs8_mod2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs72_forward_to_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FORWARDMESSAGETO"))
 DECLARE tmp_full_name = vc
 SELECT INTO "NL:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.reference_nbr=patstring(tmp_ref_nbr)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.event_cd=cs72_forward_to_cd
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd))
  DETAIL
   tmp_full_name = trim(ce.result_val)
  WITH nocounter
 ;end select
 IF (trim(tmp_full_name) <= " ")
  SET log_message = build2("No forward to value found for DCP_FORMS_ACTIVITY_ID ",tmp_ref_nbr)
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 DECLARE cs48_active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE tmp_found_ind = i4 WITH noconstant(0)
 SELECT INTO "NL:"
  pr.person_id
  FROM prsnl pr
  PLAN (pr
   WHERE pr.name_full_formatted=tmp_full_name
    AND pr.active_ind=1
    AND pr.active_status_cd=cs48_active_cd)
  DETAIL
   tmp_found_ind = 1
  WITH nocounter
 ;end select
 IF (tmp_found_ind != 1)
  SET log_message = build2("No PRSNL rows found for NAME_FULL_FORMATTED ",tmp_full_name)
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 SET log_misc1 = substring(1,(size(tmp_ref_nbr) - 1),tmp_ref_nbr)
 SET log_message = build2("At least one PRSNL row found for NAME_FULL_FORMATTED ",tmp_full_name,
  ". Logging DCP_FORMS_ACTIVITY_ID ",log_misc1," in LOG_MISC1")
 SET retval = 100
#exit_script
 FREE SET cs8_auth_cd
 FREE SET cs8_mod1_cd
 FREE SET cs8_mod2_cd
 FREE SET cs72_forward_to_cd
 FREE SET cs48_active_ind
 FREE SET tmp_ref_nbr
 FREE SET tmp_full_name
 FREE SET tmp_found_ind
END GO

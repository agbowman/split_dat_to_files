CREATE PROGRAM ancillary_pending:dba
 PROMPT
  "Output to File/Printer/MINE " = "MINE",
  "Look back xx number of days: " = "1"
 SET ops_ind = validate(request->batch_selection,"N")
 IF (isnumeric( $2)=1)
  SET beg_dt = cnvtlookbehind(concat( $2,",D"))
  SET end_dt = curdate
 ELSE
  SET error_message = concat("Please enter an integer for number of days back.")
  CALL write_error_message(error_message)
  GO TO exit_script
 ENDIF
 SET temp_beg_dt = format(beg_dt,"MM/DD/YYYY;;D")
 CALL echo(beg_dt)
 SET temp_end_dt = format(curdate,"MM/DD/YYYY;;D")
 CALL echo(temp_end_dt)
 SET start_disp = format(beg_dt,"MM/DD/YYYY;;d")
 SET end_disp = format(end_dt,"MM/DD/YYYY;;d")
 DECLARE verified_cd = f8 WITH noconstant(0.0)
 DECLARE corrected_cd = f8 WITH noconstant(0.0)
 DECLARE mrn_pool_cd = f8 WITH noconstant(0.0)
 DECLARE facility_cd = f8 WITH noconstant(0.0)
 DECLARE pr_cnt = i2
 SET active_cd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET facility_cd = uar_get_code_by("DISPLAYKEY",220,"")
 SET mrn_alias_cd = uar_get_code_by("MEANING",4,"MRN")
 SET fin_nbr_cd = uar_get_code_by("DISPLAYKEY",319,"FIN NBR")
 SET verified_cd = uar_get_code_by("MEANING",1901,"VERIFIED")
 SET corrected_cd = uar_get_code_by("MEANING",1901,"CORRECTED")
 SET p_cnt = 0
 DECLARE eeg_portable_cd = f8 WITH noconstant(0.0)
 DECLARE eeg_sleep_cd = f8 WITH noconstant(0.0)
 DECLARE eeg_routine_cd = f8 WITH noconstant(0.0)
 DECLARE broncho_eval_cd = f8 WITH noconstant(0.0)
 DECLARE diffuse_cap_cd = f8 WITH noconstant(0.0)
 DECLARE asthma_test_cd = f8 WITH noconstant(0.0)
 DECLARE lung_cap_cd = f8 WITH noconstant(0.0)
 DECLARE max_vent_cd = f8 WITH noconstant(0.0)
 DECLARE metacholine_cd = f8 WITH noconstant(0.0)
 DECLARE pft_comp_cd = f8 WITH noconstant(0.0)
 DECLARE pulm_stress_cd = f8 WITH noconstant(0.0)
 DECLARE spiro_pft_cd = f8 WITH noconstant(0.0)
 DECLARE echo_2d_cd = f8 WITH noconstant(0.0)
 DECLARE echo_complete_cd = f8 WITH noconstant(0.0)
 DECLARE echo_stress_cd = f8 WITH noconstant(0.0)
 DECLARE echo_dobutamine_cd = f8 WITH noconstant(0.0)
 DECLARE holter_24_cd = f8 WITH noconstant(0.0)
 DECLARE holter_48_cd = f8 WITH noconstant(0.0)
 DECLARE stress_dobutamine_cd = f8 WITH noconstant(0.0)
 DECLARE stress_persantine_cd = f8 WITH noconstant(0.0)
 DECLARE tread_mod_stress_cd = f8 WITH noconstant(0.0)
 DECLARE tread_mod_nuc_cd = f8 WITH noconstant(0.0)
 DECLARE tread_post_stress_cd = f8 WITH noconstant(0.0)
 DECLARE tread_post_nuc_cd = f8 WITH noconstant(0.0)
 DECLARE tread_stress_cd = f8 WITH noconstant(0.0)
 DECLARE tread_nuc_cd = f8 WITH noconstant(0.0)
 SET eeg_portable_cd = uar_get_code_by("DISPLAYKEY",200,"EEGPORTABLE")
 SET eeg_sleep_cd = uar_get_code_by("DISPLAYKEY",200,"EEGWSLEEP")
 SET eeg_routine_cd = uar_get_code_by("DISPLAYKEY",200,"EEGROUTINE")
 SET broncho_eval_cd = uar_get_code_by("DISPLAYKEY",200,"BRONCHOSPASMEVALUATION")
 SET diffuse_cap_cd = uar_get_code_by("DISPLAYKEY",200,"DIFFUSINGCAPACITYCARBONMONOXIDE")
 SET asthma_test_cd = uar_get_code_by("DISPLAYKEY",200,"EXERCISETESTFORASTHMA")
 SET lung_cap_cd = uar_get_code_by("DISPLAYKEY",200,"LUNGRESIDUALCAPACITY")
 SET max_vent_cd = uar_get_code_by("DISPLAYKEY",200,"MAXIMUMVOLUNTARYVENTILATION")
 SET metacholine_cd = uar_get_code_by("DISPLAYKEY",200,"METACHOLINECHALLENGE")
 SET pft_comp_cd = uar_get_code_by("DISPLAYKEY",200,"PFTCOMPLETE")
 SET pulm_stress_cd = uar_get_code_by("DISPLAYKEY",200,"PULMSTRESSHOMEO2EVAL")
 SET spiro_pft_cd = uar_get_code_by("DISPLAYKEY",200,"SPIROMETRYSCREENINGPFT")
 SET echo_2d_cd = uar_get_code_by("DISPLAYKEY",200,"ECHO2DWCONTRAST")
 SET echo_complete_cd = uar_get_code_by("DISPLAYKEY",200,"ECHOCOMPLETE")
 SET echo_stress_cd = uar_get_code_by("DISPLAYKEY",200,"ECHOSTRESS")
 SET echo_dobutamine_cd = uar_get_code_by("DISPLAYKEY",200,"ECHOSTRESSWDOBUTAMINE")
 SET holter_24_cd = uar_get_code_by("DISPLAYKEY",200,"HOLTERMONITOR24HOURS")
 SET holter_48_cd = uar_get_code_by("DISPLAYKEY",200,"HOLTERMONITOR48HOURS")
 SET stress_dobutamine_cd = uar_get_code_by("DISPLAYKEY",200,"STRESSNUCWDOBUTAMINE")
 SET stress_persantine_cd = uar_get_code_by("DISPLAYKEY",200,"STRESSNUCWPERSANTINE")
 SET tread_mod_stress_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLMODIFIEDSTRESS")
 SET tread_mod_nuc_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLMODIFIEDWNUCIMAGING")
 SET tread_post_stress_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLPOSTMISTRESS")
 SET tread_post_nuc_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLPOSTMIWNUCIMAGING")
 SET tread_stress_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLSTANDARDSTRESS")
 SET tread_nuc_cd = uar_get_code_by("DISPLAYKEY",200,"TREADMILLSTANDARDWNUCIMAGING")
 SELECT INTO  $1
  p_name = substring(1,25,p.name_full_formatted), mrn = substring(1,12,pa.alias), fin_nbr = substring
  (1,15,ea.alias),
  test_name = concat(substring(3,8,uar_get_code_display(ce.event_cd))," - ",substring(27,5,
    uar_get_code_display(ce.event_cd))), accession_num = concat(substring(5,1,ce.accession_nbr),"-",
   substring(8,2,ce.accession_nbr),"-",substring(10,3,ce.accession_nbr),
   "-",substring(14,5,ce.accession_nbr)), result_tm = cnvtstring(cnvttime(ce.verified_dt_tm))
  FROM clinical_event ce,
   encounter e,
   person p,
   person_alias pa,
   encntr_alias ea
  PLAN (ce
   WHERE ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(beg_dt,0) AND cnvtdatetime(end_dt,235959)
    AND ce.catalog_cd IN (eeg_portable_cd, eeg_sleep_cd, eeg_routine_cd, broncho_eval_cd,
   diffuse_cap_cd,
   asthma_test_cd, lung_cap_cd, max_vent_cd, metacholine_cd, pft_comp_cd,
   pulm_stress_cd, spiro_pft_cd, echo_2d_cd, echo_complete_cd, echo_stress_cd,
   echo_dobutamine_cd, holter_24_cd, holter_48_cd, stress_dobutamine_cd, stress_persantine_cd,
   tread_mod_stress_cd, tread_mod_nuc_cd, tread_post_stress_cd, tread_post_nuc_cd, tread_stress_cd,
   tread_nuc_cd)
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND ce.record_status_cd=active_cd)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
   JOIN (p
   WHERE p.person_id=ce.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(mrn_alias_cd)
    AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.active_ind=outerjoin(1))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd)
    AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.active_ind=outerjoin(1))
  ORDER BY ce.verified_dt_tm, p_name
  WITH nocounter, nullreport, maxrow = 60,
   maxcol = 132
 ;end select
 IF (ops_ind != "N")
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SUBROUTINE write_error_message(error_msg)
   SELECT INTO trim( $1)
    FROM dummyt d
    DETAIL
     col 2, error_msg
    WITH nocounter, noheading, noformat
   ;end select
 END ;Subroutine
END GO

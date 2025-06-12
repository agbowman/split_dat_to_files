CREATE PROGRAM bhs_rpt_find_form_from_dta:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "DTA Display (*):" = "",
  "Begin Date time:" = "CURDATE",
  "End date time" = "CURDATE"
  WITH outdev, dtadisp, begdatetime,
  enddatetime
 DECLARE dtacodevalue = f8
 DECLARE dtadisplay = vc
 DECLARE beg_effective_dt_tm = q8
 DECLARE end_effective_dt_tm = q8
 FREE RECORD dtalist
 RECORD dtalist(
   1 formqual[*]
     2 dta_display = vc
     2 dcp_form_ref_id = f8
     2 definition = vc
     2 dta_displaykey = vc
 )
 SET beg_effective_dt_tm = cnvtdatetime(build2( $BEGDATETIME,"0"))
 SET end_effective_dt_tm = cnvtdatetime(build2( $ENDDATETIME,"235959"))
 CALL echo(datetimediff(end_effective_dt_tm,beg_effective_dt_tm))
 IF (datetimediff(end_effective_dt_tm,beg_effective_dt_tm) > 31)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 31 days", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ELSEIF (datetimediff(end_effective_dt_tm,beg_effective_dt_tm) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_program
 ENDIF
 SET dtadisplay = replace(cnvtupper( $DTADISP),"1234567890ABCDEFGHIJKLMNOPQRSTUVWXYQZ*",
  "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYQZ*",3)
 CALL echo(dtadisplay)
 SET num = 0
 SET formcnt = 0
 IF (textlen(dtadisplay) < 2)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = dtadisplay, msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ENDIF
 SELECT INTO  $OUTDEV
  sort = build2(dfr.dcp_forms_ref_id,cv.code_value)
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp,
   discrete_task_assay dta,
   code_value cv
  PLAN (dfr
   WHERE dfr.dcp_forms_ref_id > 0
    AND dfr.beg_effective_dt_tm <= cnvtdatetime(end_effective_dt_tm)
    AND dfr.end_effective_dt_tm >= cnvtdatetime(beg_effective_dt_tm)
    AND cnvtupper(dfr.description)="*")
   JOIN (dfd
   WHERE dfr.dcp_form_instance_id=dfd.dcp_form_instance_id
    AND dfr.dcp_forms_ref_id=dfr.dcp_forms_ref_id)
   JOIN (dsr
   WHERE dfd.dcp_section_ref_id=dsr.dcp_section_ref_id
    AND dsr.beg_effective_dt_tm <= cnvtdatetime(end_effective_dt_tm)
    AND dsr.end_effective_dt_tm >= cnvtdatetime(beg_effective_dt_tm))
   JOIN (dir
   WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
    AND dir.dcp_section_ref_id=dsr.dcp_section_ref_id)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
    AND nvp.parent_entity_name="DCP_INPUT_REF"
    AND cnvtupper(nvp.pvc_name)="*TASK*")
   JOIN (dta
   WHERE dta.task_assay_cd=nvp.merge_id
    AND dta.beg_effective_dt_tm <= cnvtdatetime(end_effective_dt_tm)
    AND dta.end_effective_dt_tm >= cnvtdatetime(beg_effective_dt_tm))
   JOIN (cv
   WHERE cv.code_set=72
    AND cv.code_value=dta.event_cd
    AND cv.display_key IN (patstring(dtadisplay)))
  ORDER BY sort
  HEAD sort
   stat = alterlist(dtalist->formqual,100), formcnt = (formcnt+ 1), dtalist->formqual[formcnt].
   dta_display = cv.display,
   dtalist->formqual[formcnt].dcp_form_ref_id = dfr.dcp_forms_ref_id, dtalist->formqual[formcnt].
   definition = dfr.definition, dtalist->formqual[formcnt].dta_displaykey = cv.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(dtalist->formqual,formcnt)
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = dtadisplay, msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ELSE
  SELECT INTO  $OUTDEV
   dta_display = substring(1,80,dtalist->formqual[d.seq].dta_display), refid = dtalist->formqual[d
   .seq].dcp_form_ref_id, def = substring(1,80,dtalist->formqual[d.seq].definition),
   displaykey = substring(1,80,dtalist->formqual[d.seq].dta_displaykey)
   FROM (dummyt d  WITH seq = size(dtalist->formqual,5))
   ORDER BY dta_display
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_program
END GO

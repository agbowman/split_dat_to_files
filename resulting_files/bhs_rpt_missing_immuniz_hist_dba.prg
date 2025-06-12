CREATE PROGRAM bhs_rpt_missing_immuniz_hist:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Email Separated by Commas" = ""
  WITH outdev, s_emails
 DECLARE ms_filename = vc WITH noconstant(concat("missing_immunizations_cs104501_")), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),format(sysdate,"MMDDYYYY;;q"),
   ".csv")), protect
 DECLARE ml_email = i4 WITH noconstant(0), protect
 DECLARE mf_cs93_immunizations = f8 WITH constant(uar_get_code_by("DISPLAYKEY",93,"IMMUNIZATIONS")),
 protect
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 SET ml_email = findstring("@", $S_EMAILS,1,0)
 CALL echo(build("ml_email = ",ml_email))
 IF (ml_email=0)
  SELECT DISTINCT INTO  $OUTDEV
   immunization = uar_get_code_description(vese.event_cd), immunization_code_value = vese.event_cd
   FROM v500_event_set_explode vese
   PLAN (vese
    WHERE vese.event_set_cd=mf_cs93_immunizations
     AND  NOT (vese.event_cd IN (
    (SELECT
     cvg.child_code_value
     FROM code_value_group cvg
     WHERE cvg.child_code_value=vese.event_cd
      AND cvg.parent_code_value IN (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=104501
       AND cv.active_ind=1
       AND cv.cdf_meaning="IMMUNEHIST"))))))
   ORDER BY immunization
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (ml_email > 0)
  SET frec->file_name = ms_output_file
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SELECT DISTINCT INTO "NL:"
   immunization = uar_get_code_description(vese.event_cd), immunization = vese.event_cd
   FROM v500_event_set_explode vese
   PLAN (vese
    WHERE vese.event_set_cd=value(uar_get_code_by("DISPLAYKEY",93,"IMMUNIZATIONS"))
     AND  NOT (vese.event_cd IN (
    (SELECT
     cvg.child_code_value
     FROM code_value_group cvg
     WHERE cvg.child_code_value=vese.event_cd
      AND cvg.parent_code_value IN (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=104501
       AND cv.active_ind=1
       AND cv.cdf_meaning="IMMUNEHIST"))))))
   ORDER BY immunization
   HEAD REPORT
    frec->file_buf = build('"Immunization",','"Immunization Code",',char(13)), stat = cclio("WRITE",
     frec)
   DETAIL
    frec->file_buf = build('"',trim(uar_get_code_description(vese.event_cd),3),'","',trim(cnvtstring(
       vese.event_cd,12,1),3),'"',
     char(13)), stat = cclio("WRITE",frec)
   FOOT REPORT
    stat = cclio("CLOSE",frec)
   WITH nocounter, nocounter, time = 30
  ;end select
  IF (curqual > 0
   AND cnvtupper(curdomain)="P627")
   SET ms_subject = build2(
    "Immunization History update needed to add codes to codeset 104501. Domain is ",trim(curdomain,3),
    ". Date: ",format(cnvtdatetime(curdate,curtime),"mm/dd/yyyy hh:mm;;Q"))
   EXECUTE bhs_ma_email_file
   CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
   SELECT INTO value( $OUTDEV)
    FROM dummyt d
    HEAD REPORT
     msg1 = "The report has been sent to:", msg2 = build2("     ", $S_EMAILS),
     CALL print(calcpos(36,18)),
     msg1, row + 2, msg2
    WITH dio = 08
   ;end select
  ENDIF
 ENDIF
END GO

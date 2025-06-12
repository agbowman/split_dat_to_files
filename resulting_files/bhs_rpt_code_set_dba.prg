CREATE PROGRAM bhs_rpt_code_set:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Code Set:" = 0,
  "Export Type:" = "codeset",
  "Email:" = ""
  WITH outdev, l_code_set, s_export,
  s_email
 DECLARE ml_code_set = i4 WITH protect, constant(cnvtint( $L_CODE_SET))
 DECLARE ms_export = vc WITH protect, constant(trim(cnvtlower( $S_EXPORT),3))
 DECLARE ms_email = vc WITH protect, constant(trim(cnvtlower( $S_EMAIL),3))
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 EXECUTE bhs_ma_email_file
 SELECT INTO "nl:"
  FROM code_value_set cvs
  WHERE cvs.code_set=ml_code_set
  WITH nocounter
 ;end select
 IF (((ml_code_set=0) OR (curqual < 1)) )
  SET ms_log = "Code set invalid"
  GO TO exit_script
 ENDIF
 IF (findstring("@bhs.org",ms_email)=0
  AND findstring("@baystatehealth.org",ms_email)=0)
  SET ms_log = "Invalid Baystate email address"
  GO TO exit_script
 ENDIF
 CALL echo(build2("ms_filename: ",ms_filename))
 IF (ms_export="codeset")
  SET ms_filename = concat("bhs_",trim(cnvtlower(curdomain),3),"_cs",trim(cnvtstring(ml_code_set),3),
   ".csv")
  SET ms_subject = concat(trim(curdomain,3)," Code Set ",trim(cnvtstring(ml_code_set),3)," Export")
  SELECT INTO value(ms_filename)
   cv.active_dt_tm, cv.active_ind, cv.active_status_prsnl_id,
   cv.active_type_cd, cv.begin_effective_dt_tm, cv.cdf_meaning,
   cv.cki, cv.code_set, cv.code_value,
   cv.collation_seq, cv.concept_cki, cv.data_status_cd,
   cv.data_status_dt_tm, cv.data_status_prsnl_id, cv.definition,
   cv.description, cv.display, cv.display_key,
   cv.display_key_a_nls, cv.display_key_nls, cv.end_effective_dt_tm,
   cv.inactive_dt_tm, cv.updt_cnt, cv.updt_dt_tm,
   cv.updt_id
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=ml_code_set)
   ORDER BY cv.display
   WITH pcformat('"',",",1), format = stream, format,
    skipreport = 1
  ;end select
 ELSEIF (ms_export="outalias")
  SET ms_subject = concat(trim(curdomain,3)," Outbound Alias - Code Set ",trim(cnvtstring(ml_code_set
     ),3)," Export")
  SET ms_filename = concat("bhs_",trim(cnvtlower(curdomain),3),"_out_alias_cs",trim(cnvtstring(
     ml_code_set),3),".csv")
  SELECT INTO value(ms_filename)
   cvo.*
   FROM code_value_outbound cvo
   PLAN (cvo
    WHERE cvo.code_set=ml_code_set)
   ORDER BY cvo.alias
   WITH pcformat('"',",",1), format = stream, format,
    skipreport = 1
  ;end select
 ENDIF
 IF (curqual > 0)
  CALL emailfile(value(ms_filename),ms_filename,ms_email,ms_tmp,0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   PLAN (d)
   HEAD REPORT
    col 0, ms_subject, row + 1,
    ms_tmp = concat("Sent to: ",ms_email), col 0, ms_tmp
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (textlen(ms_log) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   PLAN (d)
   HEAD REPORT
    col 0, ms_log
   WITH nocounter
  ;end select
 ENDIF
END GO

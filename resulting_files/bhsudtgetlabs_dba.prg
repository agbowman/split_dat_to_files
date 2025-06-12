CREATE PROGRAM bhsudtgetlabs:dba
 DECLARE mn_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE ms_table_row_b = vc WITH protect, constant("<td><p><span>")
 DECLARE ms_table_row_e = vc WITH protect, constant("</span></p></td>")
 DECLARE mf_sensitive_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12033,"SENSITIVE"))
 DECLARE mf_active_life_cycle_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12030,
   "ACTIVE"))
 DECLARE mf_snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE ms_event_group = vc WITH protect, noconstant(" ")
 DECLARE ms_text = vc WITH protect, noconstant(" ")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 IF (validate(reply->text)=0)
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
  )
 ENDIF
 FREE RECORD labs
 RECORD labs(
   1 s_lead_val = vc
   1 s_lead_dt_tm = vc
   1 s_hba1c_val = vc
   1 s_hba1c_dt_tm = vc
   1 s_ldl_val = vc
   1 s_ldl_dt_tm = vc
   1 s_hdl_val = vc
   1 s_hdl_dt_tm = vc
   1 s_trigl_val = vc
   1 s_trigl_dt_tm = vc
   1 s_chol_val = vc
   1 s_chol_dt_tm = vc
 )
 IF (mn_debug_flag >= 1)
  CALL echo("Start of script bhs_udt_get_problems")
 ENDIF
 SELECT
  t.person_id, ce.event_end_dt_tm, ce.result_val,
  cv.display_key
  FROM code_value cv,
   clinical_event ce,
   code_value cv2
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.display_key IN ("HEMOGLOBINA1CMONITORING", "GLYCOHEMOGLOBINA1C", "HEMOGLOBINA1CDIAGNOSTIC",
   "POCHGA1CRESULTS", "CHOLESTEROL",
   "TRIGLYCERIDES", "HDLCHOLESTEROL", "LDLCHOLESTEROL", "LDLCARDIAC", "DIRECTLOWDENSITYLIPOPROTEIN",
   "BLOODLEADPEDI15YR"))
   JOIN (ce
   WHERE ce.event_cd=cv.code_value
    AND (ce.person_id=request->person_id)
    AND (ce.event_end_dt_tm > (sysdate - 365))
    AND textlen(trim(ce.result_val)) > 0)
   JOIN (cv2
   WHERE cv2.code_value=ce.result_status_cd
    AND  NOT (cv2.display_key IN ("NOTDONE", "INERROR")))
  ORDER BY ce.event_end_dt_tm
  DETAIL
   IF (cv.display_key IN ("HEMOGLOBINA1CMONITORING", "GLYCOHEMOGLOBINA1C", "HEMOGLOBINA1CDIAGNOSTIC",
   "POCHGA1CRESULTS"))
    labs->s_hba1c_val = ce.result_val, labs->s_hba1c_dt_tm = substring(1,14,format(ce.event_end_dt_tm,
      "@SHORTDATE;;Q"))
   ELSEIF (cv.display_key IN ("CHOLESTEROL"))
    labs->s_chol_val = ce.result_val, labs->s_chol_dt_tm = substring(1,14,format(ce.event_end_dt_tm,
      "@SHORTDATE;;Q"))
   ELSEIF (cv.display_key IN ("TRIGLYCERIDES"))
    labs->s_trigl_val = ce.result_val, labs->s_trigl_dt_tm = substring(1,14,format(ce.event_end_dt_tm,
      "@SHORTDATE;;Q"))
   ELSEIF (cv.display_key IN ("HDLCHOLESTEROL"))
    labs->s_hdl_val = ce.result_val, labs->s_hdl_dt_tm = substring(1,14,format(ce.event_end_dt_tm,
      "@SHORTDATE;;Q"))
   ELSEIF (cv.display_key IN ("LDLCHOLESTEROL", "LDLCARDIAC", "DIRECTLOWDENSITYLIPOPROTEIN"))
    labs->s_ldl_val = ce.result_val, labs->s_ldl_dt_tm = substring(1,14,format(ce.event_end_dt_tm,
      "@SHORTDATE;;Q"))
   ELSEIF (cv.display_key IN ("BLOODLEADPEDI15YR"))
    labs->s_lead_val = ce.result_val, labs->s_lead_dt_tm = substring(1,14,format(ce.event_end_dt_tm,
      "@SHORTDATE;;Q"))
   ENDIF
  WITH nocounter
 ;end select
 IF (mn_debug_flag >= 8)
  CALL echorecord(labs)
 ENDIF
 SET ms_text = concat("<html><body><table border=0 cellspacing=0 cellpadding=0>","<tr>",
  "<td width=125 valign=top><p><b><span>Lab</span></b></p></td>",
  "<td width=100 valign=top><p><b><span>Result Value</span></b></p></td>",
  "<td width=100 valign=top><p><b><span>Date</span></b></p></td>",
  "</tr>")
 SET ms_text = concat(ms_text,"<tr>")
 SET ms_text = concat(ms_text,ms_table_row_b,"Lead",ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_lead_val,ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_lead_dt_tm,ms_table_row_e)
 SET ms_text = concat(ms_text,"</tr>")
 SET ms_text = concat(ms_text,"<tr>")
 SET ms_text = concat(ms_text,ms_table_row_b,"Hemoglobin A1C",ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_hba1c_val,ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_hba1c_dt_tm,ms_table_row_e)
 SET ms_text = concat(ms_text,"</tr>")
 SET ms_text = concat(ms_text,"<tr>")
 SET ms_text = concat(ms_text,ms_table_row_b,"LDL",ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_ldl_val,ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_ldl_dt_tm,ms_table_row_e)
 SET ms_text = concat(ms_text,"</tr>")
 SET ms_text = concat(ms_text,"<tr>")
 SET ms_text = concat(ms_text,ms_table_row_b,"HDL",ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_hdl_val,ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_hdl_dt_tm,ms_table_row_e)
 SET ms_text = concat(ms_text,"</tr>")
 SET ms_text = concat(ms_text,"<tr>")
 SET ms_text = concat(ms_text,ms_table_row_b,"Triglycerides",ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_trigl_val,ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_trigl_dt_tm,ms_table_row_e)
 SET ms_text = concat(ms_text,"</tr>")
 SET ms_text = concat(ms_text,"<tr>")
 SET ms_text = concat(ms_text,ms_table_row_b,"Total Cholesterol",ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_chol_val,ms_table_row_e)
 SET ms_text = concat(ms_text,ms_table_row_b,labs->s_chol_dt_tm,ms_table_row_e)
 SET ms_text = concat(ms_text,"</tr>")
 SET ms_text = concat(ms_text,"</table></body></html>")
 SET reply->text = ms_text
 SET reply->format = 1
 IF (mn_debug_flag >= 5)
  CALL echo(build("reply->text:",reply->text))
 ENDIF
#exit_script
 IF (mn_debug_flag >= 4)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD labs
 IF (mn_debug_flag >= 1)
  CALL echo("End of script bhs_udt_get_problems")
 ENDIF
END GO

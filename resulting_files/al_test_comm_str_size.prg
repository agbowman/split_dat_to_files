CREATE PROGRAM al_test_comm_str_size
 DECLARE mf_cs16449_reasonforexam_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "REASONFOREXAM"))
 DECLARE mf_cs16449_reasonforexamdcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   16449,"REASONFOREXAMDCP"))
 DECLARE mf_cs16449_clinquestion1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "RADIOLOGYCLINICALQUESTION"))
 DECLARE mf_cs16449_clinquestion2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "OTHERCLINICALQUESTION"))
 DECLARE mf_cs16449_specialinstructions_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   16449,"SPECIALINSTRUCTIONS"))
 DECLARE mf_order_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_ft_exam_reason = vc WITH protect, noconstant("")
 DECLARE ms_exam_reason = vc WITH protect, noconstant("")
 DECLARE ms_clin_question = vc WITH protect, noconstant("")
 DECLARE ms_other_clin_question = vc WITH protect, noconstant("")
 DECLARE ms_special_instructions = vc WITH protect, noconstant("")
 DECLARE ms_temp_str = vc WITH protect, noconstant("")
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE ml_blob_return_len = i4 WITH protect, noconstant(0)
 DECLARE ml_bsize = i4 WITH protect, noconstant(0)
 DECLARE mf_cs71_hxofpresentillness_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HISTORYOFPRESENTILLNESS"))
 DECLARE mf_cs71_otherobjectivefindings_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"OTHEROBJECTIVEFINDINGS"))
 SET ms_blob_out = fillstring(65536," ")
 DECLARE ms_hx_of_present_illness = vc WITH protect, noconstant("")
 DECLARE ms_other_obj_findings = vc WITH protect, noconstant("")
 DECLARE ml_check_msg_size = i4 WITH protect, noconstant(0)
 SET mf_order_id = 4320884597.0
 SELECT INTO "nl:"
  FROM order_detail od
  PLAN (od
   WHERE od.order_id=mf_order_id
    AND od.oe_field_id IN (mf_cs16449_reasonforexam_cd, mf_cs16449_reasonforexamdcp_cd,
   mf_cs16449_clinquestion1_cd, mf_cs16449_clinquestion2_cd, mf_cs16449_specialinstructions_cd))
  ORDER BY od.oe_field_id, od.action_sequence DESC
  HEAD od.oe_field_id
   IF (od.oe_field_id=mf_cs16449_reasonforexam_cd)
    ms_ft_exam_reason = trim(od.oe_field_display_value,3)
   ENDIF
   IF (od.oe_field_id=mf_cs16449_reasonforexamdcp_cd)
    ms_exam_reason = trim(od.oe_field_display_value,3)
   ENDIF
   IF (od.oe_field_id=mf_cs16449_clinquestion1_cd)
    ms_clin_question = trim(od.oe_field_display_value,3)
   ENDIF
   IF (od.oe_field_id=mf_cs16449_clinquestion2_cd)
    ms_other_clin_question = trim(od.oe_field_display_value,3)
   ENDIF
   IF (od.oe_field_id=mf_cs16449_specialinstructions_cd)
    ms_special_instructions = trim(od.oe_field_display_value,3)
   ENDIF
  WITH nocounter
 ;end select
 IF (size(trim(ms_exam_reason,3)) > 0)
  SET ms_temp_str = concat("Reason: ",ms_exam_reason)
 ENDIF
 IF (size(trim(ms_ft_exam_reason,3)) > 0)
  IF (size(trim(ms_temp_str,3)) > 0)
   SET ms_temp_str = concat(ms_temp_str,"; ",ms_ft_exam_reason)
  ELSE
   SET ms_temp_str = concat("Reason: ",ms_ft_exam_reason)
  ENDIF
 ENDIF
 IF (size(trim(ms_clin_question,3)) > 0)
  IF (size(trim(ms_temp_str,3)) > 0)
   SET ms_temp_str = concat(ms_temp_str,"; Clinical Question(s): ",ms_clin_question)
  ELSE
   SET ms_temp_str = concat("Clinical Question(s): ",ms_clin_question)
  ENDIF
  IF (size(trim(ms_other_clin_question,3)) > 0)
   SET ms_temp_str = concat(ms_temp_str,"; ",ms_other_clin_question)
  ENDIF
 ELSEIF (size(trim(ms_other_clin_question,3)) > 0)
  IF (size(trim(ms_temp_str,3)) > 0)
   SET ms_temp_str = concat(ms_temp_str,"; Clinical Question(s): ",ms_other_clin_question)
  ELSE
   SET ms_temp_str = concat("Clinical Question(s): ",ms_other_clin_question)
  ENDIF
 ENDIF
 IF (size(trim(ms_special_instructions,3)) > 0)
  IF (size(trim(ms_temp_str,3)) > 0)
   SET ms_temp_str = concat(ms_temp_str,"; Special Instructions: ",ms_special_instructions)
  ELSE
   SET ms_temp_str = concat("Special Instructions: ",ms_special_instructions)
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   clinical_event ce,
   ce_blob cb
  PLAN (o
   WHERE o.order_id=mf_order_id)
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.event_cd IN (mf_cs71_hxofpresentillness_cd, mf_cs71_otherobjectivefindings_cd)
    AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd))
   JOIN (cb
   WHERE cb.event_id=outerjoin(ce.event_id)
    AND cb.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY ce.event_cd, ce.clinsig_updt_dt_tm DESC
  HEAD ce.event_cd
   IF (ce.event_cd=mf_cs71_hxofpresentillness_cd)
    ms_hx_of_present_illness = trim(ce.result_val,3)
   ENDIF
   IF (mf_cs71_otherobjectivefindings_cd)
    IF (cb.event_id > 0.0)
     CALL uar_ocf_uncompress(cb.blob_contents,size(cb.blob_contents),ms_blob_out,size(ms_blob_out),
     ml_blob_return_len),
     CALL uar_rtf2(ms_blob_out,size(ms_blob_out),ms_blob_out,size(ms_blob_out),ml_bsize,1),
     ms_other_obj_findings = trim(ms_blob_out,3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (size(trim(ms_hx_of_present_illness,3)) > 0)
  IF (size(trim(ms_temp_str,3)) > 0)
   SET ms_temp_str = concat(ms_temp_str,"; Hx of Present Illness: ",ms_hx_of_present_illness)
  ELSE
   SET ms_temp_str = concat("Hx of Present Illness: ",ms_hx_of_present_illness)
  ENDIF
 ENDIF
 IF (size(trim(ms_other_obj_findings,3)) > 0)
  IF (size(trim(ms_temp_str,3)) > 0)
   SET ms_temp_str = concat(ms_temp_str,"; Other Objective Findings: ",ms_other_obj_findings)
  ELSE
   SET ms_temp_str = concat("Other Objective Findings: ",ms_other_obj_findings)
  ENDIF
 ENDIF
 SET ml_check_msg_size = 1
 SELECT INTO "nl:"
  FROM order_comment oc,
   long_text lt
  PLAN (oc
   WHERE oc.order_id=mf_order_id)
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id
    AND lt.active_ind=1)
  ORDER BY oc.action_sequence DESC
  HEAD REPORT
   ml_check_msg_size = 0
   IF (((((size(trim(lt.long_text,3))+ size(trim(ms_temp_str,3)))+ 2)+ size("Order Comment: ")) > 400
   ))
    ms_temp_str = concat("Refer to EMR; ",trim(substring(1,386,concat(ms_temp_str,"; Order Comment: ",
        trim(lt.long_text,3)))))
   ELSE
    IF (size(trim(ms_temp_str,3)) > 0)
     ms_temp_str = concat(ms_temp_str,"; Order Comment: ",trim(lt.long_text,3))
    ELSE
     ms_temp_str = trim(lt.long_text,3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_check_msg_size=1)
  IF (size(trim(ms_temp_str,3)) > 400)
   SET ms_temp_str = concat("Refer to EMR; ",trim(substring(1,386,ms_temp_str),3))
  ENDIF
 ENDIF
 SET ms_temp_str = replace(replace(replace(replace(replace(replace(replace(replace(ms_temp_str,"&",
         " "),"^"," "),"|"," "),"~"," "),"\"," "),char(9),"  "),char(10)," "),char(13)," ")
 CALL echo(ms_temp_str)
END GO

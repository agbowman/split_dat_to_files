CREATE PROGRAM bhs_ma_test_ff_diabetic:dba
 FREE SET results
 RECORD results(
   1 person_id = f8
   1 p_name = vc
   1 hgb = f8
   1 hgb_cd = f8
   1 hgb_utd = vc
   1 hgdt = vc
   1 average_glucose = f8
   1 avg_glucose_utd = vc
   1 glucosedt = vc
   1 bp_systolic = i4
   1 bp_sysdt = vc
   1 bp_diastolic = i4
   1 bp_diasdt = vc
   1 bp_utd = vc
   1 blood_pressure = vc
   1 bp_dt = vc
   1 chol_total = i4
   1 chol_total_utd = vc
   1 chol_total_dt = vc
   1 chol_ldl = i4
   1 chol_ldl_utd = vc
   1 chol_ldl_dt = vc
   1 chol_hdl = i4
   1 chol_hdl_utd = vc
   1 chol_hdl_dt = vc
   1 chol_triglycerides = i4
   1 chol_triglyc_utd = vc
   1 chol_trig_dt = vc
   1 bmi = f8
   1 bmi_utd = vc
   1 bmi_dt = vc
   1 height_value = f8
   1 height_units_cd = f8
   1 use_height_value = f8
   1 ideal_23 = f8
   1 ideal_27 = f8
   1 eye_exam_event_id = f8
   1 eye_exam_date = dq8
   1 eye_follow_event_id = f8
   1 eye_follow_date = dq8
   1 foot_exam_date = dq8
   1 influenza_date = dq8
   1 pneumo_date = dq8
   1 creat_ratio = i4
   1 creat_utd = vc
 )
 RECORD temp(
   1 stemp = vc
 )
 DECLARE mnstat = i2 WITH noconstant(0)
 DECLARE hgb1_cd = f8 WITH public, noconstant(0.0)
 DECLARE hgb2_cd = f8 WITH public, noconstant(0.0)
 DECLARE hgb3_cd = f8 WITH public, noconstant(0.0)
 DECLARE hgb4_cd = f8 WITH public, noconstant(0.0)
 DECLARE avg_gluc_cd = f8 WITH public, noconstant(0.0)
 DECLARE bp_systolic_cd = f8 WITH public, noconstant(0.0)
 DECLARE bp_diastolic_cd = f8 WITH public, noconstant(0.0)
 DECLARE chol1_cd = f8 WITH public, noconstant(0.0)
 DECLARE chol2_cd = f8 WITH public, noconstant(0.0)
 DECLARE chol_trig1_cd = f8 WITH public, noconstant(0.0)
 DECLARE chol_trig2_cd = f8 WITH public, noconstant(0.0)
 DECLARE chol_hdl1_cd = f8 WITH public, noconstant(0.0)
 DECLARE chol_hdl2_cd = f8 WITH public, noconstant(0.0)
 DECLARE chol_ldl1_cd = f8 WITH public, noconstant(0.0)
 DECLARE chol_ldl2_cd = f8 WITH public, noconstant(0.0)
 DECLARE chol_ldl3_cd = f8 WITH public, noconstant(0.0)
 DECLARE bmi_cd = f8 WITH public, noconstant(0.0)
 DECLARE height_cd = f8 WITH public, noconstant(0.0)
 DECLARE eye_follow_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza1_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza2_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza3_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza4_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza5_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza6_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza7_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza8_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza9_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza10_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza11_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza12_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza13_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza14_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza15_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza16_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza17_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza18_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza19_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza20_cd = f8 WITH public, noconstant(0.0)
 DECLARE influenza21_cd = f8 WITH public, noconstant(0.0)
 DECLARE pneumo1_cd = f8 WITH public, noconstant(0.0)
 DECLARE pneumo2_cd = f8 WITH public, noconstant(0.0)
 DECLARE pneumo3_cd = f8 WITH public, noconstant(0.0)
 DECLARE pneumo4_cd = f8 WITH public, noconstant(0.0)
 DECLARE pneumo5_cd = f8 WITH public, noconstant(0.0)
 DECLARE pneumo6_cd = f8 WITH public, noconstant(0.0)
 DECLARE pneumo7_cd = f8 WITH public, noconstant(0.0)
 DECLARE pneumo8_cd = f8 WITH public, noconstant(0.0)
 DECLARE creat_ratio1_cd = f8 WITH public, noconstant(0.0)
 DECLARE creat_ratio2_cd = f8 WITH public, noconstant(0.0)
 DECLARE inerror_cd = f8 WITH noconstant(0.0)
 DECLARE notdone_cd = f8 WITH noconstant(0.0)
 DECLARE cm_cd = f8 WITH public, noconstant(0.0)
 DECLARE in_cd = f8 WITH public, noconstant(0.0)
 SET hgb1_cd = uar_get_code_by("DISPLAYKEY",72,"HEMOGLOBINA1CMONITORING")
 SET hgb2_cd = uar_get_code_by("DISPLAYKEY",72,"HEMOGLOBINA")
 SET hgb3_cd = uar_get_code_by("DISPLAYKEY",72,"HEMOGLOBINA2")
 SET hgb5_cd = uar_get_code_by("DISPLAYKEY",72,"HEMOGLOBINA1CMONITORING")
 SET hgb6_cd = uar_get_code_by("DISPLAYKEY",72,"HEMOGLOBINPOCPOCCARTRIDGE")
 SET avg_gluc_cd = uar_get_code_by("DISPLAYKEY",72,"ESTIMATEDAVERAGEGLUCOSE")
 SET bp_systolic_cd = uar_get_code_by("DISPLAYKEY",72,"SYSTOLICBLOODPRESSURE")
 SET bp_diastolic_cd = uar_get_code_by("DISPLAYKEY",72,"DIASTOLICBLOODPRESSURE")
 SET chol1_cd = uar_get_code_by("DISPLAYKEY",72,"CHOLESTEROL")
 SET chol_trig1_cd = uar_get_code_by("DISPLAYKEY",72,"TRIGLYCERIDES")
 SET chol_hdl1_cd = uar_get_code_by("DISPLAYKEY",72,"HDLCHOLESTEROL")
 SET chol_ldl1_cd = uar_get_code_by("DISPLAYKEY",72,"LDLCHOLESTEROL")
 SET bmi_cd = uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX")
 SET height_cd = uar_get_code_by("DISPLAYKEY",72,"HEIGHT")
 SET eye_follow_cd = uar_get_code_by("DISPLAYKEY",72,"EYEEXAMFOLLOWUP")
 SET eye_exam_findings_cd = uar_get_code_by("DISPLAYKEY",72,"EYEEXAMFINDINGS")
 SET foot_exam_performedby_cd = uar_get_code_by("DISPLAYKEY",72,"FOOTEXAMPERFORMEDBY")
 SET influenza1_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAVIRUSVACCINEINACTIVATED")
 SET influenza2_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAVIRUSVACCINEOLDTERM")
 SET influenza3_cd = uar_get_code_by("DISPLAYKEY",72,"PREVNARINJOLDTERM")
 SET influenza4_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAINACTIVEIMOLDTERM")
 SET influenza5_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZALIVEINTRANASALOLDTERM")
 SET influenza6_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAVACCINEOLDTERM")
 SET influenza7_cd = uar_get_code_by("DISPLAYKEY",72,"AFLURIAOLDTERM")
 SET influenza8_cd = uar_get_code_by("DISPLAYKEY",72,"DECAVACOLDTERM")
 SET influenza9_cd = uar_get_code_by("DISPLAYKEY",72,"FLUARIXOLDTERM")
 SET influenza10_cd = uar_get_code_by("DISPLAYKEY",72,"FLULAVALOLDTERM")
 SET influenza11_cd = uar_get_code_by("DISPLAYKEY",72,"FLUMISTOLDTERM")
 SET influenza12_cd = uar_get_code_by("DISPLAYKEY",72,"FLUVIRINOLDTERM")
 SET influenza13_cd = uar_get_code_by("DISPLAYKEY",72,"FLUVIRINPRESERVATIVEFREEOLDTERM")
 SET influenza14_cd = uar_get_code_by("DISPLAYKEY",72,"FLUZONEOLDTERM")
 SET influenza15_cd = uar_get_code_by("DISPLAYKEY",72,"FLUZONEPRESERVATIVEFREEOLDTERM")
 SET influenza16_cd = uar_get_code_by("DISPLAYKEY",72,"FLUZONEPRESERVATIVEFREEPEDIOLDTERM")
 SET influenza17_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUENZAVIRUSVACCINELIVE")
 SET influenza18_cd = uar_get_code_by("DISPLAYKEY",72,"PREVNAROLDTERM")
 SET influenza19_cd = uar_get_code_by("DISPLAYKEY",72,"PROQUADOLDTERM")
 SET influenza20_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUVIRUSVACH1N1INACTIVEOLDTERM")
 SET influenza21_cd = uar_get_code_by("DISPLAYKEY",72,"INFLUVIRUSVACH1N1LIVEOLDTERM")
 SET pneumo1_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCALVACCINEOLDTERM")
 SET pneumo2_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCALVACCOLDTERM")
 SET pneumo3_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCALCONJUGATEPCV7OLDTERM")
 SET pneumo4_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCALPOLYPPV23OLDTERM")
 SET pneumo5_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCAL23VALENTVACCINE")
 SET pneumo6_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCAL7VALENTVACCINE")
 SET pneumo7_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOVAX23OLDTERM")
 SET pneumo8_cd = uar_get_code_by("DISPLAYKEY",72,"PNEUMOCOCCAL13VALENTVACCINE")
 SET creat_ratio1_cd = uar_get_code_by("DISPLAYKEY",72,"MALBCREATRATIO")
 SET mnstat = uar_get_meaning_by_codeset(8,"INERROR",1,inerror_cd)
 SET mnstat = uar_get_meaning_by_codeset(8,"NOT DONE",1,notdone_cd)
 SET mnstat = uar_get_meaning_by_codeset(54,"CM",1,cm_cd)
 SET mnstat = uar_get_meaning_by_codeset(54,"INCHES",1,in_cd)
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM encounter e,
   person p
  PLAN (e
   WHERE (e.encntr_id= $ENCID))
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD p.person_id
   results->person_id = p.person_id, results->p_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ce.event_cd IN (avg_gluc_cd, bp_systolic_cd, bp_diastolic_cd, bmi_cd, height_cd,
   eye_follow_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF avg_gluc_cd:
     IF (cnvtreal(ce.event_tag) > 0)
      results->average_glucose = cnvtreal(ce.event_tag)
     ELSE
      results->avg_glucose_utd = trim(ce.event_tag,3)
     ENDIF
     ,results->glucosedt = format(ce.event_end_dt_tm,"mm/dd/yy ;;d")
    OF bp_systolic_cd:
     IF (cnvtint(ce.event_tag) > 0)
      results->bp_systolic = cnvtint(ce.event_tag)
     ELSE
      results->bp_utd = trim(ce.event_tag,3)
     ENDIF
     ,results->bp_sysdt = format(ce.event_end_dt_tm,"mm/dd/yy ;;d")
    OF bp_diastolic_cd:
     IF (cnvtint(ce.event_tag) > 0)
      results->bp_diastolic = cnvtint(ce.event_tag)
     ELSE
      results->bp_utd = trim(ce.event_tag,3)
     ENDIF
     ,results->bp_diasdt = format(ce.event_end_dt_tm,"mm/dd/yy ;;d")
    OF bmi_cd:
     IF (cnvtreal(ce.event_tag) > 0)
      results->bmi = cnvtreal(ce.event_tag)
     ELSE
      results->bmi_utd = trim(ce.event_tag,3)
     ENDIF
     ,results->bmi_dt = format(ce.event_end_dt_tm,"mm/dd/yy ;;d")
    OF height_cd:
     results->height_value = cnvtreal(ce.event_tag),results->height_units_cd = ce.result_units_cd
    OF eye_follow_cd:
     results->eye_follow_event_id = ce.event_id
   ENDCASE
  WITH nocounter
 ;end select
 IF ((results->eye_follow_event_id > 0))
  SELECT INTO "nl:"
   ce.event_tag
   FROM ce_date_result cedr
   PLAN (cedr
    WHERE (cedr.event_id=results->eye_follow_event_id)
     AND cedr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   DETAIL
    results->eye_follow_date = cnvtdatetime(cedr.result_dt_tm)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ce.event_cd IN (hgb1_cd, hgb2_cd, hgb3_cd, hgb5_cd, hgb6_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY ce.event_end_dt_tm
  DETAIL
   IF (cnvtreal(ce.event_tag) > 0)
    results->hgb = cnvtreal(ce.event_tag)
   ELSE
    results->hgb = 0.0
   ENDIF
   results->hgb_utd = trim(ce.event_tag,3), results->hgb_cd = ce.event_cd, results->hgdt = format(ce
    .event_end_dt_tm,"mm/dd/yy ;;d")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ce.event_cd IN (chol1_cd, chol2_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY ce.event_end_dt_tm
  DETAIL
   IF (cnvtint(ce.event_tag) > 0)
    results->chol_total = cnvtint(ce.event_tag), results->chol_total_utd = ""
   ELSE
    results->chol_total = 0, results->chol_total_utd = trim(ce.event_tag,3)
   ENDIF
   results->chol_total_dt = format(ce.event_end_dt_tm,"mm/dd/yy ;;d")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ce.event_cd IN (chol_trig1_cd, chol_trig2_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY ce.event_end_dt_tm
  DETAIL
   IF (cnvtint(ce.event_tag) > 0)
    results->chol_triglycerides = cnvtint(ce.event_tag), results->chol_triglyc_utd = ""
   ELSE
    results->chol_triglycerides = 0, results->chol_triglyc_utd = trim(ce.event_tag,3)
   ENDIF
   results->chol_trig_dt = format(ce.event_end_dt_tm,"mm/dd/yy ;;d")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ce.event_cd IN (chol_hdl1_cd, chol_hdl2_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY ce.event_end_dt_tm
  DETAIL
   IF (cnvtint(ce.event_tag) > 0)
    results->chol_hdl = cnvtint(ce.event_tag), results->chol_hdl_utd = ""
   ELSE
    results->chol_hdl = 0, results->chol_hdl_utd = trim(ce.event_tag,3)
   ENDIF
   results->chol_hdl_dt = format(ce.event_end_dt_tm,"mm/dd/yy ;;d")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ce.event_cd IN (chol_ldl1_cd, chol_ldl2_cd, chol_ldl3_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY ce.event_end_dt_tm
  DETAIL
   IF (cnvtint(ce.event_tag) > 0)
    results->chol_ldl = cnvtint(ce.event_tag), results->chol_ldl_utd = ""
   ELSE
    results->chol_ldl = 0, results->chol_ldl_utd = trim(ce.event_tag,3)
   ENDIF
   results->chol_ldl_dt = format(ce.event_end_dt_tm,"mm/dd/yy ;;d")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ((ce.event_title_text IN ("Diabetes Eye Exam", "Date of Eye Exam")) OR (ce.event_cd IN (
   eye_exam_findings_cd)))
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY ce.event_end_dt_tm
  HEAD ce.person_id
   results->eye_exam_date = cnvtdatetime(ce.event_end_dt_tm)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ((ce.event_title_text IN ("Date of Foot Exam")) OR (ce.event_cd IN (foot_exam_performedby_cd)
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))) )
  ORDER BY ce.event_end_dt_tm
  HEAD ce.person_id
   results->foot_exam_date = cnvtdatetime(ce.event_end_dt_tm)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ce.event_cd IN (influenza1_cd, influenza2_cd, influenza3_cd, influenza4_cd, influenza5_cd,
   influenza6_cd, influenza7_cd, influenza8_cd, influenza9_cd, influenza10_cd,
   influenza11_cd, influenza12_cd, influenza13_cd, influenza14_cd, influenza15_cd,
   influenza16_cd, influenza17_cd, influenza18_cd, influenza19_cd, influenza20_cd,
   influenza21_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY ce.event_end_dt_tm
  DETAIL
   results->influenza_date = cnvtdatetime(ce.event_end_dt_tm)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ce.event_cd IN (pneumo1_cd, pneumo2_cd, pneumo3_cd, pneumo4_cd, pneumo5_cd,
   pneumo6_cd, pneumo7_cd, pneumo8_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY ce.event_end_dt_tm
  DETAIL
   results->pneumo_date = cnvtdatetime(ce.event_end_dt_tm)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.event_tag
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=results->person_id)
    AND ce.event_cd IN (creat_ratio1_cd, creat_ratio2_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND  NOT (ce.result_status_cd IN (inerror_cd, notdone_cd))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
  ORDER BY ce.event_end_dt_tm
  DETAIL
   IF (cnvtint(ce.event_tag) > 0)
    results->creat_ratio = cnvtint(ce.event_tag), results->creat_utd = ""
   ELSE
    results->creat_ratio = 0, results->creat_utd = "Less than 5"
   ENDIF
  WITH nocounter
 ;end select
 IF ((results->bp_systolic > 0))
  SET results->blood_pressure = concat(trim(cnvtstring(results->bp_systolic),3),"/ ",trim(cnvtstring(
     results->bp_diastolic),3))
 ENDIF
 IF ((results->height_value > 0))
  IF ((results->height_units_cd=cm_cd))
   SET results->use_height_value = (results->height_value/ 2.54)
  ENDIF
  IF ((results->height_units_cd=in_cd))
   SET results->use_height_value = results->height_value
  ENDIF
 ENDIF
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   x = 0,
   CALL printimage("cclsource:deac2.frm")
  HEAD PAGE
   "{ps/ 0.0 c$clr  24 768 moveto  3.000 5.143 180.000 20.000 c$box}", row + 1,
   "{ps/ 29.0 c$clr  143 743 moveto  3.000 5.143 198.000 683.000 c$box}",
   row + 1, "{ps/ 24.0 c$clr  23 743 moveto  3.000 5.143 119.000 683.000 c$box}", row + 1,
   "{ps/ gsave [] 0 setdash 24 773 moveto 210 773 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 25 772 moveto 209 772 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 25 748 moveto 209 748 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 24 747 moveto 210 747 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 24 773 moveto 24 747 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 25 772 moveto 25 748 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 209 772 moveto 209 748 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 210 773 moveto 210 747 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 447 760 moveto 579 760 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 442 748 moveto 579 748 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 26 745 moveto 580 745 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 26 725 moveto 580 725 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 26 642 moveto 580 642 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 26 572 moveto 580 572 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 26 486 moveto 580 486 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 26 438 moveto 580 438 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 26 381 moveto 580 381 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 26 324 moveto 580 324 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 26 271 moveto 580 271 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 26 209 moveto 580 209 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 26 138 moveto 580 138 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 26 62 moveto 580 62 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 26 745 moveto 26 62 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 145 745 moveto 145 62 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 344 745 moveto 344 62 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 580 745 moveto 580 62 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 721 moveto 359 721 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 713 moveto 359 713 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 721 moveto 351 713 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 721 moveto 359 713 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 712 moveto 360 712 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 720 moveto 360 712 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 706 moveto 359 706 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 698 moveto 359 698 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 706 moveto 351 698 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 706 moveto 359 698 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 697 moveto 360 697 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 705 moveto 360 697 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 691 moveto 359 691 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 683 moveto 359 683 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 691 moveto 351 683 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 691 moveto 359 683 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 682 moveto 360 682 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 690 moveto 360 682 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 638 moveto 359 638 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 630 moveto 359 630 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 638 moveto 351 630 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 638 moveto 359 630 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 629 moveto 360 629 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 637 moveto 360 629 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 623 moveto 359 623 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 615 moveto 359 615 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 623 moveto 351 615 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 623 moveto 359 615 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 614 moveto 360 614 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 622 moveto 360 614 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 568 moveto 359 568 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 560 moveto 359 560 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 568 moveto 351 560 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 568 moveto 359 560 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 559 moveto 360 559 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 567 moveto 360 559 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 553 moveto 359 553 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 545 moveto 359 545 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 553 moveto 351 545 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 553 moveto 359 545 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 544 moveto 360 544 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 552 moveto 360 544 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 538 moveto 359 538 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 530 moveto 359 530 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 538 moveto 351 530 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 538 moveto 359 530 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 529 moveto 360 529 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 537 moveto 360 529 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 513 moveto 359 513 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 505 moveto 359 505 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 513 moveto 351 505 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 513 moveto 359 505 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 504 moveto 360 504 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 512 moveto 360 504 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 482 moveto 359 482 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 474 moveto 359 474 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 482 moveto 351 474 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 482 moveto 359 474 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 473 moveto 360 473 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 481 moveto 360 473 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 434 moveto 359 434 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 426 moveto 359 426 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 434 moveto 351 426 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 434 moveto 359 426 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 425 moveto 360 425 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 433 moveto 360 425 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 377 moveto 359 377 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 369 moveto 359 369 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 377 moveto 351 369 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 377 moveto 359 369 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 368 moveto 360 368 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 376 moveto 360 368 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 351 moveto 359 351 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 343 moveto 359 343 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 351 moveto 351 343 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 351 moveto 359 343 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 342 moveto 360 342 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 350 moveto 360 342 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 320 moveto 359 320 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 312 moveto 359 312 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 320 moveto 351 312 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 320 moveto 359 312 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 311 moveto 360 311 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 319 moveto 360 311 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 267 moveto 359 267 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 259 moveto 359 259 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 267 moveto 351 259 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 267 moveto 359 259 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 258 moveto 360 258 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 266 moveto 360 258 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 205 moveto 359 205 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 197 moveto 359 197 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 205 moveto 351 197 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 205 moveto 359 197 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 196 moveto 360 196 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 204 moveto 360 196 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 179 moveto 359 179 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 171 moveto 359 171 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 179 moveto 351 171 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 179 moveto 359 171 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 170 moveto 360 170 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 178 moveto 360 170 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 134 moveto 359 134 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 126 moveto 359 126 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 134 moveto 351 126 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 134 moveto 359 126 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 125 moveto 360 125 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 133 moveto 360 125 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 351 108 moveto 359 108 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 100 moveto 359 100 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 351 108 moveto 351 100 lineto stroke grestore/}",
   row + 1, "{ps/ gsave [] 0 setdash 359 108 moveto 359 100 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 352 99 moveto 360 99 lineto stroke grestore/}", row + 1,
   "{ps/ gsave [] 0 setdash 360 107 moveto 360 99 lineto stroke grestore/}",
   row + 1, "{COLOR/0}", "{F/4}{CPI/8}{LPI/5}",
   row + 1, "{POS/33/18}Your Diabetes Report Card", row + 1,
   "{F/4}{CPI/11}{LPI/5}", row + 1, "{POS/415/12}Name:",
   row + 1, "{POS/415/24}Date:", row + 1,
   "{POS/450/12}", results->p_name, row + 1,
   "{POS/450/24}", curdate"mm/dd/yy;;d", row + 1,
   "{F/4}{CPI/10}{LPI/5}", row + 1, "{POS/214/43}{B}Risk Factor:",
   "{POS/426/43}{B}Your Goals:", "{F/4}{CPI/10}{LPI/5}", row + 1,
   "{POS/190/61}{B}Poor Diabetes Control", row + 1, "{F/4}{CPI/11}{LPI/5}",
   row + 1, "{POS/366/63}Hemoglobin A1c goal is less than 7.0%", row + 1,
   "{POS/366/78}Fasting blood glucose of 80-120 mg/ dL.", row + 1,
   "{POS/366/93}You should get your A1c checked every 3",
   row + 1, "{POS/366/105}to 6 months", row + 1
   IF ((results->hgb_utd > " "))
    hgb_utd = trim(results->hgb_utd), "{POS/255/74}", hgb_utd"{POS/300/74}",
    results->hgdt
   ELSE
    IF ((results->hgb > 0.0))
     "{POS/255/74}", results->hgb"###.#%", "{POS/300/74}",
     results->hgdt
    ENDIF
   ENDIF
   IF ( NOT ((results->hgb_cd IN (hgb2_cd, hgb4_cd))))
    IF ((results->avg_glucose_utd > " "))
     "{POS/250/88}", results->avg_glucose_utd
    ELSE
     IF ((results->average_glucose > 0.0))
      "{POS/261/88}", results->average_glucose"###"
     ENDIF
    ENDIF
   ENDIF
   "{F/6}{CPI/11}{LPI/5}", row + 1, "{POS/151/75}My Hemoglobin A1c is _____",
   row + 1, "{POS/151/88}= average glucose of ___________.", row + 1,
   "{POS/158/101}This A1c blood test measures how your", row + 1,
   "{POS/153/114}sugars (glucose) have been running in the",
   row + 1, "{POS/215/127}past 3 months.", row + 1,
   "{F/4}{CPI/10}{LPI/5}", row + 1, "{POS/194/144}{B}High Blood Pressure",
   row + 1, "{F/4}{CPI/11}{LPI/5}", row + 1,
   "{POS/366/146}{B}130/ 80 or less", row + 1,
   "{POS/366/161}You should get your blood pressure checked at",
   row + 1, "{POS/366/173}every office visit.", row + 1
   IF ((results->bp_utd > " "))
    "{POS/290/157}", results->bp_utd"(POS/302/157}", results->bp_diasdt
   ELSE
    IF ((results->blood_pressure > " "))
     "{POS/250/157}", results->blood_pressure"(POS/302/157}", results->bp_diasdt
    ENDIF
   ENDIF
   "{F/6}{CPI/11}{LPI/5}", row + 1, "{POS/151/158}My blood pressure is_________",
   row + 1, "{POS/176/171}This blood pressure goal is very", row + 1,
   "{POS/153/184}important in preventing the complications", row + 1, "{POS/220/197}of diabetes.",
   row + 1, "{F/0}{CPI/5}{LPI/3}", row + 1,
   "{POS/151/228}.", row + 1, "{POS/151/241}.",
   row + 1, "{POS/151/254}.", row + 1,
   "{POS/151/267}.", row + 1, "{F/4}{CPI/10}{LPI/5}",
   row + 1, "{POS/200/214}{B}High Cholesterol", row + 1,
   "{F/4}{CPI/11}{LPI/5}", row + 1, "{POS/366/216}Total Cholesterol {U}less than 200",
   row + 1, "{POS/366/231}Triglycerides {U}less than 150", row + 1,
   "{POS/366/246}HDL {U}more than 45{ENDU} (men), {U}more than 55", row + 1, "{POS/366/258}(women)",
   row + 1, "{POS/366/271}LDL {U}less than 100{ENDU} (if high risk heart disease", row + 1,
   "{POS/366/283}target is 70)", row + 1
   IF ((results->chol_total_utd > " "))
    "{POS/283/227}", results->chol_total_utd"{POS/302/227}", results->chol_total_dt
   ELSE
    IF ((results->chol_total > 0))
     "{POS/283/227}", results->chol_total"###", "{POS/302/227}",
     results->chol_total_dt
    ENDIF
   ENDIF
   IF ((results->chol_triglyc_utd > " "))
    "{POS/261/240}", results->chol_triglyc_utd"{POS/302/240}", results->chol_trig_dt
   ELSE
    IF ((results->chol_triglycerides > 0))
     "{POS/266/240}", results->chol_triglycerides"####", "{POS/302/240}",
     results->chol_trig_dt
    ENDIF
   ENDIF
   IF ((results->chol_hdl_utd > " "))
    "{POS/260/253}", results->chol_hdl_utd"{POS/302/253}", results->chol_hdl_dt
   ELSE
    IF ((results->chol_hdl > 0))
     "{POS/266/253}", results->chol_hdl"###", "{POS/302/253}",
     results->chol_hdl_dt
    ENDIF
   ENDIF
   IF ((results->chol_ldl_utd > " "))
    "{POS/260/266}", results->chol_ldl_utd"{POS/302/266}", results->chol_ldl_dt
   ELSE
    IF ((results->chol_ldl > 0))
     "{POS/264/266}", results->chol_ldl"###", "{POS/302/266}",
     results->chol_ldl_dt
    ENDIF
   ENDIF
   "{F/6}{CPI/11}{LPI/5}", row + 1, "{POS/170/228}Total Cholesterol level is____",
   row + 1, "{POS/170/241}Triglyceride level is______", row + 1,
   "{POS/170/254}HDL (good) level is_____", row + 1, "{POS/170/267}LDL (bad) level is______",
   row + 1, "{F/4}{CPI/10}{LPI/5}", row + 1,
   "{POS/190/300}{B}Poor Diet and Obesity", row + 1, "{F/4}{CPI/11}{LPI/5}",
   row + 1, "{POS/366/302}Healthy eating and a healthy body weight help", row + 1,
   "{POS/366/314}keep your blood sugar and diabetes under", row + 1, "{POS/366/326}control.",
   row + 1
   IF ((results->bmi_utd > " "))
    "{POS/276/313}", results->bmi_utd"{POS/300/313}", results->bmi_dt
   ELSE
    IF ((results->bmi > 0))
     "{POS/280/313}", results->bmi"###", "{POS/300/313}",
     results->bmi_dt
    ENDIF
   ENDIF
   "{F/6}{CPI/11}{LPI/5}", row + 1, "{POS/150/314}My BMI (body mass index) is____",
   row + 1, "{POS/156/327}A BMI of 18-25 is considered healthy.", row + 1,
   "{POS/410/330}{B}Ideal weight:_________________", row + 1, "{F/4}{CPI/10}{LPI/5}",
   row + 1, "{POS/156/348}{B}Unrecognized Diabetic Eye Disease", row + 1,
   "{F/4}{CPI/11}{LPI/5}", row + 1, "{POS/366/350}Get a dilated eye exam by an eyecare specialist",
   row + 1, "{POS/366/362}{B}ONCE A YEAR{ENDB} or as directed.", row + 1
   IF ((results->eye_exam_date > 0))
    "{POS/260/385}", results->eye_exam_date"mm/dd/yy;;d", row + 1
   ENDIF
   IF ((results->eye_follow_date > 0))
    "{POS/410/385}", results->eye_follow_date"mm/dd/yy;;d", row + 1
   ENDIF
   "{F/6}{CPI/11}{LPI/5}", row + 1, "{POS/175/362}Diabetes is the leading cause of",
   row + 1, "{POS/199/374}blindness in the U.S.", row + 1,
   "{POS/156/386}{B}Date of last eye exam_______________", row + 1,
   "{POS/351/386}{B}Due Date:_______________",
   row + 1, "{F/4}{CPI/10}{LPI/5}", row + 1,
   "{POS/156/405}{B}Unrecognized Diabetic Foot Disease", row + 1, "{F/4}{CPI/11}{LPI/5}",
   row + 1, "{POS/366/407}Get a foot exam in your doctor's office {B}ONCE", row + 1,
   "{POS/366/419}{B}A YEAR.", row + 1, "{POS/366/433}Check your feet daily.",
   row + 1
   IF ((results->foot_exam_date > 0))
    "{POS/260/442}", results->foot_exam_date"mm/dd/yy;;d", row + 1
   ENDIF
   "{F/6}{CPI/11}{LPI/5}", row + 1, "{POS/158/419}Diabetes causes loss of sensation in the",
   row + 1, "{POS/193/431}feet and poor circulation.", row + 1,
   "{POS/156/443}{B}Date of last foot exam_______________", row + 1, "{F/4}{CPI/10}{LPI/5}",
   row + 1, "{POS/183/462}{B}Lack of Physical Activity", row + 1,
   "{F/4}{CPI/11}{LPI/5}", row + 1, "{POS/366/464}Exercise 30-60 minutes most days of the week.",
   row + 1, "{F/6}{CPI/11}{LPI/5}", row + 1,
   "{POS/366/476}(Increase to 60-90 minutes most days of the", row + 1,
   "{POS/366/488}week to manage body weight.)",
   row + 1, "{POS/164/474}Increased activity is a natural way of", row + 1,
   "{POS/165/486}improving your diabetes control and", row + 1, "{POS/215/498}overall health.",
   row + 1, "{F/4}{CPI/10}{LPI/5}", row + 1,
   "{POS/157/515}{B}Unrecognized Risk of Heart Disease", row + 1, "{POS/217/529}{B}and stroke",
   row + 1, "{F/4}{CPI/11}{LPI/5}", row + 1,
   "{POS/366/517}Take an Aspirin (or other blood thinner) a day", row + 1,
   "{POS/366/529}if you have diabetes and are over age 30 unless ",
   row + 1, "{POS/366/541}your physician tells you otherwise.", row + 1,
   "{F/6}{CPI/11}{LPI/5}", row + 1, "{POS/156/542}People with diabetes have an increased",
   row + 1, "{POS/174/554}risk of heart attack and stroke.", row + 1,
   "{F/4}{CPI/10}{LPI/5}", row + 1, "{POS/189/577}{B}Influenza Vaccination",
   row + 1, "{POS/176/591}{B}Pneumococcal Vaccination", row + 1,
   "{F/4}{CPI/11}{LPI/5}", row + 1, "{POS/366/579}Influenza vaccination annually",
   row + 1, "{POS/366/605}Pneumococcal vaccination - talk with your", row + 1,
   "{POS/366/617}care provider", row + 1
   IF ((results->influenza_date > 0))
    "{POS/480/590}", results->influenza_date"mm/dd/yy;;d", row + 1
   ENDIF
   IF ((results->pneumo_date > 0))
    "{POS/500/630}", results->pneumo_date"mm/dd/yy;;d", row + 1
   ENDIF
   "{F/6}{CPI/11}{LPI/5}", row + 1, "{POS/169/604}Getting these vaccines can prevent",
   row + 1, "{POS/183/616}serious illness or even death", row + 1,
   "{POS/351/591}{B}Last influenza vaccination___________", row + 1,
   "{POS/351/631}{B}Last pneumococcal vaccination___________",
   row + 1, "{F/4}{CPI/10}{LPI/5}", row + 1,
   "{POS/168/648}{B}Unrecognized Diabetic Kidney", row + 1, "{POS/226/661}{B}Disease",
   row + 1, "{F/4}{CPI/11}{LPI/5}", row + 1,
   "{POS/366/650}Get a yearly urine test to check if diabetes may", row + 1,
   "{POS/366/662}be affecting the kidneys.",
   row + 1, "{POS/366/676}If kidney damage is found, you should take a", row + 1,
   "{POS/366/688}type of blood pressure medicine called an ACE", row + 1,
   "{POS/366/700}Inhibitor to slow down the progression.",
   row + 1
   IF ((results->creat_utd > " "))
    "{POS/164/684}", results->creat_utd
   ELSE
    IF ((results->creat_ratio > 0))
     "{POS/178/684}", results->creat_ratio"###"
    ENDIF
   ENDIF
   "{F/6}{CPI/11}{LPI/5}", row + 1, "{POS/165/673}My microalbumin to creatinine ratio",
   row + 1, "{POS/150/685}is:_____________ (Normal is less than 30)", row + 1,
   "{POS/160/697}Diabetes is the most common cause of", row + 1,
   "{POS/188/709}kidney failure in the U.S.",
   row + 1, "{F/0}{CPI/5}{LPI/3}", row + 1,
   "{POS/370/736}TARGET", row + 1, "{F/0}{CPI/7}{LPI/3}",
   row + 1, "{POS/452/734}:", row + 1,
   "{F/9}{CPI/7}{LPI/3}", row + 1, "{POS/460/736}DIABETES",
   row + 1, "{F/4}{CPI/11}{LPI/5}", row + 1,
   "{POS/425/746}Focus on your future", row + 1, "{COLOR/10}",
   "{F/4}{CPI/10}{LPI/5}", row + 1, temp->stemp = concat("{POS/55/43}{B}",char(96),char(96),
    "A-B-C's''"),
   temp->stemp, row + 1, temp->stemp = concat("{POS/55/93}{B}is for ",char(96),char(96),"A1c''"),
   temp->stemp, row + 1, temp->stemp = concat("{POS/52/176}{B}is for ",char(96),char(96),"Blood"),
   temp->stemp, row + 1, "{POS/60/190}{B}Pressure''",
   row + 1, temp->stemp = concat("{POS/36/246}{B}is for ",char(96),char(96),"Cholesterol''"), temp->
   stemp,
   row + 1, temp->stemp = concat("{POS/53/332}{B}is for ",char(96),char(96),"Diet''"), temp->stemp,
   row + 1, temp->stemp = concat("{POS/52/380}{B}is for ",char(96),char(96),"Eyes''"), temp->stemp,
   row + 1, temp->stemp = concat("{POS/52/437}{B}is for ",char(96),char(96),"Feet''"), temp->stemp,
   row + 1, temp->stemp = concat("{POS/36/494}{B}is for ",char(96),char(96),"Get Active''"), temp->
   stemp,
   row + 1, temp->stemp = concat("{POS/41/547}{B}is for",char(96),char(96),"Heart and"), temp->stemp,
   row + 1, "{POS/65/561}{B}Stroke''", row + 1,
   "{POS/70/609}{B}is for", row + 1, temp->stemp = concat("{POS/40/623}{B}",char(96),char(96),
    "Immunizations''"),
   temp->stemp, row + 1, temp->stemp = concat("{POS/43/680}{B}is for ",char(96),char(96),"Kidneys''"),
   temp->stemp, row + 1, "{POS/66/665}{B}J,",
   row + 1, "{F/4}{CPI/4}{LPI/1}", row + 1,
   "{POS/75/78}{B}A", row + 1, "{POS/75/161}{B}B",
   row + 1, "{POS/75/231}{B}C", row + 1,
   "{POS/75/317}{B}D", row + 1, "{POS/75/365}{B}E",
   row + 1, "{POS/75/422}{B}F", row + 1,
   "{POS/72/479}{B}G", row + 1, "{POS/72/532}{B}H",
   row + 1, "{POS/77/594}{B}I", row + 1,
   "{POS/78/665}{B}K", row + 1,
   CALL print(calcpos(26,765)),
   CALL printimage("cclsource:deac2.dct")
  WITH nocounter, nullreport, dio = 08,
   noformfeed, maxcol = 2000, maxrow = 2000
 ;end select
END GO

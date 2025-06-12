CREATE PROGRAM bhs_rpt_ed_admit_bmd_modify:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE display_line = vc
 DECLARE tempstring = vc
 SET eid = trigger_encntrid
 SET retval = 100
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 FREE RECORD admit
 RECORD admit(
   1 result1 = vc
   1 result2 = vc
   1 result3 = vc
   1 result4 = vc
   1 result5 = vc
   1 result6 = vc
   1 result7 = vc
   1 result8 = vc
   1 result9 = vc
   1 result10 = vc
   1 result11 = vc
   1 result12 = vc
   1 result13 = vc
   1 result14 = vc
   1 result15 = vc
   1 result16 = vc
   1 result17 = vc
   1 result18 = vc
   1 result19 = vc
   1 result20 = vc
   1 result21 = vc
   1 result22 = vc
   1 result23 = vc
   1 result24 = vc
   1 result25 = vc
   1 result26 = vc
   1 result27 = vc
   1 result28 = vc
   1 result29 = vc
   1 result30 = vc
   1 result31 = vc
   1 result32 = vc
   1 result33 = vc
   1 result34 = vc
   1 result35 = vc
 )
 FREE RECORD textdisplay
 RECORD textdisplay(
   1 cnt = i4
   1 qual[*]
     2 display = vc
     2 result = i4
 )
 SET result1 = uar_get_code_by("DISPLAYKEY",72,"ADMISSIONCATEGORYED")
 SET result2 = uar_get_code_by("DISPLAYKEY",72,"EDREASONFORADMISSION")
 SET result3 = uar_get_code_by("DISPLAYKEY",72,"ADMITTINGPHYSICIAN")
 SET result4 = uar_get_code_by("DISPLAYKEY",72,"ATTENDINGPHYSICIAN")
 SET result5 = uar_get_code_by("displaykey",72,"ADMISSIONTYPE")
 SET result6 = uar_get_code_by("displaykey",72,"LEVELOFCARE")
 SET result7 = uar_get_code_by("displaykey",72,"BMDSERVICE")
 SET result8 = uar_get_code_by("displaykey",72,"ISOLATIONNEEDED")
 SET result9 = uar_get_code_by("displaykey",72,"11SITTERNEEDED")
 SET result10 = uar_get_code_by("displaykey",72,"PATIENTSTABILITYED")
 SET result11 = uar_get_code_by("displaykey",72,"ADDITIONALADMITCOMMENTSED")
 SET result12 = uar_get_code_by("displaykey",72,"REQUIREDNEEDSED")
 SET result13 = uar_get_code_by("displaykey",72,"CARDIOLOGYMONITORINGNEEDED")
 SET result14 = uar_get_code_by("displaykey",72,"CARDIOLOGYMONITORING")
 SET result15 = uar_get_code_by("displaykey",72,"MEDICALMONITORINGNEEDED")
 SET result16 = uar_get_code_by("displaykey",72,"MEDICALMONITORING")
 SET result17 = uar_get_code_by("displaykey",72,"VENTILATORNEEDED")
 SET result18 = uar_get_code_by("displaykey",72,"VENTILATORCRITERIA")
 SET result19 = uar_get_code_by("displaykey",72,"CRITICALCAREADMITNEEDED")
 SET result20 = uar_get_code_by("displaykey",72,"CRITICALCAREADMITCRITERIA")
 SET result21 = uar_get_code_by("displaykey",72,"CONSTANTCOMPANIONNEEDED")
 SET result22 = uar_get_code_by("displaykey",72,"CONSTANTCOMPANION")
 SET result23 = uar_get_code_by("displaykey",72,"AIRBORNEISOLATIONNEEDED")
 SET result24 = uar_get_code_by("displaykey",72,"AIRBORNEISOLATION")
 SET result25 = uar_get_code_by("displaykey",72,"CONTACTISOLATIONNEEDED")
 SET result26 = uar_get_code_by("displaykey",72,"CONTACTISOLATION")
 SET result27 = uar_get_code_by("displaykey",72,"DROPLETISOLATIONNEEDED")
 SET result28 = uar_get_code_by("displaykey",72,"DROPLETISOLATION")
 SET result29 = uar_get_code_by("displaykey",72,"SPECIALTYBEDMATTRESSNEEDED")
 SET result30 = uar_get_code_by("displaykey",72,"SPECIALTYBEDMATTRESS")
 SET result31 = uar_get_code_by("displaykey",72,"NEGATIVEPRESSUREROOMNEEDED")
 SET result32 = uar_get_code_by("displaykey",72,"NEGATIVEPRESSUREROOM")
 SET result33 = uar_get_code_by("displaykey",72,"POSITIVEPRESSUREROOMNEEDED")
 SET result34 = uar_get_code_by("displaykey",72,"POSITIVEPRESSUREROOM")
 SET result35 = uar_get_code_by("displaykey",72,"ADDITIONALCOMMENTSED")
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.encntr_id=eid
   AND ((ce.event_cd+ 0) IN (result1, result2, result3, result4, result5,
  result6, result7, result8, result9, result10,
  result11, result12, result13, result14, result15,
  result16, result17, result18, result19, result20,
  result21, result22, result23, result24, result25,
  result26, result27, result28, result29, result30,
  result31, result32, result33, result34, result35))
   AND ce.view_level=1
   AND ce.valid_until_dt_tm > sysdate
   AND ce.result_status_cd=35
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF result1:
     admit->result1 = concat("{b}Admission Category (ED):{endb}  ",trim(ce.result_val))
    OF result2:
     admit->result2 = concat("{b}ED Reason for Admission:{endb}  ",trim(ce.result_val))
    OF result3:
     admit->result3 = concat("{b}Admitting Physician:{endb}  ",trim(ce.result_val))
    OF result4:
     admit->result4 = concat("{b}Attending Physician:{endb}  ",trim(ce.result_val))
    OF result5:
     admit->result5 = concat("{b}Admission Type:{endb}  ",trim(ce.result_val))
    OF result6:
     admit->result6 = concat("{b}Level of Care:{endb}  ",trim(ce.result_val))
    OF result7:
     admit->result7 = concat("{b}BMD Service:{endb}  ",trim(ce.result_val))
    OF result8:
     admit->result8 = concat("{b}Isolation Needed:{endb}  ",trim(ce.result_val))
    OF result9:
     admit->result9 = concat("{b}1:1 Sitter Needed:{endb}  ",trim(ce.result_val))
    OF result10:
     admit->result10 = concat("{b}Patient Stability (ED):{endb}  ",trim(ce.result_val))
    OF result11:
     admit->result11 = concat("{b}Additional Admit Comments (ED):{endb}  ",trim(ce.result_val))
    OF result12:
     admit->result12 = concat("{b}Required Needs (ED):{endb}  ",trim(ce.result_val))
    OF result13:
     admit->result13 = concat("{b}Cardiology Monitoring Needed (ED):{endb}  ",trim(ce.result_val))
    OF result14:
     admit->result14 = concat("{b}Cardiology Monitoring:{endb}  ",trim(ce.result_val))
    OF result15:
     admit->result15 = concat("{b}Medical Monitoring Needed (ED):{endb}  ",trim(ce.result_val))
    OF result16:
     admit->result16 = concat("{b}Medical Monitoring:{endb}  ",trim(ce.result_val))
    OF result17:
     admit->result17 = concat("{b}Ventilator Needed:{endb}  ",trim(ce.result_val))
    OF result18:
     admit->result18 = concat("{b}Ventilator Criteria:{endb}  ",trim(ce.result_val))
    OF result19:
     admit->result19 = concat("{b}Critical Care Admit Needed:{endb}  ",trim(ce.result_val))
    OF result20:
     admit->result20 = concat("{b}Critical Care Admit Criteria:{endb}  ",trim(ce.result_val))
    OF result21:
     admit->result21 = concat("{b}Constant Companion Needed:{endb}  ",trim(ce.result_val))
    OF result22:
     admit->result22 = concat("{b}Constant Companion:{endb}  ",trim(ce.result_val))
    OF result23:
     admit->result23 = concat("{b}Airborne Isolation Needed:{endb}  ",trim(ce.result_val))
    OF result24:
     admit->result24 = concat("{b}Airborne Isolation:{endb}  ",trim(ce.result_val))
    OF result25:
     admit->result25 = concat("{b}Contact Isolation Needed:{endb}  ",trim(ce.result_val))
    OF result26:
     admit->result26 = concat("{b}Contact Isolation:{endb}  ",trim(ce.result_val))
    OF result27:
     admit->result27 = concat("{b}Droplet Isolation Needed:{endb}  ",trim(ce.result_val))
    OF result28:
     admit->result28 = concat("{b}Droplet Isolation:{endb}  ",trim(ce.result_val))
    OF result29:
     admit->result29 = concat("{b}Specialty Bed/Mattress Needed:{endb}  ",trim(ce.result_val))
    OF result30:
     admit->result30 = concat("{b}Specialty Bed/Mattress:{endb}  ",trim(ce.result_val))
    OF result31:
     admit->result31 = concat("{b}Negative Pressure Room Needed:{endb}  ",trim(ce.result_val))
    OF result32:
     admit->result32 = concat("{b}Negative Pressure Room:{endb}  ",trim(ce.result_val))
    OF result33:
     admit->result33 = concat("{b}Positive Pressure Room Needed:{endb}  ",trim(ce.result_val))
    OF result34:
     admit->result34 = concat("{b}Positive Pressure Room:{endb}  ",trim(ce.result_val))
    OF result35:
     admit->result35 = concat("{b}Additional Comments (ED):{endb}  ",trim(ce.result_val))
   ENDCASE
  WITH nocounter
 ;end select
 SET pt->line_cnt = 0
 SET max_length = 85
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result1,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 1
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result2,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 2
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result3,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 3
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result4,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 4
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result5,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 5
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result6,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 6
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result7,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 7
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result8,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 8
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result9,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 9
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result10,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 10
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result11,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
   SET textdisplay->qual[textdisplay->cnt].result = 11
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result12,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result13,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result14,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result15,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result16,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result17,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result18,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result19,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result20,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result21,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result22,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result23,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result24,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result25,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result26,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result27,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result28,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result29,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result30,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result31,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result32,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result33,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result34,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 SET pt->line_cnt = 0
 SET line_cnt = 0
 SET tempstring = " "
 SET tempstring = trim(admit->result35,3)
 EXECUTE dcp_parse_text value(tempstring), value(max_length)
 FOR (line_cnt = 1 TO pt->line_cnt)
   SET textdisplay->cnt = (textdisplay->cnt+ 1)
   SET stat = alterlist(textdisplay->qual,textdisplay->cnt)
   SET textdisplay->qual[textdisplay->cnt].display = trim(pt->lns[line_cnt].line)
 ENDFOR
 DECLARE pat_name = vc
 DECLARE pat_loc = vc
 SET today_date = trim(format(sysdate,"MM-DD-YYYY HH:MM:SS;;d"))
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE e.encntr_id=eid)
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   pat_name = p.name_full_formatted, pat_loc = uar_get_code_display(e.loc_nurse_unit_cd)
  WITH nocounter
 ;end select
 SELECT INTO "bmccn3edcharge"
  FROM dummyt d
  HEAD REPORT
   xpos = 120, ypos = 72,
   CALL print(calcpos(xpos,ypos)),
   "{u}{b}ED Admission Request Form (BMD) - MODIFY{endb}{endu}", " ", today_date,
   xpos = 80, ypos = (ypos+ 30),
   CALL print(calcpos(xpos,ypos)),
   "{b}Initial Physician Request{endb}", row + 2, xpospos = 80,
   ypos = (ypos+ 10),
   CALL print(calcpos(xpos,ypos)), "{b}Patient Name:{endb}  ",
   pat_name, row + 1, xpospos = 80,
   ypos = (ypos+ 10),
   CALL print(calcpos(xpos,ypos)), "{b}Patient Location:{endb}  ",
   pat_loc, row + 1, xpospos = 80,
   ypos = (ypos+ 20),
   CALL print(calcpos(xpos,ypos)), "{b}{u}MD Section:{endb}{endu}  ",
   row + 1
   FOR (x = 1 TO textdisplay->cnt)
     IF ((textdisplay->qual[x].result > 0))
      xpos = 80, ypos = (ypos+ 10)
      IF (ypos > 650)
       BREAK
      ENDIF
      CALL print(calcpos(xpos,ypos)), textdisplay->qual[x].display, row + 1
     ENDIF
   ENDFOR
   xpos = 80, ypos = (ypos+ 30),
   CALL print(calcpos(xpos,ypos)),
   "{b}{u}Nursing Section:{endb}{endu}", row + 2
   FOR (x = 1 TO textdisplay->cnt)
     IF ((textdisplay->qual[x].result=0))
      xpos = 80, ypos = (ypos+ 10)
      IF (ypos > 650)
       BREAK
      ENDIF
      CALL print(calcpos(xpos,ypos)), textdisplay->qual[x].display, row + 1
     ENDIF
   ENDFOR
  WITH nocounter, dio = 8, maxcol = 500
 ;end select
END GO

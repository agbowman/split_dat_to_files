CREATE PROGRAM bhs_rw_quitworks_form:dba
 DECLARE rpt_output = vc
 DECLARE var_encntr_id = f8
 DECLARE var_beg_dt_tm = vc
 DECLARE var_end_dt_tm = vc
 IF (validate(request->visit[1].encntr_id,0.00) <= 0.00)
  SET rpt_output =  $1
  SET var_encntr_id = cnvtreal( $2)
 ELSE
  SET rpt_output = request->output_device
  SET var_encntr_id = request->visit[1].encntr_id
 ENDIF
 IF (trim(var_beg_dt_tm,3)=" ")
  SET var_beg_dt_tm = "01-JAN-1800 00:00:00"
 ENDIF
 IF (trim(var_end_dt_tm,3)=" ")
  SET var_end_dt_tm = "31-DEC-2100 23:59:59"
 ENDIF
 SUBROUTINE (req_get_date(var_date_str=vc,req_default=vc) =vc)
   IF (trim(var_date_str,3) <= " ")
    CALL echo("No date passed in.  Exitting REQ_GET_DATE")
    RETURN(req_default)
   ELSE
    FREE SET tmp_mon
    FREE SET tmp_date_str
    FREE SET tmp_date_fmt
    DECLARE tmp_mon = c3
    DECLARE tmp_date_str = c14
    DECLARE tmp_date_fmt = c21
    SET tmp_date_str = trim(var_date_str)
    SET tmp_mon = format(cnvtdatetime(cnvtdate(concat(substring(5,2,tmp_date_str),"012000")),0),
     "MMM;;D")
    SET tmp_date_fmt = concat(substring(7,2,tmp_date_str),"-",tmp_mon,"-",substring(1,4,tmp_date_str),
     " ",substring(9,2,tmp_date_str),":",substring(11,2,tmp_date_str),":",
     substring(13,2,tmp_date_str))
    RETURN(tmp_date_fmt)
   ENDIF
 END ;Subroutine
 IF (var_encntr_id <= 0.00)
  CALL echo("No encounter_id passed in.  Exitting Script")
  GO TO exit_script
 ENDIF
 DECLARE pcp_reltn_cd = f8
 DECLARE ez_addr_cd = f8
 DECLARE ez_phone_cd = f8
 DECLARE bus_addr_cd = f8
 DECLARE bus_phone_cd = f8
 DECLARE bus_fax_cd = f8
 DECLARE home_addr_cd = f8
 DECLARE home_phone_cd = f8
 SET pcp_reltn_cd = uar_get_code_by("MEANING",333,"PCP")
 SET ez_addr_cd = uar_get_code_by("MEANING",212,"EZSCRIPT")
 SET ez_phone_cd = uar_get_code_by("MEANING",43,"EZSCRIPT")
 SET bus_addr_cd = uar_get_code_by("MEANING",212,"BUSINESS")
 SET bus_phone_cd = uar_get_code_by("MEANING",43,"BUSINESS")
 SET bus_fax_cd = uar_get_code_by("MEANING",43,"FAX BUS")
 SET home_addr_cd = uar_get_code_by("MEANING",212,"HOME")
 SET home_phone_cd = uar_get_code_by("MEANING",43,"HOME")
 DECLARE bmpwestsideadult_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"BMPWESTSIDEADULT")),
 protect
 FREE RECORD work
 RECORD work(
   1 refer_id = f8
   1 refer_name = vc
   1 refer_unit = vc
   1 refer_unit_cd = f8
   1 refer_fac = vc
   1 refer_fac_add2 = vc
   1 refer_facility = vc
   1 refer_fac_add1 = vc
   1 address_id = f8
   1 refer_addr = vc
   1 refer_city = vc
   1 refer_state = vc
   1 refer_zip = vc
   1 phone_id = f8
   1 refer_phone = vc
   1 fax_id = f8
   1 refer_fax = vc
   1 followup_id = f8
   1 followup_name = vc
   1 followup_phone = vc
   1 followup_fax = vc
   1 patient_id = f8
   1 patient_first_name = vc
   1 patient_last_name = vc
   1 patient_dob = vc
   1 patient_phone = vc
   1 patient_addr = vc
   1 patient_city = vc
   1 patient_state = vc
   1 patient_zip = vc
   1 patient_ins = vc
   1 q_cnt = i4
   1 questions[*]
     2 event_cd = f8
     2 display = vc
     2 display_key = vc
     2 event_id = f8
     2 value = vc
 )
 SET work->q_cnt = 4
 SET stat = alterlist(work->questions,work->q_cnt)
 SET work->questions[1].display_key = "MAYQUITWORKSLEAVEAMESSAGE"
 SET work->questions[2].display_key = "LANGUAGEPREFERRED"
 SET work->questions[3].display_key = "EMAILADDRESS"
 SET work->questions[4].display_key = "CALLPREFERREDTIME"
 DECLARE temp_num = i4
 DECLARE patlocationcd = f8
 SELECT INTO "NL:"
  vec.event_cd, vec.event_cd_disp
  FROM v500_event_code vec
  PLAN (vec
   WHERE expand(temp_num,1,work->q_cnt,vec.event_cd_disp_key,work->questions[temp_num].display_key))
  DETAIL
   FOR (q = 1 TO work->q_cnt)
     IF ((work->questions[q].display_key=vec.event_cd_disp_key))
      work->questions[q].event_cd = vec.event_cd, work->questions[q].display = vec.event_cd_disp
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM encounter e,
   person p,
   address a,
   phone ph,
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (e
   WHERE var_encntr_id=e.encntr_id)
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.active_ind= Outerjoin(1))
    AND (a.address_type_cd= Outerjoin(home_addr_cd)) )
   JOIN (ph
   WHERE (ph.parent_entity_id= Outerjoin(p.person_id))
    AND (ph.parent_entity_name= Outerjoin("PERSON"))
    AND (ph.active_ind= Outerjoin(1))
    AND (ph.phone_type_cd= Outerjoin(home_phone_cd)) )
   JOIN (epr
   WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
    AND (epr.encntr_prsnl_r_cd= Outerjoin(pcp_reltn_cd)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(epr.prsnl_person_id)) )
  ORDER BY e.encntr_id, epr.beg_effective_dt_tm DESC
  HEAD e.encntr_id
   work->patient_id = p.person_id, work->patient_first_name = p.name_first, work->patient_last_name
    = p.name_last,
   work->patient_dob = format(p.birth_dt_tm,"MM/DD/YYYY;;D"), work->patient_addr = a.street_addr,
   work->patient_city = a.city,
   work->patient_state =
   IF (a.state_cd <= 0.00) a.state
   ELSE uar_get_code_display(a.state_cd)
   ENDIF
   , work->patient_zip = a.zipcode, work->patient_phone = ph.phone_num,
   work->patient_ins = uar_get_code_display(e.financial_class_cd)
   IF ((work->refer_id <= 0.00)
    AND pr.person_id > 0.00)
    work->refer_id = pr.person_id, work->refer_name = pr.name_full_formatted, work->refer_unit =
    uar_get_code_description(e.loc_nurse_unit_cd),
    work->refer_unit_cd = e.loc_nurse_unit_cd
   ENDIF
   IF ((work->followup_id <= 0.00)
    AND pr.person_id > 0.00)
    work->followup_id = pr.person_id, work->followup_name = pr.name_full_formatted
   ENDIF
   IF (e.loc_facility_cd=bmpwestsideadult_cd)
    patlocationcd = e.loc_facility_cd
   ELSE
    patlocationcd = e.loc_nurse_unit_cd
   ENDIF
  WITH nocounter
 ;end select
 DECLARE sub_alias = vc
 SELECT INTO "NL:"
  FROM code_value cv,
   code_value_alias cva
  PLAN (cv
   WHERE cv.code_value=patlocationcd)
   JOIN (cva
   WHERE cv.code_value=cva.code_value)
  HEAD cv.code_value
   IF (cv.code_value=bmpwestsideadult_cd)
    sub_alias = concat("*^~",trim(substring((findstring("^~",trim(cva.alias),1,1)+ 1),size(trim(cva
         .alias)),trim(cva.alias))))
   ELSEIF (cv.code_value > 0.00)
    sub_alias = concat("*^~",trim(substring((findstring("^~",trim(cva.alias),1,1)+ 2),size(trim(cva
         .alias)),trim(cva.alias))))
   ENDIF
  WITH nocounter
 ;end select
 SET work->refer_fac = "Baystate Health System"
 SELECT INTO "NL:"
  facility = substring(1,(findstring("^~",trim(cva.alias),1,0) - 1),trim(cva.alias))
  FROM code_value_alias cva
  PLAN (cva
   WHERE cva.code_set=220
    AND cva.alias=patstring(sub_alias)
    AND cva.alias != "")
  ORDER BY cva.alias
  HEAD cva.code_value
   IF (facility="WESTSIDE")
    work->refer_fac = "BMP West Side Adult Medicine", work->refer_fac_add1 = "46 Daggett Drive", work
    ->refer_fac_add2 = "West Springfield,MA 01089"
   ELSEIF (((facility="BMC") OR (facility="BMC INPT PSYCH")) )
    work->refer_fac = "Baystate Medical Center", work->refer_fac_add1 = "759 Chestnut St.", work->
    refer_fac_add2 = "Springfield,MA 01199"
   ELSEIF (((facility="FMC") OR (((facility="BFMC") OR (facility="FMC INPT PSYCH")) )) )
    work->refer_fac = "Baystate Franklin Medical Center", work->refer_fac_add1 = "164 High St.", work
    ->refer_fac_add2 = "Greenfield,MA 01301"
   ELSEIF (((facility="MLH") OR (facility="BMLH")) )
    work->refer_fac = "Baystate Mary Lane Hospital", work->refer_fac_add1 = "85 South St.", work->
    refer_fac_add2 = "Ware, MA 01082"
   ELSEIF (((facility="BWH") OR (facility="BWH INPT PSYCH")) )
    work->refer_fac = "Baystate Wing Hospital", work->refer_fac_add1 = "40 Wright St.", work->
    refer_fac_add2 = "Palmer, MA 01069"
   ENDIF
  WITH nocounter
 ;end select
 FREE SET sub_alias
 SELECT INTO "NL:"
  type =
  IF (a.address_type_cd=bus_addr_cd) 1
  ELSEIF (a.address_type_cd=ez_addr_cd) 2
  ELSE 99
  ENDIF
  FROM address a
  PLAN (a
   WHERE (work->refer_id=a.parent_entity_id)
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=bus_addr_cd
    AND a.active_ind=1)
  ORDER BY type
  HEAD type
   IF (type < 99
    AND (work->address_id <= 0.00))
    work->address_id = a.address_id, work->refer_addr = a.street_addr, work->refer_city = a.city,
    work->refer_state =
    IF (a.state_cd <= 0.00) a.state
    ELSE uar_get_code_display(a.state_cd)
    ENDIF
    , work->refer_zip = a.zipcode
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  type =
  IF (ph.phone_type_cd=bus_phone_cd) 1
  ELSEIF (ph.phone_type_cd=ez_phone_cd) 2
  ELSEIF (ph.phone_type_cd=bus_fax_cd) 3
  ELSE 99
  ENDIF
  FROM phone ph
  PLAN (ph
   WHERE (work->refer_id=ph.parent_entity_id)
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd IN (ez_phone_cd, bus_phone_cd, bus_fax_cd)
    AND ph.active_ind=1)
  ORDER BY type
  HEAD type
   IF (type IN (1, 2)
    AND (work->phone_id <= 0.00))
    work->phone_id = ph.phone_id, work->refer_phone = ph.phone_num, work->followup_phone = ph
    .phone_num
   ELSEIF (type=3
    AND (work->fax_id <= 0.00))
    work->fax_id = ph.phone_id, work->refer_fax = ph.phone_num, work->followup_fax = ph.phone_num
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(work->q_cnt)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE ce.encntr_id=var_encntr_id
    AND (ce.event_cd=work->questions[d.seq].event_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_end_dt_tm >= cnvtdatetime(var_beg_dt_tm)
    AND ce.event_end_dt_tm <= cnvtdatetime(var_end_dt_tm))
  ORDER BY d.seq, ce.event_end_dt_tm DESC
  HEAD d.seq
   IF ((work->questions[d.seq].event_id <= 0.00))
    work->questions[d.seq].event_id = ce.event_id, work->questions[d.seq].value = ce.result_val
   ENDIF
  WITH nocounter
 ;end select
 DECLARE lbl_str = vc
 DECLARE val_str = vc
 SELECT INTO value(rpt_output)
  FROM dummyt d
  HEAD REPORT
   col + 0, "{F/8}", row + 1,
   def_x = 36, def_y = 36, tmp_len = 0,
   col + 0, "{CPI/8}{LPI/5}", row + 1,
   y_pos = (def_y - 18), x_pos = def_x, col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0, "{B}QuitWorks - Mass Resident Enrollment Form{ENDB}",
   row + 1, x_pos = 458, col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0, "{B}Baystate Health{ENDB}",
   row + 1, col 0, "{CPI/10}{LPI/6}",
   row + 1, y_pos = def_y, x_pos = (def_x+ 174),
   col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   "Fax this form to 1-866-560-9113", row + 1, y_pos += 9,
   x_pos = def_x, col + 0,
   CALL print(calcpos(x_pos,y_pos)),
   col + 0,
   CALL print(fillstring(80,"_")), row + 1,
   y_pos += 15, x_pos = (def_x+ 18), col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0, "{B}",
   work->refer_fac, "{ENDB}", row + 1,
   y_pos += 15, x_pos = (def_x+ 18), col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0, "{B}",
   work->refer_fac_add1, "{ENDB}", row + 1,
   y_pos += 15, x_pos = (def_x+ 18), col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0, "{B}",
   work->refer_fac_add2, "{ENDB}", row + 1,
   y_pos += 3, x_pos = def_x, col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   CALL print(fillstring(80,"_")),
   row + 1,
   MACRO (print_value)
    col + 0,
    CALL print(calcpos(x_pos,y_pos)), col + 0,
    lbl_str, ": "
    IF (trim(val_str,3) <= " ")
     tmp_len = 0, tmp_len = (91 - (size(trim(lbl_str,3))+ 3))
     FOR (x = 1 TO tmp_len)
      col + 0"_"
     ENDFOR
    ELSE
     col + 0, val_str
    ENDIF
    row + 1
   ENDMACRO
  DETAIL
   col + 0, "{CPI/10}{LPI/6}", row + 1,
   y_pos += 9, x_pos = def_x, col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   CALL print(fillstring(80,"_")),
   row + 1, y_pos += 15, x_pos = (def_x+ 18),
   col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   "Referral Source/Follow-up Contact", row + 1, y_pos += 3,
   x_pos = def_x, col + 0,
   CALL print(calcpos(x_pos,y_pos)),
   col + 0,
   CALL print(fillstring(80,"_")), row + 1,
   col + 0, "{CPI/12}{LPI/7}", row + 1,
   y_pos += 18, x_pos = (def_x+ 18), col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0, "Referred by",
   row + 1, y_pos += 15, x_pos = (def_x+ 36),
   lbl_str = "Name", val_str = work->refer_name, print_value,
   y_pos += 15, lbl_str = "Facility", val_str = work->refer_unit,
   print_value, y_pos += 15, lbl_str = "Address"
   IF ((work->address_id <= 0.00))
    val_str = " "
   ELSE
    val_str = concat(work->refer_addr,"  ",work->refer_city,", ",work->refer_state,
     "  ",work->refer_zip)
   ENDIF
   print_value, y_pos += 15, lbl_str = "Phone",
   val_str = work->refer_phone, print_value, y_pos += 15,
   lbl_str = "Fax", val_str = work->refer_fax, print_value,
   y_pos += 18, x_pos = (def_x+ 18), col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0, "Follow-up Report Contact",
   row + 1, y_pos += 15, x_pos = (def_x+ 36),
   lbl_str = "Name", val_str = work->followup_name, print_value,
   y_pos += 15, lbl_str = "Phone", val_str = work->followup_phone,
   print_value, y_pos += 15, lbl_str = "Fax",
   val_str = work->followup_fax, print_value, col + 0,
   "{CPI/10}{LPI/6}", row + 1, y_pos += 9,
   x_pos = def_x, col + 0,
   CALL print(calcpos(x_pos,y_pos)),
   col + 0,
   CALL print(fillstring(80,"_")), row + 1,
   y_pos += 15, x_pos = (def_x+ 18), col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0, "Patient",
   row + 1, y_pos += 3, x_pos = def_x,
   col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   CALL print(fillstring(80,"_")), row + 1, col + 0,
   "{CPI/12}{LPI/7}", row + 1, y_pos += 18,
   x_pos = (def_x+ 18), lbl_str = "First Name", val_str = work->patient_first_name,
   print_value, y_pos += 15, lbl_str = "Last Name",
   val_str = work->patient_last_name, print_value, y_pos += 15,
   lbl_str = "Date of Birth", val_str = work->patient_dob, print_value,
   y_pos += 15, lbl_str = "Phone", val_str = work->patient_phone,
   print_value, y_pos += 15, lbl_str = "Address"
   IF ((work->patient_addr <= " "))
    val_str = " "
   ELSE
    val_str = concat(work->patient_addr,"  ",work->patient_city,",  ",work->patient_state,
     "  ",work->patient_zip)
   ENDIF
   print_value, y_pos += 15, lbl_str = "Primary Insurance",
   val_str = work->patient_ins, print_value, y_pos += 6
   FOR (q = 1 TO work->q_cnt)
     IF (trim(work->questions[q].display) > " ")
      y_pos += 15, lbl_str = work->questions[q].display, val_str = work->questions[q].value,
      print_value
     ENDIF
   ENDFOR
  FOOT REPORT
   col + 0, "{CPI/10}{LPI/6}", row + 1,
   y_pos = 462, x_pos = def_x, col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   CALL print(fillstring(80,"_")),
   row + 1, y_pos += 24, x_pos = (def_x+ 18),
   col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   "I, ______________________________, hereby authorize Try-To STOP TOBACCO Resource", row + 1, y_pos
    += 18,
   col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   'Center of Massachusetts, (the "Resource Center"), and its representatives to disclose', row + 1,
   y_pos += 18,
   col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   "information about me to:", row + 1, y_pos += 18,
   x_pos += 18, col + 0,
   CALL print(calcpos(x_pos,y_pos)),
   col + 0,
   "1) the American Cancer Society Quitline to the extent necessary to allow me to participate", row
    + 1,
   y_pos += 18, x_pos += 12, col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0, "in its tobacco cessation counseling program; and",
   row + 1, y_pos += 18, x_pos -= 12,
   col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   '2) my primary care provider or other provider ("Provider") I designate to the Resource Center',
   row + 1, y_pos += 18,
   x_pos += 12, col + 0,
   CALL print(calcpos(x_pos,y_pos)),
   col + 0, "to the extent the Resource Center deems necessary to give my Provider an update of my",
   row + 1,
   y_pos += 18, col + 0,
   CALL print(calcpos(x_pos,y_pos)),
   col + 0, "progress in attempting to stop smoking.", row + 1,
   y_pos += 18, x_pos = (def_x+ 18), col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   "I authorize my Provider to release the information on this enrollment form to the Resource",
   row + 1, y_pos += 18, col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   "Center for purposes of my participation in the QuitWorks program. I also authorize the Resource",
   row + 1, y_pos += 18, col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   "Center and its representatives to contact me upon receiving this referral from my Provider.",
   row + 1, y_pos += 24, x_pos = def_x,
   col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   CALL print(fillstring(80,"_")), row + 1, y_pos += 15,
   x_pos = (def_x+ 18), col + 0,
   CALL print(calcpos(x_pos,y_pos)),
   col + 0, "{CPI/12}{LPI/8}SIGNATURE OF QUITWORKS CLIENT OR CLIENT'S REPRESENTATIVE", x_pos = 440,
   col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   "DATE{CPI/10}{LPI/6}", row + 1, y_pos += 18,
   x_pos = def_x, col + 0,
   CALL print(calcpos(x_pos,y_pos)),
   col + 0,
   CALL print(fillstring(80,"_")), row + 1,
   y_pos += 12, x_pos = (def_x+ 18), col + 0,
   CALL print(calcpos(x_pos,y_pos)), col + 0,
   "{CPI/12}{LPI/8}PRINTED NAME OF QUITWORKS CLIENT REPRESENTATIVE",
   x_pos = 440, col + 0,
   CALL print(calcpos(x_pos,y_pos)),
   col + 0, "RELATIONSHIP TO CLIENT", row + 1
  WITH nocounter, dio = 8, formfeed = none,
   maxcol = 32000, format = variable
 ;end select
#exit_script
 CALL echorecord(work)
 SET last_mod =
 "001 30-11-16 C14393 SR 414210706 Modified the script to print the correct address on the report"
END GO

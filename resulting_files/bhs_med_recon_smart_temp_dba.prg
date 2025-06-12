CREATE PROGRAM bhs_med_recon_smart_temp:dba
 IF ( NOT (validate(request,0)))
  FREE RECORD request
  RECORD request(
    1 recon_type = c1
    1 encntr_id = f8
    1 pop1[*]
      2 order_id = f8
      2 catalog_cd = f8
      2 cki = vc
      2 order_mnemonic = vc
      2 order_detail_display_line = vc
      2 clinical_display_line = vc
      2 multum[*]
        3 class_1 = vc
        3 class_2 = vc
        3 class_3 = vc
      2 dose = vc
      2 dose_unit = f8
      2 volume_dose = vc
      2 volume_dose_unit = f8
      2 frequency = f8
      2 prn_ind = i2
      2 prn_reason = vc
    1 pop2[*]
      2 order_id = f8
      2 catalog_cd = f8
      2 cki = vc
      2 order_mnemonic = vc
      2 order_detail_display_line = vc
      2 clinical_display_line = vc
      2 multum[*]
        3 class_1 = vc
        3 class_2 = vc
        3 class_3 = vc
      2 dose = cv
      2 dose_unit = f8
      2 volume_dose = vc
      2 volume_dose_unit = f8
      2 frequency = f8
      2 prn_ind = i2
      2 prn_reason = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 DECLARE pat_name = vc
 DECLARE fin_nbr = vc
 DECLARE admit_date = vc
 DECLARE loc_disp = vc
 DECLARE attend_doc_name = vc
 DECLARE pcp_doc_name = vc
 DECLARE attend_doc_r_cd = f8
 DECLARE pcp_doc_r_cd = f8
 SET attend_doc_r_cd = uar_get_code_by("MEANING",333,"ATTENDDOC")
 SET pcp_doc_r_cd = uar_get_code_by("MEANING",333,"PCP")
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl pr,
   dummyt d
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm
    AND ea.encntr_alias_type_cd=1077)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN epr.beg_effective_dt_tm AND epr.end_effective_dt_tm
    AND epr.encntr_prsnl_r_cd IN (attend_doc_r_cd, pcp_doc_r_cd))
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  HEAD e.encntr_id
   pat_name = substring(1,30,p.name_full_formatted), fin_nbr = substring(1,10,ea.alias), admit_date
    = format(e.reg_dt_tm,"MM/DD/YYYY;;D"),
   loc_disp = concat(trim(uar_get_code_display(e.loc_nurse_unit_cd))," ",trim(uar_get_code_display(e
      .loc_room_cd))," ",trim(uar_get_code_display(e.loc_bed_cd)))
  DETAIL
   IF (epr.encntr_prsnl_r_cd=attend_doc_r_cd)
    attend_doc_name = substring(1,30,pr.name_full_formatted)
   ELSEIF (epr.encntr_prsnl_r_cd=pcp_doc_r_cd)
    pcp_doc_name = substring(1,30,pr.name_full_formatted)
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 DECLARE allergy_disp = vc
 DECLARE cancelled_reaction_status_cd = f8
 SET cancelled_reaction_status_cd = uar_get_code_by("MEANING",12025,"CANCELED")
 CALL echo(cancelled_reaction_status_cd)
 SELECT INTO "nl:"
  FROM encounter e,
   allergy a,
   nomenclature n
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id))
   JOIN (a
   WHERE a.person_id=e.person_id
    AND a.active_ind=1
    AND a.reaction_status_cd != cancelled_reaction_status_cd)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  HEAD REPORT
   allergy_disp = n.source_string, first_allergy = 1
  DETAIL
   IF (first_allergy=1)
    first_allergy = 0
   ELSE
    allergy_disp = concat(allergy_disp,"; ",trim(n.source_string)),
    CALL echo(n.source_string)
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD problems
 RECORD problems(
   1 list[*]
     2 order_mnemonic = vc
     2 dose = vc
     2 dose_unit = f8
     2 volume_dose = vc
     2 volume_dose_unit = f8
     2 frequency = f8
     2 comment = vc
     2 prn_ind = i2
     2 prn_reason = vc
 )
 DECLARE prob_cnt = i4
 SET prob_cnt = 0
 FOR (i = 1 TO size(request->pop1,5))
   DECLARE found_cat_cd = i2
   DECLARE dose_change = i2
   DECLARE freq_change = i2
   SET found_cat_cd = 0
   SET dose_change = 0
   SET freq_change = 0
   FOR (j = 1 TO size(request->pop2,5))
     IF ((request->pop1[i].catalog_cd=request->pop2[j].catalog_cd))
      SET found_cat_cd = 1
      IF ((request->pop1[i].dose != request->pop2[j].dose))
       IF (dose_change != 2)
        SET dose_change = 1
       ENDIF
      ELSE
       SET dose_change = 2
      ENDIF
      IF ((request->pop1[i].frequency != request->pop2[j].frequency))
       IF (freq_change != 2)
        SET freq_change = 1
       ENDIF
      ELSE
       SET freq_change = 2
      ENDIF
      IF (found_cat_cd=1
       AND freq_change=0
       AND dose_change=0)
       SET j = (size(request->pop2,5)+ 1)
      ENDIF
     ENDIF
   ENDFOR
   IF (found_cat_cd=0)
    SET prob_cnt = (prob_cnt+ 1)
    IF (mod(prob_cnt,10)=1)
     SET stat = alterlist(problems->list,(prob_cnt+ 9))
    ENDIF
    SET problems->list[prob_cnt].order_mnemonic = request->pop1[i].order_mnemonic
    SET problems->list[prob_cnt].prn_ind = request->pop1[i].prn_ind
    SET problems->list[prob_cnt].prn_reason = request->pop1[i].prn_reason
    SET problems->list[prob_cnt].dose = request->pop1[i].dose
    SET problems->list[prob_cnt].dose_unit = request->pop1[i].dose_unit
    SET problems->list[prob_cnt].volume_dose = request->pop1[i].volume_dose
    SET problems->list[prob_cnt].volume_dose_unit = request->pop1[i].volume_dose_unit
    SET problems->list[prob_cnt].frequency = request->pop1[i].frequency
    SET problems->list[prob_cnt].comment = "Missing"
   ELSEIF (dose_change != 2)
    SET prob_cnt = (prob_cnt+ 1)
    IF (mod(prob_cnt,10)=1)
     SET stat = alterlist(problems->list,(prob_cnt+ 9))
    ENDIF
    SET problems->list[prob_cnt].order_mnemonic = request->pop1[i].order_mnemonic
    SET problems->list[prob_cnt].prn_ind = request->pop1[i].prn_ind
    SET problems->list[prob_cnt].prn_reason = request->pop1[i].prn_reason
    SET problems->list[prob_cnt].dose = request->pop1[i].dose
    SET problems->list[prob_cnt].dose_unit = request->pop1[i].dose_unit
    SET problems->list[prob_cnt].volume_dose = request->pop1[i].volume_dose
    SET problems->list[prob_cnt].volume_dose_unit = request->pop1[i].volume_dose_unit
    SET problems->list[prob_cnt].frequency = request->pop1[i].frequency
    SET problems->list[prob_cnt].comment = "Dose"
   ELSEIF (freq_change != 2)
    SET prob_cnt = (prob_cnt+ 1)
    IF (mod(prob_cnt,10)=1)
     SET stat = alterlist(problems->list,(prob_cnt+ 9))
    ENDIF
    SET problems->list[prob_cnt].order_mnemonic = request->pop1[i].order_mnemonic
    SET problems->list[prob_cnt].prn_ind = request->pop1[i].prn_ind
    SET problems->list[prob_cnt].prn_reason = request->pop1[i].prn_reason
    SET problems->list[prob_cnt].dose = request->pop1[i].dose
    SET problems->list[prob_cnt].dose_unit = request->pop1[i].dose_unit
    SET problems->list[prob_cnt].volume_dose = request->pop1[i].volume_dose
    SET problems->list[prob_cnt].volume_dose_unit = request->pop1[i].volume_dose_unit
    SET problems->list[prob_cnt].frequency = request->pop1[i].frequency
    SET problems->list[prob_cnt].comment = "Frequency"
   ENDIF
 ENDFOR
 SET stat = alterlist(problems->list,prob_cnt)
 SET rhead = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}{\colortbl;\red0",
  "\green0\blue0;\red255\green255\blue255;\red255\green128\blue128;}\deftab1134")
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs16 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET lock = "{\*\txfieldstart\txfieldtype0\txfieldflags3}\plain\f0\fs18"
 SET unlock = "{\*\txfieldend}"
 SET wr = " \plain \f0 \fs18 \cb2 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wbu = " \plain \f0 \fs18 \b \ul \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET tblhead1 = concat("\trowd \irow0\irowband0\ts15\trgaph108 ",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx5000","\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx11000","\pard\ql\li0\ri0\widctlpar\intbl\aspalpha\aspnum\faauto",
  "\adjustright\rin0\lin0")
 SET tblhead3 = concat("\trowd \irow0\irowband0\ts15\trgaph108 ",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ","\cltxlrtb\cellx5000",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\cltxlrtb\clshdrawnil\cellx11000","\pard\ql\li0\ri0\widctlpar\intbl\aspalpha\aspnum\faauto",
  "\adjustright\rin0\lin0")
 SET tblhead2 = concat("\trowd \irow0\irowband0\ts15\trgaph108 ",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx4365","\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx5600","\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx6400",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx7400","\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\clshdng2000\cltxlrtb\cellx11000","\pard\ql\li0\ri0\widctlpar\intbl\aspalpha\aspnum\faauto",
  "\adjustright\rin0\lin0")
 SET tblhead4 = concat("\trowd \irow0\irowband0\ts15\trgaph108 ",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ","\cltxlrtb\cellx4365",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ","\cltxlrtb\cellx5600",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ","\cltxlrtb\cellx6400",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ","\cltxlrtb\cellx7400",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ",
  "\cltxlrtb\cellx11000","\pard\ql\li0\ri0\widctlpar\intbl\aspalpha\aspnum\faauto",
  "\adjustright\rin0\lin0")
 SET tblhead5 = concat("\trowd \irow0\irowband0\ts15\trgaph108 ",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ","\cltxlrtb\cellx11000",
  "\pard\ql\li0\ri0\widctlpar\intbl\aspalpha\aspnum\faauto",
  "\adjustright\rin0\lin0")
 SET tblhead6 = concat("\trowd \irow0\irowband0\ts15\trgaph108 ",
  "\clbrdrt\brdrs\brdrw06\brdrcf11 \clbrdrl\brdrs\brdrw06\brdrcf11",
  "\clbrdrb\brdrs\brdrw06\brdrcf11 \clbrdrr\brdrs\brdrw06\brdrcf11 ","\cltxlrtb\cellx4500",
  "\pard\ql\li0\ri0\widctlpar\intbl\aspalpha\aspnum\faauto",
  "\adjustright\rin0\lin0")
 SET rtfeof = "}"
 SET temp_disp1 = fillstring(200,"")
 SET temp_disp2 = fillstring(200,"")
 SET temp_disp3 = fillstring(200,"")
 SET temp_disp4 = fillstring(200,"")
 SET temp_disp5 = fillstring(250,"")
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id))
  DETAIL
   reply->text = concat(rhead,lock," ",wb,trim(uar_get_code_description(e.loc_facility_cd)),
    reol,wb)
  WITH nocounter
 ;end select
 IF ((request->recon_type="A"))
  SET reply->text = concat(reply->text," ADMISSION MEDICATION LIST",reol,wb)
 ELSEIF ((request->recon_type="T"))
  SET reply->text = concat(reply->text," TRANSFER MEDICATION LIST",reol,wb)
 ELSEIF ((request->recon_type="D"))
  SET reply->text = concat(reply->text," DISCHARGE MEDICATION LIST",reol,wb)
 ENDIF
 SET reply->text = concat(reply->text,wb,"RECONCILIATION FORM",reol,reol,
  wu,"Patient Name",wr,": ",pat_name,
  " ",reol,wu,"ID",wr,
  ": ",fin_nbr,reol,wu,"Date of Admission",
  wr,": ",admit_date,reol,wu,
  "Location",wr,": ",loc_disp,reol,
  wu,"Date and Time of Report",wr,": ",format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY HH:MM;;d"),
  reol,wu,"Attending MD",wr,": ",
  attend_doc_name,reol,wu,"PCP MD",wr,
  ": ",pcp_doc_name,reol,wu,"Allergies",
  wr,": ",allergy_disp,rh2r)
 IF ((request->recon_type="T"))
  SET reply->text = concat(reply->text,reol,wu,"Prior Location",wr,
   ":  S1 S1419 A",reol,wu,"Date/Time of arrival at prior location",wr,
   ": ",format(cnvtdatetime((curdate - 3),(curtime - 100)),"MM/DD/YYYY HH:MM;;D"),reol)
 ENDIF
 SET reply->text = concat(reply->text,reol,reol,tblhead1,wb)
 IF ((request->recon_type="A"))
  SET reply->text = concat(reply->text,wb,"Current Home Medications \cell Meds being Given \cell\row",
   wr)
 ELSEIF ((request->recon_type="T"))
  SET reply->text = concat(reply->text,wb,
   "Prior Meds Being Given \cell Meds Being Given Now \cell\row",wr)
 ELSEIF ((request->recon_type="D"))
  SET reply->text = concat(reply->text,wb,
   "Home Meds prior to Admission \cell Home Medications at Discharge \cell\row",wr)
 ENDIF
 SET reply->text = concat(reply->text,tblhead3)
 DECLARE column1 = vc
 DECLARE column2 = vc
 IF (size(request->pop1,5) > size(request->pop2,5))
  SET max_loop = size(request->pop1,5)
 ELSE
  SET max_loop = size(request->pop2,5)
 ENDIF
 FOR (i = 1 TO max_loop)
   IF (i <= size(request->pop1,5))
    SET column1 = concat(trim(request->pop1[i].order_mnemonic))
    IF ((request->pop1[i].dose > "")
     AND (request->pop1[i].dose_unit > 0))
     SET column1 = concat(column1," ",request->pop1[i].dose," ",trim(uar_get_code_display(request->
        pop1[i].dose_unit)))
     IF ((request->pop1[i].prn_ind=1))
      SET column1 = concat(column1,", ","PRN")
     ENDIF
    ELSEIF ((request->pop1[i].volume_dose > "")
     AND (request->pop1[i].volume_dose_unit > 0))
     SET column1 = concat(column1," ",request->pop1[i].volume_dose," ",trim(uar_get_code_display(
        request->pop1[i].volume_dose_unit)))
     IF ((request->pop1[i].prn_ind=1))
      SET column1 = concat(column1,", ","PRN")
     ENDIF
    ELSEIF ((request->pop1[i].dose > ""))
     SET column1 = concat(column1," ",request->pop1[i].dose)
     IF ((request->pop1[i].prn_ind=1))
      SET column1 = concat(column1,", ","PRN")
     ENDIF
    ENDIF
    SET column1 = concat(column1," ",trim(uar_get_code_display(request->pop1[i].frequency)))
   ELSE
    SET column1 = " "
   ENDIF
   IF (i <= size(request->pop2,5))
    SET column2 = trim(request->pop2[i].order_mnemonic)
    IF ((request->pop2[i].dose > "")
     AND (request->pop2[i].dose_unit > 0))
     SET column2 = concat(column2," ",request->pop2[i].dose," ",trim(uar_get_code_display(request->
        pop2[i].dose_unit)))
     IF ((request->pop2[i].prn_ind=1))
      SET column2 = concat(column2,", ","PRN")
     ENDIF
    ELSEIF ((request->pop2[i].volume_dose > "")
     AND (request->pop2[i].volume_dose_unit > 0))
     SET column2 = concat(column2," ",request->pop2[i].volume_dose," ",trim(uar_get_code_display(
        request->pop2[i].volume_dose_unit)))
     IF ((request->pop2[i].prn_ind=1))
      SET column2 = concat(column2,", ","PRN")
     ENDIF
    ELSEIF ((request->pop2[i].dose > ""))
     SET column2 = concat(column2," ",request->pop2[i].dose)
     IF ((request->pop2[i].prn_ind=1))
      SET column2 = concat(column2,", ","PRN")
     ENDIF
    ENDIF
    SET column2 = concat(column2," ",trim(uar_get_code_display(request->pop2[i].frequency)))
   ELSE
    SET column2 = " "
   ENDIF
   SET reply->text = concat(reply->text," ",column1," \cell ",column2,
    "\cell \row")
 ENDFOR
 SET reply->text = concat(reply->text," \pard \ql ",reol,reol)
 SET reply->text = concat(reply->text,tblhead2)
 IF ((request->recon_type="A"))
  SET reply->text = concat(reply->text,
   " Home Medications Not Being Given or Being Given With Changes "," \cell\pard\intbl",wr,
   "Discrepency\cell\pard\intbl ",
   wr,"To Be Given\cell\pard\intbl",wb,"NOT",wr,
   " to be given","\cell\pard\intbl Rationale for not giving\cell \pard\intbl \row ",unlock)
 ELSEIF ((request->recon_type="T"))
  SET reply->text = concat(reply->text," Medications Not Being Given or Being Given With Changes ",
   " \cell\pard\intbl",wr,"Discrepency\cell\pard\intbl ",
   wr,"To Be Given\cell\pard\intbl",wb,"NOT",wr,
   " to be given","\cell\pard\intbl Rationale for not giving\cell \pard\intbl \row ",unlock)
 ELSEIF ((request->recon_type="D"))
  SET reply->text = concat(reply->text," Home Medications Not Prescribed or Prescribed With Changes ",
   " \cell\pard\intbl",wr,"Discrepency\cell\pard\intbl ",
   wr,"To Be Given\cell\pard\intbl",wb,"NOT",wr,
   " to be given","\cell\pard\intbl Rationale for not giving\cell \pard\intbl \row ",unlock)
 ENDIF
 SET reply->text = concat(reply->text,tblhead4)
 FOR (i = 1 TO size(problems->list,5))
   SET column1 = trim(problems->list[i].order_mnemonic)
   IF ((problems->list[i].dose > "")
    AND (problems->list[i].dose_unit > 0))
    SET column1 = concat(column1," ",problems->list[i].dose," ",trim(uar_get_code_display(problems->
       list[i].dose_unit)))
    IF ((problems->list[i].prn_ind=1))
     SET column1 = concat(column1,", ","PRN")
    ENDIF
   ELSEIF ((problems->list[i].volume_dose > "")
    AND (problems->list[i].volume_dose_unit > 0))
    SET column1 = concat(column1," ",problems->list[i].volume_dose," ",trim(uar_get_code_display(
       problems->list[i].volume_dose_unit)))
    IF ((problems->list[i].prn_ind=1))
     SET column1 = concat(column1,", ","PRN")
    ENDIF
   ELSEIF ((problems->list[i].dose > " "))
    SET column1 = concat(column1," ",problems->list[i].dose)
    IF ((problems->list[i].prn_ind=1))
     SET column1 = concat(column1,", ","PRN")
    ENDIF
   ENDIF
   SET column1 = concat(column1," ",trim(uar_get_code_display(problems->list[i].frequency)))
   SET reply->text = concat(reply->text,lock," ",column1," \cell ",
    problems->list[i].comment," \cell",unlock," \cell \cell "," \cell \row ")
 ENDFOR
 SET reply->text = concat(reply->text," \cell \cell \cell \cell \cell\row",
  " \cell \cell \cell \cell \cell\row")
 SET reply->text = concat(reply->text," \pard \ql ",reol,wr,"Comments:",
  reol,tblhead5," \cell \row ",reol,reol)
 SET reply->text = concat(reply->text,wr,"Name of Provider Notified: ",reol,tblhead6,
  " \cell \row ",reol)
 SET reply->text = concat(reply->text,rtfeof)
 CALL echorecord(problems)
 CALL echorecord(request)
END GO

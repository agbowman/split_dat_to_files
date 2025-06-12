CREATE PROGRAM bhs_cls_phystats:dba
 PROMPT
  "Output to File/Printer/MINE/Email Address" = "MINE",
  "Enter Start Date:" = "CURDATE",
  "Enter End Date:" = "CURDATE",
  "Orders to Qualify" = "1",
  "Encounter Types" = "1",
  "Output Type" = "1"
  WITH prompt1, prompt2, prompt3,
  prompt4, prompt5, prompt6
 FREE RECORD phys
 RECORD phys(
   1 phys_list_cnt = i4
   1 list[*]
     2 person_id = f8
     2 person_name = vc
     2 position_cd = f8
     2 facility_cd = f8
     2 mdcount = f8
     2 prcount = f8
     2 pvcount = f8
     2 sidcount = f8
     2 wrcount = f8
     2 otcount = f8
     2 totcount = f8
 )
 DECLARE inp_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Inpatient"))
 DECLARE day_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Daystay"))
 DECLARE obs_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Observation"))
 DECLARE emergency_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Emergency"))
 DECLARE disch_inp_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Disch IP"))
 DECLARE disch_obs_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Disch Obv"))
 DECLARE disch_day_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "Disch Daystay"))
 DECLARE disch_es_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Disch ES"))
 DECLARE exp_inp_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Expired IP"))
 DECLARE exp_obs_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Expired Obv"))
 DECLARE exp_day_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "Expired Daystay"))
 DECLARE exp_es_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Expired ES"))
 DECLARE pharm_activity_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,"Pharmacy")
  )
 DECLARE pharm_op_activity_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,
   "Pharmacy Outpatient"))
 DECLARE fin_alias_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cnt = i4
 DECLARE output_line = vc
 DECLARE mdcount = f8
 DECLARE prcount = f8
 DECLARE pvcount = f8
 DECLARE sidcount = f8
 DECLARE wrcount = f8
 DECLARE otcount = f8
 DECLARE totcount = f8
 DECLARE mdpct = f8
 DECLARE prpct = f8
 DECLARE pvpct = f8
 DECLARE sidpct = f8
 DECLARE wrpct = f8
 DECLARE output_dest = vc
 DECLARE email_ind = i2
 DECLARE cnt = i4
 DECLARE filename_in = vc
 DECLARE filename_out = vc
 DECLARE mnemonic = vc
 IF (findstring("@", $PROMPT1) > 0)
  SET email_ind = 1
 ELSE
  SET email_ind = 0
 ENDIF
 IF (( $PROMPT2="BEGOFPREVMONTH"))
  SET current_month = month(curdate)
  SET month_qual = (current_month - 1)
  SET year_qual = year(curdate)
  IF (month_qual=0)
   SET month_qual = 12
   SET year_qual = (year_qual - 1)
  ENDIF
  SET beg_date_qual = cnvtdate(concat(format(month_qual,"##"),"01",format(year_qual,"####")))
 ELSE
  SET beg_date_qual = cnvtdate(cnvtint( $PROMPT2))
 ENDIF
 IF (( $PROMPT3="ENDOFPREVMONTH"))
  SET current_month = month(curdate)
  SET current_year = year(curdate)
  SET end_date_qual = (cnvtdate(concat(format(current_month,"##"),"01",format(current_year,"####")))
   - 1)
 ELSE
  SET end_date_qual = cnvtdate(cnvtint( $PROMPT3))
 ENDIF
 SET beg_date_disp = format(beg_date_qual,"MM/DD/YYYY;;d")
 SET end_date_disp = format(end_date_qual,"MM/DD/YYYY;;d")
 SET m = cnvtstring(month(beg_date_qual))
 SET y = cnvtstring(year(beg_date_qual))
 DECLARE outfile1 = vc
 DECLARE outfile2 = vc
 SET outfile1 = trim(concat("cpoe_detail_",y,m),4)
 SET outfile2 = trim(concat("cpoe_summary_",y,m),4)
 SELECT INTO value(outfile1)
  FROM orders o,
   order_action oa,
   prsnl p,
   encounter e,
   encntr_alias ea,
   person pe,
   prsnl p2
  PLAN (oa
   WHERE oa.action_dt_tm >= cnvtdatetime(beg_date_qual,0)
    AND oa.action_dt_tm <= cnvtdatetime(end_date_qual,235959)
    AND oa.action_type_cd=2534
    AND  NOT (oa.order_provider_id IN (0, 1, 1934566, 1196828, 589879,
   589827, 844764, 749374, 589854, 589850)))
   JOIN (o
   WHERE o.template_order_id=0
    AND o.order_id=oa.order_id
    AND o.orig_ord_as_flag=0
    AND o.contributor_system_cd=469
    AND ((( $PROMPT4="1")) OR (( $PROMPT4="2")
    AND o.activity_type_cd IN (pharm_activity_type_cd, pharm_op_activity_type_cd))) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.encntr_type_cd IN (obs_enc_type_cd, inp_enc_type_cd, day_enc_type_cd, emergency_enc_type_cd,
   disch_inp_enc_type_cd,
   disch_obs_enc_type_cd, disch_day_enc_type_cd, disch_es_enc_type_cd, exp_inp_enc_type_cd,
   exp_obs_enc_type_cd,
   exp_day_enc_type_cd, exp_es_enc_type_cd))
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
   JOIN (p2
   WHERE p2.person_id=oa.action_personnel_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ea.encntr_alias_type_cd=fin_alias_type_cd)
   JOIN (pe
   WHERE pe.person_id=e.person_id)
  ORDER BY p.name_full_formatted, o.order_id
  HEAD REPORT
   phys_count = 0
   IF (( $PROMPT6="1"))
    output_line = concat("Counter",",","Physician",",","Encounter Type",
     ",","Activity Type",",","Order Type",",",
     "Facility",",","Fin",",","Patient Name",
     ",","Order",",","Action Prsnl",",",
     "Order ID",",","Order Date"), col 1, output_line,
    row + 1
   ENDIF
   i = 0
  HEAD p.name_full_formatted
   mdcount = 0, prcount = 0, pvcount = 0,
   sidcount = 0, wrcount = 0, otcount = 0
  DETAIL
   i = 1, physname = p.name_full_formatted, output_line = concat(trim(cnvtstring(i)),",",char(34),
    trim(physname),char(34),
    ",",char(34),trim(uar_get_code_display(e.encntr_type_cd)),char(34),",",
    char(34),trim(uar_get_code_display(o.activity_type_cd)),char(34))
   IF (oa.action_personnel_id=oa.order_provider_id)
    mdcount = (mdcount+ 1), output_line = concat(output_line,",",char(34),"cpoe orders",char(34))
   ELSE
    IF (oa.communication_type_cd=2559)
     prcount = (prcount+ 1), output_line = concat(output_line,",",char(34),"protocol orders",char(34)
      )
    ELSEIF (oa.communication_type_cd=2560)
     pvcount = (pvcount+ 1), output_line = concat(output_line,",",char(34),"phone/verbal orders",char
      (34))
    ELSEIF (oa.communication_type_cd=2561)
     sidcount = (sidcount+ 1), output_line = concat(output_line,",",char(34),
      "sec/immun/downtime orders",char(34))
    ELSEIF (oa.communication_type_cd=2562)
     wrcount = (wrcount+ 1), output_line = concat(output_line,",",char(34),"written orders",char(34))
    ELSE
     otcount = (otcount+ 1), output_line = concat(output_line,",",char(34),"other orders",char(34))
    ENDIF
   ENDIF
   mnemonic = replace(o.order_mnemonic,char(34),"",0), output_line = concat(output_line,",",char(34),
    trim(uar_get_code_display(e.loc_facility_cd)),char(34),
    ",",char(34),trim(ea.alias),char(34),",",
    char(34),trim(pe.name_full_formatted),char(34),",",char(34),
    trim(mnemonic),char(34),",",char(34),trim(p2.name_full_formatted),
    char(34),",",char(34),trim(cnvtstring(o.order_id)),char(34),
    ",",char(34),format(o.orig_order_dt_tm,"MM/DD/YYYY;;D"),char(34)), output_line = replace(
    output_line,char(10),"",0),
   output_line = replace(output_line,char(13),"",0), col 1, output_line
   IF (output_line > " ")
    row + 1
   ELSE
    row- (1)
   ENDIF
  FOOT  p.name_full_formatted
   totcount = (((((mdcount+ prcount)+ pvcount)+ sidcount)+ wrcount)+ otcount)
   IF (totcount > 0)
    cnt = (cnt+ 1)
    IF (mod(cnt,100)=1)
     stat = alterlist(phys->list,(cnt+ 99))
    ENDIF
    phys->list[cnt].person_id = p.person_id, phys->list[cnt].person_name = p.name_full_formatted,
    phys->list[cnt].facility_cd = e.loc_facility_cd,
    phys->list[cnt].position_cd = p.position_cd, phys->list[cnt].mdcount = mdcount, phys->list[cnt].
    prcount = prcount,
    phys->list[cnt].pvcount = pvcount, phys->list[cnt].wrcount = wrcount, phys->list[cnt].sidcount =
    sidcount,
    phys->list[cnt].otcount = otcount, phys->list[cnt].totcount = totcount
   ENDIF
  FOOT REPORT
   stat = alterlist(phys->list,cnt)
  WITH maxcol = 800, maxrow = 1, format = variable,
   landscape, compress, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = concat(trim(outfile1,3),".dat")
  SET filename_out = concat(trim(outfile1,3),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Baystate Medical Center CPOE Details Report  ",beg_date_disp,
   " to ",end_date_disp)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
 IF (( $PROMPT6="2")
  AND email_ind=0)
  DECLARE dclcom = vc
  SET filename_in = concat(trim(outfile1,3),".dat")
  SET filename_out = concat(trim(outfile1,3),".csv")
  SET dclcom = concat("mv ",filename_in," ",filename_out)
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  SET stat = 0
  SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",filename_out,
   " 172.17.3.15 egftp egftp /tempfiles/hold/egate/cis_cpoe")
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
 ENDIF
 DECLARE output_string = vc
 DECLARE loc_facility_display = vc
 DECLARE loc_facility_group = vc
 SELECT INTO value(outfile2)
  loc_facility_cd = phys->list[d.seq].facility_cd, person_id = phys->list[d.seq].person_id, docname
   = phys->list[d.seq].person_name,
  position_cd = phys->list[d.seq].position_cd
  FROM (dummyt d  WITH seq = value(cnt))
  ORDER BY loc_facility_cd, docname
  HEAD REPORT
   num_lines_printed = 0, phys_type = fillstring(20," ")
   IF (( $PROMPT6="1"))
    IF (email_ind=0)
     col 1, "Date Range: ", beg_date_disp,
     " - ", end_date_disp, row + 1
     IF (( $PROMPT4="1"))
      col 1, "All Orders"
     ELSEIF (( $PROMPT4="2"))
      col 1, "Pharmacy Orders Only"
     ENDIF
     row + 1
     IF (( $PROMPT5="1"))
      col 1, "Outpatients Excluded"
     ELSEIF (( $PROMPT4="2"))
      col 1, "All Encounter Types"
     ENDIF
     row + 1, col 002, "DocName",
     col 034, "Specialty", col 054,
     "MD Ord", col 064, "MD Pct",
     col 074, "Prot Ord", col 084,
     "Prot Pct", col 097, "PhVb Ord",
     col 107, "PhVb Pct", col 120,
     "SID Ord", col 130, "SID Pct",
     col 142, "Writ Ord", col 152,
     "Writ Pct", col 163, "Other Ord",
     col 174, "Total Ord", col 186,
     "CPOE Rate", row + 1
    ELSE
     col 1, ',"Date Range: ', beg_date_disp,
     " - ", end_date_disp, '"',
     row + 1
     IF (( $PROMPT4="1"))
      col 1, ',"All Orders"'
     ELSEIF (( $PROMPT4="2"))
      col 1, ',"Pharmacy Orders Only"'
     ENDIF
     row + 1
     IF (( $PROMPT5="1"))
      col 1, ',"Outpatients Excluded"'
     ELSEIF (( $PROMPT4="2"))
      col 1, ',"All Encounter Types"'
     ENDIF
     row + 1, output_string = concat(',"DocName","Specialty","Facility","MD Ord","MD Pct","Prot Ord"',
      ',"Prot Pct","PhVb Ord","PhVb Pct","SID Ord","SID Pct"',
      ',"Writ Ord","Writ Pct","Other Ord","Total Ord","CPOE Rate"'), col 1,
     output_string, row + 1
    ENDIF
   ENDIF
  HEAD loc_facility_cd
   IF (( $PROMPT6="1"))
    IF (email_ind=0)
     IF (loc_facility_cd > 0.00)
      loc_facility_display = substring(1,40,uar_get_code_display(loc_facility_cd)), col 1,
      loc_facility_display
     ELSE
      col 1, "Unknown Facility"
     ENDIF
     row + 1
    ENDIF
   ENDIF
  DETAIL
   CASE (uar_get_code_display(position_cd))
    OF "BHS Anesthesiology MD":
     phys_type = "Anesthesiology"
    OF "BHS Cardiology MD":
     phys_type = "Internal Medicine"
    OF "BHS Cardiac Surgery MD":
     phys_type = "Surgery"
    OF "BHS Critical Care MD":
     phys_type = "Internal Medicine"
    OF "BHS ER Medicine MD":
     phys_type = "Emergency Medicine"
    OF "BHS Infectious Disease MD":
     phys_type = "Internal Medicine"
    OF "BHS GI MD":
     phys_type = "Internal Medicine"
    OF "BHS Urology MD":
     phys_type = "Surgery"
    OF "BHS Thoracic MD":
     phys_type = "Surgery"
    OF "BHS Trauma MD":
     phys_type = "Surgery"
    OF "BHS Resident":
     phys_type = "Resident"
    OF "BHS Oncology MD":
     phys_type = "Internal Medicine"
    OF "BHS Neonatal MD":
     phys_type = "Pediatrics"
    OF "BHS Neurology MD":
     phys_type = "Internal Medicine"
    OF "BHS OB/GYN MD":
     phys_type = "Ob/Gyn"
    OF "BHS Orthopedics MD":
     phys_type = "Surgery"
    OF "BHS General Pediatrics MD":
     phys_type = "Pediatrics"
    OF "BHS Psychiatry MD":
     phys_type = "Psychiatry"
    OF "BHS Physiatry MD":
     phys_type = "Internal Medicine"
    OF "BHS Pulmonary MD":
     phys_type = "Internal Medicine"
    OF "BHS Radiology MD":
     phys_type = "Radiology"
    OF "BHS Renal MD":
     phys_type = "Internal Medicine"
    OF "BHS General Surgery MD":
     phys_type = "Surgery"
    OF "BHS Midwife":
     phys_type = "Ob/Gyn"
    OF "BHS Associate Professional":
     phys_type = "Associate Provider"
    OF "BHS Physician (General Medicine)":
     phys_type = "Internal Medicine"
    OF "BHS Medical Student":
     phys_type = "Medical Student"
    ELSE
     phys_type = "Other"
   ENDCASE
   mdpct = (phys->list[d.seq].mdcount/ phys->list[d.seq].totcount), prpct = (phys->list[d.seq].
   prcount/ phys->list[d.seq].totcount), pvpct = (phys->list[d.seq].pvcount/ phys->list[d.seq].
   totcount),
   sidpct = (phys->list[d.seq].sidcount/ phys->list[d.seq].totcount), wrpct = (phys->list[d.seq].
   wrcount/ phys->list[d.seq].totcount), cpoe_rate = (phys->list[d.seq].mdcount/ (phys->list[d.seq].
   mdcount+ phys->list[d.seq].wrcount))
   IF (( $PROMPT6="1"))
    IF (email_ind=0)
     col 002, docname, col 034,
     phys_type, col 055, phys->list[d.seq].mdcount"#####;R",
     col 064, mdpct"#.####;R", col 077,
     phys->list[d.seq].prcount"#####;R", col 086, prpct"#.####;R",
     col 100, phys->list[d.seq].pvcount"#####;R", col 109,
     pvpct"#.####;R", col 122, phys->list[d.seq].sidcount"#####;R",
     col 131, sidpct"#.####;R", col 145,
     phys->list[d.seq].wrcount"#####;R", col 154, wrpct"#.####;R",
     col 167, phys->list[d.seq].otcount"#####;R", col 177,
     phys->list[d.seq].totcount"######;R", col 189, cpoe_rate"#.####;R"
    ELSE
     output_string = build(',"',docname,'","',phys_type,'","',
      loc_facility_display,'",',phys->list[d.seq].mdcount,",",mdpct,
      ",",phys->list[d.seq].prcount,",",prpct,",",
      phys->list[d.seq].pvcount,",",pvpct,",",phys->list[d.seq].sidcount,
      ",",sidpct,",",phys->list[d.seq].wrcount,",",
      wrpct,",",phys->list[d.seq].otcount,",",phys->list[d.seq].totcount,
      ",",cpoe_rate), col 1, output_string
    ENDIF
    num_lines_printed = (num_lines_printed+ 1)
    IF (num_lines_printed < cnt)
     row + 1
    ENDIF
   ELSE
    IF (loc_facility_cd > 0.00)
     loc_facility_display = uar_get_code_display(loc_facility_cd)
    ELSE
     loc_facility_display = "Unknown Facility"
    ENDIF
    IF (loc_facility_display IN ("FMC", "ADULT PHP- FMC", "BEACON RCV", "OUTPT PSYCH",
    "FMC INPT PSYCH",
    "BRAT RETRE", "BFMC", "ADULT PHP- BFMC", "BFMC INPT PSYCH"))
     loc_facility_group = "BFMC "
    ELSEIF (loc_facility_display IN ("MLH", "BMLH"))
     loc_facility_group = "BMLH "
    ELSEIF (loc_facility_display="MOCK")
     loc_facility_group = "MOCK"
    ELSEIF (loc_facility_display="Unknown Facility")
     loc_facility_group = "Unknown Facility"
    ELSE
     loc_facility_group = "BMC "
    ENDIF
    cpoe_count = (phys->list[d.seq].mdcount+ phys->list[d.seq].wrcount), output_string = build(char(
      34),end_date_disp,char(34),",",char(34),
     phys->list[d.seq].person_name,char(34),",",char(34),phys_type,
     char(34),",",char(34),loc_facility_display,char(34),
     ",",char(34),loc_facility_group,char(34),",",
     phys->list[d.seq].mdcount,",",phys->list[d.seq].prcount,",",phys->list[d.seq].pvcount,
     ",",phys->list[d.seq].sidcount,",",phys->list[d.seq].wrcount,",",
     phys->list[d.seq].otcount,",",phys->list[d.seq].totcount,",",cpoe_count), col 1,
    output_string, num_lines_printed = (num_lines_printed+ 1)
    IF (num_lines_printed < cnt)
     row + 1
    ENDIF
   ENDIF
  WITH maxcol = 200, maxrow = 1, format = variable,
   landscape, compress, formfeed = none
 ;end select
 DECLARE dclcom = vc
 IF (email_ind=1)
  SET filename_in = concat(trim(outfile2,3),".dat")
  SET filename_out = concat(trim(outfile2,3),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Baystate Medical Center CPOE Summary Report ",beg_date_disp,
   " to ",end_date_disp)
  IF (( $PROMPT4="1"))
   SET subject_line = concat(subject_line,", All Orders")
  ELSEIF (( $PROMPT4="2"))
   SET subject_line = concat(subject_line,", Pharmacy Orders Only")
  ENDIF
  IF (( $PROMPT5="1"))
   SET subject_line = concat(subject_line,", Outpatients Excluded")
  ELSEIF (( $PROMPT5="2"))
   SET subject_line = concat(subject_line,", All Encounter Types")
  ENDIF
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
 IF (( $PROMPT6="2")
  AND email_ind=0)
  SET filename_in = concat(trim(outfile2,3),".dat")
  SET filename_out = concat(trim(outfile2,3),".csv")
  SET dclcom = concat("mv ",filename_in," ",filename_out)
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  SET stat = 0
  SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",filename_out,
   " 172.17.3.15 egftp egftp /tempfiles/hold/egate/cis_cpoe")
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
 ENDIF
#endprogram
#end_prog
END GO

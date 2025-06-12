CREATE PROGRAM cls_physstats_to_hbi_read:dba
 PROMPT
  "Output to File/Printer/MINE/Email Address" = "MINE",
  "Enter Start Date:" = "CURDATE",
  "Enter End Date:" = "CURDATE",
  "Orders to Qualify" = "1",
  "Encounter Types" = "1",
  "Output Type" = "1"
  WITH prompt1, prompt2, prompt3,
  prompt4, prompt5, prompt6
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
 SET output_dest =  $PROMPT1
 IF (((findstring("@", $PROMPT1) > 0) OR (( $PROMPT6="2"))) )
  IF (( $PROMPT6="1"))
   SET email_ind = 1
  ENDIF
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET email_ind = 0
  SET output_dest =  $PROMPT1
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
 CALL echo(beg_date_disp)
 CALL echo(end_date_disp)
 DECLARE obs_enc_type_cd = f8
 DECLARE inp_enc_type_cd = f8
 DECLARE day_enc_type_cd = f8
 DECLARE emergency_enc_type_cd = f8
 DECLARE disch_inp_enc_type_cd = f8
 DECLARE disch_obs_enc_type_cd = f8
 DECLARE disch_day_enc_type_cd = f8
 DECLARE disch_es_type_cd = f8
 DECLARE exp_inp_enc_type_cd = f8
 DECLARE exp_obs_enc_type_cd = f8
 DECLARE exp_day_enc_type_cd = f8
 DECLARE exp_es_type_cd = f8
 DECLARE pharm_activity_type_cd = f8
 DECLARE fin_alias_type_cd = f8
 SET obs_enc_type_cd = uar_get_code_by("DISPLAY",71,"Observation")
 SET inp_enc_type_cd = uar_get_code_by("DISPLAY",71,"Inpatient")
 SET day_enc_type_cd = uar_get_code_by("DISPLAY",71,"Daystay")
 SET emergency_enc_type_cd = uar_get_code_by("DISPLAY",71,"Emergency")
 SET disch_inp_enc_type_cd = uar_get_code_by("DISPLAY",71,"Disch IP")
 SET disch_obs_enc_type_cd = uar_get_code_by("DISPLAY",71,"Disch Obv")
 SET disch_day_enc_type_cd = uar_get_code_by("DISPLAY",71,"Disch Daystay")
 SET disch_es_enc_type_cd = uar_get_code_by("DISPLAY",71,"Disch ES")
 SET exp_inp_enc_type_cd = uar_get_code_by("DISPLAY",71,"Expired IP")
 SET exp_obs_enc_type_cd = uar_get_code_by("DISPLAY",71,"Expired Obv")
 SET exp_day_enc_type_cd = uar_get_code_by("DISPLAY",71,"Expired Daystay")
 SET exp_es_enc_type_cd = uar_get_code_by("DISPLAY",71,"Expired ES")
 SET pharm_activity_type_cd = uar_get_code_by("DISPLAY",106,"Pharmacy")
 SET pharm_op_activity_type_cd = uar_get_code_by("DISPLAY",106,"Pharmacy Outpatient")
 SET fin_alias_type_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 DECLARE cnt = i4
 FREE RECORD phys
 RECORD phys(
   1 list[*]
     2 person_id = f8
     2 person_name = vc
     2 position_cd = f8
     2 facility_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 comm_type_cd = f8
     2 action_prsnl_id = f8
     2 pat_name = vc
 )
 DECLARE output_line = vc
 SET m = month(beg_date_qual)
 CALL echo(build("month: ",m))
 CALL echo(output_dest)
 SELECT DISTINCT INTO value(output_dest)
  p.name_full_formatted, o.order_id, sort_order =
  IF (oa.order_provider_id=oa.action_personnel_id) 1
  ELSEIF (oa.communication_type_cd=2559) 2
  ELSEIF (oa.communication_type_cd=2560) 3
  ELSEIF (oa.communication_type_cd=2561) 4
  ELSEIF (oa.communication_type_cd=2562) 5
  ELSE 6
  ENDIF
  FROM orders o,
   order_action oa,
   prsnl p,
   encounter e,
   encntr_alias ea,
   person pe,
   prsnl p2
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(beg_date_qual,0) AND cnvtdatetime(end_date_qual,235959)
    AND oa.action_type_cd=2534)
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
   WHERE p.person_id=oa.order_provider_id
    AND  NOT (oa.order_provider_id IN (0, 1934566, 1196828, 589879, 589827,
   844764, 749374, 589854, 589850)))
   JOIN (p2
   WHERE p2.person_id=oa.action_personnel_id
    AND  NOT (oa.order_provider_id IN (0, 1934566, 1196828, 589879, 589827,
   844764, 749374, 589854, 589850)))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ea.encntr_alias_type_cd=fin_alias_type_cd)
   JOIN (pe
   WHERE pe.person_id=e.person_id)
  ORDER BY p.name_full_formatted, o.order_id
  HEAD REPORT
   output_line = concat("Counter",",","Physician",",","Encounter Type",
    ",","Activity Type",",","Order Type",",",
    "Facility",",","Fin",",","Patient Name",
    ",","Order",",","Action Prsnl",",",
    "Order ID",",","Order Date"), col 1, output_line,
   row + 1, i = 0
  DETAIL
   i = 1, physname = replace(trim(p.name_full_formatted),",","",0), output_line = concat(cnvtstring(i
     ),",",physname,",",trim(uar_get_code_display(e.encntr_type_cd)),
    ",",trim(uar_get_code_display(o.activity_type_cd)))
   IF (sort_order=1)
    output_line = concat(output_line,'","CPOE Orders"')
   ELSEIF (sort_order=2)
    output_line = concat(output_line,'","Protocol Orders"')
   ELSEIF (sort_order=3)
    output_line = concat(output_line,'","Phone/Verbal Orders"')
   ELSEIF (sort_order=4)
    output_line = concat(output_line,'","Sec/Immun/Downtime Orders"')
   ELSEIF (sort_order=5)
    output_line = concat(output_line,'","Written Orders"')
   ELSE
    output_line = concat(output_line,'","Other Orders"')
   ENDIF
   output_line = concat(output_line,',"',trim(uar_get_code_display(e.loc_facility_cd)),'","',trim(ea
     .alias),
    '","',trim(replace(pe.name_full_formatted,'"'," ",0)),'","',trim(replace(o.order_mnemonic,'"'," ",
      0)),'","',
    trim(replace(p2.name_full_formatted,'"'," ",0)),'",',cnvtstring(o.order_id),",",format(o
     .orig_order_dt_tm,"MM/DD/YYYY;;D")), col 1, output_line
   IF (output_line > " ")
    row + 1
   ELSE
    row- (1)
   ENDIF
  WITH maxcol = 800, maxrow = 1, format = variable,
   landscape, compress, formfeed = none
 ;end select
 IF (( $PROMPT6="2"))
  DECLARE dclcom = vc
  SET dclcom = concat("mv ",output_dest,".dat ",output_dest,".csv")
  CALL echo(dclcom)
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  SET stat = 0
  SET dclcom = concat("$CCLUSERDIR/bhs_ftp_file.ksh ",output_dest,
   ".csv 172.17.3.15 egftp egftp /tempfiles/hold/egate/cis_cpoe")
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
 ENDIF
 IF (email_ind=1)
  SET filename_in = concat(trim(output_dest),".dat")
  SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Med Recon Detail ",beg_date_disp," to ",end_date_disp)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#endprogram
#end_prog
END GO

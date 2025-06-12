CREATE PROGRAM cls_physstats_one_phys:dba
 PROMPT
  "Output to File/Printer/MINE/Email Address" = "MINE",
  "Enter Start Date:" = "CURDATE",
  "Enter End Date:" = "CURDATE",
  "Orders to qualify" = "1",
  "Encounter Types" = "1",
  "Select Physician from List"
  WITH prompt1, prompt2, prompt3,
  prompt4, prompt5, prompt7
 SET printer =  $PROMPT1
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
 IF (findstring("@", $PROMPT1) > 0)
  SET email_ind = 1
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET email_ind = 0
  SET output_dest =  $PROMPT1
 ENDIF
 SET beg_date_qual = cnvtdate(cnvtalphanum( $PROMPT2))
 SET end_date_qual = cnvtdate(cnvtalphanum( $PROMPT3))
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
 SELECT INTO  $PROMPT1
  o.active_ind, o_active_status_disp = uar_get_code_display(o.active_status_cd), o
  .active_status_dt_tm,
  o_contrib_sys_disp = uar_get_code_display(o.contributor_system_cd), o.cs_order_id, o
  .discontinue_effective_dt_tm,
  o.group_order_flag, o.group_order_id, o.order_id,
  o_order_status_disp = uar_get_code_display(o.order_status_cd), o.person_id, o.status_dt_tm,
  o.status_prsnl_id, o.updt_dt_tm, o.template_order_id,
  oa.action_personnel_id, oa.effective_dt_tm, oa.order_dt_tm,
  oa.order_provider_id, oa.order_id, oa.updt_dt_tm,
  oa.communication_type_cd, p.person_id, docname = substring(0,30,p.name_full_formatted),
  oa_action_type_disp = uar_get_code_display(oa.action_type_cd), oa.action_sequence, sort_order =
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
   person pe
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(beg_date_qual,0) AND cnvtdatetime(end_date_qual,235959)
    AND oa.action_type_cd=2534
    AND ((oa.order_provider_id+ 0)= $PROMPT7))
   JOIN (o
   WHERE o.template_order_id=0
    AND o.order_id=oa.order_id
    AND o.contributor_system_cd=469
    AND ((( $PROMPT4="1")) OR (( $PROMPT4="2")
    AND o.activity_type_cd IN (pharm_activity_type_cd, pharm_op_activity_type_cd))) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND ((( $PROMPT5="1")
    AND e.encntr_type_cd IN (obs_enc_type_cd, inp_enc_type_cd, day_enc_type_cd, emergency_enc_type_cd,
   disch_inp_enc_type_cd,
   disch_obs_enc_type_cd, disch_day_enc_type_cd, disch_es_enc_type_cd, exp_inp_enc_type_cd,
   exp_obs_enc_type_cd,
   exp_day_enc_type_cd, exp_es_enc_type_cd)) OR (( $PROMPT5="2"))) )
   JOIN (p
   WHERE p.person_id=outerjoin(oa.action_personnel_id))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ea.encntr_alias_type_cd=fin_alias_type_cd)
   JOIN (pe
   WHERE pe.person_id=e.person_id)
  ORDER BY e.loc_facility_cd, sort_order
  HEAD e.loc_facility_cd
   facility_disp = substring(1,20,uar_get_code_display(e.loc_facility_cd)), col 1, facility_disp,
   row + 1
  HEAD sort_order
   IF (sort_order=1)
    col 5, "CPOE Orders"
   ELSEIF (sort_order=2)
    col 5, "Protocol Orders"
   ELSEIF (sort_order=3)
    col 5, "Phone/Verbal Orders"
   ELSEIF (sort_order=4)
    col 5, "Sec/Immun/Downtime Orders"
   ELSEIF (sort_order=5)
    col 5, "Written Orders"
   ELSE
    col 5, "Other Orders"
   ENDIF
   row + 1, order_cnt = 0
  DETAIL
   order_cnt = (order_cnt+ 1), fin_disp = substring(1,13,ea.alias), col 10,
   fin_disp, pat_name_disp = substring(1,30,pe.name_full_formatted), col 25,
   pat_name_disp, ord_mnemonic_disp = substring(1,30,o.ordered_as_mnemonic), col 56,
   ord_mnemonic_disp, enc_type_disp = substring(1,9,uar_get_code_display(e.encntr_type_cd)), col 87,
   enc_type_disp, action_person = substring(1,30,p.name_full_formatted), col 97,
   action_person, row + 1
  FOOT  sort_order
   col 5, "Total: ", order_cnt,
   row + 1
  WITH nocounter
 ;end select
#endprogram
END GO

CREATE PROGRAM bhs_rpt_case_mgmt_ins:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Last Name" = "",
  "First Name" = "",
  "Person ID" = 0,
  "Encounter" = 0,
  "Email" = "",
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, last_name, first_name,
  vpid, pat_encounter, email,
  start_dt, end_dt
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "case_mgmt_rpt.pdf"
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
 ENDIF
 IF (datetimediff(cnvtdatetime(cnvtdate( $END_DT),0),cnvtdatetime(cnvtdate( $START_DT),0)) > 14)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 14 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(cnvtdatetime(cnvtdate( $END_DT),0),cnvtdatetime(cnvtdate( $START_DT),0)) < 0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Negative days .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 SET date_diff = cnvtint(round(datetimediff(cnvtdatetime(cnvtdate( $END_DT),235959),cnvtdatetime(
     cnvtdate( $START_DT),0),1),0))
 CALL echo(build("Date Diff =",date_diff))
 FREE RECORD insurance_review
 RECORD insurance_review(
   1 person_id = f8
   1 patient_name = vc
   1 encntr_id = f8
   1 dob = vc
   1 accout_no = vc
   1 admit_date = vc
   1 patient_type = vc
   1 reason_for_visit = vc
   1 loc_cnt = i2
   1 weight = vc
   1 locations = vc
   1 loc_hist = vc
   1 dates[*]
     2 cnt_day_item = i4
     2 cnt_ord_for_day = i4
     2 day_dt = dq8
     2 day = vc
     2 ord_day = vc
     2 order_day[*]
       3 clin_cat = vc
       3 clin_cat_cd = f8
       3 order_id = f8
       3 hna_ord_mnem = vc
       3 order_name = vc
       3 clin_display = vc
       3 action_type = vc
       3 stop_date = vc
       3 order_date = vc
       3 order_status = vc
       3 order_status_date = vc
       3 comment = vc
       3 time_view = vc
       3 sort1 = i2
       3 sort2 = i2
       3 sort3 = i2
     2 rad_result_cnt = i4
     2 cnt_rad_res = i4
     2 day_rad = vc
     2 rad_results[*]
       3 res_order_name = vc
       3 accession_num = c20
       3 s_ce_event = f8
       3 s_display = vc
       3 s_value = vc
       3 s_date = vc
       3 blob_result = vc
     2 lab_result_cnt = i4
     2 day_lab = vc
     2 lab_results[*]
       3 accession_num = c20
       3 s_ce_event = f8
       3 s_display = vc
       3 s_value = vc
       3 s_date = vc
       3 blob_result = vc
     2 op_rpt_day = vc
     2 op_rpt_cnt = i4
     2 op_report[*]
       3 accession_num = c20
       3 s_ce_event = f8
       3 s_display = vc
       3 s_value = vc
       3 s_date = vc
       3 blob_result = vc
     2 vitals_day = vc
     2 vital_cnt = i4
     2 vitals_hi_lo_crit[*]
       3 vitals_tag = vc
       3 vital_res = vc
       3 vital_col = i4
     2 cnt_io = i4
     2 io_day = vc
     2 in_24_tot = i4
     2 out_24_tot = i4
     2 io_bal_24 = i4
 )
 SET stat = alterlist(insurance_review->dates,date_diff)
 FOR (dt = 1 TO size(insurance_review->dates,5))
   SET insurance_review->dates[dt].day = format(cnvtdatetime((cnvtdate( $START_DT)+ (dt - 1)),0),
    "yyyymmdd;;d")
   SET insurance_review->dates[dt].day_dt = cnvtdatetime((cnvtdate( $START_DT)+ (dt - 1)),0)
   SET insurance_review->dates[dt].cnt_day_item = 0
 ENDFOR
 DECLARE test1 = vc WITH protect
 DECLARE a_prt = i4 WITH noconstant(0), public
 DECLARE nodata = vc WITH protect
 DECLARE room_needed = f8 WITH public
 DECLARE tmp_work_room = f8 WITH noconstant(0), public
 DECLARE continued = vc WITH noconstant(" "), public
 DECLARE g_prt = i4 WITH protect
 DECLARE e_prt = i4 WITH protect
 DECLARE c_prt = i4 WITH protect
 DECLARE b_prt = i4 WITH protect
 DECLARE order_day_order_status_date = vc WITH noconstant(" "), protect
 DECLARE order_day_clin_display = vc WITH noconstant(" "), protect
 DECLARE order_day_order_name = vc WITH noconstant(" "), protect
 DECLARE ord_cnt = i4 WITH noconstant(0)
 DECLARE current_cat = vc WITH noconstant(" "), public
 DECLARE vital_day_cnt = i4 WITH noconstant(0), public
 DECLARE io_day_cnt = i4 WITH noconstant(0), public
 DECLARE op_rpt_day_cnt = i4 WITH noconstant(0), public
 DECLARE laboratory = f8 WITH constant(uar_get_code_by("DISPLAYKEY",93,"LABORATORY")), protect
 DECLARE radiology = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RADIOLOGY")), protect
 DECLARE authverified = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")), protect
 DECLARE intake_x = i4 WITH protect
 DECLARE output_x = i4 WITH protect
 DECLARE output_combine = vc WITH protect
 DECLARE intake_combine = vc WITH noconstant(""), protect
 DECLARE ord_date_prt = vc WITH noconstant('" "'), public
 DECLARE ord_display_prt = vc WITH noconstant('" "'), public
 DECLARE ord_prt = vc WITH noconstant('" "'), public
 DECLARE becont = i4 WITH noconstant(0), protect
 DECLARE time_view = vc WITH public
 DECLARE clin_cat_neuro_diag = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,
   "NEURODIAGNOSTICS"))
 DECLARE clin_cat_nutri_serv = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,
   "DIETNUTRITIONSERVICES"))
 DECLARE clin_cat_iv = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,"IVSOLUTIONS"))
 DECLARE clin_cat_meds = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,"MEDICATIONS"))
 DECLARE clin_cat_mdtorn = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,"MDTORN"))
 DECLARE clin_cat_cond = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,"CONDITION"))
 DECLARE clin_cat_cardpul = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,
   "CARDIOPULMONARY"))
 DECLARE clin_cat_lab = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,"LABORATORY"))
 DECLARE clin_cat_rad = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",16389,
   "DIAGNOSTICIMAGING"))
 DECLARE o_stat_ordered = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE result_stat_auth = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED "))
 DECLARE mf_normal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"NORMAL"))
 DECLARE class_type_radiology = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",53,"RADIOLOGY")
  )
 DECLARE class_type_doc = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE operativereport = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"OPERATIVEREPORT"
   ))
 DECLARE ord_act_asmt = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ASMTTXMONITORING")
  )
 DECLARE ord_act_comm = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "COMMUNICATIONORDERS"))
 DECLARE ord_act_io = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"INTAKEANDOUTPUT"))
 DECLARE ord_act_wound = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"WOUNDCARE"))
 DECLARE ord_act_ivas = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INVASIVELINESTUBESDRAINS"))
 DECLARE ord_act_iso = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ISOLATION"))
 DECLARE ord_act_pharm = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE ord_act_resptx = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RTTXPROCEDURES")
  )
 DECLARE ord_act_genlab = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE ord_act_rad = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY"))
 DECLARE ord_act_isolation = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ISOLATION"))
 DECLARE ocfcomp = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP")), protect
 DECLARE blob_out_rad = vc WITH noconstant(" ")
 DECLARE blob_out2 = vc WITH noconstant(" ")
 DECLARE blob_out3 = vc WITH noconstant(" ")
 DECLARE day_ord = vc WITH public
 SELECT INTO "NL:"
  e_active_status_disp = uar_get_code_display(e.active_status_cd), e.encntr_id, e_encntr_type_disp =
  uar_get_code_display(e.encntr_type_cd),
  e_loc_facility_disp = uar_get_code_display(e.loc_facility_cd), e_loc_nurse_unit_disp =
  uar_get_code_display(e.loc_nurse_unit_cd), e_loc_room_disp = uar_get_code_display(e.loc_room_cd),
  e_loc_temp_disp = uar_get_code_display(e.loc_temp_cd), ea_encntr_alias_type_disp =
  uar_get_code_display(ea.encntr_alias_type_cd), ea.encntr_alias_type_cd,
  per.name_full_formatted
  FROM encounter e,
   encntr_alias ea,
   person per
  PLAN (e
   WHERE (e.encntr_id= $PAT_ENCOUNTER))
   JOIN (per
   WHERE per.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1077)
  HEAD e.encntr_id
   insurance_review->person_id = e.person_id, insurance_review->admit_date = format(e.reg_dt_tm,
    "mm/dd/yy hh:mm;;d"), insurance_review->reason_for_visit = trim(e.reason_for_visit,3),
   insurance_review->dob = format(per.birth_dt_tm,"mm/dd/yy;;d"), insurance_review->patient_type =
   e_encntr_type_disp, insurance_review->accout_no = ea.alias,
   insurance_review->encntr_id = e.encntr_id, insurance_review->patient_name = per
   .name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e_loc_facility_disp = uar_get_code_display(elh.loc_facility_cd), e_loc_nurse_unit_disp =
  uar_get_code_display(elh.loc_nurse_unit_cd)
  FROM encntr_loc_hist elh
  PLAN (elh
   WHERE (elh.encntr_id=insurance_review->encntr_id))
  ORDER BY elh.end_effective_dt_tm DESC, elh.loc_facility_cd, elh.loc_nurse_unit_cd
  HEAD REPORT
   CALL echo(build("e_loc_nurse_unit_disp = ",e_loc_nurse_unit_disp))
  HEAD elh.loc_facility_cd
   null
  HEAD elh.loc_nurse_unit_cd
   IF ((insurance_review->locations > ""))
    insurance_review->locations = concat(insurance_review->locations,", ",trim(e_loc_facility_disp,3),
     "-",trim(e_loc_nurse_unit_disp,3))
   ELSE
    insurance_review->locations = concat(trim(e_loc_facility_disp,3),"-",trim(e_loc_nurse_unit_disp,3
      ))
   ENDIF
  FOOT  elh.loc_nurse_unit_cd
   null
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  ord_activity_type_disp = uar_get_code_display(ord.activity_type_cd), ord_catalog_disp =
  uar_get_code_display(ord.catalog_cd), ord_catalog_type_disp = uar_get_code_display(ord
   .catalog_type_cd),
  ord_dcp_clin_cat_disp = uar_get_code_display(ord.dcp_clin_cat_cd), day_ord = format(ord
   .orig_order_dt_tm,"yyyymmdd;;d"), ord.clinical_display_line,
  ord.simplified_display_line, ord_order_status_disp = uar_get_code_display(ord.order_status_cd),
  sort_clin_cat =
  IF (ord.dcp_clin_cat_cd=clin_cat_nutri_serv) 1
  ELSEIF (ord.dcp_clin_cat_cd IN (clin_cat_cond, clin_cat_mdtorn)) 2
  ELSEIF (ord.dcp_clin_cat_cd=clin_cat_cardpul) 3
  ELSEIF (ord.dcp_clin_cat_cd IN (clin_cat_meds, clin_cat_iv)) 4
  ELSE 7
  ENDIF
  ,
  sort_ord_act =
  IF (ord.activity_type_cd=ord_act_io) 1
  ELSEIF (ord.activity_type_cd=ord_act_asmt) 2
  ELSEIF (ord.activity_type_cd=ord_act_wound) 3
  ELSEIF (ord.activity_type_cd=ord_act_iso) 4
  ELSEIF (ord.activity_type_cd=ord_act_comm) 5
  ELSEIF (ord.activity_type_cd=ord_act_ivas) 7
  ELSE 7
  ENDIF
  , sort_time_view =
  IF (ord.freq_type_flag=5
   AND ord.activity_type_cd=705
   AND ord.iv_ind=0) 1
  ELSEIF (((ord.freq_type_flag=1) OR (ord.freq_type_flag=4))
   AND ord.activity_type_cd=705) 2
  ELSEIF (ord.freq_type_flag=3
   AND ord.activity_type_cd=705
   AND ord.prn_ind=1) 3
  ELSEIF (((ord.freq_type_flag=0) OR (ord.freq_type_flag=5))
   AND ord.activity_type_cd=705
   AND ord.iv_ind=1) 5
  ELSE 6
  ENDIF
  FROM (dummyt d1  WITH seq = value(size(insurance_review->dates,5))),
   orders ord
  PLAN (d1)
   JOIN (ord
   WHERE (ord.encntr_id=insurance_review->encntr_id)
    AND ((ord.dcp_clin_cat_cd IN (clin_cat_nutri_serv, clin_cat_iv, clin_cat_meds, clin_cat_cond,
   clin_cat_cardpul)) OR (ord.dcp_clin_cat_cd=clin_cat_mdtorn
    AND ord.activity_type_cd IN (ord_act_asmt, ord_act_comm, ord_act_io, ord_act_wound, ord_act_ivas,
   ord_act_iso)))
    AND ord.template_order_flag <= 1
    AND (format(ord.orig_order_dt_tm,"yyyymmdd;;d")=insurance_review->dates[d1.seq].day)
    AND (ord.person_id=insurance_review->person_id))
  ORDER BY d1.seq, sort_clin_cat, sort_ord_act,
   sort_time_view
  HEAD d1.seq
   insurance_review->dates[d1.seq].ord_day = day_ord, ord_cnt = 0, stat = alterlist(insurance_review
    ->dates[d1.seq].order_day,10)
  DETAIL
   IF (ord.order_status_cd=2550
    AND ord.dcp_clin_cat_cd=clin_cat_nutri_serv)
    ord_cnt = (ord_cnt+ 1)
    IF (ord_cnt >= size(insurance_review->dates[d1.seq].order_day))
     CALL echo(build("RESIZE 1 from >",size(insurance_review->dates[d1.seq].order_day))), stat =
     alterlist(insurance_review->dates[d1.seq].order_day,(ord_cnt+ 10))
    ENDIF
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_cat = "Nutricians Services",
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_cat_cd = ord.dcp_clin_cat_cd,
    insurance_review->dates[d1.seq].order_day[ord_cnt].order_date = format(ord.orig_order_dt_tm,
     "@SHORTDATETIME"),
    insurance_review->dates[d1.seq].order_day[ord_cnt].order_id = ord.order_id, insurance_review->
    dates[d1.seq].order_day[ord_cnt].order_name =
    IF (trim(ord.ordered_as_mnemonic,3) > " ") trim(ord.ordered_as_mnemonic,3)
    ELSE trim(ord.hna_order_mnemonic,3)
    ENDIF
    , insurance_review->dates[d1.seq].order_day[ord_cnt].clin_display = trim(ord
     .clinical_display_line),
    insurance_review->dates[d1.seq].order_day[ord_cnt].stop_date = format(ord.projected_stop_dt_tm,
     "mm/dd/yy;;d"), insurance_review->dates[d1.seq].order_day[ord_cnt].sort1 = sort_clin_cat,
    insurance_review->dates[d1.seq].order_day[ord_cnt].sort2 = 0,
    insurance_review->dates[d1.seq].order_day[ord_cnt].sort3 = 0
   ELSEIF (ord.dcp_clin_cat_cd=clin_cat_mdtorn
    AND ord.activity_type_cd IN (ord_act_asmt, ord_act_comm, ord_act_io, ord_act_wound, ord_act_ivas,
   ord_act_iso))
    ord_cnt = (ord_cnt+ 1)
    IF (ord_cnt >= size(insurance_review->dates[d1.seq].order_day))
     CALL echo(build("RESIZE 2 from >",size(insurance_review->dates[d1.seq].order_day))), stat =
     alterlist(insurance_review->dates[d1.seq].order_day,(ord_cnt+ 10))
    ENDIF
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_cat_cd = ord.dcp_clin_cat_cd,
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_cat = "MD to RN", insurance_review->
    dates[d1.seq].order_day[ord_cnt].order_id = ord.order_id,
    insurance_review->dates[d1.seq].order_day[ord_cnt].order_date = format(ord.orig_order_dt_tm,
     "@SHORTDATETIME"), insurance_review->dates[d1.seq].order_day[ord_cnt].order_name =
    IF (trim(ord.ordered_as_mnemonic,3) > " ") trim(ord.ordered_as_mnemonic,3)
    ELSE trim(ord.hna_order_mnemonic,3)
    ENDIF
    , insurance_review->dates[d1.seq].order_day[ord_cnt].clin_display = trim(ord
     .clinical_display_line),
    insurance_review->dates[d1.seq].order_day[ord_cnt].stop_date = format(ord.projected_stop_dt_tm,
     "mm/dd/yy;;d"), insurance_review->dates[d1.seq].order_day[ord_cnt].sort1 = sort_clin_cat,
    insurance_review->dates[d1.seq].order_day[ord_cnt].sort2 = sort_ord_act,
    insurance_review->dates[d1.seq].order_day[ord_cnt].sort3 = 0
   ELSEIF (ord.dcp_clin_cat_cd=clin_cat_cardpul
    AND ord.activity_type_cd=ord_act_resptx
    AND ord.order_status_cd=o_stat_ordered)
    ord_cnt = (ord_cnt+ 1)
    IF (ord_cnt >= size(insurance_review->dates[d1.seq].order_day))
     CALL echo(build("RESIZE 3 from >",size(insurance_review->dates[d1.seq].order_day))), stat =
     alterlist(insurance_review->dates[d1.seq].order_day,(ord_cnt+ 10))
    ENDIF
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_cat = "Respiratory Therapy",
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_cat_cd = ord.dcp_clin_cat_cd,
    insurance_review->dates[d1.seq].order_day[ord_cnt].order_id = ord.order_id,
    insurance_review->dates[d1.seq].order_day[ord_cnt].order_date = format(ord.orig_order_dt_tm,
     "@SHORTDATETIME"), insurance_review->dates[d1.seq].order_day[ord_cnt].order_name =
    IF (trim(ord.ordered_as_mnemonic,3) > " ") trim(ord.ordered_as_mnemonic,3)
    ELSE trim(ord.hna_order_mnemonic,3)
    ENDIF
    , insurance_review->dates[d1.seq].order_day[ord_cnt].clin_display = trim(ord
     .clinical_display_line),
    insurance_review->dates[d1.seq].order_day[ord_cnt].stop_date = format(ord.projected_stop_dt_tm,
     "mm/dd/yy;;d"), insurance_review->dates[d1.seq].order_day[ord_cnt].sort1 = sort_clin_cat,
    insurance_review->dates[d1.seq].order_day[ord_cnt].sort2 = 0,
    insurance_review->dates[d1.seq].order_day[ord_cnt].sort3 = 0
   ELSEIF (ord.dcp_clin_cat_cd=clin_cat_meds)
    ord_cnt = (ord_cnt+ 1)
    IF (ord_cnt >= size(insurance_review->dates[d1.seq].order_day))
     CALL echo(build("RESIZE  4 from >",size(insurance_review->dates[d1.seq].order_day))), stat =
     alterlist(insurance_review->dates[d1.seq].order_day,(ord_cnt+ 10))
    ENDIF
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_cat = "Medications", insurance_review->
    dates[d1.seq].order_day[ord_cnt].sort3 = sort_time_view
    IF (sort_time_view=1)
     insurance_review->dates[d1.seq].order_day[ord_cnt].time_view = "unscheduled"
    ELSEIF (sort_time_view=2)
     insurance_review->dates[d1.seq].order_day[ord_cnt].time_view = "scheduled"
    ELSEIF (sort_time_view=3)
     insurance_review->dates[d1.seq].order_day[ord_cnt].time_view = "prn"
    ELSEIF (sort_time_view=5)
     insurance_review->dates[d1.seq].order_day[ord_cnt].time_view = "cont_iv"
    ELSEIF (sort_time_view=6)
     insurance_review->dates[d1.seq].order_day[ord_cnt].time_view = "misc"
    ENDIF
    insurance_review->dates[d1.seq].order_day[ord_cnt].order_id = ord.order_id, insurance_review->
    dates[d1.seq].order_day[ord_cnt].order_date = format(ord.orig_order_dt_tm,"@SHORTDATETIME"),
    insurance_review->dates[d1.seq].order_day[ord_cnt].order_name =
    IF (trim(ord.ordered_as_mnemonic,3) > " ") trim(ord.ordered_as_mnemonic,3)
    ELSE trim(ord.hna_order_mnemonic,3)
    ENDIF
    ,
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_display = trim(ord.clinical_display_line),
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_cat_cd = ord.dcp_clin_cat_cd,
    insurance_review->dates[d1.seq].order_day[ord_cnt].stop_date = format(ord.projected_stop_dt_tm,
     "mm/dd/yy;;d"),
    insurance_review->dates[d1.seq].order_day[ord_cnt].sort1 = sort_clin_cat, insurance_review->
    dates[d1.seq].order_day[ord_cnt].sort2 = 0
   ELSEIF (ord.dcp_clin_cat_cd=clin_cat_cond
    AND ord.activity_type_cd=ord_act_isolation)
    ord_cnt = (ord_cnt+ 1)
    IF (ord_cnt >= size(insurance_review->dates[d1.seq].order_day))
     CALL echo(build("RESIZE 5 from >",size(insurance_review->dates[d1.seq].order_day))), stat =
     alterlist(insurance_review->dates[d1.seq].order_day,(ord_cnt+ 10))
    ENDIF
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_cat = "Condition and Isolation",
    insurance_review->dates[d1.seq].order_day[ord_cnt].clin_cat_cd = ord.dcp_clin_cat_cd,
    insurance_review->dates[d1.seq].order_day[ord_cnt].order_id = ord.order_id,
    insurance_review->dates[d1.seq].order_day[ord_cnt].order_date = format(ord.orig_order_dt_tm,
     "@SHORTDATETIME"), insurance_review->dates[d1.seq].order_day[ord_cnt].order_name =
    IF (trim(ord.ordered_as_mnemonic,3) > " ") trim(ord.ordered_as_mnemonic,3)
    ELSE trim(ord.hna_order_mnemonic,3)
    ENDIF
    , insurance_review->dates[d1.seq].order_day[ord_cnt].clin_display = trim(ord
     .clinical_display_line,3),
    insurance_review->dates[d1.seq].order_day[ord_cnt].stop_date = format(ord.projected_stop_dt_tm,
     "mm/dd/yy;;d"), insurance_review->dates[d1.seq].order_day[ord_cnt].order_status = trim(
     uar_get_code_display(ord.order_status_cd)), insurance_review->dates[d1.seq].order_day[ord_cnt].
    order_status_date = format(ord.status_dt_tm,"mm/dd/yy hh:mm;;d"),
    insurance_review->dates[d1.seq].order_day[ord_cnt].sort1 = sort_clin_cat, insurance_review->
    dates[d1.seq].order_day[ord_cnt].sort2 = 0, insurance_review->dates[d1.seq].order_day[ord_cnt].
    sort3 = 0
   ENDIF
   CALL echo(build("ord_cnt end =>>",ord_cnt))
  FOOT  d1.seq
   stat = alterlist(insurance_review->dates[d1.seq].order_day,ord_cnt), insurance_review->dates[d1
   .seq].cnt_ord_for_day = ord_cnt, insurance_review->dates[d1.seq].cnt_day_item = (insurance_review
   ->dates[d1.seq].cnt_day_item+ 1),
   CALL echo(build("ord_cnt=>>",ord_cnt))
  WITH nocounter
 ;end select
 CALL echo("*******************************Get LABS RESULTS START*********************************")
 SELECT INTO "NL:"
  lab_result_day = format(ce.event_end_dt_tm,"yyyymmdd;;d")
  FROM (dummyt d1  WITH seq = value(size(insurance_review->dates,5))),
   clinical_event ce,
   code_value cv1,
   code_value cv2,
   v500_event_set_explode ese
  PLAN (d1)
   JOIN (ese
   WHERE ese.event_set_cd=laboratory)
   JOIN (ce
   WHERE (ce.encntr_id=insurance_review->encntr_id)
    AND ce.event_cd=ese.event_cd
    AND ce.view_level=1
    AND ce.normalcy_cd != mf_normal_cd
    AND (ce.person_id=insurance_review->person_id)
    AND (insurance_review->dates[d1.seq].day=format(ce.event_end_dt_tm,"yyyymmdd;;d")))
   JOIN (cv1
   WHERE cv1.code_value=ce.event_cd)
   JOIN (cv2
   WHERE cv2.code_value=ce.result_units_cd)
  ORDER BY d1.seq, lab_result_day
  HEAD d1.seq
   cnt_labs = 0, pn_result_cnt = 0, insurance_review->dates[d1.seq].day_lab = lab_result_day
  DETAIL
   pn_result_cnt = (pn_result_cnt+ 1)
   IF (pn_result_cnt > size(insurance_review->dates[d1.seq].lab_results,5))
    stat = alterlist(insurance_review->dates[d1.seq].lab_results,(pn_result_cnt+ 10))
   ENDIF
   insurance_review->dates[d1.seq].lab_results[pn_result_cnt].s_display = trim(cv1.display),
   insurance_review->dates[d1.seq].lab_results[pn_result_cnt].s_value = concat(trim(ce.result_val),
    " ",trim(cv2.display)," ",trim(uar_get_code_display(ce.normalcy_cd))), insurance_review->dates[d1
   .seq].lab_results[pn_result_cnt].s_date = format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
  FOOT  d1.seq
   stat = alterlist(insurance_review->dates[d1.seq].lab_results,pn_result_cnt), insurance_review->
   dates[d1.seq].lab_result_cnt = pn_result_cnt, insurance_review->dates[d1.seq].cnt_day_item = (
   insurance_review->dates[d1.seq].cnt_day_item+ 1)
  WITH nocounter
 ;end select
 CALL echo("*************************Get LABS RESULTS END*************************************")
 CALL echo("***************************get rad results start**************************************")
 SELECT INTO "nl:"
  rad_result_day = format(ce1.event_end_dt_tm,"yyyymmdd;;d")
  FROM (dummyt d1  WITH seq = value(size(insurance_review->dates,5))),
   clinical_event ce,
   clinical_event ce1,
   ce_blob cb,
   code_value cv
  PLAN (d1)
   JOIN (cv
   WHERE cv.display_key="RADRPT"
    AND cv.data_status_cd=25
    AND cv.code_set=72)
   JOIN (ce
   WHERE (ce.encntr_id=insurance_review->encntr_id)
    AND ce.event_cd=cv.code_value
    AND ce.authentic_flag=1)
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.authentic_flag=1
    AND ce1.event_class_cd=class_type_doc
    AND (insurance_review->dates[d1.seq].day=format(ce.event_end_dt_tm,"yyyymmdd;;d")))
   JOIN (cb
   WHERE ce1.event_id=cb.event_id)
  ORDER BY d1.seq, ce1.event_id
  HEAD d1.seq
   day_cnt_rad_res = 0, rad_result_cnt = 0
  DETAIL
   insurance_review->dates[d1.seq].day_rad = format(ce1.event_end_dt_tm,"yyyymmdd;;d"),
   rad_result_cnt = (rad_result_cnt+ 1)
   IF (rad_result_cnt > size(insurance_review->dates[d1.seq].rad_results,5))
    stat = alterlist(insurance_review->dates[d1.seq].rad_results,(rad_result_cnt+ 10))
   ENDIF
   insurance_review->dates[d1.seq].rad_results[rad_result_cnt].s_ce_event = ce1.event_id,
   insurance_review->dates[d1.seq].rad_results[rad_result_cnt].accession_num = ce1.accession_nbr
   IF (cb.compression_cd=ocfcomp)
    blob_compressed_trimmed = fillstring(64000," "), blob_uncompressed_rad = fillstring(64000," "),
    blob_return_len = 0,
    blob_out_rad = fillstring(64000," "), blob_compressed_trimmed = cb.blob_contents,
    CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),
    blob_uncompressed_rad,size(blob_uncompressed_rad),blob_return_len),
    blob_out_rad = replace(blob_uncompressed_rad,"ocf_blob","",0), insurance_review->dates[d1.seq].
    rad_results[rad_result_cnt].blob_result = blob_out_rad
   ELSE
    blob_out_rad = blob_compressed_trimmed, insurance_review->dates[d1.seq].rad_results[
    rad_result_cnt].blob_result = blob_out_rad
   ENDIF
  FOOT  d1.seq
   stat = alterlist(insurance_review->dates[d1.seq].rad_results,rad_result_cnt), insurance_review->
   dates[d1.seq].cnt_day_item = (insurance_review->dates[d1.seq].cnt_day_item+ 1), insurance_review->
   dates[d1.seq].rad_result_cnt = rad_result_cnt
  WITH nocounter
 ;end select
 CALL echo("get red results end")
 CALL echo("****************;get vital 2 start **********************************")
 DECLARE abileft_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABILEFT")), protect
 DECLARE abiright_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABIRIGHT")), protect
 SET tempc = uar_get_code_by("displaykey",72,"TEMPERATURE")
 SET o2_sat = uar_get_code_by("displaykey",72,"OXYGENSATURATION")
 SET pulse = uar_get_code_by("displaykey",72,"PULSERATE")
 SET rr = uar_get_code_by("displaykey",72,"RESPIRATORYRATE")
 SET sbp = uar_get_code_by("displaykey",72,"SYSTOLICBLOODPRESSURE")
 SET dbp = uar_get_code_by("displaykey",72,"DIASTOLICBLOODPRESSURE")
 SET fb = uar_get_code_by("description",93,"IO")
 SET intake_cd = uar_get_code_by("displaykey",93,"INTAKE")
 SET output_cd = uar_get_code_by("displaykey",93,"OUTPUT")
 SELECT INTO "nl:"
  vital_day = format(ce.event_end_dt_tm,"yyyymmdd;;d"), temp2 = format(ce.event_end_dt_tm,
   "mm/dd/yyyy hh:mm;;d"), ce_normalcy_disp = uar_get_code_display(ce.normalcy_cd),
  ce.valid_from_dt_tm
  FROM (dummyt d1  WITH seq = value(size(insurance_review->dates,5))),
   clinical_event ce
  PLAN (d1)
   JOIN (ce
   WHERE (ce.encntr_id=insurance_review->encntr_id)
    AND ((ce.event_cd+ 0) IN (tempc, o2_sat, pulse, rr, sbp,
   dbp))
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > sysdate
    AND ce.normalcy_cd != mf_normal_cd
    AND (insurance_review->dates[d1.seq].day=format(ce.event_end_dt_tm,"yyyymmdd;;d")))
  ORDER BY d1.seq, ce.event_cd, ce.valid_from_dt_tm DESC
  HEAD d1.seq
   temp = fillstring(500,""), vital_cnt = 0, prev = "XXXXXX",
   num_col = 0
  DETAIL
   vital_cnt = (vital_cnt+ 1)
   IF (trim(prev) != trim(ce.event_title_text))
    prev = trim(ce.event_tag), num_col = (num_col+ 1)
   ENDIF
   IF (vital_cnt > size(insurance_review->dates[d1.seq].vitals_hi_lo_crit,5))
    stat = alterlist(insurance_review->dates[d1.seq].vitals_hi_lo_crit,(vital_cnt+ 10))
   ENDIF
   insurance_review->dates[d1.seq].vitals_hi_lo_crit[vital_cnt].vital_res = concat(trim(ce.event_tag),
    " ",trim(ce_normalcy_disp)), insurance_review->dates[d1.seq].vitals_hi_lo_crit[vital_cnt].
   vitals_tag = concat(temp2," - ",trim(ce.event_title_text)), insurance_review->dates[d1.seq].
   vitals_hi_lo_crit[vital_cnt].vital_col = num_col
  FOOT  d1.seq
   stat = alterlist(insurance_review->dates[d1.seq].vitals_hi_lo_crit,vital_cnt), insurance_review->
   dates[d1.seq].vital_cnt = vital_cnt, insurance_review->dates[d1.seq].cnt_day_item = (
   insurance_review->dates[d1.seq].cnt_day_item+ 1)
  WITH nocounter
 ;end select
 CALL echo("****************;get vital 2 end **********************************")
 CALL echo("****************;get io start **********************************")
 SELECT INTO "nl:"
  io_day = format(ce.event_end_dt_tm,"yyyymmdd;;d")
  FROM (dummyt d1  WITH seq = value(size(insurance_review->dates,5))),
   v500_event_set_canon es,
   v500_event_set_explode ese,
   clinical_event ce
  PLAN (d1)
   JOIN (es
   WHERE es.parent_event_set_cd=fb)
   JOIN (ese
   WHERE ese.event_set_cd=es.event_set_cd)
   JOIN (ce
   WHERE ce.event_cd=ese.event_cd
    AND ce.view_level=1
    AND (ce.encntr_id=insurance_review->encntr_id)
    AND (insurance_review->dates[d1.seq].day=format(ce.event_end_dt_tm,"yyyymmdd;;d")))
  ORDER BY d1.seq
  HEAD d1.seq
   24_intake_val = 0.0, 24_output_val = 0.0, 24_balance = 0.0,
   io_day_cnt = (io_day_cnt+ 1), insurance_review->dates[d1.seq].io_day = io_day
  DETAIL
   num = cnvtreal(ce.result_val)
   IF (es.event_set_cd=intake_cd)
    insurance_review->dates[d1.seq].in_24_tot = (insurance_review->dates[d1.seq].in_24_tot+ num)
   ELSEIF (es.event_set_cd=output_cd)
    insurance_review->dates[d1.seq].out_24_tot = (insurance_review->dates[d1.seq].out_24_tot+ num)
   ENDIF
  FOOT  d1.seq
   insurance_review->dates[d1.seq].io_bal_24 = (insurance_review->dates[d1.seq].in_24_tot -
   insurance_review->dates[d1.seq].out_24_tot), insurance_review->dates[d1.seq].cnt_io = io_day_cnt,
   insurance_review->dates[d1.seq].cnt_day_item = (insurance_review->dates[d1.seq].cnt_day_item+ 1)
  WITH nocounter
 ;end select
 CALL echo("********** get operative report *****************")
 SELECT INTO "nl:"
  op_rpt_day = format(ce.event_end_dt_tm,"yyyymmdd;;d")
  FROM (dummyt d1  WITH seq = value(size(insurance_review->dates,5))),
   clinical_event ce,
   ce_blob cb
  PLAN (d1)
   JOIN (ce
   WHERE (ce.encntr_id=insurance_review->encntr_id)
    AND ce.event_class_cd=class_type_doc
    AND ce.event_cd=operativereport
    AND (insurance_review->dates[d1.seq].day=format(ce.event_end_dt_tm,"yyyymmdd;;d")))
   JOIN (cb
   WHERE ce.event_id=cb.event_id)
  ORDER BY d1.seq, ce.event_id
  HEAD d1.seq
   op_rpt_cnt = 0, insurance_review->dates[d1.seq].op_rpt_day = op_rpt_day
  DETAIL
   op_rpt_cnt = (op_rpt_cnt+ 1)
   IF (op_rpt_cnt > size(insurance_review->dates[d1.seq].op_report,5))
    stat = alterlist(insurance_review->dates[d1.seq].op_report,(op_rpt_cnt+ 10))
   ENDIF
   insurance_review->dates[d1.seq].op_report[op_rpt_cnt].s_ce_event = ce.event_id
   IF (cb.compression_cd=ocfcomp)
    blob_compressed_trimmed = fillstring(64000," "), blob_uncompressed_rad = fillstring(64000," "),
    blob_return_len = 0,
    blob_out_rad = fillstring(64000," "), blob_compressed_trimmed = cb.blob_contents,
    CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),
    blob_uncompressed_rad,size(blob_uncompressed_rad),blob_return_len),
    blob_out_rad = replace(blob_uncompressed_rad,"ocf_blob","",0), insurance_review->dates[d1.seq].
    op_report[op_rpt_cnt].blob_result = blob_out_rad
   ELSE
    blob_out_rad = blob_compressed_trimmed, insurance_review->dates[d1.seq].op_report[op_rpt_cnt].
    blob_result = blob_out_rad
   ENDIF
  FOOT  d1.seq
   stat = alterlist(insurance_review->dates[d1.seq].op_report,op_rpt_cnt), insurance_review->dates[d1
   .seq].op_rpt_cnt = op_rpt_cnt, insurance_review->dates[d1.seq].cnt_day_item = (insurance_review->
   dates[d1.seq].cnt_day_item+ 1)
  WITH nocounter
 ;end select
 CALL echo("********** get operative report END *****************")
 CALL echorecord(insurance_review)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE _creatertf(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE case_mgmt_ins_header(ncalc=i2) = f8 WITH protect
 DECLARE case_mgmt_ins_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesection(ncalc=i2) = f8 WITH protect
 DECLARE headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE date_header(ncalc=i2) = f8 WITH protect
 DECLARE date_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE order_header(ncalc=i2) = f8 WITH protect
 DECLARE order_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderssection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE orderssectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE line_sep(ncalc=i2) = f8 WITH protect
 DECLARE line_sepabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE rad_header(ncalc=i2) = f8 WITH protect
 DECLARE rad_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE rad_section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE rad_sectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE vitals_header(ncalc=i2) = f8 WITH protect
 DECLARE vitals_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE vitals_section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE vitals_sectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE labs_header(ncalc=i2) = f8 WITH protect
 DECLARE labs_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE labs_section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE labs_sectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE operative_header(ncalc=i2) = f8 WITH protect
 DECLARE operative_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE operative_section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE operative_sectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE ioheader(ncalc=i2) = f8 WITH protect
 DECLARE ioheaderabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE page_foot(ncalc=i2) = f8 WITH protect
 DECLARE page_footabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _remorder_name = i2 WITH noconstant(1), protect
 DECLARE _remclin_display = i2 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontorderssection = i2 WITH noconstant(0), protect
 DECLARE _remrad_result = i2 WITH noconstant(1), protect
 DECLARE _bcontrad_section = i2 WITH noconstant(0), protect
 DECLARE _hrtf_rad_result = i4 WITH noconstant(0), protect
 DECLARE _remvitals_tag = i2 WITH noconstant(1), protect
 DECLARE _remvitals_res = i2 WITH noconstant(1), protect
 DECLARE _bcontvitals_section = i2 WITH noconstant(0), protect
 DECLARE _remlab_dt_tm = i2 WITH noconstant(1), protect
 DECLARE _remlab_name = i2 WITH noconstant(1), protect
 DECLARE _remlab_result = i2 WITH noconstant(1), protect
 DECLARE _bcontlabs_section = i2 WITH noconstant(0), protect
 DECLARE _remoperative_rpt = i2 WITH noconstant(1), protect
 DECLARE _bcontoperative_section = i2 WITH noconstant(0), protect
 DECLARE _hrtf_operative_rpt = i4 WITH noconstant(0), protect
 DECLARE _newcenturyschlbk100 = i4 WITH noconstant(0), protect
 DECLARE _times12bu0 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica120 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _newcenturyschlbk10u0 = i4 WITH noconstant(0), protect
 DECLARE _souvenir120 = i4 WITH noconstant(0), protect
 DECLARE _newcenturyschlbk12bi0 = i4 WITH noconstant(0), protect
 DECLARE _newcenturyschlbk120 = i4 WITH noconstant(0), protect
 DECLARE _avantgarde120 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE case_mgmt_ins_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = case_mgmt_ins_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE case_mgmt_ins_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.540000), private
   DECLARE __pat_name = vc WITH noconstant(build2(insurance_review->patient_name,char(0))), protect
   DECLARE __pat_type = vc WITH noconstant(build2(trim(insurance_review->patient_type,3),char(0))),
   protect
   DECLARE __admit_date = vc WITH noconstant(build2(trim(insurance_review->admit_date,3),char(0))),
   protect
   DECLARE __visit_reason = vc WITH noconstant(build2(insurance_review->reason_for_visit,char(0))),
   protect
   DECLARE __acct_num = vc WITH noconstant(build2(insurance_review->accout_no,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build2(trim(insurance_review->dob,3),char(0))), protect
   DECLARE __locations = vc WITH noconstant(build2(trim(insurance_review->locations,3),char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.906
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient  Name:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pat_name)
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.563)
    SET rptsd->m_width = 7.563
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times12bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Case Management Insurance Review Report",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Date:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Type:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 1.229
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pat_type)
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 1.510
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__admit_date)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.448
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location History:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 1.260
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__visit_reason)
    SET rptsd->m_flags = 512
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 7.250)
    SET rptsd->m_width = 1.021
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acct_num)
    SET rptsd->m_flags = 580
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Account Number/FIN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 1.479
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 4.688)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__locations)
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reasonfor Visit:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.375),(offsetx+ 9.938),(offsety+
     1.375))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagesection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE date_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = date_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE date_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __date = vc WITH noconstant(build2(format(insurance_review->dates[a_prt].day_dt,
      "MM/DD/YYYY;;d"),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__date)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_avantgarde120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.938)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_newcenturyschlbk120)
    IF (check_rres=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No Data available",char(0)))
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE order_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = order_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE order_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   DECLARE __current_cat = vc WITH noconstant(build2(insurance_review->dates[a_prt].order_day[b_prt].
     clin_cat,char(0))), protect
   IF ((insurance_review->dates[a_prt].order_day[b_prt].time_view > " "))
    DECLARE __timeview = vc WITH noconstant(build2(concat("(",trim(insurance_review->dates[a_prt].
        order_day[b_prt].time_view,3),")"),char(0))), protect
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.010)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.563
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_newcenturyschlbk12bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__current_cat)
    SET rptsd->m_y = (offsety+ 0.010)
    SET rptsd->m_x = (offsetx+ 2.563)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    IF ((insurance_review->dates[a_prt].order_day[b_prt].time_view > " "))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__timeview)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.010)
    SET rptsd->m_x = (offsetx+ 6.313)
    SET rptsd->m_width = 1.333
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_souvenir120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderssection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderssectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE orderssectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_order_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_clin_display = f8 WITH noconstant(0.0), private
   DECLARE __order_name = vc WITH noconstant(build2(trim(insurance_review->dates[a_prt].order_day[
      b_prt].order_name,3),char(0))), protect
   DECLARE __clin_display = vc WITH noconstant(build2(trim(order_day_clin_display,3),char(0))),
   protect
   IF (bcontinue=0)
    SET _remorder_name = 1
    SET _remclin_display = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremorder_name = _remorder_name
   IF (_remorder_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorder_name,((size(
        __order_name) - _remorder_name)+ 1),__order_name)))
    SET drawheight_order_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorder_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorder_name,((size(__order_name) -
       _remorder_name)+ 1),__order_name)))))
     SET _remorder_name = (_remorder_name+ rptsd->m_drawlength)
    ELSE
     SET _remorder_name = 0
    ENDIF
    SET growsum = (growsum+ _remorder_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 5.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremclin_display = _remclin_display
   IF (_remclin_display > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remclin_display,((size(
        __clin_display) - _remclin_display)+ 1),__clin_display)))
    SET drawheight_clin_display = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remclin_display = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remclin_display,((size(__clin_display) -
       _remclin_display)+ 1),__clin_display)))))
     SET _remclin_display = (_remclin_display+ rptsd->m_drawlength)
    ELSE
     SET _remclin_display = 0
    ENDIF
    SET growsum = (growsum+ _remclin_display)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = drawheight_order_name
   IF (ncalc=rpt_render
    AND _holdremorder_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorder_name,((size(
        __order_name) - _holdremorder_name)+ 1),__order_name)))
   ELSE
    SET _remorder_name = _holdremorder_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.188)
   SET rptsd->m_width = 5.063
   SET rptsd->m_height = drawheight_clin_display
   IF (ncalc=rpt_render
    AND _holdremclin_display > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremclin_display,((
       size(__clin_display) - _holdremclin_display)+ 1),__clin_display)))
   ELSE
    SET _remclin_display = _holdremclin_display
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE line_sep(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = line_sepabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE line_sepabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.063),(offsetx+ 9.938),(offsety+
     0.063))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE rad_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = rad_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE rad_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 292
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_newcenturyschlbk12bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Radiology Results",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.052)
    SET rptsd->m_x = (offsetx+ 6.313)
    SET rptsd->m_width = 1.427
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_souvenir120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE rad_section(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = rad_sectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE rad_sectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_rad_result = f8 WITH noconstant(0.0), private
   DECLARE __rad_result = vc WITH noconstant(build2(insurance_review->dates[a_prt].rad_results[c_prt]
     .blob_result,char(0))), protect
   IF (bcontinue=0)
    SET _remrad_result = 1
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _remrad_result > 0)
    IF (_hrtf_rad_result=0)
     SET _hrtf_rad_result = uar_rptcreatertf(_hreport,__rad_result,7.406)
    ENDIF
    SET _fdrawheight = maxheight
    SET _rptstat = uar_rptrtfdraw(_hreport,_hrtf_rad_result,(offsetx+ 0.063),(offsety+ 0.000),
     _fdrawheight)
    IF ((_fdrawheight > (sectionheight - 0.000)))
     SET sectionheight = (0.000+ _fdrawheight)
    ENDIF
    IF (_rptstat != rpt_continue)
     SET _rptstat = uar_rptdestroyrtf(_hreport,_hrtf_rad_result)
     SET _hrtf_rad_result = 0
     SET _remrad_result = 0
    ENDIF
   ENDIF
   SET growsum = (growsum+ _remrad_result)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE vitals_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = vitals_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE vitals_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 292
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_newcenturyschlbk12bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Vitals",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.313)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE vitals_section(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = vitals_sectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE vitals_sectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_vitals_tag = f8 WITH noconstant(0.0), private
   DECLARE drawheight_vitals_res = f8 WITH noconstant(0.0), private
   DECLARE __vitals_tag = vc WITH noconstant(build2(insurance_review->dates[a_prt].vitals_hi_lo_crit[
     e_prt].vitals_tag,char(0))), protect
   DECLARE __vitals_res = vc WITH noconstant(build2(insurance_review->dates[a_prt].vitals_hi_lo_crit[
     e_prt].vital_res,char(0))), protect
   IF (bcontinue=0)
    SET _remvitals_tag = 1
    SET _remvitals_res = 1
   ENDIF
   SET rptsd->m_flags = 37
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_newcenturyschlbk100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremvitals_tag = _remvitals_tag
   IF (_remvitals_tag > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remvitals_tag,((size(
        __vitals_tag) - _remvitals_tag)+ 1),__vitals_tag)))
    SET drawheight_vitals_tag = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remvitals_tag = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remvitals_tag,((size(__vitals_tag) -
       _remvitals_tag)+ 1),__vitals_tag)))))
     SET _remvitals_tag = (_remvitals_tag+ rptsd->m_drawlength)
    ELSE
     SET _remvitals_tag = 0
    ENDIF
    SET growsum = (growsum+ _remvitals_tag)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 2.135
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremvitals_res = _remvitals_res
   IF (_remvitals_res > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remvitals_res,((size(
        __vitals_res) - _remvitals_res)+ 1),__vitals_res)))
    SET drawheight_vitals_res = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remvitals_res = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remvitals_res,((size(__vitals_res) -
       _remvitals_res)+ 1),__vitals_res)))))
     SET _remvitals_res = (_remvitals_res+ rptsd->m_drawlength)
    ELSE
     SET _remvitals_res = 0
    ENDIF
    SET growsum = (growsum+ _remvitals_res)
   ENDIF
   SET rptsd->m_flags = 36
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = drawheight_vitals_tag
   IF (ncalc=rpt_render
    AND _holdremvitals_tag > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremvitals_tag,((size(
        __vitals_tag) - _holdremvitals_tag)+ 1),__vitals_tag)))
   ELSE
    SET _remvitals_tag = _holdremvitals_tag
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 2.135
   SET rptsd->m_height = drawheight_vitals_res
   IF (ncalc=rpt_render
    AND _holdremvitals_res > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremvitals_res,((size(
        __vitals_res) - _holdremvitals_res)+ 1),__vitals_res)))
   ELSE
    SET _remvitals_res = _holdremvitals_res
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE labs_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = labs_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE labs_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.302
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_newcenturyschlbk12bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Lab Results",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.010)
    SET rptsd->m_x = (offsetx+ 6.313)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE labs_section(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = labs_sectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE labs_sectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_lab_dt_tm = f8 WITH noconstant(0.0), private
   DECLARE drawheight_lab_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_lab_result = f8 WITH noconstant(0.0), private
   DECLARE __lab_dt_tm = vc WITH noconstant(build2(trim(insurance_review->dates[a_prt].lab_results[
      g_prt].s_date,3),char(0))), protect
   DECLARE __lab_name = vc WITH noconstant(build2(trim(insurance_review->dates[a_prt].lab_results[
      g_prt].s_display,3),char(0))), protect
   DECLARE __lab_result = vc WITH noconstant(build2(trim(insurance_review->dates[a_prt].lab_results[
      g_prt].s_value,3),char(0))), protect
   IF (bcontinue=0)
    SET _remlab_dt_tm = 1
    SET _remlab_name = 1
    SET _remlab_result = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_newcenturyschlbk100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlab_dt_tm = _remlab_dt_tm
   IF (_remlab_dt_tm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlab_dt_tm,((size(
        __lab_dt_tm) - _remlab_dt_tm)+ 1),__lab_dt_tm)))
    SET drawheight_lab_dt_tm = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlab_dt_tm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlab_dt_tm,((size(__lab_dt_tm) -
       _remlab_dt_tm)+ 1),__lab_dt_tm)))))
     SET _remlab_dt_tm = (_remlab_dt_tm+ rptsd->m_drawlength)
    ELSE
     SET _remlab_dt_tm = 0
    ENDIF
    SET growsum = (growsum+ _remlab_dt_tm)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.531
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlab_name = _remlab_name
   IF (_remlab_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlab_name,((size(
        __lab_name) - _remlab_name)+ 1),__lab_name)))
    SET drawheight_lab_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlab_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlab_name,((size(__lab_name) -
       _remlab_name)+ 1),__lab_name)))))
     SET _remlab_name = (_remlab_name+ rptsd->m_drawlength)
    ELSE
     SET _remlab_name = 0
    ENDIF
    SET growsum = (growsum+ _remlab_name)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.688)
   SET rptsd->m_width = 1.948
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlab_result = _remlab_result
   IF (_remlab_result > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlab_result,((size(
        __lab_result) - _remlab_result)+ 1),__lab_result)))
    SET drawheight_lab_result = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlab_result = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlab_result,((size(__lab_result) -
       _remlab_result)+ 1),__lab_result)))))
     SET _remlab_result = (_remlab_result+ rptsd->m_drawlength)
    ELSE
     SET _remlab_result = 0
    ENDIF
    SET growsum = (growsum+ _remlab_result)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = drawheight_lab_dt_tm
   IF (ncalc=rpt_render
    AND _holdremlab_dt_tm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlab_dt_tm,((size(
        __lab_dt_tm) - _holdremlab_dt_tm)+ 1),__lab_dt_tm)))
   ELSE
    SET _remlab_dt_tm = _holdremlab_dt_tm
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 1.531
   SET rptsd->m_height = drawheight_lab_name
   IF (ncalc=rpt_render
    AND _holdremlab_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlab_name,((size(
        __lab_name) - _holdremlab_name)+ 1),__lab_name)))
   ELSE
    SET _remlab_name = _holdremlab_name
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.688)
   SET rptsd->m_width = 1.948
   SET rptsd->m_height = drawheight_lab_result
   IF (ncalc=rpt_render
    AND _holdremlab_result > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlab_result,((size(
        __lab_result) - _holdremlab_result)+ 1),__lab_result)))
   ELSE
    SET _remlab_result = _holdremlab_result
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE operative_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = operative_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE operative_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 292
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.875
    SET rptsd->m_height = 0.281
    SET _oldfont = uar_rptsetfont(_hreport,_newcenturyschlbk12bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Operative Reports",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.094)
    SET rptsd->m_x = (offsetx+ 2.813)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_newcenturyschlbk100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE operative_section(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = operative_sectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE operative_sectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_operative_rpt = f8 WITH noconstant(0.0), private
   DECLARE __operative_rpt = vc WITH noconstant(build2(insurance_review->dates[a_prt].op_report[d_prt
     ].blob_result,char(0))), protect
   IF (bcontinue=0)
    SET _remoperative_rpt = 1
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _remoperative_rpt > 0)
    IF (_hrtf_operative_rpt=0)
     SET _hrtf_operative_rpt = uar_rptcreatertf(_hreport,__operative_rpt,7.375)
    ENDIF
    SET _fdrawheight = maxheight
    SET _rptstat = uar_rptrtfdraw(_hreport,_hrtf_operative_rpt,(offsetx+ 0.063),(offsety+ 0.031),
     _fdrawheight)
    IF ((_fdrawheight > (sectionheight - 0.031)))
     SET sectionheight = (0.031+ _fdrawheight)
    ENDIF
    IF (_rptstat != rpt_continue)
     SET _rptstat = uar_rptdestroyrtf(_hreport,_hrtf_operative_rpt)
     SET _hrtf_operative_rpt = 0
     SET _remoperative_rpt = 0
    ENDIF
   ENDIF
   SET growsum = (growsum+ _remoperative_rpt)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE ioheader(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ioheaderabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE ioheaderabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE __in_24_tot = vc WITH noconstant(build2(insurance_review->dates[a_prt].in_24_tot,char(0))),
   protect
   DECLARE __out_24_tot = vc WITH noconstant(build2(insurance_review->dates[a_prt].out_24_tot,char(0)
     )), protect
   DECLARE __io_bal_24 = vc WITH noconstant(build2(insurance_review->dates[a_prt].io_bal_24,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_newcenturyschlbk12bi0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("24 hr I/O",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_newcenturyschlbk100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__in_24_tot)
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 0.917
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__out_24_tot)
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__io_bal_24)
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_newcenturyschlbk10u0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Input Total",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.313)
    SET rptsd->m_width = 0.917
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Output Total",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.313)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Balance",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE page_foot(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE page_footabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 1024
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.260
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.156)
    SET rptsd->m_width = 0.719
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(b_prt,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.208)
    SET rptsd->m_width = 1.792
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tmp_work_room,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.635)
    SET rptsd->m_width = 2.302
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(test1,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_CASE_MGMT_INS"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_underline = rpt_on
   SET _times12bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_underline = rpt_off
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_avantgarde
   SET rptfont->m_bold = rpt_off
   SET _avantgarde120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_newcenturyschlbk
   SET _newcenturyschlbk120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_italic = rpt_on
   SET _newcenturyschlbk12bi0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET _helvetica120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_souvenir
   SET _souvenir120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 10
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_newcenturyschlbk
   SET _newcenturyschlbk100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_underline = rpt_on
   SET _newcenturyschlbk10u0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET d0 = case_mgmt_ins_header(rpt_render)
 SET cur_page = 0
 SET tmp_work_room = 0.00
 SET tmp_height = 0.00
 SET y_page_head = 0.26
 SET y_page_foot = 10.29
 SET page_foot_buffer = 0.26
 SET y_end_of_page = (y_page_foot - page_foot_buffer)
 FOR (a_prt = 1 TO size(insurance_review->dates,5))
   SET check_rres = insurance_review->dates[a_prt].cnt_day_item
   CALL echo(build("check_rres *********** ",check_rres))
   IF ((insurance_review->dates[a_prt].cnt_day_item > 0))
    SET prev_sort1 = 0
    SET prev_sort2 = 0
    SET prev_sort3 = 0
    SET test1 = "date head  1"
    SET d0 = date_header(rpt_render)
    SET test1 = ""
    SET d0 = line_sep(rpt_render)
    IF ((insurance_review->dates[a_prt].cnt_ord_for_day > 0))
     FOR (b_prt = 1 TO size(insurance_review->dates[a_prt].order_day,5))
       SET order_day_order_name = insurance_review->dates[a_prt].order_day[b_prt].order_name
       SET order_day_clin_display = insurance_review->dates[a_prt].order_day[b_prt].clin_display
       SET order_day_order_status_date = insurance_review->dates[a_prt].order_day[b_prt].
       order_status_date
       IF (b_prt=1)
        SET tmp_work_room = (y_end_of_page - _yoffset)
        IF (tmp_work_room < 0)
         SET cur_page = (cur_page+ 1)
         CALL echo(build("b_prt = ",b_prt))
         SET _yoffset = y_page_foot
         SET d0 = page_foot(rpt_render)
         SET test1 = "if 1"
         SET d0 = pagebreak(0)
         SET test1 = ""
         SET _yoffset = y_page_head
         SET tmp_work_room = (y_end_of_page - y_page_head)
        ENDIF
        SET test1 = "ord head 1"
        SET d0 = order_header(rpt_render)
        SET test1 = "111"
        SET d0 = line_sep(rpt_render)
        SET d0 = orderssection(rpt_render,tmp_work_room,becont)
        SET prev_sort1 = insurance_review->dates[a_prt].order_day[b_prt].sort1
        SET prev_sort2 = insurance_review->dates[a_prt].order_day[b_prt].sort2
        SET prev_sort3 = insurance_review->dates[a_prt].order_day[b_prt].sort3
        WHILE (becont=1)
          SET cur_page = (cur_page+ 1)
          SET _yoffset = y_page_foot
          SET test1 = "while 1"
          SET d0 = page_foot(rpt_render)
          SET test1 = " "
          SET d0 = pagebreak(0)
          SET _yoffset = y_page_head
          SET tmp_work_room = (y_end_of_page - _yoffset)
          IF (tmp_work_room < 0)
           SET cur_page = (cur_page+ 1)
           SET _yoffset = y_page_foot
           SET d0 = page_foot(rpt_render)
           SET d0 = pagebreak(0)
           SET _yoffset = y_page_head
           SET tmp_work_room = (y_end_of_page - y_page_head)
          ENDIF
          SET d0 = line_sep(rpt_render)
          SET d0 = orderssection(rpt_render,tmp_work_room,becont)
        ENDWHILE
       ELSEIF ((((prev_sort1 != insurance_review->dates[a_prt].order_day[b_prt].sort1)
        AND (insurance_review->dates[a_prt].order_day[b_prt].sort3=0)) OR ((((prev_sort1=
       insurance_review->dates[a_prt].order_day[b_prt].sort1)
        AND (prev_sort3 != insurance_review->dates[a_prt].order_day[b_prt].sort3)
        AND (insurance_review->dates[a_prt].order_day[b_prt].sort3 > 0)) OR ((prev_sort1 !=
       insurance_review->dates[a_prt].order_day[b_prt].sort1)
        AND (prev_sort3 != insurance_review->dates[a_prt].order_day[b_prt].sort3)
        AND (insurance_review->dates[a_prt].order_day[b_prt].sort3 > 0))) )) )
        SET room_needed = (order_header(rpt_calcheight)+ line_sep(rpt_calcheight))
        SET tmp_work_room = ((y_end_of_page - _yoffset) - room_needed)
        IF (tmp_work_room < 0)
         SET cur_page = (cur_page+ 1)
         SET _yoffset = y_page_foot
         SET d0 = page_foot(rpt_render)
         SET d0 = pagebreak(0)
         SET d0 = line_sep(rpt_render)
         SET continued = "continued"
         SET d0 = date_header(rpt_render)
         SET d0 = order_header(rpt_render)
         SET _yoffset = y_page_head
         SET continued = ""
         SET tmp_work_room = (y_end_of_page - _yoffset)
        ELSE
         SET d0 = line_sep(rpt_render)
         SET d0 = order_header(rpt_render)
         SET d0 = orderssection(rpt_render,tmp_work_room,becont)
        ENDIF
        WHILE (becont=1)
          SET cur_page = (cur_page+ 1)
          SET _yoffset = y_page_foot
          SET d0 = page_foot(rpt_render)
          SET d0 = pagebreak(0)
          SET _yoffset = y_page_head
          SET continued = "continued"
          SET d0 = date_header(rpt_render)
          SET d0 = order_header(rpt_render)
          SET _yoffset = y_page_head
          SET continued = ""
          SET tmp_work_room = ((y_end_of_page - _yoffset) - room_needed)
          IF (tmp_work_room < 0)
           SET cur_page = (cur_page+ 1)
           SET _yoffset = y_page_foot
           SET d0 = page_foot(rpt_render)
           SET d0 = pagebreak(0)
           SET _yoffset = y_page_head
           SET continued = "continued"
           SET d0 = date_header(rpt_render)
           SET d0 = line_sep(rpt_render)
           SET d0 = order_header(rpt_render)
           SET _yoffset = y_page_head
           SET continued = ""
           SET tmp_work_room = (y_end_of_page - _yoffset)
          ENDIF
          SET d0 = orderssection(rpt_render,tmp_work_room,becont)
        ENDWHILE
       ELSE
        SET tmp_work_room = (y_end_of_page - _yoffset)
        SET d0 = orderssection(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          SET cur_page = (cur_page+ 1)
          SET _yoffset = y_page_foot
          SET d0 = page_foot(rpt_render)
          SET d0 = pagebreak(0)
          SET continued = "continued"
          SET d0 = date_header(rpt_render)
          SET d0 = line_sep(rpt_render)
          SET d0 = order_header(rpt_render)
          SET _yoffset = y_page_head
          SET continued = ""
          SET tmp_work_room = (y_end_of_page - _yoffset)
          IF (tmp_work_room < 0)
           SET cur_page = (cur_page+ 1)
           SET _yoffset = y_page_foot
           SET d0 = page_foot(rpt_render)
           SET d0 = pagebreak(0)
           SET continued = "continued"
           SET d0 = date_header(rpt_render)
           SET d0 = order_header(rpt_render)
           SET _yoffset = y_page_head
           SET continued = ""
           SET tmp_work_room = (y_end_of_page - _yoffset)
          ENDIF
          SET d0 = orderssection(rpt_render,tmp_work_room,becont)
        ENDWHILE
       ENDIF
       SET prev_sort1 = insurance_review->dates[a_prt].order_day[b_prt].sort1
       SET prev_sort2 = insurance_review->dates[a_prt].order_day[b_prt].sort2
       SET prev_sort3 = insurance_review->dates[a_prt].order_day[b_prt].sort3
     ENDFOR
    ENDIF
    IF ((insurance_review->dates[a_prt].vital_cnt > 0))
     FOR (e_prt = 1 TO size(insurance_review->dates[a_prt].vitals_hi_lo_crit,5))
       IF (e_prt=1)
        SET room_needed = (vitals_header(rpt_calcheight)+ line_sep(rpt_calcheight))
        SET tmp_work_room = ((y_end_of_page - _yoffset) - room_needed)
        IF (tmp_work_room < 0)
         SET cur_page = (cur_page+ 1)
         SET _yoffset = y_page_foot
         SET d0 = page_foot(rpt_render)
         SET d0 = pagebreak(0)
         SET _yoffset = y_page_head
        ENDIF
        SET d0 = line_sep(rpt_render)
        SET d0 = vitals_header(rpt_render)
        SET tmp_work_room = (y_end_of_page - _yoffset)
        IF (tmp_work_room < 0)
         SET cur_page = (cur_page+ 1)
         SET _yoffset = y_page_foot
         SET d0 = page_foot(rpt_render)
         SET d0 = pagebreak(0)
         SET _yoffset = y_page_head
         SET tmp_work_room = (y_end_of_page - y_page_head)
         SET continued = "continued"
         SET d0 = date_header(rpt_render)
         SET d0 = line_sep(rpt_render)
         SET d0 = vitals_header(rpt_render)
         SET continued = ""
        ENDIF
        SET d0 = vitals_section(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          SET cur_page = (cur_page+ 1)
          SET _yoffset = y_page_foot
          SET d0 = page_foot(rpt_render)
          SET d0 = pagebreak(0)
          SET _yoffset = y_page_head
          SET continued = "continued"
          SET d0 = date_header(rpt_render)
          SET d0 = line_sep(rpt_render)
          SET d0 = vitals_header(rpt_render)
          SET continued = ""
          SET tmp_work_room = (y_end_of_page - _yoffset)
          IF (tmp_work_room < 0)
           SET cur_page = (cur_page+ 1)
           SET _yoffset = y_page_foot
           SET d0 = page_foot(rpt_render)
           SET d0 = pagebreak(0)
           SET _yoffset = y_page_head
           SET tmp_work_room = (y_end_of_page - y_page_head)
           SET continued = "continued"
           SET d0 = date_header(rpt_render)
           SET d0 = line_sep(rpt_render)
           SET d0 = vitals_header(rpt_render)
           SET continued = ""
          ENDIF
          SET d0 = vitals_section(rpt_render,tmp_work_room,becont)
        ENDWHILE
       ELSE
        SET tmp_work_room = (y_end_of_page - _yoffset)
        IF (tmp_work_room < 0)
         SET cur_page = (cur_page+ 1)
         SET _yoffset = y_page_foot
         SET d0 = page_foot(rpt_render)
         SET d0 = pagebreak(0)
         SET _yoffset = y_page_head
         SET tmp_work_room = (y_end_of_page - y_page_head)
         SET continued = "continued"
         SET d0 = date_header(rpt_render)
         SET d0 = line_sep(rpt_render)
         SET d0 = vitals_header(rpt_render)
         SET continued = ""
        ENDIF
        SET d0 = vitals_section(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          SET cur_page = (cur_page+ 1)
          SET _yoffset = y_page_foot
          SET d0 = page_foot(rpt_render)
          SET d0 = pagebreak(0)
          SET _yoffset = y_page_head
          SET continued = "continued"
          SET d0 = date_header(rpt_render)
          SET d0 = line_sep(rpt_render)
          SET d0 = vitals_header(rpt_render)
          SET continued = ""
          SET tmp_work_room = (y_end_of_page - _yoffset)
          IF (tmp_work_room < 0)
           SET cur_page = (cur_page+ 1)
           SET _yoffset = y_page_foot
           SET d0 = page_foot(rpt_render)
           SET d0 = pagebreak(0)
           SET _yoffset = y_page_head
           SET tmp_work_room = (y_end_of_page - y_page_head)
          ENDIF
          SET d0 = vitals_section(rpt_render,tmp_work_room,becont)
        ENDWHILE
       ENDIF
     ENDFOR
    ENDIF
    IF ((insurance_review->dates[a_prt].lab_result_cnt > 0))
     SET becont = 0
     FOR (g_prt = 1 TO size(insurance_review->dates[a_prt].lab_results,5))
       IF (g_prt=1)
        SET room_needed = (labs_header(rpt_calcheight)+ line_sep(rpt_calcheight))
        SET tmp_work_room = ((y_end_of_page - _yoffset) - room_needed)
        IF (tmp_work_room < 0)
         SET cur_page = (cur_page+ 1)
         SET _yoffset = y_page_foot
         SET d0 = page_foot(rpt_render)
         SET d0 = pagebreak(0)
         SET _yoffset = y_page_head
         SET tmp_work_room = (y_end_of_page - y_page_head)
         SET continued = "continued"
         SET d0 = date_header(rpt_render)
         SET d0 = line_sep(rpt_render)
         SET d0 = labs_header(rpt_render)
         SET continued = ""
        ENDIF
        SET d0 = line_sep(rpt_render)
        SET d0 = labs_header(rpt_render)
        SET d0 = labs_section(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          SET cur_page = (cur_page+ 1)
          SET _yoffset = y_page_foot
          SET d0 = page_foot(rpt_render)
          SET d0 = pagebreak(0)
          SET _yoffset = y_page_head
          SET continued = "continued"
          SET d0 = date_header(rpt_render)
          SET d0 = line_sep(rpt_render)
          SET d0 = labs_header(rpt_render)
          SET continued = ""
          SET tmp_work_room = (y_end_of_page - _yoffset)
          IF (tmp_work_room < 0)
           SET cur_page = (cur_page+ 1)
           SET _yoffset = y_page_foot
           SET d0 = page_foot(rpt_render)
           SET d0 = pagebreak(0)
           SET _yoffset = y_page_head
           SET tmp_work_room = (y_end_of_page - y_page_head)
           SET continued = "continued"
           SET d0 = date_header(rpt_render)
           SET d0 = line_sep(rpt_render)
           SET d0 = labs_header(rpt_render)
           SET continued = ""
          ENDIF
          SET d0 = labs_section(rpt_render,tmp_work_room,becont)
        ENDWHILE
       ELSE
        SET tmp_work_room = (y_end_of_page - _yoffset)
        IF (tmp_work_room < 0)
         SET cur_page = (cur_page+ 1)
         SET _yoffset = y_page_foot
         SET d0 = page_foot(rpt_render)
         SET d0 = pagebreak(0)
         SET _yoffset = y_page_head
         SET tmp_work_room = (y_end_of_page - y_page_head)
         SET continued = "continued"
         SET d0 = date_header(rpt_render)
         SET d0 = line_sep(rpt_render)
         SET d0 = labs_header(rpt_render)
         SET continued = ""
        ENDIF
        SET d0 = labs_section(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          SET cur_page = (cur_page+ 1)
          SET _yoffset = y_page_foot
          SET d0 = page_foot(rpt_render)
          SET d0 = pagebreak(0)
          SET _yoffset = y_page_head
          SET tmp_work_room = (y_end_of_page - _yoffset)
          IF (tmp_work_room < 0)
           SET cur_page = (cur_page+ 1)
           SET _yoffset = y_page_foot
           SET d0 = page_foot(rpt_render)
           SET d0 = pagebreak(0)
           SET _yoffset = y_page_head
           SET tmp_work_room = (y_end_of_page - y_page_head)
           SET continued = "continued"
           SET d0 = date_header(rpt_render)
           SET d0 = line_sep(rpt_render)
           SET d0 = labs_header(rpt_render)
           SET continued = ""
           SET d0 = labs_section(rpt_render,tmp_work_room,becont)
          ELSE
           SET d0 = labs_section(rpt_render,tmp_work_room,becont)
          ENDIF
        ENDWHILE
       ENDIF
     ENDFOR
    ENDIF
    IF ((insurance_review->dates[a_prt].cnt_io > 0))
     SET room_needed = (ioheader(rpt_calcheight)+ line_sep(rpt_calcheight))
     SET tmp_work_room = ((y_end_of_page - _yoffset) - room_needed)
     IF (tmp_work_room < 0)
      SET cur_page = (cur_page+ 1)
      SET _yoffset = y_page_foot
      SET d0 = page_foot(rpt_render)
      SET d0 = pagebreak(0)
      SET _yoffset = y_page_head
      SET tmp_work_room = (y_end_of_page - y_page_head)
      SET d0 = line_sep(rpt_render)
      SET d0 = ioheader(rpt_render)
      SET d0 = line_sep(rpt_render)
     ELSE
      SET d0 = line_sep(rpt_render)
      SET d0 = ioheader(rpt_render)
      SET d0 = line_sep(rpt_render)
     ENDIF
     WHILE (becont=1)
       SET cur_page = (cur_page+ 1)
       SET _yoffset = y_page_foot
       SET d0 = page_foot(rpt_render)
       SET d0 = pagebreak(0)
       SET _yoffset = y_page_head
       SET tmp_work_room = (y_end_of_page - _yoffset)
       IF (tmp_work_room < 0)
        SET tmp_work_room = (y_end_of_page - y_page_head)
       ENDIF
     ENDWHILE
    ENDIF
    IF ((insurance_review->dates[a_prt].rad_result_cnt > 0))
     FOR (c_prt = 1 TO size(insurance_review->dates[a_prt].rad_results,5))
      SET rad_result_blob = insurance_review->dates[a_prt].rad_results[c_prt].blob_result
      IF (c_prt=1)
       SET d0 = line_sep(rpt_render)
       SET d0 = rad_header(rpt_render)
       SET tmp_work_room = (y_end_of_page - _yoffset)
       IF (tmp_work_room < 0)
        SET cur_page = (cur_page+ 1)
        SET _yoffset = y_page_foot
        SET d0 = page_foot(rpt_render)
        SET d0 = pagebreak(0)
        SET _yoffset = y_page_head
        SET tmp_work_room = (y_end_of_page - y_page_head)
       ENDIF
       SET tmp_work_room = (y_end_of_page - _yoffset)
       SET d0 = rad_section(rpt_render,tmp_work_room,becont)
       CALL echo(build("tmp_work_room",tmp_work_room))
       CALL echo(build("Rpt_Render",rpt_render))
       WHILE (becont=1)
         SET cur_page = (cur_page+ 1)
         SET _yoffset = y_page_foot
         SET d0 = page_foot(rpt_render)
         SET d0 = pagebreak(0)
         SET _yoffset = y_page_head
         SET tmp_work_room = (y_end_of_page - _yoffset)
         IF (tmp_work_room < 0)
          SET cur_page = (cur_page+ 1)
          SET _yoffset = y_page_foot
          SET d0 = page_foot(rpt_render)
          SET d0 = pagebreak(0)
          SET _yoffset = y_page_head
          SET tmp_work_room = (y_end_of_page - y_page_head)
         ENDIF
         SET d0 = rad_header(rpt_render)
         SET d0 = rad_section(rpt_render,tmp_work_room,becont)
       ENDWHILE
      ELSE
       SET tmp_work_room = (y_end_of_page - _yoffset)
       IF (tmp_work_room < 0)
        SET cur_page = (cur_page+ 1)
        SET _yoffset = y_page_foot
        SET d0 = page_foot(rpt_render)
        SET d0 = pagebreak(0)
        SET _yoffset = y_page_head
        SET tmp_work_room = (y_end_of_page - y_page_head)
       ENDIF
       SET d0 = rad_section(rpt_render,tmp_work_room,becont)
       WHILE (becont=1)
         CALL break_page(_yoffset,y_page_head)
         CALL get_work_room(tmp_work_room,y_end_of_page,_yoffset)
         SET d0 = rad_header(rpt_render)
         SET d0 = rad_section(rpt_render,tmp_work_room,becont)
       ENDWHILE
      ENDIF
     ENDFOR
    ENDIF
    IF ((insurance_review->dates[a_prt].op_rpt_cnt > 0))
     FOR (d_prt = 1 TO size(insurance_review->dates[a_prt].op_report,5))
       IF (d_prt=1)
        SET tmp_work_room = ((y_end_of_page - _yoffset) - operative_header(rpt_calcheight))
        IF (tmp_work_room < 0)
         SET cur_page = (cur_page+ 1)
         SET _yoffset = y_page_foot
         SET d0 = page_foot(rpt_render)
         SET d0 = pagebreak(0)
         SET _yoffset = y_page_head
         SET tmp_work_room = (y_end_of_page - y_page_head)
         SET d0 = operative_header(rpt_render)
         SET d0 = line_sep(rpt_render)
         SET d0 = operative_section(rpt_render,tmp_work_room,becont)
        ELSE
         SET d0 = operative_header(rpt_render)
         SET d0 = line_sep(rpt_render)
         SET d0 = operative_section(rpt_render,tmp_work_room,becont)
        ENDIF
        WHILE (becont=1)
          SET cur_page = (cur_page+ 1)
          SET _yoffset = y_page_foot
          SET d0 = page_foot(rpt_render)
          SET d0 = pagebreak(0)
          SET _yoffset = y_page_head
          SET tmp_work_room = (y_end_of_page - _yoffset)
          IF (tmp_work_room < 0)
           CALL break_page(_yoffset,y_page_head)
           SET tmp_work_room = (y_end_of_page - y_page_head)
          ENDIF
          SET continued = "continued"
          SET d0 = date_header(rpt_render)
          SET d0 = line_sep(rpt_render)
          SET d0 = operative_header(rpt_render)
          SET d0 = line_sep(rpt_render)
          SET d0 = operative_section(rpt_render,tmp_work_room,becont)
          SET continued = ""
        ENDWHILE
       ELSE
        SET tmp_work_room = (y_end_of_page - _yoffset)
        IF (tmp_work_room < 0)
         SET cur_page = (cur_page+ 1)
         SET _yoffset = y_page_foot
         SET d0 = page_foot(rpt_render)
         SET d0 = pagebreak(0)
         SET _yoffset = y_page_head
         SET tmp_work_room = (y_end_of_page - y_page_head)
        ENDIF
        SET d0 = operative_section(rpt_render,tmp_work_room,becont)
        WHILE (becont=1)
          SET cur_page = (cur_page+ 1)
          SET _yoffset = y_page_foot
          SET d0 = page_foot(rpt_render)
          SET d0 = pagebreak(0)
          SET _yoffset = y_page_head
          SET continued = "continued"
          SET d0 = date_header(rpt_render)
          SET d0 = line_sep(rpt_render)
          SET d0 = operative_header(rpt_render)
          SET d0 = line_sep(rpt_render)
          SET continued = ""
          SET tmp_work_room = (y_end_of_page - _yoffset)
          IF (tmp_work_room < 0)
           SET cur_page = (cur_page+ 1)
           SET _yoffset = y_page_foot
           SET d0 = page_foot(rpt_render)
           SET d0 = pagebreak(0)
           SET _yoffset = y_page_head
           SET tmp_work_room = (y_end_of_page - y_page_head)
          ENDIF
          SET d0 = operative_section(rpt_render,tmp_work_room,becont)
        ENDWHILE
       ENDIF
     ENDFOR
    ENDIF
    IF (curendreport=1
     AND (_yoffset > (y_end_of_page+ page_foot_buffer)))
     SET cur_page = (cur_page+ 1)
     SET _yoffset = y_page_foot
     SET d0 = page_foot(rpt_render)
     SET _yoffset = y_page_head
     SET d0 = line_sep(rpt_render)
    ELSE
     SET cur_page = (cur_page+ 1)
     SET _yoffset = y_page_foot
     SET d0 = page_foot(rpt_render)
     SET d0 = pagebreak(0)
     SET _yoffset = y_page_head
     SET _yoffset = y_page_head
    ENDIF
   ENDIF
 ENDFOR
 SET d0 = finalizereport(var_output)
 CALL echo(var_output)
 IF (email_ind=1)
  SET filename_in = trim(var_output)
  SET email_address = trim( $EMAIL)
  SET filename_out = "Case_Management_Report.pdf"
  SET subject = concat("Case Management Report")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out,email_address,subject,1)
 ENDIF
#exit_prg
END GO

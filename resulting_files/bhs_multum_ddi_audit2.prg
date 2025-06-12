CREATE PROGRAM bhs_multum_ddi_audit2
 PROMPT
  "Output to File/Printer/MINE/Email" = "MINE",
  "Beginning Date" = "CURDATE",
  "Ending Date" = "CURDATE",
  "Report Option" = "1",
  "Encounter Types" = ""
  WITH outdev, begdate, enddate,
  printoption, pat_type
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
 SET pat_type2 = fillstring(20," ")
 IF (findstring("@", $OUTDEV) > 0)
  SET email_ind = 1
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET email_ind = 0
  SET output_dest =  $OUTDEV
 ENDIF
 IF (cnvtupper( $BEGDATE) IN ("BEGOFPREVMONTH", "BOM"))
  SET beg_date_qual = datetimefind(cnvtdatetime((curdate - 28),0000),"M","B","B")
 ELSEIF (cnvtupper( $BEGDATE) IN ("BEGOFWEEKLY", "BOW"))
  SET beg_date_qual = datetimefind(cnvtdatetime((curdate - 6),0000),"W","B","B")
 ELSE
  SET beg_date_qual = cnvtdatetime(cnvtdate( $BEGDATE),0000)
 ENDIF
 IF (cnvtupper( $ENDDATE) IN ("ENDOFPREVMONTH", "EOM"))
  SET end_date_qual = datetimefind(cnvtdatetime((curdate - 28),235959),"M","E","E")
 ELSEIF (cnvtupper( $ENDDATE) IN ("ENDOFWEEKLY", "EOW"))
  SET end_date_qual = datetimefind(cnvtdatetime((curdate - 6),235959),"W","E","E")
 ELSE
  SET end_date_qual = cnvtdatetime(cnvtdate( $ENDDATE),235959)
 ENDIF
 SET beg_date_disp = format(beg_date_qual,"MM/DD/YYYY;;d")
 SET end_date_disp = format(end_date_qual,"MM/DD/YYYY;;d")
 CALL echo(beg_date_disp)
 CALL echo(end_date_disp)
 IF (( $PAT_TYPE="1"))
  SET pat_type2 = "Exclude Outpatients"
 ELSEIF (( $PAT_TYPE="2"))
  SET pat_type2 = "All Patient Types"
 ENDIF
 DECLARE percent_1 = f8
 DECLARE cnt = i4
 SET cnt = 0
 FREE RECORD eks
 RECORD eks(
   1 list[*]
     2 dlg_event_id = f8
     2 active_ind = i4
     2 prsnl_id = f8
     2 encntr_id = f8
     2 fmrn = vc
     2 person_id = f8
     2 patient_name = vc
     2 prsnl_name = vc
     2 prsnl_position_cd = f8
     2 severity = i4
     2 override_rsn_cd = f8
     2 override_rsn_lt_id = f8
     2 override_rsn_ft = vc
     2 facility_cd = f8
     2 trigger
       3 order_id = f8
       3 catalog_cd = f8
       3 order_row_exists = i4
       3 orig_ord_as_flag = i4
       3 order_dt_tm = dq8
       3 drug_class_cd = f8
       3 physician_id = f8
       3 physician_name = vc
       3 physician_position_cd = f8
     2 interact
       3 order_id = f8
       3 catalog_cd = f8
       3 orig_ord_as_flag = i4
       3 order_dt_tm = dq8
       3 drug_class_cd = f8
       3 physician_id = f8
       3 physician_name = vc
       3 physician_position_cd = f8
 )
 SELECT INTO "nl:"
  FROM eks_dlg_event ede,
   eks_dlg_event_attr edea,
   prsnl pr,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (ede
   WHERE trim(ede.dlg_name)="MUL_MED!DRUGDRUG"
    AND ede.updt_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual))
   JOIN (edea
   WHERE edea.dlg_event_id=ede.dlg_event_id)
   JOIN (pr
   WHERE pr.person_id=ede.dlg_prsnl_id)
   JOIN (e
   WHERE e.encntr_id=ede.encntr_id
    AND ((( $PAT_TYPE="1")
    AND e.encntr_type_cd IN (obs_enc_type_cd, inp_enc_type_cd, day_enc_type_cd, emergency_enc_type_cd,
   disch_inp_enc_type_cd,
   disch_obs_enc_type_cd, disch_day_enc_type_cd, disch_es_enc_type_cd, exp_inp_enc_type_cd,
   exp_obs_enc_type_cd,
   exp_day_enc_type_cd, exp_es_enc_type_cd)) OR (( $PAT_TYPE="2"))) )
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1077
    AND cnvtdatetime(curdate,curtime3) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm
    AND ea.active_ind=1)
   JOIN (p
   WHERE p.person_id=ede.person_id)
  ORDER BY ede.dlg_event_id
  HEAD REPORT
   row + 1
  HEAD ede.dlg_event_id
   cnt = (cnt+ 1)
   IF (mod(cnt,100000)=1)
    stat = alterlist(eks->list,(cnt+ 100000))
   ENDIF
   eks->list[cnt].dlg_event_id = ede.dlg_event_id, eks->list[cnt].encntr_id = ede.encntr_id, eks->
   list[cnt].person_id = ede.person_id,
   eks->list[cnt].prsnl_id = ede.dlg_prsnl_id, eks->list[cnt].trigger.catalog_cd = ede
   .trigger_entity_id, eks->list[cnt].trigger.order_id = ede.trigger_order_id,
   eks->list[cnt].trigger.order_row_exists = 0, eks->list[cnt].override_rsn_cd = ede
   .override_reason_cd, eks->list[cnt].override_rsn_lt_id = ede.long_text_id,
   eks->list[cnt].prsnl_name = trim(pr.name_full_formatted), eks->list[cnt].prsnl_position_cd = pr
   .position_cd, eks->list[cnt].fmrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd)),
   eks->list[cnt].patient_name = trim(p.name_full_formatted), eks->list[cnt].facility_cd = e
   .loc_facility_cd, eks->list[cnt].active_ind = 1
  DETAIL
   IF (edea.attr_name="SEVERITY_LEVEL")
    eks->list[cnt].severity = edea.attr_id
    IF (edea.attr_id < 3)
     eks->list[cnt].active_ind = 0
    ENDIF
   ELSEIF (edea.attr_name="CATALOG_CD")
    eks->list[cnt].interact.catalog_cd = edea.attr_id
   ELSEIF (edea.attr_name="ORDER_ID")
    eks->list[cnt].interact.order_id = edea.attr_id
   ENDIF
  FOOT REPORT
   stat = alterlist(eks->list,cnt)
  WITH nocounter
 ;end select
 CALL echo("getting triggering order information")
 SELECT INTO "nl:"
  *
  FROM (dummyt d  WITH seq = value(size(eks->list,5))),
   orders o,
   order_catalog oc,
   order_action oa,
   prsnl pr,
   dummyt d2
  PLAN (d
   WHERE (eks->list[d.seq].severity >= 3))
   JOIN (oc
   WHERE (oc.catalog_cd=eks->list[d.seq].trigger.catalog_cd))
   JOIN (d2)
   JOIN (o
   WHERE (o.order_id=eks->list[d.seq].trigger.order_id))
   JOIN (oa
   WHERE (oa.order_id=eks->list[d.seq].trigger.order_id)
    AND oa.action_type_cd=2534)
   JOIN (pr
   WHERE pr.person_id=outerjoin(oa.order_provider_id))
  DETAIL
   eks->list[d.seq].trigger.order_dt_tm = o.orig_order_dt_tm, eks->list[d.seq].trigger.physician_id
    = pr.person_id, eks->list[d.seq].trigger.physician_name = trim(pr.name_full_formatted),
   eks->list[d.seq].trigger.physician_position_cd = pr.position_cd, eks->list[d.seq].trigger.
   orig_ord_as_flag = o.orig_ord_as_flag
   IF (o.order_id > 0)
    eks->list[d.seq].trigger.order_row_exists = 1
   ENDIF
  WITH outerjoin = d2, nocounter
 ;end select
 CALL echo("getting interacting order information")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(eks->list,5))),
   orders o,
   order_catalog oc,
   order_action oa,
   prsnl pr,
   dummyt d2
  PLAN (d
   WHERE (eks->list[d.seq].severity >= 3))
   JOIN (oc
   WHERE (oc.catalog_cd=eks->list[d.seq].interact.catalog_cd))
   JOIN (d2)
   JOIN (o
   WHERE (o.order_id=eks->list[d.seq].interact.order_id))
   JOIN (oa
   WHERE (oa.order_id=eks->list[d.seq].interact.order_id)
    AND oa.action_type_cd=2534)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
  DETAIL
   eks->list[d.seq].interact.order_dt_tm = o.orig_order_dt_tm, eks->list[d.seq].interact.physician_id
    = pr.person_id, eks->list[d.seq].interact.physician_name = pr.name_full_formatted,
   eks->list[d.seq].interact.physician_position_cd = pr.position_cd, eks->list[d.seq].interact.
   orig_ord_as_flag = o.orig_ord_as_flag
  WITH nocounter, outerjoin = d2
 ;end select
 CALL echo("building temporary table")
 SELECT INTO "nl:"
  encntr_id = eks->list[d.seq].encntr_id, prsnl_id = eks->list[d.seq].prsnl_id, trigger_catalog_cd =
  eks->list[d.seq].trigger.catalog_cd,
  trigger_order_id = eks->list[d.seq].trigger.order_id, interact_order_id = eks->list[d.seq].interact
  .order_id, dlg_event_id = eks->list[d.seq].dlg_event_id,
  override_rsn_lt_id = eks->list[d.seq].override_rsn_lt_id, override_rsn_cd = eks->list[d.seq].
  override_rsn_cd, severity = eks->list[d.seq].severity
  FROM (dummyt d  WITH seq = value(size(eks->list,5)))
  PLAN (d
   WHERE (eks->list[d.seq].active_ind=1))
  ORDER BY encntr_id, interact_order_id, trigger_catalog_cd,
   prsnl_id, dlg_event_id
  DETAIL
   eks->list[d.seq].active_ind = 0
  FOOT  interact_order_id
   eks->list[d.seq].active_ind = 1
  WITH nocounter
 ;end select
 RECORD cat_codes(
   1 cnt = i4
   1 list[*]
     2 catalog_cd = f8
     2 cnt = i4
 )
 IF (((( $4="1")) OR (validate(request->batch_selection))) )
  CALL echo("building unique catalog code list")
  SELECT INTO "nl:"
   FROM order_action oa,
    orders o
   PLAN (oa
    WHERE oa.action_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
     AND oa.action_type_cd=2534)
    JOIN (o
    WHERE o.order_id=oa.order_id)
   ORDER BY o.catalog_cd, o.order_id
   HEAD REPORT
    cat_cd_cnt = 0
   HEAD o.catalog_cd
    cat_cd_cnt = (cat_cd_cnt+ 1)
    IF (mod(cat_cd_cnt,10)=1)
     stat = alterlist(cat_codes->list,(cat_cd_cnt+ 9))
    ENDIF
    ord_cnt = 0
   DETAIL
    ord_cnt = (ord_cnt+ 1)
   FOOT  o.catalog_cd
    cat_codes->list[cat_cd_cnt].cnt = ord_cnt, cat_codes->list[cat_cd_cnt].catalog_cd = o.catalog_cd
   FOOT REPORT
    stat = alterlist(cat_codes->list,cat_cd_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (((( $4="2")) OR (validate(request->batch_selection))) )
  SELECT INTO "nl:"
   FROM long_text lt,
    (dummyt d  WITH seq = value(size(eks->list,5)))
   PLAN (d
    WHERE (eks->list[d.seq].override_rsn_lt_id > 0))
    JOIN (lt
    WHERE (lt.long_text_id=eks->list[d.seq].override_rsn_lt_id))
   DETAIL
    eks->list[d.seq].override_rsn_ft = lt.long_text
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("ALL DONE, now output")
 DECLARE output_line = vc
 DECLARE facility_disp = vc
 DECLARE interact_ord_phys_pos = vc
 DECLARE trigger_ord_phys_pos = vc
 DECLARE user_position = vc
 DECLARE override_reason = vc
 DECLARE override_yes_no = vc
 SET report_type =  $PRINTOPTION
 SELECT INTO value(output_dest)
  trig_mnemonic = uar_get_code_display(eks->list[d.seq].trigger.catalog_cd), interact_mnemonic =
  uar_get_code_display(eks->list[d.seq].interact.catalog_cd)
  FROM (dummyt d  WITH seq = value(size(eks->list,5))),
   orders interact,
   orders trgr,
   dummyt d1,
   dummyt d2
  PLAN (d
   WHERE (eks->list[d.seq].interact.orig_ord_as_flag IN (1, 0))
    AND (eks->list[d.seq].severity >= 3)
    AND (eks->list[d.seq].active_ind=1)
    AND (eks->list[d.seq].trigger.catalog_cd > 0))
   JOIN (d1)
   JOIN (trgr
   WHERE (trgr.order_id=eks->list[d.seq].trigger.order_id))
   JOIN (d2)
   JOIN (interact
   WHERE (interact.order_id=eks->list[d.seq].interact.order_id))
  ORDER BY trig_mnemonic, interact_mnemonic
  HEAD REPORT
   count_1 = 0.00, count_2 = 0.00, count_3 = 0.00,
   count_4 = 0.00, percent_1 = 0.00, percent_2 = 0.00,
   percent_3 = 0.00, col 1, ',"Baystate Health",',
   row + 1, col 1, ',"Drug Drug Interaction Report",',
   row + 1, col 1, ',"Beginning Date: ',
   beg_date_disp, '",', row + 1,
   col 1, ',"Ending Date: ', end_date_disp,
   '",', row + 1
   IF (report_type="2")
    col 1, ',"Detail Report:', pat_type2,
    '",', row + 1, output_line = build(',"',"Triggering Drug",'","',"Interacting Drug",'","',
     "Patient Name",'","',"Facility",'","',"Ordering Physician",
     '","',"Ordering Physician Position",'","',"FMRN",'","',
     "Order Date",'","',"User Position",'","',"Order ID",
     '","',"Override Reason",'","',"Free-text Override Reason",'","',
     "Severity",'","',"Overridden?",'","',"Triggering Order Detail",
     '","',"Interacting Order Detail",'",'),
    col 1, output_line, row + 1
   ELSEIF (report_type="1")
    col 1, ',"Summary Report: ', pat_type2,
    '",', row + 1, output_line = build(',"',"Triggering Drug",'","',"Interacting Drug",'","',
     "# Interact",'","',"# Overridden",'","',"% Overridden",
     '","',"# Not Overridden",'","',"% Not Overridden",'","',
     "# Total Orders",'","',"Tot % Interact",'",'),
    col 1, output_line, row + 1
   ENDIF
  HEAD trig_mnemonic
   row + 0
  HEAD interact_mnemonic
   interact_count = 0.00, override_count = 0.00, override_percent = 0.00
  DETAIL
   interact_count = (interact_count+ 1)
   IF ((eks->list[d.seq].trigger.order_id > 0)
    AND (eks->list[d.seq].trigger.order_row_exists=1))
    override_count = (override_count+ 1)
   ENDIF
   IF (report_type="2")
    facility_disp = substring(1,40,uar_get_code_display(eks->list[d.seq].facility_cd)),
    interact_ord_phys_pos = substring(1,40,uar_get_code_display(eks->list[d.seq].interact.
      physician_position_cd)), trigger_ord_phys_pos = substring(1,40,uar_get_code_display(eks->list[d
      .seq].trigger.physician_position_cd)),
    user_position = substring(1,40,uar_get_code_display(eks->list[d.seq].prsnl_position_cd)),
    override_reason = substring(1,100,uar_get_code_display(eks->list[d.seq].override_rsn_cd)),
    order_date_disp = format(eks->list[d.seq].trigger.order_dt_tm,"MM/DD/YYYY HH:MM:SS;;D")
    IF ((eks->list[d.seq].trigger.order_id > 0)
     AND (eks->list[d.seq].trigger.order_row_exists=1))
     override_yes_no = "Y"
    ELSE
     override_yes_no = "N", override_reason = ""
    ENDIF
    output_line = build(',"',trim(uar_get_code_display(eks->list[d.seq].trigger.catalog_cd)),'","',
     trim(uar_get_code_display(eks->list[d.seq].interact.catalog_cd)),'","',
     eks->list[d.seq].patient_name,'","',facility_disp,'","',eks->list[d.seq].trigger.physician_name,
     '","',trigger_ord_phys_pos,'","',eks->list[d.seq].fmrn,'","',
     order_date_disp,'","',user_position,'","',eks->list[d.seq].trigger.order_id,
     '","',override_reason,'","',eks->list[d.seq].override_rsn_ft,'","',
     eks->list[d.seq].severity,'","',override_yes_no,'","',trgr.clinical_display_line,
     '","',interact.clinical_display_line,'",'), col 1, output_line,
    row + 1
   ENDIF
  FOOT  interact_mnemonic
   IF (report_type="1")
    override_percent = 0.00
    IF (interact_count > 0)
     override_percent = round(((override_count * 100)/ interact_count),2)
    ENDIF
    not_override_count = (interact_count - override_count), not_override_percent = round(((
     not_override_count/ interact_count) * 100),2)
    FOR (i = 1 TO size(cat_codes->list,5))
      IF ((cat_codes->list[i].catalog_cd=eks->list[d.seq].trigger.catalog_cd))
       tot_cnt = (cat_codes->list[i].cnt+ not_override_count)
      ENDIF
    ENDFOR
    alert_percent = 0.00, alert_percent = round(((interact_count * 100)/ tot_cnt),2), output_line =
    build(',"',trim(uar_get_code_display(eks->list[d.seq].trigger.catalog_cd)),'","',trim(
      uar_get_code_display(eks->list[d.seq].interact.catalog_cd)),'","',
     interact_count,'","',override_count,'","',override_percent,
     '","',not_override_count,'","',not_override_percent,'","',
     tot_cnt,'","',alert_percent,'",'),
    col 1, output_line, row + 1,
    count_1 = (count_1+ interact_count), count_2 = (count_2+ override_count), count_3 = (count_3+
    not_override_count),
    count_4 = (count_4+ tot_cnt)
   ENDIF
  FOOT REPORT
   IF (report_type="1")
    row + 1, percent_1 = round(((count_2/ count_1) * 100),2), percent_2 = round(((count_3/ count_1)
      * 100),2),
    percent_3 = round(((count_1/ count_4) * 100),2), output_line2 = build(',"Totals"',","," ",",",
     count_1,
     ",",count_2,",",percent_1,",",
     count_3,",",percent_2,",",count_4,
     ",",percent_3,","), col 1,
    output_line2, row + 1
   ELSE
    row + 0
   ENDIF
  FOOT  trig_mnemonic
   row + 0
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable, outerjoin = d1, outerjoin = d2,
   nullreport
 ;end select
 IF (email_ind=1)
  SET filename_in = concat(trim(output_dest),".dat")
  SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - B M C Drug Drug Interaction Rpt ",beg_date_disp," to ",
   end_date_disp)
  IF (( $PRINTOPTION="1"))
   SET subject_line = concat(subject_line," - Executive Summary")
  ELSE
   SET subject_line = concat(subject_line," - Detail")
  ENDIF
  IF (( $PAT_TYPE="1"))
   SET subject_line = concat(subject_line," - Exclude OP")
  ELSE
   SET subject_line = concat(subject_line," - Include OP")
  ENDIF
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO

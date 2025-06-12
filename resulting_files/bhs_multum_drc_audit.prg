CREATE PROGRAM bhs_multum_drc_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beginning Date" = "CURDATE",
  "Ending Date" = "CURDATE",
  "Format" = "1",
  "Encounter Types" = ""
  WITH outdev, begdate, enddate,
  report_format, pat_type
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
 DECLARE beg_date_qual = dq8
 DECLARE end_date_qual = dq8
 IF (findstring("@", $OUTDEV) > 0)
  SET email_ind = 1
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET email_ind = 0
  SET output_dest =  $OUTDEV
 ENDIF
 IF (( $BEGDATE="BEGOFPREVMONTH"))
  SET current_month = month(curdate)
  SET month_qual = (current_month - 1)
  SET year_qual = year(curdate)
  IF (month_qual=0)
   SET month_qual = 12
   SET year_qual = (year_qual - 1)
  ENDIF
  SET beg_date_qual = datetimefind(cnvtdatetime((curdate - 10),0),"M","B","B")
  SET beg_date_qual = cnvtdate(beg_date_qual)
 ELSE
  SET beg_date_qual = cnvtdate( $BEGDATE)
 ENDIF
 IF (( $ENDDATE="ENDOFPREVMONTH"))
  SET current_month = month(curdate)
  SET current_year = year(curdate)
  SET end_date_qual = datetimefind(cnvtdatetime((curdate - 10),0),"M","E","E")
  SET end_date_qual = cnvtdate(end_date_qual)
 ELSE
  SET end_date_qual = cnvtdate( $ENDDATE)
 ENDIF
 SET beg_date_disp = format(beg_date_qual,"MM/DD/YYYY;;d")
 SET end_date_disp = format(end_date_qual,"MM/DD/YYYY;;d")
 CALL echo(build("BEG DATE: ",beg_date_disp))
 CALL echo(build("END DATE:",end_date_disp))
 CALL echo(beg_date_qual)
 CALL echo(end_date_qual)
 IF (( $PAT_TYPE="1"))
  SET pat_type2 = "Exclude Outpatients"
 ELSEIF (( $PAT_TYPE="2"))
  SET pat_type2 = "All Patient Types"
 ENDIF
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
     2 nomenclature_id = f8
     2 source_string = vc
     2 source_identifier = vc
     2 allergy_id = f8
     2 substance_type_cd = f8
     2 reaction_class_cd = f8
     2 severity_cd = f8
     2 trigger
       3 order_id = f8
       3 catalog_cd = f8
       3 cki = vc
       3 orig_ord_as_flag = i4
       3 order_row_exists = i4
       3 catalog_mnemonic = c20
       3 order_mnemonic = vc
       3 clinical_disp_line = vc
       3 order_dt_tm = dq8
       3 drug_class_cd = f8
       3 physician_id = f8
       3 physician_name = vc
       3 physician_position_cd = f8
 )
 SELECT INTO "nl:"
  FROM eks_dlg_event ede,
   prsnl pr,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (ede
   WHERE ede.dlg_name="PHA_EKM!PHA_DRC_KDMO"
    AND ede.updt_dt_tm BETWEEN cnvtdatetime(beg_date_qual,000000) AND cnvtdatetime(end_date_qual,
    235959)
    AND  NOT ( EXISTS (
   (SELECT
    ede2.dlg_name
    FROM eks_dlg_event ede2
    WHERE ede2.encntr_id=ede.encntr_id
     AND ede2.dlg_prsnl_id=ede.dlg_prsnl_id
     AND ede2.trigger_order_id=ede.trigger_order_id
     AND ede2.dlg_name=ede.dlg_name
     AND ede2.dlg_event_id != ede.dlg_event_id
     AND ede2.dlg_dt_tm < ede.dlg_dt_tm))))
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
  ORDER BY ede.encntr_id, ede.dlg_prsnl_id, ede.trigger_entity_id,
   ede.dlg_event_id DESC
  HEAD ede.encntr_id
   row + 0
  HEAD ede.dlg_prsnl_id
   row + 0
  HEAD ede.trigger_entity_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(eks->list,(cnt+ 9))
   ENDIF
   eks->list[cnt].dlg_event_id = ede.dlg_event_id, eks->list[cnt].encntr_id = ede.encntr_id, eks->
   list[cnt].person_id = ede.person_id,
   eks->list[cnt].prsnl_id = ede.dlg_prsnl_id, eks->list[cnt].trigger.catalog_cd = ede
   .trigger_entity_id, eks->list[cnt].trigger.order_id = ede.trigger_order_id,
   eks->list[cnt].trigger.order_row_exists = 0, eks->list[cnt].override_rsn_cd = ede
   .override_reason_cd, eks->list[cnt].override_rsn_lt_id = ede.long_text_id,
   eks->list[cnt].prsnl_name = pr.name_full_formatted, eks->list[cnt].prsnl_position_cd = pr
   .position_cd, eks->list[cnt].fmrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd)),
   eks->list[cnt].patient_name = p.name_full_formatted, eks->list[cnt].facility_cd = e
   .loc_facility_cd, eks->list[cnt].active_ind = 1
  FOOT REPORT
   stat = alterlist(eks->list,cnt)
  WITH nocounter
 ;end select
 IF (size(eks->list,5) <= 0)
  GO TO exit_script
 ENDIF
 CALL echo("getting triggering order information")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(eks->list,5))),
   orders o,
   order_catalog oc,
   order_action oa,
   prsnl pr,
   dummyt d2
  PLAN (d)
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
   eks->list[d.seq].trigger.catalog_mnemonic = oc.primary_mnemonic, eks->list[d.seq].trigger.
   order_mnemonic = oc.primary_mnemonic, eks->list[d.seq].trigger.clinical_disp_line = o
   .clinical_display_line,
   eks->list[d.seq].trigger.order_dt_tm = o.orig_order_dt_tm, eks->list[d.seq].trigger.physician_id
    = pr.person_id, eks->list[d.seq].trigger.physician_name = pr.name_full_formatted,
   eks->list[d.seq].trigger.physician_position_cd = pr.position_cd, eks->list[d.seq].trigger.cki = oc
   .cki, eks->list[d.seq].trigger.orig_ord_as_flag = o.orig_ord_as_flag
   IF (o.order_id > 0)
    eks->list[d.seq].trigger.order_row_exists = 1
   ENDIF
  WITH outerjoin = d2, nocounter
 ;end select
 CALL echo("getting interacting allergy information")
 RECORD cat_codes(
   1 cnt = i4
   1 list[*]
     2 catalog_cd = f8
     2 cnt = i4
 )
 FOR (i = 1 TO size(eks->list,5))
  SET found = 0
  IF ((eks->list[i].active_ind=1))
   FOR (j = 1 TO cat_codes->cnt)
     IF ((cat_codes->list[j].catalog_cd=eks->list[i].trigger.catalog_cd))
      SET found = 1
      SET j = (cat_codes->cnt+ 1)
     ENDIF
   ENDFOR
   CALL echo(build(found,":",i,"-",eks->list[i].trigger.catalog_cd))
   IF (found=0)
    SET cat_codes->cnt = (cat_codes->cnt+ 1)
    IF (mod(cat_codes->cnt,10)=1)
     SET stat = alterlist(cat_codes->list,(cat_codes->cnt+ 9))
    ENDIF
    SET cat_codes->list[cat_codes->cnt].catalog_cd = eks->list[i].trigger.catalog_cd
   ENDIF
  ENDIF
 ENDFOR
 SET stat = alterlist(cat_codes->list,cat_codes->cnt)
 SET stat = alterlist(cat_codes->list,cat_codes->cnt)
 CALL echo("retrieving all orders in the date range with catalog codes in the list")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cat_codes->list,5))),
   order_action oa,
   orders o
  PLAN (d)
   JOIN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(beg_date_qual,000000) AND cnvtdatetime(end_date_qual,
    235959)
    AND oa.action_type_cd=2534)
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND ((o.catalog_cd - 0)=cat_codes->list[d.seq].catalog_cd))
  ORDER BY o.catalog_cd, o.order_id
  HEAD o.catalog_cd
   ord_cnt = 0
  DETAIL
   ord_cnt = (ord_cnt+ 1)
  FOOT  o.catalog_cd
   cat_codes->list[d.seq].cnt = ord_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM long_text lt,
   (dummyt d  WITH seq = value(size(eks->list,5)))
  PLAN (d)
   JOIN (lt
   WHERE (lt.long_text_id=eks->list[d.seq].override_rsn_lt_id))
  DETAIL
   eks->list[d.seq].override_rsn_ft = lt.long_text
  WITH nocounter
 ;end select
 CALL echo("ALL DONE, now output")
 DECLARE output_line = vc
 DECLARE facility_disp = vc
 DECLARE interact_ord_phys_pos = vc
 DECLARE trigger_ord_phys_pos = vc
 DECLARE user_position = vc
 DECLARE override_reason = vc
 DECLARE override_yes_no = vc
 SET dynamic_maxcol = 1000
 SET dynamic_formfeed = "NONE"
 SET dynamic_maxrow = 1
 SET report_type =  $4
 SELECT INTO value(output_dest)
  trig_mnemonic = eks->list[d.seq].trigger.catalog_mnemonic, allergy_disp = eks->list[d.seq].
  source_string
  FROM (dummyt d  WITH seq = value(size(eks->list,5)))
  PLAN (d
   WHERE (eks->list[d.seq].active_ind=1)
    AND (eks->list[d.seq].trigger.orig_ord_as_flag != 1)
    AND size(eks->list[d.seq].trigger.catalog_mnemonic) > 0)
  ORDER BY trig_mnemonic, allergy_disp
  HEAD REPORT
   count_1 = 0.00, count_2 = 0.00, count_3 = 0.00,
   count_4 = 0.00, percent_1 = 0.00, percent_2 = 0.00,
   percent_3 = 0.00, col 1, ',"Baystate Health",',
   row + 1, col 1, ',"Dose Range Checking Report",',
   row + 1, col 1, ',"Beginning Date: ',
   beg_date_disp, '",', row + 1,
   col 1, ',"Ending Date: ', end_date_disp,
   '",', row + 1
   IF (report_type="2")
    col 1, ',"Detail Report: ', pat_type2,
    '",', row + 1, output_line = build(',"',"Triggering Drug",'","',"Facility",'","',
     "Ordering Physician",'","',"Ordering Physician Position",'","',"FMRN",
     '","',"Order Date",'","',"User Position",'","',
     "Order ID",'","',"Override Reason",'","',"Free-text Override Reason",
     '","',"Overridden?",'","',"Triggering Order Detail",'",')
   ELSEIF (report_type="1")
    col 1, ',"Summary Report: ', pat_type2,
    '",', row + 1, output_line = concat(',"Triggering Drug","# Alerts","#Overridden"',
     ',"% Overridden","# Not Overridden","% Not Overridden"',',"# Total Orders",Total % Alerts",')
   ENDIF
   col 1, output_line, row + 1,
   row + 0
  HEAD trig_mnemonic
   interact_count = 0.00, override_count = 0.00
  HEAD allergy_disp
   override_percent = 0.00
  DETAIL
   IF (report_type="2")
    interact_count = (interact_count+ 1)
    IF ((eks->list[d.seq].trigger.order_id > 0)
     AND (eks->list[d.seq].trigger.order_row_exists=1))
     override_count = (override_count+ 1)
    ENDIF
    facility_disp = substring(1,40,uar_get_code_display(eks->list[d.seq].facility_cd)),
    trigger_ord_phys_pos = substring(1,40,uar_get_code_display(eks->list[d.seq].trigger.
      physician_position_cd)), user_position = substring(1,40,uar_get_code_display(eks->list[d.seq].
      prsnl_position_cd)),
    override_reason = substring(1,100,uar_get_code_display(eks->list[d.seq].override_rsn_cd)),
    order_date_disp = format(eks->list[d.seq].trigger.order_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
    allergy_severity = uar_get_code_display(eks->list[d.seq].severity_cd),
    allergy_reaction_class = uar_get_code_display(eks->list[d.seq].reaction_class_cd)
    IF ((eks->list[d.seq].trigger.order_id > 0)
     AND (eks->list[d.seq].trigger.order_row_exists=1))
     override_yes_no = "Y"
    ELSE
     override_yes_no = "N"
    ENDIF
    output_line = build(',"',eks->list[d.seq].trigger.order_mnemonic,'","',facility_disp,'","',
     eks->list[d.seq].trigger.physician_name,'","',trigger_ord_phys_pos,'","',eks->list[d.seq].fmrn,
     '","',order_date_disp,'","',user_position,'","',
     eks->list[d.seq].trigger.order_id,'","',override_reason,'","',eks->list[d.seq].override_rsn_ft,
     '","',override_yes_no,'","',eks->list[d.seq].trigger.clinical_disp_line,'",'), col 1,
    output_line,
    row + 1
   ELSEIF (report_type="1")
    IF ((eks->list[d.seq].trigger.order_id > 0)
     AND (eks->list[d.seq].trigger.order_row_exists=1))
     override_count = (override_count+ 1)
    ENDIF
    interact_count = (interact_count+ 1)
   ENDIF
  FOOT  allergy_disp
   row + 0
  FOOT  trig_mnemonic
   IF (report_type="1")
    override_percent = round(((override_count * 100)/ interact_count),2), not_overridden = (
    interact_count - override_count), not_override_percent = round(((not_overridden * 100)/
     interact_count),2),
    total_ordered = 0, total_percent = 0.00
    FOR (i = 1 TO size(cat_codes->list,5))
      IF ((cat_codes->list[i].catalog_cd=eks->list[d.seq].trigger.catalog_cd))
       total_ordered = cat_codes->list[i].cnt, total_percent = round(((interact_count * 100)/
        total_ordered),2)
      ENDIF
    ENDFOR
    output_line = build(',"',eks->list[d.seq].trigger.order_mnemonic,'",',interact_count,",",
     override_count,",",override_percent,",",not_overridden,
     ",",not_override_percent,",",total_ordered,",",
     total_percent,","), col 1, output_line,
    row + 1, count_1 = (count_1+ interact_count), count_2 = (count_2+ override_count),
    count_3 = (count_3+ not_overridden), count_4 = (count_4+ total_ordered)
   ENDIF
  FOOT REPORT
   IF (report_type="1")
    row + 2, percent_1 = round(((count_2/ count_1) * 100),2), percent_2 = round(((count_3/ count_1)
      * 100),2),
    percent_3 = round(((count_1/ count_4) * 100),2), output_line2 = build(',"Totals"',",",count_1,",",
     count_2,
     ",",percent_1,",",count_3,",",
     percent_2,",",count_4,",",percent_3,
     ","), col 1,
    output_line2, row + 1
   ELSE
    row + 0
   ENDIF
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 IF (email_ind=1)
  SET filename_in = concat(trim(output_dest),".dat")
  SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - B M C Dose Range Checking Rpt ",beg_date_disp," to ",
   end_date_disp)
  IF (( $4="1"))
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
#exit_script
END GO

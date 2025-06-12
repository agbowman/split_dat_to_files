CREATE PROGRAM bhs_multum_dai_audit_v3
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
 DECLARE dclcom = vc
 DECLARE output_destfile = vc
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
  SET output_dest = trim(cnvtlower(curprog))
 ELSE
  SET email_ind = 0
  SET output_dest =  $OUTDEV
 ENDIF
 IF (( $2="BOM"))
  SET current_month = month(curdate)
  SET month_qual = (current_month - 1)
  SET year_qual = year(curdate)
  IF (month_qual=0)
   SET month_qual = 12
   SET year_qual = (year_qual - 1)
  ENDIF
  SET beg_date_qual = datetimefind(cnvtdatetime((curdate - 20),0),"M","B","B")
 ELSE
  SET beg_date_qual = cnvtdatetime(cnvtdate(cnvtint( $2)),0)
 ENDIF
 IF (( $3="EOM"))
  SET current_month = month(curdate)
  SET current_year = year(curdate)
  SET end_date_qual = datetimefind(cnvtdatetime((curdate - 20),0),"M","E","E")
 ELSE
  SET end_date_qual = cnvtdatetime(cnvtdate(cnvtint( $3)),235959)
 ENDIF
 SET beg_date_disp = format(beg_date_qual,"MM/DD/YYYY;;d")
 SET end_date_disp = format(end_date_qual,"MM/DD/YYYY;;d")
 CALL echo(build("BEG DATE: ",beg_date_disp))
 CALL echo(build("END DATE:",end_date_disp))
 DECLARE cnt = i4
 SET cnt = 0
 FREE RECORD eks
 RECORD eks(
   1 list[*]
     2 dlg_event_id = f8
     2 active_ind = i4
     2 prsnl_id = f8
     2 encntr_id = f8
     2 encntrtype = f8
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
   eks_dlg_event_attr edea,
   prsnl pr,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (ede
   WHERE trim(ede.dlg_name)="MUL_MED!DRUGALLERGY"
    AND ede.updt_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual))
   JOIN (edea
   WHERE edea.dlg_event_id=ede.dlg_event_id)
   JOIN (pr
   WHERE pr.person_id=ede.dlg_prsnl_id)
   JOIN (e
   WHERE e.encntr_id=ede.encntr_id)
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
   list[cnt].encntrtype = e.encntr_type_cd,
   eks->list[cnt].person_id = ede.person_id, eks->list[cnt].prsnl_id = ede.dlg_prsnl_id, eks->list[
   cnt].trigger.catalog_cd = ede.trigger_entity_id,
   eks->list[cnt].trigger.order_id = ede.trigger_order_id, eks->list[cnt].trigger.order_row_exists =
   0, eks->list[cnt].override_rsn_cd = ede.override_reason_cd,
   eks->list[cnt].override_rsn_lt_id = ede.long_text_id, eks->list[cnt].prsnl_name = pr
   .name_full_formatted, eks->list[cnt].prsnl_position_cd = pr.position_cd,
   eks->list[cnt].fmrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd)), eks->list[cnt].patient_name = p
   .name_full_formatted, eks->list[cnt].facility_cd = e.loc_facility_cd,
   eks->list[cnt].active_ind = 1
  DETAIL
   IF (edea.attr_name="NOMENCLATURE_ID")
    eks->list[cnt].allergy_id = edea.attr_id
   ENDIF
  FOOT REPORT
   stat = alterlist(eks->list,cnt)
  WITH nocounter
 ;end select
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
 SELECT INTO "nl:"
  FROM allergy a,
   nomenclature n,
   (dummyt d  WITH seq = value(size(eks->list,5)))
  PLAN (d)
   JOIN (a
   WHERE (a.allergy_id=eks->list[d.seq].allergy_id))
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  DETAIL
   eks->list[d.seq].source_string = n.source_string, eks->list[d.seq].source_identifier = n
   .source_identifier, eks->list[d.seq].nomenclature_id = n.nomenclature_id,
   eks->list[d.seq].substance_type_cd = a.substance_type_cd, eks->list[d.seq].reaction_class_cd = a
   .reaction_class_cd, eks->list[d.seq].severity_cd = a.severity_cd
  WITH nocounter
 ;end select
 CALL echo("building temporary table")
 SELECT INTO TABLE value(concat("AJT_MULTUM_T"))
  dlg_event_id = eks->list[d.seq].dlg_event_id, active_ind = eks->list[d.seq].active_ind, prsnl_id =
  eks->list[d.seq].prsnl_id,
  encntr_id = eks->list[d.seq].encntr_id, fmrn = eks->list[d.seq].fmrn, person_id = eks->list[d.seq].
  person_id,
  patient_name = eks->list[d.seq].patient_name, prsnl_name = eks->list[d.seq].prsnl_name,
  prsnl_position_cd = eks->list[d.seq].prsnl_position_cd,
  severity = eks->list[d.seq].severity, override_rsn_cd = eks->list[d.seq].override_rsn_cd,
  override_rsn_lt_id = eks->list[d.seq].override_rsn_lt_id,
  override_rsn_ft = eks->list[d.seq].override_rsn_ft, facility_cd = eks->list[d.seq].facility_cd,
  trigger_order_id = eks->list[d.seq].trigger.order_id,
  trigger_catalog_cd = eks->list[d.seq].trigger.catalog_cd, trigger_order_row_exists = eks->list[d
  .seq].trigger.order_row_exists, trigger_catalog_mnemonic = eks->list[d.seq].trigger.
  catalog_mnemonic,
  trigger_order_mnemonic = eks->list[d.seq].trigger.order_mnemonic, trigger_clinical_disp_line = eks
  ->list[d.seq].trigger.clinical_disp_line, trigger_order_dt_tm = eks->list[d.seq].trigger.
  order_dt_tm,
  trigger_drug_class_cd = eks->list[d.seq].trigger.drug_class_cd, trigger_physician_id = eks->list[d
  .seq].trigger.physician_id, trigger_physician_name = eks->list[d.seq].trigger.physician_name,
  trigger_physician_position_cd = eks->list[d.seq].trigger.physician_position_cd, nomenclature_id =
  eks->list[d.seq].nomenclature_id, allergy_id = eks->list[d.seq].allergy_id,
  index = d.seq
  FROM (dummyt d  WITH seq = value(size(eks->list,5)))
  PLAN (d
   WHERE size(eks->list[d.seq].trigger.catalog_mnemonic) > 0)
  ORDER BY dlg_event_id, encntr_id, prsnl_id,
   trigger_catalog_cd, nomenclature_id
 ;end select
 CALL echo("joining temp table to itself to eliminate duplicate alerts")
 SELECT INTO "nl:"
  FROM ajt_multum_t a,
   ajt_multum_t b
  PLAN (a)
   JOIN (b
   WHERE a.dlg_event_id > b.dlg_event_id
    AND a.encntr_id=b.encntr_id
    AND a.prsnl_id=b.prsnl_id
    AND a.trigger_catalog_cd=b.trigger_catalog_cd)
  DETAIL
   IF (((a.nomenclature_id=b.allergy_id) OR (a.nomenclature_id=b.nomenclature_id)) )
    IF (((a.override_rsn_cd > 0) OR (((a.override_rsn_lt_id > 0) OR ((eks->list[b.index].active_ind=0
    ))) )) )
     eks->list[a.index].active_ind = 0
    ELSE
     eks->list[b.index].active_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 RECORD cat_codes(
   1 cnt = i4
   1 list[*]
     2 catalog_cd = f8
     2 cnt = i4
 )
 CALL echo("buildling unique catalog code list")
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
 FREE RECORD reports
 RECORD reports(
   1 qual[*]
     2 patienttype = c1
     2 reportoption = c1
 )
 SET stat = alterlist(reports->qual,4)
 SET reports->qual[1].patienttype = "1"
 SET reports->qual[1].reportoption = "1"
 SET reports->qual[2].patienttype = "2"
 SET reports->qual[2].reportoption = "2"
 SET reports->qual[3].patienttype = "1"
 SET reports->qual[3].reportoption = "2"
 SET reports->qual[4].patienttype = "2"
 SET reports->qual[4].reportoption = "1"
 DECLARE patienttype = c1
 DECLARE reporttype = c1
 FOR (l = 1 TO 4)
   SET output_destfile = build(output_dest,l,".csv")
   SET patienttype = reports->qual[l].patienttype
   SET reporttype = reports->qual[l].reportoption
   IF (patienttype="1")
    SET pat_type2 = "Exclude Outpatients"
   ELSEIF (patienttype="2")
    SET pat_type2 = "All Patient Types"
   ENDIF
   CALL echo("ALL DONE, now output")
   DECLARE output_line = vc
   DECLARE facility_disp = vc
   DECLARE interact_ord_phys_pos = vc
   DECLARE trigger_ord_phys_pos = vc
   DECLARE user_position = vc
   DECLARE override_reason = vc
   DECLARE override_yes_no = vc
   SET report_type = reporttype
   SELECT INTO value(output_destfile)
    trig_mnemonic = eks->list[d.seq].trigger.catalog_mnemonic, allergy_disp = eks->list[d.seq].
    source_string
    FROM (dummyt d  WITH seq = value(size(eks->list,5)))
    PLAN (d
     WHERE (((eks->list[d.seq].encntrtype IN (obs_enc_type_cd, inp_enc_type_cd, day_enc_type_cd,
     emergency_enc_type_cd, disch_inp_enc_type_cd,
     disch_obs_enc_type_cd, disch_day_enc_type_cd, disch_es_enc_type_cd, exp_inp_enc_type_cd,
     exp_obs_enc_type_cd,
     exp_day_enc_type_cd, exp_es_enc_type_cd))
      AND patienttype="1") OR (patienttype="2"))
      AND (eks->list[d.seq].active_ind=1)
      AND (eks->list[d.seq].trigger.orig_ord_as_flag != 1)
      AND size(eks->list[d.seq].trigger.catalog_mnemonic) > 0)
    ORDER BY trig_mnemonic, allergy_disp
    HEAD REPORT
     count_1 = 0.00, count_2 = 0.00, count_3 = 0.00,
     count_4 = 0.00, percent_1 = 0.00, percent_2 = 0.00,
     percent_3 = 0.00, col 1, ',"Baystate Health",',
     row + 1, col 1, ',"Drug Allergy Interaction Report",',
     row + 1, col 1, ',"Beginning Date: ',
     beg_date_disp, '",', row + 1,
     col 1, ',"Ending Date: ', end_date_disp,
     '",', row + 1
     IF (report_type="2")
      col 1, ',"Detail Report: ', pat_type2,
      '",', row + 1, output_line = build(',"',"Triggering Drug",'","',"Allergy",'","',
       "Severity",'","',"Reaction Class",'","',"Exact Match",
       '","',"Patient Name",'","',"Facility",'","',
       "Ordering Physician",'","',"Ordering Physician Position",'","',"FMRN",
       '","',"Order Date",'","',"User Position",'","',
       "Order ID",'","',"Override Reason",'","',"Free-text Override Reason",
       '","',"Severity",'","',"Overridden?",'","',
       "Triggering Order Detail",'",'),
      col 1, output_line, row + 1
     ELSEIF (report_type="1")
      col 1, ',"Summary Report: ', pat_type2,
      '",', row + 1, output_line = build(',"',"Triggering Drug",'","',"Allergy",'","',
       "# Interact",'","',"# Override",'","',"% Overridden",
       '","',"# Not Overridden",'","',"% Not Overridden",'","',
       "# Total Orders",'","',"Total % Interact",'",'),
      col 1, output_line, row + 1
     ENDIF
    HEAD trig_mnemonic
     row + 0
    HEAD allergy_disp
     interact_count = 0.00, override_count = 0.00, override_percent = 0.00
    DETAIL
     interact_count = (interact_count+ 1)
     IF ((eks->list[d.seq].trigger.order_id > 0)
      AND (eks->list[d.seq].trigger.order_row_exists=1))
      override_count = (override_count+ 1)
     ENDIF
     IF (report_type="2")
      facility_disp = substring(1,40,uar_get_code_display(eks->list[d.seq].facility_cd)),
      trigger_ord_phys_pos = substring(1,40,uar_get_code_display(eks->list[d.seq].trigger.
        physician_position_cd)), user_position = substring(1,40,uar_get_code_display(eks->list[d.seq]
        .prsnl_position_cd)),
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
      IF ((substring(9,6,eks->list[d.seq].trigger.cki)=eks->list[d.seq].source_identifier))
       exact_match = "Y"
      ELSE
       exact_match = "N"
      ENDIF
      output_line = build(',"',eks->list[d.seq].trigger.order_mnemonic,'","',eks->list[d.seq].
       source_string,'","',
       allergy_severity,'","',allergy_reaction_class,'","',exact_match,
       '","',eks->list[d.seq].patient_name,'","',facility_disp,'","',
       eks->list[d.seq].trigger.physician_name,'","',trigger_ord_phys_pos,'","',eks->list[d.seq].fmrn,
       '","',order_date_disp,'","',user_position,'","',
       eks->list[d.seq].trigger.order_id,'","',override_reason,'","',eks->list[d.seq].override_rsn_ft,
       '","',eks->list[d.seq].severity,'","',override_yes_no,'","',
       eks->list[d.seq].trigger.clinical_disp_line,'",'), col 1, output_line,
      row + 1
     ENDIF
    FOOT  allergy_disp
     IF (report_type="1")
      override_percent = 0.00
      IF (interact_count > 0.00)
       override_percent = round(((override_count * 100)/ interact_count),2)
      ENDIF
      not_override_count = (interact_count - override_count), not_override_percent = round(((
       not_override_count/ interact_count) * 100),2)
      FOR (i = 1 TO size(cat_codes->list,5))
        IF ((cat_codes->list[i].catalog_cd=eks->list[d.seq].trigger.catalog_cd))
         tot_cnt = (cat_codes->list[i].cnt+ not_override_count)
        ENDIF
      ENDFOR
      alert_percent = 0.00, alert_percent = round(((interact_count * 100)/ tot_cnt),2), output_line
       = build(',"',eks->list[d.seq].trigger.order_mnemonic,'","',eks->list[d.seq].source_string,
       '","',
       interact_count,'","',override_count,'","',override_percent,
       '","',not_override_count,'","',not_override_percent,'","',
       tot_cnt,'",',alert_percent,","),
      col 1, output_line, row + 1
     ENDIF
     count_1 = (count_1+ interact_count), count_2 = (count_2+ override_count), count_3 = (count_3+
     not_override_count),
     count_4 = (count_4+ tot_cnt)
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
     format = variable
   ;end select
   IF (email_ind=1)
    EXECUTE bhs_ma_email_file
    CALL emailfile(output_destfile,output_destfile,"naser.sanjar2@bhs.org","multum dai reports",1)
   ENDIF
 ENDFOR
#end_prog
END GO

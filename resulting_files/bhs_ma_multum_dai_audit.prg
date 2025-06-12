CREATE PROGRAM bhs_ma_multum_dai_audit
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 action_dt_tm = dq8
   1 beg_date = dq8
   1 end_date = dq8
   1 list_cnt = i4
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
 FREE RECORD cat_codes
 RECORD cat_codes(
   1 cnt = i4
   1 list[*]
     2 catalog_cd = f8
     2 cnt = i4
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE ip1_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE ip2_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE ip3_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITIP"))
 DECLARE ip4_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE ip5_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"))
 DECLARE ip6_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE ip7_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITDAYSTAY"))
 DECLARE ip8_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHDAYSTAY"))
 DECLARE ip9_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE ip10_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV"))
 DECLARE ip11_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY"))
 DECLARE ip12_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE ip13_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES"))
 DECLARE ip14_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES"))
 DECLARE fin_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE order_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE encounter_type = vc
 DECLARE dclcom = vc
 DECLARE t_line = vc
 DECLARE len = i4
 DECLARE subject_line = vc
 IF (validate(request->batch_selection))
  SET t_record->action_dt_tm = cnvtdatetime(request->ops_date)
  IF ((t_record->action_dt_tm <= 0))
   SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
  ENDIF
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (25))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"M","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"M","E","E")
  SET email_list =  $1
 ELSE
  SET t_record->beg_date = cnvtdatetime("01-SEP-2009 00:00:00")
  SET t_record->end_date = cnvtdatetime("30-SEP-2009 23:59:59")
  SET email_list = "naser.sanjar@bhs.org"
 ENDIF
 SELECT INTO "nl:"
  FROM eks_dlg_event ede,
   eks_dlg_event_attr edea,
   prsnl pr,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (ede
   WHERE trim(ede.dlg_name)="MUL_MED!DRUGALLERGY"
    AND ede.updt_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND ede.updt_dt_tm <= cnvtdatetime(t_record->end_date))
   JOIN (edea
   WHERE edea.dlg_event_id=ede.dlg_event_id)
   JOIN (pr
   WHERE pr.person_id=ede.dlg_prsnl_id)
   JOIN (e
   WHERE e.encntr_id=ede.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ea.active_ind=1)
   JOIN (p
   WHERE p.person_id=ede.person_id)
  ORDER BY ede.encntr_id, ede.dlg_prsnl_id, ede.trigger_entity_id,
   ede.dlg_event_id DESC
  HEAD ede.encntr_id
   null
  HEAD ede.dlg_prsnl_id
   row + 0
  HEAD ede.trigger_entity_id
   t_record->list_cnt = (t_record->list_cnt+ 1)
   IF (mod(t_record->list_cnt,10000)=1)
    stat = alterlist(t_record->list,(t_record->list_cnt+ 9999))
   ENDIF
   t_record->list[t_record->list_cnt].dlg_event_id = ede.dlg_event_id, t_record->list[t_record->
   list_cnt].encntr_id = ede.encntr_id, t_record->list[t_record->list_cnt].encntrtype = e
   .encntr_type_cd,
   t_record->list[t_record->list_cnt].person_id = ede.person_id, t_record->list[t_record->list_cnt].
   prsnl_id = ede.dlg_prsnl_id, t_record->list[t_record->list_cnt].trigger.catalog_cd = ede
   .trigger_entity_id,
   t_record->list[t_record->list_cnt].trigger.order_id = ede.trigger_order_id, t_record->list[
   t_record->list_cnt].trigger.order_row_exists = 0, t_record->list[t_record->list_cnt].
   override_rsn_cd = ede.override_reason_cd,
   t_record->list[t_record->list_cnt].override_rsn_lt_id = ede.long_text_id, t_record->list[t_record
   ->list_cnt].prsnl_name = pr.name_full_formatted, t_record->list[t_record->list_cnt].
   prsnl_position_cd = pr.position_cd,
   t_record->list[t_record->list_cnt].fmrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd)), t_record->
   list[t_record->list_cnt].patient_name = p.name_full_formatted, t_record->list[t_record->list_cnt].
   facility_cd = e.loc_facility_cd,
   t_record->list[t_record->list_cnt].active_ind = 1
  DETAIL
   IF (edea.attr_name="NOMENCLATURE_ID")
    t_record->list[t_record->list_cnt].allergy_id = edea.attr_id
   ENDIF
  FOOT REPORT
   stat = alterlist(t_record->list,t_record->list_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   orders o,
   order_catalog oc,
   order_action oa,
   prsnl pr,
   dummyt d2
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=t_record->list[d.seq].trigger.catalog_cd))
   JOIN (d2)
   JOIN (o
   WHERE (o.order_id=t_record->list[d.seq].trigger.order_id))
   JOIN (oa
   WHERE (oa.order_id=t_record->list[d.seq].trigger.order_id)
    AND oa.action_type_cd=order_cd)
   JOIN (pr
   WHERE pr.person_id=outerjoin(oa.order_provider_id))
  DETAIL
   t_record->list[d.seq].trigger.catalog_mnemonic = oc.primary_mnemonic, t_record->list[d.seq].
   trigger.order_mnemonic = oc.primary_mnemonic, t_record->list[d.seq].trigger.clinical_disp_line = o
   .clinical_display_line,
   t_record->list[d.seq].trigger.order_dt_tm = o.orig_order_dt_tm, t_record->list[d.seq].trigger.
   physician_id = pr.person_id, t_record->list[d.seq].trigger.physician_name = pr.name_full_formatted,
   t_record->list[d.seq].trigger.physician_position_cd = pr.position_cd, t_record->list[d.seq].
   trigger.cki = oc.cki, t_record->list[d.seq].trigger.orig_ord_as_flag = o.orig_ord_as_flag
   IF (o.order_id > 0)
    t_record->list[d.seq].trigger.order_row_exists = 1
   ENDIF
  WITH outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   nomenclature n
  PLAN (d)
   JOIN (n
   WHERE (n.nomenclature_id=t_record->list[d.seq].allergy_id))
  DETAIL
   t_record->list[d.seq].source_string = n.source_string, t_record->list[d.seq].source_identifier = n
   .source_identifier, t_record->list[d.seq].nomenclature_id = n.nomenclature_id
  WITH nocounter
 ;end select
 SELECT INTO TABLE multum_t
  dlg_event_id = t_record->list[d.seq].dlg_event_id, active_ind = t_record->list[d.seq].active_ind,
  prsnl_id = t_record->list[d.seq].prsnl_id,
  encntr_id = t_record->list[d.seq].encntr_id, override_rsn_cd = t_record->list[d.seq].
  override_rsn_cd, override_rsn_lt_id = t_record->list[d.seq].override_rsn_lt_id,
  trigger_catalog_cd = t_record->list[d.seq].trigger.catalog_cd, nomenclature_id = t_record->list[d
  .seq].nomenclature_id, allergy_id = t_record->list[d.seq].allergy_id,
  index = d.seq
  FROM (dummyt d  WITH seq = t_record->list_cnt)
  PLAN (d
   WHERE size(t_record->list[d.seq].trigger.catalog_mnemonic) > 0)
  ORDER BY dlg_event_id, encntr_id, prsnl_id,
   trigger_catalog_cd, nomenclature_id
 ;end select
 SELECT INTO "nl:"
  FROM multum_t a,
   multum_t b
  PLAN (a)
   JOIN (b
   WHERE a.dlg_event_id > b.dlg_event_id
    AND a.encntr_id=b.encntr_id
    AND a.prsnl_id=b.prsnl_id
    AND a.trigger_catalog_cd=b.trigger_catalog_cd)
  DETAIL
   IF (((a.nomenclature_id=b.allergy_id) OR (a.nomenclature_id=b.nomenclature_id)) )
    IF (((a.override_rsn_cd > 0) OR (((a.override_rsn_lt_id > 0) OR ((t_record->list[b.index].
    active_ind=0))) )) )
     t_record->list[a.index].active_ind = 0
    ELSE
     t_record->list[b.index].active_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 DROP TABLE multum_t
 SET dclcom = "rm -f multum_t*"
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
 SELECT INTO "nl:"
  FROM order_action oa,
   orders o
  PLAN (oa
   WHERE oa.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND oa.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND oa.action_type_cd=order_cd)
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
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   long_text lt
  PLAN (d)
   JOIN (lt
   WHERE (lt.long_text_id=t_record->list[d.seq].override_rsn_lt_id))
  DETAIL
   t_record->list[d.seq].override_rsn_ft = lt.long_text
  WITH nocounter
 ;end select
 SET stat = remove("dai_detail.xls.gz")
 SET stat = remove("dai_ip_summary.xls")
 SET stat = remove("dai_op_summary.xls")
 SELECT INTO "dai_detail.xls"
  trig_mnemonic = t_record->list[d.seq].trigger.catalog_mnemonic, allergy_disp = t_record->list[d.seq
  ].source_string
  FROM (dummyt d  WITH seq = value(size(t_record->list,5)))
  PLAN (d
   WHERE (t_record->list[d.seq].active_ind=1)
    AND (t_record->list[d.seq].trigger.orig_ord_as_flag != 1)
    AND size(t_record->list[d.seq].trigger.catalog_mnemonic) > 0)
  ORDER BY trig_mnemonic, allergy_disp
  HEAD REPORT
   t_line = "Drug Allergy Interaction Report Detail", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q")), col 0,
   t_line, row + 1, t_line = concat("Triggering Drug",char(9),"Allergy",char(9),"Severity",
    char(9),"Reaction Class",char(9),"Exact Match",char(9),
    "Patient Name",char(9),"Encounter Type",char(9),"Facility",
    char(9),"Ordering Physician",char(9),"Ordering Physician Position",char(9),
    "FMRN",char(9),"Order Date",char(9),"User Position",
    char(9),"Order ID",char(9),"Override Reason",char(9),
    "Free-text Override Reason",char(9),"Overridden?",char(9),"Triggering Order Detail"),
   col 0, t_line, row + 1
  DETAIL
   facility_disp = substring(1,40,uar_get_code_display(t_record->list[d.seq].facility_cd)),
   trigger_ord_phys_pos = substring(1,40,uar_get_code_display(t_record->list[d.seq].trigger.
     physician_position_cd)), user_position = substring(1,40,uar_get_code_display(t_record->list[d
     .seq].prsnl_position_cd)),
   override_reason = substring(1,100,uar_get_code_display(t_record->list[d.seq].override_rsn_cd)),
   order_date_disp = format(t_record->list[d.seq].trigger.order_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   allergy_severity = uar_get_code_display(t_record->list[d.seq].severity_cd),
   allergy_reaction_class = uar_get_code_display(t_record->list[d.seq].reaction_class_cd)
   IF ((t_record->list[d.seq].trigger.order_id > 0)
    AND (t_record->list[d.seq].trigger.order_row_exists=1))
    override_yes_no = "Y"
   ELSE
    override_yes_no = "N"
   ENDIF
   IF ((substring(9,6,t_record->list[d.seq].trigger.cki)=t_record->list[d.seq].source_identifier))
    exact_match = "Y"
   ELSE
    exact_match = "N"
   ENDIF
   IF ((t_record->list[d.seq].encntrtype IN (ip1_cd, ip2_cd, ip3_cd, ip4_cd, ip5_cd,
   ip6_cd, ip7_cd, ip8_cd, ip9_cd, ip10_cd,
   ip11_cd, ip12_cd, ip13_cd, ip14_cd)))
    encounter_type = "Inpatient"
   ELSE
    encounter_type = "Outpatient"
   ENDIF
   t_line = concat(t_record->list[d.seq].trigger.order_mnemonic,char(9),t_record->list[d.seq].
    source_string,char(9),allergy_severity,
    char(9),allergy_reaction_class,char(9),exact_match,char(9),
    t_record->list[d.seq].patient_name,char(9),encounter_type,char(9),facility_disp,
    char(9),t_record->list[d.seq].trigger.physician_name,char(9),trigger_ord_phys_pos,char(9),
    t_record->list[d.seq].fmrn,char(9),order_date_disp,char(9),user_position,
    char(9),trim(cnvtstring(t_record->list[d.seq].trigger.order_id)),char(9),override_reason,char(9),
    t_record->list[d.seq].override_rsn_ft,char(9),override_yes_no,char(9),t_record->list[d.seq].
    trigger.clinical_disp_line), col 0, t_line,
   row + 1
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 SELECT INTO "dai_ip_summary.xls"
  trig_mnemonic = t_record->list[d.seq].trigger.catalog_mnemonic, allergy_disp = t_record->list[d.seq
  ].source_string
  FROM (dummyt d  WITH seq = value(size(t_record->list,5)))
  PLAN (d
   WHERE (t_record->list[d.seq].encntrtype IN (ip1_cd, ip2_cd, ip3_cd, ip4_cd, ip5_cd,
   ip6_cd, ip7_cd, ip8_cd, ip9_cd, ip10_cd,
   ip11_cd, ip12_cd, ip13_cd, ip14_cd))
    AND (t_record->list[d.seq].active_ind=1)
    AND (t_record->list[d.seq].trigger.orig_ord_as_flag != 1)
    AND size(t_record->list[d.seq].trigger.catalog_mnemonic) > 0)
  ORDER BY trig_mnemonic, allergy_disp
  HEAD REPORT
   count_1 = 0.00, count_2 = 0.00, count_3 = 0.00,
   count_4 = 0.00, percent_1 = 0.00, percent_2 = 0.00,
   percent_3 = 0.00, t_line = "Drug Allergy Interaction Report Inpatient Summary", col 0,
   t_line, row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(
     t_record->end_date,"DD-MMM-YYYY;;Q")),
   col 0, t_line, row + 1,
   t_line = concat("Triggering Drug",char(9),"Allergy",char(9),"# Interact",
    char(9),"# Override",char(9),"% Overridden",char(9),
    "# Not Overridden",char(9),"% Not Overridden",char(9),"# Total Orders",
    char(9),"Total % Interact"), col 0, t_line,
   row + 1
  HEAD allergy_disp
   interact_count = 0.00, override_count = 0.00, override_percent = 0.00
  DETAIL
   interact_count = (interact_count+ 1)
   IF ((t_record->list[d.seq].trigger.order_id > 0)
    AND (t_record->list[d.seq].trigger.order_row_exists=1))
    override_count = (override_count+ 1)
   ENDIF
  FOOT  allergy_disp
   override_percent = 0.00
   IF (interact_count > 0.00)
    override_percent = round(((override_count * 100)/ interact_count),2)
   ENDIF
   not_override_count = (interact_count - override_count), not_override_percent = round(((
    not_override_count/ interact_count) * 100),2)
   FOR (i = 1 TO size(cat_codes->list,5))
     IF ((cat_codes->list[i].catalog_cd=t_record->list[d.seq].trigger.catalog_cd))
      tot_cnt = (cat_codes->list[i].cnt+ not_override_count)
     ENDIF
   ENDFOR
   alert_percent = 0.00, alert_percent = round(((interact_count * 100)/ tot_cnt),2), t_line = build(
    t_record->list[d.seq].trigger.order_mnemonic,char(9),t_record->list[d.seq].source_string,char(9),
    interact_count,
    char(9),override_count,char(9),override_percent,char(9),
    not_override_count,char(9),not_override_percent,char(9),tot_cnt,
    char(9),alert_percent),
   col 0, t_line, row + 1,
   count_1 = (count_1+ interact_count), count_2 = (count_2+ override_count), count_3 = (count_3+
   not_override_count),
   count_4 = (count_4+ tot_cnt)
  FOOT REPORT
   row + 1, percent_1 = round(((count_2/ count_1) * 100),2), percent_2 = round(((count_3/ count_1) *
    100),2),
   percent_3 = round(((count_1/ count_4) * 100),2), t_line = build("Totals",char(9),char(9),count_1,
    char(9),
    count_2,char(9),percent_1,char(9),count_3,
    char(9),percent_2,char(9),count_4,char(9),
    percent_3), col 0,
   t_line
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 SELECT INTO "dai_op_summary.xls"
  trig_mnemonic = t_record->list[d.seq].trigger.catalog_mnemonic, allergy_disp = t_record->list[d.seq
  ].source_string, encntr_type = uar_get_code_display(t_record->list[d.seq].encntrtype)
  FROM (dummyt d  WITH seq = value(size(t_record->list,5)))
  PLAN (d
   WHERE  NOT ((t_record->list[d.seq].encntrtype IN (ip1_cd, ip2_cd, ip3_cd, ip4_cd, ip5_cd,
   ip6_cd, ip7_cd, ip8_cd, ip9_cd, ip10_cd,
   ip11_cd, ip12_cd, ip13_cd, ip14_cd)))
    AND (t_record->list[d.seq].active_ind=1)
    AND (t_record->list[d.seq].trigger.orig_ord_as_flag != 1)
    AND size(t_record->list[d.seq].trigger.catalog_mnemonic) > 0)
  ORDER BY trig_mnemonic, allergy_disp
  HEAD REPORT
   count_1 = 0.00, count_2 = 0.00, count_3 = 0.00,
   count_4 = 0.00, percent_1 = 0.00, percent_2 = 0.00,
   percent_3 = 0.00, t_line = "Drug Allergy Interaction Report outpatient Summary", col 0,
   t_line, row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(
     t_record->end_date,"DD-MMM-YYYY;;Q")),
   col 0, t_line, row + 1,
   t_line = concat("Triggering Drug",char(9),"Allergy",char(9),"# Interact",
    char(9),"# Override",char(9),"% Overridden",char(9),
    "# Not Overridden",char(9),"% Not Overridden",char(9),"# Total Orders",
    char(9),"Total % Interact"), col 0, t_line,
   row + 1
  HEAD allergy_disp
   interact_count = 0.00, override_count = 0.00, override_percent = 0.00
  DETAIL
   interact_count = (interact_count+ 1)
   IF ((t_record->list[d.seq].trigger.order_id > 0)
    AND (t_record->list[d.seq].trigger.order_row_exists=1))
    override_count = (override_count+ 1)
   ENDIF
  FOOT  allergy_disp
   override_percent = 0.00
   IF (interact_count > 0.00)
    override_percent = round(((override_count * 100)/ interact_count),2)
   ENDIF
   not_override_count = (interact_count - override_count), not_override_percent = round(((
    not_override_count/ interact_count) * 100),2)
   FOR (i = 1 TO size(cat_codes->list,5))
     IF ((cat_codes->list[i].catalog_cd=t_record->list[d.seq].trigger.catalog_cd))
      tot_cnt = (cat_codes->list[i].cnt+ not_override_count)
     ENDIF
   ENDFOR
   alert_percent = 0.00, alert_percent = round(((interact_count * 100)/ tot_cnt),2), t_line = build(
    t_record->list[d.seq].trigger.order_mnemonic,char(9),t_record->list[d.seq].source_string,char(9),
    interact_count,
    char(9),override_count,char(9),override_percent,char(9),
    not_override_count,char(9),not_override_percent,char(9),tot_cnt,
    char(9),alert_percent),
   col 0, t_line, row + 1,
   count_1 = (count_1+ interact_count), count_2 = (count_2+ override_count), count_3 = (count_3+
   not_override_count),
   count_4 = (count_4+ tot_cnt)
  FOOT REPORT
   row + 1, percent_1 = round(((count_2/ count_1) * 100),2), percent_2 = round(((count_3/ count_1) *
    100),2),
   percent_3 = round(((count_1/ count_4) * 100),2), t_line = build("Totals",char(9),char(9),count_1,
    char(9),
    count_2,char(9),percent_1,char(9),count_3,
    char(9),percent_2,char(9),count_4,char(9),
    percent_3), col 0,
   t_line
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 IF (findfile("dai_detail.xls")=1
  AND findfile("dai_ip_summary.xls")=1
  AND findfile("dai_op_summary.xls")=1)
  SET subject_line = concat("Multum DAI Reports ",format(t_record->beg_date,"DD-MMM-YYYY HH:MM;;Q"),
   " to ",format(t_record->end_date,"DD-MMM-YYYY HH:MM;;Q"))
  SET dclcom = concat('echo " " | mailx -s "',subject_line,'" ','-a "dai_detail.xls" ',
   '-a "dai_ip_summary.xls" ',
   '-a "dai_op_summary.xls" ',email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("dai_detail.xls")
  SET stat = remove("dai_op_summary.xls")
  SET stat = remove("dai_ip_summary.xls")
 ENDIF
#exit_script
 SET reply->status_data[1].status = "S"
END GO

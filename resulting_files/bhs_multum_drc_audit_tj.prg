CREATE PROGRAM bhs_multum_drc_audit_tj
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
     2 pat_age = vc
     2 pat_weight = vc
     2 creatinine = vc
     2 creatinine_clearance = vc
     2 aa_gfr = vc
     2 naa_gfr = vc
     2 alert_message = vc
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
 DECLARE weight_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE crea_clr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CREATININECLEARANCE"))
 DECLARE aa_gfr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ESTIMATEDGFRAFRICANAMERICAN"))
 DECLARE naa_gfr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDGFRNONAFRICANAMERICAN"))
 DECLARE crea_cd = f8
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=72
    AND c.display_key="CREATININEBLOOD"
    AND c.display="Creatinine-Blood"
    AND c.active_ind=1)
  DETAIL
   crea_cd = c.code_value
  WITH nocounter
 ;end select
 DECLARE fin_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE order_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE encounter_type = vc
 DECLARE dclcom = vc
 DECLARE t_line = vc
 DECLARE ib = vc
 DECLARE ibl = i4
 DECLARE ob = c32000 WITH noconstant("")
 DECLARE obl = i4 WITH noconstant(32000)
 DECLARE rbl = i4 WITH noconstant(0)
 DECLARE rtf_ind = i2
 IF (validate(request->batch_selection))
  SET t_record->action_dt_tm = cnvtdatetime(request->ops_date)
  IF ((t_record->action_dt_tm <= 0))
   SET t_record->action_dt_tm = cnvtdatetime(sysdate)
  ENDIF
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (25))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"M","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"M","E","E")
  SET email_list =  $1
 ENDIF
 SET t_record->beg_date = cnvtdatetime("01-DEC-2007 00:00:00")
 SET t_record->end_date = cnvtdatetime("31-DEC-2007 23:59:59")
 SET email_list = "anthony.jacobson@bhs.org"
 SELECT INTO "nl:"
  FROM eks_dlg_event ede,
   prsnl pr,
   encounter e,
   person p,
   encntr_alias ea,
   long_text l
  PLAN (ede
   WHERE trim(ede.dlg_name)="PHA_EKM!PHA_DRC_DEV2"
    AND ede.updt_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND ede.updt_dt_tm <= cnvtdatetime(t_record->end_date)
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
   WHERE e.encntr_id=ede.encntr_id)
   JOIN (l
   WHERE (l.long_text_id= Outerjoin(ede.alert_long_text_id))
    AND (l.active_ind= Outerjoin(1)) )
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ea.active_ind=1)
   JOIN (p
   WHERE p.person_id=ede.person_id)
  ORDER BY ede.encntr_id, ede.dlg_prsnl_id, ede.trigger_entity_id,
   ede.dlg_event_id DESC
  HEAD ede.encntr_id
   null
  HEAD ede.dlg_prsnl_id
   null
  HEAD ede.trigger_entity_id
   t_record->list_cnt += 1
   IF (mod(t_record->list_cnt,100)=1)
    stat = alterlist(t_record->list,(t_record->list_cnt+ 99))
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
   t_record->list[t_record->list_cnt].active_ind = 1, rtf_ind = 0, ib = l.long_text
   IF (size(ib) > 6)
    IF (substring(1,7,ib)="{\rtf1\")
     rtf_ind = 1
    ENDIF
   ENDIF
   IF (rtf_ind=1)
    ibl = size(ib),
    CALL uar_rtf(ib,ibl,ob,obl,rbl,0), ob = trim(ob,1),
    t_record->list[t_record->list_cnt].alert_message = ob
   ELSE
    t_record->list[t_record->list_cnt].alert_message = trim(l.long_text,1)
   ENDIF
  FOOT REPORT
   stat = alterlist(t_record->list,t_record->list_cnt)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=t_record->list[d.seq].trigger.catalog_cd))
  DETAIL
   t_record->list[d.seq].trigger.catalog_mnemonic = oc.primary_mnemonic, t_record->list[d.seq].
   trigger.order_mnemonic = oc.primary_mnemonic, t_record->list[d.seq].trigger.cki = oc.cki
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   orders o,
   order_action oa,
   prsnl pr,
   person p
  PLAN (d)
   JOIN (o
   WHERE (o.order_id= Outerjoin(t_record->list[d.seq].trigger.order_id)) )
   JOIN (oa
   WHERE (oa.order_id= Outerjoin(o.order_id))
    AND (oa.action_type_cd= Outerjoin(order_cd)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(oa.order_provider_id)) )
   JOIN (p
   WHERE (p.person_id= Outerjoin(o.person_id)) )
  DETAIL
   t_record->list[d.seq].trigger.clinical_disp_line = o.clinical_display_line, t_record->list[d.seq].
   trigger.order_dt_tm = o.orig_order_dt_tm, t_record->list[d.seq].trigger.physician_id = pr
   .person_id,
   t_record->list[d.seq].trigger.physician_name = pr.name_full_formatted, t_record->list[d.seq].
   trigger.physician_position_cd = pr.position_cd, t_record->list[d.seq].trigger.orig_ord_as_flag = o
   .orig_ord_as_flag,
   t_record->list[d.seq].pat_age = cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),
    o.orig_order_dt_tm,0)
   IF (o.order_id > 0)
    t_record->list[d.seq].trigger.order_row_exists = 1
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   orders o,
   clinical_event ce
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=t_record->list[d.seq].trigger.order_id))
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ce.event_end_dt_tm <= o.orig_order_dt_tm
    AND ce.event_cd=crea_cd
    AND ce.result_units_cd > 0.00
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY o.order_id, ce.clinsig_updt_dt_tm DESC
  HEAD o.order_id
   t_record->list[d.seq].creatinine = ce.result_val
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   orders o,
   clinical_event ce
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=t_record->list[d.seq].trigger.order_id))
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ce.event_end_dt_tm <= o.orig_order_dt_tm
    AND ce.event_cd=weight_cd
    AND ce.result_units_cd > 0.00
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY o.order_id, ce.clinsig_updt_dt_tm DESC
  HEAD o.order_id
   t_record->list[d.seq].pat_weight = ce.result_val
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   orders o,
   clinical_event ce
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=t_record->list[d.seq].trigger.order_id))
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ce.event_end_dt_tm <= o.orig_order_dt_tm
    AND ce.event_cd=crea_clr_cd
    AND ce.result_units_cd > 0.00
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY o.order_id, ce.clinsig_updt_dt_tm DESC
  HEAD o.order_id
   t_record->list[d.seq].creatinine_clearance = ce.result_val
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   orders o,
   clinical_event ce
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=t_record->list[d.seq].trigger.order_id))
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ((ce.clinsig_updt_dt_tm+ 0) <= o.orig_order_dt_tm)
    AND ce.event_cd=aa_gfr_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY o.order_id, ce.clinsig_updt_dt_tm DESC
  HEAD o.order_id
   t_record->list[d.seq].aa_gfr = ce.result_val
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   orders o,
   clinical_event ce
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=t_record->list[d.seq].trigger.order_id))
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ((ce.clinsig_updt_dt_tm+ 0) <= o.orig_order_dt_tm)
    AND ce.event_cd=naa_gfr_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY o.order_id, ce.clinsig_updt_dt_tm DESC
  HEAD o.order_id
   t_record->list[d.seq].naa_gfr = ce.result_val
  WITH maxcol = 1000
 ;end select
 FOR (i = 1 TO t_record->list_cnt)
  SET found = 0
  IF ((t_record->list[i].active_ind=1))
   FOR (j = 1 TO cat_codes->cnt)
     IF ((cat_codes->list[j].catalog_cd=t_record->list[i].trigger.catalog_cd))
      SET found = 1
      SET j = (cat_codes->cnt+ 1)
     ENDIF
   ENDFOR
   IF (found=0)
    SET cat_codes->cnt += 1
    IF (mod(cat_codes->cnt,10)=1)
     SET stat = alterlist(cat_codes->list,(cat_codes->cnt+ 9))
    ENDIF
    SET cat_codes->list[cat_codes->cnt].catalog_cd = t_record->list[i].trigger.catalog_cd
   ENDIF
  ENDIF
 ENDFOR
 SET stat = alterlist(cat_codes->list,cat_codes->cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(cat_codes->list,5))),
   order_action oa,
   orders o
  PLAN (d)
   JOIN (oa
   WHERE oa.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND oa.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND oa.action_type_cd=order_cd)
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND ((o.catalog_cd+ 0)=cat_codes->list[d.seq].catalog_cd))
  ORDER BY o.catalog_cd, o.order_id
  HEAD o.catalog_cd
   ord_cnt = 0
  DETAIL
   ord_cnt += 1
  FOOT  o.catalog_cd
   cat_codes->list[d.seq].cnt = ord_cnt
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   long_text lt
  PLAN (d)
   JOIN (lt
   WHERE (lt.long_text_id=t_record->list[d.seq].override_rsn_lt_id))
  DETAIL
   t_record->list[d.seq].override_rsn_ft = lt.long_text
  WITH maxcol = 1000
 ;end select
 SET stat = remove("drc_detail.xls.gz")
 SET stat = remove("drc_summary.xls")
 SELECT INTO "drc_detail.xls"
  trig_mnemonic = t_record->list[d.seq].trigger.catalog_mnemonic, allergy_disp = t_record->list[d.seq
  ].source_string
  FROM (dummyt d  WITH seq = t_record->list_cnt)
  PLAN (d
   WHERE (t_record->list[d.seq].active_ind=1)
    AND (t_record->list[d.seq].trigger.orig_ord_as_flag != 1)
    AND size(t_record->list[d.seq].trigger.catalog_mnemonic) > 0)
  ORDER BY trig_mnemonic, allergy_disp
  HEAD REPORT
   t_line = "Dose Range Checking Report Detail", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q")), col 0,
   t_line, row + 1, t_line = concat("Triggering Drug",char(9),"Encounter Type",char(9),"Patient Name",
    char(9),"Age",char(9),"Weight (KG)",char(9),
    "Creatinine",char(9),"Creatinine Clearance",char(9),"Estimated GFR African American",
    char(9),"Estimated GFR Non African American",char(9),"Facility",char(9),
    "Ordering Physician",char(9),"Ordering Physician Position",char(9),"FMRN",
    char(9),"Order Date",char(9),"User Position",char(9),
    "Order ID",char(9),"Override Reason",char(9),"Free-text Override Reason",
    char(9),"Overridden?",char(9),"Triggering Order Detail",char(9),
    "Alert Message"),
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
   IF ((t_record->list[d.seq].encntrtype IN (ip1_cd, ip2_cd, ip3_cd, ip4_cd, ip5_cd,
   ip6_cd, ip7_cd, ip8_cd, ip9_cd, ip10_cd,
   ip11_cd)))
    encounter_type = "Inpatient"
   ELSE
    encounter_type = "Outpatient"
   ENDIF
   t_line = concat(t_record->list[d.seq].trigger.order_mnemonic,char(9),encounter_type,char(9),
    t_record->list[d.seq].patient_name,
    char(9),t_record->list[d.seq].pat_age,char(9),t_record->list[d.seq].pat_weight,char(9),
    t_record->list[d.seq].creatinine,char(9),t_record->list[d.seq].creatinine_clearance,char(9),
    t_record->list[d.seq].aa_gfr,
    char(9),t_record->list[d.seq].naa_gfr,char(9),facility_disp,char(9),
    t_record->list[d.seq].trigger.physician_name,char(9),trigger_ord_phys_pos,char(9),t_record->list[
    d.seq].fmrn,
    char(9),order_date_disp,char(9),user_position,char(9),
    trim(cnvtstring(t_record->list[d.seq].trigger.order_id)),char(9),override_reason,char(9),t_record
    ->list[d.seq].override_rsn_ft,
    char(9),override_yes_no,char(9),t_record->list[d.seq].trigger.clinical_disp_line,char(9),
    trim(t_record->list[d.seq].alert_message)), col 0, t_line,
   row + 1
  WITH maxcol = 32600, formfeed = none, maxrow = 1,
   format = variable, compress
 ;end select
 SELECT INTO "drc_summary.xls"
  trig_mnemonic = t_record->list[d.seq].trigger.catalog_mnemonic, allergy_disp = t_record->list[d.seq
  ].source_string
  FROM (dummyt d  WITH seq = t_record->list_cnt)
  PLAN (d
   WHERE (t_record->list[d.seq].active_ind=1)
    AND (t_record->list[d.seq].trigger.orig_ord_as_flag != 1)
    AND size(t_record->list[d.seq].trigger.catalog_mnemonic) > 0)
  ORDER BY trig_mnemonic, allergy_disp
  HEAD REPORT
   t_line = "Dose Range Checking Report Detail", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q")), col 0,
   t_line, row + 1, t_line = concat("Triggering Drug",char(9),"# Alerts",char(9),"#Overridden",
    char(9),"% Overridden",char(9),"# Not Overridden",char(9),
    "% Not Overridden",char(9),"# Total Orders",char(9),"Total % Alerts"),
   col 0, t_line, row + 1,
   count_1 = 0.00, count_2 = 0.00, count_3 = 0.00,
   count_4 = 0.00
  HEAD trig_mnemonic
   interact_count = 0.00, override_count = 0.00
  HEAD allergy_disp
   override_percent = 0.00
  DETAIL
   IF ((t_record->list[d.seq].trigger.order_id > 0)
    AND (t_record->list[d.seq].trigger.order_row_exists=1))
    override_count += 1
   ENDIF
   interact_count += 1
  FOOT  allergy_disp
   null
  FOOT  trig_mnemonic
   override_percent = round(((override_count * 100)/ interact_count),2), not_overridden = (
   interact_count - override_count), not_override_percent = round(((not_overridden * 100)/
    interact_count),2),
   total_ordered = 0, total_percent = 0.00
   FOR (i = 1 TO size(cat_codes->list,5))
     IF ((cat_codes->list[i].catalog_cd=t_record->list[d.seq].trigger.catalog_cd))
      total_ordered = cat_codes->list[i].cnt, total_percent = round(((interact_count * 100)/
       total_ordered),2)
     ENDIF
   ENDFOR
   t_line = build(t_record->list[d.seq].trigger.order_mnemonic,char(9),interact_count,char(9),
    override_count,
    char(9),override_percent,char(9),not_overridden,char(9),
    not_override_percent,char(9),total_ordered,char(9),total_percent), col 0, t_line,
   row + 1, count_1 += interact_count, count_2 += override_count,
   count_3 += not_overridden, count_4 += total_ordered
  FOOT REPORT
   row + 2, percent_1 = round(((count_2/ count_1) * 100),2), percent_2 = round(((count_3/ count_1) *
    100),2),
   percent_3 = round(((count_1/ count_4) * 100),2), t_line = build("Totals",char(9),count_1,char(9),
    count_2,
    char(9),percent_1,char(9),count_3,char(9),
    percent_2,char(9),count_4,char(9),percent_3), col 0,
   t_line
  WITH maxcol = 32600, formfeed = none, maxrow = 1,
   format = variable, compress
 ;end select
 DECLARE len = i4
 DECLARE subject_line = vc
 DECLARE dclcom = vc
 IF (findfile("drc_detail.xls")=1
  AND findfile("drc_summary.xls")=1)
  SET dclcom = "gzip drc_detail.xls"
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET subject_line = concat("Multum DRC Reports ",format(t_record->beg_date,"DD-MMM-YYYY HH:MM;;Q"),
   " to ",format(t_record->end_date,"DD-MMM-YYYY HH:MM;;Q"))
  SET dclcom = concat('echo " " | mailx -s "',subject_line,'" ','-a "drc_detail.xls.gz" ',
   '-a "drc_summary.xls" ',
   email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("drc_detail.xls.gz")
  SET stat = remove("drc_summary.xls")
 ENDIF
#exit_script
 SET reply->status_data[1].status = "S"
END GO

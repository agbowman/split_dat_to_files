CREATE PROGRAM bhs_multum_ddi_audit_tj
 FREE RECORD t_record
 RECORD t_record(
   1 action_dt_tm = dq8
   1 beg_date = dq8
   1 end_date = dq8
   1 t_beg_date = dq8
   1 t_end_date = dq8
   1 list_cnt = i4
   1 list[*]
     2 dlg_event_id = f8
     2 active_ind = i4
     2 prsnl_id = f8
     2 encntr_id = f8
     2 opind = c1
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
   1 t_list_cnt = i4
   1 t_list[*]
     2 dlg_event_id = f8
     2 active_ind = i4
     2 prsnl_id = f8
     2 encntr_id = f8
     2 opind = c1
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
 DECLARE fin_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE order_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE encounter_type = vc
 DECLARE t_line = vc
 DECLARE facility_disp = vc
 DECLARE interact_ord_phys_pos = vc
 DECLARE trigger_ord_phys_pos = vc
 DECLARE user_position = vc
 DECLARE override_reason = vc
 DECLARE override_yes_no = vc
 DECLARE percent_1 = f8
 IF (validate(request->batch_selection))
  SET t_record->action_dt_tm = cnvtdatetime(request->ops_date)
  IF ((t_record->action_dt_tm <= 0))
   SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
  ENDIF
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (25))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"M","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"M","E","E")
  SET email_list =  $1
 ENDIF
 SET t_record->beg_date = cnvtdatetime("01-DEC-2007 00:00:00")
 SET t_record->end_date = cnvtdatetime("31-DEC-2007 23:59:59")
 SET email_list = "anthony.jacobson@bhs.org"
 SET days_cnt = ceil(datetimediff(t_record->end_date,t_record->beg_date))
 SET t_record->t_beg_date = t_record->beg_date
 FOR (i = 1 TO days_cnt)
   IF (i=1)
    SET t_record->t_end_date = datetimefind(t_record->beg_date,"D","E","E")
   ELSE
    SET t_record->t_beg_date = cnvtdatetime(datetimeadd(t_record->t_beg_date,1))
    SET t_record->t_end_date = cnvtdatetime(datetimefind(t_record->t_beg_date,"D","E","E"))
   ENDIF
   CALL echo("***********************************")
   CALL echo(format(t_record->t_beg_date,";;q"))
   CALL echo(format(t_record->t_end_date,";;q"))
   SELECT INTO "nl:"
    FROM eks_dlg_event ede,
     eks_dlg_event_attr edea,
     prsnl pr,
     encounter e,
     person p,
     encntr_alias ea
    PLAN (ede
     WHERE ede.updt_dt_tm >= cnvtdatetime(t_record->t_beg_date)
      AND ede.updt_dt_tm <= cnvtdatetime(t_record->t_end_date)
      AND trim(ede.dlg_name)="MUL_MED!DRUGDRUG")
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
    ORDER BY ede.dlg_event_id
    HEAD ede.dlg_event_id
     t_record->t_list_cnt = (t_record->t_list_cnt+ 1)
     IF (mod(t_record->t_list_cnt,10000)=1)
      stat = alterlist(t_record->t_list,(t_record->t_list_cnt+ 9999))
     ENDIF
     t_record->t_list[t_record->t_list_cnt].dlg_event_id = ede.dlg_event_id, t_record->t_list[
     t_record->t_list_cnt].encntr_id = ede.encntr_id, t_record->t_list[t_record->t_list_cnt].
     encntrtype = e.encntr_type_cd,
     t_record->t_list[t_record->t_list_cnt].person_id = ede.person_id, t_record->t_list[t_record->
     t_list_cnt].prsnl_id = ede.dlg_prsnl_id, t_record->t_list[t_record->t_list_cnt].trigger.
     catalog_cd = ede.trigger_entity_id,
     t_record->t_list[t_record->t_list_cnt].trigger.order_id = ede.trigger_order_id, t_record->
     t_list[t_record->t_list_cnt].trigger.order_row_exists = 0, t_record->t_list[t_record->t_list_cnt
     ].override_rsn_cd = ede.override_reason_cd,
     t_record->t_list[t_record->t_list_cnt].override_rsn_lt_id = ede.long_text_id, t_record->t_list[
     t_record->t_list_cnt].prsnl_name = trim(pr.name_full_formatted), t_record->t_list[t_record->
     t_list_cnt].prsnl_position_cd = pr.position_cd,
     t_record->t_list[t_record->t_list_cnt].fmrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd)),
     t_record->t_list[t_record->t_list_cnt].patient_name = trim(p.name_full_formatted), t_record->
     t_list[t_record->t_list_cnt].facility_cd = e.loc_facility_cd,
     t_record->t_list[t_record->t_list_cnt].active_ind = 1
    DETAIL
     IF (edea.attr_name="SEVERITY_LEVEL")
      t_record->t_list[t_record->t_list_cnt].severity = edea.attr_id
      IF (edea.attr_id < 3)
       t_record->t_list[t_record->t_list_cnt].active_ind = 0
      ENDIF
     ELSEIF (edea.attr_name="CATALOG_CD")
      t_record->t_list[t_record->t_list_cnt].interact.catalog_cd = edea.attr_id
     ELSEIF (edea.attr_name="ORDER_ID")
      t_record->t_list[t_record->t_list_cnt].interact.order_id = edea.attr_id
     ENDIF
    FOOT REPORT
     stat = alterlist(t_record->t_list,t_record->t_list_cnt)
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = t_record->t_list_cnt),
     order_catalog oc,
     dummyt d2,
     orders o,
     order_action oa,
     prsnl pr
    PLAN (d
     WHERE (t_record->t_list[d.seq].severity >= 3))
     JOIN (oc
     WHERE (oc.catalog_cd=t_record->t_list[d.seq].trigger.catalog_cd))
     JOIN (d2)
     JOIN (o
     WHERE (o.order_id=t_record->t_list[d.seq].trigger.order_id))
     JOIN (oa
     WHERE (oa.order_id=t_record->t_list[d.seq].trigger.order_id)
      AND oa.action_type_cd=order_cd)
     JOIN (pr
     WHERE pr.person_id=outerjoin(oa.order_provider_id))
    DETAIL
     t_record->t_list[d.seq].trigger.order_dt_tm = o.orig_order_dt_tm, t_record->t_list[d.seq].
     trigger.physician_id = pr.person_id, t_record->t_list[d.seq].trigger.physician_name = trim(pr
      .name_full_formatted),
     t_record->t_list[d.seq].trigger.physician_position_cd = pr.position_cd, t_record->t_list[d.seq].
     trigger.orig_ord_as_flag = o.orig_ord_as_flag
     IF (o.order_id > 0)
      t_record->t_list[d.seq].trigger.order_row_exists = 1
     ENDIF
    WITH outerjoin = d2
   ;end select
   SELECT INTO "nl:"
    encntr_id = t_record->t_list[d.seq].encntr_id, prsnl_id = t_record->t_list[d.seq].prsnl_id,
    trigger_catalog_cd = t_record->t_list[d.seq].trigger.catalog_cd,
    trigger_order_id = t_record->t_list[d.seq].trigger.order_id, interact_order_id = t_record->
    t_list[d.seq].interact.order_id, dlg_event_id = t_record->t_list[d.seq].dlg_event_id,
    override_rsn_lt_id = t_record->t_list[d.seq].override_rsn_lt_id, override_rsn_cd = t_record->
    t_list[d.seq].override_rsn_cd, severity = t_record->t_list[d.seq].severity
    FROM (dummyt d  WITH seq = t_record->t_list_cnt)
    PLAN (d
     WHERE (t_record->t_list[d.seq].active_ind=1))
    ORDER BY encntr_id, interact_order_id, trigger_catalog_cd,
     prsnl_id, dlg_event_id
    DETAIL
     t_record->t_list[d.seq].active_ind = 0
    FOOT  interact_order_id
     t_record->t_list[d.seq].active_ind = 1
    WITH maxcol = 1000
   ;end select
   SET xx = t_record->list_cnt
   SET stat = alterlist(t_record->list,(xx+ 100))
   FOR (x = 1 TO t_record->t_list_cnt)
     IF ((t_record->t_list[x].interact.orig_ord_as_flag IN (1, 0))
      AND (t_record->t_list[x].severity >= 3)
      AND (t_record->t_list[x].active_ind=1)
      AND (t_record->t_list[x].trigger.catalog_cd > 0))
      SET xx = (xx+ 1)
      IF (mod(xx,100)=1)
       SET stat = alterlist(t_record->list,(xx+ 99))
      ENDIF
      SET t_record->list[xx].encntrtype = t_record->t_list[x].encntrtype
      SET t_record->list[xx].opind = t_record->t_list[x].opind
      SET t_record->list[xx].dlg_event_id = t_record->t_list[x].dlg_event_id
      SET t_record->list[xx].active_ind = t_record->t_list[x].active_ind
      SET t_record->list[xx].prsnl_id = t_record->t_list[x].prsnl_id
      SET t_record->list[xx].encntr_id = t_record->t_list[x].encntr_id
      SET t_record->list[xx].fmrn = t_record->t_list[x].fmrn
      SET t_record->list[xx].person_id = t_record->t_list[x].person_id
      SET t_record->list[xx].patient_name = t_record->t_list[x].patient_name
      SET t_record->list[xx].prsnl_position_cd = t_record->t_list[x].prsnl_position_cd
      SET t_record->list[xx].severity = t_record->t_list[x].severity
      SET t_record->list[xx].override_rsn_cd = t_record->t_list[x].override_rsn_cd
      SET t_record->list[xx].override_rsn_lt_id = t_record->t_list[x].override_rsn_lt_id
      SET t_record->list[xx].override_rsn_ft = t_record->t_list[x].override_rsn_ft
      SET t_record->list[xx].facility_cd = t_record->t_list[x].facility_cd
      SET t_record->list[xx].trigger.order_id = t_record->t_list[x].trigger.order_id
      SET t_record->list[xx].trigger.catalog_cd = t_record->t_list[x].trigger.catalog_cd
      SET t_record->list[xx].trigger.order_row_exists = t_record->t_list[x].trigger.order_row_exists
      SET t_record->list[xx].trigger.orig_ord_as_flag = t_record->t_list[x].trigger.orig_ord_as_flag
      SET t_record->list[xx].trigger.order_dt_tm = t_record->t_list[x].trigger.order_dt_tm
      SET t_record->list[xx].trigger.drug_class_cd = t_record->t_list[x].trigger.drug_class_cd
      SET t_record->list[xx].trigger.physician_id = t_record->t_list[x].trigger.physician_id
      SET t_record->list[xx].trigger.physician_name = t_record->t_list[x].trigger.physician_name
      SET t_record->list[xx].trigger.physician_position_cd = t_record->t_list[x].trigger.
      physician_position_cd
      SET t_record->list[xx].interact.order_id = t_record->t_list[x].interact.order_id
      SET t_record->list[xx].interact.catalog_cd = t_record->t_list[x].interact.catalog_cd
      SET t_record->list[xx].interact.orig_ord_as_flag = t_record->t_list[x].interact.
      orig_ord_as_flag
      SET t_record->list[xx].interact.order_dt_tm = t_record->t_list[x].interact.order_dt_tm
      SET t_record->list[xx].interact.drug_class_cd = t_record->t_list[x].interact.drug_class_cd
      SET t_record->list[xx].interact.physician_id = t_record->t_list[x].interact.physician_id
      SET t_record->list[xx].interact.physician_name = t_record->t_list[x].interact.physician_name
      SET t_record->list[xx].interact.physician_position_cd = t_record->t_list[x].interact.
      physician_position_cd
     ENDIF
   ENDFOR
   SET t_record->list_cnt = xx
   SET t_record->t_list_cnt = 0
   SET stat = alterlist(t_record->t_list,t_record->t_list_cnt)
 ENDFOR
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
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM long_text lt,
   (dummyt d  WITH seq = t_record->list_cnt)
  PLAN (d
   WHERE (t_record->list[d.seq].override_rsn_lt_id > 0))
   JOIN (lt
   WHERE (lt.long_text_id=t_record->list[d.seq].override_rsn_lt_id))
  DETAIL
   t_record->list[d.seq].override_rsn_ft = lt.long_text
  WITH nocounter
 ;end select
 SET stat = remove("ddi_detail.xls.gz")
 SET stat = remove("ddi_summary.xls")
 SELECT INTO "ddi_detail.xls"
  trig_mnemonic = uar_get_code_display(t_record->list[d.seq].trigger.catalog_cd), interact_mnemonic
   = uar_get_code_display(t_record->list[d.seq].interact.catalog_cd)
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   orders interact,
   orders trgr,
   dummyt d1,
   dummyt d2
  PLAN (d
   WHERE (t_record->list[d.seq].interact.orig_ord_as_flag IN (1, 0))
    AND (t_record->list[d.seq].severity >= 3)
    AND (t_record->list[d.seq].active_ind=1)
    AND (t_record->list[d.seq].trigger.catalog_cd > 0))
   JOIN (d1)
   JOIN (trgr
   WHERE (trgr.order_id=t_record->list[d.seq].trigger.order_id))
   JOIN (d2)
   JOIN (interact
   WHERE (interact.order_id=t_record->list[d.seq].interact.order_id))
  ORDER BY trig_mnemonic, interact_mnemonic
  HEAD REPORT
   t_line = "Drug Drug Interaction Report Detail", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q")), col 0,
   t_line, row + 1, t_line = concat("Triggering Drug",char(9),"Interacting Drug",char(9),
    "Patient Name",
    char(9),"Encounter Type",char(9),"Facility",char(9),
    "Ordering Physician",char(9),"Ordering Physician Position",char(9),"FMRN",
    char(9),"Order Date",char(9),"User Position",char(9),
    "Order ID",char(9),"Override Reason",char(9),"Free-text Override Reason",
    char(9),"Severity",char(9),"Overridden?",char(9),
    "Triggering Order Detail",char(9),"Interacting Order Detail"),
   col 0, t_line, row + 1
  DETAIL
   facility_disp = substring(1,40,uar_get_code_display(t_record->list[d.seq].facility_cd)),
   interact_ord_phys_pos = substring(1,40,uar_get_code_display(t_record->list[d.seq].interact.
     physician_position_cd)), trigger_ord_phys_pos = substring(1,40,uar_get_code_display(t_record->
     list[d.seq].trigger.physician_position_cd)),
   user_position = substring(1,40,uar_get_code_display(t_record->list[d.seq].prsnl_position_cd)),
   override_reason = substring(1,100,uar_get_code_display(t_record->list[d.seq].override_rsn_cd)),
   order_date_disp = format(t_record->list[d.seq].trigger.order_dt_tm,"MM/DD/YYYY HH:MM:SS;;D")
   IF ((t_record->list[d.seq].trigger.order_id > 0)
    AND (t_record->list[d.seq].trigger.order_row_exists=1))
    override_yes_no = "Y"
   ELSE
    override_yes_no = "N", override_reason = ""
   ENDIF
   IF ((t_record->list[d.seq].encntrtype IN (ip1_cd, ip2_cd, ip3_cd, ip4_cd, ip5_cd,
   ip6_cd, ip7_cd, ip8_cd, ip9_cd, ip10_cd,
   ip11_cd)))
    encounter_type = "Inpatient"
   ELSE
    encounter_type = "Outpatient"
   ENDIF
   t_line = concat(trim(uar_get_code_display(t_record->list[d.seq].trigger.catalog_cd)),char(9),trim(
     uar_get_code_display(t_record->list[d.seq].interact.catalog_cd)),char(9),t_record->list[d.seq].
    patient_name,
    char(9),encounter_type,char(9),facility_disp,char(9),
    t_record->list[d.seq].trigger.physician_name,char(9),trigger_ord_phys_pos,char(9),t_record->list[
    d.seq].fmrn,
    char(9),order_date_disp,char(9),user_position,char(9),
    trim(cnvtstring(t_record->list[d.seq].trigger.order_id)),char(9),override_reason,char(9),t_record
    ->list[d.seq].override_rsn_ft,
    char(9),trim(cnvtstring(t_record->list[d.seq].severity)),char(9),override_yes_no,char(9),
    trgr.clinical_display_line,char(9),interact.clinical_display_line), col 0, t_line,
   row + 1
  WITH maxcol = 32600, formfeed = none, maxrow = 1,
   format = variable, outerjoin = d1, outerjoin = d2
 ;end select
 SELECT INTO "ddi_summary.xls"
  trig_mnemonic = uar_get_code_display(t_record->list[d.seq].trigger.catalog_cd), interact_mnemonic
   = uar_get_code_display(t_record->list[d.seq].interact.catalog_cd)
  FROM (dummyt d  WITH seq = t_record->list_cnt),
   orders interact,
   orders trgr,
   dummyt d1,
   dummyt d2
  PLAN (d
   WHERE (t_record->list[d.seq].interact.orig_ord_as_flag IN (1, 0))
    AND (t_record->list[d.seq].severity >= 3)
    AND (t_record->list[d.seq].active_ind=1)
    AND (t_record->list[d.seq].trigger.catalog_cd > 0))
   JOIN (d1)
   JOIN (trgr
   WHERE (trgr.order_id=t_record->list[d.seq].trigger.order_id))
   JOIN (d2)
   JOIN (interact
   WHERE (interact.order_id=t_record->list[d.seq].interact.order_id))
  ORDER BY trig_mnemonic, interact_mnemonic
  HEAD REPORT
   t_line = "Drug Drug Interaction Report Summary", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q")), col 0,
   t_line, row + 1, t_line = concat("Triggering Drug",char(9),"Interacting Drug",char(9),"# Interact",
    char(9),"# Overridden",char(9),"% Overridden",char(9),
    "# Not Overridden",char(9),"% Not Overridden",char(9),"# Total Orders",
    char(9),"Tot % Interact"),
   col 0, t_line, row + 1,
   count_1 = 0.00, count_2 = 0.00, count_3 = 0.00,
   count_4 = 0.00, percent_1 = 0.00, percent_2 = 0.00,
   percent_3 = 0.00
  HEAD interact_mnemonic
   interact_count = 0.00, override_count = 0.00, override_percent = 0.00
  DETAIL
   interact_count = (interact_count+ 1)
   IF ((t_record->list[d.seq].trigger.order_id > 0)
    AND (t_record->list[d.seq].trigger.order_row_exists=1))
    override_count = (override_count+ 1)
   ENDIF
  FOOT  interact_mnemonic
   override_percent = 0.00
   IF (interact_count > 0)
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
    trim(uar_get_code_display(t_record->list[d.seq].trigger.catalog_cd)),char(9),trim(
     uar_get_code_display(t_record->list[d.seq].interact.catalog_cd)),char(9),interact_count,
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
   t_line, row + 1
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable, outerjoin = d1, outerjoin = d2
 ;end select
 DECLARE len = i4
 DECLARE subject_line = vc
 DECLARE dclcom = vc
 IF (findfile("ddi_detail.xls")=1
  AND findfile("ddi_summary.xls")=1)
  SET dclcom = "gzip ddi_detail.xls"
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET subject_line = concat("Multum DDI Reports ",format(t_record->beg_date,"DD-MMM-YYYY HH:MM;;Q"),
   " to ",format(t_record->end_date,"DD-MMM-YYYY HH:MM;;Q"))
  SET dclcom = concat('echo " " | mailx -s "',subject_line,'" ','-a "ddi_detail.xls.gz" ',
   '-a "ddi_summary.xls" ',
   email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("ddi_detail.xls.gz")
  SET stat = remove("ddi_summary.xls")
 ENDIF
#exit_script
 SET reply->status_data[1].status = "S"
END GO

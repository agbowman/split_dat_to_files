CREATE PROGRAM bhs_athn_intake_output_v2
 DECLARE moutputdevice = vc WITH protect, noconstant( $1)
 DECLARE encntr_id = f8 WITH protect, constant( $3)
 DECLARE person_id = f8 WITH protect, constant( $2)
 DECLARE io = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"INTAKEANDOUTPUT"))
 DECLARE routeofadmin = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE intermittent = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",18309,"INTERMITTENT"))
 DECLARE med = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",18309,"MED"))
 DECLARE io_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",93,"IO"))
 DECLARE intake_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"INTAKE"))
 DECLARE output_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"OUTPUT"))
 FREE RECORD out_rec
 RECORD out_rec(
   1 continuous_orders[*]
     2 order_id = vc
     2 dept_misc_line = vc
     2 start_date = vc
     2 stop_date = vc
     2 order_status = vc
     2 events[*]
       3 event_id = vc
       3 parent_event_id = vc
       3 result = vc
       3 result_units = vc
       3 perform_date = vc
       3 result_status = vc
   1 medications[*]
     2 catalog_cd = vc
     2 catalog_display = vc
     2 hna_order_mnemonic = vc
     2 parent_events[*]
       3 child_events[*]
         4 event_id = vc
         4 parent_event_id = vc
         4 event_display = vc
         4 admin_date = vc
         4 infuse_volume = vc
         4 infuse_volume_unit = vc
         4 admin_dosage = vc
         4 dosage_unit = vc
         4 diluent_display = vc
         4 io_start_date = vc
         4 io_end_date = vc
   1 misc_intake[*]
     2 io_type_display = vc
     2 io_seq = vc
     2 section[*]
       3 section_name = vc
       3 section_seq = vc
       3 dynamic_label[*]
         4 dyn_label_id = vc
         4 dyn_label_name = vc
         4 events[*]
           5 event_name = vc
           5 event_code = vc
           5 results[*]
             6 event_id = vc
             6 parent_event_id = vc
             6 result_val = vc
             6 result_units = vc
             6 result_dt_time = vc
             6 result_status = vc
   1 intake_output[*]
     2 io_type_display = vc
     2 io_seq = vc
     2 section[*]
       3 section_name = vc
       3 section_seq = vc
       3 dynamic_label[*]
         4 dyn_label_id = vc
         4 dyn_label_name = vc
         4 events[*]
           5 event_name = vc
           5 event_code = vc
           5 results[*]
             6 event_id = vc
             6 parent_event_id = vc
             6 result_val = vc
             6 result_units = vc
             6 resultd_dt_time = vc
             6 result_status = vc
             6 intake_output_flag = vc
 )
 DECLARE ocnt1 = i4 WITH protect, noconstant(0)
 DECLARE ocnt2 = i4 WITH protect, noconstant(0)
 DECLARE mcnt1 = i4 WITH protect, noconstant(0)
 DECLARE mcnt2 = i4 WITH protect, noconstant(0)
 DECLARE mcnt3 = i4 WITH protect, noconstant(0)
 DECLARE icnt1 = i4 WITH protect, noconstant(0)
 DECLARE icnt2 = i4 WITH protect, noconstant(0)
 DECLARE icnt3 = i4 WITH protect, noconstant(0)
 DECLARE icnt4 = i4 WITH protect, noconstant(0)
 DECLARE icnt5 = i4 WITH protect, noconstant(0)
 DECLARE cnt1 = i4 WITH protect, noconstant(0)
 DECLARE cnt2 = i4 WITH protect, noconstant(0)
 DECLARE cnt3 = i4 WITH protect, noconstant(0)
 DECLARE cnt4 = i4 WITH protect, noconstant(0)
 DECLARE cnt5 = i4 WITH protect, noconstant(0)
 SET begindate =  $4
 SET enddate =  $5
 IF (encntr_id > 1)
  SET where_params = build("O.ENCNTR_ID =",encntr_id," ")
  SET where_params1 = build("ce.ENCNTR_ID =",encntr_id," ")
 ELSE
  SET where_params = build("O.person_ID =",person_id," ")
  SET where_params1 = build("ce.person_ID =",person_id," ")
 ENDIF
 SELECT INTO "NL:"
  FROM orders o,
   clinical_event ce,
   ce_intake_output_result cr
  PLAN (o
   WHERE parser(where_params)
    AND o.iv_ind=1)
   JOIN (ce
   WHERE (ce.order_id= Outerjoin(o.order_id))
    AND (ce.event_tag!= Outerjoin("DCP GENERIC CODE"))
    AND (ce.valid_from_dt_tm< Outerjoin(sysdate))
    AND (ce.valid_until_dt_tm> Outerjoin(sysdate))
    AND (ce.event_reltn_cd= Outerjoin(135.00))
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(begindate) AND cnvtdatetime(enddate))
   JOIN (cr
   WHERE cr.reference_event_id=ce.parent_event_id
    AND cr.encntr_id=o.encntr_id)
  ORDER BY o.order_id, ce.parent_event_id
  HEAD o.order_id
   ocnt1 += 1, stat = alterlist(out_rec->continuous_orders,ocnt1), out_rec->continuous_orders[ocnt1].
   order_id = cnvtstring(o.order_id),
   out_rec->continuous_orders[ocnt1].dept_misc_line = o.dept_misc_line, out_rec->continuous_orders[
   ocnt1].start_date = datetimezoneformat(o.current_start_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
    curtimezonedef), out_rec->continuous_orders[ocnt1].stop_date = datetimezoneformat(o
    .projected_stop_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef),
   out_rec->continuous_orders[ocnt1].order_status = uar_get_code_display(o.order_status_cd), ocnt2 =
   0
  HEAD ce.parent_event_id
   IF (ce.parent_event_id > 0)
    ocnt2 += 1, stat = alterlist(out_rec->continuous_orders[ocnt1].events,ocnt2), out_rec->
    continuous_orders[ocnt1].events[ocnt2].event_id = cnvtstring(ce.parent_event_id),
    out_rec->continuous_orders[ocnt1].events[ocnt2].parent_event_id = cnvtstring(ce.parent_event_id),
    out_rec->continuous_orders[ocnt1].events[ocnt2].result = ce.result_val, out_rec->
    continuous_orders[ocnt1].events[ocnt2].result_units = uar_get_code_display(ce.result_units_cd),
    out_rec->continuous_orders[ocnt1].events[ocnt2].perform_date = datetimezoneformat(ce
     .event_end_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef), out_rec->
    continuous_orders[ocnt1].events[ocnt2].result_status = uar_get_code_display(ce.result_status_cd)
   ENDIF
  WITH time = 30
 ;end select
 SELECT INTO "NL:"
  FROM orders o,
   order_detail od,
   clinical_event ce,
   ce_med_result c,
   ce_intake_output_result cr
  PLAN (o
   WHERE parser(where_params)
    AND o.med_order_type_cd IN (intermittent, med))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=routeofadmin
    AND od.oe_field_value IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=4001
     AND cv.active_ind=1
     AND ((cv.cdf_meaning="IV") OR (cv.display_key="SWISHANDSPIT")) )))
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(begindate) AND cnvtdatetime(enddate))
   JOIN (c
   WHERE c.event_id=ce.event_id)
   JOIN (cr
   WHERE cr.reference_event_id=ce.parent_event_id
    AND cr.encntr_id=o.encntr_id)
  ORDER BY o.catalog_cd, ce.parent_event_id, ce.event_id,
   ce.updt_dt_tm DESC
  HEAD o.catalog_cd
   mcnt1 += 1, stat = alterlist(out_rec->medications,mcnt1), out_rec->medications[mcnt1].catalog_cd
    = cnvtstring(o.catalog_cd),
   out_rec->medications[mcnt1].catalog_display = uar_get_code_display(o.catalog_cd), out_rec->
   medications[mcnt1].hna_order_mnemonic = o.hna_order_mnemonic, mcnt2 = 0
  HEAD ce.parent_event_id
   mcnt2 += 1, stat = alterlist(out_rec->medications[mcnt1].parent_events,mcnt2), mcnt3 = 0
  DETAIL
   mcnt3 += 1, stat = alterlist(out_rec->medications[mcnt1].parent_events[mcnt2].child_events,mcnt3),
   out_rec->medications[mcnt1].parent_events[mcnt2].child_events[mcnt3].event_display =
   uar_get_code_display(ce.event_cd),
   out_rec->medications[mcnt1].parent_events[mcnt2].child_events[mcnt3].event_id = cnvtstring(c
    .event_id), out_rec->medications[mcnt1].parent_events[mcnt2].child_events[mcnt3].parent_event_id
    = cnvtstring(ce.parent_event_id), out_rec->medications[mcnt1].parent_events[mcnt2].child_events[
   mcnt3].admin_date = datetimezoneformat(c.admin_end_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
    curtimezonedef),
   out_rec->medications[mcnt1].parent_events[mcnt2].child_events[mcnt3].infuse_volume = cnvtstring(cr
    .io_volume), out_rec->medications[mcnt1].parent_events[mcnt2].child_events[mcnt3].
   infuse_volume_unit = uar_get_code_display(c.infused_volume_unit_cd), out_rec->medications[mcnt1].
   parent_events[mcnt2].child_events[mcnt3].admin_dosage = cnvtstring(c.admin_dosage),
   out_rec->medications[mcnt1].parent_events[mcnt2].child_events[mcnt3].dosage_unit =
   uar_get_code_display(c.dosage_unit_cd), out_rec->medications[mcnt1].parent_events[mcnt2].
   child_events[mcnt3].diluent_display = uar_get_code_display(c.diluent_type_cd), out_rec->
   medications[mcnt1].parent_events[mcnt2].child_events[mcnt3].io_start_date = datetimezoneformat(cr
    .io_start_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef),
   out_rec->medications[mcnt1].parent_events[mcnt2].child_events[mcnt3].io_end_date =
   datetimezoneformat(cr.io_end_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
  WITH time = 30
 ;end select
 SELECT DISTINCT INTO "NL:"
  FROM v500_event_set_canon v,
   v500_event_set_canon v1,
   v500_event_set_explode ve1,
   clinical_event ce,
   ce_dynamic_label cd
  PLAN (v
   WHERE v.parent_event_set_cd=0)
   JOIN (v1
   WHERE v1.parent_event_set_cd=v.event_set_cd)
   JOIN (ve1
   WHERE ve1.event_set_cd=v1.event_set_cd)
   JOIN (ce
   WHERE ce.event_cd=ve1.event_cd
    AND parser(where_params1)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(begindate) AND cnvtdatetime(enddate)
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (cd
   WHERE (cd.ce_dynamic_label_id= Outerjoin(ce.ce_dynamic_label_id)) )
  ORDER BY v.event_set_cd, v1.event_set_cd, cd.label_name,
   ve1.event_cd, ce.event_id, ce.updt_dt_tm DESC
  HEAD v.event_set_cd
   icnt1 += 1, stat = alterlist(out_rec->misc_intake,icnt1), out_rec->misc_intake[icnt1].
   io_type_display = uar_get_code_display(v.event_set_cd),
   out_rec->misc_intake[icnt1].io_seq = cnvtstring(v.event_set_collating_seq), icnt2 = 0
  HEAD v1.event_set_cd
   icnt2 += 1, stat = alterlist(out_rec->misc_intake[icnt1].section,icnt2), out_rec->misc_intake[
   icnt1].section[icnt2].section_name = uar_get_code_display(v1.event_set_cd),
   out_rec->misc_intake[icnt1].section[icnt2].section_seq = cnvtstring(v1.event_set_collating_seq),
   icnt3 = 0
  HEAD cd.label_name
   icnt3 += 1, stat = alterlist(out_rec->misc_intake[icnt1].section[icnt2].dynamic_label,icnt3),
   out_rec->misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].dyn_label_id = cnvtstring(cd
    .label_template_id),
   out_rec->misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].dyn_label_name = cd.label_name,
   icnt4 = 0
  HEAD ve1.event_cd
   icnt4 += 1, stat = alterlist(out_rec->misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].
    events,icnt4), out_rec->misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].events[icnt4].
   event_name = uar_get_code_display(ve1.event_cd),
   out_rec->misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].events[icnt4].event_code =
   cnvtstring(ce.event_cd), icnt5 = 0
  DETAIL
   icnt5 += 1, stat = alterlist(out_rec->misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].
    events[icnt4].results,icnt5), out_rec->misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].
   events[icnt4].results[icnt5].event_id = cnvtstring(ce.event_id),
   out_rec->misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].events[icnt4].results[icnt5].
   parent_event_id = cnvtstring(ce.parent_event_id), out_rec->misc_intake[icnt1].section[icnt2].
   dynamic_label[icnt3].events[icnt4].results[icnt5].result_val = ce.result_val, out_rec->
   misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].events[icnt4].results[icnt5].result_units
    = uar_get_code_display(ce.result_units_cd),
   out_rec->misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].events[icnt4].results[icnt5].
   result_dt_time = datetimezoneformat(ce.event_end_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
    curtimezonedef), out_rec->misc_intake[icnt1].section[icnt2].dynamic_label[icnt3].events[icnt4].
   results[icnt5].result_status = uar_get_code_display(ce.result_status_cd)
  WITH time = 30
 ;end select
 SELECT DISTINCT INTO "NL:"
  FROM v500_event_set_canon v,
   v500_event_set_canon v1,
   v500_event_set_explode ve1,
   clinical_event ce,
   ce_dynamic_label cd,
   discrete_task_assay d
  PLAN (v
   WHERE v.parent_event_set_cd=io_cd)
   JOIN (v1
   WHERE v1.parent_event_set_cd=v.event_set_cd)
   JOIN (ve1
   WHERE ve1.event_set_cd=v1.event_set_cd)
   JOIN (ce
   WHERE ce.event_cd=ve1.event_cd
    AND parser(where_params1)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(begindate) AND cnvtdatetime(enddate)
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (d
   WHERE (d.event_cd= Outerjoin(ce.event_cd)) )
   JOIN (cd
   WHERE (cd.ce_dynamic_label_id= Outerjoin(ce.ce_dynamic_label_id)) )
  ORDER BY v.event_set_cd, v1.event_set_cd, cd.label_name,
   ve1.event_cd, ce.event_id, ce.updt_dt_tm DESC
  HEAD v.event_set_cd
   cnt1 += 1, stat = alterlist(out_rec->intake_output,cnt1), out_rec->intake_output[cnt1].
   io_type_display = trim(uar_get_code_display(v.event_set_cd),3),
   out_rec->intake_output[cnt1].io_seq = trim(cnvtstring(v.event_set_collating_seq),3), cnt2 = 0
  HEAD v1.event_set_cd
   cnt2 += 1, stat = alterlist(out_rec->intake_output[cnt1].section,cnt2), out_rec->intake_output[
   cnt1].section[cnt2].section_name = trim(uar_get_code_display(v1.event_set_cd),3),
   out_rec->intake_output[cnt1].section[cnt2].section_seq = trim(cnvtstring(v1
     .event_set_collating_seq),3), cnt3 = 0
  HEAD cd.label_name
   cnt3 += 1, stat = alterlist(out_rec->intake_output[cnt1].section[cnt2].dynamic_label,cnt3),
   out_rec->intake_output[cnt1].section[cnt2].dynamic_label[cnt3].dyn_label_id = trim(cnvtstring(
     cnvtint(cd.label_template_id)),3),
   out_rec->intake_output[cnt1].section[cnt2].dynamic_label[cnt3].dyn_label_name = trim(cd.label_name,
    3), cnt4 = 0
  HEAD ve1.event_cd
   cnt4 += 1, stat = alterlist(out_rec->intake_output[cnt1].section[cnt2].dynamic_label[cnt3].events,
    cnt4), out_rec->intake_output[cnt1].section[cnt2].dynamic_label[cnt3].events[cnt4].event_name =
   trim(uar_get_code_display(ve1.event_cd)),
   out_rec->intake_output[cnt1].section[cnt2].dynamic_label[cnt3].events[cnt4].event_code = trim(
    cnvtstring(ce.event_cd)), cnt5 = 0
  DETAIL
   cnt5 += 1, stat = alterlist(out_rec->intake_output[cnt1].section[cnt2].dynamic_label[cnt3].events[
    cnt4].results,cnt5), out_rec->intake_output[cnt1].section[cnt2].dynamic_label[cnt3].events[cnt4].
   results[cnt5].event_id = cnvtstring(ce.event_id),
   out_rec->intake_output[cnt1].section[cnt2].dynamic_label[cnt3].events[cnt4].results[cnt5].
   parent_event_id = cnvtstring(ce.parent_event_id), out_rec->intake_output[cnt1].section[cnt2].
   dynamic_label[cnt3].events[cnt4].results[cnt5].result_val = ce.result_val, out_rec->intake_output[
   cnt1].section[cnt2].dynamic_label[cnt3].events[cnt4].results[cnt5].result_units =
   uar_get_code_display(ce.result_units_cd),
   out_rec->intake_output[cnt1].section[cnt2].dynamic_label[cnt3].events[cnt4].results[cnt5].
   resultd_dt_time = datetimezoneformat(ce.event_end_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
    curtimezonedef), out_rec->intake_output[cnt1].section[cnt2].dynamic_label[cnt3].events[cnt4].
   results[cnt5].result_status = uar_get_code_display(ce.result_status_cd), out_rec->intake_output[
   cnt1].section[cnt2].dynamic_label[cnt3].events[cnt4].results[cnt5].intake_output_flag = cnvtstring
   (d.io_flag)
  WITH time = 30
 ;end select
 EXECUTE bhs_athn_write_json_output
END GO

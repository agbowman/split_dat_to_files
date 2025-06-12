CREATE PROGRAM bhs_prax_order_notifications
 FREE RECORD orders_n
 RECORD orders_n(
   1 orders_cnt = i4
   1 prsnl[*]
     2 prsnl_id = f8
     2 order_id = f8
     2 ord_notification_id = f8
     2 templateorderid = f8
     2 person_id = f8
     2 encounter_id = f8
     2 patientname = vc
     2 orderdescription = vc
     2 orderdetail = vc
     2 originatorid = f8
     2 originatorname = vc
     2 createddate = vc
     2 updatedate = vc
     2 orderstatus = vc
     2 stopdate = vc
     2 stopreason = vc
     2 actiontype = vc
     2 summarytype = vc
     2 prsnl_group_id = f8
     2 prsnl_group_name = vc
     2 proxy_prsnl_id = f8
     2 proxy_prsnl_name = vc
 )
 DECLARE prsnl_id = f8 WITH protect, constant(request->prsnl[1].prsnl_id)
 DECLARE msg_type_id = f8 WITH protect, constant(request->person[1].person_id)
 SET begindate = request->nv[1].pvc_value
 SET enddate = request->nv[2].pvc_value
 DECLARE moutputdevice = vc WITH protect, constant(request->output_device)
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE cnt = i4
 SET cnt = 0
 IF (msg_type_id=1)
  SELECT DISTINCT INTO "nl:"
   o.order_id, oo.template_order_id, oo.encntr_id,
   prsnl_id = o.to_prsnl_id, patient_name = p.name_full_formatted, name_of_order =
   uar_get_code_display(oo.catalog_cd),
   details_od_order = oo.clinical_display_line, originator_id = oa.action_personnel_id, o.order_id,
   oa.action_sequence, originator_name = pr.name_full_formatted, created_date_time = oo
   .orig_order_dt_tm,
   oo.updt_dt_tm, order_status = uar_get_code_display(oo.order_status_cd), action_type = dm1
   .description,
   orderdescription =
   IF (oo.hna_order_mnemonic=oo.ordered_as_mnemonic) oo.ordered_as_mnemonic
   ELSEIF (oo.iv_ind=1) oo.ordered_as_mnemonic
   ELSE build(oo.hna_order_mnemonic," (",oo.ordered_as_mnemonic,")")
   ENDIF
   FROM order_notification o,
    orders oo,
    order_action oa,
    person p,
    prsnl pr,
    dm_flags dm1
   PLAN (o
    WHERE o.to_prsnl_id=prsnl_id
     AND o.notification_status_flag=1
     AND o.notification_type_flag IN (1, 2)
     AND o.notification_display_dt_tm BETWEEN (sysdate - 30) AND sysdate)
    JOIN (oo
    WHERE oo.order_id=o.order_id)
    JOIN (p
    WHERE p.person_id=oo.person_id)
    JOIN (oa
    WHERE oa.order_id=oo.order_id
     AND oa.inactive_flag=0)
    JOIN (pr
    WHERE pr.person_id=oa.action_personnel_id
     AND pr.person_id != 1)
    JOIN (dm1
    WHERE dm1.table_name="ORDER_NOTIFICATION"
     AND dm1.column_name="NOTIFICATION_TYPE_FLAG"
     AND dm1.flag_value=o.notification_type_flag)
   ORDER BY o.updt_dt_tm DESC, o.order_notification_id, oa.action_sequence DESC
   HEAD o.order_notification_id
    cnt = (cnt+ 1), stat = alterlist(orders_n->prsnl[cnt],cnt), orders_n->prsnl[cnt].order_id = oo
    .order_id,
    orders_n->prsnl[cnt].ord_notification_id = o.order_notification_id, orders_n->prsnl[cnt].
    templateorderid = oo.template_order_id, orders_n->prsnl[cnt].prsnl_id = prsnl_id,
    orders_n->prsnl[cnt].person_id = oo.person_id, orders_n->prsnl[cnt].encounter_id = oo.encntr_id,
    orders_n->prsnl[cnt].patientname = p.name_full_formatted,
    orders_n->prsnl[cnt].orderdescription = orderdescription, orders_n->prsnl[cnt].orderdetail = oo
    .clinical_display_line, orders_n->prsnl[cnt].originatorid = oa.order_provider_id,
    orders_n->prsnl[cnt].originatorname = pr.name_full_formatted, orders_n->prsnl[cnt].createddate =
    format(oo.orig_order_dt_tm,"mm/dd/yyyy hh:mm"), orders_n->prsnl[cnt].updatedate = format(oo
     .updt_dt_tm,"mm/dd/yyyy hh:mm"),
    orders_n->prsnl[cnt].orderstatus = uar_get_code_display(oo.order_status_cd), orders_n->prsnl[cnt]
    .stopdate = format(oo.projected_stop_dt_tm,"mm/dd/yyyy hh:mm"), orders_n->prsnl[cnt].stopreason
     = uar_get_code_display(oo.stop_type_cd),
    orders_n->prsnl[cnt].actiontype = dm1.description, orders_n->prsnl[cnt].summarytype = "InBox"
   FOOT REPORT
    stat = alterlist(orders_n->prsnl,cnt), orders_n->orders_cnt = cnt
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (msg_type_id=2)
  SELECT DISTINCT INTO "nl:"
   o.order_id, oo.template_order_id, oo.encntr_id,
   prsnl_id = o.to_prsnl_id, patient_name = p.name_full_formatted, name_of_order =
   uar_get_code_display(oo.catalog_cd),
   details_od_order = oo.clinical_display_line, originator_id = oa.action_personnel_id, o.order_id,
   oa.action_sequence, originator_name = pr.name_full_formatted, created_date_time = oo
   .orig_order_dt_tm,
   oo.updt_dt_tm, order_status = uar_get_code_display(oo.order_status_cd), action_type = dm1
   .description,
   orderdescription =
   IF (oo.hna_order_mnemonic=oo.ordered_as_mnemonic) oo.ordered_as_mnemonic
   ELSEIF (oo.iv_ind=1) oo.ordered_as_mnemonic
   ELSE build(oo.hna_order_mnemonic," (",oo.ordered_as_mnemonic,")")
   ENDIF
   FROM proxy px,
    prsnl pr1,
    order_notification o,
    orders oo,
    order_action oa,
    person p,
    prsnl pr,
    dm_flags dm1
   PLAN (px
    WHERE px.person_id=prsnl_id
     AND px.end_effective_dt_tm > sysdate
     AND px.beg_effective_dt_tm < sysdate
     AND px.active_ind=1)
    JOIN (pr1
    WHERE pr1.person_id=px.proxy_person_id)
    JOIN (o
    WHERE o.to_prsnl_id=pr1.person_id
     AND o.notification_status_flag=1
     AND o.notification_type_flag IN (1, 2)
     AND o.notification_display_dt_tm BETWEEN (sysdate - 30) AND sysdate)
    JOIN (oo
    WHERE oo.order_id=o.order_id)
    JOIN (p
    WHERE p.person_id=oo.person_id)
    JOIN (oa
    WHERE oa.order_id=oo.order_id
     AND oa.inactive_flag=0)
    JOIN (pr
    WHERE pr.person_id=oa.action_personnel_id
     AND pr.person_id != 1)
    JOIN (dm1
    WHERE dm1.table_name="ORDER_NOTIFICATION"
     AND dm1.column_name="NOTIFICATION_TYPE_FLAG"
     AND dm1.flag_value=o.notification_type_flag)
   ORDER BY o.updt_dt_tm DESC, o.order_notification_id, oa.action_sequence DESC
   HEAD o.order_notification_id
    cnt = (cnt+ 1), stat = alterlist(orders_n->prsnl[cnt],cnt), orders_n->prsnl[cnt].order_id = oo
    .order_id,
    orders_n->prsnl[cnt].ord_notification_id = o.order_notification_id, orders_n->prsnl[cnt].
    templateorderid = oo.template_order_id, orders_n->prsnl[cnt].prsnl_id = prsnl_id,
    orders_n->prsnl[cnt].person_id = oo.person_id, orders_n->prsnl[cnt].encounter_id = oo.encntr_id,
    orders_n->prsnl[cnt].patientname = p.name_full_formatted,
    orders_n->prsnl[cnt].orderdescription = orderdescription, orders_n->prsnl[cnt].orderdetail = oo
    .clinical_display_line, orders_n->prsnl[cnt].originatorid = oa.order_provider_id,
    orders_n->prsnl[cnt].originatorname = pr.name_full_formatted, orders_n->prsnl[cnt].createddate =
    format(oo.orig_order_dt_tm,"mm/dd/yyyy hh:mm"), orders_n->prsnl[cnt].updatedate = format(oo
     .updt_dt_tm,"mm/dd/yyyy hh:mm"),
    orders_n->prsnl[cnt].orderstatus = uar_get_code_display(oo.order_status_cd), orders_n->prsnl[cnt]
    .stopdate = format(oo.projected_stop_dt_tm,"mm/dd/yyyy hh:mm"), orders_n->prsnl[cnt].stopreason
     = uar_get_code_display(oo.stop_type_cd),
    orders_n->prsnl[cnt].actiontype = dm1.description, orders_n->prsnl[cnt].summarytype = "Proxy",
    orders_n->prsnl[cnt].proxy_prsnl_id = pr1.person_id,
    orders_n->prsnl[cnt].proxy_prsnl_name = pr1.name_full_formatted
   FOOT REPORT
    stat = alterlist(orders_n->prsnl,cnt), orders_n->orders_cnt = cnt
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (msg_type_id=3)
  SELECT DISTINCT INTO "nl:"
   o.order_id, oo.template_order_id, oo.encntr_id,
   prsnl_id = o.to_prsnl_id, patient_name = p.name_full_formatted, name_of_order =
   uar_get_code_display(oo.catalog_cd),
   details_od_order = oo.clinical_display_line, originator_id = oa.action_personnel_id, o.order_id,
   oa.action_sequence, originator_name = pr.name_full_formatted, created_date_time = oo
   .orig_order_dt_tm,
   oo.updt_dt_tm, order_status = uar_get_code_display(oo.order_status_cd), action_type = dm1
   .description,
   orderdescription =
   IF (oo.hna_order_mnemonic=oo.ordered_as_mnemonic) oo.ordered_as_mnemonic
   ELSEIF (oo.iv_ind=1) oo.ordered_as_mnemonic
   ELSE build(oo.hna_order_mnemonic," (",oo.ordered_as_mnemonic,")")
   ENDIF
   FROM prsnl_group_reltn pg,
    prsnl_group pgr,
    order_notification o,
    orders oo,
    order_action oa,
    person p,
    prsnl pr,
    dm_flags dm1
   PLAN (pg
    WHERE pg.person_id=prsnl_id
     AND pg.active_ind=1)
    JOIN (pgr
    WHERE pgr.prsnl_group_id=pg.prsnl_group_id)
    JOIN (o
    WHERE o.to_prsnl_group_id=pg.prsnl_group_id
     AND o.notification_status_flag=1
     AND o.notification_type_flag IN (1, 2)
     AND o.notification_display_dt_tm BETWEEN (sysdate - 30) AND sysdate)
    JOIN (oo
    WHERE oo.order_id=o.order_id)
    JOIN (p
    WHERE p.person_id=oo.person_id)
    JOIN (oa
    WHERE oa.order_id=oo.order_id
     AND oa.inactive_flag=0)
    JOIN (pr
    WHERE pr.person_id=oa.action_personnel_id
     AND pr.person_id != 1)
    JOIN (dm1
    WHERE dm1.table_name="ORDER_NOTIFICATION"
     AND dm1.column_name="NOTIFICATION_TYPE_FLAG"
     AND dm1.flag_value=o.notification_type_flag)
   ORDER BY o.updt_dt_tm DESC, o.order_notification_id, oa.action_sequence DESC
   HEAD o.order_notification_id
    cnt = (cnt+ 1), stat = alterlist(orders_n->prsnl[cnt],cnt), orders_n->prsnl[cnt].order_id = oo
    .order_id,
    orders_n->prsnl[cnt].ord_notification_id = o.order_notification_id, orders_n->prsnl[cnt].
    templateorderid = oo.template_order_id, orders_n->prsnl[cnt].prsnl_id = prsnl_id,
    orders_n->prsnl[cnt].person_id = oo.person_id, orders_n->prsnl[cnt].encounter_id = oo.encntr_id,
    orders_n->prsnl[cnt].patientname = p.name_full_formatted,
    orders_n->prsnl[cnt].orderdescription = orderdescription, orders_n->prsnl[cnt].orderdetail = oo
    .clinical_display_line, orders_n->prsnl[cnt].originatorid = oa.order_provider_id,
    orders_n->prsnl[cnt].originatorname = pr.name_full_formatted, orders_n->prsnl[cnt].createddate =
    format(oo.orig_order_dt_tm,"mm/dd/yyyy hh:mm"), orders_n->prsnl[cnt].updatedate = format(oo
     .updt_dt_tm,"mm/dd/yyyy hh:mm"),
    orders_n->prsnl[cnt].orderstatus = uar_get_code_display(oo.order_status_cd), orders_n->prsnl[cnt]
    .stopdate = format(oo.projected_stop_dt_tm,"mm/dd/yyyy hh:mm"), orders_n->prsnl[cnt].stopreason
     = uar_get_code_display(oo.stop_type_cd),
    orders_n->prsnl[cnt].actiontype = dm1.description, orders_n->prsnl[cnt].summarytype = "Pools",
    orders_n->prsnl[cnt].prsnl_group_id = pgr.prsnl_group_id,
    orders_n->prsnl[cnt].prsnl_group_name = pgr.prsnl_group_name
   FOOT REPORT
    stat = alterlist(orders_n->prsnl,cnt), orders_n->orders_cnt = cnt
   WITH nocounter, time = 30
  ;end select
 ENDIF
 SET json = cnvtrectojson(orders_n)
 SELECT INTO value(moutputdevice)
  json
  FROM dummyt d
  WITH format, separator = " "
 ;end select
END GO

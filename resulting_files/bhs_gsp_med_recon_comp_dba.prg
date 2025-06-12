CREATE PROGRAM bhs_gsp_med_recon_comp:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 RECORD pt_info(
   1 person_id = f8
   1 encntr_id = f8
 )
 IF (validate(request->visit[1],0.00) <= 0.00)
  IF (reflect(parameter(1,0)) > " ")
   SET pt_info->encntr_id = cnvtreal( $1)
  ENDIF
 ELSE
  SET pt_info->encntr_id = request->visit[1].encntr_id
 ENDIF
 IF ((pt_info->encntr_id <= 0.00))
  CALL echo("no valid enctr_id given. exitting script")
  GO TO exit_script
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 RECORD reply(
   1 spread_type = i2
   1 report_title = vc
   1 grid_lines_ind = i2
   1 col_cnt = i2
   1 col[*]
     2 header = vc
     2 width = i2
     2 type = i2
     2 wrap_ind = i2
   1 row_cnt = i2
   1 row[*]
     2 keyl[*]
       3 key_type = i2
       3 key_id = f8
     2 col[*]
       3 data_string = vc
       3 data_double = f8
       3 data_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE RECORD med_recon_request
 RECORD med_recon_request(
   1 recon_type = c1
   1 encntr_id = f8
   1 pop1[*]
     2 order_id = f8
     2 order_status = vc
     2 order_dt = vc
     2 orig_ord_as_flag = i2
     2 catalog_cd = f8
     2 cki = vc
     2 order_mnemonic = vc
     2 order_detail_display_line = vc
     2 clinical_display_line = vc
     2 dose = vc
     2 dose_unit = f8
     2 volume_dose = vc
     2 volume_dose_unit = f8
     2 frequency = f8
     2 prn_ind = i2
     2 prn_reason = vc
     2 acompliance_status = vc
     2 acompliance_date = vc
     2 acompliance_person = vc
     2 arecon_prsnl = vc
     2 arecon_action_mean = vc
     2 arecon_id = f8
     2 arecon_type = vc
     2 arecon_dt_tm = vc
     2 arec_mnemonic = vc
     2 areplaced_order = vc
     2 a_old_order_id = f8
 )
 DECLARE prob_cnt = i4
 SET prob_cnt = 0
 RECORD temp(
   1 row_cnt = i2
   1 row[*]
     2 col[*]
     2 data_string = vc
     2 data_double = f8
     2 data_dt_tm = dq8
 )
 RECORD comp(
   1 encntr_id = f8
   1 comps[*]
     2 ord_comp_id = f8
     2 perf_person = vc
     2 no_meds_ind = i2
     2 unable_obtain_id = i2
     2 ord_comp_detail_id = f8
     2 comp_capture_dt = vc
     2 comp_status = vc
     2 info_source = vc
     2 lacst_occur_dttm = vc
     2 order_num = f8
     2 orig_ord_as_flag = i2
     2 order_status_disp = vc
 )
 RECORD reconciled(
   1 encntr_id = f8
   1 recons[*]
     2 recon_prsnl = vc
     2 recon_action_mean = vc
     2 recon_id = f8
     2 recon_det_id = f8
     2 recon_type = vc
     2 recon_dt_tm = vc
     2 order_as_flag = i2
     2 order_num = f8
     2 order_status = vc
     2 no_known_neds_ind = i2
     2 recon_replaced_ord = vc
 )
 SET med_recon_request->encntr_id = pt_info->encntr_id
 SET comp->encntr_id = pt_info->encntr_id
 SET reconciled->encntr_id = pt_info->encntr_id
 DECLARE pharmacy_act_type_cd = f8
 DECLARE ordered_order_status_cd = f8
 DECLARE intermittent_type_cd = f8
 SET pharmacy_act_type_cd = uar_get_code_by("DISPLAYKEY",106,"PHARMACY")
 SET ordered_order_status_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 SET intermittent_type_cd = uar_get_code_by("MEANING",18309,"INTERMITTENT")
 SET durable_equip_cd = uar_get_code_by("DISPLAYKEY",200,"DURABLEMEDICALEQUIPMENT")
 SELECT INTO "nl:"
  cur_order_status = uar_get_code_display(o.order_status_cd), oor_reltn_disp = uar_get_code_display(
   oor.relation_type_cd)
  FROM orders o,
   encounter e,
   order_order_reltn oor
  PLAN (e
   WHERE (e.encntr_id=pt_info->encntr_id))
   JOIN (o
   WHERE o.person_id=e.person_id
    AND o.orig_ord_as_flag IN (0, 1, 2)
    AND o.template_order_flag IN (0, 1)
    AND o.activity_type_cd=pharmacy_act_type_cd
    AND o.iv_ind=0
    AND o.med_order_type_cd != intermittent_type_cd
    AND o.catalog_cd != durable_equip_cd)
   JOIN (oor
   WHERE outerjoin(o.order_id)=oor.related_to_order_id)
  ORDER BY o.catalog_cd, o.order_id
  HEAD REPORT
   cnt = 0, stat = alterlist(med_recon_request->pop1,10)
  HEAD o.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt > 1)
    stat = alterlist(med_recon_request->pop1,(cnt+ 9))
   ENDIF
   med_recon_request->pop1[cnt].order_id = o.order_id, med_recon_request->pop1[cnt].order_dt = format
   (o.updt_dt_tm,"@SHORTDATETIME"), med_recon_request->pop1[cnt].catalog_cd = o.catalog_cd,
   med_recon_request->pop1[cnt].cki = o.cki, med_recon_request->pop1[cnt].orig_ord_as_flag = o
   .orig_ord_as_flag, med_recon_request->pop1[cnt].order_status = cur_order_status,
   med_recon_request->pop1[cnt].arecon_action_mean = oor_reltn_disp, med_recon_request->pop1[cnt].
   a_old_order_id = oor.related_from_order_id
   IF (o.ordered_as_mnemonic=o.hna_order_mnemonic)
    med_recon_request->pop1[cnt].order_mnemonic = trim(o.hna_order_mnemonic)
   ELSE
    med_recon_request->pop1[cnt].order_mnemonic = concat(trim(o.ordered_as_mnemonic,3)," (",trim(o
      .hna_order_mnemonic,3),")")
   ENDIF
   med_recon_request->pop1[cnt].clinical_display_line = o.clinical_display_line
   IF (o.orig_ord_as_flag IN (1, 2))
    med_recon_request->pop1[cnt].acompliance_status = ""
   ELSEIF ( NOT (o.orig_ord_as_flag IN (1, 2)))
    med_recon_request->pop1[cnt].acompliance_status = ""
   ENDIF
  FOOT REPORT
   stat = alterlist(med_recon_request->pop1,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = size(med_recon_request->pop1,5)),
   orders o
  PLAN (d1)
   JOIN (o
   WHERE (med_recon_request->pop1[d1.seq].a_old_order_id=o.order_id))
  DETAIL
   IF ((med_recon_request->pop1[d1.seq].a_old_order_id=o.order_id)
    AND (med_recon_request->pop1[d1.seq].a_old_order_id > 0))
    tempord = concat(trim(o.ordered_as_mnemonic,3)," (",trim(o.hna_order_mnemonic,3),")",", ",
     o.clinical_display_line), med_recon_request->pop1[d1.seq].areplaced_order = tempord
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(med_recon_request->pop1,5))),
   order_detail od
  PLAN (d)
   JOIN (od
   WHERE (od.order_id=med_recon_request->pop1[d.seq].order_id)
    AND od.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "FREQ", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT",
   "FREETXTDOSE", "SPECINX", "SCH/PRN", "PRNREASON"))
  DETAIL
   IF (od.oe_field_meaning="VOLUMEDOSE")
    med_recon_request->pop1[d.seq].volume_dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
    med_recon_request->pop1[d.seq].dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="FREETXTDOSE"
    AND od.oe_field_display_value != "See Instructions")
    med_recon_request->pop1[d.seq].dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="SPECINX")
    med_recon_request->pop1[d.seq].dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
    med_recon_request->pop1[d.seq].volume_dose_unit = cnvtreal(od.oe_field_value)
   ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
    med_recon_request->pop1[d.seq].dose_unit = cnvtreal(od.oe_field_value)
   ELSEIF (od.oe_field_meaning="FREQ")
    med_recon_request->pop1[d.seq].frequency = cnvtreal(od.oe_field_value)
   ELSEIF (od.oe_field_meaning="SCH/PRN"
    AND trim(od.oe_field_display_value)="Yes")
    med_recon_request->pop1[d.seq].prn_ind = 1
   ELSEIF (od.oe_field_meaning="PRNREASON")
    med_recon_request->pop1[d.seq].prn_reason = trim(od.oe_field_display_value)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  compliance_status_disp = uar_get_code_display(ocd.compliance_status_cd), information_source =
  uar_get_code_display(ocd.information_source_cd), compliance_capture_dt_tm = format(oc
   .performed_dt_tm,"@SHORTDATETIME"),
  order_status_disp = uar_get_code_display(o.order_status_cd)
  FROM order_compliance oc,
   order_compliance_detail ocd,
   prsnl prl,
   long_text lt,
   orders o
  PLAN (oc
   WHERE (oc.encntr_id=comp->encntr_id))
   JOIN (ocd
   WHERE ocd.order_compliance_id=outerjoin(oc.order_compliance_id))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(ocd.long_text_id))
   JOIN (prl
   WHERE oc.performed_prsnl_id=outerjoin(prl.person_id))
   JOIN (o
   WHERE o.order_id=outerjoin(ocd.order_nbr))
  ORDER BY ocd.order_nbr, oc.order_compliance_id DESC, ocd.order_compliance_detail_id DESC
  HEAD REPORT
   cnt_ord = 0, cnt_comp = 0, stat = alterlist(comp->comps,10)
  HEAD ocd.order_nbr
   IF (ocd.order_nbr > 0)
    cnt_comp = (cnt_comp+ 1)
    IF (mod(cnt_comp,10)=1
     AND cnt_comp != 1)
     stat = alterlist(comp->comps,(cnt_comp+ 9))
    ENDIF
    comp->comps[cnt_comp].comp_capture_dt = compliance_capture_dt_tm
    IF (ocd.order_nbr=0
     AND oc.unable_to_obtain_ind=0
     AND oc.no_known_home_meds_ind=0)
     comp->comps[cnt_comp].comp_status = "Not done"
    ELSEIF (oc.unable_to_obtain_ind=1)
     comp->comps[cnt_comp].comp_status = "Unable to obtain medication"
    ELSEIF (oc.no_known_home_meds_ind=1)
     comp->comps[cnt_comp].comp_status = "No known Home Meds"
    ELSE
     comp->comps[cnt_comp].comp_status = compliance_status_disp
    ENDIF
    comp->comps[cnt_comp].info_source = information_source, comp->comps[cnt_comp].perf_person = prl
    .name_full_formatted, comp->comps[cnt_comp].no_meds_ind = oc.no_known_home_meds_ind,
    comp->comps[cnt_comp].ord_comp_detail_id = ocd.order_compliance_detail_id, comp->comps[cnt_comp].
    ord_comp_id = oc.order_compliance_id, comp->comps[cnt_comp].unable_obtain_id = oc
    .unable_to_obtain_ind,
    comp->comps[cnt_comp].order_num = ocd.order_nbr, comp->comps[cnt_comp].orig_ord_as_flag = o
    .orig_ord_as_flag, comp->comps[cnt_comp].order_status_disp = order_status_disp
   ENDIF
  FOOT REPORT
   stat = alterlist(comp->comps,cnt_comp)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  orn_performed_dt_tm = format(orn.performed_dt_tm,"@SHORTDATETIME"), o_order_status_disp =
  uar_get_code_display(o.order_status_cd)
  FROM order_recon orn,
   order_recon_detail ord,
   dm_flags dm,
   prsnl prn,
   orders o,
   order_order_reltn oor,
   orders o2
  PLAN (orn
   WHERE (orn.encntr_id=reconciled->encntr_id))
   JOIN (ord
   WHERE ord.order_recon_id=outerjoin(orn.order_recon_id))
   JOIN (dm
   WHERE orn.recon_type_flag=dm.flag_value
    AND dm.table_name="ORDER_RECON"
    AND dm.column_name="RECON_TYPE_FLAG")
   JOIN (prn
   WHERE orn.performed_prsnl_id=prn.person_id)
   JOIN (o
   WHERE o.order_id=ord.order_nbr)
   JOIN (oor
   WHERE outerjoin(ord.order_nbr)=oor.related_to_order_id)
   JOIN (o2
   WHERE oor.related_from_order_id=o2.order_id)
  ORDER BY ord.order_nbr, orn.order_recon_id DESC, ord.order_recon_detail_id DESC
  HEAD REPORT
   stat = alterlist(reconciled->recons,10), cnt_rec = 0
  HEAD ord.order_nbr
   cnt_rec = (cnt_rec+ 1)
   IF (mod(cnt_rec,10)=1
    AND cnt_rec != 1)
    stat = alterlist(reconciled->recons,(cnt_rec+ 9))
   ENDIF
   reconciled->recons[cnt_rec].recon_prsnl = prn.name_full_formatted, reconciled->recons[cnt_rec].
   no_known_neds_ind = orn.no_known_meds_ind, reconciled->recons[cnt_rec].order_num = ord.order_nbr,
   reconciled->recons[cnt_rec].order_status = o_order_status_disp, reconciled->recons[cnt_rec].
   recon_action_mean = ord.recon_order_action_mean, reconciled->recons[cnt_rec].recon_type = dm
   .description,
   reconciled->recons[cnt_rec].recon_det_id = ord.order_recon_detail_id, reconciled->recons[cnt_rec].
   recon_dt_tm = orn_performed_dt_tm, reconciled->recons[cnt_rec].recon_replaced_ord = concat(trim(o2
     .ordered_as_mnemonic,3)," (",trim(o2.hna_order_mnemonic,3),")",", ",
    o2.clinical_display_line)
  FOOT REPORT
   stat = alterlist(reconciled->recons,cnt_rec)
  WITH nocounter
 ;end select
 FOR (y = 1 TO size(med_recon_request->pop1,5))
   SET pos1 = 0
   SET locnum1 = 0
   SET pos1 = locateval(locnum1,1,size(comp->comps,5),med_recon_request->pop1[y].order_id,comp->
    comps[locnum1].order_num)
   IF (pos1 > 0)
    SET med_recon_request->pop1[y].acompliance_status = comp->comps[pos1].comp_status
    SET med_recon_request->pop1[y].acompliance_person = comp->comps[pos1].perf_person
    SET med_recon_request->pop1[y].acompliance_date = comp->comps[pos1].comp_capture_dt
   ENDIF
 ENDFOR
 FOR (x = 1 TO size(med_recon_request->pop1,5))
   SET pos = 0
   SET locnum = 0
   SET pos = locateval(locnum,1,size(reconciled->recons,5),med_recon_request->pop1[x].order_id,
    reconciled->recons[locnum].order_num)
   IF (pos > 0)
    SET med_recon_request->pop1[x].arecon_type = reconciled->recons[pos].recon_type
    SET med_recon_request->pop1[x].arecon_prsnl = reconciled->recons[pos].recon_prsnl
    SET med_recon_request->pop1[x].arecon_dt_tm = reconciled->recons[pos].recon_dt_tm
    SET med_recon_request->pop1[x].arecon_action_mean = reconciled->recons[pos].recon_action_mean
    SET med_recon_request->pop1[x].areplaced_order = reconciled->recons[pos].recon_replaced_ord
   ENDIF
 ENDFOR
 SET col_cnt = 10
 SET reply->col_cnt = col_cnt
 SET stat = alterlist(reply->col,col_cnt)
 SET reply->col[1].header = "Order Name"
 SET reply->col[1].width = 340
 SET reply->col[1].wrap_ind = 1
 SET reply->col[2].header = "Order Type"
 SET reply->col[2].width = 50
 SET reply->col[2].wrap_ind = 1
 SET reply->col[3].header = "Order Status"
 SET reply->col[3].width = 100
 SET reply->col[3].wrap_ind = 1
 SET reply->col[4].header = "Compliance"
 SET reply->col[4].width = 100
 SET reply->col[4].wrap_ind = 1
 SET reply->col[5].header = "Compliance Date"
 SET reply->col[5].width = 100
 SET reply->col[5].wrap_ind = 1
 SET reply->col[6].header = "Compliance Prnsl"
 SET reply->col[6].width = 100
 SET reply->col[6].wrap_ind = 1
 SET reply->col[7].header = "Reconcile Type"
 SET reply->col[7].width = 100
 SET reply->col[7].wrap_ind = 1
 SET reply->col[8].header = "Recon Status"
 SET reply->col[8].width = 100
 SET reply->col[8].wrap_ind = 1
 SET reply->col[9].header = "Recon Prsnl"
 SET reply->col[9].width = 100
 SET reply->col[9].wrap_ind = 1
 SET reply->col[10].header = "Order Replaces"
 SET reply->col[10].width = 100
 SET reply->col[10].wrap_ind = 1
 SET reply->report_title = "Patient Medication Compliance Status"
 SET reply->grid_lines_ind = 3
 SET stat = alterlist(reply->row,10)
 FOR (i = 1 TO size(med_recon_request->pop1,5))
   SET reply->row_cnt = i
   SET stat = alterlist(reply->row,i)
   SET stat = alterlist(reply->row[i].col,10)
   IF ((med_recon_request->pop1[i].orig_ord_as_flag=0))
    SET reply->row[i].col[2].data_string = "Inpat"
   ELSEIF ((med_recon_request->pop1[i].orig_ord_as_flag=1))
    SET reply->row[i].col[2].data_string = "Rx"
   ELSEIF ((med_recon_request->pop1[i].orig_ord_as_flag=2))
    SET reply->row[i].col[2].data_string = "Hx"
   ENDIF
   SET reply->row[i].col[3].data_string = med_recon_request->pop1[i].order_status
   SET reply->row[i].col[4].data_string = med_recon_request->pop1[i].acompliance_status
   SET reply->row[i].col[5].data_string = med_recon_request->pop1[i].acompliance_date
   SET reply->row[i].col[6].data_string = med_recon_request->pop1[i].acompliance_person
   SET reply->row[i].col[7].data_string = med_recon_request->pop1[i].arecon_type
   IF ((med_recon_request->pop1[i].arecon_action_mean="SUSPEND"))
    SET reply->row[i].col[8].data_string = "Suspend"
   ELSEIF ((med_recon_request->pop1[i].arecon_action_mean="RECON_DO_NOT_CNVT"))
    SET reply->row[i].col[8].data_string = "Do not Convert"
   ELSEIF ((med_recon_request->pop1[i].arecon_action_mean="DISCONTINUE"))
    SET reply->row[i].col[8].data_string = "Discontinue"
   ELSEIF ((med_recon_request->pop1[i].arecon_action_mean="RECON_CONTINUE"))
    SET reply->row[i].col[8].data_string = "Continue"
   ELSEIF ((med_recon_request->pop1[i].arecon_action_mean="CONVERT_RX"))
    SET reply->row[i].col[8].data_string = "Convert to Prescription"
   ELSEIF ((med_recon_request->pop1[i].arecon_action_mean="RECON_RESUME"))
    SET reply->row[i].col[8].data_string = "Resume"
   ELSEIF ((med_recon_request->pop1[i].arecon_action_mean="ORDER"))
    SET reply->row[i].col[8].data_string = "Order"
   ELSE
    SET reply->row[i].col[8].data_string = med_recon_request->pop1[i].arecon_action_mean
   ENDIF
   SET reply->row[i].col[9].data_string = med_recon_request->pop1[i].arecon_prsnl
   SET reply->row[i].col[10].data_string = med_recon_request->pop1[i].areplaced_order
   SET reply->row[i].col[1].data_string = concat(trim(med_recon_request->pop1[i].order_mnemonic),", ",
    med_recon_request->pop1[i].clinical_display_line)
   SET reply->row[i].col[1].data_string = concat(trim(reply->row[i].col[1].data_string," ",
     uar_get_code_display(med_recon_request->pop1[i].frequency)))
 ENDFOR
 SET reply->status_data.status = "S"
END GO

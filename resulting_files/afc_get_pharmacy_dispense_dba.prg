CREATE PROGRAM afc_get_pharmacy_dispense:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 action_type = c3
    1 charge_event_qual = i2
    1 charge_event[*]
      2 ext_master_event_id = f8
      2 ext_master_event_cont_cd = f8
      2 ext_master_reference_id = f8
      2 ext_master_reference_cont_cd = f8
      2 ext_parent_event_id = f8
      2 ext_parent_event_cont_cd = f8
      2 ext_parent_reference_id = f8
      2 ext_parent_reference_cont_cd = f8
      2 ext_item_event_id = f8
      2 ext_item_event_cont_cd = f8
      2 ext_item_reference_id = f8
      2 ext_item_reference_cont_cd = f8
      2 order_id = f8
      2 contributor_system_cd = f8
      2 reference_nbr = vc
      2 person_id = f8
      2 person_name = vc
      2 encntr_id = f8
      2 collection_priority_cd = f8
      2 report_priority_cd = f8
      2 accession = vc
      2 epsdt_ind = i2
      2 order_mnemonic = c20
      2 mnemonic = c20
      2 activity_type_disp = c40
      2 misc_ind = i2
      2 misc_price = f8
      2 misc_description = vc
      2 perf_loc_cd = f8
      2 charge_event_act_qual = i2
      2 charge_event_act[*]
        3 charge_event_id = f8
        3 cea_type_cd = f8
        3 cea_type_disp = vc
        3 service_resource_cd = f8
        3 service_dt_tm = dq8
        3 charge_dt_tm = dq8
        3 charge_type_cd = f8
        3 reference_range_factor_id = f8
        3 alpha_nomen_id = f8
        3 quantity = i4
        3 units = f8
        3 unit_type_cd = f8
        3 patient_loc_cd = f8
        3 service_loc_cd = f8
        3 reason_cd = f8
        3 in_lab_dt_tm = dq8
        3 in_transit_dt_tm = dq8
        3 cea_prsnl_id = f8
        3 cea_prsnl_type_cd = f8
        3 details = vc
        3 price_sched_id = f8
        3 ext_price = f8
        3 cost = f8
        3 bill_code_sched_cd = f8
        3 bill_code = vc
        3 item_desc = vc
        3 pharm_quantity = f8
        3 item_price = f8
        3 misc_ind = i2
        3 result = vc
        3 item_copay = f8
        3 item_reimbursement = f8
        3 discount_amount = f8
        3 health_plan_id = f8
        3 prsnl_qual = i2
        3 prsnl[*]
          4 prsnl_id = f8
          4 prsnl_type_cd = f8
      2 charge_event_mod_qual = i2
      2 charge_event_mod[*]
        3 charge_event_id = f8
        3 charge_event_mod_type_cd = f8
        3 field1 = vc
        3 field2 = vc
        3 field3 = vc
        3 field4 = vc
        3 field1_id = f8
        3 field5 = vc
        3 field6 = vc
        3 field7 = vc
        3 field8 = vc
        3 field9 = vc
        3 field10 = vc
        3 field2_id = f8
        3 field3_id = f8
        3 nomen_id = f8
      2 nomen_qual = i2
      2 nomen[*]
        3 nomen_id = f8
  )
 ENDIF
 RECORD pha_rcvy(
   1 data_cnt = i4
   1 data[*]
     2 dispense_hx_id = f8
     2 parent_ind = i2
     2 reverse_ind = i2
     2 order_id = f8
     2 action_seq = i4
     2 disp_dt_tm = dq8
     2 doses = f8
     2 price = f8
     2 encntr_id = f8
     2 item_id = f8
     2 tnf_id = f8
     2 ingred_seq = i4
     2 manf_item_id = f8
     2 qty = f8
     2 cdm = vc
     2 label_desc = vc
     2 catalog_cd = f8
     2 charge_event_id = f8
     2 details = vc
     2 price_sched_id = f8
     2 person_id = f8
     2 person_name = c30
     2 found_charge = i2
     2 ndc = vc
     2 credit_ind = i2
     2 med_def_flex_id = f8
     2 start_dt_tm = dq8
     2 facility_cd = f8
     2 future_charge_ind = i2
     2 charge_on_sched_admin_ind = i2
     2 rx_admin_dispense_hx_id = f8
     2 admin_dt_tm = dq8
     2 ndc_reference_id = f8
     2 billing_factor_nbr = f8
     2 billing_uom_cd = f8
     2 scan_flag = i2
     2 table_reverse_ind = i2
     2 already_reversed_ind = i2
     2 recover_ind = i2
     2 suppress_charge_flag = i2
     2 disp_event_type_cd = f8
     2 zero_waste_flag = i2
 )
 RECORD rev_data(
   1 data_cnt = i4
   1 data[*]
     2 rev_dispense_hx_id = f8
 )
 RECORD cosa_rev_data(
   1 data_cnt = i4
   1 data[*]
     2 rev_rx_admin_dispense_hx_id = f8
 )
 RECORD idx_data(
   1 data[*]
     2 item_id = f8
     2 pha_rcvy_idx = i4
 )
 RECORD pref_data(
   1 data[*]
     2 facility_cd = f8
     2 pref_nbr = i2
 )
 RECORD tempdata(
   1 qual[*]
     2 item_id = f8
     2 tnf_id = f8
     2 action_seq = i4
     2 dispense_hx_id = f8
     2 catalog_cd = f8
     2 ref_index = i4
     2 rx_admin_dispense_hx_id = f8
 ) WITH protect
 DECLARE setrecoverind(null) = null
 DECLARE cwastecharge = f8 WITH protect, constant(uar_get_code_by("MEANING",4032,"WASTECHARGE"))
 DECLARE cwastecredit = f8 WITH protect, constant(uar_get_code_by("MEANING",4032,"WASTECREDIT"))
 DECLARE csystem = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE csyspkgtyp = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE cdispense = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,"DISPENSE"))
 DECLARE cmedproduct = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,"MEDPRODUCT"))
 DECLARE cinpatient = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE ccdm = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"CDM"))
 DECLARE cdesc = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE cndc = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
 DECLARE cmeddef = f8 WITH protect, constant(uar_get_code_by("MEANING",11001,"MED_DEF"))
 DECLARE ccontrib_med_def = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,"MED DEF"))
 DECLARE cdispid = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,"DISP ID"))
 DECLARE cmanfitem = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,"MANF ITEM"))
 DECLARE cmeddefflex = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,"MED DEF FLEX"))
 DECLARE cordcat = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,"ORD CAT"))
 DECLARE ctnf_med = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,"TNF_MED"))
 DECLARE cbillcode = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,"BILL CODE"))
 DECLARE cadmindispid = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,"ADMINDISPID"))
 DECLARE ccredit = f8 WITH protect, constant(uar_get_code_by("MEANING",13028,"CR"))
 DECLARE cpharmdr = f8 WITH protect, constant(uar_get_code_by("MEANING",13028,"PHARMDR"))
 DECLARE cpharmcr = f8 WITH protect, constant(uar_get_code_by("MEANING",13028,"PHARMCR"))
 DECLARE cpharmnc = f8 WITH protect, constant(uar_get_code_by("MEANING",13028,"PHARMNC"))
 DECLARE cdispensed = f8 WITH protect, constant(uar_get_code_by("MEANING",13029,"DISPENSED"))
 DECLARE creverse = f8 WITH protect, constant(uar_get_code_by("MEANING",13029,"REVERSE"))
 DECLARE ccdmpharmsched = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14002,
   "CDMSCHEDPHARM"))
 DECLARE csched_type_ndc = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14002,"NDCNUMBER"))
 DECLARE ccode_modifier_jw = f8 WITH protect, constant(uar_get_code_by("DISPLAY",17769,"JW"))
 DECLARE ncompound = i2 WITH protect, constant(2)
 DECLARE cblocksize = i4 WITH protect, constant(100)
 DECLARE cexpandsize = i4 WITH protect, constant(25)
 DECLARE nscf_not_suppressed = i2 WITH protect, constant(0)
 DECLARE ccode_modifier_jz = f8 WITH protect, constant(uar_get_code_by("DISPLAY",17769,"JZ"))
 DECLARE slastmod = c3 WITH private, noconstant("000")
 DECLARE smoddate = c30 WITH private, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ncdmoptionind = i2 WITH protect, noconstant(0)
 DECLARE npriceschedschema = i2 WITH protect, noconstant(0)
 DECLARE nnewmodel = i2 WITH protect, noconstant(0)
 DECLARE lrevcnt = i4 WITH protect, noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE litem = i4 WITH protect, noconstant(0)
 DECLARE litemidx = i4 WITH protect, noconstant(0)
 DECLARE lrcvyidx = i4 WITH protect, noconstant(0)
 DECLARE lfacsize = i4 WITH protect, noconstant(0)
 DECLARE lfaccnt = i4 WITH protect, noconstant(0)
 DECLARE lfacidx = i4 WITH protect, noconstant(0)
 DECLARE nfirstingredmedtype = i2 WITH protect, noconstant(0)
 DECLARE nfirstcompingred = i2 WITH protect, noconstant(0)
 DECLARE lcosarevcnt = i4 WITH protect, noconstant(0)
 DECLARE dbillingfactor = f8 WITH protect, noconstant(0)
 DECLARE dbillinguomcd = f8 WITH protect, noconstant(0)
 DECLARE dschedtypemodifier = f8 WITH protect, noconstant(0.0)
 DECLARE nchargeeventmodsize = i2 WITH protect, noconstant(0.0)
 DECLARE lrecsize = i4 WITH protect, noconstant(0)
 DECLARE nstat = i2 WITH protect, noconstant(0)
 DECLARE llocindex = i4 WITH protect, noconstant(0)
 DECLARE lrefitemidx = i4 WITH protect, noconstant(0)
 DECLARE lexpandindex = i4 WITH protect, noconstant(0)
 DECLARE lexpandtotal = i4 WITH protect, noconstant(0)
 DECLARE lexpandactualsize = i4 WITH protect, noconstant(0)
 DECLARE lexpandstart = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM user_tab_columns u
  WHERE u.table_name="PROD_DISPENSE_HX"
   AND u.column_name="PRICE_SCHED_ID"
  HEAD REPORT
   npriceschedschema = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.person_id=0
   AND dp.pref_domain="PHARMNET-INPATIENT"
   AND dp.pref_section="BILLING"
   AND dp.pref_name="CDM OPTION"
  DETAIL
   IF (dp.pref_nbr=1)
    ncdmoptionind = 1
   ELSE
    ncdmoptionind = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.person_id=0
   AND dp.pref_domain="PHARMNET-INPATIENT"
   AND dp.pref_section="FRMLRYMGMT"
   AND dp.pref_name="NEW MODEL"
  DETAIL
   IF (dp.pref_nbr=1)
    nnewmodel = 1
   ELSE
    nnewmodel = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM dispense_hx dh,
   orders o,
   order_dispense od,
   person p,
   price_sched ps,
   prod_dispense_hx pdh,
   med_def_flex mdf,
   encounter e,
   medication_definition md
  PLAN (dh
   WHERE dh.dispense_dt_tm >= cnvtdatetime(request->beg_dt_tm)
    AND dh.dispense_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND ((dh.pharm_type_cd+ 0) IN (0.0, cinpatient))
    AND ((dh.charge_ind+ 0)=1)
    AND ((dh.charge_on_sched_admin_ind+ 0)=0))
   JOIN (o
   WHERE o.order_id=dh.order_id)
   JOIN (od
   WHERE od.order_id=o.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (ps
   WHERE (ps.price_sched_id= Outerjoin(od.price_schedule_id)) )
   JOIN (pdh
   WHERE pdh.dispense_hx_id=dh.dispense_hx_id)
   JOIN (mdf
   WHERE (mdf.item_id= Outerjoin(pdh.item_id))
    AND (mdf.flex_type_cd= Outerjoin(csystem))
    AND (mdf.pharmacy_type_cd= Outerjoin(cinpatient)) )
   JOIN (md
   WHERE md.item_id=pdh.item_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  ORDER BY dh.dispense_hx_id, pdh.ingred_sequence
  HEAD REPORT
   cnt = 0, lrevcnt = 0
  HEAD dh.dispense_hx_id
   IF (((dh.rev_dispense_hx_id=0) OR (dh.residual_doses > 0)) )
    cnt += 1
    IF (mod(cnt,10)=1)
     dstat = alterlist(pha_rcvy->data,(cnt+ 9))
    ENDIF
    nfirstingredmedtype = md.med_type_flag, nfirstcompingred = 0, pha_rcvy->data[cnt].parent_ind = 1,
    pha_rcvy->data[cnt].reverse_ind = 0, pha_rcvy->data[cnt].dispense_hx_id = dh.dispense_hx_id,
    pha_rcvy->data[cnt].order_id = dh.order_id,
    pha_rcvy->data[cnt].disp_dt_tm = cnvtdatetime(dh.dispense_dt_tm), pha_rcvy->data[cnt].
    table_reverse_ind = dh.reverse_ind, pha_rcvy->data[cnt].suppress_charge_flag = validate(dh
     .suppress_charge_flag,nscf_not_suppressed),
    pha_rcvy->data[cnt].disp_event_type_cd = dh.disp_event_type_cd
    IF (dh.residual_doses > 0)
     pha_rcvy->data[cnt].doses = dh.residual_doses, pha_rcvy->data[cnt].price = dh.residual_price
    ELSE
     pha_rcvy->data[cnt].doses = dh.doses, pha_rcvy->data[cnt].price = dh.event_total_price
    ENDIF
    pha_rcvy->data[cnt].action_seq = dh.action_sequence, pha_rcvy->data[cnt].catalog_cd = o
    .catalog_cd, pha_rcvy->data[cnt].price_sched_id = ps.price_sched_id,
    pha_rcvy->data[cnt].encntr_id = o.encntr_id, pha_rcvy->data[cnt].person_name = p
    .name_full_formatted, pha_rcvy->data[cnt].person_id = p.person_id,
    pha_rcvy->data[cnt].details = o.dept_misc_line, pha_rcvy->data[cnt].start_dt_tm = o
    .current_start_dt_tm, pha_rcvy->data[cnt].facility_cd = e.loc_facility_cd,
    pha_rcvy->data[cnt].future_charge_ind = dh.future_charge_ind
    IF (dh.future_charge_ind=1)
     lfacsize = size(pref_data->data,5), lfacidx = locateval(lfaccnt,1,lfacsize,e.loc_facility_cd,
      pref_data->data[lfaccnt].facility_cd)
     IF (lfacidx=0)
      lfacsize += 1, dstat = alterlist(pref_data->data,lfacsize), pref_data->data[lfacsize].
      facility_cd = e.loc_facility_cd
     ENDIF
    ENDIF
   ENDIF
   IF (dh.rev_dispense_hx_id > 0)
    lrevcnt += 1
    IF (mod(lrevcnt,10)=1)
     dstat = alterlist(rev_data->data,(lrevcnt+ 9))
    ENDIF
    rev_data->data[lrevcnt].rev_dispense_hx_id = dh.rev_dispense_hx_id
   ENDIF
  DETAIL
   IF (((dh.rev_dispense_hx_id=0) OR (dh.residual_doses > 0))
    AND nfirstcompingred=0)
    IF (nfirstingredmedtype=ncompound)
     nfirstcompingred = 1
    ENDIF
    cnt += 1
    IF (mod(cnt,10)=1)
     dstat = alterlist(pha_rcvy->data,(cnt+ 9))
    ENDIF
    pha_rcvy->data[cnt].dispense_hx_id = dh.dispense_hx_id, pha_rcvy->data[cnt].parent_ind = 0,
    pha_rcvy->data[cnt].reverse_ind = 0,
    pha_rcvy->data[cnt].order_id = dh.order_id, pha_rcvy->data[cnt].item_id = pdh.item_id, pha_rcvy->
    data[cnt].tnf_id = pdh.tnf_id,
    pha_rcvy->data[cnt].disp_dt_tm = cnvtdatetime(dh.dispense_dt_tm), pha_rcvy->data[cnt].
    table_reverse_ind = dh.reverse_ind, pha_rcvy->data[cnt].suppress_charge_flag = validate(dh
     .suppress_charge_flag,nscf_not_suppressed),
    pha_rcvy->data[cnt].disp_event_type_cd = dh.disp_event_type_cd, pha_rcvy->data[cnt].encntr_id = o
    .encntr_id, pha_rcvy->data[cnt].person_name = p.name_full_formatted,
    pha_rcvy->data[cnt].person_id = p.person_id, pha_rcvy->data[cnt].details = o.dept_misc_line
    IF (dh.residual_doses > 0)
     pha_rcvy->data[cnt].doses = dh.residual_doses, pha_rcvy->data[cnt].price = pdh.residual_price
    ELSE
     pha_rcvy->data[cnt].doses = dh.doses, pha_rcvy->data[cnt].price = pdh.price
    ENDIF
    IF (pdh.charge_qty > 0)
     pha_rcvy->data[cnt].credit_ind = 0, pha_rcvy->data[cnt].qty = pdh.charge_qty
    ELSEIF (dh.residual_doses > 0)
     pha_rcvy->data[cnt].credit_ind = 0, pha_rcvy->data[cnt].qty = pdh.residual_qty
    ELSE
     pha_rcvy->data[cnt].credit_ind = 1, pha_rcvy->data[cnt].qty = pdh.credit_qty
    ENDIF
    pha_rcvy->data[cnt].ingred_seq = pdh.ingred_sequence, pha_rcvy->data[cnt].action_seq = dh
    .action_sequence
    IF (npriceschedschema=0)
     pha_rcvy->data[cnt].price_sched_id = 0
    ELSE
     pha_rcvy->data[cnt].price_sched_id = pdh.price_sched_id
    ENDIF
    pha_rcvy->data[cnt].charge_event_id = 0
    IF ((pha_rcvy->data[cnt].tnf_id > 0))
     pha_rcvy->data[cnt].manf_item_id = 1
    ELSE
     IF (ncdmoptionind=1)
      pha_rcvy->data[cnt].med_def_flex_id = mdf.med_def_flex_id
     ELSE
      IF (nnewmodel=1)
       pha_rcvy->data[cnt].manf_item_id = pdh.manf_item_id
      ELSE
       pha_rcvy->data[cnt].manf_item_id = 0
      ENDIF
     ENDIF
    ENDIF
    IF (ps.formula_type_flg=0)
     pha_rcvy->data[cnt].price_sched_id = ps.price_sched_id
    ENDIF
    pha_rcvy->data[cnt].scan_flag = validate(pdh.scan_flag,0), dstat = assign(pha_rcvy->data[cnt].
     zero_waste_flag,validate(pdh.zero_waste_flag,0))
   ENDIF
  FOOT  dh.dispense_hx_id
   dstat = 0
  FOOT REPORT
   pha_rcvy->data_cnt = cnt, dstat = alterlist(rev_data->data,lrevcnt), rev_data->data_cnt = lrevcnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM rx_admin_dispense_hx radh,
   dispense_hx dh,
   orders o,
   order_dispense od,
   person p,
   price_sched ps,
   rx_admin_prod_dispense_hx rapdh,
   med_def_flex mdf,
   encounter e
  PLAN (radh
   WHERE radh.admin_dt_tm >= cnvtdatetime(request->beg_dt_tm)
    AND radh.admin_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND radh.charge_flag=1)
   JOIN (dh
   WHERE dh.dispense_hx_id=radh.dispense_hx_id
    AND ((dh.pharm_type_cd+ 0) IN (0.0, cinpatient))
    AND ((dh.charge_ind+ 0)=1)
    AND ((dh.charge_on_sched_admin_ind+ 0)=1))
   JOIN (o
   WHERE o.order_id=dh.order_id)
   JOIN (od
   WHERE od.order_id=o.order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (rapdh
   WHERE rapdh.rx_admin_dispense_hx_id=radh.rx_admin_dispense_hx_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (ps
   WHERE (ps.price_sched_id= Outerjoin(od.price_schedule_id)) )
   JOIN (mdf
   WHERE (mdf.item_id= Outerjoin(rapdh.item_id))
    AND (mdf.flex_type_cd= Outerjoin(csystem))
    AND (mdf.pharmacy_type_cd= Outerjoin(cinpatient)) )
  ORDER BY radh.rx_admin_dispense_hx_id, rapdh.ingred_sequence
  HEAD REPORT
   cnt = pha_rcvy->data_cnt
  HEAD radh.rx_admin_dispense_hx_id
   lcosarevprodcnt = 0
   IF (((radh.rev_rx_admin_dispense_hx_id=0) OR (radh.residual_dose_amt > 0)) )
    cnt += 1
    IF (mod(cnt,10)=1)
     dstat = alterlist(pha_rcvy->data,(cnt+ 9))
    ENDIF
    pha_rcvy->data[cnt].charge_on_sched_admin_ind = 1, pha_rcvy->data[cnt].parent_ind = 1, pha_rcvy->
    data[cnt].reverse_ind = 0,
    pha_rcvy->data[cnt].dispense_hx_id = dh.dispense_hx_id, pha_rcvy->data[cnt].order_id = dh
    .order_id, pha_rcvy->data[cnt].disp_dt_tm = cnvtdatetime(dh.dispense_dt_tm),
    pha_rcvy->data[cnt].rx_admin_dispense_hx_id = radh.rx_admin_dispense_hx_id, pha_rcvy->data[cnt].
    admin_dt_tm = cnvtdatetime(radh.admin_dt_tm), pha_rcvy->data[cnt].table_reverse_ind = radh
    .reverse_ind,
    pha_rcvy->data[cnt].suppress_charge_flag = validate(radh.suppress_charge_flag,nscf_not_suppressed
     ), pha_rcvy->data[cnt].disp_event_type_cd = dh.disp_event_type_cd
    IF (radh.residual_dose_amt > 0)
     pha_rcvy->data[cnt].doses = radh.residual_dose_amt, pha_rcvy->data[cnt].price = radh
     .residual_price_amt
    ELSE
     pha_rcvy->data[cnt].doses = radh.dose_amt, pha_rcvy->data[cnt].price = radh
     .admin_total_price_amt
    ENDIF
    pha_rcvy->data[cnt].action_seq = dh.action_sequence, pha_rcvy->data[cnt].catalog_cd = o
    .catalog_cd, pha_rcvy->data[cnt].price_sched_id = ps.price_sched_id,
    pha_rcvy->data[cnt].encntr_id = o.encntr_id, pha_rcvy->data[cnt].person_name = p
    .name_full_formatted, pha_rcvy->data[cnt].person_id = p.person_id,
    pha_rcvy->data[cnt].details = o.dept_misc_line, pha_rcvy->data[cnt].start_dt_tm = o
    .current_start_dt_tm, pha_rcvy->data[cnt].facility_cd = e.loc_facility_cd,
    pha_rcvy->data[cnt].future_charge_ind = dh.future_charge_ind
    IF (dh.future_charge_ind=1)
     lfacsize = size(pref_data->data,5), lfacidx = locateval(lfaccnt,1,lfacsize,e.loc_facility_cd,
      pref_data->data[lfaccnt].facility_cd)
     IF (lfacidx=0)
      lfacsize += 1, dstat = alterlist(pref_data->data,lfacsize), pref_data->data[lfacsize].
      facility_cd = e.loc_facility_cd
     ENDIF
    ENDIF
   ENDIF
   IF (radh.rev_rx_admin_dispense_hx_id > 0)
    lcosarevcnt += 1
    IF (mod(lcosarevcnt,10)=1)
     dstat = alterlist(cosa_rev_data->data,(lcosarevcnt+ 9))
    ENDIF
    cosa_rev_data->data[lcosarevcnt].rev_rx_admin_dispense_hx_id = radh.rev_rx_admin_dispense_hx_id
   ENDIF
  DETAIL
   IF (((radh.rev_rx_admin_dispense_hx_id=0) OR (radh.residual_dose_amt > 0)) )
    cnt += 1
    IF (mod(cnt,10)=1)
     dstat = alterlist(pha_rcvy->data,(cnt+ 9))
    ENDIF
    pha_rcvy->data[cnt].charge_on_sched_admin_ind = 1, pha_rcvy->data[cnt].dispense_hx_id = dh
    .dispense_hx_id, pha_rcvy->data[cnt].parent_ind = 0,
    pha_rcvy->data[cnt].reverse_ind = 0, pha_rcvy->data[cnt].order_id = dh.order_id, pha_rcvy->data[
    cnt].item_id = rapdh.item_id,
    pha_rcvy->data[cnt].tnf_id = rapdh.tnf_id, pha_rcvy->data[cnt].disp_dt_tm = cnvtdatetime(dh
     .dispense_dt_tm), pha_rcvy->data[cnt].rx_admin_dispense_hx_id = radh.rx_admin_dispense_hx_id,
    pha_rcvy->data[cnt].admin_dt_tm = cnvtdatetime(radh.admin_dt_tm), pha_rcvy->data[cnt].
    table_reverse_ind = radh.reverse_ind, pha_rcvy->data[cnt].suppress_charge_flag = validate(radh
     .suppress_charge_flag,nscf_not_suppressed),
    pha_rcvy->data[cnt].disp_event_type_cd = dh.disp_event_type_cd, pha_rcvy->data[cnt].encntr_id = o
    .encntr_id, pha_rcvy->data[cnt].person_name = p.name_full_formatted,
    pha_rcvy->data[cnt].person_id = p.person_id, pha_rcvy->data[cnt].details = o.dept_misc_line
    IF (radh.residual_dose_amt > 0)
     pha_rcvy->data[cnt].doses = radh.residual_dose_amt, pha_rcvy->data[cnt].price = rapdh
     .residual_price_amt
    ELSE
     pha_rcvy->data[cnt].doses = radh.dose_amt, pha_rcvy->data[cnt].price = rapdh.price_amt
    ENDIF
    IF (rapdh.charge_qty > 0)
     pha_rcvy->data[cnt].credit_ind = 0, pha_rcvy->data[cnt].qty = rapdh.charge_qty
    ELSEIF (radh.residual_dose_amt > 0)
     pha_rcvy->data[cnt].credit_ind = 0, pha_rcvy->data[cnt].qty = rapdh.residual_qty
    ELSE
     pha_rcvy->data[cnt].credit_ind = 1, pha_rcvy->data[cnt].qty = rapdh.credit_qty
    ENDIF
    pha_rcvy->data[cnt].ingred_seq = rapdh.ingred_sequence, pha_rcvy->data[cnt].action_seq = dh
    .action_sequence
    IF (npriceschedschema=0)
     pha_rcvy->data[cnt].price_sched_id = 0
    ELSE
     pha_rcvy->data[cnt].price_sched_id = rapdh.price_sched_id
    ENDIF
    pha_rcvy->data[cnt].charge_event_id = 0
    IF ((pha_rcvy->data[cnt].tnf_id > 0))
     pha_rcvy->data[cnt].manf_item_id = 1
    ELSE
     IF (ncdmoptionind=1)
      pha_rcvy->data[cnt].med_def_flex_id = mdf.med_def_flex_id
     ELSE
      IF (nnewmodel=1)
       pha_rcvy->data[cnt].manf_item_id = rapdh.manf_item_id
      ELSE
       pha_rcvy->data[cnt].manf_item_id = 0
      ENDIF
     ENDIF
    ENDIF
    IF (ps.formula_type_flg=0)
     pha_rcvy->data[cnt].price_sched_id = ps.price_sched_id
    ENDIF
   ENDIF
  FOOT  radh.rx_admin_dispense_hx_id
   dstat = 0
  FOOT REPORT
   pha_rcvy->data_cnt = cnt, dstat = alterlist(cosa_rev_data->data,lcosarevcnt), cosa_rev_data->
   data_cnt = lcosarevcnt
  WITH nocounter
 ;end select
 IF ((pha_rcvy->data_cnt <= 0))
  GO TO exit_script
 ENDIF
 IF (lrevcnt > 0)
  SELECT INTO "nl:"
   *
   FROM (dummyt d  WITH seq = value(lrevcnt)),
    dispense_hx dh,
    orders o,
    order_dispense od,
    person p,
    price_sched ps,
    prod_dispense_hx pdh,
    med_def_flex mdf,
    medication_definition md
   PLAN (d)
    JOIN (dh
    WHERE (dh.dispense_hx_id=rev_data->data[d.seq].rev_dispense_hx_id))
    JOIN (o
    WHERE dh.order_id=o.order_id)
    JOIN (od
    WHERE od.order_id=o.order_id)
    JOIN (p
    WHERE p.person_id=o.person_id)
    JOIN (ps
    WHERE (ps.price_sched_id= Outerjoin(od.price_schedule_id)) )
    JOIN (pdh
    WHERE dh.dispense_hx_id=pdh.dispense_hx_id)
    JOIN (mdf
    WHERE (mdf.item_id= Outerjoin(pdh.item_id))
     AND (mdf.flex_type_cd= Outerjoin(csystem))
     AND (mdf.pharmacy_type_cd= Outerjoin(cinpatient)) )
    JOIN (md
    WHERE md.item_id=pdh.item_id)
   ORDER BY dh.dispense_hx_id, pdh.ingred_sequence
   HEAD REPORT
    cnt = pha_rcvy->data_cnt
   HEAD dh.dispense_hx_id
    nfirstingredmedtype = md.med_type_flag, nfirstcompingred = 0
   DETAIL
    IF (nfirstcompingred=0)
     IF (nfirstingredmedtype=ncompound)
      nfirstcompingred = 1
     ENDIF
     cnt += 1
     IF (mod(cnt,10)=1)
      dstat = alterlist(pha_rcvy->data,(cnt+ 9))
     ENDIF
     pha_rcvy->data[cnt].dispense_hx_id = dh.dispense_hx_id, pha_rcvy->data[cnt].parent_ind = 0,
     pha_rcvy->data[cnt].reverse_ind = 1,
     pha_rcvy->data[cnt].order_id = dh.order_id, pha_rcvy->data[cnt].item_id = pdh.item_id, pha_rcvy
     ->data[cnt].tnf_id = pdh.tnf_id,
     pha_rcvy->data[cnt].disp_dt_tm = cnvtdatetime(dh.dispense_dt_tm), pha_rcvy->data[cnt].
     table_reverse_ind = dh.reverse_ind, pha_rcvy->data[cnt].suppress_charge_flag = validate(dh
      .suppress_charge_flag,nscf_not_suppressed),
     pha_rcvy->data[cnt].disp_event_type_cd = dh.disp_event_type_cd, pha_rcvy->data[cnt].encntr_id =
     o.encntr_id, pha_rcvy->data[cnt].person_name = p.name_full_formatted,
     pha_rcvy->data[cnt].person_id = p.person_id, pha_rcvy->data[cnt].details = o.dept_misc_line
     IF (dh.residual_doses > 0)
      pha_rcvy->data[cnt].doses = dh.residual_doses, pha_rcvy->data[cnt].price = pdh.residual_price
     ELSE
      pha_rcvy->data[cnt].doses = dh.doses, pha_rcvy->data[cnt].price = pdh.price
     ENDIF
     IF (pdh.charge_qty > 0)
      pha_rcvy->data[cnt].credit_ind = 0, pha_rcvy->data[cnt].qty = pdh.charge_qty
     ELSE
      pha_rcvy->data[cnt].credit_ind = 0, pha_rcvy->data[cnt].qty = pdh.residual_qty
     ENDIF
     pha_rcvy->data[cnt].ingred_seq = pdh.ingred_sequence, pha_rcvy->data[cnt].action_seq = dh
     .action_sequence
     IF (npriceschedschema=0)
      pha_rcvy->data[cnt].price_sched_id = 0
     ELSE
      pha_rcvy->data[cnt].price_sched_id = pdh.price_sched_id
     ENDIF
     pha_rcvy->data[cnt].charge_event_id = 0
     IF ((pha_rcvy->data[cnt].tnf_id > 0))
      pha_rcvy->data[cnt].manf_item_id = 1
     ELSE
      IF (ncdmoptionind=1)
       pha_rcvy->data[cnt].med_def_flex_id = mdf.med_def_flex_id
      ELSE
       IF (nnewmodel=1)
        pha_rcvy->data[cnt].manf_item_id = pdh.manf_item_id
       ELSE
        pha_rcvy->data[cnt].manf_item_id = 0
       ENDIF
      ENDIF
     ENDIF
     IF (ps.formula_type_flg=0)
      pha_rcvy->data[cnt].price_sched_id = ps.price_sched_id
     ENDIF
    ENDIF
   FOOT  dh.dispense_hx_id
    dstat = 0
   FOOT REPORT
    pha_rcvy->data_cnt = cnt
   WITH nocounter
  ;end select
 ENDIF
 IF (lcosarevcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(lcosarevcnt)),
    rx_admin_dispense_hx radh,
    dispense_hx dh,
    orders o,
    order_dispense od,
    person p,
    price_sched ps,
    rx_admin_prod_dispense_hx rapdh,
    med_def_flex mdf
   PLAN (d)
    JOIN (radh
    WHERE (radh.rx_admin_dispense_hx_id=cosa_rev_data->data[d.seq].rev_rx_admin_dispense_hx_id)
     AND radh.charge_flag=1)
    JOIN (dh
    WHERE dh.dispense_hx_id=radh.dispense_hx_id)
    JOIN (o
    WHERE dh.order_id=o.order_id)
    JOIN (od
    WHERE od.order_id=o.order_id)
    JOIN (p
    WHERE p.person_id=o.person_id)
    JOIN (rapdh
    WHERE rapdh.rx_admin_dispense_hx_id=radh.rx_admin_dispense_hx_id)
    JOIN (ps
    WHERE (ps.price_sched_id= Outerjoin(od.price_schedule_id)) )
    JOIN (mdf
    WHERE (mdf.item_id= Outerjoin(rapdh.item_id))
     AND (mdf.flex_type_cd= Outerjoin(csystem))
     AND (mdf.pharmacy_type_cd= Outerjoin(cinpatient)) )
   ORDER BY radh.rx_admin_dispense_hx_id, rapdh.ingred_sequence
   HEAD REPORT
    cnt = pha_rcvy->data_cnt
   HEAD radh.rx_admin_dispense_hx_id
    dstat = 0
   DETAIL
    cnt += 1
    IF (mod(cnt,10)=1)
     dstat = alterlist(pha_rcvy->data,(cnt+ 9))
    ENDIF
    pha_rcvy->data[cnt].charge_on_sched_admin_ind = 1, pha_rcvy->data[cnt].dispense_hx_id = dh
    .dispense_hx_id, pha_rcvy->data[cnt].parent_ind = 0,
    pha_rcvy->data[cnt].reverse_ind = 1, pha_rcvy->data[cnt].order_id = dh.order_id, pha_rcvy->data[
    cnt].item_id = rapdh.item_id,
    pha_rcvy->data[cnt].tnf_id = rapdh.tnf_id, pha_rcvy->data[cnt].disp_dt_tm = cnvtdatetime(dh
     .dispense_dt_tm), pha_rcvy->data[cnt].rx_admin_dispense_hx_id = radh.rx_admin_dispense_hx_id,
    pha_rcvy->data[cnt].admin_dt_tm = cnvtdatetime(radh.admin_dt_tm), pha_rcvy->data[cnt].
    table_reverse_ind = radh.reverse_ind, pha_rcvy->data[cnt].suppress_charge_flag = validate(radh
     .suppress_charge_flag,nscf_not_suppressed),
    pha_rcvy->data[cnt].disp_event_type_cd = dh.disp_event_type_cd, pha_rcvy->data[cnt].encntr_id = o
    .encntr_id, pha_rcvy->data[cnt].person_name = p.name_full_formatted,
    pha_rcvy->data[cnt].person_id = p.person_id, pha_rcvy->data[cnt].details = o.dept_misc_line
    IF (radh.residual_dose_amt > 0)
     pha_rcvy->data[cnt].doses = radh.residual_dose_amt, pha_rcvy->data[cnt].price = rapdh
     .residual_price_amt
    ELSE
     pha_rcvy->data[cnt].doses = radh.dose_amt, pha_rcvy->data[cnt].price = rapdh.price_amt
    ENDIF
    IF (rapdh.charge_qty > 0)
     pha_rcvy->data[cnt].credit_ind = 0, pha_rcvy->data[cnt].qty = rapdh.charge_qty
    ELSE
     pha_rcvy->data[cnt].credit_ind = 0, pha_rcvy->data[cnt].qty = rapdh.residual_qty
    ENDIF
    pha_rcvy->data[cnt].ingred_seq = rapdh.ingred_sequence, pha_rcvy->data[cnt].action_seq = dh
    .action_sequence
    IF (npriceschedschema=0)
     pha_rcvy->data[cnt].price_sched_id = 0
    ELSE
     pha_rcvy->data[cnt].price_sched_id = rapdh.price_sched_id
    ENDIF
    pha_rcvy->data[cnt].charge_event_id = 0
    IF ((pha_rcvy->data[cnt].tnf_id > 0))
     pha_rcvy->data[cnt].manf_item_id = 1
    ELSE
     IF (ncdmoptionind=1)
      pha_rcvy->data[cnt].med_def_flex_id = mdf.med_def_flex_id
     ELSE
      IF (nnewmodel=1)
       pha_rcvy->data[cnt].manf_item_id = rapdh.manf_item_id
      ELSE
       pha_rcvy->data[cnt].manf_item_id = 0
      ENDIF
     ENDIF
    ENDIF
    IF (ps.formula_type_flg=0)
     pha_rcvy->data[cnt].price_sched_id = ps.price_sched_id
    ENDIF
   FOOT  radh.rx_admin_dispense_hx_id
    dstat = 0
   FOOT REPORT
    pha_rcvy->data_cnt = cnt
   WITH nocounter
  ;end select
 ENDIF
 SET dstat = alterlist(pha_rcvy->data,pha_rcvy->data_cnt)
 SET lrecsize = size(pha_rcvy->data,5)
 SET cnt2 = 0
 FOR (cnt = 1 TO lrecsize)
   IF ((pha_rcvy->data[cnt].parent_ind=0)
    AND (pha_rcvy->data[cnt].tnf_id > 0))
    SET cnt2 += 1
    IF (mod(cnt2,cblocksize)=1)
     SET nstat = alterlist(tempdata->qual,((cnt2+ cblocksize) - 1))
    ENDIF
    SET tempdata->qual[cnt2].tnf_id = pha_rcvy->data[cnt].tnf_id
    SET tempdata->qual[cnt2].action_seq = pha_rcvy->data[cnt].action_seq
    SET tempdata->qual[cnt2].ref_index = cnt
   ENDIF
 ENDFOR
 SET nstat = alterlist(tempdata->qual,cnt2)
 SET lexpandactualsize = size(tempdata->qual,5)
 IF (lexpandactualsize != 0)
  SET lexpandtotal = (ceil((cnvtreal(lexpandactualsize)/ cexpandsize)) * cexpandsize)
  SET lexpandstart = 1
  SET nstat = alterlist(tempdata->qual,lexpandtotal)
  FOR (lexpandindex = (lexpandactualsize+ 1) TO lexpandtotal)
    SET tempdata->qual[lexpandindex].tnf_id = tempdata->qual[lexpandactualsize].tnf_id
    SET tempdata->qual[lexpandindex].action_seq = tempdata->qual[lexpandactualsize].action_seq
    SET tempdata->qual[lexpandindex].ref_index = tempdata->qual[lexpandactualsize].ref_index
  ENDFOR
  SELECT INTO "NL:"
   tf.shell_item_id, tf.description
   FROM (dummyt d1  WITH seq = value((1+ ((lexpandtotal - 1)/ cexpandsize)))),
    template_nonformulary tf,
    med_def_flex mdf,
    med_flex_object_idx mfoi,
    med_product mp,
    package_type pt
   PLAN (d1
    WHERE initarray(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
    JOIN (tf
    WHERE expand(lexpandindex,lexpandstart,(lexpandstart+ (cexpandsize - 1)),tf.tnf_id,tempdata->
     qual[lexpandindex].tnf_id,
     tf.action_sequence,tempdata->qual[lexpandindex].action_seq))
    JOIN (mdf
    WHERE mdf.item_id=tf.shell_item_id
     AND mdf.pharmacy_type_cd=cinpatient
     AND mdf.flex_type_cd=csystem)
    JOIN (mfoi
    WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
     AND mfoi.flex_object_type_cd=cmedproduct
     AND ((mfoi.sequence+ 0)=1))
    JOIN (mp
    WHERE mp.med_product_id=mfoi.parent_entity_id)
    JOIN (pt
    WHERE pt.item_id=mp.manf_item_id
     AND pt.base_package_type_ind=1)
   ORDER BY tf.tnf_id, tf.action_sequence
   HEAD tf.tnf_id
    row + 0
   HEAD tf.action_sequence
    litemidx = locateval(llocindex,1,lexpandactualsize,tf.tnf_id,tempdata->qual[llocindex].tnf_id,
     tf.action_sequence,tempdata->qual[llocindex].action_seq)
    WHILE (litemidx > 0)
      lrefitemidx = tempdata->qual[litemidx].ref_index
      IF (lrefitemidx > 0)
       pha_rcvy->data[lrefitemidx].item_id = tf.shell_item_id, pha_rcvy->data[lrefitemidx].label_desc
        = tf.description, pha_rcvy->data[lrefitemidx].ndc = tf.ndc,
       pha_rcvy->data[lrefitemidx].ndc_reference_id = tf.tnf_id, pha_rcvy->data[lrefitemidx].
       billing_factor_nbr = 1, pha_rcvy->data[lrefitemidx].billing_uom_cd = pt.uom_cd
      ENDIF
      litemidx = locateval(llocindex,(litemidx+ 1),lexpandactualsize,tf.tnf_id,tempdata->qual[
       llocindex].tnf_id,
       tf.action_sequence,tempdata->qual[llocindex].action_seq)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstat = initrec(tempdata)
 ENDIF
 SET lrecsize = size(pha_rcvy->data,5)
 SET cnt2 = 0
 FOR (cnt = 1 TO lrecsize)
   IF ((pha_rcvy->data[cnt].parent_ind=0)
    AND (pha_rcvy->data[cnt].item_id > 0)
    AND (pha_rcvy->data[cnt].catalog_cd=0))
    SET cnt2 += 1
    IF (mod(cnt2,cblocksize)=1)
     SET nstat = alterlist(tempdata->qual,((cnt2+ cblocksize) - 1))
    ENDIF
    SET tempdata->qual[cnt2].item_id = pha_rcvy->data[cnt].item_id
    SET tempdata->qual[cnt2].ref_index = cnt
   ENDIF
 ENDFOR
 SET nstat = alterlist(tempdata->qual,cnt2)
 SET lexpandactualsize = size(tempdata->qual,5)
 IF (lexpandactualsize != 0)
  SET lexpandtotal = (ceil((cnvtreal(lexpandactualsize)/ cexpandsize)) * cexpandsize)
  SET lexpandstart = 1
  SET nstat = alterlist(tempdata->qual,lexpandtotal)
  FOR (lexpandindex = (lexpandactualsize+ 1) TO lexpandtotal)
   SET tempdata->qual[lexpandindex].item_id = tempdata->qual[lexpandactualsize].item_id
   SET tempdata->qual[lexpandindex].ref_index = tempdata->qual[lexpandactualsize].ref_index
  ENDFOR
  SELECT INTO "NL:"
   oci.catalog_cd
   FROM (dummyt d1  WITH seq = value((1+ ((lexpandtotal - 1)/ cexpandsize)))),
    order_catalog_item_r oci
   PLAN (d1
    WHERE initarray(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
    JOIN (oci
    WHERE expand(lexpandindex,lexpandstart,(lexpandstart+ (cexpandsize - 1)),oci.item_id,tempdata->
     qual[lexpandindex].item_id))
   HEAD oci.item_id
    litemidx = locateval(llocindex,1,lexpandactualsize,oci.item_id,tempdata->qual[llocindex].item_id)
    WHILE (litemidx > 0)
      lrefitemidx = tempdata->qual[litemidx].ref_index
      IF (lrefitemidx > 0)
       pha_rcvy->data[lrefitemidx].catalog_cd = oci.catalog_cd
      ENDIF
      litemidx = locateval(llocindex,(litemidx+ 1),lexpandactualsize,oci.item_id,tempdata->qual[
       llocindex].item_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstat = initrec(tempdata)
 ENDIF
 IF (nnewmodel=0)
  SET lrecsize = size(pha_rcvy->data,5)
  SET cnt2 = 0
  FOR (cnt = 1 TO lrecsize)
    IF ((pha_rcvy->data[cnt].parent_ind=0)
     AND (pha_rcvy->data[cnt].item_id > 0)
     AND (pha_rcvy->data[cnt].manf_item_id=0)
     AND (pha_rcvy->data[cnt].tnf_id=0))
     SET cnt2 += 1
     IF (mod(cnt2,cblocksize)=1)
      SET nstat = alterlist(tempdata->qual,((cnt2+ cblocksize) - 1))
     ENDIF
     SET tempdata->qual[cnt2].item_id = pha_rcvy->data[cnt].item_id
     SET tempdata->qual[cnt2].ref_index = cnt
    ENDIF
  ENDFOR
  SET nstat = alterlist(tempdata->qual,cnt2)
  SET lexpandactualsize = size(tempdata->qual,5)
  IF (lexpandactualsize != 0)
   SET lexpandtotal = (ceil((cnvtreal(lexpandactualsize)/ cexpandsize)) * cexpandsize)
   SET lexpandstart = 1
   SET nstat = alterlist(tempdata->qual,lexpandtotal)
   FOR (lexpandindex = (lexpandactualsize+ 1) TO lexpandtotal)
    SET tempdata->qual[lexpandindex].item_id = tempdata->qual[lexpandactualsize].item_id
    SET tempdata->qual[lexpandindex].ref_index = tempdata->qual[lexpandactualsize].ref_index
   ENDFOR
   SELECT INTO "NL:"
    md.primary_manf_item_id, oii.value
    FROM (dummyt d1  WITH seq = value((1+ ((lexpandtotal - 1)/ cexpandsize)))),
     medication_definition md,
     object_identifier_index oii
    PLAN (d1
     WHERE initarray(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
     JOIN (md
     WHERE expand(lexpandindex,lexpandstart,(lexpandstart+ (cexpandsize - 1)),md.item_id,tempdata->
      qual[lexpandindex].item_id))
     JOIN (oii
     WHERE (oii.object_id=(md.primary_manf_item_id+ 0))
      AND oii.identifier_type_cd=cndc)
    ORDER BY md.item_id, oii.primary_ind DESC
    HEAD md.item_id
     litemidx = locateval(llocindex,1,lexpandactualsize,md.item_id,tempdata->qual[llocindex].item_id)
     WHILE (litemidx > 0)
       lrefitemidx = tempdata->qual[litemidx].ref_index
       IF (lrefitemidx > 0)
        pha_rcvy->data[lrefitemidx].manf_item_id = md.primary_manf_item_id, pha_rcvy->data[
        lrefitemidx].ndc = trim(substring(1,13,oii.value))
       ENDIF
       litemidx = locateval(llocindex,(litemidx+ 1),lexpandactualsize,md.item_id,tempdata->qual[
        llocindex].item_id)
     ENDWHILE
    WITH nocounter
   ;end select
   SET nstat = initrec(tempdata)
  ENDIF
 ELSEIF (nnewmodel=1)
  SET lrecsize = size(pha_rcvy->data,5)
  SET cnt2 = 0
  FOR (cnt = 1 TO lrecsize)
    IF ((pha_rcvy->data[cnt].parent_ind=0)
     AND (pha_rcvy->data[cnt].item_id > 0)
     AND (pha_rcvy->data[cnt].tnf_id=0))
     SET cnt2 += 1
     IF (mod(cnt2,cblocksize)=1)
      SET nstat = alterlist(tempdata->qual,((cnt2+ cblocksize) - 1))
     ENDIF
     SET tempdata->qual[cnt2].item_id = pha_rcvy->data[cnt].item_id
     SET tempdata->qual[cnt2].ref_index = cnt
    ENDIF
  ENDFOR
  SET nstat = alterlist(tempdata->qual,cnt2)
  SET lexpandactualsize = size(tempdata->qual,5)
  IF (lexpandactualsize != 0)
   SET lexpandtotal = (ceil((cnvtreal(lexpandactualsize)/ cexpandsize)) * cexpandsize)
   SET lexpandstart = 1
   SET nstat = alterlist(tempdata->qual,lexpandtotal)
   FOR (lexpandindex = (lexpandactualsize+ 1) TO lexpandtotal)
    SET tempdata->qual[lexpandindex].item_id = tempdata->qual[lexpandactualsize].item_id
    SET tempdata->qual[lexpandindex].ref_index = tempdata->qual[lexpandactualsize].ref_index
   ENDFOR
   SELECT INTO "NL:"
    mp.manf_item_id, mi.value
    FROM (dummyt d1  WITH seq = value((1+ ((lexpandtotal - 1)/ cexpandsize)))),
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_product mp,
     med_identifier mi,
     package_type pt
    PLAN (d1
     WHERE initarray(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
     JOIN (mdf
     WHERE expand(lexpandindex,lexpandstart,(lexpandstart+ (cexpandsize - 1)),mdf.item_id,tempdata->
      qual[lexpandindex].item_id)
      AND mdf.pharmacy_type_cd=cinpatient
      AND mdf.flex_type_cd=csystem)
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
      AND mfoi.flex_object_type_cd=cmedproduct)
     JOIN (mp
     WHERE (mp.med_product_id=(mfoi.parent_entity_id+ 0)))
     JOIN (mi
     WHERE (mi.item_id=(mdf.item_id+ 0))
      AND mi.med_identifier_type_cd=cndc
      AND (mi.med_product_id=(mp.med_product_id+ 0)))
     JOIN (pt
     WHERE pt.item_id=mp.manf_item_id
      AND pt.base_package_type_ind=1)
    ORDER BY mdf.item_id, mp.manf_item_id, mfoi.sequence,
     mi.primary_ind DESC
    HEAD mdf.item_id
     row + 0
    HEAD mp.manf_item_id
     row + 0
    HEAD mfoi.sequence
     row + 0, litemidx = locateval(llocindex,1,lexpandactualsize,mdf.item_id,tempdata->qual[llocindex
      ].item_id)
     WHILE (litemidx > 0)
       lrefitemidx = tempdata->qual[litemidx].ref_index
       IF (lrefitemidx > 0)
        IF ((((pha_rcvy->data[lrefitemidx].manf_item_id > 0)
         AND (mp.manf_item_id=pha_rcvy->data[lrefitemidx].manf_item_id)) OR ((pha_rcvy->data[
        lrefitemidx].manf_item_id=0)
         AND mfoi.sequence=1)) )
         pha_rcvy->data[lrefitemidx].manf_item_id = mp.manf_item_id, pha_rcvy->data[lrefitemidx].ndc
          = trim(mi.value), pha_rcvy->data[lrefitemidx].ndc_reference_id = mi.med_identifier_id,
         pha_rcvy->data[lrefitemidx].billing_uom_cd = pt.uom_cd
        ENDIF
       ENDIF
       litemidx = locateval(llocindex,(litemidx+ 1),lexpandactualsize,mdf.item_id,tempdata->qual[
        llocindex].item_id)
     ENDWHILE
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value((1+ ((lexpandtotal - 1)/ cexpandsize)))),
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_dispense md
    PLAN (d1
     WHERE initarray(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
     JOIN (mdf
     WHERE expand(lexpandindex,lexpandstart,(lexpandstart+ (cexpandsize - 1)),mdf.item_id,tempdata->
      qual[lexpandindex].item_id)
      AND mdf.pharmacy_type_cd=cinpatient
      AND mdf.flex_type_cd=csyspkgtyp)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=cdispense
      AND mfoi.sequence=1)
     JOIN (md
     WHERE md.med_dispense_id=mfoi.parent_entity_id)
    ORDER BY mdf.item_id
    HEAD mdf.item_id
     litemidx = locateval(llocindex,1,lexpandactualsize,mdf.item_id,tempdata->qual[llocindex].item_id
      )
     WHILE (litemidx > 0)
       lrefitemidx = tempdata->qual[litemidx].ref_index
       IF (lrefitemidx > 0)
        dbillingfactor = validate(md.billing_factor_nbr,0), dbillinguomcd = validate(md
         .billing_uom_cd,0)
        IF (dbillingfactor > 0
         AND dbillinguomcd > 0)
         pha_rcvy->data[lrefitemidx].billing_factor_nbr = dbillingfactor, pha_rcvy->data[lrefitemidx]
         .billing_uom_cd = dbillinguomcd
        ELSE
         pha_rcvy->data[lrefitemidx].billing_factor_nbr = md.dispense_factor
        ENDIF
       ENDIF
       litemidx = locateval(llocindex,(litemidx+ 1),lexpandactualsize,mdf.item_id,tempdata->qual[
        llocindex].item_id)
     ENDWHILE
    WITH nocounter
   ;end select
   SET nstat = initrec(tempdata)
  ENDIF
 ENDIF
 SET lrecsize = size(pha_rcvy->data,5)
 SET cnt2 = 0
 FOR (cnt = 1 TO lrecsize)
   IF ((pha_rcvy->data[cnt].parent_ind=0)
    AND (pha_rcvy->data[cnt].dispense_hx_id > 0)
    AND (pha_rcvy->data[cnt].charge_on_sched_admin_ind=0))
    SET cnt2 += 1
    IF (mod(cnt2,cblocksize)=1)
     SET nstat = alterlist(tempdata->qual,((cnt2+ cblocksize) - 1))
    ENDIF
    SET tempdata->qual[cnt2].dispense_hx_id = pha_rcvy->data[cnt].dispense_hx_id
    SET tempdata->qual[cnt2].ref_index = cnt
   ENDIF
 ENDFOR
 SET nstat = alterlist(tempdata->qual,cnt2)
 SET lexpandactualsize = size(tempdata->qual,5)
 IF (lexpandactualsize != 0)
  SET lexpandtotal = (ceil((cnvtreal(lexpandactualsize)/ cexpandsize)) * cexpandsize)
  SET lexpandstart = 1
  SET nstat = alterlist(tempdata->qual,lexpandtotal)
  FOR (lexpandindex = (lexpandactualsize+ 1) TO lexpandtotal)
   SET tempdata->qual[lexpandindex].dispense_hx_id = tempdata->qual[lexpandactualsize].dispense_hx_id
   SET tempdata->qual[lexpandindex].ref_index = tempdata->qual[lexpandactualsize].ref_index
  ENDFOR
  SELECT INTO "NL:"
   ce.charge_event_id
   FROM (dummyt d1  WITH seq = value((1+ ((lexpandtotal - 1)/ cexpandsize)))),
    charge_event ce,
    charge_event_act cea,
    charge c
   PLAN (d1
    WHERE initarray(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
    JOIN (ce
    WHERE expand(lexpandindex,lexpandstart,(lexpandstart+ (cexpandsize - 1)),ce.ext_m_event_id,
     tempdata->qual[lexpandindex].dispense_hx_id)
     AND ce.ext_m_event_cont_cd=cdispid)
    JOIN (cea
    WHERE (cea.charge_event_id=(ce.charge_event_id+ 0)))
    JOIN (c
    WHERE (c.charge_event_id=(cea.charge_event_id+ 0)))
   ORDER BY ce.ext_m_event_id, cea.charge_event_id, cea.cea_type_cd,
    c.charge_event_id, c.charge_type_cd
   HEAD ce.ext_m_event_id
    row + 0
   HEAD cea.charge_event_id
    row + 0
   HEAD cea.cea_type_cd
    row + 0
   HEAD c.charge_event_id
    row + 0
   HEAD c.charge_type_cd
    litemidx = locateval(llocindex,1,lexpandactualsize,ce.ext_m_event_id,tempdata->qual[llocindex].
     dispense_hx_id)
    WHILE (litemidx > 0)
      lrefitemidx = tempdata->qual[litemidx].ref_index
      IF (lrefitemidx > 0)
       IF ((((pha_rcvy->data[lrefitemidx].tnf_id > 0)
        AND (ce.ext_i_reference_id=pha_rcvy->data[lrefitemidx].manf_item_id)) OR (((ncdmoptionind=0
        AND (pha_rcvy->data[lrefitemidx].manf_item_id > 0)
        AND (ce.ext_i_reference_id=pha_rcvy->data[lrefitemidx].manf_item_id)) OR (ncdmoptionind=1
        AND (pha_rcvy->data[lrefitemidx].med_def_flex_id > 0)
        AND (ce.ext_i_reference_id=pha_rcvy->data[lrefitemidx].med_def_flex_id))) ))
        AND ((((cea.cea_type_cd+ 0)=creverse)
        AND (pha_rcvy->data[lrefitemidx].reverse_ind=1)) OR (((cea.cea_type_cd+ 0) != creverse)
        AND (pha_rcvy->data[lrefitemidx].reverse_ind=0)))
        AND ((((c.charge_type_cd+ 0)=ccredit)
        AND (pha_rcvy->data[lrefitemidx].reverse_ind=1)) OR ((pha_rcvy->data[lrefitemidx].reverse_ind
       =0))) )
        pha_rcvy->data[lrefitemidx].charge_event_id = ce.charge_event_id, pha_rcvy->data[lrefitemidx]
        .found_charge = 1
       ENDIF
      ENDIF
      litemidx = locateval(llocindex,(litemidx+ 1),lexpandactualsize,ce.ext_m_event_id,tempdata->
       qual[llocindex].dispense_hx_id)
    ENDWHILE
   FOOT  c.charge_type_cd
    dstat = 0
   FOOT  c.charge_event_id
    dstat = 0
   FOOT  cea.cea_type_cd
    dstat = 0
   FOOT  cea.charge_event_id
    dstat = 0
   FOOT  ce.ext_m_event_id
    dstat = 0
   WITH nocounter
  ;end select
  SET nstat = initrec(tempdata)
 ENDIF
 SET cnt2 = 0
 FOR (cnt = 1 TO lrecsize)
   IF ((pha_rcvy->data[cnt].parent_ind=0)
    AND (pha_rcvy->data[cnt].rx_admin_dispense_hx_id > 0)
    AND (pha_rcvy->data[cnt].charge_on_sched_admin_ind=1))
    SET cnt2 += 1
    IF (mod(cnt2,cblocksize)=1)
     SET nstat = alterlist(tempdata->qual,((cnt2+ cblocksize) - 1))
    ENDIF
    SET tempdata->qual[cnt2].rx_admin_dispense_hx_id = pha_rcvy->data[cnt].rx_admin_dispense_hx_id
    SET tempdata->qual[cnt2].ref_index = cnt
   ENDIF
 ENDFOR
 SET nstat = alterlist(tempdata->qual,cnt2)
 SET lexpandactualsize = size(tempdata->qual,5)
 IF (lexpandactualsize != 0)
  SET lexpandtotal = (ceil((cnvtreal(lexpandactualsize)/ cexpandsize)) * cexpandsize)
  SET lexpandstart = 1
  SET nstat = alterlist(tempdata->qual,lexpandtotal)
  FOR (lexpandindex = (lexpandactualsize+ 1) TO lexpandtotal)
   SET tempdata->qual[lexpandindex].rx_admin_dispense_hx_id = tempdata->qual[lexpandactualsize].
   rx_admin_dispense_hx_id
   SET tempdata->qual[lexpandindex].ref_index = tempdata->qual[lexpandactualsize].ref_index
  ENDFOR
  SELECT INTO "NL:"
   ce.charge_event_id
   FROM (dummyt d1  WITH seq = value((1+ ((lexpandtotal - 1)/ cexpandsize)))),
    charge_event ce,
    charge_event_act cea,
    charge c
   PLAN (d1
    WHERE initarray(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
    JOIN (ce
    WHERE expand(lexpandindex,lexpandstart,(lexpandstart+ (cexpandsize - 1)),ce.ext_m_event_id,
     tempdata->qual[lexpandindex].rx_admin_dispense_hx_id)
     AND ce.ext_m_event_cont_cd=cadmindispid)
    JOIN (cea
    WHERE (cea.charge_event_id=(ce.charge_event_id+ 0)))
    JOIN (c
    WHERE c.charge_event_id=cea.charge_event_id)
   ORDER BY ce.ext_m_event_id, cea.charge_event_id, cea.cea_type_cd,
    c.charge_event_id, c.charge_type_cd
   HEAD ce.ext_m_event_id
    dstat = 0
   HEAD cea.charge_event_id
    dstat = 0
   HEAD cea.cea_type_cd
    dstat = 0
   HEAD c.charge_event_id
    dstat = 0
   HEAD c.charge_type_cd
    litemidx = locateval(llocindex,1,lexpandactualsize,ce.ext_m_event_id,tempdata->qual[llocindex].
     rx_admin_dispense_hx_id)
    WHILE (litemidx > 0)
      lrefitemidx = tempdata->qual[litemidx].ref_index
      IF (lrefitemidx > 0)
       IF ((((pha_rcvy->data[lrefitemidx].tnf_id > 0)
        AND (ce.ext_i_reference_id=pha_rcvy->data[lrefitemidx].manf_item_id)) OR (((ncdmoptionind=0
        AND (pha_rcvy->data[lrefitemidx].manf_item_id > 0)
        AND (ce.ext_i_reference_id=pha_rcvy->data[lrefitemidx].manf_item_id)) OR (ncdmoptionind=1
        AND (pha_rcvy->data[lrefitemidx].med_def_flex_id > 0)
        AND (ce.ext_i_reference_id=pha_rcvy->data[lrefitemidx].med_def_flex_id))) ))
        AND ((((cea.cea_type_cd+ 0)=creverse)
        AND (pha_rcvy->data[lrefitemidx].reverse_ind=1)) OR (((cea.cea_type_cd+ 0) != creverse)
        AND (pha_rcvy->data[lrefitemidx].reverse_ind=0)))
        AND ((((c.charge_type_cd+ 0)=ccredit)
        AND (pha_rcvy->data[lrefitemidx].reverse_ind=1)) OR ((pha_rcvy->data[lrefitemidx].reverse_ind
       =0))) )
        pha_rcvy->data[lrefitemidx].charge_event_id = ce.charge_event_id, pha_rcvy->data[lrefitemidx]
        .found_charge = 1
       ENDIF
      ENDIF
      litemidx = locateval(llocindex,(litemidx+ 1),lexpandactualsize,ce.ext_m_event_id,tempdata->
       qual[llocindex].rx_admin_dispense_hx_id)
    ENDWHILE
   FOOT  c.charge_type_cd
    dstat = 0
   FOOT  c.charge_event_id
    dstat = 0
   FOOT  cea.cea_type_cd
    dstat = 0
   FOOT  cea.charge_event_id
    dstat = 0
   FOOT  ce.ext_m_event_id
    dstat = 0
   WITH nocounter
  ;end select
  SET nstat = initrec(tempdata)
 ENDIF
 SET lrecsize = size(pha_rcvy->data,5)
 SET cnt2 = 0
 FOR (cnt = 1 TO lrecsize)
   IF ((pha_rcvy->data[cnt].parent_ind=1)
    AND (pha_rcvy->data[cnt].dispense_hx_id > 0)
    AND (pha_rcvy->data[cnt].catalog_cd > 0)
    AND (pha_rcvy->data[cnt].charge_on_sched_admin_ind=0))
    SET cnt2 += 1
    IF (mod(cnt2,cblocksize)=1)
     SET nstat = alterlist(tempdata->qual,((cnt2+ cblocksize) - 1))
    ENDIF
    SET tempdata->qual[cnt2].dispense_hx_id = pha_rcvy->data[cnt].dispense_hx_id
    SET tempdata->qual[cnt2].catalog_cd = pha_rcvy->data[cnt].catalog_cd
    SET tempdata->qual[cnt2].ref_index = cnt
   ENDIF
 ENDFOR
 SET nstat = alterlist(tempdata->qual,cnt2)
 SET lexpandactualsize = size(tempdata->qual,5)
 IF (lexpandactualsize != 0)
  SET lexpandtotal = (ceil((cnvtreal(lexpandactualsize)/ cexpandsize)) * cexpandsize)
  SET lexpandstart = 1
  SET nstat = alterlist(tempdata->qual,lexpandtotal)
  FOR (lexpandindex = (lexpandactualsize+ 1) TO lexpandtotal)
    SET tempdata->qual[lexpandindex].dispense_hx_id = tempdata->qual[lexpandactualsize].
    dispense_hx_id
    SET tempdata->qual[lexpandindex].catalog_cd = tempdata->qual[lexpandactualsize].catalog_cd
    SET tempdata->qual[lexpandindex].ref_index = tempdata->qual[lexpandactualsize].ref_index
  ENDFOR
  SELECT INTO "NL:"
   ce.charge_event_id
   FROM (dummyt d1  WITH seq = value((1+ ((lexpandtotal - 1)/ cexpandsize)))),
    charge_event ce,
    charge_event_act cea,
    charge c
   PLAN (d1
    WHERE initarray(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
    JOIN (ce
    WHERE expand(lexpandindex,lexpandstart,(lexpandstart+ (cexpandsize - 1)),ce.ext_m_event_id,
     tempdata->qual[lexpandindex].dispense_hx_id,
     ce.ext_i_reference_id,tempdata->qual[lexpandindex].catalog_cd)
     AND ce.ext_m_event_cont_cd=cdispid
     AND ce.ext_p_event_id >= 0
     AND ce.ext_p_event_cont_cd >= 0
     AND ce.ext_i_event_id >= 0
     AND ce.ext_i_event_cont_cd >= 0)
    JOIN (cea
    WHERE (cea.charge_event_id=(ce.charge_event_id+ 0)))
    JOIN (c
    WHERE (c.charge_event_id=(cea.charge_event_id+ 0)))
   ORDER BY ce.ext_m_event_id, ce.ext_i_reference_id
   HEAD ce.ext_m_event_id
    row + 0
   HEAD ce.ext_i_reference_id
    litemidx = locateval(llocindex,1,lexpandactualsize,ce.ext_m_event_id,tempdata->qual[llocindex].
     dispense_hx_id,
     ce.ext_i_reference_id,tempdata->qual[llocindex].catalog_cd)
    WHILE (litemidx > 0)
      lrefitemidx = tempdata->qual[litemidx].ref_index
      IF (lrefitemidx > 0)
       pha_rcvy->data[lrefitemidx].charge_event_id = ce.charge_event_id, pha_rcvy->data[lrefitemidx].
       found_charge = 1
      ENDIF
      litemidx = locateval(llocindex,(litemidx+ 1),lexpandactualsize,ce.ext_m_event_id,tempdata->
       qual[llocindex].dispense_hx_id,
       ce.ext_i_reference_id,tempdata->qual[llocindex].catalog_cd)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstat = initrec(tempdata)
 ENDIF
 SET cnt2 = 0
 FOR (cnt = 1 TO lrecsize)
   IF ((pha_rcvy->data[cnt].parent_ind=1)
    AND (pha_rcvy->data[cnt].rx_admin_dispense_hx_id > 0)
    AND (pha_rcvy->data[cnt].catalog_cd > 0)
    AND (pha_rcvy->data[cnt].charge_on_sched_admin_ind=1))
    SET cnt2 += 1
    IF (mod(cnt2,cblocksize)=1)
     SET nstat = alterlist(tempdata->qual,((cnt2+ cblocksize) - 1))
    ENDIF
    SET tempdata->qual[cnt2].rx_admin_dispense_hx_id = pha_rcvy->data[cnt].rx_admin_dispense_hx_id
    SET tempdata->qual[cnt2].catalog_cd = pha_rcvy->data[cnt].catalog_cd
    SET tempdata->qual[cnt2].ref_index = cnt
   ENDIF
 ENDFOR
 SET nstat = alterlist(tempdata->qual,cnt2)
 SET lexpandactualsize = size(tempdata->qual,5)
 IF (lexpandactualsize != 0)
  SET lexpandtotal = (ceil((cnvtreal(lexpandactualsize)/ cexpandsize)) * cexpandsize)
  SET lexpandstart = 1
  SET nstat = alterlist(tempdata->qual,lexpandtotal)
  FOR (lexpandindex = (lexpandactualsize+ 1) TO lexpandtotal)
    SET tempdata->qual[lexpandindex].dispense_hx_id = tempdata->qual[lexpandactualsize].
    rx_admin_dispense_hx_id
    SET tempdata->qual[lexpandindex].catalog_cd = tempdata->qual[lexpandactualsize].catalog_cd
    SET tempdata->qual[lexpandindex].ref_index = tempdata->qual[lexpandactualsize].ref_index
  ENDFOR
  SELECT INTO "NL:"
   ce.charge_event_id
   FROM (dummyt d1  WITH seq = value((1+ ((lexpandtotal - 1)/ cexpandsize)))),
    charge_event ce,
    charge_event_act cea,
    charge c
   PLAN (d1
    WHERE initarray(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
    JOIN (ce
    WHERE expand(lexpandindex,lexpandstart,(lexpandstart+ (cexpandsize - 1)),ce.ext_m_event_id,
     tempdata->qual[lexpandindex].rx_admin_dispense_hx_id,
     ce.ext_i_reference_id,tempdata->qual[lexpandindex].catalog_cd)
     AND ce.ext_m_event_cont_cd=cadmindispid
     AND ce.ext_p_event_id >= 0
     AND ce.ext_p_event_cont_cd >= 0
     AND ce.ext_i_event_id >= 0
     AND ce.ext_i_event_cont_cd >= 0)
    JOIN (cea
    WHERE (cea.charge_event_id=(ce.charge_event_id+ 0)))
    JOIN (c
    WHERE (c.charge_event_id=(cea.charge_event_id+ 0)))
   ORDER BY ce.ext_m_event_id, ce.ext_i_reference_id
   HEAD ce.ext_m_event_id
    dstat = 0
   HEAD ce.ext_i_reference_id
    litemidx = locateval(llocindex,1,lexpandactualsize,ce.ext_m_event_id,tempdata->qual[llocindex].
     rx_admin_dispense_hx_id,
     ce.ext_i_reference_id,tempdata->qual[llocindex].catalog_cd)
    WHILE (litemidx > 0)
      lrefitemidx = tempdata->qual[litemidx].ref_index
      IF (lrefitemidx > 0)
       pha_rcvy->data[lrefitemidx].charge_event_id = ce.charge_event_id, pha_rcvy->data[lrefitemidx].
       found_charge = 1
      ENDIF
      litemidx = locateval(llocindex,(litemidx+ 1),lexpandactualsize,ce.ext_m_event_id,tempdata->
       qual[llocindex].rx_admin_dispense_hx_id,
       ce.ext_i_reference_id,tempdata->qual[llocindex].catalog_cd)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstat = initrec(tempdata)
 ENDIF
 SELECT INTO "nl:"
  FROM charge_event_act cea
  PLAN (cea
   WHERE expand(lrcvyidx,1,pha_rcvy->data_cnt,cea.charge_event_id,pha_rcvy->data[lrcvyidx].
    charge_event_id,
    1,pha_rcvy->data[lrcvyidx].found_charge,0,pha_rcvy->data[lrcvyidx].parent_ind,0,
    pha_rcvy->data[lrcvyidx].table_reverse_ind)
    AND cea.charge_type_cd IN (cpharmdr, cpharmcr))
  ORDER BY cea.charge_event_id
  HEAD cea.charge_event_id
   cnt = 0, cnt2 = 0
  DETAIL
   IF (cea.cea_type_cd=creverse)
    cnt += 1
   ELSE
    cnt2 += 1
   ENDIF
  FOOT  cea.charge_event_id
   IF (cnt=cnt2)
    lrcvyidx = locateval(lrcvyidx,1,pha_rcvy->data_cnt,cea.charge_event_id,pha_rcvy->data[lrcvyidx].
     charge_event_id,
     1,pha_rcvy->data[lrcvyidx].found_charge,0,pha_rcvy->data[lrcvyidx].parent_ind,0,
     pha_rcvy->data[lrcvyidx].table_reverse_ind)
    IF (lrcvyidx > 0)
     pha_rcvy->data[lrcvyidx].already_reversed_ind = 1
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 CALL setrecoverind(null)
 IF (nnewmodel=1)
  RECORD info_request(
    1 itemlist[*]
      2 item_id = f8
    1 pharm_type_cd = f8
    1 facility_cd = f8
    1 pharm_loc_cd = f8
    1 pat_loc_cd = f8
    1 encounter_type_cd = f8
    1 package_type_id = f8
    1 med_all_ind = i2
    1 med_pha_flex_ind = i2
    1 med_identifier_ind = i2
    1 med_dispense_ind = i2
    1 med_oe_default_ind = i2
    1 med_def_ind = i2
    1 ther_class_ind = i2
    1 med_product_ind = i2
    1 med_product_prim_ind = i2
    1 med_product_ident_ind = i2
    1 med_cost_ind = i2
    1 misc_object_ind = i2
    1 med_cost_type_cd = f8
    1 med_child_ind = i2
    1 parent_item_id = f8
    1 options_pref = i4
    1 birthdate = dq8
    1 financial_class_cd = f8
    1 funding_source_cd = f8
  )
  RECORD info_reply(
    1 itemlist[*]
      2 parent_item_id = f8
      2 sequence = i4
      2 active_ind = i2
      2 med_def_flex_sys_id = f8
      2 med_def_flex_syspkg_id = f8
      2 item_id = f8
      2 package_type_id = f8
      2 form_cd = f8
      2 cki = vc
      2 med_type_flag = i2
      2 mdx_gfc_nomen_id = f8
      2 base_issue_factor = f8
      2 given_strength = vc
      2 strength = f8
      2 strength_unit_cd = f8
      2 volume = f8
      2 volume_unit_cd = f8
      2 compound_text_id = f8
      2 mixing_instructions = vc
      2 pkg_qty = f8
      2 pkg_qty_cd = f8
      2 catalog_cd = f8
      2 catalog_cki = vc
      2 synonym_id = f8
      2 oeformatid = f8
      2 orderabletypeflag = i2
      2 catalogdescription = vc
      2 catalogtypecd = f8
      2 mnemonicstr = vc
      2 primarymnemonic = vc
      2 label_description = vc
      2 brand_name = vc
      2 mnemonic = vc
      2 generic_name = vc
      2 profile_desc = vc
      2 cdm = vc
      2 rx_mask = i4
      2 med_oe_defaults_id = f8
      2 med_oe_strength = f8
      2 med_oe_strength_unit_cd = f8
      2 med_oe_volume = f8
      2 med_oe_volume_unit_cd = f8
      2 freetext_dose = vc
      2 frequency_cd = f8
      2 route_cd = f8
      2 prn_ind = i2
      2 infuse_over = f8
      2 infuse_over_cd = f8
      2 duration = f8
      2 duration_unit_cd = f8
      2 stop_type_cd = f8
      2 default_par_doses = i4
      2 max_par_supply = i4
      2 dispense_category_cd = f8
      2 alternate_dispense_category_cd = f8
      2 comment1_id = f8
      2 comment1_type = i2
      2 comment2_id = f8
      2 comment2_type = i2
      2 comment1_text = vc
      2 comment2_text = vc
      2 price_sched_id = f8
      2 nbr_labels = i4
      2 ord_as_synonym_id = f8
      2 rx_qty = f8
      2 daw_cd = f8
      2 sig_codes = vc
      2 med_dispense_id = f8
      2 med_disp_package_type_id = f8
      2 med_disp_strength = f8
      2 med_disp_strength_unit_cd = f8
      2 med_disp_volume = f8
      2 med_disp_volume_unit_cd = f8
      2 legal_status_cd = f8
      2 formulary_status_cd = f8
      2 oe_format_flag = i2
      2 med_filter_ind = i2
      2 continuous_filter_ind = i2
      2 intermittent_filter_ind = i2
      2 divisible_ind = i2
      2 used_as_base_ind = i2
      2 always_dispense_from_flag = i2
      2 floorstock_ind = i2
      2 dispense_qty = f8
      2 dispense_factor = f8
      2 label_ratio = f8
      2 prn_reason_cd = f8
      2 infinite_div_ind = f8
      2 reusable_ind = i2
      2 base_pkg_type_id = f8
      2 base_pkg_qty = f8
      2 base_pkg_uom_cd = f8
      2 medidqual[*]
        3 identifier_id = f8
        3 identifier_type_cd = f8
        3 value = vc
        3 value_key = vc
        3 sequence = i4
      2 medproductqual[*]
        3 active_ind = i2
        3 med_product_id = f8
        3 manf_item_id = f8
        3 inner_pkg_type_id = f8
        3 inner_pkg_qty = f8
        3 inner_pkg_uom_cd = f8
        3 bio_equiv_ind = i2
        3 brand_ind = i2
        3 unit_dose_ind = i2
        3 manufacturer_cd = f8
        3 manufacturer_name = vc
        3 label_description = vc
        3 ndc = vc
        3 brand = vc
        3 sequence = i2
        3 awp = f8
        3 awp_factor = f8
        3 formulary_status_cd = f8
        3 item_master_id = f8
        3 base_pkg_type_id = f8
        3 base_pkg_qty = f8
        3 base_pkg_uom_cd = f8
        3 medcostqual[*]
          4 cost_type_cd = f8
          4 cost = f8
        3 innerndcqual[*]
          4 inner_ndc = vc
      2 medingredqual[*]
        3 med_ingred_set_id = f8
        3 sequence = i2
        3 child_item_id = f8
        3 child_med_prod_id = f8
        3 child_pkg_type_id = f8
        3 base_ind = i2
        3 cmpd_qty = f8
        3 default_action_cd = f8
        3 cost1 = f8
        3 cost2 = f8
        3 awp = f8
        3 inc_in_total_ind = i2
        3 normalized_rate_ind = i2
      2 theraclassqual[*]
        3 alt_sel_category_id = f8
        3 ahfs_code = vc
      2 miscobjectqual[*]
        3 parent_entity_id = f8
        3 cdf_meaning = vc
      2 firstdoselocqual[*]
        3 location_cd = f8
      2 pkg_qty_per_pkg = f8
      2 pkg_disp_more_ind = i2
      2 dispcat_flex_ind = i4
      2 pricesch_flex_ind = i4
      2 workflow_cd = f8
      2 cmpd_qty = f8
      2 warning_labels[*]
        3 label_nbr = i4
        3 label_seq = i2
        3 label_text = vc
        3 label_default_print = i2
        3 label_exception_ind = i2
      2 premix_ind = i2
      2 ord_as_mnemonic = vc
      2 tpn_balance_method_cd = f8
      2 tpn_chloride_pct = f8
      2 tpn_default_ingred_item_id = f8
      2 tpn_fill_method_cd = f8
      2 tpn_include_ions_flag = i2
      2 tpn_overfill_amt = f8
      2 tpn_overfill_unit_cd = f8
      2 tpn_preferred_cation_cd = f8
      2 tpn_product_type_flag = i2
      2 lot_tracking_ind = i2
      2 rate = f8
      2 rate_cd = f8
      2 normalized_rate = f8
      2 normalized_rate_cd = f8
      2 freetext_rate = vc
      2 normalized_rate_ind = i2
      2 ord_detail_opts[*]
        3 facility_cd = f8
        3 age_range_id = f8
        3 oe_field_meaning_id = f8
        3 restrict_ind = i4
        3 opt_list[*]
          4 opt_txt = vc
          4 opt_cd = f8
          4 opt_nbr = f8
          4 default_ind = i4
          4 display_seq = i4
      2 poc_charge_flag = i2
      2 inventory_factor = f8
      2 prod_assign_flag = i2
      2 skip_dispense_flag = i2
      2 inv_master_id = f8
      2 grace_period_days = i4
      2 waste_charge_ind = i2
      2 cms_waste_billing_unit_amt = f8
      2 cms_waste_billing_unit_uom_cd = f8
      2 med_dispense_category_cd = f8
      2 cont_dispense_category_cd = f8
      2 int_dispense_category_cd = f8
      2 med_dispcat_flex_ind = i2
      2 int_dispcat_flex_ind = i2
      2 cont_dispcat_flex_ind = i2
      2 copay_tier_cd = f8
      2 max_dose_qty = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET info_request->pharm_type_cd = cinpatient
  SET info_request->med_identifier_ind = 1
  SET info_request->med_oe_default_ind = 1
  SET cnt = 0
  SET cnt2 = 0
  FOR (lcnt = 1 TO pha_rcvy->data_cnt)
    IF ((pha_rcvy->data[lcnt].item_id > 0)
     AND (pha_rcvy->data[lcnt].parent_ind=0)
     AND (pha_rcvy->data[lcnt].recover_ind=1))
     SET litemidx = locateval(litem,1,cnt,pha_rcvy->data[lcnt].item_id,info_request->itemlist[litem].
      item_id)
     IF (litemidx=0)
      SET cnt += 1
      IF (mod(cnt,10)=1)
       SET dstat = alterlist(info_request->itemlist,(cnt+ 9))
      ENDIF
      SET info_request->itemlist[cnt].item_id = pha_rcvy->data[lcnt].item_id
     ENDIF
     SET cnt2 += 1
     IF (mod(cnt2,10)=1)
      SET dstat = alterlist(idx_data->data,(cnt2+ 9))
     ENDIF
     SET idx_data->data[cnt2].item_id = pha_rcvy->data[lcnt].item_id
     SET idx_data->data[cnt2].pha_rcvy_idx = lcnt
    ENDIF
  ENDFOR
  SET dstat = alterlist(info_request->itemlist,cnt)
  SET dstat = alterlist(idx_data->data,cnt2)
  IF (cnt > 0)
   EXECUTE rxa_get_item_info  WITH replace("REQUEST","INFO_REQUEST"), replace("REPLY","INFO_REPLY")
   FOR (litem = 1 TO cnt2)
     SET litemidx = locateval(lcnt,1,cnt,idx_data->data[litem].item_id,info_reply->itemlist[lcnt].
      item_id)
     SET lrcvyidx = idx_data->data[litem].pha_rcvy_idx
     IF (litemidx > 0)
      FOR (lcnt = 1 TO size(info_reply->itemlist[litemidx].medidqual,5))
        IF ((info_reply->itemlist[litemidx].medidqual[lcnt].sequence=1))
         CASE (info_reply->itemlist[litemidx].medidqual[lcnt].identifier_type_cd)
          OF ccdm:
           SET pha_rcvy->data[lrcvyidx].cdm = trim(info_reply->itemlist[litemidx].medidqual[lcnt].
            value)
          OF cdesc:
           IF ((pha_rcvy->data[lrcvyidx].tnf_id=0))
            SET pha_rcvy->data[lrcvyidx].label_desc = trim(info_reply->itemlist[litemidx].medidqual[
             lcnt].value)
           ENDIF
         ENDCASE
        ENDIF
      ENDFOR
      IF ((pha_rcvy->data[lrcvyidx].price_sched_id=0))
       SET pha_rcvy->data[lrcvyidx].price_sched_id = info_reply->itemlist[litemidx].price_sched_id
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  SET lrecsize = size(pha_rcvy->data,5)
  SET cnt2 = 0
  FOR (cnt = 1 TO lrecsize)
    IF ((pha_rcvy->data[cnt].parent_ind=0)
     AND (pha_rcvy->data[cnt].item_id > 0)
     AND (pha_rcvy->data[cnt].recover_ind=1))
     SET cnt2 += 1
     IF (mod(cnt2,cblocksize)=1)
      SET nstat = alterlist(tempdata->qual,((cnt2+ cblocksize) - 1))
     ENDIF
     SET tempdata->qual[cnt2].item_id = pha_rcvy->data[cnt].item_id
     SET tempdata->qual[cnt2].ref_index = cnt
    ENDIF
  ENDFOR
  SET nstat = alterlist(tempdata->qual,cnt2)
  SET lexpandactualsize = size(tempdata->qual,5)
  IF (lexpandactualsize != 0)
   SET lexpandtotal = (ceil((cnvtreal(lexpandactualsize)/ cexpandsize)) * cexpandsize)
   SET lexpandstart = 1
   SET nstat = alterlist(tempdata->qual,lexpandtotal)
   FOR (lexpandindex = (lexpandactualsize+ 1) TO lexpandtotal)
    SET tempdata->qual[lexpandindex].item_id = tempdata->qual[lexpandactualsize].item_id
    SET tempdata->qual[lexpandindex].ref_index = tempdata->qual[lexpandactualsize].ref_index
   ENDFOR
   SELECT INTO "NL:"
    md.price_sched_id, oii.value
    FROM (dummyt d1  WITH seq = value((1+ ((lexpandtotal - 1)/ cexpandsize)))),
     medication_definition md,
     object_identifier_index oii
    PLAN (d1
     WHERE initarray(lexpandstart,evaluate(d1.seq,1,1,(lexpandstart+ cexpandsize))))
     JOIN (md
     WHERE expand(lexpandindex,lexpandstart,(lexpandstart+ (cexpandsize - 1)),md.item_id,tempdata->
      qual[lexpandindex].item_id))
     JOIN (oii
     WHERE oii.object_id=md.item_id
      AND oii.identifier_type_cd IN (ccdm, cdesc)
      AND ((oii.object_type_cd+ 0)=cmeddef)
      AND ((oii.generic_object+ 0)=0))
    ORDER BY md.item_id, oii.identifier_type_cd, oii.primary_ind DESC
    HEAD md.item_id
     row + 0
    HEAD oii.identifier_type_cd
     litemidx = locateval(llocindex,1,lexpandactualsize,md.item_id,tempdata->qual[llocindex].item_id)
     WHILE (litemidx > 0)
       lrefitemidx = tempdata->qual[litemidx].ref_index
       IF (lrefitemidx > 0)
        IF ((pha_rcvy->data[lrefitemidx].price_sched_id=0))
         pha_rcvy->data[lrefitemidx].price_sched_id = md.price_sched_id
        ENDIF
        IF (oii.identifier_type_cd=ccdm)
         pha_rcvy->data[lrefitemidx].cdm = trim(substring(1,30,oii.value))
        ELSEIF (oii.identifier_type_cd=cdesc)
         pha_rcvy->data[lrefitemidx].label_desc = trim(substring(1,30,oii.value))
        ENDIF
       ENDIF
       litemidx = locateval(llocindex,(litemidx+ 1),lexpandactualsize,md.item_id,tempdata->qual[
        llocindex].item_id)
     ENDWHILE
    WITH nocounter
   ;end select
   SET nstat = initrec(tempdata)
  ENDIF
 ENDIF
 FOR (x = 1 TO size(pref_data->data,5))
   EXECUTE rx_get_config_prefs_request
   EXECUTE rx_get_config_prefs_reply
   SET rx_gcp_request->facility_cd = pref_data->data[x].facility_cd
   SET stat = alterlist(rx_gcp_request->groups,1)
   SET rx_gcp_request->groups[1].groupname = "charge"
   SET stat = alterlist(rx_gcp_request->groups[1].entries,1)
   SET rx_gcp_request->groups[1].entries[1].entryname = "futureorderservicedttm"
   EXECUTE rx_get_config_prefs  WITH replace("REQUEST","RX_GCP_REQUEST"), replace("REPLY",
    "RX_GCP_REPLY")
   FREE RECORD rx_gcp_request
   IF ((rx_gcp_reply->status_data.status="S"))
    IF (size(rx_gcp_reply->qual,5)=1)
     IF (size(rx_gcp_reply->qual[1].entries[1].values[1].value,3)=1)
      SET pref_data->data[x].pref_nbr = cnvtint(trim(rx_gcp_reply->qual[1].entries[1].values[1].value,
        3))
     ENDIF
    ENDIF
   ENDIF
   FREE RECORD rx_gcp_reply
 ENDFOR
 SET cnt = 0
 FOR (x = 1 TO pha_rcvy->data_cnt)
  SET lfacsize = size(pref_data->data,5)
  IF ((pha_rcvy->data[x].parent_ind=1)
   AND (pha_rcvy->data[x].recover_ind=1))
   SET cnt += 1
   SET reply->action_type = "PHA"
   SET dstat = alterlist(reply->charge_event,cnt)
   IF ((pha_rcvy->data[x].charge_on_sched_admin_ind=1))
    SET reply->charge_event[cnt].ext_master_event_id = pha_rcvy->data[x].rx_admin_dispense_hx_id
    SET reply->charge_event[cnt].ext_master_event_cont_cd = cadmindispid
    SET reply->charge_event[cnt].ext_item_event_id = pha_rcvy->data[x].rx_admin_dispense_hx_id
    SET reply->charge_event[cnt].ext_item_event_cont_cd = cadmindispid
   ELSE
    SET reply->charge_event[cnt].ext_master_event_id = pha_rcvy->data[x].dispense_hx_id
    SET reply->charge_event[cnt].ext_master_event_cont_cd = cdispid
    SET reply->charge_event[cnt].ext_item_event_id = pha_rcvy->data[x].dispense_hx_id
    SET reply->charge_event[cnt].ext_item_event_cont_cd = cdispid
   ENDIF
   SET reply->charge_event[cnt].ext_master_reference_id = pha_rcvy->data[x].catalog_cd
   SET reply->charge_event[cnt].ext_master_reference_cont_cd = cordcat
   SET reply->charge_event[cnt].ext_parent_event_id = 0
   SET reply->charge_event[cnt].ext_parent_event_cont_cd = 0
   SET reply->charge_event[cnt].ext_parent_reference_id = 0
   SET reply->charge_event[cnt].ext_parent_reference_cont_cd = 0
   SET reply->charge_event[cnt].ext_item_reference_id = pha_rcvy->data[x].catalog_cd
   SET reply->charge_event[cnt].ext_item_reference_cont_cd = cordcat
   SET reply->charge_event[cnt].order_id = pha_rcvy->data[x].order_id
   SET reply->charge_event[cnt].person_id = pha_rcvy->data[x].person_id
   SET reply->charge_event[cnt].person_name = pha_rcvy->data[x].person_name
   SET reply->charge_event[cnt].encntr_id = pha_rcvy->data[x].encntr_id
   SET dstat = alterlist(reply->charge_event[cnt].charge_event_act,1)
   SET reply->charge_event[cnt].charge_event_act_qual = 1
   SET reply->charge_event[cnt].charge_event_act[1].charge_event_id = 0
   SET reply->charge_event[cnt].charge_event_act[1].cea_type_cd = cdispensed
   IF ((pha_rcvy->data[x].charge_on_sched_admin_ind=1))
    SET reply->charge_event[cnt].charge_event_act[1].service_dt_tm = pha_rcvy->data[x].admin_dt_tm
   ELSE
    SET reply->charge_event[cnt].charge_event_act[1].service_dt_tm = pha_rcvy->data[x].disp_dt_tm
    IF ((pha_rcvy->data[x].future_charge_ind=1))
     SET lfacidx = locateval(lfaccnt,1,lfacsize,pha_rcvy->data[x].facility_cd,pref_data->data[lfaccnt
      ].facility_cd)
     IF ((pref_data->data[lfacidx].pref_nbr=1))
      SET reply->charge_event[cnt].charge_event_act[1].service_dt_tm = pha_rcvy->data[x].start_dt_tm
     ENDIF
    ENDIF
   ENDIF
   SET reply->charge_event[cnt].charge_event_act[1].charge_type_cd = cpharmnc
   SET reply->charge_event[cnt].charge_event_act[1].quantity = pha_rcvy->data[x].doses
   SET reply->charge_event[cnt].charge_event_act[1].pharm_quantity = pha_rcvy->data[x].doses
   SET reply->charge_event[cnt].charge_event_act[1].details = pha_rcvy->data[x].details
   SET reply->charge_event[cnt].charge_event_act[1].price_sched_id = pha_rcvy->data[x].price_sched_id
   SET reply->charge_event[cnt].charge_event_act[1].ext_price = pha_rcvy->data[x].price
   SET reply->charge_event[cnt].charge_event_act[1].item_desc = pha_rcvy->data[x].details
   SET reply->charge_event[cnt].charge_event_act[1].misc_ind = 0
   SET reply->charge_event[cnt].charge_event_act[1].item_price = (pha_rcvy->data[x].price/ pha_rcvy->
   data[x].doses)
  ELSEIF ((pha_rcvy->data[x].parent_ind=0)
   AND (pha_rcvy->data[x].recover_ind=1))
   SET cnt += 1
   SET reply->action_type = "PHA"
   SET dstat = alterlist(reply->charge_event,cnt)
   IF ((pha_rcvy->data[x].charge_on_sched_admin_ind=1))
    SET reply->charge_event[cnt].ext_master_event_id = pha_rcvy->data[x].rx_admin_dispense_hx_id
    SET reply->charge_event[cnt].ext_master_event_cont_cd = cadmindispid
    SET reply->charge_event[cnt].ext_parent_event_id = pha_rcvy->data[x].rx_admin_dispense_hx_id
    SET reply->charge_event[cnt].ext_parent_event_cont_cd = cadmindispid
   ELSE
    SET reply->charge_event[cnt].ext_master_event_id = pha_rcvy->data[x].dispense_hx_id
    SET reply->charge_event[cnt].ext_master_event_cont_cd = cdispid
    SET reply->charge_event[cnt].ext_parent_event_id = pha_rcvy->data[x].dispense_hx_id
    SET reply->charge_event[cnt].ext_parent_event_cont_cd = cdispid
   ENDIF
   SET reply->charge_event[cnt].ext_master_reference_id = pha_rcvy->data[x].catalog_cd
   SET reply->charge_event[cnt].ext_master_reference_cont_cd = cordcat
   SET reply->charge_event[cnt].ext_parent_reference_id = pha_rcvy->data[x].catalog_cd
   SET reply->charge_event[cnt].ext_parent_reference_cont_cd = cordcat
   IF ((pha_rcvy->data[x].tnf_id > 0))
    SET reply->charge_event[cnt].ext_item_event_id = pha_rcvy->data[x].tnf_id
    SET reply->charge_event[cnt].ext_item_event_cont_cd = ctnf_med
    SET reply->charge_event[cnt].ext_item_reference_id = pha_rcvy->data[x].manf_item_id
    SET reply->charge_event[cnt].ext_item_reference_cont_cd = ctnf_med
   ELSE
    SET reply->charge_event[cnt].ext_item_event_id = pha_rcvy->data[x].item_id
    SET reply->charge_event[cnt].ext_item_event_cont_cd = ccontrib_med_def
    IF (ncdmoptionind=0)
     SET reply->charge_event[cnt].ext_item_reference_id = pha_rcvy->data[x].manf_item_id
     SET reply->charge_event[cnt].ext_item_reference_cont_cd = cmanfitem
    ELSEIF (ncdmoptionind=1)
     SET reply->charge_event[cnt].ext_item_reference_id = pha_rcvy->data[x].med_def_flex_id
     SET reply->charge_event[cnt].ext_item_reference_cont_cd = cmeddefflex
    ENDIF
   ENDIF
   SET reply->charge_event[cnt].order_id = pha_rcvy->data[x].order_id
   SET reply->charge_event[cnt].person_id = pha_rcvy->data[x].person_id
   SET reply->charge_event[cnt].person_name = pha_rcvy->data[x].person_name
   SET reply->charge_event[cnt].encntr_id = pha_rcvy->data[x].encntr_id
   SET reply->charge_event[cnt].charge_event_act_qual = 1
   SET dstat = alterlist(reply->charge_event[cnt].charge_event_act,1)
   SET reply->charge_event[cnt].charge_event_act[1].charge_event_id = 0
   IF ((pha_rcvy->data[x].reverse_ind=1))
    SET reply->charge_event[cnt].charge_event_act[1].cea_type_cd = creverse
    IF ((pha_rcvy->data[x].credit_ind=0))
     SET reply->charge_event[cnt].charge_event_act[1].charge_type_cd = cpharmcr
    ELSE
     SET reply->charge_event[cnt].charge_event_act[1].charge_type_cd = cpharmdr
    ENDIF
   ELSE
    SET reply->charge_event[cnt].charge_event_act[1].cea_type_cd = cdispensed
    IF ((pha_rcvy->data[x].credit_ind=0))
     SET reply->charge_event[cnt].charge_event_act[1].charge_type_cd = cpharmdr
    ELSE
     SET reply->charge_event[cnt].charge_event_act[1].charge_type_cd = cpharmcr
    ENDIF
   ENDIF
   IF ((pha_rcvy->data[x].charge_on_sched_admin_ind=1))
    SET reply->charge_event[cnt].charge_event_act[1].service_dt_tm = pha_rcvy->data[x].admin_dt_tm
   ELSE
    SET reply->charge_event[cnt].charge_event_act[1].service_dt_tm = pha_rcvy->data[x].disp_dt_tm
    IF ((pha_rcvy->data[x].future_charge_ind=1))
     SET lfacidx = locateval(lfaccnt,1,lfacsize,pha_rcvy->data[x].facility_cd,pref_data->data[lfaccnt
      ].facility_cd)
     IF ((pref_data->data[lfacidx].pref_nbr=1))
      SET reply->charge_event[cnt].charge_event_act[1].service_dt_tm = pha_rcvy->data[x].start_dt_tm
     ENDIF
    ENDIF
   ENDIF
   SET reply->charge_event[cnt].charge_event_act[1].quantity = pha_rcvy->data[x].qty
   SET reply->charge_event[cnt].charge_event_act[1].pharm_quantity = pha_rcvy->data[x].qty
   SET reply->charge_event[cnt].charge_event_act[1].details = pha_rcvy->data[x].label_desc
   SET reply->charge_event[cnt].charge_event_act[1].price_sched_id = pha_rcvy->data[x].price_sched_id
   SET reply->charge_event[cnt].charge_event_act[1].ext_price = pha_rcvy->data[x].price
   SET reply->charge_event[cnt].charge_event_act[1].item_desc = pha_rcvy->data[x].label_desc
   IF ((pha_rcvy->data[x].tnf_id > 0))
    SET reply->charge_event[cnt].charge_event_act[1].misc_ind = 1
   ELSE
    SET reply->charge_event[cnt].charge_event_act[1].misc_ind = 0
   ENDIF
   SET reply->charge_event[cnt].charge_event_act[1].item_price = (pha_rcvy->data[x].price/ pha_rcvy->
   data[x].qty)
   SET dstat = alterlist(reply->charge_event[cnt].charge_event_mod,1)
   SET reply->charge_event[cnt].charge_event_mod[1].charge_event_mod_type_cd = cbillcode
   SET reply->charge_event[cnt].charge_event_mod[1].field1 = cnvtstring(ccdmpharmsched)
   SET reply->charge_event[cnt].charge_event_mod[1].field2 = pha_rcvy->data[x].cdm
   SET reply->charge_event[cnt].charge_event_mod[1].field3 = pha_rcvy->data[x].ndc
   SET reply->charge_event[cnt].charge_event_mod[1].field4 = "1"
   IF (csched_type_ndc > 0)
    SET dstat = alterlist(reply->charge_event[cnt].charge_event_mod,2)
    SET reply->charge_event[cnt].charge_event_mod[2].charge_event_mod_type_cd = cbillcode
    SET reply->charge_event[cnt].charge_event_mod[2].field1 = cnvtstring(csched_type_ndc)
    SET reply->charge_event[cnt].charge_event_mod[2].field2 = pha_rcvy->data[x].ndc
    SET reply->charge_event[cnt].charge_event_mod[2].field5 = cnvtstring(pha_rcvy->data[x].
     ndc_reference_id)
    SET reply->charge_event[cnt].charge_event_mod[2].field7 = trim(format(pha_rcvy->data[x].
      billing_factor_nbr,"######.###;ILT(1);F"),3)
    SET reply->charge_event[cnt].charge_event_mod[2].field8 = cnvtstring(pha_rcvy->data[x].
     billing_uom_cd)
    SET reply->charge_event[cnt].charge_event_mod[2].field9 = cnvtstring(pha_rcvy->data[x].scan_flag)
   ENDIF
   SET dstat = uar_get_meaning_by_codeset(14002,"MODIFIER",1,dschedtypemodifier)
   IF ((pha_rcvy->data[x].disp_event_type_cd IN (cwastecharge, cwastecredit)))
    SET nchargeeventmodsize = (size(reply->charge_event[cnt].charge_event_mod,5)+ 1)
    SET dstat = alterlist(reply->charge_event[cnt].charge_event_mod,nchargeeventmodsize)
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].charge_event_mod_type_cd =
    cbillcode
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].field1 = cnvtstring(
     dschedtypemodifier)
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].field2 = "JW"
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].field3 =
    uar_get_code_description(ccode_modifier_jw)
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].field4 = "1"
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].field7 = cnvtstring(
     ccode_modifier_jw)
   ENDIF
   IF ((pha_rcvy->data[x].zero_waste_flag=1))
    SET nchargeeventmodsize = (size(reply->charge_event[cnt].charge_event_mod,5)+ 1)
    SET dstat = alterlist(reply->charge_event[cnt].charge_event_mod,nchargeeventmodsize)
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].charge_event_mod_type_cd =
    cbillcode
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].field1 = cnvtstring(
     dschedtypemodifier)
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].field2 = "JZ"
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].field3 =
    uar_get_code_description(ccode_modifier_jz)
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].field4 = "1"
    SET reply->charge_event[cnt].charge_event_mod[nchargeeventmodsize].field7 = cnvtstring(
     ccode_modifier_jz)
   ENDIF
  ENDIF
 ENDFOR
 SET reply->charge_event_qual = size(reply->charge_event,5)
 SUBROUTINE setrecoverind(null)
   DECLARE lidx = i4 WITH private, noconstant(0)
   DECLARE lidx2 = i4 WITH private, noconstant(0)
   FOR (lidx = 1 TO pha_rcvy->data_cnt)
     IF ((pha_rcvy->data[lidx].found_charge=0))
      IF ((pha_rcvy->data[lidx].suppress_charge_flag=nscf_not_suppressed))
       IF ((pha_rcvy->data[lidx].reverse_ind=1))
        IF ((pha_rcvy->data[lidx].charge_on_sched_admin_ind=1))
         SET lidx2 = locateval(lidx2,1,pha_rcvy->data_cnt,pha_rcvy->data[lidx].
          rx_admin_dispense_hx_id,pha_rcvy->data[lidx2].rx_admin_dispense_hx_id,
          0,pha_rcvy->data[lidx2].parent_ind,0,pha_rcvy->data[lidx2].reverse_ind,1,
          pha_rcvy->data[lidx2].found_charge)
        ELSE
         SET lidx2 = locateval(lidx2,1,pha_rcvy->data_cnt,pha_rcvy->data[lidx].dispense_hx_id,
          pha_rcvy->data[lidx2].dispense_hx_id,
          0,pha_rcvy->data[lidx2].parent_ind,0,pha_rcvy->data[lidx2].reverse_ind,1,
          pha_rcvy->data[lidx2].found_charge)
        ENDIF
        IF (lidx2 > 0)
         SET pha_rcvy->data[lidx].recover_ind = 1
        ENDIF
       ELSEIF ((pha_rcvy->data[lidx].table_reverse_ind=0))
        SET pha_rcvy->data[lidx].recover_ind = 1
       ENDIF
      ENDIF
     ELSE
      IF ((pha_rcvy->data[lidx].parent_ind=0)
       AND (pha_rcvy->data[lidx].table_reverse_ind=0))
       IF ((pha_rcvy->data[lidx].suppress_charge_flag=nscf_not_suppressed))
        IF ((pha_rcvy->data[lidx].already_reversed_ind=1))
         SET pha_rcvy->data[lidx].recover_ind = 1
        ENDIF
       ELSE
        IF ((pha_rcvy->data[lidx].already_reversed_ind=0))
         SET pha_rcvy->data[lidx].recover_ind = 1
         SET pha_rcvy->data[lidx].reverse_ind = 1
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 FREE RECORD pha_rcvy
 FREE RECORD rev_data
 FREE RECORD pref_data
 FREE RECORD tempdata
 FREE RECORD cosa_rev_data
 CALL echo("Last MOD: 013")
 CALL echo("MOD Date: 02/08/2023")
END GO

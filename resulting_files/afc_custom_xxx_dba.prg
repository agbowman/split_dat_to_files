CREATE PROGRAM afc_custom_xxx:dba
 CALL echo("RS4231 executing afc_run_custom_XXX")
 RECORD request2(
   1 beg_action = i2
   1 end_action = i2
   1 first_time = c1
   1 file_name = c80
   1 charge_qual = i4
   1 charge[*]
     2 interface_charge_id = f8
     2 charge_event_id = f8
     2 charge_item_id = f8
     2 charge_act_id = f8
     2 charge_mod_id = f8
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 age = f8
     2 sex_cd = f8
     2 sex_cd_alias = c100
     2 encntr_id = f8
     2 payor_id = f8
     2 order_dept = i4
     2 order_department = c40
     2 ord_doc_nbr = c20
     2 section_cd = f8
     2 section_cd_alias = c100
     2 perf_loc_cd = f8
     2 perf_loc_cd_alias = c100
     2 adm_phys_id = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 referring_phys_id = f8
     2 quantity = f8
     2 price = f8
     2 net_ext_price = f8
     2 service_dt_tm = dq8
     2 prim_cdm = c40
     2 prim_cpt = c40
     2 charge_description = c200
     2 med_nbr = c20
     2 fin_nbr = c20
     2 client = c20
     2 person_name = c30
     2 encntr_type_display = c40
     2 encntr_type_cd = f8
     2 encntr_type_cd_alias = c100
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 active_ind = i2
     2 interface_file_id = f8
     2 charge_type_cd = f8
     2 charge_type_cd_alias = c100
     2 active_status_cd = f8
     2 active_status_cd_alias = c100
     2 active_status_prsnl_id = f8
     2 active_status_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 institution_cd = f8
     2 institution_cd_alias = c100
     2 department_cd = f8
     2 department_cd_alias = c100
     2 subsection_cd = f8
     2 subsection_cd_alias = c100
     2 process_flg = i4
     2 gross_price = f8
     2 discount_amount = f8
     2 batch_num = i4
     2 bill_code1 = c50
     2 bill_code1_desc = c200
     2 bill_code2 = c50
     2 bill_code2_desc = c200
     2 bill_code3 = c50
     2 bill_code3_desc = c200
     2 diag_code1 = c50
     2 diag_desc1 = c200
     2 diag_code2 = c50
     2 diag_desc2 = c200
     2 diag_code3 = c50
     2 diag_desc3 = c200
     2 organization_id = f8
     2 level5_cd = f8
     2 level5_cd_alias = c100
     2 facility_cd = f8
     2 facility_cd_alias = c100
     2 building_cd = f8
     2 building_cd_alias = c100
     2 nurse_unit_cd = f8
     2 nurse_unit_cd_alias = c100
     2 room_cd = f8
     2 room_cd_alias = c100
     2 bed_cd = f8
     2 bed_cd_alias = c100
     2 attending_phys_id = f8
     2 additional_encntr_phys1_id = f8
     2 additional_encntr_phys2_id = f8
     2 additional_encntr_phys3_id = f8
     2 beg_effective_dt_tm = dq8
     2 prim_cpt_desc = c200
     2 order_nbr = c200
     2 manual_ind = i2
     2 posted_dt_tm = dq8
     2 override_desc = c200
     2 fin_nbr_type_flg = i4
     2 admit_type_cd = f8
     2 admit_type_cd_alias = c100
     2 prim_icd9_proc = c50
     2 prim_icd9_proc_desc = c200
     2 cost_center_cd = f8
     2 cost_center_cd_alias = c100
     2 bill_code_type_cdf = c12
     2 code_modifier1_cd = f8
     2 code_modifier1_cd_alias = c100
     2 code_modifier2_cd = f8
     2 code_modifier2_cd_alias = c100
     2 code_modifier3_cd = f8
     2 code_modifier3_cd_alias = c100
     2 code_modifier_more_ind = i2
     2 bill_code_more_ind = i2
     2 diag_more_ind = i2
     2 icd9_proc_more_ind = i2
     2 abn_status_cd = f8
     2 abn_status_cd_alias = c100
     2 user_def_ind = i2
     2 activity_type_cd = f8
     2 activity_type_cd_alias = c100
     2 contributor_source_cd = f8
     2 contributor_system_cd = f8
     2 research_acct_id = f8
 )
 FREE SET csops_request2
 RECORD csops_request2(
   1 csops_summ_id = f8
   1 job_name_cd = f8
   1 batch_num = i4
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 job_status = c1
   1 seq = i4
   1 charge_qual = i2
   1 charges[*]
     2 interface_file_id = f8
     2 charge_type_cd = f8
     2 raw_count = i4
     2 total_amount = f8
     2 total_quantity = f8
 )
 IF (validate(request->rerun_mode,"XXX") != "XXX")
  IF (trim(request->rerun_mode)="DAY")
   SET r_mode = "DAY"
  ELSEIF (trim(request->rerun_mode)="OOPS")
   SET r_mode = "OOPS"
  ELSE
   SET r_mode = "REGULAR"
  ENDIF
 ELSE
  SET r_mode = "REGULAR"
 ENDIF
 CALL echo(build("Run Mode is: ",r_mode))
 IF (validate(request->ops_date,999) != 999)
  IF ((request->ops_date > 0))
   SET rn_dt = cnvtdatetime(request->ops_date)
  ELSE
   SET rn_dt = cnvtdatetime(curdate,curtime)
  ENDIF
 ELSE
  SET rn_dt = cnvtdatetime(curdate,curtime)
 ENDIF
 CALL echo(build("Ops date is:",rn_dt))
 SET reply->status_data.status = "F"
 SET count1 = 0
 DECLARE total_qty_debit = f8
 DECLARE total_amt_debit = f8
 DECLARE total_cnt_debit = i4
 DECLARE total_qty_credit = f8
 DECLARE total_amt_credit = f8
 DECLARE total_cnt_credit = i4
 SET total_qty_credit = 0
 SET total_amt_credit = 0
 SET total_cnt_credit = 0
 SET total_qty_debit = 0
 SET total_amt_debit = 0
 SET total_cnt_debit = 0
 SET commit1_ind = 0
 SET cnt_seq = 0
 DECLARE object_name_cd = f8
 DECLARE debit_cd = f8
 DECLARE credit_cd = f8
 DECLARE g_bill_mnem_cd = f8
 DECLARE g_org_alias_client_cd = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET codeset = 25632
 SET cdf_meaning = "AFC_RUN_CUST"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,object_name_cd)
 CALL echo(build("the AFC_POST_INT code value is: ",object_name_cd))
 SET csops_request2->job_name_cd = object_name_cd
 SET codeset = 13028
 SET cdf_meaning = "DR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,debit_cd)
 CALL echo(build("the debit_cd code value is: ",debit_cd))
 SET codeset = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,credit_cd)
 CALL echo(build("the credit_cd code value is: ",credit_cd))
 SET codeset = 13031
 SET cdf_meaning = "BILLMNEM"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,g_bill_mnem_cd)
 CALL echo(build("the billmnem code is : ",g_bill_mnem_cd))
 SET codeset = 334
 SET cdf_meaning = "CLIENT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,g_org_alias_client_cd)
 CALL echo(build("the client code is : ",g_org_alias_client_cd))
 SET run_dt = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 CALL echo(format(cnvtdatetime(run_dt),"DD-MMM-YYYY hh:mm;;d"))
 SET csops_request2->start_dt_tm = rn_dt
 SET file_name = outputlist->ol_frecs[rptrun].ol_file_name
 CALL echo(build("filename is: ",file_name))
 IF (r_mode="DAY")
  SELECT INTO "nl:"
   i.*
   FROM interface_charge i
   PLAN (i
    WHERE i.process_flg=999
     AND i.posted_dt_tm=cnvtdatetime(run_dt)
     AND (i.interface_file_id=outputlist->ol_frecs[rptrun].ol_file_id))
   ORDER BY i.cost_center_cd
   DETAIL
    count1 = (count1+ 1), stat = alterlist(request2->charge,count1), stat = alterlist(reply->t01_recs,
     count1),
    request2->charge[count1].interface_charge_id = i.interface_charge_id, request2->charge[count1].
    charge_item_id = i.charge_item_id, request2->charge[count1].fin_nbr = i.fin_nbr,
    request2->charge[count1].person_name = i.person_name, request2->charge[count1].person_id = i
    .person_id, request2->charge[count1].sex_cd = 0,
    request2->charge[count1].encntr_id = i.encntr_id, request2->charge[count1].payor_id = i.payor_id,
    request2->charge[count1].encntr_type_cd = i.encntr_type_cd,
    request2->charge[count1].order_dept = i.order_dept, request2->charge[count1].order_department =
    fillstring(40," "), request2->charge[count1].section_cd = i.section_cd,
    request2->charge[count1].perf_loc_cd = i.perf_loc_cd, request2->charge[count1].encntr_type_cd = i
    .encntr_type_cd, request2->charge[count1].payor_id = i.payor_id,
    request2->charge[count1].adm_phys_id = i.adm_phys_id, request2->charge[count1].ord_phys_id = i
    .ord_phys_id, request2->charge[count1].perf_phys_id = i.perf_phys_id,
    request2->charge[count1].referring_phys_id = i.referring_phys_id, request2->charge[count1].
    ord_doc_nbr = i.ord_doc_nbr, request2->charge[count1].prim_cdm = i.prim_cdm,
    request2->charge[count1].charge_description = trim(i.prim_cdm_desc,3), request2->charge[count1].
    prim_cpt = i.prim_cpt, request2->charge[count1].quantity = i.quantity,
    request2->charge[count1].price = i.price, request2->charge[count1].net_ext_price = i
    .net_ext_price, request2->charge[count1].service_dt_tm = i.service_dt_tm,
    request2->charge[count1].updt_dt_tm = i.updt_dt_tm, request2->charge[count1].active_ind = i
    .active_ind, request2->charge[count1].interface_file_id = i.interface_file_id,
    request2->charge[count1].charge_type_cd = i.charge_type_cd, request2->charge[count1].updt_cnt = i
    .updt_cnt, request2->charge[count1].updt_id = i.updt_id,
    request2->charge[count1].updt_task = i.updt_task, request2->charge[count1].updt_applctx = i
    .updt_applctx, request2->charge[count1].active_status_cd = i.active_status_cd,
    request2->charge[count1].active_status_dt_tm = i.active_status_dt_tm, request2->charge[count1].
    end_effective_dt_tm = i.end_effective_dt_tm, request2->charge[count1].institution_cd = i
    .institution_cd,
    request2->charge[count1].department_cd = i.department_cd, request2->charge[count1].subsection_cd
     = i.subsection_cd, request2->charge[count1].gross_price = i.gross_price,
    request2->charge[count1].discount_amount = i.discount_amount, request2->charge[count1].med_nbr =
    i.med_nbr, request2->charge[count1].batch_num = i.batch_num,
    csops_request2->batch_num = request2->charge[count1].batch_num, request2->charge[count1].
    bill_code1 = i.bill_code1, request2->charge[count1].bill_code1_desc = i.bill_code1_desc,
    request2->charge[count1].bill_code2 = i.bill_code2, request2->charge[count1].bill_code2_desc = i
    .bill_code2_desc, request2->charge[count1].bill_code3 = i.bill_code3,
    request2->charge[count1].bill_code3_desc = i.bill_code3_desc, request2->charge[count1].diag_code1
     = i.diag_code1, request2->charge[count1].diag_desc1 = i.diag_desc1,
    request2->charge[count1].diag_code2 = i.diag_code2, request2->charge[count1].diag_desc2 = i
    .diag_desc2, request2->charge[count1].diag_code3 = i.diag_code3,
    request2->charge[count1].diag_desc3 = i.diag_desc3, request2->charge[count1].organization_id = i
    .organization_id, request2->charge[count1].level5_cd = i.level5_cd,
    request2->charge[count1].facility_cd = i.facility_cd, request2->charge[count1].building_cd = i
    .building_cd, request2->charge[count1].nurse_unit_cd = i.nurse_unit_cd,
    request2->charge[count1].room_cd = i.room_cd, request2->charge[count1].bed_cd = i.bed_cd,
    request2->charge[count1].attending_phys_id = i.attending_phys_id,
    request2->charge[count1].additional_encntr_phys1_id = i.additional_encntr_phys1_id, request2->
    charge[count1].additional_encntr_phys2_id = i.additional_encntr_phys2_id, request2->charge[count1
    ].additional_encntr_phys3_id = i.additional_encntr_phys3_id,
    request2->charge[count1].beg_effective_dt_tm = i.beg_effective_dt_tm, request2->charge[count1].
    prim_cpt_desc = i.prim_cpt_desc, request2->charge[count1].order_nbr = i.order_nbr,
    request2->charge[count1].manual_ind = i.manual_ind, request2->charge[count1].posted_dt_tm = i
    .posted_dt_tm, request2->charge[count1].override_desc = i.override_desc,
    request2->charge[count1].fin_nbr_type_flg = i.fin_nbr_type_flg, request2->charge[count1].
    admit_type_cd = i.admit_type_cd, request2->charge[count1].prim_icd9_proc = i.prim_icd9_proc,
    request2->charge[count1].prim_icd9_proc_desc = i.prim_icd9_proc_desc, request2->charge[count1].
    cost_center_cd = i.cost_center_cd, request2->charge[count1].bill_code_type_cdf = i
    .bill_code_type_cdf,
    request2->charge[count1].code_modifier1_cd = i.code_modifier1_cd, request2->charge[count1].
    code_modifier2_cd = i.code_modifier2_cd, request2->charge[count1].code_modifier3_cd = i
    .code_modifier3_cd,
    request2->charge[count1].code_modifier_more_ind = i.code_modifier_more_ind, request2->charge[
    count1].bill_code_more_ind = i.bill_code_more_ind, request2->charge[count1].diag_more_ind = i
    .diag_more_ind,
    request2->charge[count1].icd9_proc_more_ind = i.icd9_proc_more_ind, request2->charge[count1].
    abn_status_cd = i.abn_status_cd, request2->charge[count1].user_def_ind = i.user_def_ind,
    request2->charge[count1].activity_type_cd = i.activity_type_cd, request2->charge[count1].
    contributor_source_cd = 0, request2->charge[count1].contributor_system_cd = 0,
    request2->charge[count1].research_acct_id = 0, reply->t01_recs[count1].t01_interfaced = "Y",
    request2->charge_qual = count1
    IF ((request2->charge[count1].charge_type_cd=credit_cd))
     total_qty_credit = (total_qty_credit+ request2->charge[count1].quantity), total_amt_credit = (
     total_amt_credit+ request2->charge[count1].price), total_cnt_credit = count1
    ELSEIF ((request2->charge[count1].charge_type_cd=debit_cd))
     total_qty_debit = (total_qty_debit+ request2->charge[count1].quantity), total_amt_debit = (
     total_amt_debit+ request2->charge[count1].price), total_cnt_debit = count1
    ENDIF
   WITH nocounter, outerjoin = cv
  ;end select
  CALL echo("Finished DAY mode")
 ELSEIF (trim(r_mode)="OOPS")
  SELECT INTO "nl:"
   i.*
   FROM interface_charge i
   PLAN (i
    WHERE ((i.process_flg=0
     AND i.beg_effective_dt_tm < cnvtdatetime(run_dt)) OR (i.process_flg=999
     AND i.posted_dt_tm=cnvtdatetime(run_dt)
     AND (i.interface_file_id=outputlist->ol_frecs[rptrun].ol_file_id))) )
   ORDER BY i.cost_center_cd
   DETAIL
    count1 = (count1+ 1), stat = alterlist(request2->charge,count1), stat = alterlist(reply->t01_recs,
     count1),
    request2->charge[count1].interface_charge_id = i.interface_charge_id, request2->charge[count1].
    charge_item_id = i.charge_item_id, request2->charge[count1].fin_nbr = i.fin_nbr,
    request2->charge[count1].person_name = i.person_name, request2->charge[count1].person_id = i
    .person_id, request2->charge[count1].sex_cd = 0,
    request2->charge[count1].encntr_id = i.encntr_id, request2->charge[count1].encntr_type_cd = i
    .encntr_type_cd, request2->charge[count1].payor_id = i.payor_id,
    request2->charge[count1].order_dept = i.order_dept, request2->charge[count1].order_department =
    fillstring(40," "), request2->charge[count1].section_cd = i.section_cd,
    request2->charge[count1].perf_loc_cd = i.perf_loc_cd, request2->charge[count1].encntr_type_cd = i
    .encntr_type_cd, request2->charge[count1].payor_id = i.payor_id,
    request2->charge[count1].adm_phys_id = i.adm_phys_id, request2->charge[count1].ord_phys_id = i
    .ord_phys_id, request2->charge[count1].perf_phys_id = i.perf_phys_id,
    request2->charge[count1].referring_phys_id = i.referring_phys_id, request2->charge[count1].
    ord_doc_nbr = i.ord_doc_nbr, request2->charge[count1].prim_cdm = i.prim_cdm,
    request2->charge[count1].charge_description = trim(i.prim_cdm_desc,3), request2->charge[count1].
    prim_cpt = i.prim_cpt, request2->charge[count1].quantity = i.quantity,
    request2->charge[count1].price = i.price, request2->charge[count1].net_ext_price = i
    .net_ext_price, request2->charge[count1].service_dt_tm = i.service_dt_tm,
    request2->charge[count1].updt_dt_tm = i.updt_dt_tm, request2->charge[count1].active_ind = i
    .active_ind, request2->charge[count1].interface_file_id = i.interface_file_id,
    request2->charge[count1].charge_type_cd = i.charge_type_cd, request2->charge[count1].updt_cnt = i
    .updt_cnt, request2->charge[count1].updt_id = i.updt_id,
    request2->charge[count1].updt_task = i.updt_task, request2->charge[count1].updt_applctx = i
    .updt_applctx, request2->charge[count1].active_status_cd = i.active_status_cd,
    request2->charge[count1].active_status_dt_tm = i.active_status_dt_tm, request2->charge[count1].
    end_effective_dt_tm = i.end_effective_dt_tm, request2->charge[count1].institution_cd = i
    .institution_cd,
    request2->charge[count1].department_cd = i.department_cd, request2->charge[count1].subsection_cd
     = i.subsection_cd, request2->charge[count1].gross_price = i.gross_price,
    request2->charge[count1].discount_amount = i.discount_amount, request2->charge[count1].med_nbr =
    i.med_nbr, request2->charge[count1].batch_num = i.batch_num,
    csops_request2->batch_num = request2->charge[count1].batch_num, request2->charge[count1].
    bill_code1 = i.bill_code1, request2->charge[count1].bill_code1_desc = i.bill_code1_desc,
    request2->charge[count1].bill_code2 = i.bill_code2, request2->charge[count1].bill_code2_desc = i
    .bill_code2_desc, request2->charge[count1].bill_code3 = i.bill_code3,
    request2->charge[count1].bill_code3_desc = i.bill_code3_desc, request2->charge[count1].diag_code1
     = i.diag_code1, request2->charge[count1].diag_desc1 = i.diag_desc1,
    request2->charge[count1].diag_code2 = i.diag_code2, request2->charge[count1].diag_desc2 = i
    .diag_desc2, request2->charge[count1].diag_code3 = i.diag_code3,
    request2->charge[count1].diag_desc3 = i.diag_desc3, request2->charge[count1].organization_id = i
    .organization_id, request2->charge[count1].level5_cd = i.level5_cd,
    request2->charge[count1].facility_cd = i.facility_cd, request2->charge[count1].building_cd = i
    .building_cd, request2->charge[count1].nurse_unit_cd = i.nurse_unit_cd,
    request2->charge[count1].room_cd = i.room_cd, request2->charge[count1].bed_cd = i.bed_cd,
    request2->charge[count1].attending_phys_id = i.attending_phys_id,
    request2->charge[count1].additional_encntr_phys1_id = i.additional_encntr_phys1_id, request2->
    charge[count1].additional_encntr_phys2_id = i.additional_encntr_phys2_id, request2->charge[count1
    ].additional_encntr_phys3_id = i.additional_encntr_phys3_id,
    request2->charge[count1].beg_effective_dt_tm = i.beg_effective_dt_tm, request2->charge[count1].
    prim_cpt_desc = i.prim_cpt_desc, request2->charge[count1].order_nbr = i.order_nbr,
    request2->charge[count1].manual_ind = i.manual_ind, request2->charge[count1].posted_dt_tm = i
    .posted_dt_tm, request2->charge[count1].override_desc = i.override_desc,
    request2->charge[count1].fin_nbr_type_flg = i.fin_nbr_type_flg, request2->charge[count1].
    admit_type_cd = i.admit_type_cd, request2->charge[count1].prim_icd9_proc = i.prim_icd9_proc,
    request2->charge[count1].prim_icd9_proc_desc = i.prim_icd9_proc_desc, request2->charge[count1].
    cost_center_cd = i.cost_center_cd, request2->charge[count1].bill_code_type_cdf = i
    .bill_code_type_cdf,
    request2->charge[count1].code_modifier1_cd = i.code_modifier1_cd, request2->charge[count1].
    code_modifier2_cd = i.code_modifier2_cd, request2->charge[count1].code_modifier3_cd = i
    .code_modifier3_cd,
    request2->charge[count1].code_modifier_more_ind = i.code_modifier_more_ind, request2->charge[
    count1].bill_code_more_ind = i.bill_code_more_ind, request2->charge[count1].diag_more_ind = i
    .diag_more_ind,
    request2->charge[count1].icd9_proc_more_ind = i.icd9_proc_more_ind, request2->charge[count1].
    abn_status_cd = i.abn_status_cd, request2->charge[count1].user_def_ind = i.user_def_ind,
    request2->charge[count1].activity_type_cd = i.activity_type_cd, request2->charge[count1].
    contributor_source_cd = 0, request2->charge[count1].contributor_system_cd = 0,
    request2->charge[count1].research_acct_id = 0, reply->t01_recs[count1].t01_interfaced = "Y",
    request2->charge_qual = count1
    IF ((request2->charge[count1].charge_type_cd=credit_cd))
     CALL echo(build("charge_item_id credit",request2->charge[count1].interface_charge_id)),
     total_qty_credit = (total_qty_credit+ request2->charge[count1].quantity), total_amt_credit = (
     total_amt_credit+ request2->charge[count1].price),
     total_cnt_credit = count1
    ELSEIF ((request2->charge[count1].charge_type_cd=debit_cd))
     CALL echo(build("charge_item_id debit",request2->charge[count1].interface_charge_id)),
     total_qty_debit = (total_qty_debit+ request2->charge[count1].quantity), total_amt_debit = (
     total_amt_debit+ request2->charge[count1].price),
     total_cnt_debit = count1
    ENDIF
   WITH nocounter, outerjoin = cv
  ;end select
  CALL echo("Finished OOPS mode")
 ELSE
  SELECT INTO "nl:"
   i.*
   FROM interface_charge i
   PLAN (i
    WHERE i.process_flg=0
     AND i.beg_effective_dt_tm < cnvtdatetime(run_dt)
     AND (i.interface_file_id=outputlist->ol_frecs[rptrun].ol_file_id))
   ORDER BY i.cost_center_cd
   DETAIL
    count1 = (count1+ 1), stat = alterlist(request2->charge,count1), stat = alterlist(reply->t01_recs,
     count1),
    request2->charge[count1].interface_charge_id = i.interface_charge_id, request2->charge[count1].
    charge_item_id = i.charge_item_id, request2->charge[count1].fin_nbr = i.fin_nbr,
    request2->charge[count1].person_name = i.person_name, request2->charge[count1].person_id = i
    .person_id, request2->charge[count1].sex_cd = 0,
    request2->charge[count1].encntr_id = i.encntr_id, request2->charge[count1].encntr_type_cd = i
    .encntr_type_cd, request2->charge[count1].payor_id = i.payor_id,
    request2->charge[count1].order_dept = i.order_dept, request2->charge[count1].order_department =
    fillstring(40," "), request2->charge[count1].section_cd = i.section_cd,
    request2->charge[count1].perf_loc_cd = i.perf_loc_cd, request2->charge[count1].encntr_type_cd = i
    .encntr_type_cd, request2->charge[count1].payor_id = i.payor_id,
    request2->charge[count1].adm_phys_id = i.adm_phys_id, request2->charge[count1].ord_phys_id = i
    .ord_phys_id, request2->charge[count1].perf_phys_id = i.perf_phys_id,
    request2->charge[count1].referring_phys_id = i.referring_phys_id, request2->charge[count1].
    ord_doc_nbr = i.ord_doc_nbr, request2->charge[count1].prim_cdm = i.prim_cdm,
    request2->charge[count1].charge_description = trim(i.prim_cdm_desc,3), request2->charge[count1].
    prim_cpt = i.prim_cpt, request2->charge[count1].quantity = i.quantity,
    request2->charge[count1].price = i.price, request2->charge[count1].net_ext_price = i
    .net_ext_price, request2->charge[count1].service_dt_tm = i.service_dt_tm,
    request2->charge[count1].updt_dt_tm = i.updt_dt_tm, request2->charge[count1].active_ind = i
    .active_ind, request2->charge[count1].interface_file_id = i.interface_file_id,
    request2->charge[count1].charge_type_cd = i.charge_type_cd, request2->charge[count1].updt_cnt = i
    .updt_cnt, request2->charge[count1].updt_id = i.updt_id,
    request2->charge[count1].updt_task = i.updt_task, request2->charge[count1].updt_applctx = i
    .updt_applctx, request2->charge[count1].active_status_cd = i.active_status_cd,
    request2->charge[count1].active_status_dt_tm = i.active_status_dt_tm, request2->charge[count1].
    end_effective_dt_tm = i.end_effective_dt_tm, request2->charge[count1].institution_cd = i
    .institution_cd,
    request2->charge[count1].department_cd = i.department_cd, request2->charge[count1].subsection_cd
     = i.subsection_cd, request2->charge[count1].gross_price = i.gross_price,
    request2->charge[count1].discount_amount = i.discount_amount, request2->charge[count1].med_nbr =
    i.med_nbr, request2->charge[count1].batch_num = i.batch_num,
    csops_request2->batch_num = request2->charge[count1].batch_num, request2->charge[count1].
    bill_code1 = i.bill_code1, request2->charge[count1].bill_code1_desc = i.bill_code1_desc,
    request2->charge[count1].bill_code2 = i.bill_code2, request2->charge[count1].bill_code2_desc = i
    .bill_code2_desc, request2->charge[count1].bill_code3 = i.bill_code3,
    request2->charge[count1].bill_code3_desc = i.bill_code3_desc, request2->charge[count1].diag_code1
     = i.diag_code1, request2->charge[count1].diag_desc1 = i.diag_desc1,
    request2->charge[count1].diag_code2 = i.diag_code2, request2->charge[count1].diag_desc2 = i
    .diag_desc2, request2->charge[count1].diag_code3 = i.diag_code3,
    request2->charge[count1].diag_desc3 = i.diag_desc3, request2->charge[count1].organization_id = i
    .organization_id, request2->charge[count1].level5_cd = i.level5_cd,
    request2->charge[count1].facility_cd = i.facility_cd, request2->charge[count1].building_cd = i
    .building_cd, request2->charge[count1].nurse_unit_cd = i.nurse_unit_cd,
    request2->charge[count1].room_cd = i.room_cd, request2->charge[count1].bed_cd = i.bed_cd,
    request2->charge[count1].attending_phys_id = i.attending_phys_id,
    request2->charge[count1].additional_encntr_phys1_id = i.additional_encntr_phys1_id, request2->
    charge[count1].additional_encntr_phys2_id = i.additional_encntr_phys2_id, request2->charge[count1
    ].additional_encntr_phys3_id = i.additional_encntr_phys3_id,
    request2->charge[count1].beg_effective_dt_tm = i.beg_effective_dt_tm, request2->charge[count1].
    prim_cpt_desc = i.prim_cpt_desc, request2->charge[count1].order_nbr = i.order_nbr,
    request2->charge[count1].manual_ind = i.manual_ind, request2->charge[count1].posted_dt_tm = i
    .posted_dt_tm, request2->charge[count1].override_desc = i.override_desc,
    request2->charge[count1].fin_nbr_type_flg = i.fin_nbr_type_flg, request2->charge[count1].
    admit_type_cd = i.admit_type_cd, request2->charge[count1].prim_icd9_proc = i.prim_icd9_proc,
    request2->charge[count1].prim_icd9_proc_desc = i.prim_icd9_proc_desc, request2->charge[count1].
    cost_center_cd = i.cost_center_cd, request2->charge[count1].bill_code_type_cdf = i
    .bill_code_type_cdf,
    request2->charge[count1].code_modifier1_cd = i.code_modifier1_cd, request2->charge[count1].
    code_modifier2_cd = i.code_modifier2_cd, request2->charge[count1].code_modifier3_cd = i
    .code_modifier3_cd,
    request2->charge[count1].code_modifier_more_ind = i.code_modifier_more_ind, request2->charge[
    count1].bill_code_more_ind = i.bill_code_more_ind, request2->charge[count1].diag_more_ind = i
    .diag_more_ind,
    request2->charge[count1].icd9_proc_more_ind = i.icd9_proc_more_ind, request2->charge[count1].
    abn_status_cd = i.abn_status_cd, request2->charge[count1].user_def_ind = i.user_def_ind,
    request2->charge[count1].activity_type_cd = i.activity_type_cd, request2->charge[count1].
    contributor_source_cd = 0, request2->charge[count1].contributor_system_cd = 0,
    request2->charge[count1].research_acct_id = 0, reply->t01_recs[count1].t01_interfaced = "Y",
    request2->charge_qual = count1
    IF ((request2->charge[count1].charge_type_cd=credit_cd))
     CALL echo(build("charge_item_id credit",request2->charge[count1].interface_charge_id)),
     total_qty_credit = (total_qty_credit+ request2->charge[count1].quantity), total_amt_credit = (
     total_amt_credit+ request2->charge[count1].price),
     total_cnt_credit = count1
    ELSEIF ((request2->charge[count1].charge_type_cd=debit_cd))
     total_qty_debit = (total_qty_debit+ request2->charge[count1].quantity), total_amt_debit = (
     total_amt_debit+ request2->charge[count1].price), total_cnt_debit = count1
    ENDIF
   WITH nocounter, outerjoin = cv
  ;end select
 ENDIF
 CALL echo(build("# Recs: ",request2->charge_qual))
 IF ((request2->charge_qual=0))
  SET reply->status_data.status = "Z"
  GO TO end_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request2->charge_qual > 0))
  SELECT INTO "nl:"
   i.contributor_system_cd
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    interface_file i
   PLAN (d1)
    JOIN (i
    WHERE (i.interface_file_id=request2->charge[d1.seq].interface_file_id))
   DETAIL
    request2->charge[d1.seq].contributor_system_cd = i.contributor_system_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.contributor_souce_cd
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    contributor_system c
   PLAN (d1)
    JOIN (c
    WHERE (c.contributor_system_cd=request2->charge[d1.seq].contributor_system_cd))
   DETAIL
    request2->charge[d1.seq].contributor_source_cd = c.contributor_source_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   oapr.organization_id, oapr.alias_entity_alias_type_cd, oa.organization_id,
   oa.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    org_alias_pool_reltn oapr,
    organization_alias oa
   PLAN (d1)
    JOIN (oapr
    WHERE (oapr.organization_id=request2->charge[d1.seq].payor_id)
     AND oapr.alias_entity_name="ORGANIZATION_ALIAS"
     AND oapr.alias_entity_alias_type_cd=g_org_alias_client_cd
     AND oapr.active_ind=1)
    JOIN (oa
    WHERE (oa.organization_id=request2->charge[d1.seq].payor_id)
     AND oa.alias_pool_cd=oapr.alias_pool_cd
     AND oa.org_alias_type_cd=g_org_alias_client_cd
     AND oa.active_ind=1)
   DETAIL
    request2->charge[d1.seq].client = oa.alias
   WITH nocounter
  ;end select
  SET encntr_display = fillstring(40," ")
  SELECT INTO "nl:"
   e.encntr_type_cd, e.sex_cd, encntr_display = uar_get_code_display(e.encntr_type_cd)
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    encounter e
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=request2->charge[d1.seq].encntr_id))
   DETAIL
    request2->charge[d1.seq].encntr_type_display = encntr_display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].encntr_type_cd))
   DETAIL
    request2->charge[d1.seq].encntr_type_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.sex_cd
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    person p
   PLAN (d1)
    JOIN (p
    WHERE (p.person_id=request2->charge[d1.seq].person_id))
   DETAIL
    request2->charge[d1.seq].sex_cd = p.sex_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].sex_cd))
   DETAIL
    request2->charge[d1.seq].sex_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].section_cd))
   DETAIL
    request2->charge[d1.seq].section_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].perf_loc_cd))
   DETAIL
    request2->charge[d1.seq].perf_loc_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].charge_type_cd))
   DETAIL
    request2->charge[d1.seq].charge_type_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].active_status_cd))
   DETAIL
    request2->charge[d1.seq].active_status_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].institution_cd))
   DETAIL
    request2->charge[d1.seq].institution_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].department_cd))
   DETAIL
    request2->charge[d1.seq].department_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].subsection_cd))
   DETAIL
    request2->charge[d1.seq].subsection_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].level5_cd))
   DETAIL
    request2->charge[d1.seq].level5_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].facility_cd))
   DETAIL
    request2->charge[d1.seq].facility_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].building_cd))
   DETAIL
    request2->charge[d1.seq].building_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].nurse_unit_cd))
   DETAIL
    request2->charge[d1.seq].nurse_unit_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].room_cd))
   DETAIL
    request2->charge[d1.seq].room_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].bed_cd))
   DETAIL
    request2->charge[d1.seq].bed_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].admit_type_cd))
   DETAIL
    request2->charge[d1.seq].admit_type_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].cost_center_cd))
   DETAIL
    request2->charge[d1.seq].cost_center_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].code_modifier1_cd))
   DETAIL
    request2->charge[d1.seq].code_modifier1_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].code_modifier2_cd))
   DETAIL
    request2->charge[d1.seq].code_modifier2_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].code_modifier3_cd))
   DETAIL
    request2->charge[d1.seq].code_modifier3_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].abn_status_cd))
   DETAIL
    request2->charge[d1.seq].abn_status_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvo.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    code_value_outbound cvo
   PLAN (d1)
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request2->charge[d1.seq].contributor_source_cd)
     AND (cvo.code_value=request2->charge[d1.seq].activity_type_cd))
   DETAIL
    request2->charge[d1.seq].activity_type_cd_alias = cvo.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    charge c
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_item_id=request2->charge[d1.seq].charge_item_id))
   DETAIL
    request2->charge[d1.seq].research_acct_id = c.research_acct_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    encounter e,
    omf_encntr_smry o
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=request2->charge[d1.seq].encntr_id))
    JOIN (o
    WHERE (o.encntr_id=request2->charge[d1.seq].encntr_id))
   DETAIL
    request2->charge[d1.seq].birth_dt_tm = e.birth_dt_tm, request2->charge[d1.seq].age = o.age
   WITH nocounter
  ;end select
  SET outfile = substring(1,30,file_name)
  CALL echo(build("outfile is : ",outfile))
  SELECT INTO value(outfile)
   t01_perf_loc_cd_alias = request2->charge[d.seq].perf_loc_cd_alias, t01_charge_type_cd = request2->
   charge[d.seq].charge_type_cd_alias, t01_cost_center_cd_alias = request2->charge[d.seq].
   cost_center_cd_alias,
   t01_fin_nbr = request2->charge[d.seq].fin_nbr, t01_serv_dt = request2->charge[d.seq].service_dt_tm
   "MMDDYY;;D", t01_cdmcode = request2->charge[d.seq].prim_cdm,
   t01_serv_tm = request2->charge[d.seq].service_dt_tm"HHMM;;M", t01_quantity = request2->charge[d
   .seq].quantity, t01_amount = request2->charge[d.seq].price,
   t01_ordphys = request2->charge[d.seq].ord_doc_nbr, t01_servphys = request2->charge[d.seq].
   perf_phys_id, t01_prim_cpt = request2->charge[d.seq].prim_cpt,
   t01_refphys = request2->charge[d.seq].referring_phys_id, t01_desc = request2->charge[d.seq].
   charge_description, t01_client = request2->charge[d.seq].client,
   t01_ord_dept = request2->charge[d.seq].order_department
   FROM (dummyt d  WITH seq = value(request2->charge_qual))
   ORDER BY t01_fin_nbr
   DETAIL
    col 0, t01_charge_type_cd"#####", col 3,
    "C", col 4, t01_fin_nbr"#############",
    col 19, t01_serv_dt, col 27,
    t01_cdmcode"########", col 37, "5",
    col 39, t01_serv_tm, col 45,
    t01_quantity"###.##", col 49, t01_amount"##########",
    col 59, "N", col 60,
    t01_ordphys"######", col 68, t01_servphys"######",
    col 75, t01_refphys"######", col 82,
    "C", col 85, t01_prim_cpt"#######",
    col 93, t01_ord_dept, col 105,
    t01_desc"####################", col 125, t01_perf_loc_cd_alias"####################",
    col 145, t01_cost_center_cd_alias"####################", col 170,
    t01_client, row + 1
   WITH noformfeed, maxcol = 195, maxrow = 1,
    format = variable, noheading
  ;end select
  UPDATE  FROM interface_charge i,
    (dummyt d  WITH seq = value(request2->charge_qual))
   SET i.process_flg = 999, i.posted_dt_tm = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D"),
      " 23:59:59.99"))
   PLAN (d)
    JOIN (i
    WHERE (i.interface_charge_id=request2->charge[d.seq].interface_charge_id))
  ;end update
  COMMIT
  SET reply->status_data.status = "S"
  SET csops_request2->job_status = reply->status_data.status
  CALL echo(build("RS4231, job_status: ",csops_request2->job_status))
  SET csops_request2->end_dt_tm = cnvtdatetime(curdate,curtime)
  CALL echo(build("RS4231, end_dt_tm: ",csops_request2->end_dt_tm))
  SET stat = alterlist(csops_request2->charges,1)
  SET csops_request2->charges[1].interface_file_id = outputlist->ol_frecs[rptrun].ol_file_id
  CALL echo(build("RS4231 interface_file_id credit",csops_request2->charges[1].interface_file_id))
  SET csops_request2->charges[1].charge_type_cd = credit_cd
  CALL echo(build("RS4231 credit_cd credit",csops_request2->charges[1].charge_type_cd))
  SET csops_request2->charges[1].total_quantity = total_qty_credit
  CALL echo(build("RS4231 total_quantity credit",csops_request2->charges[1].total_quantity))
  SET csops_request2->charges[1].total_amount = total_amt_credit
  CALL echo(build("RS4231 total_amount credit",csops_request2->charges[1].total_amount))
  SET csops_request2->charges[1].raw_count = total_cnt_credit
  CALL echo(build("RS4231 total_count credit",csops_request2->charges[1].raw_count))
  SET stat = alterlist(csops_request2->charges,2)
  SET csops_request2->charges[2].interface_file_id = outputlist->ol_frecs[rptrun].ol_file_id
  CALL echo(build("RS4231 interface_file_id debit",csops_request2->charges[2].interface_file_id))
  SET csops_request2->charges[2].charge_type_cd = debit_cd
  CALL echo(build("RS4231 debit_cd",csops_request2->charges[2].charge_type_cd))
  SET csops_request2->charges[2].total_quantity = total_qty_debit
  CALL echo(build("RS4231 total_quantity debit",csops_request2->charges[2].total_quantity))
  SET csops_request2->charges[2].total_amount = total_amt_debit
  CALL echo(build("RS4231 total_amount debit",csops_request2->charges[2].total_amount))
  SET csops_request2->charges[2].raw_count = total_cnt_debit
  CALL echo(build("RS4231 total_count debit",csops_request2->charges[2].raw_count))
  EXECUTE afc_add_csops_summ
  EXECUTE afc_create_xxx
  CALL echo("Executing Create XXX")
 ELSE
  CALL echo("No charges found")
 ENDIF
#end_program
 SET count1 = 1
 FREE SET request2
END GO

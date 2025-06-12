CREATE PROGRAM afc_hl7_batch_interface:dba
 IF ("Z"=validate(afc_hl7_batch_interface_vrsn,"Z"))
  DECLARE afc_hl7_batch_interface_vrsn = vc WITH noconstant("374531.007")
 ENDIF
 SET afc_hl7_batch_interface_vrsn = "398062.008"
 EXECUTE srvrtl
 EXECUTE crmrtl
 FREE SET csops_request2
 RECORD csops_request2(
   1 csops_summ_id = f8
   1 job_name_cd = f8
   1 batch_num = f8
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
 RECORD recdate(
   1 datetime = dq8
 )
 FREE SET rqin
 RECORD rqin(
   1 message
     2 cqminfo
       3 appname = vc
       3 contribalias = vc
       3 contribrefnum = vc
       3 contribdttm = dq8
       3 priority = i4
       3 class = vc
       3 type = vc
       3 subtype = vc
       3 subtype_detail = vc
       3 debug_ind = i4
       3 verbosity_flag = i4
     2 esoinfo
       3 scriptcontrolval = i4
       3 scriptcontrolargs = vc
       3 dbnullprefix = vc
       3 aliasprefix = vc
       3 codeprefix = vc
       3 personprefix = vc
       3 eprsnlprefix = vc
       3 prsnlprefix = vc
       3 orderprefix = vc
       3 orgprefix = vc
       3 hlthplanprefix = vc
       3 nomenprefix = vc
       3 itemprefix = vc
       3 longlist[*]
         4 lval = i4
         4 strmeaning = vc
       3 stringlist[*]
         4 strval = vc
         4 strmeaning = vc
       3 doublelist[*]
         4 dval = f8
         4 strmeaning = vc
       3 sendobjectind = c1
     2 triginfo
       3 charge_seq = i4
       3 charge_total = i4
       3 send_dt_tm = dq8
       3 charge_info[*]
         4 interface_charge_id = f8
         4 order_dept = i4
         4 interface_file_id = f8
         4 charge_item_id = f8
         4 batch_num = f8
         4 bill_code1 = c50
         4 bill_code1_desc = c200
         4 bill_code2 = c50
         4 bill_code2_desc = c200
         4 bill_code3 = c50
         4 bill_code3_desc = c200
         4 prim_cdm = c50
         4 prim_cpt = c50
         4 diag_code1 = c50
         4 diag_code2 = c50
         4 diag_code3 = c50
         4 person_name = c100
         4 person_id = f8
         4 encntr_id = f8
         4 fin_nbr = c50
         4 med_nbr = c50
         4 service_dt_tm = dq8
         4 section_cd = f8
         4 encntr_type_cd = f8
         4 payor_id = f8
         4 quantity = f8
         4 price = f8
         4 net_ext_price = f8
         4 organization_id = f8
         4 institution_cd = f8
         4 department_cd = f8
         4 subsection_cd = f8
         4 level5_cd = f8
         4 facility_cd = f8
         4 building_cd = f8
         4 nurse_unit_cd = f8
         4 room_cd = f8
         4 bed_cd = f8
         4 referring_phys_id = f8
         4 ord_phys_id = f8
         4 ord_doc_nbr = c20
         4 adm_phys_id = f8
         4 attending_phys_id = f8
         4 additional_encntr_phys1_id = f8
         4 additional_encntr_phys2_id = f8
         4 additional_encntr_phys3_id = f8
         4 charge_type_cd = f8
         4 updt_cnt = i4
         4 updt_dt_tm = dq8
         4 updt_id = f8
         4 updt_task = i4
         4 updt_applctx = i4
         4 active_ind = i2
         4 active_status_cd = f8
         4 active_status_prsnl_id = f8
         4 active_status_dt_tm = dq8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 abn_status_cd = f8
         4 activity_type_cd = f8
         4 admit_type_cd = f8
         4 bill_code_more_ind = i2
         4 bill_code_type_cdf = c12
         4 code_modifier1_cd = f8
         4 code_modifier2_cd = f8
         4 code_modifier3_cd = f8
         4 code_modifier_more_ind = i2
         4 cost_center_cd = f8
         4 diag_desc1 = c200
         4 diag_desc2 = c200
         4 diag_desc3 = c200
         4 diag_more_ind = i2
         4 discount_amount = f8
         4 fin_nbr_type_flg = i4
         4 gross_price = f8
         4 icd9_proc_more_ind = i2
         4 manual_ind = i2
         4 med_service_cd = f8
         4 order_nbr = c200
         4 override_desc = c200
         4 perf_loc_cd = f8
         4 perf_phys_id = f8
         4 posted_dt_tm = dq8
         4 prim_cdm_desc = c200
         4 prim_cpt_desc = c200
         4 prim_icd9_proc = c50
         4 prim_icd9_proc_desc = c200
         4 process_flg = i4
         4 user_def_ind = i2
   1 params[*]
 )
 FREE SET rpout
 RECORD rpout(
   1 sb
     2 severity_cd = i4
     2 status_cd = i4
     2 status_text = vc
 )
 FREE SET charges
 RECORD charges(
   1 interface_charge_qual = i4
   1 interface_charge[*]
     2 interface_charge_id = f8
     2 order_dept = i4
     2 interface_file_id = f8
     2 charge_item_id = f8
     2 batch_num = f8
     2 bill_code1 = c50
     2 bill_code1_desc = c200
     2 bill_code2 = c50
     2 bill_code2_desc = c200
     2 bill_code3 = c50
     2 bill_code3_desc = c200
     2 prim_cdm = c50
     2 prim_cpt = c50
     2 diag_code1 = c50
     2 diag_code2 = c50
     2 diag_code3 = c50
     2 person_name = c100
     2 person_id = f8
     2 encntr_id = f8
     2 fin_nbr = c50
     2 med_nbr = c50
     2 service_dt_tm = dq8
     2 section_cd = f8
     2 encntr_type_cd = f8
     2 payor_id = f8
     2 quantity = f8
     2 price = f8
     2 net_ext_price = f8
     2 organization_id = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 facility_cd = f8
     2 building_cd = f8
     2 nurse_unit_cd = f8
     2 room_cd = f8
     2 bed_cd = f8
     2 referring_phys_id = f8
     2 ord_phys_id = f8
     2 ord_doc_nbr = c20
     2 adm_phys_id = f8
     2 attending_phys_id = f8
     2 additional_encntr_phys1_id = f8
     2 additional_encntr_phys2_id = f8
     2 additional_encntr_phys3_id = f8
     2 charge_type_cd = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_prsnl_id = f8
     2 active_status_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 abn_status_cd = f8
     2 activity_type_cd = f8
     2 admit_type_cd = f8
     2 bill_code_more_ind = i2
     2 bill_code_type_cdf = c12
     2 code_modifier1_cd = f8
     2 code_modifier2_cd = f8
     2 code_modifier3_cd = f8
     2 code_modifier_more_ind = i2
     2 cost_center_cd = f8
     2 diag_desc1 = c200
     2 diag_desc2 = c200
     2 diag_desc3 = c200
     2 diag_more_ind = i2
     2 discount_amount = f8
     2 fin_nbr_type_flg = i4
     2 gross_price = f8
     2 icd9_proc_more_ind = i2
     2 manual_ind = i2
     2 med_service_cd = f8
     2 order_nbr = c200
     2 override_desc = c200
     2 perf_loc_cd = f8
     2 perf_phys_id = f8
     2 posted_dt_tm = dq8
     2 prim_cdm_desc = c200
     2 prim_cpt_desc = c200
     2 prim_icd9_proc = c50
     2 prim_icd9_proc_desc = c200
     2 process_flg = i4
     2 user_def_ind = i2
     2 prim_icd9_proc_nomen_id = f8
     2 bill_code1_nomen_id = f8
     2 bill_code2_nomen_id = f8
     2 bill_code3_nomen_id = f8
     2 icd_diag_info[*]
       3 nomen_id = f8
 )
 DECLARE srvstat = i4 WITH public, noconstant(0)
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE credit_code = f8
 DECLARE cnt = i4
 DECLARE max_num_rows = i2
 DECLARE done = i2
 DECLARE grand_total = i4
 DECLARE header_sent = i2
 DECLARE num_runs = i4
 DECLARE found_some = i2
 DECLARE object_name_cd = f8
 DECLARE 13028_debit_cd = f8
 DECLARE loop_cnt_credit = i4
 DECLARE nocharge_code = f8
 DECLARE hold_fin_nbr = vc
 DECLARE fin_nbr = vc
 DECLARE strbinding = vc WITH public, noconstant("")
 DECLARE realtimeind = i2
 DECLARE 13019_billcode_cd = f8
 DECLARE 14002_icd9_cd = f8
 DECLARE 14002_proccode_cd = f8
 DECLARE diagcnt = i4
 DECLARE icddiagcnt = i4
 SET reply->status_data.status = "F"
 IF (cnvtint(outputlist->ol_frecs[rptrun].ol_max_ft1) > 0)
  SET max_ft1 = cnvtint(outputlist->ol_frecs[rptrun].ol_max_ft1)
 ELSE
  SET max_ft1 = 15
 ENDIF
 SET max_num_rows = 1000
 SET done = 0
 SET grand_total = 0
 SET header_sent = 0
 SET num_runs = 0
 SET found_some = 0
 SET total_qty_credit = 0.0
 SET total_amt_credit = 0.0
 SET total_cnt_credit = 0
 SET total_qty_debit = 0.0
 SET total_amt_debit = 0.0
 SET total_cnt_debit = 0
 SET commit1_ind = 0
 SET cnt_seq = 0
 FREE RECORD srvrec
 RECORD srvrec(
   1 qual[*]
     2 msg_id = i4
     2 hmsg = i4
     2 hreq = i4
     2 hrep = i4
     2 status = i4
 )
 DECLARE hmsgtype = i4
 SET hmsgtype = 0
 DECLARE hmsgstruct = i4
 DECLARE hcqmstruct = i4
 DECLARE htrigitem = i4
 DECLARE hchargeitem = i4
 DECLARE trigmessageid = i4
 DECLARE cqmmessageid = i4 WITH noconstant(1215001)
 DECLARE reqmessageid = i4 WITH noconstant(1215015)
 DECLARE hcqmmsg = i4 WITH noconstant(0)
 DECLARE hreqmsg = i4 WITH noconstant(0)
 DECLARE hreqtype = i4 WITH noconstant(0)
 DECLARE hreq = i4 WITH noconstant(0)
 DECLARE hrep = i4 WITH noconstant(0)
 CALL echo("executing afc_hl7_batch_interface...")
 CALL echo(build("max ft1 is: ",outputlist->ol_frecs[rptrun].ol_max_ft1))
 SET code_set = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,credit_code)
 CALL echo(build("The credit code is : ",credit_code))
 SET code_set = 13028
 SET cdf_meaning = "NO CHARGE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,nocharge_code)
 CALL echo(build("The nocharge code is : ",nocharge_code))
 SET codeset = 25632
 SET cdf_meaning = "AFC_RUN_CUST"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,object_name_cd)
 CALL echo(build("the AFC_POST_INT code value is: ",object_name_cd))
 SET csops_request2->job_name_cd = object_name_cd
 SET codeset = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,13019_billcode_cd)
 SET codeset = 14002
 SET cdf_meaning = "ICD9"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,14002_icd9_cd)
 SET codeset = 14002
 SET cdf_meaning = "PROCCODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,14002_proccode_cd)
 SET codeset = 13028
 SET cdf_meaning = "DR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,13028_debit_cd)
 CALL echo(build("the debit_cd code value is: ",13028_debit_cd))
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="SI"
   AND d.info_name="CALL_CQM_BATCH_CHARGE"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET strbinding = "BATCH"
 ENDIF
 IF ((validate(request->ops_date,- (1)) != - (1)))
  IF ((request->ops_date > 0))
   SET run_dt = cnvtdatetime(request->ops_date)
   SET csops_request2->start_dt_tm = run_dt
  ELSE
   SET run_dt = cnvtdatetime(curdate,curtime)
   SET csops_request2->start_dt_tm = run_dt
  ENDIF
 ELSE
  SET run_dt = cnvtdatetime(curdate,curtime)
  SET csops_request2->start_dt_tm = run_dt
 ENDIF
 IF (validate(request->batch_selection," ") != " ")
  SET file_passed_in = request->batch_selection
  CALL echo(build("file_pass_id is : ",file_passed_in))
  SET file_id = 0.0
  SELECT INTO "nl:"
   FROM interface_file i
   WHERE i.description=file_passed_in
   DETAIL
    file_id = i.interface_file_id
   WITH nocounter
  ;end select
  CALL echo(build("the interface file id is : ",file_id))
 ELSE
  SET file_passed_in = outputlist->ol_frecs[rptrun].ol_file_desc
  SET file_id = outputlist->ol_frecs[rptrun].ol_file_id
  CALL echo(build("the interface file id is : ",file_id))
 ENDIF
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
 SET current_run_date = cnvtdatetime(concat(format(run_dt,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 CALL echo(build("current run date is :  ",format(current_run_date,"dd mmm yyyy hh:mm:ss;;d")))
 IF (((r_mode="DAY") OR (r_mode="OOPS")) )
  SELECT INTO "nl:"
   FROM interface_file i
   WHERE i.interface_file_id=file_id
    AND i.realtime_ind=false
    AND i.hl7_ind=true
   WITH nocounter
  ;end select
  IF (curqual=0)
   GO TO end_program
  ENDIF
  SELECT INTO "nl:"
   FROM interface_charge c
   WHERE c.interface_file_id=file_id
    AND c.active_ind=1
    AND c.process_flg=999
    AND c.posted_dt_tm=cnvtdatetime(current_run_date)
   WITH forupdate(c)
  ;end select
  UPDATE  FROM interface_charge ic
   SET ic.process_flg = 0
   WHERE ic.active_ind=1
    AND ic.process_flg=999
    AND ic.posted_dt_tm=cnvtdatetime(current_run_date)
  ;end update
 ENDIF
 WHILE (done=0)
   SET num_runs = (num_runs+ 1)
   SET stat = initrec(charges)
   SET hl7_cnt = 0
   SELECT
    IF (r_mode="DAY")
     WHERE c.interface_file_id=file_id
      AND c.active_ind=1
      AND c.process_flg=0
      AND c.posted_dt_tm=cnvtdatetime(current_run_date)
    ELSEIF (r_mode="OOPS")
     WHERE c.interface_file_id=file_id
      AND c.active_ind=1
      AND ((c.process_flg=0
      AND c.beg_effective_dt_tm <= cnvtdatetime(current_run_date)) OR (c.process_flg=0
      AND c.posted_dt_tm=cnvtdatetime(current_run_date)))
    ELSE
     WHERE c.interface_file_id=file_id
      AND c.active_ind=1
      AND c.process_flg=0
      AND c.beg_effective_dt_tm <= cnvtdatetime(current_run_date)
    ENDIF
    INTO "nl:"
    c.seq
    FROM interface_charge c
    ORDER BY c.encntr_id, c.fin_nbr, c.interface_charge_id
    DETAIL
     hl7_cnt = (hl7_cnt+ 1), stat = alterlist(charges->interface_charge,hl7_cnt), charges->
     interface_charge[hl7_cnt].interface_charge_id = c.interface_charge_id,
     charges->interface_charge[hl7_cnt].order_dept = c.order_dept, charges->interface_charge[hl7_cnt]
     .interface_file_id = c.interface_file_id, charges->interface_charge[hl7_cnt].charge_item_id = c
     .charge_item_id,
     charges->interface_charge[hl7_cnt].batch_num = c.batch_num, charges->interface_charge[hl7_cnt].
     bill_code1 = c.bill_code1, charges->interface_charge[hl7_cnt].bill_code1_desc = c
     .bill_code1_desc,
     charges->interface_charge[hl7_cnt].bill_code2 = c.bill_code2, charges->interface_charge[hl7_cnt]
     .bill_code2_desc = c.bill_code2_desc, charges->interface_charge[hl7_cnt].bill_code3 = c
     .bill_code3,
     charges->interface_charge[hl7_cnt].bill_code3_desc = c.bill_code3_desc, charges->
     interface_charge[hl7_cnt].prim_cdm = c.prim_cdm, charges->interface_charge[hl7_cnt].prim_cpt = c
     .prim_cpt,
     charges->interface_charge[hl7_cnt].diag_code1 = c.diag_code1, charges->interface_charge[hl7_cnt]
     .diag_code2 = c.diag_code2, charges->interface_charge[hl7_cnt].diag_code3 = c.diag_code3,
     charges->interface_charge[hl7_cnt].person_name = c.person_name, charges->interface_charge[
     hl7_cnt].person_id = c.person_id, charges->interface_charge[hl7_cnt].encntr_id = c.encntr_id,
     charges->interface_charge[hl7_cnt].fin_nbr = c.fin_nbr, charges->interface_charge[hl7_cnt].
     med_nbr = c.med_nbr, charges->interface_charge[hl7_cnt].service_dt_tm = c.service_dt_tm,
     charges->interface_charge[hl7_cnt].section_cd = c.section_cd, charges->interface_charge[hl7_cnt]
     .encntr_type_cd = c.encntr_type_cd, charges->interface_charge[hl7_cnt].payor_id = c.payor_id,
     charges->interface_charge[hl7_cnt].quantity = c.quantity, charges->interface_charge[hl7_cnt].
     price = c.price, charges->interface_charge[hl7_cnt].net_ext_price = c.net_ext_price,
     charges->interface_charge[hl7_cnt].organization_id = c.organization_id, charges->
     interface_charge[hl7_cnt].institution_cd = c.institution_cd, charges->interface_charge[hl7_cnt].
     department_cd = c.department_cd,
     charges->interface_charge[hl7_cnt].subsection_cd = c.subsection_cd, charges->interface_charge[
     hl7_cnt].level5_cd = c.level5_cd, charges->interface_charge[hl7_cnt].facility_cd = c.facility_cd,
     charges->interface_charge[hl7_cnt].building_cd = c.building_cd, charges->interface_charge[
     hl7_cnt].nurse_unit_cd = c.nurse_unit_cd, charges->interface_charge[hl7_cnt].room_cd = c.room_cd,
     charges->interface_charge[hl7_cnt].bed_cd = c.bed_cd, charges->interface_charge[hl7_cnt].
     referring_phys_id = c.referring_phys_id, charges->interface_charge[hl7_cnt].ord_phys_id = c
     .ord_phys_id,
     charges->interface_charge[hl7_cnt].ord_doc_nbr = c.ord_doc_nbr, charges->interface_charge[
     hl7_cnt].adm_phys_id = c.adm_phys_id, charges->interface_charge[hl7_cnt].attending_phys_id = c
     .attending_phys_id,
     charges->interface_charge[hl7_cnt].additional_encntr_phys1_id = c.additional_encntr_phys1_id,
     charges->interface_charge[hl7_cnt].additional_encntr_phys2_id = c.additional_encntr_phys2_id,
     charges->interface_charge[hl7_cnt].additional_encntr_phys3_id = c.additional_encntr_phys3_id,
     charges->interface_charge[hl7_cnt].charge_type_cd = c.charge_type_cd, charges->interface_charge[
     hl7_cnt].updt_cnt = c.updt_cnt, charges->interface_charge[hl7_cnt].updt_dt_tm = c.updt_dt_tm,
     charges->interface_charge[hl7_cnt].updt_id = c.updt_id, charges->interface_charge[hl7_cnt].
     updt_task = c.updt_task, charges->interface_charge[hl7_cnt].updt_applctx = c.updt_applctx,
     charges->interface_charge[hl7_cnt].active_ind = c.active_ind, charges->interface_charge[hl7_cnt]
     .active_status_cd = c.active_status_cd, charges->interface_charge[hl7_cnt].
     active_status_prsnl_id = c.active_status_prsnl_id,
     charges->interface_charge[hl7_cnt].active_status_dt_tm = c.active_status_dt_tm, charges->
     interface_charge[hl7_cnt].beg_effective_dt_tm = c.beg_effective_dt_tm, charges->
     interface_charge[hl7_cnt].end_effective_dt_tm = c.end_effective_dt_tm,
     charges->interface_charge[hl7_cnt].abn_status_cd = c.abn_status_cd, charges->interface_charge[
     hl7_cnt].activity_type_cd = c.activity_type_cd, charges->interface_charge[hl7_cnt].admit_type_cd
      = c.admit_type_cd,
     charges->interface_charge[hl7_cnt].bill_code_more_ind = c.bill_code_more_ind, charges->
     interface_charge[hl7_cnt].bill_code_type_cdf = c.bill_code_type_cdf, charges->interface_charge[
     hl7_cnt].code_modifier1_cd = c.code_modifier1_cd,
     charges->interface_charge[hl7_cnt].code_modifier2_cd = c.code_modifier2_cd, charges->
     interface_charge[hl7_cnt].code_modifier3_cd = c.code_modifier3_cd, charges->interface_charge[
     hl7_cnt].code_modifier_more_ind = c.code_modifier_more_ind,
     charges->interface_charge[hl7_cnt].cost_center_cd = c.cost_center_cd, charges->interface_charge[
     hl7_cnt].diag_desc1 = c.diag_desc1, charges->interface_charge[hl7_cnt].diag_desc2 = c.diag_desc2,
     charges->interface_charge[hl7_cnt].diag_desc3 = c.diag_desc3, charges->interface_charge[hl7_cnt]
     .diag_more_ind = c.diag_more_ind, charges->interface_charge[hl7_cnt].discount_amount = c
     .discount_amount,
     charges->interface_charge[hl7_cnt].fin_nbr_type_flg = c.fin_nbr_type_flg, charges->
     interface_charge[hl7_cnt].gross_price = c.gross_price, charges->interface_charge[hl7_cnt].
     icd9_proc_more_ind = c.icd9_proc_more_ind,
     charges->interface_charge[hl7_cnt].manual_ind = c.manual_ind, charges->interface_charge[hl7_cnt]
     .med_service_cd = c.med_service_cd, charges->interface_charge[hl7_cnt].order_nbr = c.order_nbr,
     charges->interface_charge[hl7_cnt].override_desc = c.override_desc, charges->interface_charge[
     hl7_cnt].perf_loc_cd = c.perf_loc_cd, charges->interface_charge[hl7_cnt].perf_phys_id = c
     .perf_phys_id,
     charges->interface_charge[hl7_cnt].posted_dt_tm = c.posted_dt_tm, charges->interface_charge[
     hl7_cnt].prim_cdm_desc = c.prim_cdm_desc, charges->interface_charge[hl7_cnt].prim_cpt_desc = c
     .prim_cpt_desc,
     charges->interface_charge[hl7_cnt].prim_icd9_proc = c.prim_icd9_proc, charges->interface_charge[
     hl7_cnt].prim_icd9_proc_desc = c.prim_icd9_proc_desc, charges->interface_charge[hl7_cnt].
     process_flg = c.process_flg,
     charges->interface_charge[hl7_cnt].user_def_ind = c.user_def_ind, charges->interface_charge_qual
      = hl7_cnt
    WITH forupdate(c), nocounter, maxqual(c,value(max_num_rows))
   ;end select
   IF (curqual > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(charges->interface_charge,5))),
      charge_mod cm
     PLAN (d1)
      JOIN (cm
      WHERE (cm.charge_item_id=charges->interface_charge[d1.seq].charge_item_id)
       AND cm.charge_mod_type_cd=13019_billcode_cd
       AND cm.nomen_id > 0.0
       AND ((cm.active_ind+ 0)=true))
     ORDER BY cm.charge_item_id, cm.field1_id, cm.field2_id
     HEAD cm.charge_item_id
      diagcnt = 0
     DETAIL
      IF (uar_get_code_meaning(cm.field1_id)="PROCCODE")
       IF (cm.field2_id=1)
        charges->interface_charge[d1.seq].prim_icd9_proc_nomen_id = cm.nomen_id
       ENDIF
       IF (trim(charges->interface_charge[d1.seq].bill_code1) != "")
        CASE (cm.field2_id)
         OF 2:
          charges->interface_charge[d1.seq].bill_code1_nomen_id = cm.nomen_id
         OF 3:
          charges->interface_charge[d1.seq].bill_code2_nomen_id = cm.nomen_id
         OF 4:
          charges->interface_charge[d1.seq].bill_code3_nomen_id = cm.nomen_id
        ENDCASE
       ENDIF
      ELSEIF (uar_get_code_meaning(cm.field1_id)="ICD9")
       diagcnt = (diagcnt+ 1), stat = alterlist(charges->interface_charge[d1.seq].icd_diag_info,
        diagcnt), charges->interface_charge[d1.seq].icd_diag_info[diagcnt].nomen_id = cm.nomen_id
      ENDIF
     WITH nocounter
    ;end select
    SET found_some = 1
    SET cnt_seq = (cnt_seq+ 1)
    IF (hl7_cnt < max_num_rows)
     CALL echo("*********************")
     CALL echo("****  Last Time  ****")
     CALL echo("*********************")
     SET done = 1
    ENDIF
    SET grand_total = (grand_total+ hl7_cnt)
    SET reply->status_data.status = "S"
    CALL echo(build("charge qual is : ",charges->interface_charge_qual))
    CALL echo(build("header_send: ",header_sent))
    CALL echo("----before while---")
    IF (header_sent=0)
     IF (init_srv_stuff(0)=0)
      CALL cleanup_srv_stuff(0)
      GO TO end_program
     ENDIF
     SET hmsgstruct = uar_srvgetstruct(hreq,"message")
     IF (hmsgstruct)
      SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"cqminfo")
      IF (hcqmstruct)
       SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
       SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias",nullterm("CS_BATCH_CHARGE"))
       SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(cnvtstring(file_id,17)))
       SET recdate->datetime = cnvtdatetime(current_run_date)
       SET stat = uar_srvsetdate2(hcqmstruct,"contribdttm",recdate)
       SET stat = uar_srvsetlong(hcqmstruct,"priority",99)
       SET stat = uar_srvsetstring(hcqmstruct,"class",nullterm("CHARGE"))
       SET stat = uar_srvsetstring(hcqmstruct,"type",nullterm("FT1"))
       SET stat = uar_srvsetstring(hcqmstruct,"subtype",nullterm("BEGIN"))
       SET stat = uar_srvsetstring(hcqmstruct,"subtype_detail",nullterm("*"))
       SET stat = uar_srvsetlong(hcqmstruct,"debug_ind",0)
       SET stat = uar_srvsetlong(hcqmstruct,"verbosity_flag",1)
      ELSE
       CALL echo("FAILURE hCqmStruct")
      ENDIF
     ELSE
      CALL echo("FAILURE hMqmStruct")
     ENDIF
     IF (textlen(trim(strbinding)) > 0)
      SET srvstat = uar_srvexecuteas(hcqmmsg,hreq,hrep,nullterm(strbinding))
     ELSE
      SET srvstat = uar_srvexecute(hcqmmsg,hreq,hrep)
     ENDIF
     CALL cleanup_srv_stuff(0)
     CASE (srvstat)
      OF 0:
       CALL echo("Successful Srv Execute BEGIN")
       SET stat = alterlist(srvrec->qual,0)
      OF 1:
       CALL echo("Srv Execute failed - Communication Error -")
       CALL echo("FSI Server may be down - BEGIN")
       SET reply->status_data.status = "F"
       GO TO end_program
      OF 2:
       CALL echo("SrvSelectMessage failed -- May need to perform CCLSECLOGIN")
       SET reply->status_data.status = "F"
       GO TO end_program
      OF 3:
       CALL echo("Failed to allocate either the Request or Reply Handle")
       SET reply->status_data.status = "F"
       GO TO end_program
     ENDCASE
     IF (init_srv_stuff(0)=0)
      CALL cleanup_srv_stuff(0)
      GO TO end_program
     ENDIF
     SET hmsgstruct = uar_srvgetstruct(hreq,"message")
     IF (hmsgstruct)
      SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"cqminfo")
      IF (hcqmstruct)
       SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
       SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias",nullterm("CS_BATCH_CHARGE"))
       SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(cnvtstring(file_id,17)))
       SET recdate->datetime = cnvtdatetime(current_run_date)
       SET stat = uar_srvsetdate2(hcqmstruct,"contribdttm",recdate)
       SET stat = uar_srvsetlong(hcqmstruct,"priority",99)
       SET stat = uar_srvsetstring(hcqmstruct,"class",nullterm("CHARGE"))
       SET stat = uar_srvsetstring(hcqmstruct,"type",nullterm("FT1"))
       SET stat = uar_srvsetstring(hcqmstruct,"subtype",nullterm("HEADER"))
       SET stat = uar_srvsetstring(hcqmstruct,"subtype_detail",nullterm("*"))
       SET stat = uar_srvsetlong(hcqmstruct,"debug_ind",0)
       SET stat = uar_srvsetlong(hcqmstruct,"verbosity_flag",1)
      ELSE
       CALL echo("FAILURE hCqmStruct")
      ENDIF
     ELSE
      CALL echo("FAILURE hMsgStruct")
     ENDIF
     IF (textlen(trim(strbinding)) > 0)
      SET srvstat = uar_srvexecuteas(hcqmmsg,hreq,hrep,nullterm(strbinding))
     ELSE
      SET srvstat = uar_srvexecute(hcqmmsg,hreq,hrep)
     ENDIF
     CALL cleanup_srv_stuff(0)
     CASE (srvstat)
      OF 0:
       CALL echo("Successful Srv Execute HEADER ")
       SET header_sent = 1
       CALL echo(build("seting up the header to 1 - header_sent: ",header_sent))
       SET stat = alterlist(srvrec->qual,0)
      OF 1:
       CALL echo("Srv Execute failed - Communication Error -")
       CALL echo("FSI Server may be down - HEADER")
       SET reply->status_data.status = "F"
       GO TO end_program
      OF 2:
       CALL echo("SrvSelectMessage failed -- May need to perfrom CCLSECLOGIN")
       SET reply->status_data.status = "F"
       GO TO end_program
      OF 3:
       CALL echo("Failed to allocate either the Request or Reply Handle")
       SET reply->status_data.status = "F"
       GO TO end_program
     ENDCASE
    ENDIF
    SET loop_count = 1
    SET hold_encntr_id = 0.0
    SET encntr_id = 0.0
    WHILE ((loop_count <= charges->interface_charge_qual))
      SET encntr_id = charges->interface_charge[loop_count].encntr_id
      SET hold_encntr_id = encntr_id
      SET fin_nbr = charges->interface_charge[loop_count].fin_nbr
      SET hold_fin_nbr = fin_nbr
      SET charge_count = 1
      IF (init_srv_stuff(0)=0)
       CALL cleanup_srv_stuff(0)
       GO TO end_program
      ENDIF
      SET hmsgstruct = uar_srvgetstruct(hreq,"message")
      IF (hmsgstruct)
       SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"cqminfo")
       IF (hcqmstruct)
        SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
        SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias",nullterm("CS_BATCH_CHARGE"))
        SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(concat("E",trim(cnvtstring(
             encntr_id,17)))))
        SET recdate->datetime = cnvtdatetime(current_run_date)
        SET stat = uar_srvsetdate2(hcqmstruct,"contribdttm",recdate)
        SET stat = uar_srvsetlong(hcqmstruct,"priority",99)
        SET stat = uar_srvsetstring(hcqmstruct,"class",nullterm("CHARGE"))
        SET stat = uar_srvsetstring(hcqmstruct,"type",nullterm("FT1"))
        SET stat = uar_srvsetstring(hcqmstruct,"subtype",nullterm("DETAIL"))
        SET stat = uar_srvsetstring(hcqmstruct,"subtype_detail",nullterm("*"))
        SET stat = uar_srvsetlong(hcqmstruct,"debug_ind",0)
        SET stat = uar_srvsetlong(hcqmstruct,"verbosity_flag",1)
        SET htrigitem = uar_srvgetstruct(hmsgstruct,"TRIGInfo")
        IF (htrigitem)
         WHILE (hold_encntr_id=encntr_id
          AND hold_fin_nbr=fin_nbr
          AND charge_count <= max_ft1)
           SET stat = alterlist(rqin->message.triginfo.charge_info,charge_count)
           SET rqin->message.triginfo.charge_info[charge_count].interface_charge_id = charges->
           interface_charge[loop_count].interface_charge_id
           SET hchargeitem = uar_srvadditem(htrigitem,"charge_info")
           IF (hchargeitem)
            SET stat = uar_srvsetdouble(hchargeitem,"interface_charge_id",charges->interface_charge[
             loop_count].interface_charge_id)
            SET stat = uar_srvsetlong(hchargeitem,"order_dept",charges->interface_charge[loop_count].
             order_dept)
            SET stat = uar_srvsetdouble(hchargeitem,"interface_file_id",charges->interface_charge[
             loop_count].interface_file_id)
            SET stat = uar_srvsetdouble(hchargeitem,"charge_item_id",charges->interface_charge[
             loop_count].charge_item_id)
            SET stat = uar_srvsetdouble(hchargeitem,"batch_num",charges->interface_charge[loop_count]
             .batch_num)
            SET csops_request2->batch_num = charges->interface_charge[loop_count].batch_num
            SET stat = uar_srvsetstring(hchargeitem,"bill_code1",nullterm(charges->interface_charge[
              loop_count].bill_code1))
            SET stat = uar_srvsetstring(hchargeitem,"bill_code1_desc",nullterm(charges->
              interface_charge[loop_count].bill_code1_desc))
            SET stat = uar_srvsetstring(hchargeitem,"bill_code2",nullterm(charges->interface_charge[
              loop_count].bill_code2))
            SET stat = uar_srvsetstring(hchargeitem,"bill_code2_desc",nullterm(charges->
              interface_charge[loop_count].bill_code2_desc))
            SET stat = uar_srvsetstring(hchargeitem,"bill_code3",nullterm(charges->interface_charge[
              loop_count].bill_code3))
            SET stat = uar_srvsetstring(hchargeitem,"bill_code3_desc",nullterm(charges->
              interface_charge[loop_count].bill_code3_desc))
            SET stat = uar_srvsetstring(hchargeitem,"prim_cpt",nullterm(charges->interface_charge[
              loop_count].prim_cpt))
            SET stat = uar_srvsetstring(hchargeitem,"prim_cdm",nullterm(charges->interface_charge[
              loop_count].prim_cdm))
            SET stat = uar_srvsetstring(hchargeitem,"diag_code1",nullterm(charges->interface_charge[
              loop_count].diag_code1))
            SET stat = uar_srvsetstring(hchargeitem,"diag_code2",nullterm(charges->interface_charge[
              loop_count].diag_code2))
            SET stat = uar_srvsetstring(hchargeitem,"diag_code3",nullterm(charges->interface_charge[
              loop_count].diag_code3))
            SET stat = uar_srvsetstring(hchargeitem,"person_name",nullterm(charges->interface_charge[
              loop_count].person_name))
            SET stat = uar_srvsetdouble(hchargeitem,"person_id",charges->interface_charge[loop_count]
             .person_id)
            SET stat = uar_srvsetdouble(hchargeitem,"encntr_id",charges->interface_charge[loop_count]
             .encntr_id)
            SET stat = uar_srvsetstring(hchargeitem,"fin_nbr",nullterm(charges->interface_charge[
              loop_count].fin_nbr))
            SET stat = uar_srvsetstring(hchargeitem,"med_nbr",nullterm(charges->interface_charge[
              loop_count].med_nbr))
            SET recdate->datetime = charges->interface_charge[loop_count].service_dt_tm
            SET stat = uar_srvsetdate2(hchargeitem,"service_dt_tm",recdate)
            SET stat = uar_srvsetdouble(hchargeitem,"section_cd",charges->interface_charge[loop_count
             ].section_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"encntr_type_cd",charges->interface_charge[
             loop_count].encntr_type_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"payor_id",charges->interface_charge[loop_count].
             payor_id)
            SET stat = uar_srvsetdouble(hchargeitem,"quantity",charges->interface_charge[loop_count].
             quantity)
            SET stat = uar_srvsetdouble(hchargeitem,"price",charges->interface_charge[loop_count].
             price)
            SET stat = uar_srvsetdouble(hchargeitem,"net_ext_price",charges->interface_charge[
             loop_count].net_ext_price)
            SET stat = uar_srvsetdouble(hchargeitem,"organization_id",charges->interface_charge[
             loop_count].organization_id)
            SET stat = uar_srvsetdouble(hchargeitem,"institution_cd",charges->interface_charge[
             loop_count].institution_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"department_cd",charges->interface_charge[
             loop_count].department_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"subsection_cd",charges->interface_charge[
             loop_count].subsection_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"level5_cd",charges->interface_charge[loop_count]
             .level5_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"facility_cd",charges->interface_charge[
             loop_count].facility_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"building_cd",charges->interface_charge[
             loop_count].building_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"nurse_unit_cd",charges->interface_charge[
             loop_count].nurse_unit_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"room_cd",charges->interface_charge[loop_count].
             room_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"bed_cd",charges->interface_charge[loop_count].
             bed_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"referring_phys_id",charges->interface_charge[
             loop_count].referring_phys_id)
            SET stat = uar_srvsetdouble(hchargeitem,"ord_phys_id",charges->interface_charge[
             loop_count].ord_phys_id)
            SET stat = uar_srvsetstring(hchargeitem,"ord_doc_nbr",nullterm(charges->interface_charge[
              loop_count].ord_doc_nbr))
            SET stat = uar_srvsetdouble(hchargeitem,"adm_phys_id",charges->interface_charge[
             loop_count].adm_phys_id)
            SET stat = uar_srvsetdouble(hchargeitem,"attending_phys_id",charges->interface_charge[
             loop_count].attending_phys_id)
            SET stat = uar_srvsetdouble(hchargeitem,"additional_encntr_phys2_id",charges->
             interface_charge[loop_count].additional_encntr_phys2_id)
            SET stat = uar_srvsetdouble(hchargeitem,"additional_encntr_phys3_id",charges->
             interface_charge[loop_count].additional_encntr_phys3_id)
            SET stat = uar_srvsetdouble(hchargeitem,"charge_type_cd",charges->interface_charge[
             loop_count].charge_type_cd)
            SET stat = uar_srvsetlong(hchargeitem,"updt_cnt",charges->interface_charge[loop_count].
             updt_cnt)
            SET recdate->datetime = charges->interface_charge[loop_count].updt_dt_tm
            SET stat = uar_srvsetdate2(hchargeitem,"updt_dt_tm",recdate)
            SET stat = uar_srvsetdouble(hchargeitem,"updt_id",charges->interface_charge[loop_count].
             updt_id)
            SET stat = uar_srvsetlong(hchargeitem,"updt_task",charges->interface_charge[loop_count].
             updt_task)
            SET stat = uar_srvsetlong(hchargeitem,"updt_applctx",charges->interface_charge[loop_count
             ].updt_applctx)
            SET stat = uar_srvsetshort(hchargeitem,"active_ind",charges->interface_charge[loop_count]
             .active_ind)
            SET stat = uar_srvsetdouble(hchargeitem,"active_status_cd",charges->interface_charge[
             loop_count].active_status_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"active_status_prsnl_id",charges->
             interface_charge[loop_count].active_status_prsnl_id)
            SET recdate->datetime = charges->interface_charge[loop_count].active_status_dt_tm
            SET stat = uar_srvsetdate2(hchargeitem,"active_status_dt_tm",recdate)
            SET recdate->datetime = charges->interface_charge[loop_count].beg_effective_dt_tm
            SET stat = uar_srvsetdate2(hchargeitem,"beg_effective_dt_tm",recdate)
            SET recdate->datetime = charges->interface_charge[loop_count].end_effective_dt_tm
            SET stat = uar_srvsetdate2(hchargeitem,"end_effective_dt_tm",recdate)
            SET stat = uar_srvsetdouble(hchargeitem,"abn_status_cd",charges->interface_charge[
             loop_count].abn_status_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"activity_type_cd",charges->interface_charge[
             loop_count].activity_type_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"admit_type_cd",charges->interface_charge[
             loop_count].admit_type_cd)
            SET stat = uar_srvsetshort(hchargeitem,"bill_code_more_ind",charges->interface_charge[
             loop_count].bill_code_more_ind)
            SET stat = uar_srvsetstring(hchargeitem,"bill_code_type_cdf",nullterm(charges->
              interface_charge[loop_count].bill_code_type_cdf))
            SET stat = uar_srvsetdouble(hchargeitem,"code_modifier1_cd",charges->interface_charge[
             loop_count].code_modifier1_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"code_modifier2_cd",charges->interface_charge[
             loop_count].code_modifier2_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"code_modifier3_cd",charges->interface_charge[
             loop_count].code_modifier3_cd)
            SET stat = uar_srvsetshort(hchargeitem,"code_modifier_more_ind",charges->
             interface_charge[loop_count].code_modifier_more_ind)
            SET stat = uar_srvsetdouble(hchargeitem,"cost_center_cd",charges->interface_charge[
             loop_count].cost_center_cd)
            SET stat = uar_srvsetstring(hchargeitem,"diag_desc1",nullterm(charges->interface_charge[
              loop_count].diag_desc1))
            SET stat = uar_srvsetstring(hchargeitem,"diag_desc2",nullterm(charges->interface_charge[
              loop_count].diag_desc2))
            SET stat = uar_srvsetstring(hchargeitem,"diag_desc3",nullterm(charges->interface_charge[
              loop_count].diag_desc3))
            SET stat = uar_srvsetshort(hchargeitem,"diag_more_ind",charges->interface_charge[
             loop_count].diag_more_ind)
            SET stat = uar_srvsetdouble(hchargeitem,"discount_amount",charges->interface_charge[
             loop_count].discount_amount)
            SET stat = uar_srvsetlong(hchargeitem,"fin_nbr_type_flg",charges->interface_charge[
             loop_count].fin_nbr_type_flg)
            SET stat = uar_srvsetdouble(hchargeitem,"gross_price",charges->interface_charge[
             loop_count].gross_price)
            SET stat = uar_srvsetshort(hchargeitem,"icd9_proc_more_ind",charges->interface_charge[
             loop_count].icd9_proc_more_ind)
            SET stat = uar_srvsetshort(hchargeitem,"manual_ind",charges->interface_charge[loop_count]
             .manual_ind)
            SET stat = uar_srvsetdouble(hchargeitem,"med_service_cd",charges->interface_charge[
             loop_count].med_service_cd)
            SET stat = uar_srvsetstring(hchargeitem,"order_nbr",nullterm(charges->interface_charge[
              loop_count].order_nbr))
            SET stat = uar_srvsetstring(hchargeitem,"override_desc",nullterm(charges->
              interface_charge[loop_count].override_desc))
            SET stat = uar_srvsetdouble(hchargeitem,"perf_loc_cd",charges->interface_charge[
             loop_count].perf_loc_cd)
            SET stat = uar_srvsetdouble(hchargeitem,"perf_phys_id",charges->interface_charge[
             loop_count].perf_phys_id)
            SET recdate->datetime = charges->interface_charge[loop_count].posted_dt_tm
            SET stat = uar_srvsetdate2(hchargeitem,"posted_dt_tm",recdate)
            SET stat = uar_srvsetstring(hchargeitem,"prim_cdm_desc",nullterm(charges->
              interface_charge[loop_count].prim_cdm_desc))
            SET stat = uar_srvsetstring(hchargeitem,"prim_cpt_desc",nullterm(charges->
              interface_charge[loop_count].prim_cpt_desc))
            SET stat = uar_srvsetstring(hchargeitem,"prim_icd9_proc",nullterm(charges->
              interface_charge[loop_count].prim_icd9_proc))
            SET stat = uar_srvsetstring(hchargeitem,"prim_icd9_proc_desc",nullterm(charges->
              interface_charge[loop_count].prim_icd9_proc_desc))
            SET stat = uar_srvsetlong(hchargeitem,"process_flg",charges->interface_charge[loop_count]
             .process_flg)
            SET stat = uar_srvsetshort(hchargeitem,"user_def_ind",charges->interface_charge[
             loop_count].user_def_ind)
            IF (uar_srvfieldexists(hchargeitem,"prim_icd9_proc_nomen_id")=true)
             SET stat = uar_srvsetdouble(hchargeitem,"prim_icd9_proc_nomen_id",charges->
              interface_charge[loop_count].prim_icd9_proc_nomen_id)
            ENDIF
            IF (uar_srvfieldexists(hchargeitem,"bill_code1_nomen_id")=true)
             SET stat = uar_srvsetdouble(hchargeitem,"bill_code1_nomen_id",charges->interface_charge[
              loop_count].bill_code1_nomen_id)
            ENDIF
            IF (uar_srvfieldexists(hchargeitem,"bill_code2_nomen_id")=true)
             SET stat = uar_srvsetdouble(hchargeitem,"bill_code2_nomen_id",charges->interface_charge[
              loop_count].bill_code2_nomen_id)
            ENDIF
            IF (uar_srvfieldexists(hchargeitem,"bill_code3_nomen_id")=true)
             SET stat = uar_srvsetdouble(hchargeitem,"bill_code3_nomen_id",charges->interface_charge[
              loop_count].bill_code3_nomen_id)
            ENDIF
            IF (uar_srvfieldexists(hchargeitem,"icd_diag_info")=true)
             FOR (icddiagcnt = 1 TO size(charges->interface_charge[loop_count].icd_diag_info,5))
              SET hdiagitem = uar_srvadditem(hchargeitem,"icd_diag_info")
              IF (hdiagitem)
               SET stat = uar_srvsetdouble(hdiagitem,"nomen_id",charges->interface_charge[loop_count]
                .icd_diag_info[icddiagcnt].nomen_id)
              ENDIF
             ENDFOR
            ENDIF
           ELSE
            CALL echo("FAILURE hChargeItem")
           ENDIF
           IF ((charges->interface_charge[loop_count].charge_type_cd=credit_code))
            SET total_qty_credit = (total_qty_credit+ charges->interface_charge[loop_count].quantity)
            SET total_amt_credit = (total_amt_credit+ charges->interface_charge[loop_count].price)
            SET total_cnt_credit = loop_count
           ELSEIF ((charges->interface_charge[loop_count].charge_type_cd=13028_debit_cd))
            SET total_qty_debit = (total_qty_debit+ charges->interface_charge[loop_count].quantity)
            SET total_amt_debit = (total_amt_debit+ charges->interface_charge[loop_count].price)
            SET total_cnt_debit = loop_count
           ENDIF
           SET charge_count = (charge_count+ 1)
           SET loop_count = (loop_count+ 1)
           IF ((loop_count=(charges->interface_charge_qual+ 1)))
            SET encntr_id = 0.0
            SET fin_nbr = " "
            SET loop_count = (loop_count+ 1)
           ELSE
            SET encntr_id = charges->interface_charge[loop_count].encntr_id
            SET fin_nbr = charges->interface_charge[loop_count].fin_nbr
           ENDIF
         ENDWHILE
        ELSE
         CALL echo("FAILURE hTrigItem")
        ENDIF
       ELSE
        CALL echo("FAILURE hCqmStruct")
       ENDIF
      ELSE
       CALL echo("FAILURE hMsgStruct")
      ENDIF
      SET total = size(rqin->message.triginfo.charge_info,5)
      FOR (i = 1 TO total)
       SELECT INTO "nl:"
        c.seq
        FROM interface_charge c
        WHERE (c.interface_charge_id=rqin->message.triginfo.charge_info[i].interface_charge_id)
        WITH forupdate(c)
       ;end select
       IF (curqual > 0)
        CALL echo(build("Aquired Lock for interface_charge_id: ",rqin->message.triginfo.charge_info[i
          ].interface_charge_id))
        UPDATE  FROM interface_charge c
         SET c.process_flg = 999, c.updt_cnt = (c.updt_cnt+ 1), c.updt_id = reqinfo->updt_id,
          c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm =
          cnvtdatetime(curdate,curtime3)
         PLAN (c
          WHERE (c.interface_charge_id=rqin->message.triginfo.charge_info[i].interface_charge_id))
         WITH nocounter
        ;end update
        IF (curqual <= 0)
         CALL echo("Error while updating the row")
         SET reply->status_data.status = "F"
         ROLLBACK
         CALL cleanup_srv_stuff(0)
         GO TO end_program
        ENDIF
       ELSE
        CALL echo("Error while aquiring lock on rows")
        SET reply->status_data.status = "F"
        ROLLBACK
        CALL cleanup_srv_stuff(0)
        GO TO end_program
       ENDIF
      ENDFOR
      IF (textlen(trim(strbinding)) > 0)
       SET srvstat = uar_srvexecuteas(hcqmmsg,hreq,hrep,nullterm(strbinding))
      ELSE
       SET srvstat = uar_srvexecute(hcqmmsg,hreq,hrep)
      ENDIF
      CALL cleanup_srv_stuff(0)
      CASE (srvstat)
       OF 0:
        CALL echo("Successful Srv Execute DETAIL ")
        SET stat = alterlist(srvrec->qual,0)
        CALL echo(build("processed charges for encntr: ",hold_encntr_id))
        SET reply->status_data.status = "S"
        COMMIT
        SET commit1_ind = 1
       OF 1:
        CALL echo("Srv Execute failed - Communication Error -")
        CALL echo("FSI Server may be down - DETAIL")
        SET reply->status_data.status = "F"
        ROLLBACK
        GO TO end_program
       OF 2:
        CALL echo("SrvSelectMessage failed -- May need to perfrom CCLSECLOGIN")
        SET reply->status_data.status = "F"
        ROLLBACK
        GO TO end_program
       OF 3:
        CALL echo("Failed to allocate either the Request or Reply Handle")
        SET reply->status_data.status = "F"
        ROLLBACK
        GO TO end_program
      ENDCASE
      IF (validate(needpause)=1)
       CALL echo("I am sleeping")
       CALL pause(15)
       CALL echo("I am awake")
      ENDIF
    ENDWHILE
    SET file_name = substring(1,30,concat("ccluserdir:hl7_",trim(cnvtlower(file_passed_in),3),"_",
      trim(cnvtstring(num_runs)),".dat"))
    CALL echo(build("the audit file is : ",file_name))
    SET equal_line = fillstring(130,"=")
    SET dash_line = fillstring(130,"-")
    SET line_35 = fillstring(35,"-")
    SET person_tot = 0.00
    SET person_cnt = 0
    SET encntr_tot = 0.00
    SET encntr_cnt = 0
    SET rpt_tot = 0.00
    SET rpt_cnt = 0
    SET charge_type = fillstring(40," ")
    CALL echo("printing audit file...")
    SELECT INTO value(file_name)
     person_id = charges->interface_charge[d1.seq].person_id, encntr_id = charges->interface_charge[
     d1.seq].encntr_id, service_dt_tm = charges->interface_charge[d1.seq].service_dt_tm,
     srv_date = format(charges->interface_charge[d1.seq].service_dt_tm,"mm/dd/yy;;d"), srv_time =
     format(charges->interface_charge[d1.seq].service_dt_tm,"hh:mm;;s"), prim_cdm_desc = substring(1,
      20,charges->interface_charge[d1.seq].prim_cdm_desc),
     run_date = format(current_run_date,"mm/dd/yy;;d"), run_time = format(curtime,"hh:mm;;m")
     FROM (dummyt d1  WITH seq = value(size(charges->interface_charge,5)))
     PLAN (d1)
     ORDER BY person_id, encntr_id, service_dt_tm
     HEAD REPORT
      col 47, "** BATCH CHARGE INTERFACE REPORT **", col 100,
      "Run Date: ", run_date, " ",
      run_time, row + 2
     HEAD PAGE
      col 120, "Page: ", curpage"##",
      row + 1, col 00, "Person Name",
      col 20, "Fin Nbr", col 35,
      "Med Nbr", col 50, "CPT",
      col 60, "CDM", col 75,
      "Description", col 92, "Service Date",
      col 112, "Qty", col 117,
      "Price", col 127, "Type",
      row + 1, col 00, equal_line,
      row + 2
     HEAD person_id
      IF (person_cnt != 0)
       col 00, dash_line, row + 2
      ENDIF
      col 00, charges->interface_charge[d1.seq].person_name, person_tot = 0.00,
      person_cnt = 0
     HEAD encntr_id
      IF (person_cnt != 0)
       row + 1
      ENDIF
      col 20, charges->interface_charge[d1.seq].fin_nbr, col 35,
      charges->interface_charge[d1.seq].med_nbr, encntr_tot = 0.00, encntr_cnt = 0
     DETAIL
      IF ((charges->interface_charge[d1.seq].charge_type_cd=credit_code))
       person_tot = (person_tot+ (abs(charges->interface_charge[d1.seq].net_ext_price) * - (1))),
       person_cnt = (person_cnt - charges->interface_charge[d1.seq].quantity), encntr_tot = (
       encntr_tot+ (abs(charges->interface_charge[d1.seq].net_ext_price) * - (1))),
       encntr_cnt = (encntr_cnt - charges->interface_charge[d1.seq].quantity), rpt_tot = (rpt_tot+ (
       abs(charges->interface_charge[d1.seq].net_ext_price) * - (1))), rpt_cnt = (rpt_cnt - charges->
       interface_charge[d1.seq].quantity)
      ELSEIF ((charges->interface_charge[d1.seq].charge_type_cd != nocharge_code))
       person_tot = (person_tot+ charges->interface_charge[d1.seq].net_ext_price), person_cnt = (
       person_cnt+ charges->interface_charge[d1.seq].quantity), encntr_tot = (encntr_tot+ charges->
       interface_charge[d1.seq].net_ext_price),
       encntr_cnt = (encntr_cnt+ charges->interface_charge[d1.seq].quantity), rpt_tot = (rpt_tot+
       charges->interface_charge[d1.seq].net_ext_price), rpt_cnt = (rpt_cnt+ charges->
       interface_charge[d1.seq].quantity)
      ENDIF
      col 50, charges->interface_charge[d1.seq].prim_cpt, col 60,
      charges->interface_charge[d1.seq].prim_cdm, col 75, prim_cdm_desc,
      col 92, srv_date, " ",
      srv_time, col 110, charges->interface_charge[d1.seq].quantity"###.##",
      col 115, charges->interface_charge[d1.seq].net_ext_price"########.##"
      IF ((charges->interface_charge[d1.seq].charge_type_cd=credit_code))
       col 128, "CR"
      ELSEIF ((charges->interface_charge[d1.seq].charge_type_cd=nocharge_code))
       col 128, "NC"
      ELSE
       col 128, "D"
      ENDIF
      row + 1
     FOOT  encntr_id
      col 96, line_35, row + 1,
      col 97, "Encounter Total: ", col 115,
      encntr_cnt"#####", col 120, encntr_tot"########.##",
      row + 1
     FOOT  person_id
      col 100, "Person Total: ", col 115,
      person_cnt"#####", col 120, person_tot"########.##",
      row + 2
     FOOT REPORT
      col 100, "Report Total: ", col 115,
      rpt_cnt"#####", col 120, rpt_tot"########.##",
      row + 1, col 96, line_35
     WITH nocounter
    ;end select
   ELSE
    SET done = 1
   ENDIF
 ENDWHILE
 IF (commit1_ind=1)
  SET csops_request2->job_status = reply->status_data.status
  SET csops_request2->seq = cnt_seq
  SET stat = alterlist(csops_request2->charges,1)
  SET csops_request2->charges[1].interface_file_id = file_id
  SET csops_request2->charges[1].charge_type_cd = credit_code
  SET csops_request2->charges[1].total_quantity = total_qty_credit
  SET csops_request2->charges[1].total_amount = total_amt_credit
  SET csops_request2->charges[1].raw_count = total_cnt_credit
  SET stat = alterlist(csops_request2->charges,2)
  SET csops_request2->charges[2].interface_file_id = file_id
  SET csops_request2->charges[2].charge_type_cd = 13028_debit_cd
  SET csops_request2->charges[2].total_quantity = total_qty_debit
  SET csops_request2->charges[2].total_amount = total_amt_debit
  SET csops_request2->charges[2].raw_count = total_cnt_debit
  SET csops_request2->end_dt_tm = cnvtdatetime(curdate,curtime)
  EXECUTE afc_add_csops_summ
 ENDIF
 IF (header_sent=1)
  IF (init_srv_stuff(0)=0)
   CALL cleanup_srv_stuff(0)
   GO TO end_program
  ENDIF
  SET hmsgstruct = uar_srvgetstruct(hreq,"message")
  IF (hmsgstruct)
   SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"cqminfo")
   IF (hcqmstruct)
    SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
    SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias",nullterm("CS_BATCH_CHARGE"))
    SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(concat(trim(cnvtstring(file_id,17
         )),"~",trim(cnvtstring(grand_total)))))
    SET recdate->datetime = cnvtdatetime(current_run_date)
    SET stat = uar_srvsetdate2(hcqmstruct,"contribdttm",recdate)
    SET stat = uar_srvsetlong(hcqmstruct,"priority",99)
    SET stat = uar_srvsetstring(hcqmstruct,"class",nullterm("CHARGE"))
    SET stat = uar_srvsetstring(hcqmstruct,"type",nullterm("FT1"))
    SET stat = uar_srvsetstring(hcqmstruct,"subtype",nullterm("TRAILER"))
    SET stat = uar_srvsetstring(hcqmstruct,"subtype_detail",nullterm("*"))
    SET stat = uar_srvsetlong(hcqmstruct,"debug_ind",0)
    SET stat = uar_srvsetlong(hcqmstruct,"verbosity_flag",1)
   ELSE
    CALL echo("FAILURE hCqmStruct")
   ENDIF
  ELSE
   CALL echo("FAILURE hMsgStruct")
  ENDIF
  IF (textlen(trim(strbinding)) > 0)
   SET srvstat = uar_srvexecuteas(hcqmmsg,hreq,hrep,nullterm(strbinding))
  ELSE
   SET srvstat = uar_srvexecute(hcqmmsg,hreq,hrep)
  ENDIF
  CALL cleanup_srv_stuff(0)
  CASE (srvstat)
   OF 0:
    CALL echo("Successful Srv Execute for TRAILER ")
    SET stat = alterlist(srvrec->qual,0)
   OF 1:
    CALL echo("Srv Execute failed - Communication Error -")
    CALL echo("FSI Server may be down - TRAILER")
    SET reply->status_data.status = "F"
    GO TO end_program
   OF 2:
    CALL echo("SrvSelectMessage failed -- May need to perfrom CCLSECLOGIN")
    SET reply->status_data.status = "F"
    GO TO end_program
   OF 3:
    CALL echo("Failed to allocate either the Request or Reply Handle")
    SET reply->status_data.status = "F"
    GO TO end_program
  ENDCASE
  IF (init_srv_stuff(0)=0)
   CALL cleanup_srv_stuff(0)
   GO TO end_program
  ENDIF
  SET hmsgstruct = uar_srvgetstruct(hreq,"message")
  IF (hmsgstruct)
   SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"cqminfo")
   IF (hcqmstruct)
    SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
    SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias",nullterm("CS_BATCH_CHARGE"))
    SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(concat(trim(cnvtstring(file_id,17
         )),"~",trim(cnvtstring(grand_total)))))
    SET recdate->datetime = cnvtdatetime(current_run_date)
    SET stat = uar_srvsetdate2(hcqmstruct,"contribdttm",recdate)
    SET stat = uar_srvsetlong(hcqmstruct,"priority",99)
    SET stat = uar_srvsetstring(hcqmstruct,"class",nullterm("CHARGE"))
    SET stat = uar_srvsetstring(hcqmstruct,"type",nullterm("FT1"))
    SET stat = uar_srvsetstring(hcqmstruct,"subtype",nullterm("END"))
    SET stat = uar_srvsetstring(hcqmstruct,"subtype_detail",nullterm("*"))
    SET stat = uar_srvsetlong(hcqmstruct,"debug_ind",0)
    SET stat = uar_srvsetlong(hcqmstruct,"verbosity_flag",1)
   ELSE
    CALL echo("FAILURE hCqmStruct")
   ENDIF
  ELSE
   CALL echo("FAILURE hMsgStruct")
  ENDIF
  IF (textlen(trim(strbinding)) > 0)
   SET srvstat = uar_srvexecuteas(hcqmmsg,hreq,hrep,nullterm(strbinding))
  ELSE
   SET srvstat = uar_srvexecute(hcqmmsg,hreq,hrep)
  ENDIF
  CALL cleanup_srv_stuff(0)
  CASE (srvstat)
   OF 0:
    CALL echo("Successful Srv Execute for END ")
    SET stat = alterlist(srvrec->qual,0)
   OF 1:
    CALL echo("Srv Execute failed - Communication Error -")
    CALL echo("FSI Server may be down - END")
    SET reply->status_data.status = "F"
    GO TO end_program
   OF 2:
    CALL echo("SrvSelectMessage failed -- May need to perfrom CCLSECLOGIN")
    SET reply->status_data.status = "F"
    GO TO end_program
   OF 3:
    CALL echo("Failed to allocate either the Request or Reply Handle")
    SET reply->status_data.status = "F"
    GO TO end_program
  ENDCASE
 ENDIF
 IF (found_some=0)
  SET reply->status_data.status = "Z"
  CALL echo("No charges qualified")
 ENDIF
 IF (srvstat)
  CALL cleanup_srv_stuff(0)
 ENDIF
 SET csops_request2->job_status = reply->status_data.status
 SET csops_request2->end_dt_tm = cnvtdatetime(curdate,curtime)
 IF (hreqtype != 0)
  CALL uar_srvdestroytype(hreqtype)
 ENDIF
 CALL uar_srvdestroymessage(hreqmsg)
 CALL uar_srvdestroymessage(hcqmmsg)
 SUBROUTINE init_srv_stuff(x)
   IF (hcqmmsg=0)
    SET hcqmmsg = uar_srvselectmessage(cqmmessageid)
    IF (hcqmmsg=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (hreqmsg=0)
    SET hreqmsg = uar_srvselectmessage(reqmessageid)
    IF (hreqmsg=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (hreqtype=0)
    SET hreqtype = uar_srvcreaterequesttype(hreqmsg)
    IF (hreqtype=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET hreq = uar_srvcreateinstance(hreqtype)
   IF (hreq=0)
    RETURN(0)
   ENDIF
   SET hrep = uar_srvcreatereply(hcqmmsg)
   IF (hrep=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE cleanup_srv_stuff(x)
  IF (hreq != 0)
   CALL uar_srvdestroyinstance(hreq)
  ENDIF
  IF (hrep != 0)
   CALL uar_srvdestroyinstance(hrep)
  ENDIF
 END ;Subroutine
#end_program
 IF ((reply->status_data.status="F"))
  SET csops_request2->end_dt_tm = cnvtdatetime(curdate,curtime)
  SET csops_request2->job_status = "F"
  EXECUTE afc_add_csops_summ
 ENDIF
END GO

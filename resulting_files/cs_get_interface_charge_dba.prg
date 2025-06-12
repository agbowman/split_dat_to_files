CREATE PROGRAM cs_get_interface_charge:dba
 IF (validate(request->charge_dt_tm,999)=999)
  RECORD request(
    1 charge_dt_tm = dq8
    1 interface_file_id = f8
    1 charge_id[*]
      2 charge_id = f8
  )
  SET request->charge_dt_tm = cnvtdatetime(curdate,curtime)
 ENDIF
 RECORD reply(
   1 interface_charge[*]
     2 interface_charge_id = f8
     2 order_dept = i4
     2 interface_file_id = f8
     2 charge_item_id = f8
     2 batch_num = i4
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
     2 quantity = i4
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
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_process TO 2999_process_exit
 GO TO 9999_end
#1000_initialize
 SET desc = fillstring(100," ")
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM interface_file i
  WHERE (i.interface_file_id=request->interface_file_id)
  DETAIL
   desc = i.description
  WITH nocounter
 ;end select
 CALL echo(build("the file desc in get_interface_charge is : ",desc))
 SET file_name = substring(1,30,concat("CCLUSERDIR:hl7_",trim(desc,3),".dat"))
#1999_initialize_exit
#2000_process
 IF ((request->interface_file_id > 0))
  SELECT INTO "nl:"
   c.seq
   FROM interface_charge c
   WHERE (c.interface_file_id=request->interface_file_id)
    AND c.active_ind=1
    AND c.process_flg=0
    AND c.beg_effective_dt_tm <= datetimeadd(cnvtdatetime(request->charge_dt_tm),1)
   ORDER BY c.interface_file_id, c.encntr_id, c.fin_nbr
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->interface_charge,cnt), reply->interface_charge[cnt].
    interface_charge_id = c.interface_charge_id,
    reply->interface_charge[cnt].order_dept = c.order_dept, reply->interface_charge[cnt].
    interface_file_id = c.interface_file_id, reply->interface_charge[cnt].charge_item_id = c
    .charge_item_id,
    reply->interface_charge[cnt].batch_num = c.batch_num, reply->interface_charge[cnt].bill_code1 = c
    .bill_code1, reply->interface_charge[cnt].bill_code1_desc = c.bill_code1_desc,
    reply->interface_charge[cnt].bill_code2 = c.bill_code2, reply->interface_charge[cnt].
    bill_code2_desc = c.bill_code2_desc, reply->interface_charge[cnt].bill_code3 = c.bill_code3,
    reply->interface_charge[cnt].bill_code3_desc = c.bill_code3_desc, reply->interface_charge[cnt].
    prim_cdm = c.prim_cdm, reply->interface_charge[cnt].prim_cpt = c.prim_cpt,
    reply->interface_charge[cnt].diag_code1 = c.diag_code1, reply->interface_charge[cnt].diag_code2
     = c.diag_code2, reply->interface_charge[cnt].diag_code3 = c.diag_code3,
    reply->interface_charge[cnt].person_name = c.person_name, reply->interface_charge[cnt].person_id
     = c.person_id, reply->interface_charge[cnt].encntr_id = c.encntr_id,
    reply->interface_charge[cnt].fin_nbr = c.fin_nbr, reply->interface_charge[cnt].med_nbr = c
    .med_nbr, reply->interface_charge[cnt].service_dt_tm = c.service_dt_tm,
    reply->interface_charge[cnt].section_cd = c.section_cd, reply->interface_charge[cnt].
    encntr_type_cd = c.encntr_type_cd, reply->interface_charge[cnt].payor_id = c.payor_id,
    reply->interface_charge[cnt].quantity = c.quantity, reply->interface_charge[cnt].price = c.price,
    reply->interface_charge[cnt].net_ext_price = c.net_ext_price,
    reply->interface_charge[cnt].organization_id = c.organization_id, reply->interface_charge[cnt].
    institution_cd = c.institution_cd, reply->interface_charge[cnt].department_cd = c.department_cd,
    reply->interface_charge[cnt].subsection_cd = c.subsection_cd, reply->interface_charge[cnt].
    level5_cd = c.level5_cd, reply->interface_charge[cnt].facility_cd = c.facility_cd,
    reply->interface_charge[cnt].building_cd = c.building_cd, reply->interface_charge[cnt].
    nurse_unit_cd = c.nurse_unit_cd, reply->interface_charge[cnt].room_cd = c.room_cd,
    reply->interface_charge[cnt].bed_cd = c.bed_cd, reply->interface_charge[cnt].referring_phys_id =
    c.referring_phys_id, reply->interface_charge[cnt].ord_phys_id = c.ord_phys_id,
    reply->interface_charge[cnt].ord_doc_nbr = c.ord_doc_nbr, reply->interface_charge[cnt].
    adm_phys_id = c.adm_phys_id, reply->interface_charge[cnt].attending_phys_id = c.attending_phys_id,
    reply->interface_charge[cnt].additional_encntr_phys1_id = c.additional_encntr_phys1_id, reply->
    interface_charge[cnt].additional_encntr_phys2_id = c.additional_encntr_phys2_id, reply->
    interface_charge[cnt].additional_encntr_phys3_id = c.additional_encntr_phys3_id,
    reply->interface_charge[cnt].charge_type_cd = c.charge_type_cd, reply->interface_charge[cnt].
    updt_cnt = c.updt_cnt, reply->interface_charge[cnt].updt_dt_tm = c.updt_dt_tm,
    reply->interface_charge[cnt].updt_id = c.updt_id, reply->interface_charge[cnt].updt_task = c
    .updt_task, reply->interface_charge[cnt].updt_applctx = c.updt_applctx,
    reply->interface_charge[cnt].active_ind = c.active_ind, reply->interface_charge[cnt].
    active_status_cd = c.active_status_cd, reply->interface_charge[cnt].active_status_prsnl_id = c
    .active_status_prsnl_id,
    reply->interface_charge[cnt].active_status_dt_tm = c.active_status_dt_tm, reply->
    interface_charge[cnt].beg_effective_dt_tm = c.beg_effective_dt_tm, reply->interface_charge[cnt].
    end_effective_dt_tm = c.end_effective_dt_tm,
    reply->interface_charge[cnt].abn_status_cd = c.abn_status_cd, reply->interface_charge[cnt].
    activity_type_cd = c.activity_type_cd, reply->interface_charge[cnt].admit_type_cd = c
    .admit_type_cd,
    reply->interface_charge[cnt].bill_code_more_ind = c.bill_code_more_ind, reply->interface_charge[
    cnt].bill_code_type_cdf = c.bill_code_type_cdf, reply->interface_charge[cnt].code_modifier1_cd =
    c.code_modifier1_cd,
    reply->interface_charge[cnt].code_modifier2_cd = c.code_modifier2_cd, reply->interface_charge[cnt
    ].code_modifier3_cd = c.code_modifier3_cd, reply->interface_charge[cnt].code_modifier_more_ind =
    c.code_modifier_more_ind,
    reply->interface_charge[cnt].cost_center_cd = c.cost_center_cd, reply->interface_charge[cnt].
    diag_desc1 = c.diag_desc1, reply->interface_charge[cnt].diag_desc2 = c.diag_desc2,
    reply->interface_charge[cnt].diag_desc3 = c.diag_desc3, reply->interface_charge[cnt].
    diag_more_ind = c.diag_more_ind, reply->interface_charge[cnt].discount_amount = c.discount_amount,
    reply->interface_charge[cnt].fin_nbr_type_flg = c.fin_nbr_type_flg, reply->interface_charge[cnt].
    gross_price = c.gross_price, reply->interface_charge[cnt].icd9_proc_more_ind = c
    .icd9_proc_more_ind,
    reply->interface_charge[cnt].manual_ind = c.manual_ind, reply->interface_charge[cnt].
    med_service_cd = c.med_service_cd, reply->interface_charge[cnt].order_nbr = c.order_nbr,
    reply->interface_charge[cnt].override_desc = c.override_desc, reply->interface_charge[cnt].
    perf_loc_cd = c.perf_loc_cd, reply->interface_charge[cnt].perf_phys_id = c.perf_phys_id,
    reply->interface_charge[cnt].posted_dt_tm = c.posted_dt_tm, reply->interface_charge[cnt].
    prim_cdm_desc = c.prim_cdm_desc, reply->interface_charge[cnt].prim_cpt_desc = c.prim_cpt_desc,
    reply->interface_charge[cnt].prim_icd9_proc = c.prim_icd9_proc, reply->interface_charge[cnt].
    prim_icd9_proc_desc = c.prim_icd9_proc_desc, reply->interface_charge[cnt].process_flg = c
    .process_flg,
    reply->interface_charge[cnt].user_def_ind = c.user_def_ind
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SELECT INTO "nl:"
   c.seq
   FROM interface_charge c
   WHERE c.interface_charge_id > 0
    AND c.active_ind=1
    AND c.encntr_id > 0
    AND c.beg_effective_dt_tm <= datetimeadd(cnvtdatetime(request->charge_dt_tm),1)
    AND c.process_flg=0
   ORDER BY c.interface_file_id, c.encntr_id, c.fin_nbr
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->interface_charge,cnt), reply->interface_charge[cnt].
    interface_charge_id = c.interface_charge_id,
    reply->interface_charge[cnt].order_dept = c.order_dept, reply->interface_charge[cnt].
    interface_file_id = c.interface_file_id, reply->interface_charge[cnt].charge_item_id = c
    .charge_item_id,
    reply->interface_charge[cnt].batch_num = c.batch_num, reply->interface_charge[cnt].bill_code1 = c
    .bill_code1, reply->interface_charge[cnt].bill_code1_desc = c.bill_code1_desc,
    reply->interface_charge[cnt].bill_code2 = c.bill_code2, reply->interface_charge[cnt].
    bill_code2_desc = c.bill_code2_desc, reply->interface_charge[cnt].bill_code3 = c.bill_code3,
    reply->interface_charge[cnt].bill_code3_desc = c.bill_code3_desc, reply->interface_charge[cnt].
    prim_cdm = c.prim_cdm, reply->interface_charge[cnt].prim_cpt = c.prim_cpt,
    reply->interface_charge[cnt].diag_code1 = c.diag_code1, reply->interface_charge[cnt].diag_code2
     = c.diag_code2, reply->interface_charge[cnt].diag_code3 = c.diag_code3,
    reply->interface_charge[cnt].person_name = c.person_name, reply->interface_charge[cnt].person_id
     = c.person_id, reply->interface_charge[cnt].encntr_id = c.encntr_id,
    reply->interface_charge[cnt].fin_nbr = c.fin_nbr, reply->interface_charge[cnt].med_nbr = c
    .med_nbr, reply->interface_charge[cnt].service_dt_tm = c.service_dt_tm,
    reply->interface_charge[cnt].section_cd = c.section_cd, reply->interface_charge[cnt].
    encntr_type_cd = c.encntr_type_cd, reply->interface_charge[cnt].payor_id = c.payor_id,
    reply->interface_charge[cnt].quantity = c.quantity, reply->interface_charge[cnt].price = c.price,
    reply->interface_charge[cnt].net_ext_price = c.net_ext_price,
    reply->interface_charge[cnt].organization_id = c.organization_id, reply->interface_charge[cnt].
    institution_cd = c.institution_cd, reply->interface_charge[cnt].department_cd = c.department_cd,
    reply->interface_charge[cnt].subsection_cd = c.subsection_cd, reply->interface_charge[cnt].
    level5_cd = c.level5_cd, reply->interface_charge[cnt].facility_cd = c.facility_cd,
    reply->interface_charge[cnt].building_cd = c.building_cd, reply->interface_charge[cnt].
    nurse_unit_cd = c.nurse_unit_cd, reply->interface_charge[cnt].room_cd = c.room_cd,
    reply->interface_charge[cnt].bed_cd = c.bed_cd, reply->interface_charge[cnt].referring_phys_id =
    c.referring_phys_id, reply->interface_charge[cnt].ord_phys_id = c.ord_phys_id,
    reply->interface_charge[cnt].ord_doc_nbr = c.ord_doc_nbr, reply->interface_charge[cnt].
    adm_phys_id = c.adm_phys_id, reply->interface_charge[cnt].attending_phys_id = c.attending_phys_id,
    reply->interface_charge[cnt].additional_encntr_phys1_id = c.additional_encntr_phys1_id, reply->
    interface_charge[cnt].additional_encntr_phys2_id = c.additional_encntr_phys2_id, reply->
    interface_charge[cnt].additional_encntr_phys3_id = c.additional_encntr_phys3_id,
    reply->interface_charge[cnt].charge_type_cd = c.charge_type_cd, reply->interface_charge[cnt].
    updt_cnt = c.updt_cnt, reply->interface_charge[cnt].updt_dt_tm = c.updt_dt_tm,
    reply->interface_charge[cnt].updt_id = c.updt_id, reply->interface_charge[cnt].updt_task = c
    .updt_task, reply->interface_charge[cnt].updt_applctx = c.updt_applctx,
    reply->interface_charge[cnt].active_ind = c.active_ind, reply->interface_charge[cnt].
    active_status_cd = c.active_status_cd, reply->interface_charge[cnt].active_status_prsnl_id = c
    .active_status_prsnl_id,
    reply->interface_charge[cnt].active_status_dt_tm = c.active_status_dt_tm, reply->
    interface_charge[cnt].beg_effective_dt_tm = c.beg_effective_dt_tm, reply->interface_charge[cnt].
    end_effective_dt_tm = c.end_effective_dt_tm,
    reply->interface_charge[cnt].abn_status_cd = c.abn_status_cd, reply->interface_charge[cnt].
    activity_type_cd = c.activity_type_cd, reply->interface_charge[cnt].admit_type_cd = c
    .admit_type_cd,
    reply->interface_charge[cnt].bill_code_more_ind = c.bill_code_more_ind, reply->interface_charge[
    cnt].bill_code_type_cdf = c.bill_code_type_cdf, reply->interface_charge[cnt].code_modifier1_cd =
    c.code_modifier1_cd,
    reply->interface_charge[cnt].code_modifier2_cd = c.code_modifier2_cd, reply->interface_charge[cnt
    ].code_modifier3_cd = c.code_modifier3_cd, reply->interface_charge[cnt].code_modifier_more_ind =
    c.code_modifier_more_ind,
    reply->interface_charge[cnt].cost_center_cd = c.cost_center_cd, reply->interface_charge[cnt].
    diag_desc1 = c.diag_desc1, reply->interface_charge[cnt].diag_desc2 = c.diag_desc2,
    reply->interface_charge[cnt].diag_desc3 = c.diag_desc3, reply->interface_charge[cnt].
    diag_more_ind = c.diag_more_ind, reply->interface_charge[cnt].discount_amount = c.discount_amount,
    reply->interface_charge[cnt].fin_nbr_type_flg = c.fin_nbr_type_flg, reply->interface_charge[cnt].
    gross_price = c.gross_price, reply->interface_charge[cnt].icd9_proc_more_ind = c
    .icd9_proc_more_ind,
    reply->interface_charge[cnt].manual_ind = c.manual_ind, reply->interface_charge[cnt].
    med_service_cd = c.med_service_cd, reply->interface_charge[cnt].order_nbr = c.order_nbr,
    reply->interface_charge[cnt].override_desc = c.override_desc, reply->interface_charge[cnt].
    perf_loc_cd = c.perf_loc_cd, reply->interface_charge[cnt].perf_phys_id = c.perf_phys_id,
    reply->interface_charge[cnt].posted_dt_tm = c.posted_dt_tm, reply->interface_charge[cnt].
    prim_cdm_desc = c.prim_cdm_desc, reply->interface_charge[cnt].prim_cpt_desc = c.prim_cpt_desc,
    reply->interface_charge[cnt].prim_icd9_proc = c.prim_icd9_proc, reply->interface_charge[cnt].
    prim_icd9_proc_desc = c.prim_icd9_proc_desc, reply->interface_charge[cnt].process_flg = c
    .process_flg,
    reply->interface_charge[cnt].user_def_ind = c.user_def_ind
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 SET equal_line = fillstring(130,"=")
 SET dash_line = fillstring(130,"-")
 SET line_35 = fillstring(35,"-")
 SET person_tot = 0.00
 SET person_cnt = 0
 SET encntr_tot = 0.00
 SET encntr_cnt = 0
 SET rpt_tot = 0.00
 SET rpt_cnt = 0
 SELECT INTO value(file_name)
  person_id = reply->interface_charge[d1.seq].person_id, encntr_id = reply->interface_charge[d1.seq].
  encntr_id, service_dt_tm = reply->interface_charge[d1.seq].service_dt_tm,
  srv_date = format(reply->interface_charge[d1.seq].service_dt_tm,"mm/dd/yy;;d"), srv_time = format(
   reply->interface_charge[d1.seq].service_dt_tm,"hh:mm;;s"), prim_cdm_desc = substring(1,25,reply->
   interface_charge[d1.seq].prim_cdm_desc),
  run_date = format(request->charge_dt_tm,"mm/dd/yy;;d"), run_time = format(request->charge_dt_tm,
   "hh:mm;;s")
  FROM (dummyt d1  WITH seq = value(size(reply->interface_charge,5)))
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
   col 60, "CDM", col 70,
   "Description", col 97, "Service Date",
   col 117, "Qty", col 122,
   "Price", row + 1, col 00,
   equal_line, row + 2
  HEAD person_id
   IF (person_cnt != 0)
    col 00, dash_line, row + 2
   ENDIF
   col 00, reply->interface_charge[d1.seq].person_name, person_tot = 0.00,
   person_cnt = 0
  HEAD encntr_id
   IF (person_cnt != 0)
    row + 1
   ENDIF
   col 20, reply->interface_charge[d1.seq].fin_nbr, col 35,
   reply->interface_charge[d1.seq].med_nbr, encntr_tot = 0.00, encntr_cnt = 0
  DETAIL
   person_tot = (person_tot+ reply->interface_charge[d1.seq].net_ext_price), person_cnt = (person_cnt
   + reply->interface_charge[d1.seq].quantity), encntr_tot = (encntr_tot+ reply->interface_charge[d1
   .seq].net_ext_price),
   encntr_cnt = (encntr_cnt+ reply->interface_charge[d1.seq].quantity), rpt_tot = (rpt_tot+ reply->
   interface_charge[d1.seq].net_ext_price), rpt_cnt = (rpt_cnt+ reply->interface_charge[d1.seq].
   quantity),
   col 50, reply->interface_charge[d1.seq].prim_cpt, col 60,
   reply->interface_charge[d1.seq].prim_cdm, col 70, prim_cdm_desc,
   col 97, srv_date, " ",
   srv_time, col 115, reply->interface_charge[d1.seq].quantity"#####",
   col 120, reply->interface_charge[d1.seq].net_ext_price"########.##", row + 1
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
#2999_process_exit
#9999_end
END GO

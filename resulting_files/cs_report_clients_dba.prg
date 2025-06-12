CREATE PROGRAM cs_report_clients:dba
 FREE SET dt
 RECORD dt(
   1 run_dt = dq8
 )
 RECORD batchrequest(
   1 batch_req_qual = i4
   1 batch_req[*]
     2 client_id = f8
 )
 RECORD outputlist(
   1 ol_fqual = i2
   1 ol_frecs[*]
     2 ol_file_num = i2
     2 ol_file_name = c80
     2 ol_org_name = c80
     2 ol_file_cd = f8
     2 selected = c1
 )
 RECORD reply(
   1 t01_qual = i4
   1 t01_recs[100]
     2 to1_id = f8
     2 t01_charge_item_id = f8
     2 t01_interfaced = c1
   1 client = c10
   1 client_desc = c80
   1 client_id = f8
   1 street_addr = c100
   1 street_addr2 = c100
   1 street_addr3 = c100
   1 city = c100
   1 state = c100
   1 zipcode = c25
   1 country = c100
   1 first_time = c1
   1 invoice_nbr = f8
   1 charge_qual = i2
   1 files_qual = i4
   1 files[*]
     2 file_name = c80
     2 cover_name = c80
   1 charge[*]
     2 charge_event_id = f8
     2 charge_item_id = f8
     2 charge_act_id = f8
     2 charge_mod_id = f8
     2 bill_item_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 payor_id = f8
     2 adm_loc_cd = f8
     2 ord_loc_cd = f8
     2 ord_dept_cd = f8
     2 ord_department = c40
     2 ord_sect_cd = f8
     2 ord_section = c40
     2 perf_loc_cd = f8
     2 adm_phys_id = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 price_sched_id = f8
     2 item_quantity = i4
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 research_acct_id = f8
     2 service_dt_tm = dq8
     2 prim_mnem = c40
     2 prim_cdm = c40
     2 prim_cpt = c40
     2 order_id = f8
     2 order_nbr = c20
     2 med_nbr = c20
     2 fin_nbr = c20
     2 client = c20
     2 person_name = c80
     2 ord_phys_name = c80
     2 charge_description = c200
     2 charge_pt = c1
     2 encntr_type = c1
     2 charge_type = c6
     2 trans_type = f8
     2 client_account = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET hightime = curtime
 SET hightime = cnvtdatetime("23:59:59.99")
 SET dt->run_dt = cnvtdatetime(curdate,curtime)
 IF ((request->batch_selection != ""))
  CALL get_batch_cd(trim(request->batch_selection))
 ENDIF
 SUBROUTINE get_batch_cd(batch_cd)
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c
    WHERE c.code_set=15569
     AND c.display_key=batch_cd
    DETAIL
     request->batch_cd = c.code_value
    WITH nocounter
   ;end select
 END ;Subroutine
 IF ((request->posted_dt_tm > 0))
  SET rn_dt = cnvtdatetime(request->posted_dt_tm)
 ELSE
  IF ((request->ops_date > 0))
   SET rn_dt = cnvtdatetime(request->ops_date)
  ELSE
   SET rn_dt = cnvtdatetime(request->cutoffdate)
  ENDIF
 ENDIF
 SET end_date = concat(format(rn_dt,"DD-MMM-YYYY;;D")," 23:59:59.99")
 CALL echo(build("Run_date is: ",end_date))
 SET print_date = concat(format(rn_dt,"DD-MMM-YYYY;;D"))
 IF ((request->output_dist != ""))
  SET request->printer = request->output_dist
 ENDIF
 IF (trim(request->printer) != "")
  SET prtr_name = request->printer
 ELSE
  SET prtr_name = "FILE"
 ENDIF
 CALL echo(build("Printer name is: ",prtr_name))
 SET count1 = 0
 SET stat = alterlist(outputlist->ol_frecs,(count1+ 10))
 SET lst_file_cd = 0
 SET stat = alterlist(batchrequest->batch_req,count1)
 IF ((request->batch_cd > 0))
  SELECT INTO "nl:"
   c.*
   FROM client_batch c
   WHERE (c.batch_cd=request->batch_cd)
    AND c.active_ind=1
   DETAIL
    count1 = (count1+ 1), stat = alterlist(batchrequest->batch_req,count1), batchrequest->batch_req[
    count1].client_id = c.client_id
   WITH nocounter
  ;end select
  SET stat = alterlist(batchrequest->batch_req,count1)
  SET batchrequest->batch_req_qual = count1
 ELSE
  SET stat = alterlist(batchrequest->batch_req,1)
  SET batchrequest->batch_req[1].client_id = request->client_id
  SET batchrequest->batch_req_qual = 1
 ENDIF
 SET g_mailing_addr_cd = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=212
   AND a.cdf_meaning="MAILING"
   AND a.active_ind=1
  DETAIL
   g_mailing_addr_cd = a.code_value
  WITH nocounter
 ;end select
 SET g_business_addr_cd = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=212
   AND a.cdf_meaning="BUSINESS"
   AND a.active_ind=1
  DETAIL
   g_business_addr_cd = a.code_value
  WITH nocounter
 ;end select
 SET g_clientbill_cd = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=13031
   AND a.cdf_meaning="CLIENTBILL"
   AND a.active_ind=1
  DETAIL
   g_clientbill_cd = a.code_value
  WITH nocounter
 ;end select
 SET count1 = 0
 SELECT
  IF ((request->rerun > 0))
   PLAN (d1)
    JOIN (c
    WHERE c.posted_cd > 0
     AND c.posted_dt_tm BETWEEN cnvtdatetime(beg_posted_date) AND cnvtdatetime(end_posted_date)
     AND (c.payor_id=batchrequest->batch_req[d1.seq].client_id)
     AND c.process_flg IN (999, 0))
    JOIN (o
    WHERE (o.organization_id=batchrequest->batch_req[d1.seq].client_id))
    JOIN (i
    WHERE i.interface_file_id=c.interface_file_id)
    JOIN (d2)
    JOIN (b
    WHERE b.organization_id=c.payor_id
     AND b.bill_org_type_cd=g_clientbill_cd
     AND b.active_ind=1)
  ELSE
   PLAN (d1)
    JOIN (c
    WHERE c.posted_cd=0
     AND (c.payor_id=batchrequest->batch_req[d1.seq].client_id)
     AND c.process_flg IN (999, 0))
    JOIN (o
    WHERE (o.organization_id=batchrequest->batch_req[d1.seq].client_id))
    JOIN (i
    WHERE i.interface_file_id=c.interface_file_id)
    JOIN (d2)
    JOIN (b
    WHERE b.organization_id=c.payor_id
     AND b.bill_org_type_cd=g_clientbill_cd
     AND b.active_ind=1)
  ENDIF
  DISTINCT INTO "nl:"
  i.interface_file_id, b.bill_org_type_cd, b.bill_org_type_id,
  o.organization_id
  FROM interface_file i,
   charge c,
   bill_org_payor b,
   organization o,
   (dummyt d1  WITH seq = value(batchrequest->batch_req_qual)),
   dummyt d2
  ORDER BY i.interface_file_id, b.bill_org_type_cd, b.bill_org_type_id,
   o.organization_id
  DETAIL
   IF (lst_file_cd != o.organization_id
    AND ((i.file_name="CLIENTBILL") OR (b.bill_org_type_id=1)) )
    count1 = (count1+ 1), stat = alterlist(outputlist->ol_frecs,count1), outputlist->ol_frecs[count1]
    .ol_file_cd = o.organization_id,
    outputlist->ol_frecs[count1].ol_org_name = o.org_name, outputlist->ol_frecs[count1].selected =
    "Y", lst_file_cd = o.organization_id,
    CALL echo(build("Last File Code (org id) is: ",lst_file_cd))
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 SET stat = alterlist(outputlist->ol_frecs,count1)
 SET outputlist->ol_fqual = count1
 CALL echo(build("Org Id is:",request->client_id))
 SET true = 1
 SET false = 0
 SET g_status_code_active = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=48
   AND a.cdf_meaning="ACTIVE"
   AND a.active_ind=1
  DETAIL
   g_status_code_active = a.code_value
  WITH nocounter
 ;end select
 SET g_bill_code_cd = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=13019
   AND a.cdf_meaning="BILL CODE"
   AND a.active_ind=1
  DETAIL
   g_bill_code_cd = a.code_value
  WITH nocounter
 ;end select
 SET g_bill_mnem_cd = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=13031
   AND a.cdf_meaning="BILLMNEM"
   AND a.active_ind=1
  DETAIL
   g_bill_mnem_cd = a.code_value
  WITH nocounter
 ;end select
 SET g_org_alias_client_cd = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=334
   AND a.cdf_meaning="CLIENT"
   AND a.active_ind=1
  DETAIL
   g_org_alias_client_cd = a.code_value
  WITH nocounter
 ;end select
 SET g_person_alias_med_rec_num = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=4
   AND a.cdf_meaning="MRN"
   AND a.active_ind=1
  DETAIL
   g_person_alias_med_rec_num = a.code_value
  WITH nocounter
 ;end select
 SET g_encounter_alias_fin_num = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=319
   AND a.cdf_meaning="FIN NBR"
   AND a.active_ind=1
  DETAIL
   g_encounter_alias_fin_num = a.code_value
  WITH nocounter
 ;end select
 SET g_order_alias_order_id = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=754
   AND a.cdf_meaning="PLACERORDID"
   AND a.active_ind=1
  DETAIL
   g_order_alias_order_id = a.code_value
  WITH nocounter
 ;end select
 SET admitting_dr_cd = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=333
   AND a.cdf_meaning="ADMITDOC"
   AND a.active_ind=1
  DETAIL
   admitting_dr_cd = a.code_value
  WITH nocounter
 ;end select
 CALL echo(build("Output Qual is :",outputlist->ol_fqual))
 FOR (rptrun = 01 TO outputlist->ol_fqual)
  IF ((outputlist->ol_frecs[rptrun].selected="Y"))
   SET tot_qty = 0
   SET tot_amount = 0.00
   SET count1 = 0
   SET beg_posted_date = concat(format(request->posted_dt_tm,"DD-MMM-YYYY;;D")," 00:00:00.00")
   SET end_posted_date = concat(format(request->posted_dt_tm,"DD-MMM-YYYY;;D")," 23:59:59.99")
   SET stat = alterlist(reply->charge,(count1+ 10))
   SELECT
    IF ((request->rerun > 0))INTO "nl:"
     c.*, cv.cdf_meaning
     FROM charge c,
      code_value cv
     WHERE c.posted_dt_tm BETWEEN cnvtdatetime(beg_posted_date) AND cnvtdatetime(end_posted_date)
      AND c.posted_cd=999
      AND ((c.process_flg=0) OR (c.process_flg=999))
      AND c.service_dt_tm <= cnvtdatetime(end_date)
      AND (c.payor_id=outputlist->ol_frecs[rptrun].ol_file_cd)
      AND c.charge_type_cd=cv.code_value
      AND c.charge_item_id != 0
    ELSE INTO "nl:"
     c.*, cv.cdf_meaning
     FROM charge c,
      code_value cv
     WHERE c.posted_cd=0
      AND ((c.process_flg=0) OR (c.process_flg=999))
      AND c.service_dt_tm <= cnvtdatetime(end_date)
      AND (c.payor_id=outputlist->ol_frecs[rptrun].ol_file_cd)
      AND c.charge_type_cd=cv.code_value
      AND c.charge_item_id != 0
    ENDIF
    DETAIL
     count1 = (count1+ 1), stat = alterlist(reply->charge,count1), reply->charge[count1].
     charge_item_id = c.charge_item_id,
     reply->charge[count1].bill_item_id = c.bill_item_id, reply->charge[count1].person_id = c
     .person_id, reply->charge[count1].encntr_id = c.encntr_id,
     reply->charge[count1].charge_event_id = c.charge_event_id, reply->charge[count1].payor_id = c
     .payor_id, reply->charge[count1].adm_loc_cd = 0,
     reply->charge[count1].ord_loc_cd = c.ord_loc_cd, reply->charge[count1].perf_loc_cd = c
     .perf_loc_cd, reply->charge[count1].adm_phys_id = 0,
     reply->charge[count1].ord_phys_id = c.ord_phys_id, reply->charge[count1].perf_phys_id = c
     .perf_phys_id, reply->charge[count1].charge_description = trim(c.charge_description,3),
     reply->charge[count1].price_sched_id = c.price_sched_id, reply->charge[count1].order_id = c
     .order_id, reply->charge[count1].item_quantity = c.item_quantity,
     reply->charge[count1].item_price = c.item_price, reply->charge[count1].item_extended_price = c
     .item_extended_price, reply->charge[count1].item_allowable = c.item_allowable,
     reply->charge[count1].item_copay = c.item_copay, reply->charge[count1].research_acct_id = c
     .research_acct_id, reply->charge[count1].charge_type = cv.cdf_meaning,
     reply->charge[count1].service_dt_tm = c.service_dt_tm, tot_qty = (tot_qty+ c.item_quantity),
     tot_amount = (tot_amount+ c.item_extended_price)
    WITH nocounter, compress
   ;end select
   SET reply->charge_qual = count1
   SET stat = alterlist(reply->charge,count1)
   IF ((reply->charge_qual > 0))
    SET stat = alter(reply->t01_recs,value(reply->charge_qual))
    SET reply->t01_qual = reply->charge_qual
    FOR (count1 = 1 TO reply->charge_qual)
      SET reply->charge[count1].med_nbr = " "
      SET reply->charge[count1].fin_nbr = " "
      SET reply->charge[count1].prim_cdm = " "
      SET reply->charge[count1].prim_mnem = " "
      SET reply->charge[count1].ord_department = fillstring(40," ")
      SET reply->charge[count1].ord_section = fillstring(40," ")
      SET reply->charge[count1].person_name = " "
      SET reply->charge[count1].ord_phys_name = " "
      SET reply->charge[count1].encntr_type = " "
      SET reply->t01_recs[count1].t01_interfaced = "Y"
      SET reply->t01_recs[count1].t01_charge_item_id = reply->charge[count1].charge_item_id
    ENDFOR
    SET g_fin_nbr_cd = 0
    SELECT INTO "nl:"
     a.code_value
     FROM code_value a
     WHERE a.code_set=13031
      AND a.cdf_meaning="FINNUM"
      AND a.active_ind=1
     DETAIL
      g_fin_nbr_cd = a.code_value
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM bill_org_payor b,
      (dummyt d1  WITH seq = value(reply->charge_qual))
     PLAN (d1)
      JOIN (b
      WHERE (b.organization_id=reply->charge[d1.seq].payor_id)
       AND b.bill_org_type_cd=g_fin_nbr_cd
       AND b.active_ind=1)
     DETAIL
      reply->charge[d1.seq].client_account = b.bill_org_type_id
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     oapr.organization_id, oapr.alias_entity_alias_type_cd, oa.organization_id,
     oa.alias
     FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
      org_alias_pool_reltn oapr,
      organization_alias oa
     PLAN (d1)
      JOIN (oapr
      WHERE (oapr.organization_id=reply->charge[d1.seq].payor_id)
       AND oapr.alias_entity_name="ORGANIZATION_ALIAS"
       AND oapr.alias_entity_alias_type_cd=g_org_alias_client_cd
       AND oapr.active_ind=true)
      JOIN (oa
      WHERE (oa.organization_id=reply->charge[d1.seq].payor_id)
       AND oa.alias_pool_cd=oapr.alias_pool_cd
       AND oa.org_alias_type_cd=g_org_alias_client_cd
       AND oa.active_ind=true)
     DETAIL
      reply->charge[d1.seq].client = oa.alias
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     oapr.organization_id, oapr.alias_entity_alias_type_cd, pa.person_id,
     pa.alias
     FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
      org_alias_pool_reltn oapr,
      person_alias pa
     PLAN (d1)
      JOIN (oapr
      WHERE (oapr.organization_id=reply->charge[d1.seq].payor_id)
       AND oapr.alias_entity_name="PERSON_ALIAS"
       AND oapr.alias_entity_alias_type_cd=g_person_alias_med_rec_num
       AND oapr.active_ind=true)
      JOIN (pa
      WHERE (pa.person_id=reply->charge[d1.seq].person_id)
       AND pa.alias_pool_cd=oapr.alias_pool_cd
       AND pa.person_alias_type_cd=g_person_alias_med_rec_num
       AND pa.active_ind=true)
     DETAIL
      reply->charge[d1.seq].med_nbr = pa.alias
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     p.name_full_formatted
     FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
      person p
     PLAN (d1)
      JOIN (p
      WHERE (p.person_id=reply->charge[d1.seq].person_id))
     DETAIL
      reply->charge[d1.seq].person_name = p.name_full_formatted
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     e.encntr_type_cd, c.display
     FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
      encounter e,
      code_value c
     PLAN (d1)
      JOIN (e
      WHERE (e.encntr_id=reply->charge[d1.seq].encntr_id))
      JOIN (c
      WHERE e.encntr_type_cd=c.code_value)
     DETAIL
      reply->charge[d1.seq].encntr_type = c.display
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     ea.alias
     FROM encntr_alias ea,
      (dummyt d1  WITH seq = value(reply->charge_qual)),
      org_alias_pool_reltn oapr
     PLAN (d1)
      JOIN (oapr
      WHERE (oapr.organization_id=reply->charge[d1.seq].payor_id)
       AND oapr.alias_entity_name="ENCNTR_ALIAS"
       AND oapr.alias_entity_alias_type_cd=g_encounter_alias_fin_num
       AND oapr.active_ind=true)
      JOIN (ea
      WHERE (ea.encntr_id=reply->charge[d1.seq].encntr_id)
       AND ea.alias_pool_cd=oapr.alias_pool_cd
       AND ea.encntr_alias_type_cd=g_encounter_alias_fin_num
       AND ea.active_ind=true)
     DETAIL
      reply->charge[d1.seq].fin_nbr = ea.alias
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cm.field1_id, trim(cm.field6,3), cm.field3
     FROM charge_mod cm,
      (dummyt d1  WITH seq = value(reply->charge_qual)),
      code_value cv
     PLAN (d1)
      JOIN (cm
      WHERE (cm.charge_item_id=reply->charge[d1.seq].charge_item_id)
       AND cm.charge_mod_type_cd=g_bill_code_cd
       AND cm.active_ind=true)
      JOIN (cv
      WHERE cv.code_value=cm.field1_id
       AND cv.cdf_meaning="CDM_SCHED"
       AND cv.code_set=14002
       AND cv.active_ind=true)
     DETAIL
      reply->charge[d1.seq].prim_cdm = trim(cm.field6,3)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cm.field1_id, trim(cm.field6,3), cm.field3
     FROM charge_mod cm,
      (dummyt d1  WITH seq = value(reply->charge_qual)),
      code_value cv
     PLAN (d1)
      JOIN (cm
      WHERE (cm.charge_item_id=reply->charge[d1.seq].charge_item_id)
       AND cm.charge_mod_type_cd=g_bill_code_cd
       AND cm.active_ind=true)
      JOIN (cv
      WHERE cv.code_value=cm.field1_id
       AND cv.cdf_meaning="CPT4"
       AND cv.code_set=14002
       AND cv.active_ind=true)
     DETAIL
      reply->charge[d1.seq].prim_cpt = trim(cm.field6,3)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     bim.key2
     FROM bill_item_modifier bim,
      (dummyt d1  WITH seq = value(reply->charge_qual)),
      bill_org_payor bop
     PLAN (d1)
      JOIN (bop
      WHERE (bop.organization_id=reply->charge[d1.seq].payor_id)
       AND bop.bill_org_type_cd=g_bill_mnem_cd
       AND bop.active_ind=true)
      JOIN (bim
      WHERE (bim.bill_item_id=reply->charge[d1.seq].bill_item_id)
       AND bim.bill_item_type_cd=bop.bill_org_type_id
       AND bim.active_ind=true)
     DETAIL
      reply->charge[d1.seq].prim_mnem = trim(bim.key2,3)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     oapr.organization_id, oapr.alias_entity_alias_type_cd, oa.order_id,
     oa.alias
     FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
      org_alias_pool_reltn oapr,
      order_alias oa
     PLAN (d1)
      JOIN (oapr
      WHERE (oapr.organization_id=reply->charge[d1.seq].payor_id)
       AND oapr.alias_entity_name="ORDER_ALIAS"
       AND oapr.alias_entity_alias_type_cd=g_order_alias_order_id
       AND oapr.active_ind=true)
      JOIN (oa
      WHERE (oa.order_id=reply->charge[d1.seq].order_id)
       AND oa.alias_pool_cd=oapr.alias_pool_cd
       AND oa.order_alias_type_cd=g_order_alias_order_id
       AND oa.active_ind=true)
     DETAIL
      reply->charge[d1.seq].order_nbr = oa.alias
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     o.last_update_provider_id
     FROM orders o,
      (dummyt d1  WITH seq = value(reply->charge_qual))
     PLAN (d1
      WHERE (reply->charge[d1.seq].ord_phys_id=0))
      JOIN (o
      WHERE (o.order_id=reply->charge[d1.seq].order_id))
     DETAIL
      reply->charge[d1.seq].ord_phys_id = o.last_update_provider_id
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     p.name_full_formatted
     FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
      person p
     PLAN (d1)
      JOIN (p
      WHERE (p.person_id=reply->charge[d1.seq].ord_phys_id))
     DETAIL
      reply->charge[d1.seq].ord_phys_name = p.name_full_formatted
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     e.encntr_id, e.location_cd, epr.encntr_prsnl_reltn_id,
     epr.encntr_prsnl_r_cd, epr.prsnl_person_id
     FROM encounter e,
      (dummyt d1  WITH seq = value(reply->charge_qual)),
      (dummyt d2  WITH seq = 1),
      encntr_prsnl_reltn epr
     PLAN (d1)
      JOIN (e
      WHERE (e.encntr_id=reply->charge[d1.seq].encntr_id))
      JOIN (d2)
      JOIN (epr
      WHERE epr.encntr_id=e.encntr_id
       AND epr.encntr_prsnl_r_cd=admitting_dr_cd
       AND epr.active_ind=true)
     DETAIL
      reply->charge[d1.seq].adm_phys_id = epr.prsnl_person_id, reply->charge[d1.seq].adm_loc_cd = e
      .location_cd
     WITH nocounter, outerjoin = d2
    ;end select
    FOR (count2 = 1 TO reply->charge_qual)
      SET found_loc = "N"
      SET start_loc_cd = reply->charge[count2].ord_loc_cd
      SET loc_desc = fillstring(40," ")
      IF (start_loc_cd != null
       AND start_loc_cd > 0)
       FOR (count1 = 1 TO 50)
        CALL get_type_loc("DEPARTMENT")
        IF (found_loc="Y")
         SET count1 = 50
         SET reply->charge[count2].ord_department = loc_desc
        ENDIF
       ENDFOR
      ENDIF
    ENDFOR
    FOR (count2 = 1 TO reply->charge_qual)
      SET found_loc = "N"
      SET start_loc_cd = reply->charge[count2].perf_loc_cd
      SET loc_desc = fillstring(40," ")
      IF (start_loc_cd != null
       AND start_loc_cd > 0)
       FOR (count1 = 1 TO 50)
        CALL get_type_loc("SECTION")
        IF (found_loc="Y")
         SET count1 = 50
         SET reply->charge[count2].ord_section = loc_desc
        ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  IF ((reply->charge_qual > 0))
   SET stat = alterlist(reply->files,rptrun)
   SELECT INTO "nl:"
    o.org_name, o.org_name_key, a.street_addr,
    a.street_addr2, a.street_addr3, a.city,
    a.state, a.zipcode
    FROM organization o,
     address a,
     dummyt d1
    PLAN (o
     WHERE (o.organization_id=outputlist->ol_frecs[rptrun].ol_file_cd))
     JOIN (d1)
     JOIN (a
     WHERE (a.parent_entity_id=outputlist->ol_frecs[rptrun].ol_file_cd)
      AND a.parent_entity_name="ORGANIZATION"
      AND ((a.address_type_cd=g_business_addr_cd) OR (a.address_type_cd=g_mailing_addr_cd)) )
    DETAIL
     reply->client_desc = o.org_name, allowed = (11 - size(trim(cnvtstring(o.organization_id)))),
     CALL echo(build("Allowed length for Org Name: ",allowed)),
     namedate = cnvtdatetime(curdate,curtime), reply->files[rptrun].file_name = concat("AFC_",
      cnvtstring(namedate),".dat"), reply->files[rptrun].cover_name = concat("CVR_",cnvtstring(
       namedate),".dat"),
     reply->street_addr = a.street_addr, reply->street_addr2 = a.street_addr2, reply->street_addr3 =
     a.street_addr3,
     reply->city = a.city, reply->state = a.state, reply->zipcode = a.zipcode
    WITH nocounter, outerjoin = d1
   ;end select
   SET reply->status_data.status = "S"
   SET reply->invoice_nbr = 0
   SET new_nbr = 0
   SELECT INTO "nl:"
    y = seq(bill_item_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_nbr = cnvtreal(y)
    WITH format, nocounter
   ;end select
   SET reply->invoice_nbr = new_nbr
   CALL create_cover_page(reply->files[rptrun].cover_name)
   CALL create_custom_client(reply->files[rptrun].file_name)
   IF (trim(request->printer) != "")
    SET com = concat("print/queue=",trim(prtr_name)," ",value(reply->files[rptrun].file_name))
    CALL dcl(com,size(trim(com)),0)
   ENDIF
   SET reply->files_qual = rptrun
  ENDIF
 ENDFOR
 SUBROUTINE create_cover_page(filename1)
   SET outfile = fillstring(30," ")
   SET outfile = concat("ccluserdir:",filename1)
   CALL echo(build("Outfile is: ",outfile))
   SELECT INTO value(outfile)
    cover_id = d.seq, cover_ord_dept = reply->charge[d.seq].ord_department, cover_bill_code = reply->
    charge[d.seq].prim_cdm,
    cover_section = reply->charge[d.seq].ord_section, cover_encounter_type = reply->charge[d.seq].
    encntr_type, cover_org_id = reply->charge[d.seq].payor_id,
    cover_client = reply->charge[d.seq].client, cover_fin = reply->charge[d.seq].fin_nbr, cover_tcode
     = reply->charge[d.seq].trans_type,
    cover_charge_pt = reply->charge[d.seq].charge_pt, cover_ord_phys_name = reply->charge[d.seq].
    ord_phys_name, cover_service_dt_tm = reply->charge[d.seq].service_dt_tm,
    cover_med_nbr = reply->charge[d.seq].med_nbr, cover_person_name = reply->charge[d.seq].
    person_name, cover_charge_description = reply->charge[d.seq].charge_description,
    cover_prim_cdm = reply->charge[d.seq].prim_cdm, cover_prim_cpt = reply->charge[d.seq].prim_cpt,
    cover_item_price = reply->charge[d.seq].item_price,
    cover_item_quantity = reply->charge[d.seq].item_quantity, cover_mne = reply->charge[d.seq].
    prim_mnem, cover_ord_phys_id = reply->charge[d.seq].ord_phys_id,
    cover_code = reply->charge[d.seq].prim_cdm, cover_srv_id = reply->charge[d.seq].ord_phys_id,
    cover_bill_type = reply->charge[d.seq].charge_type,
    cover_bill_item_id = reply->charge[d.seq].bill_item_id, cover_price_sched_id = reply->charge[d
    .seq].price_sched_id
    FROM (dummyt d  WITH seq = value(reply->charge_qual))
    ORDER BY cover_section
    HEAD REPORT
     rec_cnt = 0, rec_cnt2 = 0, first_section_flg = "TRUE",
     section_written = "N", prev_section = fillstring(40," "), sect_accum_amt = 0.00,
     sect_accum_qty = 0, tot_sect_accum_qty = 0, tot_sect_accum_amt = 0.00,
     tot_accum_amt = 0.00, tot_accum_qty = 0, grand_tot_accum_qty = 0,
     grand_tot_accum_amt = 0.00, report_name = "Client Report for:  ", title30 = fillstring(47,"="),
     line120 = fillstring(120,"-"), eqline130 = fillstring(130,"="), street_addr = trim(reply->
      street_addr,3),
     street_addr2 = trim(reply->street_addr2,3), street_addr3 = trim(reply->street_addr3,3), city =
     trim(reply->city,3),
     state = trim(reply->state,3), zipcode = trim(reply->zipcode,3), date = cnvtdatetime(curdate,
      curtime),
     t_date = concat(format(date,"DD-MMM-YYYY;;D")), col 00, report_name,
     row + 2, col 00, reply->client_desc,
     row + 1, col 00, street_addr,
     col 95, "Date As of: ", col 109,
     t_date, row + 1
     IF (trim(reply->street_addr2) != "")
      col 00, street_addr2"######################################", row + 1
     ENDIF
     IF (trim(reply->street_addr3) != "")
      col 00, street_addr3"######################################", row + 1
     ENDIF
     col 00, city, col 25,
     state, col 35, zipcode,
     row + 1
    HEAD cover_section
     row + 1
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
     IF ((reply->charge[d.seq].ord_section=" "))
      ord_section = "NO SECTION FOUND"
     ELSE
      ord_section = reply->charge[d.seq].ord_section
     ENDIF
     prev_section = reply->charge[d.seq].ord_section, first_section_flg = "FALSE"
     IF (section_written="Y")
      col 20, "Section Total Qty", col 43,
      sect_accum_qty, row + 1, col 20,
      "Section Total Amt", col 40, sect_accum_amt,
      row + 1, sect_accum_qty = 0, sect_accum_amt = 0.00
     ENDIF
     row + 1, col 30, ord_section,
     row + 1, col 20, title30,
     row + 1
    DETAIL
     IF ((reply->charge_qual > 0))
      sect_accum_qty = (sect_accum_qty+ reply->charge[d.seq].item_quantity), sect_accum_amt = (
      sect_accum_amt+ reply->charge[d.seq].item_extended_price), rec_cnt = (rec_cnt+ 1),
      rec_cnt2 = ((rec_cnt2+ 1)+ (reply->charge[d.seq].item_quantity - 1))
     ENDIF
     section_written = "Y"
    FOOT PAGE
     IF ((rec_cnt=reply->charge_qual))
      IF (section_written="Y")
       row + 1, col 20, "Section Total Qty",
       col 43, sect_accum_qty, row + 1,
       col 20, "Section Total Amt", col 40,
       sect_accum_amt, row + 2
      ENDIF
      col 12, rec_cnt2"######", col 20,
      "Transactions Totaling", col 43, tot_amount"########.##",
      CALL echo(build("Grand Total is : ",tot_amount))
     ENDIF
     row + 1, col 01, "Printed: ",
     col 10, curdate"DDMMMYY;;D", col 18,
     curtime"HH:MM;;M", col 25, "By: ",
     col 29, curuser"######", col 114,
     "Page: ", col 120, curpage"###",
     pagecount = curpage
    WITH nocounter, compress
   ;end select
 END ;Subroutine
 SUBROUTINE create_custom_client(filename2)
   SET outfile = fillstring(30," ")
   SET outfile = concat("ccluserdir:",filename2)
   CALL echo(concat("OUTFILE IS: ",outfile))
   SET numbset = 0
   SELECT INTO value(outfile)
    t01_id = d.seq, t01_ord_dept = reply->charge[d.seq].ord_department, t01_bill_code = reply->
    charge[d.seq].prim_cdm,
    t01_section = reply->charge[d.seq].ord_section, t01_encounter_type = reply->charge[d.seq].
    encntr_type, t01_org_id = reply->charge[d.seq].payor_id,
    t01_client = reply->charge[d.seq].client, t01_fin = reply->charge[d.seq].fin_nbr, t01_tcode =
    reply->charge[d.seq].trans_type,
    t01_charge_pt = reply->charge[d.seq].charge_pt, t01_ord_phys_name = reply->charge[d.seq].
    ord_phys_name, t01_service_dt_tm = reply->charge[d.seq].service_dt_tm,
    t01_med_nbr = reply->charge[d.seq].med_nbr, t01_person_name = reply->charge[d.seq].person_name,
    t01_charge_description = reply->charge[d.seq].charge_description,
    t01_prim_cdm = reply->charge[d.seq].prim_cdm, t01_prim_cpt = reply->charge[d.seq].prim_cpt,
    t01_item_price = reply->charge[d.seq].item_price,
    t01_item_quantity = reply->charge[d.seq].item_quantity, t01_mne = reply->charge[d.seq].prim_mnem,
    t01_ord_phys_id = reply->charge[d.seq].ord_phys_id,
    t01_code = reply->charge[d.seq].prim_cdm, t01_srv_id = reply->charge[d.seq].ord_phys_id,
    t01_bill_type = reply->charge[d.seq].charge_type,
    t01_account_nbr = reply->charge[d.seq].client_account
    FROM (dummyt d  WITH seq = value(reply->charge_qual))
    ORDER BY t01_ord_phys_name, t01_service_dt_tm, t01_person_name
    HEAD REPORT
     rec_cnt = 0, first_time = "Y", phys_br = "N",
     bfa_accum_cnt = 0, bfa_accum_amt = 0.00, bfa_accum_qty = 0,
     bfa_department = fillstring(40," "), prev_bfa_department = fillstring(40,"*"), dept_accum_cnt =
     0,
     dept_accum_amt = 0.00, dept_accum_qty = 0, bfa_pat = fillstring(40," "),
     prev_bfa_pat = fillstring(40,"*"), page_accum_cnt = 0, page_accum_amt = 0.00,
     page_accum_qty = 0, bfa_fin = fillstring(40," "), prev_bfa_fin = fillstring(40,"*"),
     fin_accum_cnt = 0, fin_accum_qty = 0, fin_accum_amt = 0.00,
     dr_accum_amt = 0.00, dr_accum_qty = 0, dr_accum_cnt = 0,
     bfa_bill = fillstring(40," "), prev_bfa_bill = fillstring(40,"*"), bfa_bill_s = fillstring(3," "
      ),
     prev_bfa_bill_s = fillstring(3,"*"), bill_accum_cnt = 0, bill_accum_amt = 0.00,
     bill_accum_qty = 0, invoice_line = "Invoice:  ", report_name = "Client Report for:  ",
     line120 = fillstring(120,"-"), eqline130 = fillstring(130,"="), head5 = "Billing inquiries:",
     head6 = "Call: (314)454-2157", head7 = "For the Period of: ", head1 =
     "                                                St. Louis Children's Hospital",
     head2 = "                                                    Clinical Laboratories", head3 =
     "                                                       P.O. Box 14667                          Location code: ",
     head4 = "                                                    St. Louis, MO 63150",
     street_addr = trim(reply->street_addr,3), street_addr2 = trim(reply->street_addr2,3),
     street_addr3 = trim(reply->street_addr3,3),
     city = trim(reply->city,3), state = trim(reply->state,3), zipcode = trim(reply->zipcode,3),
     head10 =
"REQ PHYSICIAN    SERV DATE      MRN           PATIENT NAME          TEST DESCRIPTION          CDM       CPT4            AM\
OUNT\
", col 00, head1, row + 1,
     col 00, head2, row + 1,
     col 00, head3, row + 1,
     col 00, head4, row + 1,
     col 00, "Account #:", col 11,
     t01_account_nbr"###############", col 95, head5,
     row + 1, col 95, head6,
     row + 1, col 00, reply->client_desc,
     row + 1, col 00, street_addr,
     col 95, "Charge As of: ", col 109,
     print_date, row + 1, col 95,
     head7
     IF (trim(reply->street_addr2) != "")
      col 00, street_addr2"######################################", row + 1
     ENDIF
     IF (trim(reply->street_addr3) != "")
      col 00, street_addr3"######################################", row + 1
     ENDIF
     col 00, city, col 25,
     state, col 35, zipcode,
     col 95, t01_service_dt_tm"DD-MMM-YY;R;DATE", " TO ",
     print_date, row + 1, row + 1,
     col 00, head10, row + 1
    HEAD PAGE
     col 00, eqline130, row + 1
    HEAD t01_ord_phys_name
     IF (first_time != "Y")
      fin_accum_cnt = 0, fin_accum_amt = 0.00, fin_accum_qty = 0,
      row + 1, col 65, "Physician Subtotal",
      col 90, dr_accum_cnt"######", col 105,
      dr_accum_amt"######.##", dr_accum_cnt = 0, dr_accum_amt = 0.00,
      dr_accum_qty = 0, row + 2, phys_br = "Y"
     ENDIF
    HEAD t01_fin
     IF (first_time != "Y"
      AND phys_br="N")
      fin_accum_cnt = 0, fin_accum_amt = 0.00, fin_accum_qty = 0,
      row + 2
     ENDIF
    DETAIL
     first_time = "N", phys_br = "N"
     IF (((row+ 12) > maxrow))
      BREAK
     ENDIF
     IF ((reply->charge_qual > 0))
      phys_name = substring(1,15,reply->charge[d.seq].ord_phys_name), col 0, phys_name,
      col 17, reply->charge[d.seq].service_dt_tm"MM/DD/YY;R;DATE", i = 0,
      stopx = cnvtint(size(t01_med_nbr)), stopi = cnvtint(size(t01_med_nbr))
      FOR (i = 1 TO stopx)
        IF (substring(i,1,t01_med_nbr)=" ")
         stopi = (i - 1), i = cnvtint(size(t01_med_nbr))
        ENDIF
      ENDFOR
      spcs = 0
      IF (stopi > 13)
       mrn8 = substring((stopi - 12),13,t01_med_nbr), mrnc = 29
      ELSE
       mrn8 = substring(1,stopi,t01_med_nbr), mrnc = ((29+ 13) - stopi)
      ENDIF
      col mrnc, mrn8, col 46,
      reply->charge[d.seq].person_name, desc2 = fillstring(25," ")
      IF ((reply->charge[d.seq].charge_description > " "))
       desc2 = reply->charge[d.seq].charge_description
      ENDIF
      col 68, desc2, desc3 = fillstring(10," ")
      IF ((reply->charge[d.seq].prim_cdm > " "))
       desc3 = reply->charge[d.seq].prim_cdm
      ENDIF
      col 94, desc3, desc4 = fillstring(10," ")
      IF ((reply->charge[d.seq].prim_cpt > " "))
       desc4 = reply->charge[d.seq].prim_cpt
      ENDIF
      col 104, desc4, col 118,
      reply->charge[d.seq].item_extended_price"#####.##", bfa_accum_cnt = (bfa_accum_cnt+ 1),
      bfa_accum_amt = (bfa_accum_amt+ reply->charge[d.seq].item_extended_price),
      bfa_accum_qty = (bfa_accum_qty+ reply->charge[d.seq].item_quantity), fin_accum_cnt = (
      fin_accum_cnt+ 1), fin_accum_amt = (fin_accum_amt+ reply->charge[d.seq].item_extended_price),
      fin_accum_qty = (fin_accum_qty+ reply->charge[d.seq].item_quantity), dr_accum_cnt = (
      dr_accum_cnt+ 1), dr_accum_amt = (dr_accum_amt+ reply->charge[d.seq].item_extended_price),
      dr_accum_qty = (dr_accum_qty+ reply->charge[d.seq].item_quantity), page_accum_cnt = (
      page_accum_cnt+ 1), page_accum_amt = (page_accum_amt+ reply->charge[d.seq].item_extended_price),
      page_accum_qty = (page_accum_qty+ reply->charge[d.seq].item_quantity), rec_cnt = (rec_cnt+ 1),
      row + 1
     ENDIF
    FOOT PAGE
     IF ((rec_cnt=reply->charge_qual))
      row + 1, col 60, "Physician Subtotal",
      col 100, dr_accum_amt"######.##", col 80,
      dr_accum_cnt"######"
     ENDIF
     row 53, col 05, page_accum_cnt"#######",
     col 14, "Transactions For Page", col 100,
     page_accum_amt"######.##", row + 1
     IF ((rec_cnt=reply->charge_qual))
      col 05, bfa_accum_cnt"#######", col 14,
      "Transactions For Client", col 100, bfa_accum_amt"######.##",
      CALL echo(build("Total for Detail report: ",bfa_accum_amt))
     ENDIF
     row + 1, col 01, "Printed: ",
     col 10, curdate"DDMMMYY;;D", col 18,
     curtime"HH:MM;;M", col 25, "By: ",
     col 29, curuser"######", col 114,
     "Page: ", col 120, curpage"###",
     page_accum_cnt = 0, page_accum_amt = 0, page_accum_qty = 0,
     pagecount = curpage
    WITH nocounter, compress
   ;end select
 END ;Subroutine
 SUBROUTINE get_type_loc(type_loc)
   SELECT INTO "nl:"
    a.parent_service_resource_cd, b.cdf_meaning, b.display
    FROM resource_group a,
     code_value b
    WHERE a.child_service_resource_cd=start_loc_cd
     AND b.code_value=a.parent_service_resource_cd
     AND b.code_set=221
    DETAIL
     start_loc_cd = a.parent_service_resource_cd
     IF (b.cdf_meaning=type_loc)
      found_loc = "Y", loc_desc = b.display
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 FREE SET dt
 FREE SET batchrequest
 FREE SET outputlist
END GO

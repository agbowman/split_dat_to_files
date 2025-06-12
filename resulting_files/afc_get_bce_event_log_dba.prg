CREATE PROGRAM afc_get_bce_event_log:dba
 SET afc_get_bce_event_log = "206202.FT.021"
 RECORD reply(
   1 bce_event_log_qual = i4
   1 bce_event_log[*]
     2 abn_status_cd = f8
     2 accession = vc
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 batch_num = f8
     2 bce_event_log_id = f8
     2 bill_item_id = f8
     2 charge_description = vc
     2 charge_type_cd = f8
     2 code_modifier1_cd = f8
     2 code_modifier2_cd = f8
     2 code_modifier3_cd = f8
     2 code_modifier4_cd = f8
     2 department_cd = f8
     2 department_disp = vc
     2 diag_code1 = vc
     2 diag_code1_desc = vc
     2 diag_code2 = vc
     2 diag_code2_desc = vc
     2 diag_code3 = vc
     2 diag_code3_desc = vc
     2 diag_code4 = vc
     2 diag_code4_desc = vc
     2 diag_code5 = vc
     2 diag_code5_desc = vc
     2 diag_code6 = vc
     2 diag_code6_desc = vc
     2 diag_code7 = vc
     2 diag_code7_desc = vc
     2 encntr_id = f8
     2 ext_master_event_id = f8
     2 ext_master_event_cont_cd = f8
     2 epsdt_ind = i2
     2 institution_cd = f8
     2 institution_disp = vc
     2 level5_cd = f8
     2 level5_disp = vc
     2 ord_phys_id = f8
     2 ord_phys_name = vc
     2 perf_loc_cd = f8
     2 perf_loc_disp = vc
     2 person_id = f8
     2 person_name = vc
     2 price = f8
     2 quantity = f8
     2 reason_cd = f8
     2 reason_comment = vc
     2 ref_phys_id = f8
     2 ref_phys_name = vc
     2 ren_phys_id = f8
     2 ren_phys_name = vc
     2 section_cd = f8
     2 section_disp = vc
     2 service_dt_tm = dq8
     2 submit_ind = i2
     2 misc_ind = i2
     2 subsection_cd = f8
     2 subsection_disp = vc
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 mode_ind = i2
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_description = vc
     2 ext_short_desc = vc
     2 ext_owner_cd = f8
     2 misc_ind = i2
     2 bill_code_txt = vc
     2 batch_alias = vc
     2 batch_description = vc
     2 batch_dt_tm = dq8
     2 payment_amt = f8
     2 adjustment_amt = f8
     2 prompts[*]
       3 bce_event_bill_mod_reltn_id = f8
       3 bill_mod_id = f8
       3 prompt_value = vc
       3 key1_id = f8
       3 bim1_int = f8
       3 bim_ind = i2
     2 person_demographics[1]
       3 mrn = vc
       3 fin = vc
       3 ssn = vc
       3 reg_dt_tm = dq8
       3 disch_dt_tm = dq8
       3 location = vc
       3 attending_physician = vc
       3 sex = vc
       3 age = vc
       3 date_of_birth = dq8
       3 encounter_type = vc
       3 financial_class = vc
       3 health_plan = vc
       3 organization_id = f8
       3 loc_nurse_unit_cd = f8
       3 fin_class_cd = f8
       3 health_plan_id = f8
       3 encntr_type_cd = f8
       3 perf_loc_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET count1 = 0
 SET count2 = 0
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE stat = i2
 SET code_set = 4
 SET cdf_meaning = "MRN"
 DECLARE mrn = f8
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,mrn)
 SET code_set = 4
 SET cdf_meaning = "SSN"
 DECLARE ssn = f8
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,ssn)
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 DECLARE fin = f8
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,fin)
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 DECLARE attenddoc = f8
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,attenddoc)
 DECLARE charge_entry = f8
 SET code_set = 13016
 SET cdf_meaning = "CHARGE ENTRY"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,charge_entry)
 DECLARE modestring = vc
 IF ((request->mode_ind=0))
  SET modestring = "bel.mode_ind in (0,NULL)"
 ELSE
  SET modestring = "bel.mode_ind = 1"
 ENDIF
 IF ((request->unsubmitted_ind=1))
  SELECT INTO "nl:"
   bel.batch_num
   FROM bce_event_log bel
   WHERE bel.submit_ind IN (0, null)
    AND ((bel.active_ind+ 0)=1)
   ORDER BY bel.batch_num
   HEAD bel.batch_num
    count1 = (count1+ 1), stat = alterlist(reply->bce_event_log,count1), reply->bce_event_log[count1]
    .batch_num = bel.batch_num
   DETAIL
    count1 = count1
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(request)
 IF (((trim(request->batch_alias) != "") OR ((request->unsubmitted_ind=0))) )
  SELECT
   IF (trim(request->batch_alias) != "")INTO "nl:"
    FROM bce_event_log bel
    WHERE bel.batch_alias_key=cnvtupper(cnvtalphanum(request->batch_alias))
     AND ((bel.active_ind+ 0)=1)
     AND parser(modestring)
     AND bel.mode_ind IN (0, null)
   ELSEIF ((request->unsubmitted_ind=0))INTO "nl:"
    FROM bce_event_log bel
    WHERE bel.submit_ind IN (0, null)
     AND (bel.batch_num=request->batch_num)
     AND parser(modestring)
     AND bel.active_ind=1
   ELSE
   ENDIF
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->bce_event_log,count1), reply->bce_event_log[count1]
    .accession = bel.accession,
    reply->bce_event_log[count1].active_ind = bel.active_ind, reply->bce_event_log[count1].batch_num
     = bel.batch_num, reply->bce_event_log[count1].bce_event_log_id = bel.bce_event_log_id,
    reply->bce_event_log[count1].bill_item_id = bel.bill_item_id, reply->bce_event_log[count1].
    charge_description = bel.charge_description, reply->bce_event_log[count1].charge_type_cd = bel
    .charge_type_cd,
    reply->bce_event_log[count1].code_modifier1_cd = bel.code_modifier1_cd, reply->bce_event_log[
    count1].code_modifier2_cd = bel.code_modifier2_cd, reply->bce_event_log[count1].code_modifier3_cd
     = bel.code_modifier3_cd,
    reply->bce_event_log[count1].code_modifier4_cd = bel.code_modifier4_cd, reply->bce_event_log[
    count1].department_cd = bel.department_cd, reply->bce_event_log[count1].department_disp =
    uar_get_code_display(bel.department_cd),
    reply->bce_event_log[count1].diag_code1 = bel.diag_code1, reply->bce_event_log[count1].
    diag_code1_desc = bel.diag_code1_desc, reply->bce_event_log[count1].diag_code2 = bel.diag_code2,
    reply->bce_event_log[count1].diag_code2_desc = bel.diag_code2_desc, reply->bce_event_log[count1].
    diag_code3 = bel.diag_code3, reply->bce_event_log[count1].diag_code3_desc = bel.diag_code3_desc,
    reply->bce_event_log[count1].diag_code4 = bel.diag_code4, reply->bce_event_log[count1].
    diag_code4_desc = bel.diag_code4_desc, reply->bce_event_log[count1].diag_code5 = bel.diag_code5,
    reply->bce_event_log[count1].diag_code5_desc = bel.diag_code5_desc, reply->bce_event_log[count1].
    diag_code6 = bel.diag_code6, reply->bce_event_log[count1].diag_code6_desc = bel.diag_code6_desc,
    reply->bce_event_log[count1].diag_code7 = bel.diag_code7, reply->bce_event_log[count1].
    diag_code7_desc = bel.diag_code7_desc, reply->bce_event_log[count1].encntr_id = bel.encntr_id,
    reply->bce_event_log[count1].epsdt_ind = bel.epsdt_ind, reply->bce_event_log[count1].
    ext_master_event_id = bel.ext_master_event_id, reply->bce_event_log[count1].institution_cd = bel
    .institution_cd,
    reply->bce_event_log[count1].institution_disp = uar_get_code_display(bel.institution_cd), reply->
    bce_event_log[count1].level5_cd = bel.level5_cd, reply->bce_event_log[count1].level5_disp =
    uar_get_code_display(bel.level5_cd),
    reply->bce_event_log[count1].ord_phys_id = bel.ord_phys_id, reply->bce_event_log[count1].
    perf_loc_cd = bel.perf_loc_cd, reply->bce_event_log[count1].perf_loc_disp = uar_get_code_display(
     bel.perf_loc_cd),
    reply->bce_event_log[count1].person_id = bel.person_id, reply->bce_event_log[count1].price = bel
    .price, reply->bce_event_log[count1].quantity = bel.quantity,
    reply->bce_event_log[count1].reason_cd = bel.reason_cd, reply->bce_event_log[count1].
    reason_comment = bel.reason_comment, reply->bce_event_log[count1].ref_phys_id = bel.ref_phys_id,
    reply->bce_event_log[count1].ren_phys_id = bel.ren_phys_id, reply->bce_event_log[count1].
    section_cd = bel.section_cd, reply->bce_event_log[count1].section_disp = uar_get_code_display(bel
     .section_cd),
    reply->bce_event_log[count1].service_dt_tm = bel.service_dt_tm, reply->bce_event_log[count1].
    submit_ind = bel.submit_ind, reply->bce_event_log[count1].misc_ind = bel.misc_ind,
    reply->bce_event_log[count1].subsection_cd = bel.subsection_cd, reply->bce_event_log[count1].
    subsection_disp = uar_get_code_display(bel.subsection_cd), reply->bce_event_log[count1].
    updt_applctx = bel.updt_applctx,
    reply->bce_event_log[count1].updt_cnt = bel.updt_cnt, reply->bce_event_log[count1].updt_dt_tm =
    bel.updt_dt_tm, reply->bce_event_log[count1].updt_id = bel.updt_id,
    reply->bce_event_log[count1].updt_task = bel.updt_task, reply->bce_event_log[count1].mode_ind =
    bel.mode_ind, reply->bce_event_log[count1].bill_code_txt = bel.bill_code_txt,
    reply->bce_event_log[count1].ext_master_event_cont_cd = charge_entry, reply->bce_event_log[count1
    ].batch_alias = bel.batch_alias, reply->bce_event_log[count1].batch_description = bel
    .batch_description,
    reply->bce_event_log[count1].batch_dt_tm = bel.batch_dt_tm, reply->bce_event_log[count1].
    payment_amt = bel.payment_amt, reply->bce_event_log[count1].adjustment_amt = bel.adjustment_amt
   WITH nocounter
  ;end select
 ENDIF
 SET reply->bce_event_log_qual = count1
 SET stat = alterlist(reply->bce_event_log,count1)
 CALL echo(build("count1 is ",count1))
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BCE_EVENT_LOG"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->bce_event_log_qual > 0)
  AND (request->unsubmitted_ind < 1))
  DECLARE new_list_size = i4
  DECLARE cur_list_size = i4
  DECLARE batch_size = i4 WITH constant(50)
  DECLARE nstart = i4
  DECLARE loop_cnt = i4
  DECLARE num1 = i4 WITH noconstant(0)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].person_id = reply->bce_event_log[cur_list_size].person_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    person p
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),p.person_id,reply->bce_event_log[idx].
     person_id))
   DETAIL
    index = locateval(num1,1,cur_list_size,p.person_id,reply->bce_event_log[num1].person_id)
    WHILE (index != 0)
      reply->bce_event_log[index].person_name = p.name_full_formatted, reply->bce_event_log[index].
      person_demographics[1].date_of_birth = p.birth_dt_tm, reply->bce_event_log[index].
      person_demographics[1].age = cnvtage(p.birth_dt_tm),
      reply->bce_event_log[index].person_demographics[1].sex = uar_get_code_display(p.sex_cd), index
       = locateval(num1,(index+ 1),cur_list_size,p.person_id,reply->bce_event_log[num1].person_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].ord_phys_id = reply->bce_event_log[cur_list_size].ord_phys_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    prsnl p
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),p.person_id,reply->bce_event_log[idx].
     ord_phys_id))
   DETAIL
    index = locateval(num1,1,cur_list_size,p.person_id,reply->bce_event_log[num1].ord_phys_id)
    WHILE (index != 0)
     reply->bce_event_log[index].ord_phys_name = p.name_full_formatted,index = locateval(num1,(index
      + 1),cur_list_size,p.person_id,reply->bce_event_log[num1].ord_phys_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].ren_phys_id = reply->bce_event_log[cur_list_size].ren_phys_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    prsnl p
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),p.person_id,reply->bce_event_log[idx].
     ren_phys_id))
   DETAIL
    index = locateval(num1,1,cur_list_size,p.person_id,reply->bce_event_log[num1].ren_phys_id)
    WHILE (index != 0)
     reply->bce_event_log[index].ren_phys_name = p.name_full_formatted,index = locateval(num1,(index
      + 1),cur_list_size,p.person_id,reply->bce_event_log[num1].ren_phys_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].ref_phys_id = reply->bce_event_log[cur_list_size].ref_phys_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    prsnl p
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),p.person_id,reply->bce_event_log[idx].
     ref_phys_id))
   DETAIL
    index = locateval(num1,1,cur_list_size,p.person_id,reply->bce_event_log[num1].ref_phys_id)
    WHILE (index != 0)
     reply->bce_event_log[index].ref_phys_name = p.name_full_formatted,index = locateval(num1,(index
      + 1),cur_list_size,p.person_id,reply->bce_event_log[num1].ref_phys_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].person_id = reply->bce_event_log[cur_list_size].person_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    person_alias pa
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (pa
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pa.person_id,reply->bce_event_log[idx].
     person_id)
     AND ((pa.person_alias_type_cd=mrn) OR (pa.person_alias_type_cd=ssn))
     AND pa.active_ind=1)
   DETAIL
    index = locateval(num1,1,cur_list_size,pa.person_id,reply->bce_event_log[num1].person_id)
    WHILE (index != 0)
     IF (pa.person_alias_type_cd=mrn)
      reply->bce_event_log[index].person_demographics[1].mrn = pa.alias
     ELSEIF (pa.person_alias_type_cd=ssn)
      reply->bce_event_log[index].person_demographics[1].ssn = cnvtalias(pa.alias,pa.alias_pool_cd)
     ENDIF
     ,index = locateval(num1,(index+ 1),cur_list_size,pa.person_id,reply->bce_event_log[num1].
      person_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].encntr_id = reply->bce_event_log[cur_list_size].encntr_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    encntr_alias ea
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (ea
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ea.encntr_id,reply->bce_event_log[idx].
     encntr_id)
     AND ea.encntr_alias_type_cd=fin
     AND ea.active_ind=1)
   DETAIL
    index = locateval(num1,1,cur_list_size,ea.encntr_id,reply->bce_event_log[num1].encntr_id)
    WHILE (index != 0)
     reply->bce_event_log[index].person_demographics[1].fin = ea.alias,index = locateval(num1,(index
      + 1),cur_list_size,ea.encntr_id,reply->bce_event_log[num1].encntr_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].encntr_id = reply->bce_event_log[cur_list_size].encntr_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    encounter e
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (e
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),e.encntr_id,reply->bce_event_log[idx].
     encntr_id)
     AND e.active_ind=1)
   DETAIL
    index = locateval(num1,1,cur_list_size,e.encntr_id,reply->bce_event_log[num1].encntr_id)
    WHILE (index != 0)
      reply->bce_event_log[index].person_demographics[1].reg_dt_tm = e.reg_dt_tm, reply->
      bce_event_log[index].person_demographics[1].disch_dt_tm = e.disch_dt_tm, reply->bce_event_log[
      index].person_demographics[1].location = build(uar_get_code_display(e.loc_nurse_unit_cd),";",
       uar_get_code_display(e.loc_room_cd),";",uar_get_code_display(e.loc_bed_cd)),
      reply->bce_event_log[index].person_demographics[1].encounter_type = uar_get_code_display(e
       .encntr_type_cd), reply->bce_event_log[index].person_demographics[1].financial_class =
      uar_get_code_display(e.financial_class_cd), reply->bce_event_log[index].person_demographics[1].
      organization_id = e.organization_id,
      reply->bce_event_log[index].person_demographics[1].loc_nurse_unit_cd = e.loc_nurse_unit_cd,
      reply->bce_event_log[index].person_demographics[1].fin_class_cd = e.financial_class_cd, reply->
      bce_event_log[index].person_demographics[1].encntr_type_cd = e.encntr_type_cd,
      reply->bce_event_log[index].person_demographics[1].perf_loc_cd = e.location_cd, index =
      locateval(num1,(index+ 1),cur_list_size,e.encntr_id,reply->bce_event_log[num1].encntr_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].encntr_id = reply->bce_event_log[cur_list_size].encntr_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    encntr_prsnl_reltn epr,
    prsnl p
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (epr
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),epr.encntr_id,reply->bce_event_log[idx].
     encntr_id)
     AND epr.encntr_prsnl_r_cd=attenddoc
     AND epr.active_ind=1)
    JOIN (p
    WHERE p.person_id=epr.prsnl_person_id)
   DETAIL
    index = locateval(num1,1,cur_list_size,epr.encntr_id,reply->bce_event_log[num1].encntr_id)
    WHILE (index != 0)
     reply->bce_event_log[index].person_demographics[1].attending_physician = p.name_full_formatted,
     index = locateval(num1,(index+ 1),cur_list_size,epr.encntr_id,reply->bce_event_log[num1].
      encntr_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].encntr_id = reply->bce_event_log[cur_list_size].encntr_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    encntr_plan_reltn e,
    health_plan h
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (e
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),e.encntr_id,reply->bce_event_log[idx].
     encntr_id)
     AND e.priority_seq=1
     AND e.active_ind=1)
    JOIN (h
    WHERE h.health_plan_id=e.health_plan_id)
   DETAIL
    index = locateval(num1,1,cur_list_size,e.encntr_id,reply->bce_event_log[num1].encntr_id)
    WHILE (index != 0)
      reply->bce_event_log[index].person_demographics[1].health_plan = h.plan_name, reply->
      bce_event_log[index].person_demographics[1].health_plan_id = h.health_plan_id, index =
      locateval(num1,(index+ 1),cur_list_size,e.encntr_id,reply->bce_event_log[num1].encntr_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].bill_item_id = reply->bce_event_log[cur_list_size].bill_item_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    bill_item b
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (b
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),b.bill_item_id,reply->bce_event_log[idx].
     bill_item_id))
   DETAIL
    index = locateval(num1,1,cur_list_size,b.bill_item_id,reply->bce_event_log[num1].bill_item_id)
    WHILE (index != 0)
      reply->bce_event_log[index].ext_parent_reference_id = b.ext_parent_reference_id, reply->
      bce_event_log[index].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->
      bce_event_log[index].ext_child_reference_id = b.ext_child_reference_id,
      reply->bce_event_log[index].ext_child_contributor_cd = b.ext_child_contributor_cd, reply->
      bce_event_log[index].ext_description = b.ext_description, reply->bce_event_log[index].
      ext_short_desc = b.ext_short_desc,
      reply->bce_event_log[index].ext_owner_cd = b.ext_owner_cd, reply->bce_event_log[index].misc_ind
       = b.misc_ind, index = locateval(num1,(index+ 1),cur_list_size,b.bill_item_id,reply->
       bce_event_log[num1].bill_item_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
  SET cur_list_size = size(reply->bce_event_log,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->bce_event_log,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET reply->bce_event_log[idx].bce_event_log_id = reply->bce_event_log[cur_list_size].
    bce_event_log_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    bce_event_bill_mod_reltn ber,
    bill_item_modifier bim
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (ber
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ber.bce_event_log_id,reply->bce_event_log[idx]
     .bce_event_log_id))
    JOIN (bim
    WHERE bim.bill_item_mod_id=ber.bill_item_mod_id)
   ORDER BY ber.bce_event_log_id
   HEAD ber.bce_event_log_id
    count2 = 0
   DETAIL
    index = locateval(num1,1,cur_list_size,ber.bce_event_log_id,reply->bce_event_log[num1].
     bce_event_log_id)
    WHILE (index != 0)
      count2 = (count2+ 1), stat = alterlist(reply->bce_event_log[index].prompts,count2), reply->
      bce_event_log[index].prompts[count2].bce_event_bill_mod_reltn_id = ber
      .bce_event_bill_mod_reltn_id,
      reply->bce_event_log[index].prompts[count2].bill_mod_id = ber.bill_item_mod_id, reply->
      bce_event_log[index].prompts[count2].key1_id = bim.key1_id, reply->bce_event_log[index].
      prompts[count2].bim1_int = bim.bim1_ind,
      reply->bce_event_log[index].prompts[count2].bim_ind = bim.bim_ind, reply->bce_event_log[index].
      prompts[count2].prompt_value = ber.prompt_value, index = locateval(num1,(index+ 1),
       cur_list_size,ber.bce_event_log_id,reply->bce_event_log[num1].bce_event_log_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->bce_event_log,cur_list_size)
 ENDIF
END GO

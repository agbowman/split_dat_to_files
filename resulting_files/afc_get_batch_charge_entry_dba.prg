CREATE PROGRAM afc_get_batch_charge_entry:dba
 SET afc_get_batch_charge_entry = "78042.FT.002"
 RECORD bce(
   1 bce_qual = i4
   1 qual[*]
     2 ext_master_event_id = f8
     2 ext_master_event_cont_cd = f8
     2 ext_master_reference_id = f8
     2 ext_master_reference_cont_cd = f8
     2 order_mnemonic = vc
     2 mnemonic = vc
     2 activity_type_disp = vc
     2 bce_event_log_id = f8
     2 person_id = f8
     2 name_full_formatted = c100
     2 encntr_id = f8
     2 perf_loc_cd = f8
     2 ren_phys_id = f8
     2 ord_phys_id = f8
     2 ref_phys_id = f8
     2 accession = vc
     2 bill_item_id = f8
     2 charge_description = vc
     2 service_dt_tm = dq8
     2 quantity = f8
     2 diag_code1 = vc
     2 diag_code1_desc = vc
     2 nomen1_id = f8
     2 diag_code2 = vc
     2 diag_code2_desc = vc
     2 nomen2_id = f8
     2 diag_code3 = vc
     2 diag_code3_desc = vc
     2 nomen3_id = f8
     2 diag_code4 = vc
     2 diag_code4_desc = vc
     2 nomen4_id = f8
     2 diag_code5 = vc
     2 diag_code5_desc = vc
     2 nomen5_id = f8
     2 diag_code6 = vc
     2 diag_code6_desc = vc
     2 nomen6_id = f8
     2 diag_code7 = vc
     2 diag_code7_desc = vc
     2 nomen7_id = f8
     2 abn_status_cd = f8
     2 price = f8
     2 epsdt_ind = i2
     2 code_modifier1_cd = f8
     2 code_modifier2_cd = f8
     2 code_modifier3_cd = f8
     2 code_modifier4_cd = f8
     2 reason_cd = f8
     2 reason_comment = vc
     2 charge_type_cd = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 misc_ind = i2
     2 found_ind = i2
 )
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE 13019_billcode = f8
 DECLARE 14002_icd9 = f8
 DECLARE 14002_modifier = f8
 DECLARE 13019_userdef = f8
 DECLARE 17809_userdef = f8
 DECLARE ref_cont_cd = f8
 DECLARE complete_event = f8
 DECLARE charge_entry = f8
 DECLARE cea_ordering_type_cd = f8
 DECLARE cea_verifying_type_cd = f8
 DECLARE cea_referred_type_cd = f8
 DECLARE pesonname(dpersonid=f8) = c100
 SET count1 = 0
 SET count2 = 0
 SET nloopcount = 0
 SET prsnl_qual = 0
 SET found_count = 0
 SET not_found_count = 0
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,13019_billcode)
 SET code_set = 14002
 SET cdf_meaning = "ICD9"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,14002_icd9)
 SET code_set = 14002
 SET cdf_meaning = "MODIFIER"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,14002_modifier)
 SET code_set = 13019
 SET cdf_meaning = "USER DEF"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,13019_userdef)
 SET code_set = 17809
 SET cdf_meaning = "USER DEF"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,17809_userdef)
 SET code_set = 13029
 SET cdf_meaning = "COMPLETE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,complete_event)
 SET code_set = 13016
 SET cdf_meaning = "CHARGE ENTRY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,charge_entry)
 SET code_set = 13029
 SET cdf_meaning = "ORDERED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,cea_ordering_type_cd)
 SET code_set = 13029
 SET cdf_meaning = "VERIFIED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,cea_verifying_type_cd)
 SET code_set = 13029
 SET cdf_meaning = "REFERRED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,cea_referred_type_cd)
 SELECT INTO "nl:"
  FROM bce_event_log bel,
   bill_item b
  PLAN (bel
   WHERE bel.service_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND bel.active_ind=1)
   JOIN (b
   WHERE b.bill_item_id=bel.bill_item_id)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(bce->qual,count1), bce->qual[count1].bce_event_log_id = bel
   .bce_event_log_id,
   bce->qual[count1].ext_master_event_id = bel.ext_master_event_id, bce->qual[count1].
   ext_master_event_cont_cd = charge_entry, bce->qual[count1].ext_master_reference_id = b
   .ext_parent_reference_id,
   bce->qual[count1].ext_master_reference_cont_cd = b.ext_parent_contributor_cd, bce->qual[count1].
   order_mnemonic = b.ext_description, bce->qual[count1].mnemonic = b.ext_short_desc,
   bce->qual[count1].activity_type_disp = uar_get_code_display(b.ext_owner_cd), bce->qual[count1].
   person_id = bel.person_id, bce->qual[count1].encntr_id = bel.encntr_id,
   bce->qual[count1].perf_loc_cd = bel.perf_loc_cd, bce->qual[count1].ren_phys_id = bel.ren_phys_id,
   bce->qual[count1].ord_phys_id = bel.ord_phys_id,
   bce->qual[count1].ref_phys_id = bel.ref_phys_id, bce->qual[count1].accession = bel.accession, bce
   ->qual[count1].bill_item_id = bel.bill_item_id,
   bce->qual[count1].charge_description = bel.charge_description, bce->qual[count1].service_dt_tm =
   cnvtdatetime(bel.service_dt_tm), bce->qual[count1].quantity = bel.quantity,
   bce->qual[count1].diag_code1 = bel.diag_code1, bce->qual[count1].diag_code1_desc = bel
   .diag_code1_desc, bce->qual[count1].diag_code2 = bel.diag_code2,
   bce->qual[count1].diag_code2_desc = bel.diag_code2_desc, bce->qual[count1].diag_code3 = bel
   .diag_code3, bce->qual[count1].diag_code3_desc = bel.diag_code3_desc,
   bce->qual[count1].diag_code4 = bel.diag_code4, bce->qual[count1].diag_code4_desc = bel
   .diag_code4_desc, bce->qual[count1].diag_code5 = bel.diag_code5,
   bce->qual[count1].diag_code5_desc = bel.diag_code5_desc, bce->qual[count1].diag_code6 = bel
   .diag_code6, bce->qual[count1].diag_code6_desc = bel.diag_code6_desc,
   bce->qual[count1].diag_code7 = bel.diag_code7, bce->qual[count1].diag_code7_desc = bel
   .diag_code7_desc, bce->qual[count1].abn_status_cd = bel.abn_status_cd,
   bce->qual[count1].price = bel.price, bce->qual[count1].epsdt_ind = bel.epsdt_ind, bce->qual[count1
   ].code_modifier1_cd = bel.code_modifier1_cd,
   bce->qual[count1].code_modifier2_cd = bel.code_modifier2_cd, bce->qual[count1].code_modifier3_cd
    = bel.code_modifier3_cd, bce->qual[count1].code_modifier4_cd = bel.code_modifier4_cd,
   bce->qual[count1].reason_cd = bel.reason_cd, bce->qual[count1].reason_comment = bel.reason_comment,
   bce->qual[count1].charge_type_cd = bel.charge_type_cd,
   bce->qual[count1].institution_cd = bel.institution_cd, bce->qual[count1].department_cd = bel
   .department_cd, bce->qual[count1].section_cd = bel.section_cd,
   bce->qual[count1].subsection_cd = bel.subsection_cd, bce->qual[count1].level5_cd = bel.level5_cd,
   bce->qual[count1].misc_ind = bel.misc_ind
  WITH nocounter
 ;end select
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant(20)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE num1 = i4 WITH noconstant(0)
 SET cur_list_size = size(bce->qual,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(bce->qual,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET bce->qual[idx].person_id = bce->qual[cur_list_size].person_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   person p
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (p
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),p.person_id,bce->qual[idx].person_id))
  DETAIL
   index = locateval(num1,nstart,(nstart+ (batch_size - 1)),p.person_id,bce->qual[num1].person_id)
   WHILE (index != 0)
    bce->qual[index].name_full_formatted = p.name_full_formatted,index = locateval(num1,(index+ 1),(
     nstart+ (batch_size - 1)),p.person_id,bce->qual[num1].person_id)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(bce->qual,cur_list_size)
 CALL echorecord(bce)
 SET bce->bce_qual = count1
 IF (count1 > 0)
  FOR (nloopcount = 1 TO bce->bce_qual)
    IF (trim(bce->qual[nloopcount].diag_code1) != "")
     SELECT INTO "nl:"
      FROM nomenclature n
      WHERE (n.source_identifier=bce->qual[nloopcount].diag_code1)
       AND n.active_ind=1
      DETAIL
       bce->qual[nloopcount].nomen1_id = n.nomenclature_id
      WITH nocounter
     ;end select
    ENDIF
    IF (trim(bce->qual[nloopcount].diag_code2) != "")
     SELECT INTO "nl:"
      FROM nomenclature n
      WHERE (n.source_identifier=bce->qual[nloopcount].diag_code2)
       AND n.active_ind=1
      DETAIL
       bce->qual[nloopcount].nomen2_id = n.nomenclature_id
      WITH nocounter
     ;end select
    ENDIF
    IF (trim(bce->qual[nloopcount].diag_code3) != "")
     SELECT INTO "nl:"
      FROM nomenclature n
      WHERE (n.source_identifier=bce->qual[nloopcount].diag_code3)
       AND n.active_ind=1
      DETAIL
       bce->qual[nloopcount].nomen3_id = n.nomenclature_id
      WITH nocounter
     ;end select
    ENDIF
    IF (trim(bce->qual[nloopcount].diag_code4) != "")
     SELECT INTO "nl:"
      FROM nomenclature n
      WHERE (n.source_identifier=bce->qual[nloopcount].diag_code4)
       AND n.active_ind=1
      DETAIL
       bce->qual[nloopcount].nomen4_id = n.nomenclature_id
      WITH nocounter
     ;end select
    ENDIF
    IF (trim(bce->qual[nloopcount].diag_code5) != "")
     SELECT INTO "nl:"
      FROM nomenclature n
      WHERE (n.source_identifier=bce->qual[nloopcount].diag_code5)
       AND n.active_ind=1
      DETAIL
       bce->qual[nloopcount].nomen5_id = n.nomenclature_id
      WITH nocounter
     ;end select
    ENDIF
    IF (trim(bce->qual[nloopcount].diag_code6) != "")
     SELECT INTO "nl:"
      FROM nomenclature n
      WHERE (n.source_identifier=bce->qual[nloopcount].diag_code6)
       AND n.active_ind=1
      DETAIL
       bce->qual[nloopcount].nomen6_id = n.nomenclature_id
      WITH nocounter
     ;end select
    ENDIF
    IF (trim(bce->qual[nloopcount].diag_code7) != "")
     SELECT INTO "nl:"
      FROM nomenclature n
      WHERE (n.source_identifier=bce->qual[nloopcount].diag_code7)
       AND n.active_ind=1
      DETAIL
       bce->qual[nloopcount].nomen7_id = n.nomenclature_id
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
  SET cur_list_size = size(bce->qual,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(bce->qual,new_list_size)
  SET nstart = 1
  SET num1 = 0
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET bce->qual[idx].ext_master_event_id = bce->qual[cur_list_size].ext_master_event_id
   SET bce->qual[idx].ext_master_reference_id = bce->qual[cur_list_size].ext_master_reference_id
  ENDFOR
  SELECT INTO "nl:"
   FROM charge_event ce,
    charge_event_act cea,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (ce
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ce.ext_m_event_id,bce->qual[idx].
     ext_master_event_id,
     ce.ext_m_reference_id,bce->qual[idx].ext_master_reference_id)
     AND ce.ext_m_event_cont_cd=charge_entry
     AND ce.active_ind=1)
    JOIN (cea
    WHERE (cea.charge_event_id=(ce.charge_event_id+ 0))
     AND ((cea.cea_type_cd+ 0)=complete_event)
     AND cea.active_ind=1)
   DETAIL
    index = locateval(num1,nstart,(nstart+ (batch_size - 1)),ce.ext_m_event_id,bce->qual[num1].
     ext_master_event_id,
     ce.ext_m_reference_id,bce->qual[num1].ext_master_reference_id)
    WHILE (index != 0)
      bce->qual[index].found_ind = 1, found_count = (found_count+ 1), index = locateval(num1,(index+
       1),(nstart+ (batch_size - 1)),ce.ext_m_event_id,bce->qual[num1].ext_master_event_id,
       ce.ext_m_reference_id,bce->qual[num1].ext_master_reference_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(bce->qual,cur_list_size)
  CALL echo(build("number of records found: ",found_count))
  SET count1 = 0
  FOR (nloopcount = 1 TO bce->bce_qual)
    IF ((bce->qual[nloopcount].found_ind=0))
     SET not_found_count = (not_found_count+ 1)
     SET count1 = (count1+ 1)
     SET stat = alterlist(reply->charge_event,count1)
     SET reply->charge_event_qual = count1
     SET reply->charge_event[count1].ext_master_event_id = bce->qual[nloopcount].ext_master_event_id
     SET reply->charge_event[count1].ext_master_event_cont_cd = charge_entry
     SET reply->charge_event[count1].ext_master_reference_id = bce->qual[nloopcount].
     ext_master_reference_id
     SET reply->charge_event[count1].ext_master_reference_cont_cd = bce->qual[nloopcount].
     ext_master_reference_cont_cd
     SET reply->charge_event[count1].ext_parent_event_id = 0.0
     SET reply->charge_event[count1].ext_parent_event_cont_cd = 0.0
     SET reply->charge_event[count1].ext_parent_reference_id = 0.0
     SET reply->charge_event[count1].ext_parent_reference_cont_cd = 0.0
     SET reply->charge_event[count1].ext_item_event_id = bce->qual[nloopcount].ext_master_event_id
     SET reply->charge_event[count1].ext_item_event_cont_cd = charge_entry
     SET reply->charge_event[count1].ext_item_reference_id = bce->qual[nloopcount].
     ext_master_reference_id
     SET reply->charge_event[count1].ext_item_reference_cont_cd = bce->qual[nloopcount].
     ext_master_reference_cont_cd
     SET reply->charge_event[count1].order_mnemonic = bce->qual[nloopcount].order_mnemonic
     SET reply->charge_event[count1].mnemonic = bce->qual[nloopcount].mnemonic
     SET reply->charge_event[count1].activity_type_disp = bce->qual[nloopcount].activity_type_disp
     SET reply->charge_event[count1].person_id = bce->qual[nloopcount].person_id
     SET reply->charge_event[count1].person_name = bce->qual[nloopcount].name_full_formatted
     SET reply->charge_event[count1].encntr_id = bce->qual[nloopcount].encntr_id
     SET reply->charge_event[count1].misc_ind = bce->qual[nloopcount].misc_ind
     SET reply->charge_event[count1].misc_price = bce->qual[nloopcount].price
     SET reply->charge_event[count1].misc_description = bce->qual[nloopcount].charge_description
     SET reply->charge_event[count1].perf_loc_cd = bce->qual[nloopcount].perf_loc_cd
     SET reply->charge_event[count1].accession = bce->qual[nloopcount].accession
     SET reply->charge_event[count1].epsdt_ind = bce->qual[nloopcount].epsdt_ind
     SET reply->charge_event[count1].charge_event_act_qual = 1
     SET stat = alterlist(reply->charge_event[count1].charge_event_act,1)
     SET reply->charge_event[count1].charge_event_act[1].charge_type_cd = bce->qual[nloopcount].
     charge_type_cd
     SET reply->charge_event[count1].charge_event_act[1].quantity = bce->qual[nloopcount].quantity
     SET reply->charge_event[count1].charge_event_act[1].service_dt_tm = cnvtdatetime(bce->qual[
      nloopcount].service_dt_tm)
     SET reply->charge_event[count1].charge_event_act[1].cea_type_cd = complete_event
     SET reply->charge_event[count1].charge_event_act[1].reason_cd = bce->qual[nloopcount].reason_cd
     IF ((bce->qual[nloopcount].level5_cd > 0))
      SET reply->charge_event[count1].charge_event_act[1].service_resource_cd = bce->qual[nloopcount]
      .level5_cd
     ELSEIF ((bce->qual[nloopcount].subsection_cd > 0))
      SET reply->charge_event[count1].charge_event_act[1].service_resource_cd = bce->qual[nloopcount]
      .subsection_cd
     ELSEIF ((bce->qual[nloopcount].section_cd > 0))
      SET reply->charge_event[count1].charge_event_act[1].service_resource_cd = bce->qual[nloopcount]
      .section_cd
     ELSEIF ((bce->qual[nloopcount].department_cd > 0))
      SET reply->charge_event[count1].charge_event_act[1].service_resource_cd = bce->qual[nloopcount]
      .department_cd
     ELSEIF ((bce->qual[nloopcount].institution_cd > 0))
      SET reply->charge_event[count1].charge_event_act[1].service_resource_cd = bce->qual[nloopcount]
      .institution_cd
     ENDIF
     SET prsnl_qual = 0
     IF ((bce->qual[nloopcount].ord_phys_id > 0))
      SET prsnl_qual = (prsnl_qual+ 1)
      SET stat = alterlist(reply->charge_event[count1].charge_event_act[1].prsnl,prsnl_qual)
      SET reply->charge_event[count1].charge_event_act[1].prsnl[prsnl_qual].prsnl_id = bce->qual[
      nloopcount].ord_phys_id
      SET reply->charge_event[count1].charge_event_act[1].prsnl[prsnl_qual].prsnl_type_cd =
      cea_ordering_type_cd
     ENDIF
     IF ((bce->qual[nloopcount].ren_phys_id > 0))
      SET prsnl_qual = (prsnl_qual+ 1)
      SET stat = alterlist(reply->charge_event[count1].charge_event_act[1].prsnl,prsnl_qual)
      SET reply->charge_event[count1].charge_event_act[1].prsnl[prsnl_qual].prsnl_id = bce->qual[
      nloopcount].ren_phys_id
      SET reply->charge_event[count1].charge_event_act[1].prsnl[prsnl_qual].prsnl_type_cd =
      cea_verifying_type_cd
     ENDIF
     IF ((bce->qual[nloopcount].ref_phys_id > 0))
      SET prsnl_qual = (prsnl_qual+ 1)
      SET stat = alterlist(reply->charge_event[count1].charge_event_act[1].prsnl,prsnl_qual)
      SET reply->charge_event[count1].charge_event_act[1].prsnl[prsnl_qual].prsnl_id = bce->qual[
      nloopcount].ref_phys_id
      SET reply->charge_event[count1].charge_event_act[1].prsnl[prsnl_qual].prsnl_type_cd =
      cea_referred_type_cd
     ENDIF
     SET reply->charge_event[count1].charge_event_act[1].prsnl_qual = prsnl_qual
     IF (trim(bce->qual[nloopcount].reason_comment) != "")
      SET count2 = (count2+ 1)
      SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
      SET reply->charge_event[count1].charge_event_mod_qual = count2
      SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
      13019_userdef
      SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 17809_userdef
      SET reply->charge_event[count1].charge_event_mod[count2].field6 = cnvtupper(uar_get_display(
        17809_userdef))
      SET reply->charge_event[count1].charge_event_mod[count2].field7 = bce->qual[nloopcount].comment
     ENDIF
     IF ((bce->qual[nloopcount].code_modifier1_cd > 0))
      SET count2 = (count2+ 1)
      SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
      SET reply->charge_event[count1].charge_event_mod_qual = count2
      SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
      13019_billcode
      SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_modifier
      SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 1
      SET reply->charge_event[count1].charge_event_mod[count2].field3_id = bce->qual[nloopcount].
      code_modifier1_cd
      SET reply->charge_event[count1].charge_event_mod[count2].field6 = uar_get_code_display(bce->
       qual[nloopcount].code_modifier1_cd)
      SET reply->charge_event[count1].charge_event_mod[count2].field7 = uar_get_code_description(bce
       ->qual[nloopcount].code_modifier1_cd)
      IF ((bce->qual[nloopcount].code_modifier2_cd > 0))
       SET count2 = (count2+ 1)
       SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
       SET reply->charge_event[count1].charge_event_mod_qual = count2
       SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
       13019_billcode
       SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_modifier
       SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 2
       SET reply->charge_event[count1].charge_event_mod[count2].field3_id = bce->qual[nloopcount].
       code_modifier2_cd
       SET reply->charge_event[count1].charge_event_mod[count2].field6 = uar_get_code_display(bce->
        qual[nloopcount].code_modifier2_cd)
       SET reply->charge_event[count1].charge_event_mod[count2].field7 = uar_get_code_description(bce
        ->qual[nloopcount].code_modifier2_cd)
       IF ((bce->qual[nloopcount].code_modifier3_cd > 0))
        SET count2 = (count2+ 1)
        SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
        SET reply->charge_event[count1].charge_event_mod_qual = count2
        SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
        13019_billcode
        SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_modifier
        SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 3
        SET reply->charge_event[count1].charge_event_mod[count2].field3_id = bce->qual[nloopcount].
        code_modifier3_cd
        SET reply->charge_event[count1].charge_event_mod[count2].field6 = uar_get_code_display(bce->
         qual[nloopcount].code_modifier3_cd)
        SET reply->charge_event[count1].charge_event_mod[count2].field7 = uar_get_code_description(
         bce->qual[nloopcount].code_modifier3_cd)
        IF ((bce->qual[nloopcount].code_modifier4_cd > 0))
         SET count2 = (count2+ 1)
         SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
         SET reply->charge_event[count1].charge_event_mod_qual = count2
         SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
         13019_billcode
         SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_modifier
         SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 4
         SET reply->charge_event[count1].charge_event_mod[count2].field3_id = bce->qual[nloopcount].
         code_modifier4_cd
         SET reply->charge_event[count1].charge_event_mod[count2].field6 = uar_get_code_display(bce->
          qual[nloopcount].code_modifier4_cd)
         SET reply->charge_event[count1].charge_event_mod[count2].field7 = uar_get_code_description(
          bce->qual[nloopcount].code_modifier4_cd)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF ((bce->qual[nloopcount].nomen1_id > 0))
      SET count2 = (count2+ 1)
      SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
      SET reply->charge_event[count1].charge_event_mod_qual = count2
      SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
      13019_billcode
      SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_icd9
      SET reply->charge_event[count1].charge_event_mod[count2].nomen_id = bce->qual[nloopcount].
      nomen1_id
      SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 1
      SET reply->charge_event[count1].charge_event_mod[count2].field6 = bce->qual[nloopcount].
      diag_code1
      SET reply->charge_event[count1].charge_event_mod[count2].field7 = bce->qual[nloopcount].
      diag_code1_desc
      IF ((bce->qual[nloopcount].nomen2_id > 0))
       SET count2 = (count2+ 1)
       SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
       SET reply->charge_event[count1].charge_event_mod_qual = count2
       SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
       13019_billcode
       SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_icd9
       SET reply->charge_event[count1].charge_event_mod[count2].nomen_id = bce->qual[nloopcount].
       nomen2_id
       SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 2
       SET reply->charge_event[count1].charge_event_mod[count2].field6 = bce->qual[nloopcount].
       diag_code2
       SET reply->charge_event[count1].charge_event_mod[count2].field7 = bce->qual[nloopcount].
       diag_code2_desc
       IF ((bce->qual[nloopcount].nomen3_id > 0))
        SET count2 = (count2+ 1)
        SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
        SET reply->charge_event[count1].charge_event_mod_qual = count2
        SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
        13019_billcode
        SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_icd9
        SET reply->charge_event[count1].charge_event_mod[count2].nomen_id = bce->qual[nloopcount].
        nomen3_id
        SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 3
        SET reply->charge_event[count1].charge_event_mod[count2].field6 = bce->qual[nloopcount].
        diag_code3
        SET reply->charge_event[count1].charge_event_mod[count2].field7 = bce->qual[nloopcount].
        diag_code3_desc
        IF ((bce->qual[nloopcount].nomen4_id > 0))
         SET count2 = (count2+ 1)
         SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
         SET reply->charge_event[count1].charge_event_mod_qual = count2
         SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
         13019_billcode
         SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_icd9
         SET reply->charge_event[count1].charge_event_mod[count2].nomen_id = bce->qual[nloopcount].
         nomen4_id
         SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 4
         SET reply->charge_event[count1].charge_event_mod[count2].field6 = bce->qual[nloopcount].
         diag_code4
         SET reply->charge_event[count1].charge_event_mod[count2].field7 = bce->qual[nloopcount].
         diag_code4_desc
         IF ((bce->qual[nloopcount].nomen5_id > 0))
          SET count2 = (count2+ 1)
          SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
          SET reply->charge_event[count1].charge_event_mod_qual = count2
          SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
          13019_billcode
          SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_icd9
          SET reply->charge_event[count1].charge_event_mod[count2].nomen_id = bce->qual[nloopcount].
          nomen5_id
          SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 5
          SET reply->charge_event[count1].charge_event_mod[count2].field6 = bce->qual[nloopcount].
          diag_code5
          SET reply->charge_event[count1].charge_event_mod[count2].field7 = bce->qual[nloopcount].
          diag_code5_desc
          IF ((bce->qual[nloopcount].nomen6_id > 0))
           SET count2 = (count2+ 1)
           SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
           SET reply->charge_event[count1].charge_event_mod_qual = count2
           SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
           13019_billcode
           SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_icd9
           SET reply->charge_event[count1].charge_event_mod[count2].nomen_id = bce->qual[nloopcount].
           nomen6_id
           SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 6
           SET reply->charge_event[count1].charge_event_mod[count2].field6 = bce->qual[nloopcount].
           diag_code6
           SET reply->charge_event[count1].charge_event_mod[count2].field7 = bce->qual[nloopcount].
           diag_code6_desc
           IF ((bce->qual[nloopcount].nomen7_id > 0))
            SET count2 = (count2+ 1)
            SET stat = alterlist(reply->charge_event[count1].charge_event_mod,count2)
            SET reply->charge_event[count1].charge_event_mod_qual = count2
            SET reply->charge_event[count1].charge_event_mod[count2].charge_event_mod_type_cd =
            13019_billcode
            SET reply->charge_event[count1].charge_event_mod[count2].field1_id = 14002_icd9
            SET reply->charge_event[count1].charge_event_mod[count2].nomen_id = bce->qual[nloopcount]
            .nomen7_id
            SET reply->charge_event[count1].charge_event_mod[count2].field2_id = 7
            SET reply->charge_event[count1].charge_event_mod[count2].field6 = bce->qual[nloopcount].
            diag_code7
            SET reply->charge_event[count1].charge_event_mod[count2].field7 = bce->qual[nloopcount].
            diag_code7_desc
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 CALL echo(build("number of records not found: ",not_found_count))
 CALL echorecord(reply)
 FREE SET bce
END GO

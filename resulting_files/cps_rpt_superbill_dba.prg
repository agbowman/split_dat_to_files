CREATE PROGRAM cps_rpt_superbill:dba
 SET person_id = request->person_id
 SET encntr_id = request->encntr_id
 SET print_id = reqinfo->updt_id
 FREE RECORD person_data
 RECORD person_data(
   1 name = vc
   1 birth_dt_tm = dq8
   1 sex = vc
   1 street_addr = vc
   1 street_addr2 = vc
   1 street_addr3 = vc
   1 street_addr4 = vc
   1 city = vc
   1 state = vc
   1 zipcode = vc
   1 phone = vc
   1 mrn = vc
   1 fin_nbr = vc
   1 pcp = vc
   1 health_plan = vc
   1 health_plan_phone = vc
   1 copay = vc
   1 visit_dt_tm = dq8
 )
 FREE RECORD orders_data
 RECORD orders_data(
   1 orders[*]
     2 order_id = f8
     2 order_mnemonic = vc
     2 catalog_cd = f8
     2 bill_code = vc
     2 bill_sched_disp = vc
     2 diagnosis_qual = i4
     2 diagnosis[*]
       3 diagnosis_id = f8
       3 nomenclature_id = f8
       3 source_string = vc
       3 source_identifier = vc
       3 source_vocab = vc
 )
 SET output_file = fillstring(100," ")
 EXECUTE cpm_create_file_name "sb", "dat"
 SET output_file = trim(cpm_cfn_info->file_name_full_path)
 SET false = 0
 SET true = 1
 SET total_pages = 1
 SET orders_data_ind = true
 SET state_cd = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET printer = fillstring(60," ")
 SET a_name = fillstring(18," ")
 SET a_dob_sex = fillstring(28," ")
 SET a_home_addr = fillstring(28," ")
 SET a_city = fillstring(14," ")
 SET a_city_state_zip = fillstring(28," ")
 SET a_home_phone = fillstring(28," ")
 SET a_visit_date = fillstring(28," ")
 SET a_med_rec = fillstring(21," ")
 SET a_fin_nbr = fillstring(21," ")
 SET a_physician = fillstring(21," ")
 SET a_hlth_plan = fillstring(21," ")
 SET a_hlth_plan_ph = fillstring(21," ")
 SET a_amount = fillstring(21," ")
 SET a_procedure = fillstring(70," ")
 SET a_diagnosis = fillstring(38," ")
 SET a_source_vocab = fillstring(20," ")
 SET a_identifier = fillstring(21," ")
 SET print_line1 = fillstring(80," ")
 SET print_line2 = fillstring(79," ")
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET home_add_cd = 0.0
 SET home_phone_cd = 0.0
 SET work_phone_cd = 0.0
 SET person_mrn_cd = 0.0
 SET encntr_mrn_cd = 0.0
 SET pcp_cd = 0.0
 SET encntr_fin_nbr_cd = 0.0
 SET canceled_cd = 0.0
 SET deleted_cd = 0.0
 SET pharmacy_cd = 0.0
 SET parent_contributor_cd = 0.0
 SET bill_item_type_cd = 0.0
 SET code_set = 212
 SET cdf_meaning = "HOME"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET home_add_cd = code_value
 SET code_set = 43
 SET cdf_meaning = "HOME"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET home_phone_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "MRN"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET encntr_mrn_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "MRN"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET person_mrn_cd = code_value
 SET code_set = 331
 SET cdf_meaning = "PCP"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET pcp_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET encntr_fin_nbr_cd = code_value
 SET code_value = 0.0
 SET code_set = 43
 SET cdf_meaning = "BUSINESS"
 EXECUTE cpm_get_cd_for_cdf
 SET work_phone_cd = code_value
 SET code_value = 0.0
 SET code_set = 6004
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SET code_value = 0.0
 SET code_set = 6004
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_cd = code_value
 SET code_value = 0.0
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SET code_value = 0.0
 SET code_set = 13016
 SET cdf_meaning = "ORD CAT"
 EXECUTE cpm_get_cd_for_cdf
 SET parent_contributor_cd = code_value
 SET code_value = 0.0
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 EXECUTE cpm_get_cd_for_cdf
 SET bill_item_type_cd = code_value
 SELECT INTO "nl:"
  FROM person p,
   (dummyt d  WITH seq = 1),
   address a
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (d
   WHERE d.seq=1)
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=home_add_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY a.beg_effective_dt_tm DESC
  HEAD REPORT
   person_data->name = p.name_full_formatted, person_data->birth_dt_tm = p.birth_dt_tm, person_data->
   sex = uar_get_code_display(p.sex_cd),
   found_address = false
  HEAD a.address_id
   IF (a.address_id > 0
    AND found_address=false)
    found_address = true, person_data->street_addr = a.street_addr, person_data->street_addr2 = a
    .street_addr2,
    person_data->street_addr3 = a.street_addr3, person_data->street_addr4 = a.street_addr4,
    person_data->city = a.city,
    person_data->zipcode = a.zipcode
    IF (a.state_cd > 0)
     person_data->state = uar_get_code_display(a.state_cd)
    ELSEIF (a.state > " ")
     person_data->state = a.state
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE (p.parent_entity_id=request->person_id)
    AND p.parent_entity_name="PERSON"
    AND p.phone_type_cd=home_phone_cd
    AND p.active_ind=true
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY p.beg_effective_dt_tm DESC
  HEAD REPORT
   found_home = false
  DETAIL
   IF (found_home=false)
    found_home = true
    IF (p.phone_format_cd > 0)
     person_data->phone = trim(cnvtphone(p.phone_num,p.phone_format_cd))
    ELSE
     person_data->phone = trim(p.phone_num)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE (ea.encntr_id=request->encntr_id)
    AND ea.encntr_alias_type_cd=encntr_mrn_cd
    AND ea.active_ind=true
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ea.beg_effective_dt_tm DESC
  HEAD REPORT
   IF (ea.alias_pool_cd > 0)
    person_data->mrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
   ELSE
    person_data->mrn = trim(ea.alias)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SELECT INTO "nl:"
   FROM person_alias pa
   PLAN (pa
    WHERE (pa.person_id=request->person_id)
     AND pa.person_alias_type_cd=person_mrn_cd
     AND pa.active_ind=true
     AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pa.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY pa.beg_effective_dt_tm DESC
   HEAD REPORT
    IF (pa.alias_pool_cd > 0)
     person_data->mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
    ELSE
     person_data->mrn = trim(pa.alias)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.active_ind=true
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.beg_effective_dt_tm DESC
  HEAD REPORT
   person_data->pcp = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE (ea.encntr_id=request->encntr_id)
    AND ea.encntr_alias_type_cd=encntr_fin_nbr_cd
    AND ea.active_ind=true
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ea.beg_effective_dt_tm DESC
  HEAD REPORT
   IF (ea.alias_pool_cd > 0)
    person_data->fin_nbr = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
   ELSE
    person_data->fin_nbr = trim(ea.alias)
   ENDIF
  WITH nocounter
 ;end select
 SET org_id = 0.0
 SELECT INTO "nl:"
  FROM encntr_plan_reltn epr,
   health_plan hp,
   organization o
  PLAN (epr
   WHERE (epr.encntr_id=request->encntr_id)
    AND epr.active_ind=true
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.active_ind=true)
   JOIN (o
   WHERE o.organization_id=epr.organization_id)
  ORDER BY epr.priority_seq
  HEAD REPORT
   person_data->health_plan = o.org_name, org_id = o.organization_id
  WITH nocounter
 ;end select
 IF (org_id < 1)
  SELECT INTO "nl:"
   FROM person_plan_reltn ppr,
    health_plan hp,
    organization o
   PLAN (ppr
    WHERE (ppr.person_id=request->person_id)
     AND ppr.active_ind=true
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (hp
    WHERE hp.health_plan_id=ppr.health_plan_id
     AND hp.active_ind=true)
    JOIN (o
    WHERE o.organization_id=ppr.organization_id)
   ORDER BY ppr.priority_seq
   HEAD REPORT
    person_data->health_plan = o.org_name, org_id = o.organization_id
   WITH nocounter
  ;end select
 ENDIF
 IF (org_id > 0)
  SELECT INTO "nl:"
   FROM phone p
   PLAN (p
    WHERE p.parent_entity_id=org_id
     AND p.parent_entity_name="ORGANIZATION"
     AND p.phone_type_cd=work_phone_cd
     AND p.active_ind=true
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY p.beg_effective_dt_tm DESC
   HEAD REPORT
    found_work = false
   DETAIL
    IF (found_work=false)
     IF (p.phone_format_cd > 0)
      person_data->health_plan_phone = trim(cnvtphone(p.phone_num,p.phone_format_cd))
     ELSE
      person_data->health_plan_phone = trim(p.phone_num)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  e.encntr_id, null_chk = nullind(e.reg_dt_tm)
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=encntr_id)
  HEAD REPORT
   IF (null_chk=1)
    person_data->visit_dt_tm = e.pre_reg_dt_tm
   ELSE
    person_data->visit_dt_tm = e.reg_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD drec
 RECORD drec(
   1 app_dt_tm = dq8
   1 sys_dt_tm = dq8
 )
 DECLARE print_time = vc WITH public, noconstant(" ")
 DECLARE print_time_ampm = vc WITH public, noconstant(" ")
 DECLARE the_time = vc WITH public, noconstant(" ")
 DECLARE pm_check = vc WITH public, noconstant(" ")
 DECLARE utc_is_on = i2 WITH public, noconstant(0)
 SET utc_is_on = curutc
 IF (utc_is_on > 0)
  SET drec->sys_dt_tm = datetimezone(cnvtdatetime(curdate,curtime3),curtimezonesys,2)
  SET drec->app_dt_tm = datetimezone(drec->sys_dt_tm,curtimezoneapp)
 ELSE
  SET drec->app_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 SET print_time = format(drec->app_dt_tm,"mm/dd/yy;;d")
 CALL echo("***")
 CALL echo(build("***   print_time :",print_time))
 CALL echo("***")
 SET the_time = format(drec->app_dt_tm,"hh:mm;;s")
 CALL echo("***")
 CALL echo(build("***   the_time :",the_time))
 CALL echo("***")
 SET print_time = concat(print_time," ",substring(1,5,the_time))
 CALL echo("***")
 CALL echo(build("***   print_time :",print_time))
 CALL echo("***")
 SET pm_check = format(drec->app_dt_tm,"hh:mm;;m")
 CALL echo("***")
 CALL echo(build("***   pm_check :",pm_check))
 CALL echo("***")
 IF (cnvtint(substring(1,2,pm_check)) >= 12)
  SET print_time_ampm = cnvtupper(concat(print_time," PM"))
 ELSE
  SET print_time_ampm = cnvtupper(concat(print_time," AM"))
 ENDIF
 CALL echo("***")
 CALL echo(build("***   print_time_ampm :",print_time_ampm))
 CALL echo("***")
 IF (curutc > 0)
  SET offset = 0
  SET daylight = 0
  SET utclabel = datetimezonebyindex(curtimezoneapp,offset,daylight,7,drec->app_dt_tm)
  SET print_time = concat(print_time," ",utclabel)
  SET print_time_ampm = concat(print_time_ampm," ",utclabel)
 ENDIF
 CALL echo("***")
 CALL echo(build("***   print_time      :",print_time))
 CALL echo(build("***   print_time_ampm :",print_time_ampm))
 CALL echo("***")
 FREE SET offset
 FREE SET daylight
 FREE SET utclabel
 SELECT INTO "nl:"
  p.person_id
  FROM person p
  PLAN (p
   WHERE p.person_id=print_id)
  HEAD REPORT
   printer = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET printer = " "
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   order_catalog_synonym ocs,
   (dummyt d  WITH seq = 1),
   dcp_entity_reltn dc,
   diagnosis di,
   nomenclature n
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND (o.encntr_id=request->encntr_id)
    AND ((o.active_ind+ 0)=true)
    AND  NOT (o.order_status_cd IN (canceled_cd, deleted_cd)))
   JOIN (ocs
   WHERE ocs.synonym_id=o.synonym_id)
   JOIN (d
   WHERE d.seq > 0)
   JOIN (dc
   WHERE dc.entity1_id=o.order_id
    AND dc.active_ind=true
    AND dc.entity_reltn_mean="ORDERS/DIAGN")
   JOIN (di
   WHERE di.diagnosis_id=dc.entity2_id)
   JOIN (n
   WHERE n.nomenclature_id=di.nomenclature_id)
  ORDER BY o.order_id, dc.rank_sequence
  HEAD REPORT
   add_order = false, knt = 0, stat = alterlist(orders_data->orders,10)
  HEAD o.order_id
   IF (((o.catalog_type_cd != pharmacy_cd) OR (o.catalog_type_cd=pharmacy_cd
    AND o.orig_ord_as_flag=0)) )
    add_order = true, knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(orders_data->orders,(knt+ 9))
    ENDIF
    orders_data->orders[knt].order_id = o.order_id, orders_data->orders[knt].catalog_cd = o
    .catalog_cd, orders_data->orders[knt].order_mnemonic = ocs.mnemonic,
    dknt = 0, stat = alterlist(orders_data->orders[knt].diagnosis,10)
   ELSE
    add_order = false
   ENDIF
  DETAIL
   IF (di.diagnosis_id > 0
    AND add_order=true)
    dknt = (dknt+ 1)
    IF (mod(dknt,10)=1
     AND dknt != 1)
     stat = alterlist(orders_data->orders[knt].diagnosis,(dknt+ 9))
    ENDIF
    orders_data->orders[knt].diagnosis[dknt].diagnosis_id = di.diagnosis_id, orders_data->orders[knt]
    .diagnosis[dknt].nomenclature_id = n.nomenclature_id
    IF (n.nomenclature_id > 0)
     orders_data->orders[knt].diagnosis[dknt].source_string = n.source_string, orders_data->orders[
     knt].diagnosis[dknt].source_identifier = n.source_identifier, orders_data->orders[knt].
     diagnosis[dknt].source_vocab = uar_get_code_display(n.source_vocabulary_cd)
    ELSE
     orders_data->orders[knt].diagnosis[dknt].source_string = di.diag_ftdesc, orders_data->orders[knt
     ].diagnosis[dknt].source_identifier = "Freetext"
    ENDIF
   ENDIF
  FOOT  o.order_id
   orders_data->orders[knt].diagnosis_qual = dknt, stat = alterlist(orders_data->orders[knt].
    diagnosis,dknt)
  FOOT REPORT
   stat = alterlist(orders_data->orders,knt)
  WITH nocounter, outerjoin = d
 ;end select
 IF (size(orders_data->orders,5) < 1)
  GO TO skip_bill_code
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(orders_data->orders,5))),
   bill_item b,
   bill_item_modifier bm,
   code_value cv
  PLAN (d
   WHERE d.seq > 0)
   JOIN (b
   WHERE (b.ext_parent_reference_id=orders_data->orders[d.seq].catalog_cd)
    AND b.ext_parent_contributor_cd=parent_contributor_cd
    AND b.ext_child_reference_id=0
    AND b.ext_child_contributor_cd=0
    AND b.active_ind=1
    AND b.child_seq=0)
   JOIN (bm
   WHERE bm.bill_item_id=b.bill_item_id
    AND bm.bill_item_type_cd=bill_item_type_cd
    AND bm.active_ind=true)
   JOIN (cv
   WHERE cv.code_value=bm.key1_id
    AND ((cv.code_set+ 0)=14002))
  ORDER BY d.seq, bm.key2_id
  HEAD REPORT
   cpt4_code = fillstring(240," "), mod_code = fillstring(240," "), hcpcs_code = fillstring(240," "),
   pro_code = fillstring(240," "), cdm_code = fillstring(240," ")
  HEAD d.seq
   found_cpt4 = false, found_modifier = false, found_hcpcs = false,
   found_proccode = false, found_cdm_sched = false
  DETAIL
   IF (cv.cdf_meaning="CPT4")
    found_cpt4 = true, cpt4_code = concat("(",trim(cv.display)," ",trim(bm.key6),")")
   ELSEIF (cv.cdf_meaning="MODIFIER")
    found_modifier = true, mod_code = concat("(",trim(cv.display)," ",trim(bm.key6),")")
   ELSEIF (cv.cdf_meaning="HCPCS")
    found_hcpcs = true, hcpcs_code = concat("(",trim(cv.display)," ",trim(bm.key6),")")
   ELSEIF (cv.cdf_meaning="PROCCODE")
    found_proccode = true, pro_code = concat("(",trim(cv.display)," ",trim(bm.key6),")")
   ELSEIF (cv.cdf_meaning="CDM_SCHED")
    found_cdm_sched = true, cdm_code = concat("(",trim(cv.display)," ",trim(bm.key6),")")
   ENDIF
  FOOT  d.seq
   add_first = false
   IF (found_cpt4=true)
    IF (add_first=false)
     add_first = true, orders_data->orders[d.seq].bill_code = trim(cpt4_code)
    ELSE
     orders_data->orders[d.seq].bill_code = concat(trim(orders_data->orders[d.seq].bill_code),", ",
      trim(cpt4_code))
    ENDIF
   ENDIF
   IF (found_modifier=true)
    IF (add_first=false)
     add_first = true, orders_data->orders[d.seq].bill_code = trim(mod_code)
    ELSE
     orders_data->orders[d.seq].bill_code = concat(trim(orders_data->orders[d.seq].bill_code),", ",
      trim(mod_code))
    ENDIF
   ENDIF
   IF (found_hcpcs=true)
    IF (add_first=false)
     add_first = true, orders_data->orders[d.seq].bill_code = trim(hcpcs_code)
    ELSE
     orders_data->orders[d.seq].bill_code = concat(trim(orders_data->orders[d.seq].bill_code),", ",
      trim(hcpcs_code))
    ENDIF
   ENDIF
   IF (found_proccode=true)
    IF (add_first=false)
     add_first = true, orders_data->orders[d.seq].bill_code = trim(pro_code)
    ELSE
     orders_data->orders[d.seq].bill_code = concat(trim(orders_data->orders[d.seq].bill_code),", ",
      trim(pro_code))
    ENDIF
   ENDIF
   IF (found_cdm_sched=true)
    IF (add_first=false)
     add_first = true, orders_data->orders[d.seq].bill_code = trim(cdm_code)
    ELSE
     orders_data->orders[d.seq].bill_code = concat(trim(orders_data->orders[d.seq].bill_code),", ",
      trim(cdm_code))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#skip_bill_code
 SET dvar = 0
 SET a_name = person_data->name
 SET a_dob_sex = concat(trim(format(person_data->birth_dt_tm,"@MEDIUMDATE4YR"))," / ",trim(
   person_data->sex))
 SET a_home_addr = concat(trim(person_data->street_addr)," ",trim(person_data->street_addr2))
 SET a_city = person_data->city
 SET a_city_state_zip = concat(trim(a_city)," ",trim(person_data->state)," ",trim(person_data->
   zipcode))
 SET a_home_phone = trim(person_data->phone)
 SET a_visit_date = trim(format(person_data->visit_dt_tm,"@MEDIUMDATE4YR"))
 SET a_med_rec = person_data->mrn
 SET a_fin_nbr = person_data->fin_nbr
 SET a_physician = concat("Dr. ",trim(person_data->pcp))
 SET a_hlth_plan = person_data->health_plan
 SET a_hlth_plan_ph = person_data->health_plan_phone
 SET a_amount = concat("$",trim(person_data->copay))
 FREE RECORD print_data
 RECORD print_data(
   1 qual_knt = i4
   1 qual[*]
     2 pro_knt = i4
     2 pro[*]
       3 name = vc
     2 diag_knt = i4
     2 diag[*]
       3 name_knt = i4
       3 name[*]
         4 data = vc
 )
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 CALL echorecord(orders_data)
 CALL echo("***")
 CALL echo("***   load print_data")
 CALL echo("***")
 SET max_size = size(orders_data->orders,5)
 IF (max_size > 0)
  FOR (i = 1 TO max_size)
    SET print_data->qual_knt = i
    SET stat = alterlist(print_data->qual,i)
    SET pt->line_cnt = 0
    SET max_length = 86
    IF ((orders_data->orders[i].bill_code > " "))
     EXECUTE dcp_parse_text value(concat(trim(orders_data->orders[i].order_mnemonic)," ",trim(
        orders_data->orders[i].bill_code))), value(max_length)
    ELSE
     EXECUTE dcp_parse_text value(concat(trim(orders_data->orders[i].order_mnemonic),
       " (No bill codes found)")), value(max_length)
    ENDIF
    SET print_data->qual[i].pro_knt = pt->line_cnt
    SET stat = alterlist(print_data->qual[i].pro,pt->line_cnt)
    FOR (nidx = 1 TO pt->line_cnt)
      SET print_data->qual[i].pro[nidx].name = pt->lns[nidx].line
    ENDFOR
    IF ((orders_data->orders[i].diagnosis_qual > 0))
     FOR (jidx = 1 TO orders_data->orders[i].diagnosis_qual)
       SET print_data->qual[i].diag_knt = jidx
       SET stat = alterlist(print_data->qual[i].diag,jidx)
       SET pt->line_cnt = 0
       SET max_length = 81
       IF (trim(orders_data->orders[i].diagnosis[jidx].source_vocab) > " ")
        IF (trim(orders_data->orders[i].diagnosis[jidx].source_identifier) > " ")
         EXECUTE dcp_parse_text value(concat(trim(orders_data->orders[i].diagnosis[jidx].source_vocab
            )," ",trim(orders_data->orders[i].diagnosis[jidx].source_identifier)," :",trim(
            orders_data->orders[i].diagnosis[jidx].source_string))), value(max_length)
        ELSE
         EXECUTE dcp_parse_text value(concat(trim(orders_data->orders[i].diagnosis[jidx].source_vocab
            )," No Code : ",trim(orders_data->orders[i].diagnosis[jidx].source_string))), value(
          max_length)
        ENDIF
       ELSEIF (trim(orders_data->orders[i].diagnosis[jidx].source_identifier) > " ")
        EXECUTE dcp_parse_text value(concat("Unknown Source ",trim(orders_data->orders[i].diagnosis[
           jidx].source_identifier)," :",trim(orders_data->orders[i].diagnosis[jidx].source_string))),
        value(max_length)
       ELSE
        EXECUTE dcp_parse_text value(concat("Unknown Source No Code : ",trim(orders_data->orders[i].
           diagnosis[jidx].source_string))), value(max_length)
       ENDIF
       SET print_data->qual[i].diag[jidx].name_knt = pt->line_cnt
       SET stat = alterlist(print_data->qual[i].diag[jidx].name,pt->line_cnt)
       FOR (didx = 1 TO pt->line_cnt)
         SET print_data->qual[i].diag[jidx].name[didx].data = pt->lns[didx].line
       ENDFOR
     ENDFOR
    ELSE
     SET print_data->qual[i].diag_knt = 1
     SET stat = alterlist(print_data->qual[i].diag,1)
     SET print_data->qual[i].diag[1].name_knt = 1
     SET stat = alterlist(print_data->qual[i].diag[1].name,1)
     SET print_data->qual[i].diag[1].name[1].data = "No diagnosis associated to order"
    ENDIF
  ENDFOR
 ENDIF
 CALL echo("***")
 CALL echo("***   create report")
 CALL echo("***")
 SELECT INTO value(output_file)
  dvar
  HEAD REPORT
   print_order_line = fillstring(63," "), nbr_of_pages = 0, last_page = false,
   total_rows = 0, max_rows = 52, cur_page_row_knt = 0,
   MACRO (print_page_template)
    "{f/0/1}{cpi/14^}{lpi/8}", row + 1, "{color/31/1}",
    "{pos/028/20}{box/105/2/1}", row + 1, "{color/30/1}",
    "{pos/067/47}{box/091/8/1}", row + 1, "{color/31/1}",
    "{pos/067/47}{box/091/8/1}", row + 1, "{color/31/1}",
    "{pos/028/135}{box/105/62/1}", row + 1, "{color/31/1}",
    "{pos/067/710}{box/091/3/1}", row + 1, "{f/5/1}{cpi/5^}{lpi/3}",
    "{pos/000/08}", row + 1, col 40,
    "Superbill", row + 1, "{f/0/1}{cpi/12^}{lpi/7}",
    "{pos/000/45}", row + 1, col 10,
    "Patient:", row + 1, col 10,
    "DOB / Sex:", row + 1, col 10,
    "Address (H):", row + 2, col 10,
    "Phone (H):", row + 2, col 10,
    "Visit Date:", row + 1, "{f/5/1}",
    "{pos/000/45}", row + 1, col 55,
    a_name, row + 1, "{f/0/1}",
    "{pos/000/45}", row + 2, col 23,
    a_dob_sex, row + 1, col 23,
    a_home_addr, row + 1, col 23,
    a_city_state_zip, row + 1, col 23,
    a_home_phone, row + 2, col 23,
    a_visit_date, row + 1, "{f/0/1}",
    "{pos/000/45}", row + 1, col 53,
    "Med Rec #:", col 66, a_med_rec,
    row + 1, col 53, "Financial #:",
    col 66, a_fin_nbr, row + 1,
    col 53, "Physician:", col 66,
    a_physician, row + 2, col 53,
    "Health Plan:", col 66, a_hlth_plan,
    row + 1, col 66, a_hlth_plan_ph,
    row + 1, col 53, "Copay:",
    col 66, a_amount, row + 1,
    "{f/5/1}{cpi/8}{lpi/6}", "{pos/000/135}", row + 1,
    col 6, "Procedures:", "{f/0/1}{cpi/12^}{lpi/7}",
    "{pos/067/708}", row + 1, col 10,
    "Print id:", col 20, printer,
    row + 1, col 10, "Printed:",
    col 20, print_time_ampm, page_stamp = concat("Page ",trim(cnvtstring(nbr_of_pages))," of ",trim(
      cnvtstring(total_pages))),
    col 74, page_stamp, row + 1
    IF (last_page=true)
     col 42, "(end of report)"
    ENDIF
    "{f/0/1}", "{pos/000/135}", row + 3,
    cur_page_row_knt = 0
   ENDMACRO
   ,
   MACRO (find_item_rows)
    item_row_knt = (print_data->qual[i].pro_knt+ 2)
    FOR (bidx = 1 TO print_data->qual[i].diag_knt)
      item_row_knt = (item_row_knt+ print_data->qual[i].diag[bidx].name_knt)
    ENDFOR
   ENDMACRO
   ,
   MACRO (find_total_pages)
    FOR (i = 1 TO print_data->qual_knt)
      find_item_rows
      IF (((max_rows - cur_page_row_knt) < item_row_knt)
       AND item_row_knt < 7)
       total_pages = (total_pages+ 1), cur_page_row_knt = 0
      ENDIF
      FOR (j = 1 TO print_data->qual[i].pro_knt)
        IF ((((max_rows - cur_page_row_knt) - 1) < 0))
         total_pages = (total_pages+ 1), cur_page_row_knt = 0
         IF (j != 1)
          cur_page_row_knt = (cur_page_row_knt+ 1)
         ENDIF
         cur_page_row_knt = (cur_page_row_knt+ 1)
        ELSE
         cur_page_row_knt = (cur_page_row_knt+ 1)
        ENDIF
      ENDFOR
      cur_page_row_knt = (cur_page_row_knt+ 1)
      FOR (k = 1 TO print_data->qual[i].diag_knt)
        FOR (m = 1 TO print_data->qual[i].diag[k].name_knt)
          IF ((((max_rows - cur_page_row_knt) - 1) < 0))
           total_pages = (total_pages+ 1), cur_page_row_knt = 0
           IF (m != 1)
            cur_page_row_knt = (cur_page_row_knt+ 1)
           ELSE
            cur_page_row_knt = (cur_page_row_knt+ 1), cur_page_row_knt = (cur_page_row_knt+ 1)
           ENDIF
           cur_page_row_knt = (cur_page_row_knt+ 1)
          ELSE
           cur_page_row_knt = (cur_page_row_knt+ 1)
          ENDIF
        ENDFOR
      ENDFOR
      cur_page_row_knt = (cur_page_row_knt+ 1)
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_body)
    FOR (i = 1 TO print_data->qual_knt)
      find_item_rows
      IF (((max_rows - cur_page_row_knt) < item_row_knt)
       AND item_row_knt < 7)
       nbr_of_pages = (nbr_of_pages+ 1)
       IF (nbr_of_pages=total_pages)
        last_page = true
       ENDIF
       BREAK, print_page_template
      ENDIF
      FOR (j = 1 TO print_data->qual[i].pro_knt)
        IF ((((max_rows - cur_page_row_knt) - 1) < 0))
         nbr_of_pages = (nbr_of_pages+ 1)
         IF (nbr_of_pages=total_pages)
          last_page = true
         ENDIF
         BREAK, print_page_template
         IF (j != 1)
          col 7, "{f/1/1}", "Order continued from previous page",
          row + 1, cur_page_row_knt = (cur_page_row_knt+ 1)
         ENDIF
         col 7, "{f/1/1}", print_data->qual[i].pro[j].name,
         row + 1, cur_page_row_knt = (cur_page_row_knt+ 1)
        ELSE
         col 7, "{f/1/1}", print_data->qual[i].pro[j].name,
         row + 1, cur_page_row_knt = (cur_page_row_knt+ 1)
        ENDIF
      ENDFOR
      row + 1, cur_page_row_knt = (cur_page_row_knt+ 1)
      FOR (k = 1 TO print_data->qual[i].diag_knt)
        FOR (m = 1 TO print_data->qual[i].diag[k].name_knt)
          IF ((((max_rows - cur_page_row_knt) - 1) < 0))
           nbr_of_pages = (nbr_of_pages+ 1)
           IF (nbr_of_pages=total_pages)
            last_page = true
           ENDIF
           BREAK, print_page_template
           IF (m != 1)
            col 12, "{f/0/1}", "Diagnosis list continued from previous page",
            row + 1, cur_page_row_knt = (cur_page_row_knt+ 1)
           ELSE
            col 7, "{f/1/1}", "Orders diagnosis list continued from previous page",
            row + 1, cur_page_row_knt = (cur_page_row_knt+ 1), print_order_line = concat(trim(
              substring(1,50,print_data->qual[i].pro[1].name))," Continued..."),
            col 7, "{f/1/1}", print_order_line,
            row + 1, cur_page_row_knt = (cur_page_row_knt+ 1)
           ENDIF
           col 12, "{f/0/1}", print_data->qual[i].diag[k].name[m].data,
           row + 1, cur_page_row_knt = (cur_page_row_knt+ 1)
          ELSE
           col 12, "{f/0/1}", print_data->qual[i].diag[k].name[m].data,
           row + 1, cur_page_row_knt = (cur_page_row_knt+ 1)
          ENDIF
        ENDFOR
      ENDFOR
      row + 1, cur_page_row_knt = (cur_page_row_knt+ 1)
    ENDFOR
   ENDMACRO
   ,
   MACRO (print_no_data)
    row + 1, col 7, "{f/1/1}",
    "No orders found", row + 1
   ENDMACRO
   , find_total_pages,
   nbr_of_pages = (nbr_of_pages+ 1)
   IF (nbr_of_pages=total_pages)
    last_page = true
   ENDIF
   print_page_template
   IF ((print_data->qual_knt > 0))
    print_body
   ELSE
    print_no_data
   ENDIF
  WITH check, nocounter, nullreport,
   maxrow = 100, maxcol = 150, dio = postscript
 ;end select
 FREE RECORD reply
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 output_file = vc
   1 node = vc
   1 format_type = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->person_id = person_id
 SET reply->encntr_id = encntr_id
 SET reply->output_file = trim(output_file)
 SET reply->node = curnode
 SET reply->format_type = "application/postscript"
 SET reply->status_data.status = "S"
 SET script_version = "005 10/01/13 ST020427"
END GO

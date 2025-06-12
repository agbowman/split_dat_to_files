CREATE PROGRAM bhs_extract_acpoe_child:dba
 DECLARE ms_cr_str = vc WITH protect, constant(char(13))
 DECLARE ms_bm_str = vc WITH protect, constant(char(11))
 DECLARE ms_eom_str = vc WITH protect, constant(concat(char(28),char(13)))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_ssn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"SSN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_current_name_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",213,"CURRENT"))
 DECLARE mf_male_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE mf_female_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE mf_phone_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_phone_bus_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE mf_fax_bus_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"FAX BUS"))
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_icd9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",400,"ICD9CM"))
 DECLARE mf_icd10_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"ICD10-CM"))
 DECLARE mf_orgdoc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "ORGANIZATIONDOCTOR"))
 DECLARE mf_sunquest_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"SUNQUEST"))
 DECLARE mf_adtegate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"ADTEGATE"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE mf_deleted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE mf_future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE mf_od_copyto = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"COPYTO"))
 DECLARE mf_od_consphys = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "CONSULTING PHYSICIAN"))
 DECLARE mf_od_icd9code = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"ICD9CODE"))
 DECLARE mf_od_spec_type = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SPECIMENTYPE"))
 DECLARE mf_od_nursecollect = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "NURSE COLLECT"))
 DECLARE mf_od_orderloc = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ORDER LOCATION"))
 DECLARE mf_od_collectedyn = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "COLLECTED Y/N"))
 DECLARE mf_od_specinx = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SPECIALINSTRUCTIONS"))
 DECLARE mf_od_genetic = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "GENETICSWARRANT"))
 DECLARE ms_tmp_message = vc WITH protect, noconstant("")
 DECLARE ml_tmp_retval = i4 WITH protect, noconstant(0)
 DECLARE ml_t_size = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_orc_type = vc WITH protect, noconstant("NW")
 DECLARE ml_oa_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_template_flg = i4 WITH protect, noconstant(0)
 DECLARE ml_prev_fut_ord = i4 WITH protect, noconstant(0)
 DECLARE ml_cpy_to_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_err_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_err_msg = vc WITH protect, noconstant("")
 DECLARE ms_trans_name = vc WITH protect, noconstant("")
 DECLARE ms_file_name = vc WITH protect, noconstant("")
 DECLARE ms_file_path = vc WITH protect, noconstant(concat(trim(logical("bhscust"),3),"/ordhl7/"))
 DECLARE ml_dmc_ret = i4 WITH protect, noconstant(0)
 DECLARE ms_cmd_str = vc WITH protect, noconstant("")
 DECLARE ms_cmd_str2 = vc WITH protect, noconstant("")
 DECLARE ms_final_hl7_msg = vc WITH protect, noconstant("")
 DECLARE ml_specinx_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_genetic_pos = i4 WITH protect, noconstant(0)
 FREE RECORD prsn_info
 RECORD prsn_info(
   1 cnt = i4
   1 cmrn = vc
   1 name_first = vc
   1 name_middle = vc
   1 name_last = vc
   1 dob = vc
   1 gender = vc
   1 addr_line1 = vc
   1 addr_line2 = vc
   1 city = vc
   1 state = vc
   1 zip_code = vc
   1 home_phone_num = vc
   1 ssn = vc
   1 marital_type_cd = f8
   1 marital_type_meaning = vc
   1 msh_hl7_slice = vc
   1 pid_hl7_slice = vc
   1 diag[*]
     2 icd_code = vc
     2 icd_type = vc
     2 description = vc
     2 diag_hl7_slice = vc
   1 ord_cnt = i4
   1 ord[*]
     2 order_id = f8
     2 comment_cnt = i4
     2 comment_list[*]
       3 comment = vc
       3 nte_hl7_slice = vc
     2 obr_hl7_slice = vc
     2 orc_hl7_slice = vc
     2 ord_status_cd = f8
     2 ord_status_meaning = vc
     2 ord_catalog_cd = f8
     2 ord_catalog_meaning = vc
     2 transaction_dt_tm = f8
     2 action_dt_tm = f8
     2 order_mnemonic = vc
     2 ord_speciment = vc
     2 ord_speciment_cd = f8
     2 ord_speciment_meaning = vc
     2 ord_nursecollect = vc
     2 ord_activity_type_cd = f8
     2 ord_activity_type_meaning = vc
     2 ord_provider_id = f8
     2 ord_provider_alias = vc
     2 ord_provider_name_first = vc
     2 ord_provider_name_last = vc
     2 ord_start_dt_tm = f8
     2 orig_order_dt_tm = f8
     2 ord_location_cd = f8
     2 ord_location_meaning = vc
     2 ord_location_val = vc
     2 copy_to_cnt = i4
     2 ord_collected_date = vc
     2 copy_to[*]
       3 person_id = f8
       3 name = vc
       3 alias = vc
       3 phone_home = vc
       3 phone_bus = vc
       3 phone_fax = vc
       3 fin_num = vc
       3 fin_num_type = vc
 ) WITH protect
 SET ml_tmp_retval = - (1)
 SET retval = ml_tmp_retval
 CALL echo(request->trigger_personid)
 CALL echo(request->trigger_encntrid)
 CALL echo(request->trigger_orderid)
 SET ms_tmp_message = build("Starting script person_id = ",request->trigger_personid)
 SET ms_tmp_message = build(ms_tmp_message," encounter_id = ",request->trigger_encntrid)
 SET ms_tmp_message = build(ms_tmp_message," order_id = ",request->trigger_orderid)
 SET ms_trans_name = concat(trim(cnvtstring(request->trigger_personid,20),3),"_",trim(cnvtstring(
    request->trigger_encntrid,20),3),"_",trim(cnvtstring(request->trigger_orderid,20),3),
  "_",format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;q"))
 SET ms_file_name = concat("ord_hl7_",ms_trans_name,".txt")
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE (pa.person_id=request->trigger_personid)
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND pa.person_alias_type_cd IN (mf_cmrn_cd, mf_ssn_cd)
  ORDER BY pa.updt_dt_tm
  DETAIL
   IF (pa.person_alias_type_cd=mf_cmrn_cd)
    prsn_info->cmrn = trim(pa.alias,3)
   ENDIF
   IF (pa.person_alias_type_cd=mf_ssn_cd)
    prsn_info->ssn = trim(pa.alias,3)
   ENDIF
  FOOT REPORT
   ml_t_size = size(prsn_info->cmrn)
   IF (ml_t_size=0)
    ml_err_ind = 1, ms_tmp_message = build(ms_tmp_message,
     " CMRN size is 0. Check why CMRN was not found")
   ENDIF
   IF (ml_t_size < 7)
    FOR (ml_cnt = 1 TO (7 - ml_t_size))
      prsn_info->cmrn = concat("0",prsn_info->cmrn)
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_err_ind=1)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM person_name pn
  WHERE (pn.person_id=request->trigger_personid)
   AND pn.active_ind=1
   AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND pn.name_type_cd=mf_current_name_cd
  ORDER BY pn.name_type_seq
  DETAIL
   prsn_info->name_first = trim(pn.name_first), prsn_info->name_last = trim(pn.name_last), prsn_info
   ->name_middle = trim(pn.name_middle)
  FOOT REPORT
   ml_t_size = size(prsn_info->name_first)
   IF (ml_t_size=0)
    ml_err_ind = 1, ms_tmp_message = build(ms_tmp_message,
     " First_Name size is 0. Check why FIRST_NAME was not found")
   ENDIF
   ml_t_size = size(prsn_info->name_last)
   IF (ml_t_size=0)
    ml_err_ind = 1, ms_tmp_message = build(ms_tmp_message,
     " Last_Name size is 0. Check why LAST_NAME was not found")
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_err_ind=1)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id=request->trigger_personid)
  DETAIL
   prsn_info->marital_type_cd = p.marital_type_cd, prsn_info->dob = format(p.birth_dt_tm,
    "YYYYMMDD;;q")
   IF (p.sex_cd=mf_female_cd)
    prsn_info->gender = "F"
   ELSEIF (p.sex_cd=mf_male_cd)
    prsn_info->gender = "M"
   ELSE
    prsn_info->gender = "U"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM address ad
  WHERE ad.parent_entity_name="PERSON"
   AND (ad.parent_entity_id=request->trigger_personid)
   AND ad.address_type_cd=mf_addr_home_cd
   AND ad.active_ind=1
   AND ad.end_effective_dt_tm > sysdate
   AND ad.address_type_seq=1
  DETAIL
   prsn_info->addr_line1 = trim(ad.street_addr), prsn_info->addr_line2 = trim(ad.street_addr2),
   prsn_info->city = trim(ad.city),
   prsn_info->zip_code = trim(ad.zipcode), prsn_info->state = uar_get_code_display(ad.state_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM phone ph
  WHERE ph.parent_entity_name="PERSON"
   AND (ph.parent_entity_id=request->trigger_personid)
   AND ph.phone_type_cd IN (mf_phone_home_cd)
   AND ph.phone_type_seq=1
   AND ph.active_ind=1
   AND ph.end_effective_dt_tm > sysdate
  DETAIL
   prsn_info->home_phone_num = trim(ph.phone_num,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od,
   nomenclature n
  WHERE (od.order_id=request->trigger_orderid)
   AND od.oe_field_id=mf_od_icd9code
   AND n.nomenclature_id=od.oe_field_value
   AND n.source_vocabulary_cd IN (mf_icd9_cd, mf_icd10_cd)
  HEAD REPORT
   prsn_info->cnt = 0
  DETAIL
   prsn_info->cnt = (prsn_info->cnt+ 1), stat = alterlist(prsn_info->diag,prsn_info->cnt), prsn_info
   ->diag[prsn_info->cnt].description = trim(n.source_string),
   prsn_info->diag[prsn_info->cnt].icd_code = trim(n.source_identifier)
   IF (n.source_vocabulary_cd=mf_icd10_cd)
    prsn_info->diag[prsn_info->cnt].icd_type = "I10"
   ELSEIF (n.source_vocabulary_cd=mf_icd9_cd)
    prsn_info->diag[prsn_info->cnt].icd_type = "I9"
   ENDIF
  WITH nocounter
 ;end select
 IF ((prsn_info->cnt > 0))
  FOR (ml_loop = 1 TO prsn_info->cnt)
    SET prsn_info->diag[ml_loop].diag_hl7_slice = build("DG1","|",ml_loop,"|",prsn_info->diag[ml_loop
     ].icd_type,
     "|",prsn_info->diag[ml_loop].icd_code,"^",prsn_info->diag[ml_loop].description,"^",
     prsn_info->diag[ml_loop].icd_type,"|",prsn_info->diag[ml_loop].description,"|")
  ENDFOR
 ENDIF
 SET prsn_info->ord_cnt = 1
 SET stat = alterlist(prsn_info->ord,prsn_info->ord_cnt)
 SET prsn_info->ord[prsn_info->ord_cnt].order_id = request->trigger_orderid
 SELECT INTO "nl:"
  FROM orders o
  WHERE (o.order_id=request->trigger_orderid)
  DETAIL
   ml_template_flg = o.template_order_flag, prsn_info->ord[1].ord_status_cd = o.order_status_cd,
   prsn_info->ord[1].ord_catalog_cd = o.catalog_cd,
   prsn_info->ord[1].order_mnemonic = o.ordered_as_mnemonic, prsn_info->ord[1].ord_activity_type_cd
    = o.activity_type_cd, prsn_info->ord[1].ord_start_dt_tm = o.current_start_dt_tm,
   prsn_info->ord[1].orig_order_dt_tm = o.orig_order_dt_tm
   IF (o.order_status_cd IN (mf_canceled_cd, mf_deleted_cd))
    ms_orc_type = "CA"
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_template_flg=7)
  SET ms_tmp_message = build(ms_tmp_message," Order is a parent recurring. Do not continue. ")
  SET ml_err_ind = 1
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM order_comment oc,
   long_text lt
  WHERE (oc.order_id=prsn_info->ord[prsn_info->ord_cnt].order_id)
   AND lt.long_text_id=oc.long_text_id
  ORDER BY oc.action_sequence
  HEAD REPORT
   prsn_info->ord[prsn_info->ord_cnt].comment_cnt = 0
  DETAIL
   prsn_info->ord[prsn_info->ord_cnt].comment_cnt = (prsn_info->ord[prsn_info->ord_cnt].comment_cnt+
   1), stat = alterlist(prsn_info->ord[prsn_info->ord_cnt].comment_list,prsn_info->ord[prsn_info->
    ord_cnt].comment_cnt), prsn_info->ord[prsn_info->ord_cnt].comment_list[prsn_info->ord[prsn_info->
   ord_cnt].comment_cnt].comment = replace(lt.long_text,ms_cr_str," /.br/ ",0),
   prsn_info->ord[prsn_info->ord_cnt].comment_list[prsn_info->ord[prsn_info->ord_cnt].comment_cnt].
   nte_hl7_slice = build2("NTE|",trim(cnvtstring(prsn_info->ord[prsn_info->ord_cnt].comment_cnt),3),
    "||",prsn_info->ord[prsn_info->ord_cnt].order_mnemonic," - ",
    prsn_info->ord[prsn_info->ord_cnt].comment_list[prsn_info->ord[prsn_info->ord_cnt].comment_cnt].
    comment), ms_orc_type = "SC"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_action oa
  WHERE (oa.order_id=request->trigger_orderid)
  ORDER BY oa.action_sequence DESC
  HEAD REPORT
   prsn_info->ord[1].transaction_dt_tm = oa.order_dt_tm, prsn_info->ord[1].action_dt_tm = oa
   .action_dt_tm, prsn_info->ord[1].ord_provider_id = oa.order_provider_id,
   ml_oa_cnt = 0
  DETAIL
   IF (oa.order_status_cd=mf_future_cd)
    ml_prev_fut_ord = 1
   ENDIF
   ml_oa_cnt = (ml_oa_cnt+ 1)
  FOOT REPORT
   IF (ml_oa_cnt > 1
    AND ms_orc_type != "CA")
    ms_orc_type = "SC"
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_prev_fut_ord != 1)
  SET ms_tmp_message = build(ms_tmp_message," Order never had FUTURE status ")
  SET ml_err_ind = 1
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM order_detail od
  WHERE (od.order_id=request->trigger_orderid)
   AND od.oe_field_id IN (mf_od_spec_type, mf_od_nursecollect, mf_od_orderloc, mf_od_collectedyn,
  mf_od_specinx,
  mf_od_genetic)
  ORDER BY od.action_sequence
  DETAIL
   IF (od.oe_field_id=mf_od_nursecollect)
    prsn_info->ord[1].ord_nursecollect = trim(od.oe_field_display_value,3)
   ENDIF
   IF (od.oe_field_id=mf_od_spec_type)
    prsn_info->ord[1].ord_speciment = trim(od.oe_field_display_value,3), prsn_info->ord[1].
    ord_speciment_cd = od.oe_field_value
   ENDIF
   IF (od.oe_field_id=mf_od_orderloc)
    prsn_info->ord[1].ord_location_cd = od.oe_field_value, prsn_info->ord[1].ord_location_val = trim(
     od.oe_field_display_value,3)
   ENDIF
   IF (od.oe_field_id=mf_od_specinx)
    IF (ml_specinx_pos=0)
     prsn_info->ord[1].comment_cnt = (prsn_info->ord[1].comment_cnt+ 1), stat = alterlist(prsn_info->
      ord[1].comment_list,prsn_info->ord[1].comment_cnt), ml_specinx_pos = prsn_info->ord[1].
     comment_cnt
    ENDIF
    prsn_info->ord[1].comment_list[ml_specinx_pos].comment = replace(od.oe_field_display_value,
     ms_cr_str," /.br/ ",0), prsn_info->ord[1].comment_list[ml_specinx_pos].nte_hl7_slice = build(
     "NTE|",ml_specinx_pos,"||",prsn_info->ord[1].comment_list[ml_specinx_pos].comment)
   ENDIF
   IF (od.oe_field_id=mf_od_collectedyn)
    prsn_info->ord[1].ord_collected_date = evaluate(cnvtupper(od.oe_field_display_value),"YES",format
     (od.updt_dt_tm,"YYYYMMDDHHMMSS;;q"),"")
   ENDIF
   IF (od.oe_field_id=mf_od_genetic)
    IF (ml_genetic_pos=0)
     prsn_info->ord[1].comment_cnt = (prsn_info->ord[1].comment_cnt+ 1), stat = alterlist(prsn_info->
      ord[1].comment_list,prsn_info->ord[1].comment_cnt), ml_genetic_pos = prsn_info->ord[1].
     comment_cnt
    ENDIF
    prsn_info->ord[1].comment_list[ml_genetic_pos].comment = concat("Warrant for Genetics Test: ",
     trim(od.oe_field_display_value)), prsn_info->ord[1].comment_list[ml_genetic_pos].nte_hl7_slice
     = build("NTE|",ml_genetic_pos,"||",prsn_info->ord[1].comment_list[ml_genetic_pos].comment)
   ENDIF
  WITH nocounter
 ;end select
 IF ((prsn_info->ord[1].ord_location_cd=0.0))
  SET ms_tmp_message = build(ms_tmp_message," Order does not have ORDERLOC. Need to skip it. ")
  SET ml_err_ind = 1
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_outbound cvo
  WHERE cvo.code_value IN (prsn_info->ord[1].ord_catalog_cd, prsn_info->ord[1].ord_status_cd,
  prsn_info->ord[1].ord_speciment_cd, prsn_info->ord[1].ord_activity_type_cd, prsn_info->ord[1].
  ord_location_cd,
  prsn_info->marital_type_cd)
   AND cvo.contributor_source_cd IN (mf_sunquest_cd, mf_adtegate_cd)
  DETAIL
   IF (cvo.contributor_source_cd=mf_sunquest_cd)
    IF ((cvo.code_value=prsn_info->ord[1].ord_catalog_cd))
     prsn_info->ord[1].ord_catalog_meaning = cvo.alias
    ENDIF
    IF ((cvo.code_value=prsn_info->ord[1].ord_status_cd))
     prsn_info->ord[1].ord_status_meaning = cvo.alias
    ENDIF
    IF ((cvo.code_value=prsn_info->ord[1].ord_speciment_cd))
     prsn_info->ord[1].ord_speciment_meaning = cvo.alias
    ENDIF
    IF ((cvo.code_value=prsn_info->ord[1].ord_activity_type_cd))
     prsn_info->ord[1].ord_activity_type_meaning = cvo.alias
    ENDIF
    IF ((cvo.code_value=prsn_info->marital_type_cd))
     prsn_info->marital_type_meaning = cvo.alias
    ENDIF
   ENDIF
   IF (cvo.contributor_source_cd=mf_adtegate_cd)
    IF ((cvo.code_value=prsn_info->ord[1].ord_location_cd))
     prsn_info->ord[1].ord_location_meaning = cvo.alias
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET prsn_info->msh_hl7_slice = build("MSH|^~\&","|CERNER","|",prsn_info->ord[1].ord_location_meaning,
  "|ATLAS",
  "|BHS","|",format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;q"),"|","|ORM^O01",
  "|",replace(ms_trans_name,"_","",0),"|P","|2.3 ")
 SET prsn_info->pid_hl7_slice = build("PID|1","|",prsn_info->cmrn,"|","|",
  "|",prsn_info->name_last,"^",prsn_info->name_first,"^",
  prsn_info->name_middle,"|","|",prsn_info->dob,"|",
  prsn_info->gender,"|","|","|",prsn_info->addr_line1,
  "^",prsn_info->addr_line2,"^",prsn_info->city,"^",
  prsn_info->state,"^",prsn_info->zip_code,"|","|",
  prsn_info->home_phone_num,"|","|","|",evaluate(size(trim(prsn_info->marital_type_meaning,3)),0,"U",
   prsn_info->marital_type_meaning),
  "|","|","|",prsn_info->ssn)
 SELECT INTO "nl:"
  FROM prsnl_alias pa,
   person p
  WHERE (p.person_id=prsn_info->ord[1].ord_provider_id)
   AND pa.person_id=outerjoin(p.person_id)
   AND pa.prsnl_alias_type_cd=outerjoin(mf_orgdoc_cd)
   AND pa.active_ind=outerjoin(1)
   AND pa.end_effective_dt_tm > outerjoin(sysdate)
  DETAIL
   prsn_info->ord[1].ord_provider_alias = trim(pa.alias,3), prsn_info->ord[1].ord_provider_name_first
    = trim(p.name_first,3), prsn_info->ord[1].ord_provider_name_last = trim(p.name_last,3)
  FOOT REPORT
   ml_t_size = size(prsn_info->ord[1].ord_provider_alias)
   IF (ml_t_size < 5)
    FOR (ml_cnt = 1 TO (5 - ml_t_size))
      prsn_info->ord[1].ord_provider_alias = concat("0",prsn_info->ord[1].ord_provider_alias)
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od,
   person p
  WHERE (od.order_id=prsn_info->ord[1].order_id)
   AND od.oe_field_id=mf_od_consphys
   AND p.person_id=od.oe_field_value
  ORDER BY od.action_sequence DESC
  HEAD od.action_sequence
   IF (ml_cpy_to_ind=0)
    prsn_info->ord[1].copy_to_cnt = 0
   ENDIF
  DETAIL
   IF (p.person_id > 0
    AND ml_cpy_to_ind=0)
    prsn_info->ord[1].copy_to_cnt = (prsn_info->ord[1].copy_to_cnt+ 1), stat = alterlist(prsn_info->
     ord[1].copy_to,prsn_info->ord[1].copy_to_cnt), prsn_info->ord[1].copy_to[prsn_info->ord[1].
    copy_to_cnt].person_id = od.oe_field_value,
    prsn_info->ord[1].copy_to[prsn_info->ord[1].copy_to_cnt].name = p.name_full_formatted
   ENDIF
  FOOT  od.action_sequence
   IF ((prsn_info->ord[1].copy_to_cnt != 0))
    ml_cpy_to_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl_alias pa
  WHERE expand(ml_loop,1,prsn_info->ord[1].copy_to_cnt,pa.person_id,prsn_info->ord[1].copy_to[ml_loop
   ].person_id)
   AND pa.prsnl_alias_type_cd=mf_orgdoc_cd
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm > sysdate
  DETAIL
   ml_t_size = 0, ml_pos = locateval(ml_loop,1,prsn_info->ord[1].copy_to_cnt,pa.person_id,prsn_info->
    ord[1].copy_to[ml_loop].person_id)
   IF (ml_pos > 0)
    prsn_info->ord[1].copy_to[ml_pos].alias = trim(pa.alias,3), ml_t_size = size(prsn_info->ord[1].
     copy_to[ml_pos].alias)
    IF (ml_t_size < 5)
     FOR (ml_cnt = 1 TO (5 - ml_t_size))
       prsn_info->ord[1].copy_to[ml_pos].alias = concat("0",prsn_info->ord[1].copy_to[ml_pos].alias)
     ENDFOR
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET prsn_info->ord[1].orc_hl7_slice = build("ORC","|",ms_orc_type,"|",cnvtstring(request->
   trigger_orderid,20),
  "^HNAM_ORDERID","|","|","|",prsn_info->ord[1].ord_status_meaning,
  "|","|","|","|",format(cnvtdatetime(prsn_info->ord[1].transaction_dt_tm),"YYYYMMDDHHMMSS;;q"))
 SET prsn_info->ord[1].obr_hl7_slice = build("OBR|1","|",cnvtstring(request->trigger_orderid,20),
  "^HNAM_ORDERID","|",
  "|",prsn_info->ord[1].ord_catalog_meaning,"^",prsn_info->ord[1].order_mnemonic,"|",
  "|","|",prsn_info->ord[1].ord_collected_date,"|","|",
  "|","|","|","|","|",
  format(cnvtdatetime(prsn_info->ord[1].ord_start_dt_tm),"YYYYMMDDHHMMSS;;q"),"|",prsn_info->ord[1].
  ord_speciment_meaning,"&",prsn_info->ord[1].ord_speciment,
  "|",prsn_info->ord[1].ord_provider_alias,"^",prsn_info->ord[1].ord_provider_name_last,"^",
  prsn_info->ord[1].ord_provider_name_first,"^^^^^^^^^^ORGANIZATION DOCTOR","|","|","|",
  "|","|","|",format(cnvtdatetime(prsn_info->ord[1].action_dt_tm),"YYYYMMDDHHMMSS;;q"),"|",
  "|",prsn_info->ord[1].ord_activity_type_meaning,"|",evaluate(ms_orc_type,"CA","X",""),"|",
  "|")
 FOR (ml_loop = 1 TO prsn_info->ord[1].copy_to_cnt)
   SET prsn_info->ord[1].obr_hl7_slice = build(prsn_info->ord[1].obr_hl7_slice,evaluate(ml_loop,1,"|",
     "~"),evaluate(size(trim(prsn_info->ord[1].copy_to[ml_loop].alias,3)),0,"00000",prsn_info->ord[1]
     .copy_to[ml_loop].alias),"^",prsn_info->ord[1].copy_to[ml_loop].name,
    "^^^")
 ENDFOR
 CALL echorecord(prsn_info)
 SET ms_final_hl7_msg = concat(ms_bm_str,prsn_info->msh_hl7_slice,ms_cr_str,prsn_info->pid_hl7_slice,
  ms_cr_str,
  prsn_info->ord[1].orc_hl7_slice)
 SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,prsn_info->ord[1].obr_hl7_slice)
 IF ((prsn_info->ord[1].comment_cnt > 0))
  FOR (ml_loop = 1 TO prsn_info->ord[1].comment_cnt)
    SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,prsn_info->ord[1].comment_list[ml_loop].
     nte_hl7_slice)
  ENDFOR
 ENDIF
 IF ((prsn_info->cnt > 0))
  FOR (ml_loop = 1 TO prsn_info->cnt)
    SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_cr_str,prsn_info->diag[ml_loop].diag_hl7_slice)
  ENDFOR
 ENDIF
 SET ms_final_hl7_msg = concat(ms_final_hl7_msg,ms_eom_str)
 SET ml_tmp_retval = 100
#exit_program
 SET retval = ml_tmp_retval
 SET log_message = ms_tmp_message
 IF (ml_err_ind=0)
  SELECT INTO value(concat(ms_file_path,"suc/",ms_file_name))
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    CALL print(ms_final_hl7_msg)
   WITH nocounter, maxcol = 5000
  ;end select
  SET ms_cmd_str = concat("mv ",ms_file_path,"suc/",ms_file_name," ",
   ms_file_path,"fin/",ms_file_name)
  IF (ml_err_ind=0)
   CALL dcl(ms_cmd_str,size(ms_cmd_str),ml_dmc_ret)
  ENDIF
 ENDIF
END GO

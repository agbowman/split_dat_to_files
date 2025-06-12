CREATE PROGRAM charting_facesheet:dba
 DECLARE code_value(code_value_codeset,cdf_dp) = f8
 SUBROUTINE code_value(code_value_codeset,cdf_dp)
   SET code_value_cd = 0.0
   SELECT INTO "nl:"
    c.seq
    FROM code_value c
    WHERE ((c.code_set+ 0)=cnvtint(code_value_codeset))
     AND c.cdf_meaning=trim(cdf_dp,3)
     AND ((c.active_ind+ 0)=1)
     AND ((c.begin_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
     AND ((c.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
    DETAIL
     code_value_cd = c.code_value
    WITH nocounter
   ;end select
   RETURN(code_value_cd)
 END ;Subroutine
 IF (validate(rp_hl7_form->initialized,"!")="!")
  SET trace = recpersist
  RECORD rp_hl7_form(
    1 initialized = c1
    1 current_name_cd = f8
  )
  SET trace = norecpersist
  SET rp_hl7_form->initialized = "Y"
  SET rp_hl7_form->current_name_cd = 0
  SELECT INTO "nl:"
   c.seq
   FROM code_value c
   WHERE c.code_set=213
    AND c.cdf_meaning="CURRENT"
    AND c.active_ind=1
    AND begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
   DETAIL
    rp_hl7_form->current_name_cd = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 SET prv_alias = 1
 SET prv_last_name = 2
 SET prv_first_name = 3
 SET prv_middle_name = 4
 SET prv_name_full_formatted = 5
 SET prv_prefix = 6
 SET prv_suffix = 7
 SET prv_degree = 8
 SET prv_username = 9
 DECLARE pm_hl7_provider(prv_row_id,prv_option) = c100
 SUBROUTINE pm_hl7_provider(prv_row_id,prv_option)
   SET prv_rtn_string = fillstring(132," ")
   SET prv_last_name_st = fillstring(132," ")
   SET prv_first_name_st = fillstring(132," ")
   SET prv_name_full_formatted_st = fillstring(132," ")
   SET prv_middle_name_st = fillstring(132," ")
   SET prv_suffix_st = fillstring(132," ")
   SET prv_prefix_st = fillstring(132," ")
   SET prv_free_text = false
   SET prv_username_st = fillstring(50," ")
   SELECT INTO "nl:"
    p.seq
    FROM prsnl p
    WHERE p.person_id=prv_row_id
    DETAIL
     prv_free_text = p.free_text_ind, prv_last_name_st = p.name_last, prv_first_name_st = p
     .name_first,
     prv_name_full_formatted_st = p.name_full_formatted, prv_username_st = p.username
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CASE (prv_option)
     OF prv_alias:
      SET prv_rtn_string = " "
     OF prv_last_name:
      SET prv_rtn_string = prv_last_name_st
     OF prv_first_name:
      SET prv_rtn_string = prv_first_name_st
     OF prv_name_full_formatted:
      SET prv_rtn_string = prv_name_full_formatted_st
     OF prv_username:
      SET prv_rtn_string = prv_username_st
     OF prv_middle_name:
      IF (prv_free_text=true)
       SET rtn_string = " "
      ELSE
       SELECT INTO "nl:"
        n.seq
        FROM person_name n
        WHERE n.person_id=prv_row_id
         AND (n.name_type_cd=rp_hl7_form->current_name_cd)
         AND n.active_ind=1
         AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        DETAIL
         prv_rtn_string = n.name_middle
        WITH nocounter
       ;end select
      ENDIF
     OF prv_prefix:
      IF (prv_free_text=true)
       SET prv_rtn_string = " "
      ELSE
       SELECT INTO "nl:"
        n.seq
        FROM person_name n
        WHERE n.person_id=prv_row_id
         AND (n.name_type_cd=rp_hl7_form->current_name_cd)
         AND n.active_ind=1
         AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        DETAIL
         prv_rtn_string = n.name_prefix
        WITH nocounter
       ;end select
      ENDIF
     OF prv_suffix:
      IF (prv_free_text=true)
       SET prv_rtn_string = " "
      ELSE
       SELECT INTO "nl:"
        n.seq
        FROM person_name n
        WHERE n.person_id=prv_row_id
         AND (n.name_type_cd=rp_hl7_form->current_name_cd)
         AND n.active_ind=1
         AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        DETAIL
         prv_rtn_string = n.name_suffix
        WITH nocounter
       ;end select
      ENDIF
     OF prv_degree:
      IF (prv_free_text=true)
       SET prv_rtn_string = " "
      ELSE
       SELECT INTO "nl:"
        n.seq
        FROM person_name n
        WHERE n.person_id=prv_row_id
         AND (n.name_type_cd=rp_hl7_form->current_name_cd)
         AND n.active_ind=1
         AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        DETAIL
         prv_rtn_string = n.name_degree
        WITH nocounter
       ;end select
      ENDIF
    ENDCASE
   ENDIF
   RETURN(prv_rtn_string)
 END ;Subroutine
#initialize
 SET cur_person_id = request->patient_data.person.person_id
 SET cur_encntr_id = request->patient_data.person.encounter.encntr_id
 SET mrn_alias = request->patient_data.person.mrn.alias
 SET mrn_format = request->patient_data.person.mrn.alias_pool_cd
 SET mrn = substring(1,15,cnvtalias(mrn_alias,mrn_format))
 SET fnbr_alias = request->patient_data.person.encounter.finnbr.alias
 SET fnbr_format = request->patient_data.person.encounter.finnbr.alias_pool_cd
 SET fnbr = substring(1,15,cnvtalias(fnbr_alias,fnbr_format))
 SET barcode_fnbr = concat("*",cnvtalphanum(fnbr_alias),"*")
 SET track_type = 0
 SET track_id = 0
 SET track_type_dp = fillstring(2," ")
 SET track = fillstring(13," ")
 SELECT INTO "nl:"
  mm.media_type_cd, ma.alias
  FROM media_master mm,
   media_master_alias ma
  PLAN (mm
   WHERE ((mm.person_id+ 0)=cur_person_id)
    AND ((mm.encntr_id+ 0)=cur_encntr_id)
    AND ((mm.active_ind+ 0)=1)
    AND ((mm.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((mm.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
   JOIN (ma
   WHERE ((mm.media_master_id+ 0)=ma.media_master_id)
    AND ((ma.active_ind+ 0)=1)
    AND ((ma.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((ma.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
  DETAIL
   track_type = mm.media_type_cd, track_id = ma.alias
 ;end select
 SET pat_name = substring(1,25,request->patient_data.person.name_full_formatted)
 SET upat_name = cnvtupper(substring(1,30,request->patient_data.person.name_full_formatted))
 SET pat_dob = format(request->patient_data.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET pat_age = cnvtage(cnvtdate(request->patient_data.person.birth_dt_tm),cnvttime(request->
   patient_data.person.birth_dt_tm))
 SET upat_age = cnvtupper(cnvtage(cnvtdate(request->patient_data.person.birth_dt_tm),cnvttime(request
    ->patient_data.person.birth_dt_tm)))
 SET pat_prev_last = substring(1,20,request->patient_data.person.prev_name.name_last)
 SET pat_prev_first = substring(1,20,request->patient_data.person.prev_name.name_first)
 IF (textlen(trim(pat_prev_last)) > 0)
  SET pat_prev_name = concat(trim(pat_prev_last),", ",trim(pat_prev_first))
 ELSE
  SET pat_prev_name = " "
 ENDIF
 SET ssn_alias = request->patient_data.person.ssn.alias
 SET ssn_format = request->patient_data.person.ssn.alias_pool_cd
 SET pat_ssn = substring(1,15,cnvtalias(ssn_alias,ssn_format))
 SET pat_hm_addr = substring(1,50,request->patient_data.person.home_address.street_addr)
 SET pat_hm_addr2 = substring(1,50,request->patient_data.person.home_address.street_addr2)
 SET pat_hm_city = substring(1,25,request->patient_data.person.home_address.city)
 SET pat_hm_zipcode = substring(1,12,request->patient_data.person.home_address.zipcode)
 SET pat_hm_city_st = fillstring(30," ")
 SET hm_ph_num = request->patient_data.person.home_phone.phone_num
 SET hm_ph_frm = request->patient_data.person.home_phone.phone_format_cd
 SET pat_hm_phone = substring(1,25,cnvtphone(hm_ph_num,hm_ph_frm))
 SET pat_empl_name = substring(1,50,request->patient_data.person.employer_01.ft_org_name)
 SET pat_empl_job = substring(1,50,request->patient_data.person.employer_01.empl_occupation_text)
 SET wk_ph_num = request->patient_data.person.bus_phone.phone_num
 SET wk_ph_frm = request->patient_data.person.bus_phone.phone_format_cd
 SET pat_wk_phone = substring(1,25,cnvtphone(wk_ph_num,wk_ph_frm))
 SET empl_ph_num = request->patient_data.person.employer_01.phone.phone_num
 SET empl_ph_frm = request->patient_data.person.employer_01.phone.phone_format_cd
 SET pat_empl_phone = substring(1,25,cnvtphone(empl_ph_num,empl_ph_frm))
 SET pat_empl_addr = substring(1,50,request->patient_data.person.employer_01.address.street_addr)
 SET pat_empl_addr2 = substring(1,50,request->patient_data.person.employer_01.address.street_addr2)
 SET pat_empl_addr2_dp = fillstring(30," ")
 SET pat_empl_city = substring(1,25,request->patient_data.person.employer_01.address.city)
 SET pat_empl_zipcode = substring(1,12,request->patient_data.person.employer_01.address.zipcode)
 SET pat_empl_city_st = fillstring(30," ")
 SET gua_name = substring(1,25,request->patient_data.person.guarantor_01.person.name_full_formatted)
 SET gua_dob = format(request->patient_data.person.guarantor_01.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET gua_age = cnvtage(cnvtdate(request->patient_data.person.guarantor_01.person.birth_dt_tm),
  cnvttime(request->patient_data.person.guarantor_01.person.birth_dt_tm))
 SET gua_ssn_alias = request->patient_data.person.guarantor_01.person.ssn.alias
 SET gua_ssn_format = request->patient_data.person.guarantor_01.person.ssn.alias_pool_cd
 SET gua_ssn = substring(1,15,cnvtalias(gua_ssn_alias,gua_ssn_format))
 SET gua_hm_addr = substring(1,50,request->patient_data.person.guarantor_01.person.home_address.
  street_addr)
 SET gua_hm_addr2 = substring(1,50,request->patient_data.person.guarantor_01.person.home_address.
  street_addr2)
 SET gua_hm_city = substring(1,25,request->patient_data.person.guarantor_01.person.home_address.city)
 SET gua_hm_zipcode = substring(1,12,request->patient_data.person.guarantor_01.person.home_address.
  zipcode)
 SET gua_hm_city_st = fillstring(30," ")
 SET gua_hm_ph_num = request->patient_data.person.guarantor_01.person.home_phone.phone_num
 SET gua_hm_ph_frm = request->patient_data.person.guarantor_01.person.home_phone.phone_format_cd
 SET gua_hm_phone = substring(1,25,cnvtphone(gua_hm_ph_num,gua_hm_ph_frm))
 SET gua_empl_name = substring(1,50,request->patient_data.person.guarantor_01.person.employer_01.
  ft_org_name)
 SET gua_empl_job = substring(1,50,request->patient_data.person.guarantor_01.person.employer_01.
  empl_occupation_text)
 SET gua_empl_ph_num = request->patient_data.person.guarantor_01.person.employer_01.phone.phone_num
 SET gua_empl_ph_frm = request->patient_data.person.guarantor_01.person.employer_01.phone.
 phone_format_cd
 SET gua_empl_phone = substring(1,25,cnvtphone(gua_empl_ph_num,gua_empl_ph_frm))
 SET gua_empl_addr = substring(1,50,request->patient_data.person.guarantor_01.person.employer_01.
  address.street_addr)
 SET gua_empl_addr2 = substring(1,50,request->patient_data.person.guarantor_01.person.employer_01.
  address.street_addr2)
 SET gua_empl_addr2_dp = fillstring(30," ")
 SET gua_empl_city = substring(1,25,request->patient_data.person.guarantor_01.person.employer_01.
  address.city)
 SET gua_empl_zipcode = substring(1,12,request->patient_data.person.guarantor_01.person.employer_01.
  address.zipcode)
 SET gua_empl_city_st = fillstring(30," ")
 SET emc_name = substring(1,25,request->patient_data.person.emc.person.name_full_formatted)
 SET emc_dob = format(request->patient_data.person.emc.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET emc_age = cnvtage(cnvtdate(request->patient_data.person.emc.person.birth_dt_tm),cnvttime(request
   ->patient_data.person.emc.person.birth_dt_tm))
 SET emc_wk_ph_num = request->patient_data.person.emc.person.bus_phone.phone_num
 SET emc_wk_ph_frm = request->patient_data.person.emc.person.bus_phone.phone_format_cd
 SET emc_wk_phone = substring(1,25,cnvtphone(emc_wk_ph_num,emc_wk_ph_frm))
 SET emc_hm_addr = substring(1,50,request->patient_data.person.emc.person.home_address.street_addr)
 SET emc_hm_addr2 = substring(1,50,request->patient_data.person.emc.person.home_address.street_addr2)
 SET emc_hm_city = substring(1,25,request->patient_data.person.emc.person.home_address.city)
 SET emc_hm_zipcode = substring(1,12,request->patient_data.person.emc.person.home_address.zipcode)
 SET emc_hm_city_st = fillstring(30," ")
 SET emc_hm_ph_num = request->patient_data.person.emc.person.home_phone.phone_num
 SET emc_hm_ph_frm = request->patient_data.person.emc.person.home_phone.phone_format_cd
 SET emc_hm_phone = substring(1,25,cnvtphone(emc_hm_ph_num,emc_hm_ph_frm))
 SET s1_last = substring(1,20,request->patient_data.person.subscriber_01.person.current_name.
  name_last)
 SET s1_first = substring(1,20,request->patient_data.person.subscriber_01.person.current_name.
  name_first)
 IF (textlen(trim(s1_last)) > 0)
  SET s1_name = concat(trim(s1_last),", ",trim(s1_first))
 ELSE
  SET s1_name = " "
 ENDIF
 SET s1_dob = format(request->patient_data.person.subscriber_01.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET s1_age = cnvtage(cnvtdate(request->patient_data.person.subscriber_01.person.birth_dt_tm),
  cnvttime(request->patient_data.person.subscriber_01.person.birth_dt_tm))
 SET s1_empl_name = substring(1,20,request->patient_data.person.subscriber_01.person.employer_01.
  ft_org_name)
 SET s1_empl_job = substring(1,20,request->patient_data.person.subscriber_01.person.employer_01.
  empl_occupation_text)
 SET s1_empl_ph_num = request->patient_data.person.subscriber_01.person.employer_01.phone.phone_num
 SET s1_empl_ph_frm = request->patient_data.person.subscriber_01.person.employer_01.phone.
 phone_format_cd
 SET s1_empl_phone = substring(1,25,cnvtphone(s1_empl_ph_num,s1_empl_ph_frm))
 SET s1_empl_addr = substring(1,50,request->patient_data.person.subscriber_01.person.employer_01.
  address.street_addr)
 SET s1_empl_addr2 = substring(1,50,request->patient_data.person.subscriber_01.person.employer_01.
  address.street_addr2)
 SET s1_empl_addr2_dp = fillstring(30," ")
 SET s1_empl_city = substring(1,25,request->patient_data.person.subscriber_01.person.employer_01.
  address.city)
 SET s1_empl_zipcode = substring(1,12,request->patient_data.person.subscriber_01.person.employer_01.
  address.zipcode)
 SET s1_empl_city_st = fillstring(30," ")
 SET s1_plan_name = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  plan_info.plan_name)
 SET s1_policy_no = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  member_nbr)
 SET s1_ph_num = request->patient_data.person.subscriber_01.person.health_plan.phone_num
 SET s1_ph_frm = request->patient_data.person.subscriber_01.person.health_plan.phone_format_cd
 SET s1_plan_phone = substring(1,25,cnvtphone(s1_ph_num,s1_ph_frm))
 SET s1_plan_addr = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  address.street_addr)
 SET s1_plan_addr2 = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  address.street_addr2)
 SET s1_plan_city = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  address.city)
 SET s1_plan_zipcode = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  address.zipcode)
 SET s1_plan_city_st = fillstring(30," ")
 SET s1_precert_no = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  visit_info.auth_info_01.auth_nbr)
 SET s1_precert_ph = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  visit_info.auth_info_01.auth_detail.auth_phone_num)
 SET s1_precert_phone = concat("(",substring(1,3,s1_precert_ph),") ",substring(4,3,s1_precert_ph),"-",
  substring(7,4,s1_precert_ph))
 SET s1_group_no = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  org_plan.group_nbr)
 SET s2_last = substring(1,20,request->patient_data.person.subscriber_02.person.current_name.
  name_last)
 SET s2_first = substring(1,20,request->patient_data.person.subscriber_02.person.current_name.
  name_first)
 IF (textlen(trim(s2_last)) > 0)
  SET s2_name = concat(trim(s2_last),", ",trim(s2_first))
 ELSE
  SET s2_name = " "
 ENDIF
 SET s2_dob = format(request->patient_data.person.subscriber_02.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET s2_age = cnvtage(cnvtdate(request->patient_data.person.subscriber_02.person.birth_dt_tm),
  cnvttime(request->patient_data.person.subscriber_02.person.birth_dt_tm))
 SET s2_empl_name = substring(1,20,request->patient_data.person.subscriber_02.person.employer_01.
  ft_org_name)
 SET s2_empl_job = substring(1,20,request->patient_data.person.subscriber_02.person.employer_01.
  empl_occupation_text)
 SET s2_empl_ph_num = request->patient_data.person.subscriber_02.person.employer_01.phone.phone_num
 SET s2_empl_ph_frm = request->patient_data.person.subscriber_02.person.employer_01.phone.
 phone_format_cd
 SET s2_empl_phone = substring(1,25,cnvtphone(s2_empl_ph_num,s2_empl_ph_frm))
 SET s2_empl_addr = substring(1,50,request->patient_data.person.subscriber_02.person.employer_01.
  address.street_addr)
 SET s2_empl_addr2 = substring(1,50,request->patient_data.person.subscriber_02.person.employer_01.
  address.street_addr2)
 SET s2_empl_addr2_dp = fillstring(30," ")
 SET s2_empl_city = substring(1,25,request->patient_data.person.subscriber_02.person.employer_01.
  address.city)
 SET s2_empl_zipcode = substring(1,12,request->patient_data.person.subscriber_02.person.employer_01.
  address.zipcode)
 SET s2_empl_city_st = fillstring(30," ")
 SET s2_plan_name = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  plan_info.plan_name)
 SET s2_policy_no = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  member_nbr)
 SET s2_ph_num = request->patient_data.person.subscriber_02.person.health_plan.phone_num
 SET s2_ph_frm = request->patient_data.person.subscriber_02.person.health_plan.phone_format_cd
 SET s2_plan_phone = substring(1,25,cnvtphone(s2_ph_num,s2_ph_frm))
 SET s2_plan_addr = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  address.street_addr)
 SET s2_plan_addr2 = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  address.street_addr2)
 SET s2_plan_city = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  address.city)
 SET s2_plan_zipcode = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  address.zipcode)
 SET s2_plan_city_st = fillstring(30," ")
 SET s2_precert_no = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  visit_info.auth_info_01.auth_nbr)
 SET s2_precert_ph = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  visit_info.auth_info_01.auth_detail.auth_phone_num)
 SET s2_precert_phone = concat("(",substring(1,3,s2_precert_ph),") ",substring(4,3,s2_precert_ph),"-",
  substring(7,4,s2_precert_ph))
 SET s2_group_no = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  org_plan.group_nbr)
 SET pcp_doctor = substring(1,15,pm_hl7_provider(request->patient_data.person.pcp.prsnl_person_id,
   prv_name_full_formatted))
 SET admit_doctor = substring(1,15,trim(pm_hl7_provider(request->patient_data.person.encounter.
    admitdoc.prsnl_person_id,prv_name_full_formatted)))
 SET admit_clerk = substring(1,15,pm_hl7_provider(request->patient_data.person.encounter.reg_prsnl_id,
   prv_name_full_formatted))
 SET attend_doctor = substring(1,15,pm_hl7_provider(request->patient_data.person.encounter.attenddoc.
   prsnl_person_id,prv_name_full_formatted))
 SET admit_doc_id = request->patient_data.person.encounter.admitdoc.prsnl_person_id
 SET admit_doc_no = fillstring(25," ")
 SET admit_doc_phone = fillstring(25," ")
 SELECT INTO "nl:"
  pa.alias, ph.phone_num, ph.phone_format_cd
  FROM prsnl p,
   prsnl_alias pa,
   phone ph
  PLAN (p
   WHERE p.person_id=admit_doc_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.alias_pool_cd=0.0
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ph
   WHERE p.person_id=ph.parent_entity_id
    AND ph.parent_entity_name="PRSNL"
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   admit_doc_no = substring(1,25,trim(pa.alias)), admit_doc_phone = substring(1,25,cnvtphone(ph
     .phone_num,ph.phone_format_cd))
 ;end select
 SET i = 0
 SET doc_cd = code_value(333,"ADMITDOC")
 SET prev_enc1_reg_dt_tm = fillstring(20," ")
 SET prev_enc1_type = fillstring(30," ")
 SET prev_enc1_phy = fillstring(30," ")
 SET prev_enc2_reg_dt_tm = fillstring(20," ")
 SET prev_enc2_type = fillstring(30," ")
 SET prev_enc2_phy = fillstring(30," ")
 SET prev_enc3_reg_dt_tm = fillstring(20," ")
 SET prev_enc3_type = fillstring(30," ")
 SET prev_enc3_phy = fillstring(30," ")
 SELECT INTO "nl:"
  e.reg_dt_tm, temp_type = trim(uar_get_code_display(e.encntr_type_cd)), temp_doc = trim(substring(1,
    30,doc.name_full_formatted))
  FROM encounter e,
   encntr_prsnl_reltn ep,
   prsnl doc,
   dummyt d1,
   dummyt d2
  PLAN (e
   WHERE e.person_id=cur_person_id
    AND e.encntr_id != cur_encntr_id
    AND ((e.active_ind+ 0)=1)
    AND ((e.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((e.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
   JOIN (d1)
   JOIN (ep
   WHERE ((e.encntr_id+ 0)=ep.encntr_id)
    AND ((ep.encntr_prsnl_r_cd+ 0)=doc_cd)
    AND ((ep.active_ind+ 0)=1)
    AND ((ep.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((ep.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
   JOIN (d2)
   JOIN (doc
   WHERE ((ep.prsnl_person_id+ 0)=doc.person_id)
    AND ((doc.active_ind+ 0)=1)
    AND doc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND doc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY e.reg_dt_tm DESC
  DETAIL
   i = (i+ 1)
   IF (i=1)
    prev_enc1_reg_dt_tm = format(e.reg_dt_tm,"MM/DD/YYYY HH:MM;;D"), prev_enc1_type = temp_type,
    prev_enc1_phy = temp_doc
   ELSEIF (i=2)
    prev_enc2_reg_dt_tm = format(e.reg_dt_tm,"MM/DD/YYYY HH:MM;;D"), prev_enc2_type = temp_type,
    prev_enc2_phy = temp_doc
   ELSEIF (i=3)
    prev_enc3_reg_dt_tm = format(e.reg_dt_tm,"MM/DD/YYYY HH:MM;;D"), prev_enc3_type = temp_type,
    prev_enc3_phy = temp_doc
   ENDIF
  WITH dontcare = ep, outerjoin = d1, dontcare = doc,
   outerjoin = d2
 ;end select
 SET est_dt_tm = format(request->patient_data.person.encounter.est_arrive_dt_tm,"MM/DD/YYYY HH:MM;;D"
  )
 SET est_dt = substring(1,10,est_dt_tm)
 SET est_tm = substring(12,16,est_dt_tm)
 SET reg_dt_tm = format(request->patient_data.person.encounter.reg_dt_tm,"MM/DD/YYYY HH:MM;;D")
 SET reg_dt = substring(1,10,reg_dt_tm)
 SET reg_tm = substring(12,16,reg_dt_tm)
 SET reason4visit = substring(1,40,request->patient_data.person.encounter.reason_for_visit)
 SET acc_dt_tm = format(request->patient_data.person.encounter.accident_01.accident_dt_tm,
  "MM/DD/YYYY HH:MM;;D")
#main
 SELECT INTO  $1
  pat_sex_dp = substring(1,6,uar_get_code_display(request->patient_data.person.sex_cd)), upat_sex_dp
   = cnvtupper(substring(1,6,uar_get_code_display(request->patient_data.person.sex_cd))), pat_race_dp
   = substring(1,13,uar_get_code_display(request->patient_data.person.race_cd)),
  pat_ms_dp = uar_get_code_display(request->patient_data.person.marital_type_cd), pat_relg_dp =
  substring(1,12,uar_get_code_display(request->patient_data.person.religion_cd)), pat_hm_st_dp =
  substring(1,14,uar_get_code_display(request->patient_data.person.home_address.state_cd)),
  pat_empl_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person.employer_01.
    address.state_cd)), gua_sex_dp = uar_get_code_display(request->patient_data.person.guarantor_01.
   person.sex_cd), gua_ms_dp = uar_get_code_display(request->patient_data.person.guarantor_01.person.
   marital_type_cd),
  gua_reltn_dp = substring(1,10,uar_get_code_display(request->patient_data.person.guarantor_01.
    related_person_reltn_cd)), gua_hm_st_dp = substring(1,14,uar_get_code_display(request->
    patient_data.person.guarantor_01.person.home_address.state_cd)), gua_empl_st_dp = substring(1,14,
   uar_get_code_display(request->patient_data.person.guarantor_01.person.employer_01.address.state_cd
    )),
  gua_empl_status = uar_get_code_display(request->patient_data.person.guarantor_01.person.employer_01
   .empl_status_cd), emc_sex_dp = uar_get_code_display(request->patient_data.person.emc.person.sex_cd
   ), emc_reltn_dp = substring(1,10,uar_get_code_display(request->patient_data.person.emc.
    related_person_reltn_cd)),
  emc_hm_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person.emc.person.
    home_address.state_cd)), s1_sex_dp = uar_get_code_display(request->patient_data.person.
   subscriber_01.person.sex_cd), s1_ms_dp = uar_get_code_display(request->patient_data.person.
   subscriber_01.person.marital_type_cd),
  s1_reltn_dp = substring(1,10,uar_get_code_display(request->patient_data.person.subscriber_01.
    related_person_reltn_cd)), s1_hm_st_dp = substring(1,14,uar_get_code_display(request->
    patient_data.person.subscriber_01.person.home_address.state_cd)), s1_empl_st_dp = substring(1,14,
   uar_get_code_display(request->patient_data.person.subscriber_01.person.employer_01.address.
    state_cd)),
  s1_empl_status = uar_get_code_display(request->patient_data.person.subscriber_01.person.employer_01
   .empl_status_cd), s1_plan_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person
    .subscriber_01.person.health_plan.address.state_cd)), s2_sex_dp = uar_get_code_display(request->
   patient_data.person.subscriber_02.person.sex_cd),
  s2_ms_dp = uar_get_code_display(request->patient_data.person.subscriber_02.person.marital_type_cd),
  s2_reltn_dp = substring(1,10,uar_get_code_display(request->patient_data.person.subscriber_02.
    related_person_reltn_cd)), s2_hm_st_dp = substring(1,14,uar_get_code_display(request->
    patient_data.person.subscriber_02.person.home_address.state_cd)),
  s2_empl_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person.subscriber_02.
    person.employer_01.address.state_cd)), s2_empl_status = uar_get_code_display(request->
   patient_data.person.subscriber_02.person.employer_01.empl_status_cd), s2_plan_st_dp = substring(1,
   14,uar_get_code_display(request->patient_data.person.subscriber_02.person.health_plan.address.
    state_cd)),
  encntr_type_dp = uar_get_code_display(request->patient_data.person.encounter.encntr_type_cd),
  adm_type_dp = substring(1,22,uar_get_code_display(request->patient_data.person.encounter.
    admit_type_cd)), adm_mode_dp = substring(1,22,uar_get_code_display(request->patient_data.person.
    encounter.admit_mode_cd)),
  adm_src_dp = substring(1,22,uar_get_code_display(request->patient_data.person.encounter.
    admit_src_cd)), vip_dp = uar_get_code_display(request->patient_data.person.vip_cd),
  confid_level_dp = uar_get_code_display(request->patient_data.person.confid_level_cd),
  facility_dp = cnvtupper(trim(uar_get_code_description(request->patient_data.person.encounter.
     loc_facility_cd))), nurse_stn_dp = trim(uar_get_code_display(request->patient_data.person.
    encounter.loc_nurse_unit_cd)), room_dp = substring(1,4,uar_get_code_display(request->patient_data
    .person.encounter.loc_room_cd)),
  bed_dp = substring(1,4,uar_get_code_display(request->patient_data.person.encounter.loc_bed_cd)),
  med_srv_dp = uar_get_code_display(request->patient_data.person.encounter.med_service_cd), adr_dp =
  uar_get_code_display(request->patient_data.person.patient.living_will_cd),
  acc_type_dp = substring(1,40,uar_get_code_display(request->patient_data.person.encounter.
    accident_01.accident_cd))
  FROM dummyt d
  PLAN (d)
  DETAIL
   track_type_dp = substring(1,2,uar_get_code_display(track_type)), track = concat(trim(track_type_dp
     ),"-",cnvtstring(track_id)), barcode_track = concat("*",cnvtalphanum(track),"*")
   IF (textlen(trim(pat_hm_city)) > 0)
    pat_hm_city_st = concat(trim(pat_hm_city),", ",trim(pat_hm_st_dp))
   ENDIF
   IF (textlen(trim(pat_empl_city)) > 0)
    pat_empl_city_st = concat(trim(pat_empl_city),", ",trim(pat_empl_st_dp))
   ENDIF
   IF (textlen(trim(gua_hm_city)) > 0)
    gua_hm_city_st = concat(trim(gua_hm_city),", ",trim(gua_hm_st_dp))
   ENDIF
   IF (textlen(trim(gua_empl_city)) > 0)
    gua_empl_city_st = concat(trim(gua_empl_city),", ",trim(gua_empl_st_dp))
   ENDIF
   IF (textlen(trim(emc_hm_city)) > 0)
    emc_hm_city_st = concat(trim(emc_hm_city),", ",trim(emc_hm_st_dp))
   ENDIF
   IF (textlen(trim(s1_empl_city)) > 0)
    s1_empl_city_st = concat(trim(s1_empl_city),", ",trim(s1_empl_st_dp))
   ENDIF
   IF (textlen(trim(s1_plan_city)) > 0)
    s1_plan_city_st = concat(trim(s1_plan_city),", ",trim(s1_plan_st_dp))
   ENDIF
   IF (textlen(trim(s2_empl_city)) > 0)
    s2_empl_city_st = concat(trim(s2_empl_city),", ",trim(s2_empl_st_dp))
   ENDIF
   IF (textlen(trim(s2_plan_city)) > 0)
    s2_plan_city_st = concat(trim(s2_plan_city),", ",trim(s2_plan_st_dp))
   ENDIF
   IF (textlen(trim(acc_dt_tm)) > 0)
    acc_ind = "Y"
   ELSE
    acc_ind = "N"
   ENDIF
   cur_row = 32, next_line = 9, next_section = 11,
   next_line2 = 14, name_col = 61, sex_col = 228,
   age_col = 428, ms_col = 450, age2_col = 380,
   ssn_col = 283, hm_addr_col = 112, city1_col = 332,
   empl_addr_col = 125, claim_addr_col = 117, city2_col = 110,
   prev_date_col = 66, prev_type_col = 153, prev_phy_col = 235,
   visit_admit_col = 335, visit_type_col = 472, row + 1,
   CALL print(calcpos(220,cur_row)), "{CPI/15}{FONT/4}{B}",
   ">>>>>>>> PATIENT INFORMATION <<<<<<<<{ENDB}",
   row + 1, cur_row = (cur_row+ (next_line * 2)), row + 1,
   CALL print(calcpos(name_col,cur_row)), "Name: ", pat_name,
   row + 1,
   CALL print(calcpos(sex_col,cur_row)), "Sex: ",
   pat_sex_dp, row + 1,
   CALL print(calcpos(272,cur_row)),
   "Race: ", pat_race_dp, row + 1,
   CALL print(calcpos(329,cur_row)), "DOB: ", pat_dob,
   row + 1,
   CALL print(calcpos(age_col,cur_row)), "Age: ",
   pat_age, row + 1,
   CALL print(calcpos(490,cur_row)),
   "MS: ", pat_ms_dp, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Previous Name: ", pat_prev_name, row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "Social Security Number: ", pat_ssn,
   row + 1,
   CALL print(calcpos(age_col,cur_row)), "Religion: ",
   pat_relg_dp, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(name_col,cur_row)), "Home Address: ",
   row + 1,
   CALL print(calcpos(hm_addr_col,cur_row)), pat_hm_addr,
   row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "City/State/Zip: ",
   row + 1,
   CALL print(calcpos(city1_col,cur_row)), pat_hm_city_st,
   row + 1,
   CALL print(calcpos(age_col,cur_row)), "Home Phone: ",
   pat_hm_phone, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(hm_addr_col,cur_row)), pat_hm_addr2,
   row + 1,
   CALL print(calcpos(city1_col,cur_row)), pat_hm_zipcode,
   row + 1,
   CALL print(calcpos(age_col,cur_row)), "Work Phone: ",
   pat_wk_phone, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(name_col,cur_row)), "Employer Name: ",
   pat_empl_name, row + 1,
   CALL print(calcpos(age_col,cur_row)),
   "Employer Phone: ", pat_empl_phone, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Employer Address: ", row + 1,
   CALL print(calcpos(empl_addr_col,cur_row)),
   pat_empl_addr, row + 1,
   CALL print(calcpos(ssn_col,cur_row)),
   "City/State/Zip: ", row + 1,
   CALL print(calcpos(city1_col,cur_row)),
   pat_empl_city_st, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(empl_addr_col,cur_row)), pat_empl_addr2,
   row + 1,
   CALL print(calcpos(city1_col,cur_row)), pat_empl_zipcode,
   row + 1, cur_row = (cur_row+ next_section), row + 1,
   CALL print(calcpos(215,cur_row)), "{B}>>>>>>>> GUARANTOR INFORMATION <<<<<<<<{ENDB}", row + 1,
   cur_row = (cur_row+ (next_line * 2)), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Name: ", gua_name, row + 1,
   CALL print(calcpos(sex_col,cur_row)), "Sex: ", gua_sex_dp,
   row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "DOB: ",
   gua_dob, row + 1,
   CALL print(calcpos(age2_col,cur_row)),
   "Age: ", gua_age, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Patient's Reltn to GT: ", gua_reltn_dp, row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "Social Security Number: ", gua_ssn,
   row + 1, cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)), "Billing Address: ", row + 1,
   CALL print(calcpos(claim_addr_col,cur_row)), gua_hm_addr, row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "City/State/Zip: ", row + 1,
   CALL print(calcpos(city1_col,cur_row)), gua_hm_city_st, row + 1,
   CALL print(calcpos(age_col,cur_row)), "Home Phone: ", gua_hm_phone,
   row + 1, cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(claim_addr_col,cur_row)), gua_hm_addr2, row + 1,
   CALL print(calcpos(city1_col,cur_row)), gua_hm_zipcode, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Employer Name: ", gua_empl_name, row + 1,
   CALL print(calcpos(age_col,cur_row)), "Employer Phone: ", gua_empl_phone,
   row + 1, cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)), "Employer Address: ", row + 1,
   CALL print(calcpos(empl_addr_col,cur_row)), gua_empl_addr, row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "City/State/Zip: ", row + 1,
   CALL print(calcpos(city1_col,cur_row)), gua_empl_city_st, row + 1,
   CALL print(calcpos(age_col,cur_row)), "Employment Status: ", gua_empl_status,
   row + 1, cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(empl_addr_col,cur_row)), gua_empl_addr2, row + 1,
   CALL print(calcpos(city1_col,cur_row)), gua_empl_zipcode, row + 1,
   cur_row = (cur_row+ next_section), row + 1,
   CALL print(calcpos(190,cur_row)),
   "{B}>>>>>>>> EMERGENCY CONTACT INFORMATION <<<<<<<<{ENDB}", row + 1, cur_row = (cur_row+ (
   next_line * 2)),
   row + 1,
   CALL print(calcpos(name_col,cur_row)), "Name: ",
   emc_name, row + 1,
   CALL print(calcpos(sex_col,cur_row)),
   "Sex: ", emc_sex_dp, row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "DOB: ", emc_dob,
   row + 1,
   CALL print(calcpos(age2_col,cur_row)), "Age: ",
   emc_age, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(name_col,cur_row)), "Patient's Reltn to EMC: ",
   emc_reltn_dp, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(name_col,cur_row)), "Home Address: ",
   row + 1,
   CALL print(calcpos(hm_addr_col,cur_row)), emc_hm_addr,
   row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "City/State/Zip: ",
   row + 1,
   CALL print(calcpos(city1_col,cur_row)), emc_hm_city_st,
   row + 1,
   CALL print(calcpos(age_col,cur_row)), "Home Phone: ",
   emc_hm_phone, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(hm_addr_col,cur_row)), emc_hm_addr2,
   row + 1,
   CALL print(calcpos(city1_col,cur_row)), emc_hm_zipcode,
   row + 1, cur_row = (cur_row+ next_section), row + 1,
   CALL print(calcpos(175,cur_row)),
   "{B}>>>>>>>> PRIMARY INSURED/INSURANCE INFORMATION <<<<<<<<{ENDB}", row + 1,
   cur_row = (cur_row+ (next_line * 2)), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Name: ", s1_name, row + 1,
   CALL print(calcpos(sex_col,cur_row)), "Sex: ", s1_sex_dp,
   row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "DOB: ",
   s1_dob, row + 1,
   CALL print(calcpos(age2_col,cur_row)),
   "Age: ", s1_age, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Patient's Reltn to Sub1: ", s1_reltn_dp, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Employer Name: ", s1_empl_name, row + 1,
   CALL print(calcpos(age_col,cur_row)), "Employer Phone: ", s1_empl_phone,
   row + 1, cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)), "Employer Address: ", row + 1,
   CALL print(calcpos(empl_addr_col,cur_row)), s1_empl_addr, row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "City/State/Zip: ", row + 1,
   CALL print(calcpos(city1_col,cur_row)), s1_empl_city_st, row + 1,
   CALL print(calcpos(age_col,cur_row)), "Employment Status: ", s1_empl_status,
   row + 1, cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(empl_addr_col,cur_row)), s1_empl_addr2, row + 1,
   CALL print(calcpos(city1_col,cur_row)), s1_empl_zipcode, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Insurance Name: ", s1_plan_name, row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "Policy Number: ", s1_policy_no,
   row + 1,
   CALL print(calcpos(age_col,cur_row)), "Phone Number: ",
   s1_plan_phone, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(name_col,cur_row)), "Claim's Address: ",
   row + 1,
   CALL print(calcpos(claim_addr_col,cur_row)), s1_plan_addr,
   row + 1, cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(claim_addr_col,cur_row)), s1_plan_addr2, row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "Authorization Number: ", s1_precert_no,
   row + 1,
   CALL print(calcpos(age_col,cur_row)), "Authorization Phone Number: ",
   s1_precert_phone, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(name_col,cur_row)), "City/State/Zip: ",
   row + 1,
   CALL print(calcpos(city2_col,cur_row)), s1_plan_city_st,
   row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "Group Number: ",
   s1_group_no, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(city2_col,cur_row)), s1_plan_zipcode,
   row + 1, cur_row = (cur_row+ next_section), row + 1,
   CALL print(calcpos(170,cur_row)),
   "{B}>>>>>>>> SECONDARY INSURED/INSURANCE INFORMATION <<<<<<<<{ENDB}", row + 1,
   cur_row = (cur_row+ (next_line * 2)), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Name: ", s2_name, row + 1,
   CALL print(calcpos(sex_col,cur_row)), "Sex: ", s2_sex_dp,
   row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "DOB: ",
   s2_dob, row + 1,
   CALL print(calcpos(age2_col,cur_row)),
   "Age: ", s2_age, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Patient's Reltn to Sub2: ", s2_reltn_dp, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Employer Name: ", s2_empl_name, row + 1,
   CALL print(calcpos(age_col,cur_row)), "Employer Phone: ", s2_empl_phone,
   row + 1, cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)), "Employer Address: ", row + 1,
   CALL print(calcpos(empl_addr_col,cur_row)), s2_empl_addr, row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "City/State/Zip: ", row + 1,
   CALL print(calcpos(city1_col,cur_row)), s2_empl_city_st, row + 1,
   CALL print(calcpos(age_col,cur_row)), "Employment Status: ", s2_empl_status,
   row + 1, cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(empl_addr_col,cur_row)), s2_empl_addr2, row + 1,
   CALL print(calcpos(city1_col,cur_row)), s2_empl_zipcode, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Insurance Name: ", s2_plan_name, row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "Policy Number: ", s2_policy_no,
   row + 1,
   CALL print(calcpos(age_col,cur_row)), "Phone Number: ",
   s2_plan_phone, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(name_col,cur_row)), "Claim's Address: ",
   row + 1,
   CALL print(calcpos(claim_addr_col,cur_row)), s2_plan_addr,
   row + 1,
   CALL print(calcpos(ssn_col,cur_row)), "Authorization Number: ",
   s2_precert_no, row + 1,
   CALL print(calcpos(age_col,cur_row)),
   "Authorization Phone Number: ", s2_precert_phone, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(claim_addr_col,cur_row)),
   s2_plan_addr2, row + 1,
   CALL print(calcpos(ssn_col,cur_row)),
   "Group Number: ", s2_group_no, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "City/State/Zip: ", row + 1,
   CALL print(calcpos(city2_col,cur_row)),
   s2_plan_city_st, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(city2_col,cur_row)), s2_plan_zipcode,
   row + 1, cur_row = (cur_row+ next_section), row + 1,
   CALL print(calcpos(name_col,cur_row)), "{B}>>>>>>>> PREVIOUS ENCOUNTER INFORMATION <<<<<<<<{ENDB}",
   row + 1,
   CALL print(calcpos(375,cur_row)), "{B}>>>>>>>> VISIT INFORMATION <<<<<<<<{ENDB}", row + 1,
   cur_row = (cur_row+ (next_line * 2)), row + 1,
   CALL print(calcpos(75,cur_row)),
   "{B}{U}Visit Date(s){ENDU}{ENDB}", row + 1,
   CALL print(calcpos(prev_type_col,cur_row)),
   "{B}{U}Visit Type{ENDU}{ENDB}", row + 1,
   CALL print(calcpos(prev_phy_col,cur_row)),
   "{B}{U}Physician{ENDU}{ENDB}", row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)),
   "Reg Date/Time: ", reg_dt_tm, row + 1,
   CALL print(calcpos(visit_type_col,cur_row)), "Patient Type: ", encntr_type_dp,
   row + 1, cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(prev_date_col,cur_row)), prev_enc1_reg_dt_tm, row + 1,
   CALL print(calcpos(prev_type_col,cur_row)), prev_enc1_type, row + 1,
   CALL print(calcpos(prev_phy_col,cur_row)), prev_enc1_phy, row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)), "Admit Type: ", adm_type_dp,
   row + 1,
   CALL print(calcpos(visit_type_col,cur_row)), "Reg Clerk: ",
   admit_clerk, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(prev_date_col,cur_row)), prev_enc2_reg_dt_tm,
   row + 1,
   CALL print(calcpos(prev_type_col,cur_row)), prev_enc2_type,
   row + 1,
   CALL print(calcpos(prev_phy_col,cur_row)), prev_enc2_phy,
   row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)), "Admit Source: ",
   adm_src_dp, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(prev_date_col,cur_row)), prev_enc3_reg_dt_tm,
   row + 1,
   CALL print(calcpos(prev_type_col,cur_row)), prev_enc3_type,
   row + 1,
   CALL print(calcpos(prev_phy_col,cur_row)), prev_enc3_phy,
   row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)), "Admit Reason: ",
   reason4visit, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)), "Estimated Date of Arrival: ",
   est_dt_tm, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)), "Admitting Physician: ",
   admit_doctor, admit_doc_no, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)),
   "Attending Physician: ", attend_doctor, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)),
   "Primary Care Physician: ", pcp_doctor, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(90,cur_row)),
   "{B}>>>>>>>> ACCIDENT INFORMATION <<<<<<<<{ENDB}", row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)), "VIP Indicator: ",
   vip_dp, row + 1, cur_row = (cur_row+ next_line),
   row + 1,
   CALL print(calcpos(name_col,cur_row)), "Accident: ",
   acc_ind, row + 1,
   CALL print(calcpos(prev_type_col,cur_row)),
   "Accident Date/Time: ", acc_dt_tm, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "Accident Type: ", acc_type_dp, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)),
   "Advance Directive: ", adr_dp, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)),
   "Location: ", nurse_stn_dp, row + 1,
   CALL print(calcpos(visit_type_col,cur_row)), "Room/Bed: ", room_dp,
   "/", bed_dp, row + 1,
   cur_row = (cur_row+ next_line), row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)),
   "Medical Service: ", med_srv_dp, row + 1,
   cur_row = (cur_row+ next_line), row + 1, "{CPI/9}{FONT/4}",
   cur_row = (cur_row+ (next_line2 * 2)), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   upat_name, row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)),
   upat_sex_dp, " / ", upat_age,
   row + 1, cur_row = (cur_row+ next_line2), row + 1,
   CALL print(calcpos(name_col,cur_row)), "MRN: ", mrn,
   row + 1,
   CALL print(calcpos(visit_admit_col,cur_row)), "FIN: ",
   fnbr, row + 1, cur_row = (cur_row+ next_line2),
   row + 1,
   CALL print(calcpos(name_col,cur_row)), facility_dp,
   row + 1, cur_row = (cur_row+ next_line2), row + 1,
   CALL print(calcpos(age_col,cur_row)), "Print Dt/Tm: ", curdate,
   "  ", curtime, row + 1,
   cur_row = ((cur_row+ (next_line2 * 2))+ 20), row + 1,
   CALL print(calcpos(120,cur_row)),
   "{BCR/100}{FR/0}{CPI/6}{F/28/2}", barcode_fnbr, row + 1,
   CALL print(calcpos(350,cur_row)), "{BCR/100}{FR/0}{CPI/6}{F/28/2}", barcode_track
  WITH nocounter, maxrow = 100, noformfeed,
   dio = 36
 ;end select
#end_program
END GO

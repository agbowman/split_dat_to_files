CREATE PROGRAM bhs_mp_get_aliases_by_mrn:dba
 PROMPT
  "MRN:" = "",
  "Alias Pool:" = ""
  WITH s_mrn, s_alias_pool
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat
     2 person_id = vc
     2 pat_name = vc
     2 dob = vc
     2 sex = vc
     2 address1 = vc
     2 address2 = vc
     2 city = vc
     2 state = vc
     2 zip = vc
     2 phone = vc
     2 race = vc
     2 alias[*]
       3 alias = vc
       3 alias_type = vc
       3 active = vc
       3 end_effective_dt_tm = vc
       3 pool = vc
       3 contributor_sys = vc
       3 last_updt_dt_tm = vc
       3 prsnl_ind = vc
       3 order_cnt = vc
 ) WITH protect
 DECLARE ms_mrn = vc WITH protect, constant(trim( $S_MRN,3))
 DECLARE mf_alias_pool = f8 WITH protect, constant(cnvtreal( $S_ALIAS_POOL))
 DECLARE mf_cs4_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2623"))
 DECLARE mf_cs43_ph_home = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4017"))
 DECLARE mf_cs212_addr_home = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4018"))
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM person_alias pa1,
   person p,
   person_alias pa2
  PLAN (pa1
   WHERE pa1.alias=ms_mrn
    AND pa1.person_alias_type_cd=mf_cs4_mrn
    AND pa1.alias_pool_cd=mf_alias_pool
    AND pa1.active_ind=1
    AND pa1.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=pa1.person_id)
   JOIN (pa2
   WHERE pa2.person_id=pa1.person_id)
  HEAD REPORT
   pl_cnt = 0
  HEAD p.person_id
   mf_person_id = pa1.person_alias_id, m_rec->pat.person_id = trim(cnvtstring(p.person_id),3), m_rec
   ->pat.pat_name = trim(p.name_full_formatted,3),
   m_rec->pat.dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),3), m_rec->pat.sex = trim(
    uar_get_code_display(p.sex_cd),3), m_rec->pat.race = trim(uar_get_code_display(p.race_cd),3)
  HEAD pa2.person_alias_id
   pl_cnt += 1,
   CALL alterlist(m_rec->pat.alias,pl_cnt), m_rec->pat.alias[pl_cnt].alias = trim(pa2.alias,3),
   m_rec->pat.alias[pl_cnt].alias_type = trim(uar_get_code_display(pa2.person_alias_type_cd),3),
   m_rec->pat.alias[pl_cnt].active = trim(cnvtstring(pa2.active_ind),3), m_rec->pat.alias[pl_cnt].
   end_effective_dt_tm = trim(format(pa2.end_effective_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),
   m_rec->pat.alias[pl_cnt].pool = trim(uar_get_code_display(pa2.alias_pool_cd),3), m_rec->pat.alias[
   pl_cnt].contributor_sys = trim(uar_get_code_display(pa2.contributor_system_cd),3), m_rec->pat.
   alias[pl_cnt].last_updt_dt_tm = trim(format(pa2.updt_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM address a
  WHERE a.parent_entity_id=mf_person_id
   AND a.parent_entity_name="PERSON"
   AND a.active_ind=1
   AND a.address_type_cd=mf_cs212_addr_home
   AND a.end_effective_dt_tm > sysdate
  ORDER BY a.address_type_seq
  HEAD REPORT
   m_rec->pat.address1 = trim(a.street_addr,3), m_rec->pat.address2 = trim(a.street_addr2,3), m_rec->
   pat.city = trim(a.city,3),
   m_rec->pat.state = trim(a.state,3), m_rec->pat.zip = trim(a.zipcode,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM phone ph
  WHERE ph.parent_entity_id=mf_person_id
   AND ph.parent_entity_name="PERSON"
   AND ph.active_ind=1
   AND ph.end_effective_dt_tm > sysdate
   AND ph.phone_type_cd=mf_cs43_ph_home
  ORDER BY ph.phone_type_seq
  HEAD REPORT
   m_rec->pat.phone = trim(cnvtphone(ph.phone_num_key,ph.phone_format_cd),3)
  WITH nocounter
 ;end select
#exit_script
 SET _memory_reply_string = cnvtrectojson(m_rec)
 CALL echo(_memory_reply_string)
END GO

CREATE PROGRAM bhs_dup_mrn_cleanup:dba
 FREE RECORD p_alias
 RECORD p_alias(
   1 qual[*]
     2 person_id = f8
     2 cmrn_cnt = i4
     2 cmrn_list[*]
       3 cmrn = vc
     2 fmc_mrn = vc
     2 mlh_mrn = vc
     2 bmc_mrn = vc
     2 bwh_mrn = vc
     2 visit_seq_nbr = i4
     2 person_alias_id = f8
     2 pm_hist_tracking_id = f8
     2 beg_effective_dt_tm = f8
     2 end_effective_dt_tm = f8
     2 health_card_issue_dt_tm = f8
     2 health_card_expiry_dt_tm = f8
     2 health_card_province = c3
     2 health_card_type = vc
     2 health_card_ver_code = c3
     2 person_alias_status_cd = f8
     2 person_alias_type_cd = f8
     2 person_alias_sub_type_cd = f8
     2 alias = vc
     2 alias_pool_cd = f8
     2 active_ind = i2
     2 active_ind_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = f8
     2 active_status_prsnl_id = f8
     2 assign_authority_sys_cd = f8
     2 check_digit = i4
     2 check_digit_method_cd = f8
     2 contributor_system_cd = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = f8
     2 data_status_prsnl_id = f8
 ) WITH protect
 FREE RECORD request
 RECORD request(
   1 person_alias_qual = i4
   1 person_alias[*]
     2 person_id = f8
     2 visit_seq_nbr = i4
     2 person_alias_id = f8
     2 pm_hist_tracking_id = f8
     2 beg_effective_dt_tm = f8
     2 end_effective_dt_tm = f8
     2 health_card_issue_dt_tm = f8
     2 health_card_expiry_dt_tm = f8
     2 health_card_province = c3
     2 health_card_type = vc
     2 health_card_ver_code = c3
     2 person_alias_status_cd = f8
     2 person_alias_type_cd = f8
     2 person_alias_sub_type_cd = f8
     2 alias = vc
     2 alias_pool_cd = f8
     2 active_ind = i2
     2 active_ind_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = f8
     2 active_status_prsnl_id = f8
     2 assign_authority_sys_cd = f8
     2 check_digit = i4
     2 check_digit_method_cd = f8
     2 contributor_system_cd = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = f8
     2 data_status_prsnl_id = f8
     2 transaction_dt_tm = f8
 )
 FREE RECORD person
 RECORD person(
   1 cnt = i4
   1 qual[*]
     2 person_id = f8
     2 merge_ind = i2
 ) WITH protect
 DECLARE l_loop = i4 WITH protect, noconstant(0)
 DECLARE l_cmrn_loop = i4 WITH protect, noconstant(0)
 DECLARE l_mrn_cnt = i4 WITH protect, noconstant(0)
 DECLARE l_ndx = i4 WITH protect, noconstant(0)
 DECLARE l_ndx2 = i4 WITH protect, noconstant(0)
 DECLARE l_ndx3 = i4 WITH protect, noconstant(0)
 DECLARE l_ndx4 = i4 WITH protect, noconstant(0)
 DECLARE l_pos = i4 WITH protect, noconstant(0)
 DECLARE l_pos2 = i4 WITH protect, noconstant(0)
 DECLARE l_mrn_pos = i4 WITH protect, noconstant(0)
 DECLARE l_bmc_cnt = i4 WITH protect, noconstant(0)
 DECLARE l_fmc_cnt = i4 WITH protect, noconstant(0)
 DECLARE l_bmlh_cnt = i4 WITH protect, noconstant(0)
 DECLARE l_bwh_cnt = i4 WITH protect, noconstant(0)
 DECLARE l_updated_cnt = i4 WITH protect, noconstant(0)
 DECLARE l_bmc_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE l_fmc_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE l_bmlh_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE l_bwh_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE l_updated_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE l_bmc_cnt3 = i4 WITH protect, noconstant(0)
 DECLARE l_fmc_cnt3 = i4 WITH protect, noconstant(0)
 DECLARE l_bmlh_cnt3 = i4 WITH protect, noconstant(0)
 DECLARE l_bwh_cnt3 = i4 WITH protect, noconstant(0)
 DECLARE l_updated_cnt3 = i4 WITH protect, noconstant(0)
 DECLARE l_missing_cnt = i4 WITH protect, noconstant(0)
 DECLARE l_pool_cnt = i4 WITH protect, noconstant(0)
 DECLARE l_processed_ind = i2 WITH protect, noconstant(0)
 DECLARE l_processed_ind = i2 WITH protect, noconstant(0)
 DECLARE l_max_qual = i4 WITH protect, constant( $1)
 DECLARE l_facility = vc WITH protect, constant( $2)
 DECLARE l_file_date = vc WITH protect, constant( $3)
 DECLARE f_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE f_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE f_bmc_mrn_pool = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BMCMRN"))
 DECLARE f_fmc_mrn_pool = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"FMCMRN"))
 DECLARE f_mlh_mrn_pool = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"MLHMRN"))
 DECLARE f_bwh_mrn_pool = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BWHMRN"))
 IF ( NOT (l_facility IN ("BMC", "FMC", "MLH", "BWH")))
  CALL echo("*************************************")
  CALL echo(" Invalid facility entered ")
  CALL echo("  must be 'BMC','FMC','MLH' or 'BWH' ")
  CALL echo("*************************************")
  GO TO exit_program
 ENDIF
 CASE (l_facility)
  OF "BMC":
   SELECT DISTINCT INTO "nl:"
    p.person_id
    FROM person_alias pa1,
     person_alias pa2,
     person p
    PLAN (pa1
     WHERE pa1.active_ind=1
      AND pa1.end_effective_dt_tm > sysdate
      AND pa1.person_alias_type_cd=f_mrn_cd
      AND pa1.alias_pool_cd=f_bmc_mrn_pool)
     JOIN (pa2
     WHERE pa2.person_id=pa1.person_id
      AND pa2.active_ind=1
      AND pa2.end_effective_dt_tm > sysdate
      AND pa2.person_alias_type_cd=pa1.person_alias_type_cd
      AND pa2.alias_pool_cd=pa1.alias_pool_cd
      AND pa2.person_alias_id != pa1.person_alias_id)
     JOIN (p
     WHERE p.person_id=pa1.person_id)
    HEAD REPORT
     person->cnt = 0
    DETAIL
     person->cnt = (person->cnt+ 1), stat = alterlist(person->qual,person->cnt), person->qual[person
     ->cnt].person_id = p.person_id,
     l_bmc_cnt3 = (l_bmc_cnt3+ 1)
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    p.person_id
    FROM person_alias pa1,
     person_alias pa2,
     person p
    PLAN (pa1
     WHERE pa1.active_ind=1
      AND pa1.end_effective_dt_tm > sysdate
      AND pa1.person_alias_type_cd=f_mrn_cd
      AND pa1.alias_pool_cd=f_bmc_mrn_pool)
     JOIN (pa2
     WHERE pa2.person_id != pa1.person_id
      AND pa2.active_ind=1
      AND pa2.end_effective_dt_tm > sysdate
      AND pa2.person_alias_type_cd=pa1.person_alias_type_cd
      AND pa2.alias_pool_cd=pa1.alias_pool_cd
      AND pa2.person_alias_id != pa1.person_alias_id
      AND pa2.alias=pa1.alias)
     JOIN (p
     WHERE p.person_id=pa1.person_id)
    DETAIL
     l_pos = locateval(l_ndx,1,person->cnt,p.person_id,person->qual[l_ndx].person_id)
     IF (l_pos=0)
      person->cnt = (person->cnt+ 1), stat = alterlist(person->qual,person->cnt), person->qual[person
      ->cnt].person_id = p.person_id,
      l_bmc_cnt3 = (l_bmc_cnt3+ 1)
     ENDIF
    WITH nocounter
   ;end select
   SET ms_alias_pool_cd = build(" pa.alias_pool_cd = ",f_bmc_mrn_pool)
  OF "FMC":
   SELECT DISTINCT INTO "nl:"
    p.person_id
    FROM person_alias pa1,
     person_alias pa2,
     person p
    PLAN (pa1
     WHERE pa1.active_ind=1
      AND pa1.end_effective_dt_tm > sysdate
      AND pa1.person_alias_type_cd=f_mrn_cd
      AND pa1.alias_pool_cd=f_fmc_mrn_pool)
     JOIN (pa2
     WHERE pa2.person_id=pa1.person_id
      AND pa2.active_ind=1
      AND pa2.end_effective_dt_tm > sysdate
      AND pa2.person_alias_type_cd=pa1.person_alias_type_cd
      AND pa2.alias_pool_cd=pa1.alias_pool_cd
      AND pa2.person_alias_id != pa1.person_alias_id)
     JOIN (p
     WHERE p.person_id=pa1.person_id)
    HEAD REPORT
     person->cnt = 0
    DETAIL
     person->cnt = (person->cnt+ 1), stat = alterlist(person->qual,person->cnt), person->qual[person
     ->cnt].person_id = p.person_id,
     l_bmc_cnt3 = (l_bmc_cnt3+ 1)
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    p.person_id
    FROM person_alias pa1,
     person_alias pa2,
     person p
    PLAN (pa1
     WHERE pa1.active_ind=1
      AND pa1.end_effective_dt_tm > sysdate
      AND pa1.person_alias_type_cd=f_mrn_cd
      AND pa1.alias_pool_cd=f_fmc_mrn_pool)
     JOIN (pa2
     WHERE pa2.person_id != pa1.person_id
      AND pa2.active_ind=1
      AND pa2.end_effective_dt_tm > sysdate
      AND pa2.person_alias_type_cd=pa1.person_alias_type_cd
      AND pa2.alias_pool_cd=pa1.alias_pool_cd
      AND pa2.person_alias_id != pa1.person_alias_id
      AND pa2.alias=pa1.alias)
     JOIN (p
     WHERE p.person_id=pa1.person_id)
    DETAIL
     l_pos = locateval(l_ndx,1,person->cnt,p.person_id,person->qual[l_ndx].person_id)
     IF (l_pos=0)
      person->cnt = (person->cnt+ 1), stat = alterlist(person->qual,person->cnt), person->qual[person
      ->cnt].person_id = p.person_id,
      l_bmc_cnt3 = (l_bmc_cnt3+ 1)
     ENDIF
    WITH nocounter
   ;end select
   SET ms_alias_pool_cd = build(" pa.alias_pool_cd = ",f_fmc_mrn_pool)
  OF "MLH":
   SELECT DISTINCT INTO "nl:"
    p.person_id
    FROM person_alias pa1,
     person_alias pa2,
     person p
    PLAN (pa1
     WHERE pa1.active_ind=1
      AND pa1.end_effective_dt_tm > sysdate
      AND pa1.person_alias_type_cd=f_mrn_cd
      AND pa1.alias_pool_cd=f_mlh_mrn_pool)
     JOIN (pa2
     WHERE pa2.person_id=pa1.person_id
      AND pa2.active_ind=1
      AND pa2.end_effective_dt_tm > sysdate
      AND pa2.person_alias_type_cd=pa1.person_alias_type_cd
      AND pa2.alias_pool_cd=pa1.alias_pool_cd
      AND pa2.person_alias_id != pa1.person_alias_id)
     JOIN (p
     WHERE p.person_id=pa1.person_id)
    HEAD REPORT
     person->cnt = 0
    DETAIL
     person->cnt = (person->cnt+ 1), stat = alterlist(person->qual,person->cnt), person->qual[person
     ->cnt].person_id = p.person_id,
     l_bmc_cnt3 = (l_bmc_cnt3+ 1)
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    p.person_id
    FROM person_alias pa1,
     person_alias pa2,
     person p
    PLAN (pa1
     WHERE pa1.active_ind=1
      AND pa1.end_effective_dt_tm > sysdate
      AND pa1.person_alias_type_cd=f_mrn_cd
      AND pa1.alias_pool_cd=f_mlh_mrn_pool)
     JOIN (pa2
     WHERE pa2.person_id != pa1.person_id
      AND pa2.active_ind=1
      AND pa2.end_effective_dt_tm > sysdate
      AND pa2.person_alias_type_cd=pa1.person_alias_type_cd
      AND pa2.alias_pool_cd=pa1.alias_pool_cd
      AND pa2.person_alias_id != pa1.person_alias_id
      AND pa2.alias=pa1.alias)
     JOIN (p
     WHERE p.person_id=pa1.person_id)
    DETAIL
     l_pos = locateval(l_ndx,1,person->cnt,p.person_id,person->qual[l_ndx].person_id)
     IF (l_pos=0)
      person->cnt = (person->cnt+ 1), stat = alterlist(person->qual,person->cnt), person->qual[person
      ->cnt].person_id = p.person_id,
      l_bmc_cnt3 = (l_bmc_cnt3+ 1)
     ENDIF
    WITH nocounter
   ;end select
   SET ms_alias_pool_cd = build(" pa.alias_pool_cd = ",f_mlh_mrn_pool)
  OF "BWH":
   SELECT DISTINCT INTO "nl:"
    p.person_id
    FROM person_alias pa1,
     person_alias pa2,
     person p
    PLAN (pa1
     WHERE pa1.active_ind=1
      AND pa1.end_effective_dt_tm > sysdate
      AND pa1.person_alias_type_cd=f_mrn_cd
      AND pa1.alias_pool_cd=f_bwh_mrn_pool)
     JOIN (pa2
     WHERE pa2.person_id=pa1.person_id
      AND pa2.active_ind=1
      AND pa2.end_effective_dt_tm > sysdate
      AND pa2.person_alias_type_cd=pa1.person_alias_type_cd
      AND pa2.alias_pool_cd=pa1.alias_pool_cd
      AND pa2.person_alias_id != pa1.person_alias_id)
     JOIN (p
     WHERE p.person_id=pa1.person_id)
    HEAD REPORT
     person->cnt = 0
    DETAIL
     person->cnt = (person->cnt+ 1), stat = alterlist(person->qual,person->cnt), person->qual[person
     ->cnt].person_id = p.person_id,
     l_bmc_cnt3 = (l_bmc_cnt3+ 1)
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    p.person_id
    FROM person_alias pa1,
     person_alias pa2,
     person p
    PLAN (pa1
     WHERE pa1.active_ind=1
      AND pa1.end_effective_dt_tm > sysdate
      AND pa1.person_alias_type_cd=f_mrn_cd
      AND pa1.alias_pool_cd=f_bwh_mrn_pool)
     JOIN (pa2
     WHERE pa2.person_id != pa1.person_id
      AND pa2.active_ind=1
      AND pa2.end_effective_dt_tm > sysdate
      AND pa2.person_alias_type_cd=pa1.person_alias_type_cd
      AND pa2.alias_pool_cd=pa1.alias_pool_cd
      AND pa2.person_alias_id != pa1.person_alias_id
      AND pa2.alias=pa1.alias)
     JOIN (p
     WHERE p.person_id=pa1.person_id)
    DETAIL
     l_pos = locateval(l_ndx,1,person->cnt,p.person_id,person->qual[l_ndx].person_id)
     IF (l_pos=0)
      person->cnt = (person->cnt+ 1), stat = alterlist(person->qual,person->cnt), person->qual[person
      ->cnt].person_id = p.person_id,
      l_bmc_cnt3 = (l_bmc_cnt3+ 1)
     ENDIF
    WITH nocounter
   ;end select
   SET ms_alias_pool_cd = build(" pa.alias_pool_cd = ",f_bwh_mrn_pool)
 ENDCASE
 SELECT INTO "nl:"
  FROM person_combine pc
  WHERE pc.active_ind=1
   AND ((expand(l_ndx,1,person->cnt,pc.to_person_id,person->qual[l_ndx].person_id)) OR (expand(l_ndx2,
   1,person->cnt,pc.from_person_id,person->qual[l_ndx2].person_id)))
   AND pc.updt_dt_tm > cnvtdatetime(l_file_date)
  DETAIL
   l_pos = locateval(l_ndx3,1,person->cnt,pc.to_person_id,person->qual[l_ndx3].person_id), l_pos2 =
   locateval(l_ndx4,1,person->cnt,pc.from_person_id,person->qual[l_ndx4].person_id)
   IF (l_pos > 0)
    person->qual[l_pos].merge_ind = 1
   ELSEIF (l_pos2 > 0)
    person->qual[l_pos2].merge_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "bhs_dup_mrn_merge_list.dat"
  FROM (dummyt d  WITH seq = value(person->cnt))
  PLAN (d
   WHERE (person->qual[d.seq].merge_ind=1))
  HEAD REPORT
   col 0, "PERSON_ID", row + 1
  DETAIL
   col 0, person->qual[d.seq].person_id, row + 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE pa.person_alias_type_cd=f_mrn_cd
   AND expand(l_ndx,1,person->cnt,pa.person_id,person->qual[l_ndx].person_id,
   0,person->qual[l_ndx].merge_ind)
   AND parser(ms_alias_pool_cd)
  DETAIL
   l_mrn_cnt = (l_mrn_cnt+ 1), stat = alterlist(p_alias->qual,l_mrn_cnt), p_alias->qual[l_mrn_cnt].
   person_id = pa.person_id
   CASE (pa.alias_pool_cd)
    OF f_bmc_mrn_pool:
     p_alias->qual[l_mrn_cnt].bmc_mrn = pa.alias
    OF f_fmc_mrn_pool:
     p_alias->qual[l_mrn_cnt].fmc_mrn = pa.alias
    OF f_mlh_mrn_pool:
     p_alias->qual[l_mrn_cnt].mlh_mrn = pa.alias
    OF f_bwh_mrn_pool:
     p_alias->qual[l_mrn_cnt].bwh_mrn = pa.alias
   ENDCASE
   p_alias->qual[l_mrn_cnt].alias = pa.alias, p_alias->qual[l_mrn_cnt].visit_seq_nbr = pa
   .visit_seq_nbr, p_alias->qual[l_mrn_cnt].person_alias_id = pa.person_alias_id,
   p_alias->qual[l_mrn_cnt].health_card_issue_dt_tm = pa.health_card_issue_dt_tm, p_alias->qual[
   l_mrn_cnt].health_card_expiry_dt_tm = pa.health_card_expiry_dt_tm, p_alias->qual[l_mrn_cnt].
   health_card_province = pa.health_card_province,
   p_alias->qual[l_mrn_cnt].health_card_type = pa.health_card_type, p_alias->qual[l_mrn_cnt].
   health_card_ver_code = pa.health_card_ver_code, p_alias->qual[l_mrn_cnt].person_alias_status_cd =
   pa.person_alias_status_cd,
   p_alias->qual[l_mrn_cnt].person_alias_type_cd = pa.person_alias_type_cd, p_alias->qual[l_mrn_cnt].
   person_alias_sub_type_cd = pa.person_alias_sub_type_cd, p_alias->qual[l_mrn_cnt].alias_pool_cd =
   pa.alias_pool_cd,
   p_alias->qual[l_mrn_cnt].beg_effective_dt_tm = pa.beg_effective_dt_tm, p_alias->qual[l_mrn_cnt].
   active_status_cd = pa.active_status_cd, p_alias->qual[l_mrn_cnt].active_status_dt_tm = pa
   .active_status_dt_tm,
   p_alias->qual[l_mrn_cnt].active_status_prsnl_id = pa.active_status_prsnl_id, p_alias->qual[
   l_mrn_cnt].assign_authority_sys_cd = pa.assign_authority_sys_cd, p_alias->qual[l_mrn_cnt].
   check_digit = pa.check_digit,
   p_alias->qual[l_mrn_cnt].check_digit_method_cd = pa.check_digit_method_cd, p_alias->qual[l_mrn_cnt
   ].contributor_system_cd = pa.contributor_system_cd, p_alias->qual[l_mrn_cnt].data_status_cd = pa
   .data_status_cd,
   p_alias->qual[l_mrn_cnt].data_status_dt_tm = pa.data_status_dt_tm, p_alias->qual[l_mrn_cnt].
   data_status_prsnl_id = pa.data_status_prsnl_id, p_alias->qual[l_mrn_cnt].active_ind = pa
   .active_ind,
   p_alias->qual[l_mrn_cnt].end_effective_dt_tm = pa.end_effective_dt_tm
  WITH nocounter, expand = 1, maxqual(pa,value(l_max_qual))
 ;end select
 FOR (l_loop = 1 TO l_mrn_cnt)
   SET request->person_alias_qual = 1
   SET stat = alterlist(request->person_alias,request->person_alias_qual)
   SET request->person_alias[request->person_alias_qual].alias = p_alias->qual[l_loop].alias
   SET request->person_alias[request->person_alias_qual].person_id = p_alias->qual[l_loop].person_id
   SET request->person_alias[request->person_alias_qual].visit_seq_nbr = p_alias->qual[l_loop].
   visit_seq_nbr
   SET request->person_alias[request->person_alias_qual].person_alias_id = p_alias->qual[l_loop].
   person_alias_id
   SET request->person_alias[request->person_alias_qual].health_card_issue_dt_tm = cnvtdatetime(
    p_alias->qual[l_loop].health_card_issue_dt_tm)
   SET request->person_alias[request->person_alias_qual].health_card_expiry_dt_tm = cnvtdatetime(
    p_alias->qual[l_loop].health_card_expiry_dt_tm)
   SET request->person_alias[request->person_alias_qual].health_card_province = p_alias->qual[l_loop]
   .health_card_province
   SET request->person_alias[request->person_alias_qual].health_card_type = p_alias->qual[l_loop].
   health_card_type
   SET request->person_alias[request->person_alias_qual].health_card_ver_code = p_alias->qual[l_loop]
   .health_card_ver_code
   SET request->person_alias[request->person_alias_qual].person_alias_status_cd = p_alias->qual[
   l_loop].person_alias_status_cd
   SET request->person_alias[request->person_alias_qual].person_alias_type_cd = p_alias->qual[l_loop]
   .person_alias_type_cd
   SET request->person_alias[request->person_alias_qual].person_alias_sub_type_cd = p_alias->qual[
   l_loop].person_alias_sub_type_cd
   SET request->person_alias[request->person_alias_qual].alias_pool_cd = p_alias->qual[l_loop].
   alias_pool_cd
   SET request->person_alias[request->person_alias_qual].beg_effective_dt_tm = cnvtdatetime(p_alias->
    qual[l_loop].beg_effective_dt_tm)
   SET request->person_alias[request->person_alias_qual].active_status_cd = p_alias->qual[l_loop].
   active_status_cd
   SET request->person_alias[request->person_alias_qual].active_status_dt_tm = cnvtdatetime(p_alias->
    qual[l_loop].active_status_dt_tm)
   SET request->person_alias[request->person_alias_qual].active_status_prsnl_id = p_alias->qual[
   l_loop].active_status_prsnl_id
   SET request->person_alias[request->person_alias_qual].assign_authority_sys_cd = p_alias->qual[
   l_loop].assign_authority_sys_cd
   SET request->person_alias[request->person_alias_qual].check_digit = p_alias->qual[l_loop].
   check_digit
   SET request->person_alias[request->person_alias_qual].check_digit_method_cd = p_alias->qual[l_loop
   ].check_digit_method_cd
   SET request->person_alias[request->person_alias_qual].contributor_system_cd = p_alias->qual[l_loop
   ].contributor_system_cd
   SET request->person_alias[request->person_alias_qual].data_status_cd = p_alias->qual[l_loop].
   data_status_cd
   SET request->person_alias[request->person_alias_qual].data_status_dt_tm = cnvtdatetime(p_alias->
    qual[l_loop].data_status_dt_tm)
   SET request->person_alias[request->person_alias_qual].data_status_prsnl_id = p_alias->qual[l_loop]
   .data_status_prsnl_id
   SELECT INTO "nl:"
    FROM person_alias pa
    WHERE pa.person_alias_type_cd=f_cmrn_cd
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > sysdate
     AND (pa.person_id=p_alias->qual[l_loop].person_id)
    HEAD REPORT
     p_alias->qual[l_loop].cmrn_cnt = 0
    DETAIL
     p_alias->qual[l_loop].cmrn_cnt = (p_alias->qual[l_loop].cmrn_cnt+ 1), stat = alterlist(p_alias->
      qual[l_loop].cmrn_list,p_alias->qual[l_loop].cmrn_cnt), p_alias->qual[l_loop].cmrn_list[p_alias
     ->qual[l_loop].cmrn_cnt].cmrn = pa.alias
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "bhs_dup_mrn_no_cmrn.dat"
     FROM dual
     DETAIL
      col 0, p_alias->qual[l_loop].person_id, ",",
      col + 1, p_alias->qual[l_loop].bmc_mrn, ",",
      col + 1, p_alias->qual[l_loop].fmc_mrn, ",",
      col + 1, p_alias->qual[l_loop].mlh_mrn, ",",
      col + 1, p_alias->qual[l_loop].bwh_mrn, row + 1
     WITH nocounter, append
    ;end select
   ELSE
    FOR (l_cmrn_loop = 1 TO p_alias->qual[l_loop].cmrn_cnt)
      SET l_pool_cnt = 0
      SET l_processed_ind = 0
      SET l_not_found_ind = 0
      CASE (l_facility)
       OF "BMC":
        IF (textlen(trim(p_alias->qual[l_loop].bmc_mrn,3)) > 0)
         SELECT INTO "nl:"
          FROM bhs_dup_mrn c
          WHERE c.cn=format(p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn,"#######;rp0")
           AND c.bmc_mrn=format(p_alias->qual[l_loop].bmc_mrn,"#######;rp0")
          DETAIL
           IF (c.bmc_processed_ind=1)
            l_processed_ind = 1
           ENDIF
          WITH nocounter
         ;end select
         IF (curqual=0)
          SET l_not_found_ind = 1
         ENDIF
         SET l_bmc_cnt2 = (l_bmc_cnt2+ 1)
         SET l_updated_cnt2 = (l_updated_cnt2+ 1)
         IF (((l_processed_ind=0) OR (l_not_found_ind=1)) )
          SELECT INTO "nl:"
           FROM person_alias pa
           WHERE pa.person_alias_type_cd=f_mrn_cd
            AND (pa.person_id=p_alias->qual[l_loop].person_id)
            AND pa.alias_pool_cd=f_bmc_mrn_pool
            AND pa.active_ind=1
            AND pa.end_effective_dt_tm > sysdate
           DETAIL
            l_pool_cnt = (l_pool_cnt+ 1)
           WITH nocounter
          ;end select
          IF (l_pool_cnt <= 1
           AND l_processed_ind=1)
           SELECT INTO "bhs_dup_mrn_one_active.dat"
            FROM dual
            DETAIL
             col 0, p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn, ",",
             col + 1, "BMC,", col + 1,
             p_alias->qual[l_loop].bmc_mrn, row + 1
            WITH nocounter, append
           ;end select
          ELSE
           IF (l_not_found_ind=1)
            SET request->person_alias[request->person_alias_qual].active_ind = p_alias->qual[l_loop].
            active_ind
           ELSE
            SET request->person_alias[request->person_alias_qual].active_ind = 0
           ENDIF
           SET request->person_alias[request->person_alias_qual].end_effective_dt_tm = cnvtdatetime(
            curdate,curtime3)
           EXECUTE pm_upt_person_alias
           SET l_bmc_cnt = (l_bmc_cnt+ 1)
           SET l_updated_cnt = (l_updated_cnt+ 1)
           CALL echo("*-----------------*")
           CALL echo(l_loop)
           CALL echo(build("CN: ",p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn))
           CALL echo(build(" BMC_MRN: ",p_alias->qual[l_loop].bmc_mrn))
           CALL echo(build("PERSON_ALIAS_ID: ",p_alias->qual[l_loop].person_alias_id))
           CALL echo(build("person_id: ",p_alias->qual[l_loop].person_id))
           CALL echo("------------------")
           UPDATE  FROM bhs_dup_mrn b
            SET b.bmc_processed_ind = 1, b.bmc_prev_active_ind = p_alias->qual[l_loop].active_ind, b
             .bmc_prev_end_eff_dt_tm = cnvtdatetime(p_alias->qual[l_loop].end_effective_dt_tm),
             b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id
              = reqinfo->updt_id
            WHERE b.cn=format(p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn,"#######;rp0")
             AND b.bmc_mrn=format(p_alias->qual[l_loop].bmc_mrn,"#######;rp0")
            WITH nocounter
           ;end update
          ENDIF
         ENDIF
        ENDIF
       OF "FMC":
        IF (textlen(trim(p_alias->qual[l_loop].fmc_mrn,3)) > 0)
         SELECT INTO "nl:"
          FROM bhs_dup_mrn c
          WHERE c.cn=format(p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn,"#######;rp0")
           AND c.bfmc_mrn=format(p_alias->qual[l_loop].fmc_mrn,"#######;rp0")
          DETAIL
           IF (c.fmc_processed_ind=1)
            l_processed_ind = 1
           ENDIF
          WITH nocounter
         ;end select
         IF (curqual=0)
          SET l_not_found_ind = 1
         ENDIF
         SET l_fmc_cnt2 = (l_fmc_cnt2+ 1)
         SET l_updated_cnt2 = (l_updated_cnt2+ 1)
         IF (((l_processed_ind=0) OR (l_not_found_ind=1)) )
          SELECT INTO "nl:"
           FROM person_alias pa
           WHERE pa.person_alias_type_cd=f_mrn_cd
            AND (pa.person_id=p_alias->qual[l_loop].person_id)
            AND pa.alias_pool_cd=f_fmc_mrn_pool
            AND pa.active_ind=1
            AND pa.end_effective_dt_tm > sysdate
           DETAIL
            l_pool_cnt = (l_pool_cnt+ 1)
           WITH nocounter
          ;end select
          IF (l_pool_cnt <= 1
           AND l_processed_ind=1)
           SELECT INTO "bhs_dup_mrn_one_active.dat"
            FROM dual
            DETAIL
             col 0, p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn, ",",
             col + 1, "FMC,", col + 1,
             p_alias->qual[l_loop].fmc_mrn, row + 1
            WITH nocounter, append
           ;end select
          ELSE
           IF (l_not_found_ind=1)
            SET request->person_alias[request->person_alias_qual].active_ind = p_alias->qual[l_loop].
            active_ind
           ELSE
            SET request->person_alias[request->person_alias_qual].active_ind = 0
           ENDIF
           SET request->person_alias[request->person_alias_qual].end_effective_dt_tm = cnvtdatetime(
            curdate,curtime3)
           EXECUTE pm_upt_person_alias
           SET l_fmc_cnt = (l_fmc_cnt+ 1)
           SET l_updated_cnt = (l_updated_cnt+ 1)
           CALL echo("*-----------------*")
           CALL echo(l_loop)
           CALL echo(build("CN: ",p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn))
           CALL echo(build(" FMC_MRN: ",p_alias->qual[l_loop].fmc_mrn))
           CALL echo(build("PERSON_ALIAS_ID: ",p_alias->qual[l_loop].person_alias_id))
           CALL echo(build("person_id: ",p_alias->qual[l_loop].person_id))
           CALL echo("------------------")
           UPDATE  FROM bhs_dup_mrn b
            SET b.fmc_processed_ind = 1, b.fmc_prev_active_ind = p_alias->qual[l_loop].active_ind, b
             .fmc_prev_end_eff_dt_tm = cnvtdatetime(p_alias->qual[l_loop].end_effective_dt_tm),
             b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id
              = reqinfo->updt_id
            WHERE b.cn=format(p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn,"#######;rp0")
             AND b.fmc_mrn=format(p_alias->qual[l_loop].fmc_mrn,"#######;rp0")
            WITH nocounter
           ;end update
          ENDIF
         ENDIF
        ENDIF
       OF "MLH":
        IF (textlen(trim(p_alias->qual[l_loop].mlh_mrn,3)) > 0)
         SELECT INTO "nl:"
          FROM bhs_dup_mrn c
          WHERE c.cn=format(p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn,"#######;rp0")
           AND c.bmlh_mrn=format(p_alias->qual[l_loop].mlh_mrn,"#######;rp0")
          DETAIL
           IF (c.mlh_processed_ind=1)
            l_processed_ind = 1
           ENDIF
          WITH nocounter
         ;end select
         IF (curqual=0)
          SET l_not_found_ind = 1
         ENDIF
         SET l_bmlh_cnt2 = (l_bmlh_cnt2+ 1)
         SET l_updated_cn2t = (l_updated_cnt2+ 1)
         IF (((l_processed_ind=0) OR (l_not_found_ind=1)) )
          SELECT INTO "nl:"
           FROM person_alias pa
           WHERE pa.person_alias_type_cd=f_mrn_cd
            AND (pa.person_id=p_alias->qual[l_loop].person_id)
            AND pa.alias_pool_cd=f_mlh_mrn_pool
            AND pa.active_ind=1
            AND pa.end_effective_dt_tm > sysdate
           DETAIL
            l_pool_cnt = (l_pool_cnt+ 1)
           WITH nocounter
          ;end select
          IF (l_pool_cnt <= 1
           AND l_processed_ind=1)
           SELECT INTO "bhs_dup_mrn_one_active.dat"
            FROM dual
            DETAIL
             col 0, p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn, ",",
             col + 1, "MLH,", col + 1,
             p_alias->qual[l_loop].mlh_mrn, row + 1
            WITH nocounter, append
           ;end select
          ELSE
           IF (l_not_found_ind=1)
            SET request->person_alias[request->person_alias_qual].active_ind = p_alias->qual[l_loop].
            active_ind
           ELSE
            SET request->person_alias[request->person_alias_qual].active_ind = 0
           ENDIF
           SET request->person_alias[request->person_alias_qual].end_effective_dt_tm = cnvtdatetime(
            curdate,curtime3)
           EXECUTE pm_upt_person_alias
           SET l_bmlh_cnt = (l_bmlh_cnt+ 1)
           SET l_updated_cnt = (l_updated_cnt+ 1)
           CALL echo("*-----------------*")
           CALL echo(l_loop)
           CALL echo(build("CN: ",p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn))
           CALL echo(build("BMLH_MRN: ",p_alias->qual[l_loop].mlh_mrn))
           CALL echo(build("PERSON_ALIAS_ID: ",p_alias->qual[l_loop].person_alias_id))
           CALL echo(build("person_id: ",p_alias->qual[l_loop].person_id))
           CALL echo("------------------")
           UPDATE  FROM bhs_dup_mrn b
            SET b.mlh_processed_ind = 1, b.mlh_prev_active_ind = p_alias->qual[l_loop].active_ind, b
             .mlh_prev_end_eff_dt_tm = cnvtdatetime(p_alias->qual[l_loop].end_effective_dt_tm),
             b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id
              = reqinfo->updt_id
            WHERE b.cn=format(p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn,"#######;rp0")
             AND b.mlh_mrn=format(p_alias->qual[l_loop].mlh_mrn,"#######;rp0")
            WITH nocounter
           ;end update
          ENDIF
         ENDIF
        ENDIF
       OF "BWH":
        IF (textlen(trim(p_alias->qual[l_loop].bwh_mrn,3)) > 0)
         SELECT INTO "nl:"
          FROM bhs_dup_mrn c
          WHERE c.cn=format(p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn,"#######;rp0")
           AND (c.bwh_mrn=p_alias->qual[l_loop].bwh_mrn)
          DETAIL
           IF (c.bwh_processed_ind=1)
            l_processed_ind = 1
           ENDIF
          WITH nocounter
         ;end select
         IF (curqual=0)
          SET l_not_found_ind = 1
         ENDIF
         SET l_bwh_cnt2 = (l_bwh_cnt2+ 1)
         SET l_updated_cnt2 = (l_updated_cnt2+ 1)
         CALL echo("---")
         CALL echo(build("Processed_ind: ",l_processed_ind))
         CALL echo(build("Not_found_ind: ",l_not_found_ind))
         IF (((l_processed_ind=0) OR (l_not_found_ind=1)) )
          SELECT INTO "nl:"
           FROM person_alias pa
           WHERE pa.person_alias_type_cd=f_mrn_cd
            AND (pa.person_id=p_alias->qual[l_loop].person_id)
            AND pa.alias_pool_cd=f_bwh_mrn_pool
            AND pa.active_ind=1
            AND pa.end_effective_dt_tm > sysdate
           DETAIL
            l_pool_cnt = (l_pool_cnt+ 1)
           WITH nocounter
          ;end select
          IF (l_pool_cnt <= 1
           AND l_processed_ind=1)
           SELECT INTO "bhs_dup_mrn_one_active.dat"
            FROM dual
            DETAIL
             col 0, p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn, ",",
             col + 1, "BWH,", col + 1,
             p_alias->qual[l_loop].bwh_mrn, row + 1
            WITH nocounter, append
           ;end select
          ELSE
           IF (l_not_found_ind=1)
            SET request->person_alias[request->person_alias_qual].active_ind = p_alias->qual[l_loop].
            active_ind
           ELSE
            SET request->person_alias[request->person_alias_qual].active_ind = 0
           ENDIF
           SET request->person_alias[request->person_alias_qual].end_effective_dt_tm = cnvtdatetime(
            curdate,curtime3)
           EXECUTE pm_upt_person_alias
           SET l_bwh_cnt = (l_bwh_cnt+ 1)
           SET l_updated_cnt = (l_updated_cnt+ 1)
           CALL echo("*-----------------*")
           CALL echo(l_loop)
           CALL echo(build("CN: ",p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn))
           CALL echo(build(" BWH_MRN: ",p_alias->qual[l_loop].bwh_mrn))
           CALL echo(build("PERSON_ALIAS_ID: ",p_alias->qual[l_loop].person_alias_id))
           CALL echo(build("person_id: ",p_alias->qual[l_loop].person_id))
           CALL echo("------------------")
           UPDATE  FROM bhs_dup_mrn b
            SET b.bwh_processed_ind = 1, b.bwh_prev_active_ind = p_alias->qual[l_loop].active_ind, b
             .bwh_prev_end_eff_dt_tm = cnvtdatetime(p_alias->qual[l_loop].end_effective_dt_tm),
             b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id
              = reqinfo->updt_id
            WHERE b.cn=format(p_alias->qual[l_loop].cmrn_list[l_cmrn_loop].cmrn,"#######;rp0")
             AND b.bwh_mrn=format(p_alias->qual[l_loop].bwh_mrn,"#######;rp0")
            WITH nocounter
           ;end update
          ENDIF
         ENDIF
        ENDIF
      ENDCASE
    ENDFOR
   ENDIF
 ENDFOR
 CALL echo("*--Updated---------------*")
 CALL echo(build(" BMC_MRN: ",l_bmc_cnt))
 CALL echo(build(" FMC_MRN: ",l_fmc_cnt))
 CALL echo(build("BMLH_MRN: ",l_bmlh_cnt))
 CALL echo(build(" BWH_MRN: ",l_bwh_cnt))
 CALL echo(build("   TOTAL: ",l_updated_cnt))
 CALL echo("------------------")
 CALL echo("*--Incorrect MRNs---------------*")
 CALL echo(build(" BMC_MRN2: ",l_bmc_cnt2))
 CALL echo(build(" FMC_MRN2: ",l_fmc_cnt2))
 CALL echo(build("BMLH_MRN2: ",l_bmlh_cnt2))
 CALL echo(build(" BWH_MRN2: ",l_bwh_cnt2))
 CALL echo(build("   TOTAL2: ",l_updated_cnt2))
 CALL echo("------------------")
 SET l_updated_cnt3 = (((l_bmc_cnt3+ l_fmc_cnt3)+ l_bmlh_cnt3)+ l_bwh_cnt3)
 CALL echo("*--Should have been updated---------------*")
 CALL echo(build(" BMC_MRN3: ",l_bmc_cnt3))
 CALL echo(build(" FMC_MRN3: ",l_fmc_cnt3))
 CALL echo(build("BMLH_MRN3: ",l_bmlh_cnt3))
 CALL echo(build(" BWH_MRN3: ",l_bwh_cnt3))
 CALL echo(build("   TOTAL3: ",l_updated_cnt3))
 CALL echo("------------------")
#exit_program
 FREE RECORD cn
 FREE RECORD request
 FREE RECORD missing
 FREE RECORD m_per
END GO

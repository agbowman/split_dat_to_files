CREATE PROGRAM bhs_dup_mrn_cleanup3:dba
 FREE RECORD cn
 RECORD cn(
   1 person_alias[*]
     2 person_id = f8
     2 cn = vc
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
 )
 FREE RECORD missing
 RECORD missing(
   1 missing_cnt = i4
   1 list[*]
     2 person_id = f8
     2 person_alias_id = f8
     2 person_alias_type_cd = f8
     2 alias = vc
     2 alias_pool_cd = f8
 ) WITH protect
 FREE RECORD m_per
 RECORD m_per(
   1 cnt = i4
   1 qual[*]
     2 f_e_person_id = f8
 ) WITH protect
 DECLARE l_max_qual = i4 WITH protect, noconstant( $1)
 DECLARE l_loop = i4 WITH protect, noconstant(0)
 DECLARE l_mrn_cnt = i4 WITH protect, noconstant(0)
 DECLARE l_ndx = i4 WITH protect, noconstant(0)
 DECLARE l_ndx2 = i4 WITH protect, noconstant(0)
 DECLARE l_pos = i4 WITH protect, noconstant(0)
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
 DECLARE cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE f_bmc_mrn_pool = f8 WITH protect, constant(674540.00)
 DECLARE f_fmc_mrn_pool = f8 WITH protect, constant(674559.00)
 DECLARE f_mlh_mrn_pool = f8 WITH protect, constant(674614.00)
 DECLARE f_bwh_mrn_pool = f8 WITH protect, constant(580060529.00)
 DECLARE test_jason = i4 WITH protect
 SELECT DISTINCT INTO "nl:"
  e.person_id, ea.alias, pa.person_id
  FROM encounter e,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE e.encntr_id != 0)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1079.0
    AND ea.alias_pool_cd=f_bwh_mrn_pool
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pa
   WHERE pa.person_id=outerjoin(e.person_id)
    AND pa.person_alias_type_cd=outerjoin(10)
    AND pa.alias_pool_cd=outerjoin(f_bwh_mrn_pool)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  DETAIL
   IF (pa.person_id > 0.0)
    test_jason = 0
   ELSE
    m_per->cnt = (m_per->cnt+ 1), stat = alterlist(m_per->qual,m_per->cnt), m_per->qual[m_per->cnt].
    f_e_person_id = e.person_id,
    l_bwh_cnt3 = (l_bwh_cnt3+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE pa.person_alias_type_cd=mrn_cd
   AND expand(l_ndx,1,m_per->cnt,pa.person_id,m_per->qual[l_ndx].f_e_person_id)
   AND pa.updt_id=23045548.00
   AND pa.alias_pool_cd IN (f_bmc_mrn_pool, f_fmc_mrn_pool, f_mlh_mrn_pool, f_bwh_mrn_pool)
  DETAIL
   l_mrn_cnt = (l_mrn_cnt+ 1), stat = alterlist(cn->person_alias,l_mrn_cnt), cn->person_alias[
   l_mrn_cnt].person_id = pa.person_id
   CASE (pa.alias_pool_cd)
    OF 674540.0:
     cn->person_alias[l_mrn_cnt].bmc_mrn = pa.alias
    OF 674559.0:
     cn->person_alias[l_mrn_cnt].fmc_mrn = pa.alias
    OF 674614.0:
     cn->person_alias[l_mrn_cnt].mlh_mrn = pa.alias
    OF 580060529.0:
     cn->person_alias[l_mrn_cnt].bwh_mrn = pa.alias
   ENDCASE
   cn->person_alias[l_mrn_cnt].alias = pa.alias, cn->person_alias[l_mrn_cnt].visit_seq_nbr = pa
   .visit_seq_nbr, cn->person_alias[l_mrn_cnt].person_alias_id = pa.person_alias_id,
   cn->person_alias[l_mrn_cnt].health_card_issue_dt_tm = pa.health_card_issue_dt_tm, cn->
   person_alias[l_mrn_cnt].health_card_expiry_dt_tm = pa.health_card_expiry_dt_tm, cn->person_alias[
   l_mrn_cnt].health_card_province = pa.health_card_province,
   cn->person_alias[l_mrn_cnt].health_card_type = pa.health_card_type, cn->person_alias[l_mrn_cnt].
   health_card_ver_code = pa.health_card_ver_code, cn->person_alias[l_mrn_cnt].person_alias_status_cd
    = pa.person_alias_status_cd,
   cn->person_alias[l_mrn_cnt].person_alias_type_cd = pa.person_alias_type_cd, cn->person_alias[
   l_mrn_cnt].person_alias_sub_type_cd = pa.person_alias_sub_type_cd, cn->person_alias[l_mrn_cnt].
   alias_pool_cd = pa.alias_pool_cd,
   cn->person_alias[l_mrn_cnt].beg_effective_dt_tm = pa.beg_effective_dt_tm, cn->person_alias[
   l_mrn_cnt].active_status_cd = pa.active_status_cd, cn->person_alias[l_mrn_cnt].active_status_dt_tm
    = pa.active_status_dt_tm,
   cn->person_alias[l_mrn_cnt].active_status_prsnl_id = pa.active_status_prsnl_id, cn->person_alias[
   l_mrn_cnt].assign_authority_sys_cd = pa.assign_authority_sys_cd, cn->person_alias[l_mrn_cnt].
   check_digit = pa.check_digit,
   cn->person_alias[l_mrn_cnt].check_digit_method_cd = pa.check_digit_method_cd, cn->person_alias[
   l_mrn_cnt].contributor_system_cd = pa.contributor_system_cd, cn->person_alias[l_mrn_cnt].
   data_status_cd = pa.data_status_cd,
   cn->person_alias[l_mrn_cnt].data_status_dt_tm = pa.data_status_dt_tm, cn->person_alias[l_mrn_cnt].
   data_status_prsnl_id = pa.data_status_prsnl_id
  WITH nocounter, expand = 1
 ;end select
 FOR (l_loop = 1 TO l_mrn_cnt)
   SET request->person_alias_qual = 1
   SET stat = alterlist(request->person_alias,request->person_alias_qual)
   SET request->person_alias[request->person_alias_qual].alias = cn->person_alias[l_loop].alias
   SET request->person_alias[request->person_alias_qual].person_id = cn->person_alias[l_loop].
   person_id
   SET request->person_alias[request->person_alias_qual].visit_seq_nbr = cn->person_alias[l_loop].
   visit_seq_nbr
   SET request->person_alias[request->person_alias_qual].person_alias_id = cn->person_alias[l_loop].
   person_alias_id
   SET request->person_alias[request->person_alias_qual].health_card_issue_dt_tm = cnvtdatetime(cn->
    person_alias[l_loop].health_card_issue_dt_tm)
   SET request->person_alias[request->person_alias_qual].health_card_expiry_dt_tm = cnvtdatetime(cn->
    person_alias[l_loop].health_card_expiry_dt_tm)
   SET request->person_alias[request->person_alias_qual].health_card_province = cn->person_alias[
   l_loop].health_card_province
   SET request->person_alias[request->person_alias_qual].health_card_type = cn->person_alias[l_loop].
   health_card_type
   SET request->person_alias[request->person_alias_qual].health_card_ver_code = cn->person_alias[
   l_loop].health_card_ver_code
   SET request->person_alias[request->person_alias_qual].person_alias_status_cd = cn->person_alias[
   l_loop].person_alias_status_cd
   SET request->person_alias[request->person_alias_qual].person_alias_type_cd = cn->person_alias[
   l_loop].person_alias_type_cd
   SET request->person_alias[request->person_alias_qual].person_alias_sub_type_cd = cn->person_alias[
   l_loop].person_alias_sub_type_cd
   SET request->person_alias[request->person_alias_qual].alias_pool_cd = cn->person_alias[l_loop].
   alias_pool_cd
   SET request->person_alias[request->person_alias_qual].beg_effective_dt_tm = cnvtdatetime(cn->
    person_alias[l_loop].beg_effective_dt_tm)
   SET request->person_alias[request->person_alias_qual].active_status_cd = cn->person_alias[l_loop].
   active_status_cd
   SET request->person_alias[request->person_alias_qual].active_status_dt_tm = cnvtdatetime(cn->
    person_alias[l_loop].active_status_dt_tm)
   SET request->person_alias[request->person_alias_qual].active_status_prsnl_id = cn->person_alias[
   l_loop].active_status_prsnl_id
   SET request->person_alias[request->person_alias_qual].assign_authority_sys_cd = cn->person_alias[
   l_loop].assign_authority_sys_cd
   SET request->person_alias[request->person_alias_qual].check_digit = cn->person_alias[l_loop].
   check_digit
   SET request->person_alias[request->person_alias_qual].check_digit_method_cd = cn->person_alias[
   l_loop].check_digit_method_cd
   SET request->person_alias[request->person_alias_qual].contributor_system_cd = cn->person_alias[
   l_loop].contributor_system_cd
   SET request->person_alias[request->person_alias_qual].data_status_cd = cn->person_alias[l_loop].
   data_status_cd
   SET request->person_alias[request->person_alias_qual].data_status_dt_tm = cnvtdatetime(cn->
    person_alias[l_loop].data_status_dt_tm)
   SET request->person_alias[request->person_alias_qual].data_status_prsnl_id = cn->person_alias[
   l_loop].data_status_prsnl_id
   SELECT INTO "nl:"
    FROM person_alias pa
    WHERE pa.person_alias_type_cd=cmrn_cd
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > sysdate
     AND (pa.person_id=cn->person_alias[l_loop].person_id)
    DETAIL
     cn->person_alias[l_loop].cn = pa.alias
    WITH nocounter
   ;end select
   IF (textlen(trim(cn->person_alias[l_loop].bwh_mrn,3)) > 0)
    SELECT INTO "nl:"
     FROM cust_dup_mrn c
     WHERE c.cn=format(cn->person_alias[l_loop].cn,"#######;rp0")
      AND (c.bwh_mrn=cn->person_alias[l_loop].bwh_mrn)
     DETAIL
      request->person_alias[request->person_alias_qual].active_ind = 1, request->person_alias[request
      ->person_alias_qual].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
     WITH nocounter
    ;end select
    SET l_bwh_cnt2 = (l_bwh_cnt2+ 1)
    SET l_updated_cnt2 = (l_updated_cnt2+ 1)
    IF (curqual != 0)
     EXECUTE pm_upt_person_alias
     SET l_bwh_cnt = (l_bwh_cnt+ 1)
     SET l_updated_cnt = (l_updated_cnt+ 1)
     CALL echo("*-----------------*")
     CALL echo(l_loop)
     CALL echo(build("CN: ",cn->person_alias[l_loop].cn))
     CALL echo(build(" BWH_MRN: ",cn->person_alias[l_loop].bwh_mrn))
     CALL echo(build("PERSON_ALIAS_ID: ",cn->person_alias[l_loop].person_alias_id))
     CALL echo(build("person_id: ",cn->person_alias[l_loop].person_id))
     CALL echo("------------------")
    ELSE
     SET missing->missing_cnt = (missing->missing_cnt+ 1)
     SET stat = alterlist(missing->list,missing->missing_cnt)
     SET missing->list[missing->missing_cnt].person_id = request->person_alias[request->
     person_alias_qual].person_id
     SET missing->list[missing->missing_cnt].person_alias_id = request->person_alias[request->
     person_alias_qual].person_alias_id
     SET missing->list[missing->missing_cnt].person_alias_type_cd = request->person_alias[request->
     person_alias_qual].person_alias_type_cd
     SET missing->list[missing->missing_cnt].alias_pool_cd = request->person_alias[request->
     person_alias_qual].alias_pool_cd
     SET missing->list[missing->missing_cnt].alias = request->person_alias[request->person_alias_qual
     ].alias
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
 CALL echo("*--Will be updated ---------------*")
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
 CALL echo("*--Angelce count---------------*")
 CALL echo(build(" BMC_MRN3: ",l_bmc_cnt3))
 CALL echo(build(" FMC_MRN3: ",l_fmc_cnt3))
 CALL echo(build("BMLH_MRN3: ",l_bmlh_cnt3))
 CALL echo(build(" BWH_MRN3: ",l_bwh_cnt3))
 CALL echo(build("   TOTAL3: ",l_updated_cnt3))
 CALL echo("------------------")
#exit_program
 FREE RECORD cn
END GO

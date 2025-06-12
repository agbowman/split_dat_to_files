CREATE PROGRAM bhs_dup_mrn_cleanup_chk
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
 FREE RECORD cn
 RECORD cn(
   1 list[*]
     2 person_id = f8
     2 cn = vc
     2 fmc_mrn = f8
     2 mlh_mrn = f8
     2 bmc_mrn = f8
     2 bwh_mrn = vc
     2 prev_bmc_end_eff_dt_tm = dq8
     2 prev_bfmc_end_eff_dt_tm = dq8
     2 prev_mlh_end_eff_dt_tm = dq8
     2 prev_bwh_end_eff_dt_tm = dq8
     2 prev_bmc_active_ind = i2
     2 prev_bfmc_active_ind = i2
     2 prev_mlh_active_ind = i2
     2 prev_bwh_active_ind = i2
 )
 FREE RECORD missing
 RECORD missing(
   1 list[*]
     2 cn = vc
 )
 DECLARE cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE bmc_mrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"BMCMRN"))
 DECLARE fmc_mrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"FMCMRN"))
 DECLARE mlh_mrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"MLHMRN"))
 DECLARE bwh_mrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"BWHMRN"))
 DECLARE bhs_cmrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"BHSCMRN"))
 DECLARE j_cnt = i4 WITH protect
 DECLARE ndx = i4 WITH protect
 DECLARE ndx2 = i4 WITH protect
 DECLARE ndx3 = i4 WITH protect
 DECLARE ndx4 = i4 WITH protect
 DECLARE ndx5 = i4 WITH protect
 DECLARE ndx6 = i4 WITH protect
 DECLARE cn_pos = i4 WITH protect
 DECLARE pool_pos = i4 WITH protect
 DECLARE cn_cnt = i4 WITH protect
 DECLARE ndx = i4 WITH protect
 DECLARE ndx2 = i4 WITH protect
 DECLARE p_pos = i4 WITH protect
 DECLARE loop = i4 WITH protect
 DECLARE loop_limit = i4 WITH protect, noconstant( $1)
 SELECT INTO "nl:"
  FROM person_alias pa1,
   person_alias pa2,
   person p
  WHERE pa1.active_ind=1
   AND pa1.end_effective_dt_tm > sysdate
   AND pa1.person_alias_type_cd=10
   AND pa2.person_id=pa1.person_id
   AND pa2.active_ind=1
   AND pa2.end_effective_dt_tm > sysdate
   AND pa2.alias_pool_cd=pa1.alias_pool_cd
   AND pa2.person_alias_id != pa1.person_alias_id
   AND pa2.person_alias_type_cd=10
   AND p.person_id=pa1.person_id
  DETAIL
   cn_cnt = (cn_cnt+ 1), stat = alterlist(cn->list,cn_cnt), cn->list[cn_cnt].person_id = p.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE pa.active_ind=1
   AND pa.end_effective_dt_tm > sysdate
   AND pa.person_alias_type_cd=2
   AND expand(ndx,1,cn_cnt,pa.person_id,cn->list[ndx].person_id)
  DETAIL
   p_pos = locateval(ndx2,1,cn_cnt,pa.person_id,cn->list[ndx2].person_id), cn->list[p_pos].cn = pa
   .alias
  WITH nocounter, expand = 1
 ;end select
 FOR (loop = 1 TO cn_cnt)
   SET request->person_alias_qual = 0
   CALL echo("*****")
   CALL echo(loop)
   CALL echo(" of ")
   CALL echo(loop_limit)
   CALL echo(cn->list[loop].person_id)
   CALL echo("-----")
   SELECT INTO "nl:"
    FROM cust_dup_mrn j
    WHERE (j.cn=cn->list[loop].cn)
     AND j.processed_ind=0
    DETAIL
     cn->list[loop].bmc_mrn = cnvtreal(j.bmc_mrn), cn->list[loop].fmc_mrn = cnvtreal(j.bfmc_mrn), cn
     ->list[loop].mlh_mrn = cnvtreal(j.bmlh_mrn),
     cn->list[loop].bwh_mrn = j.bwh_mrn
    WITH nocounter
   ;end select
   IF (curqual)
    SELECT INTO "nl:"
     FROM person_alias pa
     WHERE pa.person_alias_type_cd IN (mrn_cd, cmrn_cd)
      AND pa.alias_pool_cd IN (bmc_mrn_pool_cd, fmc_mrn_pool_cd, mlh_mrn_pool_cd, bwh_mrn_pool_cd,
     bhs_cmrn_pool_cd)
      AND pa.beg_effective_dt_tm < sysdate
      AND pa.end_effective_dt_tm > sysdate
      AND (pa.person_id=cn->list[loop].person_id)
     ORDER BY pa.person_id, pa.person_alias_type_cd, pa.alias_pool_cd
     HEAD pa.person_id
      cn_pos = 0
     DETAIL
      pool_pos = 0, request->person_alias_qual = (request->person_alias_qual+ 1), stat = alterlist(
       request->person_alias,request->person_alias_qual)
      IF (pa.person_alias_type_cd=cmrn_cd)
       cn_pos = locateval(ndx2,1,j_cnt,pa.alias,cnvtstring(cn->list[ndx2].cn))
      ELSE
       IF (pa.alias_pool_cd=bmc_mrn_pool_cd)
        pool_pos = locateval(ndx3,1,j_cnt,pa.alias,cnvtstring(cn->list[ndx3].bmc_mrn)), cn->list[
        cn_pos].prev_bmc_end_eff_dt_tm = pa.end_effective_dt_tm, cn->list[cn_pos].prev_bmc_active_ind
         = pa.active_ind
       ELSEIF (pa.alias_pool_cd=fmc_mrn_pool_cd)
        pool_pos = locateval(ndx4,1,j_cnt,pa.alias,cnvtstring(cn->list[ndx4].fmc_mrn)), cn->list[
        cn_pos].prev_bfmc_end_eff_dt_tm = pa.end_effective_dt_tm, cn->list[cn_pos].
        prev_bfmc_active_ind = pa.active_ind
       ELSEIF (pa.alias_pool_cd=mlh_mrn_pool_cd)
        pool_pos = locateval(ndx5,1,j_cnt,pa.alias,cnvtstring(cn->list[ndx5].mlh_mrn)), cn->list[
        cn_pos].prev_mlh_end_eff_dt_tm = pa.end_effective_dt_tm, cn->list[cn_pos].prev_mlh_active_ind
         = pa.active_ind
       ELSEIF (pa.alias_pool_cd=bwh_mrn_pool_cd)
        pool_pos = locateval(ndx6,1,j_cnt,pa.alias,cn->list[ndx6].bwh_mrn), cn->list[cn_pos].
        prev_bwh_end_eff_dt_tm = pa.end_effective_dt_tm, cn->list[cn_pos].prev_bwh_active_ind = pa
        .active_ind
       ENDIF
       IF (pool_pos > 0
        AND (cn->list[cn_pos].cn=cn->list[pool_pos].cn))
        request->person_alias[request->person_alias_qual].active_ind = 1, request->person_alias[
        request->person_alias_qual].end_effective_dt_tm = cnvtdatetime(pa.end_effective_dt_tm)
       ELSEIF (pool_pos=0)
        request->person_alias[request->person_alias_qual].active_ind = pa.active_ind, request->
        person_alias[request->person_alias_qual].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
       ELSE
        request->person_alias[request->person_alias_qual].active_ind = pa.active_ind, request->
        person_alias[request->person_alias_qual].end_effective_dt_tm = cnvtdatetime(pa
         .end_effective_dt_tm)
       ENDIF
       request->person_alias[request->person_alias_qual].person_id = cnvtreal(pa.person_id), request
       ->person_alias[request->person_alias_qual].visit_seq_nbr = pa.visit_seq_nbr, request->
       person_alias[request->person_alias_qual].person_alias_id = pa.person_alias_id,
       request->person_alias[request->person_alias_qual].health_card_issue_dt_tm = cnvtdatetime(pa
        .health_card_issue_dt_tm), request->person_alias[request->person_alias_qual].
       health_card_expiry_dt_tm = cnvtdatetime(pa.health_card_expiry_dt_tm), request->person_alias[
       request->person_alias_qual].health_card_province = pa.health_card_province,
       request->person_alias[request->person_alias_qual].health_card_type = pa.health_card_type,
       request->person_alias[request->person_alias_qual].health_card_ver_code = pa
       .health_card_ver_code, request->person_alias[request->person_alias_qual].
       person_alias_status_cd = pa.person_alias_status_cd,
       request->person_alias[request->person_alias_qual].person_alias_type_cd = pa
       .person_alias_type_cd, request->person_alias[request->person_alias_qual].
       person_alias_sub_type_cd = pa.person_alias_sub_type_cd, request->person_alias[request->
       person_alias_qual].alias_pool_cd = pa.alias_pool_cd,
       request->person_alias[request->person_alias_qual].beg_effective_dt_tm = cnvtdatetime(pa
        .beg_effective_dt_tm), request->person_alias[request->person_alias_qual].active_status_cd =
       pa.active_status_cd, request->person_alias[request->person_alias_qual].active_status_dt_tm =
       cnvtdatetime(pa.active_status_dt_tm),
       request->person_alias[request->person_alias_qual].active_status_prsnl_id = pa
       .active_status_prsnl_id, request->person_alias[request->person_alias_qual].
       assign_authority_sys_cd = pa.assign_authority_sys_cd, request->person_alias[request->
       person_alias_qual].check_digit = pa.check_digit,
       request->person_alias[request->person_alias_qual].check_digit_method_cd = pa
       .check_digit_method_cd, request->person_alias[request->person_alias_qual].
       contributor_system_cd = pa.contributor_system_cd, request->person_alias[request->
       person_alias_qual].data_status_cd = pa.data_status_cd,
       request->person_alias[request->person_alias_qual].data_status_dt_tm = cnvtdatetime(pa
        .data_status_dt_tm), request->person_alias[request->person_alias_qual].data_status_prsnl_id
        = pa.data_status_prsnl_id
      ENDIF
     WITH nocounter, expand = 1
    ;end select
    EXECUTE pm_upt_person_alias
    COMMIT
    UPDATE  FROM cust_dup_mrn j
     SET j.processed_ind = 1, j.processed_dt_tm = cnvtdatetime(curdate,curtime3), j
      .prev_bmc_end_eff_dt_tm = cnvtdatetime(cn->list[loop].prev_bmc_end_eff_dt_tm),
      j.prev_bmc_active_ind = cn->list[loop].prev_bmc_active_ind, j.prev_bfmc_end_eff_dt_tm =
      cnvtdatetime(cn->list[loop].prev_bfmc_end_eff_dt_tm), j.prev_bfmc_active_ind = cn->list[loop].
      prev_bfmc_active_ind,
      j.prev_bmlh_end_eff_dt_tm = cnvtdatetime(cn->list[loop].prev_mlh_end_eff_dt_tm), j
      .prev_bmlh_active_ind = cn->list[loop].prev_mlh_active_ind, j.prev_bwh_end_eff_dt_tm =
      cnvtdatetime(cn->list[loop].prev_bwh_end_eff_dt_tm),
      j.prev_bwh_active_ind = cn->list[loop].prev_bwh_active_ind
     PLAN (d)
      JOIN (j
      WHERE j.cn=cnvtstring(cn->list[loop].cn))
     WITH nocounter
    ;end update
    COMMIT
   ELSE
    CALL echo("*** Not found in CUST_DUP_MRN ***")
    CALL echo(cn->list[loop].cn)
    CALL echo("---------------------------------")
    SET miss_cnt = (miss_cnt+ 1)
    SET stat = alterlist(missing->list,miss_cnt)
    SET missing->list[miss_cnt].cn = cn->list[loop].cn
   ENDIF
 ENDFOR
#exit_program
 CALL echorecord(missing)
END GO

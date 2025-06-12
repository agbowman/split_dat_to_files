CREATE PROGRAM bhs_dup_mrn_cleanup_aa:dba
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
 FREE RECORD rec_temp
 RECORD rec_temp(
   1 list[*]
     2 cn = f8
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
 DECLARE cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE bmc_mrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"BMCMRN"))
 DECLARE fmc_mrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"FMCMRN"))
 DECLARE mlh_mrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"MLHMRN"))
 DECLARE bwh_mrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"BWHMRN"))
 DECLARE bhs_cmrn_pool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",263,"BHSCMRN"))
 DECLARE j_cnt = i4
 DECLARE ndx = i4
 DECLARE ndx2 = i4
 DECLARE ndx3 = i4
 DECLARE ndx4 = i4
 DECLARE ndx5 = i4
 DECLARE ndx6 = i4
 DECLARE cn_pos = i4
 DECLARE pool_pos = i4
 DECLARE l_max_qual = i4 WITH protect, noconstant(100)
 SELECT INTO "NL:"
  FROM cust_dup_mrn j
  WHERE j.cn IN ("0443001", "2551645", "2589358", "0520976", "0730781",
  "0819757", "0721259", "2581907", "2564568", "2526743",
  "2532437")
  DETAIL
   j_cnt = (j_cnt+ 1), stat = alterlist(rec_temp->list,j_cnt), rec_temp->list[j_cnt].cn = cnvtreal(j
    .cn),
   rec_temp->list[j_cnt].bmc_mrn = cnvtreal(j.bmc_mrn), rec_temp->list[j_cnt].fmc_mrn = cnvtreal(j
    .bfmc_mrn), rec_temp->list[j_cnt].mlh_mrn = cnvtreal(j.bmlh_mrn),
   rec_temp->list[j_cnt].bwh_mrn = j.bwh_mrn
  WITH nocounter, maxqual(j,value(l_max_qual)), time = 30
 ;end select
 CALL echorecord(rec_temp)
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE pa.person_alias_type_cd IN (mrn_cd, cmrn_cd)
   AND pa.alias_pool_cd IN (bmc_mrn_pool_cd, fmc_mrn_pool_cd, mlh_mrn_pool_cd, bwh_mrn_pool_cd,
  bhs_cmrn_pool_cd)
   AND pa.person_id IN (
  (SELECT
   pa2.person_id
   FROM person_alias pa2,
    cust_dup_mrn c
   WHERE expand(ndx,1,j_cnt,pa2.person_alias_type_cd,cmrn_cd,
    pa2.alias,cnvtstring(rec_temp->list[ndx].cn))))
  ORDER BY pa.person_id, pa.person_alias_type_cd, pa.alias_pool_cd
  HEAD pa.person_id
   cn_pos = 0
  DETAIL
   pool_pos = 0, request->person_alias_qual = (request->person_alias_qual+ 1), stat = alterlist(
    request->person_alias,request->person_alias_qual)
   IF (pa.person_alias_type_cd=cmrn_cd)
    cn_pos = locateval(ndx2,1,j_cnt,pa.alias,cnvtstring(rec_temp->list[ndx2].cn))
   ELSE
    IF (pa.alias_pool_cd=bmc_mrn_pool_cd)
     pool_pos = locateval(ndx3,1,j_cnt,pa.alias,cnvtstring(rec_temp->list[ndx3].bmc_mrn)), rec_temp->
     list[cn_pos].prev_bmc_end_eff_dt_tm = pa.end_effective_dt_tm, rec_temp->list[cn_pos].
     prev_bmc_active_ind = pa.active_ind
    ELSEIF (pa.alias_pool_cd=fmc_mrn_pool_cd)
     pool_pos = locateval(ndx4,1,j_cnt,pa.alias,cnvtstring(rec_temp->list[ndx4].fmc_mrn)), rec_temp->
     list[cn_pos].prev_bfmc_end_eff_dt_tm = pa.end_effective_dt_tm, rec_temp->list[cn_pos].
     prev_bfmc_active_ind = pa.active_ind
    ELSEIF (pa.alias_pool_cd=mlh_mrn_pool_cd)
     pool_pos = locateval(ndx5,1,j_cnt,pa.alias,cnvtstring(rec_temp->list[ndx5].mlh_mrn)), rec_temp->
     list[cn_pos].prev_mlh_end_eff_dt_tm = pa.end_effective_dt_tm, rec_temp->list[cn_pos].
     prev_mlh_active_ind = pa.active_ind
    ELSEIF (pa.alias_pool_cd=bwh_mrn_pool_cd)
     pool_pos = locateval(ndx6,1,j_cnt,pa.alias,rec_temp->list[ndx6].bwh_mrn), rec_temp->list[cn_pos]
     .prev_bwh_end_eff_dt_tm = pa.end_effective_dt_tm, rec_temp->list[cn_pos].prev_bwh_active_ind =
     pa.active_ind
    ENDIF
    CALL echo("********************************************"),
    CALL echo(pa.person_alias_id),
    CALL echo(uar_get_code_display(pa.alias_pool_cd)),
    CALL echo(uar_get_code_display(pa.person_alias_type_cd)),
    CALL echo(pa.alias),
    CALL echo(pool_pos)
    IF (pool_pos > 0
     AND (rec_temp->list[cn_pos].cn=rec_temp->list[pool_pos].cn))
     request->person_alias[request->person_alias_qual].active_ind = 1, request->person_alias[request
     ->person_alias_qual].end_effective_dt_tm = cnvtdatetime(pa.end_effective_dt_tm),
     CALL echo("CN POOL MATCH")
    ELSEIF (pool_pos=0)
     request->person_alias[request->person_alias_qual].active_ind = pa.active_ind, request->
     person_alias[request->person_alias_qual].end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     CALL echo("pool = 0")
    ELSE
     request->person_alias[request->person_alias_qual].active_ind = pa.active_ind, request->
     person_alias[request->person_alias_qual].end_effective_dt_tm = cnvtdatetime(pa
      .end_effective_dt_tm),
     CALL echo("Pool match no matchCN")
    ENDIF
    request->person_alias[request->person_alias_qual].person_id = cnvtreal(pa.person_id), request->
    person_alias[request->person_alias_qual].visit_seq_nbr = pa.visit_seq_nbr, request->person_alias[
    request->person_alias_qual].person_alias_id = pa.person_alias_id,
    request->person_alias[request->person_alias_qual].health_card_issue_dt_tm = cnvtdatetime(pa
     .health_card_issue_dt_tm), request->person_alias[request->person_alias_qual].
    health_card_expiry_dt_tm = cnvtdatetime(pa.health_card_expiry_dt_tm), request->person_alias[
    request->person_alias_qual].health_card_province = pa.health_card_province,
    request->person_alias[request->person_alias_qual].health_card_type = pa.health_card_type, request
    ->person_alias[request->person_alias_qual].health_card_ver_code = pa.health_card_ver_code,
    request->person_alias[request->person_alias_qual].person_alias_status_cd = pa
    .person_alias_status_cd,
    request->person_alias[request->person_alias_qual].person_alias_type_cd = pa.person_alias_type_cd,
    request->person_alias[request->person_alias_qual].person_alias_sub_type_cd = pa
    .person_alias_sub_type_cd, request->person_alias[request->person_alias_qual].alias_pool_cd = pa
    .alias_pool_cd,
    request->person_alias[request->person_alias_qual].beg_effective_dt_tm = cnvtdatetime(pa
     .beg_effective_dt_tm), request->person_alias[request->person_alias_qual].active_status_cd = pa
    .active_status_cd, request->person_alias[request->person_alias_qual].active_status_dt_tm =
    cnvtdatetime(pa.active_status_dt_tm),
    request->person_alias[request->person_alias_qual].active_status_prsnl_id = pa
    .active_status_prsnl_id, request->person_alias[request->person_alias_qual].
    assign_authority_sys_cd = pa.assign_authority_sys_cd, request->person_alias[request->
    person_alias_qual].check_digit = pa.check_digit,
    request->person_alias[request->person_alias_qual].check_digit_method_cd = pa
    .check_digit_method_cd, request->person_alias[request->person_alias_qual].contributor_system_cd
     = pa.contributor_system_cd, request->person_alias[request->person_alias_qual].data_status_cd =
    pa.data_status_cd,
    request->person_alias[request->person_alias_qual].data_status_dt_tm = cnvtdatetime(pa
     .data_status_dt_tm), request->person_alias[request->person_alias_qual].data_status_prsnl_id = pa
    .data_status_prsnl_id
   ENDIF
  WITH nocounter, expand = 1, time = 30
 ;end select
 CALL echorecord(request)
 CALL echorecord(rec_temp)
#exit_program
END GO

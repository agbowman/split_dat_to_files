CREATE PROGRAM bhs_dup_mrn_cleanup_jw:dba
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
 DECLARE l_max_qual = i4 WITH protect, noconstant(100000)
 SELECT INTO "NL:"
  FROM cust_dup_mrn j
  WHERE j.processed_ind=0
  DETAIL
   j_cnt = (j_cnt+ 1), stat = alterlist(rec_temp->list,j_cnt), rec_temp->list[j_cnt].cn = cnvtreal(j
    .cn),
   rec_temp->list[j_cnt].bmc_mrn = cnvtreal(j.bmc_mrn), rec_temp->list[j_cnt].fmc_mrn = cnvtreal(j
    .bfmc_mrn), rec_temp->list[j_cnt].mlh_mrn = cnvtreal(j.bmlh_mrn),
   rec_temp->list[j_cnt].bwh_mrn = j.bwh_mrn,
   CALL echo(build("@",j.cn,"@")),
   CALL echo(build("@",rec_temp->list[j_cnt].cn,"@"))
  WITH nocounter, maxqual(j,value(l_max_qual))
 ;end select
#exit_program
END GO

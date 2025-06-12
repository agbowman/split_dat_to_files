CREATE PROGRAM dm_inserterremarks_cc:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF ((validate(mn_num_children,- (1))=- (1)))
  DECLARE mn_num_children = i4 WITH protect, noconstant(0)
 ENDIF
 IF ((validate(mn_num_tabs,- (2))=- (2)))
  DECLARE mn_num_tabs = i2 WITH protect, noconstant(0)
 ENDIF
 IF ((validate(dm2_rdm_parallel_debug_ind,- (1))=- (1)))
  DECLARE dm2_rdm_parallel_debug_ind = i2 WITH protect, noconstant(0)
 ELSEIF (dm2_rdm_parallel_debug_ind=1)
  CALL echo("*** Debugging mode for parallel readmes has been enabled ***")
  DECLARE debug_spaceline = c255 WITH protect, noconstant("")
  SET debug_spaceline = fillstring(255," ")
 ENDIF
 SUBROUTINE (sbr_insert_dm_info(ps_domain=vc,ps_name=vc,ps_char=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_insert_dm_info()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ps_domain))
   CALL sbr_parallel_debug_echo(concat("Info Name:   ",ps_name))
   CALL sbr_parallel_debug_echo(concat("Info Char:   ",ps_char))
   DECLARE errmsg = vc WITH protect, noconstant("")
   INSERT  FROM dm_info di
    SET di.info_domain = ps_domain, di.info_name = ps_name, di.info_number = 0,
     di.info_date = cnvtdatetime(sysdate), di.info_char = ps_char
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to insert range values into DM_INFO table: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_insert_dm_info() return: 0")
    RETURN(0)
   ENDIF
   COMMIT
   CALL sbr_parallel_debug_echo("sbr_insert_dm_info() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_update_dm_info(ps_domain=vc,ps_name=vc,ps_char=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_update_dm_info()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ps_domain))
   CALL sbr_parallel_debug_echo(concat("Info Name:   ",ps_name))
   CALL sbr_parallel_debug_echo(concat("Info Char:   ",ps_char))
   DECLARE errmsg = vc WITH protect, noconstant("")
   UPDATE  FROM dm_info di
    SET di.info_number = 0, di.info_date = cnvtdatetime(sysdate), di.info_char = ps_char
    WHERE di.info_domain=ps_domain
     AND di.info_name=ps_name
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update range values into DM_INFO table: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_update_dm_info() return: 0")
    RETURN(0)
   ENDIF
   COMMIT
   CALL sbr_parallel_debug_echo("sbr_update_dm_info() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_delete_dm_info(ps_domain=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_delete_dm_info()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ps_domain))
   DECLARE errmsg = vc WITH protect, noconstant("")
   DELETE  FROM dm_info
    WHERE info_domain=ps_domain
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error deleting from the DM_INFO table: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_delete_dm_info() return: 0")
    RETURN(0)
   ENDIF
   COMMIT
   CALL sbr_parallel_debug_echo("sbr_delete_dm_info() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_wipe_ranges(ms_info_domain_nm=vc,ms_child_prefix=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_wipe_ranges()")
   CALL sbr_parallel_debug_echo(concat("Domain Name:  ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Range Prefix: ",ms_child_prefix))
   DECLARE temp_range = vc WITH protect, noconstant("min:0:max:0")
   DECLARE temp_range_name = vc WITH protect, noconstant("")
   IF (sbr_delete_dm_info(ms_info_domain_nm)=0)
    CALL sbr_parallel_debug_echo("sbr_wipe_ranges() return: 0")
    RETURN(0)
   ENDIF
   FOR (range_idx = 1 TO mn_num_children)
    SET temp_range_name = concat(ms_child_prefix," ",cnvtstring(range_idx))
    IF (sbr_insert_dm_info(ms_info_domain_nm,temp_range_name,temp_range)=0)
     CALL sbr_parallel_debug_echo("sbr_wipe_ranges() return: 0")
     RETURN(0)
    ENDIF
   ENDFOR
   CALL sbr_parallel_debug_echo("sbr_wipe_ranges() return: 1")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_count_children(ms_info_domain_nm=vc) =i4)
   CALL sbr_parallel_debug_echo("Entering sbr_count_children()")
   CALL sbr_parallel_debug_echo(concat("Domain Name: ",ms_info_domain_nm))
   DECLARE mn_count = i4 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=ms_info_domain_nm
     AND di.info_char="SUCCESS"
    DETAIL
     mn_count += 1
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to select from info_table for success row: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_count_children() return: -1")
    RETURN(- (1))
   ENDIF
   CALL sbr_parallel_debug_echo(concat("sbr_count_children() return: ",build(mn_count)))
   RETURN(mn_count)
 END ;Subroutine
 SUBROUTINE (sbr_parallel_debug_echo(ms_msg=vc) =null)
   IF (dm2_rdm_parallel_debug_ind=1)
    IF (findstring("() return:",ms_msg) > 0)
     SET mn_num_tabs = maxval(0,(mn_num_tabs - 1))
    ENDIF
    CALL echo(concat(substring(1,(mn_num_tabs * 2),debug_spaceline),trim(ms_msg,1)))
    IF (ms_msg=patstring("Entering*?"))
     SET mn_num_tabs += 1
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE sbr_handle_cc_error(null) = i2
 IF ((validate(mf_runtime,- (1))=- (1)))
  DECLARE mf_runtime = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF ((validate(dq_starttime,- (1))=- (1)))
  DECLARE dq_starttime = dq8 WITH protect
 ENDIF
 IF ((validate(mf_min_batch_tm,- (2))=- (2)))
  DECLARE mf_min_batch_tm = f8 WITH protect, noconstant(- (1.0))
  DECLARE mf_max_batch_tm = f8 WITH protect, noconstant(- (1.0))
 ENDIF
 SUBROUTINE (sbr_get_min_max(mf_min_range_id=f8(ref),mf_max_range_id=f8(ref)) =null)
   CALL sbr_parallel_debug_echo("Entering sbr_get_min_max()")
   SET mf_min_range_id =  $1
   SET mf_max_range_id =  $2
   CALL echo(concat("MIN: ",cnvtstring(mf_min_range_id)))
   CALL echo(concat("MAX: ",cnvtstring(mf_max_range_id)))
   CALL sbr_parallel_debug_echo("sbr_get_min_max() return: <No return value>")
 END ;Subroutine
 SUBROUTINE sbr_handle_cc_error(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   IF (error(errmsg,0) != 0)
    IF (((findstring("ORA-01555",errmsg) != 0) OR (((findstring("ORA-01650",errmsg) != 0) OR (((
    findstring("ORA-01562",errmsg) != 0) OR (((findstring("ORA-30036",errmsg) != 0) OR (((findstring(
     "ORA-30027",errmsg) != 0) OR (findstring("ORA-01581",errmsg) != 0)) )) )) )) )) )
     ROLLBACK
     SET mn_rollback_seg_failed = 1
     CALL echo("Trapped rollback segment error; restructuring readme...")
     SET readme_data->status = "F"
     SET readme_data->message = concat("Trapped rollback error: ",errmsg)
     RETURN(0)
    ELSEIF (findstring("ORA-00060",errmsg) != 0)
     ROLLBACK
     SET mn_deadlock_ind = 1
     CALL echo("Detected deadlock error")
     SET readme_data->status = "F"
     SET readme_data->message = concat("Trapped deadlock error: ",errmsg)
     RETURN(0)
    ENDIF
    CALL echo("Processing failed...")
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failure during CC readme execution: ",errmsg)
    SET mn_child_failed = 1
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (sbr_upd_id_evaluated(mf_max_id=f8,ms_info_domain_nm=vc,ms_max_name=vc) =i2)
   CALL sbr_parallel_debug_echo("Entering sbr_upd_id_evaluated()")
   CALL sbr_parallel_debug_echo(concat("Maximum ID:        ",cnvtstring(mf_max_id)))
   CALL sbr_parallel_debug_echo(concat("Domain Name:       ",ms_info_domain_nm))
   CALL sbr_parallel_debug_echo(concat("Max Eval Row Name: ",ms_max_name))
   DECLARE errmsg = vc WITH protect, noconstant("")
   SET mf_runtime = datetimediff(cnvtdatetime(sysdate),dq_starttime,5)
   CALL sbr_parallel_debug_echo(concat("Runtime: ",cnvtstring(mf_runtime)))
   UPDATE  FROM dm_info di
    SET di.info_number = mf_max_id, di.info_date = cnvtdatetime(sysdate), di.updt_cnt = (di.updt_cnt
     + 1),
     di.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE di.info_domain=ms_info_domain_nm
     AND di.info_name=concat(ms_max_name," ",cnvtstring(mf_readme_num))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update SUCCESS row on DM_INFO: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_upd_id_evaluated() return: 0")
    RETURN(0)
   ELSE
    CALL sbr_parallel_debug_echo("Committing SUCCESS row update.")
    COMMIT
   ENDIF
   IF (mf_min_batch_tm >= 0.0)
    CALL sbr_parallel_debug_echo("Minimum runtime previously set; using smallest value")
    SET mf_min_batch_tm = minval(mf_min_batch_tm,mf_runtime)
   ELSE
    CALL sbr_parallel_debug_echo("Minimum runtime not previously set; using current runtime")
    SET mf_min_batch_tm = mf_runtime
   ENDIF
   SET mf_max_batch_tm = maxval(mf_max_batch_tm,mf_runtime)
   CALL sbr_parallel_debug_echo(concat("Minimum runtime: ",cnvtstring(mf_min_batch_tm)))
   CALL sbr_parallel_debug_echo(concat("Maximum runtime: ",cnvtstring(mf_max_batch_tm)))
   UPDATE  FROM dm_parallel_readme_stats dprs
    SET dprs.total_elapsed_tm = (dprs.total_elapsed_tm+ mf_runtime), dprs.min_batch_tm =
     mf_min_batch_tm, dprs.max_batch_tm = mf_max_batch_tm,
     dprs.last_batch_tm = mf_runtime, dprs.std_dvtn_square = ((dprs.total_elapsed_tm** 2)+ (
     mf_runtime** 2)), dprs.updt_dt_tm = cnvtdatetime(sysdate),
     dprs.updt_cnt = (dprs.updt_cnt+ 1), dprs.updt_id = reqinfo->updt_id, dprs.updt_applctx = reqinfo
     ->updt_applctx,
     dprs.updt_task = reqinfo->updt_task
    WHERE dprs.readme_id=mf_readme_num
     AND dprs.range_name=concat(ms_max_name," ",cnvtstring(mf_readme_num))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error updating statistics row: ",errmsg)
    CALL sbr_parallel_debug_echo(concat("README_DATA->MESSAGE: ",readme_data->message))
    CALL sbr_parallel_debug_echo("sbr_upd_id_evaluated() return: 0")
    RETURN(0)
   ELSE
    CALL sbr_parallel_debug_echo("Committing stats row update.")
    COMMIT
   ENDIF
   CALL sbr_parallel_debug_echo("sbr_upd_id_evaluated() return: 1")
   RETURN(1)
 END ;Subroutine
 DECLARE mf_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_child_c_info_domain_nm = vc WITH protect, noconstant("")
 DECLARE ms_child_c_max_name = vc WITH protect, noconstant("")
 DECLARE ncnt = i2 WITH protect, noconstant(0)
 DECLARE fparentactivityid = f8 WITH protect, noconstant(0.0)
 DECLARE fbatchtransid = f8 WITH protect, noconstant(0.0)
 DECLARE ftranstotalamount = f8 WITH protect, noconstant(0.0)
 DECLARE fpostdttm = dq8 WITH protect, noconstant(0)
 DECLARE fbegeffectivedttm = dq8 WITH protect, noconstant(0)
 DECLARE fbillvrsnnbr = i4 WITH protect, noconstant(0)
 DECLARE fbillnbrdisp = vc WITH protect, noconstant("")
 DECLARE fcorspactivityid = f8 WITH protect, noconstant(0.0)
 DECLARE fbenefitorderid = f8 WITH protect, noconstant(0.0)
 DECLARE ftransgroupnbr = i4 WITH protect, noconstant(0)
 DECLARE fpftlineitemid = f8 WITH protect, noconstant(0.0)
 DECLARE iidx = i4 WITH protect, noconstant(0)
 DECLARE fbatchtransfileid = f8 WITH protect, noconstant(0.0)
 DECLARE fdenialid = f8 WITH protect, noconstant(0.0)
 DECLARE fdenialdetailfilerid = f8 WITH protect, noconstant(0.0)
 SET ms_child_c_info_domain_nm = "DM_INSERTERREMARKS_README"
 SET ms_child_c_max_name = "MAX acct_id EVALUATED"
 CALL sbr_get_min_max(mf_min_id,mf_max_id)
 CALL echo("Processing...")
 CALL echo("")
 RECORD ecaposted(
   1 objarray[*]
     2 batch_trans_file_id = f8
     2 batch_trans_id = f8
     2 trans_group_nbr = i2
     2 balance = f8
     2 ecaamount = f8
     2 corsp_activity_id = f8
     2 pft_line_item_id = f8
     2 billversionnumber = i4
     2 benefitorderid = f8
     2 bill_nbr_disp = vc
     2 post_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
 ) WITH protect
 DECLARE getclaimlevelecaposted(null) = i2
 DECLARE getlinelevelecaposted(null) = i2
 DECLARE addbtfdata(null) = i2
 DECLARE adddenialdata(null) = i2
 DECLARE adddenialdetaildata(null) = i2
 DECLARE addbatchdenialfiledata(null) = i2
 DECLARE addbatchdenialfiledatadetail(null) = i2
 CALL getclaimlevelecaposted(0)
 CALL getlinelevelecaposted(0)
 SET stat = alterlist(ecaposted->objarray,ncnt)
 IF (ncnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = "No Data to Insert"
  GO TO exit_program
 ENDIF
 FOR (iidx = 1 TO ncnt)
   SET ftranstotalamount = (ecaposted->objarray[iidx].balance+ ecaposted->objarray[iidx].ecaamount)
   SET fbatchtransid = ecaposted->objarray[iidx].batch_trans_id
   SET fbillvrsnnbr = ecaposted->objarray[iidx].billversionnumber
   SET fbillnbrdisp = ecaposted->objarray[iidx].bill_nbr_disp
   SET fcorspactivityid = ecaposted->objarray[iidx].corsp_activity_id
   SET fpftlineitemid = ecaposted->objarray[iidx].pft_line_item_id
   SET fbenefitorderid = ecaposted->objarray[iidx].benefitorderid
   SET ftransgroupnbr = ecaposted->objarray[iidx].trans_group_nbr
   SET fpostdttm = ecaposted->objarray[iidx].post_dt_tm
   SET fbegeffectivedttm = ecaposted->objarray[iidx].beg_effective_dt_tm
   CALL addbtfdata(null)
   CALL adddenialdata(null)
   CALL adddenialdetaildata(null)
   CALL addbatchdenialfiledata(null)
   CALL addbatchdenialfiledatadetail(null)
   COMMIT
 ENDFOR
 IF (sbr_handle_cc_error(null)=0)
  GO TO exit_program
 ENDIF
 CALL echo("Processing...Completed")
 IF (sbr_upd_id_evaluated(mf_max_id,ms_child_c_info_domain_nm,ms_child_c_max_name)=0)
  GO TO exit_program
 ENDIF
 SUBROUTINE getclaimlevelecaposted(dummyvar)
   SELECT INTO "nl:"
    FROM encounter e,
     pft_encntr pe,
     account a,
     benefit_order bo,
     bill_reltn brn,
     bill_rec br,
     batch_trans_file btf,
     pft_trans_reltn ptr,
     trans_trans_reltn ttr,
     pft_trans_reltn ptr1,
     batch_trans_file btf1,
     batch_trans bt1
    PLAN (e
     WHERE e.encntr_id >= mf_min_id
      AND e.encntr_id <= mf_max_id
      AND e.active_ind=1)
     JOIN (pe
     WHERE pe.encntr_id=e.encntr_id
      AND pe.active_ind=true)
     JOIN (a
     WHERE a.acct_id=pe.acct_id
      AND a.acct_type_cd=f_cs18736_ar
      AND a.active_ind=true
      AND a.acct_sub_type_cd=f_cs20849_patient
      AND a.acct_status_cd=f_cs18735_open)
     JOIN (bo
     WHERE bo.pft_encntr_id=pe.pft_encntr_id
      AND bo.active_ind=true)
     JOIN (brn
     WHERE brn.parent_entity_id=bo.benefit_order_id
      AND brn.parent_entity_name="BENEFIT ORDER"
      AND brn.active_ind=true)
     JOIN (br
     WHERE br.corsp_activity_id=brn.corsp_activity_id
      AND br.active_ind=true
      AND br.bill_status_cd != f_cs18935_canceled)
     JOIN (btf
     WHERE btf.corsp_activity_id=br.corsp_activity_id
      AND btf.active_ind=true
      AND btf.pft_line_item_id=0.0
      AND btf.trans_subtype_cd=f_cs20549_exp_reim_adj
      AND btf.trans_reason_cd != f_cs18937_reversal_cd)
     JOIN (ptr
     WHERE ptr.batch_trans_file_id=btf.batch_trans_file_id
      AND ptr.active_ind=true
      AND ptr.parent_entity_id=br.corsp_activity_id
      AND ptr.parent_entity_name="BILL"
      AND ptr.trans_type_cd=f_cs18649_adjust_cd)
     JOIN (ttr
     WHERE (ttr.parent_activity_id= Outerjoin(ptr.activity_id))
      AND (ttr.active_ind= Outerjoin(true))
      AND (ttr.trans_reltn_reason_cd= Outerjoin(f_cs25753_reversal_cd)) )
     JOIN (ptr1
     WHERE (ptr1.activity_id= Outerjoin(ttr.child_activity_id))
      AND (ptr1.active_ind= Outerjoin(true))
      AND (ptr1.parent_entity_name= Outerjoin("BILL")) )
     JOIN (btf1
     WHERE (btf1.batch_trans_file_id= Outerjoin(ptr1.batch_trans_file_id))
      AND (btf1.active_ind= Outerjoin(true)) )
     JOIN (bt1
     WHERE (bt1.batch_trans_id= Outerjoin(btf1.batch_trans_id))
      AND (bt1.active_ind= Outerjoin(true)) )
    ORDER BY ptr.parent_entity_id, ttr.trans_trans_reltn_id, ptr.beg_effective_dt_tm DESC
    HEAD ptr.parent_entity_id
     ncnt += 1
     IF (mod(ncnt,100)=1)
      stat = alterlist(ecaposted->objarray,(ncnt+ 99))
     ENDIF
     ecaposted->objarray[ncnt].balance = (br.balance * evaluate(br.balance_dr_cr_flag,1,1.0,2,- (1.0),
      0.0)), ecaposted->objarray[ncnt].ecaamount = (ptr.amount * evaluate(ptr.dr_cr_flag,1,1.0,2,- (
      1.0),
      0.0)), ecaposted->objarray[ncnt].batch_trans_file_id = btf.batch_trans_file_id,
     ecaposted->objarray[ncnt].batch_trans_id = btf.batch_trans_id, ecaposted->objarray[ncnt].
     trans_group_nbr = btf.trans_group_nbr, ecaposted->objarray[ncnt].corsp_activity_id = ptr
     .parent_entity_id,
     ecaposted->objarray[ncnt].pft_line_item_id = 0.0, ecaposted->objarray[ncnt].billversionnumber =
     btf.bill_vrsn_nbr, ecaposted->objarray[ncnt].benefitorderid = btf.benefit_order_id,
     ecaposted->objarray[ncnt].bill_nbr_disp = btf.bill_nbr_disp, ecaposted->objarray[ncnt].
     beg_effective_dt_tm = btf.beg_effective_dt_tm, ecaposted->objarray[ncnt].post_dt_tm = btf
     .post_dt_tm,
     fparentactivityid = ptr.activity_id
    HEAD ttr.trans_trans_reltn_id
     IF (ttr.parent_activity_id=fparentactivityid
      AND bt1.batch_type_flag IN (500, 501))
      ecaposted->objarray[ncnt].ecaamount += (ptr1.amount * evaluate(ptr1.dr_cr_flag,1,1.0,2,- (1.0),
       0.0))
     ENDIF
    WITH nocounter
   ;end select
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE getlinelevelecaposted(dummyvar)
   SELECT INTO "nl:"
    FROM encounter e,
     pft_encntr pe,
     account a,
     benefit_order bo,
     bill_reltn brn,
     bill_rec br,
     batch_trans_file btf,
     pft_line_item pli,
     pft_trans_reltn ptr,
     trans_trans_reltn ttr,
     pft_trans_reltn ptr1,
     batch_trans_file btf1,
     batch_trans bt1
    PLAN (e
     WHERE e.encntr_id >= mf_min_id
      AND e.encntr_id <= mf_max_id
      AND e.active_ind=1)
     JOIN (pe
     WHERE pe.encntr_id=e.encntr_id
      AND pe.active_ind=true)
     JOIN (a
     WHERE a.acct_id=pe.acct_id
      AND a.acct_type_cd=f_cs18736_ar
      AND a.active_ind=true
      AND a.acct_sub_type_cd=f_cs20849_patient
      AND a.acct_status_cd=f_cs18735_open)
     JOIN (bo
     WHERE bo.pft_encntr_id=pe.pft_encntr_id
      AND bo.active_ind=true)
     JOIN (brn
     WHERE brn.parent_entity_id=bo.benefit_order_id
      AND brn.parent_entity_name="BENEFIT ORDER"
      AND brn.active_ind=true)
     JOIN (br
     WHERE br.corsp_activity_id=brn.corsp_activity_id
      AND br.active_ind=true
      AND br.bill_status_cd != f_cs18935_canceled)
     JOIN (btf
     WHERE btf.corsp_activity_id=br.corsp_activity_id
      AND btf.active_ind=true
      AND btf.pft_line_item_id > 0.0
      AND btf.trans_subtype_cd=f_cs20549_exp_reim_adj
      AND btf.trans_reason_cd != f_cs18937_reversal_cd)
     JOIN (pli
     WHERE pli.pft_line_item_id=btf.pft_line_item_id)
     JOIN (ptr
     WHERE ptr.parent_entity_id=pli.pft_line_item_id
      AND ptr.parent_entity_name="PFTLINEITEM"
      AND ptr.active_ind=true
      AND ptr.trans_type_cd=f_cs18649_adjust_cd)
     JOIN (ttr
     WHERE (ttr.parent_activity_id= Outerjoin(ptr.activity_id))
      AND (ttr.active_ind= Outerjoin(true))
      AND (ttr.trans_reltn_reason_cd= Outerjoin(f_cs25753_reversal_cd)) )
     JOIN (ptr1
     WHERE (ptr1.activity_id= Outerjoin(ttr.child_activity_id))
      AND (ptr1.active_ind= Outerjoin(true))
      AND (ptr1.parent_entity_name= Outerjoin("PFTLINEITEM")) )
     JOIN (btf1
     WHERE (btf1.batch_trans_file_id= Outerjoin(ptr1.batch_trans_file_id))
      AND (btf1.active_ind= Outerjoin(true)) )
     JOIN (bt1
     WHERE (bt1.batch_trans_id= Outerjoin(btf1.batch_trans_id))
      AND (bt1.active_ind= Outerjoin(true)) )
    ORDER BY ptr.parent_entity_id, ptr.beg_effective_dt_tm DESC, ttr.trans_trans_reltn_id
    HEAD ptr.parent_entity_id
     ncnt += 1
     IF (mod(ncnt,100)=1)
      stat = alterlist(ecaposted->objarray,(ncnt+ 99))
     ENDIF
     ecaposted->objarray[ncnt].balance = pli.total_charges, ecaposted->objarray[ncnt].ecaamount = (
     ptr.amount * evaluate(ptr.dr_cr_flag,1,1.0,2,- (1.0),
      0.0)), ecaposted->objarray[ncnt].batch_trans_file_id = btf.batch_trans_file_id,
     ecaposted->objarray[ncnt].batch_trans_id = btf.batch_trans_id, ecaposted->objarray[ncnt].
     trans_group_nbr = btf.trans_group_nbr, ecaposted->objarray[ncnt].corsp_activity_id = br
     .corsp_activity_id,
     ecaposted->objarray[ncnt].pft_line_item_id = ptr.parent_entity_id, ecaposted->objarray[ncnt].
     billversionnumber = btf.bill_vrsn_nbr, ecaposted->objarray[ncnt].benefitorderid = btf
     .benefit_order_id,
     ecaposted->objarray[ncnt].bill_nbr_disp = btf.bill_nbr_disp, ecaposted->objarray[ncnt].
     beg_effective_dt_tm = btf.beg_effective_dt_tm, ecaposted->objarray[ncnt].post_dt_tm = btf
     .post_dt_tm,
     fparentactivityid = ptr.activity_id
    HEAD ttr.trans_trans_reltn_id
     IF (ttr.parent_activity_id=fparentactivityid
      AND bt1.batch_type_flag IN (500, 501))
      ecaposted->objarray[ncnt].ecaamount += (ptr1.amount * evaluate(ptr1.dr_cr_flag,1,1.0,2,- (1.0),
       0.0))
     ENDIF
    WITH nocounter
   ;end select
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE addbtfdata(null)
   SELECT INTO "nl:"
    next_seq = seq(pft_bre_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     fbatchtransfileid = cnvtreal(next_seq)
    WITH format, counter
   ;end select
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   INSERT  FROM batch_trans_file b
    SET b.batch_trans_file_id = fbatchtransfileid, b.batch_trans_id = fbatchtransid, b.sequence_nbr
      = null,
     b.trans_type_cd = 0.0, b.trans_subtype_cd = 0.0, b.trans_reason_cd = 0.0,
     b.dr_cr_ar_flag = null, b.trans_total_amount = ftranstotalamount, b.ar_account_id = 0.0,
     b.finance_chrg_id = 0.0, b.payment_method_cd = 0.0, b.payment_num_desc = null,
     b.post_dt_tm = cnvtdatetime(fpostdttm), b.cc_beg_eff_dt_tm = null, b.cc_end_eff_dt_tm = null,
     b.current_cur_cd = 0.0, b.orig_cur_cd = 0.0, b.beg_effective_dt_tm = cnvtdatetime(
      fbegeffectivedttm),
     b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.00"), b.purged_ind = null, b
     .benefit_order_id = fbenefitorderid,
     b.bill_nbr_disp = fbillnbrdisp, b.bill_vrsn_nbr = fbillvrsnnbr, b.cc_auth_nbr = null,
     b.check_date = null, b.chrg_activity_id = 0.0, b.corsp_activity_id = fcorspactivityid,
     b.dr_cr_flag =
     IF (ftranstotalamount > 0.009) 1
     ELSEIF ((ftranstotalamount < - (0.009))) 2
     ELSE 0
     ENDIF
     , b.encntr_id = 0.0, b.error_ind = null,
     b.error_status_cd = f_cs20569_posted_cd, b.nontrans_flag = 1, b.parent_entity_id = 0.0,
     b.parent_entity_name = null, b.payor_cntrl_nbr_txt = null, b.payor_name = null,
     b.pft_encntr_id = 0.0, b.posting_method_cd = 0.0, b.related_seq_nbr = null,
     b.roll_bo_ind = null, b.created_dt_tm = cnvtdatetime(curdate,curtime), b.created_prsnl_id =
     fsystemid,
     b.trans_alias_id = 0.0, b.patient_responsibility = null, b.claim_status_cd = 0.0,
     b.health_plan_id = 0.0, b.edi_adj_group_cd = 0.0, b.edi_adj_quantity = 0,
     b.inpat_prof_comp_amt = 0.0, b.non_inpat_prof_comp_amt = 0.0, b.esrd_payment_amount = 0.0,
     b.claim_file_cd = 0.0, b.post_claim_default_ind = 0.0, b.tendered_amount = 0.0,
     b.pft_line_item_id = fpftlineitemid, b.long_text_id = 0.0, b.change_due_amt = 0.0,
     b.raw_batch_trans_file_id = null, b.trans_group_nbr = ftransgroupnbr, b.external_ident = null,
     b.guarantor_person_id = 0.0, b.cc_token_txt = null, b.error_status_reason_desc = null,
     b.cc_type_cd = 0.0, b.merchant_ident = null, b.pft_payment_plan_id = 0.0,
     b.chrg_writeoff_ind = 0, b.cc_location_cd = 0.0, b.edi_adj_reason_cd = 0.0,
     b.source_flag = 1, b.chrg_auto_fifo_flag = 0, b.cc_trans_org_id = 0.0,
     b.payor_org_id = 0.0, b.posting_category_type_flag = 0, b.pft_payment_location_id = 0.0,
     b.from_batch_trans_file_id = 0.0, b.interchange_transaction_ident = null, b.guar_acct_id = 0.0,
     b.surchrg_prtcptn_status_cd = 0.0, b.cc_app_name = null, b.cc_card_entry_mode_txt = null,
     b.cc_cvm_txt = null, b.cc_aid_txt = null, b.cc_tvr_txt = null,
     b.cc_iad_txt = null, b.cc_tsi_txt = null, b.cc_arc_txt = null,
     b.cc_app_label = null, b.active_ind = 1, b.active_status_cd = f_cs48_active_status_cd,
     b.active_status_dt_tm = cnvtdatetime(curdate,curtime), b.active_status_prsnl_id = fsystemid, b
     .updt_applctx = 0.0,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = fsystemid,
     b.updt_task = 0.0
    WITH nocounter
   ;end insert
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE adddenialdata(null)
   SELECT INTO "nl:"
    next_seq = seq(pft_bre_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     fdenialid = cnvtreal(next_seq)
    WITH format, counter
   ;end select
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   INSERT  FROM denial d
    SET d.beg_effective_dt_tm = cnvtdatetime(fbegeffectivedttm), d.bill_vrsn_nbr = fbillvrsnnbr, d
     .corsp_activity_id = fcorspactivityid,
     d.denial_id = fdenialid, d.denial_reason_cd = f_cs24730_denial_res_cd, d.denial_txt =
     "Estimated Reimbursement",
     d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.00"), d.journal_bo_reltn_id = 0.0, d
     .denial_code_txt = "ER",
     d.batch_trans_file_id = fbatchtransfileid, d.denial_type_cd = f_cs29904_denial_type_cd, d
     .active_ind = 1,
     d.active_status_cd = f_cs48_active_status_cd, d.active_status_dt_tm = cnvtdatetime(curdate,
      curtime), d.active_status_prsnl_id = fsystemid,
     d.updt_applctx = 0.0, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime),
     d.updt_id = fsystemid, d.updt_task = 0.0
    WITH nocounter
   ;end insert
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE adddenialdetaildata(null)
   INSERT  FROM denial_detail d
    SET d.denial_detail_id = seq(pft_bre_seq,nextval), d.denial_id = fdenialid, d
     .remark_code_attrib_cd = f_cs26913_denial_rrmark_cd,
     d.remark_code_attrib_value = cnvtstring(ftranstotalamount), d.beg_effective_dt_tm = cnvtdatetime
     (fbegeffectivedttm), d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.00"),
     d.active_ind = 1, d.active_status_cd = f_cs48_active_status_cd, d.active_status_dt_tm =
     cnvtdatetime(curdate,curtime),
     d.active_status_prsnl_id = fsystemid, d.updt_applctx = 0.0, d.updt_cnt = 0,
     d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id = fsystemid, d.updt_task = 0.0
    WITH nocounter
   ;end insert
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   INSERT  FROM denial_detail d
    SET d.denial_detail_id = seq(pft_bre_seq,nextval), d.denial_id = fdenialid, d
     .remark_code_attrib_cd = f_cs26913_denial_rrmark_alias_cd,
     d.remark_code_attrib_value = "ER", d.beg_effective_dt_tm = cnvtdatetime(fbegeffectivedttm), d
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.00"),
     d.active_ind = 1, d.active_status_cd = f_cs48_active_status_cd, d.active_status_dt_tm =
     cnvtdatetime(curdate,curtime),
     d.active_status_prsnl_id = fsystemid, d.updt_applctx = 0.0, d.updt_cnt = 0,
     d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id = fsystemid, d.updt_task = 0.0
    WITH nocounter
   ;end insert
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE addbatchdenialfiledata(null)
   SELECT INTO "nl:"
    next_seq = seq(pft_bre_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     fdenialdetailfilerid = cnvtreal(next_seq)
    WITH format, counter
   ;end select
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   INSERT  FROM batch_denial_file_r b
    SET b.batch_denial_file_r_id = fdenialdetailfilerid, b.batch_trans_file_id = fbatchtransfileid, b
     .beg_effective_dt_tm = cnvtdatetime(fbegeffectivedttm),
     b.denial_cd = f_cs24730_denial_res_cd, b.denial_text = "Estimated Reimbursement", b
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.00"),
     b.denial_code_txt = "ER", b.denial_type_cd = 0.0, b.trans_reltn_reason_cd = 0,
     b.active_ind = 1, b.active_status_cd = f_cs48_active_status_cd, b.active_status_dt_tm =
     cnvtdatetime(curdate,curtime),
     b.active_status_prsnl_id = fsystemid, b.updt_applctx = 0.0, b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = fsystemid, b.updt_task = 0
    WITH nocounter
   ;end insert
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE addbatchdenialfiledatadetail(null)
   INSERT  FROM batch_denial_file_detail_r b
    SET b.batch_denial_file_detail_r_id = seq(pft_bre_seq,nextval), b.batch_denial_file_r_id =
     fdenialdetailfilerid, b.remark_code_attrib_cd = f_cs26913_denial_rrmark_cd,
     b.remark_code_attrib_value = cnvtstring(ftranstotalamount), b.beg_effective_dt_tm = cnvtdatetime
     (fbegeffectivedttm), b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.00"),
     b.active_ind = 1, b.active_status_cd = f_cs48_active_status_cd, b.active_status_dt_tm =
     cnvtdatetime(curdate,curtime),
     b.active_status_prsnl_id = fsystemid, b.updt_applctx = 0.0, b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = fsystemid, b.updt_task = 0
    WITH nocounter
   ;end insert
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   INSERT  FROM batch_denial_file_detail_r b
    SET b.batch_denial_file_detail_r_id = seq(pft_bre_seq,nextval), b.batch_denial_file_r_id =
     fdenialdetailfilerid, b.remark_code_attrib_cd = f_cs26913_denial_rrmark_alias_cd,
     b.remark_code_attrib_value = "ER", b.beg_effective_dt_tm = cnvtdatetime(fbegeffectivedttm), b
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.00"),
     b.active_ind = 1, b.active_status_cd = f_cs48_active_status_cd, b.active_status_dt_tm =
     cnvtdatetime(curdate,curtime),
     b.active_status_prsnl_id = fsystemid, b.updt_applctx = 0.0, b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = fsystemid, b.updt_task = 0
    WITH nocounter
   ;end insert
   IF (sbr_handle_cc_error(null)=0)
    GO TO exit_program
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
END GO

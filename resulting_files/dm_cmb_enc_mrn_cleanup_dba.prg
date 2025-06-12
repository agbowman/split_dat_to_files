CREATE PROGRAM dm_cmb_enc_mrn_cleanup:dba
 RECORD request(
   1 parent_table = c50
   1 cmb_mode = c20
   1 error_message = c132
   1 transaction_type = c8
   1 xxx_combine[*]
     2 xxx_combine_id = f8
     2 from_xxx_id = f8
     2 from_mrn = c200
     2 from_alias_pool_cd = f8
     2 from_alias_type_cd = f8
     2 to_xxx_id = f8
     2 to_mrn = c200
     2 to_alias_pool_cd = f8
     2 to_alias_type_cd = f8
     2 encntr_id = f8
     2 application_flag = i2
     2 combine_weight = f8
     2 comment_txt = c250
   1 xxx_combine_det[*]
     2 xxx_combine_det_id = f8
     2 xxx_combine_id = f8
     2 entity_name = c32
     2 entity_id = f8
     2 entity_pk[*]
       3 col_name = c30
       3 data_type = c30
       3 data_char = c100
       3 data_number = f8
       3 data_date = dq8
     2 combine_action_cd = f8
     2 attribute_name = c32
     2 prev_active_ind = i2
     2 prev_active_status_cd = f8
     2 prev_end_eff_dt_tm = dq8
     2 combine_desc_cd = f8
 )
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[10]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 encntr_id = f8
     2 encntr_status_cd = f8
     2 encntr_alias_type_cd = f8
     2 data_status_cd = f8
     2 alias_pool_cd = f8
     2 alias = c200
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 to_rec[*]
     2 to_id = c200
     2 active_ind = dq8
     2 active_status_cd = f8
     2 encntr_id = f8
     2 encntr_alias_type_cd = f8
     2 data_status_cd = f8
     2 alias_pool_cd = f8
     2 alias = c200
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 person_id = f8
   1 pm_hist_tracking_id = f8
 )
 FREE SET rcolumns
 RECORD rcolumns(
   1 col[100]
     2 col_name = c50
 )
 FREE RECORD dcemc_excl
 RECORD dcemc_excl(
   1 excl_cnt = i4
   1 qual[*]
     2 column_name = vc
 )
 DECLARE dcemc_idx = i4 WITH protect, noconstant(0)
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 DECLARE dm_cmb_get_context(dummy=i2) = null
 DECLARE dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) = null
 SUBROUTINE dm_cmb_get_context(dummy)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dm_cmb_exc_maint_status(s_dcems_status,s_dcems_msg,s_dcems_tname)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 DECLARE get_cmb_enc_info(null) = null WITH protect
 IF ((validate(rcmbencinfo->enc_cnt,- (1))=- (1)))
  FREE RECORD rcmbencinfo
  RECORD rcmbencinfo(
    1 enc_cnt = i4
    1 enc[*]
      2 encntr_id = f8
      2 active_ind = i2
      2 encntr_status_cd = f8
  )
 ENDIF
 SUBROUTINE get_cmb_enc_info(null)
   SET rcmbencinfo->enc_cnt = 0
   SELECT
    IF ((request->xxx_combine[icombine].encntr_id=0)
     AND (rev_cmb_request->reverse_ind=1))
     FROM encounter e
     WHERE (e.person_id=request->xxx_combine[icombine].to_xxx_id)
    ELSEIF ((request->xxx_combine[icombine].encntr_id=0))
     FROM encounter e
     WHERE (e.person_id=request->xxx_combine[icombine].from_xxx_id)
    ELSE
     FROM encounter e
     WHERE (e.encntr_id=request->xxx_combine[icombine].encntr_id)
    ENDIF
    INTO "nl:"
    DETAIL
     rcmbencinfo->enc_cnt = (rcmbencinfo->enc_cnt+ 1)
     IF (mod(rcmbencinfo->enc_cnt,10)=1)
      stat = alterlist(rcmbencinfo->enc,(rcmbencinfo->enc_cnt+ 9))
     ENDIF
     rcmbencinfo->enc[rcmbencinfo->enc_cnt].encntr_id = e.encntr_id, rcmbencinfo->enc[rcmbencinfo->
     enc_cnt].active_ind = e.active_ind, rcmbencinfo->enc[rcmbencinfo->enc_cnt].encntr_status_cd = e
     .encntr_status_cd
    FOOT REPORT
     stat = alterlist(rcmbencinfo->enc,rcmbencinfo->enc_cnt)
    WITH nocounter, forupdatewait(e)
   ;end select
   IF (dm_debug_cmb)
    CALL echorecord(rcmbencinfo)
   ENDIF
 END ;Subroutine
 IF ((validate(dcieah_request->encntr_alias_hist_id,- (9))=- (9)))
  RECORD dcieah_request(
    1 encntr_alias_hist_id = f8
    1 pm_hist_tracking_id = f8
    1 encntr_alias_id = f8
    1 encntr_id = f8
    1 alias = c200
  )
 ENDIF
 IF (validate(dcieah_reply->status,"b")="b")
  FREE RECORD dcieah_reply
  RECORD dcieah_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 IF ((validate(dcipht_request->pm_hist_tracking_id,- (9))=- (9)))
  RECORD dcipht_request(
    1 pm_hist_tracking_id = f8
    1 encntr_id = f8
    1 person_id = f8
    1 transaction_type_txt = c3
    1 transaction_reason_txt = c30
  )
 ENDIF
 IF (validate(dcipht_reply->status,"b")="b")
  RECORD dcipht_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 DECLARE dcemc_from_enc_alias_id = f8
 DECLARE dcemc_to_person_alias_id = f8
 DECLARE dcemc_pc_id = f8
 DECLARE dcemc_cleanup_type = c2
 DECLARE dcemc_err_file = vc
 DECLARE icombinedet = i4
 DECLARE mrn_change_ind = i4
 SET icombinedet = 0
 SET dcemc_from_enc_alias_id =  $1
 SET dcemc_to_person_alias_id =  $2
 SET dcemc_pc_id =  $3
 SET dcemc_cleanup_type = cnvtupper( $4)
 SET dcemc_err_file =  $5
 SET mrn_change_ind =  $6
 IF ( NOT (dcemc_cleanup_type IN ("PC", "EM")))
  CALL write_log(concat("cleanup_type ",dcemc_cleanup_type," is not valide"),dcemc_err_file)
  GO TO exit_program
 ENDIF
 DECLARE pcea_alias_cnt = i4
 DECLARE to_mrn_cnt = i4
 DECLARE ap_inact_ind = i2
 DECLARE pcea_alias_flag = i2
 DECLARE encntr_alias_hist_ind = i2
 DECLARE ea_hist_cnt = i4
 DECLARE ap_not_found = f8
 DECLARE del = f8
 DECLARE upt = f8
 DECLARE add = f8
 DECLARE eff = f8
 SET encntr_alias_hist_ind = 0
 SET to_mrn_cnt = 0
 SET ap_inact_ind = 0
 SET pcea_alias_flag = 0
 FREE RECORD pcea_alias_pool
 RECORD pcea_alias_pool(
   1 from_person_id = i4
   1 to_person_id = i4
   1 list[*]
     2 alias_pool_cd = i4
     2 cmb_inactive_ind = i2
 )
 FREE RECORD ea_hist
 RECORD ea_hist(
   1 list[*]
     2 ea_hist_id = f8
 )
 SET count1 = 0
 SET cmb_dummy = 0
 SET loopcount = 1
 CALL echo("end ")
 DECLARE encntr_mrn_cd = f8 WITH noconstant(0.0)
 DECLARE person_mrn_cd = f8 WITH noconstant(0.0)
 DECLARE combine_hist_cd = f8 WITH noconstant(0.0)
 DECLARE encntrmrncmb_cd = f8 WITH noconstant(0.0)
 DECLARE active_cd = f8 WITH noconstant(0.0)
 DECLARE rpt_debug = i2
 SET rpt_debug = 0
 IF (validate(dm_debug,- (1))=1)
  SET rpt_debug = 1
 ENDIF
 CALL echo(build("rpt_debug = ",rpt_debug))
 SET col_count = 0
 SELECT INTO "nl:"
  FROM dtable dt
  WHERE dt.table_name="ENCNTR_ALIAS_HIST"
  DETAIL
   encntr_alias_hist_ind = 1
  WITH nocounter
 ;end select
 SET del = 0.0
 SET stat = uar_get_meaning_by_codeset(327,"DEL",1,del)
 IF (del=0.0)
  SET dm_err->err_ind = 1
  CALL write_log("No active, effective code_value exists for cdf_meaning 'DEL' for code_set 327",
   dcemc_err_file)
  GO TO exit_sub
 ENDIF
 SET upt = 0.0
 SET stat = uar_get_meaning_by_codeset(327,"UPT",1,upt)
 IF (upt=0)
  SET dm_err->err_ind = 1
  CALL write_log("No active, effective code_value exists for cdf_meaning 'UPT' for code_set 327",
   dcemc_err_file)
  GO TO exit_sub
 ENDIF
 SET add = 0.0
 SET stat = uar_get_meaning_by_codeset(327,"ADD",1,add)
 IF (add=0)
  SET dm_err->err_ind = 1
  CALL write_log("No active, effective code_value exists for cdf_meaning 'ADD' for code_set 327",
   dcemc_err_file)
  GO TO exit_sub
 ENDIF
 SET eff = 0.0
 SET stat = uar_get_meaning_by_codeset(327,"EFF",1,eff)
 IF (eff=0)
  SET dm_err->err_ind = 1
  CALL write_log("No active, effective code_value exists for cdf_meaning 'EFF' for code_set 327",
   dcemc_err_file)
  GO TO exit_sub
 ENDIF
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,encntr_mrn_cd)
 IF (encntr_mrn_cd=0.0)
  CALL write_log("No active, effective code_value with code_set=319, cdf_meaning='MRN'",
   dcemc_err_file)
  SET dm_err->err_ind = 1
  GO TO exit_sub
 ENDIF
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,person_mrn_cd)
 IF (person_mrn_cd=0.0)
  CALL write_log("No active, effective code_value with code_set=4, cdf_meaning='MRN'",dcemc_err_file)
  SET dm_err->err_ind = 1
  GO TO exit_sub
 ENDIF
 SET stat = uar_get_meaning_by_codeset(261,"ACTIVE",1,active_cd)
 IF (active_cd=0.0)
  CALL write_log("No active, effective code_value with code_set=261, cdf_meaning='ACTIVE'",
   dcemc_err_file)
  SET dm_err->err_ind = 1
  GO TO exit_sub
 ENDIF
 SET stat = uar_get_meaning_by_codeset(48,"COMBINEHIST",1,combine_hist_cd)
 IF (combine_hist_cd=0.0)
  CALL write_log("No active, effective code_value with code_set=48, cdf_meaning='COMBINEHIST'",
   dcemc_err_file)
  SET dm_err->err_ind = 1
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  frm.alias
  FROM encntr_alias frm
  WHERE frm.encntr_alias_id=dcemc_from_enc_alias_id
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(rreclist->from_rec,(count1+ 9))
   ENDIF
   rreclist->from_rec[count1].from_id = frm.encntr_alias_id, rreclist->from_rec[count1].active_ind =
   frm.active_ind, rreclist->from_rec[count1].active_status_cd = frm.active_status_cd,
   rreclist->from_rec[count1].encntr_alias_type_cd = frm.encntr_alias_type_cd, rreclist->from_rec[
   count1].data_status_cd = frm.data_status_cd, rreclist->from_rec[count1].alias_pool_cd = frm
   .alias_pool_cd,
   rreclist->from_rec[count1].alias = frm.alias, rreclist->from_rec[count1].beg_effective_dt_tm = frm
   .beg_effective_dt_tm, rreclist->from_rec[count1].end_effective_dt_tm = frm.end_effective_dt_tm,
   rreclist->from_rec[count1].encntr_id = frm.encntr_id
  FOOT REPORT
   stat = alter(rreclist->from_rec,count1)
  WITH nocounter, forupdatewait(frm)
 ;end select
 IF (count1=0)
  SET dm_err->err_ind = 0
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  tu.person_alias_id
  FROM person_alias tu
  WHERE tu.person_alias_id=dcemc_to_person_alias_id
  DETAIL
   to_mrn_cnt = (to_mrn_cnt+ 1), stat = alterlist(rreclist->to_rec,to_mrn_cnt), rreclist->to_rec[
   to_mrn_cnt].alias = tu.alias,
   rreclist->to_rec[to_mrn_cnt].updt_dt_tm = tu.updt_dt_tm, rreclist->to_rec[to_mrn_cnt].
   alias_pool_cd = tu.alias_pool_cd, rreclist->to_rec[to_mrn_cnt].person_id = tu.person_id
  WITH nocounter
 ;end select
 IF (dcemc_cleanup_type="EM")
  FOR (loopcount = 1 TO count1)
   CALL del_from2(cmb_dummy)
   CALL add_to(1)
  ENDFOR
 ELSEIF (dcemc_cleanup_type="PC")
  FOR (loopcount = 1 TO count1)
   IF (((mrn_change_ind=1) OR (mrn_change_ind=2)) )
    CALL del_from2(cmb_dummy)
   ELSEIF (((mrn_change_ind=3) OR (mrn_change_ind=4)) )
    CALL end_effective_from(cmb_dummy)
   ENDIF
   CALL add_to(1)
  ENDFOR
 ENDIF
 INSERT  FROM person_combine_det cdt,
   (dummyt d  WITH seq = size(request->xxx_combine_det,5))
  SET cdt.attribute_name = request->xxx_combine_det[d.seq].attribute_name, cdt.combine_action_cd =
   request->xxx_combine_det[d.seq].combine_action_cd, cdt.person_combine_id = dcemc_pc_id,
   cdt.entity_id = request->xxx_combine_det[d.seq].entity_id, cdt.entity_name = request->
   xxx_combine_det[d.seq].entity_name, cdt.person_combine_det_id = seq(person_combine_seq,nextval),
   cdt.updt_cnt = 0, cdt.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdt.updt_id = reqinfo->updt_id,
   cdt.updt_task = reqinfo->updt_task, cdt.updt_applctx = reqinfo->updt_applctx, cdt.active_ind = 1,
   cdt.active_status_cd = reqdata->active_status_cd, cdt.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), cdt.active_status_prsnl_id = reqinfo->updt_id,
   cdt.prev_active_ind = request->xxx_combine_det[d.seq].prev_active_ind, cdt.combine_desc_cd =
   request->xxx_combine_det[d.seq].combine_desc_cd, cdt.prev_active_status_cd = request->
   xxx_combine_det[d.seq].prev_active_status_cd,
   cdt.prev_end_eff_dt_tm = cnvtdatetime(request->xxx_combine_det[d.seq].prev_end_eff_dt_tm)
  PLAN (d)
   JOIN (cdt)
  WITH nocounter
 ;end insert
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET dm_err->err_ind = 1
  CALL write_log(emsg,dcemc_err_file)
 ENDIF
#exit_sub
 IF ((dm_err->err_ind > 0))
  ROLLBACK
 ELSE
  IF (rpt_debug=1)
   CALL echo("remember to commit")
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SUBROUTINE del_from2(dummy)
   CALL echo("del_from2")
   UPDATE  FROM encntr_alias frm
    SET frm.active_ind = false, frm.active_status_cd = combine_hist_cd, frm.updt_cnt = (frm.updt_cnt
     + 1),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task,
     frm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (frm.encntr_alias_id=rreclist->from_rec[loopcount].from_id)
    WITH nocounter
   ;end update
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[loopcount].from_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_ALIAS"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[loopcount].
   active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[loopcount].
   active_status_cd
   IF (curqual=0)
    SET dm_err->err_ind = 1
    CALL write_log(build("Couldn't inactivate encntr_alias record with encntr_alias_id=",rreclist->
      from_rec[loopcount].from_id),dcemc_err_file)
    GO TO exit_sub
   ENDIF
   IF (dcemc_cleanup_type="EM")
    IF (encntr_alias_hist_ind=1)
     SET ea_hist_cnt = 0
     SELECT INTO "nl:"
      FROM encntr_alias_hist p
      WHERE (p.encntr_alias_id=rreclist->from_rec[loopcount].from_id)
       AND p.active_ind=1
      DETAIL
       ea_hist_cnt = (ea_hist_cnt+ 1)
       IF (mod(ea_hist_cnt,100)=1)
        stat = alterlist(ea_hist->list,(ea_hist_cnt+ 99))
       ENDIF
       ea_hist->list[ea_hist_cnt].ea_hist_id = p.encntr_alias_hist_id
      FOOT REPORT
       stat = alterlist(ea_hist->list,ea_hist_cnt)
      WITH nocounter, forupdatewait(p)
     ;end select
     FOR (ealp_cnt = 1 TO ea_hist_cnt)
       CALL del_ea_hist(ea_hist->list[ealp_cnt].ea_hist_id)
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE del_ea_hist(sbr_deh_hist_id)
   CALL echo("del_ea_hist")
   UPDATE  FROM encntr_alias_hist p
    SET p.active_ind = 0, p.active_status_cd = combine_hist_cd, p.updt_applctx = reqinfo->
     updt_applctx,
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     p.updt_cnt = (p.updt_cnt+ 1)
    WHERE p.encntr_alias_hist_id=sbr_deh_hist_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET dm_err->err_ind = 1
    CALL write_log(build("Couldn't inactivate encntr_alias_hist record with encntr_alias_hist_id=",
      deh_hist_id),dcemc_err_file)
    GO TO exit_sub
   ENDIF
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = sbr_deh_hist_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_ALIAS_HIST"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[loopcount].
   active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[loopcount].
   active_status_cd
 END ;Subroutine
 SUBROUTINE end_effective_from(dummy)
   CALL echo("end_effective_from")
   UPDATE  FROM encntr_alias frm
    SET frm.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (frm.encntr_alias_id=rreclist->from_rec[loopcount].from_id)
    WITH nocounter
   ;end update
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = eff
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[loopcount].from_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_ALIAS"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = rreclist->from_rec[loopcount].
   end_effective_dt_tm
   IF (curqual=0)
    SET dm_err->err_ind = 1
    CALL write_log(buildt("Couldn't end effective encntr_alias record with encntr_alias_id=",rreclist
      ->from_rec[loopcount].from_id),dcemc_err_file)
    GO TO exit_sub
   ENDIF
 END ;Subroutine
 SUBROUTINE add_to(sbr_to_idx)
   CALL echo(" add_to")
   DECLARE encntr_alias_hist_row = i2
   SET encntr_alias_hist_row = 0
   IF (col_count=0)
    SELECT INTO "nl:"
     FROM user_tab_cols utc
     WHERE utc.table_name="ENCNTR_ALIAS"
      AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name=
     "LAST_UTC_TS")) ))
     HEAD REPORT
      dcemc_excl->excl_cnt = 0, stat = alterlist(dcemc_excl->qual,0)
     DETAIL
      dcemc_excl->excl_cnt = (dcemc_excl->excl_cnt+ 1), stat = alterlist(dcemc_excl->qual,dcemc_excl
       ->excl_cnt), dcemc_excl->qual[dcemc_excl->excl_cnt].column_name = utc.column_name
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     l.attr_name
     FROM dtable t,
      dtableattr a,
      dtableattrl l
     WHERE t.table_name="ENCNTR_ALIAS"
      AND t.table_name=a.table_name
      AND l.structtype="F"
      AND btest(l.stat,11)=0
      AND  NOT (l.attr_name IN ("UPDT_CNT", "UPDT_DT_TM", "UPDT_ID", "UPDT_APPLCTX", "UPDT_TASK",
     "ACTIVE_IND", "ACTIVE_STATUS_CD", "ACTIVE_STATUS_DT_TM", "ACTIVE_STATUS_PRSNL_ID",
     "ENCNTR_ALIAS_ID",
     "ALIAS", "ALIAS_POOL_CD", "END_EFFECTIVE_DT_TM"))
      AND  NOT (expand(dcemc_idx,1,dcemc_excl->excl_cnt,l.attr_name,dcemc_excl->qual[dcemc_idx].
      column_name))
     DETAIL
      col_count = (col_count+ 1)
      IF (mod(col_count,100)=1)
       stat = alter(rcolumns->col,(col_count+ 99))
      ENDIF
      rcolumns->col[col_count].col_name = l.attr_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET dm_err->err_ind = 1
     CALL write_log("Fields on encntr_alias table not selected when trying to add a new record.",
      dcemc_err_file)
     GO TO exit_sub
    ENDIF
    IF (encntr_alias_hist_ind=1)
     SELECT INTO "nl:"
      FROM encntr_alias_hist eah
      WHERE (eah.encntr_id=rreclist->from_rec[loopcount].encntr_id)
       AND (eah.alias=rreclist->to_rec[sbr_to_idx].alias)
       AND eah.active_ind=1
      DETAIL
       encntr_alias_hist_row = 1
      WITH nocounter
     ;end select
     IF (encntr_alias_hist_row=0)
      IF ((rreclist->pm_hist_tracking_id=0))
       SELECT INTO "nl:"
        y = seq(person_seq,nextval)
        FROM dual
        DETAIL
         rreclist->pm_hist_tracking_id = cnvtreal(y)
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET dm_err->err_ind = 1
        CALL write_log(
         "Couldn't get next sequence value from person_seq when adding new encntr_alias_hist record",
         dcemc_err_file)
        GO TO exit_sub
       ENDIF
       SET dcipht_request->pm_hist_tracking_id = rreclist->pm_hist_tracking_id
       SET dcipht_request->person_id = rreclist->to_rec[sbr_to_idx].person_id
       SET dcipht_request->encntr_id = 0.0
       SET dcipht_request->transaction_reason_txt = "DM_CMB_ENC_MRN_CLEANUP"
       SET dcipht_request->transaction_type_txt = "CMB"
       EXECUTE dm_cmb_ins_pm_hist_tracking
       IF ((dcipht_reply->status="F"))
        SET dm_err->err_ind = 1
        CALL write_log(dcipht_reply->err_msg,dcemc_err_file)
        GO TO exit_sub
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET new_encntr_alias_id = 0.0
   SELECT INTO "nl:"
    y = seq(encounter_seq,nextval)
    FROM dual
    DETAIL
     new_encntr_alias_id = cnvtreal(y)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dm_err->err_ind = 1
    CALL write_log(
     "Couldn't get next sequence value from encounter_seq when adding new encntr_alias record",
     dcemc_err_file)
    GO TO exit_sub
   ENDIF
   CALL parser("insert into encntr_alias (")
   FOR (x = 1 TO col_count)
     CALL parser(concat(trim(rcolumns->col[x].col_name),", "))
   ENDFOR
   CALL parser("updt_cnt, updt_dt_tm, updt_id, updt_applctx, updt_task, ")
   CALL parser("active_ind, active_status_cd, active_status_dt_tm, active_status_prsnl_id, ")
   CALL parser("encntr_alias_id, alias, alias_pool_cd, end_effective_dt_tm)")
   CALL parser("(select ")
   FOR (x = 1 TO col_count)
     CALL parser(concat("FRM.",trim(rcolumns->col[x].col_name),", "))
   ENDFOR
   CALL parser("0, ")
   CALL parser("cnvtdatetime(curdate, curtime3), ")
   CALL parser("reqinfo->updt_id, ")
   CALL parser("reqinfo->updt_applctx, ")
   CALL parser("reqinfo->updt_task, ")
   CALL parser("1, ")
   CALL parser("reqdata->active_status_cd, ")
   CALL parser("cnvtdatetime(curdate, curtime3), ")
   CALL parser("reqinfo->updt_id, ")
   CALL parser("NEW_ENCNTR_ALIAS_ID, ")
   CALL parser("rRecList->to_rec[sbr_to_idx]->alias,")
   CALL parser("rRecList->from_rec[loopcount]->alias_pool_cd,")
   CALL parser("cnvtdatetime(rRecList->from_rec[loopcount]->end_effective_dt_tm)")
   CALL parser("from encntr_alias FRM")
   CALL parser(build("where FRM.encntr_alias_id = ",rreclist->from_rec[loopcount].from_id,")"))
   CALL parser("go")
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = add
   SET request->xxx_combine_det[icombinedet].entity_id = new_encntr_alias_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_ALIAS"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   IF (curqual=0)
    SET dm_err->err_ind = 1
    CALL write_log("Couldn't insert new encntr_alias record",dcemc_err_file)
    GO TO exit_sub
   ENDIF
   IF (encntr_alias_hist_ind=1
    AND encntr_alias_hist_row=0)
    SET dcieah_request->encntr_alias_hist_id = 0.0
    SELECT INTO "nl:"
     y = seq(encounter_seq,nextval)
     FROM dual
     DETAIL
      dcieah_request->encntr_alias_hist_id = cnvtreal(y)
     WITH nocounter
    ;end select
    SET dcieah_request->pm_hist_tracking_id = rreclist->pm_hist_tracking_id
    SET dcieah_request->encntr_alias_id = new_encntr_alias_id
    SET dcieah_request->encntr_id = rreclist->from_rec[loopcount].encntr_id
    SET dcieah_request->alias = rreclist->to_rec[sbr_to_idx].alias
    EXECUTE dm_cmb_ins_encntr_alias_hist
    IF ((dcieah_reply->status="F"))
     SET dm_err->err_ind = 1
     CALL write_log(dcieah_reply->err_msg,dcemc_err_file)
     GO TO exit_sub
    ENDIF
    SET icombinedet = (icombinedet+ 1)
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].combine_action_cd = add
    SET request->xxx_combine_det[icombinedet].entity_id = dcieah_request->encntr_alias_hist_id
    SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_ALIAS_HIST"
   ENDIF
 END ;Subroutine
 SUBROUTINE write_log(wl_text,wl_logfile)
  CALL echo(wl_text)
  SELECT INTO value(wl_logfile)
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    row + 1, curdate"mm/dd/yyyy;;d", " ",
    curtime3"hh:mm:ss;3;m", " ", curprog,
    row + 1, "FROM PERSON_ID:    ", dcemc_from_enc_alias_id,
    row + 1, "TO ENCNTR_ALIAS_ID:", dcemc_to_person_alias_id,
    row + 1, "PERSON_COMBINE_ID: ", dcemc_pc_id,
    row + 1, "CLEANUP_TYPE:      ", dcemc_cleanup_type
    IF (dcemc_cleanup_type="PC")
     row + 1, "MRN_CHANGE_IND:    ", mrn_change_ind
    ENDIF
    row + 1, wl_text, row + 1
   WITH nocounter, format = variable, formfeed = none,
    maxrow = 1, maxcol = 200, append
  ;end select
 END ;Subroutine
 FREE SET rreclist
END GO

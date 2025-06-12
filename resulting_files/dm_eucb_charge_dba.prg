CREATE PROGRAM dm_eucb_charge:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
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
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 IF ((validate(dcgea_request->alias_type_cd,- (1))=- (1)))
  RECORD dcgea_request(
    1 alias_type_cd = f8
    1 alias_dt_tm = dq8
    1 encntr_id = f8
  )
 ENDIF
 IF ((validate(dcgea_reply->encntr_alias_id,- (1))=- (1)))
  RECORD dcgea_reply(
    1 encntr_alias_id = f8
    1 alias = vc
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 DECLARE ucbsuberrmsg = vc WITH protect, noconstant(" ")
 IF ( NOT (validate(debit_off_desc_cd)))
  DECLARE debit_off_desc_cd = f8 WITH public, noconstant(0.0)
  SET stat = uar_get_meaning_by_codeset(14200,nullterm("OFFSETDEBIT"),1,debit_off_desc_cd)
 ENDIF
 IF ( NOT (validate(credit_off_desc_cd)))
  DECLARE credit_off_desc_cd = f8 WITH public, noconstant(0.0)
  SET stat = uar_get_meaning_by_codeset(14200,nullterm("OFFSETCREDIT"),1,credit_off_desc_cd)
 ENDIF
 IF ( NOT (validate(327_eff_cd)))
  DECLARE 327_eff_cd = f8 WITH public, noconstant(0.0)
  SET stat = uar_get_meaning_by_codeset(327,nullterm("EFF"),1,327_eff_cd)
 ENDIF
 IF ( NOT (validate(327_del_cd)))
  DECLARE 327_del_cd = f8 WITH public, noconstant(0.0)
  SET stat = uar_get_meaning_by_codeset(327,nullterm("DEL"),1,327_del_cd)
 ENDIF
 SUBROUTINE (credit_charge(sbr_cc_cii=f8,sbr_cc_type=i4,sbr_loopcount=i4,sbr_cc_process_type=c2) =
  null)
   DECLARE cc_new_nbr = f8
   DECLARE cc_col_count = i4
   SET cc_new_nbr = 0.0
   SET cc_col_count = size(rcolumns->col,5)
   SELECT INTO "nl:"
    y = seq(charge_event_seq,nextval)
    FROM dual
    DETAIL
     cc_new_nbr = y
    WITH format, nocounter
   ;end select
   CALL error_logger(curqual,"Couldn't get the next sequence number",gen_nbr_error)
   CALL parser("insert into charge (")
   FOR (x = 1 TO cc_col_count)
     IF (x=cc_col_count)
      CALL parser(concat(trim(rcolumns->col[x].col_name),")"))
     ELSE
      CALL parser(concat(trim(rcolumns->col[x].col_name),","))
     ENDIF
   ENDFOR
   CALL parser("(select ")
   FOR (x = 1 TO cc_col_count)
    IF (x=cc_col_count)
     SET v_comma_str = " "
    ELSE
     SET v_comma_str = ","
    ENDIF
    CASE (trim(rcolumns->col[x].col_name))
     OF "CHARGE_ITEM_ID":
      CALL parser(build("cc_new_nbr",v_comma_str))
     OF "PARENT_CHARGE_ITEM_ID":
      CALL parser(build("sbr_cc_cii",v_comma_str))
     OF "COMBINE_IND":
      CALL parser(build("1",v_comma_str))
     OF "PROCESS_FLG":
      CALL parser(build("sbr_cc_type",v_comma_str))
     OF "POSTED_CD":
      CALL parser(build("0",v_comma_str))
     OF "POSTED_DT_TM":
      CALL parser(build("NULL",v_comma_str))
     OF "CREDITED_DT_TM":
      CALL parser(build("cnvtdatetime(curdate, curtime)",v_comma_str))
     OF "ITEM_PRICE":
      CALL parser(build("(rRecList->from_rec[sbr_loopcount]->item_price * -1)",v_comma_str))
     OF "ITEM_EXTENDED_PRICE":
      CALL parser(build("(rRecList->from_rec[sbr_loopcount]->item_extended_price * -1)",v_comma_str))
     OF "CHARGE_TYPE_CD":
      IF ((rreclist->from_rec[sbr_loopcount].charge_type_cd=credit_cd))
       CALL parser(build("DEBIT_CD",v_comma_str))
      ELSE
       CALL parser(build("CREDIT_CD",v_comma_str))
      ENDIF
     OF "ACTIVE_IND":
      CALL parser(build("1",v_comma_str))
     OF "ACTIVE_STATUS_CD":
      CALL parser(build("active_code",v_comma_str))
     OF "ACTIVE_STATUS_PRSNL_ID":
      CALL parser(build("ReqInfo->updt_id",v_comma_str))
     OF "ACTIVE_STATUS_DT_TM":
      CALL parser(build("cnvtdatetime(curdate, curtime)",v_comma_str))
     OF "UPDT_CNT":
      CALL parser(build("0",v_comma_str))
     OF "UPDT_DT_TM":
      CALL parser(build("cnvtdatetime(curdate, curtime)",v_comma_str))
     OF "UPDT_ID":
      CALL parser(build("ReqInfo->updt_id",v_comma_str))
     OF "UPDT_APPLCTX":
      CALL parser(build("ReqInfo->updt_applctx",v_comma_str))
     OF "UPDT_TASK":
      CALL parser(build("ReqInfo->updt_task",v_comma_str))
     OF "OFFSET_CHARGE_ITEM_ID":
      CALL parser(build("sbr_cc_cii",v_comma_str))
     OF "POSTED_ID":
      CALL parser(build("ReqInfo->updt_id",v_comma_str))
     ELSE
      CALL parser(build("FRM.",trim(rcolumns->col[x].col_name),v_comma_str))
    ENDCASE
   ENDFOR
   CALL parser("from charge FRM")
   CALL parser(build("where FRM.charge_item_id = ",rreclist->from_rec[sbr_loopcount].from_id,")"))
   CALL parser("with nocounter go")
   IF (error(ucbsuberrmsg,0) != 0)
    CALL error_logger(0,"Couldn't insert charge on the from person",insert_error)
   ENDIF
   IF (sbr_cc_process_type="*C")
    SET icombinedet += 1
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].combine_action_cd = add
    SET request->xxx_combine_det[icombinedet].entity_id = cc_new_nbr
    SET request->xxx_combine_det[icombinedet].entity_name = "CHARGE"
    IF ((rreclist->from_rec[sbr_loopcount].charge_type_cd=credit_cd))
     SET request->xxx_combine_det[icombinedet].combine_desc_cd = debit_off_desc_cd
    ELSE
     SET request->xxx_combine_det[icombinedet].combine_desc_cd = credit_off_desc_cd
    ENDIF
    IF (sbr_cc_process_type="PC")
     SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
    ELSE
     SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
    ENDIF
   ENDIF
   CALL copy_charge_mod(rreclist->from_rec[sbr_loopcount].from_id,cc_new_nbr,sbr_cc_process_type)
   SET tmp_offset_charge_item_id = cc_new_nbr
   IF (sbr_cc_process_type IN ("EC", "EU"))
    SET igl_idx = 0
    SET iindex = 0
    SET igl_idx = locateval(iindex,1,size(upt_charge_struct->objarray,5),rreclist->from_rec[
     sbr_loopcount].from_id,upt_charge_struct->objarray[iindex].charge_item_id)
    IF (igl_idx > 0)
     SET upt_charge_struct->objarray[igl_idx].tmp_offset_charge_item_id = cc_new_nbr
    ENDIF
    SET igl_idx = 0
    SET iindex = 0
    SET igl_idx = locateval(iindex,1,size(credit_charge_struct->objarray,5),rreclist->from_rec[
     sbr_loopcount].from_id,credit_charge_struct->objarray[iindex].charge_item_id)
    IF (igl_idx > 0)
     SET credit_charge_struct->objarray[igl_idx].new_chargeitemid = cc_new_nbr
    ENDIF
   ENDIF
   SET dcgea_request->alias_type_cd = 319_mrn
   SET dcgea_request->alias_dt_tm = rreclist->from_rec[sbr_loopcount].beg_effective_dt_tm
   SET dcgea_request->encntr_id = rreclist->from_rec[sbr_loopcount].encntr_id
   EXECUTE dm_cmb_get_enc_alias
   IF ((dcgea_reply->status="F"))
    SET failed = select_error
    SET ucb_failed = select_error
    SET request->error_message = dcgea_reply->err_msg
    GO TO end_of_program
   ENDIF
   IF ((dcgea_reply->encntr_alias_id > 0))
    CALL insert_fin_mrn_charge_mod(cc_new_nbr,dcgea_reply->alias,13019_mrn_alias,sbr_cc_process_type)
   ELSEIF (sbr_cc_process_type="EC")
    DECLARE frommrnalias = vc WITH noconstant("")
    SELECT INTO "nl:"
     FROM encntr_combine ec,
      encntr_combine_det ecd,
      encntr_alias ea
     PLAN (ec
      WHERE (ec.from_encntr_id=rreclist->from_rec[sbr_loopcount].encntr_id)
       AND ec.active_ind=1)
      JOIN (ecd
      WHERE ecd.encntr_combine_id=ec.encntr_combine_id
       AND ecd.active_ind=1
       AND ecd.entity_name="ENCNTR_ALIAS"
       AND ecd.combine_action_cd=327_del_cd
       AND ecd.prev_active_ind=1)
      JOIN (ea
      WHERE ea.encntr_alias_id=ecd.entity_id
       AND ea.encntr_alias_type_cd=319_mrn
       AND ea.active_ind=0)
     DETAIL
      frommrnalias = ea.alias
     WITH nocounter
    ;end select
    IF (curqual > 0
     AND frommrnalias != ""
     AND frommrnalias != null)
     CALL insert_fin_mrn_charge_mod(cc_new_nbr,frommrnalias,13019_mrn_alias,sbr_cc_process_type)
    ENDIF
   ENDIF
   SET dcgea_request->alias_type_cd = 319_fin_nbr
   EXECUTE dm_cmb_get_enc_alias
   IF ((dcgea_reply->status="F"))
    SET failed = select_error
    SET ucb_failed = select_error
    SET request->error_message = dcgea_reply->err_msg
    GO TO end_of_program
   ENDIF
   IF ((dcgea_reply->encntr_alias_id > 0))
    CALL insert_fin_mrn_charge_mod(cc_new_nbr,dcgea_reply->alias,13019_finnbr_alias,
     sbr_cc_process_type)
   ELSEIF (sbr_cc_process_type="EC")
    DECLARE fromfinalias = vc WITH noconstant("")
    SELECT INTO "nl:"
     FROM encntr_combine ec,
      encntr_combine_det ecd,
      encntr_alias ea
     PLAN (ec
      WHERE (ec.from_encntr_id=rreclist->from_rec[sbr_loopcount].encntr_id)
       AND ec.active_ind=1)
      JOIN (ecd
      WHERE ecd.encntr_combine_id=ec.encntr_combine_id
       AND ecd.active_ind=1
       AND ecd.entity_name="ENCNTR_ALIAS"
       AND ecd.combine_action_cd=327_eff_cd
       AND ecd.prev_end_eff_dt_tm != null)
      JOIN (ea
      WHERE ea.encntr_alias_id=ecd.entity_id
       AND ea.encntr_alias_type_cd=319_fin_nbr
       AND ea.active_ind=1)
     DETAIL
      fromfinalias = ea.alias
     WITH nocounter
    ;end select
    IF (curqual > 0
     AND fromfinalias != ""
     AND fromfinalias != null)
     CALL insert_fin_mrn_charge_mod(cc_new_nbr,fromfinalias,13019_finnbr_alias,sbr_cc_process_type)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (insert_fin_mrn_charge_mod(sbr_ifcm_dnbr=f8,sbr_ifcm_alias=vc,sbr_ifcm_alinbr=f8,
  sbr_ifcm_process_type=c2) =null)
   DECLARE sbr_new_nbric = f8
   SET sbr_new_nbric = 0.0
   SELECT INTO "nl:"
    y = seq(charge_event_seq,nextval)
    FROM dual
    DETAIL
     sbr_new_nbric = y
    WITH format, nocounter
   ;end select
   CALL error_logger(curqual,"Couldn't get the next sequence number",gen_nbr_error)
   INSERT  FROM charge_mod c
    SET c.charge_mod_id = sbr_new_nbric, c.charge_item_id = sbr_ifcm_dnbr, c.charge_mod_type_cd =
     14002_combine,
     c.field6 = sbr_ifcm_alias, c.field1_id = sbr_ifcm_alinbr, c.active_ind = 1,
     c.active_status_cd = reqdata->active_status_cd, c.active_status_prsnl_id = reqinfo->updt_id, c
     .active_status_dt_tm = cnvtdatetime(sysdate),
     c.beg_effective_dt_tm = cnvtdatetime(sysdate), c.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), c.updt_cnt = 0,
     c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id, c.updt_applctx =
     reqinfo->updt_applctx,
     c.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (error(ucbsuberrmsg,0) != 0)
    CALL error_logger(0,"Couldn't insert charge_mod record-insert_fin_mrn_charge_mod",insert_error)
   ENDIF
   IF (sbr_ifcm_process_type="*C")
    SET icombinedet += 1
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].combine_action_cd = add
    SET request->xxx_combine_det[icombinedet].entity_id = sbr_new_nbric
    SET request->xxx_combine_det[icombinedet].entity_name = "CHARGE_MOD"
    IF (sbr_ifcm_process_type="PC")
     SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
    ELSE
     SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (copy_charge_mod(sbr_ccm_ciicc=f8,sbr_ccm_innbr=f8,sbr_ccm_process_type=c2) =null)
   DECLARE countcm = i4
   DECLARE ccm_new_nbrc = f8
   DECLARE ccm_mod_count = i4
   FREE RECORD holdreq
   RECORD holdreq(
     1 cm[*]
       2 charge_mod_id = f8
   )
   SET countcm = 0
   SET ccm_mod_count = size(modcolumns->col,5)
   SELECT INTO "nl:"
    c.charge_mod_id
    FROM charge_mod c
    WHERE c.charge_item_id=sbr_ccm_ciicc
     AND  NOT (c.field1_id IN (13019_mrn_alias, 13019_finnbr_alias))
    DETAIL
     countcm += 1, stat = alterlist(holdreq->cm,countcm), holdreq->cm[countcm].charge_mod_id = c
     .charge_mod_id
    WITH nocounter
   ;end select
   FOR (i = 1 TO countcm)
     SET ccm_new_nbrc = 0.0
     SELECT INTO "nl:"
      y = seq(charge_event_seq,nextval)
      FROM dual
      DETAIL
       ccm_new_nbrc = y
      WITH format, nocounter
     ;end select
     CALL error_logger(curqual,"Couldn't get the next sequence number",gen_nbr_error)
     CALL parser("insert into charge_mod (")
     FOR (x = 1 TO ccm_mod_count)
       IF (x=ccm_mod_count)
        CALL parser(concat(trim(modcolumns->col[x].col_name),")"))
       ELSE
        CALL parser(concat(trim(modcolumns->col[x].col_name),","))
       ENDIF
     ENDFOR
     CALL parser(" (select ")
     FOR (x = 1 TO ccm_mod_count)
      IF (x=ccm_mod_count)
       SET v_comma_str = " "
      ELSE
       SET v_comma_str = ","
      ENDIF
      CASE (trim(modcolumns->col[x].col_name))
       OF "CHARGE_MOD_ID":
        CALL parser(build("ccm_new_nbrc",v_comma_str))
       OF "CHARGE_ITEM_ID":
        CALL parser(build("sbr_ccm_inNBR",v_comma_str))
       OF "ACTIVE_IND":
        CALL parser(build("1",v_comma_str))
       OF "ACTIVE_STATUS_CD":
        CALL parser(build("active_code",v_comma_str))
       OF "ACTIVE_STATUS_PRSNL_ID":
        CALL parser(build("ReqInfo->updt_id",v_comma_str))
       OF "ACTIVE_STATUS_DT_TM":
        CALL parser(build("cnvtdatetime(curdate,curtime3)",v_comma_str))
       OF "BEG_EFFECTIVE_DT_TM":
        CALL parser(build("cnvtdatetime(curdate,curtime3)",v_comma_str))
       OF "END_EFFECTIVE_DT_TM":
        CALL parser(build('cnvtdatetime("31-DEC-2100")',v_comma_str))
       OF "UPDT_CNT":
        CALL parser(build("0",v_comma_str))
       OF "UPDT_DT_TM":
        CALL parser(build("cnvtdatetime(curdate, curtime)",v_comma_str))
       OF "UPDT_ID":
        CALL parser(build("ReqInfo->updt_id",v_comma_str))
       OF "UPDT_APPLCTX":
        CALL parser(build("ReqInfo->updt_applctx",v_comma_str))
       OF "UPDT_TASK":
        CALL parser(build("ReqInfo->updt_task",v_comma_str))
       ELSE
        CALL parser(build("C.",trim(modcolumns->col[x].col_name),v_comma_str))
      ENDCASE
     ENDFOR
     CALL parser("from charge_mod C")
     CALL parser(build("where C.charge_mod_id = ",holdreq->cm[i].charge_mod_id,")"))
     CALL parser("with nocounter go")
     CALL error_logger(curqual,"Couldn't insert charge_mod record-copy_charge_mod",insert_error)
     IF (sbr_ccm_process_type="*C")
      SET icombinedet += 1
      SET stat = alterlist(request->xxx_combine_det,icombinedet)
      SET request->xxx_combine_det[icombinedet].combine_action_cd = add
      SET request->xxx_combine_det[icombinedet].entity_id = ccm_new_nbrc
      SET request->xxx_combine_det[icombinedet].entity_name = "CHARGE_MOD"
      IF (sbr_ccm_process_type="PC")
       SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
      ELSE
       SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (error_logger(sbr_qualify=i4,sbr_err_msg=vc,sbr_err_type=i4) =null)
   IF (sbr_qualify=0)
    SET failed = sbr_err_type
    SET ucb_failed = sbr_err_type
    SET request->error_message = sbr_err_msg
    GO TO end_of_program
   ENDIF
 END ;Subroutine
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "CHARGE"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_EUCB_CHARGE"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO end_of_program
 ENDIF
 IF ("Z"=validate(dm_eucb_charge_vrsn,"Z"))
  DECLARE dm_eucb_charge_vrsn = vc WITH noconstant("CHARGSRV-14677.007")
 ENDIF
 SET dm_eucb_charge_vrsn = "CHARGSRV-12188.006"
 CALL echorecord(request,"ccluserdir:encucb.dat")
 CALL echorecord(rchildren,"ccluserdir:childeucb.dat")
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 to_person_id = f8
     2 to_encntr_id = f8
     2 parent_charge_item_id = f8
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 payor_id = f8
     2 ord_loc_cd = f8
     2 perf_loc_cd = f8
     2 ord_phys_id = f8
     2 perf_phys_id = f8
     2 charge_description = c200
     2 price_sched_id = f8
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 item_allowable = f8
     2 item_copay = f8
     2 charge_type_cd = f8
     2 research_acct_id = f8
     2 suspense_rsn_cd = f8
     2 reason_comment = c200
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 activity_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 credited_dt_tm = dq8
     2 adjusted_dt_tm = dq8
     2 def_bill_item_id = f8
     2 tier_group_cd = f8
     2 interface_file_id = f8
     2 verify_phys_id = f8
     2 manual_ind = f8
     2 offset_charge_item_id = f8
     2 activity_type_cd = f8
 )
 FREE RECORD dropchgsyncreq
 RECORD dropchgsyncreq(
   1 to_person_id = f8
   1 to_encntr_id = f8
   1 charge[*]
     2 charge_item_id = f8
   1 primaryhealthplans[*]
     2 health_plan_id = f8
     2 priority_sequence = i4
   1 primaryhealthplancount = f8
   1 health_plan_id = f8
 )
 FREE RECORD insert_struct
 RECORD insert_struct(
   1 objarray[*]
     2 charge_item_id = f8
     2 process_flag = i2
     2 loop_cnt = i4
     2 offset_charge_item_id = f8
     2 new_chargeitemid = f8
 )
 FREE RECORD insert_10_struct
 RECORD insert_10_struct(
   1 objarray[*]
     2 charge_item_id = f8
     2 process_flag = i2
 )
 FREE RECORD credit_charge_struct
 RECORD credit_charge_struct(
   1 objarray[*]
     2 charge_item_id = f8
     2 process_flag = i2
     2 loop_cnt = i4
     2 offset_charge_item_id = f8
     2 new_chargeitemid = f8
 )
 FREE RECORD upt_charge_struct
 RECORD upt_charge_struct(
   1 objarray[*]
     2 charge_item_id = f8
     2 process_flag = i2
     2 tmp_offset_charge_item_id = f8
 )
 FREE RECORD debit_charge_struct
 RECORD debit_charge_struct(
   1 objarray[*]
     2 charge_item_id = f8
     2 new_chargeitemid = f8
     2 offset_charge_item_id = f8
 ) WITH protect
 RECORD eventpersist(
   1 charge[*]
     2 charge_event_id = f8
 ) WITH persistscript
 RECORD dropchgsyncrep(
   1 charges[*]
     2 charge_item_id = f8
     2 charge_type_cd = f8
     2 charge_event_id = f8
     2 tier_group_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD euc_excl
 RECORD euc_excl(
   1 excl_cnt = i4
   1 qual[*]
     2 column_name = vc
 )
 FREE SET rcolumns
 RECORD rcolumns(
   1 col[*]
     2 col_name = c50
 )
 FREE SET modcolumns
 RECORD modcolumns(
   1 col[*]
     2 col_name = c50
 )
 DECLARE credit_cd = f8
 DECLARE debit_cd = f8
 DECLARE active_code = f8
 DECLARE debit_desc_cd = f8
 DECLARE suspense_cd = f8
 DECLARE suspense_reason_cd = f8
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE v_ocii_exists = i2
 DECLARE v_comma_str = c1
 DECLARE synccount = i4 WITH public, noconstant(0)
 DECLARE inschgcnt = i4 WITH public, noconstant(0)
 DECLARE ins10chgcnt = i4 WITH public, noconstant(0)
 DECLARE crdtchgcnt = i4 WITH public, noconstant(0)
 DECLARE uptchgcnt = i4 WITH public, noconstant(0)
 DECLARE debitchgcnt = i4 WITH public, noconstant(0)
 DECLARE tempeventid = f8 WITH noconstant(0.0)
 DECLARE eventexists = i2 WITH noconstant(0)
 DECLARE bcopycharge = i2 WITH public, noconstant(false)
 DECLARE indx = i4 WITH protect, noconstant(0)
 DECLARE ipos = i4 WITH protect, noconstant(0)
 DECLARE ccnt = i4 WITH protect, noconstant(0)
 DECLARE offidx = i4 WITH protect, noconstant(0)
 DECLARE ucberrmsg = vc WITH protect, noconstant(" ")
 DECLARE groupcnt = i4 WITH public, noconstant(0)
 DECLARE mpcnt = i4 WITH public, noconstant(0)
 DECLARE debitparentchargeitemid = f8 WITH protect, noconstant(0.0)
 DECLARE addprimaryhealthplan(null) = null
 SET v_ocii_exists = 0
 SET v_comma_str = " "
 SET suspense_reason_desc = fillstring(60," ")
 SET count1 = 0
 SET col_count = 0
 SET mod_count = 0
 SET loop_cnt = 0
 SET codeset = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,credit_cd)
 CALL echo(build("the credit_cd code value is: ",credit_cd))
 SET codeset = 13028
 SET cdf_meaning = "DR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,debit_cd)
 CALL echo(build("the debit_cd code value is: ",debit_cd))
 SET codeset = 48
 SET cdf_meaning = "ACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,active_code)
 CALL echo(build("the code value is: ",active_code))
 SET codeset = 14200
 SET cdf_meaning = "DEBITCHARGE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,debit_desc_cd)
 CALL echo(build("the debitcharge code is: ",debit_desc_cd))
 SET codeset = 13019
 SET cdf_meaning = "SUSPENSE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,suspense_cd)
 CALL echo(build("the suspense code is: ",suspense_cd))
 SET codeset = 13030
 SET cdf_meaning = "COMBINED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,nullterm(cdf_meaning),cnt,suspense_reason_cd)
 CALL echo(build("the suspense reason code is: ",suspense_reason_cd))
 SET suspense_reason_desc = uar_get_code_description(suspense_reason_cd)
 DECLARE 14002_combine = f8
 SET stat = uar_get_meaning_by_codeset(14002,nullterm("COMBINE"),1,14002_combine)
 CALL echo(build("the combine_cd is : ",14002_combine))
 DECLARE 319_fin_nbr = f8
 SET stat = uar_get_meaning_by_codeset(319,nullterm("FIN NBR"),1,319_fin_nbr)
 CALL echo(build("the combine_cd is : ",319_fin_nbr))
 DECLARE 13019_mrn_alias = f8
 SET stat = uar_get_meaning_by_codeset(13019,nullterm("MRNALIAS"),1,13019_mrn_alias)
 CALL echo(build("the mrn_alias_cd is : ",13019_mrn_alias))
 IF (13019_mrn_alias IN (0.0, null))
  CALL echo("13019_MRN_ALIAS IS NULL")
  SET request->error_message = "13019_MRN_ALIAS IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE 319_mrn = f8
 SET stat = uar_get_meaning_by_codeset(319,nullterm("MRN"),1,319_mrn)
 CALL echo(build("the mrn_cd is : ",319_mrn))
 IF (319_mrn IN (0.0, null))
  CALL echo("319_MRN IS NULL")
  SET request->error_message = "319_MRN IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE 13019_finnbr_alias = f8
 SET 13019_finnbr_alias = 0
 SET stat = uar_get_meaning_by_codeset(13019,nullterm("FINNBRALIAS"),1,13019_finnbr_alias)
 IF (13019_finnbr_alias IN (0.0, null))
  CALL echo("13019_FINNBR_ALIAS IS NULL")
  SET request->error_message = "13019_FINNBR_ALIAS IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE npharmacycd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(106,nullterm("PHARMACY"),1,npharmacycd)
 IF (npharmacycd IN (0.0, null))
  CALL echo("nPharmacyCd IS NULL")
  SET request->error_message = "nPharmacyCd IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE nnochargecd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13028,nullterm("NO CHARGE"),1,nnochargecd)
 IF (nnochargecd IN (0.0, null))
  CALL echo("nNoChargeCd IS NULL")
  SET request->error_message = "nNoChargeCd IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 IF ( NOT (validate(cs106_genericaddon)))
  DECLARE cs106_genericaddon = f8 WITH protect, constant(getcodevalue(106,"AFC ADD GEN",0))
 ENDIF
 IF ( NOT (validate(cs106_specificaddon)))
  DECLARE cs106_specificaddon = f8 WITH protect, constant(getcodevalue(106,"AFC ADD SPEC",0))
 ENDIF
 IF ( NOT (validate(cs106_defaultaddon)))
  DECLARE cs106_defaultaddon = f8 WITH protect, constant(getcodevalue(106,"AFC ADD DEF",0))
 ENDIF
 SET combine_interface_flag = 0
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="COMBINE INTERFACE FLAG"
  DETAIL
   combine_interface_flag = di.info_number
  WITH nocounter
 ;end select
 DECLARE euc_idx = i4 WITH protect, noconstant(0)
 SET stat = alterlist(euc_excl->qual,0)
 SELECT INTO "nl:"
  FROM user_tab_cols utc
  WHERE utc.table_name="CHARGE"
   AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name="LAST_UTC_TS"
  )) ))
  HEAD REPORT
   euc_excl->excl_cnt = 0
  DETAIL
   euc_excl->excl_cnt += 1, stat = alterlist(euc_excl->qual,euc_excl->excl_cnt), euc_excl->qual[
   euc_excl->excl_cnt].column_name = utc.column_name
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  l.attr_name
  FROM dtable t,
   dtableattr a,
   dtableattrl l
  WHERE t.table_name="CHARGE"
   AND t.table_name=a.table_name
   AND l.structtype="F"
   AND btest(l.stat,11)=0
   AND  NOT (expand(euc_idx,1,euc_excl->excl_cnt,l.attr_name,euc_excl->qual[euc_idx].column_name))
  DETAIL
   col_count += 1
   IF (mod(col_count,100)=1)
    stat = alterlist(rcolumns->col,(col_count+ 99))
   ENDIF
   IF (l.attr_name="OFFSET_CHARGE_ITEM_ID")
    v_ocii_exists = 1
   ENDIF
   rcolumns->col[col_count].col_name = l.attr_name
  FOOT REPORT
   stat = alterlist(rcolumns->col,col_count)
  WITH nocounter
 ;end select
 CALL error_logger(curqual,"Error retrieving column names for the charge table",select_error)
 SET stat = alterlist(euc_excl->qual,0)
 SELECT INTO "nl:"
  FROM user_tab_cols utc
  WHERE utc.table_name="CHARGE_MOD"
   AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name="LAST_UTC_TS"
  )) ))
  HEAD REPORT
   euc_excl->excl_cnt = 0
  DETAIL
   euc_excl->excl_cnt += 1, stat = alterlist(euc_excl->qual,euc_excl->excl_cnt), euc_excl->qual[
   euc_excl->excl_cnt].column_name = utc.column_name
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  l.attr_name
  FROM dtable t,
   dtableattr a,
   dtableattrl l
  WHERE t.table_name="CHARGE_MOD"
   AND t.table_name=a.table_name
   AND l.structtype="F"
   AND btest(l.stat,11)=0
   AND  NOT (expand(euc_idx,1,euc_excl->excl_cnt,l.attr_name,euc_excl->qual[euc_idx].column_name))
  DETAIL
   mod_count += 1
   IF (mod(mod_count,100)=1)
    stat = alterlist(modcolumns->col,(mod_count+ 99))
   ENDIF
   modcolumns->col[mod_count].col_name = l.attr_name
  FOOT REPORT
   stat = alterlist(modcolumns->col,mod_count)
  WITH nocounter
 ;end select
 CALL error_logger(curqual,"Error retrieving column names for the charge_mod table",select_error)
 CALL echo(build("Including AFC_PREFERENCE_MANAGER_ACCESS.INC, version [",nullterm("191119.000"),"]")
  )
 SUBROUTINE (bmanprefcheck(_null_=i2) =i2)
   EXECUTE prefrtl
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE lprefstat = i4 WITH protect, noconstant(0)
   DECLARE hgroupin = i4 WITH protect, noconstant(0)
   DECLARE hsubgroupin = i4 WITH protect, noconstant(0)
   DECLARE hgroupout = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE entryindex = i4 WITH protect, noconstant(0)
   DECLARE entrycount = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE attrindex = i4 WITH protect, noconstant(0)
   DECLARE attrcount = i4 WITH protect, noconstant(0)
   DECLARE valindex = i4 WITH protect, noconstant(0)
   DECLARE valcount = i4 WITH protect, noconstant(0)
   DECLARE namelength = i4 WITH protect, noconstant(50)
   DECLARE entryname = c50 WITH protect, noconstant("")
   DECLARE attrname = c50 WITH protect, noconstant("")
   DECLARE sreturn = c50 WITH protect, noconstant("")
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL echo("Failed to create preference instance")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET lprefstat = uar_prefaddcontext(hpref,"default","system")
   IF (lprefstat != 1)
    CALL echo("Failed to add preference context")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET lprefstat = uar_prefsetsection(hpref,"config")
   IF (lprefstat != 1)
    CALL echo("Failed to set preference section")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET hgroupin = uar_prefcreategroup()
   IF (hgroupin=0)
    CALL echo("Failed to create preference group")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET lprefstat = uar_prefsetgroupname(hgroupin,"charge services")
   IF (lprefstat != 1)
    CALL echo("Failed to set preference group name")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET lprefstat = uar_prefaddgroup(hpref,hgroupin)
   IF (lprefstat != 1)
    CALL echo("Failed to add preference group")
    CALL preferencecleanup(0)
    RETURN(true)
   ENDIF
   SET lprefstat = uar_prefperform(hpref)
   IF (lprefstat != 1)
    CALL echo(build("Preference perform failed. lPrefStat:",lprefstat))
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET hsection = uar_prefgetsectionbyname(hpref,"config")
   IF (hsection=0)
    CALL echo("Failed to get preference section")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET hgroupout = uar_prefgetgroupbyname(hsection,"charge services")
   IF (hgroupout=0)
    CALL echo("Failed to get preference group")
    CALL preferencecleanup(0)
    RETURN(false)
   ENDIF
   SET lprefstat = uar_prefgetgroupentrycount(hgroupout,entrycount)
   IF (lprefstat != 1)
    CALL echo("Failed to get preference entry count")
    CALL preferencecleanup(0)
    RETURN(true)
   ENDIF
   FOR (entryindex = 0 TO (entrycount - 1))
     SET namelength = 50
     SET entryname = fillstring(50," ")
     SET hentry = uar_prefgetgroupentry(hgroupout,entryindex)
     IF (hentry=0)
      CALL echo("Failed to get preference group entry")
      CALL preferencecleanup(0)
      RETURN(true)
     ENDIF
     SET lprefstat = uar_prefgetentryname(hentry,entryname,namelength)
     IF (lprefstat != 1)
      CALL echo("Failed to get preference entry name")
      CALL preferencecleanup(0)
      RETURN(true)
     ENDIF
     SET lprefstat = uar_prefgetentryattrcount(hentry,attrcount)
     IF (lprefstat != 1)
      CALL echo("Failed to get preference entry attribute count")
      CALL preferencecleanup(0)
      RETURN(true)
     ENDIF
     FOR (attrindex = 0 TO (attrcount - 1))
       SET namelength = 50
       SET attrname = fillstring(50," ")
       SET hattr = uar_prefgetentryattr(hentry,attrindex)
       IF (hattr=0)
        CALL echo("Failed to get preference entry attribute")
        CALL preferencecleanup(0)
        RETURN(false)
       ENDIF
       SET lprefstat = uar_prefgetattrname(hattr,attrname,namelength)
       IF (lprefstat != 1)
        CALL echo("Failed to get preference entry attribute name")
        CALL preferencecleanup(0)
        RETURN(false)
       ENDIF
       SET lprefstat = uar_prefgetattrvalcount(hattr,valcount)
       IF (lprefstat != 1)
        CALL echo("Failed to get preference entry attribute value count")
        CALL preferencecleanup(0)
        RETURN(false)
       ENDIF
       FOR (valindex = 0 TO (valcount - 1))
        SET namelength = 50
        CASE (trim(entryname))
         OF "manual charge copy":
          SET hval = uar_prefgetattrval(hattr,sreturn,namelength,valindex)
        ENDCASE
       ENDFOR
     ENDFOR
   ENDFOR
   CALL preferencecleanup(0)
   IF (sreturn="1")
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (preferencecleanup(_null_=i2) =null)
   CALL uar_prefdestroyinstance(hpref)
   CALL uar_prefdestroygroup(hgroupin)
   CALL uar_prefdestroygroup(hgroupout)
   CALL uar_prefdestroygroup(hsubgroupin)
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroyentry(hentry)
   CALL uar_prefdestroyattr(hattr)
 END ;Subroutine
 SET bcopycharge = bmanprefcheck(0)
 DECLARE tmp_offset_charge_item_id = f8
 IF ((rchildren->qual1[det_cnt].combine_desc_cd=debit_desc_cd))
  CALL get_charge_record(rchildren->qual1[det_cnt].entity_id)
  SET dropchgsyncreq->to_encntr_id = rreclist->from_rec[1].to_encntr_id
  CALL add_primary_healthplans("NULL")
  CALL addprimaryhealthplan(null)
  IF ((rreclist->from_rec[loop_cnt].charge_type_cd != credit_cd))
   CALL echorecord(rreclist,"ccluserdir:receucb.dat")
   SET dropchgsyncreq->to_encntr_id = rreclist->from_rec[1].to_encntr_id
   FOR (loop_cnt = 1 TO size(rreclist->from_rec,5))
     IF ((rreclist->from_rec[loop_cnt].process_flg IN (999, 977)))
      IF (combine_interface_flag=0)
       CALL chg_struct_build("CREDIT",rreclist->from_rec[loop_cnt].from_id,6,loop_cnt)
       CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,6,loop_cnt)
       CALL chg_struct_build("UPT",rreclist->from_rec[loop_cnt].from_id,999,loop_cnt)
      ELSE
       CALL chg_struct_build("CREDIT",rreclist->from_rec[loop_cnt].from_id,0,loop_cnt)
       IF ((rreclist->from_rec[loop_cnt].offset_charge_item_id > 0))
        CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,10,loop_cnt)
       ELSEIF ((((rreclist->from_rec[loop_cnt].manual_ind=1)
        AND bcopycharge) OR ((rreclist->from_rec[loop_cnt].activity_type_cd=npharmacycd))) )
        CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,0,loop_cnt)
       ELSE
        CALL drop_charge_sync(loop_cnt)
        CALL populatedebitchargerecord(rreclist->from_rec[loop_cnt].from_id)
       ENDIF
       CALL chg_struct_build("UPT",rreclist->from_rec[loop_cnt].from_id,999,loop_cnt)
      ENDIF
     ELSEIF ((((rreclist->from_rec[loop_cnt].process_flg=0)) OR ((rreclist->from_rec[loop_cnt].
     process_flg=1))) )
      CALL chg_struct_build("CREDIT",rreclist->from_rec[loop_cnt].from_id,10,loop_cnt)
      IF ((rreclist->from_rec[loop_cnt].charge_type_cd=nnochargecd)
       AND (rreclist->from_rec[loop_cnt].activity_type_cd=npharmacycd))
       CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,0,loop_cnt)
      ELSEIF ((rreclist->from_rec[loop_cnt].activity_type_cd != npharmacycd)
       AND isaddoncharge(rreclist->from_rec[loop_cnt].from_id))
       CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,1,loop_cnt)
      ELSE
       IF ((rreclist->from_rec[loop_cnt].offset_charge_item_id > 0))
        CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,10,loop_cnt)
       ELSEIF ((((rreclist->from_rec[loop_cnt].manual_ind=1)
        AND bcopycharge) OR ((rreclist->from_rec[loop_cnt].activity_type_cd=npharmacycd))) )
        CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,0,loop_cnt)
       ELSE
        CALL drop_charge_sync(loop_cnt)
        CALL populatedebitchargerecord(rreclist->from_rec[loop_cnt].from_id)
       ENDIF
      ENDIF
      CALL chg_struct_build("UPT",rreclist->from_rec[loop_cnt].from_id,10,loop_cnt)
     ELSEIF ((rreclist->from_rec[loop_cnt].process_flg IN (100, 177)))
      IF ((rreclist->from_rec[loop_cnt].offset_charge_item_id > 0))
       CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,10,loop_cnt)
      ELSEIF ((((rreclist->from_rec[loop_cnt].manual_ind=1)
       AND bcopycharge) OR ((rreclist->from_rec[loop_cnt].activity_type_cd=npharmacycd))) )
       CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,0,loop_cnt)
       CALL chg_struct_build("CREDIT",rreclist->from_rec[loop_cnt].from_id,0,loop_cnt)
      ELSE
       CALL drop_charge_sync(loop_cnt)
       CALL populatedebitchargerecord(rreclist->from_rec[loop_cnt].from_id)
       CALL chg_struct_build("CREDIT",rreclist->from_rec[loop_cnt].from_id,0,loop_cnt)
      ENDIF
      CALL chg_struct_build("UPT",rreclist->from_rec[loop_cnt].from_id,100,loop_cnt)
     ELSEIF ((rreclist->from_rec[loop_cnt].process_flg=777))
      CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,777,loop_cnt)
      CALL chg_struct_build("CREDIT",rreclist->from_rec[loop_cnt].from_id,777,loop_cnt)
      CALL chg_struct_build("UPT",rreclist->from_rec[loop_cnt].from_id,777,loop_cnt)
     ELSEIF ((rreclist->from_rec[loop_cnt].process_flg != 10))
      IF ((rreclist->from_rec[loop_cnt].process_flg=6))
       CALL chg_struct_build("CREDIT",rreclist->from_rec[loop_cnt].from_id,10,loop_cnt)
       CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,rreclist->from_rec[loop_cnt].
        process_flg,loop_cnt)
       CALL chg_struct_build("UPT",rreclist->from_rec[loop_cnt].from_id,10,loop_cnt)
      ELSE
       CALL chg_struct_build("CREDIT",rreclist->from_rec[loop_cnt].from_id,10,loop_cnt)
       IF ((rreclist->from_rec[loop_cnt].offset_charge_item_id > 0))
        CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,10,loop_cnt)
       ELSE
        IF ((rreclist->from_rec[loop_cnt].activity_type_cd=npharmacycd))
         CALL chg_struct_build("INS",rreclist->from_rec[loop_cnt].from_id,rreclist->from_rec[loop_cnt
          ].process_flg,loop_cnt)
        ELSE
         CALL drop_charge_sync(loop_cnt)
         CALL populatedebitchargerecord(rreclist->from_rec[loop_cnt].from_id)
        ENDIF
       ENDIF
       CALL chg_struct_build("UPT",rreclist->from_rec[loop_cnt].from_id,10,loop_cnt)
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (size(dropchgsyncreq->charge,5) > 0)
  CALL echorecord(dropchgsyncreq)
  EXECUTE dm_cmb_drop_charge_sync  WITH replace("REQUEST",dropchgsyncreq), replace("REPLY",
   dropchgsyncrep)
  IF ((dropchgsyncrep->status_data.status != "S"))
   GO TO end_of_program
  ENDIF
  IF (size(debit_charge_struct->objarray,5) > 0
   AND size(dropchgsyncrep->charges,5) > 0)
   SET stat = alterlist(debit_charge_struct->objarray,size(dropchgsyncrep->charges,5))
   SET debitparentchargeitemid = debit_charge_struct->objarray[1].charge_item_id
   FOR (debitchgcnt = 1 TO size(dropchgsyncrep->charges,5))
    SET debit_charge_struct->objarray[debitchgcnt].charge_item_id = debitparentchargeitemid
    SET debit_charge_struct->objarray[debitchgcnt].new_chargeitemid = dropchgsyncrep->charges[
    debitchgcnt].charge_item_id
   ENDFOR
  ENDIF
 ELSE
  SET stat = initrec(debit_charge_struct)
 ENDIF
 FOR (inschgcnt = 1 TO size(insert_struct->objarray,5))
  SET loop_cnt = inschgcnt
  CALL insert_charge(insert_struct->objarray[inschgcnt].charge_item_id,insert_struct->objarray[
   inschgcnt].process_flag)
 ENDFOR
 FOR (crdtchgcnt = 1 TO size(credit_charge_struct->objarray,5))
  SET loop_cnt = crdtchgcnt
  CALL credit_charge(credit_charge_struct->objarray[crdtchgcnt].charge_item_id,credit_charge_struct->
   objarray[crdtchgcnt].process_flag,credit_charge_struct->objarray[crdtchgcnt].loop_cnt,"EU")
 ENDFOR
 SET ccnt = size(insert_struct->objarray,5)
 FOR (offidx = 1 TO ccnt)
   CALL updateoffsetparent_chargeid(insert_struct->objarray[offidx].charge_item_id,insert_struct->
    objarray[offidx].new_chargeitemid,ccnt,insert_struct)
 ENDFOR
 SET ccnt = size(credit_charge_struct->objarray,5)
 FOR (offidx = 1 TO ccnt)
   IF ((credit_charge_struct->objarray[offidx].offset_charge_item_id > 0.0))
    CALL updateoffsetparent_chargeid(credit_charge_struct->objarray[offidx].charge_item_id,
     credit_charge_struct->objarray[offidx].new_chargeitemid,ccnt,credit_charge_struct)
   ENDIF
 ENDFOR
 FOR (uptchgcnt = 1 TO size(upt_charge_struct->objarray,5))
  SET loop_cnt = uptchgcnt
  CALL update_charge(upt_charge_struct->objarray[uptchgcnt].charge_item_id,upt_charge_struct->
   objarray[uptchgcnt].process_flag)
 ENDFOR
 SET ccnt = size(debit_charge_struct->objarray,5)
 FOR (offidx = 1 TO ccnt)
   CALL updateoffsetparent_chargeid(debit_charge_struct->objarray[offidx].charge_item_id,
    debit_charge_struct->objarray[offidx].new_chargeitemid,ccnt,debit_charge_struct)
 ENDFOR
 FREE SET rreclist
 FREE SET rcolumns
 FREE SET modcolumns
 GO TO end_of_program
 SUBROUTINE get_charge_record(cii)
  SELECT INTO "nl:"
   frm.*
   FROM charge frm
   PLAN (frm
    WHERE frm.charge_item_id=cii)
   DETAIL
    count1 += 1, stat = alterlist(rreclist->from_rec,count1), rreclist->from_rec[count1].from_id =
    frm.charge_item_id,
    rreclist->from_rec[count1].to_encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, rreclist->
    from_rec[count1].encntr_id = frm.encntr_id, rreclist->from_rec[count1].item_price = frm
    .item_price,
    rreclist->from_rec[count1].item_extended_price = frm.item_extended_price, rreclist->from_rec[
    count1].charge_type_cd = frm.charge_type_cd, rreclist->from_rec[count1].process_flg = frm
    .process_flg,
    rreclist->from_rec[count1].credited_dt_tm = frm.credited_dt_tm, rreclist->from_rec[count1].
    offset_charge_item_id = frm.offset_charge_item_id, rreclist->from_rec[count1].beg_effective_dt_tm
     = frm.beg_effective_dt_tm,
    rreclist->from_rec[count1].activity_type_cd = frm.activity_type_cd, rreclist->from_rec[count1].
    manual_ind = frm.manual_ind, rreclist->from_rec[count1].service_dt_tm = frm.service_dt_tm
   WITH forupdatewait(frm), nocounter
  ;end select
  SELECT INTO "nl:"
   frm.*
   FROM charge frm
   WHERE frm.parent_charge_item_id=cii
   DETAIL
    count1 += 1, stat = alterlist(rreclist->from_rec,count1), rreclist->from_rec[count1].from_id =
    frm.charge_item_id,
    rreclist->from_rec[count1].to_encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, rreclist->
    from_rec[count1].encntr_id = frm.encntr_id, rreclist->from_rec[count1].item_price = frm
    .item_price,
    rreclist->from_rec[count1].item_extended_price = frm.item_extended_price, rreclist->from_rec[
    count1].charge_type_cd = frm.charge_type_cd, rreclist->from_rec[count1].process_flg = frm
    .process_flg,
    rreclist->from_rec[count1].credited_dt_tm = frm.credited_dt_tm, rreclist->from_rec[count1].
    offset_charge_item_id = frm.offset_charge_item_id, rreclist->from_rec[count1].activity_type_cd =
    frm.activity_type_cd,
    rreclist->from_rec[count1].service_dt_tm = frm.service_dt_tm
   WITH forupdatewait(frm), nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE insert_charge(cii,type)
   CALL echo("inside insert_charge")
   SET new_nbri = 0.0
   SET count2 = loop_cnt
   SELECT INTO "nl:"
    y = seq(charge_event_seq,nextval)
    FROM dual
    DETAIL
     new_nbri = y
    WITH format, nocounter
   ;end select
   SET insert_struct->objarray[count2].new_chargeitemid = new_nbri
   CALL error_logger(curqual,"Couldn't get the next sequence number",gen_nbr_error)
   CALL parser("insert into charge (")
   FOR (x = 1 TO col_count)
     IF (x=col_count)
      CALL parser(concat(trim(rcolumns->col[x].col_name),")"))
     ELSE
      CALL parser(concat(trim(rcolumns->col[x].col_name),","))
     ENDIF
   ENDFOR
   CALL parser("(select ")
   FOR (x = 1 TO col_count)
    IF (x=col_count)
     SET v_comma_str = " "
    ELSE
     SET v_comma_str = ","
    ENDIF
    CASE (trim(rcolumns->col[x].col_name))
     OF "CHARGE_ITEM_ID":
      CALL parser(build("new_nbri",v_comma_str))
     OF "ENCNTR_ID":
      CALL parser(build("rRecList->from_rec[insert_struct->objArray[count2].loop_cnt]->to_encntr_id",
        v_comma_str))
     OF "COMBINE_IND":
      CALL parser(build("0",v_comma_str))
     OF "PROCESS_FLG":
      CALL parser(build("type",v_comma_str))
     OF "ACTIVE_IND":
      CALL parser(build("1",v_comma_str))
     OF "ACTIVE_STATUS_CD":
      CALL parser(build("active_code",v_comma_str))
     OF "ACTIVE_STATUS_PRSNL_ID":
      CALL parser(build("ReqInfo->updt_id",v_comma_str))
     OF "ACTIVE_STATUS_DT_TM":
      CALL parser(build("cnvtdatetime(curdate, curtime3)",v_comma_str))
     OF "UPDT_CNT":
      CALL parser(build("0",v_comma_str))
     OF "UPDT_DT_TM":
      CALL parser(build("cnvtdatetime(curdate, curtime)",v_comma_str))
     OF "UPDT_ID":
      CALL parser(build("ReqInfo->updt_id",v_comma_str))
     OF "POSTED_ID":
      CALL parser(build("ReqInfo->updt_id",v_comma_str))
     OF "UPDT_APPLCTX":
      CALL parser(build("ReqInfo->updt_applctx",v_comma_str))
     OF "UPDT_TASK":
      CALL parser(build("ReqInfo->updt_task",v_comma_str))
     OF "PARENT_CHARGE_ITEM_ID":
      IF ((insert_struct->objarray[count2].offset_charge_item_id > 0.0))
       CALL parser(build("FRM.",trim(rcolumns->col[x].col_name),v_comma_str))
      ELSE
       CALL parser(build("0.00",v_comma_str))
      ENDIF
     ELSE
      CALL parser(build("FRM.",trim(rcolumns->col[x].col_name),v_comma_str))
    ENDCASE
   ENDFOR
   CALL parser("from charge FRM")
   CALL parser(build("where FRM.charge_item_id = ",rreclist->from_rec[insert_struct->objarray[count2]
     .loop_cnt].from_id,")"))
   CALL parser("with nocounter go")
   IF (error(ucberrmsg,0) != 0)
    CALL error_logger(0,"Couldn't insert charge on the to person",insert_error)
   ENDIF
   CALL copy_charge_mod(rreclist->from_rec[insert_struct->objarray[count2].loop_cnt].from_id,new_nbri,
    "EU")
   IF (type=1)
    CALL insert_charge_mod(new_nbri)
   ENDIF
   SET igl_idx = 0
   SET iindex = 0
   SET igl_idx = locateval(iindex,1,size(upt_charge_struct->objarray,5),cii,upt_charge_struct->
    objarray[iindex].charge_item_id)
   IF (igl_idx > 0)
    SET upt_charge_struct->objarray[igl_idx].tmp_offset_charge_item_id = new_nbri
   ENDIF
 END ;Subroutine
 SUBROUTINE update_charge(cii,flag_type)
   DECLARE creditoffsetchargeitemid = f8 WITH protect, noconstant(0.0)
   IF (v_ocii_exists=1)
    SELECT INTO "nl:"
     FROM charge c
     WHERE c.charge_item_id=cii
     DETAIL
      IF (c.offset_charge_item_id > 0)
       creditoffsetchargeitemid = c.offset_charge_item_id
      ENDIF
     WITH nocounter
    ;end select
    IF (creditoffsetchargeitemid=0.0)
     SET igl_idx = 0
     SET iindex = 0
     SET igl_idx = locateval(iindex,1,size(upt_charge_struct->objarray,5),cii,upt_charge_struct->
      objarray[iindex].charge_item_id)
     IF (igl_idx > 0)
      SET creditoffsetchargeitemid = upt_charge_struct->objarray[igl_idx].tmp_offset_charge_item_id
     ENDIF
    ENDIF
   ENDIF
   UPDATE  FROM charge c
    SET c.process_flg = flag_type, c.combine_ind = 1, c.offset_charge_item_id =
     creditoffsetchargeitemid,
     c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task
    WHERE c.charge_item_id=cii
    WITH nocounter
   ;end update
   IF (error(ucberrmsg,0) != 0)
    CALL error_logger(0,"Couldn't update charge on the from person",update_error)
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_charge_mod(ciiic)
   SET new_nbric = 0.0
   SELECT INTO "nl:"
    y = seq(charge_event_seq,nextval)
    FROM dual
    DETAIL
     new_nbric = y
    WITH format, nocounter
   ;end select
   CALL error_logger(curqual,"Couldn't get the next sequence number",gen_nbr_error)
   INSERT  FROM charge_mod c
    SET c.charge_mod_id = new_nbric, c.charge_item_id = ciiic, c.charge_mod_type_cd = suspense_cd,
     c.field6 = trim(suspense_reason_desc), c.field1_id = suspense_reason_cd, c.active_ind = true,
     c.active_status_cd = active_code, c.active_status_prsnl_id = reqinfo->updt_id, c
     .active_status_dt_tm = cnvtdatetime(sysdate),
     c.beg_effective_dt_tm = cnvtdatetime(sysdate), c.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), c.updt_cnt = 0,
     c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id, c.updt_applctx =
     reqinfo->updt_applctx,
     c.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (error(ucberrmsg,0) != 0)
    CALL error_logger(0,"Couldn't insert charge_mod record-insert_charge_mod",insert_error)
   ENDIF
 END ;Subroutine
 SUBROUTINE add_primary_healthplans(d)
   CALL echo("Adding primary health plans to the DropChgSyncReq structure")
   SET groupcnt = 0
   SET mpcnt = 0.0
   SELECT INTO "nl:"
    epr.health_plan_id
    FROM encntr_plan_cob epc,
     encntr_plan_cob_reltn epcr,
     encntr_plan_reltn epr
    PLAN (epc
     WHERE (epc.encntr_id=dropchgsyncreq->to_encntr_id)
      AND epc.active_ind=1
      AND epc.beg_effective_dt_tm <= cnvtdatetime(rreclist->from_rec[1].service_dt_tm)
      AND epc.end_effective_dt_tm >= cnvtdatetime(rreclist->from_rec[1].service_dt_tm))
     JOIN (epcr
     WHERE epcr.encntr_plan_cob_id=epc.encntr_plan_cob_id
      AND epcr.active_ind=1
      AND epcr.priority_seq=1)
     JOIN (epr
     WHERE epr.encntr_plan_reltn_id=epcr.encntr_plan_reltn_id
      AND epr.active_ind=1
      AND epr.beg_effective_dt_tm <= cnvtdatetime(rreclist->from_rec[1].service_dt_tm)
      AND epr.end_effective_dt_tm >= cnvtdatetime(rreclist->from_rec[1].service_dt_tm))
    ORDER BY epr.beg_effective_dt_tm, epr.health_plan_id
    HEAD epr.health_plan_id
     mpcnt += 1, dropchgsyncreq->primaryhealthplancount = mpcnt
     IF (epc.encntr_plan_cob_id > 0)
      groupcnt += 1, stat = alterlist(dropchgsyncreq->primaryhealthplans,groupcnt), dropchgsyncreq->
      primaryhealthplans[groupcnt].health_plan_id = epr.health_plan_id,
      dropchgsyncreq->primaryhealthplans[groupcnt].priority_sequence = 1
     ENDIF
    WITH nocounter
   ;end select
   SET groupcnt = 0
   SET mpcnt = 0
 END ;Subroutine
 SUBROUTINE addprimaryhealthplan(d)
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_plan_cob epc,
     encntr_plan_cob_reltn epcr,
     encntr_plan_reltn epr1,
     encntr_plan_reltn epr
    PLAN (e
     WHERE (e.encntr_id=dropchgsyncreq->to_encntr_id))
     JOIN (epr
     WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
      AND (epr.priority_seq= Outerjoin(1))
      AND (epr.active_ind= Outerjoin(1)) )
     JOIN (epc
     WHERE (epc.encntr_id= Outerjoin(e.encntr_id))
      AND (epc.active_ind= Outerjoin(1)) )
     JOIN (epcr
     WHERE (epcr.encntr_plan_cob_id= Outerjoin(epc.encntr_plan_cob_id))
      AND (epcr.priority_seq= Outerjoin(1))
      AND (epcr.active_ind= Outerjoin(1)) )
     JOIN (epr1
     WHERE (epr1.encntr_plan_reltn_id= Outerjoin(epcr.encntr_plan_reltn_id))
      AND (epr1.active_ind= Outerjoin(1)) )
    DETAIL
     IF (epc.encntr_plan_cob_id > 0)
      IF (epr1.encntr_plan_reltn_id > 0)
       IF (epc.beg_effective_dt_tm <= cnvtdatetime(rreclist->from_rec[1].service_dt_tm)
        AND epc.end_effective_dt_tm >= cnvtdatetime(rreclist->from_rec[1].service_dt_tm)
        AND epr1.beg_effective_dt_tm <= cnvtdatetime(rreclist->from_rec[1].service_dt_tm)
        AND epr1.end_effective_dt_tm >= cnvtdatetime(rreclist->from_rec[1].service_dt_tm))
        CALL validatehealthplan(epr1.health_plan_id)
       ENDIF
      ENDIF
     ELSE
      IF (epr.encntr_plan_reltn_id > 0)
       IF (epr.beg_effective_dt_tm <= cnvtdatetime(rreclist->from_rec[1].service_dt_tm)
        AND epr.end_effective_dt_tm >= cnvtdatetime(rreclist->from_rec[1].service_dt_tm))
        CALL validatehealthplan(epr.health_plan_id)
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (validatehealthplan(healthplanid=f8) =null)
   IF (validate(dropchgsyncreq->health_plan_id))
    SET dropchgsyncreq->health_plan_id = healthplanid
   ENDIF
 END ;Subroutine
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  SET ucb_failed = ccl_error
 ENDIF
 SUBROUTINE drop_charge_sync(curindex)
   SET eventexists = 0
   SET tempeventid = 0.0
   SELECT INTO "nl:"
    FROM charge c
    WHERE (c.charge_item_id=rchildren->qual1[det_cnt].entity_id)
    DETAIL
     tempeventid = c.charge_event_id
    WITH nocounter
   ;end select
   FOR (synccount = 1 TO size(eventpersist->charge,5))
     IF ((eventpersist->charge[synccount].charge_event_id=tempeventid))
      SET eventexists = 1
     ENDIF
   ENDFOR
   IF (eventexists=0)
    SET synccount = (size(dropchgsyncreq->charge,5)+ 1)
    SET stat = alterlist(dropchgsyncreq->charge,synccount)
    SET dropchgsyncreq->charge[synccount].charge_item_id = rreclist->from_rec[curindex].from_id
    SET synccount = (size(eventpersist->charge,5)+ 1)
    SET stat = alterlist(eventpersist->charge,synccount)
    SET eventpersist->charge[synccount].charge_event_id = tempeventid
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_struct_build(struct_key,cii,flag,loop)
   IF (struct_key="INS")
    SET inschgcnt += 1
    SET stat = alterlist(insert_struct->objarray,inschgcnt)
    SET insert_struct->objarray[inschgcnt].charge_item_id = cii
    SET insert_struct->objarray[inschgcnt].process_flag = flag
    SET insert_struct->objarray[inschgcnt].loop_cnt = loop
    SET insert_struct->objarray[inschgcnt].offset_charge_item_id = rreclist->from_rec[loop].
    offset_charge_item_id
   ELSEIF (struct_key="INS10")
    SET ins10chgcnt += 1
    SET stat = alterlist(insert_10_struct->objarray,ins10chgcnt)
    SET insert_10_struct->objarray[ins10chgcnt].charge_item_id = cii
   ELSEIF (struct_key="CREDIT")
    SET crdtchgcnt += 1
    SET stat = alterlist(credit_charge_struct->objarray,crdtchgcnt)
    SET credit_charge_struct->objarray[crdtchgcnt].charge_item_id = cii
    SET credit_charge_struct->objarray[crdtchgcnt].process_flag = flag
    SET credit_charge_struct->objarray[crdtchgcnt].loop_cnt = loop
    SET credit_charge_struct->objarray[crdtchgcnt].offset_charge_item_id = rreclist->from_rec[loop].
    offset_charge_item_id
   ELSEIF (struct_key="UPT")
    SET uptchgcnt += 1
    SET stat = alterlist(upt_charge_struct->objarray,uptchgcnt)
    SET upt_charge_struct->objarray[uptchgcnt].charge_item_id = cii
    SET upt_charge_struct->objarray[uptchgcnt].process_flag = flag
   ENDIF
 END ;Subroutine
 SUBROUTINE (populatedebitchargerecord(chargeitemid=f8) =null)
   SET debitchgcnt += 1
   SET stat = alterlist(debit_charge_struct->objarray,debitchgcnt)
   SET debit_charge_struct->objarray[debitchgcnt].charge_item_id = chargeitemid
 END ;Subroutine
 SUBROUTINE (updateoffsetparent_chargeid(existingcii=f8,newcii=f8,recordcount=i4,lookupref=vc(ref)) =
  null)
   SET indx = 0
   SET ipos = 0
   SET indx = locateval(ipos,1,recordcount,existingcii,lookupref->objarray[ipos].
    offset_charge_item_id)
   IF (newcii > 0.0)
    IF (indx > 0)
     UPDATE  FROM charge c
      SET c.offset_charge_item_id = lookupref->objarray[indx].new_chargeitemid, c
       .parent_charge_item_id = evaluate2(
        IF (c.charge_type_cd=credit_cd
         AND c.parent_charge_item_id > 0.0) lookupref->objarray[indx].new_chargeitemid
        ELSEIF (c.charge_type_cd=debit_cd
         AND c.offset_charge_item_id > 0.0) 0.0
        ELSE existingcii
        ENDIF
        ), c.updt_cnt = (c.updt_cnt+ 1),
       c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->
       updt_applctx,
       c.updt_task = reqinfo->updt_task, c.original_encntr_id =
       (SELECT
        chrg.original_encntr_id
        FROM charge chrg
        WHERE chrg.charge_item_id=evaluate2(
         IF (c.charge_type_cd=credit_cd
          AND c.parent_charge_item_id > 0.0) lookupref->objarray[indx].new_chargeitemid
         ELSEIF (c.charge_type_cd=debit_cd
          AND c.offset_charge_item_id > 0.0) 0.0
         ELSE existingcii
         ENDIF
         ))
      WHERE c.charge_item_id=newcii
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM charge c
      SET c.parent_charge_item_id = existingcii, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm =
       cnvtdatetime(sysdate),
       c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
       updt_task,
       c.original_encntr_id =
       (SELECT
        c.original_encntr_id
        FROM charge c
        WHERE c.charge_item_id=existingcii)
      WHERE c.charge_item_id=newcii
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (isaddoncharge(chargeid=f8) =null)
   DECLARE billitemextownercd = f8 WITH public, noconstant(0.0)
   SELECT INTO "nl:"
    FROM charge c,
     bill_item b
    PLAN (c
     WHERE c.charge_item_id=chargeid
      AND c.active_ind=true
      AND c.process_flg=1)
     JOIN (b
     WHERE b.bill_item_id=c.bill_item_id
      AND b.active_ind=true
      AND b.ext_owner_cd IN (cs106_genericaddon, cs106_specificaddon, cs106_defaultaddon))
    DETAIL
     billitemextownercd = b.ext_owner_cd
    WITH format, nocounter
   ;end select
   IF (billitemextownercd > 0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
#end_of_program
 FREE RECORD dropchgsyncreq
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(insert_struct)
  CALL echorecord(upt_charge_struct)
  CALL echorecord(credit_charge_struct)
  CALL echorecord(insert_10_struct)
 ENDIF
END GO

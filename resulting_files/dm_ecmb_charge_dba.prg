CREATE PROGRAM dm_ecmb_charge:dba
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
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "CHARGE"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_ECMB_CHARGE"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO end_of_program
 ENDIF
 IF ("Z"=validate(dm_ecmb_charge_vrsn,"Z"))
  DECLARE dm_ecmb_charge_vrsn = vc WITH noconstant("680200.001")
 ENDIF
 SET dm_ecmb_charge_vrsn = "680200.001"
 DECLARE v_ocii_exists = i2
 SET v_ocii_exists = 0
 CALL echorecord(request,"ccluserdir:enccmb.dat")
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 to_encntr_id = f8
     2 parent_charge_item_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 payor_id = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 charge_type_cd = f8
     2 posted_cd = f8
     2 posted_dt_tm = dq8
     2 process_flg = i4
     2 credited_dt_tm = dq8
     2 combine_ind = i2
     2 offset_charge_item_id = f8
     2 beg_effective_dt_tm = dq8
     2 activity_type_cd = f8
     2 manual_ind = i2
     2 charge_event_id = f8
     2 tier_group_cd = f8
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
 FREE RECORD ecc_requestmain
 RECORD ecc_requestmain(
   1 cstart = i4
   1 cend = i4
 )
 FREE RECORD ecc_excl
 RECORD ecc_excl(
   1 excl_cnt = i4
   1 qual[*]
     2 column_name = vc
 )
 SET count1 = 0
 SET count2 = 0
 SET col_count = 0
 SET mod_count = 0
 DECLARE credit_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13028,nullterm("CR"),1,credit_cd)
 IF (credit_cd IN (0.0, null))
  CALL echo("CREDIT_CD IS NULL")
  SET request->error_message = "CREDIT_CD IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE suspense_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13019,nullterm("SUSPENSE"),1,suspense_cd)
 IF (suspense_cd IN (0.0, null))
  CALL echo("suspense_cd IS NULL")
  SET request->error_message = "suspense_cd IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE debit_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13028,nullterm("DR"),1,debit_cd)
 IF (debit_cd IN (0.0, null))
  CALL echo("DEBIT_CD IS NULL")
  SET request->error_message = "DEBIT_CD IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE debit_desc_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(14200,nullterm("DEBITCHARGE"),1,debit_desc_cd)
 IF (debit_desc_cd IN (0.0, null))
  CALL echo("DEBIT_DESC_CD IS NULL")
  SET request->error_message = "DEBIT_DESC_CD IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE credit_desc_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(14200,nullterm("CREDITCHARGE"),1,credit_desc_cd)
 IF (credit_desc_cd IN (0.0, null))
  CALL echo("CREDIT_DESC_CD IS NULL")
  SET request->error_message = "CREDIT_DESC_CD IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE debit_off_desc_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(14200,nullterm("OFFSETDEBIT"),1,debit_off_desc_cd)
 IF (debit_off_desc_cd IN (0.0, null))
  CALL echo("DEBIT_OFF_DESC_CD IS NULL")
  SET request->error_message = "DEBIT_OFF_DESC_CD IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE credit_off_desc_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(14200,nullterm("OFFSETCREDIT"),1,credit_off_desc_cd)
 IF (credit_off_desc_cd IN (0.0, null))
  CALL echo("CREDIT_OFF_DESC_CD IS NULL")
  SET request->error_message = "CREDIT_OFF_DESC_CD IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE suspense_reason_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13030,nullterm("COMBINED"),1,suspense_reason_cd)
 IF (suspense_reason_cd IN (0.0, null))
  CALL echo("SUSPENSE_REASON_CD IS NULL")
  SET request->error_message = "SUSPENSE_REASON_CD IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 SET ssuspensedesc = uar_get_code_description(suspense_reason_cd)
 DECLARE active_code = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(48,nullterm("ACTIVE"),1,active_code)
 IF (active_code IN (0.0, null))
  CALL echo("active_code IS NULL")
  SET request->error_message = "active_code IS NULL"
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
 DECLARE 14002_combine = f8
 SET stat = uar_get_meaning_by_codeset(14002,nullterm("COMBINE"),1,14002_combine)
 CALL echo(build("the combine_cd is : ",14002_combine))
 IF (14002_combine IN (0.0, null))
  CALL echo("14002_COMBINE IS NULL")
  SET request->error_message = "14002_COMBINE IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE 319_fin_nbr = f8
 SET stat = uar_get_meaning_by_codeset(319,nullterm("FIN NBR"),1,319_fin_nbr)
 CALL echo(build("the combine_cd is : ",319_fin_nbr))
 IF (319_fin_nbr IN (0.0, null))
  CALL echo("319_FIN_NBR IS NULL")
  SET request->error_message = "319_FIN_NBR IS NULL"
  SET failed = general_error
  GO TO end_of_program
 ENDIF
 DECLARE 13019_mrn_alias = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13019,nullterm("MRNALIAS"),1,13019_mrn_alias)
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
 DECLARE ecc_idx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM user_tab_cols utc
  WHERE utc.table_name="CHARGE"
   AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name="LAST_UTC_TS"
  )) ))
  HEAD REPORT
   ecc_excl->excl_cnt = 0
  DETAIL
   ecc_excl->excl_cnt += 1, stat = alterlist(ecc_excl->qual,ecc_excl->excl_cnt), ecc_excl->qual[
   ecc_excl->excl_cnt].column_name = utc.column_name
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
   AND  NOT (expand(ecc_idx,1,ecc_excl->excl_cnt,l.attr_name,ecc_excl->qual[ecc_idx].column_name))
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
 SET stat = alterlist(ecc_excl->qual,0)
 SELECT INTO "nl:"
  FROM user_tab_cols utc
  WHERE utc.table_name="CHARGE_MOD"
   AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name="LAST_UTC_TS"
  )) ))
  HEAD REPORT
   ecc_excl->excl_cnt = 0
  DETAIL
   ecc_excl->excl_cnt += 1, stat = alterlist(ecc_excl->qual,ecc_excl->excl_cnt), ecc_excl->qual[
   ecc_excl->excl_cnt].column_name = utc.column_name
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
   AND  NOT (expand(ecc_idx,1,ecc_excl->excl_cnt,l.attr_name,ecc_excl->qual[ecc_idx].column_name))
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
 DECLARE tmp_offset_charge_item_id = f8
 SET to_payor_id = 0.0
 SET final_person_id = 0.0
 SELECT INTO "nl:"
  t.person_id, t.organization_id
  FROM encounter t
  WHERE (t.encntr_id=request->xxx_combine[icombine].to_xxx_id)
   AND t.active_ind=true
  DETAIL
   final_person_id = t.person_id, to_payor_id = t.organization_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  frm.*
  FROM charge frm
  WHERE (frm.encntr_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.active_ind=true
   AND ((frm.combine_ind=false) OR (frm.combine_ind=null))
  ORDER BY frm.charge_item_id
  DETAIL
   count1 += 1, count2 += 1, stat = alterlist(rreclist->from_rec,count1),
   rreclist->from_rec[count1].from_id = frm.charge_item_id, rreclist->from_rec[count1].to_encntr_id
    = request->xxx_combine[icombine].to_xxx_id, rreclist->from_rec[count1].encntr_id = frm.encntr_id,
   rreclist->from_rec[count1].payor_id = frm.payor_id, rreclist->from_rec[count1].item_price = frm
   .item_price, rreclist->from_rec[count1].item_extended_price = frm.item_extended_price,
   rreclist->from_rec[count1].charge_type_cd = frm.charge_type_cd, rreclist->from_rec[count1].
   posted_cd = frm.posted_cd, rreclist->from_rec[count1].posted_dt_tm = frm.posted_dt_tm,
   rreclist->from_rec[count1].process_flg = frm.process_flg, rreclist->from_rec[count1].
   credited_dt_tm = frm.credited_dt_tm
   IF (v_ocii_exists=1)
    rreclist->from_rec[count1].offset_charge_item_id = frm.offset_charge_item_id
   ENDIF
   rreclist->from_rec[count1].beg_effective_dt_tm = frm.beg_effective_dt_tm, rreclist->from_rec[
   count1].activity_type_cd = frm.activity_type_cd, rreclist->from_rec[count1].manual_ind = frm
   .manual_ind,
   rreclist->from_rec[count1].charge_event_id = frm.charge_event_id, rreclist->from_rec[count1].
   tier_group_cd = frm.tier_group_cd
  WITH forupdatewait(frm), nocounter
 ;end select
 SET dm_cmb_blocks = 0.0
 SELECT INTO "nl:"
  d.info_number
  FROM dm_info d
  WHERE d.info_domain="DM COMBINE"
   AND d.info_name="ECMB CHARGE BATCH SIZE"
  DETAIL
   dm_cmb_blocks = d.info_number
  WITH nocounter
 ;end select
 IF (dm_cmb_blocks=0)
  SET dm_cmb_blocks = 1000
 ENDIF
 SET ecc_requestmain->cstart = 0
 SET ecc_requestmain->cend = 0
 WHILE ((ecc_requestmain->cend < count2)
  AND failed=0)
   SET ecc_requestmain->cstart = (ecc_requestmain->cend+ 1)
   SET ecc_requestmain->cend = least(count2,(ecc_requestmain->cend+ dm_cmb_blocks))
   CALL echo(build("Performing combine for records: ",ecc_requestmain->cstart," to:",ecc_requestmain
     ->cend))
   CALL echo("-----")
   EXECUTE encntr_cmb_charge_child
 ENDWHILE
 CALL echorecord(request,"ccluserdir:xxx_cmb.dat")
 IF (failed)
  GO TO end_of_program
 ENDIF
 FREE SET rreclist
 FREE SET rcolumns
 FREE SET modcolumns
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
 ENDIF
#end_of_program
END GO

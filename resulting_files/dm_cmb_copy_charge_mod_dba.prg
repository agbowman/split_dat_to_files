CREATE PROGRAM dm_cmb_copy_charge_mod:dba
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
 CALL echo("copy_charge_mod")
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
  WHERE (c.charge_item_id=dcccm_request->sbr_ccm_ciicc)
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
    IF (x=mod_count)
     SET v_comma_str = " "
    ELSE
     SET v_comma_str = ","
    ENDIF
    CASE (trim(modcolumns->col[x].col_name))
     OF "CHARGE_MOD_ID":
      CALL parser(build("ccm_new_nbrc",v_comma_str))
     OF "CHARGE_ITEM_ID":
      CALL parser(build("dcccm_request->sbr_ccm_inNBR",v_comma_str))
     OF "BEG_EFFECTIVE_DT_TM":
      CALL parser(build("cnvtdatetime(curdate,curtime3)",v_comma_str))
     OF "END_EFFECTIVE_DT_TM":
      CALL parser(build('cnvtdatetime("31-DEC-2100")',v_comma_str))
     OF "ACTIVE_IND":
      CALL parser(build("1",v_comma_str))
     OF "ACTIVE_STATUS_CD":
      CALL parser(build("active_code",v_comma_str))
     OF "ACTIVE_STATUS_PRSNL_ID":
      CALL parser(build("ReqInfo->updt_id",v_comma_str))
     OF "ACTIVE_STATUS_DT_TM":
      CALL parser(build("cnvtdatetime(curdate,curtime3)",v_comma_str))
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
   IF ((dcccm_request->sbr_ccm_process_type="*C"))
    SET icombinedet += 1
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].combine_action_cd = add
    SET request->xxx_combine_det[icombinedet].entity_id = ccm_new_nbrc
    SET request->xxx_combine_det[icombinedet].entity_name = "CHARGE_MOD"
    IF ((dcccm_request->sbr_ccm_process_type="PC"))
     SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
    ELSE
     SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
    ENDIF
   ENDIF
 ENDFOR
#end_of_program
END GO

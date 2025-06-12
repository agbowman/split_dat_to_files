CREATE PROGRAM aps_add_report_params:dba
 IF ( NOT (validate(ppr_action_max,0)))
  DECLARE ppr_action_max = i2 WITH public, constant(65535)
  DECLARE ppr_action_none = i2 WITH public, constant(0)
  DECLARE ppr_action_add = i2 WITH public, constant(1)
  DECLARE ppr_action_del = i2 WITH public, constant(2)
  DECLARE ppr_action_chg = i2 WITH public, constant(4)
  DECLARE ppr_action_ina = i2 WITH public, constant(8)
  DECLARE ppr_action_parent_chg = i2 WITH public, constant(16)
  DECLARE ppr_action_chld_chg = i2 WITH public, constant(32)
  DECLARE ppr_action_both_chg = i2 WITH public, constant(64)
  DECLARE ppr_action_del_no_id = i2 WITH public, constant(128)
  DECLARE ppr_hnauser_directoryon = i2 WITH public, constant(1)
  DECLARE ppr_hnauser_securityon = i2 WITH public, constant(2)
  DECLARE ppr_null_date = vc WITH public, constant("31-DEC-2100 23:59:59")
  DECLARE ppr_seq_name = vc WITH public, constant("PATIENT_PRIVACY_SEQ")
  SUBROUTINE (add_dm_info(domain=vc(value),name=vc(value),val_number=f8(value),val_char=vc(value),
   val_date=q8(value)) =i2)
    EXECUTE gm_dm_info2388_def "I"
    SUBROUTINE (gm_i_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_number":
        SET gm_i_dm_info2388_req->qual[iqual].info_number = ival
        SET gm_i_dm_info2388_req->info_numberi = 1
       OF "info_long_id":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_i_dm_info2388_req->qual[iqual].info_long_id = ival
        SET gm_i_dm_info2388_req->info_long_idi = 1
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (gm_i_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_date":
        SET gm_i_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
        SET gm_i_dm_info2388_req->info_datei = 1
       OF "updt_dt_tm":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_i_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
        SET gm_i_dm_info2388_req->updt_dt_tmi = 1
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (gm_i_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_domain":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_i_dm_info2388_req->qual[iqual].info_domain = ival
        SET gm_i_dm_info2388_req->info_domaini = 1
       OF "info_name":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_i_dm_info2388_req->qual[iqual].info_name = ival
        SET gm_i_dm_info2388_req->info_namei = 1
       OF "info_char":
        SET gm_i_dm_info2388_req->qual[iqual].info_char = ival
        SET gm_i_dm_info2388_req->info_chari = 1
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SET gm_i_dm_info2388_req->allow_partial_ind = 0
    SET gm_i_dm_info2388_req->info_numberi = 1
    SET gm_i_dm_info2388_req->info_domaini = 1
    SET gm_i_dm_info2388_req->info_namei = 1
    SET gm_i_dm_info2388_req->info_chari = 1
    SET stat = alterlist(gm_i_dm_info2388_req->qual,1)
    SET gm_i_dm_info2388_req->qual[1].info_domain = domain
    SET gm_i_dm_info2388_req->qual[1].info_name = name
    SET gm_i_dm_info2388_req->qual[1].info_number = val_number
    SET gm_i_dm_info2388_req->qual[1].info_char = val_char
    IF (val_date > 0)
     SET gm_i_dm_info2388_req->info_datei = 1
     SET gm_i_dm_info2388_req->qual[1].info_date = val_date
    ENDIF
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","GM_I_DM_INFO2388_REQ"), replace("REPLY",
     "GM_I_DM_INFO2388_REP")
    IF ((gm_i_dm_info2388_rep->status_data.status="S"))
     FREE RECORD gm_i_dm_info2388_req
     FREE RECORD gm_i_dm_info2388_rep
     RETURN(0)
    ELSE
     FREE RECORD gm_i_dm_info2388_req
     FREE RECORD gm_i_dm_info2388_rep
     RETURN(1)
    ENDIF
  END ;Subroutine
  SUBROUTINE (upt_dm_info(domain=vc(value),name=vc(value),val_number=f8(value),val_char=vc(value),
   val_date=q8(value)) =i2)
    EXECUTE gm_dm_info2388_def "U"
    SUBROUTINE (gm_u_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_number":
        IF (null_ind=1)
         SET gm_u_dm_info2388_req->info_numberf = 2
        ELSE
         SET gm_u_dm_info2388_req->info_numberf = 1
        ENDIF
        SET gm_u_dm_info2388_req->qual[iqual].info_number = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_numberw = 1
        ENDIF
       OF "info_long_id":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_u_dm_info2388_req->info_long_idf = 1
        SET gm_u_dm_info2388_req->qual[iqual].info_long_id = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_long_idw = 1
        ENDIF
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (gm_u_dm_info2388_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "updt_cnt":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_u_dm_info2388_req->updt_cntf = 1
        SET gm_u_dm_info2388_req->qual[iqual].updt_cnt = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->updt_cntw = 1
        ENDIF
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (gm_u_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_date":
        IF (null_ind=1)
         SET gm_u_dm_info2388_req->info_datef = 2
        ELSE
         SET gm_u_dm_info2388_req->info_datef = 1
        ENDIF
        SET gm_u_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_datew = 1
        ENDIF
       OF "updt_dt_tm":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_u_dm_info2388_req->updt_dt_tmf = 1
        SET gm_u_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->updt_dt_tmw = 1
        ENDIF
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (gm_u_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
      DECLARE stat = i2 WITH protect, noconstant(0)
      IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
       SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
       IF (stat=0)
        CALL echo("can not expand request structure")
        RETURN(0)
       ENDIF
      ENDIF
      CASE (cnvtlower(icol_name))
       OF "info_domain":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_u_dm_info2388_req->info_domainf = 1
        SET gm_u_dm_info2388_req->qual[iqual].info_domain = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_domainw = 1
        ENDIF
       OF "info_name":
        IF (null_ind=1)
         CALL echo("error can not set this column to null")
         RETURN(0)
        ENDIF
        SET gm_u_dm_info2388_req->info_namef = 1
        SET gm_u_dm_info2388_req->qual[iqual].info_name = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_namew = 1
        ENDIF
       OF "info_char":
        IF (null_ind=1)
         SET gm_u_dm_info2388_req->info_charf = 2
        ELSE
         SET gm_u_dm_info2388_req->info_charf = 1
        ENDIF
        SET gm_u_dm_info2388_req->qual[iqual].info_char = ival
        IF (wq_ind=1)
         SET gm_u_dm_info2388_req->info_charw = 1
        ENDIF
       ELSE
        CALL echo("invalid column name passed")
        RETURN(0)
      ENDCASE
      RETURN(1)
    END ;Subroutine
    SET gm_u_dm_info2388_req->allow_partial_ind = 0
    SET gm_u_dm_info2388_req->force_updt_ind = 1
    SET gm_u_dm_info2388_req->info_charf = 1
    SET gm_u_dm_info2388_req->info_numberf = 1
    SET gm_u_dm_info2388_req->info_domainw = 1
    SET gm_u_dm_info2388_req->info_namew = 1
    SET stat = alterlist(gm_u_dm_info2388_req->qual,1)
    SET gm_u_dm_info2388_req->qual[1].info_domain = domain
    SET gm_u_dm_info2388_req->qual[1].info_name = name
    SET gm_u_dm_info2388_req->qual[1].info_char = val_char
    SET gm_u_dm_info2388_req->qual[1].info_number = val_number
    IF (val_date > 0)
     SET gm_u_dm_info2388_req->info_datef = 1
     SET gm_u_dm_info2388_req->qual[1].info_date = val_date
    ENDIF
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","GM_U_DM_INFO2388_REQ"), replace("REPLY",
     "GM_U_DM_INFO2388_REP")
    IF ((gm_u_dm_info2388_rep->status_data.status="S"))
     FREE RECORD gm_u_dm_info2388_req
     FREE RECORD gm_u_dm_info2388_rep
     RETURN(0)
    ELSE
     FREE RECORD gm_u_dm_info2388_req
     FREE RECORD gm_u_dm_info2388_rep
     RETURN(1)
    ENDIF
  END ;Subroutine
  SUBROUTINE (ens_dm_info(domain=vc(value),name=vc(value),val_number=f8(value),val_char=vc(value),
   val_date=q8(value)) =i2)
    DECLARE row_exists_ind = i2 WITH protected, noconstant(0)
    DECLARE success_ind = i2 WITH protected, noconstant(0)
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain=domain
      AND d.info_name=name
     DETAIL
      row_exists_ind = 1
     WITH nocounter
    ;end select
    IF (row_exists_ind=1)
     SET success_ind = upt_dm_info(domain,name,val_number,val_char,val_date)
    ELSE
     SET success_ind = add_dm_info(domain,name,val_number,val_char,val_date)
    ENDIF
    RETURN(success_ind)
  END ;Subroutine
  SUBROUTINE (convert_id_to_string(id=f8(value),digit_cnt=i4(value)) =vc)
    DECLARE id_str = vc WITH private, noconstant("")
    DECLARE id_len = i4 WITH private, noconstant(0)
    DECLARE decimal_pos = i4 WITH private, noconstant(0)
    DECLARE idx = i4 WITH private, noconstant(0)
    SET id_str = trim(cnvtstring(id))
    SET id_len = size(id_str)
    IF (id_len > 0)
     SET decimal_pos = findstring(".",id_str)
     IF (decimal_pos > 0)
      SET id_str = substring(1,(decimal_pos - 1),id_str)
     ENDIF
     IF (digit_cnt > 0)
      SET id_str = concat(id_str,".")
      FOR (idx = 1 TO digit_cnt)
        SET id_str = concat(id_str,"0")
      ENDFOR
     ENDIF
    ENDIF
    RETURN(id_str)
  END ;Subroutine
  SUBROUTINE (ppr_column_exists(stable=vc(value),scolumn=vc(value)) =i4)
    DECLARE ce_flag = i4 WITH public, noconstant(0)
    DECLARE stablename = vc WITH public, noconstant(" ")
    DECLARE scolumnname = vc WITH public, noconstant(" ")
    SET ce_flag = 0
    SET stablename = cnvtupper(stable)
    SET scolumnname = cnvtupper(scolumn)
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stablename
      AND l.attr_name=scolumnname
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
    RETURN(ce_flag)
  END ;Subroutine
  SUBROUTINE (directory_status(nhnausermode=i4) =i2)
   IF (nhnausermode=0)
    RETURN(0)
   ELSEIF (nhnausermode < 0)
    RETURN(- (1))
   ELSE
    IF (((nhnausermode - ppr_hnauser_securityon) >= 0))
     SET nhnausermode -= ppr_hnauser_securityon
    ENDIF
    IF (((nhnausermode - ppr_hnauser_directoryon) >= 0))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
  END ;Subroutine
  SUBROUTINE (security_status(nhnausermode=i4) =i2)
   IF (nhnausermode=0)
    RETURN(0)
   ELSEIF (nhnausermode < 0)
    RETURN(- (1))
   ELSE
    IF (((nhnausermode - ppr_hnauser_securityon) >= 0))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
  END ;Subroutine
 ENDIF
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 IF ( NOT (validate(upd_codeset_req,0)))
  RECORD upd_codeset_req(
    1 qual[*]
      2 code_value = f8
      2 code_set = i4
      2 cdf_meaning = c12
      2 display = c40
      2 description = c60
      2 definition = c100
      2 collation_seq = i4
      2 active_ind = i2
      2 cv_key = vc
  )
 ENDIF
 IF ( NOT (validate(upd_codeset_rep,0)))
  RECORD upd_codeset_rep(
    1 qual[*]
      2 code_value = f8
      2 cv_key = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD reply(
   1 query_cd = f8
   1 qual[*]
     2 query_param_id = f8
     2 sequence = i4
     2 freetext_long_text_id = f8
     2 synoptic_ccl_long_text_id = f8
     2 synoptic_xml_long_text_id = f8
   1 org_qual[*]
     2 organization_id = f8
     2 filter_entity_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD aptemp(
   1 qual[*]
     2 parent_entity_name = c30
 )
 RECORD filter_entity_req(
   1 validate_refdata_ind = i2
   1 delete_all_ind = i2
   1 filter_entity[*]
     2 filter_type_cd = f8
     2 filter_type_data_id = f8
     2 filter_entity1_id = f8
     2 filter_entity1_name = c30
     2 filter_entity2_id = f8
     2 filter_entity2_name = c30
     2 filter_entity3_id = f8
     2 filter_entity3_name = c30
     2 filter_entity4_id = f8
     2 filter_entity4_name = c30
     2 filter_entity5_id = f8
     2 filter_entity5_name = c30
     2 action_flag = i2
     2 safe_for_action = i2
     2 values[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 exclusion_filter_ind = i2
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 filter_entity_reltn_id = f8
       3 action_flag_values = i2
       3 validated_data = i2
 )
 RECORD filter_entity_rep(
   1 filter_entity[*]
     2 filter_type_data_id = f8
     2 festatus = i4
     2 feerrnum = i4
     2 feerrmsg = c132
     2 values[*]
       3 filter_entity_reltn_id = f8
       3 valstatus = i4
       3 errnum = i4
       3 errmsg = c132
   1 scriptstatus = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 IF (validate(_sacrtl_org_inc_,99999)=99999)
  DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
  RECORD sac_org(
    1 organizations[*]
      2 organization_id = f8
      2 confid_cd = f8
      2 confid_level = i4
  )
  EXECUTE secrtl
  EXECUTE sacrtl
  DECLARE orgcnt = i4 WITH protected, noconstant(0)
  DECLARE secstat = i2
  DECLARE logontype = i4 WITH protect, noconstant(- (1))
  DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
  DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
  DECLARE dynorg_enabled = i4 WITH constant(1)
  DECLARE dynorg_disabled = i4 WITH constant(0)
  DECLARE logontype_nhs = i4 WITH constant(1)
  DECLARE logontype_legacy = i4 WITH constant(0)
  DECLARE confid_cnt = i4 WITH protected, noconstant(0)
  RECORD confid_codes(
    1 list[*]
      2 code_value = f8
      2 coll_seq = f8
  )
  CALL uar_secgetclientlogontype(logontype)
  CALL echo(build("logontype:",logontype))
  IF (logontype != logontype_nhs)
   SET dynamic_org_ind = dynorg_disabled
  ENDIF
  IF (logontype=logontype_nhs)
   SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
     DECLARE scur_trust = vc
     DECLARE pref_val = vc
     DECLARE is_enabled = i4 WITH constant(1)
     DECLARE is_disabled = i4 WITH constant(0)
     SET scur_trust = cnvtstring(dtrustid)
     SET scur_trust = concat(scur_trust,".00")
     IF ( NOT (validate(pref_req,0)))
      RECORD pref_req(
        1 write_ind = i2
        1 delete_ind = i2
        1 pref[*]
          2 contexts[*]
            3 context = vc
            3 context_id = vc
          2 section = vc
          2 section_id = vc
          2 subgroup = vc
          2 entries[*]
            3 entry = vc
            3 values[*]
              4 value = vc
      )
     ENDIF
     IF ( NOT (validate(pref_rep,0)))
      RECORD pref_rep(
        1 pref[*]
          2 section = vc
          2 section_id = vc
          2 subgroup = vc
          2 entries[*]
            3 pref_exists_ind = i2
            3 entry = vc
            3 values[*]
              4 value = vc
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
     ENDIF
     SET stat = alterlist(pref_req->pref,1)
     SET stat = alterlist(pref_req->pref[1].contexts,2)
     SET stat = alterlist(pref_req->pref[1].entries,1)
     SET pref_req->pref[1].contexts[1].context = "organization"
     SET pref_req->pref[1].contexts[1].context_id = scur_trust
     SET pref_req->pref[1].contexts[2].context = "default"
     SET pref_req->pref[1].contexts[2].context_id = "system"
     SET pref_req->pref[1].section = "workflow"
     SET pref_req->pref[1].section_id = "UK Trust Security"
     SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
     EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
     IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
      RETURN(is_enabled)
     ELSE
      RETURN(is_disabled)
     ENDIF
   END ;Subroutine
   DECLARE hprop = i4 WITH protect, noconstant(0)
   DECLARE tmpstat = i2
   DECLARE spropname = vc
   DECLARE sroleprofile = vc
   SET hprop = uar_srvcreateproperty()
   SET tmpstat = uar_secgetclientattributesext(5,hprop)
   SET spropname = uar_srvfirstproperty(hprop)
   SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
   SELECT INTO "nl:"
    FROM prsnl_org_reltn_type prt,
     prsnl_org_reltn por
    PLAN (prt
     WHERE prt.role_profile=sroleprofile
      AND prt.active_ind=1
      AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (por
     WHERE (por.organization_id= Outerjoin(prt.organization_id))
      AND (por.person_id= Outerjoin(prt.prsnl_id))
      AND (por.active_ind= Outerjoin(1))
      AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY por.prsnl_org_reltn_id
    DETAIL
     orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
     sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
     confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
     sac_org->organizations[1].confid_level =
     IF (confid_cd > 0) confid_cd
     ELSE 0
     ENDIF
    WITH maxrec = 1
   ;end select
   SET dcur_trustid = sac_org->organizations[1].organization_id
   SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
   CALL uar_srvdestroyhandle(hprop)
  ENDIF
  IF (dynamic_org_ind=dynorg_disabled)
   SET confid_cnt = 0
   SELECT INTO "NL:"
    c.code_value, c.collation_seq
    FROM code_value c
    WHERE c.code_set=87
    DETAIL
     confid_cnt += 1
     IF (mod(confid_cnt,10)=1)
      secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
     ENDIF
     confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
     coll_seq = c.collation_seq
    WITH nocounter
   ;end select
   SET secstat = alterlist(confid_codes->list,confid_cnt)
   SELECT DISTINCT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
    HEAD REPORT
     IF (orgcnt > 0)
      secstat = alterlist(sac_org->organizations,100)
     ENDIF
    DETAIL
     orgcnt += 1
     IF (mod(orgcnt,100)=1)
      secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
     ENDIF
     sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
     orgcnt].confid_cd = por.confid_level_cd
    FOOT REPORT
     secstat = alterlist(sac_org->organizations,orgcnt)
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(orgcnt)),
     (dummyt d2  WITH seq = value(confid_cnt))
    PLAN (d1)
     JOIN (d2
     WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
    DETAIL
     sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
    WITH nocounter
   ;end select
  ELSEIF (dynamic_org_ind=dynorg_enabled)
   DECLARE nhstrustchild_org_org_reltn_cd = f8
   SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
   SELECT INTO "nl:"
    FROM org_org_reltn oor
    PLAN (oor
     WHERE oor.organization_id=dcur_trustid
      AND oor.active_ind=1
      AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
    HEAD REPORT
     IF (orgcnt > 0)
      secstat = alterlist(sac_org->organizations,10)
     ENDIF
    DETAIL
     IF (oor.related_org_id > 0)
      orgcnt += 1
      IF (mod(orgcnt,10)=1)
       secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
      ENDIF
      sac_org->organizations[orgcnt].organization_id = oor.related_org_id
     ENDIF
    FOOT REPORT
     secstat = alterlist(sac_org->organizations,orgcnt)
    WITH nocounter
   ;end select
  ELSE
   CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
  ENDIF
 ENDIF
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE lcounter = i4 WITH protect, noconstant(0)
 DECLARE dsearch_item = f8 WITH protect, noconstant(0.0)
 DECLARE lindex_var = i4 WITH protect, noconstant(1)
 DECLARE lend_pos = i4 WITH protect, noconstant(0)
 SET lend_pos = size(sac_org->organizations,5)
 DECLARE scase_accprefix = c20 WITH protect, constant("CASE_ACCPREFIX")
 DECLARE scase_casetype = c20 WITH protect, constant("CASE_CASETYPE")
 DECLARE scase_catalogcd = c20 WITH protect, constant("CASE_CATALOGCD")
 DECLARE scase_client = c20 WITH protect, constant("CASE_CLIENT")
 DECLARE scase_queryresult = c20 WITH protect, constant("CASE_QUERYRESULT")
 DECLARE scase_reqphys = c20 WITH protect, constant("CASE_REQPHYS")
 DECLARE scase_resppath = c20 WITH protect, constant("CASE_RESPPATH")
 DECLARE scase_respresi = c20 WITH protect, constant("CASE_RESPRESI")
 DECLARE scase_specimen = c20 WITH protect, constant("CASE_SPECIMEN")
 DECLARE scase_taskassay = c20 WITH protect, constant("CASE_TASKASSAY")
 DECLARE scase_verid = c20 WITH protect, constant("CASE_VERID")
 DECLARE scriteria_diagcode1 = c20 WITH protect, constant("CRITERIA_DIAGCODE1")
 DECLARE scriteria_diagcode2 = c20 WITH protect, constant("CRITERIA_DIAGCODE2")
 DECLARE scriteria_diagcode3 = c20 WITH protect, constant("CRITERIA_DIAGCODE3")
 DECLARE scriteria_diagcode4 = c20 WITH protect, constant("CRITERIA_DIAGCODE4")
 DECLARE scriteria_diagcode5 = c20 WITH protect, constant("CRITERIA_DIAGCODE5")
 DECLARE scriteria_internal = c20 WITH protect, constant("CRITERIA_INTERNAL")
 DECLARE spatient_ethnicgroup = c20 WITH protect, constant("PATIENT_ETHNICGROUP")
 DECLARE spatient_gender = c20 WITH protect, constant("PATIENT_GENDER")
 DECLARE spatient_race = c20 WITH protect, constant("PATIENT_RACE")
 DECLARE spatient_species = c20 WITH protect, constant("PATIENT_SPECIES")
 DECLARE spatient_military = c20 WITH protect, constant("PATIENT_MILITARY")
 DECLARE scode_value = c30 WITH protect, constant("CODE_VALUE")
 DECLARE sprsnl = c30 WITH protect, constant("PRSNL")
 DECLARE sap_prefix = c30 WITH protect, constant("AP_PREFIX")
 DECLARE sorganization = c30 WITH protect, constant("ORGANIZATION")
 DECLARE sap_case_query = c30 WITH protect, constant("AP_CASE_QUERY")
 DECLARE snomenclature = c30 WITH protect, constant("NOMENCLATURE")
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE dfacilitytype = f8 WITH protect, noconstant(0.0)
 DECLARE dtemplatefiltertype = f8 WITH protect, noconstant(0.0)
 WHILE (lindex=0
  AND lcounter < size(request->org_qual,5))
   SET lcounter += 1
   SET dsearch_item = request->org_qual[lcounter].organization_id
   SET lindex = locateval(lindex_var,1,lend_pos,dsearch_item,sac_org->organizations[lindex_var].
    organization_id)
 ENDWHILE
 IF (lindex=0
  AND size(request->org_qual,5) != 0)
  GO TO no_role_profile_association_error
 ENDIF
 SET dfacilitytype = uar_get_code_by("MEANING",278,"FACILITY")
 IF (dfacilitytype <= 0)
  CALL subevent_add("UAR","F","UAR_GET_CODE_BY","278_FACILITY")
  GO TO exit_script
 ENDIF
 SET dtemplatefiltertype = uar_get_code_by("MEANING",30620,"CS14252")
 IF (dtemplatefiltertype <= 0)
  CALL subevent_add("UAR","F","UAR_GET_CODE_BY","30620_CS14252")
  GO TO exit_script
 ENDIF
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nbr_to_insert = cnvtint(size(request->qual,5))
 SET lnbrorgstoinsert = cnvtint(size(request->org_qual,5))
 SET index = 0
 SET stat = alterlist(reply->qual,nbr_to_insert)
 SET stat = alterlist(filter_entity_req->filter_entity,lnbrorgstoinsert)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE trim(request->short_name)=trim(cv.display)
    AND (cv.code_set=request->code_set)
    AND cv.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN cv.begin_effective_dt_tm AND cv.end_effective_dt_tm
    AND cv.cdf_meaning IN ("", "PATHNET-AP"))
  DETAIL
   reply->query_cd = cv.code_value
  WITH nocounter
 ;end select
 IF ((reply->query_cd > 0))
  SELECT INTO "nl:"
   FROM org_type_reltn o
   PLAN (o
    WHERE expand(lindex_var,1,lend_pos,o.organization_id,sac_org->organizations[lindex_var].
     organization_id)
     AND o.org_type_cd=dfacilitytype)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SELECT INTO "nl:"
    f.parent_entity_id
    FROM filter_entity_reltn f
    PLAN (f
     WHERE (f.parent_entity_id=reply->query_cd)
      AND cnvtdatetime(sysdate) BETWEEN f.beg_effective_dt_tm AND f.end_effective_dt_tm)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SELECT INTO "nl:"
     f.parent_entity_id
     FROM filter_entity_reltn f
     PLAN (f
      WHERE (f.parent_entity_id=reply->query_cd)
       AND expand(lindex_var,1,lend_pos,f.filter_entity1_id,sac_org->organizations[lindex_var].
       organization_id)
       AND cnvtdatetime(sysdate) BETWEEN f.beg_effective_dt_tm AND f.end_effective_dt_tm)
     WITH nocounter
    ;end select
    IF (curqual=0)
     GO TO no_association_error
    ENDIF
   ENDIF
  ENDIF
  GO TO dup_error
 ENDIF
 SET stat = initrec(upd_codeset_req)
 SET stat = alterlist(upd_codeset_req->qual,1)
 SET upd_codeset_req->qual[1].code_value = 0.0
 SET upd_codeset_req->qual[1].code_set = request->code_set
 SET upd_codeset_req->qual[1].cdf_meaning = "PATHNET-AP"
 SET upd_codeset_req->qual[1].display = trim(request->short_name)
 SET upd_codeset_req->qual[1].description = trim(request->description)
 SET upd_codeset_req->qual[1].active_ind = 1
 EXECUTE pcs_upd_code_values  WITH replace("REQUEST","UPD_CODESET_REQ"), replace("REPLY",
  "UPD_CODESET_REP")
 IF ((upd_codeset_rep->status_data.status != "S"))
  GO TO c_failed
 ELSE
  SET reply->query_cd = upd_codeset_rep->qual[1].code_value
 ENDIF
 SET stat = alterlist(aptemp->qual,nbr_to_insert)
 FOR (index = 1 TO nbr_to_insert)
   SELECT INTO "nl:"
    seq_nbr = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     reply->qual[index].query_param_id = cnvtreal(seq_nbr), reply->qual[index].sequence = request->
     qual[index].sequence
    WITH format, counter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
   IF ((request->qual[index].param_name="CRITERIA_FREETEXT"))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      reply->qual[index].freetext_long_text_id = cnvtreal(seq_nbr)
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO ltseq_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = reply->qual[index].freetext_long_text_id, lt.long_text = request->qual[
      index].freetext_query, lt.parent_entity_name = "AP_DIAG_QUERY_PARAM",
      lt.parent_entity_id = reply->qual[index].query_param_id, lt.active_ind = 1, lt.active_status_cd
       = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
      lt.updt_dt_tm = cnvtdatetime(sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     GO TO lt_failed
    ENDIF
   ENDIF
   IF ((request->qual[index].param_name="CRITERIA_SYNOPTIC"))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      reply->qual[index].synoptic_ccl_long_text_id = cnvtreal(seq_nbr)
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO ltseq_failed
    ENDIF
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      reply->qual[index].synoptic_xml_long_text_id = cnvtreal(seq_nbr)
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO ltseq_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = reply->qual[index].synoptic_ccl_long_text_id, lt.long_text = request->
      qual[index].synoptic_ccl_query, lt.parent_entity_name = "AP_DIAG_QUERY_PARAM",
      lt.parent_entity_id = reply->qual[index].query_param_id, lt.active_ind = 1, lt.active_status_cd
       = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
      lt.updt_dt_tm = cnvtdatetime(sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     GO TO lt_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = reply->qual[index].synoptic_xml_long_text_id, lt.long_text = request->
      qual[index].synoptic_xml_query, lt.parent_entity_name = "AP_DIAG_QUERY_PARAM",
      lt.parent_entity_id = reply->qual[index].query_param_id, lt.active_ind = 1, lt.active_status_cd
       = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
      lt.updt_dt_tm = cnvtdatetime(sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual != 1)
     GO TO lt_failed
    ENDIF
   ENDIF
   IF ((request->qual[index].begin_value_id > 0.0))
    IF ((request->qual[index].param_name IN (scase_casetype, scase_specimen, spatient_ethnicgroup,
    spatient_gender, spatient_race,
    spatient_species, spatient_military, scase_taskassay, scase_catalogcd)))
     SET aptemp->qual[index].parent_entity_name = scode_value
    ELSEIF ((request->qual[index].param_name IN (scase_reqphys, scase_resppath, scase_respresi,
    scase_verid)))
     SET aptemp->qual[index].parent_entity_name = sprsnl
    ELSEIF ((request->qual[index].param_name=scase_accprefix))
     SET aptemp->qual[index].parent_entity_name = sap_prefix
    ELSEIF ((request->qual[index].param_name=scase_client))
     SET aptemp->qual[index].parent_entity_name = sorganization
    ELSEIF ((request->qual[index].param_name=scase_queryresult))
     SET aptemp->qual[index].parent_entity_name = sap_case_query
    ELSEIF ((request->qual[index].param_name IN (scriteria_diagcode1, scriteria_diagcode2,
    scriteria_diagcode3, scriteria_diagcode4, scriteria_diagcode5,
    scriteria_internal)))
     SET aptemp->qual[index].parent_entity_name = snomenclature
    ENDIF
   ENDIF
 ENDFOR
 INSERT  FROM ap_diag_query_param adqp,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET adqp.query_cd = reply->query_cd, adqp.query_param_id = reply->qual[d.seq].query_param_id, adqp
   .param_name = request->qual[d.seq].param_name,
   adqp.criteria_type_flag = request->qual[d.seq].criteria_type_flag, adqp.date_type_flag = request->
   qual[d.seq].date_type_flag, adqp.beg_value_id = request->qual[d.seq].begin_value_id,
   adqp.beg_value_dt_tm = cnvtdatetime(request->qual[d.seq].begin_value_dt_tm), adqp.end_value_id =
   request->qual[d.seq].end_value_id, adqp.end_value_dt_tm = cnvtdatetime(request->qual[d.seq].
    end_value_dt_tm),
   adqp.negation_ind = request->qual[d.seq].negation_ind, adqp.source_vocabulary_cd = request->qual[d
   .seq].source_vocabulary_cd, adqp.sequence = reply->qual[d.seq].sequence,
   adqp.freetext_long_text_id = reply->qual[d.seq].freetext_long_text_id, adqp.freetext_query_flag =
   request->qual[d.seq].freetext_query_flag, adqp.synoptic_ccl_long_text_id = reply->qual[d.seq].
   synoptic_ccl_long_text_id,
   adqp.synoptic_xml_long_text_id = reply->qual[d.seq].synoptic_xml_long_text_id, adqp
   .synoptic_query_flag = request->qual[d.seq].synoptic_query_flag, adqp.updt_dt_tm = cnvtdatetime(
    sysdate),
   adqp.updt_id = reqinfo->updt_id, adqp.updt_task = reqinfo->updt_task, adqp.updt_applctx = reqinfo
   ->updt_applctx,
   adqp.updt_cnt = 0, adqp.parent_entity_name = aptemp->qual[d.seq].parent_entity_name
  PLAN (d)
   JOIN (adqp
   WHERE (adqp.query_cd=reply->query_cd))
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 IF (curqual != nbr_to_insert)
  GO TO adqp_failed
 ENDIF
 FREE SET aptemp
 IF (lnbrorgstoinsert > 0)
  FOR (lcnt = 1 TO lnbrorgstoinsert)
    SET stat = alterlist(filter_entity_req->filter_entity[lcnt].values,1)
    SET filter_entity_req->filter_entity[lcnt].filter_type_cd = dtemplatefiltertype
    SET filter_entity_req->filter_entity[lcnt].filter_entity1_name = "ORGANIZATION"
    SET filter_entity_req->filter_entity[lcnt].filter_entity2_name = ""
    SET filter_entity_req->filter_entity[lcnt].filter_entity3_name = ""
    SET filter_entity_req->filter_entity[lcnt].filter_entity4_name = ""
    SET filter_entity_req->filter_entity[lcnt].filter_entity5_name = ""
    SET filter_entity_req->filter_entity[lcnt].filter_entity1_id = request->org_qual[lcnt].
    organization_id
    SET filter_entity_req->filter_entity[lcnt].action_flag = ppr_action_add
    SET filter_entity_req->filter_entity[lcnt].values[1].parent_entity_id = reply->query_cd
    SET filter_entity_req->filter_entity[lcnt].values[1].parent_entity_name = "CODE_VALUE"
    SET filter_entity_req->filter_entity[lcnt].values[1].exclusion_filter_ind = 0
    SET filter_entity_req->filter_entity[lcnt].values[1].action_flag_values = ppr_action_add
  ENDFOR
  EXECUTE ppr_ens_filter_ref  WITH replace("REQUEST",filter_entity_req), replace("REPLY",
   filter_entity_rep)
  IF ((filter_entity_rep->status_data.status != "S"))
   GO TO orgs_failed
  ENDIF
  SET stat = alterlist(reply->org_qual,lnbrorgstoinsert)
  FOR (lcnt = 1 TO lnbrorgstoinsert)
   SET reply->org_qual[lcnt].organization_id = request->org_qual[lcnt].organization_id
   SET reply->org_qual[lcnt].filter_entity_id = filter_entity_rep->filter_entity[lcnt].values[1].
   filter_entity_reltn_id
  ENDFOR
 ENDIF
 FREE SET filter_entity_rep
 FREE SET filter_entity_req
 GO TO exit_script
#orgs_failed
 SET reply->status_data.subeventstatus[1].operationname = "execute"
 SET reply->status_data.subeventstatus[1].operationstatus = filter_entity_rep->status_data.status
 SET reply->status_data.subeventstatus[1].targetobjectname = "ppr_ens_filter_ref"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "FILTER_ENTITY_RELTN"
 SET failed = "T"
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "reference_seq"
 SET failed = "T"
 GO TO exit_script
#ltseq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "long_data_seq"
 SET failed = "T"
 GO TO exit_script
#c_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 SET failed = "T"
 GO TO exit_script
#lt_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#adqp_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_DIAG_QUERY_PARAM"
 SET failed = "T"
 GO TO exit_script
#dup_error
 SET reply->status_data.status = "P"
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 SET failed = "T"
 GO TO exit_script
#no_association_error
 SET reply->status_data.status = "P"
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL_ORG_RELTN"
 SET failed = "T"
 GO TO exit_script
#no_role_profile_association_error
 SET reply->status_data.status = "U"
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "FILTER_ENTITY_RELTN"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD sac_org
END GO

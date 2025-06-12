CREATE PROGRAM aps_add_wp_template:dba
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
 RECORD reply(
   1 template_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationstatus = c1
       3 operationname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = c100
   1 org_qual[*]
     2 organization_id = f8
     2 filter_entity_id = f8
 )
 RECORD temp(
   1 qual[1]
     2 long_text_id = f8
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
 DECLARE code_set = i4 WITH protected, noconstant(30620)
 DECLARE code_value = f8 WITH protected, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH protected, noconstant("WPTEMPLATE  ")
 DECLARE dorgfiltercd = f8 WITH protected, noconstant(0.0)
 DECLARE norginsertcnt = i2 WITH constant(cnvtint(size(request->org_qual,5)))
 DECLARE dloctypecd = f8 WITH protected, noconstant(0.0)
 DECLARE lerrcode = i4 WITH protected, noconstant(0)
 DECLARE serrmsg = vc WITH protected, noconstant(" ")
 DECLARE nresultlayoutexistsind = i2 WITH protected, noconstant(0)
 DECLARE ltextitemindex = i4 WITH protected, noconstant(0)
 DECLARE nresultlayoutexistsind_fieldexists = i2 WITH protected, noconstant(0)
 DECLARE nresultlayoutid_fieldexists = i2 WITH protected, noconstant(0)
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
 SET failed = "F"
 SET x = 0
 SET reply->status_data.status = "F"
 SET nbr_text_to_insert = cnvtint(size(request->text_qual,5))
 SET upper_short_desc = cnvtupper(request->short_desc)
 IF (nbr_text_to_insert > 1)
  SET stat = alter(request->text_qual,nbr_text_to_insert)
  SET stat = alter(temp->qual,nbr_text_to_insert)
 ENDIF
 EXECUTE cpm_get_cd_for_cdf
 SET dorgfiltercd = code_value
 IF (dorgfiltercd <= 0)
  GO TO cv_wpt_failed
 ENDIF
 SET code_value = 0.0
 SET code_set = 222
 SET cdf_meaning = "FACILITY"
 EXECUTE cpm_get_cd_for_cdf
 SET dloctypecd = code_value
 IF (dloctypecd <= 0)
  GO TO cv_fac_failed
 ENDIF
 SET lerrcode = error(serrmsg,1)
 SET stat = alterlist(filter_entity_req->filter_entity,norginsertcnt)
 SELECT INTO "nl:"
  t.*
  FROM wp_template t
  PLAN (t
   WHERE (request->type_cd=t.template_type_cd)
    AND upper_short_desc=t.short_desc
    AND (request->activity_type_cd=t.activity_type_cd)
    AND (request->person_id=t.person_id))
  DETAIL
   reply->template_id = t.template_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM filter_entity_reltn fer
   WHERE (fer.parent_entity_id=reply->template_id)
  ;end select
  IF (curqual > 0)
   SELECT DISTINCT INTO "nl:"
    FROM location l,
     filter_entity_reltn fer
    PLAN (fer
     WHERE (fer.parent_entity_id=reply->template_id)
      AND fer.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND fer.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (l
     WHERE expand(lindex_var,1,lend_pos,l.organization_id,sac_org->organizations[lindex_var].
      organization_id)
      AND l.location_type_cd=dloctypecd)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET reply->status_data.status = "P"
   ELSE
    SET reply->status_data.status = "D"
   ENDIF
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  seq_nbr = seq(pathnet_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   reply->template_id = cnvtreal(seq_nbr)
  WITH format, counter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 SELECT INTO "nl:"
  t.*
  FROM wp_template t,
   wp_template_text tx
  PLAN (t
   WHERE t.template_id=0.0)
   JOIN (tx
   WHERE (tx.template_id= Outerjoin(t.template_id)) )
  HEAD REPORT
   nresultlayoutexistsind_fieldexists = validate(t.result_layout_exists_ind),
   nresultlayoutid_fieldexists = validate(tx.pcs_rslt_layout_id)
  WITH nocounter
 ;end select
 IF (curqual != 1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Zero row does not exist in WP_TEMPLATE"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (nresultlayoutexistsind_fieldexists > 0
  AND nresultlayoutid_fieldexists > 0)
  FOR (ltextitemindex = 1 TO size(request->text_qual,5))
    IF ((request->text_qual[ltextitemindex].result_layout_id > 0))
     SET nresultlayoutexistsind = 1
     SET ltextitemindex = (size(request->text_qual,5)+ 1)
    ELSE
     SET nresultlayoutexistsind = 0
    ENDIF
  ENDFOR
  INSERT  FROM wp_template t
   SET t.template_id = reply->template_id, t.template_type_cd = request->type_cd, t.short_desc =
    cnvtupper(request->short_desc),
    t.description = request->description, t.activity_type_cd = request->activity_type_cd, t.person_id
     = request->person_id,
    t.active_ind = request->active_ind, t.updt_dt_tm = cnvtdatetime(curdate,curtime), t.updt_id =
    reqinfo->updt_id,
    t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = 0,
    t.result_layout_exists_ind = nresultlayoutexistsind
   WITH nocounter
  ;end insert
 ELSE
  INSERT  FROM wp_template t
   SET t.template_id = reply->template_id, t.template_type_cd = request->type_cd, t.short_desc =
    cnvtupper(request->short_desc),
    t.description = request->description, t.activity_type_cd = request->activity_type_cd, t.person_id
     = request->person_id,
    t.active_ind = request->active_ind, t.updt_dt_tm = cnvtdatetime(curdate,curtime), t.updt_id =
    reqinfo->updt_id,
    t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual != 1)
  GO TO t_failed
 ENDIF
 FOR (x = 1 TO nbr_text_to_insert)
   IF (nresultlayoutid_fieldexists > 0
    AND (request->text_qual[x].result_layout_id > 0))
    SELECT INTO "nl:"
     prtd.text_display_id
     FROM pcs_rslt_tmplt_dflt prtd
     PLAN (prtd
      WHERE (prtd.pcs_rslt_layout_id=request->text_qual[x].result_layout_id)
       AND prtd.active_ind=1
       AND cnvtdatetime(sysdate) BETWEEN prtd.beg_effective_dt_tm AND prtd.end_effective_dt_tm)
     DETAIL
      temp->qual[x].long_text_id = prtd.text_display_id
     WITH format, counter
    ;end select
   ELSE
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp->qual[x].long_text_id = cnvtreal(seq_nbr)
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO lt_seq_failed
    ENDIF
    INSERT  FROM long_text lt,
      (dummyt d  WITH seq = value(nbr_text_to_insert))
     SET lt.long_text_id = temp->qual[d.seq].long_text_id, lt.parent_entity_name = "WP_TEMPLATE_TEXT",
      lt.parent_entity_id = reply->template_id,
      lt.long_text = request->text_qual[d.seq].text, lt.active_ind = 1, lt.active_status_cd = reqdata
      ->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
      lt.updt_dt_tm = cnvtdatetime(sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (lt
      WHERE (lt.parent_entity_id=reply->template_id))
     WITH nocounter, outerjoin = d, dontexist
    ;end insert
    IF (curqual != 1)
     GO TO lt_failed
    ENDIF
   ENDIF
 ENDFOR
 IF (nresultlayoutexistsind > 0
  AND nresultlayoutid_fieldexists > 0)
  INSERT  FROM wp_template_text tt,
    (dummyt d  WITH seq = value(nbr_text_to_insert))
   SET tt.template_id = reply->template_id, tt.sequence = request->text_qual[d.seq].sequence, tt
    .long_text_id = temp->qual[d.seq].long_text_id,
    tt.updt_dt_tm = cnvtdatetime(sysdate), tt.updt_id = reqinfo->updt_id, tt.updt_task = reqinfo->
    updt_task,
    tt.updt_applctx = reqinfo->updt_applctx, tt.updt_cnt = 0, tt.pcs_rslt_layout_id = request->
    text_qual[d.seq].result_layout_id,
    tt.pcs_rslt_frmt_vrsn_id = request->text_qual[d.seq].format_id
   PLAN (d)
    JOIN (tt
    WHERE (tt.template_id=reply->template_id)
     AND (tt.sequence=request->text_qual[d.seq].sequence))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
 ELSE
  INSERT  FROM wp_template_text tt,
    (dummyt d  WITH seq = value(nbr_text_to_insert))
   SET tt.template_id = reply->template_id, tt.sequence = request->text_qual[d.seq].sequence, tt
    .long_text_id = temp->qual[d.seq].long_text_id,
    tt.updt_dt_tm = cnvtdatetime(sysdate), tt.updt_id = reqinfo->updt_id, tt.updt_task = reqinfo->
    updt_task,
    tt.updt_applctx = reqinfo->updt_applctx, tt.updt_cnt = 0
   PLAN (d)
    JOIN (tt
    WHERE (tt.template_id=reply->template_id)
     AND (tt.sequence=request->text_qual[d.seq].sequence))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
 ENDIF
 IF (curqual != nbr_text_to_insert)
  GO TO tt_failed
 ENDIF
 IF (norginsertcnt > 0)
  FOR (x = 1 TO norginsertcnt)
    SET stat = alterlist(filter_entity_req->filter_entity[x].values,1)
    SET filter_entity_req->filter_entity[x].filter_type_cd = dorgfiltercd
    SET filter_entity_req->filter_entity[x].filter_entity1_name = "ORGANIZATION"
    SET filter_entity_req->filter_entity[x].filter_entity2_name = ""
    SET filter_entity_req->filter_entity[x].filter_entity3_name = ""
    SET filter_entity_req->filter_entity[x].filter_entity4_name = ""
    SET filter_entity_req->filter_entity[x].filter_entity5_name = ""
    SET filter_entity_req->filter_entity[x].filter_entity1_id = request->org_qual[x].organization_id
    SET filter_entity_req->filter_entity[x].action_flag = ppr_action_add
    SET filter_entity_req->filter_entity[x].values[1].parent_entity_id = reply->template_id
    SET filter_entity_req->filter_entity[x].values[1].parent_entity_name = "WP_TEMPLATE"
    SET filter_entity_req->filter_entity[x].values[1].exclusion_filter_ind = 0
    SET filter_entity_req->filter_entity[x].values[1].action_flag_values = ppr_action_add
  ENDFOR
  EXECUTE ppr_ens_filter_ref  WITH replace("REQUEST",filter_entity_req), replace("REPLY",
   filter_entity_rep)
  IF ((filter_entity_rep->status_data.status != "S"))
   GO TO orgs_failed
  ENDIF
  SET stat = alterlist(reply->org_qual,norginsertcnt)
  FOR (x = 1 TO norginsertcnt)
   SET reply->org_qual[x].organization_id = request->org_qual[x].organization_id
   SET reply->org_qual[x].filter_entity_id = filter_entity_rep->filter_entity[x].values[1].
   filter_entity_reltn_id
  ENDFOR
 ENDIF
 GO TO exit_script
#cv_wpt_failed
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CS 30620 - WPTEMPLATE"
 SET failed = "T"
 GO TO exit_script
#cv_fac_failed
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CS 222 - FACILITY"
 SET failed = "T"
 GO TO exit_script
#orgs_failed
 SET reply->status_data.subeventstatus[1].operationname = "execute"
 SET reply->status_data.subeventstatus[1].operationstatus = filter_entity_rep->status_data.status
 SET reply->status_data.subeventstatus[1].targetobjectname = "ppr_ens_filter_ref"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "FILTER_ENTITY_RELTN"
 SET failed = "T"
 GO TO exit_script
#lt_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT_SEQ"
 SET failed = "T"
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHNET_SEQ"
 SET failed = "T"
 GO TO exit_script
#t_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "WP_TEMPLATE"
 SET failed = "T"
 GO TO exit_script
#tt_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "WP_TEMPLATE_TEXT"
 SET failed = "T"
 GO TO exit_script
#lt_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
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
  IF ((reply->status_data.status != "P")
   AND (reply->status_data.status != "D"))
   SET reply->status_data.status = "S"
   COMMIT
  ENDIF
 ELSE
  ROLLBACK
 ENDIF
 FREE RECORD sac_org
END GO

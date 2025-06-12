CREATE PROGRAM aps_get_login_spec_info:dba
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 facility_accn_prefix_cd = f8
   1 qual[*]
     2 accession_id = f8
     2 accession = c21
     2 order_qual[*]
       3 order_id = f8
       3 service_resource_cd = f8
       3 service_resource_disp = c40
       3 requested_by_id = f8
       3 requested_by_name = vc
       3 requesting_physician_reltn_qual[*]
         4 prsnl_reltn_activity_id = f8
         4 prsnl_reltn_id = f8
         4 updt_cnt = i4
       3 order_comment_action_seq = i4
       3 order_comment = vc
       3 order_comment_long_text_id = f8
       3 order_comment_lt_updt_cnt = i4
       3 detail_qual[*]
         4 action_sequence = i4
         4 detail_sequence = i4
         4 field_display_value = vc
         4 field_dt_tm_value = dq8
         4 field_id = f8
         4 field_meaning = c25
         4 field_value = f8
         4 field_meaning_id = f8
         4 reltn_qual[*]
           5 prsnl_reltn_activity_id = f8
           5 prsnl_reltn_id = f8
           5 updt_cnt = i4
       3 nomen_entity_qual[*]
         4 diagnosis_code = c50
         4 nomenclature_id = f8
         4 diagnosis_desc = vc
         4 diag_priority = i4
       3 catalog_cd = f8
       3 container_drawn_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(reltn_get_req,0)))
  RECORD reltn_get_req(
    1 qual[*]
      2 prsnl_id = f8
      2 parent_entity_id = f8
      2 parent_entity_name = c30
      2 entity_type_id = f8
      2 entity_type_name = c30
      2 person_id = f8
      2 encntr_id = f8
      2 order_id = f8
      2 accession_nbr = c20
  )
 ENDIF
 IF ( NOT (validate(reltn_get_rep,0)))
  RECORD reltn_get_rep(
    1 qual[*]
      2 prsnl_reltn[*]
        3 prsnl_reltn_activity_id = f8
        3 prsnl_id = f8
        3 parent_entity_id = f8
        3 parent_entity_name = c30
        3 entity_type_id = f8
        3 entity_type_name = c30
        3 prsnl_reltn_id = f8
        3 person_id = f8
        3 encntr_id = f8
        3 accession_nbr = c20
        3 order_id = f8
        3 usage_nbr = i4
        3 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
#script
 DECLARE nmaxdetailcnt = i4 WITH protect, noconstant(0)
 DECLARE nprsnlcnt = i4 WITH protect, noconstant(0)
 DECLARE nordphyscnt = i4 WITH protect, noconstant(0)
 DECLARE nconsphyscnt = i4 WITH protect, noconstant(0)
 DECLARE dconsultphystypeid = f8 WITH protect, noconstant(0.0)
 DECLARE dorderphystypeid = f8 WITH protect, noconstant(0.0)
 DECLARE nmaxreltncnt = i4 WITH protect, noconstant(0)
 DECLARE nprsnlreltncheckprg = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET acc_cnt = 0
 SET order_cnt = 0
 SET max_order_cnt = 0
 SET detail_cnt = 0
 SET nomen_entity_cnt = 0
 SET accession_id = 0.0
 SET ap_activity_type_cd = 0.0
 SET order_comment_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET order_action_type_cd = 0.0
 SET modify_action_type_cd = 0.0
 SET renew_action_type_cd = 0.0
 SET activate_action_type_cd = 0.0
 SET order_diag_cd = 0.0
 SET order_icd9_cd = 0.0
 SET ordered_order_status_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(333,"CONSULTDOC",1,dconsultphystypeid)
 SET stat = uar_get_meaning_by_codeset(333,"ORDERDOC",1,dorderphystypeid)
 IF (checkprg("PPR_GET_PRSNL_RELTN_ACT") > 0)
  SET nprsnlreltncheckprg = 1
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6003
   AND c.cdf_meaning IN ("ORDER", "RENEW", "MODIFY", "ACTIVATE")
   AND c.active_ind=1
  HEAD REPORT
   order_action_type_cd = 0.0, modify_action_type_cd = 0.0, renew_action_type_cd = 0.0,
   activate_action_type_cd = 0.0
  DETAIL
   CASE (c.cdf_meaning)
    OF "ORDER":
     order_action_type_cd = c.code_value
    OF "MODIFY":
     modify_action_type_cd = c.code_value
    OF "RENEW":
     renew_action_type_cd = c.code_value
    OF "ACTIVATE":
     activate_action_type_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET code_set = 106
 SET cdf_meaning = "AP"
 EXECUTE cpm_get_cd_for_cdf
 SET ap_activity_type_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_order_status_cd = code_value
 SET code_set = 23549
 SET cdf_meaning = "ORDERDIAG"
 EXECUTE cpm_get_cd_for_cdf
 SET order_diag_cd = code_value
 SET code_set = 23549
 SET cdf_meaning = "ORDERICD9"
 EXECUTE cpm_get_cd_for_cdf
 SET order_icd9_cd = code_value
 IF ((request->encntr_id IN (null, 0)))
  SELECT INTO "nl:"
   ac.accession_id
   FROM accession ac
   WHERE (request->accession=ac.accession)
   DETAIL
    acc_cnt += 1, accession_id = ac.accession_id
   WITH nocounter
  ;end select
  IF (acc_cnt=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "A"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "ACCESSION"
   SET reply->status_data.status = "A"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  a.accession_id, o.order_id, osrc_exists = decode(osrc.seq,1,0),
  p_exists = decode(p.seq,1,0)
  FROM ap_login_order_list a,
   encounter e,
   location l,
   accession acc,
   orders o,
   (dummyt d  WITH seq = 1),
   order_serv_res_container osrc,
   (dummyt d1  WITH seq = 1),
   prsnl p
  PLAN (a
   WHERE parser(
    IF (accession_id=0.0) "request->encntr_id = a.encntr_id"
    ELSE "accession_id = a.accession_id"
    ENDIF
    ))
   JOIN (e
   WHERE a.encntr_id=e.encntr_id)
   JOIN (l
   WHERE e.location_cd=l.location_cd)
   JOIN (acc
   WHERE a.accession_id=acc.accession_id)
   JOIN (o
   WHERE a.order_id=o.order_id
    AND ap_activity_type_cd=o.activity_type_cd
    AND ((o.order_status_cd+ 0)=ordered_order_status_cd))
   JOIN (d
   WHERE 1=d.seq)
   JOIN (osrc
   WHERE o.order_id=osrc.order_id)
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (p
   WHERE o.last_update_provider_id=p.person_id)
  ORDER BY acc.accession, a.accession_id, o.order_id
  HEAD REPORT
   acc_cnt = 0, reply->person_id = e.person_id, reply->encntr_id = a.encntr_id,
   reply->encntr_id = a.encntr_id
  HEAD a.accession_id
   order_cnt = 0, acc_cnt += 1, stat = alterlist(reply->qual,acc_cnt),
   reply->qual[acc_cnt].accession_id = a.accession_id, reply->qual[acc_cnt].accession = acc.accession,
   reply->facility_accn_prefix_cd = l.facility_accn_prefix_cd
  HEAD o.order_id
   order_cnt += 1
   IF (order_cnt > max_order_cnt)
    max_order_cnt = order_cnt
   ENDIF
   stat = alterlist(reply->qual[acc_cnt].order_qual,order_cnt), reply->qual[acc_cnt].order_qual[
   order_cnt].order_id = o.order_id, reply->qual[acc_cnt].order_qual[order_cnt].catalog_cd = o
   .catalog_cd
   IF (osrc_exists=1)
    reply->qual[acc_cnt].order_qual[order_cnt].service_resource_cd = osrc.service_resource_cd
   ENDIF
   reply->qual[acc_cnt].order_qual[order_cnt].requested_by_id = o.last_update_provider_id
   IF (p_exists=1)
    reply->qual[acc_cnt].order_qual[order_cnt].requested_by_name = trim(p.name_full_formatted)
   ENDIF
  FOOT  a.accession_id
   stat = alterlist(reply->qual[acc_cnt].order_qual,order_cnt)
  WITH nocounter, outerjoin = d, dontcare = osrc,
   outerjoin = d1, dontcare = p
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_LOGIN_ORDER_LIST"
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->qual,0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d1.seq, d2.seq, od.order_id,
  od.oe_field_id, od.action_sequence
  FROM (dummyt d1  WITH seq = value(acc_cnt)),
   (dummyt d2  WITH seq = value(max_order_cnt)),
   order_action oa,
   order_detail od
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->qual[d1.seq].order_qual,5))
   JOIN (oa
   WHERE (oa.order_id=reply->qual[d1.seq].order_qual[d2.seq].order_id)
    AND ((oa.action_type_cd=order_action_type_cd) OR (((oa.action_type_cd=modify_action_type_cd) OR (
   ((oa.action_type_cd=activate_action_type_cd) OR (oa.action_type_cd=renew_action_type_cd)) )) ))
    AND oa.action_rejected_ind=0)
   JOIN (od
   WHERE od.order_id=oa.order_id
    AND od.action_sequence=oa.action_sequence)
  ORDER BY d1.seq, d2.seq, od.order_id,
   od.oe_field_id, od.action_sequence DESC
  HEAD d1.seq
   detail_cnt = 0, act_seq = 0
  HEAD d2.seq
   detail_cnt = 0, act_seq = 0
  HEAD od.oe_field_id
   act_seq = od.action_sequence, flag = 1
  HEAD od.action_sequence
   IF (act_seq != od.action_sequence)
    flag = 0
   ENDIF
  DETAIL
   IF (flag=1)
    detail_cnt += 1
    IF (mod(detail_cnt,10)=1)
     stat = alterlist(reply->qual[d1.seq].order_qual[d2.seq].detail_qual,(detail_cnt+ 9))
    ENDIF
    IF (detail_cnt > nmaxdetailcnt)
     nmaxdetailcnt = detail_cnt
    ENDIF
    reply->qual[d1.seq].order_qual[d2.seq].detail_qual[detail_cnt].action_sequence = od
    .action_sequence, reply->qual[d1.seq].order_qual[d2.seq].detail_qual[detail_cnt].detail_sequence
     = od.detail_sequence, reply->qual[d1.seq].order_qual[d2.seq].detail_qual[detail_cnt].
    field_display_value = od.oe_field_display_value,
    reply->qual[d1.seq].order_qual[d2.seq].detail_qual[detail_cnt].field_dt_tm_value = cnvtdatetime(
     od.oe_field_dt_tm_value), reply->qual[d1.seq].order_qual[d2.seq].detail_qual[detail_cnt].
    field_id = od.oe_field_id, reply->qual[d1.seq].order_qual[d2.seq].detail_qual[detail_cnt].
    field_meaning = od.oe_field_meaning,
    reply->qual[d1.seq].order_qual[d2.seq].detail_qual[detail_cnt].field_value = od.oe_field_value,
    reply->qual[d1.seq].order_qual[d2.seq].detail_qual[detail_cnt].field_meaning_id = od
    .oe_field_meaning_id
   ENDIF
  FOOT  od.action_sequence
   row + 0
  FOOT  od.oe_field_id
   row + 0
  FOOT  d2.seq
   stat = alterlist(reply->qual[d1.seq].order_qual[d2.seq].detail_qual,detail_cnt)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SET stat = alterlist(reply->qual,acc_cnt)
 SELECT INTO "nl:"
  d1.seq, d2.seq, ocr.order_id
  FROM (dummyt d1  WITH seq = value(acc_cnt)),
   (dummyt d2  WITH seq = value(max_order_cnt)),
   order_container_r ocr,
   container c
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->qual[d1.seq].order_qual,5))
   JOIN (ocr
   WHERE (ocr.order_id=reply->qual[d1.seq].order_qual[d2.seq].order_id))
   JOIN (c
   WHERE c.container_id=ocr.container_id)
  ORDER BY d1.seq, d2.seq, c.drawn_dt_tm DESC
  HEAD d1.seq
   row + 0
  HEAD d2.seq
   reply->qual[d1.seq].order_qual[d2.seq].container_drawn_dt_tm = cnvtdatetime(c.drawn_dt_tm)
  WITH nocounter
 ;end select
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET order_comment_cd = code_value
 SELECT INTO "nl:"
  lt.long_text
  FROM order_comment oc,
   (dummyt d1  WITH seq = value(size(reply->qual,5))),
   (dummyt d2  WITH seq = value(max_order_cnt)),
   long_text lt
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->qual[d1.seq].order_qual,5))
   JOIN (oc
   WHERE (reply->qual[d1.seq].order_qual[d2.seq].order_id=oc.order_id)
    AND oc.comment_type_cd=order_comment_cd)
   JOIN (lt
   WHERE oc.long_text_id=lt.long_text_id)
  ORDER BY d1.seq, d2.seq, oc.order_id,
   oc.action_sequence DESC
  HEAD REPORT
   x = 0
  HEAD d1.seq
   x = 0
  HEAD oc.order_id
   reply->qual[d1.seq].order_qual[d2.seq].order_comment_action_seq = oc.action_sequence, reply->qual[
   d1.seq].order_qual[d2.seq].order_comment_lt_updt_cnt = lt.updt_cnt, reply->qual[d1.seq].
   order_qual[d2.seq].order_comment_long_text_id = lt.long_text_id,
   reply->qual[d1.seq].order_qual[d2.seq].order_comment = trim(lt.long_text)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d1.seq, d2.seq, n.nomenclature_id,
  n.source_string
  FROM (dummyt d1  WITH seq = value(acc_cnt)),
   (dummyt d2  WITH seq = value(max_order_cnt)),
   nomen_entity_reltn ner,
   nomenclature n
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->qual[d1.seq].order_qual,5))
   JOIN (ner
   WHERE ner.parent_entity_name="ORDERS"
    AND (ner.parent_entity_id=reply->qual[d1.seq].order_qual[d2.seq].order_id)
    AND ner.reltn_type_cd=order_diag_cd
    AND ner.active_ind=1
    AND ner.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ner.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=ner.nomenclature_id)
  ORDER BY d1.seq, d2.seq, ner.priority
  HEAD d1.seq
   nomen_entity_cnt = 0
  HEAD d2.seq
   nomen_entity_cnt = 0
  DETAIL
   nomen_entity_cnt += 1, stat = alterlist(reply->qual[d1.seq].order_qual[d2.seq].nomen_entity_qual,
    nomen_entity_cnt), reply->qual[d1.seq].order_qual[d2.seq].nomen_entity_qual[nomen_entity_cnt].
   nomenclature_id = n.nomenclature_id,
   reply->qual[d1.seq].order_qual[d2.seq].nomen_entity_qual[nomen_entity_cnt].diagnosis_code = n
   .source_identifier, reply->qual[d1.seq].order_qual[d2.seq].nomen_entity_qual[nomen_entity_cnt].
   diagnosis_desc = n.source_string, reply->qual[d1.seq].order_qual[d2.seq].nomen_entity_qual[
   nomen_entity_cnt].diag_priority = ner.priority
  WITH nocounter
 ;end select
 IF (nomen_entity_cnt=0)
  SELECT INTO "nl:"
   d1.seq, d2.seq, n.nomenclature_id,
   n.source_string
   FROM (dummyt d1  WITH seq = value(acc_cnt)),
    (dummyt d2  WITH seq = value(max_order_cnt)),
    nomen_entity_reltn ner,
    nomenclature n
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(reply->qual[d1.seq].order_qual,5))
    JOIN (ner
    WHERE ner.parent_entity_name="ORDERS"
     AND (ner.parent_entity_id=reply->qual[d1.seq].order_qual[d2.seq].order_id)
     AND ner.reltn_type_cd=order_icd9_cd
     AND ner.active_ind=1
     AND ner.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND ner.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (n
    WHERE n.nomenclature_id=ner.nomenclature_id)
   ORDER BY d1.seq, d2.seq
   HEAD d1.seq
    nomen_entity_cnt = 0
   HEAD d2.seq
    nomen_entity_cnt = 0
   DETAIL
    nomen_entity_cnt += 1, stat = alterlist(reply->qual[d1.seq].order_qual[d2.seq].nomen_entity_qual,
     nomen_entity_cnt), reply->qual[d1.seq].order_qual[d2.seq].nomen_entity_qual[nomen_entity_cnt].
    nomenclature_id = n.nomenclature_id,
    reply->qual[d1.seq].order_qual[d2.seq].nomen_entity_qual[nomen_entity_cnt].diagnosis_code = n
    .source_identifier, reply->qual[d1.seq].order_qual[d2.seq].nomen_entity_qual[nomen_entity_cnt].
    diagnosis_desc = n.source_string, reply->qual[d1.seq].order_qual[d2.seq].nomen_entity_qual[
    nomen_entity_cnt].diag_priority = ner.priority
   WITH nocounter
  ;end select
 ENDIF
 IF (nprsnlreltncheckprg=1)
  SET nprsnlcnt = 0
  SELECT INTO "nl:"
   d1.*
   FROM (dummyt d1  WITH seq = value(acc_cnt)),
    (dummyt d2  WITH seq = value(max_order_cnt))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(reply->qual[d1.seq].order_qual,5))
   ORDER BY d1.seq, d2.seq
   DETAIL
    nprsnlcnt += 1
    IF (mod(nprsnlcnt,10)=1)
     stat = alterlist(reltn_get_req->qual,(nprsnlcnt+ 9))
    ENDIF
    reltn_get_req->qual[nprsnlcnt].prsnl_id = reply->qual[d1.seq].order_qual[d2.seq].requested_by_id,
    reltn_get_req->qual[nprsnlcnt].parent_entity_name = "ORDERS", reltn_get_req->qual[nprsnlcnt].
    parent_entity_id = reply->qual[d1.seq].order_qual[d2.seq].order_id,
    reltn_get_req->qual[nprsnlcnt].entity_type_name = "CODE_VALUE", reltn_get_req->qual[nprsnlcnt].
    entity_type_id = dorderphystypeid
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d1.*
   FROM (dummyt d1  WITH seq = value(acc_cnt)),
    (dummyt d2  WITH seq = value(max_order_cnt)),
    (dummyt d3  WITH seq = value(nmaxdetailcnt))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(reply->qual[d1.seq].order_qual,5))
    JOIN (d3
    WHERE d3.seq <= size(reply->qual[d1.seq].order_qual[d2.seq].detail_qual,5)
     AND (reply->qual[d1.seq].order_qual[d2.seq].detail_qual[d3.seq].field_meaning="CONSULTDOC"))
   ORDER BY d1.seq, d2.seq, d3.seq
   DETAIL
    nprsnlcnt += 1
    IF (mod(nprsnlcnt,10)=1)
     stat = alterlist(reltn_get_req->qual,(nprsnlcnt+ 9))
    ENDIF
    reltn_get_req->qual[nprsnlcnt].prsnl_id = reply->qual[d1.seq].order_qual[d2.seq].detail_qual[d3
    .seq].field_value, reltn_get_req->qual[nprsnlcnt].parent_entity_name = "ORDERS", reltn_get_req->
    qual[nprsnlcnt].parent_entity_id = reply->qual[d1.seq].order_qual[d2.seq].order_id,
    reltn_get_req->qual[nprsnlcnt].entity_type_name = "CODE_VALUE", reltn_get_req->qual[nprsnlcnt].
    entity_type_id = dconsultphystypeid
   WITH nocounter
  ;end select
  IF (nprsnlcnt > 0)
   SET stat = alterlist(reltn_get_req->qual,nprsnlcnt)
   EXECUTE ppr_get_prsnl_reltn_act  WITH replace("REQUEST","RELTN_GET_REQ"), replace("REPLY",
    "RELTN_GET_REP")
   IF ((reltn_get_rep->status_data.status="S"))
    SELECT INTO "nl:"
     d1.seq
     FROM (dummyt d1  WITH seq = value(size(reltn_get_rep->qual,5)))
     PLAN (d1)
     DETAIL
      IF (size(reltn_get_rep->qual[d1.seq].prsnl_reltn,5) > nmaxreltncnt)
       nmaxreltncnt = size(reltn_get_rep->qual[d1.seq].prsnl_reltn,5)
      ENDIF
     WITH nocounter
    ;end select
    IF (nmaxreltncnt > 0)
     SELECT INTO "nl:"
      d1.seq
      FROM (dummyt d1  WITH seq = value(size(reltn_get_rep->qual,5))),
       (dummyt d2  WITH seq = value(nmaxreltncnt)),
       (dummyt d3  WITH seq = value(acc_cnt)),
       (dummyt d4  WITH seq = value(max_order_cnt)),
       (dummyt d5  WITH seq = value(nmaxdetailcnt))
      PLAN (d1)
       JOIN (d2
       WHERE d2.seq <= size(reltn_get_rep->qual[d1.seq].prsnl_reltn,5))
       JOIN (d3
       WHERE (reply->qual[d3.seq].accession=reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].
       accession_nbr))
       JOIN (d4
       WHERE d4.seq <= size(reply->qual[d3.seq].order_qual,5)
        AND (reply->qual[d3.seq].order_qual[d4.seq].order_id=reltn_get_rep->qual[d1.seq].prsnl_reltn[
       d2.seq].order_id))
       JOIN (d5
       WHERE d5.seq <= size(reply->qual[d3.seq].order_qual[d4.seq].detail_qual,5))
      ORDER BY d3.seq, d4.seq, d5.seq
      HEAD d3.seq
       nordphyscnt = 0
      HEAD d4.seq
       nconsphyscnt = 0
      DETAIL
       IF (d5.seq=1
        AND (reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].entity_type_name="CODE_VALUE")
        AND (reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].entity_type_id=dorderphystypeid)
        AND (reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].prsnl_id=reply->qual[d3.seq].order_qual[
       d4.seq].requested_by_id))
        nordphyscnt += 1, stat = alterlist(reply->qual[d3.seq].order_qual[d4.seq].
         requesting_physician_reltn_qual,nordphyscnt), reply->qual[d3.seq].order_qual[d4.seq].
        requesting_physician_reltn_qual[nordphyscnt].prsnl_reltn_activity_id = reltn_get_rep->qual[d1
        .seq].prsnl_reltn[d2.seq].prsnl_reltn_activity_id,
        reply->qual[d3.seq].order_qual[d4.seq].requesting_physician_reltn_qual[nordphyscnt].
        prsnl_reltn_id = reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].prsnl_reltn_id, reply->qual[
        d3.seq].order_qual[d4.seq].requesting_physician_reltn_qual[nordphyscnt].updt_cnt =
        reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].updt_cnt
       ENDIF
       IF ((reply->qual[d3.seq].order_qual[d4.seq].detail_qual[d5.seq].field_meaning="CONSULTDOC")
        AND (reply->qual[d3.seq].order_qual[d4.seq].detail_qual[d5.seq].field_value=reltn_get_rep->
       qual[d1.seq].prsnl_reltn[d2.seq].prsnl_id)
        AND (reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].entity_type_name="CODE_VALUE")
        AND (reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].entity_type_id=dconsultphystypeid))
        nconsphyscnt += 1, stat = alterlist(reply->qual[d3.seq].order_qual[d4.seq].detail_qual[d5.seq
         ].reltn_qual,nconsphyscnt), reply->qual[d3.seq].order_qual[d4.seq].detail_qual[d5.seq].
        reltn_qual[nconsphyscnt].prsnl_reltn_activity_id = reltn_get_rep->qual[d1.seq].prsnl_reltn[d2
        .seq].prsnl_reltn_activity_id,
        reply->qual[d3.seq].order_qual[d4.seq].detail_qual[d5.seq].reltn_qual[nconsphyscnt].
        prsnl_reltn_id = reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].prsnl_reltn_id, reply->qual[
        d3.seq].order_qual[d4.seq].detail_qual[d5.seq].reltn_qual[nconsphyscnt].updt_cnt =
        reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].updt_cnt
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#exit_script
 FREE RECORD reltn_get_rep
 FREE RECORD reltn_get_req
END GO

CREATE PROGRAM aps_chg_consulting_physicians:dba
 RECORD reply(
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
 IF ( NOT (validate(reltn_ens_req,0)))
  RECORD reltn_ens_req(
    1 validated_data_ind = i2
    1 qual[*]
      2 prsnl_reltn_activity_id = f8
      2 prsnl_id = f8
      2 parent_entity_id = f8
      2 parent_entity_name = c30
      2 entity_type_id = f8
      2 entity_type_name = c30
      2 prsnl_reltn_id = f8
      2 person_id = f8
      2 encntr_id = f8
      2 order_id = f8
      2 accession_nbr = c20
      2 usage_nbr = i4
      2 updt_cnt = i4
      2 action_flag = i2
  )
 ENDIF
 IF ( NOT (validate(reltn_ens_rep,0)))
  RECORD reltn_ens_rep(
    1 qual[*]
      2 status = i2
      2 error_num = i4
      2 error_msg = vc
      2 prsnl_reltn_activity_id = f8
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
 DECLARE nprsnlgetcnt = i4 WITH protect, noconstant(0)
 DECLARE nprsnlenscnt = i4 WITH protect, noconstant(0)
 DECLARE dconsultphystypeid = f8 WITH protect, noconstant(0.0)
 DECLARE dpersonid = f8 WITH protect, noconstant(0.0)
 DECLARE dencntrid = f8 WITH protect, noconstant(0.0)
 DECLARE nmaxreltncnt = i4 WITH protect, noconstant(0)
 DECLARE caccessionnbr = c20 WITH protect, noconstant("")
 DECLARE nprsnlreltncheckprg = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET error_cnt = 0
 SET stat = uar_get_meaning_by_codeset(333,"CONSULTDOC",1,dconsultphystypeid)
 IF (checkprg("PPR_ENS_PRSNL_RELTN_ACT") > 0)
  SET nprsnlreltncheckprg = 1
 ENDIF
 IF (nprsnlreltncheckprg=1)
  SELECT INTO "nl:"
   pc.*
   FROM pathology_case pc
   WHERE (pc.case_id=request->case_id)
   DETAIL
    dpersonid = pc.person_id, dencntrid = pc.encntr_id, caccessionnbr = pc.accession_nbr
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d1.*
   FROM case_provider cp
   PLAN (cp
    WHERE (cp.case_id=request->case_id))
   DETAIL
    nprsnlgetcnt += 1
    IF (mod(nprsnlgetcnt,10)=1)
     stat = alterlist(reltn_get_req->qual,(nprsnlgetcnt+ 9))
    ENDIF
    reltn_get_req->qual[nprsnlgetcnt].prsnl_id = cp.physician_id, reltn_get_req->qual[nprsnlgetcnt].
    parent_entity_id = request->case_id, reltn_get_req->qual[nprsnlgetcnt].parent_entity_name =
    "ACCESSION",
    reltn_get_req->qual[nprsnlgetcnt].entity_type_name = "CODE_VALUE", reltn_get_req->qual[
    nprsnlgetcnt].entity_type_id = dconsultphystypeid
   WITH nocounter
  ;end select
 ENDIF
 DELETE  FROM case_provider cp
  WHERE (request->case_id=cp.case_id)
  WITH nocounter
 ;end delete
 IF ((request->add_cnt > 0))
  INSERT  FROM case_provider cp,
    (dummyt d  WITH seq = value(request->add_cnt))
   SET cp.case_id = request->case_id, cp.physician_id = request->physician_qual[d.seq].physician_id,
    cp.updt_dt_tm = cnvtdatetime(curdate,curtime),
    cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->
    updt_applctx,
    cp.updt_cnt = 0
   PLAN (d)
    JOIN (cp)
   WITH nocounter
  ;end insert
  IF ((curqual != request->add_cnt))
   CALL handle_errors("ADD","F","TABLE","CASE_PROVIDER")
   SET reqinfo->commit_ind = 0
  ELSE
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ENDIF
  IF (nprsnlreltncheckprg=1)
   SELECT INTO "nl:"
    d1.seq
    FROM (dummyt d1  WITH seq = value(request->add_cnt))
    PLAN (d1)
    DETAIL
     IF (size(request->physician_qual[d1.seq].reltn_qual,5) > nmaxreltncnt)
      nmaxreltncnt = size(request->physician_qual[d1.seq].reltn_qual,5)
     ENDIF
    WITH nocounter
   ;end select
   IF (nmaxreltncnt > 0)
    SELECT INTO "nl:"
     d1.*
     FROM (dummyt d1  WITH seq = value(request->add_cnt)),
      (dummyt d2  WITH seq = value(nmaxreltncnt))
     PLAN (d1)
      JOIN (d2
      WHERE d2.seq <= size(request->physician_qual[d1.seq].reltn_qual,5))
     DETAIL
      nprsnlenscnt += 1
      IF (mod(nprsnlenscnt,10)=1)
       stat = alterlist(reltn_ens_req->qual,(nprsnlenscnt+ 9))
      ENDIF
      reltn_ens_req->qual[nprsnlenscnt].parent_entity_id = request->case_id, reltn_ens_req->qual[
      nprsnlenscnt].parent_entity_name = "ACCESSION", reltn_ens_req->qual[nprsnlenscnt].
      entity_type_name = "CODE_VALUE",
      reltn_ens_req->qual[nprsnlenscnt].entity_type_id = dconsultphystypeid, reltn_ens_req->qual[
      nprsnlenscnt].action_flag = ppr_action_add, reltn_ens_req->qual[nprsnlenscnt].prsnl_id =
      request->physician_qual[d1.seq].physician_id,
      reltn_ens_req->qual[nprsnlenscnt].prsnl_reltn_id = request->physician_qual[d1.seq].reltn_qual[
      d2.seq].prsnl_reltn_id, reltn_ens_req->qual[nprsnlenscnt].person_id = dpersonid, reltn_ens_req
      ->qual[nprsnlenscnt].encntr_id = dencntrid,
      reltn_ens_req->qual[nprsnlenscnt].accession_nbr = caccessionnbr, reltn_ens_req->qual[
      nprsnlenscnt].usage_nbr = 1
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 IF (nprsnlgetcnt > 0
  AND (reply->status_data.status="S"))
  SET stat = alterlist(reltn_get_req->qual,nprsnlgetcnt)
  EXECUTE ppr_get_prsnl_reltn_act  WITH replace("REQUEST","RELTN_GET_REQ"), replace("REPLY",
   "RELTN_GET_REP")
  IF ((reltn_get_rep->status_data.status="S"))
   SET nmaxreltncnt = 0
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
     d1.*
     FROM (dummyt d1  WITH seq = value(size(reltn_get_rep->qual,5))),
      (dummyt d2  WITH seq = value(nmaxreltncnt))
     PLAN (d1)
      JOIN (d2
      WHERE d2.seq <= size(reltn_get_rep->qual[d1.seq].prsnl_reltn,5))
     DETAIL
      nprsnlenscnt += 1
      IF (mod(nprsnlenscnt,10)=1)
       stat = alterlist(reltn_ens_req->qual,(nprsnlenscnt+ 9))
      ENDIF
      reltn_ens_req->qual[nprsnlenscnt].action_flag = ppr_action_del, reltn_ens_req->qual[
      nprsnlenscnt].prsnl_reltn_activity_id = reltn_get_rep->qual[d1.seq].prsnl_reltn[d2.seq].
      prsnl_reltn_activity_id, reltn_ens_req->qual[nprsnlenscnt].updt_cnt = reltn_get_rep->qual[d1
      .seq].prsnl_reltn[d2.seq].updt_cnt
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF (nprsnlenscnt > 0
  AND (reply->status_data.status="S"))
  SET reltn_ens_req->validated_data_ind = 1
  SET stat = alterlist(reltn_ens_req->qual,nprsnlenscnt)
  EXECUTE ppr_ens_prsnl_reltn_act  WITH replace("REQUEST","RELTN_ENS_REQ"), replace("REPLY",
   "RELTN_ENS_REP")
  IF ((reltn_ens_rep->status_data.status="F"))
   CALL handle_errors("ADD","F","TABLE","PRSNL_RELTN_ACTIVITY")
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ENDIF
 ENDIF
 FREE RECORD reltn_get_rep
 FREE RECORD reltn_get_req
 FREE RECORD reltn_ens_rep
 FREE RECORD reltn_ens_req
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
END GO

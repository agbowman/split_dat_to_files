CREATE PROGRAM aps_del_report_params:dba
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
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 RECORD deleted_orgs(
   1 qual[*]
     2 organization_id = f8
     2 filter_entity_id = f8
 )
 RECORD temp_long_text(
   1 qual[*]
     2 long_text_id = f8
 )
#script
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE dtemplatefiltertype = f8 WITH protect, noconstant(0.0)
 DECLARE lnbrtodelete = i4 WITH protect, noconstant(0)
 SET failed = "F"
 SET errors = " "
 SET count = 0
 SET number_to_del = 0
 SET reply->status_data.status = "F"
 SET table_error = "    "
 SET del_long_text_id = 0.0
 SET dtemplatefiltertype = uar_get_code_by("MEANING",30620,"CS14252")
 IF (dtemplatefiltertype <= 0)
  CALL subevent_add("UAR","F","UAR_GET_CODE_BY","30620_CS14252")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  adqp.query_cd
  FROM ap_diag_query_param adqp
  WHERE (adqp.query_cd=request->query_cd)
  HEAD REPORT
   number_to_del = 0, del_long_text_id = 0.0, tmp_cnt = 0
  DETAIL
   number_to_del += 1
   IF (adqp.param_name="CRITERIA_FREETEXT")
    tmp_cnt += 1, stat = alterlist(temp_long_text->qual,tmp_cnt), temp_long_text->qual[tmp_cnt].
    long_text_id = adqp.freetext_long_text_id
   ENDIF
   IF (adqp.param_name="CRITERIA_SYNOPTIC")
    tmp_cnt += 1, stat = alterlist(temp_long_text->qual,tmp_cnt), temp_long_text->qual[tmp_cnt].
    long_text_id = adqp.synoptic_ccl_long_text_id,
    tmp_cnt += 1, stat = alterlist(temp_long_text->qual,tmp_cnt), temp_long_text->qual[tmp_cnt].
    long_text_id = adqp.synoptic_xml_long_text_id
   ENDIF
  WITH nocounter
 ;end select
 DELETE  FROM ap_diag_query_param adqp,
   (dummyt d  WITH seq = value(number_to_del))
  SET adqp.query_cd = request->query_cd
  PLAN (d)
   JOIN (adqp
   WHERE (adqp.query_cd=request->query_cd))
  WITH nocounter
 ;end delete
 IF (curqual != number_to_del)
  SET errors = "D"
  SET table_error = "ADQP"
  GO TO check_error
 ENDIF
 SET param_del_cnt = size(temp_long_text->qual,5)
 IF (param_del_cnt != 0)
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(param_del_cnt))
   SET lt.long_text_id = temp_long_text->qual[d.seq].long_text_id
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=temp_long_text->qual[d.seq].long_text_id))
   WITH nocounter
  ;end delete
  IF (curqual != param_del_cnt)
   SET errors = "D"
   SET table_error = "LT"
   GO TO check_error
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE (request->query_cd=cv.code_value)
  WITH forupdate(cv)
 ;end select
 IF (curqual=0)
  SET errors = "L"
  SET table_error = "CV"
  GO TO check_error
 ENDIF
 DELETE  FROM code_value cv
  WHERE (cv.code_value=request->query_cd)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET errors = "D"
  SET table_error = "CV"
  GO TO check_error
 ENDIF
 SELECT INTO "nl:"
  f.filter_entity1_id, f.filter_entity_reltn_id
  FROM filter_entity_reltn f
  WHERE (f.parent_entity_id=request->query_cd)
   AND f.filter_entity1_name="ORGANIZATION"
   AND f.filter_type_cd=dtemplatefiltertype
   AND f.parent_entity_name="CODE_VALUE"
  DETAIL
   lcnt += 1
   IF (mod(lcnt,10)=1)
    stat = alterlist(deleted_orgs->qual,(lcnt+ 9))
   ENDIF
   deleted_orgs->qual[lcnt].organization_id = f.filter_entity1_id, deleted_orgs->qual[lcnt].
   filter_entity_id = f.filter_entity_reltn_id
  WITH nocounter
 ;end select
 SET stat = alterlist(deleted_orgs->qual,lcnt)
 SET lnbrtodelete = cnvtint(size(deleted_orgs->qual,5))
 IF (lnbrtodelete > 0)
  SET stat = alterlist(filter_entity_req->filter_entity,lnbrtodelete)
  FOR (lcnt = 1 TO lnbrtodelete)
    SET stat = alterlist(filter_entity_req->filter_entity[lcnt].values,1)
    SET filter_entity_req->filter_entity[lcnt].filter_type_cd = dtemplatefiltertype
    SET filter_entity_req->filter_entity[lcnt].filter_entity1_name = "ORGANIZATION"
    SET filter_entity_req->filter_entity[lcnt].filter_entity2_name = ""
    SET filter_entity_req->filter_entity[lcnt].filter_entity3_name = ""
    SET filter_entity_req->filter_entity[lcnt].filter_entity4_name = ""
    SET filter_entity_req->filter_entity[lcnt].filter_entity5_name = ""
    SET filter_entity_req->filter_entity[lcnt].filter_entity1_id = deleted_orgs->qual[lcnt].
    organization_id
    SET filter_entity_req->filter_entity[lcnt].action_flag = ppr_action_ina
    SET filter_entity_req->filter_entity[lcnt].values[1].parent_entity_id = request->query_cd
    SET filter_entity_req->filter_entity[lcnt].values[1].parent_entity_name = "CODE_VALUE"
    SET filter_entity_req->filter_entity[lcnt].values[1].exclusion_filter_ind = 0
    SET filter_entity_req->filter_entity[lcnt].values[1].action_flag_values = 0
    SET filter_entity_req->filter_entity[lcnt].values[1].filter_entity_reltn_id = deleted_orgs->qual[
    lcnt].filter_entity_id
  ENDFOR
  FREE SET deleted_orgs
  EXECUTE ppr_ens_filter_ref  WITH replace("REQUEST",filter_entity_req), replace("REPLY",
   filter_entity_rep)
  IF ((filter_entity_rep->status_data.status != "S"))
   GO TO orgs_failed
  ENDIF
  FREE SET filter_entity_req
  FREE SET filter_entity_rep
 ENDIF
 GO TO exit_script
#orgs_failed
 SET reply->status_data.subeventstatus[1].operationname = "execute"
 SET reply->status_data.subeventstatus[1].operationstatus = filter_entity_rep->status_data.status
 SET reply->status_data.subeventstatus[1].targetobjectname = "ppr_ens_filter_ref"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "FILTER_ENTITY_RELTN"
 SET failed = "T"
 GO TO exit_script
#check_error
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 IF (table_error="ADQP")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_DIAG_QUERY_PARAM"
 ELSEIF (table_error="LT")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 ELSE
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 ENDIF
 IF (errors="L")
  SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 ELSEIF (errors="U")
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 ENDIF
 SET failed = "T"
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO

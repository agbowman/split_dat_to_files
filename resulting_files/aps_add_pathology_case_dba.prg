CREATE PROGRAM aps_add_pathology_case:dba
 RECORD reply(
   1 case_id = f8
   1 group_cd = f8
   1 case_year = i4
   1 case_number = i4
   1 accession = c20
   1 accessioned_dt_tm = dq8
   1 updt_id = f8
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 processing_task_id = f8
     2 spec_comments_long_text_id = f8
     2 task_comments_long_text_id = f8
   1 report_qual[*]
     2 report_id = f8
     2 report_sequence = i4
   1 rpt_qual[*]
     2 report_id = f8
     2 catalog_cd = f8
   1 nomen_entity_qual[*]
     2 nomen_entity_reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((validate(accession_common_version,- (1))=- (1)))
  DECLARE accession_common_version = i2 WITH constant(0)
  DECLARE acc_success = i2 WITH constant(0)
  DECLARE acc_error = i2 WITH constant(1)
  DECLARE acc_future = i2 WITH constant(2)
  DECLARE acc_null_dt_tm = i2 WITH constant(3)
  DECLARE acc_template = i2 WITH constant(300)
  DECLARE acc_pool = i2 WITH constant(310)
  DECLARE acc_pool_sequence = i2 WITH constant(320)
  DECLARE acc_duplicate = i2 WITH constant(410)
  DECLARE acc_modify = i2 WITH constant(420)
  DECLARE acc_sequence_id = i2 WITH constant(430)
  DECLARE acc_insert = i2 WITH constant(440)
  DECLARE acc_pool_id = i2 WITH constant(450)
  DECLARE acc_aor_false = i2 WITH constant(500)
  DECLARE acc_aor_true = i2 WITH constant(501)
  DECLARE acc_person_false = i2 WITH constant(502)
  DECLARE acc_person_true = i2 WITH constant(503)
  DECLARE site_length = i2 WITH constant(5)
  DECLARE julian_sequence_length = i2 WITH constant(6)
  DECLARE prefix_sequence_length = i2 WITH constant(7)
  DECLARE accession_status = i4 WITH noconstant(acc_success)
  DECLARE accession_meaning = c200 WITH noconstant(fillstring(200," "))
  RECORD acc_settings(
    1 acc_settings_loaded = i2
    1 site_code_length = i4
    1 julian_sequence_length = i4
    1 alpha_sequence_length = i4
    1 year_display_length = i4
    1 default_site_cd = f8
    1 default_site_prefix = c5
    1 assignment_days = i4
    1 assignment_dt_tm = dq8
    1 check_disp_ind = i2
  )
  RECORD accession_fmt(
    1 time_ind = i2
    1 insert_aor_ind = i2
    1 cpri_lookup = i2
    1 act_lookup = i2
    1 qual[*]
      2 order_id = f8
      2 catalog_cd = f8
      2 facility_cd = f8
      2 site_prefix_cd = f8
      2 site_prefix_disp = c5
      2 accession_format_cd = f8
      2 accession_format_mean = c12
      2 accession_class_cd = f8
      2 specimen_type_cd = f8
      2 accession_dt_tm = dq8
      2 accession_day = i4
      2 accession_year = i4
      2 alpha_prefix = c2
      2 accession_seq_nbr = i4
      2 accession_pool_id = f8
      2 assignment_meaning = vc
      2 assignment_status = i2
      2 accession_id = f8
      2 accession = c20
      2 accession_formatted = c25
      2 activity_type_cd = f8
      2 activity_type_mean = c12
      2 order_tag = i2
      2 accession_info_pos = i2
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 accession_parent = i2
      2 body_site_cd = f8
      2 body_site_ind = i2
      2 specimen_type_ind = i2
      2 service_area_cd = f8
      2 linked_qual[*]
        3 linked_pos = i2
  )
  RECORD accession_grp(
    1 cpri_lookup = i2
    1 act_lookup = i2
    1 qual[*]
      2 catalog_cd = f8
      2 specimen_type_cd = f8
      2 site_prefix_cd = f8
      2 accession_format_cd = f8
      2 accession_class_cd = f8
      2 accession_dt_tm = dq8
      2 accession_pool_id = f8
      2 accession_id = f8
      2 accession = c20
      2 activity_type_cd = f8
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 body_site_cd = f8
      2 service_area_cd = f8
  )
  DECLARE accession_nbr = c20 WITH noconstant(fillstring(20," "))
  DECLARE accession_nbr_chk = c50 WITH noconstant(fillstring(50," "))
  RECORD accession_str(
    1 site_prefix_disp = c5
    1 accession_year = i4
    1 accession_day = i4
    1 alpha_prefix = c2
    1 accession_seq_nbr = i4
    1 accession_pool_id = f8
  )
  DECLARE acc_site_prefix_cd = f8 WITH noconstant(0.0)
  DECLARE acc_site_prefix = c5 WITH noconstant(fillstring(value(site_length)," "))
  DECLARE accession_id = f8 WITH noconstant(0.0)
  DECLARE accession_dup_id = f8 WITH noconstant(0.0)
  DECLARE accession_updt_cnt = i4 WITH noconstant(0)
  DECLARE accession_assignment_ind = i2 WITH noconstant(0)
  RECORD accession_chk(
    1 check_disp_ind = i2
    1 site_prefix_cd = f8
    1 accession_year = i4
    1 accession_day = i4
    1 accession_pool_id = f8
    1 accession_seq_nbr = i4
    1 accession_class_cd = f8
    1 accession_format_cd = f8
    1 alpha_prefix = c2
    1 accession_id = f8
    1 accession = c20
    1 accession_nbr_check = c50
    1 accession_updt_cnt = i4
    1 action_ind = i2
    1 preactive_ind = i2
    1 assignment_ind = i2
  )
 ENDIF
 RECORD req200423(
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 delete_flag = i2
 )
 RECORD rep200423(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 FREE RECORD cont_upd_orders
 RECORD cont_upd_orders(
   1 new_accession_id = f8
   1 new_accession = vc
   1 qual[*]
     2 order_id = f8
 )
 FREE RECORD cont_upd_list
 RECORD cont_upd_list(
   1 qual[*]
     2 container_id = f8
     2 max_accession_size = i4
     2 barcode_accession = vc
     2 container_nbr = i4
 )
 DECLARE update_spec_container_accession(null) = i2
 EXECUTE accrtl
 SUBROUTINE update_spec_container_accession(null)
   DECLARE cont_upd_orders_cnt = i4 WITH protect, noconstant(0)
   DECLARE cont_to_updt_cnt = i4 WITH protect, noconstant(0)
   DECLARE lcontainernbr = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET cont_upd_orders_cnt = size(cont_upd_orders->qual,5)
   IF (cont_upd_orders_cnt > 0)
    SELECT INTO "nl:"
     FROM container_accession ca
     WHERE (ca.accession_id=cont_upd_orders->new_accession_id)
     ORDER BY ca.accession_container_nbr DESC
     HEAD ca.accession_id
      lcontainernbr = ca.accession_container_nbr
     WITH nocounter
    ;end select
    SELECT INTO "n1:"
     FROM (dummyt d  WITH seq = value(cont_upd_orders_cnt)),
      order_serv_res_container osrc,
      container c,
      collection_class cc
     PLAN (d)
      JOIN (osrc
      WHERE (cont_upd_orders->qual[d.seq].order_id > 0)
       AND (osrc.order_id=cont_upd_orders->qual[d.seq].order_id))
      JOIN (c
      WHERE osrc.container_id > 0
       AND osrc.container_id=c.container_id)
      JOIN (cc
      WHERE c.coll_class_cd=cc.coll_class_cd)
     ORDER BY osrc.container_id
     HEAD osrc.container_id
      cont_to_updt_cnt += 1, stat = alterlist(cont_upd_list->qual,cont_to_updt_cnt), cont_upd_list->
      qual[cont_to_updt_cnt].container_id = osrc.container_id,
      lcontainernbr += 1, cont_upd_list->qual[cont_to_updt_cnt].container_nbr = lcontainernbr,
      cont_upd_list->qual[cont_to_updt_cnt].barcode_accession = uar_acctruncateunformatted(nullterm(
        cont_upd_orders->new_accession),0,cc.max_accession_size)
     WITH nocounter
    ;end select
    IF (cont_to_updt_cnt > 0)
     UPDATE  FROM container_accession ca,
       (dummyt d  WITH seq = value(cont_to_updt_cnt))
      SET ca.accession = cont_upd_orders->new_accession, ca.accession_id = cont_upd_orders->
       new_accession_id, ca.accession_container_nbr = cont_upd_list->qual[d.seq].container_nbr,
       ca.barcode_accession = cont_upd_list->qual[d.seq].barcode_accession, ca.updt_cnt = (ca
       .updt_cnt+ 1), ca.updt_applctx = reqinfo->updt_applctx,
       ca.updt_dt_tm = cnvtdatetime(sysdate), ca.updt_id = reqinfo->updt_id, ca.updt_task = reqinfo->
       updt_task
      PLAN (d)
       JOIN (ca
       WHERE (ca.container_id=cont_upd_list->qual[d.seq].container_id))
      WITH nocounter
     ;end update
     IF (cont_to_updt_cnt=curqual)
      RETURN(1)
     ELSE
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#script
 DECLARE nprsnlenscnt = i4 WITH protect, noconstant(0)
 DECLARE dconphystypeid = f8 WITH protect, noconstant(0.0)
 DECLARE dordphystypeid = f8 WITH protect, noconstant(0.0)
 DECLARE nmaxreltncnt = i4 WITH protect, noconstant(0)
 DECLARE nprsnlreltncheckprg = i4 WITH protect, noconstant(0)
 DECLARE nextaccidx = i2 WITH protect, noconstant(0)
 DECLARE naccnupdtordercnt = i4 WITH protect, noconstant(0)
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET reply->updt_id = reqinfo->updt_id
 SET provider_cnt = 0
 SET specimen_cnt = 0
 SET status_cd = 0.0
 SET detail_status_cd = 0.0
 SET spec_task_assay_cd = 0.0
 SET new_comments_long_text_id = 0.0
 SET group_cd = 0.0
 SET case_nbr = 0.0
 SET accession_nbr = ""
 SET case_yr = 0.0
 SET temp_updt_cnt = 0
 SET nomen_entity_cnt = size(request->nomen_entity_qual,5)
 SET nomen_entity_inact_cnt = 0
 SET order_icd9_cd = 0.0
 SET accn_icd9_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(333,"CONSULTDOC",1,dconphystypeid)
 SET stat = uar_get_meaning_by_codeset(333,"ORDERDOC",1,dordphystypeid)
 IF (checkprg("PPR_ENS_PRSNL_RELTN_ACT") > 0)
  SET nprsnlreltncheckprg = 1
 ENDIF
 SET s_active_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  HEAD REPORT
   s_active_cd = 0.0
  DETAIL
   s_active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1305
   AND c.cdf_meaning IN ("ORDERED", "PENDING")
  HEAD REPORT
   status_cd = 0.0, detail_status_cd = 0.0
  DETAIL
   IF (c.cdf_meaning="ORDERED")
    status_cd = c.code_value
   ELSE
    detail_status_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->comments_long_text_id=0)
  AND textlen(trim(request->comments)) > 0)
  SELECT INTO "nl:"
   seq_nbr = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    new_comments_long_text_id = seq_nbr
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(accession_fmt->qual,1)
 IF ((request->case_id=0))
  IF ((request->accession_nbr > " "))
   SELECT INTO "nl:"
    aar.accession_assignment_pool_id
    FROM accession_assign_xref aar
    WHERE (request->accession_format_cd=aar.accession_format_cd)
     AND (request->site_cd=aar.site_prefix_cd)
    DETAIL
     accession_str->accession_pool_id = aar.accession_assignment_pool_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "ACCESSION_ASSIGN_XREF"
    SET failed = "T"
    GO TO exit_script
   ENDIF
   SET accession_str->site_prefix_disp = substring(1,5,request->accession_nbr)
   SET accession_str->alpha_prefix = substring(6,2,request->accession_nbr)
   SET accession_str->accession_year = cnvtint(substring(8,4,request->accession_nbr))
   SET accession_str->accession_seq_nbr = cnvtint(substring(12,7,request->accession_nbr))
   SET accession_str->accession_day = 0
   EXECUTE accession_string
   SET accession_chk->site_prefix_cd = request->site_cd
   SET accession_chk->accession_year = accession_str->accession_year
   SET accession_chk->accession_day = accession_str->accession_day
   SET accession_chk->accession_pool_id = accession_str->accession_pool_id
   SET accession_chk->accession_seq_nbr = accession_str->accession_seq_nbr
   SET accession_chk->accession_class_cd = 0.0
   SET accession_chk->accession_format_cd = request->accession_format_cd
   SET accession_chk->alpha_prefix = accession_str->alpha_prefix
   SET accession_chk->accession = accession_nbr
   SET accession_chk->accession_nbr_check = accession_nbr_chk
   SET accession_chk->action_ind = 0
   SET accession_chk->preactive_ind = 0
   EXECUTE accession_check
   IF (accession_status != acc_success)
    SET reply->status_data.subeventstatus[1].operationname = "ACC_ASSIGNMENT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "ACCESSION"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = accession_meaning
    SET failed = "T"
    GO TO exit_script
   ENDIF
   SET reply->case_id = accession_id
   SET accession_fmt->qual[1].accession_pool_id = accession_chk->accession_pool_id
   SET accession_fmt->qual[1].accession_year = accession_chk->accession_year
   SET accession_fmt->qual[1].accession_seq_nbr = accession_chk->accession_seq_nbr
   SET accession_fmt->qual[1].accession = accession_chk->accession
  ELSE
   CALL echo("Format")
   SET accession_fmt->qual[1].order_id = 0.0
   SET accession_fmt->qual[1].catalog_cd = 0.0
   SET accession_fmt->qual[1].accession_class_cd = 0.0
   SET accession_fmt->qual[1].specimen_type_cd = 0.0
   SET accession_fmt->qual[1].site_prefix_cd = request->site_cd
   SET accession_fmt->qual[1].accession_format_cd = request->accession_format_cd
   SET accession_fmt->qual[1].accession_dt_tm = cnvtdatetime(curdate,curtime)
   CALL echo("Execute")
   EXECUTE accession_assign
   IF (accession_status != acc_success)
    SET reply->status_data.subeventstatus[1].operationname = "ACC_ASSIGNMENT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "ACCESSION"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = accession_meaning
    SET failed = "T"
    GO TO exit_script
   ENDIF
   SET reply->case_id = accession_fmt->qual[1].accession_id
  ENDIF
  SET reply->accessioned_dt_tm = cnvtdatetime(curdate,curtime)
  CALL echo("Done")
  IF (new_comments_long_text_id > 0)
   INSERT  FROM long_text lt
    SET lt.long_text_id = new_comments_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(
      sysdate),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
      sysdate),
     lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "PATHOLOGY_CASE", lt
     .parent_entity_id = reply->case_id,
     lt.long_text = request->comments
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ENDIF
  INSERT  FROM pathology_case p
   SET p.case_id = reply->case_id, p.person_id = request->person_id, p.encntr_id = request->encntr_id,
    p.prefix_id = request->prefix_cd, p.case_type_cd = request->case_type_cd, p.chr_ind = request->
    chr_ind,
    p.group_id = accession_fmt->qual[1].accession_pool_id, p.case_year = accession_fmt->qual[1].
    accession_year, p.case_number = accession_fmt->qual[1].accession_seq_nbr,
    p.accession_nbr = accession_fmt->qual[1].accession, p.reserved_ind = 0, p.requesting_physician_id
     = request->requesting_physician_id,
    p.responsible_resident_id = request->responsible_resident_id, p.responsible_pathologist_id =
    request->responsible_pathologist_id, p.case_collect_dt_tm =
    IF ((request->case_collect_dt_tm=0)) null
    ELSE cnvtdatetime(request->case_collect_dt_tm)
    ENDIF
    ,
    p.case_received_dt_tm =
    IF ((request->case_received_dt_tm=0)) null
    ELSE cnvtdatetime(request->case_received_dt_tm)
    ENDIF
    , p.accession_prsnl_id = reqinfo->updt_id, p.accessioned_dt_tm = cnvtdatetime(reply->
     accessioned_dt_tm),
    p.loc_building_cd = request->loc_building_cd, p.loc_facility_cd = request->loc_facility_cd, p
    .loc_nurse_unit_cd = request->loc_nurse_unit_cd,
    p.comments_long_text_id =
    IF (textlen(trim(request->comments)) > 0) new_comments_long_text_id
    ELSE 0.0
    ENDIF
    , p.origin_flag = 0, p.source_of_smear_cd = request->source_of_smear_cd,
    p.received_smear_ind = request->received_smear_ind, p.updt_dt_tm = cnvtdatetime(curdate,curtime),
    p.updt_id = reqinfo->updt_id,
    p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
   PLAN (p)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->case_id = request->case_id
  SET reply->accessioned_dt_tm = cnvtdatetime(curdate,curtime)
  IF ((request->comments_long_text_id > 0))
   SELECT INTO "nl:"
    lt.*
    FROM long_text lt,
     (dummyt d  WITH seq = 1)
    PLAN (d)
     JOIN (lt
     WHERE (lt.long_text_id=request->comments_long_text_id))
    DETAIL
     temp_updt_cnt = lt.updt_cnt
    WITH nocounter, forupdate(lt)
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
    SET failed = "T"
    GO TO exit_script
   ENDIF
   IF ((request->lt_updt_cnt != temp_updt_cnt))
    SET reply->status_data.subeventstatus[1].operationname = "UPDT_CNT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
    SET failed = "T"
    SET failed = "T"
    GO TO exit_script
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->
     updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.active_ind = 1,
     lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id, lt
     .long_text = request->comments
    WHERE (lt.long_text_id=request->comments_long_text_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSE
   IF ((request->comments_long_text_id=0)
    AND textlen(trim(request->comments)) > 0)
    INSERT  FROM long_text lt
     SET lt.long_text_id = new_comments_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(
       sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
       sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "PATHOLOGY_CASE", lt
      .parent_entity_id = reply->case_id,
      lt.long_text = request->comments
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   p.*
   FROM pathology_case p,
    (dummyt d  WITH seq = 1)
   PLAN (d)
    JOIN (p
    WHERE (p.case_id=request->case_id)
     AND p.reserved_ind=1)
   DETAIL
    group_cd = p.group_id, case_nbr = p.case_number, accession_nbr = p.accession_nbr,
    case_yr = p.case_year, temp_updt_cnt = p.updt_cnt
   WITH nocounter, forupdate(p)
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  IF ((request->path_case_updt_cnt != temp_updt_cnt))
   SET reply->status_data.subeventstatus[1].operationname = "UPDT_CNT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
   SET failed = "T"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM pathology_case p,
    (dummyt d  WITH seq = 1)
   SET p.person_id = request->person_id, p.encntr_id = request->encntr_id, p.case_type_cd = request->
    case_type_cd,
    p.chr_ind = request->chr_ind, p.reserved_ind = 0, p.requesting_physician_id = request->
    requesting_physician_id,
    p.responsible_resident_id = request->responsible_resident_id, p.responsible_pathologist_id =
    request->responsible_pathologist_id, p.case_collect_dt_tm =
    IF ((request->case_collect_dt_tm=0)) null
    ELSE cnvtdatetime(request->case_collect_dt_tm)
    ENDIF
    ,
    p.case_received_dt_tm =
    IF ((request->case_received_dt_tm=0)) null
    ELSE cnvtdatetime(request->case_received_dt_tm)
    ENDIF
    , p.accession_prsnl_id = reqinfo->updt_id, p.accessioned_dt_tm = cnvtdatetime(reply->
     accessioned_dt_tm),
    p.loc_building_cd = request->loc_building_cd, p.loc_facility_cd = request->loc_facility_cd, p
    .loc_nurse_unit_cd = request->loc_nurse_unit_cd,
    p.comments_long_text_id =
    IF (textlen(trim(request->comments)) > 0
     AND (request->comments_long_text_id=0)) new_comments_long_text_id
    ELSE p.comments_long_text_id
    ENDIF
    , p.origin_flag = 0, p.source_of_smear_cd = request->source_of_smear_cd,
    p.received_smear_ind = request->received_smear_ind, p.updt_dt_tm = cnvtdatetime(curdate,curtime),
    p.updt_id = reqinfo->updt_id,
    p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (p
    WHERE (p.case_id=request->case_id))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->case_id=0))
  SET reply->group_cd = accession_fmt->qual[1].accession_pool_id
  SET reply->accession = accession_fmt->qual[1].accession
  SET reply->case_number = accession_fmt->qual[1].accession_seq_nbr
  SET reply->case_year = accession_fmt->qual[1].accession_year
 ELSE
  SET reply->group_cd = group_cd
  SET reply->accession = accession_nbr
  SET reply->case_number = case_nbr
  SET reply->case_year = case_yr
 ENDIF
 IF (size(request->requesting_physician_reltn_qual,5) > 0)
  IF (nprsnlreltncheckprg=1)
   SELECT INTO "nl:"
    d1.*
    FROM (dummyt d1  WITH seq = value(size(request->requesting_physician_reltn_qual,5)))
    PLAN (d1)
    DETAIL
     nprsnlenscnt += 1
     IF (mod(nprsnlenscnt,10)=1)
      stat = alterlist(reltn_ens_req->qual,(nprsnlenscnt+ 9))
     ENDIF
     reltn_ens_req->qual[nprsnlenscnt].parent_entity_id = reply->case_id, reltn_ens_req->qual[
     nprsnlenscnt].parent_entity_name = "ACCESSION", reltn_ens_req->qual[nprsnlenscnt].
     entity_type_name = "CODE_VALUE",
     reltn_ens_req->qual[nprsnlenscnt].entity_type_id = dordphystypeid, reltn_ens_req->qual[
     nprsnlenscnt].action_flag = ppr_action_add, reltn_ens_req->qual[nprsnlenscnt].prsnl_id = request
     ->requesting_physician_id,
     reltn_ens_req->qual[nprsnlenscnt].prsnl_reltn_id = request->requesting_physician_reltn_qual[d1
     .seq].prsnl_reltn_id, reltn_ens_req->qual[nprsnlenscnt].updt_cnt = request->
     requesting_physician_reltn_qual[d1.seq].updt_cnt, reltn_ens_req->qual[nprsnlenscnt].person_id =
     request->person_id,
     reltn_ens_req->qual[nprsnlenscnt].encntr_id = request->encntr_id, reltn_ens_req->qual[
     nprsnlenscnt].accession_nbr = reply->accession, reltn_ens_req->qual[nprsnlenscnt].usage_nbr = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET provider_cnt = size(request->provider_qual,5)
 IF (provider_cnt > 0)
  INSERT  FROM case_provider cp,
    (dummyt d  WITH seq = value(provider_cnt))
   SET cp.case_id = reply->case_id, cp.physician_id = request->provider_qual[d.seq].physician_id, cp
    .updt_dt_tm = cnvtdatetime(curdate,curtime),
    cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->updt_task, cp.updt_applctx = reqinfo->
    updt_applctx,
    cp.updt_cnt = 0
   PLAN (d)
    JOIN (cp
    WHERE (reply->case_id=cp.case_id)
     AND (request->provider_qual[d.seq].physician_id=cp.physician_id))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_PROVIDER"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  IF (nprsnlreltncheckprg=1)
   SELECT INTO "nl:"
    d1.seq
    FROM (dummyt d1  WITH seq = value(provider_cnt))
    PLAN (d1)
    DETAIL
     IF (size(request->provider_qual[d1.seq].reltn_qual,5) > nmaxreltncnt)
      nmaxreltncnt = size(request->provider_qual[d1.seq].reltn_qual,5)
     ENDIF
    WITH nocounter
   ;end select
   IF (nmaxreltncnt > 0)
    SELECT INTO "nl:"
     d1.*
     FROM (dummyt d1  WITH seq = value(provider_cnt)),
      (dummyt d2  WITH seq = value(nmaxreltncnt))
     PLAN (d1)
      JOIN (d2
      WHERE d2.seq <= size(request->provider_qual[d1.seq].reltn_qual,5))
     DETAIL
      nprsnlenscnt += 1
      IF (mod(nprsnlenscnt,10)=1)
       stat = alterlist(reltn_ens_req->qual,(nprsnlenscnt+ 9))
      ENDIF
      reltn_ens_req->qual[nprsnlenscnt].parent_entity_id = reply->case_id, reltn_ens_req->qual[
      nprsnlenscnt].parent_entity_name = "ACCESSION", reltn_ens_req->qual[nprsnlenscnt].
      entity_type_name = "CODE_VALUE",
      reltn_ens_req->qual[nprsnlenscnt].entity_type_id = dconphystypeid, reltn_ens_req->qual[
      nprsnlenscnt].action_flag = ppr_action_add, reltn_ens_req->qual[nprsnlenscnt].prsnl_id =
      request->provider_qual[d1.seq].physician_id,
      reltn_ens_req->qual[nprsnlenscnt].prsnl_reltn_id = request->provider_qual[d1.seq].reltn_qual[d2
      .seq].prsnl_reltn_id, reltn_ens_req->qual[nprsnlenscnt].person_id = request->person_id,
      reltn_ens_req->qual[nprsnlenscnt].encntr_id = request->encntr_id,
      reltn_ens_req->qual[nprsnlenscnt].accession_nbr = reply->accession, reltn_ens_req->qual[
      nprsnlenscnt].usage_nbr = 1
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF (size(request->report_qual,5) > 0)
  SET request->case_id = reply->case_id
  EXECUTE aps_add_pathology_report
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 SET specimen_cnt = size(request->spec_qual,5)
 SET stat = alterlist(reply->spec_qual,specimen_cnt)
 SET stat = alterlist(req200423->spec_qual,specimen_cnt)
 SELECT INTO "nl:"
  ptr.task_assay_cd
  FROM profile_task_r ptr
  WHERE (request->order_catalog_cd=ptr.catalog_cd)
   AND ptr.item_type_flag=0
   AND ptr.active_ind=1
   AND ptr.beg_effective_dt_tm < cnvtdatetime(sysdate)
   AND ((ptr.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (ptr.end_effective_dt_tm=null))
  HEAD REPORT
   spec_task_assay_cd = 0.0
  DETAIL
   spec_task_assay_cd = ptr.task_assay_cd
  WITH nocounter
 ;end select
 FOR (y = 1 TO specimen_cnt)
   SELECT INTO "nl:"
    seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     reply->spec_qual[y].case_specimen_id = seq_nbr, req200423->spec_qual[y].case_specimen_id =
     seq_nbr, req200423->spec_qual[y].delete_flag = 0
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
   IF (((textlen(trim(request->spec_qual[y].special_comments)) > 0) OR (textlen(trim(request->
     spec_qual[y].task_comments)) > 0)) )
    IF (textlen(trim(request->spec_qual[y].special_comments)) > 0)
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       reply->spec_qual[y].spec_comments_long_text_id = seq_nbr
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      GO TO seq_failed
     ENDIF
    ENDIF
    IF (textlen(trim(request->spec_qual[y].task_comments)) > 0)
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       reply->spec_qual[y].task_comments_long_text_id = seq_nbr
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      GO TO seq_failed
     ENDIF
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     reply->spec_qual[y].processing_task_id = seq_nbr
    WITH format, nocounter
   ;end select
   IF (textlen(trim(request->spec_qual[y].special_comments)) > 0)
    INSERT  FROM long_text lt
     SET lt.long_text_id = reply->spec_qual[y].spec_comments_long_text_id, lt.updt_cnt = 0, lt
      .updt_dt_tm = cnvtdatetime(sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
       sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "CASE_SPECIMEN", lt
      .parent_entity_id = reply->spec_qual[y].case_specimen_id,
      lt.long_text = request->spec_qual[y].special_comments
     WITH nocounter
    ;end insert
   ENDIF
   IF (textlen(trim(request->spec_qual[y].task_comments)) > 0)
    INSERT  FROM long_text lt
     SET lt.long_text_id = reply->spec_qual[y].task_comments_long_text_id, lt.updt_cnt = 0, lt
      .updt_dt_tm = cnvtdatetime(sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
       sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "PROCESSING_TASK", lt
      .parent_entity_id = reply->spec_qual[y].processing_task_id,
      lt.long_text = request->spec_qual[y].task_comments
     WITH nocounter
    ;end insert
   ENDIF
   INSERT  FROM case_specimen cs
    SET cs.case_id = reply->case_id, cs.case_specimen_id = reply->spec_qual[y].case_specimen_id, cs
     .specimen_cd = request->spec_qual[y].specimen_cd,
     cs.nomenclature_id = 0.0, cs.specimen_description =
     IF (textlen(request->spec_qual[y].specimen_description) > 0) request->spec_qual[y].
      specimen_description
     ELSE null
     ENDIF
     , cs.spec_comments_long_text_id = reply->spec_qual[y].spec_comments_long_text_id,
     cs.specimen_tag_id = request->spec_qual[y].specimen_tag_cd, cs.collect_dt_tm = cnvtdatetime(
      request->spec_qual[y].collect_dt_tm), cs.received_dt_tm = cnvtdatetime(request->spec_qual[y].
      received_dt_tm),
     cs.received_id = reqinfo->updt_id, cs.received_fixative_cd = request->spec_qual[y].
     received_fixative_cd, cs.inadequacy_reason_cd = request->spec_qual[y].adequacy_reason_cd,
     cs.updt_dt_tm = cnvtdatetime(curdate,curtime), cs.updt_id = reqinfo->updt_id, cs.updt_task =
     reqinfo->updt_task,
     cs.updt_applctx = reqinfo->updt_applctx, cs.updt_cnt = 0
    PLAN (cs)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO cs_failed
   ENDIF
   IF ((request->spec_qual[y].order_id=0.0))
    INSERT  FROM ap_ops_exception aoe
     SET aoe.parent_id = reply->spec_qual[y].case_specimen_id, aoe.action_flag = 2, aoe.active_ind =
      1,
      aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task
       = reqinfo->updt_task,
      aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     GO TO ops_failed
    ENDIF
    IF (curutc=1)
     INSERT  FROM ap_ops_exception_detail aoed
      SET aoed.action_flag = 2, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
       aoed.parent_id = reply->spec_qual[y].case_specimen_id, aoed.sequence = 1, aoed.updt_applctx =
       reqinfo->updt_applctx,
       aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
       updt_id,
       aoed.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO ops_det_failed
     ENDIF
    ENDIF
   ENDIF
   INSERT  FROM processing_task pt
    SET pt.processing_task_id = reply->spec_qual[y].processing_task_id, pt.comments_long_text_id =
     reply->spec_qual[y].task_comments_long_text_id, pt.case_id = reply->case_id,
     pt.case_specimen_id = reply->spec_qual[y].case_specimen_id, pt.case_specimen_tag_id = request->
     spec_qual[y].specimen_tag_cd, pt.order_id = request->spec_qual[y].order_id,
     pt.create_inventory_flag = 4, pt.cassette_id = 0, pt.cassette_tag_id = 0,
     pt.slide_id = 0, pt.slide_tag_id = 0, pt.task_assay_cd = spec_task_assay_cd,
     pt.service_resource_cd = request->spec_qual[y].service_resource_cd, pt.priority_cd = request->
     spec_qual[y].priority_cd, pt.request_dt_tm = cnvtdatetime(sysdate),
     pt.request_prsnl_id = reqinfo->updt_id, pt.status_cd = status_cd, pt.status_prsnl_id = reqinfo->
     updt_id,
     pt.status_dt_tm = cnvtdatetime(sysdate), pt.updt_dt_tm = cnvtdatetime(sysdate), pt.updt_id =
     reqinfo->updt_id,
     pt.updt_task = reqinfo->updt_task, pt.updt_cnt = 0, pt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO task_failed
   ENDIF
 ENDFOR
 IF ((request->transfer_logged_in_cont_accns=1))
  SET cont_upd_orders->new_accession_id = accession_fmt->qual[1].accession_id
  SET cont_upd_orders->new_accession = accession_fmt->qual[1].accession
  FOR (y = 1 TO specimen_cnt)
    IF ((request->spec_qual[y].order_id > 0.0))
     SET naccnupdtordercnt += 1
     SET stat = alterlist(cont_upd_orders->qual,naccnupdtordercnt)
     SET cont_upd_orders->qual[naccnupdtordercnt].order_id = request->spec_qual[y].order_id
    ENDIF
  ENDFOR
  IF (update_spec_container_accession(null) != 1)
   GO TO cont_accn_updt_failed
  ENDIF
 ENDIF
 EXECUTE aps_chk_case_synoptic_ws  WITH replace("REQUEST","REQ200423"), replace("REPLY","REP200423")
 IF ((rep200423->status_data.status != "S"))
  GO TO synoptic_failed
 ENDIF
 DELETE  FROM ap_login_order_list a,
   (dummyt d  WITH seq = value(cnvtint(size(request->spec_qual,5))))
  SET a.seq = 1
  PLAN (d)
   JOIN (a
   WHERE (request->spec_qual[d.seq].order_id > 0)
    AND (request->spec_qual[d.seq].order_id=a.order_id))
  WITH nocounter
 ;end delete
 IF (size(request->prompt_qual,5) > 0)
  SET request->case_id = reply->case_id
  EXECUTE aps_chg_prompt_test
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=23549
   AND cv.cdf_meaning="ACCNICD9"
   AND cv.active_ind=1
  HEAD REPORT
   accn_icd9_cd = 0.0
  DETAIL
   accn_icd9_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (nomen_entity_cnt > 0
  AND failed="F")
  FOR (i = 1 TO nomen_entity_cnt)
    SET request->nomen_entity_qual[i].parent_entity_name = "ACCESSION"
    SET request->nomen_entity_qual[i].parent_entity_id = reply->case_id
    SET request->nomen_entity_qual[i].child_entity_name = "NOMENCLATURE"
    SET request->nomen_entity_qual[i].child_entity_id = request->nomen_entity_qual[i].nomenclature_id
    SET request->nomen_entity_qual[i].reltn_type_cd = accn_icd9_cd
    SET request->nomen_entity_qual[i].freetext_display = ""
    SET request->nomen_entity_qual[i].person_id = request->person_id
    SET request->nomen_entity_qual[i].encntr_id = request->encntr_id
    SET request->nomen_entity_qual[i].diag_priority = request->nomen_entity_qual[i].diag_priority
  ENDFOR
  EXECUTE dcp_add_nomen_entity_reltn
  IF (failed="T")
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=23549
   AND cv.cdf_meaning="ORDERICD9"
   AND cv.active_ind=1
  HEAD REPORT
   order_icd9_cd = 0.0
  DETAIL
   order_icd9_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM nomen_entity_reltn ner,
   (dummyt d  WITH seq = value(specimen_cnt))
  PLAN (d
   WHERE (request->spec_qual[d.seq].order_id != 0.0))
   JOIN (ner
   WHERE ner.parent_entity_name="ORDERS"
    AND (ner.parent_entity_id=request->spec_qual[d.seq].order_id)
    AND ner.reltn_type_cd=order_icd9_cd)
  HEAD REPORT
   nomen_entity_inact_cnt = 0
  DETAIL
   nomen_entity_inact_cnt += 1
   IF (mod(nomen_entity_inact_cnt,10)=1)
    stat = alterlist(request->nomen_entity_inact_qual,(nomen_entity_inact_cnt+ 9))
   ENDIF
   request->nomen_entity_inact_qual[nomen_entity_inact_cnt].nomen_entity_reltn_id = ner
   .nomen_entity_reltn_id
  FOOT REPORT
   stat = alterlist(request->nomen_entity_inact_qual,nomen_entity_inact_cnt)
  WITH nocounter
 ;end select
 IF (nomen_entity_inact_cnt > 0
  AND failed="F")
  EXECUTE dcp_inact_nomen_entity_reltn
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (nprsnlenscnt > 0)
  SET reltn_ens_req->validated_data_ind = 1
  SET stat = alterlist(reltn_ens_req->qual,nprsnlenscnt)
  EXECUTE ppr_ens_prsnl_reltn_act  WITH replace("REQUEST","RELTN_ENS_REQ"), replace("REPLY",
   "RELTN_ENS_REP")
  IF ((reltn_ens_rep->status_data.status="F"))
   CALL echorecord(reltn_ens_req)
   CALL echorecord(reltn_ens_rep)
   GO TO prsnl_reltn_failed
  ENDIF
 ENDIF
 FOR (nextaccidx = 1 TO size(request->ext_acc_qual,5))
   IF ((request->ext_acc_qual[nextaccidx].int_identifier[1].accession_id=0))
    SET request->ext_acc_qual[nextaccidx].int_identifier[1].accession_id = reply->case_id
   ENDIF
 ENDFOR
 IF (size(request->ext_acc_qual,5) > 0)
  EXECUTE pcs_upd_external_accessions
  IF ((reply->status_data.status="F"))
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "NEXTVAL"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHNET_SEQ"
 SET failed = "T"
 GO TO exit_script
#cs_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_SPECIMEN"
 SET failed = "T"
 GO TO exit_script
#ops_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION"
 SET failed = "T"
 GO TO exit_script
#ops_det_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION_DETAIL"
 SET failed = "T"
 GO TO exit_script
#task_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#synoptic_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_CASE_SYNOPTIC_WS"
 SET failed = "T"
 GO TO exit_script
#prsnl_reltn_failed
 SET reply->status_data.subeventstatus[1].operationname = concat("INSERT:  ",reltn_ens_rep->
  status_data.subeventstatus[1].operationname)
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL_RELTN_ACTIVITY"
 SET failed = "T"
#cont_accn_updt_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CONTAINER_ACCESSION"
 SET failed = "T"
#exit_script
 FREE RECORD req200423
 FREE RECORD rep200423
 FREE RECORD reltn_ens_rep
 FREE RECORD reltn_ens_req
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET stat = alterlist(accession_fmt->qual,0)
END GO

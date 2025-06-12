CREATE PROGRAM acm_get_proc_by_proc_id:dba
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 IF ( NOT (validate(ppr_credentials_include_var,0)))
  DECLARE ppr_credentials_include_var = i4 WITH public, constant(1)
  DECLARE sdefaultname = vc WITH public, noconstant("")
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
  FREE RECORD date_rec
  FREE RECORD ppr_get_cred_req
  FREE RECORD ppr_get_cred_rep
  FREE RECORD ppr_ens_cred_req
  FREE RECORD ppr_ens_cred_rep
  FREE RECORD date_rec
  RECORD date_rec(
    1 compare_date = dq8
    1 max_date = dq8
  )
  SET date_rec->compare_date = cnvtdatetime(sysdate)
  SET date_rec->max_date = null
  SUBROUTINE (getnamedisplay(dpersonid=f8,dnametypecd=f8) =vc)
   SELECT INTO "nl:"
    pnh.transaction_dt_tm
    FROM person_name_hist pnh
    WHERE pnh.person_id=dpersonid
     AND pnh.name_type_cd=dnametypecd
     AND pnh.transaction_dt_tm < cnvtdatetime(date_rec->compare_date)
    DETAIL
     IF ((date_rec->max_date < pnh.transaction_dt_tm))
      date_rec->max_date = pnh.transaction_dt_tm, sdefaultname = pnh.name_full
     ENDIF
    WITH nocounter
   ;end select
   RETURN(sdefaultname)
  END ;Subroutine
  IF (validate(persons))
   FREE RECORD persons
  ENDIF
  RECORD persons(
    1 qual[*]
      2 person_id = f8
      2 type_cd = f8
      2 trans_dt_tm = dq8
      2 names[*]
        3 full_name = vc
        3 last = vc
        3 first = vc
        3 middle = vc
        3 prefix = vc
        3 suffix = vc
        3 title = vc
        3 degree = vc
        3 initials = vc
        3 begin_dt_tm = dq8
        3 end_dt_tm = dq8
  )
  SUBROUTINE (getdisplaycomponents(return_all_names=i2) =i2)
    DECLARE foo = i4
    DECLARE idx = i4
    DECLARE interval = q8
    DECLARE name_idx = i4
    DECLARE persons_size = i4
    DECLARE prev_beg_date = q8
    DECLARE errmsg = c132 WITH public, noconstant(" ")
    DECLARE error_check = i4 WITH public, noconstant(0)
    DECLARE returnval = i4 WITH public, noconstant(0)
    SET error_check = error(errmsg,1)
    FREE RECORD counters
    RECORD counters(
      1 qual[*]
        2 count = i2
    )
    SET persons_size = size(persons->qual,5)
    SET foo = alterlist(counters->qual,persons_size)
    SET interval = (cnvtdatetime("01-Jan-2006 00:00:30.00") - cnvtdatetime("01-Jan-2006 00:00:00.00")
    )
    SET prev_beg_date = cnvtdatetime(ppr_null_date)
    FOR (idx = 1 TO persons_size)
      IF ((persons->qual[idx].person_id=0))
       RETURN(1)
      ELSEIF ((persons->qual[idx].type_cd=0.0))
       RETURN(1)
      ELSEIF ((persons->qual[idx].trans_dt_tm=0.0))
       SET persons->qual[idx].trans_dt_tm = cnvtdatetime(sysdate)
      ENDIF
    ENDFOR
    SELECT INTO "nl:"
     p.person_id, pn.person_name_id, beg_dt_tm = decode(pn.beg_effective_dt_tm,pn.beg_effective_dt_tm,
      p.beg_effective_dt_tm)
     FROM person_name pn,
      prsnl p,
      (dummyt d1  WITH seq = value(persons_size))
     PLAN (d1)
      JOIN (p
      WHERE (p.person_id=persons->qual[d1.seq].person_id))
      JOIN (pn
      WHERE pn.person_id=p.person_id
       AND (pn.name_type_cd=persons->qual[d1.seq].type_cd)
       AND pn.active_ind=1)
     ORDER BY beg_dt_tm DESC
     HEAD d1.seq
      prev_beg_date = cnvtdatetime(ppr_null_date)
     DETAIL
      name_idx = counters->qual[d1.seq].count
      IF (mod(name_idx,10)=0)
       foo = alterlist(persons->qual[d1.seq].names,(name_idx+ 10))
      ENDIF
      name_idx += 1
      IF (pn.person_name_id != 0)
       IF ((((prev_beg_date < (cnvtdatetime(pn.beg_effective_dt_tm) - interval))) OR ((prev_beg_date
        >= (cnvtdatetime(pn.beg_effective_dt_tm)+ interval)))) )
        persons->qual[d1.seq].names[name_idx].full_name = pn.name_full, persons->qual[d1.seq].names[
        name_idx].last = pn.name_last, persons->qual[d1.seq].names[name_idx].first = pn.name_first,
        persons->qual[d1.seq].names[name_idx].middle = pn.name_middle, persons->qual[d1.seq].names[
        name_idx].prefix = pn.name_prefix, persons->qual[d1.seq].names[name_idx].suffix = pn
        .name_suffix,
        persons->qual[d1.seq].names[name_idx].title = pn.name_title, persons->qual[d1.seq].names[
        name_idx].degree = pn.name_degree, persons->qual[d1.seq].names[name_idx].initials = pn
        .name_initials,
        persons->qual[d1.seq].names[name_idx].begin_dt_tm = cnvtdatetime(pn.beg_effective_dt_tm),
        persons->qual[d1.seq].names[name_idx].end_dt_tm = cnvtdatetime(pn.end_effective_dt_tm),
        prev_beg_date = cnvtdatetime(pn.beg_effective_dt_tm),
        counters->qual[d1.seq].count = name_idx
       ENDIF
      ELSE
       persons->qual[d1.seq].names[name_idx].full_name = p.name_full_formatted, persons->qual[d1.seq]
       .names[name_idx].first = p.name_first, persons->qual[d1.seq].names[name_idx].last = p
       .name_last,
       persons->qual[d1.seq].names[name_idx].begin_dt_tm = cnvtdatetime(p.beg_effective_dt_tm),
       persons->qual[d1.seq].names[name_idx].end_dt_tm = cnvtdatetime(p.end_effective_dt_tm),
       prev_beg_date = cnvtdatetime(p.beg_effective_dt_tm),
       counters->qual[d1.seq].count = name_idx
      ENDIF
     FOOT  d1.seq
      row + 0
     WITH nocounter
    ;end select
    FOR (idx = 1 TO persons_size)
      SET foo = alterlist(persons->qual[idx].names,counters->qual[idx].count)
    ENDFOR
    IF (return_all_names=0)
     FOR (idx = 1 TO persons_size)
       IF ((counters->qual[idx].count > 0))
        FOR (name_idx = 1 TO counters->qual[idx].count)
          IF ((persons->qual[idx].trans_dt_tm > persons->qual[idx].names[name_idx].begin_dt_tm)
           AND (persons->qual[idx].trans_dt_tm <= persons->qual[idx].names[name_idx].end_dt_tm))
           SET persons->qual[idx].names[1].full_name = persons->qual[idx].names[name_idx].full_name
           SET persons->qual[idx].names[1].last = persons->qual[idx].names[name_idx].last
           SET persons->qual[idx].names[1].first = persons->qual[idx].names[name_idx].first
           SET persons->qual[idx].names[1].middle = persons->qual[idx].names[name_idx].middle
           SET persons->qual[idx].names[1].prefix = persons->qual[idx].names[name_idx].prefix
           SET persons->qual[idx].names[1].suffix = persons->qual[idx].names[name_idx].suffix
           SET persons->qual[idx].names[1].initials = persons->qual[idx].names[name_idx].initials
           SET persons->qual[idx].names[1].title = persons->qual[idx].names[name_idx].title
           SET persons->qual[idx].names[1].degree = persons->qual[idx].names[name_idx].degree
           SET persons->qual[idx].names[1].begin_dt_tm = persons->qual[idx].names[name_idx].
           begin_dt_tm
           SET persons->qual[idx].names[1].end_dt_tm = persons->qual[idx].names[name_idx].end_dt_tm
           SET name_idx = (counters->qual[idx].count+ 10)
          ENDIF
        ENDFOR
        IF (((name_idx - 1) <= counters->qual[idx].count))
         SET persons->qual[idx].names[1].full_name = persons->qual[idx].names[counters->qual[idx].
         count].full_name
         SET persons->qual[idx].names[1].last = persons->qual[idx].names[counters->qual[idx].count].
         last
         SET persons->qual[idx].names[1].first = persons->qual[idx].names[counters->qual[idx].count].
         first
         SET persons->qual[idx].names[1].middle = persons->qual[idx].names[counters->qual[idx].count]
         .middle
         SET persons->qual[idx].names[1].prefix = persons->qual[idx].names[counters->qual[idx].count]
         .prefix
         SET persons->qual[idx].names[1].suffix = persons->qual[idx].names[counters->qual[idx].count]
         .suffix
         SET persons->qual[idx].names[1].initials = persons->qual[idx].names[counters->qual[idx].
         count].initials
         SET persons->qual[idx].names[1].title = persons->qual[idx].names[counters->qual[idx].count].
         title
         SET persons->qual[idx].names[1].degree = persons->qual[idx].names[counters->qual[idx].count]
         .degree
         SET persons->qual[idx].names[1].begin_dt_tm = persons->qual[idx].names[counters->qual[idx].
         count].begin_dt_tm
         SET persons->qual[idx].names[1].end_dt_tm = persons->qual[idx].names[counters->qual[idx].
         count].end_dt_tm
        ENDIF
        SET foo = alterlist(persons->qual[idx].names,1)
       ENDIF
     ENDFOR
    ELSEIF (return_all_names != 1)
     CALL echo("!! Invalid input parameter for GetNameComponentsDisplay() !!")
     SET returnval = 1
    ENDIF
    IF (error(errmsg,0) != 0)
     CALL echo(errmsg)
     SET returnval = 2
    ENDIF
    FREE RECORD counters
    RETURN(returnval)
  END ;Subroutine
  SUBROUTINE (getnamecomponentsdisplay(return_all_names=i2) =i2)
    DECLARE foo = i4
    DECLARE idx = i4
    DECLARE interval = q8
    DECLARE name_idx = i4
    DECLARE persons_size = i4
    DECLARE prev_beg_date = q8
    DECLARE returnval = i4 WITH public, noconstant(0)
    FREE RECORD counters
    RECORD counters(
      1 qual[*]
        2 count = i2
    )
    SET persons_size = size(persons->qual,5)
    SET foo = alterlist(counters->qual,persons_size)
    SET interval = (cnvtdatetime("01-Jan-2006 00:00:30.00") - cnvtdatetime("01-Jan-2006 00:00:00.00")
    )
    SET prev_beg_date = cnvtdatetime(ppr_null_date)
    FOR (idx = 1 TO persons_size)
      IF ((persons->qual[idx].person_id=0))
       RETURN(1)
      ELSEIF ((persons->qual[idx].type_cd=0.0))
       RETURN(1)
      ELSEIF ((persons->qual[idx].trans_dt_tm=0.0))
       SET persons->qual[idx].trans_dt_tm = cnvtdatetime(sysdate)
      ENDIF
    ENDFOR
    SELECT INTO "nl:"
     p.person_id, pn.person_name_id, pnh.person_name_hist_id,
     beg_dt_tm = decode(pnh.transaction_dt_tm,pnh.transaction_dt_tm,pn.beg_effective_dt_tm,pn
      .beg_effective_dt_tm,p.beg_effective_dt_tm)
     FROM person_name_hist pnh,
      person_name pn,
      prsnl p,
      dummyt d1,
      dummyt d2,
      (dummyt d3  WITH seq = value(persons_size))
     PLAN (d3)
      JOIN (p
      WHERE (p.person_id=persons->qual[d3.seq].person_id))
      JOIN (((d1)
      JOIN (pnh
      WHERE pnh.person_id=p.person_id
       AND (pnh.name_type_cd=persons->qual[d3.seq].type_cd)
       AND pnh.active_ind=1)
      ) ORJOIN ((d2)
      JOIN (pn
      WHERE pn.person_id=p.person_id
       AND (pn.name_type_cd=persons->qual[d3.seq].type_cd)
       AND pn.active_ind=1)
      ))
     ORDER BY beg_dt_tm DESC
     HEAD d3.seq
      prev_beg_date = cnvtdatetime(ppr_null_date)
     DETAIL
      name_idx = counters->qual[d3.seq].count
      IF (mod(name_idx,10)=0)
       foo = alterlist(persons->qual[d3.seq].names,(name_idx+ 10))
      ENDIF
      name_idx += 1
      IF (pnh.person_name_hist_id != 0)
       IF ((((prev_beg_date < (cnvtdatetime(pnh.transaction_dt_tm) - interval))) OR ((prev_beg_date
        >= (cnvtdatetime(pnh.transaction_dt_tm)+ interval)))) )
        persons->qual[d3.seq].names[name_idx].full_name = pnh.name_full, persons->qual[d3.seq].names[
        name_idx].last = pnh.name_last, persons->qual[d3.seq].names[name_idx].first = pnh.name_first,
        persons->qual[d3.seq].names[name_idx].middle = pnh.name_middle, persons->qual[d3.seq].names[
        name_idx].prefix = pnh.name_prefix, persons->qual[d3.seq].names[name_idx].suffix = pnh
        .name_suffix,
        persons->qual[d3.seq].names[name_idx].title = pnh.name_title, persons->qual[d3.seq].names[
        name_idx].degree = pnh.name_degree, persons->qual[d3.seq].names[name_idx].initials = pnh
        .name_initials,
        persons->qual[d3.seq].names[name_idx].begin_dt_tm = cnvtdatetime(pnh.transaction_dt_tm),
        persons->qual[d3.seq].names[name_idx].end_dt_tm = cnvtdatetime(prev_beg_date), prev_beg_date
         = cnvtdatetime(pnh.transaction_dt_tm),
        counters->qual[d3.seq].count = name_idx
       ENDIF
      ELSEIF (pn.person_name_id != 0)
       IF ((((prev_beg_date < (cnvtdatetime(pn.beg_effective_dt_tm) - interval))) OR ((prev_beg_date
        >= (cnvtdatetime(pn.beg_effective_dt_tm)+ interval)))) )
        persons->qual[d3.seq].names[name_idx].full_name = pn.name_full, persons->qual[d3.seq].names[
        name_idx].last = pn.name_last, persons->qual[d3.seq].names[name_idx].first = pn.name_first,
        persons->qual[d3.seq].names[name_idx].middle = pn.name_middle, persons->qual[d3.seq].names[
        name_idx].prefix = pn.name_prefix, persons->qual[d3.seq].names[name_idx].suffix = pn
        .name_suffix,
        persons->qual[d3.seq].names[name_idx].title = pn.name_title, persons->qual[d3.seq].names[
        name_idx].degree = pn.name_degree, persons->qual[d3.seq].names[name_idx].initials = pn
        .name_initials,
        persons->qual[d3.seq].names[name_idx].begin_dt_tm = cnvtdatetime(pn.beg_effective_dt_tm),
        persons->qual[d3.seq].names[name_idx].end_dt_tm = cnvtdatetime(pn.end_effective_dt_tm),
        prev_beg_date = cnvtdatetime(pn.beg_effective_dt_tm),
        counters->qual[d3.seq].count = name_idx
       ENDIF
      ELSE
       persons->qual[d3.seq].names[name_idx].full_name = p.name_full_formatted, persons->qual[d3.seq]
       .names[name_idx].first = p.name_first, persons->qual[d3.seq].names[name_idx].last = p
       .name_last,
       persons->qual[d3.seq].names[name_idx].begin_dt_tm = cnvtdatetime(p.beg_effective_dt_tm),
       persons->qual[d3.seq].names[name_idx].end_dt_tm = cnvtdatetime(p.end_effective_dt_tm),
       prev_beg_date = cnvtdatetime(p.beg_effective_dt_tm),
       counters->qual[d3.seq].count = name_idx
      ENDIF
     FOOT  d1.seq
      row + 0
     WITH nocounter
    ;end select
    FOR (idx = 1 TO persons_size)
      SET foo = alterlist(persons->qual[idx].names,counters->qual[idx].count)
    ENDFOR
    IF (return_all_names=0)
     FOR (idx = 1 TO persons_size)
       IF ((counters->qual[idx].count > 0))
        FOR (name_idx = 1 TO counters->qual[idx].count)
          IF ((persons->qual[idx].trans_dt_tm > persons->qual[idx].names[name_idx].begin_dt_tm)
           AND (persons->qual[idx].trans_dt_tm <= persons->qual[idx].names[name_idx].end_dt_tm))
           SET persons->qual[idx].names[1].full_name = persons->qual[idx].names[name_idx].full_name
           SET persons->qual[idx].names[1].last = persons->qual[idx].names[name_idx].last
           SET persons->qual[idx].names[1].first = persons->qual[idx].names[name_idx].first
           SET persons->qual[idx].names[1].middle = persons->qual[idx].names[name_idx].middle
           SET persons->qual[idx].names[1].prefix = persons->qual[idx].names[name_idx].prefix
           SET persons->qual[idx].names[1].suffix = persons->qual[idx].names[name_idx].suffix
           SET persons->qual[idx].names[1].initials = persons->qual[idx].names[name_idx].initials
           SET persons->qual[idx].names[1].title = persons->qual[idx].names[name_idx].title
           SET persons->qual[idx].names[1].degree = persons->qual[idx].names[name_idx].degree
           SET persons->qual[idx].names[1].begin_dt_tm = persons->qual[idx].names[name_idx].
           begin_dt_tm
           SET persons->qual[idx].names[1].end_dt_tm = persons->qual[idx].names[name_idx].end_dt_tm
           SET name_idx = (counters->qual[idx].count+ 10)
          ENDIF
        ENDFOR
        IF (((name_idx - 1) <= counters->qual[idx].count))
         SET persons->qual[idx].names[1].full_name = persons->qual[idx].names[counters->qual[idx].
         count].full_name
         SET persons->qual[idx].names[1].last = persons->qual[idx].names[counters->qual[idx].count].
         last
         SET persons->qual[idx].names[1].first = persons->qual[idx].names[counters->qual[idx].count].
         first
         SET persons->qual[idx].names[1].middle = persons->qual[idx].names[counters->qual[idx].count]
         .middle
         SET persons->qual[idx].names[1].prefix = persons->qual[idx].names[counters->qual[idx].count]
         .prefix
         SET persons->qual[idx].names[1].suffix = persons->qual[idx].names[counters->qual[idx].count]
         .suffix
         SET persons->qual[idx].names[1].title = persons->qual[idx].names[counters->qual[idx].count].
         title
         SET persons->qual[idx].names[1].initials = persons->qual[idx].names[counters->qual[idx].
         count].initials
         SET persons->qual[idx].names[1].degree = persons->qual[idx].names[counters->qual[idx].count]
         .degree
         SET persons->qual[idx].names[1].begin_dt_tm = persons->qual[idx].names[counters->qual[idx].
         count].begin_dt_tm
         SET persons->qual[idx].names[1].end_dt_tm = persons->qual[idx].names[counters->qual[idx].
         count].end_dt_tm
        ENDIF
        SET foo = alterlist(persons->qual[idx].names,1)
       ENDIF
     ENDFOR
    ELSEIF (return_all_names != 1)
     CALL echo("!! Invalid input parameter for GetNameComponentsDisplay() !!")
     SET returnval = 1
    ENDIF
    FREE RECORD counters
    RETURN(returnval)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 procedures[*]
      2 providers[*]
        3 proc_prsnl_reltn_id = f8
        3 provider_id = f8
        3 provider_name = vc
        3 procedure_reltn_cd = f8
      2 comments[*]
        3 comment_id = f8
        3 prsnl_id = f8
        3 comment_dt_tm = dq8
        3 comment = vc
        3 prsnl_name = vc
        3 comment_tz = i4
      2 modifier_groups[*]
        3 sequence = i4
        3 modifiers[*]
          4 proc_modifier_id = f8
          4 sequence = i4
          4 nomenclature_id = f8
          4 source_string = vc
          4 concept_cki = vc
          4 source_vocabulary_cd = f8
          4 source_identifier = vc
      2 diagnosis_groups[*]
        3 nomen_entity_reltn_id = f8
        3 diagnosis_group_id = f8
      2 procedure_id = f8
      2 version = i4
      2 encounter_id = f8
      2 nomenclature_id = f8
      2 source_string = vc
      2 concept_cki = vc
      2 source_vocabulary_cd = f8
      2 source_identifier = vc
      2 performed_dt_tm = dq8
      2 performed_dt_tm_prec = i4
      2 minutes = i4
      2 priority = i4
      2 anesthesia_cd = f8
      2 anesthesia_minutes = i4
      2 tissue_type_cd = f8
      2 location_id = f8
      2 free_text_location = vc
      2 free_text = vc
      2 note = vc
      2 ranking_cd = f8
      2 clinical_service_cd = f8
      2 active_ind = i2
      2 end_effective_dt_tm = dq8
      2 contributor_system_cd = f8
      2 procedure_type = i4
      2 suppress_narrative_ind = i2
      2 last_action_dt_tm = dq8
      2 free_text_timeframe = vc
      2 performed_dt_tm_prec_cd = f8
      2 laterality_cd = f8
      2 update_dt_tm = dq8
      2 proc_start_dt_tm = dq8
      2 proc_end_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE location = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE index1 = i4 WITH protect, noconstant(0)
 DECLARE index2 = i4 WITH protect, noconstant(0)
 DECLARE expand_index = i4 WITH protect, noconstant(0)
 DECLARE locate_index = i4 WITH protect, noconstant(0)
 DECLARE prsnl_idx = i4 WITH protect, noconstant(0)
 DECLARE name_idx = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE cur_list_size = i4 WITH protect, constant(size(request->procedures,5))
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 IF (cur_list_size=1)
  SET batch_size = 1
 ELSE
  SET batch_size = 20
 ENDIF
 DECLARE loop_cnt = i4 WITH protect, noconstant(ceil((cnvtreal(cur_list_size)/ batch_size)))
 DECLARE new_list_size = i4 WITH protect, constant((loop_cnt * batch_size))
 DECLARE nomen_cnt = i4 WITH protect, noconstant(0)
 DECLARE nomen_batch_size = i4 WITH protect, noconstant(0)
 DECLARE nomen_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_nomen_size = i4 WITH protect, noconstant(0)
 DECLARE provider_cnt = i4 WITH protect, noconstant(0)
 DECLARE provider_batch_size = i4 WITH protect, noconstant(0)
 DECLARE provider_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_provider_size = i4 WITH protect, noconstant(0)
 DECLARE name_type_prsnl = f8 WITH protect, constant(loadcodevalue(213,"PRSNL",0))
 DECLARE mul_algcat = f8 WITH protect, constant(loadcodevalue(12100,"MUL.ALGCAT",0))
 DECLARE mul_drug = f8 WITH protect, constant(loadcodevalue(12100,"MUL.DRUG",0))
 DECLARE mul_dclass = f8 WITH protect, constant(loadcodevalue(12100,"MUL.DCLASS",1))
 DECLARE gddb_actcomp = f8 WITH protect, constant(loadcodevalue(12100,"GDDB.ACTCOMP",1))
 DECLARE gddb_actgrp = f8 WITH protect, constant(loadcodevalue(12100,"GDDB.ACTGRP",1))
 DECLARE gddb_ggpi = f8 WITH protect, constant(loadcodevalue(12100,"GDDB.GGPI",1))
 DECLARE gddb_hlthiss = f8 WITH protect, constant(loadcodevalue(12100,"GDDB.HLTHISS",1))
 DECLARE gddb_mol = f8 WITH protect, constant(loadcodevalue(12100,"GDDB.MOL",1))
 DECLARE gddb_prod = f8 WITH protect, constant(loadcodevalue(12100,"GDDB.PROD",1))
 DECLARE gddb_prodln = f8 WITH protect, constant(loadcodevalue(12100,"GDDB.PRODLN",1))
 DECLARE gddb_subst = f8 WITH protect, constant(loadcodevalue(12100,"GDDB.SUBST",1))
 SET stat = alterlist(reply->procedures,cur_list_size)
 FOR (index = 1 TO cur_list_size)
   IF ((request->procedures[index].procedure_id <= 0))
    SET failed = attribute_error
    GO TO exit_script
   ELSE
    SET reply->procedures[index].procedure_id = request->procedures[index].procedure_id
   ENDIF
 ENDFOR
 SET stat = alterlist(request->procedures,new_list_size)
 FOR (index = (cur_list_size+ 1) TO new_list_size)
   SET request->procedures[index].procedure_id = request->procedures[cur_list_size].procedure_id
 ENDFOR
 FREE RECORD temp
 RECORD temp(
   1 nomenclatures[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 concept_cki = vc
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
 )
 RECORD proctemp(
   1 qual[*]
     2 date = dq8
 )
 SET stat = alterlist(proctemp->qual,cur_list_size)
 IF (checkdic("PROCEDURE.PROC_START_DT_TM","A",0)
  AND checkdic("PROCEDURE.PROC_END_DT_TM","A",0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    procedure p
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(expand_index,nstart,(nstart+ (batch_size - 1)),p.procedure_id,request->procedures[
     expand_index].procedure_id))
   HEAD REPORT
    count = 0
   DETAIL
    count += 1, location = locateval(locate_index,1,cur_list_size,p.procedure_id,reply->procedures[
     locate_index].procedure_id), reply->procedures[location].active_ind = p.active_ind,
    reply->procedures[location].anesthesia_cd = p.anesthesia_cd, reply->procedures[location].
    anesthesia_minutes = p.anesthesia_minutes, reply->procedures[location].clinical_service_cd = p
    .clinical_service_cd,
    reply->procedures[location].contributor_system_cd = p.contributor_system_cd, reply->procedures[
    location].encounter_id = p.encntr_id, reply->procedures[location].end_effective_dt_tm = p
    .end_effective_dt_tm,
    reply->procedures[location].free_text = p.proc_ftdesc, reply->procedures[location].
    free_text_location = p.proc_ft_loc, reply->procedures[location].free_text_timeframe = p
    .proc_ft_time_frame,
    reply->procedures[location].location_id = p.proc_loc_cd, reply->procedures[location].minutes = p
    .proc_minutes, reply->procedures[location].nomenclature_id = p.nomenclature_id
    IF (p.nomenclature_id > 0.0
     AND locateval(locate_index,1,nomen_cnt,p.nomenclature_id,temp->nomenclatures[locate_index].
     nomenclature_id)=0)
     nomen_cnt += 1
     IF (mod(nomen_cnt,10)=1)
      stat = alterlist(temp->nomenclatures,(nomen_cnt+ 9))
     ENDIF
     temp->nomenclatures[nomen_cnt].nomenclature_id = p.nomenclature_id
    ENDIF
    reply->procedures[location].note = p.procedure_note, reply->procedures[location].performed_dt_tm
     = p.proc_dt_tm, reply->procedures[location].performed_dt_tm_prec = p.proc_dt_tm_prec_flag,
    reply->procedures[location].performed_dt_tm_prec_cd = p.proc_dt_tm_prec_cd, reply->procedures[
    location].priority = p.proc_priority, reply->procedures[location].procedure_type = p
    .proc_type_flag,
    reply->procedures[location].ranking_cd = p.ranking_cd, reply->procedures[location].
    suppress_narrative_ind = p.suppress_narrative_ind, reply->procedures[location].tissue_type_cd = p
    .tissue_type_cd,
    reply->procedures[location].version = p.updt_cnt, reply->procedures[location].laterality_cd = p
    .laterality_cd, proctemp->qual[location].date = p.updt_dt_tm
    IF (validate(reply->procedures[location].update_dt_tm))
     stat = assign(validate(reply->procedures[location].update_dt_tm),p.updt_dt_tm)
    ENDIF
    IF (validate(reply->procedures[location].proc_start_dt_tm))
     stat = assign(validate(reply->procedures[location].proc_start_dt_tm),p.proc_start_dt_tm)
    ENDIF
    IF (validate(reply->procedures[location].proc_end_dt_tm))
     stat = assign(validate(reply->procedures[location].proc_end_dt_tm),p.proc_end_dt_tm)
    ENDIF
   FOOT REPORT
    stat = alterlist(temp->nomenclatures,nomen_cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    procedure p
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(expand_index,nstart,(nstart+ (batch_size - 1)),p.procedure_id,request->procedures[
     expand_index].procedure_id))
   HEAD REPORT
    count = 0
   DETAIL
    count += 1, location = locateval(locate_index,1,cur_list_size,p.procedure_id,reply->procedures[
     locate_index].procedure_id), reply->procedures[location].active_ind = p.active_ind,
    reply->procedures[location].anesthesia_cd = p.anesthesia_cd, reply->procedures[location].
    anesthesia_minutes = p.anesthesia_minutes, reply->procedures[location].clinical_service_cd = p
    .clinical_service_cd,
    reply->procedures[location].contributor_system_cd = p.contributor_system_cd, reply->procedures[
    location].encounter_id = p.encntr_id, reply->procedures[location].end_effective_dt_tm = p
    .end_effective_dt_tm,
    reply->procedures[location].free_text = p.proc_ftdesc, reply->procedures[location].
    free_text_location = p.proc_ft_loc, reply->procedures[location].free_text_timeframe = p
    .proc_ft_time_frame,
    reply->procedures[location].location_id = p.proc_loc_cd, reply->procedures[location].minutes = p
    .proc_minutes, reply->procedures[location].nomenclature_id = p.nomenclature_id
    IF (p.nomenclature_id > 0.0
     AND locateval(locate_index,1,nomen_cnt,p.nomenclature_id,temp->nomenclatures[locate_index].
     nomenclature_id)=0)
     nomen_cnt += 1
     IF (mod(nomen_cnt,10)=1)
      stat = alterlist(temp->nomenclatures,(nomen_cnt+ 9))
     ENDIF
     temp->nomenclatures[nomen_cnt].nomenclature_id = p.nomenclature_id
    ENDIF
    reply->procedures[location].note = p.procedure_note, reply->procedures[location].performed_dt_tm
     = p.proc_dt_tm, reply->procedures[location].performed_dt_tm_prec = p.proc_dt_tm_prec_flag,
    reply->procedures[location].performed_dt_tm_prec_cd = p.proc_dt_tm_prec_cd, reply->procedures[
    location].priority = p.proc_priority, reply->procedures[location].procedure_type = p
    .proc_type_flag,
    reply->procedures[location].ranking_cd = p.ranking_cd, reply->procedures[location].
    suppress_narrative_ind = p.suppress_narrative_ind, reply->procedures[location].tissue_type_cd = p
    .tissue_type_cd,
    reply->procedures[location].version = p.updt_cnt, reply->procedures[location].laterality_cd = p
    .laterality_cd, proctemp->qual[location].date = p.updt_dt_tm
    IF (validate(reply->procedures[location].update_dt_tm))
     stat = assign(validate(reply->procedures[location].update_dt_tm),p.updt_dt_tm)
    ENDIF
   FOOT REPORT
    stat = alterlist(temp->nomenclatures,nomen_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (count != cur_list_size)
  SET failed = select_error
  SET table_name = "PROCEDURE"
  GO TO exit_script
 ENDIF
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   proc_modifier pm
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (pm
   WHERE expand(expand_index,nstart,(nstart+ (batch_size - 1)),pm.parent_entity_id,request->
    procedures[expand_index].procedure_id)
    AND pm.parent_entity_name="PROCEDURE"
    AND pm.active_ind=1
    AND pm.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY pm.parent_entity_id, pm.group_seq, pm.sequence
  HEAD REPORT
   IF (nomen_cnt > 0)
    stat = alterlist(temp->nomenclatures,(nomen_cnt+ (10 - mod(nomen_cnt,10))))
   ENDIF
  HEAD pm.parent_entity_id
   modifier_groups = 0, location = locateval(locate_index,1,cur_list_size,pm.parent_entity_id,reply->
    procedures[locate_index].procedure_id)
  HEAD pm.group_seq
   modifier_groups += 1
   IF (mod(modifier_groups,10)=1)
    stat = alterlist(reply->procedures[location].modifier_groups,(modifier_groups+ 9))
   ENDIF
   reply->procedures[location].modifier_groups[modifier_groups].sequence = pm.group_seq, modifiers =
   0
  DETAIL
   modifiers += 1
   IF (mod(modifiers,10)=1)
    stat = alterlist(reply->procedures[location].modifier_groups[modifier_groups].modifiers,(
     modifiers+ 9))
   ENDIF
   reply->procedures[location].modifier_groups[modifier_groups].modifiers[modifiers].proc_modifier_id
    = pm.proc_modifier_id, reply->procedures[location].modifier_groups[modifier_groups].modifiers[
   modifiers].sequence = pm.sequence, reply->procedures[location].modifier_groups[modifier_groups].
   modifiers[modifiers].nomenclature_id = pm.nomenclature_id
   IF (pm.nomenclature_id > 0.0
    AND locateval(locate_index,1,nomen_cnt,pm.nomenclature_id,temp->nomenclatures[locate_index].
    nomenclature_id)=0)
    nomen_cnt += 1
    IF (mod(nomen_cnt,10)=1)
     stat = alterlist(temp->nomenclatures,(nomen_cnt+ 9))
    ENDIF
    temp->nomenclatures[nomen_cnt].nomenclature_id = pm.nomenclature_id
   ENDIF
  FOOT  pm.group_seq
   stat = alterlist(reply->procedures[location].modifier_groups[modifier_groups].modifiers,modifiers)
  FOOT  pm.parent_entity_id
   stat = alterlist(reply->procedures[location].modifier_groups,modifier_groups)
  FOOT REPORT
   stat = alterlist(temp->nomenclatures,nomen_cnt)
  WITH nocounter
 ;end select
 IF (nomen_cnt > 0)
  IF (nomen_cnt=1)
   SET nomen_batch_size = 1
  ELSE
   SET nomen_batch_size = 20
  ENDIF
  SET nomen_loop_cnt = ceil((cnvtreal(nomen_cnt)/ nomen_batch_size))
  SET new_nomen_size = (nomen_loop_cnt * nomen_batch_size)
  SET stat = alterlist(temp->nomenclatures,new_nomen_size)
  FOR (index = (nomen_cnt+ 1) TO new_nomen_size)
    SET temp->nomenclatures[index].nomenclature_id = temp->nomenclatures[nomen_cnt].nomenclature_id
  ENDFOR
  SET nstart = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nomen_loop_cnt)),
    nomenclature n
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nomen_batch_size))))
    JOIN (n
    WHERE expand(expand_index,nstart,(nstart+ (nomen_batch_size - 1)),n.nomenclature_id,temp->
     nomenclatures[expand_index].nomenclature_id))
   DETAIL
    location = locateval(locate_index,1,nomen_cnt,n.nomenclature_id,temp->nomenclatures[locate_index]
     .nomenclature_id), temp->nomenclatures[location].source_string = n.source_string, temp->
    nomenclatures[location].source_identifier = n.source_identifier,
    temp->nomenclatures[location].source_vocabulary_cd = n.source_vocabulary_cd
    IF (textlen(trim(n.concept_cki)) > 0)
     temp->nomenclatures[location].concept_cki = n.concept_cki
    ELSEIF (n.concept_source_cd > 0
     AND n.concept_source_cd IN (mul_algcat, mul_dclass, mul_drug, gddb_actcomp, gddb_actgrp,
    gddb_ggpi, gddb_hlthiss, gddb_mol, gddb_prod, gddb_prodln,
    gddb_subst))
     IF (textlen(trim(n.concept_identifier)) > 0)
      temp->nomenclatures[location].concept_cki = build(uar_get_code_meaning(n.concept_source_cd),"!",
       n.concept_identifier)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(temp->nomenclatures,nomen_cnt)
  FOR (index = 1 TO cur_list_size)
    IF ((reply->procedures[index].nomenclature_id > 0.0))
     SET location = locateval(locate_index,1,nomen_cnt,reply->procedures[index].nomenclature_id,temp
      ->nomenclatures[locate_index].nomenclature_id)
     IF (location > 0)
      SET reply->procedures[index].concept_cki = temp->nomenclatures[location].concept_cki
      SET reply->procedures[index].source_identifier = temp->nomenclatures[location].
      source_identifier
      SET reply->procedures[index].source_string = temp->nomenclatures[location].source_string
      SET reply->procedures[index].source_vocabulary_cd = temp->nomenclatures[location].
      source_vocabulary_cd
     ENDIF
    ENDIF
    SET modifier_grp_size = size(reply->procedures[index].modifier_groups,5)
    FOR (index1 = 1 TO modifier_grp_size)
     SET modifiers_size = size(reply->procedures[index].modifier_groups[index1].modifiers,5)
     FOR (index2 = 1 TO modifiers_size)
      SET location = locateval(locate_index,1,nomen_cnt,reply->procedures[index].modifier_groups[
       index1].modifiers[index2].nomenclature_id,temp->nomenclatures[locate_index].nomenclature_id)
      IF (location > 0)
       SET reply->procedures[index].modifier_groups[index1].modifiers[index2].concept_cki = temp->
       nomenclatures[location].concept_cki
       SET reply->procedures[index].modifier_groups[index1].modifiers[index2].source_identifier =
       temp->nomenclatures[location].source_identifier
       SET reply->procedures[index].modifier_groups[index1].modifiers[index2].source_string = temp->
       nomenclatures[location].source_string
       SET reply->procedures[index].modifier_groups[index1].modifiers[index2].source_vocabulary_cd =
       temp->nomenclatures[location].source_vocabulary_cd
      ENDIF
     ENDFOR
    ENDFOR
  ENDFOR
 ENDIF
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   procedure_action pa
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (pa
   WHERE expand(expand_index,nstart,(nstart+ (batch_size - 1)),pa.procedure_id,request->procedures[
    expand_index].procedure_id)
    AND (pa.prsnl_id=reqinfo->updt_id))
  ORDER BY pa.procedure_id
  FOOT  pa.procedure_id
   location = locateval(locate_index,1,cur_list_size,pa.procedure_id,reply->procedures[locate_index].
    procedure_id), reply->procedures[location].last_action_dt_tm = max(pa.action_dt_tm)
  WITH nocounter
 ;end select
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   proc_prsnl_reltn ppr
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (ppr
   WHERE expand(expand_index,nstart,(nstart+ (batch_size - 1)),ppr.procedure_id,request->procedures[
    expand_index].procedure_id)
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY ppr.procedure_id
  HEAD ppr.procedure_id
   prsnl_cnt = 0, location = locateval(locate_index,1,cur_list_size,ppr.procedure_id,reply->
    procedures[locate_index].procedure_id)
  DETAIL
   prsnl_cnt += 1
   IF (mod(prsnl_cnt,10)=1)
    stat = alterlist(reply->procedures[location].providers,(prsnl_cnt+ 9))
   ENDIF
   reply->procedures[location].providers[prsnl_cnt].proc_prsnl_reltn_id = ppr.proc_prsnl_reltn_id,
   reply->procedures[location].providers[prsnl_cnt].procedure_reltn_cd = ppr.proc_prsnl_reltn_cd,
   reply->procedures[location].providers[prsnl_cnt].provider_id = ppr.prsnl_person_id
   IF (ppr.proc_ft_prsnl != null
    AND ppr.proc_ft_prsnl != "")
    reply->procedures[location].providers[prsnl_cnt].provider_name = ppr.proc_ft_prsnl
   ELSE
    IF (ppr.prsnl_person_id > 0.0)
     provider_cnt += 1
     IF (mod(provider_cnt,10)=1)
      stat = alterlist(persons->qual,(provider_cnt+ 9))
     ENDIF
     persons->qual[provider_cnt].person_id = ppr.prsnl_person_id, persons->qual[provider_cnt].
     trans_dt_tm = proctemp->qual[location].date, persons->qual[provider_cnt].type_cd =
     name_type_prsnl
    ENDIF
   ENDIF
  FOOT  ppr.procedure_id
   stat = alterlist(reply->procedures[location].providers,prsnl_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(persons->qual,provider_cnt)
 IF (provider_cnt > 0)
  SET stat = getdisplaycomponents(0)
  FOR (index = 1 TO cur_list_size)
   SET provider_size = size(reply->procedures[index].providers,5)
   FOR (index1 = 1 TO provider_size)
     IF ((reply->procedures[index].providers[index1].provider_name=""))
      SET location = locateval(locate_index,1,provider_cnt,reply->procedures[index].providers[index1]
       .provider_id,persons->qual[locate_index].person_id,
       proctemp->qual[index].date,persons->qual[locate_index].trans_dt_tm)
      IF (location > 0
       AND size(persons->qual[location].names,5) > 0
       AND (persons->qual[location].person_id > 0.0))
       SET reply->procedures[index].providers[index1].provider_name = persons->qual[location].names[1
       ].full_name
      ENDIF
     ENDIF
   ENDFOR
  ENDFOR
 ENDIF
 FREE RECORD temp
 FREE RECORD proctemp
 SET stat = initrec(persons)
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   long_text lt
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (lt
   WHERE expand(expand_index,nstart,(nstart+ (batch_size - 1)),lt.parent_entity_id,request->
    procedures[expand_index].procedure_id)
    AND lt.parent_entity_name="PROCEDURE"
    AND lt.active_ind=1)
  ORDER BY lt.parent_entity_id, cnvtdatetime(lt.updt_dt_tm) DESC
  HEAD lt.parent_entity_id
   comments = 0, location = locateval(locate_index,1,cur_list_size,lt.parent_entity_id,reply->
    procedures[locate_index].procedure_id)
  DETAIL
   prsnl_idx += 1, comments += 1
   IF (mod(comments,10)=1)
    stat = alterlist(reply->procedures[location].comments,(comments+ 9))
   ENDIF
   IF (mod(prsnl_idx,10)=1)
    stat = alterlist(persons->qual,(prsnl_idx+ 9))
   ENDIF
   reply->procedures[location].comments[comments].comment = lt.long_text, reply->procedures[location]
   .comments[comments].comment_dt_tm = lt.updt_dt_tm, reply->procedures[location].comments[comments].
   comment_id = lt.long_text_id,
   reply->procedures[location].comments[comments].prsnl_id = lt.updt_id, persons->qual[prsnl_idx].
   person_id = lt.updt_id, persons->qual[prsnl_idx].type_cd = name_type_prsnl,
   persons->qual[prsnl_idx].trans_dt_tm = lt.updt_dt_tm
   IF (checkdic("LONG_TEXT.UPDT_TZ","A",0) > 0)
    stat = assign(validate(reply->procedures[location].comments[comments].comment_tz),lt.updt_tz)
   ENDIF
  FOOT  lt.parent_entity_id
   stat = alterlist(reply->procedures[location].comments,comments)
  FOOT REPORT
   stat = alterlist(persons->qual,prsnl_idx)
  WITH nocounter
 ;end select
 CALL echorecord(persons)
 IF (size(persons->qual,5) > 0)
  SET stat = getdisplaycomponents(0)
 ENDIF
 CALL echorecord(persons)
 FOR (ii = 1 TO size(reply->procedures,5))
   FOR (jj = 1 TO size(reply->procedures[ii].comments,5))
    SET name_idx = locateval(locate_index,1,size(persons->qual,5),reply->procedures[ii].comments[jj].
     prsnl_id,persons->qual[locate_index].person_id,
     reply->procedures[ii].comments[jj].comment_dt_tm,persons->qual[locate_index].trans_dt_tm)
    IF (name_idx > 0
     AND size(persons->qual[name_idx].names,5) > 0
     AND (persons->qual[name_idx].person_id > 0.0))
     SET reply->procedures[ii].comments[jj].prsnl_name = persons->qual[name_idx].names[1].full_name
    ENDIF
   ENDFOR
 ENDFOR
 CALL echorecord(persons)
 SET nstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   nomen_entity_reltn ner
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (ner
   WHERE expand(expand_index,nstart,(nstart+ (batch_size - 1)),ner.child_entity_id,request->
    procedures[expand_index].procedure_id)
    AND ner.child_entity_name="PROCEDURE"
    AND ner.active_ind=1
    AND ner.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ner.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY ner.child_entity_id
  HEAD ner.child_entity_id
   diag_group_cnt = 0, location = locateval(locate_index,1,cur_list_size,ner.child_entity_id,reply->
    procedures[locate_index].procedure_id)
  DETAIL
   diag_group_cnt += 1
   IF (mod(diag_group_cnt,10)=1)
    stat = alterlist(reply->procedures[location].diagnosis_groups,(diag_group_cnt+ 9))
   ENDIF
   reply->procedures[location].diagnosis_groups[diag_group_cnt].nomen_entity_reltn_id = ner
   .nomen_entity_reltn_id, reply->procedures[location].diagnosis_groups[diag_group_cnt].
   diagnosis_group_id = ner.parent_entity_id
  FOOT  ner.child_entity_id
   stat = alterlist(reply->procedures[location].diagnosis_groups,diag_group_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET stat = alterlist(request->procedures,cur_list_size)
 IF ( NOT (failed))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data = "F"
  SET stat = alterlist(reply->procedures,0)
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO

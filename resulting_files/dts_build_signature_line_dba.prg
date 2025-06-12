CREATE PROGRAM dts_build_signature_line:dba
 IF ((request->called_ind != "Y"))
  RECORD reply(
    1 qual[*]
      2 signature_line = vc
    1 signature_line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 SUBROUTINE (formatname(formatdesc=vc,retstring=vc(ref),firstname=vc,middlename=vc,lastname=vc,
  namefullformat=vc) =null WITH protect)
   DECLARE iposnameformat = i4 WITH noconstant(0)
   DECLARE curpos = i4 WITH noconstant(0)
   DECLARE nextpos = i4 WITH noconstant(0)
   DECLARE sresult = vc WITH noconstant("")
   DECLARE token = vc WITH noconstant("")
   DECLARE bcontinueloop = i2 WITH noconstant(1)
   SET retstring = ""
   SET iposnameformat = findstring("#NameFormat#",formatdesc)
   IF (iposnameformat=0)
    SET sresult = namefullformat
   ELSE
    SET iformatdesclen = textlen(trim(formatdesc))
    SET curpos = findstring("#",formatdesc,(iposnameformat+ 1),0)
    SET nextpos = findstring("%",formatdesc,1,0)
    IF (nextpos=0)
     SET token = notrim(substring((curpos+ 1),((iformatdesclen - curpos) - 1),formatdesc))
     IF (sresult="")
      SET sresult = notrim(token)
     ELSE
      SET sresult = notrim(build2(notrim(sresult),notrim(token)))
     ENDIF
    ELSE
     SET bcontinueloop = 1
     WHILE (((curpos+ 1) <= iformatdesclen)
      AND bcontinueloop != 0)
       SET token = notrim(substring((curpos+ 1),((nextpos - curpos) - 1),formatdesc))
       IF (token="FN")
        IF (sresult="")
         SET sresult = trim(firstname)
        ELSE
         SET sresult = notrim(build2(notrim(sresult),trim(firstname)))
        ENDIF
       ELSEIF (token="MN")
        IF (sresult="")
         SET sresult = trim(middlename)
        ELSE
         SET sresult = notrim(build2(notrim(sresult),trim(middlename)))
        ENDIF
       ELSEIF (token="LN")
        IF (sresult="")
         SET sresult = trim(lastname)
        ELSE
         SET sresult = notrim(build2(notrim(sresult),trim(lastname)))
        ENDIF
       ELSEIF (token="NFF")
        IF (sresult="")
         SET sresult = namefullformat
        ELSE
         SET sresult = notrim(build2(notrim(sresult),trim(namefullformat)))
        ENDIF
       ELSE
        IF (sresult="")
         SET sresult = notrim(token)
        ELSE
         SET sresult = notrim(build2(notrim(sresult),notrim(token)))
        ENDIF
       ENDIF
       SET curpos = nextpos
       SET nextpos = findstring("%",formatdesc,(curpos+ 1),0)
       IF (nextpos=0)
        SET token = notrim(substring((curpos+ 1),((iformatdesclen - curpos) - 1),formatdesc))
        SET bcontinueloop = 0
        IF (sresult="")
         SET sresult = notrim(token)
        ELSE
         SET sresult = notrim(build2(notrim(sresult),notrim(token)))
        ENDIF
       ENDIF
     ENDWHILE
    ENDIF
   ENDIF
   SET retstring = notrim(sresult)
 END ;Subroutine
 DECLARE bretrievedprsnldata = i2
 DECLARE cnt_qualified = i2
 DECLARE cur_col_pos = i2
 DECLARE cur_row = i2
 DECLARE cur_row_pos = i2
 DECLARE iapiip = i2
 DECLARE ibsldr = i2
 DECLARE igpip = i2
 DECLARE igvd = i2
 DECLARE iaction_prsnl = i2
 DECLARE max_cols = i2
 DECLARE nprsnlitem = i2
 DECLARE prsnl_cnt = i2
 DECLARE prsnl_ind = i2
 DECLARE resi_ind = i2
 DECLARE t_prsnl_id = f8
 DECLARE return_string = c200
 DECLARE return_val = i2
 DECLARE action_prsnl_cnt = i2
 DECLARE status_flag = i2
 DECLARE action_date = c20
 DECLARE action_time = c20
 DECLARE action_status = c20
 DECLARE formatid = f8
 DECLARE brule = i2
 DECLARE rule_type = c20
 DECLARE rule_value = c200
 DECLARE address_ind = i2
 DECLARE request_comment = c200
 DECLARE action_comment = c120
 RECORD prsnl_info(
   1 qual[*]
     2 prsnl_id = f8
     2 initials = c3
     2 action_dt_tm = dq8
     2 action_type_mean = c12
     2 action_status_mean = c12
     2 proxy_prsnl_id = f8
     2 name_full = c100
     2 name_first = c100
     2 name_middle = c100
     2 name_last = c100
     2 name_title = c100
     2 street_addr = c100
     2 street_addr2 = c100
     2 street_addr3 = c100
     2 street_addr4 = c100
     2 city = c100
     2 state = c100
     2 zipcode = c25
     2 contactname = c200
     2 comment = c200
 )
 RECORD temp(
   1 qual[*]
     2 line_nbr = i4
     2 column_pos = i4
     2 meaning = c12
     2 literal_display = vc
     2 max_size = i4
     2 literal_size = i4
     2 used = i2
     2 format_desc = c60
 )
 RECORD rule(
   1 qual[*]
     2 index = i4
     2 line_nbr = i4
     2 column_pos = i4
     2 meaning = c12
     2 literal_display = vc
     2 max_size = i4
     2 literal_size = i4
 )
 RECORD tempdate(
   1 date_now = dq8
   1 date_tz = i4
 )
 DECLARE add_type_cd = f8 WITH constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE prsnl_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL"))
 DECLARE saction_status_completed = c9 WITH constant("COMPLETED")
 SET iapiip = 0
 SET ibsldr = 0
 SET igpip = 0
 SET igvd = 0
 SET iaction_prsnl = 0
 SET bretrievedprsnldata = 0
 SET cnt_qualified = 0
 SET cur_row = 0
 SET cur_row_pos = 0
 SET cur_col_pos = 0
 SET max_cols = 0
 SET nprsnlitem = 0
 SET prsnl_cnt = 0
 SET prsnl_ind = 0
 SET resi_ind = 0
 SET t_prsnl_id = 0.0
 SET return_string = fillstring(200," ")
 SET return_val = 0
 SET action_prsnl_cnt = 0
 SET status_flag = 0
 SET action_date = fillstring(20," ")
 SET brule = 0
 SET rule_type = fillstring(20," ")
 SET rule_value = fillstring(20," ")
 SET address_ind = 0
 SET cdf_meaning = fillstring(20," ")
 SET request_comment = fillstring(200," ")
 SET action_comment = fillstring(120," ")
 DECLARE date_example = vc
 DECLARE findpt = i2
 DECLARE deflength = i2
 DECLARE date_mask = c100
 DECLARE time_mask = c100
 DECLARE time_now = c100
 DECLARE zone_now = c100
 DECLARE default_format = c20
 SET findpt = 0
 SET deflength = 0
 SET date_mask = fillstring(100," ")
 SET time_mask = fillstring(100," ")
 SET time_now = fillstring(100," ")
 SET zone_now = fillstring(100," ")
 SET default_format = fillstring(20," ")
 SET subtypecd = request->activity_subtype_cd
 IF (subtypecd=0)
  SET subtypecd = uar_get_code_by("MEANING",5801,"TRANSCRIPT")
 ENDIF
 DECLARE clindoccd = f8 WITH constant(uar_get_code_by("MEANING",106,"CLINDOC"))
 SET reply->status_data.status = "F"
 IF ((request->status_mean IN ("AUTH", "ALTERED", "MODIFIED")))
  SET status_flag = 2
 ELSE
  SET status_flag = 1
 ENDIF
 SET action_prsnl_cnt = size(request->action_prsnl_qual,5)
 SET stat = alterlist(reply->qual,action_prsnl_cnt)
 IF (action_prsnl_cnt <= 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "EXECUTE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Script"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Prsnl list empty!"
  GO TO exit_program
 ENDIF
 SET stat = alterlist(request->row_qual,0)
 SET request->max_cols = 0
 SET request->called_ind = "Y"
 SET return_val = getformat(status_flag)
 IF (return_val > 0)
  IF (prsnl_ind=1)
   CALL retrieveprsnlinfo(0)
  ENDIF
  CALL buildsldatarequest(return_val)
  EXECUTE aps_get_signature_line
  SET reply->qual[1].signature_line = reply->signature_line
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "GetFormat"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Script"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid signature line format found"
 ENDIF
 SET reply->status_data.status = "S"
#exit_program
 DECLARE getformat(gffsstatus_flag) = i2
 SUBROUTINE getformat(gffsstatus_flag)
   CALL echo("Just entered GetFormat...")
   SET cnt_qualified = 0
   SET stat = alterlist(temp->qual,0)
   SELECT INTO "nl:"
    sldr.task_assay_cd, sldr.status_flag, slf.format_id,
    slfd.format_id, slfd.sequence, cv.cdf_meaning,
    format_desc = uar_get_code_description(slfd.data_element_format_cd)
    FROM discrete_task_assay dta,
     sign_line_dta_r sldr,
     sign_line_format slf,
     sign_line_format_detail slfd,
     code_value cv
    PLAN (dta
     WHERE dta.activity_type_cd=clindoccd
      AND (dta.event_cd=request->event_cd))
     JOIN (sldr
     WHERE sldr.task_assay_cd=dta.task_assay_cd
      AND sldr.status_flag IN (gffsstatus_flag, 0)
      AND sldr.activity_subtype_cd=subtypecd)
     JOIN (slf
     WHERE sldr.format_id=slf.format_id
      AND slf.active_ind=1)
     JOIN (slfd
     WHERE sldr.format_id=slfd.format_id)
     JOIN (cv
     WHERE slfd.data_element_cd=cv.code_value)
    ORDER BY slfd.format_id DESC, sldr.task_assay_cd DESC, sldr.status_flag DESC,
     slfd.sequence
    HEAD REPORT
     cnt = 0, cnt_qualified = 0, temp_status_flag = 0,
     temp_task_assay_cd = 0.0
    DETAIL
     cnt += 1
     IF (cnt=1)
      temp_task_assay_cd = sldr.task_assay_cd, temp_status_flag = sldr.status_flag
     ENDIF
     IF (sldr.task_assay_cd=temp_task_assay_cd
      AND sldr.status_flag=temp_status_flag)
      cnt_qualified += 1
      IF (mod(cnt_qualified,10)=1)
       stat = alterlist(temp->qual,(cnt_qualified+ 9))
      ENDIF
      temp->qual[cnt_qualified].line_nbr = slfd.line_nbr, temp->qual[cnt_qualified].column_pos = slfd
      .column_pos
      IF (cv.code_value != 0.0)
       temp->qual[cnt_qualified].meaning = cv.cdf_meaning
      ELSE
       temp->qual[cnt_qualified].meaning = ""
      ENDIF
      temp->qual[cnt_qualified].literal_display = slfd.literal_display, temp->qual[cnt_qualified].
      max_size = slfd.max_size, temp->qual[cnt_qualified].literal_size = slfd.literal_size,
      temp->qual[cnt_qualified].used = 0
      IF (cv.code_value != 0.0
       AND  NOT (cv.cdf_meaning IN ("CNTRANSDT", "CNTRANSTM", "CNDICTDT", "CNDICTTM", "CNSIGNDT",
      "CNSIGNTM")))
       prsnl_ind = 1
      ENDIF
      temp->qual[cnt_qualified].format_desc = format_desc
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->qual,cnt_qualified)
    WITH nocounter
   ;end select
   RETURN(cnt_qualified)
 END ;Subroutine
 SUBROUTINE addprsnlinfoitem(apiiprsnlid,action_dt_tm,action_type_mean,action_status_mean)
   IF (apiiprsnlid != 0)
    SET nprsnlitem = 0
    SET iapiip = 1
    WHILE (iapiip <= prsnl_cnt
     AND nprsnlitem=0)
     IF ((apiiprsnlid=prsnl_info->qual[iapiip].prsnl_id)
      AND (action_type_mean=prsnl_info->qual[iapiip].action_type_mean)
      AND (action_dt_tm=prsnl_info->qual[iapiip].action_dt_tm))
      SET nprsnlitem = iapiip
     ENDIF
     SET iapiip += 1
    ENDWHILE
    IF (nprsnlitem=0)
     SET prsnl_cnt += 1
     SET stat = alterlist(prsnl_info->qual,prsnl_cnt)
     SET prsnl_info->qual[prsnl_cnt].prsnl_id = apiiprsnlid
     SET prsnl_info->qual[prsnl_cnt].action_dt_tm = action_dt_tm
     SET prsnl_info->qual[prsnl_cnt].action_type_mean = action_type_mean
     SET prsnl_info->qual[prsnl_cnt].action_status_mean = action_status_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getprsnlinfobyid(gpiprsnlid,saction,action_dt_tm)
  SET nprsnlitem = 0
  IF (gpiprsnlid != 0)
   SET igpip = 1
   WHILE (igpip <= prsnl_cnt
    AND nprsnlitem=0)
    IF ((gpiprsnlid=prsnl_info->qual[igpip].prsnl_id)
     AND (saction=prsnl_info->qual[igpip].action_type_mean)
     AND (action_dt_tm=prsnl_info->qual[igpip].action_dt_tm))
     SET nprsnlitem = igpip
    ENDIF
    SET igpip += 1
   ENDWHILE
  ENDIF
 END ;Subroutine
 SUBROUTINE retrievetemporaryprsnlinfo(nindex)
   SELECT INTO "nl:"
    FROM prsnl pr
    WHERE (pr.person_id=prsnl_info->qual[nindex].prsnl_id)
     AND pr.active_ind=1
    DETAIL
     prsnl_info->qual[nindex].name_full = trim(pr.name_full_formatted), prsnl_info->qual[nindex].
     name_first = trim(pr.name_first), prsnl_info->qual[nindex].name_middle = "",
     prsnl_info->qual[nindex].name_last = trim(pr.name_last)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE retrieveprsnlinfo(rpidummy)
   IF (bretrievedprsnldata=0)
    FOR (ib = 1 TO action_prsnl_cnt)
     CALL addprsnlinfoitem(request->action_prsnl_qual[ib].action_prsnl_id,request->action_prsnl_qual[
      ib].action_dt_tm,request->action_prsnl_qual[ib].action_type_mean,request->action_prsnl_qual[ib]
      .action_status_mean)
     IF ((request->action_prsnl_qual[ib].proxy_prsnl_id > 0))
      CALL addprsnlinfoitem(request->action_prsnl_qual[ib].proxy_prsnl_id,request->action_prsnl_qual[
       ib].action_dt_tm,request->action_prsnl_qual[ib].action_type_mean,request->action_prsnl_qual[ib
       ].action_status_mean)
     ENDIF
    ENDFOR
    IF (prsnl_cnt > 0)
     SET stat = alterlist(persons->qual,prsnl_cnt)
     FOR (ib = 1 TO prsnl_cnt)
       SET persons->qual[ib].person_id = prsnl_info->qual[ib].prsnl_id
       SET persons->qual[ib].type_cd = prsnl_cd
       SET persons->qual[ib].trans_dt_tm = prsnl_info->qual[ib].action_dt_tm
     ENDFOR
     SET status = getdisplaycomponents(0)
     SET prsnl_name_cnt = 0
     FOR (ib = 1 TO prsnl_cnt)
      SET prsnl_name_cnt = size(persons->qual[ib].names,5)
      IF (prsnl_name_cnt > 0)
       SET prsnl_info->qual[ib].name_full = trim(persons->qual[ib].names[1].full_name)
       SET prsnl_info->qual[ib].name_first = persons->qual[ib].names[1].first
       SET prsnl_info->qual[ib].name_middle = persons->qual[ib].names[1].middle
       SET prsnl_info->qual[ib].name_last = persons->qual[ib].names[1].last
       SET prsnl_info->qual[ib].name_title = persons->qual[ib].names[1].title
       SET prsnl_info->qual[ib].initials = persons->qual[ib].names[1].initials
      ELSE
       CALL retrievetemporaryprsnlinfo(ib)
      ENDIF
     ENDFOR
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(prsnl_cnt)),
       address a
      PLAN (d)
       JOIN (a
       WHERE (a.parent_entity_id=prsnl_info->qual[d.seq].prsnl_id)
        AND a.active_ind=1
        AND a.address_type_cd=add_type_cd
        AND a.parent_entity_name="PERSON")
      DETAIL
       prsnl_info->qual[d.seq].street_addr = trim(a.street_addr), prsnl_info->qual[d.seq].
       street_addr2 = trim(a.street_addr2), prsnl_info->qual[d.seq].street_addr3 = trim(a
        .street_addr3),
       prsnl_info->qual[d.seq].street_addr4 = trim(a.street_addr4), prsnl_info->qual[d.seq].city =
       trim(a.city), prsnl_info->qual[d.seq].state = trim(a.state),
       prsnl_info->qual[d.seq].zipcode = trim(a.zipcode), prsnl_info->qual[d.seq].contactname = trim(
        a.contact_name), prsnl_info->qual[d.seq].comment = trim(a.comment_txt)
      WITH nocounter
     ;end select
    ENDIF
    SET bretrievedprsnldata = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE buildsldatarequest(bsldrcnt)
   CALL echo("Just entered BuildSLDataRequest...")
   SET cur_row_pos = 0
   SET cur_row = 0
   SET max_cols = 0
   SET next_line = 0
   SET diff = 0
   SET ind1 = 0
   FOR (ibsldr = 1 TO bsldrcnt)
     SET return_string = fillstring(200," ")
     SET brule = 0
     SET nprsnlitem = 0
     SET binsert = 0
     IF (ibsldr > 1)
      SET ind1 = (ibsldr - 1)
      SET diff = (temp->qual[ibsldr].line_nbr - temp->qual[ind1].line_nbr)
     ENDIF
     CALL getvaluedata(trim(temp->qual[ibsldr].meaning),temp->qual[ibsldr].format_desc)
     IF (brule=1
      AND (temp->qual[ibsldr].used=0))
      CALL buildrules(rule_type)
     ENDIF
     SET binsert = 1
     IF (brule=0
      AND (temp->qual[ibsldr].used=0))
      IF ((temp->qual[ibsldr].line_nbr != cur_row))
       SET next_line = 1
       SET cur_row_pos += 1
       SET cur_row = temp->qual[ibsldr].line_nbr
       SET cur_col_pos = 1
       SET stat = alterlist(request->row_qual,cur_row_pos)
       SET stat = alterlist(request->row_qual[cur_row_pos].col_qual,cur_col_pos)
       SET request->row_qual[cur_row_pos].line_num = temp->qual[ibsldr].line_nbr
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].position = temp->qual[ibsldr].
       column_pos
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].max_size = temp->qual[ibsldr].
       max_size
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_size = temp->qual[ibsldr].
       literal_size
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr].
       literal_display
       IF (trim(temp->qual[ibsldr].meaning) != "")
        CALL getvaluedata(trim(temp->qual[ibsldr].meaning),temp->qual[ibsldr].format_desc)
        SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].value = trim(return_string)
        IF (textlen(trim(return_string))=0)
         SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = ""
        ELSE
         SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr
         ].literal_display
        ENDIF
       ENDIF
      ELSE
       SET cur_col_pos += 1
       SET next_line = 0
       SET stat = alterlist(request->row_qual[cur_row_pos].col_qual,cur_col_pos)
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].position = temp->qual[ibsldr].
       column_pos
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].max_size = temp->qual[ibsldr].
       max_size
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_size = temp->qual[ibsldr].
       literal_size
       SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr].
       literal_display
       IF (trim(temp->qual[ibsldr].meaning) != "")
        CALL getvaluedata(trim(temp->qual[ibsldr].meaning),temp->qual[ibsldr].format_desc)
        SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].value = trim(return_string)
        IF (textlen(trim(return_string))=0)
         SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = ""
        ELSE
         SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr
         ].literal_display
        ENDIF
       ENDIF
      ENDIF
      IF (cur_col_pos > max_cols)
       SET max_cols = cur_col_pos
      ENDIF
     ENDIF
   ENDFOR
   SET request->max_cols = max_cols
 END ;Subroutine
 SUBROUTINE findactionperson(saction)
   CALL echo("Just entered FindAuthor...")
   SET nprsnlitem = 0
   SET ib = 1
   IF (saction="PROXY")
    SET iproxy = 1
    SET saction = "SIGN"
   ELSE
    SET iproxy = 0
   ENDIF
   WHILE (ib <= action_prsnl_cnt
    AND nprsnlitem=0)
    IF ((request->action_prsnl_qual[ib].action_type_mean=saction))
     IF (iproxy=0)
      CALL getprsnlinfobyid(request->action_prsnl_qual[ib].action_prsnl_id,saction,request->
       action_prsnl_qual[ib].action_dt_tm)
     ELSE
      CALL getprsnlinfobyid(request->action_prsnl_qual[ib].proxy_prsnl_id,saction,request->
       action_prsnl_qual[ib].action_dt_tm)
     ENDIF
    ENDIF
    SET ib += 1
   ENDWHILE
 END ;Subroutine
 SUBROUTINE findactiondate(saction,formatdesc,defaultformat)
   CALL echo("Just entered FindActionDate...")
   SET nprsnlitem = 0
   SET ib = 1
   SET action_date = fillstring(20," ")
   SET action_time = fillstring(20," ")
   SET default_format = fillstring(20," ")
   WHILE (ib <= action_prsnl_cnt
    AND nprsnlitem=0)
    IF ((request->action_prsnl_qual[ib].action_type_mean=saction))
     SET tempdate->date_now = request->action_prsnl_qual[ib].action_dt_tm
     SET tempdate->date_tz = request->action_prsnl_qual[ib].time_zone
     IF ((tempdate->date_now=null))
      SET return_string = ""
     ELSE
      CALL formatdate(formatdesc,defaultformat)
     ENDIF
     SET nprsnlitem = 1
    ENDIF
    SET ib += 1
   ENDWHILE
   SET nprsnlitem = 0
 END ;Subroutine
 SUBROUTINE formatdate(formatdesc,defaultformat)
   CALL echo("Just entered FormatDate...")
   SET deflength = 0
   SET findptf = 0
   SET findptl = 0
   IF (textlen(trim(formatdesc)) > 0)
    CALL echo("Made it into FormatDate...")
    SET findptf = findstring("|",formatdesc)
    IF (findptf=0)
     SET return_string = format(tempdate->date_now,formatdesc)
    ELSE
     SET findptl = findstring("|",formatdesc,1,1)
     SET deflength = textlen(trim(formatdesc))
     SET date_mask = substring(1,(findptf - 1),formatdesc)
     IF (findptl != findptf)
      SET time_mask = substring((findptf+ 1),((findptl - 1) - findptf),formatdesc)
      SET zone_mask = substring((findptl+ 1),deflength,formatdesc)
      SET zone_now = datetimezoneformat(tempdate->date_now,tempdate->date_tz,"ZZZ")
     ELSE
      SET time_mask = substring((findptf+ 1),deflength,formatdesc)
     ENDIF
     IF (substring(textlen(trim(time_mask)),textlen(trim(time_mask)),formatdesc)="S")
      SET time_now = format(tempdate->date_now,time_mask)
      IF (substring(1,1,time_now)="0")
       SET time_now = substring(2,textlen(time_now),time_now)
      ENDIF
     ELSE
      SET time_now = format(tempdate->date_now,time_mask)
     ENDIF
     IF (findptl != findptf)
      SET return_string = concat(format(tempdate->date_now,date_mask)," ",trim(time_now)," ",zone_now
       )
     ELSE
      SET return_string = concat(format(tempdate->date_now,date_mask)," ",time_now)
     ENDIF
    ENDIF
   ELSE
    SET return_string = format(cnvtdatetime(tempdate->date_now),defaultformat)
   ENDIF
   IF ((tempdate->date_now=null))
    SET return_string = ""
   ENDIF
 END ;Subroutine
 SUBROUTINE findactionstatus(saction)
   CALL echo("Just entered FindActionStatus...")
   SET nprsnlitem = 0
   SET ib = 1
   SET action_status = fillstring(20," ")
   SET action_status_mean = fillstring(20," ")
   WHILE (ib <= action_prsnl_cnt
    AND nprsnlitem=0)
    IF ((request->action_prsnl_qual[ib].action_type_mean=saction))
     SET action_status_mean = request->action_prsnl_qual[ib].action_status_mean
    ENDIF
    SET ib += 1
   ENDWHILE
   SELECT INTO "nl:"
    cv1.description
    FROM code_value cv1
    PLAN (cv1
     WHERE cv1.code_set=103
      AND cv1.cdf_meaning=action_status_mean
      AND cv1.active_ind=1)
    DETAIL
     action_status = cv1.description
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getrequestcomment(saction)
   CALL echo("Just entered GetRequestComment...")
   SET nprsnlitem = 0
   SET ib = 1
   SET request_comment = fillstring(200," ")
   WHILE (ib <= action_prsnl_cnt
    AND nprsnlitem=0)
    IF ((request->action_prsnl_qual[ib].action_type_mean=saction))
     SET request_comment = request->action_prsnl_qual[ib].request_comment
     CALL echo(build("Found Comment...",request_comment))
     SET nprsnlitem = 1
    ENDIF
    SET ib += 1
   ENDWHILE
   CALL echo("EXITING entered GetRequestComment...")
   SET nprsnlitem = 0
 END ;Subroutine
 SUBROUTINE getactioncomment(saction)
   CALL echo("Just entered GetActionComment...")
   SET nprsnlitem = 0
   SET ib = 1
   SET action_comment = fillstring(120," ")
   WHILE (ib <= action_prsnl_cnt
    AND nprsnlitem=0)
    IF ((request->action_prsnl_qual[ib].action_type_mean=saction))
     SET action_comment = request->action_prsnl_qual[ib].action_comment
     CALL echo(build("Found Action Comment...",request_comment))
     SET nprsnlitem = 1
    ENDIF
    SET ib += 1
   ENDWHILE
   SET nprsnlitem = 0
 END ;Subroutine
 SUBROUTINE buildrules(saction1)
   CALL echo(build("Just entered BuildRules...sAction1 = ",saction1))
   SET stemp = fillstring(100," ")
   SET ifirsttime = 0
   SET ic = 1
   SET icnt = 0
   SET cnt2 = 0
   SET rule_cnt = 0
   SET stype = fillstring(50," ")
   SET difference = 0
   SET dindex = 0
   SET dindex1 = 0
   SET dindex2 = 0
   FOR (icnt = ibsldr TO bsldrcnt)
     SET brule = 0
     SET rule_type = " "
     SET rule_value = " "
     CALL getvaluedata(trim(temp->qual[icnt].meaning),temp->qual[icnt].format_desc)
     IF (rule_type=saction1
      AND brule=1)
      SET rule_cnt += 1
      SET stat = alterlist(rule->qual,rule_cnt)
      SET rule->qual[rule_cnt].index = icnt
      SET temp->qual[icnt].used = 1
     ELSE
      SET icnt = bsldrcnt
     ENDIF
   ENDFOR
   IF (rule_cnt=1)
    SET difference = diff
   ELSEIF (rule_cnt > 1)
    SET dindex1 = rule->qual[1].index
    SET dindex2 = rule->qual[rule_cnt].index
    SET difference = ((temp->qual[dindex2].line_nbr - temp->qual[dindex1].line_nbr)+ diff)
   ENDIF
   WHILE (ic <= action_prsnl_cnt)
     CALL echo(build("starting building rules...iC = ",ic))
     IF ((request->action_prsnl_qual[ic].action_type_mean=saction1))
      SET nprsnlitem = 0
      CALL getprsnlinfobyid(request->action_prsnl_qual[ic].action_prsnl_id,request->
       action_prsnl_qual[ic].action_type_mean,request->action_prsnl_qual[ic].action_dt_tm)
      IF (ifirsttime > 0)
       FOR (cnt2 = 1 TO rule_cnt)
         SET rule_value = " "
         SET address_ind = 0
         SET dindex = rule->qual[cnt2].index
         CALL getvaluedata(temp->qual[dindex].meaning,temp->qual[dindex].format_desc)
         IF (address_ind=0)
          CALL addtorequeststructure(0)
         ELSEIF (address_ind=1)
          IF (nprsnlitem != 0)
           CALL getpersonaddress(saction1)
          ENDIF
         ENDIF
       ENDFOR
       FOR (icnt2 = ibsldr TO bsldrcnt)
         SET temp->qual[icnt2].line_nbr += difference
       ENDFOR
      ENDIF
      IF (ifirsttime=0)
       CALL echo(build("skipping the first person..."))
      ENDIF
      SET ifirsttime += 1
     ENDIF
     SET ic += 1
   ENDWHILE
   IF (ifirsttime > 0)
    FOR (icnt2 = ibsldr TO bsldrcnt)
      SET temp->qual[icnt2].line_nbr -= difference
    ENDFOR
   ENDIF
   SET address_ind = 0
   CALL echo(build("Exit BuildRules...sAction1 = ",saction1))
 END ;Subroutine
 SUBROUTINE addtorequeststructure(idummy)
   CALL echo("Just entered AddToRequestStructure...")
   SET indexadd = dindex
   IF ((temp->qual[indexadd].line_nbr != cur_row))
    SET cur_row_pos += 1
    SET cur_row = temp->qual[dindex].line_nbr
    SET cur_col_pos = 1
    SET stat = alterlist(request->row_qual,cur_row_pos)
    SET stat = alterlist(request->row_qual[cur_row_pos].col_qual,cur_col_pos)
    SET request->row_qual[cur_row_pos].line_num = temp->qual[dindex].line_nbr
   ELSE
    SET cur_col_pos += 1
    SET stat = alterlist(request->row_qual[cur_row_pos].col_qual,cur_col_pos)
   ENDIF
   SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].position = temp->qual[dindex].column_pos
   SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].max_size = temp->qual[dindex].max_size
   SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_size = temp->qual[dindex].
   literal_size
   SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].value = trim(rule_value)
   IF (textlen(trim(rule_value))=0)
    SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = ""
   ELSE
    SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[dindex].
    literal_display
   ENDIF
   IF (cur_col_pos > max_cols)
    SET max_cols = cur_col_pos
   ENDIF
 END ;Subroutine
 SUBROUTINE insertaddressfield(svalue)
   CALL echo(build("Just entered InsertAddressField...sValue = ",svalue))
   SET icnt3 = 0
   SET cur_row_pos += 1
   SET cur_row = temp->qual[ibsldr].line_nbr
   SET cur_col_pos = 1
   SET stat = alterlist(request->row_qual,cur_row_pos)
   SET stat = alterlist(request->row_qual[cur_row_pos].col_qual,cur_col_pos)
   FOR (icnt3 = ibsldr TO bsldrcnt)
     SET temp->qual[icnt3].line_nbr += 1
   ENDFOR
   SET request->row_qual[cur_row_pos].line_num = temp->qual[ibsldr].line_nbr
   SET temp->qual[ibsldr].literal_display = ""
   SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].position = temp->qual[ibsldr].column_pos
   SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].max_size = temp->qual[ibsldr].max_size
   SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_size = temp->qual[ibsldr].
   literal_size
   SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr].
   literal_display
   SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].value = trim(svalue)
   IF (textlen(trim(svalue))=0)
    SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = ""
   ELSE
    SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr].
    literal_display
   ENDIF
   IF (cur_col_pos > max_cols)
    SET max_cols = cur_col_pos
   ENDIF
 END ;Subroutine
 SUBROUTINE getpersonaddress(saction)
   CALL echo(build("Just entered GetPersonAddress...sAction = ",saction))
   CALL echo(build("Address_Ind, ",address_ind))
   SET stemp = fillstring(100," ")
   SET icnt4 = 0
   SET stemp = prsnl_info->qual[nprsnlitem].street_addr
   IF (address_ind=1)
    IF (textlen(trim(stemp)) > 0)
     SET rule_value = trim(stemp)
     CALL addtorequeststructure(0)
     FOR (icnt2 = ibsldr TO bsldrcnt)
       SET temp->qual[icnt2].line_nbr += 1
     ENDFOR
    ENDIF
   ELSE
    IF (textlen(trim(stemp)) > 0)
     SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].value = trim(stemp)
     SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = temp->qual[ibsldr].
     literal_display
    ELSE
     SET request->row_qual[cur_row_pos].col_qual[cur_col_pos].literal_display = ""
    ENDIF
   ENDIF
   SET stemp = prsnl_info->qual[nprsnlitem].street_addr2
   IF (textlen(trim(stemp)) > 0)
    IF (address_ind=1)
     SET rule_value = trim(stemp)
     SET rule->qual[cnt2].literal_display = ""
     CALL addtorequeststructure(0)
     FOR (icnt2 = ibsldr TO bsldrcnt)
       SET temp->qual[icnt2].line_nbr += 1
     ENDFOR
    ELSE
     CALL insertaddressfield(stemp)
    ENDIF
   ENDIF
   SET stemp = prsnl_info->qual[nprsnlitem].street_addr3
   IF (textlen(trim(stemp)) > 0)
    IF (address_ind=1)
     SET rule_value = trim(stemp)
     SET rule->qual[cnt2].literal_display = ""
     CALL addtorequeststructure(0)
     FOR (icnt2 = ibsldr TO bsldrcnt)
       SET temp->qual[icnt2].line_nbr += 1
     ENDFOR
    ELSE
     CALL insertaddressfield(stemp)
    ENDIF
   ENDIF
   SET stemp = prsnl_info->qual[nprsnlitem].street_addr4
   IF (textlen(trim(stemp)) > 0)
    IF (address_ind=1)
     SET rule_value = trim(stemp)
     SET rule->qual[cnt2].literal_display = ""
     CALL addtorequeststructure(0)
     FOR (icnt2 = ibsldr TO bsldrcnt)
       SET temp->qual[icnt2].line_nbr += 1
     ENDFOR
    ELSE
     CALL insertaddressfield(stemp)
    ENDIF
   ENDIF
   SET stemp = prsnl_info->qual[nprsnlitem].city
   IF (textlen(trim(stemp)))
    SET stemp = build(stemp,",_",prsnl_info->qual[nprsnlitem].state,"_",prsnl_info->qual[nprsnlitem].
     zipcode)
    SET stemp = replace(stemp,"_"," ",0)
   ENDIF
   IF (textlen(trim(stemp)) > 0)
    IF (address_ind=1)
     SET rule_value = trim(stemp)
     SET rule->qual[cnt2].literal_display = ""
     CALL addtorequeststructure(0)
     FOR (icnt2 = ibsldr TO bsldrcnt)
       SET temp->qual[icnt2].line_nbr += 1
     ENDFOR
    ELSE
     CALL insertaddressfield(stemp)
    ENDIF
   ENDIF
   SET return_string = stemp
 END ;Subroutine
 SUBROUTINE adjustspaces(idummy)
   CALL echo("Just entered AdjustSpaces...")
   SET scomment = fillstring(200," ")
   SET sholder = fillstring(200," ")
   SET sh1 = fillstring(200," ")
   SET sh2 = fillstring(200," ")
   SET iposition = 0
   SET icnt5 = 0
   SET ilen = 0
   SET scolumn_pos = 0
   SET scomment = prsnl_info->qual[nprsnlitem].comment
   SET scolumn_pos = temp->qual[ibsldr].column_pos
   IF (scolumn_pos > 0)
    FOR (icnt5 = 1 TO (scolumn_pos - 1))
      SET sholder = build(sholder,"_")
    ENDFOR
   ENDIF
   SET ilen = textlen(scomment)
   SET iposition = findstring(char(13),scomment)
   IF (ilen > 0
    AND iposition > 0)
    SET sh1 = substring(1,(iposition+ 1),scomment)
    SET sh2 = substring((iposition+ 2),ilen,scomment)
    SET scomment = build(sh1,sholder,sh2)
    SET scomment = replace(scomment,"_"," ",0)
   ENDIF
   CALL echo(build("Adjusting Spaces...",scomment))
   SET return_string = scomment
 END ;Subroutine
 SUBROUTINE getvaluedata(gvdmeaning,formatdesc)
   CALL echo(build("Just entered GetValueData...GVDmeaning = ",gvdmeaning))
   SET return_string = ""
   CASE (trim(gvdmeaning))
    OF "CNETITLETEXT":
     SET return_string = request->event_title_text
    OF "CNAUTHINIT":
     CALL findactionperson("SIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNAUTHNAME":
     CALL findactionperson("SIGN")
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,return_string,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->
       qual[nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNAUTHTITLE":
     CALL findactionperson("SIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNAUTHADD":
     SET address_ind = 0
     IF (binsert=1)
      CALL findactionperson("SIGN")
     ENDIF
     IF (nprsnlitem != 0)
      CALL getpersonaddress("SIGN")
     ENDIF
    OF "CNAUTHADDCOM":
     CALL findactionperson("SIGN")
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
     ENDIF
    OF "CNAUTHADDNAM":
     CALL findactionperson("SIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNAUTHORSN":
     SET brule = 1
     SET rule_type = "SIGN"
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,rule_value,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->qual[
       nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNAUTHORSI":
     SET brule = 1
     SET rule_type = "SIGN"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNAUTHORST":
     SET brule = 1
     SET rule_type = "SIGN"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNAUTHORSA":
     SET brule = 1
     SET rule_type = "SIGN"
     SET address_ind = 1
     IF (nprsnlitem != 0)
      SET rule_value = return_string
     ENDIF
    OF "CNAUTHORSC":
     SET brule = 1
     SET rule_type = "SIGN"
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
      SET rule_value = return_string
     ENDIF
    OF "CNAUTHORSD":
     SET brule = 1
     SET rule_type = "SIGN"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNSIGNDTN":
     SET brule = 1
     SET rule_type = "SIGN"
     IF (nprsnlitem != 0
      AND (prsnl_info->qual[nprsnlitem].action_status_mean=saction_status_completed))
      SET tempdate->date_now = request->action_prsnl_qual[ic].action_dt_tm
      SET tempdate->date_tz = request->action_prsnl_qual[ic].time_zone
      CALL formatdate(formatdesc,"mm/dd/yy;;d")
      SET rule_value = return_string
      CALL echo(build("CN Sign Date = ",rule_value))
     ENDIF
    OF "CNSIGNTMN":
     SET brule = 1
     SET rule_type = "SIGN"
     IF (nprsnlitem != 0
      AND (prsnl_info->qual[nprsnlitem].action_status_mean=saction_status_completed))
      SET tempdate->date_now = request->action_prsnl_qual[ic].action_dt_tm
      SET tempdate->date_tz = request->action_prsnl_qual[ic].time_zone
      CALL formatdate(formatdesc,"hh:mm;;d")
      SET rule_value = return_string
      CALL echo(build("CN Sign Time = ",rule_value))
     ENDIF
    OF "CNSIGNDT":
     CALL findactionperson("SIGN")
     IF ((prsnl_info->qual[nprsnlitem].action_status_mean=saction_status_completed))
      CALL findactiondate("SIGN",formatdesc,"mm/dd/yy;;d")
     ENDIF
    OF "CNSIGNTM":
     CALL findactionperson("SIGN")
     IF ((prsnl_info->qual[nprsnlitem].action_status_mean=saction_status_completed))
      CALL findactiondate("SIGN",formatdesc,"hh:mm;;d")
     ENDIF
    OF "CNSIGNCOM":
     CALL getrequestcomment("SIGN")
     SET return_string = request_comment
    OF "CNSIGN(N)COM":
     SET brule = 1
     SET rule_type = "SIGN"
     IF (nprsnlitem != 0)
      SET rule_value = request->action_prsnl_qual[ic].request_comment
      CALL echo(build("CN Sign(n) Comment = ",rule_value))
     ENDIF
    OF "CNSIGNSTATUS":
     CALL findactionstatus("SIGN")
     SET return_string = action_status
    OF "CNSIGNACCMT":
     CALL getactioncomment("SIGN")
     SET return_string = action_comment
    OF "CNSIGNACCMTN":
     SET brule = 1
     SET rule_type = "SIGN"
     IF (nprsnlitem != 0)
      SET rule_value = request->action_prsnl_qual[ic].action_comment
      CALL echo(build("CN Signature Action Comment = ",rule_value))
     ENDIF
    OF "CNDICTDT":
     CALL findactiondate("PERFORM",formatdesc,"mm/dd/yy;;d")
    OF "CNDICTTM":
     CALL findactiondate("PERFORM",formatdesc,"hh:mm;;d")
    OF "CNTRANSINIT":
     CALL findactionperson("TRANSCRIBE")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNTRANSNAME":
     CALL findactionperson("TRANSCRIBE")
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,return_string,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->
       qual[nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNTRANSTITL":
     CALL findactionperson("TRANSCRIBE")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNTRANSBA":
     SET address_ind = 0
     IF (binsert=1)
      CALL findactionperson("TRANSCRIBE")
     ENDIF
     IF (nprsnlitem != 0)
      CALL getpersonaddress("TRANSCRIBE")
     ENDIF
    OF "CNTRANSBC":
     CALL findactionperson("TRANSCRIBE")
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
     ENDIF
    OF "CNTRANSBN":
     CALL findactionperson("TRANSCRIBE")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNTRANSN":
     SET brule = 1
     SET rule_type = "TRANSCRIBE"
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,rule_value,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->qual[
       nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNTRANSI":
     SET brule = 1
     SET rule_type = "TRANSCRIBE"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNTRANST":
     SET brule = 1
     SET rule_type = "TRANSCRIBE"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNTRANSA":
     SET brule = 1
     SET rule_type = "TRANSCRIBE"
     SET address_ind = 1
     IF (nprsnlitem != 0)
      SET rule_value = return_string
     ENDIF
    OF "CNTRANSC":
     SET brule = 1
     SET rule_type = "TRANSCRIBE"
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
      SET rule_value = return_string
     ENDIF
    OF "CNTRANSD":
     SET brule = 1
     SET rule_type = "TRANSCRIBE"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNTRANSDT":
     CALL findactiondate("TRANSCRIBE",formatdesc,"mm/dd/yy;;d")
    OF "CNTRANSTM":
     CALL findactiondate("TRANSCRIBE",formatdesc,"hh:mm;;d")
    OF "CNTRANSDTN":
     SET brule = 1
     SET rule_type = "TRANSCRIBE"
     IF (nprsnlitem != 0)
      SET tempdate->date_now = request->action_prsnl_qual[ic].action_dt_tm
      SET tempdate->date_tz = request->action_prsnl_qual[ic].time_zone
      CALL formatdate(formatdesc,"mm/dd/yy;;d")
      SET rule_value = return_string
      CALL echo(build("CN Transcribed Date (n) = ",rule_value))
     ENDIF
    OF "CNTRANSTMN":
     SET brule = 1
     SET rule_type = "TRANSCRIBE"
     IF (nprsnlitem != 0)
      SET tempdate->date_now = request->action_prsnl_qual[ic].action_dt_tm
      SET tempdate->date_tz = request->action_prsnl_qual[ic].time_zone
      CALL formatdate(formatdesc,"hh:mm;;d")
      SET rule_value = return_string
      CALL echo(build("CN Transcribed Time (n) = ",rule_value))
     ENDIF
    OF "CNMODIFYINIT":
     CALL findactionperson("MODIFY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNMODIFYNAME":
     CALL findactionperson("MODIFY")
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,return_string,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->
       qual[nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNMODIFYTITL":
     CALL findactionperson("MODIFY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNMODIFYBA":
     SET address_ind = 0
     IF (binsert=1)
      CALL findactionperson("MODIFY")
     ENDIF
     IF (nprsnlitem != 0)
      CALL getpersonaddress("MODIFY")
     ENDIF
    OF "CNMODIFYBC":
     CALL findactionperson("MODIFY")
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
     ENDIF
    OF "CNMODIFYBN":
     CALL findactionperson("MODIFY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNMODIFYN":
     SET brule = 1
     SET rule_type = "MODIFY"
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,rule_value,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->qual[
       nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNMODIFYI":
     SET brule = 1
     SET rule_type = "MODIFY"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNMODIFYT":
     SET brule = 1
     SET rule_type = "MODIFY"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNMODIFYA":
     SET brule = 1
     SET rule_type = "MODIFY"
     SET address_ind = 1
     IF (nprsnlitem != 0)
      SET rule_value = return_string
     ENDIF
    OF "CNMODIFYC":
     SET brule = 1
     SET rule_type = "MODIFY"
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
      SET rule_value = return_string
     ENDIF
    OF "CNMODIFYD":
     SET brule = 1
     SET rule_type = "MODIFY"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNMODIFYDT":
     CALL findactiondate("MODIFY",formatdesc,"mm/dd/yy;;d")
    OF "CNMODIFYTM":
     CALL findactiondate("MODIFY",formatdesc,"hh:mm;;d")
    OF "CNMODIFYDTN":
     SET brule = 1
     SET rule_type = "MODIFY"
     IF (nprsnlitem != 0)
      SET tempdate->date_now = request->action_prsnl_qual[ic].action_dt_tm
      SET tempdate->date_tz = request->action_prsnl_qual[ic].time_zone
      CALL formatdate(formatdesc,"mm/dd/yy;;d")
      SET rule_value = return_string
      CALL echo(build("CN Modify Date (n) = ",rule_value))
     ENDIF
    OF "CNMODIFYTMN":
     SET brule = 1
     SET rule_type = "MODIFY"
     IF (nprsnlitem != 0)
      SET tempdate->date_now = request->action_prsnl_qual[ic].action_dt_tm
      SET tempdate->date_tz = request->action_prsnl_qual[ic].time_zone
      CALL formatdate(formatdesc,"hh:mm;;d")
      SET rule_value = return_string
      CALL echo(build("CN MODIFY Time = ",rule_value))
     ENDIF
    OF "CNCOSIGNINIT":
     CALL findactionperson("COSIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNCOSIGNNAME":
     CALL findactionperson("COSIGN")
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,return_string,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->
       qual[nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNCOSIGNTITL":
     CALL findactionperson("COSIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNCOSIGNADD":
     SET address_ind = 0
     IF (binsert=1)
      CALL findactionperson("COSIGN")
     ENDIF
     IF (nprsnlitem != 0)
      CALL getpersonaddress("COSIGN")
     ENDIF
    OF "CNCOSIGNCOM":
     CALL findactionperson("COSIGN")
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
     ENDIF
    OF "CNCOSIGNNAM":
     CALL findactionperson("COSIGN")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNCOSIGNSN":
     SET brule = 1
     SET rule_type = "COSIGN"
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,rule_value,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->qual[
       nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNCOSIGNSI":
     SET brule = 1
     SET rule_type = "COSIGN"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNCOSIGNST":
     SET brule = 1
     SET rule_type = "COSIGN"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNCOSIGNSA":
     SET brule = 1
     SET rule_type = "COSIGN"
     SET address_ind = 1
     IF (nprsnlitem != 0)
      SET rule_value = return_string
     ENDIF
    OF "CNCOSIGNSC":
     SET brule = 1
     SET rule_type = "COSIGN"
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
      SET rule_value = return_string
     ENDIF
    OF "CNCOSIGNSD":
     SET brule = 1
     SET rule_type = "COSIGN"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNCOSIGNDT":
     CALL findactiondate("COSIGN",formatdesc,"mm/dd/yy;;d")
    OF "CNCOSIGNTIM":
     CALL findactiondate("COSIGN",formatdesc,"hh:mm;;d")
    OF "CNCOSIGNDTN":
     SET brule = 1
     SET rule_type = "COSIGN"
     IF (nprsnlitem != 0)
      SET tempdate->date_now = request->action_prsnl_qual[ic].action_dt_tm
      SET tempdate->date_tz = request->action_prsnl_qual[ic].time_zone
      CALL formatdate(formatdesc,"mm/dd/yy;;d")
      SET rule_value = return_string
      CALL echo(build("CN CoSign Date (n) = ",rule_value))
     ENDIF
    OF "CNCOSIGNTIMN":
     SET brule = 1
     SET rule_type = "COSIGN"
     IF (nprsnlitem != 0)
      SET tempdate->date_now = request->action_prsnl_qual[ic].action_dt_tm
      SET tempdate->date_tz = request->action_prsnl_qual[ic].time_zone
      CALL formatdate(formatdesc,"hh:mm;;d")
      SET rule_value = return_string
      CALL echo(build("CN CoSign Time (n) = ",rule_value))
     ENDIF
    OF "CNCOSIGNACT":
     CALL getactioncomment("COSIGN")
     SET return_string = action_comment
    OF "CNCOSIGNACTN":
     SET brule = 1
     SET rule_type = "COSIGN"
     IF (nprsnlitem != 0)
      SET rule_value = request->action_prsnl_qual[ic].action_comment
      CALL echo(build("CN CoSignature Action Comment = ",rule_value))
     ENDIF
    OF "CNCOSIGNCMT":
     CALL getrequestcomment("COSIGN")
     SET return_string = request_comment
    OF "CNCOSIGNCMTN":
     SET brule = 1
     SET rule_type = "COSIGN"
     IF (nprsnlitem != 0)
      SET rule_value = request->action_prsnl_qual[ic].request_comment
      CALL echo(build("CN CoSignature Request Comment = ",rule_value))
     ENDIF
    OF "CNAUTHPNAME":
     CALL findactionperson("PROXY")
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,return_string,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->
       qual[nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNPROXYINIT":
     CALL findactionperson("PROXY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNPROXYNAME":
     CALL findactionperson("PROXY")
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,return_string,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->
       qual[nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNPROXYTITLE":
     CALL findactionperson("PROXY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNPROXYBA":
     SET address_ind = 0
     IF (binsert=1)
      CALL findactionperson("PROXY")
     ENDIF
     IF (nprsnlitem != 0)
      CALL getpersonaddress("PROXY")
     ENDIF
    OF "CNPROXYBC":
     CALL findactionperson("PROXY")
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
     ENDIF
    OF "CNPROXYBN":
     CALL findactionperson("PROXY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNPROXYN":
     SET brule = 1
     SET rule_type = "PROXY"
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,rule_value,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->qual[
       nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNPROXYI":
     SET brule = 1
     SET rule_type = "PROXY"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNPROXYT":
     SET brule = 1
     SET rule_type = "PROXY"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNPROXYA":
     SET brule = 1
     SET rule_type = "PROXY"
     SET address_ind = 1
     IF (nprsnlitem != 0)
      SET rule_value = return_string
     ENDIF
    OF "CNPROXYC":
     SET brule = 1
     SET rule_type = "PROXY"
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
      SET rule_value = return_string
     ENDIF
    OF "CNPROXYD":
     SET brule = 1
     SET rule_type = "PROXY"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNREVIEWINIT":
     CALL findactionperson("REVIEW")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNREVIEWNAME":
     CALL findactionperson("REVIEW")
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,return_string,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->
       qual[nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNREVIEWTITL":
     CALL findactionperson("REVIEW")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNREVIEWBA":
     SET address_ind = 0
     IF (binsert=1)
      CALL findactionperson("REVIEW")
     ENDIF
     IF (nprsnlitem != 0)
      CALL getpersonaddress("REVIEW")
     ENDIF
    OF "CNREVIEWBC":
     CALL findactionperson("REVIEW")
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
     ENDIF
    OF "CNREVIEWBN":
     CALL findactionperson("REVIEW")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNREVIEWERSN":
     SET brule = 1
     SET rule_type = "REVIEW"
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,rule_value,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->qual[
       nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNREVIEWERSI":
     SET brule = 1
     SET rule_type = "REVIEW"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNREVIEWERST":
     SET brule = 1
     SET rule_type = "REVIEW"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNREVIEWERSA":
     SET brule = 1
     SET rule_type = "REVIEW"
     SET address_ind = 1
     IF (nprsnlitem != 0)
      SET rule_value = return_string
     ENDIF
    OF "CNREVIEWERSC":
     SET brule = 1
     SET rule_type = "REVIEW"
     IF (nprsnlitem != 0)
      CALL adjustspaces(0)
      SET rule_value = return_string
     ENDIF
    OF "CNREVIEWERSD":
     SET brule = 1
     SET rule_type = "REVIEW"
     IF (nprsnlitem != 0)
      SET rule_value = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNREVIEWCOM":
     CALL getrequestcomment("REVIEW")
     SET return_string = request_comment
    OF "CNREVIEW(N)C":
     SET brule = 1
     SET rule_type = "REVIEW"
     IF (nprsnlitem != 0)
      SET rule_value = request->action_prsnl_qual[ic].request_comment
      CALL echo(build("CN Sign(n) Comment = ",rule_value))
     ENDIF
    OF "CNREVIEWACT":
     CALL getactioncomment("REVIEW")
     SET return_string = action_comment
    OF "CNREVIEWACTN":
     SET brule = 1
     SET rule_type = "REVIEW"
     IF (nprsnlitem != 0)
      SET rule_value = request->action_prsnl_qual[ic].action_comment
      CALL echo(build("CN Review Action Comment = ",rule_value))
     ENDIF
    OF "CNVERIINIT":
     CALL findactionperson("VERIFY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].initials
     ENDIF
    OF "CNVERINAME":
     CALL findactionperson("VERIFY")
     IF (nprsnlitem != 0)
      CALL formatname(formatdesc,return_string,prsnl_info->qual[nprsnlitem].name_first,prsnl_info->
       qual[nprsnlitem].name_middle,prsnl_info->qual[nprsnlitem].name_last,
       prsnl_info->qual[nprsnlitem].name_full)
     ENDIF
    OF "CNVERITITLE":
     CALL findactionperson("VERIFY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].name_title
     ENDIF
    OF "CNVERIBUSADD":
     SET address_ind = 0
     IF (binsert=1)
      CALL findactionperson("VERIFY")
     ENDIF
     IF (nprsnlitem != 0)
      CALL getpersonaddress("VERIFY")
     ENDIF
    OF "CNVERICONNAM":
     CALL findactionperson("VERIFY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNVERICONADD":
     CALL findactionperson("VERIFY")
     IF (nprsnlitem != 0)
      SET return_string = prsnl_info->qual[nprsnlitem].contactname
     ENDIF
    OF "CNVERIDATE":
     CALL findactiondate("VERIFY",formatdesc,"mm/dd/yy;;d")
    OF "CNVERITIME":
     CALL findactiondate("VERIFY",formatdesc,"hh:mm;;d")
    OF "CNVERICMT":
     CALL getactioncomment("VERIFY")
     SET return_string = action_comment
    ELSE
     SET return_string = "?????"
   ENDCASE
 END ;Subroutine
END GO

CREATE PROGRAM ce_get_person_names:dba
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
 DECLARE name_type_current = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(213,"CURRENT",1,name_type_current)
 DECLARE name_type_prsnl = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(213,"PRSNL",1,name_type_prsnl)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE person_cnt = i4 WITH constant(size(request->person_id_list,5))
 DECLARE prsnl_cnt = i4 WITH constant(size(request->prsnl_id_list,5))
 DECLARE total_cnt = i4 WITH constant((person_cnt+ prsnl_cnt))
 DECLARE idx1 = i4
 DECLARE idx2 = i4
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE getpatientdisplayname(null) = i2
 FREE RECORD person
 RECORD person(
   1 qual[*]
     2 person_id = f8
     2 names[*]
       3 full_name = vc
       3 begin_dt_tm = dq8
       3 end_dt_tm = dq8
 )
 IF (person_cnt > 0)
  SET stat = alterlist(person->qual,person_cnt)
  FOR (idx1 = 1 TO person_cnt)
    SET person->qual[idx1].person_id = request->person_id_list[idx1].person_id
  ENDFOR
  SET stat = getpatientdisplayname(null)
  IF (stat=2)
   SET reply->qual = 0
   GO TO exit_script
  ENDIF
 ENDIF
 IF (prsnl_cnt > 0)
  SET stat = alterlist(persons->qual,prsnl_cnt)
  FOR (idx1 = 1 TO prsnl_cnt)
    SET persons->qual[idx1].person_id = request->prsnl_id_list[idx1].prsnl_id
    SET persons->qual[idx1].type_cd = name_type_prsnl
    SET persons->qual[idx1].trans_dt_tm = request->prsnl_id_list[idx1].name_return_dt_tm
  ENDFOR
  SET stat = getdisplaycomponents(0)
  IF (stat=2)
   SET reply->qual = 0
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->person_list,total_cnt)
 SET reply->qual = total_cnt
 FOR (idx1 = 1 TO person_cnt)
   SET reply->person_list[idx1].person_id = person->qual[idx1].person_id
   SET person_name_cnt = size(person->qual[idx1].names,5)
   IF (person_name_cnt > 0)
    SET reply->person_list[idx1].name_full_formatted = person->qual[idx1].names[1].full_name
   ENDIF
 ENDFOR
 FOR (idx2 = 1 TO prsnl_cnt)
   SET reply->person_list[idx1].person_id = persons->qual[idx2].person_id
   SET prsnl_name_cnt = size(persons->qual[idx2].names,5)
   IF (prsnl_name_cnt > 0)
    SET reply->person_list[idx1].prsnl_name_full_formatted = persons->qual[idx2].names[1].full_name
   ENDIF
   SET idx1 += 1
 ENDFOR
 GO TO exit_script
 SUBROUTINE getpatientdisplayname(null)
   DECLARE idx = i4
   DECLARE interval = q8
   DECLARE name_idx = i4
   DECLARE prev_beg_date = q8
   DECLARE errmsg = vc WITH public, noconstant(" ")
   DECLARE error_check = i4 WITH public, noconstant(0)
   DECLARE returnval = i4 WITH public, noconstant(0)
   DECLARE current_date = dq8 WITH constant(cnvtdatetime(sysdate))
   SET error_check = error(errmsg,1)
   FREE RECORD counters
   RECORD counters(
     1 qual[*]
       2 count = i2
   )
   SET foo = alterlist(counters->qual,person_cnt)
   SET interval = (cnvtdatetime("01-Jan-2006 00:00:30.00") - cnvtdatetime("01-Jan-2006 00:00:00.00"))
   SET prev_beg_date = cnvtdatetime(ppr_null_date)
   FOR (idx = 1 TO person_cnt)
     IF ((person->qual[idx].person_id=0))
      RETURN(1)
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    p.person_id, pn.person_name_id
    FROM person_name pn,
     person p,
     (dummyt d1  WITH seq = value(person_cnt))
    PLAN (d1)
     JOIN (p
     WHERE (p.person_id=person->qual[d1.seq].person_id))
     JOIN (pn
     WHERE pn.person_id=p.person_id
      AND pn.name_type_cd=name_type_current
      AND pn.active_ind=1)
    ORDER BY pn.beg_effective_dt_tm DESC
    HEAD d1.seq
     prev_beg_date = cnvtdatetime(ppr_null_date)
    DETAIL
     name_idx = counters->qual[d1.seq].count
     IF (mod(name_idx,10)=0)
      stat = alterlist(person->qual[d1.seq].names,(name_idx+ 10))
     ENDIF
     name_idx += 1
     IF (pn.person_name_id != 0)
      IF ((((prev_beg_date < (cnvtdatetime(pn.beg_effective_dt_tm) - interval))) OR ((prev_beg_date
       >= (cnvtdatetime(pn.beg_effective_dt_tm)+ interval)))) )
       person->qual[d1.seq].names[name_idx].full_name = pn.name_full, person->qual[d1.seq].names[
       name_idx].begin_dt_tm = cnvtdatetime(pn.beg_effective_dt_tm), person->qual[d1.seq].names[
       name_idx].end_dt_tm = cnvtdatetime(pn.end_effective_dt_tm),
       prev_beg_date = cnvtdatetime(pn.beg_effective_dt_tm), counters->qual[d1.seq].count = name_idx
      ENDIF
     ELSE
      person->qual[d1.seq].names[name_idx].full_name = p.name_full_formatted, person->qual[d1.seq].
      names[name_idx].begin_dt_tm = cnvtdatetime(p.beg_effective_dt_tm), person->qual[d1.seq].names[
      name_idx].end_dt_tm = cnvtdatetime(p.end_effective_dt_tm),
      prev_beg_date = cnvtdatetime(p.beg_effective_dt_tm), counters->qual[d1.seq].count = name_idx
     ENDIF
    FOOT  d1.seq
     row + 0
    WITH nocounter
   ;end select
   FOR (idx = 1 TO person_cnt)
     SET stat = alterlist(person->qual[idx].names,counters->qual[idx].count)
   ENDFOR
   FOR (idx = 1 TO person_cnt)
     IF ((counters->qual[idx].count > 0))
      FOR (name_idx = 1 TO counters->qual[idx].count)
        IF ((current_date > person->qual[idx].names[name_idx].begin_dt_tm)
         AND (current_date <= person->qual[idx].names[name_idx].end_dt_tm))
         SET person->qual[idx].names[1].full_name = person->qual[idx].names[name_idx].full_name
         SET person->qual[idx].names[1].begin_dt_tm = person->qual[idx].names[name_idx].begin_dt_tm
         SET person->qual[idx].names[1].end_dt_tm = person->qual[idx].names[name_idx].end_dt_tm
         SET name_idx = (counters->qual[idx].count+ 10)
        ENDIF
      ENDFOR
      IF (((name_idx - 1) <= counters->qual[idx].count))
       SET person->qual[idx].names[1].full_name = person->qual[idx].names[counters->qual[idx].count].
       full_name
       SET person->qual[idx].names[1].begin_dt_tm = person->qual[idx].names[counters->qual[idx].count
       ].begin_dt_tm
       SET person->qual[idx].names[1].end_dt_tm = person->qual[idx].names[counters->qual[idx].count].
       end_dt_tm
      ENDIF
      SET stat = alterlist(person->qual[idx].names,1)
     ENDIF
   ENDFOR
   IF (error(errmsg,0) != 0)
    SET returnval = 2
   ENDIF
   FREE RECORD counters
   RETURN(returnval)
 END ;Subroutine
#exit_script
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO

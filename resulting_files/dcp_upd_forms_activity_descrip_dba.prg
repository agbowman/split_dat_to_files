CREATE PROGRAM dcp_upd_forms_activity_descrip:dba
 EXECUTE gm_dm_info2388_def "I"
 DECLARE gm_i_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_dm_info2388_f8(icol_name,ival,iqual,null_ind)
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
 SUBROUTINE gm_i_dm_info2388_dq8(icol_name,ival,iqual,null_ind)
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
 SUBROUTINE gm_i_dm_info2388_vc(icol_name,ival,iqual,null_ind)
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
 EXECUTE gm_dm_info2388_def "U"
 DECLARE gm_u_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_dm_info2388_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_dm_info2388_f8(icol_name,ival,iqual,null_ind,wq_ind)
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
 SUBROUTINE gm_u_dm_info2388_i4(icol_name,ival,iqual,null_ind,wq_ind)
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
 SUBROUTINE gm_u_dm_info2388_dq8(icol_name,ival,iqual,null_ind,wq_ind)
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
 SUBROUTINE gm_u_dm_info2388_vc(icol_name,ival,iqual,null_ind,wq_ind)
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
 RECORD pairing(
   1 pair[*]
     2 dcp_forms_ref_id = f8
     2 description = vc
 )
 DECLARE forms_ref_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE last_id_upd = f8 WITH noconstant(0.0)
 SET dm_exist = "F"
 SELECT INTO "nl:"
  FROM dm_info dmi
  WHERE dmi.info_domain="PVREADME1103"
   AND dmi.info_name="dcp_upd_forms_activity_descrip"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET dm_exist = "T"
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa
  ORDER BY dfa.dcp_forms_ref_id
  HEAD dfa.dcp_forms_ref_id
   forms_ref_cnt = (forms_ref_cnt+ 1)
   IF (mod(forms_ref_cnt,100)=1)
    stat = alterlist(pairing->pair,(forms_ref_cnt+ 99))
   ENDIF
   pairing->pair[forms_ref_cnt].dcp_forms_ref_id = dfa.dcp_forms_ref_id
  FOOT REPORT
   stat = alterlist(pairing->pair,forms_ref_cnt)
  WITH nocounter
 ;end select
 SET readme_data->message = build("PVReadMe 1103:# Rows needing update: ",forms_ref_cnt)
 EXECUTE dm_readme_status
 COMMIT
 FOR (pairing_index = 1 TO forms_ref_cnt)
   SELECT INTO "nl:"
    FROM dcp_forms_ref dfr
    WHERE (dfr.dcp_forms_ref_id=pairing->pair[pairing_index].dcp_forms_ref_id)
    DETAIL
     pairing->pair[pairing_index].description = dfr.description
    WITH nocounter
   ;end select
 ENDFOR
 SET upd_cnt = 0
 FOR (pairing_index = 1 TO forms_ref_cnt)
   SET upd_cnt = (upd_cnt+ 1)
   UPDATE  FROM dcp_forms_activity dfa
    SET dfa.description = pairing->pair[pairing_index].description
    WHERE (dfa.dcp_forms_ref_id=pairing->pair[pairing_index].dcp_forms_ref_id)
    WITH check
   ;end update
   IF (((upd_cnt=10000) OR (pairing_index=forms_ref_cnt)) )
    COMMIT
    SET readme_data->message = build("PVReadMe 1103:",pairing_index,"of ",forms_ref_cnt,
     " rows updated with commit")
    EXECUTE dm_readme_status
    COMMIT
    SET upd_cnt = 0
   ENDIF
   IF (pairing_index=forms_ref_cnt)
    SET last_id_upd = pairing->pair[pairing_index].dcp_forms_ref_id
   ENDIF
 ENDFOR
 CALL echo(build("LAST UPD ID IS: ",last_id_upd))
 IF (last_id_upd > 0)
  IF (dm_exist="T")
   SET gm_u_dm_info2388_req->force_updt_ind = 1
   SET gm_u_dm_info2388_req->info_domainw = 1
   SET gm_u_dm_info2388_req->info_numberf = 1
   SET stat = alterlist(gm_u_dm_info2388_req->qual,1)
   SET gm_u_dm_info2388_req->qual[1].info_domain = "PVREADME1103"
   SET gm_u_dm_info2388_req->qual[1].info_number = last_id_upd
   EXECUTE gm_u_dm_info2388  WITH replace("REQUEST",gm_u_dm_info2388_req), replace("REPLY",
    gm_u_dm_info2388_rep)
  ELSE
   SET gm_i_dm_info2388_req->allow_partial_ind = 0
   SET gm_i_dm_info2388_req->info_domaini = 1
   SET gm_i_dm_info2388_req->info_namei = 1
   SET gm_i_dm_info2388_req->info_numberi = 1
   SET stat = alterlist(gm_i_dm_info2388_req->qual,1)
   SET gm_i_dm_info2388_req->qual[1].info_domain = "PVREADME1103"
   SET gm_i_dm_info2388_req->qual[1].info_name = "dcp_upd_forms_activity_descrip"
   SET gm_i_dm_info2388_req->qual[1].info_number = last_id_upd
   EXECUTE gm_i_dm_info2388  WITH replace("REQUEST",gm_i_dm_info2388_req), replace("REPLY",
    gm_i_dm_info2388_rep)
  ENDIF
 ENDIF
 FREE RECORD gm_i_dm_info2388_req
 FREE RECORD gm_i_dm_info2388_rep
 FREE RECORD gm_u_dm_info2388_req
 FREE RECORD gm_u_dm_info2388_rep
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
 COMMIT
END GO

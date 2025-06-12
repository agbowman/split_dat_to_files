CREATE PROGRAM dcp_apache_dm_info:dba
 PROMPT
  "Insert Path For APACHE Data Dump for Business Objects:" = "",
  "Activity Extract From Date And Time Is:" = "CURDATE",
  "Output to File/Printer/MINE" = ""
  WITH dumppath, dumpdate, outdev
 SET founddatepath = 0
 SET update_count = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="APACHE"
   AND di.info_name="APACHE RA DUMP DATE-PATH"
  DETAIL
   founddatepath = 1, update_count = di.updt_cnt
  WITH nocounter
 ;end select
 IF (founddatepath=0)
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
  SET gm_i_dm_info2388_req->allow_partial_ind = 0
  SET gm_i_dm_info2388_req->info_domaini = 1
  SET gm_i_dm_info2388_req->info_namei = 1
  SET gm_i_dm_info2388_req->info_datei = 1
  SET gm_i_dm_info2388_req->info_chari = 1
  SET gm_i_dm_info2388_req->info_numberi = 0
  SET gm_i_dm_info2388_req->info_long_idi = 0
  SET gm_i_dm_info2388_req->info_daten = 0
  SET gm_i_dm_info2388_req->info_charn = 0
  SET gm_i_dm_info2388_req->info_numbern = 1
  SET stat = alterlist(gm_i_dm_info2388_req->qual,1)
  SET gm_i_dm_info2388_req->qual[1].info_domain = "APACHE"
  SET gm_i_dm_info2388_req->qual[1].info_name = "APACHE RA DUMP DATE-PATH"
  SET gm_i_dm_info2388_req->qual[1].info_date = cnvtdatetime( $DUMPDATE)
  SET gm_i_dm_info2388_req->qual[1].info_char = value( $DUMPPATH)
  EXECUTE gm_i_dm_info2388  WITH replace(request,gm_i_dm_info2388_req), replace(reply,
   gm_i_dm_info2388_rep)
  IF ((gm_i_dm_info2388_rep->qual[1].status=1))
   SET reqinfo->commit_ind = 1
   COMMIT
  ELSE
   SET reqinfo->commit_ind = 0
  ENDIF
  FREE RECORD gm_i_dm_info2388_req
  FREE RECORD gm_i_dm_info2388_rep
 ELSE
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
  SET gm_u_dm_info2388_req->allow_partial_ind = 1
  SET gm_u_dm_info2388_req->force_updt_ind = 1
  SET gm_u_dm_info2388_req->info_domainw = 1
  SET gm_u_dm_info2388_req->info_namew = 1
  SET gm_u_dm_info2388_req->info_datew = 0
  SET gm_u_dm_info2388_req->info_charw = 0
  SET gm_u_dm_info2388_req->info_numberw = 0
  SET gm_u_dm_info2388_req->info_long_idw = 0
  SET gm_u_dm_info2388_req->updt_applctxw = 0
  SET gm_u_dm_info2388_req->updt_dt_tmw = 0
  SET gm_u_dm_info2388_req->updt_cntw = 0
  SET gm_u_dm_info2388_req->updt_idw = 0
  SET gm_u_dm_info2388_req->updt_taskw = 0
  SET gm_u_dm_info2388_req->info_domainf = 0
  SET gm_u_dm_info2388_req->info_namef = 0
  SET gm_u_dm_info2388_req->info_datef = 1
  SET gm_u_dm_info2388_req->info_charf = 1
  SET gm_u_dm_info2388_req->info_numberf = 0
  SET gm_u_dm_info2388_req->info_long_idf = 0
  SET gm_u_dm_info2388_req->updt_cntf = 0
  SET stat = alterlist(gm_u_dm_info2388_req->qual,1)
  SET gm_u_dm_info2388_req->qual[1].info_domain = "APACHE"
  SET gm_u_dm_info2388_req->qual[1].info_name = "APACHE RA DUMP DATE-PATH"
  SET gm_u_dm_info2388_req->qual[1].info_date = cnvtdatetime( $DUMPDATE)
  IF (trim(value( $DUMPPATH))="")
   SET gm_u_dm_info2388_req->info_charf = 0
  ELSE
   SET gm_u_dm_info2388_req->qual[1].info_char = value( $DUMPPATH)
  ENDIF
  EXECUTE gm_u_dm_info2388  WITH replace(request,gm_u_dm_info2388_req), replace(reply,
   gm_u_dm_info2388_rep)
  IF ((gm_u_dm_info2388_rep->qual[1].status=1))
   SET reqinfo->commit_ind = 1
   COMMIT
  ELSE
   SET reqinfo->commit_ind = 0
  ENDIF
  FREE RECORD gm_u_dm_info2388_req
  FREE RECORD gm_u_dm_info2388_rep
 ENDIF
 SELECT INTO  $OUTDEV
  di.info_domain, di.info_name, di.info_date";;Q",
  di.info_char
  FROM dm_info di
  WHERE di.info_domain="APACHE"
   AND di.info_name="APACHE RA DUMP DATE-PATH"
  WITH nocounter, format, separator = " "
 ;end select
END GO

CREATE PROGRAM dcp_add_code_value_group:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE temp_fdcatcd = f8 WITH noconstant(0.0)
 DECLARE found = c1 WITH noconstant("F")
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE codevalue = f8 WITH noconstant(0.0)
 DECLARE qual_cnt = i4 WITH noconstant(0)
 SET qual_cnt = size(request->qual,5)
 DECLARE fdcatcd = f8 WITH noconstant(0.0)
 DECLARE cdfmeaning = c12 WITH public, noconstant(fillstring(12," "))
 SET cdfmeaning = request->cdf_meaning
 DECLARE atc = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dsc = f8 WITH constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE trim(cnvtupper(cv.display))=trim(cnvtupper(request->display))
   AND cv.code_set=25451
  DETAIL
   CALL echo(build("cv =",cnvtupper(cv.display))), fdcatcd = cv.code_value, found = "T"
  WITH nocounter
 ;end select
 IF (found="T")
  EXECUTE gm_code_value0619_def "U"
  DECLARE gm_u_code_value0619_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_code_value0619_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_code_value0619_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_code_value0619_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_code_value0619_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  SUBROUTINE gm_u_code_value0619_f8(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_code_value0619_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "code_value":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_code_value0619_req->code_valuef = 1
      SET gm_u_code_value0619_req->qual[iqual].code_value = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->code_valuew = 1
      ENDIF
     OF "active_type_cd":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_code_value0619_req->active_type_cdf = 1
      SET gm_u_code_value0619_req->qual[iqual].active_type_cd = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->active_type_cdw = 1
      ENDIF
     OF "data_status_cd":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_code_value0619_req->data_status_cdf = 1
      SET gm_u_code_value0619_req->qual[iqual].data_status_cd = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->data_status_cdw = 1
      ENDIF
     OF "data_status_prsnl_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_code_value0619_req->data_status_prsnl_idf = 1
      SET gm_u_code_value0619_req->qual[iqual].data_status_prsnl_id = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->data_status_prsnl_idw = 1
      ENDIF
     OF "active_status_prsnl_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_code_value0619_req->active_status_prsnl_idf = 1
      SET gm_u_code_value0619_req->qual[iqual].active_status_prsnl_id = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->active_status_prsnl_idw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_code_value0619_i2(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_code_value0619_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "active_ind":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->active_indf = 2
      ELSE
       SET gm_u_code_value0619_req->active_indf = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].active_ind = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->active_indw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_code_value0619_i4(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_code_value0619_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "code_set":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_code_value0619_req->code_setf = 1
      SET gm_u_code_value0619_req->qual[iqual].code_set = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->code_setw = 1
      ENDIF
     OF "collation_seq":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->collation_seqf = 2
      ELSE
       SET gm_u_code_value0619_req->collation_seqf = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].collation_seq = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->collation_seqw = 1
      ENDIF
     OF "updt_cnt":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_code_value0619_req->updt_cntf = 1
      SET gm_u_code_value0619_req->qual[iqual].updt_cnt = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->updt_cntw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_code_value0619_dq8(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_code_value0619_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "active_dt_tm":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->active_dt_tmf = 2
      ELSE
       SET gm_u_code_value0619_req->active_dt_tmf = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].active_dt_tm = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->active_dt_tmw = 1
      ENDIF
     OF "inactive_dt_tm":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->inactive_dt_tmf = 2
      ELSE
       SET gm_u_code_value0619_req->inactive_dt_tmf = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].inactive_dt_tm = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->inactive_dt_tmw = 1
      ENDIF
     OF "updt_dt_tm":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_code_value0619_req->updt_dt_tmf = 1
      SET gm_u_code_value0619_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->updt_dt_tmw = 1
      ENDIF
     OF "begin_effective_dt_tm":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->begin_effective_dt_tmf = 2
      ELSE
       SET gm_u_code_value0619_req->begin_effective_dt_tmf = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].begin_effective_dt_tm = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->begin_effective_dt_tmw = 1
      ENDIF
     OF "end_effective_dt_tm":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_code_value0619_req->end_effective_dt_tmf = 1
      SET gm_u_code_value0619_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->end_effective_dt_tmw = 1
      ENDIF
     OF "data_status_dt_tm":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->data_status_dt_tmf = 2
      ELSE
       SET gm_u_code_value0619_req->data_status_dt_tmf = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].data_status_dt_tm = cnvtdatetime(ival)
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->data_status_dt_tmw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_code_value0619_vc(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_code_value0619_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "cdf_meaning":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->cdf_meaningf = 2
      ELSE
       SET gm_u_code_value0619_req->cdf_meaningf = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].cdf_meaning = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->cdf_meaningw = 1
      ENDIF
     OF "display":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->displayf = 2
      ELSE
       SET gm_u_code_value0619_req->displayf = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].display = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->displayw = 1
      ENDIF
     OF "display_key":
      SET gm_u_code_value0619_req->qual[iqual].display_key = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->display_keyw = 1
      ENDIF
     OF "description":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->descriptionf = 2
      ELSE
       SET gm_u_code_value0619_req->descriptionf = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].description = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->descriptionw = 1
      ENDIF
     OF "definition":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->definitionf = 2
      ELSE
       SET gm_u_code_value0619_req->definitionf = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].definition = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->definitionw = 1
      ENDIF
     OF "cki":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_code_value0619_req->ckif = 1
      SET gm_u_code_value0619_req->qual[iqual].cki = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->ckiw = 1
      ENDIF
     OF "concept_cki":
      IF (null_ind=1)
       SET gm_u_code_value0619_req->concept_ckif = 2
      ELSE
       SET gm_u_code_value0619_req->concept_ckif = 1
      ENDIF
      SET gm_u_code_value0619_req->qual[iqual].concept_cki = ival
      IF (wq_ind=1)
       SET gm_u_code_value0619_req->concept_ckiw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SET stat = alterlist(gm_u_code_value0619_req->qual,1)
  SET gm_u_code_value0619_req->code_valuew = 1
  SET gm_u_code_value0619_req->force_updt_ind = 1
  SET gm_u_code_value0619_req->active_indf = 1
  SET gm_u_code_value0619_req->collation_seqf = 1
  SET gm_u_code_value0619_req->data_status_cdf = 1
  SET gm_u_code_value0619_req->qual[1].code_value = fdcatcd
  SET gm_u_code_value0619_req->qual[1].active_ind = 1
  SET gm_u_code_value0619_req->qual[1].collation_seq = request->collation_seq
  SET gm_u_code_value0619_req->qual[1].data_status_cd = dsc
  EXECUTE gm_u_code_value0619  WITH replace("REQUEST",gm_u_code_value0619_req), replace("REPLY",
   gm_u_code_value0619_rep)
  GO TO insert_cvg
 ENDIF
 EXECUTE gm_code_value0619_def "I"
 DECLARE gm_i_code_value0619_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_code_value0619_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_code_value0619_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_code_value0619_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_code_value0619_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_code_value0619_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].active_type_cd = ival
     SET gm_i_code_value0619_req->active_type_cdi = 1
    OF "data_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].data_status_cd = ival
     SET gm_i_code_value0619_req->data_status_cdi = 1
    OF "data_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].data_status_prsnl_id = ival
     SET gm_i_code_value0619_req->data_status_prsnl_idi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_code_value0619_req->active_status_prsnl_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_code_value0619_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_code_value0619_req->qual[iqual].active_ind = ival
     SET gm_i_code_value0619_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_code_value0619_i4(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "code_set":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].code_set = ival
     SET gm_i_code_value0619_req->code_seti = 1
    OF "collation_seq":
     SET gm_i_code_value0619_req->qual[iqual].collation_seq = ival
     SET gm_i_code_value0619_req->collation_seqi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_code_value0619_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].active_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->active_dt_tmi = 1
    OF "inactive_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].inactive_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->inactive_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->updt_dt_tmi = 1
    OF "begin_effective_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].begin_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->begin_effective_dt_tmi = 1
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->end_effective_dt_tmi = 1
    OF "data_status_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].data_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->data_status_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_code_value0619_vc(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "cdf_meaning":
     SET gm_i_code_value0619_req->qual[iqual].cdf_meaning = ival
     SET gm_i_code_value0619_req->cdf_meaningi = 1
    OF "display":
     SET gm_i_code_value0619_req->qual[iqual].display = ival
     SET gm_i_code_value0619_req->displayi = 1
    OF "description":
     SET gm_i_code_value0619_req->qual[iqual].description = ival
     SET gm_i_code_value0619_req->descriptioni = 1
    OF "definition":
     SET gm_i_code_value0619_req->qual[iqual].definition = ival
     SET gm_i_code_value0619_req->definitioni = 1
    OF "cki":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].cki = ival
     SET gm_i_code_value0619_req->ckii = 1
    OF "concept_cki":
     SET gm_i_code_value0619_req->qual[iqual].concept_cki = ival
     SET gm_i_code_value0619_req->concept_ckii = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SET gm_i_code_value0619_req->code_seti = 1
 SET gm_i_code_value0619_req->displayi = 1
 SET gm_i_code_value0619_req->descriptioni = 1
 SET gm_i_code_value0619_req->cdf_meaningi = 1
 SET gm_i_code_value0619_req->collation_seqi = 1
 SET gm_i_code_value0619_req->active_indi = 1
 SET gm_i_code_value0619_req->active_type_cdi = 1
 SET gm_i_code_value0619_req->active_dt_tmi = 1
 SET gm_i_code_value0619_req->begin_effective_dt_tmi = 1
 SET gm_i_code_value0619_req->end_effective_dt_tmi = 1
 SET gm_i_code_value0619_req->data_status_cdi = 1
 SET stat = alterlist(gm_i_code_value0619_req->qual,1)
 SET gm_i_code_value0619_req->qual[1].code_set = 25451
 SET gm_i_code_value0619_req->qual[1].display = substring(1,40,request->display)
 SET gm_i_code_value0619_req->qual[1].description = substring(1,40,request->display)
 SET gm_i_code_value0619_req->qual[1].cdf_meaning = request->cdf_meaning
 SET gm_i_code_value0619_req->qual[1].collation_seq = request->collation_seq
 SET gm_i_code_value0619_req->qual[1].active_ind = 1
 SET gm_i_code_value0619_req->qual[1].active_type_cd = atc
 SET gm_i_code_value0619_req->qual[1].active_dt_tm = cnvtdatetime(curdate,curtime3)
 SET gm_i_code_value0619_req->qual[1].begin_effective_dt_tm = cnvtdatetime(curdate,curtime3)
 SET gm_i_code_value0619_req->qual[1].end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
 SET gm_i_code_value0619_req->qual[1].data_status_cd = dsc
 EXECUTE gm_i_code_value0619  WITH replace("REQUEST",gm_i_code_value0619_req), replace("REPLY",
  gm_i_code_value0619_rep)
 IF ((gm_i_code_value0619_rep->curqual=0)
  AND (gm_i_code_value0619_rep->status_data.status="F"))
  FREE RECORD gm_i_code_value0619_req
  FREE RECORD gm_i_code_value0619_rep
  GO TO cv_failed
 ENDIF
 SET fdcatcd = gm_i_code_value0619_rep->qual[1].code_value
 FREE RECORD gm_i_code_value0619_req
 FREE RECORD gm_i_code_value0619_rep
#insert_cvg
 INSERT  FROM code_value_group cvg,
   (dummyt d  WITH seq = value(qual_cnt))
  SET cvg.code_set = 6026, cvg.parent_code_value = fdcatcd, cvg.child_code_value = request->qual[d
   .seq].task_activity_cd,
   cvg.updt_id = reqinfo->updt_id, cvg.updt_task = reqinfo->updt_task, cvg.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (cvg)
  WITH nocounter
 ;end insert
 CALL echo(build("curqual =",curqual))
 IF (curqual=0)
  GO TO cvg_failed
 ENDIF
#cv_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 SET cfailed = "T"
 GO TO exit_script
#cvg_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "code_value_group"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE_GROUP"
 SET cfailed = "T"
 GO TO exit_script
 CALL echo(build("failed =",failed))
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP Attachment Tool"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO INSERT"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

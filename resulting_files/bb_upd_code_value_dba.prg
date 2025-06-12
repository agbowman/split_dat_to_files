CREATE PROGRAM bb_upd_code_value:dba
 RECORD reply(
   1 codelist[*]
     2 code_value = f8
     2 row_number = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 EXECUTE gm_code_value0619_def "I"
 SUBROUTINE (gm_i_code_value0619_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
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
 SUBROUTINE (gm_i_code_value0619_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) =i2)
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
 SUBROUTINE (gm_i_code_value0619_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) =i2)
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
 SUBROUTINE (gm_i_code_value0619_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
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
 SUBROUTINE (gm_i_code_value0619_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) =i2)
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
 EXECUTE gm_code_value0619_def "U"
 SUBROUTINE (gm_u_code_value0619_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
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
 SUBROUTINE (gm_u_code_value0619_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
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
 SUBROUTINE (gm_u_code_value0619_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
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
 SUBROUTINE (gm_u_code_value0619_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
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
 SUBROUTINE (gm_u_code_value0619_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
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
 SET modify = predeclare
 DECLARE end_dt_tm = q8 WITH constant(cnvtdatetime("31-DEC-2100 23:59:59.99"))
 DECLARE script_name = c17 WITH constant("bb_upd_code_value")
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE cv_cnt = i4 WITH noconstant(0)
 DECLARE cv_idx = i4 WITH noconstant(0)
 DECLARE reply_cnt = i4 WITH noconstant(0)
 DECLARE authentic_cs = i4 WITH constant(8)
 DECLARE authentic_mean = c12 WITH constant("AUTH")
 DECLARE authentic_cd = f8 WITH noconstant(0.0)
 DECLARE count = i4 WITH noconstant(0)
 DECLARE tmp_active_cd = f8 WITH noconstant(0.0)
 DECLARE tmp_inactive_cd = f8 WITH noconstant(0.0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 SET authentic_cd = uar_get_code_by("MEANING",authentic_cs,nullterm(authentic_mean))
 IF (authentic_cd <= 0.0)
  SET errmsg = concat("Failed to retrieve authentic code with meaning of ",trim(authentic_mean),".")
  CALL errorhandler("F","uar_get_code_by",errmsg)
 ENDIF
 SET cv_cnt = size(request->codevaluelist,5)
 FOR (cv_idx = 1 TO cv_cnt)
   IF ((request->codevaluelist[cv_idx].add_row=1))
    SET gm_i_code_value0619_req->allow_partial_ind = 0
    SET stat = gm_i_code_value0619_i4("CODE_SET",request->codevaluelist[cv_idx].code_set,1,0)
    IF (stat=1)
     SET stat = gm_i_code_value0619_vc("CDF_MEANING",request->codevaluelist[cv_idx].cdf_meaning,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_vc("DISPLAY",request->codevaluelist[cv_idx].display,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_vc("DESCRIPTION",request->codevaluelist[cv_idx].description,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_vc("DEFINITION",request->codevaluelist[cv_idx].definition,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_i4("COLLATION_SEQ",request->codevaluelist[cv_idx].collation_seq,1,
      0)
    ENDIF
    IF (stat=1)
     IF ((request->codevaluelist[cv_idx].active_ind=1))
      SET stat = gm_i_code_value0619_f8("ACTIVE_TYPE_CD",reqdata->active_status_cd,1,0)
     ELSE
      SET stat = gm_i_code_value0619_f8("ACTIVE_TYPE_CD",reqdata->inactive_status_cd,1,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_i2("ACTIVE_IND",request->codevaluelist[cv_idx].active_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_dq8("ACTIVE_DT_TM",cnvtdatetime(sysdate),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_dq8("BEGIN_EFFECTIVE_DT_TM",cnvtdatetime(sysdate),1,0)
    ENDIF
    IF (stat=1)
     IF ((request->codevaluelist[cv_idx].active_ind=1))
      SET stat = gm_i_code_value0619_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(end_dt_tm),1,0)
     ELSE
      SET stat = gm_i_code_value0619_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(sysdate),1,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_f8("DATA_STATUS_CD",authentic_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_dq8("DATA_STATUS_DT_TM",cnvtdatetime(sysdate),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_f8("DATA_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_code_value0619_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
    ENDIF
    IF (stat=1)
     IF ((request->codevaluelist[cv_idx].active_ind=0))
      SET stat = gm_i_code_value0619_dq8("INACTIVE_DT_TM",cnvtdatetime(sysdate),1,0)
     ENDIF
    ENDIF
    IF (stat=1)
     EXECUTE gm_i_code_value0619  WITH replace(request,gm_i_code_value0619_req), replace(reply,
      gm_i_code_value0619_rep)
     IF ((gm_i_code_value0619_rep->status_data.status="F"))
      CALL errorhandler("F","CODE_VALUE",gm_i_code_value0619_rep->qual[1].error_msg)
     ELSE
      SET reply_cnt += 1
      IF (mod(reply_cnt,10)=1)
       SET stat = alterlist(reply->codelist,(reply_cnt+ 9))
      ENDIF
      SET reply->codelist[reply_cnt].code_value = gm_i_code_value0619_rep->qual[1].code_value
      SET reply->codelist[reply_cnt].row_number = request->codevaluelist[cv_idx].row_number
     ENDIF
    ELSE
     CALL errorhandler("F","CODE_VALUE","Insert failed.")
    ENDIF
   ELSE
    SET gm_u_code_value0619_req->allow_partial_ind = 0
    SET gm_u_code_value0619_req->force_updt_ind = 1
    SET stat = gm_u_code_value0619_f8("CODE_VALUE",request->codevaluelist[cv_idx].code_value,1,0,1)
    IF (stat=1)
     SET stat = gm_u_code_value0619_vc("CDF_MEANING",request->codevaluelist[cv_idx].cdf_meaning,1,0,0
      )
    ENDIF
    IF (stat=1)
     SET stat = gm_u_code_value0619_vc("DISPLAY",request->codevaluelist[cv_idx].display,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_code_value0619_vc("DESCRIPTION",request->codevaluelist[cv_idx].description,1,0,0
      )
    ENDIF
    IF (stat=1)
     SET stat = gm_u_code_value0619_vc("DEFINITION",request->codevaluelist[cv_idx].definition,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_code_value0619_i4("COLLATION_SEQ",request->codevaluelist[cv_idx].collation_seq,1,
      0,0)
    ENDIF
    IF (stat=1)
     IF ((request->codevaluelist[cv_idx].active_ind=0))
      SET stat = gm_u_code_value0619_f8("ACTIVE_TYPE_CD",reqdata->inactive_status_cd,1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_code_value0619_i2("ACTIVE_IND",request->codevaluelist[cv_idx].active_ind,1,0,0)
    ENDIF
    IF (stat=1)
     IF ((request->codevaluelist[cv_idx].active_ind=0))
      SET stat = gm_u_code_value0619_dq8("INACTIVE_DT_TM",cnvtdatetime(sysdate),1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     IF ((request->codevaluelist[cv_idx].active_ind=0))
      SET stat = gm_u_code_value0619_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(sysdate),1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_code_value0619  WITH replace(request,gm_u_code_value0619_req), replace(reply,
      gm_u_code_value0619_rep)
     IF ((gm_u_code_value0619_rep->status_data.status="F"))
      CALL errorhandler("F","CODE_VALUE",gm_u_code_value0619_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","CODE_VALUE","Update failed.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->codelist,reply_cnt)
 GO TO set_status
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   SET reqinfo->commit_ind = 0
   GO TO exit_script
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 FREE RECORD gm_i_code_value0619_req
 FREE RECORD gm_i_code_value0619_rep
 FREE RECORD gm_u_code_value0619_req
 FREE RECORD gm_u_code_value0619_rep
END GO

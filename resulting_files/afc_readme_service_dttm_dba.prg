CREATE PROGRAM afc_readme_service_dttm:dba
 IF ("Z"=validate(afc_readme_service_dttm_vrsn,"Z"))
  DECLARE afc_readme_service_dttm_vrsn = vc WITH noconstant("52748.000")
 ENDIF
 SET afc_readme_service_dttm_vrsn = "52748.000"
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD gm_u_code_value0619_req
 FREE RECORD gm_u_code_value0619_rep
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
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stempcdfmeaning = c12
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=17809
   AND cv.cki="CKI.CODEVALUE!22116"
   AND active_ind=1
  DETAIL
   stempcdfmeaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 IF (stempcdfmeaning="SERVICE DTTM")
  SET reply->status_data.status = "S"
  CALL echo("Success - CDF_MEANING is already correct.")
 ELSE
  SET reply->status_data.status = "F"
  CALL echo("Fail - CDF_MEANING needs to be updated.")
 ENDIF
 CALL echo(stempcdfmeaning)
 IF ((reply->status_data.status="F"))
  SET gm_u_code_value0619_req->allow_partial_ind = 1
  SET gm_u_code_value0619_req->force_updt_ind = 1
  SET gm_u_code_value0619_req->cdf_meaningf = 1
  SET gm_u_code_value0619_req->code_setw = 1
  SET gm_u_code_value0619_req->ckiw = 1
  SET gm_u_code_value0619_req->active_indw = 1
  SET stat = alterlist(gm_u_code_value0619_req->qual,1)
  SET gm_u_code_value0619_req->qual[1].cdf_meaning = "SERVICE DTTM"
  SET gm_u_code_value0619_req->qual[1].code_set = 17809
  SET gm_u_code_value0619_req->qual[1].cki = "CKI.CODEVALUE!22116"
  SET gm_u_code_value0619_req->qual[1].active_ind = 1
  CALL echo("Execute GM_U_CODE_VALUE0619_NOUAR")
  EXECUTE gm_u_code_value0619_nouar  WITH replace("REQUEST",gm_u_code_value0619_req), replace("REPLY",
   gm_u_code_value0619_rep)
  FREE RECORD gm_u_code_value0619_req
  FREE RECORD gm_u_code_value0619_rep
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=17809
   AND cv.cki="CKI.CODEVALUE!22116"
   AND active_ind=1
  DETAIL
   stempcdfmeaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 IF (stempcdfmeaning="SERVICE DTTM")
  SET reply->status_data.status = "S"
  CALL echo("Success - CDF_MEANING is correct.")
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  CALL echo("Fail - CDF_MEANING is not correct.")
  ROLLBACK
 ENDIF
 CALL echo(stempcdfmeaning)
 IF ((reply->status_data.status="S"))
  CALL echo("status is successful")
  SET readme_data->status = "S"
  SET readme_data->message = "Service Date and Time CDF_Meaning updated successfully"
 ELSE
  CALL echo("status failed")
  SET readme_data->status = "F"
  SET readme_data->message = "Service Date and Time CDF_Meaning update failed"
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo(readme_data->message)
 ENDIF
 CALL echo("end of AFC_README_SERVICE_DTTM program")
END GO

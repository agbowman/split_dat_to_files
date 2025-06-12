CREATE PROGRAM dm_reset_cmb_last_updt:dba
 FREE RECORD rclu_varchar
 RECORD rclu_varchar(
   1 vc_variable = vc
 )
 DECLARE sbr_drclu_initialize(null) = i2
 DECLARE sbr_drclu_update_dminfo(null) = i2
 FREE RECORD gm_u_dm_info2388_req
 FREE RECORD gm_u_dm_info2388_rep
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
 IF (sbr_drclu_initialize(null)=0)
  CALL echo("Initialization failed")
  GO TO end_program
 ENDIF
 IF (sbr_drclu_update_dminfo(null)=0)
  CALL echo("Initialization successful, but failed on update")
  GO TO end_program
 ENDIF
#end_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD rclu_varchar
 FREE RECORD gm_u_dm_info2388_req
 FREE RECORD gm_u_dm_info2388_rep
 SUBROUTINE sbr_drclu_initialize(null)
   DECLARE di_const_input1 = c13
   DECLARE di_const_input2 = c14
   DECLARE di_rtn_status = i2
   SET di_const_input1 = "CMB_LAST_UPDT"
   SET di_const_input2 = "CMB_LAST_UPDT2"
   SET di_rtn_status = 0
   SET readme_data->status = "F"
   SET readme_data->message = "Readme Failed: Starting dm_reset_cmb_last_updt.prg script."
   SET rclu_varchar->vc_variable = trim(cnvtupper( $1))
   IF ((((rclu_varchar->vc_variable=di_const_input1)) OR ((rclu_varchar->vc_variable=di_const_input2)
   )) )
    SET di_rtn_status = 1
   ELSE
    SET readme_data->message = concat(
     "Readme Failed: Invalid input for dm_reset_cmb_last_updt.prg script."," Input value was: ",
     rclu_varchar->vc_variable)
   ENDIF
   RETURN(di_rtn_status)
 END ;Subroutine
 SUBROUTINE sbr_drclu_update_dminfo(null)
   DECLARE ud_rtn_status = i2
   DECLARE cnt = i4
   FREE RECORD rs_dst
   RECORD rs_dst(
     1 cmbname = vc
     1 cmbdate = dq8
     1 uluname = vc
     1 uludate = dq8
     1 newdt = dq8
     1 rqdrcdcnt = i4
     1 rclu_err_msg = c132
   )
   SET rs_dst->rclu_err_msg = fillstring(132," ")
   SET ud_rtn_status = 1
   SET rs_dst->rqdrcdcnt = 0
   SELECT INTO "nl:"
    i.info_name, i.info_date
    FROM dm_info i
    WHERE i.info_domain="DATA MANAGEMENT"
     AND i.info_name IN ("USERLASTUPDT", rclu_varchar->vc_variable)
    ORDER BY i.info_name
    DETAIL
     IF (i.info_name="USERLASTUPDT")
      rs_dst->uluname = i.info_name,
      CALL echo("NAME: "),
      CALL echo(rs_dst->uluname),
      rs_dst->uludate = i.info_date,
      CALL echo("DATE: "),
      CALL echo(rs_dst->uludate),
      rs_dst->rqdrcdcnt = (rs_dst->rqdrcdcnt+ 1)
     ELSEIF ((i.info_name=rclu_varchar->vc_variable))
      rs_dst->cmbname = i.info_name,
      CALL echo("NAME: "),
      CALL echo(rs_dst->cmbname),
      rs_dst->cmbdate = i.info_date,
      CALL echo("DATE: "),
      CALL echo(rs_dst->cmbdate),
      rs_dst->rqdrcdcnt = (rs_dst->rqdrcdcnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (error(rs_dst->rclu_err_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message =
    "ERROR: Select from dm_info where i.info_domain = DATA MANAGEMENT failed."
    SET ud_rtn_status = 0
   ELSEIF ((rs_dst->rqdrcdcnt < 2))
    SET readme_data->status = "S"
    SET readme_data->message = "SUCCESS: One or both of the DATA MANAGEMENT rows are not there."
   ELSEIF (((rs_dst->cmbdate - rs_dst->uludate) < 0))
    SET readme_data->status = "S"
    SET readme_data->message = "SUCCESS: CMB_LAST_UPDT(2) is already less than USERLASTUPDT."
   ELSE
    SET rs_dst->newdt = datetimeadd(rs_dst->uludate,- ((60/ 1440.0)))
    SET gm_u_dm_info2388_req->allow_partial_ind = 1
    SET gm_u_dm_info2388_req->force_updt_ind = 1
    SET stat = gm_u_dm_info2388_vc("INFO_DOMAIN","DATA MANAGEMENT",1,0,1)
    IF (stat=1)
     SET stat = gm_u_dm_info2388_vc("INFO_NAME",rclu_varchar->vc_variable,1,0,1)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_dm_info2388_dq8("INFO_DATE",rs_dst->newdt,1,0,0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_dm_info2388  WITH replace(request,gm_u_dm_info2388_req), replace(reply,
      gm_u_dm_info2388_rep)
     IF ((gm_u_dm_info2388_rep->qual[1].status=1))
      SET readme_data->status = "S"
      SET readme_data->message =
      "SUCCESS: CMB_LAST_UPDT(2) has been set back 1 hour less than USERLASTUPDT..."
      COMMIT
     ELSE
      SET readme_data->status = "F"
      SET readme_data->message = "ERROR: Update of dm_info failed."
      SET ud_rtn_status = 0
      ROLLBACK
     ENDIF
    ELSE
     SET readme_data->status = "F"
     SET readme_data->message = "ERROR: Update of gm_u_dm_info2388_req failed."
     SET ud_rtn_status = 0
    ENDIF
   ENDIF
   FREE RECORD rs_dst
   RETURN(ud_rtn_status)
 END ;Subroutine
END GO

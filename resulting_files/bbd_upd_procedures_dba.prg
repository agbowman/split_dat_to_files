CREATE PROGRAM bbd_upd_procedures:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 EXECUTE gm_bbd_donation8460_def "I"
 DECLARE gm_i_bbd_donation8460_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donation8460_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donation8460_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donation8460_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_donation8460_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donation8460_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donation8460_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "procedure_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].procedure_id = ival
     SET gm_i_bbd_donation8460_req->procedure_idi = 1
    OF "procedure_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].procedure_cd = ival
     SET gm_i_bbd_donation8460_req->procedure_cdi = 1
    OF "deferrals_allowed_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].deferrals_allowed_cd = ival
     SET gm_i_bbd_donation8460_req->deferrals_allowed_cdi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_donation8460_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_donation8460_req->active_status_prsnl_idi = 1
    OF "updt_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].updt_id = ival
     SET gm_i_bbd_donation8460_req->updt_idi = 1
    OF "default_donation_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].default_donation_type_cd = ival
     SET gm_i_bbd_donation8460_req->default_donation_type_cdi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donation8460_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donation8460_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donation8460_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "schedule_ind":
     SET gm_i_bbd_donation8460_req->qual[iqual].schedule_ind = ival
     SET gm_i_bbd_donation8460_req->schedule_indi = 1
    OF "start_stop_ind":
     SET gm_i_bbd_donation8460_req->qual[iqual].start_stop_ind = ival
     SET gm_i_bbd_donation8460_req->start_stop_indi = 1
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_donation8460_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donation8460_i4(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donation8460_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donation8460_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "nbr_per_volume_level":
     SET gm_i_bbd_donation8460_req->qual[iqual].nbr_per_volume_level = ival
     SET gm_i_bbd_donation8460_req->nbr_per_volume_leveli = 1
    OF "updt_applctx":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].updt_applctx = ival
     SET gm_i_bbd_donation8460_req->updt_applctxi = 1
    OF "updt_task":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].updt_task = ival
     SET gm_i_bbd_donation8460_req->updt_taski = 1
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].updt_cnt = ival
     SET gm_i_bbd_donation8460_req->updt_cnti = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donation8460_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donation8460_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donation8460_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donation8460_req->beg_effective_dt_tmi = 1
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donation8460_req->end_effective_dt_tmi = 1
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donation8460_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation8460_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donation8460_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_donation8460_def "U"
 DECLARE gm_u_bbd_donation8460_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donation8460_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donation8460_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donation8460_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_donation8460_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donation8460_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donation8460_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "procedure_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->procedure_idf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].procedure_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->procedure_idw = 1
     ENDIF
    OF "procedure_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->procedure_cdf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].procedure_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->procedure_cdw = 1
     ENDIF
    OF "deferrals_allowed_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->deferrals_allowed_cdf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].deferrals_allowed_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->deferrals_allowed_cdw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->active_status_cdf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->active_status_prsnl_idw = 1
     ENDIF
    OF "default_donation_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->default_donation_type_cdf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].default_donation_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->default_donation_type_cdw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donation8460_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donation8460_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donation8460_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "schedule_ind":
     IF (null_ind=1)
      SET gm_u_bbd_donation8460_req->schedule_indf = 2
     ELSE
      SET gm_u_bbd_donation8460_req->schedule_indf = 1
     ENDIF
     SET gm_u_bbd_donation8460_req->qual[iqual].schedule_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->schedule_indw = 1
     ENDIF
    OF "start_stop_ind":
     IF (null_ind=1)
      SET gm_u_bbd_donation8460_req->start_stop_indf = 2
     ELSE
      SET gm_u_bbd_donation8460_req->start_stop_indf = 1
     ENDIF
     SET gm_u_bbd_donation8460_req->qual[iqual].start_stop_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->start_stop_indw = 1
     ENDIF
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->active_indf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donation8460_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donation8460_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donation8460_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "nbr_per_volume_level":
     IF (null_ind=1)
      SET gm_u_bbd_donation8460_req->nbr_per_volume_levelf = 2
     ELSE
      SET gm_u_bbd_donation8460_req->nbr_per_volume_levelf = 1
     ENDIF
     SET gm_u_bbd_donation8460_req->qual[iqual].nbr_per_volume_level = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->nbr_per_volume_levelw = 1
     ENDIF
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->updt_cntf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donation8460_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donation8460_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donation8460_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->beg_effective_dt_tmf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->beg_effective_dt_tmw = 1
     ENDIF
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->end_effective_dt_tmf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->end_effective_dt_tmw = 1
     ENDIF
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->active_status_dt_tmf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation8460_req->updt_dt_tmf = 1
     SET gm_u_bbd_donation8460_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donation8460_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_procedur8459_def "I"
 DECLARE gm_i_bbd_procedur8459_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_procedur8459_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_procedur8459_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_procedur8459_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_procedur8459_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_procedur8459_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_procedur8459_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "procedure_outcome_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].procedure_outcome_id = ival
     SET gm_i_bbd_procedur8459_req->procedure_outcome_idi = 1
    OF "outcome_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].outcome_cd = ival
     SET gm_i_bbd_procedur8459_req->outcome_cdi = 1
    OF "synonym_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].synonym_id = ival
     SET gm_i_bbd_procedur8459_req->synonym_idi = 1
    OF "procedure_id":
     SET gm_i_bbd_procedur8459_req->qual[iqual].procedure_id = ival
     SET gm_i_bbd_procedur8459_req->procedure_idi = 1
    OF "quar_reason_cd":
     SET gm_i_bbd_procedur8459_req->qual[iqual].quar_reason_cd = ival
     SET gm_i_bbd_procedur8459_req->quar_reason_cdi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_procedur8459_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_procedur8459_req->active_status_prsnl_idi = 1
    OF "updt_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].updt_id = ival
     SET gm_i_bbd_procedur8459_req->updt_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_procedur8459_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_procedur8459_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_procedur8459_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "count_as_donation_ind":
     SET gm_i_bbd_procedur8459_req->qual[iqual].count_as_donation_ind = ival
     SET gm_i_bbd_procedur8459_req->count_as_donation_indi = 1
    OF "add_product_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].add_product_ind = ival
     SET gm_i_bbd_procedur8459_req->add_product_indi = 1
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_procedur8459_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_procedur8459_i4(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_procedur8459_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_procedur8459_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "updt_applctx":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].updt_applctx = ival
     SET gm_i_bbd_procedur8459_req->updt_applctxi = 1
    OF "updt_task":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].updt_task = ival
     SET gm_i_bbd_procedur8459_req->updt_taski = 1
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].updt_cnt = ival
     SET gm_i_bbd_procedur8459_req->updt_cnti = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_procedur8459_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_procedur8459_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_procedur8459_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_procedur8459_req->beg_effective_dt_tmi = 1
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_procedur8459_req->end_effective_dt_tmi = 1
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_procedur8459_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_procedur8459_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_procedur8459_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_procedur8459_def "U"
 DECLARE gm_u_bbd_procedur8459_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_procedur8459_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_procedur8459_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_procedur8459_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_procedur8459_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_procedur8459_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_procedur8459_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "procedure_outcome_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->procedure_outcome_idf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].procedure_outcome_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->procedure_outcome_idw = 1
     ENDIF
    OF "outcome_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->outcome_cdf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].outcome_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->outcome_cdw = 1
     ENDIF
    OF "synonym_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->synonym_idf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].synonym_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->synonym_idw = 1
     ENDIF
    OF "procedure_id":
     IF (null_ind=1)
      SET gm_u_bbd_procedur8459_req->procedure_idf = 2
     ELSE
      SET gm_u_bbd_procedur8459_req->procedure_idf = 1
     ENDIF
     SET gm_u_bbd_procedur8459_req->qual[iqual].procedure_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->procedure_idw = 1
     ENDIF
    OF "quar_reason_cd":
     IF (null_ind=1)
      SET gm_u_bbd_procedur8459_req->quar_reason_cdf = 2
     ELSE
      SET gm_u_bbd_procedur8459_req->quar_reason_cdf = 1
     ENDIF
     SET gm_u_bbd_procedur8459_req->qual[iqual].quar_reason_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->quar_reason_cdw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->active_status_cdf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_procedur8459_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_procedur8459_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_procedur8459_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "count_as_donation_ind":
     IF (null_ind=1)
      SET gm_u_bbd_procedur8459_req->count_as_donation_indf = 2
     ELSE
      SET gm_u_bbd_procedur8459_req->count_as_donation_indf = 1
     ENDIF
     SET gm_u_bbd_procedur8459_req->qual[iqual].count_as_donation_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->count_as_donation_indw = 1
     ENDIF
    OF "add_product_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->add_product_indf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].add_product_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->add_product_indw = 1
     ENDIF
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->active_indf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_procedur8459_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_procedur8459_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_procedur8459_req->qual,iqual)
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
     SET gm_u_bbd_procedur8459_req->updt_cntf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_procedur8459_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_procedur8459_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_procedur8459_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->beg_effective_dt_tmf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->beg_effective_dt_tmw = 1
     ENDIF
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->end_effective_dt_tmf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->end_effective_dt_tmw = 1
     ENDIF
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->active_status_dt_tmf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_procedur8459_req->updt_dt_tmf = 1
     SET gm_u_bbd_procedur8459_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_procedur8459_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_outcome_8462_def "I"
 DECLARE gm_i_bbd_outcome_8462_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_outcome_8462_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_outcome_8462_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_outcome_8462_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_outcome_8462_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_outcome_8462_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_outcome_8462_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "outcome_reason_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].outcome_reason_id = ival
     SET gm_i_bbd_outcome_8462_req->outcome_reason_idi = 1
    OF "reason_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].reason_cd = ival
     SET gm_i_bbd_outcome_8462_req->reason_cdi = 1
    OF "deferral_expire_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].deferral_expire_cd = ival
     SET gm_i_bbd_outcome_8462_req->deferral_expire_cdi = 1
    OF "procedure_outcome_id":
     SET gm_i_bbd_outcome_8462_req->qual[iqual].procedure_outcome_id = ival
     SET gm_i_bbd_outcome_8462_req->procedure_outcome_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_outcome_8462_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_outcome_8462_req->active_status_prsnl_idi = 1
    OF "updt_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].updt_id = ival
     SET gm_i_bbd_outcome_8462_req->updt_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_outcome_8462_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_outcome_8462_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_outcome_8462_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_outcome_8462_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_outcome_8462_i4(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_outcome_8462_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_outcome_8462_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "days_ineligible":
     SET gm_i_bbd_outcome_8462_req->qual[iqual].days_ineligible = ival
     SET gm_i_bbd_outcome_8462_req->days_ineligiblei = 1
    OF "hours_ineligible":
     SET gm_i_bbd_outcome_8462_req->qual[iqual].hours_ineligible = ival
     SET gm_i_bbd_outcome_8462_req->hours_ineligiblei = 1
    OF "updt_applctx":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].updt_applctx = ival
     SET gm_i_bbd_outcome_8462_req->updt_applctxi = 1
    OF "updt_task":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].updt_task = ival
     SET gm_i_bbd_outcome_8462_req->updt_taski = 1
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].updt_cnt = ival
     SET gm_i_bbd_outcome_8462_req->updt_cnti = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_outcome_8462_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_outcome_8462_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_outcome_8462_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_outcome_8462_req->beg_effective_dt_tmi = 1
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_outcome_8462_req->end_effective_dt_tmi = 1
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_outcome_8462_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8462_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_outcome_8462_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_outcome_8462_def "U"
 DECLARE gm_u_bbd_outcome_8462_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_outcome_8462_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_outcome_8462_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_outcome_8462_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_outcome_8462_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_outcome_8462_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_outcome_8462_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "outcome_reason_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->outcome_reason_idf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].outcome_reason_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->outcome_reason_idw = 1
     ENDIF
    OF "reason_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->reason_cdf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].reason_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->reason_cdw = 1
     ENDIF
    OF "deferral_expire_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->deferral_expire_cdf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].deferral_expire_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->deferral_expire_cdw = 1
     ENDIF
    OF "procedure_outcome_id":
     IF (null_ind=1)
      SET gm_u_bbd_outcome_8462_req->procedure_outcome_idf = 2
     ELSE
      SET gm_u_bbd_outcome_8462_req->procedure_outcome_idf = 1
     ENDIF
     SET gm_u_bbd_outcome_8462_req->qual[iqual].procedure_outcome_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->procedure_outcome_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->active_status_cdf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_outcome_8462_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_outcome_8462_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_outcome_8462_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->active_indf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_outcome_8462_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_outcome_8462_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_outcome_8462_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "days_ineligible":
     IF (null_ind=1)
      SET gm_u_bbd_outcome_8462_req->days_ineligiblef = 2
     ELSE
      SET gm_u_bbd_outcome_8462_req->days_ineligiblef = 1
     ENDIF
     SET gm_u_bbd_outcome_8462_req->qual[iqual].days_ineligible = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->days_ineligiblew = 1
     ENDIF
    OF "hours_ineligible":
     IF (null_ind=1)
      SET gm_u_bbd_outcome_8462_req->hours_ineligiblef = 2
     ELSE
      SET gm_u_bbd_outcome_8462_req->hours_ineligiblef = 1
     ENDIF
     SET gm_u_bbd_outcome_8462_req->qual[iqual].hours_ineligible = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->hours_ineligiblew = 1
     ENDIF
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->updt_cntf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_outcome_8462_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_outcome_8462_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_outcome_8462_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->beg_effective_dt_tmf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->beg_effective_dt_tmw = 1
     ENDIF
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->end_effective_dt_tmf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->end_effective_dt_tmw = 1
     ENDIF
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->active_status_dt_tmf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8462_req->updt_dt_tmf = 1
     SET gm_u_bbd_outcome_8462_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8462_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_outcome_8461_def "I"
 DECLARE gm_i_bbd_outcome_8461_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_outcome_8461_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_outcome_8461_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_outcome_8461_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_outcome_8461_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_outcome_8461_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_outcome_8461_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "outcome_bag_type_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].outcome_bag_type_id = ival
     SET gm_i_bbd_outcome_8461_req->outcome_bag_type_idi = 1
    OF "bag_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].bag_type_cd = ival
     SET gm_i_bbd_outcome_8461_req->bag_type_cdi = 1
    OF "procedure_outcome_id":
     SET gm_i_bbd_outcome_8461_req->qual[iqual].procedure_outcome_id = ival
     SET gm_i_bbd_outcome_8461_req->procedure_outcome_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_outcome_8461_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_outcome_8461_req->active_status_prsnl_idi = 1
    OF "updt_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].updt_id = ival
     SET gm_i_bbd_outcome_8461_req->updt_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_outcome_8461_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_outcome_8461_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_outcome_8461_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "default_ind":
     SET gm_i_bbd_outcome_8461_req->qual[iqual].default_ind = ival
     SET gm_i_bbd_outcome_8461_req->default_indi = 1
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_outcome_8461_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_outcome_8461_i4(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_outcome_8461_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_outcome_8461_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "updt_applctx":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].updt_applctx = ival
     SET gm_i_bbd_outcome_8461_req->updt_applctxi = 1
    OF "updt_task":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].updt_task = ival
     SET gm_i_bbd_outcome_8461_req->updt_taski = 1
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].updt_cnt = ival
     SET gm_i_bbd_outcome_8461_req->updt_cnti = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_outcome_8461_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_outcome_8461_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_outcome_8461_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_outcome_8461_req->beg_effective_dt_tmi = 1
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_outcome_8461_req->end_effective_dt_tmi = 1
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_outcome_8461_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_outcome_8461_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_outcome_8461_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_outcome_8461_def "U"
 DECLARE gm_u_bbd_outcome_8461_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_outcome_8461_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_outcome_8461_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_outcome_8461_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_outcome_8461_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_outcome_8461_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_outcome_8461_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "outcome_bag_type_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8461_req->outcome_bag_type_idf = 1
     SET gm_u_bbd_outcome_8461_req->qual[iqual].outcome_bag_type_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->outcome_bag_type_idw = 1
     ENDIF
    OF "bag_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8461_req->bag_type_cdf = 1
     SET gm_u_bbd_outcome_8461_req->qual[iqual].bag_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->bag_type_cdw = 1
     ENDIF
    OF "procedure_outcome_id":
     IF (null_ind=1)
      SET gm_u_bbd_outcome_8461_req->procedure_outcome_idf = 2
     ELSE
      SET gm_u_bbd_outcome_8461_req->procedure_outcome_idf = 1
     ENDIF
     SET gm_u_bbd_outcome_8461_req->qual[iqual].procedure_outcome_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->procedure_outcome_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8461_req->active_status_cdf = 1
     SET gm_u_bbd_outcome_8461_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8461_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_outcome_8461_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_outcome_8461_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_outcome_8461_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_outcome_8461_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "default_ind":
     IF (null_ind=1)
      SET gm_u_bbd_outcome_8461_req->default_indf = 2
     ELSE
      SET gm_u_bbd_outcome_8461_req->default_indf = 1
     ENDIF
     SET gm_u_bbd_outcome_8461_req->qual[iqual].default_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->default_indw = 1
     ENDIF
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8461_req->active_indf = 1
     SET gm_u_bbd_outcome_8461_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_outcome_8461_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_outcome_8461_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_outcome_8461_req->qual,iqual)
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
     SET gm_u_bbd_outcome_8461_req->updt_cntf = 1
     SET gm_u_bbd_outcome_8461_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_outcome_8461_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_outcome_8461_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_outcome_8461_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8461_req->beg_effective_dt_tmf = 1
     SET gm_u_bbd_outcome_8461_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->beg_effective_dt_tmw = 1
     ENDIF
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8461_req->end_effective_dt_tmf = 1
     SET gm_u_bbd_outcome_8461_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->end_effective_dt_tmw = 1
     ENDIF
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8461_req->active_status_dt_tmf = 1
     SET gm_u_bbd_outcome_8461_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_outcome_8461_req->updt_dt_tmf = 1
     SET gm_u_bbd_outcome_8461_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_outcome_8461_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_bag_type8458_def "I"
 DECLARE gm_i_bbd_bag_type8458_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_bag_type8458_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_bag_type8458_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_bag_type8458_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_bag_type8458_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_bag_type8458_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_bag_type8458_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "bag_type_product_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].bag_type_product_id = ival
     SET gm_i_bbd_bag_type8458_req->bag_type_product_idi = 1
    OF "product_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].product_cd = ival
     SET gm_i_bbd_bag_type8458_req->product_cdi = 1
    OF "outcome_bag_type_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].outcome_bag_type_id = ival
     SET gm_i_bbd_bag_type8458_req->outcome_bag_type_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_bag_type8458_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_bag_type8458_req->active_status_prsnl_idi = 1
    OF "updt_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].updt_id = ival
     SET gm_i_bbd_bag_type8458_req->updt_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_bag_type8458_i4(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_bag_type8458_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_bag_type8458_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "updt_applctx":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].updt_applctx = ival
     SET gm_i_bbd_bag_type8458_req->updt_applctxi = 1
    OF "updt_task":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].updt_task = ival
     SET gm_i_bbd_bag_type8458_req->updt_taski = 1
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].updt_cnt = ival
     SET gm_i_bbd_bag_type8458_req->updt_cnti = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_bag_type8458_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_bag_type8458_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_bag_type8458_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "default_ind":
     SET gm_i_bbd_bag_type8458_req->qual[iqual].default_ind = ival
     SET gm_i_bbd_bag_type8458_req->default_indi = 1
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_bag_type8458_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_bag_type8458_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_bag_type8458_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_bag_type8458_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_bag_type8458_req->beg_effective_dt_tmi = 1
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_bag_type8458_req->end_effective_dt_tmi = 1
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_bag_type8458_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_bag_type8458_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_bag_type8458_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_bag_type8458_def "U"
 DECLARE gm_u_bbd_bag_type8458_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_bag_type8458_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_bag_type8458_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_bag_type8458_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_bag_type8458_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_bag_type8458_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_bag_type8458_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "bag_type_product_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_bag_type8458_req->bag_type_product_idf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].bag_type_product_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->bag_type_product_idw = 1
     ENDIF
    OF "product_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_bag_type8458_req->product_cdf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].product_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->product_cdw = 1
     ENDIF
    OF "outcome_bag_type_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_bag_type8458_req->outcome_bag_type_idf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].outcome_bag_type_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->outcome_bag_type_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_bag_type8458_req->active_status_cdf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_bag_type8458_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_bag_type8458_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_bag_type8458_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_bag_type8458_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "default_ind":
     IF (null_ind=1)
      SET gm_u_bbd_bag_type8458_req->default_indf = 2
     ELSE
      SET gm_u_bbd_bag_type8458_req->default_indf = 1
     ENDIF
     SET gm_u_bbd_bag_type8458_req->qual[iqual].default_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->default_indw = 1
     ENDIF
    OF "active_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_bag_type8458_req->active_indf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_bag_type8458_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_bag_type8458_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_bag_type8458_req->qual,iqual)
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
     SET gm_u_bbd_bag_type8458_req->updt_cntf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_bag_type8458_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_bag_type8458_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_bag_type8458_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_bag_type8458_req->beg_effective_dt_tmf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->beg_effective_dt_tmw = 1
     ENDIF
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_bag_type8458_req->end_effective_dt_tmf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->end_effective_dt_tmw = 1
     ENDIF
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_bag_type8458_req->active_status_dt_tmf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_bag_type8458_req->updt_dt_tmf = 1
     SET gm_u_bbd_bag_type8458_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_bag_type8458_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SET modify = predeclare
 DECLARE getsequence(null) = f8 WITH protect, noconstant(0.0)
 DECLARE system_dt_tm = q8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE script_name = c18 WITH constant("bbd_upd_procedures")
 DECLARE procedure_cnt = i4 WITH noconstant(0)
 DECLARE outcome_cnt = i4 WITH noconstant(0)
 DECLARE reason_cnt = i4 WITH noconstant(0)
 DECLARE bagtype_cnt = i4 WITH noconstant(0)
 DECLARE product_cnt = i4 WITH noconstant(0)
 DECLARE o_cnt = i4 WITH noconstant(0)
 DECLARE r_cnt = i4 WITH noconstant(0)
 DECLARE b_cnt = i4 WITH noconstant(0)
 DECLARE p_cnt = i4 WITH noconstant(0)
 DECLARE p_idx = i4 WITH noconstant(0)
 DECLARE o_idx = i4 WITH noconstant(0)
 DECLARE r_idx = i4 WITH noconstant(0)
 DECLARE b_idx = i4 WITH noconstant(0)
 DECLARE pr_idx = i4 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 DECLARE tmp_active_cd = f8 WITH noconstant(0.0)
 DECLARE tmp_inactive_cd = f8 WITH noconstant(0.0)
 DECLARE snap_o_cnt = i4 WITH noconstant(0)
 DECLARE snap_o_idx = i4 WITH noconstant(0)
 DECLARE snap_r_cnt = i4 WITH noconstant(0)
 DECLARE snap_b_cnt = i4 WITH noconstant(0)
 DECLARE snap_b_idx = i4 WITH noconstant(0)
 DECLARE snap_p_cnt = i4 WITH noconstant(0)
 DECLARE snap_p_idx = i4 WITH noconstant(0)
 DECLARE locate_idx = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 SET procedure_cnt = size(request->procedurelist,5)
 FOR (p_idx = 1 TO procedure_cnt)
   FREE RECORD snapshot
   RECORD snapshot(
     1 procedure_id = f8
     1 procedure_cd = f8
     1 deferrals_allowed_cd = f8
     1 nbr_per_volume_level = i4
     1 schedule_ind = i1
     1 start_stop_ind = i1
     1 beg_effective_dt_tm = dq8
     1 end_effective_dt_tm = dq8
     1 active_status_dt_tm = dq8
     1 active_status_prsnl_id = f8
     1 updt_applctx = i4
     1 updt_cnt = i4
     1 updt_dt_tm = dq8
     1 updt_id = f8
     1 updt_task = i4
     1 outcomelist[*]
       2 procedure_outcome_id = f8
       2 outcome_cd = f8
       2 count_as_donation_ind = i2
       2 synonym_id = f8
       2 add_product_ind = i2
       2 quar_reason_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 updt_applctx = i4
       2 updt_cnt = i4
       2 updt_dt_tm = dq8
       2 updt_id = f8
       2 updt_task = i4
       2 reasonlist[*]
         3 outcome_reason_id = f8
         3 reason_cd = f8
         3 days_ineligible = i4
         3 hours_ineligible = i4
         3 deferral_expire_cd = f8
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
         3 active_status_dt_tm = dq8
         3 active_status_prsnl_id = f8
         3 updt_applctx = i4
         3 updt_cnt = i4
         3 updt_dt_tm = dq8
         3 updt_id = f8
         3 updt_task = i4
       2 bagtypelist[*]
         3 outcome_bag_type_id = f8
         3 bag_type_cd = f8
         3 default_ind = i2
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
         3 active_status_dt_tm = dq8
         3 active_status_prsnl_id = f8
         3 updt_applctx = i4
         3 updt_cnt = i4
         3 updt_dt_tm = dq8
         3 updt_id = f8
         3 updt_task = i4
         3 productlist[*]
           4 bag_type_product_id = f8
           4 product_cd = f8
           4 default_ind = i2
           4 beg_effective_dt_tm = dq8
           4 end_effective_dt_tm = dq8
           4 active_status_dt_tm = dq8
           4 active_status_prsnl_id = f8
           4 updt_applctx = i4
           4 updt_cnt = i4
           4 updt_dt_tm = dq8
           4 updt_id = f8
           4 updt_task = i4
     1 default_donation_type_cd = f8
   )
   SELECT INTO "nl:"
    bdp.*, bpo.*, bor.*,
    bobt.*, bbtp.*, outcome_path = evaluate(nullind(bpo.procedure_outcome_id),0,1,0),
    bag_reason_path = decode(bor.seq,1,bobt.seq,2,0), product_path = evaluate(nullind(bbtp
      .bag_type_product_id),0,1,0)
    FROM bbd_donation_procedure bdp,
     bbd_procedure_outcome bpo,
     bbd_outcome_reason bor,
     bbd_outcome_bag_type bobt,
     bbd_bag_type_product bbtp,
     dummyt d1,
     dummyt d2
    PLAN (bdp
     WHERE (bdp.procedure_cd=request->procedurelist[p_idx].procedure_cd)
      AND bdp.active_ind=1)
     JOIN (bpo
     WHERE bpo.procedure_id=outerjoin(bdp.procedure_id)
      AND bpo.active_ind=outerjoin(1))
     JOIN (((d1)
     JOIN (bor
     WHERE bor.procedure_outcome_id=bpo.procedure_outcome_id
      AND bor.active_ind=1)
     ) ORJOIN ((d2)
     JOIN (bobt
     WHERE bobt.procedure_outcome_id=bpo.procedure_outcome_id
      AND bobt.active_ind=1)
     JOIN (bbtp
     WHERE bbtp.outcome_bag_type_id=outerjoin(bobt.outcome_bag_type_id)
      AND bbtp.active_ind=outerjoin(1))
     ))
    ORDER BY bdp.procedure_cd, bpo.procedure_outcome_id, bor.outcome_reason_id,
     bobt.outcome_bag_type_id, bbtp.bag_type_product_id
    HEAD bdp.procedure_cd
     o_cnt = 0, request->procedurelist[p_idx].procedure_id = bdp.procedure_id, snapshot->procedure_id
      = bdp.procedure_id,
     snapshot->procedure_cd = bdp.procedure_cd, snapshot->deferrals_allowed_cd = bdp
     .deferrals_allowed_cd, snapshot->nbr_per_volume_level = bdp.nbr_per_volume_level,
     snapshot->schedule_ind = bdp.schedule_ind, snapshot->start_stop_ind = bdp.start_stop_ind,
     snapshot->beg_effective_dt_tm = bdp.beg_effective_dt_tm,
     snapshot->end_effective_dt_tm = bdp.end_effective_dt_tm, snapshot->active_status_dt_tm = bdp
     .active_status_dt_tm, snapshot->active_status_prsnl_id = bdp.active_status_prsnl_id,
     snapshot->updt_applctx = bdp.updt_applctx, snapshot->updt_cnt = bdp.updt_cnt, snapshot->
     updt_dt_tm = bdp.updt_dt_tm,
     snapshot->updt_id = bdp.updt_id, snapshot->updt_task = bdp.updt_task, snapshot->
     default_donation_type_cd = bdp.default_donation_type_cd
    HEAD bpo.procedure_outcome_id
     IF (outcome_path=1)
      r_cnt = 0, b_cnt = 0, o_cnt = (o_cnt+ 1)
      IF (mod(o_cnt,10)=1)
       stat = alterlist(snapshot->outcomelist,(o_cnt+ 9))
      ENDIF
      snapshot->outcomelist[o_cnt].procedure_outcome_id = bpo.procedure_outcome_id, snapshot->
      outcomelist[o_cnt].outcome_cd = bpo.outcome_cd, snapshot->outcomelist[o_cnt].
      count_as_donation_ind = bpo.count_as_donation_ind,
      snapshot->outcomelist[o_cnt].synonym_id = bpo.synonym_id, snapshot->outcomelist[o_cnt].
      add_product_ind = bpo.add_product_ind, snapshot->outcomelist[o_cnt].quar_reason_cd = bpo
      .quar_reason_cd,
      snapshot->outcomelist[o_cnt].beg_effective_dt_tm = bpo.beg_effective_dt_tm, snapshot->
      outcomelist[o_cnt].end_effective_dt_tm = bpo.end_effective_dt_tm, snapshot->outcomelist[o_cnt].
      active_status_dt_tm = bpo.active_status_dt_tm,
      snapshot->outcomelist[o_cnt].active_status_prsnl_id = bpo.active_status_prsnl_id, snapshot->
      outcomelist[o_cnt].updt_applctx = bpo.updt_applctx, snapshot->outcomelist[o_cnt].updt_cnt = bpo
      .updt_cnt,
      snapshot->outcomelist[o_cnt].updt_dt_tm = bpo.updt_dt_tm, snapshot->outcomelist[o_cnt].updt_id
       = bpo.updt_id, snapshot->outcomelist[o_cnt].updt_task = bpo.updt_task
     ENDIF
    HEAD bor.outcome_reason_id
     IF (bag_reason_path=1)
      r_cnt = (r_cnt+ 1)
      IF (mod(r_cnt,10)=1)
       stat = alterlist(snapshot->outcomelist[o_cnt].reasonlist,(r_cnt+ 9))
      ENDIF
      snapshot->outcomelist[o_cnt].reasonlist[r_cnt].outcome_reason_id = bor.outcome_reason_id,
      snapshot->outcomelist[o_cnt].reasonlist[r_cnt].reason_cd = bor.reason_cd, snapshot->
      outcomelist[o_cnt].reasonlist[r_cnt].days_ineligible = bor.days_ineligible,
      snapshot->outcomelist[o_cnt].reasonlist[r_cnt].hours_ineligible = bor.hours_ineligible,
      snapshot->outcomelist[o_cnt].reasonlist[r_cnt].deferral_expire_cd = bor.deferral_expire_cd,
      snapshot->outcomelist[o_cnt].reasonlist[r_cnt].beg_effective_dt_tm = bor.beg_effective_dt_tm,
      snapshot->outcomelist[o_cnt].reasonlist[r_cnt].end_effective_dt_tm = bor.end_effective_dt_tm,
      snapshot->outcomelist[o_cnt].reasonlist[r_cnt].active_status_dt_tm = bor.active_status_dt_tm,
      snapshot->outcomelist[o_cnt].reasonlist[r_cnt].active_status_prsnl_id = bor
      .active_status_prsnl_id,
      snapshot->outcomelist[o_cnt].reasonlist[r_cnt].updt_applctx = bor.updt_applctx, snapshot->
      outcomelist[o_cnt].reasonlist[r_cnt].updt_cnt = bor.updt_cnt, snapshot->outcomelist[o_cnt].
      reasonlist[r_cnt].updt_dt_tm = bor.updt_dt_tm,
      snapshot->outcomelist[o_cnt].reasonlist[r_cnt].updt_id = bor.updt_id, snapshot->outcomelist[
      o_cnt].reasonlist[r_cnt].updt_task = bor.updt_task
     ENDIF
    HEAD bobt.outcome_bag_type_id
     IF (bag_reason_path=2)
      p_cnt = 0, b_cnt = (b_cnt+ 1)
      IF (mod(b_cnt,10)=1)
       stat = alterlist(snapshot->outcomelist[o_cnt].bagtypelist,(b_cnt+ 9))
      ENDIF
      snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].outcome_bag_type_id = bobt.outcome_bag_type_id,
      snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].bag_type_cd = bobt.bag_type_cd, snapshot->
      outcomelist[o_cnt].bagtypelist[b_cnt].default_ind = bobt.default_ind,
      snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].beg_effective_dt_tm = bobt.beg_effective_dt_tm,
      snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].end_effective_dt_tm = bobt.end_effective_dt_tm,
      snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].active_status_dt_tm = bobt.active_status_dt_tm,
      snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].active_status_prsnl_id = bobt
      .active_status_prsnl_id, snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].updt_applctx = bobt
      .updt_applctx, snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].updt_cnt = bobt.updt_cnt,
      snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].updt_dt_tm = bobt.updt_dt_tm, snapshot->
      outcomelist[o_cnt].bagtypelist[b_cnt].updt_id = bobt.updt_id, snapshot->outcomelist[o_cnt].
      bagtypelist[b_cnt].updt_task = bobt.updt_task
     ENDIF
    HEAD bbtp.bag_type_product_id
     IF (bag_reason_path=2)
      IF (product_path=1)
       p_cnt = (p_cnt+ 1)
       IF (mod(p_cnt,10)=1)
        stat = alterlist(snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist,(p_cnt+ 9))
       ENDIF
       snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist[p_cnt].bag_type_product_id = bbtp
       .bag_type_product_id, snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist[p_cnt].
       product_cd = bbtp.product_cd, snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist[
       p_cnt].default_ind = bbtp.default_ind,
       snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist[p_cnt].beg_effective_dt_tm = bbtp
       .beg_effective_dt_tm, snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist[p_cnt].
       end_effective_dt_tm = bbtp.end_effective_dt_tm, snapshot->outcomelist[o_cnt].bagtypelist[b_cnt
       ].productlist[p_cnt].active_status_dt_tm = bbtp.active_status_dt_tm,
       snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist[p_cnt].active_status_prsnl_id =
       bbtp.active_status_prsnl_id, snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist[p_cnt
       ].updt_applctx = bbtp.updt_applctx, snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].
       productlist[p_cnt].updt_cnt = bbtp.updt_cnt,
       snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist[p_cnt].updt_dt_tm = bbtp
       .updt_dt_tm, snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist[p_cnt].updt_id = bbtp
       .updt_id, snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist[p_cnt].updt_task = bbtp
       .updt_task
      ENDIF
     ENDIF
    DETAIL
     row + 0
    FOOT  bbtp.bag_type_product_id
     IF (bag_reason_path=2)
      IF (product_path=1)
       row + 0
      ENDIF
     ENDIF
    FOOT  bobt.outcome_bag_type_id
     IF (bag_reason_path=2)
      stat = alterlist(snapshot->outcomelist[o_cnt].bagtypelist[b_cnt].productlist,p_cnt)
     ENDIF
    FOOT  bor.outcome_reason_id
     IF (bag_reason_path=1)
      row + 0
     ENDIF
    FOOT  bpo.procedure_outcome_id
     IF (outcome_path=1)
      stat = alterlist(snapshot->outcomelist[o_cnt].reasonlist,r_cnt), stat = alterlist(snapshot->
       outcomelist[o_cnt].bagtypelist,b_cnt)
     ENDIF
    FOOT  bdp.procedure_cd
     stat = alterlist(snapshot->outcomelist,o_cnt)
    WITH nocounter, outerjoin(d1), outerjoin(d2)
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select bbd_donation_procedure",errmsg)
   ENDIF
   IF (curqual=0
    AND (request->procedurelist[p_idx].active_ind=1))
    SET gm_i_bbd_donation8460_req->allow_partial_ind = 0
    SET stat = gm_i_bbd_donation8460_f8("PROCEDURE_ID",request->procedurelist[p_idx].procedure_id,1,0
     )
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("PROCEDURE_CD",request->procedurelist[p_idx].procedure_cd,1,
      0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("DEFERRALS_ALLOWED_CD",request->procedurelist[p_idx].
      deferrals_allowed_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i4("NBR_PER_VOLUME_LEVEL",request->procedurelist[p_idx].
      nbr_per_volume_level,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i2("SCHEDULE_IND",request->procedurelist[p_idx].schedule_ind,1,
      0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i2("START_STOP_IND",request->procedurelist[p_idx].
      start_stop_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
       "31-DEC-2100 23:59:59.99"),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i2("ACTIVE_IND",request->procedurelist[p_idx].active_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("DEFAULT_DONATION_TYPE_CD",request->procedurelist[p_idx].
      default_donation_type_cd,1,0)
    ENDIF
    IF (stat=1)
     SET modify = nopredeclare
     EXECUTE gm_i_bbd_donation8460  WITH replace(request,gm_i_bbd_donation8460_req), replace(reply,
      gm_i_bbd_donation8460_rep)
     SET modify = predeclare
     IF ((gm_i_bbd_donation8460_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_DONATION_PROCEDURE",gm_i_bbd_donation8460_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONATION_PROCEDURE","Insert failed.")
    ENDIF
    SET outcome_cnt = size(request->procedurelist[p_idx].outcomelist,5)
    FOR (o_idx = 1 TO outcome_cnt)
      SET gm_i_bbd_procedur8459_req->allow_partial_ind = 0
      SET stat = gm_i_bbd_procedur8459_f8("PROCEDURE_OUTCOME_ID",request->procedurelist[p_idx].
       outcomelist[o_idx].procedure_outcome_id,1,0)
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("PROCEDURE_ID",request->procedurelist[p_idx].procedure_id,
        1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("OUTCOME_CD",request->procedurelist[p_idx].outcomelist[
        o_idx].outcome_cd,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_i2("COUNT_AS_DONATION_IND",request->procedurelist[p_idx].
        outcomelist[o_idx].count_as_donation_ind,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("SYNONYM_ID",request->procedurelist[p_idx].outcomelist[
        o_idx].synonym_id,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_i2("ADD_PRODUCT_IND",request->procedurelist[p_idx].
        outcomelist[o_idx].add_product_ind,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("QUAR_REASON_CD",request->procedurelist[p_idx].
        outcomelist[o_idx].quar_reason_cd,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
         "31-DEC-2100 23:59:59.99"),1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_i2("ACTIVE_IND",request->procedurelist[p_idx].outcomelist[
        o_idx].active_ind,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
      ENDIF
      IF (stat=1)
       SET modify = nopredeclare
       EXECUTE gm_i_bbd_procedur8459  WITH replace(request,gm_i_bbd_procedur8459_req), replace(reply,
        gm_i_bbd_procedur8459_rep)
       SET modify = predeclare
       IF ((gm_i_bbd_procedur8459_rep->status_data.status="F"))
        CALL errorhandler("F","BBD_PROCEDURE_OUTCOME",gm_i_bbd_procedur8459_rep->qual[1].error_msg)
       ENDIF
      ELSE
       CALL errorhandler("F","BBD_PROCEDURE_OUTCOME","Insert failed.")
      ENDIF
      SET reason_cnt = size(request->procedurelist[p_idx].outcomelist[o_idx].reasonlist,5)
      FOR (r_idx = 1 TO reason_cnt)
        SET gm_i_bbd_outcome_8462_req->allow_partial_ind = 0
        SET stat = gm_i_bbd_outcome_8462_f8("OUTCOME_REASON_ID",request->procedurelist[p_idx].
         outcomelist[o_idx].reasonlist[r_idx].outcome_reason_id,1,0)
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("PROCEDURE_OUTCOME_ID",request->procedurelist[p_idx].
          outcomelist[o_idx].procedure_outcome_id,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("REASON_CD",request->procedurelist[p_idx].outcomelist[
          o_idx].reasonlist[r_idx].reason_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_i4("DAYS_INELIGIBLE",request->procedurelist[p_idx].
          outcomelist[o_idx].reasonlist[r_idx].days_ineligible,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_i4("HOURS_INELIGIBLE",request->procedurelist[p_idx].
          outcomelist[o_idx].reasonlist[r_idx].hours_ineligible,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("DEFERRAL_EXPIRE_CD",request->procedurelist[p_idx].
          outcomelist[o_idx].reasonlist[r_idx].deferral_expire_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
           "31-DEC-2100 23:59:59.99"),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_i2("ACTIVE_IND",request->procedurelist[p_idx].outcomelist[
          o_idx].reasonlist[r_idx].active_ind,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,
          0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
        ENDIF
        IF (stat=1)
         SET modify = nopredeclare
         EXECUTE gm_i_bbd_outcome_8462  WITH replace(request,gm_i_bbd_outcome_8462_req), replace(
          reply,gm_i_bbd_outcome_8462_rep)
         SET modify = predeclare
         IF ((gm_i_bbd_outcome_8462_rep->status_data.status="F"))
          CALL errorhandler("F","BBD_OUTCOME_REASON",gm_i_bbd_outcome_8462_rep->qual[1].error_msg)
         ENDIF
        ELSE
         CALL errorhandler("F","BBD_OUTCOME_REASON","Insert failed.")
        ENDIF
      ENDFOR
      SET bagtype_cnt = size(request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist,5)
      FOR (b_idx = 1 TO bagtype_cnt)
        SET gm_i_bbd_outcome_8461_req->allow_partial_ind = 0
        SET stat = gm_i_bbd_outcome_8461_f8("OUTCOME_BAG_TYPE_ID",request->procedurelist[p_idx].
         outcomelist[o_idx].bagtypelist[b_idx].outcome_bag_type_id,1,0)
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_f8("PROCEDURE_OUTCOME_ID",request->procedurelist[p_idx].
          outcomelist[o_idx].procedure_outcome_id,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_f8("BAG_TYPE_CD",request->procedurelist[p_idx].outcomelist[
          o_idx].bagtypelist[b_idx].bag_type_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_i2("DEFAULT_IND",request->procedurelist[p_idx].outcomelist[
          o_idx].bagtypelist[b_idx].default_ind,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
           "31-DEC-2100 23:59:59.99"),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_i2("ACTIVE_IND",request->procedurelist[p_idx].outcomelist[
          o_idx].bagtypelist[b_idx].active_ind,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,
          0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
        ENDIF
        IF (stat=1)
         SET modify = nopredeclare
         EXECUTE gm_i_bbd_outcome_8461  WITH replace(request,gm_i_bbd_outcome_8461_req), replace(
          reply,gm_i_bbd_outcome_8461_rep)
         SET modify = predeclare
         IF ((gm_i_bbd_outcome_8461_rep->status_data.status="F"))
          CALL errorhandler("F","BBD_OUTCOME_BAG_TYPE",gm_i_bbd_outcome_8461_rep->qual[1].error_msg)
         ENDIF
        ELSE
         CALL errorhandler("F","BBD_OUTCOME_BAG_TYPE","Insert failed.")
        ENDIF
        SET product_cnt = size(request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].
         productlist,5)
        FOR (pr_idx = 1 TO product_cnt)
          SET gm_i_bbd_bag_type8458_req->allow_partial_ind = 0
          SET stat = gm_i_bbd_bag_type8458_f8("BAG_TYPE_PRODUCT_ID",request->procedurelist[p_idx].
           outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].bag_type_product_id,1,0)
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_f8("OUTCOME_BAG_TYPE_ID",request->procedurelist[p_idx].
            outcomelist[o_idx].bagtypelist[b_idx].outcome_bag_type_id,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_f8("PRODUCT_CD",request->procedurelist[p_idx].
            outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].product_cd,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_i2("DEFAULT_IND",request->procedurelist[p_idx].
            outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].default_ind,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
             "31-DEC-2100 23:59:59.99"),1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_i2("ACTIVE_IND",request->procedurelist[p_idx].
            outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].active_ind,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),
            1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
          ENDIF
          IF (stat=1)
           SET modify = nopredeclare
           EXECUTE gm_i_bbd_bag_type8458  WITH replace(request,gm_i_bbd_bag_type8458_req), replace(
            reply,gm_i_bbd_bag_type8458_rep)
           SET modify = predeclare
           IF ((gm_i_bbd_bag_type8458_rep->status_data.status="F"))
            CALL errorhandler("F","BBD_BAG_TYPE_PRODUCT",gm_i_bbd_bag_type8458_rep->qual[1].error_msg
             )
           ENDIF
          ELSE
           CALL errorhandler("F","BBD_BAG_TYPE_PRODUCT","Insert failed.")
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
   ELSEIF (curqual > 0)
    SET gm_u_bbd_donation8460_req->allow_partial_ind = 0
    SET gm_u_bbd_donation8460_req->force_updt_ind = 1
    SET stat = gm_u_bbd_donation8460_f8("PROCEDURE_ID",request->procedurelist[p_idx].procedure_id,1,0,
     1)
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_f8("PROCEDURE_CD",request->procedurelist[p_idx].procedure_cd,1,
      0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_f8("DEFERRALS_ALLOWED_CD",request->procedurelist[p_idx].
      deferrals_allowed_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_i4("NBR_PER_VOLUME_LEVEL",request->procedurelist[p_idx].
      nbr_per_volume_level,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_i2("SCHEDULE_IND",request->procedurelist[p_idx].schedule_ind,1,
      0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_i2("START_STOP_IND",request->procedurelist[p_idx].
      start_stop_ind,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
       "31-DEC-2100 23:59:59.99"),1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_i2("ACTIVE_IND",request->procedurelist[p_idx].active_ind,1,0,0)
    ENDIF
    IF (stat=1)
     IF ((request->procedurelist[p_idx].active_ind=1))
      SET stat = gm_u_bbd_donation8460_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0,0)
     ELSE
      SET stat = gm_u_bbd_donation8460_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation8460_f8("DEFAULT_DONATION_TYPE_CD",request->procedurelist[p_idx].
      default_donation_type_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET modify = nopredeclare
     EXECUTE gm_u_bbd_donation8460  WITH replace(request,gm_u_bbd_donation8460_req), replace(reply,
      gm_u_bbd_donation8460_rep)
     SET modify = predeclare
     IF ((gm_u_bbd_donation8460_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_DONATION_PROCEDURE",gm_u_bbd_donation8460_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONATION_PROCEDURE","Update failed.")
     GO TO exit_script
    ENDIF
    SET outcome_cnt = size(request->procedurelist[p_idx].outcomelist,5)
    SET snap_o_cnt = size(snapshot->outcomelist,5)
    IF ((request->procedurelist[p_idx].active_ind=0))
     SELECT INTO "nl:"
      d2_exists = decode(d2.seq,1,0)
      FROM (dummyt d1  WITH seq = value(snap_o_cnt)),
       (dummyt d2  WITH seq = 1)
      PLAN (d1
       WHERE maxrec(d2,outcome_cnt))
       JOIN (d2
       WHERE (request->procedurelist[p_idx].outcomelist[d2.seq].outcome_cd=snapshot->outcomelist[d1
       .seq].outcome_cd))
      DETAIL
       IF (d2_exists=0)
        outcome_cnt = (outcome_cnt+ 1), stat = alterlist(request->procedurelist[p_idx].outcomelist,
         outcome_cnt), request->procedurelist[p_idx].outcomelist[outcome_cnt].procedure_outcome_id =
        snapshot->outcomelist[d1.seq].procedure_outcome_id,
        request->procedurelist[p_idx].outcomelist[outcome_cnt].outcome_cd = snapshot->outcomelist[d1
        .seq].outcome_cd, request->procedurelist[p_idx].outcomelist[outcome_cnt].
        count_as_donation_ind = snapshot->outcomelist[d1.seq].count_as_donation_ind, request->
        procedurelist[p_idx].outcomelist[outcome_cnt].synonym_id = snapshot->outcomelist[d1.seq].
        synonym_id,
        request->procedurelist[p_idx].outcomelist[outcome_cnt].add_product_ind = snapshot->
        outcomelist[d1.seq].add_product_ind, request->procedurelist[p_idx].outcomelist[outcome_cnt].
        quar_reason_cd = snapshot->outcomelist[d1.seq].quar_reason_cd, request->procedurelist[p_idx].
        outcomelist[outcome_cnt].active_ind = 0
       ENDIF
      WITH nocounter, outerjoin = d1
     ;end select
    ENDIF
    FOR (o_idx = 1 TO outcome_cnt)
      SELECT INTO "nl:"
       FROM bbd_procedure_outcome bpo
       WHERE (bpo.outcome_cd=request->procedurelist[p_idx].outcomelist[o_idx].outcome_cd)
        AND (bpo.procedure_id=request->procedurelist[p_idx].procedure_id)
        AND bpo.active_ind=1
       DETAIL
        request->procedurelist[p_idx].outcomelist[o_idx].procedure_outcome_id = bpo
        .procedure_outcome_id
       WITH nocounter, forupdate(bpo)
      ;end select
      SET error_check = error(errmsg,0)
      IF (error_check != 0)
       CALL errorhandler("F","Select bbd_procedure_outcome",errmsg)
      ENDIF
      IF (curqual=0
       AND (request->procedurelist[p_idx].outcomelist[o_idx].active_ind=1))
       SET gm_i_bbd_procedur8459_req->allow_partial_ind = 0
       SET stat = gm_i_bbd_procedur8459_f8("PROCEDURE_OUTCOME_ID",request->procedurelist[p_idx].
        outcomelist[o_idx].procedure_outcome_id,1,0)
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_f8("PROCEDURE_ID",request->procedurelist[p_idx].procedure_id,
         1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_f8("OUTCOME_CD",request->procedurelist[p_idx].outcomelist[
         o_idx].outcome_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_i2("COUNT_AS_DONATION_IND",request->procedurelist[p_idx].
         outcomelist[o_idx].count_as_donation_ind,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_f8("SYNONYM_ID",request->procedurelist[p_idx].outcomelist[
         o_idx].synonym_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_i2("ADD_PRODUCT_IND",request->procedurelist[p_idx].
         outcomelist[o_idx].add_product_ind,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_f8("QUAR_REASON_CD",request->procedurelist[p_idx].
         outcomelist[o_idx].quar_reason_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
          "31-DEC-2100 23:59:59.99"),1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_i2("ACTIVE_IND",1,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0
         )
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_procedur8459_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
       ENDIF
       IF (stat=1)
        SET modify = nopredeclare
        EXECUTE gm_i_bbd_procedur8459  WITH replace(request,gm_i_bbd_procedur8459_req), replace(reply,
         gm_i_bbd_procedur8459_rep)
        SET modify = predeclare
        IF ((gm_i_bbd_procedur8459_rep->status_data.status="F"))
         CALL errorhandler("F","BBD_PROCEDURE_OUTCOME",gm_i_bbd_procedur8459_rep->qual[1].error_msg)
        ENDIF
       ELSE
        CALL errorhandler("F","BBD_PROCEDURE_OUTCOME","Insert failed.")
       ENDIF
      ELSEIF (curqual > 0)
       SET gm_u_bbd_procedur8459_req->allow_partial_ind = 0
       SET gm_u_bbd_procedur8459_req->force_updt_ind = 1
       SET stat = gm_u_bbd_procedur8459_f8("PROCEDURE_OUTCOME_ID",request->procedurelist[p_idx].
        outcomelist[o_idx].procedure_outcome_id,1,0,1)
       IF (stat=1)
        SET stat = gm_u_bbd_procedur8459_f8("OUTCOME_CD",request->procedurelist[p_idx].outcomelist[
         o_idx].outcome_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_procedur8459_i2("COUNT_AS_DONATION_IND",request->procedurelist[p_idx].
         outcomelist[o_idx].count_as_donation_ind,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_procedur8459_f8("SYNONYM_ID",request->procedurelist[p_idx].outcomelist[
         o_idx].synonym_id,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_procedur8459_i2("ADD_PRODUCT_IND",request->procedurelist[p_idx].
         outcomelist[o_idx].add_product_ind,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_procedur8459_f8("QUAR_REASON_CD",request->procedurelist[p_idx].
         outcomelist[o_idx].quar_reason_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_procedur8459_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_procedur8459_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
          "31-DEC-2100 23:59:59.99"),1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_procedur8459_i2("ACTIVE_IND",request->procedurelist[p_idx].outcomelist[
         o_idx].active_ind,1,0,0)
       ENDIF
       IF (stat=1)
        IF ((request->procedurelist[p_idx].outcomelist[o_idx].active_ind=1))
         SET stat = gm_u_bbd_procedur8459_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0,0)
        ELSE
         SET stat = gm_u_bbd_procedur8459_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
        ENDIF
       ENDIF
       IF (stat=1)
        SET modify = nopredeclare
        EXECUTE gm_u_bbd_procedur8459  WITH replace(request,gm_u_bbd_procedur8459_req), replace(reply,
         gm_u_bbd_procedur8459_rep)
        SET modify = predeclare
        IF ((gm_u_bbd_procedur8459_rep->status_data.status="F"))
         CALL errorhandler("F","BBD_PROCEDURE_OUTCOME",gm_u_bbd_procedur8459_rep->qual[1].error_msg)
        ENDIF
       ELSE
        CALL errorhandler("F","BBD_PROCEDURE_OUTCOME","Update failed.")
        GO TO exit_script
       ENDIF
      ENDIF
      SET reason_cnt = size(request->procedurelist[p_idx].outcomelist[o_idx].reasonlist,5)
      SET snap_o_idx = locateval(locate_idx,1,snap_o_cnt,request->procedurelist[p_idx].outcomelist[
       o_idx].outcome_cd,snapshot->outcomelist[locate_idx].outcome_cd)
      SET snap_r_cnt = size(snapshot->outcomelist[snap_o_idx].reasonlist,5)
      IF ((request->procedurelist[p_idx].outcomelist[o_idx].active_ind=0)
       AND snap_r_cnt > 0)
       SELECT INTO "nl:"
        d2_exists = decode(d2.seq,1,0)
        FROM (dummyt d1  WITH seq = value(snap_r_cnt)),
         (dummyt d2  WITH seq = 1)
        PLAN (d1
         WHERE maxrec(d2,reason_cnt))
         JOIN (d2
         WHERE (request->procedurelist[p_idx].outcomelist[o_idx].reasonlist[d2.seq].reason_cd=
         snapshot->outcomelist[snap_o_idx].reasonlist[d1.seq].reason_cd))
        DETAIL
         IF (d2_exists=0)
          reason_cnt = (reason_cnt+ 1), stat = alterlist(request->procedurelist[p_idx].outcomelist[
           o_idx].reasonlist,reason_cnt), request->procedurelist[p_idx].outcomelist[o_idx].
          reasonlist[reason_cnt].outcome_reason_id = snapshot->outcomelist[snap_o_idx].reasonlist[d1
          .seq].outcome_reason_id,
          request->procedurelist[p_idx].outcomelist[o_idx].reasonlist[reason_cnt].reason_cd =
          snapshot->outcomelist[snap_o_idx].reasonlist[d1.seq].reason_cd, request->procedurelist[
          p_idx].outcomelist[o_idx].reasonlist[reason_cnt].days_ineligible = snapshot->outcomelist[
          snap_o_idx].reasonlist[d1.seq].days_ineligible, request->procedurelist[p_idx].outcomelist[
          o_idx].reasonlist[reason_cnt].hours_ineligible = snapshot->outcomelist[snap_o_idx].
          reasonlist[d1.seq].hours_ineligible,
          request->procedurelist[p_idx].outcomelist[o_idx].reasonlist[reason_cnt].deferral_expire_cd
           = snapshot->outcomelist[snap_o_idx].reasonlist[d1.seq].deferral_expire_cd, request->
          procedurelist[p_idx].outcomelist[o_idx].reasonlist[reason_cnt].active_ind = 0
         ENDIF
        WITH nocounter, outerjoin = d1
       ;end select
      ENDIF
      FOR (r_idx = 1 TO reason_cnt)
        SELECT INTO "nl:"
         FROM bbd_outcome_reason bor
         WHERE (bor.reason_cd=request->procedurelist[p_idx].outcomelist[o_idx].reasonlist[r_idx].
         reason_cd)
          AND (bor.procedure_outcome_id=request->procedurelist[p_idx].outcomelist[o_idx].
         procedure_outcome_id)
          AND bor.active_ind=1
         DETAIL
          request->procedurelist[p_idx].outcomelist[o_idx].reasonlist[r_idx].outcome_reason_id = bor
          .outcome_reason_id
         WITH nocounter, forupdate(bor)
        ;end select
        SET error_check = error(errmsg,0)
        IF (error_check != 0)
         CALL errorhandler("F","Select bbd_outcome_reason",errmsg)
        ENDIF
        IF (curqual=0
         AND (request->procedurelist[p_idx].outcomelist[o_idx].reasonlist[r_idx].active_ind > 0))
         SET gm_u_bbd_procedur8459_req->allow_partial_ind = 0
         SET gm_u_bbd_procedur8459_req->force_updt_ind = 1
         SET stat = gm_i_bbd_outcome_8462_f8("OUTCOME_REASON_ID",request->procedurelist[p_idx].
          outcomelist[o_idx].reasonlist[r_idx].outcome_reason_id,1,0)
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_f8("PROCEDURE_OUTCOME_ID",request->procedurelist[p_idx].
           outcomelist[o_idx].procedure_outcome_id,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_f8("REASON_CD",request->procedurelist[p_idx].outcomelist[
           o_idx].reasonlist[r_idx].reason_cd,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_i4("DAYS_INELIGIBLE",request->procedurelist[p_idx].
           outcomelist[o_idx].reasonlist[r_idx].days_ineligible,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_i4("HOURS_INELIGIBLE",request->procedurelist[p_idx].
           outcomelist[o_idx].reasonlist[r_idx].hours_ineligible,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_f8("DEFERRAL_EXPIRE_CD",request->procedurelist[p_idx].
           outcomelist[o_idx].reasonlist[r_idx].deferral_expire_cd,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
            "31-DEC-2100 23:59:59.99"),1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_i2("ACTIVE_IND",1,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,
           0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8462_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
         ENDIF
         IF (stat=1)
          SET modify = nopredeclare
          EXECUTE gm_i_bbd_outcome_8462  WITH replace(request,gm_i_bbd_outcome_8462_req), replace(
           reply,gm_i_bbd_outcome_8462_rep)
          SET modify = predeclare
          IF ((gm_i_bbd_outcome_8462_rep->status_data.status="F"))
           CALL errorhandler("F","BBD_OUTCOME_REASON",gm_i_bbd_outcome_8462_rep->qual[1].error_msg)
          ENDIF
         ELSE
          CALL errorhandler("F","BBD_OUTCOME_REASON","Insert failed.")
         ENDIF
        ELSEIF (curqual > 0)
         SET gm_u_bbd_outcome_8462_req->allow_partial_ind = 0
         SET gm_u_bbd_outcome_8462_req->force_updt_ind = 1
         SET stat = gm_u_bbd_outcome_8462_f8("OUTCOME_REASON_ID",request->procedurelist[p_idx].
          outcomelist[o_idx].reasonlist[r_idx].outcome_reason_id,1,0,1)
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8462_f8("PROCEDURE_OUTCOME_ID",request->procedurelist[p_idx].
           outcomelist[o_idx].procedure_outcome_id,1,0,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8462_f8("REASON_CD",request->procedurelist[p_idx].outcomelist[
           o_idx].reasonlist[r_idx].reason_cd,1,0,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8462_i4("DAYS_INELIGIBLE",request->procedurelist[p_idx].
           outcomelist[o_idx].reasonlist[r_idx].days_ineligible,1,0,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8462_i4("HOURS_INELIGIBLE",request->procedurelist[p_idx].
           outcomelist[o_idx].reasonlist[r_idx].hours_ineligible,1,0,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8462_f8("DEFERRAL_EXPIRE_CD",request->procedurelist[p_idx].
           outcomelist[o_idx].reasonlist[r_idx].deferral_expire_cd,1,0,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8462_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0,0
           )
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8462_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
            "31-DEC-2100 23:59:59.99"),1,0,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8462_i2("ACTIVE_IND",request->procedurelist[p_idx].outcomelist[
           o_idx].reasonlist[r_idx].active_ind,1,0,0)
         ENDIF
         IF (stat=1)
          IF ((request->procedurelist[p_idx].outcomelist[o_idx].reasonlist[r_idx].active_ind=1))
           SET stat = gm_u_bbd_outcome_8462_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0,0)
          ELSE
           SET stat = gm_u_bbd_outcome_8462_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
          ENDIF
         ENDIF
         IF (stat=1)
          SET modify = nopredeclare
          EXECUTE gm_u_bbd_outcome_8462  WITH replace(request,gm_u_bbd_outcome_8462_req), replace(
           reply,gm_u_bbd_outcome_8462_rep)
          SET modify = predeclare
          IF ((gm_u_bbd_outcome_8462_rep->status_data.status="F"))
           CALL errorhandler("F","BBD_OUTCOME_REASON",gm_u_bbd_outcome_8462_rep->qual[1].error_msg)
          ENDIF
         ELSE
          CALL errorhandler("F","BBD_OUTCOME_REASON","Update failed.")
          GO TO exit_script
         ENDIF
        ENDIF
      ENDFOR
      SET bagtype_cnt = size(request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist,5)
      SET snap_b_cnt = size(snapshot->outcomelist[snap_o_idx].bagtypelist,5)
      IF ((request->procedurelist[p_idx].outcomelist[o_idx].active_ind=0)
       AND snap_b_cnt > 0)
       SELECT INTO "nl:"
        d2_exists = decode(d2.seq,1,0)
        FROM (dummyt d1  WITH seq = value(snap_b_cnt)),
         (dummyt d2  WITH seq = 1)
        PLAN (d1
         WHERE maxrec(d2,bagtype_cnt))
         JOIN (d2
         WHERE (request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[d2.seq].bag_type_cd=
         snapshot->outcomelist[snap_o_idx].bagtypelist[d1.seq].bag_type_cd))
        DETAIL
         IF (d2_exists=0)
          bagtype_cnt = (bagtype_cnt+ 1), stat = alterlist(request->procedurelist[p_idx].outcomelist[
           o_idx].bagtypelist,bagtype_cnt), request->procedurelist[p_idx].outcomelist[o_idx].
          bagtypelist[bagtype_cnt].outcome_bag_type_id = snapshot->outcomelist[snap_o_idx].
          bagtypelist[d1.seq].outcome_bag_type_id,
          request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[bagtype_cnt].bag_type_cd =
          snapshot->outcomelist[snap_o_idx].bagtypelist[d1.seq].bag_type_cd, request->procedurelist[
          p_idx].outcomelist[o_idx].bagtypelist[bagtype_cnt].default_ind = snapshot->outcomelist[
          snap_o_idx].bagtypelist[d1.seq].default_ind, request->procedurelist[p_idx].outcomelist[
          o_idx].bagtypelist[bagtype_cnt].active_ind = 0
         ENDIF
        WITH nocounter, outerjoin = d1
       ;end select
      ENDIF
      IF (snap_b_cnt > 0)
       SELECT INTO "nl:"
        FROM (dummyt d1  WITH seq = value(snap_b_cnt)),
         (dummyt d2  WITH seq = 1)
        PLAN (d1
         WHERE maxrec(d2,bagtype_cnt)
          AND (snapshot->outcomelist[snap_o_idx].bagtypelist[d1.seq].default_ind=1))
         JOIN (d2
         WHERE (request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[d2.seq].default_ind=1))
        DETAIL
         IF ((snapshot->outcomelist[snap_o_idx].bagtypelist[d1.seq].bag_type_cd != request->
         procedurelist[p_idx].outcomelist[o_idx].bagtypelist[d2.seq].bag_type_cd))
          bagtype_cnt = (bagtype_cnt+ 1), stat = alterlist(request->procedurelist[p_idx].outcomelist[
           o_idx].bagtypelist,bagtype_cnt), request->procedurelist[p_idx].outcomelist[o_idx].
          bagtypelist[bagtype_cnt].outcome_bag_type_id = snapshot->outcomelist[snap_o_idx].
          bagtypelist[d1.seq].outcome_bag_type_id,
          request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[bagtype_cnt].bag_type_cd =
          snapshot->outcomelist[snap_o_idx].bagtypelist[d1.seq].bag_type_cd, request->procedurelist[
          p_idx].outcomelist[o_idx].bagtypelist[bagtype_cnt].default_ind = 0, request->procedurelist[
          p_idx].outcomelist[o_idx].bagtypelist[bagtype_cnt].active_ind = request->procedurelist[
          p_idx].active_ind
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
      FOR (b_idx = 1 TO bagtype_cnt)
        SELECT INTO "nl:"
         FROM bbd_outcome_bag_type bob
         WHERE (bob.bag_type_cd=request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].
         bag_type_cd)
          AND (bob.procedure_outcome_id=request->procedurelist[p_idx].outcomelist[o_idx].
         procedure_outcome_id)
          AND bob.active_ind=1
         DETAIL
          request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].outcome_bag_type_id =
          bob.outcome_bag_type_id
         WITH nocounter, forupdate(bob)
        ;end select
        SET error_check = error(errmsg,0)
        IF (error_check != 0)
         CALL errorhandler("F","Select bbd_outcome_bag_type",errmsg)
        ENDIF
        IF (curqual=0
         AND (request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].active_ind=1))
         SET gm_i_bbd_outcome_8461_req->allow_partial_ind = 0
         SET stat = gm_i_bbd_outcome_8461_f8("OUTCOME_BAG_TYPE_ID",request->procedurelist[p_idx].
          outcomelist[o_idx].bagtypelist[b_idx].outcome_bag_type_id,1,0)
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8461_f8("PROCEDURE_OUTCOME_ID",request->procedurelist[p_idx].
           outcomelist[o_idx].procedure_outcome_id,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8461_f8("BAG_TYPE_CD",request->procedurelist[p_idx].
           outcomelist[o_idx].bagtypelist[b_idx].bag_type_cd,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8461_i2("DEFAULT_IND",request->procedurelist[p_idx].
           outcomelist[o_idx].bagtypelist[b_idx].default_ind,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8461_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8461_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
            "31-DEC-2100 23:59:59.99"),1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8461_i2("ACTIVE_IND",1,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8461_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8461_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,
           0)
         ENDIF
         IF (stat=1)
          SET stat = gm_i_bbd_outcome_8461_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
         ENDIF
         IF (stat=1)
          SET modify = nopredeclare
          EXECUTE gm_i_bbd_outcome_8461  WITH replace(request,gm_i_bbd_outcome_8461_req), replace(
           reply,gm_i_bbd_outcome_8461_rep)
          SET modify = predeclare
          IF ((gm_i_bbd_outcome_8461_rep->status_data.status="F"))
           CALL errorhandler("F","BBD_OUTCOME_BAG_TYPE",gm_i_bbd_outcome_8461_rep->qual[1].error_msg)
          ENDIF
         ELSE
          CALL errorhandler("F","BBD_OUTCOME_BAG_TYPE","Insert failed.")
         ENDIF
        ELSEIF (curqual > 0)
         SET gm_u_bbd_outcome_8461_req->allow_partial_ind = 0
         SET gm_u_bbd_outcome_8461_req->force_updt_ind = 1
         SET stat = gm_u_bbd_outcome_8461_f8("OUTCOME_BAG_TYPE_ID",request->procedurelist[p_idx].
          outcomelist[o_idx].bagtypelist[b_idx].outcome_bag_type_id,1,0,1)
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8461_f8("PROCEDURE_OUTCOME_ID",request->procedurelist[p_idx].
           outcomelist[o_idx].procedure_outcome_id,1,0,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8461_f8("BAG_TYPE_CD",request->procedurelist[p_idx].
           outcomelist[o_idx].bagtypelist[b_idx].bag_type_cd,1,0,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8461_i2("DEFAULT_IND",request->procedurelist[p_idx].
           outcomelist[o_idx].bagtypelist[b_idx].default_ind,1,0,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8461_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0,0
           )
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8461_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
            "31-DEC-2100 23:59:59.99"),1,0,0)
         ENDIF
         IF (stat=1)
          SET stat = gm_u_bbd_outcome_8461_i2("ACTIVE_IND",request->procedurelist[p_idx].outcomelist[
           o_idx].bagtypelist[b_idx].active_ind,1,0,0)
         ENDIF
         IF (stat=1)
          IF ((request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].active_ind=1))
           SET stat = gm_u_bbd_outcome_8461_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0,0)
          ELSE
           SET stat = gm_u_bbd_outcome_8461_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
          ENDIF
         ENDIF
         IF (stat=1)
          SET modify = nopredeclare
          EXECUTE gm_u_bbd_outcome_8461  WITH replace(request,gm_u_bbd_outcome_8461_req), replace(
           reply,gm_u_bbd_outcome_8461_rep)
          SET modify = predeclare
          IF ((gm_u_bbd_outcome_8461_rep->status_data.status="F"))
           CALL errorhandler("F","BBD_OUTCOME_BAG_TYPE",gm_u_bbd_outcome_8461_rep->qual[1].error_msg)
          ENDIF
         ELSE
          CALL errorhandler("F","BBD_OUTCOME_BAG_TYPE","Update failed.")
          GO TO exit_script
         ENDIF
        ENDIF
        SET product_cnt = size(request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].
         productlist,5)
        SET snap_b_idx = locateval(locate_idx,1,snap_b_cnt,request->procedurelist[p_idx].outcomelist[
         o_idx].bagtypelist[b_idx].bag_type_cd,snapshot->outcomelist[snap_o_idx].bagtypelist[
         locate_idx].bag_type_cd)
        SET snap_p_cnt = size(snapshot->outcomelist[snap_o_idx].bagtypelist[snap_b_idx].productlist,5
         )
        IF ((request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].active_ind=0)
         AND snap_p_cnt > 0)
         SELECT INTO "nl:"
          d2_exists = decode(d2.seq,1,0)
          FROM (dummyt d1  WITH seq = value(snap_p_cnt)),
           (dummyt d2  WITH seq = 1)
          PLAN (d1
           WHERE maxrec(d2,product_cnt))
           JOIN (d2
           WHERE (request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].productlist[d2
           .seq].product_cd=snapshot->outcomelist[snap_o_idx].bagtypelist[snap_b_idx].productlist[d1
           .seq].product_cd))
          DETAIL
           IF (d2_exists=0)
            product_cnt = (product_cnt+ 1), stat = alterlist(request->procedurelist[p_idx].
             outcomelist[o_idx].bagtypelist[b_idx].productlist,product_cnt), request->procedurelist[
            p_idx].outcomelist[o_idx].bagtypelist[b_idx].productlist[product_cnt].bag_type_product_id
             = snapshot->outcomelist[snap_o_idx].bagtypelist[snap_b_idx].productlist[d1.seq].
            bag_type_product_id,
            request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].productlist[
            product_cnt].product_cd = snapshot->outcomelist[snap_o_idx].bagtypelist[snap_b_idx].
            productlist[d1.seq].product_cd, request->procedurelist[p_idx].outcomelist[o_idx].
            bagtypelist[b_idx].productlist[product_cnt].default_ind = snapshot->outcomelist[
            snap_o_idx].bagtypelist[snap_b_idx].productlist[d1.seq].default_ind, request->
            procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].productlist[product_cnt].
            active_ind = 0
           ENDIF
          WITH nocounter, outerjoin = d1
         ;end select
        ENDIF
        IF (snap_p_cnt > 0)
         SELECT INTO "nl:"
          FROM (dummyt d1  WITH seq = value(snap_p_cnt)),
           (dummyt d2  WITH seq = 1)
          PLAN (d1
           WHERE maxrec(d2,product_cnt)
            AND (snapshot->outcomelist[snap_o_idx].bagtypelist[snap_b_idx].productlist[d1.seq].
           default_ind=1))
           JOIN (d2
           WHERE (request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].productlist[d2
           .seq].default_ind=1))
          DETAIL
           IF ((snapshot->outcomelist[snap_o_idx].bagtypelist[snap_b_idx].productlist[d1.seq].
           product_cd != request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].
           productlist[d2.seq].product_cd))
            product_cnt = (product_cnt+ 1), stat = alterlist(request->procedurelist[p_idx].
             outcomelist[o_idx].bagtypelist[b_idx].productlist,product_cnt), request->procedurelist[
            p_idx].outcomelist[o_idx].bagtypelist[b_idx].productlist[product_cnt].bag_type_product_id
             = snapshot->outcomelist[snap_o_idx].bagtypelist[snap_b_idx].productlist[d1.seq].
            bag_type_product_id,
            request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].productlist[
            product_cnt].product_cd = snapshot->outcomelist[snap_o_idx].bagtypelist[snap_b_idx].
            productlist[d1.seq].product_cd, request->procedurelist[p_idx].outcomelist[o_idx].
            bagtypelist[b_idx].productlist[product_cnt].default_ind = 0, request->procedurelist[p_idx
            ].outcomelist[o_idx].bagtypelist[b_idx].productlist[product_cnt].active_ind = request->
            procedurelist[p_idx].active_ind
           ENDIF
          WITH nocounter
         ;end select
        ENDIF
        FOR (pr_idx = 1 TO product_cnt)
          SELECT INTO "nl:"
           FROM bbd_bag_type_product btp
           WHERE (btp.product_cd=request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].
           productlist[pr_idx].product_cd)
            AND (btp.outcome_bag_type_id=request->procedurelist[p_idx].outcomelist[o_idx].
           bagtypelist[b_idx].outcome_bag_type_id)
            AND btp.active_ind=1
           DETAIL
            request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].
            bag_type_product_id = btp.bag_type_product_id
           WITH nocounter, forupdate(btp)
          ;end select
          SET error_check = error(errmsg,0)
          IF (error_check != 0)
           CALL errorhandler("F","Select bbd_bag_type_product",errmsg)
          ENDIF
          IF (curqual=0
           AND (request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].productlist[
          pr_idx].active_ind=1))
           SET gm_i_bbd_bag_type8458_req->allow_partial_ind = 0
           SET stat = gm_i_bbd_bag_type8458_f8("BAG_TYPE_PRODUCT_ID",request->procedurelist[p_idx].
            outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].bag_type_product_id,1,0)
           IF (stat=1)
            SET stat = gm_i_bbd_bag_type8458_f8("OUTCOME_BAG_TYPE_ID",request->procedurelist[p_idx].
             outcomelist[o_idx].bagtypelist[b_idx].outcome_bag_type_id,1,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_i_bbd_bag_type8458_f8("PRODUCT_CD",request->procedurelist[p_idx].
             outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].product_cd,1,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_i_bbd_bag_type8458_i2("DEFAULT_IND",request->procedurelist[p_idx].
             outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].default_ind,1,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_i_bbd_bag_type8458_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0
             )
           ENDIF
           IF (stat=1)
            SET stat = gm_i_bbd_bag_type8458_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
              "31-DEC-2100 23:59:59.99"),1,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_i_bbd_bag_type8458_i2("ACTIVE_IND",1,1,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_i_bbd_bag_type8458_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_i_bbd_bag_type8458_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),
             1,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_i_bbd_bag_type8458_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
           ENDIF
           IF (stat=1)
            SET modify = nopredeclare
            EXECUTE gm_i_bbd_bag_type8458  WITH replace(request,gm_i_bbd_bag_type8458_req), replace(
             reply,gm_i_bbd_bag_type8458_rep)
            SET modify = predeclare
            IF ((gm_i_bbd_bag_type8458_rep->status_data.status="F"))
             CALL errorhandler("F","BBD_BAG_TYPE_PRODUCT",gm_i_bbd_bag_type8458_rep->qual[1].
              error_msg)
            ENDIF
           ELSE
            CALL errorhandler("F","BBD_BAG_TYPE_PRODUCT","Insert failed.")
           ENDIF
          ELSEIF (curqual > 0)
           SET gm_u_bbd_bag_type8458_req->allow_partial_ind = 0
           SET gm_u_bbd_bag_type8458_req->force_updt_ind = 1
           SET stat = gm_u_bbd_bag_type8458_f8("BAG_TYPE_PRODUCT_ID",request->procedurelist[p_idx].
            outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].bag_type_product_id,1,0,1)
           IF (stat=1)
            SET stat = gm_u_bbd_bag_type8458_f8("OUTCOME_BAG_TYPE_ID",request->procedurelist[p_idx].
             outcomelist[o_idx].bagtypelist[b_idx].outcome_bag_type_id,1,0,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_u_bbd_bag_type8458_f8("PRODUCT_CD",request->procedurelist[p_idx].
             outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].product_cd,1,0,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_u_bbd_bag_type8458_i2("DEFAULT_IND",request->procedurelist[p_idx].
             outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].default_ind,1,0,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_u_bbd_bag_type8458_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0,
             0)
           ENDIF
           IF (stat=1)
            SET stat = gm_u_bbd_bag_type8458_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
              "31-DEC-2100 23:59:59.99"),1,0,0)
           ENDIF
           IF (stat=1)
            SET stat = gm_u_bbd_bag_type8458_i2("ACTIVE_IND",request->procedurelist[p_idx].
             outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].active_ind,1,0,0)
           ENDIF
           IF (stat=1)
            IF ((request->procedurelist[p_idx].outcomelist[o_idx].bagtypelist[b_idx].productlist[
            pr_idx].active_ind=1))
             SET stat = gm_u_bbd_bag_type8458_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0,0)
            ELSE
             SET stat = gm_u_bbd_bag_type8458_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0
              )
            ENDIF
           ENDIF
           IF (stat=1)
            SET modify = nopredeclare
            EXECUTE gm_u_bbd_bag_type8458  WITH replace(request,gm_u_bbd_bag_type8458_req), replace(
             reply,gm_u_bbd_bag_type8458_rep)
            SET modify = predeclare
            IF ((gm_u_bbd_bag_type8458_rep->status_data.status="F"))
             CALL errorhandler("F","BBD_BAG_TYPE_PRODUCT",gm_u_bbd_bag_type8458_rep->qual[1].
              error_msg)
            ENDIF
           ELSE
            CALL errorhandler("F","BBD_BAG_TYPE_PRODUCT","Update failed.")
            GO TO exit_script
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
    SET snapshot->procedure_id = getsequence(0)
    SET gm_i_bbd_donation8460_req->allow_partial_ind = 0
    SET stat = gm_i_bbd_donation8460_f8("PROCEDURE_ID",snapshot->procedure_id,1,0)
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("PROCEDURE_CD",snapshot->procedure_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("DEFERRALS_ALLOWED_CD",snapshot->deferrals_allowed_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i4("NBR_PER_VOLUME_LEVEL",snapshot->nbr_per_volume_level,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i2("SCHEDULE_IND",snapshot->schedule_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i2("START_STOP_IND",snapshot->start_stop_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(snapshot->
       beg_effective_dt_tm),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i2("ACTIVE_IND",0,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(snapshot->
       active_status_dt_tm),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("ACTIVE_STATUS_PRSNL_ID",snapshot->active_status_prsnl_id,1,
      0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i4("UPDT_APPLCTX",snapshot->updt_applctx,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i4("UPDT_TASK",snapshot->updt_task,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_dq8("UPDT_DT_TM",cnvtdatetime(snapshot->updt_dt_tm),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("UPDT_ID",snapshot->updt_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_i4("UPDT_CNT",snapshot->updt_cnt,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation8460_f8("DEFAULT_DONATION_TYPE_CD",snapshot->
      default_donation_type_cd,1,0)
    ENDIF
    IF (stat=1)
     SET modify = nopredeclare
     EXECUTE gm_i_bbd_donation8460  WITH replace(request,gm_i_bbd_donation8460_req), replace(reply,
      gm_i_bbd_donation8460_rep)
     SET modify = predeclare
     IF ((gm_i_bbd_donation8460_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_DONATION_PROCEDURE",gm_i_bbd_donation8460_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONATION_PROCEDURE","Insert failed.")
    ENDIF
    SET outcome_cnt = size(snapshot->outcomelist,5)
    FOR (o_idx = 1 TO outcome_cnt)
      SET snapshot->outcomelist[o_idx].procedure_outcome_id = getsequence(0)
      SET gm_i_bbd_procedur8459_req->allow_partial_ind = 0
      SET stat = gm_i_bbd_procedur8459_f8("PROCEDURE_OUTCOME_ID",snapshot->outcomelist[o_idx].
       procedure_outcome_id,1,0)
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("PROCEDURE_ID",snapshot->procedure_id,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("OUTCOME_CD",snapshot->outcomelist[o_idx].outcome_cd,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_i2("COUNT_AS_DONATION_IND",snapshot->outcomelist[o_idx].
        count_as_donation_ind,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("SYNONYM_ID",snapshot->outcomelist[o_idx].synonym_id,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_i2("ADD_PRODUCT_IND",snapshot->outcomelist[o_idx].
        add_product_ind,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("QUAR_REASON_CD",snapshot->outcomelist[o_idx].
        quar_reason_cd,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(snapshot->outcomelist[
         o_idx].beg_effective_dt_tm),1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_i2("ACTIVE_IND",0,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(snapshot->outcomelist[
         o_idx].active_status_dt_tm),1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("ACTIVE_STATUS_PRSNL_ID",snapshot->outcomelist[o_idx].
        active_status_prsnl_id,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_i4("UPDT_APPLCTX",snapshot->outcomelist[o_idx].updt_applctx,1,
        0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_i4("UPDT_TASK",snapshot->outcomelist[o_idx].updt_task,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_dq8("UPDT_DT_TM",cnvtdatetime(snapshot->outcomelist[o_idx].
         updt_dt_tm),1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_f8("UPDT_ID",snapshot->outcomelist[o_idx].updt_id,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_procedur8459_i4("UPDT_CNT",snapshot->outcomelist[o_idx].updt_cnt,1,0)
      ENDIF
      IF (stat=1)
       SET modify = nopredeclare
       EXECUTE gm_i_bbd_procedur8459  WITH replace(request,gm_i_bbd_procedur8459_req), replace(reply,
        gm_i_bbd_procedur8459_rep)
       SET modify = predeclare
       IF ((gm_i_bbd_procedur8459_rep->status_data.status="F"))
        CALL errorhandler("F","BBD_PROCEDURE_OUTCOME",gm_i_bbd_procedur8459_rep->qual[1].error_msg)
       ENDIF
      ELSE
       CALL errorhandler("F","BBD_PROCEDURE_OUTCOME","Insert failed.")
      ENDIF
      SET reason_cnt = size(snapshot->outcomelist[o_idx].reasonlist,5)
      FOR (r_idx = 1 TO reason_cnt)
        SET snapshot->outcomelist[o_idx].reasonlist[r_idx].outcome_reason_id = getsequence(0)
        SET gm_i_bbd_outcome_8462_req->allow_partial_ind = 0
        SET stat = gm_i_bbd_outcome_8462_f8("OUTCOME_REASON_ID",snapshot->outcomelist[o_idx].
         reasonlist[r_idx].outcome_reason_id,1,0)
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("PROCEDURE_OUTCOME_ID",snapshot->outcomelist[o_idx].
          procedure_outcome_id,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("REASON_CD",snapshot->outcomelist[o_idx].reasonlist[
          r_idx].reason_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_i4("DAYS_INELIGIBLE",snapshot->outcomelist[o_idx].
          reasonlist[r_idx].days_ineligible,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_i4("HOURS_INELIGIBLE",snapshot->outcomelist[o_idx].
          reasonlist[r_idx].hours_ineligible,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("DEFERRAL_EXPIRE_CD",snapshot->outcomelist[o_idx].
          reasonlist[r_idx].deferral_expire_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(snapshot->
           outcomelist[o_idx].reasonlist[r_idx].beg_effective_dt_tm),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_i2("ACTIVE_IND",0,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(snapshot->
           outcomelist[o_idx].reasonlist[r_idx].active_status_dt_tm),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("ACTIVE_STATUS_PRSNL_ID",snapshot->outcomelist[o_idx].
          reasonlist[r_idx].active_status_prsnl_id,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_i4("UPDT_APPLCTX",snapshot->outcomelist[o_idx].reasonlist[
          r_idx].updt_applctx,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_i4("UPDT_TASK",snapshot->outcomelist[o_idx].reasonlist[
          r_idx].updt_task,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_dq8("UPDT_DT_TM",cnvtdatetime(snapshot->outcomelist[o_idx].
           reasonlist[r_idx].updt_dt_tm),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_f8("UPDT_ID",snapshot->outcomelist[o_idx].reasonlist[r_idx]
          .updt_id,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8462_i4("UPDT_CNT",snapshot->outcomelist[o_idx].reasonlist[r_idx
          ].updt_cnt,1,0)
        ENDIF
        IF (stat=1)
         SET modify = nopredeclare
         EXECUTE gm_i_bbd_outcome_8462  WITH replace(request,gm_i_bbd_outcome_8462_req), replace(
          reply,gm_i_bbd_outcome_8462_rep)
         SET modify = predeclare
         IF ((gm_i_bbd_outcome_8462_rep->status_data.status="F"))
          CALL errorhandler("F","BBD_OUTCOME_REASON",gm_i_bbd_outcome_8462_rep->qual[1].error_msg)
         ENDIF
        ELSE
         CALL errorhandler("F","BBD_OUTCOME_REASON","Insert failed.")
        ENDIF
      ENDFOR
      SET bagtype_cnt = size(snapshot->outcomelist[o_idx].bagtypelist,5)
      FOR (b_idx = 1 TO bagtype_cnt)
        SET snapshot->outcomelist[o_idx].bagtypelist[b_idx].outcome_bag_type_id = getsequence(0)
        SET gm_i_bbd_outcome_8461_req->allow_partial_ind = 0
        SET stat = gm_i_bbd_outcome_8461_f8("OUTCOME_BAG_TYPE_ID",snapshot->outcomelist[o_idx].
         bagtypelist[b_idx].outcome_bag_type_id,1,0)
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_f8("PROCEDURE_OUTCOME_ID",snapshot->outcomelist[o_idx].
          procedure_outcome_id,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_f8("BAG_TYPE_CD",snapshot->outcomelist[o_idx].bagtypelist[
          b_idx].bag_type_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_i2("DEFAULT_IND",snapshot->outcomelist[o_idx].bagtypelist[
          b_idx].default_ind,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(snapshot->
           outcomelist[o_idx].bagtypelist[b_idx].beg_effective_dt_tm),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_i2("ACTIVE_IND",0,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(snapshot->
           outcomelist[o_idx].bagtypelist[b_idx].active_status_dt_tm),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_f8("ACTIVE_STATUS_PRSNL_ID",snapshot->outcomelist[o_idx].
          bagtypelist[b_idx].active_status_prsnl_id,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_i4("UPDT_APPLCTX",snapshot->outcomelist[o_idx].bagtypelist[
          b_idx].updt_applctx,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_i4("UPDT_TASK",snapshot->outcomelist[o_idx].bagtypelist[
          b_idx].updt_task,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_dq8("UPDT_DT_TM",cnvtdatetime(snapshot->outcomelist[o_idx].
           bagtypelist[b_idx].updt_dt_tm),1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_f8("UPDT_ID",snapshot->outcomelist[o_idx].bagtypelist[b_idx
          ].updt_id,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_outcome_8461_i4("UPDT_CNT",snapshot->outcomelist[o_idx].bagtypelist[
          b_idx].updt_cnt,1,0)
        ENDIF
        IF (stat=1)
         SET modify = nopredeclare
         EXECUTE gm_i_bbd_outcome_8461  WITH replace(request,gm_i_bbd_outcome_8461_req), replace(
          reply,gm_i_bbd_outcome_8461_rep)
         SET modify = predeclare
         IF ((gm_i_bbd_outcome_8461_rep->status_data.status="F"))
          CALL errorhandler("F","BBD_OUTCOME_BAG_TYPE",gm_i_bbd_outcome_8461_rep->qual[1].error_msg)
         ENDIF
        ELSE
         CALL errorhandler("F","BBD_OUTCOME_BAG_TYPE","Insert failed.")
        ENDIF
        SET product_cnt = size(snapshot->outcomelist[o_idx].bagtypelist[b_idx].productlist,5)
        FOR (pr_idx = 1 TO product_cnt)
          SET snapshot->outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].bag_type_product_id
           = getsequence(0)
          SET gm_i_bbd_bag_type8458_req->allow_partial_ind = 0
          SET stat = gm_i_bbd_bag_type8458_f8("BAG_TYPE_PRODUCT_ID",snapshot->outcomelist[o_idx].
           bagtypelist[b_idx].productlist[pr_idx].bag_type_product_id,1,0)
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_f8("OUTCOME_BAG_TYPE_ID",snapshot->outcomelist[o_idx].
            bagtypelist[b_idx].outcome_bag_type_id,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_f8("PRODUCT_CD",snapshot->outcomelist[o_idx].bagtypelist[
            b_idx].productlist[pr_idx].product_cd,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_i2("DEFAULT_IND",snapshot->outcomelist[o_idx].
            bagtypelist[b_idx].productlist[pr_idx].default_ind,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(snapshot->
             outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].beg_effective_dt_tm),1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_i2("ACTIVE_IND",0,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(snapshot->
             outcomelist[o_idx].bagtypelist[b_idx].productlist[pr_idx].active_status_dt_tm),1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_f8("ACTIVE_STATUS_PRSNL_ID",snapshot->outcomelist[o_idx].
            bagtypelist[b_idx].productlist[pr_idx].active_status_prsnl_id,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_i4("UPDT_APPLCTX",snapshot->outcomelist[o_idx].
            bagtypelist[b_idx].productlist[pr_idx].updt_applctx,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_i4("UPDT_TASK",snapshot->outcomelist[o_idx].bagtypelist[
            b_idx].productlist[pr_idx].updt_task,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_dq8("UPDT_DT_TM",cnvtdatetime(snapshot->outcomelist[o_idx
             ].bagtypelist[b_idx].productlist[pr_idx].updt_dt_tm),1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_f8("UPDT_ID",snapshot->outcomelist[o_idx].bagtypelist[
            b_idx].productlist[pr_idx].updt_id,1,0)
          ENDIF
          IF (stat=1)
           SET stat = gm_i_bbd_bag_type8458_i4("UPDT_CNT",snapshot->outcomelist[o_idx].bagtypelist[
            b_idx].productlist[pr_idx].updt_cnt,1,0)
          ENDIF
          IF (stat=1)
           SET modify = nopredeclare
           EXECUTE gm_i_bbd_bag_type8458  WITH replace(request,gm_i_bbd_bag_type8458_req), replace(
            reply,gm_i_bbd_bag_type8458_rep)
           SET modify = predeclare
           IF ((gm_i_bbd_bag_type8458_rep->status_data.status="F"))
            CALL errorhandler("F","BBD_BAG_TYPE_PRODUCT",gm_i_bbd_bag_type8458_rep->qual[1].error_msg
             )
           ENDIF
          ELSE
           CALL errorhandler("F","BBD_BAG_TYPE_PRODUCT","Insert failed.")
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 GO TO set_status
 SUBROUTINE getsequence(null)
   DECLARE ref_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     ref_id = y
    WITH format, counter
   ;end select
   IF (ref_id=0.0)
    CALL errorhandler("F","DUAL","Dual select failed.")
   ELSE
    RETURN(ref_id)
   ENDIF
 END ;Subroutine
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
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
 FREE RECORD snapshot
 FREE RECORD gm_i_bbd_donation8460_req
 FREE RECORD gm_i_bbd_donation8460_rep
 FREE RECORD gm_u_bbd_donation8460_req
 FREE RECORD gm_u_bbd_donation8460_rep
 FREE RECORD gm_i_bbd_procedur8459_req
 FREE RECORD gm_i_bbd_procedur8459_rep
 FREE RECORD gm_u_bbd_procedur8459_req
 FREE RECORD gm_u_bbd_procedur8459_rep
 FREE RECORD gm_i_bbd_outcome_8462_req
 FREE RECORD gm_i_bbd_outcome_8462_rep
 FREE RECORD gm_u_bbd_outcome_8462_req
 FREE RECORD gm_u_bbd_outcome_8462_rep
 FREE RECORD gm_i_bbd_outcome_8461_req
 FREE RECORD gm_i_bbd_outcome_8461_rep
 FREE RECORD gm_u_bbd_outcome_8461_req
 FREE RECORD gm_u_bbd_outcome_8461_rep
 FREE RECORD gm_i_bbd_bag_type8458_req
 FREE RECORD gm_i_bbd_bag_type8458_rep
 FREE RECORD gm_u_bbd_bag_type8458_req
 FREE RECORD gm_u_bbd_bag_type8458_rep
END GO

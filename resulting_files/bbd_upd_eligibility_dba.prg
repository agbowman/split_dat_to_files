CREATE PROGRAM bbd_upd_eligibility:dba
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
 EXECUTE gm_bbd_product_8463_def "I"
 DECLARE gm_i_bbd_product_8463_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_product_8463_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_product_8463_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_product_8463_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_product_8463_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_product_8463_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_product_8463_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "product_eligibility_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_product_8463_req->qual[iqual].product_eligibility_id = ival
     SET gm_i_bbd_product_8463_req->product_eligibility_idi = 1
    OF "product_cd":
     SET gm_i_bbd_product_8463_req->qual[iqual].product_cd = ival
     SET gm_i_bbd_product_8463_req->product_cdi = 1
    OF "previous_product_cd":
     SET gm_i_bbd_product_8463_req->qual[iqual].previous_product_cd = ival
     SET gm_i_bbd_product_8463_req->previous_product_cdi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_product_8463_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_product_8463_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_product_8463_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_product_8463_req->active_status_prsnl_idi = 1
    OF "updt_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_product_8463_req->qual[iqual].updt_id = ival
     SET gm_i_bbd_product_8463_req->updt_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_product_8463_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_product_8463_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_product_8463_req->qual,iqual)
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
     SET gm_i_bbd_product_8463_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_product_8463_req->active_indi = 1
    OF "list_ind":
     SET gm_i_bbd_product_8463_req->qual[iqual].list_ind = ival
     SET gm_i_bbd_product_8463_req->list_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_product_8463_i4(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_product_8463_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_product_8463_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "days_until_eligible":
     SET gm_i_bbd_product_8463_req->qual[iqual].days_until_eligible = ival
     SET gm_i_bbd_product_8463_req->days_until_eligiblei = 1
    OF "updt_applctx":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_product_8463_req->qual[iqual].updt_applctx = ival
     SET gm_i_bbd_product_8463_req->updt_applctxi = 1
    OF "updt_task":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_product_8463_req->qual[iqual].updt_task = ival
     SET gm_i_bbd_product_8463_req->updt_taski = 1
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_product_8463_req->qual[iqual].updt_cnt = ival
     SET gm_i_bbd_product_8463_req->updt_cnti = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_product_8463_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_product_8463_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_product_8463_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     SET gm_i_bbd_product_8463_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_product_8463_req->beg_effective_dt_tmi = 1
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_product_8463_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_product_8463_req->end_effective_dt_tmi = 1
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_product_8463_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_product_8463_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_product_8463_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_product_8463_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_product_8463_def "U"
 DECLARE gm_u_bbd_product_8463_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_product_8463_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_product_8463_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_product_8463_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_product_8463_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_product_8463_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_product_8463_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "product_eligibility_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_product_8463_req->product_eligibility_idf = 1
     SET gm_u_bbd_product_8463_req->qual[iqual].product_eligibility_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->product_eligibility_idw = 1
     ENDIF
    OF "product_cd":
     IF (null_ind=1)
      SET gm_u_bbd_product_8463_req->product_cdf = 2
     ELSE
      SET gm_u_bbd_product_8463_req->product_cdf = 1
     ENDIF
     SET gm_u_bbd_product_8463_req->qual[iqual].product_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->product_cdw = 1
     ENDIF
    OF "previous_product_cd":
     IF (null_ind=1)
      SET gm_u_bbd_product_8463_req->previous_product_cdf = 2
     ELSE
      SET gm_u_bbd_product_8463_req->previous_product_cdf = 1
     ENDIF
     SET gm_u_bbd_product_8463_req->qual[iqual].previous_product_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->previous_product_cdw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_product_8463_req->active_status_cdf = 1
     SET gm_u_bbd_product_8463_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_product_8463_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_product_8463_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_product_8463_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_product_8463_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_product_8463_req->qual,iqual)
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
     SET gm_u_bbd_product_8463_req->active_indf = 1
     SET gm_u_bbd_product_8463_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->active_indw = 1
     ENDIF
    OF "list_ind":
     IF (null_ind=1)
      SET gm_u_bbd_product_8463_req->list_indf = 2
     ELSE
      SET gm_u_bbd_product_8463_req->list_indf = 1
     ENDIF
     SET gm_u_bbd_product_8463_req->qual[iqual].list_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->list_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_product_8463_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_product_8463_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_product_8463_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "days_until_eligible":
     IF (null_ind=1)
      SET gm_u_bbd_product_8463_req->days_until_eligiblef = 2
     ELSE
      SET gm_u_bbd_product_8463_req->days_until_eligiblef = 1
     ENDIF
     SET gm_u_bbd_product_8463_req->qual[iqual].days_until_eligible = ival
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->days_until_eligiblew = 1
     ENDIF
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_product_8463_req->updt_cntf = 1
     SET gm_u_bbd_product_8463_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_product_8463_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_product_8463_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_product_8463_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "beg_effective_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_product_8463_req->beg_effective_dt_tmf = 2
     ELSE
      SET gm_u_bbd_product_8463_req->beg_effective_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_product_8463_req->qual[iqual].beg_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->beg_effective_dt_tmw = 1
     ENDIF
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_product_8463_req->end_effective_dt_tmf = 1
     SET gm_u_bbd_product_8463_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->end_effective_dt_tmw = 1
     ENDIF
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_product_8463_req->active_status_dt_tmf = 1
     SET gm_u_bbd_product_8463_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_product_8463_req->updt_dt_tmf = 1
     SET gm_u_bbd_product_8463_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_product_8463_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SET modify = predeclare
 DECLARE system_dt_tm = q8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE script_name = c19 WITH constant("bbd_upd_eligibility")
 DECLARE elig_cnt = i4 WITH noconstant(0)
 DECLARE elig_index = i4 WITH noconstant(0)
 DECLARE new_elig_id = f8 WITH noconstant(0.0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 DECLARE tmp_active_cd = f8 WITH noconstant(0.0)
 DECLARE tmp_inactive_cd = f8 WITH noconstant(0.0)
 SET elig_cnt = size(request->eligibilitylist,5)
 FOR (elig_index = 1 TO elig_cnt)
   FREE RECORD eligibility
   RECORD eligibility(
     1 product_cd = f8
     1 previous_product_cd = f8
     1 days_until_eligible = i4
     1 beg_effective_dt_tm = dq8
     1 end_effective_dt_tm = dq8
     1 active_status_cd = f8
     1 active_status_dt_tm = dq8
     1 active_status_prsnl_id = f8
     1 updt_id = f8
     1 updt_applctx = i4
     1 updt_task = i4
     1 updt_dt_tm = dq8
     1 updt_cnt = i4
     1 list_ind = i2
   )
   SELECT INTO "nl:"
    bpe.*
    FROM bbd_product_eligibility bpe
    WHERE (bpe.product_eligibility_id=request->eligibilitylist[elig_index].product_eligibility_id)
    DETAIL
     eligibility->product_cd = bpe.product_cd, eligibility->previous_product_cd = bpe
     .previous_product_cd, eligibility->days_until_eligible = bpe.days_until_eligible,
     eligibility->beg_effective_dt_tm = bpe.beg_effective_dt_tm, eligibility->end_effective_dt_tm =
     bpe.end_effective_dt_tm, eligibility->active_status_cd = bpe.active_status_cd,
     eligibility->active_status_dt_tm = bpe.active_status_dt_tm, eligibility->active_status_prsnl_id
      = bpe.active_status_prsnl_id, eligibility->updt_id = bpe.updt_id,
     eligibility->updt_applctx = bpe.updt_applctx, eligibility->updt_task = bpe.updt_task,
     eligibility->updt_dt_tm = bpe.updt_dt_tm,
     eligibility->updt_cnt = bpe.updt_cnt, eligibility->list_ind = bpe.list_ind
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET gm_i_bbd_product_8463_req->allow_partial_ind = 0
    SET stat = gm_i_bbd_product_8463_f8("PRODUCT_ELIGIBILITY_ID",request->eligibilitylist[elig_index]
     .product_eligibility_id,1,0)
    IF (stat=1)
     SET stat = gm_i_bbd_product_8463_i4("DAYS_UNTIL_ELIGIBLE",request->eligibilitylist[elig_index].
      days_until_eligible,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_product_8463_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_product_8463_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
       "31-DEC-2100 23:59:59.99"),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_product_8463_f8("PRODUCT_CD",request->eligibilitylist[elig_index].product_cd,
      1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_product_8463_f8("PREVIOUS_PRODUCT_CD",request->eligibilitylist[elig_index].
      previous_product_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_product_8463_i2("ACTIVE_IND",request->eligibilitylist[elig_index].active_ind,
      1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_product_8463_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_product_8463_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_product_8463_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_product_8463_i2("LIST_IND",request->eligibilitylist[elig_index].list_ind,1,0
      )
    ENDIF
    IF (stat=1)
     EXECUTE gm_i_bbd_product_8463  WITH replace(request,gm_i_bbd_product_8463_req), replace(reply,
      gm_i_bbd_product_8463_rep)
     IF ((gm_i_bbd_product_8463_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_PRODUCT_ELIGIBILITY",gm_i_bbd_product_8463_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_PRODUCT_ELIGIBILITY","Insert failed.")
    ENDIF
   ELSE
    SET gm_u_bbd_product_8463_req->allow_partial_ind = 0
    SET gm_u_bbd_product_8463_req->force_updt_ind = 1
    SET stat = gm_u_bbd_product_8463_f8("PRODUCT_ELIGIBILITY_ID",request->eligibilitylist[elig_index]
     .product_eligibility_id,1,0,1)
    IF (stat=1)
     SET stat = gm_u_bbd_product_8463_i4("DAYS_UNTIL_ELIGIBLE",request->eligibilitylist[elig_index].
      days_until_eligible,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_product_8463_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0,0)
    ENDIF
    IF (stat=1)
     IF ((request->eligibilitylist[elig_index].active_ind=1))
      SET stat = gm_u_bbd_product_8463_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(
        "31-DEC-2100 23:59:59.99"),1,0,0)
     ELSE
      SET stat = gm_u_bbd_product_8463_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_product_8463_f8("PRODUCT_CD",request->eligibilitylist[elig_index].product_cd,
      1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_product_8463_f8("PREVIOUS_PRODUCT_CD",request->eligibilitylist[elig_index].
      previous_product_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_product_8463_i2("ACTIVE_IND",request->eligibilitylist[elig_index].active_ind,
      1,0,0)
    ENDIF
    IF (stat=1)
     IF ((request->eligibilitylist[elig_index].active_ind=1))
      SET stat = gm_u_bbd_product_8463_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0,0)
     ELSE
      SET stat = gm_u_bbd_product_8463_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_product_8463_i2("LIST_IND",request->eligibilitylist[elig_index].list_ind,1,0,
      0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_bbd_product_8463  WITH replace(request,gm_u_bbd_product_8463_req), replace(reply,
      gm_u_bbd_product_8463_rep)
     IF ((gm_u_bbd_product_8463_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_PRODUCT_ELIGIBILITY",gm_u_bbd_product_8463_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_PRODUCT_ELIGIBILITY","Update failed.")
     GO TO exit_script
    ENDIF
    IF ((request->eligibilitylist[elig_index].active_ind=1))
     SELECT INTO "nl:"
      y = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       new_elig_id = y
      WITH counter
     ;end select
     IF (new_elig_id=0)
      CALL errorhandler("F","DUAL","Dual select failed.")
     ENDIF
     SET gm_i_bbd_product_8463_req->allow_partial_ind = 0
     SET stat = gm_i_bbd_product_8463_f8("PRODUCT_ELIGIBILITY_ID",new_elig_id,1,0)
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_i4("DAYS_UNTIL_ELIGIBLE",eligibility->days_until_eligible,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_dq8("BEG_EFFECTIVE_DT_TM",cnvtdatetime(eligibility->
        beg_effective_dt_tm),1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime(system_dt_tm),1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_f8("PRODUCT_CD",eligibility->product_cd,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_f8("PREVIOUS_PRODUCT_CD",eligibility->previous_product_cd,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_i2("ACTIVE_IND",0,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_f8("ACTIVE_STATUS_CD",eligibility->active_status_cd,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(eligibility->
        active_status_dt_tm),1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_f8("ACTIVE_STATUS_PRSNL_ID",eligibility->
       active_status_prsnl_id,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_i4("UPDT_APPLCTX",eligibility->updt_applctx,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_i4("UPDT_TASK",eligibility->updt_task,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_dq8("UPDT_DT_TM",cnvtdatetime(eligibility->updt_dt_tm),1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_f8("UPDT_ID",eligibility->updt_id,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_i4("UPDT_CNT",eligibility->updt_cnt,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_product_8463_i2("LIST_IND",eligibility->list_ind,1,0)
     ENDIF
     IF (stat=1)
      EXECUTE gm_i_bbd_product_8463  WITH replace(request,gm_i_bbd_product_8463_req), replace(reply,
       gm_i_bbd_product_8463_rep)
      IF ((gm_i_bbd_product_8463_rep->status_data.status="F"))
       CALL errorhandler("F","BBD_PRODUCT_ELIGIBILITY",gm_i_bbd_product_8463_rep->qual[1].error_msg)
      ENDIF
     ELSE
      CALL errorhandler("F","BBD_PRODUCT_ELIGIBILITY","Insert failed.")
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 GO TO set_status
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
 FREE RECORD eligibility
 FREE RECORD gm_i_bbd_product_8463_req
 FREE RECORD gm_i_bbd_product_8463_rep
 FREE RECORD gm_u_bbd_product_8463_req
 FREE RECORD gm_u_bbd_product_8463_rep
END GO

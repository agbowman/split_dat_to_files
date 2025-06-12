CREATE PROGRAM bbd_upd_donor:dba
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
 EXECUTE gm_person_donor2148_def "I"
 DECLARE gm_i_person_donor2148_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_person_donor2148_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_person_donor2148_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_person_donor2148_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_person_donor2148_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_person_donor2148_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].person_id = ival
     SET gm_i_person_donor2148_req->person_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].active_status_cd = ival
     SET gm_i_person_donor2148_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_person_donor2148_req->active_status_prsnl_idi = 1
    OF "rare_donor_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].rare_donor_cd = ival
     SET gm_i_person_donor2148_req->rare_donor_cdi = 1
    OF "willingness_level_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].willingness_level_cd = ival
     SET gm_i_person_donor2148_req->willingness_level_cdi = 1
    OF "eligibility_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].eligibility_type_cd = ival
     SET gm_i_person_donor2148_req->eligibility_type_cdi = 1
    OF "spec_dnr_interest_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].spec_dnr_interest_cd = ival
     SET gm_i_person_donor2148_req->spec_dnr_interest_cdi = 1
    OF "counseling_reqrd_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].counseling_reqrd_cd = ival
     SET gm_i_person_donor2148_req->counseling_reqrd_cdi = 1
    OF "watch_reason_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].watch_reason_cd = ival
     SET gm_i_person_donor2148_req->watch_reason_cdi = 1
    OF "donation_level":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].donation_level = ival
     SET gm_i_person_donor2148_req->donation_leveli = 1
    OF "donation_level_trans":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].donation_level_trans = ival
     SET gm_i_person_donor2148_req->donation_level_transi = 1
    OF "recruit_inv_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].recruit_inv_area_cd = ival
     SET gm_i_person_donor2148_req->recruit_inv_area_cdi = 1
    OF "recruit_owner_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].recruit_owner_area_cd = ival
     SET gm_i_person_donor2148_req->recruit_owner_area_cdi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_person_donor2148_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_person_donor2148_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_person_donor2148_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "lock_ind":
     SET gm_i_person_donor2148_req->qual[iqual].lock_ind = ival
     SET gm_i_person_donor2148_req->lock_indi = 1
    OF "active_ind":
     SET gm_i_person_donor2148_req->qual[iqual].active_ind = ival
     SET gm_i_person_donor2148_req->active_indi = 1
    OF "elig_for_reinstate_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].elig_for_reinstate_ind = ival
     SET gm_i_person_donor2148_req->elig_for_reinstate_indi = 1
    OF "reinstated_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].reinstated_ind = ival
     SET gm_i_person_donor2148_req->reinstated_indi = 1
    OF "watch_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].watch_ind = ival
     SET gm_i_person_donor2148_req->watch_indi = 1
    OF "mailings_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].mailings_ind = ival
     SET gm_i_person_donor2148_req->mailings_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_person_donor2148_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_person_donor2148_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_person_donor2148_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     SET gm_i_person_donor2148_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_person_donor2148_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_person_donor2148_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_person_donor2148_req->updt_dt_tmi = 1
    OF "defer_until_dt_tm":
     SET gm_i_person_donor2148_req->qual[iqual].defer_until_dt_tm = cnvtdatetime(ival)
     SET gm_i_person_donor2148_req->defer_until_dt_tmi = 1
    OF "reinstated_dt_tm":
     SET gm_i_person_donor2148_req->qual[iqual].reinstated_dt_tm = cnvtdatetime(ival)
     SET gm_i_person_donor2148_req->reinstated_dt_tmi = 1
    OF "last_donation_dt_tm":
     SET gm_i_person_donor2148_req->qual[iqual].last_donation_dt_tm = cnvtdatetime(ival)
     SET gm_i_person_donor2148_req->last_donation_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_person_donor2148_def "U"
 DECLARE gm_u_person_donor2148_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_person_donor2148_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_person_donor2148_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_person_donor2148_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_person_donor2148_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_person_donor2148_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_person_donor2148_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->person_idf = 1
     SET gm_u_person_donor2148_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->person_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->active_status_cdf = 1
     SET gm_u_person_donor2148_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->active_status_prsnl_idf = 1
     SET gm_u_person_donor2148_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->active_status_prsnl_idw = 1
     ENDIF
    OF "rare_donor_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->rare_donor_cdf = 1
     SET gm_u_person_donor2148_req->qual[iqual].rare_donor_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->rare_donor_cdw = 1
     ENDIF
    OF "willingness_level_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->willingness_level_cdf = 1
     SET gm_u_person_donor2148_req->qual[iqual].willingness_level_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->willingness_level_cdw = 1
     ENDIF
    OF "eligibility_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->eligibility_type_cdf = 1
     SET gm_u_person_donor2148_req->qual[iqual].eligibility_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->eligibility_type_cdw = 1
     ENDIF
    OF "spec_dnr_interest_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->spec_dnr_interest_cdf = 1
     SET gm_u_person_donor2148_req->qual[iqual].spec_dnr_interest_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->spec_dnr_interest_cdw = 1
     ENDIF
    OF "counseling_reqrd_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->counseling_reqrd_cdf = 1
     SET gm_u_person_donor2148_req->qual[iqual].counseling_reqrd_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->counseling_reqrd_cdw = 1
     ENDIF
    OF "watch_reason_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->watch_reason_cdf = 1
     SET gm_u_person_donor2148_req->qual[iqual].watch_reason_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->watch_reason_cdw = 1
     ENDIF
    OF "donation_level":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->donation_levelf = 1
     SET gm_u_person_donor2148_req->qual[iqual].donation_level = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->donation_levelw = 1
     ENDIF
    OF "donation_level_trans":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->donation_level_transf = 1
     SET gm_u_person_donor2148_req->qual[iqual].donation_level_trans = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->donation_level_transw = 1
     ENDIF
    OF "recruit_inv_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->recruit_inv_area_cdf = 1
     SET gm_u_person_donor2148_req->qual[iqual].recruit_inv_area_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->recruit_inv_area_cdw = 1
     ENDIF
    OF "recruit_owner_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->recruit_owner_area_cdf = 1
     SET gm_u_person_donor2148_req->qual[iqual].recruit_owner_area_cd = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->recruit_owner_area_cdw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_person_donor2148_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_person_donor2148_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_person_donor2148_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "lock_ind":
     IF (null_ind=1)
      SET gm_u_person_donor2148_req->lock_indf = 2
     ELSE
      SET gm_u_person_donor2148_req->lock_indf = 1
     ENDIF
     SET gm_u_person_donor2148_req->qual[iqual].lock_ind = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->lock_indw = 1
     ENDIF
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_person_donor2148_req->active_indf = 2
     ELSE
      SET gm_u_person_donor2148_req->active_indf = 1
     ENDIF
     SET gm_u_person_donor2148_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->active_indw = 1
     ENDIF
    OF "elig_for_reinstate_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->elig_for_reinstate_indf = 1
     SET gm_u_person_donor2148_req->qual[iqual].elig_for_reinstate_ind = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->elig_for_reinstate_indw = 1
     ENDIF
    OF "reinstated_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->reinstated_indf = 1
     SET gm_u_person_donor2148_req->qual[iqual].reinstated_ind = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->reinstated_indw = 1
     ENDIF
    OF "watch_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->watch_indf = 1
     SET gm_u_person_donor2148_req->qual[iqual].watch_ind = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->watch_indw = 1
     ENDIF
    OF "mailings_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->mailings_indf = 1
     SET gm_u_person_donor2148_req->qual[iqual].mailings_ind = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->mailings_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_person_donor2148_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_person_donor2148_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_person_donor2148_req->qual,iqual)
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
     SET gm_u_person_donor2148_req->updt_cntf = 1
     SET gm_u_person_donor2148_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_person_donor2148_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_person_donor2148_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_person_donor2148_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_person_donor2148_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_person_donor2148_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_person_donor2148_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_person_donor2148_req->updt_dt_tmf = 1
     SET gm_u_person_donor2148_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->updt_dt_tmw = 1
     ENDIF
    OF "defer_until_dt_tm":
     IF (null_ind=1)
      SET gm_u_person_donor2148_req->defer_until_dt_tmf = 2
     ELSE
      SET gm_u_person_donor2148_req->defer_until_dt_tmf = 1
     ENDIF
     SET gm_u_person_donor2148_req->qual[iqual].defer_until_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->defer_until_dt_tmw = 1
     ENDIF
    OF "reinstated_dt_tm":
     IF (null_ind=1)
      SET gm_u_person_donor2148_req->reinstated_dt_tmf = 2
     ELSE
      SET gm_u_person_donor2148_req->reinstated_dt_tmf = 1
     ENDIF
     SET gm_u_person_donor2148_req->qual[iqual].reinstated_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->reinstated_dt_tmw = 1
     ENDIF
    OF "last_donation_dt_tm":
     IF (null_ind=1)
      SET gm_u_person_donor2148_req->last_donation_dt_tmf = 2
     ELSE
      SET gm_u_person_donor2148_req->last_donation_dt_tmf = 1
     ENDIF
     SET gm_u_person_donor2148_req->qual[iqual].last_donation_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_person_donor2148_req->last_donation_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE ldidx = i4 WITH public, noconstant(0)
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE script_name = c13 WITH constant("BBD_UPD_DONOR")
 DECLARE add_ind = i2 WITH constant(1)
 DECLARE change_ind = i2 WITH constant(2)
 FOR (ldidx = 1 TO size(request->donor_list,5))
   IF ((request->donor_list[ldidx].add_change_ind=change_ind))
    SET gm_u_person_donor2148_req->allow_partial_ind = 0
    SET gm_u_person_donor2148_req->force_updt_ind = 0
    SET stat = gm_u_person_donor2148_i2("ACTIVE_IND",request->donor_list[ldidx].active_ind,1,0,0)
    IF ((request->donor_list[ldidx].active_ind=1))
     IF (stat=1)
      SET stat = gm_u_person_donor2148_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_u_person_donor2148_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0,0
       )
     ENDIF
     IF (stat=1)
      SET stat = gm_u_person_donor2148_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0,0)
     ENDIF
    ELSEIF ((request->donor_list[ldidx].active_ind=0))
     IF (stat=1)
      SET stat = gm_u_person_donor2148_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("COUNSELING_REQRD_CD",request->donor_list[ldidx].
      counseling_reqrd_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_dq8("DEFER_UNTIL_DT_TM",cnvtdatetime(request->donor_list[ldidx]
       .defer_until_dt_tm),1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("DONATION_LEVEL",request->donor_list[ldidx].donation_level,1,
      0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("DONATION_LEVEL_TRANS",request->donor_list[ldidx].
      donation_level_trans,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("ELIGIBILITY_TYPE_CD",request->donor_list[ldidx].
      eligibility_type_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_i2("ELIG_FOR_REINSTATE_IND",request->donor_list[ldidx].
      elig_for_reinstate_ind,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_dq8("LAST_DONATION_DT_TM",cnvtdatetime(request->donor_list[
       ldidx].last_donation_dt_tm),1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_i2("LOCK_IND",request->donor_list[ldidx].lock_ind,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_i2("MAILINGS_IND",request->donor_list[ldidx].mailings_ind,1,0,0
      )
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("PERSON_ID",request->donor_list[ldidx].person_id,1,0,1)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("RARE_DONOR_CD",request->donor_list[ldidx].rare_donor_cd,1,0,
      0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("RECRUIT_INV_AREA_CD",request->donor_list[ldidx].
      recruit_inv_area_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("RECRUIT_OWNER_AREA_CD",request->donor_list[ldidx].
      recruit_owner_area_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_dq8("REINSTATED_DT_TM",cnvtdatetime(request->donor_list[ldidx].
       reinstated_dt_tm),1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_i2("REINSTATED_IND",request->donor_list[ldidx].reinstated_ind,1,
      0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("SPEC_DNR_INTEREST_CD",request->donor_list[ldidx].
      spec_dnr_interest_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_i4("UPDT_CNT",request->donor_list[ldidx].updt_cnt,1,0,1)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_i2("WATCH_IND",request->donor_list[ldidx].watch_ind,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("WATCH_REASON_CD",request->donor_list[ldidx].watch_reason_cd,
      1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_person_donor2148_f8("WILLINGNESS_LEVEL_CD",request->donor_list[ldidx].
      willingness_level_cd,1,0,0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_person_donor2148  WITH replace(request,gm_u_person_donor2148_req), replace(reply,
      gm_u_person_donor2148_rep)
     IF ((gm_u_person_donor2148_rep->status_data.status="F"))
      CALL errorhandler("F","PERSON_DONOR",gm_u_person_donor2148_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","PERSON_DONOR","Update failed.")
    ENDIF
   ELSEIF ((request->donor_list[ldidx].add_change_ind=add_ind))
    SET gm_i_person_donor2148_req->allow_partial_ind = 0
    SET stat = gm_i_person_donor2148_i2("ACTIVE_IND",request->donor_list[ldidx].active_ind,1,0)
    IF ((request->donor_list[ldidx].active_ind=1))
     IF (stat=1)
      SET stat = gm_i_person_donor2148_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_person_donor2148_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_person_donor2148_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
     ENDIF
    ELSEIF ((request->donor_list[ldidx].active_ind=0))
     IF (stat=1)
      SET stat = gm_i_person_donor2148_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("COUNSELING_REQRD_CD",request->donor_list[ldidx].
      counseling_reqrd_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_dq8("DEFER_UNTIL_DT_TM",cnvtdatetime(request->donor_list[ldidx]
       .defer_until_dt_tm),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("DONATION_LEVEL",request->donor_list[ldidx].donation_level,1,
      0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("DONATION_LEVEL_TRANS",request->donor_list[ldidx].
      donation_level_trans,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("ELIGIBILITY_TYPE_CD",request->donor_list[ldidx].
      eligibility_type_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_i2("ELIG_FOR_REINSTATE_IND",request->donor_list[ldidx].
      elig_for_reinstate_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_dq8("LAST_DONATION_DT_TM",cnvtdatetime(request->donor_list[
       ldidx].last_donation_dt_tm),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_i2("LOCK_IND",request->donor_list[ldidx].lock_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_i2("MAILINGS_IND",request->donor_list[ldidx].mailings_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("PERSON_ID",request->donor_list[ldidx].person_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("RARE_DONOR_CD",request->donor_list[ldidx].rare_donor_cd,1,0
      )
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("RECRUIT_INV_AREA_CD",request->donor_list[ldidx].
      recruit_inv_area_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("RECRUIT_OWNER_AREA_CD",request->donor_list[ldidx].
      recruit_owner_area_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_dq8("REINSTATED_DT_TM",cnvtdatetime(request->donor_list[ldidx].
       reinstated_dt_tm),1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_i2("REINSTATED_IND",request->donor_list[ldidx].reinstated_ind,1,
      0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("SPEC_DNR_INTEREST_CD",request->donor_list[ldidx].
      spec_dnr_interest_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_i2("WATCH_IND",request->donor_list[ldidx].watch_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("WATCH_REASON_CD",request->donor_list[ldidx].watch_reason_cd,
      1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_person_donor2148_f8("WILLINGNESS_LEVEL_CD",request->donor_list[ldidx].
      willingness_level_cd,1,0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_i_person_donor2148  WITH replace(request,gm_i_person_donor2148_req), replace(reply,
      gm_i_person_donor2148_rep)
     IF ((gm_i_person_donor2148_rep->status_data.status="F"))
      CALL errorhandler("F","PERSON_DONOR",gm_i_person_donor2148_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","PERSON_DONOR","Insert failed.")
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
 FREE RECORD gm_i_person_donor2148_req
 FREE RECORD gm_i_person_donor2148_rep
 FREE RECORD gm_u_person_donor2148_req
 FREE RECORD gm_u_person_donor2148_rep
END GO

CREATE PROGRAM bbd_upd_contacts:dba
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
 EXECUTE gm_bbd_donor_cont1635_def "I"
 DECLARE gm_i_bbd_donor_cont1635_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donor_cont1635_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donor_cont1635_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_donor_cont1635_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donor_cont1635_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donor_cont1635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].contact_id = ival
     SET gm_i_bbd_donor_cont1635_req->contact_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].person_id = ival
     SET gm_i_bbd_donor_cont1635_req->person_idi = 1
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].encntr_id = ival
     SET gm_i_bbd_donor_cont1635_req->encntr_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_donor_cont1635_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_donor_cont1635_req->active_status_prsnl_idi = 1
    OF "contact_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].contact_type_cd = ival
     SET gm_i_bbd_donor_cont1635_req->contact_type_cdi = 1
    OF "init_contact_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].init_contact_prsnl_id = ival
     SET gm_i_bbd_donor_cont1635_req->init_contact_prsnl_idi = 1
    OF "contact_outcome_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].contact_outcome_cd = ival
     SET gm_i_bbd_donor_cont1635_req->contact_outcome_cdi = 1
    OF "contact_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].contact_status_cd = ival
     SET gm_i_bbd_donor_cont1635_req->contact_status_cdi = 1
    OF "inventory_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].inventory_area_cd = ival
     SET gm_i_bbd_donor_cont1635_req->inventory_area_cdi = 1
    OF "organization_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].organization_id = ival
     SET gm_i_bbd_donor_cont1635_req->organization_idi = 1
    OF "owner_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].owner_area_cd = ival
     SET gm_i_bbd_donor_cont1635_req->owner_area_cdi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donor_cont1635_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donor_cont1635_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donor_cont1635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_donor_cont1635_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donor_cont1635_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donor_cont1635_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donor_cont1635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donor_cont1635_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donor_cont1635_req->updt_dt_tmi = 1
    OF "contact_dt_tm":
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].contact_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donor_cont1635_req->contact_dt_tmi = 1
    OF "needed_dt_tm":
     SET gm_i_bbd_donor_cont1635_req->qual[iqual].needed_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donor_cont1635_req->needed_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_donor_cont1635_def "U"
 DECLARE gm_u_bbd_donor_cont1635_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donor_cont1635_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donor_cont1635_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donor_cont1635_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_donor_cont1635_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_cont1635_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_cont1635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->contact_idf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->contact_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->person_idf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->person_idw = 1
     ENDIF
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->encntr_idf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].encntr_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->encntr_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->active_status_cdf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->active_status_prsnl_idw = 1
     ENDIF
    OF "contact_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->contact_type_cdf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].contact_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->contact_type_cdw = 1
     ENDIF
    OF "init_contact_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->init_contact_prsnl_idf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].init_contact_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->init_contact_prsnl_idw = 1
     ENDIF
    OF "contact_outcome_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->contact_outcome_cdf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].contact_outcome_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->contact_outcome_cdw = 1
     ENDIF
    OF "contact_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->contact_status_cdf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].contact_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->contact_status_cdw = 1
     ENDIF
    OF "inventory_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->inventory_area_cdf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].inventory_area_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->inventory_area_cdw = 1
     ENDIF
    OF "organization_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->organization_idf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].organization_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->organization_idw = 1
     ENDIF
    OF "owner_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->owner_area_cdf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].owner_area_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->owner_area_cdw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donor_cont1635_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_cont1635_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_cont1635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_bbd_donor_cont1635_req->active_indf = 2
     ELSE
      SET gm_u_bbd_donor_cont1635_req->active_indf = 1
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donor_cont1635_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_cont1635_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_cont1635_req->qual,iqual)
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
     SET gm_u_bbd_donor_cont1635_req->updt_cntf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donor_cont1635_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_cont1635_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_cont1635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_donor_cont1635_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_bbd_donor_cont1635_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->updt_dt_tmf = 1
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->updt_dt_tmw = 1
     ENDIF
    OF "contact_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_donor_cont1635_req->contact_dt_tmf = 2
     ELSE
      SET gm_u_bbd_donor_cont1635_req->contact_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].contact_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->contact_dt_tmw = 1
     ENDIF
    OF "needed_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_donor_cont1635_req->needed_dt_tmf = 2
     ELSE
      SET gm_u_bbd_donor_cont1635_req->needed_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_donor_cont1635_req->qual[iqual].needed_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont1635_req->needed_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_other_cont3472_def "I"
 DECLARE gm_i_bbd_other_cont3472_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_other_cont3472_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_other_cont3472_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_other_cont3472_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_other_cont3472_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_other_cont3472_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_other_cont3472_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "other_contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].other_contact_id = ival
     SET gm_i_bbd_other_cont3472_req->other_contact_idi = 1
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].contact_id = ival
     SET gm_i_bbd_other_cont3472_req->contact_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].person_id = ival
     SET gm_i_bbd_other_cont3472_req->person_idi = 1
    OF "outcome_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].outcome_cd = ival
     SET gm_i_bbd_other_cont3472_req->outcome_cdi = 1
    OF "contact_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].contact_prsnl_id = ival
     SET gm_i_bbd_other_cont3472_req->contact_prsnl_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_other_cont3472_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_other_cont3472_req->active_status_prsnl_idi = 1
    OF "method_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].method_cd = ival
     SET gm_i_bbd_other_cont3472_req->method_cdi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_other_cont3472_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_other_cont3472_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_other_cont3472_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "follow_up_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].follow_up_ind = ival
     SET gm_i_bbd_other_cont3472_req->follow_up_indi = 1
    OF "active_ind":
     IF (null_ind=1)
      SET gm_i_bbd_other_cont3472_req->active_indn = 1
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_other_cont3472_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_other_cont3472_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_other_cont3472_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_other_cont3472_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_i_bbd_other_cont3472_req->active_status_dt_tmn = 1
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_other_cont3472_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_other_cont3472_req->updt_dt_tmi = 1
    OF "contact_dt_tm":
     IF (null_ind=1)
      SET gm_i_bbd_other_cont3472_req->contact_dt_tmn = 1
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].contact_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_other_cont3472_req->contact_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_other_cont3472_vc(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_other_cont3472_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_other_cont3472_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "donation_ident":
     IF (null_ind=1)
      SET gm_i_bbd_other_cont3472_req->donation_identn = 1
     ENDIF
     SET gm_i_bbd_other_cont3472_req->qual[iqual].donation_ident = ival
     SET gm_i_bbd_other_cont3472_req->donation_identi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_other_cont3472_def "U"
 DECLARE gm_u_bbd_other_cont3472_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_other_cont3472_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_other_cont3472_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_other_cont3472_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_other_cont3472_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_other_cont3472_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_other_cont3472_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_other_cont3472_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "other_contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_other_cont3472_req->other_contact_idf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].other_contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->other_contact_idw = 1
     ENDIF
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_other_cont3472_req->contact_idf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->contact_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_other_cont3472_req->person_idf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->person_idw = 1
     ENDIF
    OF "outcome_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_other_cont3472_req->outcome_cdf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].outcome_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->outcome_cdw = 1
     ENDIF
    OF "contact_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_other_cont3472_req->contact_prsnl_idf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].contact_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->contact_prsnl_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_other_cont3472_req->active_status_cdf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_other_cont3472_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->active_status_prsnl_idw = 1
     ENDIF
    OF "method_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_other_cont3472_req->method_cdf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].method_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->method_cdw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_other_cont3472_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_other_cont3472_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_other_cont3472_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "follow_up_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_other_cont3472_req->follow_up_indf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].follow_up_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->follow_up_indw = 1
     ENDIF
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_bbd_other_cont3472_req->active_indf = 2
     ELSE
      SET gm_u_bbd_other_cont3472_req->active_indf = 1
     ENDIF
     SET gm_u_bbd_other_cont3472_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_other_cont3472_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_other_cont3472_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_other_cont3472_req->qual,iqual)
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
     SET gm_u_bbd_other_cont3472_req->updt_cntf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_other_cont3472_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_other_cont3472_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_other_cont3472_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_other_cont3472_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_bbd_other_cont3472_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_other_cont3472_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_other_cont3472_req->updt_dt_tmf = 1
     SET gm_u_bbd_other_cont3472_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->updt_dt_tmw = 1
     ENDIF
    OF "contact_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_other_cont3472_req->contact_dt_tmf = 2
     ELSE
      SET gm_u_bbd_other_cont3472_req->contact_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_other_cont3472_req->qual[iqual].contact_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->contact_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_other_cont3472_vc(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_other_cont3472_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_other_cont3472_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "donation_ident":
     IF (null_ind=1)
      SET gm_u_bbd_other_cont3472_req->donation_identf = 2
     ELSE
      SET gm_u_bbd_other_cont3472_req->donation_identf = 1
     ENDIF
     SET gm_u_bbd_other_cont3472_req->qual[iqual].donation_ident = ival
     IF (wq_ind=1)
      SET gm_u_bbd_other_cont3472_req->donation_identw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_donation_r2146_def "I"
 DECLARE gm_i_bbd_donation_r2146_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donation_r2146_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donation_r2146_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donation_r2146_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_donation_r2146_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donation_r2146_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donation_r2146_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "donation_result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].donation_result_id = ival
     SET gm_i_bbd_donation_r2146_req->donation_result_idi = 1
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].encntr_id = ival
     SET gm_i_bbd_donation_r2146_req->encntr_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].person_id = ival
     SET gm_i_bbd_donation_r2146_req->person_idi = 1
    OF "procedure_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].procedure_cd = ival
     SET gm_i_bbd_donation_r2146_req->procedure_cdi = 1
    OF "venipuncture_site_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].venipuncture_site_cd = ival
     SET gm_i_bbd_donation_r2146_req->venipuncture_site_cdi = 1
    OF "bag_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].bag_type_cd = ival
     SET gm_i_bbd_donation_r2146_req->bag_type_cdi = 1
    OF "phleb_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].phleb_prsnl_id = ival
     SET gm_i_bbd_donation_r2146_req->phleb_prsnl_idi = 1
    OF "outcome_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].outcome_cd = ival
     SET gm_i_bbd_donation_r2146_req->outcome_cdi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_donation_r2146_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_donation_r2146_req->active_status_prsnl_idi = 1
    OF "owner_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].owner_area_cd = ival
     SET gm_i_bbd_donation_r2146_req->owner_area_cdi = 1
    OF "inv_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].inv_area_cd = ival
     SET gm_i_bbd_donation_r2146_req->inv_area_cdi = 1
    OF "draw_station_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].draw_station_cd = ival
     SET gm_i_bbd_donation_r2146_req->draw_station_cdi = 1
    OF "specimen_unit_meas_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].specimen_unit_meas_cd = ival
     SET gm_i_bbd_donation_r2146_req->specimen_unit_meas_cdi = 1
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].contact_id = ival
     SET gm_i_bbd_donation_r2146_req->contact_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donation_r2146_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donation_r2146_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donation_r2146_req->qual,iqual)
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
     SET gm_i_bbd_donation_r2146_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_donation_r2146_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donation_r2146_i4(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donation_r2146_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donation_r2146_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "specimen_volume":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].specimen_volume = ival
     SET gm_i_bbd_donation_r2146_req->specimen_volumei = 1
    OF "total_volume":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].total_volume = ival
     SET gm_i_bbd_donation_r2146_req->total_volumei = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donation_r2146_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donation_r2146_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donation_r2146_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "drawn_dt_tm":
     IF (null_ind=1)
      SET gm_i_bbd_donation_r2146_req->drawn_dt_tmn = 1
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].drawn_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donation_r2146_req->drawn_dt_tmi = 1
    OF "start_dt_tm":
     IF (null_ind=1)
      SET gm_i_bbd_donation_r2146_req->start_dt_tmn = 1
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].start_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donation_r2146_req->start_dt_tmi = 1
    OF "stop_dt_tm":
     IF (null_ind=1)
      SET gm_i_bbd_donation_r2146_req->stop_dt_tmn = 1
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].stop_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donation_r2146_req->stop_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donation_r2146_req->updt_dt_tmi = 1
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donation_r2146_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donation_r2146_req->active_status_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_donation_r2146_def "U"
 DECLARE gm_u_bbd_donation_r2146_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donation_r2146_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donation_r2146_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donation_r2146_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_donation_r2146_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donation_r2146_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donation_r2146_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "donation_result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->donation_result_idf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].donation_result_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->donation_result_idw = 1
     ENDIF
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->encntr_idf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].encntr_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->encntr_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->person_idf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->person_idw = 1
     ENDIF
    OF "procedure_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->procedure_cdf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].procedure_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->procedure_cdw = 1
     ENDIF
    OF "venipuncture_site_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->venipuncture_site_cdf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].venipuncture_site_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->venipuncture_site_cdw = 1
     ENDIF
    OF "bag_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->bag_type_cdf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].bag_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->bag_type_cdw = 1
     ENDIF
    OF "phleb_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->phleb_prsnl_idf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].phleb_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->phleb_prsnl_idw = 1
     ENDIF
    OF "outcome_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->outcome_cdf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].outcome_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->outcome_cdw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->active_status_cdf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->active_status_prsnl_idw = 1
     ENDIF
    OF "owner_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->owner_area_cdf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].owner_area_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->owner_area_cdw = 1
     ENDIF
    OF "inv_area_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->inv_area_cdf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].inv_area_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->inv_area_cdw = 1
     ENDIF
    OF "draw_station_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->draw_station_cdf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].draw_station_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->draw_station_cdw = 1
     ENDIF
    OF "specimen_unit_meas_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->specimen_unit_meas_cdf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].specimen_unit_meas_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->specimen_unit_meas_cdw = 1
     ENDIF
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->contact_idf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->contact_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donation_r2146_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donation_r2146_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donation_r2146_req->qual,iqual)
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
     SET gm_u_bbd_donation_r2146_req->active_indf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donation_r2146_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donation_r2146_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donation_r2146_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "specimen_volume":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->specimen_volumef = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].specimen_volume = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->specimen_volumew = 1
     ENDIF
    OF "total_volume":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->total_volumef = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].total_volume = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->total_volumew = 1
     ENDIF
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->updt_cntf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donation_r2146_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donation_r2146_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donation_r2146_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "drawn_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_donation_r2146_req->drawn_dt_tmf = 2
     ELSE
      SET gm_u_bbd_donation_r2146_req->drawn_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_donation_r2146_req->qual[iqual].drawn_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->drawn_dt_tmw = 1
     ENDIF
    OF "start_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_donation_r2146_req->start_dt_tmf = 2
     ELSE
      SET gm_u_bbd_donation_r2146_req->start_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_donation_r2146_req->qual[iqual].start_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->start_dt_tmw = 1
     ENDIF
    OF "stop_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_donation_r2146_req->stop_dt_tmf = 2
     ELSE
      SET gm_u_bbd_donation_r2146_req->stop_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_donation_r2146_req->qual[iqual].stop_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->stop_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->updt_dt_tmf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->updt_dt_tmw = 1
     ENDIF
    OF "active_status_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donation_r2146_req->active_status_dt_tmf = 1
     SET gm_u_bbd_donation_r2146_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donation_r2146_req->active_status_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_don_produc2147_def "I"
 DECLARE gm_i_bbd_don_produc2147_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_don_produc2147_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_don_produc2147_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_don_produc2147_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_don_produc2147_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_don_produc2147_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "donation_product_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_don_produc2147_req->qual[iqual].donation_product_id = ival
     SET gm_i_bbd_don_produc2147_req->donation_product_idi = 1
    OF "donation_results_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_don_produc2147_req->qual[iqual].donation_results_id = ival
     SET gm_i_bbd_don_produc2147_req->donation_results_idi = 1
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_don_produc2147_req->qual[iqual].contact_id = ival
     SET gm_i_bbd_don_produc2147_req->contact_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_don_produc2147_req->qual[iqual].person_id = ival
     SET gm_i_bbd_don_produc2147_req->person_idi = 1
    OF "product_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_don_produc2147_req->qual[iqual].product_id = ival
     SET gm_i_bbd_don_produc2147_req->product_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_don_produc2147_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_don_produc2147_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_don_produc2147_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_don_produc2147_req->active_status_prsnl_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_don_produc2147_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_don_produc2147_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_don_produc2147_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_bbd_don_produc2147_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_don_produc2147_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_don_produc2147_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_don_produc2147_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_don_produc2147_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     SET gm_i_bbd_don_produc2147_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_don_produc2147_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_don_produc2147_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_don_produc2147_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_don_produc2147_def "U"
 DECLARE gm_u_bbd_don_produc2147_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_don_produc2147_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_don_produc2147_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_don_produc2147_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_don_produc2147_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_don_produc2147_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_don_produc2147_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "donation_product_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_don_produc2147_req->donation_product_idf = 1
     SET gm_u_bbd_don_produc2147_req->qual[iqual].donation_product_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->donation_product_idw = 1
     ENDIF
    OF "donation_results_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_don_produc2147_req->donation_results_idf = 1
     SET gm_u_bbd_don_produc2147_req->qual[iqual].donation_results_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->donation_results_idw = 1
     ENDIF
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_don_produc2147_req->contact_idf = 1
     SET gm_u_bbd_don_produc2147_req->qual[iqual].contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->contact_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_don_produc2147_req->person_idf = 1
     SET gm_u_bbd_don_produc2147_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->person_idw = 1
     ENDIF
    OF "product_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_don_produc2147_req->product_idf = 1
     SET gm_u_bbd_don_produc2147_req->qual[iqual].product_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->product_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_don_produc2147_req->active_status_cdf = 1
     SET gm_u_bbd_don_produc2147_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_don_produc2147_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_don_produc2147_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_don_produc2147_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_don_produc2147_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_don_produc2147_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_bbd_don_produc2147_req->active_indf = 2
     ELSE
      SET gm_u_bbd_don_produc2147_req->active_indf = 1
     ENDIF
     SET gm_u_bbd_don_produc2147_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_don_produc2147_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_don_produc2147_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_don_produc2147_req->qual,iqual)
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
     SET gm_u_bbd_don_produc2147_req->updt_cntf = 1
     SET gm_u_bbd_don_produc2147_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_don_produc2147_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_don_produc2147_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_don_produc2147_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_don_produc2147_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_bbd_don_produc2147_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_don_produc2147_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_don_produc2147_req->updt_dt_tmf = 1
     SET gm_u_bbd_don_produc2147_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_don_produc2147_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_recruitmen3635_def "I"
 DECLARE gm_i_bbd_recruitmen3635_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_recruitmen3635_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_recruitmen3635_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_recruitmen3635_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_recruitmen3635_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_recruitmen3635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "recruit_result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].recruit_result_id = ival
     SET gm_i_bbd_recruitmen3635_req->recruit_result_idi = 1
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].contact_id = ival
     SET gm_i_bbd_recruitmen3635_req->contact_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].person_id = ival
     SET gm_i_bbd_recruitmen3635_req->person_idi = 1
    OF "recruit_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].recruit_prsnl_id = ival
     SET gm_i_bbd_recruitmen3635_req->recruit_prsnl_idi = 1
    OF "outcome_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].outcome_cd = ival
     SET gm_i_bbd_recruitmen3635_req->outcome_cdi = 1
    OF "recruit_list_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].recruit_list_id = ival
     SET gm_i_bbd_recruitmen3635_req->recruit_list_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_recruitmen3635_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_recruitmen3635_req->active_status_prsnl_idi = 1
    OF "contact_method_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].contact_method_cd = ival
     SET gm_i_bbd_recruitmen3635_req->contact_method_cdi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_recruitmen3635_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_recruitmen3635_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_recruitmen3635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_recruitmen3635_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_recruitmen3635_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_recruitmen3635_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_recruitmen3635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_recruitmen3635_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_recruitmen3635_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_recruitmen3635_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_recruitmen3635_def "U"
 DECLARE gm_u_bbd_recruitmen3635_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_recruitmen3635_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_recruitmen3635_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_recruitmen3635_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_recruitmen3635_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_recruitmen3635_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_recruitmen3635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "recruit_result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->recruit_result_idf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].recruit_result_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->recruit_result_idw = 1
     ENDIF
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->contact_idf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->contact_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->person_idf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->person_idw = 1
     ENDIF
    OF "recruit_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->recruit_prsnl_idf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].recruit_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->recruit_prsnl_idw = 1
     ENDIF
    OF "outcome_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->outcome_cdf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].outcome_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->outcome_cdw = 1
     ENDIF
    OF "recruit_list_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->recruit_list_idf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].recruit_list_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->recruit_list_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->active_status_cdf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->active_status_prsnl_idw = 1
     ENDIF
    OF "contact_method_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->contact_method_cdf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].contact_method_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->contact_method_cdw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_recruitmen3635_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_recruitmen3635_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_recruitmen3635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_bbd_recruitmen3635_req->active_indf = 2
     ELSE
      SET gm_u_bbd_recruitmen3635_req->active_indf = 1
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_recruitmen3635_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_recruitmen3635_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_recruitmen3635_req->qual,iqual)
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
     SET gm_u_bbd_recruitmen3635_req->updt_cntf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_recruitmen3635_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_recruitmen3635_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_recruitmen3635_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_recruitmen3635_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_bbd_recruitmen3635_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_recruitmen3635_req->updt_dt_tmf = 1
     SET gm_u_bbd_recruitmen3635_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_recruitmen3635_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_contact_no5125_def "I"
 DECLARE gm_i_bbd_contact_no5125_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_contact_no5125_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_contact_no5125_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_contact_no5125_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_contact_no5125_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_contact_no5125_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "contact_note_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_contact_no5125_req->qual[iqual].contact_note_id = ival
     SET gm_i_bbd_contact_no5125_req->contact_note_idi = 1
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_contact_no5125_req->qual[iqual].contact_id = ival
     SET gm_i_bbd_contact_no5125_req->contact_idi = 1
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_contact_no5125_req->qual[iqual].encntr_id = ival
     SET gm_i_bbd_contact_no5125_req->encntr_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_contact_no5125_req->qual[iqual].person_id = ival
     SET gm_i_bbd_contact_no5125_req->person_idi = 1
    OF "contact_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_contact_no5125_req->qual[iqual].contact_type_cd = ival
     SET gm_i_bbd_contact_no5125_req->contact_type_cdi = 1
    OF "long_text_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_contact_no5125_req->qual[iqual].long_text_id = ival
     SET gm_i_bbd_contact_no5125_req->long_text_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_contact_no5125_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_contact_no5125_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_contact_no5125_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_contact_no5125_req->active_status_prsnl_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_contact_no5125_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_contact_no5125_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_contact_no5125_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_bbd_contact_no5125_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_contact_no5125_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_contact_no5125_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_contact_no5125_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_contact_no5125_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "create_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_contact_no5125_req->qual[iqual].create_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_contact_no5125_req->create_dt_tmi = 1
    OF "active_status_dt_tm":
     SET gm_i_bbd_contact_no5125_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_contact_no5125_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_contact_no5125_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_contact_no5125_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_contact_no5125_def "U"
 DECLARE gm_u_bbd_contact_no5125_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_contact_no5125_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_contact_no5125_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_contact_no5125_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_contact_no5125_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_contact_no5125_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_contact_no5125_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "contact_note_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_contact_no5125_req->contact_note_idf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].contact_note_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->contact_note_idw = 1
     ENDIF
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_contact_no5125_req->contact_idf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->contact_idw = 1
     ENDIF
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_contact_no5125_req->encntr_idf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].encntr_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->encntr_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_contact_no5125_req->person_idf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->person_idw = 1
     ENDIF
    OF "contact_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_contact_no5125_req->contact_type_cdf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].contact_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->contact_type_cdw = 1
     ENDIF
    OF "long_text_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_contact_no5125_req->long_text_idf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].long_text_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->long_text_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_contact_no5125_req->active_status_cdf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_contact_no5125_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_contact_no5125_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_contact_no5125_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_contact_no5125_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_bbd_contact_no5125_req->active_indf = 2
     ELSE
      SET gm_u_bbd_contact_no5125_req->active_indf = 1
     ENDIF
     SET gm_u_bbd_contact_no5125_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_contact_no5125_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_contact_no5125_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_contact_no5125_req->qual,iqual)
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
     SET gm_u_bbd_contact_no5125_req->updt_cntf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_contact_no5125_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_contact_no5125_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_contact_no5125_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "create_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_contact_no5125_req->create_dt_tmf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].create_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->create_dt_tmw = 1
     ENDIF
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_contact_no5125_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_bbd_contact_no5125_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_contact_no5125_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_contact_no5125_req->updt_dt_tmf = 1
     SET gm_u_bbd_contact_no5125_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_contact_no5125_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_donor_cont5127_def "I"
 DECLARE gm_i_bbd_donor_cont5127_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donor_cont5127_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donor_cont5127_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_donor_cont5127_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donor_cont5127_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donor_cont5127_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "contact_reltn_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont5127_req->qual[iqual].contact_reltn_id = ival
     SET gm_i_bbd_donor_cont5127_req->contact_reltn_idi = 1
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont5127_req->qual[iqual].contact_id = ival
     SET gm_i_bbd_donor_cont5127_req->contact_idi = 1
    OF "related_contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont5127_req->qual[iqual].related_contact_id = ival
     SET gm_i_bbd_donor_cont5127_req->related_contact_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont5127_req->qual[iqual].person_id = ival
     SET gm_i_bbd_donor_cont5127_req->person_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont5127_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_donor_cont5127_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont5127_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_donor_cont5127_req->active_status_prsnl_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donor_cont5127_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donor_cont5127_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donor_cont5127_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_bbd_donor_cont5127_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_donor_cont5127_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donor_cont5127_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donor_cont5127_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donor_cont5127_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     SET gm_i_bbd_donor_cont5127_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donor_cont5127_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_cont5127_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donor_cont5127_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_donor_cont5127_def "U"
 DECLARE gm_u_bbd_donor_cont5127_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donor_cont5127_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donor_cont5127_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donor_cont5127_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_donor_cont5127_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_cont5127_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_cont5127_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "contact_reltn_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont5127_req->contact_reltn_idf = 1
     SET gm_u_bbd_donor_cont5127_req->qual[iqual].contact_reltn_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont5127_req->contact_reltn_idw = 1
     ENDIF
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont5127_req->contact_idf = 1
     SET gm_u_bbd_donor_cont5127_req->qual[iqual].contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont5127_req->contact_idw = 1
     ENDIF
    OF "related_contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont5127_req->related_contact_idf = 1
     SET gm_u_bbd_donor_cont5127_req->qual[iqual].related_contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont5127_req->related_contact_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont5127_req->person_idf = 1
     SET gm_u_bbd_donor_cont5127_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont5127_req->person_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont5127_req->active_status_cdf = 1
     SET gm_u_bbd_donor_cont5127_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont5127_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont5127_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_donor_cont5127_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont5127_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donor_cont5127_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_cont5127_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_cont5127_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_bbd_donor_cont5127_req->active_indf = 2
     ELSE
      SET gm_u_bbd_donor_cont5127_req->active_indf = 1
     ENDIF
     SET gm_u_bbd_donor_cont5127_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont5127_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donor_cont5127_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_cont5127_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_cont5127_req->qual,iqual)
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
     SET gm_u_bbd_donor_cont5127_req->updt_cntf = 1
     SET gm_u_bbd_donor_cont5127_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont5127_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donor_cont5127_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_cont5127_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_cont5127_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_donor_cont5127_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_bbd_donor_cont5127_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_donor_cont5127_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont5127_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_cont5127_req->updt_dt_tmf = 1
     SET gm_u_bbd_donor_cont5127_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donor_cont5127_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_donor_elig2144_def "I"
 DECLARE gm_i_bbd_donor_elig2144_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donor_elig2144_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_donor_elig2144_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_donor_elig2144_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donor_elig2144_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donor_elig2144_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "eligibility_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].eligibility_id = ival
     SET gm_i_bbd_donor_elig2144_req->eligibility_idi = 1
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].contact_id = ival
     SET gm_i_bbd_donor_elig2144_req->contact_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].person_id = ival
     SET gm_i_bbd_donor_elig2144_req->person_idi = 1
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].encntr_id = ival
     SET gm_i_bbd_donor_elig2144_req->encntr_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_donor_elig2144_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_donor_elig2144_req->active_status_prsnl_idi = 1
    OF "eligibility_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].eligibility_type_cd = ival
     SET gm_i_bbd_donor_elig2144_req->eligibility_type_cdi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donor_elig2144_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donor_elig2144_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donor_elig2144_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_donor_elig2144_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_donor_elig2144_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_donor_elig2144_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_donor_elig2144_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donor_elig2144_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donor_elig2144_req->updt_dt_tmi = 1
    OF "eligible_dt_tm":
     SET gm_i_bbd_donor_elig2144_req->qual[iqual].eligible_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_donor_elig2144_req->eligible_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_donor_elig2144_def "U"
 DECLARE gm_u_bbd_donor_elig2144_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donor_elig2144_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donor_elig2144_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_donor_elig2144_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_donor_elig2144_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_elig2144_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_elig2144_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "eligibility_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->eligibility_idf = 1
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].eligibility_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->eligibility_idw = 1
     ENDIF
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->contact_idf = 1
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->contact_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->person_idf = 1
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->person_idw = 1
     ENDIF
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->encntr_idf = 1
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].encntr_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->encntr_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->active_status_cdf = 1
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->active_status_prsnl_idw = 1
     ENDIF
    OF "eligibility_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->eligibility_type_cdf = 1
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].eligibility_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->eligibility_type_cdw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donor_elig2144_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_elig2144_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_elig2144_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_bbd_donor_elig2144_req->active_indf = 2
     ELSE
      SET gm_u_bbd_donor_elig2144_req->active_indf = 1
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donor_elig2144_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_elig2144_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_elig2144_req->qual,iqual)
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
     SET gm_u_bbd_donor_elig2144_req->updt_cntf = 1
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_donor_elig2144_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_donor_elig2144_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_donor_elig2144_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_donor_elig2144_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_bbd_donor_elig2144_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->updt_dt_tmf = 1
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->updt_dt_tmw = 1
     ENDIF
    OF "eligible_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_donor_elig2144_req->eligible_dt_tmf = 2
     ELSE
      SET gm_u_bbd_donor_elig2144_req->eligible_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_donor_elig2144_req->qual[iqual].eligible_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_donor_elig2144_req->eligible_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_deferral_r2145_def "I"
 DECLARE gm_i_bbd_deferral_r2145_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_deferral_r2145_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bbd_deferral_r2145_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bbd_deferral_r2145_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_deferral_r2145_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_deferral_r2145_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "deferral_reason_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].deferral_reason_id = ival
     SET gm_i_bbd_deferral_r2145_req->deferral_reason_idi = 1
    OF "eligibility_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].eligibility_id = ival
     SET gm_i_bbd_deferral_r2145_req->eligibility_idi = 1
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].contact_id = ival
     SET gm_i_bbd_deferral_r2145_req->contact_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].person_id = ival
     SET gm_i_bbd_deferral_r2145_req->person_idi = 1
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].encntr_id = ival
     SET gm_i_bbd_deferral_r2145_req->encntr_idi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].active_status_cd = ival
     SET gm_i_bbd_deferral_r2145_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bbd_deferral_r2145_req->active_status_prsnl_idi = 1
    OF "reason_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].reason_cd = ival
     SET gm_i_bbd_deferral_r2145_req->reason_cdi = 1
    OF "result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].result_id = ival
     SET gm_i_bbd_deferral_r2145_req->result_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_deferral_r2145_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_deferral_r2145_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_deferral_r2145_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].active_ind = ival
     SET gm_i_bbd_deferral_r2145_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bbd_deferral_r2145_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bbd_deferral_r2145_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bbd_deferral_r2145_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_deferral_r2145_req->active_status_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_deferral_r2145_req->updt_dt_tmi = 1
    OF "eligible_dt_tm":
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].eligible_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_deferral_r2145_req->eligible_dt_tmi = 1
    OF "occurred_dt_tm":
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].occurred_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_deferral_r2145_req->occurred_dt_tmi = 1
    OF "calc_elig_dt_tm":
     SET gm_i_bbd_deferral_r2145_req->qual[iqual].calc_elig_dt_tm = cnvtdatetime(ival)
     SET gm_i_bbd_deferral_r2145_req->calc_elig_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bbd_deferral_r2145_def "U"
 DECLARE gm_u_bbd_deferral_r2145_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_deferral_r2145_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_deferral_r2145_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bbd_deferral_r2145_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bbd_deferral_r2145_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_deferral_r2145_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_deferral_r2145_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "deferral_reason_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->deferral_reason_idf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].deferral_reason_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->deferral_reason_idw = 1
     ENDIF
    OF "eligibility_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->eligibility_idf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].eligibility_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->eligibility_idw = 1
     ENDIF
    OF "contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->contact_idf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->contact_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->person_idf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->person_idw = 1
     ENDIF
    OF "encntr_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->encntr_idf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].encntr_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->encntr_idw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->active_status_cdf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->active_status_prsnl_idf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->active_status_prsnl_idw = 1
     ENDIF
    OF "reason_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->reason_cdf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].reason_cd = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->reason_cdw = 1
     ENDIF
    OF "result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->result_idf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].result_id = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->result_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_deferral_r2145_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_deferral_r2145_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_deferral_r2145_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_bbd_deferral_r2145_req->active_indf = 2
     ELSE
      SET gm_u_bbd_deferral_r2145_req->active_indf = 1
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_deferral_r2145_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_deferral_r2145_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_deferral_r2145_req->qual,iqual)
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
     SET gm_u_bbd_deferral_r2145_req->updt_cntf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bbd_deferral_r2145_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bbd_deferral_r2145_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bbd_deferral_r2145_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_deferral_r2145_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_bbd_deferral_r2145_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->active_status_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->updt_dt_tmf = 1
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->updt_dt_tmw = 1
     ENDIF
    OF "eligible_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_deferral_r2145_req->eligible_dt_tmf = 2
     ELSE
      SET gm_u_bbd_deferral_r2145_req->eligible_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].eligible_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->eligible_dt_tmw = 1
     ENDIF
    OF "occurred_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_deferral_r2145_req->occurred_dt_tmf = 2
     ELSE
      SET gm_u_bbd_deferral_r2145_req->occurred_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].occurred_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->occurred_dt_tmw = 1
     ENDIF
    OF "calc_elig_dt_tm":
     IF (null_ind=1)
      SET gm_u_bbd_deferral_r2145_req->calc_elig_dt_tmf = 2
     ELSE
      SET gm_u_bbd_deferral_r2145_req->calc_elig_dt_tmf = 1
     ENDIF
     SET gm_u_bbd_deferral_r2145_req->qual[iqual].calc_elig_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bbd_deferral_r2145_req->calc_elig_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bb_exception1445_def "I"
 DECLARE gm_i_bb_exception1445_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bb_exception1445_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bb_exception1445_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_bb_exception1445_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_bb_exception1445_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bb_exception1445_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bb_exception1445_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "exception_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].exception_id = ival
     SET gm_i_bb_exception1445_req->exception_idi = 1
    OF "product_event_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].product_event_id = ival
     SET gm_i_bb_exception1445_req->product_event_idi = 1
    OF "exception_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].exception_type_cd = ival
     SET gm_i_bb_exception1445_req->exception_type_cdi = 1
    OF "override_reason_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].override_reason_cd = ival
     SET gm_i_bb_exception1445_req->override_reason_cdi = 1
    OF "event_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].event_type_cd = ival
     SET gm_i_bb_exception1445_req->event_type_cdi = 1
    OF "result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].result_id = ival
     SET gm_i_bb_exception1445_req->result_idi = 1
    OF "from_abo_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].from_abo_cd = ival
     SET gm_i_bb_exception1445_req->from_abo_cdi = 1
    OF "from_rh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].from_rh_cd = ival
     SET gm_i_bb_exception1445_req->from_rh_cdi = 1
    OF "to_abo_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].to_abo_cd = ival
     SET gm_i_bb_exception1445_req->to_abo_cdi = 1
    OF "to_rh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].to_rh_cd = ival
     SET gm_i_bb_exception1445_req->to_rh_cdi = 1
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].active_status_cd = ival
     SET gm_i_bb_exception1445_req->active_status_cdi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_bb_exception1445_req->active_status_prsnl_idi = 1
    OF "perform_result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].perform_result_id = ival
     SET gm_i_bb_exception1445_req->perform_result_idi = 1
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].person_id = ival
     SET gm_i_bb_exception1445_req->person_idi = 1
    OF "donor_contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].donor_contact_id = ival
     SET gm_i_bb_exception1445_req->donor_contact_idi = 1
    OF "donor_contact_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].donor_contact_type_cd = ival
     SET gm_i_bb_exception1445_req->donor_contact_type_cdi = 1
    OF "review_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].review_status_cd = ival
     SET gm_i_bb_exception1445_req->review_status_cdi = 1
    OF "review_by_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].review_by_prsnl_id = ival
     SET gm_i_bb_exception1445_req->review_by_prsnl_idi = 1
    OF "review_doc_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].review_doc_id = ival
     SET gm_i_bb_exception1445_req->review_doc_idi = 1
    OF "exception_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].exception_prsnl_id = ival
     SET gm_i_bb_exception1445_req->exception_prsnl_idi = 1
    OF "order_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].order_id = ival
     SET gm_i_bb_exception1445_req->order_idi = 1
    OF "person_abo_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].person_abo_cd = ival
     SET gm_i_bb_exception1445_req->person_abo_cdi = 1
    OF "person_rh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].person_rh_cd = ival
     SET gm_i_bb_exception1445_req->person_rh_cdi = 1
    OF "product_abo_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].product_abo_cd = ival
     SET gm_i_bb_exception1445_req->product_abo_cdi = 1
    OF "product_rh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].product_rh_cd = ival
     SET gm_i_bb_exception1445_req->product_rh_cdi = 1
    OF "procedure_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].procedure_cd = ival
     SET gm_i_bb_exception1445_req->procedure_cdi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bb_exception1445_i2(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bb_exception1445_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bb_exception1445_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_bb_exception1445_req->qual[iqual].active_ind = ival
     SET gm_i_bb_exception1445_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bb_exception1445_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bb_exception1445_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bb_exception1445_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_bb_exception1445_req->updt_dt_tmi = 1
    OF "active_status_dt_tm":
     SET gm_i_bb_exception1445_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_bb_exception1445_req->active_status_dt_tmi = 1
    OF "review_dt_tm":
     SET gm_i_bb_exception1445_req->qual[iqual].review_dt_tm = cnvtdatetime(ival)
     SET gm_i_bb_exception1445_req->review_dt_tmi = 1
    OF "exception_dt_tm":
     SET gm_i_bb_exception1445_req->qual[iqual].exception_dt_tm = cnvtdatetime(ival)
     SET gm_i_bb_exception1445_req->exception_dt_tmi = 1
    OF "default_expire_dt_tm":
     SET gm_i_bb_exception1445_req->qual[iqual].default_expire_dt_tm = cnvtdatetime(ival)
     SET gm_i_bb_exception1445_req->default_expire_dt_tmi = 1
    OF "ineligible_until_dt_tm":
     SET gm_i_bb_exception1445_req->qual[iqual].ineligible_until_dt_tm = cnvtdatetime(ival)
     SET gm_i_bb_exception1445_req->ineligible_until_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_bb_exception1445_vc(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bb_exception1445_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bb_exception1445_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "donation_ident":
     IF (null_ind=1)
      SET gm_i_bb_exception1445_req->donation_identn = 1
     ENDIF
     SET gm_i_bb_exception1445_req->qual[iqual].donation_ident = ival
     SET gm_i_bb_exception1445_req->donation_identi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bb_exception1445_def "U"
 DECLARE gm_u_bb_exception1445_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bb_exception1445_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bb_exception1445_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bb_exception1445_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_bb_exception1445_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_bb_exception1445_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bb_exception1445_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bb_exception1445_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "exception_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->exception_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].exception_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->exception_idw = 1
     ENDIF
    OF "product_event_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->product_event_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].product_event_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->product_event_idw = 1
     ENDIF
    OF "exception_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->exception_type_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].exception_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->exception_type_cdw = 1
     ENDIF
    OF "override_reason_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->override_reason_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].override_reason_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->override_reason_cdw = 1
     ENDIF
    OF "event_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->event_type_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].event_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->event_type_cdw = 1
     ENDIF
    OF "result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->result_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].result_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->result_idw = 1
     ENDIF
    OF "from_abo_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->from_abo_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].from_abo_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->from_abo_cdw = 1
     ENDIF
    OF "from_rh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->from_rh_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].from_rh_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->from_rh_cdw = 1
     ENDIF
    OF "to_abo_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->to_abo_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].to_abo_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->to_abo_cdw = 1
     ENDIF
    OF "to_rh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->to_rh_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].to_rh_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->to_rh_cdw = 1
     ENDIF
    OF "active_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->active_status_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].active_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->active_status_cdw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->active_status_prsnl_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->active_status_prsnl_idw = 1
     ENDIF
    OF "perform_result_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->perform_result_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].perform_result_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->perform_result_idw = 1
     ENDIF
    OF "person_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->person_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].person_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->person_idw = 1
     ENDIF
    OF "donor_contact_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->donor_contact_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].donor_contact_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->donor_contact_idw = 1
     ENDIF
    OF "donor_contact_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->donor_contact_type_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].donor_contact_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->donor_contact_type_cdw = 1
     ENDIF
    OF "review_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->review_status_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].review_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->review_status_cdw = 1
     ENDIF
    OF "review_by_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->review_by_prsnl_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].review_by_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->review_by_prsnl_idw = 1
     ENDIF
    OF "review_doc_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->review_doc_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].review_doc_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->review_doc_idw = 1
     ENDIF
    OF "exception_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->exception_prsnl_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].exception_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->exception_prsnl_idw = 1
     ENDIF
    OF "order_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->order_idf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].order_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->order_idw = 1
     ENDIF
    OF "person_abo_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->person_abo_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].person_abo_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->person_abo_cdw = 1
     ENDIF
    OF "person_rh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->person_rh_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].person_rh_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->person_rh_cdw = 1
     ENDIF
    OF "product_abo_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->product_abo_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].product_abo_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->product_abo_cdw = 1
     ENDIF
    OF "product_rh_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->product_rh_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].product_rh_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->product_rh_cdw = 1
     ENDIF
    OF "procedure_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->procedure_cdf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].procedure_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->procedure_cdw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bb_exception1445_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bb_exception1445_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bb_exception1445_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_bb_exception1445_req->active_indf = 2
     ELSE
      SET gm_u_bb_exception1445_req->active_indf = 1
     ENDIF
     SET gm_u_bb_exception1445_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bb_exception1445_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bb_exception1445_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bb_exception1445_req->qual,iqual)
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
     SET gm_u_bb_exception1445_req->updt_cntf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bb_exception1445_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bb_exception1445_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bb_exception1445_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_exception1445_req->updt_dt_tmf = 1
     SET gm_u_bb_exception1445_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->updt_dt_tmw = 1
     ENDIF
    OF "active_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_bb_exception1445_req->active_status_dt_tmf = 2
     ELSE
      SET gm_u_bb_exception1445_req->active_status_dt_tmf = 1
     ENDIF
     SET gm_u_bb_exception1445_req->qual[iqual].active_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->active_status_dt_tmw = 1
     ENDIF
    OF "review_dt_tm":
     IF (null_ind=1)
      SET gm_u_bb_exception1445_req->review_dt_tmf = 2
     ELSE
      SET gm_u_bb_exception1445_req->review_dt_tmf = 1
     ENDIF
     SET gm_u_bb_exception1445_req->qual[iqual].review_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->review_dt_tmw = 1
     ENDIF
    OF "exception_dt_tm":
     IF (null_ind=1)
      SET gm_u_bb_exception1445_req->exception_dt_tmf = 2
     ELSE
      SET gm_u_bb_exception1445_req->exception_dt_tmf = 1
     ENDIF
     SET gm_u_bb_exception1445_req->qual[iqual].exception_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->exception_dt_tmw = 1
     ENDIF
    OF "default_expire_dt_tm":
     IF (null_ind=1)
      SET gm_u_bb_exception1445_req->default_expire_dt_tmf = 2
     ELSE
      SET gm_u_bb_exception1445_req->default_expire_dt_tmf = 1
     ENDIF
     SET gm_u_bb_exception1445_req->qual[iqual].default_expire_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->default_expire_dt_tmw = 1
     ENDIF
    OF "ineligible_until_dt_tm":
     IF (null_ind=1)
      SET gm_u_bb_exception1445_req->ineligible_until_dt_tmf = 2
     ELSE
      SET gm_u_bb_exception1445_req->ineligible_until_dt_tmf = 1
     ENDIF
     SET gm_u_bb_exception1445_req->qual[iqual].ineligible_until_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->ineligible_until_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_bb_exception1445_vc(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bb_exception1445_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bb_exception1445_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "donation_ident":
     IF (null_ind=1)
      SET gm_u_bb_exception1445_req->donation_identf = 2
     ELSE
      SET gm_u_bb_exception1445_req->donation_identf = 1
     ENDIF
     SET gm_u_bb_exception1445_req->qual[iqual].donation_ident = ival
     IF (wq_ind=1)
      SET gm_u_bb_exception1445_req->donation_identw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 DECLARE script_name = c16 WITH constant("bbd_upd_contacts")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE add_ind = i2 WITH constant(1)
 DECLARE change_ind = i2 WITH constant(2)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE i_idx = i4 WITH protect, noconstant(0)
 DECLARE j_idx = i4 WITH protect, noconstant(0)
 DECLARE contact_type_cs = i4 WITH constant(14220)
 DECLARE contact_counsel_mean = c12 WITH constant("COUNSEL")
 DECLARE contact_counsel_cd = f8 WITH protect, noconstant(0.0)
 DECLARE contact_conf_mean = c12 WITH constant("CONFIDENTIAL")
 DECLARE contact_conf_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dreplacednoteid = f8 WITH protect, noconstant(0.0)
 SET contact_counsel_cd = uar_get_code_by("MEANING",contact_type_cs,nullterm(contact_counsel_mean))
 IF (contact_counsel_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(
    contact_counsel_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET contact_conf_cd = uar_get_code_by("MEANING",contact_type_cs,nullterm(contact_conf_mean))
 IF (contact_conf_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(
    contact_conf_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 FOR (i_idx = 1 TO size(request->contactlist,5))
   IF ((request->contactlist[i_idx].add_change_ind=add_ind))
    SET gm_i_bbd_donor_cont1635_req->allow_partial_ind = 0
    SET stat = gm_i_bbd_donor_cont1635_i2("ACTIVE_IND",request->contactlist[i_idx].active_ind,1,0)
    IF ((request->contactlist[i_idx].active_ind=1))
     IF (stat=1)
      SET stat = gm_i_bbd_donor_cont1635_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_donor_cont1635_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0
       )
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_donor_cont1635_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
     ENDIF
    ELSEIF ((request->contactlist[i_idx].active_ind=0))
     IF (stat=1)
      SET stat = gm_i_bbd_donor_cont1635_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_dq8("CONTACT_DT_TM",request->contactlist[i_idx].contact_dt_tm,
      1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_f8("CONTACT_OUTCOME_CD",request->contactlist[i_idx].
      contact_outcome_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_f8("CONTACT_STATUS_CD",request->contactlist[i_idx].
      contact_status_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_f8("CONTACT_TYPE_CD",request->contactlist[i_idx].
      contact_type_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_f8("ENCNTR_ID",request->contactlist[i_idx].encounter_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_f8("INIT_CONTACT_PRSNL_ID",request->contactlist[i_idx].
      init_contact_prsnl_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_f8("INVENTORY_AREA_CD",request->contactlist[i_idx].
      inventory_area_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_dq8("NEEDED_DT_TM",request->contactlist[i_idx].needed_dt_tm,1,
      0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_f8("ORGANIZATION_ID",request->contactlist[i_idx].
      organization_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_f8("OWNER_AREA_CD",request->contactlist[i_idx].owner_area_cd,
      1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_cont1635_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_i_bbd_donor_cont1635  WITH replace(request,gm_i_bbd_donor_cont1635_req), replace(
      reply,gm_i_bbd_donor_cont1635_rep)
     IF ((gm_i_bbd_donor_cont1635_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_DONOR_CONTACT",gm_i_bbd_donor_cont1635_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONOR_CONTACT","Insert failed.")
    ENDIF
   ELSEIF ((request->contactlist[i_idx].add_change_ind=change_ind))
    SET gm_u_bbd_donor_cont1635_req->allow_partial_ind = 0
    SET gm_u_bbd_donor_cont1635_req->force_updt_ind = 0
    SET stat = gm_u_bbd_donor_cont1635_i2("ACTIVE_IND",request->contactlist[i_idx].active_ind,1,0,0)
    IF ((request->contactlist[i_idx].active_ind=0))
     IF (stat=1)
      SET stat = gm_u_bbd_donor_cont1635_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_dq8("CONTACT_DT_TM",request->contactlist[i_idx].contact_dt_tm,
      1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0,1)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_f8("CONTACT_OUTCOME_CD",request->contactlist[i_idx].
      contact_outcome_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_f8("CONTACT_STATUS_CD",request->contactlist[i_idx].
      contact_status_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_f8("CONTACT_TYPE_CD",request->contactlist[i_idx].
      contact_type_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_f8("ENCNTR_ID",request->contactlist[i_idx].encounter_id,1,0,0
      )
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_f8("INIT_CONTACT_PRSNL_ID",request->contactlist[i_idx].
      init_contact_prsnl_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_f8("INVENTORY_AREA_CD",request->contactlist[i_idx].
      inventory_area_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_dq8("NEEDED_DT_TM",request->contactlist[i_idx].needed_dt_tm,1,
      0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_f8("ORGANIZATION_ID",request->contactlist[i_idx].
      organization_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_f8("OWNER_AREA_CD",request->contactlist[i_idx].owner_area_cd,
      1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_cont1635_i4("UPDT_CNT",request->contactlist[i_idx].updt_cnt,1,0,1)
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_bbd_donor_cont1635  WITH replace(request,gm_u_bbd_donor_cont1635_req), replace(
      reply,gm_u_bbd_donor_cont1635_rep)
     IF ((gm_u_bbd_donor_cont1635_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_DONOR_CONTACT",gm_u_bbd_donor_cont1635_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONOR_CONTACT","Update failed.")
    ENDIF
   ENDIF
   IF ((request->contactlist[i_idx].contactcounselingother.other_contact_id > 0.0)
    AND (request->contactlist[i_idx].contactcounselingother.add_change_ind=add_ind))
    SET gm_i_bbd_other_cont3472_req->allow_partial_ind = 0
    SET stat = gm_i_bbd_other_cont3472_i2("ACTIVE_IND",request->contactlist[i_idx].active_ind,1,0)
    IF ((request->contactlist[i_idx].active_ind=1))
     IF (stat=1)
      SET stat = gm_i_bbd_other_cont3472_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_other_cont3472_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0
       )
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_other_cont3472_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
     ENDIF
    ELSEIF ((request->contactlist[i_idx].active_ind=0))
     IF (stat=1)
      SET stat = gm_i_bbd_other_cont3472_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_other_cont3472_dq8("CONTACT_DT_TM",request->contactlist[i_idx].contact_dt_tm,
      1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_other_cont3472_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_other_cont3472_f8("CONTACT_PRSNL_ID",request->contactlist[i_idx].
      contactcounselingother.contact_prsnl_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_other_cont3472_i2("FOLLOW_UP_IND",request->contactlist[i_idx].
      contactcounselingother.follow_up_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_other_cont3472_f8("METHOD_CD",request->contactlist[i_idx].
      contactcounselingother.method_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_other_cont3472_f8("OTHER_CONTACT_ID",request->contactlist[i_idx].
      contactcounselingother.other_contact_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_other_cont3472_f8("OUTCOME_CD",request->contactlist[i_idx].
      contact_outcome_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_other_cont3472_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_other_cont3472_vc("DONATION_IDENT",request->contactlist[i_idx].
      donation_ident,1,0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_i_bbd_other_cont3472  WITH replace(request,gm_i_bbd_other_cont3472_req), replace(
      reply,gm_i_bbd_other_cont3472_rep)
     IF ((gm_i_bbd_other_cont3472_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_OTHER_CONTACT",gm_i_bbd_other_cont3472_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_OTHER_CONTACT","Insert failed.")
    ENDIF
   ELSEIF ((request->contactlist[i_idx].contactcounselingother.other_contact_id > 0.0)
    AND (request->contactlist[i_idx].contactcounselingother.add_change_ind=change_ind))
    SET gm_u_bbd_other_cont3472_req->allow_partial_ind = 0
    SET gm_u_bbd_other_cont3472_req->force_updt_ind = 0
    SET stat = gm_u_bbd_other_cont3472_i2("ACTIVE_IND",request->contactlist[i_idx].active_ind,1,0,0)
    IF ((request->contactlist[i_idx].active_ind=0))
     IF (stat=1)
      SET stat = gm_u_bbd_other_cont3472_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_other_cont3472_dq8("CONTACT_DT_TM",request->contactlist[i_idx].contact_dt_tm,
      1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_other_cont3472_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_other_cont3472_f8("CONTACT_PRSNL_ID",request->contactlist[i_idx].
      contactcounselingother.contact_prsnl_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_other_cont3472_i2("FOLLOW_UP_IND",request->contactlist[i_idx].
      contactcounselingother.follow_up_ind,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_other_cont3472_f8("METHOD_CD",request->contactlist[i_idx].
      contactcounselingother.method_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_other_cont3472_f8("OTHER_CONTACT_ID",request->contactlist[i_idx].
      contactcounselingother.other_contact_id,1,0,1)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_other_cont3472_f8("OUTCOME_CD",request->contactlist[i_idx].
      contact_outcome_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_other_cont3472_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_other_cont3472_i4("UPDT_CNT",request->contactlist[i_idx].
      contactcounselingother.updt_cnt,1,0,1)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_other_cont3472_vc("DONATION_IDENT",request->contactlist[i_idx].
      contactcounselingother.donation_ident,1,0,0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_bbd_other_cont3472  WITH replace(request,gm_u_bbd_other_cont3472_req), replace(
      reply,gm_u_bbd_other_cont3472_rep)
     IF ((gm_u_bbd_other_cont3472_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_OTHER_CONTACT",gm_u_bbd_other_cont3472_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_OTHER_CONTACT","Update failed.")
    ENDIF
   ENDIF
   IF ((request->contactlist[i_idx].contactdonation.donation_result_id > 0.0)
    AND (request->contactlist[i_idx].contactdonation.add_change_ind=add_ind))
    SET gm_i_bbd_donation_r2146_req->allow_partial_ind = 0
    SET stat = gm_i_bbd_donation_r2146_i2("ACTIVE_IND",request->contactlist[i_idx].active_ind,1,0)
    IF ((request->contactlist[i_idx].active_ind=1))
     IF (stat=1)
      SET stat = gm_i_bbd_donation_r2146_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_donation_r2146_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0
       )
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_donation_r2146_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
     ENDIF
    ELSEIF ((request->contactlist[i_idx].active_ind=0))
     IF (stat=1)
      SET stat = gm_i_bbd_donation_r2146_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("BAG_TYPE_CD",request->contactlist[i_idx].contactdonation.
      bag_type_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("DONATION_RESULT_ID",request->contactlist[i_idx].
      contactdonation.donation_result_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_dq8("DRAWN_DT_TM",request->contactlist[i_idx].contactdonation
      .drawn_dt_tm,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("DRAW_STATION_CD",request->contactlist[i_idx].
      contactdonation.draw_station_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("ENCNTR_ID",request->contactlist[i_idx].encounter_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("INV_AREA_CD",request->contactlist[i_idx].contactdonation.
      inv_area_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("OUTCOME_CD",request->contactlist[i_idx].
      contact_outcome_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("OWNER_AREA_CD",request->contactlist[i_idx].
      contactdonation.owner_area_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("PHLEB_PRSNL_ID",request->contactlist[i_idx].
      contactdonation.phleb_prsnl_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("PROCEDURE_CD",request->contactlist[i_idx].contactdonation
      .procedure_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("SPECIMEN_UNIT_MEAS_CD",request->contactlist[i_idx].
      contactdonation.specimen_unit_meas_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_i4("SPECIMEN_VOLUME",request->contactlist[i_idx].
      contactdonation.specimen_volume,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_dq8("START_DT_TM",request->contactlist[i_idx].contactdonation
      .start_dt_tm,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_dq8("STOP_DT_TM",request->contactlist[i_idx].contactdonation.
      stop_dt_tm,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_i4("TOTAL_VOLUME",request->contactlist[i_idx].contactdonation
      .total_volume,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donation_r2146_f8("VENIPUNCTURE_SITE_CD",request->contactlist[i_idx].
      contactdonation.venipuncture_site_cd,1,0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_i_bbd_donation_r2146  WITH replace(request,gm_i_bbd_donation_r2146_req), replace(
      reply,gm_i_bbd_donation_r2146_rep)
     IF ((gm_i_bbd_donation_r2146_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_DONATION_RESULTS",gm_i_bbd_donation_r2146_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONATION_RESULTS","Insert failed.")
    ENDIF
   ELSEIF ((request->contactlist[i_idx].contactdonation.donation_result_id > 0.0)
    AND (request->contactlist[i_idx].contactdonation.add_change_ind=change_ind))
    SET gm_u_bbd_donation_r2146_req->allow_partial_ind = 0
    SET gm_u_bbd_donation_r2146_req->force_updt_ind = 0
    SET stat = gm_u_bbd_donation_r2146_i2("ACTIVE_IND",request->contactlist[i_idx].active_ind,1,0,0)
    IF ((request->contactlist[i_idx].active_ind=0))
     IF (stat=1)
      SET stat = gm_u_bbd_donation_r2146_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("BAG_TYPE_CD",request->contactlist[i_idx].contactdonation.
      bag_type_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("DONATION_RESULT_ID",request->contactlist[i_idx].
      contactdonation.donation_result_id,1,0,1)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_dq8("DRAWN_DT_TM",request->contactlist[i_idx].contactdonation
      .drawn_dt_tm,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("DRAW_STATION_CD",request->contactlist[i_idx].
      contactdonation.draw_station_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("ENCNTR_ID",request->contactlist[i_idx].encounter_id,1,0,0
      )
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("INV_AREA_CD",request->contactlist[i_idx].contactdonation.
      inv_area_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("OUTCOME_CD",request->contactlist[i_idx].
      contact_outcome_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("OWNER_AREA_CD",request->contactlist[i_idx].
      contactdonation.owner_area_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("PHLEB_PRSNL_ID",request->contactlist[i_idx].
      contactdonation.phleb_prsnl_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("PROCEDURE_CD",request->contactlist[i_idx].contactdonation
      .procedure_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("SPECIMEN_UNIT_MEAS_CD",request->contactlist[i_idx].
      contactdonation.specimen_unit_meas_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_i4("SPECIMEN_VOLUME",request->contactlist[i_idx].
      contactdonation.specimen_volume,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_dq8("START_DT_TM",request->contactlist[i_idx].contactdonation
      .start_dt_tm,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_dq8("STOP_DT_TM",request->contactlist[i_idx].contactdonation.
      stop_dt_tm,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_i4("TOTAL_VOLUME",request->contactlist[i_idx].contactdonation
      .total_volume,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_f8("VENIPUNCTURE_SITE_CD",request->contactlist[i_idx].
      contactdonation.venipuncture_site_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donation_r2146_i4("UPDT_CNT",request->contactlist[i_idx].contactdonation.
      updt_cnt,1,0,1)
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_bbd_donation_r2146  WITH replace(request,gm_u_bbd_donation_r2146_req), replace(
      reply,gm_u_bbd_donation_r2146_rep)
     IF ((gm_u_bbd_donation_r2146_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_DONATION_RESULTS",gm_u_bbd_donation_r2146_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONATION_RESULTS","Update failed.")
    ENDIF
   ENDIF
   IF ((request->contactlist[i_idx].contactdonation.donation_result_id > 0.0))
    FOR (j_idx = 1 TO size(request->contactlist[i_idx].contactdonation.donationproductlist,5))
      IF ((request->contactlist[i_idx].contactdonation.donationproductlist[j_idx].add_change_ind=
      add_ind))
       SET gm_i_bbd_don_produc2147_req->allow_partial_ind = 0
       SET stat = gm_i_bbd_don_produc2147_i2("ACTIVE_IND",request->contactlist[i_idx].contactdonation
        .donationproductlist[j_idx].active_ind,1,0)
       IF ((request->contactlist[i_idx].contactdonation.donationproductlist[j_idx].active_ind=1))
        IF (stat=1)
         SET stat = gm_i_bbd_don_produc2147_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_don_produc2147_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),
          1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_don_produc2147_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
        ENDIF
       ELSEIF ((request->contactlist[i_idx].contactdonation.donationproductlist[j_idx].active_ind=0))
        IF (stat=1)
         SET stat = gm_i_bbd_don_produc2147_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
        ENDIF
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_don_produc2147_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0
         )
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_don_produc2147_f8("DONATION_PRODUCT_ID",request->contactlist[i_idx].
         contactdonation.donationproductlist[j_idx].donation_product_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_don_produc2147_f8("DONATION_RESULTS_ID",request->contactlist[i_idx].
         contactdonation.donation_result_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_don_produc2147_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_don_produc2147_f8("PRODUCT_ID",request->contactlist[i_idx].
         contactdonation.donationproductlist[j_idx].product_id,1,0)
       ENDIF
       IF (stat=1)
        EXECUTE gm_i_bbd_don_produc2147  WITH replace(request,gm_i_bbd_don_produc2147_req), replace(
         reply,gm_i_bbd_don_produc2147_rep)
        IF ((gm_i_bbd_don_produc2147_rep->status_data.status="F"))
         CALL errorhandler("F","BBD_DON_PRODUCT_R",gm_i_bbd_don_produc2147_rep->qual[1].error_msg)
        ENDIF
       ELSE
        CALL errorhandler("F","BBD_DON_PRODUCT_R","Insert failed.")
       ENDIF
      ELSEIF ((request->contactlist[i_idx].contactdonation.donationproductlist[j_idx].add_change_ind=
      change_ind))
       SET gm_u_bbd_don_produc2147_req->allow_partial_ind = 0
       SET gm_u_bbd_don_produc2147_req->force_updt_ind = 0
       SET stat = gm_u_bbd_don_produc2147_i2("ACTIVE_IND",request->contactlist[i_idx].contactdonation
        .donationproductlist[j_idx].active_ind,1,0,0)
       IF ((request->contactlist[i_idx].contactdonation.donationproductlist[j_idx].active_ind=0))
        IF (stat=1)
         SET stat = gm_u_bbd_don_produc2147_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
        ENDIF
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_don_produc2147_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0,
         0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_don_produc2147_f8("DONATION_PRODUCT_ID",request->contactlist[i_idx].
         contactdonation.donationproductlist[j_idx].donation_product_id,1,0,1)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_don_produc2147_f8("DONATION_RESULTS_ID",request->contactlist[i_idx].
         contactdonation.donation_result_id,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_don_produc2147_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0,0
         )
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_don_produc2147_f8("PRODUCT_ID",request->contactlist[i_idx].
         contactdonation.donationproductlist[j_idx].product_id,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_don_produc2147_i4("UPDT_CNT",request->contactlist[i_idx].contactdonation.
         donationproductlist[j_idx].updt_cnt,1,0,1)
       ENDIF
       IF (stat=1)
        EXECUTE gm_u_bbd_don_produc2147  WITH replace(request,gm_u_bbd_don_produc2147_req), replace(
         reply,gm_u_bbd_don_produc2147_rep)
        IF ((gm_u_bbd_don_produc2147_rep->status_data.status="F"))
         CALL errorhandler("F","BBD_DON_PRODUCT_R",gm_u_bbd_don_produc2147_rep->qual[1].error_msg)
        ENDIF
       ELSE
        CALL errorhandler("F","BBD_DON_PRODUCT_R","Update failed.")
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((request->contactlist[i_idx].contactrecruitment.recruit_result_id > 0.0)
    AND (request->contactlist[i_idx].contactrecruitment.add_change_ind=add_ind))
    SET gm_i_bbd_recruitmen3635_req->allow_partial_ind = 0
    SET stat = gm_i_bbd_recruitmen3635_i2("ACTIVE_IND",request->contactlist[i_idx].active_ind,1,0)
    IF ((request->contactlist[i_idx].active_ind=1))
     IF (stat=1)
      SET stat = gm_i_bbd_recruitmen3635_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_recruitmen3635_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0
       )
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_recruitmen3635_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
     ENDIF
    ELSEIF ((request->contactlist[i_idx].active_ind=0))
     IF (stat=1)
      SET stat = gm_i_bbd_recruitmen3635_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_recruitmen3635_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_recruitmen3635_f8("OUTCOME_CD",request->contactlist[i_idx].
      contact_outcome_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_recruitmen3635_f8("CONTACT_METHOD_CD",request->contactlist[i_idx].
      contactrecruitment.contact_method_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_recruitmen3635_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_recruitmen3635_f8("RECRUIT_LIST_ID",request->contactlist[i_idx].
      contactrecruitment.recruit_list_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_recruitmen3635_f8("RECRUIT_PRSNL_ID",request->contactlist[i_idx].
      contactrecruitment.recruit_prsnl_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_recruitmen3635_f8("RECRUIT_RESULT_ID",request->contactlist[i_idx].
      contactrecruitment.recruit_result_id,1,0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_i_bbd_recruitmen3635  WITH replace(request,gm_i_bbd_recruitmen3635_req), replace(
      reply,gm_i_bbd_recruitmen3635_rep)
     IF ((gm_i_bbd_recruitmen3635_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_RECRUITMENT_RSLTS",gm_i_bbd_recruitmen3635_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_RECRUITMENT_RSLTS","Insert failed.")
    ENDIF
    IF ((request->contactlist[i_idx].contactrecruitment.recruit_list_id > 0))
     SELECT INTO "nl:"
      rdr.recruiting_donor_reltn_id
      FROM bbd_recruiting_donor_reltn rdr
      WHERE (rdr.list_id=request->contactlist[i_idx].contactrecruitment.recruit_list_id)
       AND (rdr.person_id=request->contactlist[i_idx].person_id)
      WITH nocounter, forupdate(rdr)
     ;end select
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Select recruit donor row.",errmsg)
     ENDIF
     IF (curqual > 0)
      UPDATE  FROM bbd_recruiting_donor_reltn rdr
       SET rdr.contact_id = request->contactlist[i_idx].contact_id, rdr.updt_cnt = (rdr.updt_cnt+ 1),
        rdr.updt_applctx = reqinfo->updt_applctx,
        rdr.updt_dt_tm = cnvtdatetime(curdate,curtime3), rdr.updt_id = reqinfo->updt_id, rdr
        .updt_task = reqinfo->updt_task
       WHERE (rdr.list_id=request->contactlist[i_idx].contactrecruitment.recruit_list_id)
        AND (rdr.person_id=request->contactlist[i_idx].person_id)
       WITH nocounter
      ;end update
      SET error_check = error(errmsg,0)
      IF (error_check != 0)
       CALL errorhandler("F","Update recruit donor row.",errmsg)
      ENDIF
     ELSE
      CALL errorhandler("F","Update Failed.",errmsg)
     ENDIF
    ENDIF
   ELSEIF ((request->contactlist[i_idx].contactrecruitment.recruit_result_id > 0.0)
    AND (request->contactlist[i_idx].contactrecruitment.add_change_ind=change_ind))
    SET gm_u_bbd_recruitmen3635_req->allow_partial_ind = 0
    SET gm_u_bbd_recruitmen3635_req->force_updt_ind = 0
    SET stat = gm_u_bbd_recruitmen3635_i2("ACTIVE_IND",request->contactlist[i_idx].active_ind,1,0,0)
    IF ((request->contactlist[i_idx].active_ind=0))
     IF (stat=1)
      SET stat = gm_u_bbd_recruitmen3635_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_recruitmen3635_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_recruitmen3635_f8("OUTCOME_CD",request->contactlist[i_idx].
      contact_outcome_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_recruitmen3635_f8("CONTACT_METHOD_CD",request->contactlist[i_idx].
      contactrecruitment.contact_method_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_recruitmen3635_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_recruitmen3635_f8("RECRUIT_LIST_ID",request->contactlist[i_idx].
      contactrecruitment.recruit_list_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_recruitmen3635_f8("RECRUIT_PRSNL_ID",request->contactlist[i_idx].
      contactrecruitment.recruit_prsnl_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_recruitmen3635_f8("RECRUIT_RESULT_ID",request->contactlist[i_idx].
      contactrecruitment.recruit_result_id,1,0,1)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_recruitmen3635_i4("UPDT_CNT",request->contactlist[i_idx].contactrecruitment.
      updt_cnt,1,0,1)
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_bbd_recruitmen3635  WITH replace(request,gm_u_bbd_recruitmen3635_req), replace(
      reply,gm_u_bbd_recruitmen3635_rep)
     IF ((gm_u_bbd_recruitmen3635_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_RECRUITMENT_RSLTS",gm_u_bbd_recruitmen3635_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_RECRUITMENT_RSLTS","Insert failed.")
    ENDIF
   ENDIF
   IF ((request->contactlist[i_idx].contactnote.contact_note_id > 0.0)
    AND (request->contactlist[i_idx].contactnote.add_change_ind=add_ind))
    IF ((request->contactlist[i_idx].contact_type_cd=contact_counsel_cd))
     SELECT
      cn.counseling_note_id
      FROM bbd_counseling_note cn
      WHERE (cn.person_id=request->contactlist[i_idx].person_id)
       AND cn.active_ind=1
      DETAIL
       dreplacednoteid = cn.counseling_note_id
      WITH nocounter, forupdate(cn)
     ;end select
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Select BBD_Counseling_Note",errmsg)
     ENDIF
     IF (curqual > 0)
      UPDATE  FROM bbd_counseling_note cn
       SET cn.active_ind = 0, cn.updt_cnt = (cn.updt_cnt+ 1), cn.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        cn.updt_id = reqinfo->updt_id, cn.updt_task = reqinfo->updt_task, cn.updt_applctx = reqinfo->
        updt_applctx,
        cn.active_status_cd = reqdata->inactive_status_cd, cn.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3), cn.active_status_prsnl_id = reqinfo->updt_id
       WHERE (cn.person_id=request->contactlist[i_idx].person_id)
        AND cn.active_ind=1
       WITH nocounter
      ;end update
      SET error_check = error(errmsg,0)
      IF (error_check != 0)
       CALL errorhandler("F","Update BBD_Counseling_Note",errmsg)
      ENDIF
      SELECT
       lt.long_text_id
       FROM long_text lt
       WHERE ((lt.parent_entity_id+ 0.0)=dreplacednoteid)
        AND lt.active_ind=1
        AND lt.parent_entity_name="BBD_COUNSELING_NOTE"
       WITH nocounter, forupdate(lt)
      ;end select
      SET error_check = error(errmsg,0)
      IF (error_check != 0)
       CALL errorhandler("F","Select Long_Text",errmsg)
      ENDIF
      IF (curqual > 0)
       UPDATE  FROM long_text lt
        SET lt.active_ind = 0, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo
         ->updt_applctx,
         lt.active_status_cd = reqdata->inactive_status_cd, lt.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3), lt.active_status_prsnl_id = reqinfo->updt_id
        WHERE ((lt.parent_entity_id+ 0.0)=dreplacednoteid)
         AND lt.active_ind=1
         AND lt.parent_entity_name="BBD_COUNSELING_NOTE"
        WITH nocounter
       ;end update
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Update Long_Text",errmsg)
       ENDIF
      ENDIF
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = request->contactlist[i_idx].contactnote.long_text_id, lt.long_text =
       request->contactlist[i_idx].contactnote.note_text, lt.parent_entity_id = request->contactlist[
       i_idx].contactnote.contact_note_id,
       lt.parent_entity_name = "BBD_COUNSELING_NOTE", lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
       updt_applctx,
       lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       lt.active_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Insert Long_Text",errmsg)
     ENDIF
     INSERT  FROM bbd_counseling_note cn
      SET cn.counseling_note_id = request->contactlist[i_idx].contactnote.contact_note_id, cn
       .person_id = request->contactlist[i_idx].person_id, cn.long_text_id = request->contactlist[
       i_idx].contactnote.long_text_id,
       cn.contact_id = request->contactlist[i_idx].contact_id, cn.create_dt_tm = cnvtdatetime(curdate,
        curtime3), cn.active_ind = request->contactlist[i_idx].contactnote.active_ind,
       cn.active_status_cd = reqdata->active_status_cd, cn.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), cn.active_status_prsnl_id = reqinfo->updt_id,
       cn.updt_cnt = 0, cn.updt_dt_tm = cnvtdatetime(curdate,curtime3), cn.updt_id = reqinfo->updt_id,
       cn.updt_task = reqinfo->updt_task, cn.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Insert BBD_Counseling_Note",errmsg)
     ENDIF
    ELSEIF ((request->contactlist[i_idx].contact_type_cd=contact_conf_cd))
     SELECT
      cn.confidential_id
      FROM bbd_confidential_note cn
      WHERE (cn.person_id=request->contactlist[i_idx].person_id)
       AND cn.active_ind=1
      DETAIL
       dreplacednoteid = cn.confidential_id
      WITH nocounter, forupdate(cn)
     ;end select
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Select BBD_Confidential_Note",errmsg)
     ENDIF
     IF (curqual > 0)
      UPDATE  FROM bbd_confidential_note cn
       SET cn.active_ind = 0, cn.updt_cnt = (cn.updt_cnt+ 1), cn.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        cn.updt_id = reqinfo->updt_id, cn.updt_task = reqinfo->updt_task, cn.updt_applctx = reqinfo->
        updt_applctx,
        cn.active_status_cd = reqdata->inactive_status_cd, cn.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3), cn.active_status_prsnl_id = reqinfo->updt_id
       WHERE (cn.person_id=request->contactlist[i_idx].person_id)
        AND cn.active_ind=1
       WITH nocounter
      ;end update
      SET error_check = error(errmsg,0)
      IF (error_check != 0)
       CALL errorhandler("F","Update BBD_Confidential_Note",errmsg)
      ENDIF
      SELECT
       lt.long_text_id
       FROM long_text lt
       WHERE ((lt.parent_entity_id+ 0.0)=dreplacednoteid)
        AND lt.active_ind=1
        AND lt.parent_entity_name="BBD_CONFIDENTIAL_NOTE"
       WITH nocounter, forupdate(lt)
      ;end select
      SET error_check = error(errmsg,0)
      IF (error_check != 0)
       CALL errorhandler("F","Select Long_Text",errmsg)
      ENDIF
      IF (curqual > 0)
       UPDATE  FROM long_text lt
        SET lt.active_ind = 0, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo
         ->updt_applctx,
         lt.active_status_cd = reqdata->inactive_status_cd, lt.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3), lt.active_status_prsnl_id = reqinfo->updt_id
        WHERE ((lt.parent_entity_id+ 0.0)=dreplacednoteid)
         AND lt.active_ind=1
         AND lt.parent_entity_name="BBD_CONFIDENTIAL_NOTE"
        WITH nocounter
       ;end update
       SET error_check = error(errmsg,0)
       IF (error_check != 0)
        CALL errorhandler("F","Update Long_Text",errmsg)
       ENDIF
      ENDIF
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = request->contactlist[i_idx].contactnote.long_text_id, lt.long_text =
       request->contactlist[i_idx].contactnote.note_text, lt.parent_entity_id = request->contactlist[
       i_idx].contactnote.contact_note_id,
       lt.parent_entity_name = "BBD_CONFIDENTIAL_NOTE", lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime
       (curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
       updt_applctx,
       lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       lt.active_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Insert Long_Text",errmsg)
     ENDIF
     INSERT  FROM bbd_confidential_note cn
      SET cn.confidential_id = request->contactlist[i_idx].contactnote.contact_note_id, cn.person_id
        = request->contactlist[i_idx].person_id, cn.long_text_id = request->contactlist[i_idx].
       contactnote.long_text_id,
       cn.contact_id = request->contactlist[i_idx].contact_id, cn.create_dt_tm = cnvtdatetime(curdate,
        curtime3), cn.active_ind = request->contactlist[i_idx].contactnote.active_ind,
       cn.active_status_cd = reqdata->active_status_cd, cn.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), cn.active_status_prsnl_id = reqinfo->updt_id,
       cn.updt_cnt = 0, cn.updt_dt_tm = cnvtdatetime(curdate,curtime3), cn.updt_id = reqinfo->updt_id,
       cn.updt_task = reqinfo->updt_task, cn.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Insert BBD_Confidential_Note",errmsg)
     ENDIF
    ELSE
     SET gm_i_bbd_contact_no5125_req->allow_partial_ind = 0
     SET stat = gm_i_bbd_contact_no5125_i2("ACTIVE_IND",request->contactlist[i_idx].contactnote.
      active_ind,1,0)
     IF ((request->contactlist[i_idx].contactnote.active_ind=1))
      IF (stat=1)
       SET stat = gm_i_bbd_contact_no5125_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_contact_no5125_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,
        0)
      ENDIF
      IF (stat=1)
       SET stat = gm_i_bbd_contact_no5125_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
      ENDIF
     ELSEIF ((request->contactlist[i_idx].contactnote.active_ind=0))
      IF (stat=1)
       SET stat = gm_i_bbd_contact_no5125_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
      ENDIF
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_contact_no5125_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_contact_no5125_f8("CONTACT_NOTE_ID",request->contactlist[i_idx].contactnote
       .contact_note_id,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_contact_no5125_f8("CONTACT_TYPE_CD",request->contactlist[i_idx].
       contact_type_cd,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_contact_no5125_dq8("CREATE_DT_TM",request->contactlist[i_idx].contactnote.
       create_dt_tm,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_contact_no5125_f8("ENCNTR_ID",request->contactlist[i_idx].encounter_id,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_contact_no5125_f8("LONG_TEXT_ID",request->contactlist[i_idx].contactnote.
       long_text_id,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_contact_no5125_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0)
     ENDIF
     IF (stat=1)
      EXECUTE gm_i_bbd_contact_no5125  WITH replace(request,gm_i_bbd_contact_no5125_req), replace(
       reply,gm_i_bbd_contact_no5125_rep)
      IF ((gm_i_bbd_contact_no5125_rep->status_data.status="F"))
       CALL errorhandler("F","BBD_CONTACT_NOTE",gm_i_bbd_contact_no5125_rep->qual[1].error_msg)
      ENDIF
     ELSE
      CALL errorhandler("F","BBD_CONTACT_NOTE","Insert failed.")
     ENDIF
     INSERT  FROM long_text lt
      SET lt.active_ind = request->contactlist[i_idx].contactnote.active_ind, lt.active_status_cd =
       IF ((request->contactlist[i_idx].contactnote.active_ind=1)) reqdata->active_status_cd
       ELSEIF ((request->contactlist[i_idx].contactnote.active_ind=0)) reqdata->inactive_status_cd
       ENDIF
       , lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = request->contactlist[i_idx].
       contactnote.note_text, lt.long_text_id = request->contactlist[i_idx].contactnote.long_text_id,
       lt.parent_entity_id = request->contactlist[i_idx].contactnote.contact_note_id, lt
       .parent_entity_name = "BBD_CONTACT_NOTE", lt.updt_applctx = reqinfo->updt_applctx,
       lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
       lt.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL errorhandler("F","LONG_TEXT","Insert failed.")
     ENDIF
    ENDIF
   ELSEIF ((request->contactlist[i_idx].contactnote.contact_note_id > 0.0)
    AND (request->contactlist[i_idx].contactnote.add_change_ind=change_ind))
    SET gm_u_bbd_contact_no5125_req->allow_partial_ind = 0
    SET gm_u_bbd_contact_no5125_req->force_updt_ind = 0
    SET stat = gm_u_bbd_contact_no5125_i2("ACTIVE_IND",request->contactlist[i_idx].contactnote.
     active_ind,1,0,0)
    IF ((request->contactlist[i_idx].contactnote.active_ind=0))
     IF (stat=1)
      SET stat = gm_u_bbd_contact_no5125_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_contact_no5125_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_contact_no5125_f8("CONTACT_NOTE_ID",request->contactlist[i_idx].contactnote.
      contact_note_id,1,0,1)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_contact_no5125_f8("CONTACT_TYPE_CD",request->contactlist[i_idx].
      contact_type_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_contact_no5125_dq8("CREATE_DT_TM",request->contactlist[i_idx].contactnote.
      create_dt_tm,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_contact_no5125_f8("ENCNTR_ID",request->contactlist[i_idx].encounter_id,1,0,0
      )
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_contact_no5125_f8("LONG_TEXT_ID",request->contactlist[i_idx].contactnote.
      long_text_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_contact_no5125_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_contact_no5125_i4("UPDT_CNT",request->contactlist[i_idx].contactnote.
      updt_cnt,1,0,1)
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_bbd_contact_no5125  WITH replace(request,gm_u_bbd_contact_no5125_req), replace(
      reply,gm_u_bbd_contact_no5125_rep)
     IF ((gm_u_bbd_contact_no5125_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_CONTACT_NOTE",gm_u_bbd_contact_no5125_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_CONTACT_NOTE","Insert failed.")
    ENDIF
    SELECT INTO "nl:"
     lt.*
     FROM long_text lt
     WHERE (lt.long_text_id=request->contactlist[i_idx].contactnote.long_text_id)
      AND (lt.updt_cnt=request->contactlist[i_idx].contactnote.long_text_updt_cnt)
     WITH nocounter, forupdate(lt)
    ;end select
    IF (curqual=0)
     CALL errorhandler("F","LONG_TEXT","Update lock failed.")
    ENDIF
    UPDATE  FROM long_text lt
     SET lt.active_ind = request->contactlist[i_idx].contactnote.active_ind, lt.active_status_cd =
      IF ((request->contactlist[i_idx].contactnote.active_ind=1)) reqdata->active_status_cd
      ELSEIF ((request->contactlist[i_idx].contactnote.active_ind=0)) reqdata->inactive_status_cd
      ENDIF
      , lt.long_text = request->contactlist[i_idx].contactnote.note_text,
      lt.long_text_id = request->contactlist[i_idx].contactnote.long_text_id, lt.parent_entity_id =
      request->contactlist[i_idx].contactnote.contact_note_id, lt.parent_entity_name =
      "BBD_CONTACT_NOTE",
      lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task
     WHERE (lt.long_text_id=request->contactlist[i_idx].contactnote.long_text_id)
      AND (lt.updt_cnt=request->contactlist[i_idx].contactnote.updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL errorhandler("F","LONG_TEXT","Update failed.")
    ENDIF
   ENDIF
   IF ((request->contactlist[i_idx].contact_id > 0.0))
    FOR (j_idx = 1 TO size(request->contactlist[i_idx].relatedcontactlist,5))
      IF ((request->contactlist[i_idx].relatedcontactlist[j_idx].add_change_ind=add_ind))
       SET gm_i_bbd_donor_cont5127_req->allow_partial_ind = 0
       SET stat = gm_i_bbd_donor_cont5127_i2("ACTIVE_IND",request->contactlist[i_idx].
        relatedcontactlist[j_idx].active_ind,1,0)
       IF ((request->contactlist[i_idx].relatedcontactlist[j_idx].active_ind=1))
        IF (stat=1)
         SET stat = gm_i_bbd_donor_cont5127_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_donor_cont5127_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),
          1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_donor_cont5127_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
        ENDIF
       ELSEIF ((request->contactlist[i_idx].relatedcontactlist[j_idx].active_ind=0))
        IF (stat=1)
         SET stat = gm_i_bbd_donor_cont5127_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
        ENDIF
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_donor_cont5127_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0
         )
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_donor_cont5127_f8("CONTACT_RELTN_ID",request->contactlist[i_idx].
         relatedcontactlist[j_idx].contact_reltn_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_donor_cont5127_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_donor_cont5127_f8("RELATED_CONTACT_ID",request->contactlist[i_idx].
         relatedcontactlist[j_idx].related_contact_id,1,0)
       ENDIF
       IF (stat=1)
        EXECUTE gm_i_bbd_donor_cont5127  WITH replace(request,gm_i_bbd_donor_cont5127_req), replace(
         reply,gm_i_bbd_donor_cont5127_rep)
        IF ((gm_i_bbd_donor_cont5127_rep->status_data.status="F"))
         CALL errorhandler("F","BBD_DONOR_CONTACT_R",gm_i_bbd_donor_cont5127_rep->qual[1].error_msg)
        ENDIF
       ELSE
        CALL errorhandler("F","BBD_DONOR_CONTACT_R","Insert failed.")
       ENDIF
      ELSEIF ((request->contactlist[i_idx].relatedcontactlist[j_idx].add_change_ind=change_ind))
       SET gm_u_bbd_donor_cont5127_req->allow_partial_ind = 0
       SET gm_u_bbd_donor_cont5127_req->force_updt_ind = 0
       SET stat = gm_u_bbd_donor_cont5127_i2("ACTIVE_IND",request->contactlist[i_idx].
        relatedcontactlist[j_idx].active_ind,1,0,0)
       IF ((request->contactlist[i_idx].relatedcontactlist[j_idx].active_ind=0))
        IF (stat=1)
         SET stat = gm_u_bbd_donor_cont5127_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
        ENDIF
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_donor_cont5127_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0,
         0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_donor_cont5127_f8("CONTACT_RELTN_ID",request->contactlist[i_idx].
         relatedcontactlist[j_idx].contact_reltn_id,1,0,1)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_donor_cont5127_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0,0
         )
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_donor_cont5127_f8("RELATED_CONTACT_ID",request->contactlist[i_idx].
         relatedcontactlist[j_idx].related_contact_id,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_donor_cont5127_i4("UPDT_CNT",request->contactlist[i_idx].
         relatedcontactlist[j_idx].updt_cnt,1,0,1)
       ENDIF
       IF (stat=1)
        EXECUTE gm_u_bbd_donor_cont5127  WITH replace(request,gm_u_bbd_donor_cont5127_req), replace(
         reply,gm_u_bbd_donor_cont5127_rep)
        IF ((gm_u_bbd_donor_cont5127_rep->status_data.status="F"))
         CALL errorhandler("F","BBD_DONOR_CONTACT_R",gm_u_bbd_donor_cont5127_rep->qual[1].error_msg)
        ENDIF
       ELSE
        CALL errorhandler("F","BBD_DONOR_CONTACT_R","Update failed.")
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((request->contactlist[i_idx].donoreligibility.eligibility_id > 0.0)
    AND (request->contactlist[i_idx].donoreligibility.add_change_ind=add_ind))
    SET gm_i_bbd_donor_elig2144_req->allow_partial_ind = 0
    SET stat = gm_i_bbd_donor_elig2144_i2("ACTIVE_IND",request->contactlist[i_idx].active_ind,1,0)
    IF ((request->contactlist[i_idx].active_ind=1))
     IF (stat=1)
      SET stat = gm_i_bbd_donor_elig2144_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_donor_elig2144_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0
       )
     ENDIF
     IF (stat=1)
      SET stat = gm_i_bbd_donor_elig2144_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
     ENDIF
    ELSEIF ((request->contactlist[i_idx].active_ind=0))
     IF (stat=1)
      SET stat = gm_i_bbd_donor_elig2144_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_elig2144_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_elig2144_f8("ELIGIBILITY_ID",request->contactlist[i_idx].
      donoreligibility.eligibility_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_elig2144_f8("ELIGIBILITY_TYPE_CD",request->contactlist[i_idx].
      donoreligibility.eligibility_type_cd,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_elig2144_dq8("ELIGIBLE_DT_TM",request->contactlist[i_idx].
      donoreligibility.eligible_dt_tm,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_elig2144_f8("ENCNTR_ID",request->contactlist[i_idx].encounter_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bbd_donor_elig2144_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_i_bbd_donor_elig2144  WITH replace(request,gm_i_bbd_donor_elig2144_req), replace(
      reply,gm_i_bbd_donor_elig2144_rep)
     IF ((gm_i_bbd_donor_elig2144_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_DONOR_ELIGIBILITY",gm_i_bbd_donor_elig2144_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONOR_ELIGIBILITY","Insert failed.")
    ENDIF
   ELSEIF ((request->contactlist[i_idx].donoreligibility.eligibility_id > 0.0)
    AND (request->contactlist[i_idx].donoreligibility.add_change_ind=change_ind))
    SET gm_u_bbd_donor_elig2144_req->allow_partial_ind = 0
    SET gm_u_bbd_donor_elig2144_req->force_updt_ind = 0
    SET stat = gm_u_bbd_donor_elig2144_i2("ACTIVE_IND",request->contactlist[i_idx].active_ind,1,0,0)
    IF ((request->contactlist[i_idx].active_ind=0))
     IF (stat=1)
      SET stat = gm_u_bbd_donor_elig2144_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
     ENDIF
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_elig2144_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_elig2144_f8("ELIGIBILITY_ID",request->contactlist[i_idx].
      donoreligibility.eligibility_id,1,0,1)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_elig2144_f8("ELIGIBILITY_TYPE_CD",request->contactlist[i_idx].
      donoreligibility.eligibility_type_cd,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_elig2144_dq8("ELIGIBLE_DT_TM",request->contactlist[i_idx].
      donoreligibility.eligible_dt_tm,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_elig2144_f8("ENCNTR_ID",request->contactlist[i_idx].encounter_id,1,0,0
      )
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_elig2144_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bbd_donor_elig2144_i4("UPDT_CNT",request->contactlist[i_idx].donoreligibility.
      updt_cnt,1,0,1)
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_bbd_donor_elig2144  WITH replace(request,gm_u_bbd_donor_elig2144_req), replace(
      reply,gm_u_bbd_donor_elig2144_rep)
     IF ((gm_u_bbd_donor_elig2144_rep->status_data.status="F"))
      CALL errorhandler("F","BBD_DONOR_ELIGIBILITY",gm_u_bbd_donor_elig2144_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BBD_DONOR_ELIGIBILITY","Update failed.")
    ENDIF
   ENDIF
   IF ((request->contactlist[i_idx].donoreligibility.eligibility_id > 0.0))
    FOR (j_idx = 1 TO size(request->contactlist[i_idx].donoreligibility.deferralreasonlist,5))
      IF ((request->contactlist[i_idx].donoreligibility.deferralreasonlist[j_idx].add_change_ind=
      add_ind))
       SET gm_i_bbd_deferral_r2145_req->allow_partial_ind = 0
       SET stat = gm_i_bbd_deferral_r2145_i2("ACTIVE_IND",request->contactlist[i_idx].
        donoreligibility.deferralreasonlist[j_idx].active_ind,1,0)
       IF ((request->contactlist[i_idx].donoreligibility.deferralreasonlist[j_idx].active_ind=1))
        IF (stat=1)
         SET stat = gm_i_bbd_deferral_r2145_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_deferral_r2145_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),
          1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bbd_deferral_r2145_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
        ENDIF
       ELSEIF ((request->contactlist[i_idx].donoreligibility.deferralreasonlist[j_idx].active_ind=0))
        IF (stat=1)
         SET stat = gm_i_bbd_deferral_r2145_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
        ENDIF
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_deferral_r2145_dq8("CALC_ELIG_DT_TM",request->contactlist[i_idx].
         donoreligibility.deferralreasonlist[j_idx].calc_elig_dt_tm,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_deferral_r2145_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0
         )
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_deferral_r2145_f8("DEFERRAL_REASON_ID",request->contactlist[i_idx].
         donoreligibility.deferralreasonlist[j_idx].deferral_reason_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_deferral_r2145_f8("ELIGIBILITY_ID",request->contactlist[i_idx].
         donoreligibility.eligibility_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_deferral_r2145_dq8("ELIGIBLE_DT_TM",request->contactlist[i_idx].
         donoreligibility.deferralreasonlist[j_idx].eligible_dt_tm,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_deferral_r2145_f8("ENCNTR_ID",request->contactlist[i_idx].encounter_id,1,
         0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_deferral_r2145_dq8("OCCURRED_DT_TM",request->contactlist[i_idx].
         donoreligibility.deferralreasonlist[j_idx].occurred_dt_tm,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_deferral_r2145_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bbd_deferral_r2145_f8("REASON_CD",request->contactlist[i_idx].
         donoreligibility.deferralreasonlist[j_idx].reason_cd,1,0)
       ENDIF
       IF (stat=1)
        EXECUTE gm_i_bbd_deferral_r2145  WITH replace(request,gm_i_bbd_deferral_r2145_req), replace(
         reply,gm_i_bbd_deferral_r2145_rep)
        IF ((gm_i_bbd_deferral_r2145_rep->status_data.status="F"))
         CALL errorhandler("F","BBD_DEFERRAL_REASON",gm_i_bbd_deferral_r2145_rep->qual[1].error_msg)
        ENDIF
       ELSE
        CALL errorhandler("F","BBD_DEFERRAL_REASON","Insert failed.")
       ENDIF
      ELSEIF ((request->contactlist[i_idx].donoreligibility.deferralreasonlist[j_idx].add_change_ind=
      change_ind))
       SET gm_u_bbd_deferral_r2145_req->allow_partial_ind = 0
       SET gm_u_bbd_deferral_r2145_req->force_updt_ind = 0
       SET stat = gm_u_bbd_deferral_r2145_i2("ACTIVE_IND",request->contactlist[i_idx].
        donoreligibility.deferralreasonlist[j_idx].active_ind,1,0,0)
       IF ((request->contactlist[i_idx].donoreligibility.deferralreasonlist[j_idx].active_ind=0))
        IF (stat=1)
         SET stat = gm_u_bbd_deferral_r2145_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
        ENDIF
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_deferral_r2145_dq8("CALC_ELIG_DT_TM",request->contactlist[i_idx].
         donoreligibility.deferralreasonlist[j_idx].calc_elig_dt_tm,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_deferral_r2145_f8("CONTACT_ID",request->contactlist[i_idx].contact_id,1,0,
         0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_deferral_r2145_f8("DEFERRAL_REASON_ID",request->contactlist[i_idx].
         donoreligibility.deferralreasonlist[j_idx].deferral_reason_id,1,0,1)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_deferral_r2145_f8("ELIGIBILITY_ID",request->contactlist[i_idx].
         donoreligibility.eligibility_id,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_deferral_r2145_dq8("ELIGIBLE_DT_TM",request->contactlist[i_idx].
         donoreligibility.deferralreasonlist[j_idx].eligible_dt_tm,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_deferral_r2145_f8("ENCNTR_ID",request->contactlist[i_idx].encounter_id,1,
         0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_deferral_r2145_dq8("OCCURRED_DT_TM",request->contactlist[i_idx].
         donoreligibility.deferralreasonlist[j_idx].occurred_dt_tm,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_deferral_r2145_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0,0
         )
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_deferral_r2145_f8("REASON_CD",request->contactlist[i_idx].
         donoreligibility.deferralreasonlist[j_idx].reason_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bbd_deferral_r2145_i4("UPDT_CNT",request->contactlist[i_idx].donoreligibility
         .deferralreasonlist[j_idx].updt_cnt,1,0,1)
       ENDIF
       IF (stat=1)
        EXECUTE gm_u_bbd_deferral_r2145  WITH replace(request,gm_u_bbd_deferral_r2145_req), replace(
         reply,gm_u_bbd_deferral_r2145_rep)
        IF ((gm_u_bbd_deferral_r2145_rep->status_data.status="F"))
         CALL errorhandler("F","BBD_DEFERRAL_REASON",gm_u_bbd_deferral_r2145_rep->qual[1].error_msg)
        ENDIF
       ELSE
        CALL errorhandler("F","BBD_DEFERRAL_REASON","Update failed.")
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((request->contactlist[i_idx].contact_id > 0.0))
    FOR (j_idx = 1 TO size(request->contactlist[i_idx].exceptionlist,5))
      IF ((request->contactlist[i_idx].exceptionlist[j_idx].add_change_ind=add_ind))
       SET gm_i_bb_exception1445_req->allow_partial_ind = 0
       SET stat = gm_i_bb_exception1445_i2("ACTIVE_IND",request->contactlist[i_idx].exceptionlist[
        j_idx].active_ind,1,0)
       IF ((request->contactlist[i_idx].exceptionlist[j_idx].active_ind=1))
        IF (stat=1)
         SET stat = gm_i_bb_exception1445_f8("ACTIVE_STATUS_CD",reqdata->active_status_cd,1,0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bb_exception1445_dq8("ACTIVE_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,
          0)
        ENDIF
        IF (stat=1)
         SET stat = gm_i_bb_exception1445_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
        ENDIF
       ELSEIF ((request->contactlist[i_idx].exceptionlist[j_idx].active_ind=0))
        IF (stat=1)
         SET stat = gm_i_bb_exception1445_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0)
        ENDIF
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("EXCEPTION_ID",request->contactlist[i_idx].exceptionlist[
         j_idx].exception_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("EXCEPTION_TYPE_CD",request->contactlist[i_idx].
         exceptionlist[j_idx].exception_type_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_dq8("EXCEPTION_DT_TM",request->contactlist[i_idx].
         contact_dt_tm,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("OVERRIDE_REASON_CD",request->contactlist[i_idx].
         exceptionlist[j_idx].override_reason_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("DONOR_CONTACT_ID",request->contactlist[i_idx].contact_id,
         1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("DONOR_CONTACT_TYPE_CD",request->contactlist[i_idx].
         contact_type_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("PRODUCT_ABO_CD",request->contactlist[i_idx].
         exceptionlist[j_idx].donor_abo_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("PRODUCT_RH_CD",request->contactlist[i_idx].
         exceptionlist[j_idx].donor_rh_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("PERSON_ABO_CD",request->contactlist[i_idx].
         exceptionlist[j_idx].recipient_abo_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("PERSON_RH_CD",request->contactlist[i_idx].exceptionlist[
         j_idx].recipient_rh_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_dq8("INELIGIBLE_UNTIL_DT_TM",request->contactlist[i_idx].
         exceptionlist[j_idx].ineligible_until_dt_tm,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_f8("PROCEDURE_CD",request->contactlist[i_idx].exceptionlist[
         j_idx].procedure_cd,1,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_i_bb_exception1445_vc("DONATION_IDENT",request->contactlist[i_idx].
         exceptionlist[j_idx].donation_ident,1,0)
       ENDIF
       IF (stat=1)
        EXECUTE gm_i_bb_exception1445  WITH replace(request,gm_i_bb_exception1445_req), replace(reply,
         gm_i_bb_exception1445_rep)
        IF ((gm_i_bb_exception1445_rep->status_data.status="F"))
         CALL errorhandler("F","BB_EXCEPTION",gm_i_bb_exception1445_rep->qual[1].error_msg)
        ENDIF
       ELSE
        CALL errorhandler("F","BB_EXCEPTION","Insert failed.")
       ENDIF
      ELSEIF ((request->contactlist[i_idx].exceptionlist[j_idx].add_change_ind=change_ind))
       SET gm_u_bb_exception1445_req->allow_partial_ind = 0
       SET gm_u_bb_exception1445_req->force_updt_ind = 0
       SET stat = gm_u_bb_exception1445_i2("ACTIVE_IND",request->contactlist[i_idx].exceptionlist[
        j_idx].active_ind,1,0,0)
       IF ((request->contactlist[i_idx].exceptionlist[j_idx].active_ind=0))
        IF (stat=1)
         SET stat = gm_u_bb_exception1445_f8("ACTIVE_STATUS_CD",reqdata->inactive_status_cd,1,0,0)
        ENDIF
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("EXCEPTION_ID",request->contactlist[i_idx].exceptionlist[
         j_idx].exception_id,1,0,1)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("EXCEPTION_TYPE_CD",request->contactlist[i_idx].
         exceptionlist[j_idx].exception_type_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_dq8("EXCEPTION_DT_TM",request->contactlist[i_idx].
         contact_dt_tm,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("OVERRIDE_REASON_CD",request->contactlist[i_idx].
         exceptionlist[j_idx].override_reason_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("PERSON_ID",request->contactlist[i_idx].person_id,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("DONOR_CONTACT_ID",request->contactlist[i_idx].contact_id,
         1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("DONOR_CONTACT_TYPE_CD",request->contactlist[i_idx].
         contact_type_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_i4("UPDT_CNT",request->contactlist[i_idx].exceptionlist[
         j_idx].updt_cnt,1,0,1)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("PRODUCT_ABO_CD",request->contactlist[i_idx].
         exceptionlist[j_idx].donor_abo_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("PRODUCT_RH_CD",request->contactlist[i_idx].
         exceptionlist[j_idx].donor_rh_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("PERSON_ABO_CD",request->contactlist[i_idx].
         exceptionlist[j_idx].recipient_abo_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("PERSON_RH_CD",request->contactlist[i_idx].exceptionlist[
         j_idx].recipient_rh_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_f8("PROCEDURE_CD",request->contactlist[i_idx].exceptionlist[
         j_idx].procedure_cd,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_dq8("INELIGIBLE_UNTIL_DT_TM",request->contactlist[i_idx].
         exceptionlist[j_idx].ineligible_until_dt_tm,1,0,0)
       ENDIF
       IF (stat=1)
        SET stat = gm_u_bb_exception1445_vc("DONATION_IDENT",request->contactlist[i_idx].
         exceptionlist[j_idx].donation_ident,1,0,0)
       ENDIF
       IF (stat=1)
        EXECUTE gm_u_bb_exception1445  WITH replace(request,gm_u_bb_exception1445_req), replace(reply,
         gm_u_bb_exception1445_rep)
        IF ((gm_u_bb_exception1445_rep->status_data.status="F"))
         CALL errorhandler("F","BB_EXCEPTION",gm_u_bb_exception1445_rep->qual[1].error_msg)
        ENDIF
       ELSE
        CALL errorhandler("F","BB_EXCEPTION","Update failed.")
       ENDIF
      ENDIF
    ENDFOR
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
 FREE RECORD gm_i_bbd_donor_cont1635_req
 FREE RECORD gm_i_bbd_donor_cont1635_rep
 FREE RECORD gm_u_bbd_donor_cont1635_req
 FREE RECORD gm_u_bbd_donor_cont1635_rep
 FREE RECORD gm_i_bbd_other_cont3472_req
 FREE RECORD gm_i_bbd_other_cont3472_rep
 FREE RECORD gm_u_bbd_other_cont3472_req
 FREE RECORD gm_u_bbd_other_cont3472_rep
 FREE RECORD gm_i_bbd_donation_r2146_req
 FREE RECORD gm_i_bbd_donation_r2146_rep
 FREE RECORD gm_u_bbd_donation_r2146_req
 FREE RECORD gm_u_bbd_donation_r2146_rep
 FREE RECORD gm_i_bbd_don_produc2147_req
 FREE RECORD gm_i_bbd_don_produc2147_rep
 FREE RECORD gm_u_bbd_don_produc2147_req
 FREE RECORD gm_u_bbd_don_produc2147_rep
 FREE RECORD gm_i_bbd_recruitmen3635_req
 FREE RECORD gm_i_bbd_recruitmen3635_rep
 FREE RECORD gm_u_bbd_recruitmen3635_req
 FREE RECORD gm_u_bbd_recruitmen3635_rep
 FREE RECORD gm_i_bbd_contact_no5125_req
 FREE RECORD gm_i_bbd_contact_no5125_rep
 FREE RECORD gm_u_bbd_contact_no5125_req
 FREE RECORD gm_u_bbd_contact_no5125_rep
 FREE RECORD gm_i_bbd_donor_cont5127_req
 FREE RECORD gm_i_bbd_donor_cont5127_rep
 FREE RECORD gm_u_bbd_donor_cont5127_req
 FREE RECORD gm_u_bbd_donor_cont5127_rep
 FREE RECORD gm_i_bbd_donor_elig2144_req
 FREE RECORD gm_i_bbd_donor_elig2144_rep
 FREE RECORD gm_u_bbd_donor_elig2144_req
 FREE RECORD gm_u_bbd_donor_elig2144_rep
 FREE RECORD gm_i_bbd_deferral_r2145_req
 FREE RECORD gm_i_bbd_deferral_r2145_rep
 FREE RECORD gm_u_bbd_deferral_r2145_req
 FREE RECORD gm_u_bbd_deferral_r2145_rep
 FREE RECORD gm_i_bb_exception1445_req
 FREE RECORD gm_i_bb_exception1445_rep
 FREE RECORD gm_u_bb_exception1445_req
 FREE RECORD gm_u_bb_exception1445_rep
END GO

CREATE PROGRAM bb_upd_label_params:dba
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
 EXECUTE gm_bb_isbt_labe0450_def "I"
 SUBROUTINE (gm_i_bb_isbt_labe0450_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bb_isbt_labe0450_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bb_isbt_labe0450_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "bb_isbt_label_param_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_isbt_labe0450_req->qual[iqual].bb_isbt_label_param_id = ival
     SET gm_i_bb_isbt_labe0450_req->bb_isbt_label_param_idi = 1
    OF "option_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_isbt_labe0450_req->qual[iqual].option_id = ival
     SET gm_i_bb_isbt_labe0450_req->option_idi = 1
    OF "orig_product_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_isbt_labe0450_req->qual[iqual].orig_product_cd = ival
     SET gm_i_bb_isbt_labe0450_req->orig_product_cdi = 1
    OF "new_product_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_isbt_labe0450_req->qual[iqual].new_product_cd = ival
     SET gm_i_bb_isbt_labe0450_req->new_product_cdi = 1
    OF "label_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_isbt_labe0450_req->qual[iqual].label_type_cd = ival
     SET gm_i_bb_isbt_labe0450_req->label_type_cdi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_bb_isbt_labe0450_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_bb_isbt_labe0450_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_bb_isbt_labe0450_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "print_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_isbt_labe0450_req->qual[iqual].print_ind = ival
     SET gm_i_bb_isbt_labe0450_req->print_indi = 1
    OF "supplier_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_isbt_labe0450_req->qual[iqual].supplier_ind = ival
     SET gm_i_bb_isbt_labe0450_req->supplier_indi = 1
    OF "licensed_supplier_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_isbt_labe0450_req->qual[iqual].licensed_supplier_ind = ival
     SET gm_i_bb_isbt_labe0450_req->licensed_supplier_indi = 1
    OF "licensed_modifier_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_isbt_labe0450_req->qual[iqual].licensed_modifier_ind = ival
     SET gm_i_bb_isbt_labe0450_req->licensed_modifier_indi = 1
    OF "new_product_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_bb_isbt_labe0450_req->qual[iqual].new_product_ind = ival
     SET gm_i_bb_isbt_labe0450_req->new_product_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bb_isbt_labe0450_def "U"
 SUBROUTINE (gm_u_bb_isbt_labe0450_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bb_isbt_labe0450_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bb_isbt_labe0450_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "bb_isbt_label_param_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_isbt_labe0450_req->bb_isbt_label_param_idf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].bb_isbt_label_param_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->bb_isbt_label_param_idw = 1
     ENDIF
    OF "option_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_isbt_labe0450_req->option_idf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].option_id = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->option_idw = 1
     ENDIF
    OF "orig_product_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_isbt_labe0450_req->orig_product_cdf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].orig_product_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->orig_product_cdw = 1
     ENDIF
    OF "new_product_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_isbt_labe0450_req->new_product_cdf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].new_product_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->new_product_cdw = 1
     ENDIF
    OF "label_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_isbt_labe0450_req->label_type_cdf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].label_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->label_type_cdw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_u_bb_isbt_labe0450_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bb_isbt_labe0450_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bb_isbt_labe0450_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "print_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_isbt_labe0450_req->print_indf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].print_ind = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->print_indw = 1
     ENDIF
    OF "supplier_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_isbt_labe0450_req->supplier_indf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].supplier_ind = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->supplier_indw = 1
     ENDIF
    OF "licensed_supplier_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_isbt_labe0450_req->licensed_supplier_indf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].licensed_supplier_ind = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->licensed_supplier_indw = 1
     ENDIF
    OF "licensed_modifier_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_isbt_labe0450_req->licensed_modifier_indf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].licensed_modifier_ind = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->licensed_modifier_indw = 1
     ENDIF
    OF "new_product_ind":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_bb_isbt_labe0450_req->new_product_indf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].new_product_ind = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->new_product_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_u_bb_isbt_labe0450_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_bb_isbt_labe0450_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_bb_isbt_labe0450_req->qual,iqual)
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
     SET gm_u_bb_isbt_labe0450_req->updt_cntf = 1
     SET gm_u_bb_isbt_labe0450_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_bb_isbt_labe0450_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_bb_isbt_labe0450_def "D"
 SUBROUTINE (gm_d_bb_isbt_labe0450_f8(icol_name=vc,ival=f8,iqual=i4) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_d_bb_isbt_labe0450_req->qual,5) < iqual)
    SET stat = alterlist(gm_d_bb_isbt_labe0450_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "bb_isbt_label_param_id":
     SET gm_d_bb_isbt_labe0450_req->qual[iqual].bb_isbt_label_param_id = ival
     SET gm_d_bb_isbt_labe0450_req->bb_isbt_label_param_idw = 1
    OF "option_id":
     SET gm_d_bb_isbt_labe0450_req->qual[iqual].option_id = ival
     SET gm_d_bb_isbt_labe0450_req->option_idw = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 DECLARE script_name = c19 WITH constant("bb_upd_label_params")
 DECLARE insert_ind = i2 WITH constant(1)
 DECLARE update_ind = i2 WITH constant(2)
 DECLARE delete_ind = i2 WITH constant(3)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE i_idx = i4 WITH protect, noconstant(0)
 FOR (i_idx = 1 TO size(request->param_list,5))
   IF ((request->param_list[i_idx].save_flag=insert_ind))
    SET gm_i_bb_isbt_labe0450_req->allow_partial_ind = 0
    SET stat = gm_i_bb_isbt_labe0450_f8("BB_ISBT_LABEL_PARAM_ID",request->param_list[i_idx].
     label_param_id,1,0)
    IF (stat=1)
     SET stat = gm_i_bb_isbt_labe0450_i2("LICENSED_MODIFIER_IND",request->param_list[i_idx].
      licensed_modifier_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bb_isbt_labe0450_i2("LICENSED_SUPPLIER_IND",request->param_list[i_idx].
      licensed_supplier_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bb_isbt_labe0450_i2("NEW_PRODUCT_IND",request->param_list[i_idx].new_product_ind,
      1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bb_isbt_labe0450_f8("OPTION_ID",request->param_list[i_idx].option_id,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bb_isbt_labe0450_i2("PRINT_IND",request->param_list[i_idx].print_ind,1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bb_isbt_labe0450_f8("ORIG_PRODUCT_CD",request->param_list[i_idx].orig_product_cd,
      1,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bb_isbt_labe0450_f8("NEW_PRODUCT_CD",request->param_list[i_idx].new_product_cd,1,
      0)
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bb_isbt_labe0450_f8("LABEL_TYPE_CD",request->param_list[i_idx].label_type_cd,1,0
      )
    ENDIF
    IF (stat=1)
     SET stat = gm_i_bb_isbt_labe0450_i2("SUPPLIER_IND",request->param_list[i_idx].supplier_ind,1,0)
    ENDIF
    IF (stat=1)
     EXECUTE gm_i_bb_isbt_labe0450  WITH replace(request,gm_i_bb_isbt_labe0450_req), replace(reply,
      gm_i_bb_isbt_labe0450_rep)
     IF ((gm_i_bb_isbt_labe0450_rep->status_data.status="F"))
      CALL errorhandler("F","BB_ISBT_LABEL_PARAM",gm_i_bb_isbt_labe0450_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BB_ISBT_LABEL_PARAM","Insert failed.")
    ENDIF
   ELSEIF ((request->param_list[i_idx].save_flag=update_ind))
    SET gm_u_bb_isbt_labe0450_req->allow_partial_ind = 0
    SET gm_u_bb_isbt_labe0450_req->force_updt_ind = 0
    SET stat = gm_u_bb_isbt_labe0450_f8("BB_ISBT_LABEL_PARAM_ID",request->param_list[i_idx].
     label_param_id,1,0,1)
    IF (stat=1)
     SET stat = gm_u_bb_isbt_labe0450_i2("LICENSED_MODIFIER_IND",request->param_list[i_idx].
      licensed_modifier_ind,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bb_isbt_labe0450_i2("LICENSED_SUPPLIER_IND",request->param_list[i_idx].
      licensed_supplier_ind,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bb_isbt_labe0450_i2("NEW_PRODUCT_IND",request->param_list[i_idx].new_product_ind,
      1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bb_isbt_labe0450_f8("OPTION_ID",request->param_list[i_idx].option_id,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bb_isbt_labe0450_i2("PRINT_IND",request->param_list[i_idx].print_ind,1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bb_isbt_labe0450_f8("ORIG_PRODUCT_CD",request->param_list[i_idx].orig_product_cd,
      1,0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bb_isbt_labe0450_f8("NEW_PRODUCT_CD",request->param_list[i_idx].new_product_cd,1,
      0,0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bb_isbt_labe0450_f8("LABEL_TYPE_CD",request->param_list[i_idx].label_type_cd,1,0,
      0)
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bb_isbt_labe0450_i2("SUPPLIER_IND",request->param_list[i_idx].supplier_ind,1,0,0
      )
    ENDIF
    IF (stat=1)
     SET stat = gm_u_bb_isbt_labe0450_i4("UPDT_CNT",request->param_list[i_idx].updt_cnt,1,0,1)
    ENDIF
    IF (stat=1)
     EXECUTE gm_u_bb_isbt_labe0450  WITH replace(request,gm_u_bb_isbt_labe0450_req), replace(reply,
      gm_u_bb_isbt_labe0450_rep)
     IF ((gm_u_bb_isbt_labe0450_rep->status_data.status="F"))
      CALL errorhandler("F","BB_ISBT_LABEL_PARAM",gm_u_bb_isbt_labe0450_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BB_ISBT_LABEL_PARAM","Update failed.")
    ENDIF
   ELSEIF ((request->param_list[i_idx].save_flag=delete_ind))
    SET gm_d_bb_isbt_labe0450_req->allow_partial_ind = 0
    SET stat = gm_d_bb_isbt_labe0450_f8("BB_ISBT_LABEL_PARAM_ID",request->param_list[i_idx].
     label_param_id,1)
    IF (stat=1)
     EXECUTE gm_d_bb_isbt_labe0450  WITH replace(request,gm_d_bb_isbt_labe0450_req), replace(reply,
      gm_d_bb_isbt_labe0450_rep)
     IF ((gm_d_bb_isbt_labe0450_rep->status_data.status="F"))
      CALL errorhandler("F","BB_ISBT_LABEL_PARAM",gm_d_bb_isbt_labe0450_rep->qual[1].error_msg)
     ENDIF
    ELSE
     CALL errorhandler("F","BB_ISBT_LABEL_PARAM","Delete failed.")
    ENDIF
   ENDIF
 ENDFOR
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
 FREE RECORD gm_i_bb_isbt_labe0450_req
 FREE RECORD gm_i_bb_isbt_labe0450_rep
 FREE RECORD gm_u_bb_isbt_labe0450_req
 FREE RECORD gm_u_bb_isbt_labe0450_rep
 FREE RECORD gm_d_bb_isbt_labe0450_req
 FREE RECORD gm_d_bb_isbt_labe0450_rep
END GO

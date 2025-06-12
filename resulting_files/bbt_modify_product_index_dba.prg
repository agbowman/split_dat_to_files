CREATE PROGRAM bbt_modify_product_index:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
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
 SET reply->status_data.status = "S"
 SET failures = 0
 SET cur_product_disp = fillstring(40," ")
 SET cur_product_desc = fillstring(60," ")
 SET failure_flag = "N"
 SET insert_flag = "N"
 SET nbr_to_chg = size(request->qual,5)
 SET idx = 0
 SET nidx = 0
 SET cur_product_barcode = fillstring(15," ")
 SET new_product_barcode_id = 0.0
 FOR (idx = 1 TO nbr_to_chg)
   SET insert_flag = "N"
   SET cur_product_disp = uar_get_code_display(request->qual[idx].product_cd)
   SET cur_product_desc = uar_get_code_description(request->qual[idx].product_cd)
   IF (((cur_product_disp="") OR (cur_product_desc="")) )
    SET failure_flag = "Y"
    SET reply->status_data.subeventstatus[1].operationname = "lock code_value forupdate"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "product_index"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(request->qual[idx].
     product_cd,32,2)
    GO TO exit_script
   ELSE
    IF ((((cur_product_disp != request->qual[idx].product_disp)) OR ((cur_product_desc != request->
    qual[idx].product_desc))) )
     SET gm_u_code_value0619_req->allow_partial_ind = 0
     SET gm_u_code_value0619_req->force_updt_ind = 1
     SET gm_u_code_value0619_req->code_valuew = 1
     SET gm_u_code_value0619_req->code_setw = 1
     SET gm_u_code_value0619_req->displayf = 1
     SET gm_u_code_value0619_req->descriptionf = 1
     SET gm_u_code_value0619_req->definitionf = 1
     SET gm_u_code_value0619_req->active_indf = 1
     SET nidx = (nidx+ 1)
     SET stat = alterlist(gm_u_code_value0619_req->qual,nidx)
     SET gm_u_code_value0619_req->qual[nidx].code_set = 1604
     SET gm_u_code_value0619_req->qual[nidx].code_value = request->qual[idx].product_cd
     SET gm_u_code_value0619_req->qual[nidx].display = request->qual[idx].product_disp
     SET gm_u_code_value0619_req->qual[nidx].description = request->qual[idx].product_desc
     SET gm_u_code_value0619_req->qual[nidx].definition = request->qual[idx].product_desc
     SET gm_u_code_value0619_req->qual[nidx].active_ind = 1
     EXECUTE gm_u_code_value0619  WITH replace("REQUEST","GM_U_CODE_VALUE0619_REQ"), replace("REPLY",
      "GM_U_CODE_VALUE0619_REP")
     IF ((gm_u_code_value0619_rep->status_data.status != "S"))
      SET failure_flag = "Y"
      SET reply->status_data.subeventstatus[1].operationname = "update code_value"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(request->qual[idx].
       product_cd,32,2)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF (failure_flag="N")
    SET bar_cnt = cnvtint(size(request->qual[idx].barcodelist,5))
    SET bar = 0
    FOR (bar = 1 TO bar_cnt)
      IF ((request->qual[idx].barcodelist[bar].product_barcode_id > 0))
       UPDATE  FROM product_barcode b
        SET b.active_ind = 0, b.active_status_cd = reqdata->inactive_status_cd, b.active_status_dt_tm
          = cnvtdatetime(curdate,curtime3),
         b.active_status_prsnl_id = reqinfo->updt_id, b.updt_cnt = (b.updt_cnt+ 1), b.updt_id =
         reqinfo->updt_id,
         b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_dt_tm =
         cnvtdatetime(curdate,curtime3)
        WHERE (b.product_barcode_id=request->qual[idx].barcodelist[bar].product_barcode_id)
         AND (b.updt_cnt=request->qual[idx].barcodelist[bar].updt_cnt)
       ;end update
       IF (curqual=0)
        SET failure_flag = "Y"
        SET reply->status_data.subeventstatus[1].operationname = "update product_barcode"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "product_barcode"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = request->qual[idx].barcodelist[
        bar].product_barcode
        GO TO exit_script
       ENDIF
      ELSE
       SET new_product_barcode_id = 0.0
       SET new_product_barcode_id = next_pathnet_seq(0)
       IF (curqual=0)
        SET failure_flag = "Y"
        SET reply->status_data.subeventstatus[1].operationname = "get new product_barcode_id"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_pathnet_seq_sub"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = request->qual[idx].barcodelist[
        bar].product_barcode
        GO TO exit_script
       ENDIF
       INSERT  FROM product_barcode b
        SET b.product_barcode_id = new_product_barcode_id, b.product_barcode = request->qual[idx].
         barcodelist[bar].product_barcode, b.product_cd = request->qual[idx].product_cd,
         b.product_cat_cd = request->qual[idx].product_cat_cd, b.product_class_cd = request->qual[idx
         ].product_class_cd, b.active_ind = 1,
         b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
         b.updt_cnt = 0, b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task,
         b.updt_applctx = reqinfo->updt_applctx, b.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET failure_flag = "Y"
        SET reply->status_data.subeventstatus[1].operationname = "insert product_barcode"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "product_barcode"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = request->qual[idx].barcodelist[
        bar].product_barcode
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (failure_flag="N")
    SELECT INTO "nl:"
     p.*
     FROM product_index p
     WHERE (request->qual[idx].product_cd=p.product_cd)
     WITH nocounter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET failure_flag = "Y"
     SET reply->status_data.subeventstatus[1].operationname = "insert product_barcode"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "product_barcode"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->qual[idx].barcodelist[bar]
     .product_barcode
     GO TO exit_script
    ELSE
     UPDATE  FROM product_index p
      SET p.autologous_ind = request->qual[idx].autologous_ind, p.directed_ind = request->qual[idx].
       directed_ind, p.max_days_expire = request->qual[idx].max_days_expire,
       p.max_hrs_expire = request->qual[idx].max_hrs_expire, p.default_volume = request->qual[idx].
       default_volume, p.default_supplier_id = request->qual[idx].default_supplier_id,
       p.allow_dispense_ind = request->qual[idx].allow_dispense_ind, p.synonym_id = request->qual[idx
       ].synonym_id, p.auto_quarantine_min = request->qual[idx].auto_quarantine_min,
       p.validate_ag_ab_ind = request->qual[idx].validate_ag_ab_ind, p.validate_trans_req_ind =
       request->qual[idx].validate_trans_req_ind, p.intl_units_ind = request->qual[idx].
       intl_units_ind,
       p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p
       .storage_temp_cd = request->qual[idx].storage_temp_cd,
       p.drawn_dt_tm_ind = request->qual[idx].drawn_dt_tm_ind, p.aliquot_ind = request->qual[idx].
       aliquot_ind
      WHERE (request->qual[idx].product_cd=p.product_cd)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failure_flag = "Y"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_modify_product_index"
      SET reply->status_data.subeventstatus[1].operationname = "update"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "product_index"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "product_index"
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
#exit_script
 IF (failure_flag="N")
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 IF (failure_flag="N")
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "SUCCESS"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "product_index & product_barcode"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "product_index & product_barcode"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 FREE RECORD gm_u_code_value0619_req
 FREE RECORD gm_u_code_value0619_rep
END GO

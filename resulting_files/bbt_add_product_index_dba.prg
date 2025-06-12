CREATE PROGRAM bbt_add_product_index:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
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
 EXECUTE gm_code_value0619_def "I"
 DECLARE next_code = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET nbr_to_add = size(request->qual,5)
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SET auth_data_status_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   auth_data_status_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (idx = 1 TO nbr_to_add)
   SET next_code = 0.0
   SET gm_i_code_value0619_req->allow_partial_ind = 0
   SET stat = gm_i_code_value0619_i4("CODE_SET",1604,1,0)
   IF (stat=1)
    SET stat = gm_i_code_value0619_vc("DISPLAY",request->qual[idx].product_disp,1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_vc("DESCRIPTION",request->qual[idx].product_desc,1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_vc("DEFINITION",request->qual[idx].product_desc,1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_f8("ACTIVE_TYPE_CD",reqdata->active_status_cd,1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_i2("ACTIVE_IND",request->qual[idx].active_ind,1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_dq8("ACTIVE_DT_TM",cnvtdatetime(curdate,curtime3),1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_dq8("BEGIN_EFFECTIVE_DT_TM",cnvtdatetime(curdate,curtime3),1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_dq8("END_EFFECTIVE_DT_TM",cnvtdatetime("31-DEC-2100:00:00:00.00"),
     1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_f8("DATA_STATUS_CD",auth_data_status_cd,1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_dq8("DATA_STATUS_DT_TM",cnvtdatetime(curdate,curtime3),1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_f8("DATA_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
   ENDIF
   IF (stat=1)
    SET stat = gm_i_code_value0619_f8("ACTIVE_STATUS_PRSNL_ID",reqinfo->updt_id,1,0)
   ENDIF
   IF (stat=1)
    EXECUTE gm_i_code_value0619  WITH replace(request,gm_i_code_value0619_req), replace(reply,
     gm_i_code_value0619_rep)
   ENDIF
   IF (stat=1)
    IF ((gm_i_code_value0619_rep->status_data.status="F"))
     SET curqual = 0
    ENDIF
    SET next_code = gm_i_code_value0619_rep->qual[1].code_value
   ENDIF
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "codeset"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET failed = "T"
   ELSE
    INSERT  FROM product_index p
     SET p.product_class_cd = request->qual[idx].product_class_cd, p.product_cat_cd = request->qual[
      idx].product_cat_cd, p.product_cd = next_code,
      p.autologous_ind = request->qual[idx].autologous_ind, p.directed_ind = request->qual[idx].
      directed_ind, p.max_days_expire = request->qual[idx].max_days_expire,
      p.max_hrs_expire = request->qual[idx].max_hrs_expire, p.default_volume = request->qual[idx].
      default_volume, p.default_supplier_id = request->qual[idx].default_supplier_id,
      p.allow_dispense_ind = request->qual[idx].allow_dispense_ind, p.synonym_id = request->qual[idx]
      .synonym_id, p.auto_quarantine_min = request->qual[idx].auto_quarantine_min,
      p.validate_ag_ab_ind = request->qual[idx].validate_ag_ab_ind, p.validate_trans_req_ind =
      request->qual[idx].validate_trans_req_ind, p.intl_units_ind = request->qual[idx].intl_units_ind,
      p.storage_temp_cd = request->qual[idx].storage_temp_cd, p.active_ind = request->qual[idx].
      active_ind, p.active_status_cd = reqdata->active_status_cd,
      p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
      updt_id, p.drawn_dt_tm_ind = request->qual[idx].drawn_dt_tm_ind,
      p.aliquot_ind = request->qual[idx].aliquot_ind, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
      updt_task
     WITH counter
    ;end insert
    IF (curqual=0)
     SET y = (y+ 1)
     IF (y > 1)
      SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_product_index"
     SET reply->status_data.subeventstatus[y].operationname = "insert"
     SET reply->status_data.subeventstatus[y].operationstatus = "F"
     SET reply->status_data.subeventstatus[y].targetobjectname = "product_index"
     SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].product_desc
     SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET failed = "T"
    ELSE
     SET bar = 0
     SET new_product_barcode_id = 0.0
     SET bar_cnt = size(request->qual[idx].barcodelist,5)
     FOR (bar = 1 TO bar_cnt)
       SET new_product_barcode_id = 0.0
       SET new_product_barcode_id = next_pathnet_seq(0)
       IF (curqual=0)
        SET failure_flag = "Y"
        SET reply->status_data.subeventstatus[1].operationname = "get new product_barcode_id"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_pathnet_seq_sub"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = request->qual[idx].barcodelist[
        bar].product_barcode
        SET failed = "T"
       ENDIF
       INSERT  FROM product_barcode b
        SET b.product_cd = next_code, b.product_barcode_id = new_product_barcode_id, b
         .product_barcode = request->qual[idx].barcodelist[bar].product_barcode,
         b.product_cat_cd = request->qual[idx].product_cat_cd, b.product_class_cd = request->qual[idx
         ].product_class_cd, b.active_ind = 1,
         b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
         b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
         b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
        WITH counter
       ;end insert
       IF (curqual=0)
        SET y = (y+ 1)
        IF (y > 1)
         SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[y].operationname = "insert"
        SET reply->status_data.subeventstatus[y].operationstatus = "F"
        SET reply->status_data.subeventstatus[y].targetobjectname = "product_barcode"
        SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].product_desc
        SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
        SET failed = "T"
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET y = (y+ 1)
  IF (y > 1)
   SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[y].operationname = "insert"
  SET reply->status_data.subeventstatus[y].operationstatus = "F"
  SET reply->status_data.subeventstatus[y].targetobjectname = "product_barcode"
  SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].product_desc
  SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
 ENDIF
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
 FREE RECORD gm_u_code_value0619_req
 FREE RECORD gm_u_code_value0619_rep
END GO

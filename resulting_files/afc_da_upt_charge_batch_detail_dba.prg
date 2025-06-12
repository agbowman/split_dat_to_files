CREATE PROGRAM afc_da_upt_charge_batch_detail:dba
 SET afc_da_upt_charge_batch_detail_vrsn = 257887
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(pft_failed,0)=0
  AND validate(pft_failed,1)=1)
  DECLARE pft_failed = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(table_name,"X")="X"
  AND validate(table_name,"Z")="Z")
  DECLARE table_name = vc WITH public, noconstant(" ")
 ENDIF
 IF (validate(call_echo_ind,0)=0
  AND validate(call_echo_ind,1)=1)
  DECLARE call_echo_ind = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(failed,0)=0
  AND validate(failed,1)=1)
  DECLARE failed = i2 WITH public, noconstant(false)
 ENDIF
 DECLARE mdtdanone = dq8 WITH noconstant(0.0)
 DECLARE mdtdaend = dq8 WITH noconstant(0.0)
 DECLARE msdatablename = vc WITH noconstant("")
 SET mdtdanone = cnvtdatetime("01-JAN-1800 00:00:00.00")
 SET mdtdaend = cnvtdatetime("31-DEC-2100 23:59:59.00")
 SET msdatablename = "CHARGE_BATCH_DETAIL"
 DECLARE mndamodobj = i4 WITH noconstant(0)
 DECLARE mndamodrec = i4 WITH noconstant(0)
 DECLARE mndamodfld = i4 WITH noconstant(0)
 DECLARE mndastart = i4 WITH noconstant(1)
 DECLARE mndastop = i4 WITH noconstant(0)
 IF (trim(cnvtstring(validate(transinfo->trans_dt_tm,0)))="0")
  RECORD transinfo(
    1 trans_dt_tm = dq8
  )
  SET transinfo->trans_dt_tm = cnvtdatetime(sysdate)
 ENDIF
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 pft_status_data
      2 status = c1
      2 subeventstatus[*]
        3 status = c1
        3 table_name = vc
        3 pk_values = vc
    1 mod_objs[*]
      2 entity_type = vc
      2 mod_recs[*]
        3 table_name = vc
        3 pk_values = vc
        3 mod_flds[*]
          4 field_name = vc
          4 field_type = vc
          4 field_value_obj = vc
          4 field_value_db = vc
    1 failure_stack
      2 failures[*]
        3 programname = vc
        3 routinename = vc
        3 message = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET mndamodobj = size(reply->mod_objs,5)
 IF (mndamodobj=0)
  SET stat = alterlist(reply->mod_objs,1)
  SET mndamodobj = 1
  SET reply->mod_objs[mndamodobj].entity_type = msdatablename
 ENDIF
 SET mndamodrec = size(reply->mod_objs[mndamodobj].mod_recs,5)
 FREE RECORD mrsstatus
 RECORD mrsstatus(
   1 objarray[*]
     2 status = i4
     2 daid = f8
     2 modify_this_record = i2
 )
 SET gnstat = alterlist(mrsstatus->objarray,size(request->objarray,5))
 SET mndastop = size(request->objarray,5)
 SET stat = alterlist(reply->mod_objs[mndamodobj].mod_recs,(mndamodrec+ ((mndastop - mndastart)+ 1)))
 SET reply->status_data.status = "F"
 CALL upt_charge_batch_detail(mndastart,mndastop)
 SUBROUTINE (upt_charge_batch_detail(nstart=i4,nstop=i4) =null WITH protect)
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE blocked = i2 WITH noconstant(0), protect
   SET blocked = false
   SET i = nstart
   FOR (i = 1 TO size(request->objarray,5))
     IF (validate(request->objarray[i].charge_batch_detail_id,- (0.00001)) <= 0.0)
      IF (false=checkerror(attribute_error))
       RETURN
      ENDIF
     ENDIF
   ENDFOR
   SET blocked = false
   SELECT INTO "nl:"
    c.*
    FROM charge_batch_detail c,
     (dummyt dt  WITH seq = value(size(request->objarray,5)))
    PLAN (dt)
     JOIN (c
     WHERE (c.charge_batch_detail_id=request->objarray[dt.seq].charge_batch_detail_id))
    DETAIL
     mndamodrec += 1, mndamodfld = 0, reply->mod_objs[mndamodobj].mod_recs[mndamodrec].table_name =
     msdatablename,
     reply->mod_objs[mndamodobj].mod_recs[mndamodrec].pk_values = build(c.charge_batch_detail_id)
     IF ((validate(request->objarray[dt.seq].charge_batch_id,c.charge_batch_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].charge_batch_id,c.charge_batch_id) != c.charge_batch_id)
      CALL logfieldmodified("CHARGE_BATCH_ID","F8",build(validate(request->objarray[dt.seq].
        charge_batch_id,c.charge_batch_id)),build(c.charge_batch_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].encntr_id,c.encntr_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].encntr_id,c.encntr_id) != c.encntr_id)
      CALL logfieldmodified("ENCNTR_ID","F8",build(validate(request->objarray[dt.seq].encntr_id,c
        .encntr_id)),build(c.encntr_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].ordering_phys_id,c.ordering_phys_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].ordering_phys_id,c.ordering_phys_id) != c
     .ordering_phys_id)
      CALL logfieldmodified("ORDERING_PHYS_ID","F8",build(validate(request->objarray[dt.seq].
        ordering_phys_id,c.ordering_phys_id)),build(c.ordering_phys_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].rendering_phys_id,c.rendering_phys_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].rendering_phys_id,c.rendering_phys_id) != c
     .rendering_phys_id)
      CALL logfieldmodified("RENDERING_PHYS_ID","F8",build(validate(request->objarray[dt.seq].
        rendering_phys_id,c.rendering_phys_id)),build(c.rendering_phys_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].bill_item_id,c.bill_item_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].bill_item_id,c.bill_item_id) != c.bill_item_id)
      CALL logfieldmodified("BILL_ITEM_ID","F8",build(validate(request->objarray[dt.seq].bill_item_id,
        c.bill_item_id)),build(c.bill_item_id))
     ENDIF
     IF (validate(request->objarray[dt.seq].service_item_ident,c.service_item_ident) != char(128)
      AND validate(request->objarray[dt.seq].service_item_ident,c.service_item_ident) != c
     .service_item_ident)
      CALL logfieldmodified("SERVICE_ITEM_IDENT","C50",validate(request->objarray[dt.seq].
       service_item_ident,c.service_item_ident),c.service_item_ident)
     ENDIF
     IF ((validate(request->objarray[dt.seq].service_item_ident_type_cd,c.service_item_ident_type_cd)
      != - (0.00001))
      AND validate(request->objarray[dt.seq].service_item_ident_type_cd,c.service_item_ident_type_cd)
      != c.service_item_ident_type_cd)
      CALL logfieldmodified("SERVICE_ITEM_IDENT_TYPE_CD","F8",build(validate(request->objarray[dt.seq
        ].service_item_ident_type_cd,c.service_item_ident_type_cd)),build(c
       .service_item_ident_type_cd))
     ENDIF
     IF ((validate(request->objarray[dt.seq].service_item_qty,c.service_item_qty) != - (0.00001))
      AND validate(request->objarray[dt.seq].service_item_qty,c.service_item_qty) != c
     .service_item_qty)
      CALL logfieldmodified("SERVICE_ITEM_QTY","F8",build(validate(request->objarray[dt.seq].
        service_item_qty,c.service_item_qty)),build(c.service_item_qty))
     ENDIF
     IF ((validate(request->objarray[dt.seq].service_item_price_amt,c.service_item_price_amt) != - (
     0.00001))
      AND validate(request->objarray[dt.seq].service_item_price_amt,c.service_item_price_amt) != c
     .service_item_price_amt)
      CALL logfieldmodified("SERVICE_ITEM_PRICE_AMT","F8",build(validate(request->objarray[dt.seq].
        service_item_price_amt,c.service_item_price_amt)),build(c.service_item_price_amt))
     ENDIF
     IF (validate(request->objarray[dt.seq].service_item_desc,c.service_item_desc) != char(128)
      AND validate(request->objarray[dt.seq].service_item_desc,c.service_item_desc) != c
     .service_item_desc)
      CALL logfieldmodified("SERVICE_ITEM_DESC","C200",validate(request->objarray[dt.seq].
       service_item_desc,c.service_item_desc),c.service_item_desc)
     ENDIF
     IF (validate(request->objarray[dt.seq].service_dt_tm,c.service_dt_tm) != 0.0
      AND validate(request->objarray[dt.seq].service_dt_tm,c.service_dt_tm) != c.service_dt_tm)
      CALL logfieldmodified("SERVICE_DT_TM","Q8",cnvtstring(validate(request->objarray[dt.seq].
        service_dt_tm,c.service_dt_tm)),cnvtstring(c.service_dt_tm))
     ENDIF
     IF ((validate(request->objarray[dt.seq].perf_loc_cd,c.perf_loc_cd) != - (0.00001))
      AND validate(request->objarray[dt.seq].perf_loc_cd,c.perf_loc_cd) != c.perf_loc_cd)
      CALL logfieldmodified("PERF_LOC_CD","F8",build(validate(request->objarray[dt.seq].perf_loc_cd,c
        .perf_loc_cd)),build(c.perf_loc_cd))
     ENDIF
     IF ((validate(request->objarray[dt.seq].status_cd,c.status_cd) != - (0.00001))
      AND validate(request->objarray[dt.seq].status_cd,c.status_cd) != c.status_cd)
      CALL logfieldmodified("STATUS_CD","F8",build(validate(request->objarray[dt.seq].status_cd,c
        .status_cd)),build(c.status_cd))
     ENDIF
     IF ((validate(request->objarray[dt.seq].active_ind,c.active_ind) != - (1))
      AND validate(request->objarray[dt.seq].active_ind,c.active_ind) != c.active_ind)
      CALL logfieldmodified("ACTIVE_IND","I2",cnvtstring(validate(request->objarray[dt.seq].
        active_ind,c.active_ind)),cnvtstring(c.active_ind))
     ENDIF
     IF ((validate(request->objarray[dt.seq].patient_responsibility_flag,c
      .patient_responsibility_flag) != - (1))
      AND validate(request->objarray[dt.seq].patient_responsibility_flag,c
      .patient_responsibility_flag) != c.patient_responsibility_flag)
      CALL logfieldmodified("PATIENT_RESPONSIBILITY_FLAG","I2",cnvtstring(validate(request->objarray[
        dt.seq].patient_responsibility_flag,c.patient_responsibility_flag)),cnvtstring(c
       .patient_responsibility_flag))
     ENDIF
     IF ((validate(request->objarray[dt.seq].item_copay_amt,c.item_copay_amt) != - (0.00001))
      AND validate(request->objarray[dt.seq].item_copay_amt,c.item_copay_amt) != c.item_copay_amt)
      CALL logfieldmodified("ITEM_COPAY_AMT","F8",build(validate(request->objarray[dt.seq].
        item_copay_amt,c.item_copay_amt)),build(c.item_copay_amt))
     ENDIF
     IF ((validate(request->objarray[dt.seq].item_deductible_amt,c.item_deductible_amt) != - (0.00001
     ))
      AND validate(request->objarray[dt.seq].item_deductible_amt,c.item_deductible_amt) != c
     .item_deductible_amt)
      CALL logfieldmodified("ITEM_DEDUCTIBLE_AMT","F8",build(validate(request->objarray[dt.seq].
        item_deductible_amt,c.item_deductible_amt)),build(c.item_deductible_amt))
     ENDIF
     IF (validate(request->objarray[dt.seq].diagnosis_pointer_txt,c.diagnosis_pointer_txt) != char(
      128)
      AND validate(request->objarray[dt.seq].diagnosis_pointer_txt,c.diagnosis_pointer_txt) != c
     .diagnosis_pointer_txt)
      CALL logfieldmodified("DIAGNOSIS_POINTER_TXT","C50",validate(request->objarray[dt.seq].
       diagnosis_pointer_txt,c.diagnosis_pointer_txt),c.diagnosis_pointer_txt)
     ENDIF
     IF ((request->objarray[dt.seq].updt_cnt != c.updt_cnt)
      AND (request->objarray[dt.seq].updt_cnt != - (99999)))
      blocked = true
     ELSE
      mrsstatus->objarray[dt.seq].status = 1
      IF (mndamodfld > 0)
       mrsstatus->objarray[dt.seq].modify_this_record = true
      ENDIF
     ENDIF
     IF ((validate(request->objarray[dt.seq].service_resource_cd,- (0.00001)) != - (0.00001))
      AND validate(request->objarray[dt.seq].service_resource_cd,c.service_resource_cd) != c
     .service_resource_cd)
      CALL logfieldmodified("SERVICE_RESOURCE_CD","F8",build(validate(request->objarray[dt.seq].
        service_resource_cd,c.service_resource_cd)),build(c.service_resource_cd))
     ENDIF
    WITH forupdate(c)
   ;end select
   FOR (i = 1 TO size(mrsstatus->objarray,5))
     IF ((mrsstatus->objarray[i].status != 1))
      CALL checkerror(lock_error)
      RETURN
     ENDIF
   ENDFOR
   UPDATE  FROM charge_batch_detail c,
     (dummyt dt  WITH seq = value(size(request->objarray,5)))
    SET c.charge_batch_id =
     IF ((validate(request->objarray[dt.seq].charge_batch_id,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].charge_batch_id,- (0.00001))
     ELSE c.charge_batch_id
     ENDIF
     , c.encntr_id =
     IF ((validate(request->objarray[dt.seq].encntr_id,- (0.00001)) != - (0.00001))) validate(request
       ->objarray[dt.seq].encntr_id,- (0.00001))
     ELSE c.encntr_id
     ENDIF
     , c.ordering_phys_id =
     IF ((validate(request->objarray[dt.seq].ordering_phys_id,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].ordering_phys_id,- (0.00001))
     ELSE c.ordering_phys_id
     ENDIF
     ,
     c.bill_item_id =
     IF ((validate(request->objarray[dt.seq].bill_item_id,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].bill_item_id,- (0.00001))
     ELSE c.bill_item_id
     ENDIF
     , c.service_item_ident =
     IF (validate(request->objarray[dt.seq].service_item_ident,char(128)) != char(128)) validate(
       request->objarray[dt.seq].service_item_ident,char(128))
     ELSE c.service_item_ident
     ENDIF
     , c.service_item_ident_type_cd =
     IF ((validate(request->objarray[dt.seq].service_item_ident_type_cd,- (0.00001)) != - (0.00001)))
       validate(request->objarray[dt.seq].service_item_ident_type_cd,- (0.00001))
     ELSE c.service_item_ident_type_cd
     ENDIF
     ,
     c.service_item_qty =
     IF ((validate(request->objarray[dt.seq].service_item_qty,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].service_item_qty,- (0.00001))
     ELSE c.service_item_qty
     ENDIF
     , c.service_item_price_amt =
     IF ((validate(request->objarray[dt.seq].service_item_price_amt,- (0.00001)) != - (0.00001)))
      validate(request->objarray[dt.seq].service_item_price_amt,- (0.00001))
     ELSE c.service_item_price_amt
     ENDIF
     , c.service_item_desc =
     IF (validate(request->objarray[dt.seq].service_item_desc,char(128)) != char(128)) validate(
       request->objarray[dt.seq].service_item_desc,char(128))
     ELSE c.service_item_desc
     ENDIF
     ,
     c.service_dt_tm =
     IF (validate(request->objarray[dt.seq].service_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
        objarray[dt.seq].service_dt_tm,0.0))
     ELSE c.service_dt_tm
     ENDIF
     , c.perf_loc_cd =
     IF ((validate(request->objarray[dt.seq].perf_loc_cd,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].perf_loc_cd,- (0.00001))
     ELSE c.perf_loc_cd
     ENDIF
     , c.status_cd =
     IF ((validate(request->objarray[dt.seq].status_cd,- (0.00001)) != - (0.00001))) validate(request
       ->objarray[dt.seq].status_cd,- (0.00001))
     ELSE c.status_cd
     ENDIF
     ,
     c.patient_responsibility_flag =
     IF ((validate(request->objarray[dt.seq].patient_responsibility_flag,- (1)) != - (1))) validate(
       request->objarray[dt.seq].patient_responsibility_flag,- (1))
     ELSE c.patient_responsibility_flag
     ENDIF
     , c.item_copay_amt =
     IF ((validate(request->objarray[dt.seq].item_copay_amt,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].item_copay_amt,- (0.00001))
     ELSE c.item_copay_amt
     ENDIF
     , c.item_deductible_amt =
     IF ((validate(request->objarray[dt.seq].item_deductible_amt,- (0.00001)) != - (0.00001)))
      validate(request->objarray[dt.seq].item_deductible_amt,- (0.00001))
     ELSE c.item_deductible_amt
     ENDIF
     ,
     c.diagnosis_pointer_txt =
     IF (validate(request->objarray[dt.seq].diagnosis_pointer_txt,char(128)) != char(128)) validate(
       request->objarray[dt.seq].diagnosis_pointer_txt,char(128))
     ELSE c.diagnosis_pointer_txt
     ENDIF
     , c.rendering_phys_id =
     IF ((validate(request->objarray[dt.seq].rendering_phys_id,- (0.00001)) != - (0.00001))) validate
      (request->objarray[dt.seq].rendering_phys_id,- (0.00001))
     ELSE c.rendering_phys_id
     ENDIF
     , c.service_resource_cd =
     IF ((validate(request->objarray[dt.seq].service_resource_cd,- (0.00001)) != - (0.00001)))
      validate(request->objarray[dt.seq].service_resource_cd,- (0.00001))
     ELSE c.service_resource_cd
     ENDIF
     ,
     c.active_ind =
     IF ((validate(request->objarray[dt.seq].active_ind,- (1)) != - (1))) validate(request->objarray[
       dt.seq].active_ind,- (1))
     ELSE c.active_ind
     ENDIF
     , c.updt_dt_tm = cnvtdatetime(transinfo->trans_dt_tm), c.updt_id = reqinfo->updt_id,
     c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->
     updt_applctx
    PLAN (dt
     WHERE (mrsstatus->objarray[dt.seq].modify_this_record=true))
     JOIN (c
     WHERE (c.charge_batch_detail_id=request->objarray[dt.seq].charge_batch_detail_id))
    WITH nocounter, status(mrsstatus->objarray[dt.seq].status)
   ;end update
   FOR (i = 1 TO size(mrsstatus->objarray,5))
     IF ((mrsstatus->objarray[i].status != 1))
      CALL checkerror(update_error)
      RETURN
     ENDIF
   ENDFOR
   CALL checkerror(true)
 END ;Subroutine
 SUBROUTINE (checkerror(nfailed=i4) =i2 WITH protect)
   IF (nfailed=true)
    SET reply->status_data.status = "S"
    SET reqinfo->commit_ind = true
    RETURN(true)
   ELSE
    CASE (nfailed)
     OF gen_nbr_error:
      SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
     OF insert_error:
      SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     OF update_error:
      SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     OF replace_error:
      SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
     OF delete_error:
      SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     OF undelete_error:
      SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
     OF remove_error:
      SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
     OF attribute_error:
      SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
     OF lock_error:
      SET reply->status_data.subeventstatus[1].operationname = "LOCK"
     ELSE
      SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    ENDCASE
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = msdatablename
    SET reqinfo->commit_ind = false
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (logfieldmodified(sfieldname=vc,sfieldtype=vc,sobjvalue=vc,sdbvalue=vc) =null)
   IF (mndamodfld=size(reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds,5))
    SET stat = alterlist(reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds,(mndamodfld+ 1))
   ENDIF
   SET mndamodfld += 1
   SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds[mndamodfld].field_name = sfieldname
   SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds[mndamodfld].field_type = sfieldtype
   SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds[mndamodfld].field_value_obj = trim(
    sobjvalue,3)
   SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds[mndamodfld].field_value_db = trim(
    sdbvalue,3)
 END ;Subroutine
#end_program
 SET stat = alterlist(reply->mod_objs[mndamodobj].mod_recs,mndamodrec)
 FREE RECORD mrsstatus
END GO

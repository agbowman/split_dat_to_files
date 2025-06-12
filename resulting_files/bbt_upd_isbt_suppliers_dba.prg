CREATE PROGRAM bbt_upd_isbt_suppliers:dba
 RECORD reply(
   1 qual[*]
     2 isbt_supplier_id = f8
     2 inventory_area_cd = f8
     2 isbt_supplier_fin = c5
     2 license_nbr = c15
     2 organization_id = f8
     2 registration_nbr = c15
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE new_bb_isbt_supplier_id = f8 WITH noconstant(0.0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE qual_cnt = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE supplier_cnt = i4 WITH noconstant(0)
 DECLARE splr = i4 WITH noconstant(0)
 DECLARE fin_index = i4 WITH noconstant(0)
 SET supplier_cnt = size(request->supplierlist,5)
 FOR (splr = 1 TO supplier_cnt)
   IF ((request->supplierlist[splr].isbt_supplier_id != 0))
    SELECT INTO "nl:"
     *
     FROM bb_isbt_supplier biss
     WHERE (((biss.inventory_area_cd=request->supplierlist[splr].inventory_area_cd)
      AND biss.inventory_area_cd=0
      AND (biss.organization_id=request->supplierlist[splr].organization_id)
      AND (biss.bb_isbt_supplier_id != request->supplierlist[splr].isbt_supplier_id)
      AND (biss.isbt_supplier_fin=request->supplierlist[splr].isbt_supplier_fin)) OR ((((biss
     .inventory_area_cd=request->supplierlist[splr].inventory_area_cd)
      AND biss.inventory_area_cd > 0
      AND (biss.organization_id=request->supplierlist[splr].organization_id)
      AND (biss.bb_isbt_supplier_id != request->supplierlist[splr].isbt_supplier_id)) OR ((biss
     .isbt_supplier_fin=request->supplierlist[splr].isbt_supplier_fin)
      AND (biss.organization_id != request->supplierlist[splr].organization_id))) ))
      AND biss.active_ind=1
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET errmsg = "Unique Supplier Exists - Update Failed."
     CALL errorhandler("INSERT","F","BBT_UPD_ISBT_SUPPLIERS",errmsg)
     GO TO exit_script
    ENDIF
    UPDATE  FROM bb_isbt_supplier biss
     SET biss.inventory_area_cd = request->supplierlist[splr].inventory_area_cd, biss.license_nbr_txt
       = request->supplierlist[splr].license_nbr, biss.isbt_supplier_fin = request->supplierlist[splr
      ].isbt_supplier_fin,
      biss.organization_id = request->supplierlist[splr].organization_id, biss.registration_nbr_txt
       = request->supplierlist[splr].registration_nbr, biss.active_ind = request->supplierlist[splr].
      active_ind,
      biss.updt_dt_tm = cnvtdatetime(curdate,curtime3), biss.updt_cnt = (biss.updt_cnt+ 1)
     WHERE (biss.bb_isbt_supplier_id=request->supplierlist[splr].isbt_supplier_id)
    ;end update
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("UPDATE","F","BBT_UPD_ISBT_SUPPLIERS",errmsg)
     GO TO exit_script
    ENDIF
    IF (curqual=0)
     SET errmsg = "Update failed."
     CALL errorhandler("UPDATE","F","BBT_UPD_ISBT_SUPPLIERS",errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET qual_cnt = 0
 FOR (splr = 1 TO supplier_cnt)
   IF ((request->supplierlist[splr].isbt_supplier_id=0))
    SELECT INTO "nl:"
     *
     FROM bb_isbt_supplier biss
     WHERE (((biss.inventory_area_cd=request->supplierlist[splr].inventory_area_cd)
      AND biss.inventory_area_cd=0
      AND (biss.organization_id=request->supplierlist[splr].organization_id)
      AND (biss.isbt_supplier_fin=request->supplierlist[splr].isbt_supplier_fin)) OR ((((biss
     .inventory_area_cd=request->supplierlist[splr].inventory_area_cd)
      AND biss.inventory_area_cd > 0
      AND (biss.organization_id=request->supplierlist[splr].organization_id)) OR ((biss
     .isbt_supplier_fin=request->supplierlist[splr].isbt_supplier_fin)
      AND (biss.organization_id != request->supplierlist[splr].organization_id))) ))
      AND biss.active_ind=1
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET errmsg = "Unique Supplier Exists - Update Failed."
     CALL errorhandler("INSERT","F","BBT_UPD_ISBT_SUPPLIERS",errmsg)
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     y = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_bb_isbt_supplier_id = y
     WITH format, counter
    ;end select
    IF (curqual=0)
     SET errmsg = "Unable to obtain reference sequence id"
     CALL errorhandler("SELECT","F","DUAL",errmsg)
     GO TO exit_script
    ENDIF
    INSERT  FROM bb_isbt_supplier biss
     SET biss.active_ind = 1, biss.bb_isbt_supplier_id = new_bb_isbt_supplier_id, biss
      .inventory_area_cd = request->supplierlist[splr].inventory_area_cd,
      biss.isbt_supplier_fin = request->supplierlist[splr].isbt_supplier_fin, biss.license_nbr_txt =
      request->supplierlist[splr].license_nbr, biss.organization_id = request->supplierlist[splr].
      organization_id,
      biss.registration_nbr_txt = request->supplierlist[splr].registration_nbr, biss.updt_cnt = 0,
      biss.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      biss.updt_id = reqinfo->updt_id, biss.updt_task = reqinfo->updt_task, biss.updt_applctx =
      reqinfo->updt_applctx,
      biss.active_status_cd = reqdata->active_status_cd, biss.updt_id = reqinfo->updt_id
    ;end insert
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("INSERT","F","BBT_UPD_ISBT_SUPPLIERS",errmsg)
     GO TO exit_script
    ENDIF
    SET qual_cnt = (qual_cnt+ 1)
    IF (qual_cnt > size(reply->qual,5))
     SET stat = alterlist(reply->qual,(qual_cnt+ 9))
    ENDIF
    SET reply->qual[qual_cnt].organization_id = request->supplierlist[splr].organization_id
    SET reply->qual[qual_cnt].isbt_supplier_id = new_bb_isbt_supplier_id
    SET reply->qual[qual_cnt].inventory_area_cd = request->supplierlist[splr].inventory_area_cd
    SET reply->qual[qual_cnt].isbt_supplier_fin = request->supplierlist[splr].isbt_supplier_fin
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->qual,qual_cnt)
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE errorhandler(operationname,operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = operationname
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO

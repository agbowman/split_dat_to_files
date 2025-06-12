CREATE PROGRAM aps_chg_inventory_types:dba
 RECORD reply(
   1 qual[*]
     2 inventory_type_cd = f8
     2 retention[*]
       3 ap_inv_retention_id = f8
       3 prefix_id = f8
       3 normalcy_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD delete_rows
 RECORD delete_rows(
   1 qual[*]
     2 ap_inv_retention_id = f8
 )
 FREE RECORD insert_rows
 RECORD insert_rows(
   1 qual[*]
     2 inventory_type_cd = f8
     2 ap_inv_retention_id = f8
     2 prefix_id = f8
     2 normalcy_cd = f8
     2 retention_tm_value = f8
     2 retention_units_cd = f8
 )
 FREE RECORD m_dm2_seq_stat
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 SET modify = predeclare
 DECLARE mlreq_qual_size = i4 WITH protect, constant(size(request->qual,5))
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE mlretentionsize = i4 WITH protect, noconstant(0)
 DECLARE mldeletecnt = i4 WITH protect, noconstant(0)
 DECLARE mlinsertcnt = i4 WITH protect, noconstant(0)
 DECLARE mlstat = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 FOR (i = 1 TO mlreq_qual_size)
  SET mlretentionsize = size(request->qual[i].retention,5)
  FOR (j = 1 TO mlretentionsize)
    IF ((request->qual[i].retention[j].ap_inv_retention_id=0.0))
     SET mlinsertcnt = (mlinsertcnt+ 1)
     IF (mod(mlinsertcnt,5)=1)
      SET mlstat = alterlist(insert_rows->qual,(mlinsertcnt+ 4))
     ENDIF
     SET insert_rows->qual[mlinsertcnt].inventory_type_cd = request->qual[i].inventory_type_cd
     SET insert_rows->qual[mlinsertcnt].prefix_id = request->qual[i].retention[j].prefix_id
     SET insert_rows->qual[mlinsertcnt].normalcy_cd = request->qual[i].retention[j].normalcy_cd
     SET insert_rows->qual[mlinsertcnt].retention_tm_value = request->qual[i].retention[j].
     retention_tm_value
     SET insert_rows->qual[mlinsertcnt].retention_units_cd = request->qual[i].retention[j].
     retention_units_cd
    ELSE
     SET mldeletecnt = (mldeletecnt+ 1)
     IF (mod(mldeletecnt,10)=1)
      SET mlstat = alterlist(delete_rows->qual,(mldeletecnt+ 9))
     ENDIF
     SET delete_rows->qual[mldeletecnt].ap_inv_retention_id = request->qual[i].retention[j].
     ap_inv_retention_id
    ENDIF
  ENDFOR
 ENDFOR
 CALL echo(build2("mlDeleteCnt: ",mldeletecnt))
 IF (mldeletecnt != 0)
  SET mlstat = alterlist(delete_rows->qual,mldeletecnt)
  IF (deleterows(null)=false)
   GO TO end_script
  ENDIF
 ENDIF
 FREE RECORD delete_rows
 CALL echo(build2("mlInsertCnt: ",mlinsertcnt))
 IF (mlinsertcnt != 0)
  SET mlstat = alterlist(insert_rows->qual,mlinsertcnt)
  IF (lookupseqs(null)=false)
   GO TO end_script
  ENDIF
  IF (insertrows(null)=false)
   GO TO end_script
  ENDIF
 ENDIF
 FREE RECORD insert_rows
 FREE RECORD m_dm2_seq_stat
 SET reply->status_data.status = "S"
 DECLARE deleterows() = i2
 SUBROUTINE deleterows(null)
  DELETE  FROM ap_inv_retention air
   WHERE expand(i,1,mldeletecnt,air.ap_inv_retention_id,delete_rows->qual[i].ap_inv_retention_id)
  ;end delete
  IF (curqual=mldeletecnt)
   RETURN(true)
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_INV_RETENTION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Failed to delete rows from the AP_INV_RETENTION table. Rollback issued."
   RETURN(false)
  ENDIF
 END ;Subroutine
 DECLARE lookupseqs() = i2
 SUBROUTINE lookupseqs(null)
   EXECUTE dm2_dar_get_bulk_seq "INSERT_ROWS->QUAL", mlinsertcnt, "AP_INV_RETENTION_ID",
   1, "NETTING_SEQ"
   IF ((m_dm2_seq_stat->n_status != 1))
    CALL echo("ERROR encountered in DM2_DAR_GET_BULK_SEQ.")
    CALL echo(m_dm2_seq_stat->s_error_msg)
    SET reply->status_data.subeventstatus[1].operationname = "LOOKUP"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "PATHNET_SEQS"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to create ap_inv_retention_ids for new rows. Rollback issued."
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 DECLARE insertrows() = i2
 SUBROUTINE insertrows(null)
   DECLARE k = i4 WITH protect, noconstant(0)
   DECLARE dprevinvtypecd = f8 WITH protect, noconstant(0.0)
   DECLARE lqualcnt = i4 WITH protect, noconstant(0)
   DECLARE lretcnt = i4 WITH protect, noconstant(0)
   INSERT  FROM ap_inv_retention air,
     (dummyt d  WITH seq = value(mlinsertcnt))
    SET air.ap_inv_retention_id = insert_rows->qual[d.seq].ap_inv_retention_id, air.inventory_type_cd
      = insert_rows->qual[d.seq].inventory_type_cd, air.normalcy_cd = insert_rows->qual[d.seq].
     normalcy_cd,
     air.prefix_id = insert_rows->qual[d.seq].prefix_id, air.retention_tm_value = insert_rows->qual[d
     .seq].retention_tm_value, air.retention_units_cd = insert_rows->qual[d.seq].retention_units_cd,
     air.updt_applctx = reqinfo->updt_applctx, air.updt_cnt = 0, air.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     air.updt_id = reqinfo->updt_id, air.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (air)
    WITH nocounter
   ;end insert
   IF (curqual != mlinsertcnt)
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "AP_INV_RETENTION"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to insert new rows into ap_inv_retention. Rollback issued."
    RETURN(false)
   ENDIF
   SET mlstat = alterlist(reply->qual,mlinsertcnt)
   FOR (k = 1 TO mlinsertcnt)
     IF ((dprevinvtypecd != insert_rows->qual[k].inventory_type_cd))
      IF (dprevinvtypecd != 0.0)
       SET mlstat = alterlist(reply->qual[lqualcnt].retention,lretcnt)
      ENDIF
      SET lqualcnt = (lqualcnt+ 1)
      IF (mod(lqualcnt,3)=1)
       SET mlstat = alterlist(reply->qual,(lqualcnt+ 2))
      ENDIF
      SET reply->qual[lqualcnt].inventory_type_cd = insert_rows->qual[k].inventory_type_cd
      SET lretcnt = 0
      SET dprevinvtypecd = reply->qual[lqualcnt].inventory_type_cd
     ENDIF
     SET lretcnt = (lretcnt+ 1)
     IF (mod(lretcnt,5)=1)
      SET mlstat = alterlist(reply->qual[lqualcnt].retention,(lretcnt+ 4))
     ENDIF
     SET reply->qual[lqualcnt].retention[lretcnt].ap_inv_retention_id = insert_rows->qual[k].
     ap_inv_retention_id
     SET reply->qual[lqualcnt].retention[lretcnt].prefix_id = insert_rows->qual[k].prefix_id
     SET reply->qual[lqualcnt].retention[lretcnt].normalcy_cd = insert_rows->qual[k].normalcy_cd
   ENDFOR
   SET mlstat = alterlist(reply->qual[lqualcnt].retention,lretcnt)
   SET mlstat = alterlist(reply->qual,lqualcnt)
   RETURN(true)
 END ;Subroutine
#end_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO

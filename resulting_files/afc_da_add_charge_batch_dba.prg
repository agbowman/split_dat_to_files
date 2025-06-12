CREATE PROGRAM afc_da_add_charge_batch:dba
 SET afc_da_add_charge_batch_vrsn = 20110424
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
 DECLARE msdatablename = vc WITH noconstant("")
 SET msdatablename = "CHARGE_BATCH"
 DECLARE mndamodobj = i4 WITH noconstant(0)
 DECLARE mndamodrec = i4 WITH noconstant(0)
 DECLARE mndamodfld = i4 WITH noconstant(0)
 DECLARE mndastart = i4 WITH noconstant(1)
 DECLARE mndastop = i4 WITH noconstant(0)
 DECLARE checkerror(nfailed=i4) = i2 WITH protect
 DECLARE logfieldmodified(sfieldname=vc,sfieldtype=vc,sobjvalue=vc,sdbvalue=vc) = null
 DECLARE add_charge_batch(nstart=i4,nstop=i4) = null WITH protect
 IF (trim(cnvtstring(validate(transinfo->trans_dt_tm,0)))="0")
  RECORD transinfo(
    1 trans_dt_tm = dq8
  )
  SET transinfo->trans_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF (validate(reply->pft_status_data,"Z")="Z")
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
 CALL add_charge_batch(mndastart,mndastop)
 SUBROUTINE add_charge_batch(nstart,nstop)
   DECLARE dactivestatuscd = f8 WITH noconstant(0.0), protect
   DECLARE i = i4 WITH noconstant(0), protect
   SET dactivestatuscd = reqdata->active_status_cd
   FOR (i = 1 TO size(request->objarray,5))
     IF (validate(request->objarray[i].charge_batch_id,- (0.00001)) <= 0.0)
      SELECT INTO "nl:"
       sdapk = seq(batch_charge_entry_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        mrsstatus->objarray[i].daid = cnvtreal(sdapk)
       WITH format, counter
      ;end select
      IF (validate(request->objarray[i].charge_batch_id))
       SET request->objarray[i].charge_batch_id = mrsstatus->objarray[i].daid
      ENDIF
      IF (((curqual=0) OR ((mrsstatus->objarray[i].daid <= 0.0))) )
       IF (false=checkerror(gen_nbr_error))
        RETURN
       ENDIF
      ENDIF
     ELSE
      SET mrsstatus->objarray[i].daid = request->objarray[i].charge_batch_id
     ENDIF
   ENDFOR
   INSERT  FROM charge_batch c,
     (dummyt dt  WITH seq = value(size(request->objarray,5)))
    SET c.charge_batch_id = mrsstatus->objarray[dt.seq].daid, c.created_prsnl_id =
     IF ((validate(request->objarray[dt.seq].created_prsnl_id,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].created_prsnl_id,- (0.00001))
     ELSE 0.0
     ENDIF
     , c.assigned_prsnl_id =
     IF ((validate(request->objarray[dt.seq].assigned_prsnl_id,- (0.00001)) != - (0.00001))) validate
      (request->objarray[dt.seq].assigned_prsnl_id,- (0.00001))
     ELSE 0.0
     ENDIF
     ,
     c.user_defined_ind =
     IF ((validate(request->objarray[dt.seq].user_defined_ind,- (1)) != - (1))) validate(request->
       objarray[dt.seq].user_defined_ind,- (1))
     ELSE 0
     ENDIF
     , c.status_cd =
     IF ((validate(request->objarray[dt.seq].status_cd,- (0.00001)) != - (0.00001))) validate(request
       ->objarray[dt.seq].status_cd,- (0.00001))
     ELSE 0.0
     ENDIF
     , c.status_dt_tm =
     IF (validate(request->objarray[dt.seq].status_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
        objarray[dt.seq].status_dt_tm,0.0))
     ELSE null
     ENDIF
     ,
     c.created_dt_tm = cnvtdatetime(transinfo->trans_dt_tm), c.accessed_dt_tm =
     IF (validate(request->objarray[dt.seq].accessed_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request
        ->objarray[dt.seq].accessed_dt_tm,0.0))
     ELSE null
     ENDIF
     , c.batch_alias =
     IF (validate(request->objarray[dt.seq].batch_alias,char(128)) != char(128)) validate(request->
       objarray[dt.seq].batch_alias,char(128))
     ELSE ""
     ENDIF
     ,
     c.batch_dt_tm =
     IF (validate(request->objarray[dt.seq].batch_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request->
        objarray[dt.seq].batch_dt_tm,0.0))
     ELSE null
     ENDIF
     , c.active_ind =
     IF ((validate(request->objarray[dt.seq].active_ind,- (1))=- (1))) true
     ELSE validate(request->objarray[dt.seq].active_ind,- (1))
     ENDIF
     , c.updt_dt_tm = cnvtdatetime(transinfo->trans_dt_tm),
     c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
     c.updt_applctx = reqinfo->updt_applctx
    PLAN (dt)
     JOIN (c)
    WITH nocounter, status(mrsstatus->objarray[dt.seq].status)
   ;end insert
   FOR (i = 1 TO size(mrsstatus->objarray,5))
     IF ((mrsstatus->objarray[i].status != 1))
      CALL checkerror(insert_error)
      RETURN
     ENDIF
     IF (mndamodrec=size(reply->mod_objs[mndamodobj].mod_recs,5))
      SET stat = alterlist(reply->mod_objs[mndamodobj].mod_recs,1)
     ENDIF
     SET mndamodrec = (mndamodrec+ 1)
     SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].table_name = msdatablename
     SET reply->mod_objs[mndamodobj].mod_recs[mndamodrec].pk_values = cnvtstring(mrsstatus->objarray[
      i].daid,17,1)
   ENDFOR
   CALL checkerror(true)
 END ;Subroutine
 SUBROUTINE checkerror(nfailed)
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
 SUBROUTINE logfieldmodified(sfieldname,sfieldtype,sobjvalue,sdbvalue)
   IF (mndamodfld=size(reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds,5))
    SET stat = alterlist(reply->mod_objs[mndamodobj].mod_recs[mndamodrec].mod_flds,(mndamodfld+ 1))
   ENDIF
   SET mndamodfld = (mndamodfld+ 1)
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

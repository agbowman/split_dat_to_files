CREATE PROGRAM afc_da_upt_chrg_batch_dtl_fld:dba
 SET afc_da_upt_chrg_batch_dtl_fld_vrsn = 20130816
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
 SET msdatablename = "CHARGE_BATCH_DETAIL_FIELD"
 DECLARE mndamodobj = i4 WITH noconstant(0)
 DECLARE mndamodrec = i4 WITH noconstant(0)
 DECLARE mndamodfld = i4 WITH noconstant(0)
 DECLARE mndastart = i4 WITH noconstant(1)
 DECLARE mndastop = i4 WITH noconstant(0)
 DECLARE checkerror(nfailed=i4) = i2 WITH protect
 DECLARE logfieldmodified(sfieldname=vc,sfieldtype=vc,sobjvalue=vc,sdbvalue=vc) = null
 DECLARE upt_charge_batch_detail_field(nstart=i4,nstop=i4) = null WITH protect
 IF (trim(cnvtstring(validate(transinfo->trans_dt_tm,0)))="0")
  RECORD transinfo(
    1 trans_dt_tm = dq8
  )
  SET transinfo->trans_dt_tm = cnvtdatetime(curdate,curtime3)
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
 CALL upt_charge_batch_detail_field(mndastart,mndastop)
 SUBROUTINE upt_charge_batch_detail_field(nstart,nstop)
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE blocked = i2 WITH noconstant(0), protect
   SET blocked = false
   SET i = nstart
   FOR (i = 1 TO size(request->objarray,5))
     IF (validate(request->objarray[i].charge_batch_detail_field_id,- (0.00001)) <= 0.0)
      IF (false=checkerror(attribute_error))
       RETURN
      ENDIF
     ENDIF
   ENDFOR
   SET blocked = false
   SELECT INTO "nl:"
    c.*
    FROM charge_batch_detail_field c,
     (dummyt dt  WITH seq = value(size(request->objarray,5)))
    PLAN (dt)
     JOIN (c
     WHERE (c.charge_batch_detail_field_id=request->objarray[dt.seq].charge_batch_detail_field_id))
    DETAIL
     mndamodrec = (mndamodrec+ 1), mndamodfld = 0, reply->mod_objs[mndamodobj].mod_recs[mndamodrec].
     table_name = msdatablename,
     reply->mod_objs[mndamodobj].mod_recs[mndamodrec].pk_values = build(c
      .charge_batch_detail_field_id)
     IF ((validate(request->objarray[dt.seq].charge_batch_detail_id,c.charge_batch_detail_id) != - (
     0.00001))
      AND validate(request->objarray[dt.seq].charge_batch_detail_id,c.charge_batch_detail_id) != c
     .charge_batch_detail_id)
      CALL logfieldmodified("CHARGE_BATCH_DETAIL_ID","F8",build(validate(request->objarray[dt.seq].
        charge_batch_detail_id,c.charge_batch_detail_id)),build(c.charge_batch_detail_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].field_type_cd,c.field_type_cd) != - (0.00001))
      AND validate(request->objarray[dt.seq].field_type_cd,c.field_type_cd) != c.field_type_cd)
      CALL logfieldmodified("FIELD_TYPE_CD","F8",build(validate(request->objarray[dt.seq].
        field_type_cd,c.field_type_cd)),build(c.field_type_cd))
     ENDIF
     IF (((validate(request->objarray[dt.seq].field_value_dt_tm,c.field_value_dt_tm) != 0.0
      AND validate(request->objarray[dt.seq].field_value_dt_tm,c.field_value_dt_tm) != c
     .field_value_dt_tm) OR (validate(request->objarray[dt.seq].field_value_dt_tm_null,0)=1)) )
      CALL logfieldmodified("FIELD_VALUE_DT_TM","Q8",cnvtstring(validate(request->objarray[dt.seq].
        field_value_dt_tm,c.field_value_dt_tm)),cnvtstring(c.field_value_dt_tm))
     ENDIF
     IF (validate(request->objarray[dt.seq].field_value_char,c.field_value_char) != char(128)
      AND validate(request->objarray[dt.seq].field_value_char,c.field_value_char) != c
     .field_value_char)
      CALL logfieldmodified("FIELD_VALUE_CHAR","C200",validate(request->objarray[dt.seq].
       field_value_char,c.field_value_char),c.field_value_char)
     ENDIF
     IF ((validate(request->objarray[dt.seq].field_value_nbr,c.field_value_nbr) != - (0.00001))
      AND validate(request->objarray[dt.seq].field_value_nbr,c.field_value_nbr) != c.field_value_nbr)
      CALL logfieldmodified("FIELD_VALUE_NBR","F8",build(validate(request->objarray[dt.seq].
        field_value_nbr,c.field_value_nbr)),build(c.field_value_nbr))
     ENDIF
     IF ((validate(request->objarray[dt.seq].field_value_ind,c.field_value_ind) != - (1))
      AND validate(request->objarray[dt.seq].field_value_ind,c.field_value_ind) != c.field_value_ind)
      CALL logfieldmodified("FIELD_VALUE_IND","I2",cnvtstring(validate(request->objarray[dt.seq].
        field_value_ind,c.field_value_ind)),cnvtstring(c.field_value_ind))
     ENDIF
     IF ((validate(request->objarray[dt.seq].field_value_cd,c.field_value_cd) != - (0.00001))
      AND validate(request->objarray[dt.seq].field_value_cd,c.field_value_cd) != c.field_value_cd)
      CALL logfieldmodified("FIELD_VALUE_CD","F8",build(validate(request->objarray[dt.seq].
        field_value_cd,c.field_value_cd)),build(c.field_value_cd))
     ENDIF
     IF ((validate(request->objarray[dt.seq].active_ind,c.active_ind) != - (1))
      AND validate(request->objarray[dt.seq].active_ind,c.active_ind) != c.active_ind)
      CALL logfieldmodified("ACTIVE_IND","I2",cnvtstring(validate(request->objarray[dt.seq].
        active_ind,c.active_ind)),cnvtstring(c.active_ind))
     ENDIF
     IF (((validate(request->objarray[dt.seq].field_value_start_dt_tm,c.field_value_start_dt_tm) !=
     0.0
      AND validate(request->objarray[dt.seq].field_value_start_dt_tm,c.field_value_start_dt_tm) != c
     .field_value_start_dt_tm) OR (validate(request->objarray[dt.seq].field_value_start_dt_tm_null,0)
     =1)) )
      CALL logfieldmodified("FIELD_VALUE_START_DT_TM","Q8",cnvtstring(validate(request->objarray[dt
        .seq].field_value_start_dt_tm,c.field_value_start_dt_tm)),cnvtstring(c
       .field_value_start_dt_tm))
     ENDIF
     IF (((validate(request->objarray[dt.seq].field_value_end_dt_tm,c.field_value_end_dt_tm) != 0.0
      AND validate(request->objarray[dt.seq].field_value_end_dt_tm,c.field_value_end_dt_tm) != c
     .field_value_end_dt_tm) OR (validate(request->objarray[dt.seq].field_value_end_dt_tm_null,0)=1
     )) )
      CALL logfieldmodified("FIELD_VALUE_END_DT_TM","Q8",cnvtstring(validate(request->objarray[dt.seq
        ].field_value_end_dt_tm,c.field_value_end_dt_tm)),cnvtstring(c.field_value_end_dt_tm))
     ENDIF
     IF ((validate(request->objarray[dt.seq].field_value_prsnl_id,c.field_value_prsnl_id) != - (
     0.00001))
      AND validate(request->objarray[dt.seq].field_value_prsnl_id,c.field_value_prsnl_id) != c
     .field_value_prsnl_id)
      CALL logfieldmodified("FIELD_VALUE_PRSNL_ID","F8",build(validate(request->objarray[dt.seq].
        field_value_prsnl_id,c.field_value_prsnl_id)),build(c.field_value_prsnl_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].priority_seq,c.priority_seq) != - (1))
      AND validate(request->objarray[dt.seq].priority_seq,c.priority_seq) != c.priority_seq)
      CALL logfieldmodified("PRIORITY_SEQ","I4",cnvtstring(validate(request->objarray[dt.seq].
        priority_seq,c.priority_seq)),cnvtstring(c.priority_seq))
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
    WITH forupdate(c)
   ;end select
   FOR (i = 1 TO size(mrsstatus->objarray,5))
     IF ((mrsstatus->objarray[i].status != 1))
      CALL checkerror(lock_error)
      RETURN
     ENDIF
   ENDFOR
   UPDATE  FROM charge_batch_detail_field c,
     (dummyt dt  WITH seq = value(size(request->objarray,5)))
    SET c.charge_batch_detail_id =
     IF ((validate(request->objarray[dt.seq].charge_batch_detail_id,- (0.00001)) != - (0.00001)))
      validate(request->objarray[dt.seq].charge_batch_detail_id,- (0.00001))
     ELSE c.charge_batch_detail_id
     ENDIF
     , c.field_type_cd =
     IF ((validate(request->objarray[dt.seq].field_type_cd,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].field_type_cd,- (0.00001))
     ELSE c.field_type_cd
     ENDIF
     , c.field_value_dt_tm =
     IF (validate(request->objarray[dt.seq].field_value_dt_tm,0.0) > 0.0) cnvtdatetime(validate(
        request->objarray[dt.seq].field_value_dt_tm,0.0))
     ELSEIF (validate(request->objarray[dt.seq].field_value_dt_tm_null,0)=1) null
     ELSE c.field_value_dt_tm
     ENDIF
     ,
     c.field_value_char =
     IF (validate(request->objarray[dt.seq].field_value_char,char(128)) != char(128)) validate(
       request->objarray[dt.seq].field_value_char,char(128))
     ELSE c.field_value_char
     ENDIF
     , c.field_value_nbr =
     IF ((validate(request->objarray[dt.seq].field_value_nbr,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].field_value_nbr,- (0.00001))
     ELSE c.field_value_nbr
     ENDIF
     , c.field_value_ind =
     IF ((validate(request->objarray[dt.seq].field_value_ind,- (1)) != - (1))) validate(request->
       objarray[dt.seq].field_value_ind,- (1))
     ELSE c.field_value_ind
     ENDIF
     ,
     c.field_value_cd =
     IF ((validate(request->objarray[dt.seq].field_value_cd,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].field_value_cd,- (0.00001))
     ELSE c.field_value_cd
     ENDIF
     , c.field_value_start_dt_tm =
     IF (validate(request->objarray[dt.seq].field_value_start_dt_tm,0.0) > 0.0) cnvtdatetime(validate
       (request->objarray[dt.seq].field_value_start_dt_tm,0.0))
     ELSEIF (validate(request->objarray[dt.seq].field_value_start_dt_tm_null,0)=1) null
     ELSE c.field_value_start_dt_tm
     ENDIF
     , c.field_value_end_dt_tm =
     IF (validate(request->objarray[dt.seq].field_value_end_dt_tm,0.0) > 0.0) cnvtdatetime(validate(
        request->objarray[dt.seq].field_value_end_dt_tm,0.0))
     ELSEIF (validate(request->objarray[dt.seq].field_value_end_dt_tm_null,0)=1) null
     ELSE c.field_value_end_dt_tm
     ENDIF
     ,
     c.field_value_prsnl_id =
     IF ((validate(request->objarray[dt.seq].field_value_prsnl_id,- (0.00001)) != - (0.00001)))
      validate(request->objarray[dt.seq].field_value_prsnl_id,- (0.00001))
     ELSE c.field_value_prsnl_id
     ENDIF
     , c.priority_seq =
     IF ((validate(request->objarray[dt.seq].priority_seq,- (1)) != - (1))) validate(request->
       objarray[dt.seq].priority_seq,- (1))
     ELSE c.priority_seq
     ENDIF
     , c.active_ind =
     IF ((validate(request->objarray[dt.seq].active_ind,- (1)) != - (1))) validate(request->objarray[
       dt.seq].active_ind,- (1))
     ELSE c.active_ind
     ENDIF
     ,
     c.updt_dt_tm = cnvtdatetime(transinfo->trans_dt_tm), c.updt_id = reqinfo->updt_id, c.updt_task
      = reqinfo->updt_task,
     c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx
    PLAN (dt
     WHERE (mrsstatus->objarray[dt.seq].modify_this_record=true))
     JOIN (c
     WHERE (c.charge_batch_detail_field_id=request->objarray[dt.seq].charge_batch_detail_field_id))
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

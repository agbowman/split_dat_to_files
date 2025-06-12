CREATE PROGRAM afc_da_upt_charge_event_mod:dba
 SET afc_upt_charge_event_mod_vrsn = 20171002
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
 DECLARE mdtdanone = dq8 WITH noconstant(0.0)
 DECLARE mdtdaend = dq8 WITH noconstant(0.0)
 DECLARE msdatablename = vc WITH noconstant("")
 SET mdtdanone = cnvtdatetime("01-JAN-1800 00:00:00.00")
 SET mdtdaend = cnvtdatetime("31-DEC-2100 23:59:59.00")
 SET msdatablename = "CHARGE_EVENT_MOD"
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
 CALL upt_charge_event_mod(mndastart,mndastop)
 SUBROUTINE (upt_charge_event_mod(nstart=i4,nstop=i4) =null WITH protect)
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE blocked = i2 WITH noconstant(0), protect
   SET blocked = false
   SET i = nstart
   FOR (i = 1 TO size(request->objarray,5))
     IF (validate(request->objarray[i].charge_event_mod_id,- (0.00001)) <= 0.0)
      IF (false=checkerror(attribute_error))
       RETURN
      ENDIF
     ENDIF
   ENDFOR
   SET blocked = false
   SELECT INTO "nl:"
    c.*
    FROM charge_event_mod c,
     (dummyt dt  WITH seq = value(size(request->objarray,5)))
    PLAN (dt)
     JOIN (c
     WHERE (c.charge_event_mod_id=request->objarray[dt.seq].charge_event_mod_id))
    DETAIL
     mndamodrec += 1, mndamodfld = 0, reply->mod_objs[mndamodobj].mod_recs[mndamodrec].table_name =
     msdatablename,
     reply->mod_objs[mndamodobj].mod_recs[mndamodrec].pk_values = build(c.charge_event_mod_id)
     IF ((validate(request->objarray[dt.seq].charge_event_id,c.charge_event_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].charge_event_id,c.charge_event_id) != c.charge_event_id)
      CALL logfieldmodified("CHARGE_EVENT_ID","F8",build(validate(request->objarray[dt.seq].
        charge_event_id,c.charge_event_id)),build(c.charge_event_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].charge_event_mod_type_cd,c.charge_event_mod_type_cd) !=
     - (0.00001))
      AND validate(request->objarray[dt.seq].charge_event_mod_type_cd,c.charge_event_mod_type_cd) !=
     c.charge_event_mod_type_cd)
      CALL logfieldmodified("CHARGE_EVENT_MOD_TYPE_CD","F8",build(validate(request->objarray[dt.seq].
        charge_event_mod_type_cd,c.charge_event_mod_type_cd)),build(c.charge_event_mod_type_cd))
     ENDIF
     IF (validate(request->objarray[dt.seq].field1,c.field1) != char(128)
      AND validate(request->objarray[dt.seq].field1,c.field1) != c.field1)
      CALL logfieldmodified("FIELD1","C200",validate(request->objarray[dt.seq].field1,c.field1),c
      .field1)
     ENDIF
     IF (validate(request->objarray[dt.seq].field2,c.field2) != char(128)
      AND validate(request->objarray[dt.seq].field2,c.field2) != c.field2)
      CALL logfieldmodified("FIELD2","C200",validate(request->objarray[dt.seq].field2,c.field2),c
      .field2)
     ENDIF
     IF (validate(request->objarray[dt.seq].field3,c.field3) != char(128)
      AND validate(request->objarray[dt.seq].field3,c.field3) != c.field3)
      CALL logfieldmodified("FIELD3","C200",validate(request->objarray[dt.seq].field3,c.field3),c
      .field3)
     ENDIF
     IF (validate(request->objarray[dt.seq].field4,c.field4) != char(128)
      AND validate(request->objarray[dt.seq].field4,c.field4) != c.field4)
      CALL logfieldmodified("FIELD4","C200",validate(request->objarray[dt.seq].field4,c.field4),c
      .field4)
     ENDIF
     IF (validate(request->objarray[dt.seq].field5,c.field5) != char(128)
      AND validate(request->objarray[dt.seq].field5,c.field5) != c.field5)
      CALL logfieldmodified("FIELD5","C200",validate(request->objarray[dt.seq].field5,c.field5),c
      .field5)
     ENDIF
     IF (validate(request->objarray[dt.seq].field6,c.field6) != char(128)
      AND validate(request->objarray[dt.seq].field6,c.field6) != c.field6)
      CALL logfieldmodified("FIELD6","C200",validate(request->objarray[dt.seq].field6,c.field6),c
      .field6)
     ENDIF
     IF (validate(request->objarray[dt.seq].field7,c.field7) != char(128)
      AND validate(request->objarray[dt.seq].field7,c.field7) != c.field7)
      CALL logfieldmodified("FIELD7","C200",validate(request->objarray[dt.seq].field7,c.field7),c
      .field7)
     ENDIF
     IF (validate(request->objarray[dt.seq].field8,c.field8) != char(128)
      AND validate(request->objarray[dt.seq].field8,c.field8) != c.field8)
      CALL logfieldmodified("FIELD8","C200",validate(request->objarray[dt.seq].field8,c.field8),c
      .field8)
     ENDIF
     IF (validate(request->objarray[dt.seq].field9,c.field9) != char(128)
      AND validate(request->objarray[dt.seq].field9,c.field9) != c.field9)
      CALL logfieldmodified("FIELD9","C200",validate(request->objarray[dt.seq].field9,c.field9),c
      .field9)
     ENDIF
     IF (validate(request->objarray[dt.seq].field10,c.field10) != char(128)
      AND validate(request->objarray[dt.seq].field10,c.field10) != c.field10)
      CALL logfieldmodified("FIELD10","C200",validate(request->objarray[dt.seq].field10,c.field10),c
      .field10)
     ENDIF
     IF ((validate(request->objarray[dt.seq].active_ind,c.active_ind) != - (1))
      AND validate(request->objarray[dt.seq].active_ind,c.active_ind) != c.active_ind)
      CALL logfieldmodified("ACTIVE_IND","I2",cnvtstring(validate(request->objarray[dt.seq].
        active_ind,c.active_ind)),cnvtstring(c.active_ind))
     ENDIF
     IF ((validate(request->objarray[dt.seq].active_status_cd,c.active_status_cd) != - (0.00001))
      AND validate(request->objarray[dt.seq].active_status_cd,c.active_status_cd) != c
     .active_status_cd)
      CALL logfieldmodified("ACTIVE_STATUS_CD","F8",build(validate(request->objarray[dt.seq].
        active_status_cd,c.active_status_cd)),build(c.active_status_cd))
     ENDIF
     IF (validate(request->objarray[dt.seq].beg_effective_dt_tm,c.beg_effective_dt_tm) != 0.0
      AND validate(request->objarray[dt.seq].beg_effective_dt_tm,c.beg_effective_dt_tm) != c
     .beg_effective_dt_tm)
      CALL logfieldmodified("BEG_EFFECTIVE_DT_TM","Q8",cnvtstring(validate(request->objarray[dt.seq].
        beg_effective_dt_tm,c.beg_effective_dt_tm)),cnvtstring(c.beg_effective_dt_tm))
     ENDIF
     IF (validate(request->objarray[dt.seq].end_effective_dt_tm,c.end_effective_dt_tm) != 0.0
      AND validate(request->objarray[dt.seq].end_effective_dt_tm,c.end_effective_dt_tm) != c
     .end_effective_dt_tm)
      CALL logfieldmodified("END_EFFECTIVE_DT_TM","Q8",cnvtstring(validate(request->objarray[dt.seq].
        end_effective_dt_tm,c.end_effective_dt_tm)),cnvtstring(c.end_effective_dt_tm))
     ENDIF
     IF ((validate(request->objarray[dt.seq].code1_cd,c.code1_cd) != - (0.00001))
      AND validate(request->objarray[dt.seq].code1_cd,c.code1_cd) != c.code1_cd)
      CALL logfieldmodified("CODE1_CD","F8",build(validate(request->objarray[dt.seq].code1_cd,c
        .code1_cd)),build(c.code1_cd))
     ENDIF
     IF ((validate(request->objarray[dt.seq].nomen_id,c.nomen_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].nomen_id,c.nomen_id) != c.nomen_id)
      CALL logfieldmodified("NOMEN_ID","F8",build(validate(request->objarray[dt.seq].nomen_id,c
        .nomen_id)),build(c.nomen_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].field1_id,c.field1_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].field1_id,c.field1_id) != c.field1_id)
      CALL logfieldmodified("FIELD1_ID","F8",build(validate(request->objarray[dt.seq].field1_id,c
        .field1_id)),build(c.field1_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].field2_id,c.field2_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].field2_id,c.field2_id) != c.field2_id)
      CALL logfieldmodified("FIELD2_ID","F8",build(validate(request->objarray[dt.seq].field2_id,c
        .field2_id)),build(c.field2_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].field3_id,c.field3_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].field3_id,c.field3_id) != c.field3_id)
      CALL logfieldmodified("FIELD3_ID","F8",build(validate(request->objarray[dt.seq].field3_id,c
        .field3_id)),build(c.field3_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].field4_id,c.field4_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].field4_id,c.field4_id) != c.field4_id)
      CALL logfieldmodified("FIELD4_ID","F8",build(validate(request->objarray[dt.seq].field4_id,c
        .field4_id)),build(c.field4_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].field5_id,c.field5_id) != - (0.00001))
      AND validate(request->objarray[dt.seq].field5_id,c.field5_id) != c.field5_id)
      CALL logfieldmodified("FIELD5_ID","F8",build(validate(request->objarray[dt.seq].field5_id,c
        .field5_id)),build(c.field5_id))
     ENDIF
     IF ((validate(request->objarray[dt.seq].cm1_nbr,c.cm1_nbr) != - (0.00001))
      AND validate(request->objarray[dt.seq].cm1_nbr,c.cm1_nbr) != c.cm1_nbr)
      CALL logfieldmodified("CM1_NBR","F8",build(validate(request->objarray[dt.seq].cm1_nbr,c.cm1_nbr
        )),build(c.cm1_nbr))
     ENDIF
     IF (((validate(request->objarray[dt.seq].activity_dt_tm,c.activity_dt_tm) != 0.0
      AND validate(request->objarray[dt.seq].activity_dt_tm,c.activity_dt_tm) != c.activity_dt_tm)
      OR (validate(request->objarray[dt.seq].activity_dt_tm_null,0)=1)) )
      CALL logfieldmodified("ACTIVITY_DT_TM","Q8",cnvtstring(validate(request->objarray[dt.seq].
        activity_dt_tm,c.activity_dt_tm)),cnvtstring(c.activity_dt_tm))
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
   UPDATE  FROM charge_event_mod c,
     (dummyt dt  WITH seq = value(size(request->objarray,5)))
    SET c.charge_event_id =
     IF ((validate(request->objarray[dt.seq].charge_event_id,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].charge_event_id,- (0.00001))
     ELSE c.charge_event_id
     ENDIF
     , c.charge_event_mod_type_cd =
     IF ((validate(request->objarray[dt.seq].charge_event_mod_type_cd,- (0.00001)) != - (0.00001)))
      validate(request->objarray[dt.seq].charge_event_mod_type_cd,- (0.00001))
     ELSE c.charge_event_mod_type_cd
     ENDIF
     , c.field1 =
     IF (validate(request->objarray[dt.seq].field1,char(128)) != char(128)) validate(request->
       objarray[dt.seq].field1,char(128))
     ELSE c.field1
     ENDIF
     ,
     c.field2 =
     IF (validate(request->objarray[dt.seq].field2,char(128)) != char(128)) validate(request->
       objarray[dt.seq].field2,char(128))
     ELSE c.field2
     ENDIF
     , c.field3 =
     IF (validate(request->objarray[dt.seq].field3,char(128)) != char(128)) validate(request->
       objarray[dt.seq].field3,char(128))
     ELSE c.field3
     ENDIF
     , c.field4 =
     IF (validate(request->objarray[dt.seq].field4,char(128)) != char(128)) validate(request->
       objarray[dt.seq].field4,char(128))
     ELSE c.field4
     ENDIF
     ,
     c.field5 =
     IF (validate(request->objarray[dt.seq].field5,char(128)) != char(128)) validate(request->
       objarray[dt.seq].field5,char(128))
     ELSE c.field5
     ENDIF
     , c.field6 =
     IF (validate(request->objarray[dt.seq].field6,char(128)) != char(128)) validate(request->
       objarray[dt.seq].field6,char(128))
     ELSE c.field6
     ENDIF
     , c.field7 =
     IF (validate(request->objarray[dt.seq].field7,char(128)) != char(128)) validate(request->
       objarray[dt.seq].field7,char(128))
     ELSE c.field7
     ENDIF
     ,
     c.field8 =
     IF (validate(request->objarray[dt.seq].field8,char(128)) != char(128)) validate(request->
       objarray[dt.seq].field8,char(128))
     ELSE c.field8
     ENDIF
     , c.field9 =
     IF (validate(request->objarray[dt.seq].field9,char(128)) != char(128)) validate(request->
       objarray[dt.seq].field9,char(128))
     ELSE c.field9
     ENDIF
     , c.field10 =
     IF (validate(request->objarray[dt.seq].field10,char(128)) != char(128)) validate(request->
       objarray[dt.seq].field10,char(128))
     ELSE c.field10
     ENDIF
     ,
     c.beg_effective_dt_tm =
     IF (validate(request->objarray[dt.seq].beg_effective_dt_tm,0.0) > 0.0) cnvtdatetime(validate(
        request->objarray[dt.seq].beg_effective_dt_tm,0.0))
     ELSE c.beg_effective_dt_tm
     ENDIF
     , c.end_effective_dt_tm =
     IF (validate(request->objarray[dt.seq].end_effective_dt_tm,0.0) > 0.0) cnvtdatetime(validate(
        request->objarray[dt.seq].end_effective_dt_tm,0.0))
     ELSE c.end_effective_dt_tm
     ENDIF
     , c.code1_cd =
     IF ((validate(request->objarray[dt.seq].code1_cd,- (0.00001)) != - (0.00001))) validate(request
       ->objarray[dt.seq].code1_cd,- (0.00001))
     ELSE c.code1_cd
     ENDIF
     ,
     c.nomen_id =
     IF ((validate(request->objarray[dt.seq].nomen_id,- (0.00001)) != - (0.00001))) validate(request
       ->objarray[dt.seq].nomen_id,- (0.00001))
     ELSE c.nomen_id
     ENDIF
     , c.field1_id =
     IF ((validate(request->objarray[dt.seq].field1_id,- (0.00001)) != - (0.00001))) validate(request
       ->objarray[dt.seq].field1_id,- (0.00001))
     ELSE c.field1_id
     ENDIF
     , c.field2_id =
     IF ((validate(request->objarray[dt.seq].field2_id,- (0.00001)) != - (0.00001))) validate(request
       ->objarray[dt.seq].field2_id,- (0.00001))
     ELSE c.field2_id
     ENDIF
     ,
     c.field3_id =
     IF ((validate(request->objarray[dt.seq].field3_id,- (0.00001)) != - (0.00001))) validate(request
       ->objarray[dt.seq].field3_id,- (0.00001))
     ELSE c.field3_id
     ENDIF
     , c.field4_id =
     IF ((validate(request->objarray[dt.seq].field4_id,- (0.00001)) != - (0.00001))) validate(request
       ->objarray[dt.seq].field4_id,- (0.00001))
     ELSE c.field4_id
     ENDIF
     , c.field5_id =
     IF ((validate(request->objarray[dt.seq].field5_id,- (0.00001)) != - (0.00001))) validate(request
       ->objarray[dt.seq].field5_id,- (0.00001))
     ELSE c.field5_id
     ENDIF
     ,
     c.cm1_nbr =
     IF ((validate(request->objarray[dt.seq].cm1_nbr,- (0.00001)) != - (0.00001))) validate(request->
       objarray[dt.seq].cm1_nbr,- (0.00001))
     ELSE c.cm1_nbr
     ENDIF
     , c.activity_dt_tm =
     IF (validate(request->objarray[dt.seq].activity_dt_tm,0.0) > 0.0) cnvtdatetime(validate(request
        ->objarray[dt.seq].activity_dt_tm,0.0))
     ELSEIF (validate(request->objarray[dt.seq].activity_dt_tm_null,0)=1) null
     ELSE c.activity_dt_tm
     ENDIF
     , c.updt_cnt = (c.updt_cnt+ 1),
     c.updt_dt_tm = cnvtdatetime(transinfo->trans_dt_tm), c.updt_id = reqinfo->updt_id, c.updt_task
      = reqinfo->updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.active_ind =
     IF ((validate(request->objarray[dt.seq].active_ind,- (1)) != - (1))) validate(request->objarray[
       dt.seq].active_ind,- (1))
     ELSE c.active_ind
     ENDIF
     , c.active_status_cd =
     IF ((validate(request->objarray[dt.seq].active_status_cd,- (0.00001)) != - (0.00001))) validate(
       request->objarray[dt.seq].active_status_cd,- (0.00001))
     ELSE c.active_status_cd
     ENDIF
     ,
     c.active_status_dt_tm = evaluate(validate(request->objarray[dt.seq].active_status_cd,c
       .active_status_cd),c.active_status_cd,c.active_status_dt_tm,- (0.00001),c.active_status_dt_tm,
      cnvtdatetime(transinfo->trans_dt_tm)), c.active_status_prsnl_id = reqinfo->updt_id
    PLAN (dt
     WHERE (mrsstatus->objarray[dt.seq].modify_this_record=true))
     JOIN (c
     WHERE (c.charge_event_mod_id=request->objarray[dt.seq].charge_event_mod_id))
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

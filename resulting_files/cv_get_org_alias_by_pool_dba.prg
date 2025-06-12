CREATE PROGRAM cv_get_org_alias_by_pool:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET cfc_org_alias_by_pool = "F"
 SET lvl_error = 0
 SET lvl_warning = 1
 SET lvl_audit = 2
 SET lvl_info = 3
 SET lvl_debug = 4
 SET log_to_reply = 1
 SET log_to_screen = 0
 SET log_msg = fillstring(100," ")
 DECLARE sn_log_message(log_level,log_reply,log_event,log_mesg) = null WITH protected
 SUBROUTINE sn_log_message(log_level,log_reply,log_event,log_mesg)
   DECLARE sn_log_num = i4 WITH protected, noconstant(0)
   SET sn_log_level = evaluate(log_level,lvl_error,"E",lvl_warning,"W",
    lvl_audit,"A",lvl_info,"I",lvl_debug,
    "D","U")
   IF (log_reply=log_to_reply)
    SET sn_log_num = size(reply->status_data.subeventstatus,5)
    IF (sn_log_num=1)
     IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
      SET sn_log_num += 1
     ENDIF
    ELSE
     SET sn_log_num += 1
    ENDIF
    SET stat = alter(reply->status_data.subeventstatus,sn_log_num)
    SET reply->status_data.subeventstatus[sn_log_num].operationname = log_event
    SET reply->status_data.subeventstatus[sn_log_num].operationstatus = sn_log_level
    SET reply->status_data.subeventstatus[sn_log_num].targetobjectname = curprog
    SET reply->status_data.subeventstatus[sn_log_num].targetobjectvalue = log_mesg
   ELSE
    CALL echo("-----------------")
    CALL echo(build("Event           :",log_event))
    CALL echo(build("Status          :",sn_log_level))
    CALL echo(build("Current Program :",curprog))
    CALL echo(build("Message         :",log_mesg))
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 organization_alias_id = f8
      2 org_alias_type_cd = f8
      2 org_alias_type_disp = c40
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 alias = vc
      2 alias_pool_cd = f8
      2 alias_pool_disp = c40
      2 organization_id = f8
      2 display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  IF ( NOT (validate(req_org_alias_by_pool,0)))
   RECORD req_org_alias_by_pool(
     1 alias_pool_cd = f8
     1 organization_id = f8
     1 qual[*]
       2 organization_alias_id = f8
       2 org_alias_type_cd = f8
       2 org_alias_type_disp = c40
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 alias = vc
       2 alias_pool_cd = f8
       2 alias_pool_disp = c40
       2 organization_id = f8
       2 display = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  SET req_org_alias_by_pool->alias_pool_cd = request->alias_pool_cd
  SET req_org_alias_by_pool->organization_id = request->organization_id
  SET cfc_org_alias_by_pool = "T"
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT
  IF ((req_org_alias_by_pool->organization_id=0.0))
   PLAN (c
    WHERE (c.alias_pool_cd=req_org_alias_by_pool->alias_pool_cd)
     AND c.active_ind=1)
    JOIN (o
    WHERE c.organization_id=o.organization_id)
  ELSE
   PLAN (c
    WHERE (c.organization_id=req_org_alias_by_pool->organization_id)
     AND (c.alias_pool_cd=req_org_alias_by_pool->alias_pool_cd)
     AND c.active_ind=1)
    JOIN (o
    WHERE c.organization_id=o.organization_id)
  ENDIF
  INTO "nl:"
  c.organization_id, c.organization_alias_id, c.org_alias_type_cd,
  c.alias, c.beg_effective_dt_tm, c.end_effective_dt_tm,
  c.alias_pool_cd, o.organization_id, o.org_name
  FROM organization_alias c,
   organization o
  DETAIL
   count1 += 1, stat = alterlist(req_org_alias_by_pool->qual,count1), req_org_alias_by_pool->qual[
   count1].organization_alias_id = c.organization_alias_id,
   req_org_alias_by_pool->qual[count1].org_alias_type_cd = c.org_alias_type_cd, req_org_alias_by_pool
   ->qual[count1].alias = c.alias, req_org_alias_by_pool->qual[count1].beg_effective_dt_tm = c
   .beg_effective_dt_tm,
   req_org_alias_by_pool->qual[count1].end_effective_dt_tm = c.end_effective_dt_tm,
   req_org_alias_by_pool->qual[count1].alias_pool_cd = c.alias_pool_cd, req_org_alias_by_pool->qual[
   count1].organization_id = c.organization_id,
   req_org_alias_by_pool->qual[count1].display = o.org_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL sn_log_message(lvl_info,log_to_reply,"ORG_ALIAS","No records in Org Alias Pool")
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (cfc_org_alias_by_pool="T")
  SET stat = alterlist(reply->qual,size(req_org_alias_by_pool->qual,5))
  FOR (count1 = 1 TO size(req_org_alias_by_pool->qual,5))
    SET reply->qual[count1].organization_alias_id = req_org_alias_by_pool->qual[count1].
    organization_alias_id
    SET reply->qual[count1].org_alias_type_cd = req_org_alias_by_pool->qual[count1].org_alias_type_cd
    SET reply->qual[count1].alias = req_org_alias_by_pool->qual[count1].alias
    SET reply->qual[count1].beg_effective_dt_tm = req_org_alias_by_pool->qual[count1].
    beg_effective_dt_tm
    SET reply->qual[count1].end_effective_dt_tm = req_org_alias_by_pool->qual[count1].
    end_effective_dt_tm
    SET reply->qual[count1].alias_pool_cd = req_org_alias_by_pool->qual[count1].alias_pool_cd
    SET reply->qual[count1].organization_id = req_org_alias_by_pool->qual[count1].organization_id
    SET reply->qual[count1].display = req_org_alias_by_pool->qual[count1].display
  ENDFOR
 ENDIF
END GO

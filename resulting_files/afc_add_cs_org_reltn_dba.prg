CREATE PROGRAM afc_add_cs_org_reltn:dba
 DECLARE nfailed = i4
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 cs_org_reltn_qual = i2
    1 cs_org_reltn[10]
      2 cs_org_reltn_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET reply->cs_org_reltn_qual = action_end
 ENDIF
 SET x = action_end
 SET reply->status_data.status = "F"
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE active_code = f8
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,active_code)
 DECLARE data_status_code = f8
 SET code_set = 8
 SET cdf_meaning = "UNAUTH"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,data_status_code)
 DECLARE pricesched = f8
 SET code_set = 26078
 SET cdf_meaning = "PRICE_SCHED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,pricesched)
 DECLARE billcodesched = f8
 SET code_set = 26078
 SET cdf_meaning = "BC_SCHED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,billcodesched)
 DECLARE billitem = f8
 SET code_set = 26078
 SET cdf_meaning = "BILL_ITEM"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,billitem)
 SET table_name = "CS_ORG_RELTN"
 SET found = 0
 DECLARE dummyvar = i2
 SET dummyvar = 0
 CALL check_cs_org_reltn(dummyvar)
 IF (found=2)
  SET reply->status_data.status = "D"
  SET nfailed = insert_error
  CALL echo("GOING TO END_PROGRAM")
  GO TO end_program
 ELSEIF (found=1)
  CALL upt_cs_org_reltn(action_begin,action_end)
  IF (nfailed != false)
   SET reply->status_data.status = "D"
   SET nfailed = insert_error
   CALL echo("GOING TO END_PROGRAM")
   GO TO end_program
  ENDIF
 ELSE
  CALL add_cs_org_reltn(action_begin,action_end)
  IF (nfailed != false)
   GO TO check_error
  ENDIF
 ENDIF
#check_error
 IF (nfailed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = false
  RETURN(false)
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
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE check_cs_org_reltn(dummyvar)
   IF ((request->cs_org_reltn[x].key1_entity_name="BC_SCHED"))
    SELECT INTO "nl:"
     FROM cs_org_reltn cs
     WHERE (cs.organization_id=request->cs_org_reltn[x].organization_id)
      AND (cs.key1_id=request->cs_org_reltn[x].key1_id)
      AND (cs.key1_entity_name=request->cs_org_reltn[x].key1_entity_name)
      AND cs.cs_org_reltn_type_cd=billcodesched
     DETAIL
      IF (cs.active_ind=1)
       found = 2
      ELSE
       found = 1, request->cs_org_reltn[x].cs_org_reltn_id = cs.cs_org_reltn_id
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF ((request->cs_org_reltn[1].key1_entity_name="PRICE_SCHED"))
    SELECT INTO "nl:"
     FROM cs_org_reltn cs
     WHERE (cs.organization_id=request->cs_org_reltn[x].organization_id)
      AND (cs.key1_id=request->cs_org_reltn[x].key1_id)
      AND (cs.key1_entity_name=request->cs_org_reltn[x].key1_entity_name)
      AND cs.cs_org_reltn_type_cd=pricesched
     DETAIL
      IF (cs.active_ind=1)
       found = 2
      ELSE
       found = 1, request->cs_org_reltn[x].cs_org_reltn_id = cs.cs_org_reltn_id
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF ((request->cs_org_reltn[1].key1_entity_name="BILL_ITEM"))
    SELECT INTO "nl:"
     FROM cs_org_reltn cs
     WHERE (cs.organization_id=request->cs_org_reltn[x].organization_id)
      AND (cs.key1_id=request->cs_org_reltn[x].key1_id)
      AND (cs.key1_entity_name=request->cs_org_reltn[x].key1_entity_name)
      AND cs.cs_org_reltn_type_cd=billitem
     DETAIL
      IF (cs.active_ind=1)
       found = 2
      ELSE
       found = 1, request->cs_org_reltn[x].cs_org_reltn_id = cs.cs_org_reltn_id
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM cs_org_reltn cs
     WHERE (cs.organization_id=request->cs_org_reltn[x].organization_id)
      AND (cs.key1_id=request->cs_org_reltn[x].key1_id)
      AND (cs.cs_org_reltn_type_cd=request->cs_org_reltn[x].cs_org_reltn_type_cd)
     DETAIL
      IF (cs.active_ind=1)
       found = 2
      ELSE
       found = 1, request->cs_org_reltn[x].cs_org_reltn_id = cs.cs_org_reltn_id
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE add_cs_org_reltn(add_begin,add_end)
   SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
   SET new_nbr = 0.0
   SELECT INTO "nl:"
    y = seq(cs_org_reltn_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_nbr = cnvtreal(y)
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET nfailed = gen_nbr_error
    RETURN
   ELSE
    SET request->cs_org_reltn[x].cs_org_reltn_id = new_nbr
   ENDIF
   INSERT  FROM cs_org_reltn c
    SET c.cs_org_reltn_id = new_nbr, c.organization_id =
     IF ((request->cs_org_reltn[x].organization_id <= 0)) 0
     ELSE request->cs_org_reltn[x].organization_id
     ENDIF
     , c.cs_org_reltn_type_cd =
     IF ((request->cs_org_reltn[x].cs_org_reltn_type_cd <= 0)) 0
     ELSE request->cs_org_reltn[x].cs_org_reltn_type_cd
     ENDIF
     ,
     c.key1_id =
     IF ((request->cs_org_reltn[x].key1_id <= 0)) 0
     ELSE request->cs_org_reltn[x].key1_id
     ENDIF
     , c.key1_entity_name =
     IF ((request->cs_org_reltn[x].cs_org_reltn_type_cd != null)) request->cs_org_reltn[x].
      key1_entity_name
     ELSE '""'
     ENDIF
     , c.data_status_cd = data_status_code,
     c.data_status_dt_tm = cnvtdatetime(curdate,curtime3), c.data_status_prsnl_id = reqinfo->updt_id,
     c.beg_effective_dt_tm =
     IF ((request->cs_org_reltn[x].beg_effective_dt_tm <= 0)) cnvtdatetime(curdate,curtime3)
     ELSE cnvtdatetime(request->cs_org_reltn[x].beg_effective_dt_tm)
     ENDIF
     ,
     c.end_effective_dt_tm =
     IF ((request->cs_org_reltn[x].end_effective_dt_tm <= 0)) cnvtdatetime("31-DEC-2100 00:00:00.00")
     ELSE cnvtdatetime(request->cs_org_reltn[x].end_effective_dt_tm)
     ENDIF
     , c.active_ind = request->cs_org_reltn[x].active_ind, c.active_status_cd =
     IF ((request->cs_org_reltn[x].active_status_cd=0)) active_code
     ELSE request->cs_org_reltn[x].active_status_cd
     ENDIF
     ,
     c.active_status_prsnl_id = reqinfo->updt_id, c.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), c.updt_cnt = 0,
     c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_applctx =
     reqinfo->updt_applctx,
     c.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET nfailed = insert_error
    RETURN
   ELSE
    SET reply->cs_org_reltn[x].cs_org_reltn_id = request->cs_org_reltn[x].cs_org_reltn_id
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_cs_org_reltn(add_begin,add_end)
  UPDATE  FROM cs_org_reltn c
   SET c.active_ind = true, c.active_status_cd = active_code, c.active_status_prsnl_id = reqinfo->
    updt_id,
    c.active_status_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (c.updt_cnt+ 1), c
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
    updt_task
   WHERE (c.cs_org_reltn_id=request->cs_org_reltn[x].cs_org_reltn_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET nfailed = insert_error
   RETURN
  ELSE
   SET reply->cs_org_reltn[x].cs_org_reltn_id = request->cs_org_reltn[x].cs_org_reltn_id
  ENDIF
 END ;Subroutine
#end_program
 CALL echo("inside end_program")
END GO

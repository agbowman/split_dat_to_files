CREATE PROGRAM cps_build_top20_orders:dba
 SET modify = predeclare
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD hold
 RECORD hold(
   1 qual_count = i4
   1 qual[*]
     2 user_id = f8
     2 long_description_key_cap = vc
     2 alt_sel_category_id = f8
     2 syn_count = i4
     2 syn[*]
       3 item_count = i4
       3 synonym_id = f8
 )
 FREE RECORD anchor
 RECORD anchor(
   1 dt_tm = dq8
 )
 DECLARE last_mod = vc WITH private, noconstant(" ")
 DECLARE pharmacy_cd = f8 WITH protect, noconstant(0.0)
 DECLARE low_count = i4 WITH protect, noconstant(5)
 DECLARE code_value = f8 WITH protect, noconstant(0.0)
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE cdf_meaning = vc WITH protect, noconstant(" ")
 DECLARE stat = i4
 IF ((request->days_back < 1))
  SET anchor->dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),- (90))
 ELSE
  SET anchor->dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),- (request->days_back))
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM app_prefs ap,
   name_value_prefs nvp
  PLAN (ap
   WHERE ap.prsnl_id=0.0
    AND ap.position_cd=0.0
    AND ap.application_number=961000
    AND ap.active_ind=true)
   JOIN (nvp
   WHERE nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.parent_entity_name="APP_PREFS"
    AND nvp.pvc_name="TOP20_ORDER_COUNT")
  HEAD REPORT
   low_count = cnvtint(nvp.pvc_value)
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "NAME_VALUE_PREFS"
  GO TO exit_script
 ENDIF
 SET code_value = 0.0
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,pharmacy_cd)
 IF (stat > 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for ",trim(cdf_meaning)," on code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  item_count = count(o.order_id), o.last_update_provider_id, o.synonym_id
  FROM orders o
  PLAN (o
   WHERE o.updt_dt_tm >= cnvtdatetime(anchor->dt_tm)
    AND ((o.last_update_provider_id+ 0) > 0)
    AND ((o.synonym_id+ 0) > 0)
    AND ((o.catalog_type_cd+ 0) != pharmacy_cd)
    AND ((o.active_ind+ 0)=true))
  GROUP BY o.last_update_provider_id, o.synonym_id
  HAVING count(o.order_id) >= low_count
  ORDER BY o.last_update_provider_id, item_count DESC
  HEAD REPORT
   count = 0, stat = alterlist(hold->qual,10)
  HEAD o.last_update_provider_id
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(hold->qual,(count+ 9))
   ENDIF
   20_count = 0, hold->qual[count].user_id = o.last_update_provider_id, ncount = 0,
   stat = alterlist(hold->qual[count].syn,10)
  DETAIL
   20_count = (20_count+ 1)
   IF (20_count <= 20)
    ncount = (ncount+ 1)
    IF (mod(ncount,10)=1
     AND ncount != 1)
     stat = alterlist(hold->qual[count].syn,(ncount+ 9))
    ENDIF
    hold->qual[count].syn[ncount].item_count = item_count, hold->qual[count].syn[ncount].synonym_id
     = o.synonym_id
   ENDIF
  FOOT  o.last_update_provider_id
   hold->qual[count].syn_count = ncount, stat = alterlist(hold->qual[count].syn,ncount)
  FOOT REPORT
   hold->qual_count = count, stat = alterlist(hold->qual,count)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ORDERS"
  GO TO exit_script
 ENDIF
 IF ((hold->qual_count < 1))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d1.seq
  FROM (dummyt d1  WITH seq = value(hold->qual_count)),
   prsnl p
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (p
   WHERE (p.person_id=hold->qual[d1.seq].user_id))
  ORDER BY d1.seq
  DETAIL
   IF (p.username != null
    AND p.username > " ")
    hold->qual[d1.seq].long_description_key_cap = concat(trim(cnvtupper(p.username)),"_TOP20_ORDERS")
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ALT_SEL_CAT"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO hold->qual_count)
  IF ((hold->qual[i].long_description_key_cap > " "))
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM alt_sel_cat ac
    PLAN (ac
     WHERE (ac.owner_id=hold->qual[i].user_id)
      AND (ac.long_description_key_cap=hold->qual[i].long_description_key_cap))
    DETAIL
     hold->qual[i].alt_sel_category_id = ac.alt_sel_category_id
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "ALT_SEL_CAT"
    GO TO exit_script
   ENDIF
   IF (curqual < 1)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     y = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      hold->qual[i].alt_sel_category_id = cnvtreal(y)
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = gen_nbr_error
     SET table_name = "REFERENCE_SEQ"
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM alt_sel_cat ac
     SET ac.alt_sel_category_id = hold->qual[i].alt_sel_category_id, ac.short_description =
      "System Tracked Order Favorites", ac.long_description = hold->qual[i].long_description_key_cap,
      ac.long_description_key_cap = hold->qual[i].long_description_key_cap, ac.child_cat_ind = 0, ac
      .owner_id = hold->qual[i].user_id,
      ac.security_flag = 1, ac.updt_dt_tm = cnvtdatetime(curdate,curtime3), ac.updt_id = reqinfo->
      updt_id,
      ac.updt_task = reqinfo->updt_task, ac.updt_cnt = 0, ac.updt_applctx = reqinfo->updt_applctx,
      ac.source_component_flag = 3
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "ALT_SEL_CAT"
     GO TO exit_script
    ENDIF
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   DELETE  FROM alt_sel_list al
    WHERE (al.alt_sel_category_id=hold->qual[i].alt_sel_category_id)
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = delete_error
    SET table_name = "ALT_SEL_LIST"
    GO TO exit_script
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   INSERT  FROM alt_sel_list al,
     (dummyt d1  WITH seq = value(hold->qual[i].syn_count))
    SET al.alt_sel_category_id = hold->qual[i].alt_sel_category_id, d1.seq = d1.seq, al.sequence = d1
     .seq,
     al.list_type = 2, al.child_alt_sel_cat_id = 0.0, al.reference_task_id = 0.0,
     al.synonym_id = hold->qual[i].syn[d1.seq].synonym_id, al.updt_cnt = hold->qual[i].syn[d1.seq].
     item_count, al.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     al.updt_id = reqinfo->updt_id, al.updt_task = reqinfo->updt_task, al.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d1
     WHERE d1.seq > 0)
     JOIN (al
     WHERE 0=0)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
    SET table_name = "ALT_SEL_LIST"
    GO TO exit_script
   ENDIF
  ENDIF
  COMMIT
 ENDFOR
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "005"
 SET modify = nopredeclare
END GO

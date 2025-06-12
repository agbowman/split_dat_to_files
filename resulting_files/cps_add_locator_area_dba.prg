CREATE PROGRAM cps_add_locator_area:dba
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
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD loc_arr(
   1 location[0]
     2 del_loc_area_id = f8
 )
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET count = 0
 SET table_name = "locator_view_area_r"
 SELECT INTO "NL:"
  lvar.locator_area_id
  FROM locator_view_area_r lvar
  WHERE (lvar.locator_view_cd=request->locator_view_cd)
  DETAIL
   count += 1
   IF (mod(count,10)=1)
    stat = alter(loc_arr->location,(count+ 10))
   ENDIF
   loc_arr->location[count].del_loc_area_id = lvar.locator_area_id,
   CALL echo(loc_arr->location[count].del_loc_area_id)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alter(loc_arr->location,count)
  SET ierrcode = error(serrmsg,1)
  DELETE  FROM locator_view_area_r
   WHERE (locator_view_cd=request->locator_view_cd)
    AND locator_view_area_id > 0
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = delete_error
   GO TO check_error
  ELSE
   CALL echo(build("deleted rows = ",curqual))
   SET table_name = "locator_area"
   FOR (j = 1 TO count)
     DELETE  FROM locator_area l
      WHERE (locator_area_id=loc_arr->location[j].del_loc_area_id)
       AND locator_area_id > 0
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = delete_error
      GO TO check_error
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET table_name = "LOCATOR_AREA"
 SET number_to_insert = 0
 SET number_to_insert = request->location_qual
 IF (number_to_insert > 0)
  SET loc_area_id[value(number_to_insert)] = 0.0
  FOR (i = 1 TO number_to_insert)
    SET next_code = 0.0
    EXECUTE cpm_next_code
    SET loc_area_id[i] = next_code
  ENDFOR
  INSERT  FROM locator_area l,
    (dummyt d1  WITH seq = value(number_to_insert))
   SET l.locator_area_id = loc_area_id[d1.seq], l.location_cd = request->location[d1.seq].location_cd,
    l.caption =
    IF ((request->location[d1.seq].caption=" ")) null
    ELSE request->location[d1.seq].caption
    ENDIF
    ,
    l.alert_time =
    IF ((request->location[d1.seq].alert_time=0)) null
    ELSE request->location[d1.seq].alert_time
    ENDIF
    , l.style =
    IF ((request->location[d1.seq].style=0)) null
    ELSE request->location[d1.seq].style
    ENDIF
    , l.top =
    IF ((request->location[d1.seq].top=0)) null
    ELSE request->location[d1.seq].top
    ENDIF
    ,
    l.left =
    IF ((request->location[d1.seq].left=0)) null
    ELSE request->location[d1.seq].left
    ENDIF
    , l.right =
    IF ((request->location[d1.seq].right=0)) null
    ELSE request->location[d1.seq].right
    ENDIF
    , l.bottom =
    IF ((request->location[d1.seq].bottom=0)) null
    ELSE request->location[d1.seq].bottom
    ENDIF
    ,
    l.updt_dt_tm = cnvtdatetime(sysdate), l.updt_cnt = 0, l.updt_id = reqinfo->updt_id,
    l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.max_items = 0
   PLAN (d1)
    JOIN (l)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = insert_error
   GO TO check_error
  ELSE
   SET failed = false
  ENDIF
  SET table_name = "LOCATOR_VIEW_AREA_R"
  FOR (i = 1 TO number_to_insert)
    SET next_code = 0.0
    EXECUTE cpm_next_code
    INSERT  FROM locator_view_area_r l
     SET l.locator_view_area_id = next_code, l.locator_area_id = loc_area_id[i], l.locator_view_cd =
      request->locator_view_cd,
      l.updt_dt_tm = cnvtdatetime(sysdate), l.updt_cnt = 0, l.updt_id = reqinfo->updt_id,
      l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
  ENDFOR
  IF (curqual=0)
   SET failed = insert_error
   GO TO check_error
  ELSE
   SET failed = false
  ENDIF
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  IF (failed=none_found)
   SET reply->status_data.status = "Z"
   SET reqinfo->commit_ind = true
  ELSE
   CASE (failed)
    OF insert_error:
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    ELSE
     SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   ENDCASE
  ENDIF
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
 ENDIF
 SET pco_script_version = "002 06/29/04 TG3128"
END GO

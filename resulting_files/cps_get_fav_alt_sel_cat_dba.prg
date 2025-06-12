CREATE PROGRAM cps_get_fav_alt_sel_cat:dba
 FREE RECORD reply
 RECORD reply(
   1 ord_favorite_found = i2
   1 med_favorite_found = i2
   1 ord_cat_count = i4
   1 ord_cat[*]
     2 alt_sel_cat_id = f8
     2 short_description = vc
     2 long_description = vc
     2 child_cat_ind = i2
     2 child_count = i4
     2 updt_cnt = i4
     2 source_component_flag = i2
     2 child[*]
       3 child_alt_sel_cat_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
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
 DECLARE owner_id = f8 WITH public, noconstant(0.0)
 IF ((request->owner_id > 0))
  SET owner_id = request->owner_id
 ELSE
  SET owner_id = reqinfo->updt_id
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat ac,
   alt_sel_list al
  PLAN (ac
   WHERE ac.owner_id=owner_id
    AND ac.security_flag=1
    AND ac.source_component_flag IN (2, 3))
   JOIN (al
   WHERE al.alt_sel_category_id=outerjoin(ac.alt_sel_category_id)
    AND al.list_type=outerjoin(1)
    AND al.synonym_id < outerjoin(1))
  ORDER BY ac.long_description_key_cap DESC, al.sequence
  HEAD REPORT
   knt = 0, stat = alterlist(reply->ord_cat,10)
  HEAD ac.alt_sel_category_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->ord_cat,(knt+ 9))
   ENDIF
   reply->ord_cat[knt].alt_sel_cat_id = ac.alt_sel_category_id, reply->ord_cat[knt].short_description
    = ac.short_description, reply->ord_cat[knt].long_description = ac.long_description,
   reply->ord_cat[knt].child_cat_ind = ac.child_cat_ind, reply->ord_cat[knt].updt_cnt = ac.updt_cnt,
   reply->ord_cat[knt].source_component_flag = ac.source_component_flag,
   lknt = 0, stat = alterlist(reply->ord_cat[knt].child,10)
  DETAIL
   IF (al.alt_sel_category_id > 0)
    lknt = (lknt+ 1)
    IF (mod(lknt,10)=1
     AND lknt != 1)
     stat = alterlist(reply->ord_cat[knt].child,(lknt+ 9))
    ENDIF
    reply->ord_cat[knt].child[lknt].child_alt_sel_cat_id = al.child_alt_sel_cat_id
   ENDIF
  FOOT  ac.alt_sel_category_id
   reply->ord_cat[knt].child_count = lknt, stat = alterlist(reply->ord_cat[knt].child,lknt)
   IF (lknt > 0)
    reply->ord_cat[knt].child_cat_ind = 1
   ELSE
    reply->ord_cat[knt].child_cat_ind = 0
   ENDIF
  FOOT REPORT
   reply->ord_cat_count = knt, stat = alterlist(reply->ord_cat,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ALT_SEL_CAT"
  GO TO exit_script
 ENDIF
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
 ELSEIF ((reply->ord_cat_count < 1))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "012 01/03/02 SF3151"
END GO

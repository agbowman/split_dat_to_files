CREATE PROGRAM cps_get_all_alt_sel_cat:dba
 FREE SET reply
 RECORD reply(
   1 ord_favorite_found = i2
   1 med_favorite_found = i2
   1 ord_cat_count = i4
   1 ord_cat[*]
     2 alt_sel_cat_id = f8
     2 short_description = vc
     2 long_description = vc
     2 source_component_flag = i2
     2 child_cat_ind = i2
     2 child_count = i4
     2 updt_cnt = i4
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
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat ac,
   alt_sel_list al
  PLAN (ac
   WHERE ((ac.owner_id+ 0)=0)
    AND ((ac.security_flag+ 0)=2)
    AND ((ac.ahfs_ind+ 0) IN (0, null))
    AND ((ac.adhoc_ind+ 0) IN (0, null)))
   JOIN (al
   WHERE al.alt_sel_category_id=outerjoin(ac.alt_sel_category_id)
    AND al.list_type=outerjoin(1)
    AND al.synonym_id < outerjoin(1))
  ORDER BY ac.long_description_key_cap, al.alt_sel_category_id, al.sequence
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
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ALT_SEL_CAT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   SET failed = true
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "Z"
   SET failed = true
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SET last_mod = "017 07/19/05 PC3603"
END GO

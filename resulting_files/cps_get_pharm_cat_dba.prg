CREATE PROGRAM cps_get_pharm_cat:dba
 FREE SET reply
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
#build_cache
 SET knt = 0
 SELECT INTO "nl:"
  ac.alt_sel_category_id, ac.long_description_key_cap
  FROM alt_sel_cat ac
  PLAN (ac
   WHERE ac.owner_id=0
    AND ac.security_flag=2
    AND ac.ahfs_ind=1
    AND ac.adhoc_ind IN (0, null))
  ORDER BY ac.long_description_key_cap
  HEAD REPORT
   knt = 0, stat = alterlist(reply->ord_cat,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->ord_cat,(knt+ 9))
   ENDIF
   reply->ord_cat[knt].alt_sel_cat_id = ac.alt_sel_category_id, reply->ord_cat[knt].short_description
    = ac.short_description, reply->ord_cat[knt].long_description = ac.long_description,
   reply->ord_cat[knt].child_cat_ind = ac.child_cat_ind, reply->ord_cat[knt].updt_cnt = ac.updt_cnt,
   CALL echo(reply->ord_cat[knt].alt_sel_cat_id)
  FOOT REPORT
   reply->ord_cat_count = knt, stat = alterlist(reply->ord_cat,knt),
   CALL echo(build("ord_cat_cnt : ",reply->ord_cat_count," : ",reply->ord_cat[knt].alt_sel_cat_id))
  WITH nocounter
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
 IF (failed=true)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  al.alt_sel_category_id
  FROM (dummyt d  WITH seq = value(reply->ord_cat_count)),
   alt_sel_list al,
   alt_sel_cat ac
  PLAN (d
   WHERE d.seq > 0)
   JOIN (al
   WHERE (al.alt_sel_category_id=reply->ord_cat[d.seq].alt_sel_cat_id)
    AND (reply->ord_cat[d.seq].child_cat_ind > 0)
    AND al.list_type=1
    AND al.synonym_id < 1)
   JOIN (ac
   WHERE ac.alt_sel_category_id=al.child_alt_sel_cat_id
    AND ac.owner_id=0
    AND ac.security_flag=2)
  ORDER BY al.alt_sel_category_id, al.sequence
  HEAD al.alt_sel_category_id
   knt2 = 0
  DETAIL
   FOR (knt = 1 TO value(reply->ord_cat_count))
     IF ((reply->ord_cat[knt].alt_sel_cat_id=al.alt_sel_category_id))
      knt2 = (knt2+ 1), stat = alterlist(reply->ord_cat[knt].child,knt2), reply->ord_cat[knt].child[
      knt2].child_alt_sel_cat_id = al.child_alt_sel_cat_id,
      reply->ord_cat[knt].child_count = knt2,
      CALL echo(reply->ord_cat[knt].child[knt2].child_alt_sel_cat_id),
      CALL echo(reply->ord_cat[knt].child_count," : ",knt2)
     ENDIF
   ENDFOR
  WITH nocounter
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
END GO

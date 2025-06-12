CREATE PROGRAM cps_get_fav_nomen_cat:dba
 FREE SET reply
 RECORD reply(
   1 diag_favorite_found = i2
   1 cat_list_qual = i4
   1 cat_list[*]
     2 cat_id = f8
     2 cat_name = vc
     2 child_cat_qual = i4
     2 child_cat[*]
       3 child_cat_id = f8
   1 nomen_list_qual = i4
   1 nomen_list[*]
     2 parent_cat_id = f8
     2 cat_list_id = f8
     2 nomen_id = f8
     2 src_strg = vc
     2 src_ident = vc
     2 src_vocab_cd = f8
     2 prin_type_cd = f8
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
 IF ((request->username > " ")
  AND (request->option_flag < 1))
  SET diag_username = concat(trim(request->username),"_DIAG")
  SELECT INTO "NL:"
   FROM nomen_category nc
   PLAN (nc
    WHERE nc.category_name=diag_username)
   HEAD REPORT
    count1 = 0, stat = alterlist(reply->cat_list,10)
   DETAIL
    count1 = (count1+ 1)
    IF (count1 >= size(reply->cat_list,5))
     stat = alterlist(reply->cat_list,(count1+ 10))
    ENDIF
    reply->cat_list[count1].cat_id = nc.nomen_category_id, reply->cat_list[count1].cat_name = nc
    .category_name, reply->diag_favorite_found = 1
   FOOT REPORT
    reply->cat_list_qual = count1, stat = alterlist(reply->cat_list,count1)
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "NOMEN_CATEGORY"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET failed = true
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "Z"
    SET failed = true
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "NL:"
   FROM nomen_cat_list nl
   PLAN (nl
    WHERE nl.child_flag=1)
   ORDER BY nl.parent_category_id
   HEAD nl.parent_category_id
    count2 = 0
   DETAIL
    end_count = value(reply->cat_list_qual)
    FOR (count1 = 1 TO end_count)
      IF ((reply->cat_list[count1].cat_id=nl.parent_category_id))
       end_count = count1, count2 = (count2+ 1), reply->cat_list[count1].child_cat_qual = count2,
       stat = alterlist(reply->cat_list[count1].child_cat,count2), reply->cat_list[count1].child_cat[
       count2].child_cat_id = nl.child_category_id
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "NOMEN_CAT_LIST"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET failed = true
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "Z"
    SET failed = true
    GO TO exit_script
   ENDIF
  ENDIF
 ELSEIF ((request->option_flag > 0))
  GO TO get_items
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "INPUT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REQ->USERNAME"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Username is blank"
  SET failed = true
  GO TO exit_script
 ENDIF
#get_items
 IF ((request->option_flag > 0))
  SELECT INTO "NL:"
   nl.parent_category_id, source_string = substring(1,200,n.source_string)
   FROM nomen_cat_list nl,
    nomenclature n,
    (dummyt d  WITH seq = value(size(request->cat_list,5)))
   PLAN (d)
    JOIN (nl
    WHERE (nl.parent_category_id=request->cat_list[d.seq].cat_id)
     AND nl.child_flag=2)
    JOIN (n
    WHERE n.nomenclature_id=nl.nomenclature_id
     AND n.active_ind=1
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY nl.parent_category_id, source_string
   HEAD REPORT
    count1 = 0, stat = alterlist(reply->nomen_list,10)
   DETAIL
    count1 = (count1+ 1)
    IF (count1 >= size(reply->nomen_list,5))
     stat = alterlist(reply->nomen_list,(count1+ 10))
    ENDIF
    reply->nomen_list[count1].parent_cat_id = nl.parent_category_id, reply->nomen_list[count1].
    cat_list_id = nl.nomen_cat_list_id, reply->nomen_list[count1].nomen_id = n.nomenclature_id,
    reply->nomen_list[count1].src_strg = n.source_string, reply->nomen_list[count1].src_ident = n
    .source_identifier, reply->nomen_list[count1].src_vocab_cd = n.source_vocabulary_cd,
    reply->nomen_list[count1].prin_type_cd = n.principle_type_cd
   FOOT REPORT
    reply->nomen_list_qual = count1, stat = alterlist(reply->nomen_list,count1)
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "NOMEN_LIST"
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
 ELSE
  SELECT INTO "NL:"
   nl.parent_category_id, source_string = substring(1,200,n.source_string)
   FROM nomen_cat_list nl,
    nomenclature n,
    (dummyt d  WITH seq = value(reply->cat_list_qual))
   PLAN (d)
    JOIN (nl
    WHERE (nl.parent_category_id=reply->cat_list[d.seq].cat_id)
     AND nl.child_flag=2)
    JOIN (n
    WHERE n.nomenclature_id=nl.nomenclature_id
     AND n.active_ind=1
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY nl.parent_category_id, source_string
   HEAD REPORT
    count1 = 0, stat = alterlist(reply->nomen_list,10)
   DETAIL
    count1 = (count1+ 1)
    IF (count1 >= size(reply->nomen_list,5))
     stat = alterlist(reply->nomen_list,(count1+ 10))
    ENDIF
    reply->nomen_list[count1].parent_cat_id = nl.parent_category_id, reply->nomen_list[count1].
    cat_list_id = nl.nomen_cat_list_id, reply->nomen_list[count1].nomen_id = n.nomenclature_id,
    reply->nomen_list[count1].src_strg = n.source_string, reply->nomen_list[count1].src_ident = n
    .source_identifier, reply->nomen_list[count1].src_vocab_cd = n.source_vocabulary_cd,
    reply->nomen_list[count1].prin_type_cd = n.principle_type_cd
   FOOT REPORT
    reply->nomen_list_qual = count1, stat = alterlist(reply->nomen_list,count1)
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "NOMEN_LIST"
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
 ENDIF
#exit_script
END GO

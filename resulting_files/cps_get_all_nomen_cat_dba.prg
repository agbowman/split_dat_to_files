CREATE PROGRAM cps_get_all_nomen_cat:dba
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
 IF ((validate(srv_nomen_cat_list->cat_list_qual,- (99))=- (99)))
  SET trace = recpersist
  FREE SET srv_nomen_cat_list
  RECORD srv_nomen_cat_list(
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
  )
  SET trace = norecpersist
  CALL echo(" ")
  CALL echo("Going to BUILD_CACHE")
  CALL echo(" ")
  GO TO build_cache
 ELSE
  CALL echo(" ")
  CALL echo("Going to GET_REPLY")
  CALL echo(" ")
  GO TO get_reply
 ENDIF
#build_cache
 CALL echo(" ")
 CALL echo("Building Cache")
 CALL echo(" ")
 CALL echo(" ")
 CALL echo("Getting Parent Categories")
 CALL echo(" ")
 SELECT INTO "NL:"
  FROM nomen_category nc
  PLAN (nc
   WHERE nc.category_name > " "
    AND findstring("_DIAG",nc.category_name) < 1)
  ORDER BY nc.category_name
  HEAD REPORT
   knt = 0, stat = alterlist(srv_nomen_cat_list->cat_list,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(srv_nomen_cat_list->cat_list,(knt+ 10))
   ENDIF
   srv_nomen_cat_list->cat_list[knt].cat_id = nc.nomen_category_id, srv_nomen_cat_list->cat_list[knt]
   .cat_name = nc.category_name
  FOOT REPORT
   srv_nomen_cat_list->cat_list_qual = knt, stat = alterlist(srv_nomen_cat_list->cat_list,knt)
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
   FREE SET srv_nomen_cat_list
   GO TO exit_script
  ELSEIF ((srv_nomen_cat_list->cat_list_qual < 1))
   SET reply->status_data.status = "Z"
   SET failed = true
   FREE SET srv_nomen_cat_list
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(" ")
 CALL echo("Getting Children")
 CALL echo(" ")
 SELECT INTO "NL:"
  nl.parent_category_id
  FROM nomen_cat_list nl
  PLAN (nl
   WHERE nl.child_flag=1)
  ORDER BY nl.parent_category_id
  HEAD nl.parent_category_id
   knt2 = 0
  DETAIL
   end_count = value(srv_nomen_cat_list->cat_list_qual)
   FOR (knt = 1 TO end_count)
     IF ((srv_nomen_cat_list->cat_list[knt].cat_id=nl.parent_category_id))
      end_count = knt, knt2 = (knt2+ 1), srv_nomen_cat_list->cat_list[knt].child_cat_qual = knt2,
      stat = alterlist(srv_nomen_cat_list->cat_list[knt].child_cat,knt2), srv_nomen_cat_list->
      cat_list[knt].child_cat[knt2].child_cat_id = nl.child_category_id
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
   FREE SET srv_nomen_cat_list
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(" ")
 CALL echo("Getting Nomen Items")
 CALL echo(" ")
 SET hold = value(srv_nomen_cat_list->cat_list_qual)
 IF (hold > 0)
  SELECT INTO "NL:"
   nl.parent_category_id, source_string = substring(1,200,n.source_string)
   FROM nomen_cat_list nl,
    nomenclature n,
    (dummyt d  WITH seq = value(hold))
   PLAN (d)
    JOIN (nl
    WHERE (nl.parent_category_id=srv_nomen_cat_list->cat_list[d.seq].cat_id)
     AND nl.child_flag=2
     AND nl.nomenclature_id > 0)
    JOIN (n
    WHERE n.nomenclature_id=nl.nomenclature_id
     AND n.active_ind=1
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY nl.parent_category_id, source_string
   HEAD REPORT
    knt = 0, stat = alterlist(srv_nomen_cat_list->nomen_list,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(srv_nomen_cat_list->nomen_list,(knt+ 10))
    ENDIF
    srv_nomen_cat_list->nomen_list[knt].parent_cat_id = nl.parent_category_id, srv_nomen_cat_list->
    nomen_list[knt].cat_list_id = nl.nomen_cat_list_id, srv_nomen_cat_list->nomen_list[knt].nomen_id
     = n.nomenclature_id,
    srv_nomen_cat_list->nomen_list[knt].src_strg = n.source_string, srv_nomen_cat_list->nomen_list[
    knt].src_ident = n.source_identifier, srv_nomen_cat_list->nomen_list[knt].src_vocab_cd = n
    .source_vocabulary_cd,
    srv_nomen_cat_list->nomen_list[knt].prin_type_cd = n.principle_type_cd
   FOOT REPORT
    stat = alterlist(srv_nomen_cat_list->nomen_list,knt), srv_nomen_cat_list->nomen_list_qual = knt
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "NOMENCLATURE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    SET failed = true
    FREE SET srv_nomen_cat_list
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#get_reply
 CALL echo(" ")
 CALL echo("Getting Reply")
 CALL echo(" ")
 IF ((request->cat_list_qual < 1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(srv_nomen_cat_list->cat_list_qual))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    knt = 0, stat = alterlist(reply->cat_list,srv_nomen_cat_list->cat_list_qual)
   DETAIL
    knt = (knt+ 1)
    IF (knt > size(reply->cat_list,5))
     stat = alterlist(reply->cat_list,(knt+ 10))
    ENDIF
    reply->cat_list[knt].cat_id = srv_nomen_cat_list->cat_list[d.seq].cat_id, reply->cat_list[knt].
    cat_name = srv_nomen_cat_list->cat_list[d.seq].cat_name, reply->cat_list[knt].child_cat_qual =
    srv_nomen_cat_list->cat_list[d.seq].child_cat_qual
    IF ((srv_nomen_cat_list->cat_list[d.seq].child_cat_qual > 0))
     stat = alterlist(reply->cat_list[knt].child_cat,srv_nomen_cat_list->cat_list[d.seq].
      child_cat_qual)
     FOR (i = 1 TO srv_nomen_cat_list->cat_list[d.seq].child_cat_qual)
       reply->cat_list[knt].child_cat[i].child_cat_id = srv_nomen_cat_list->cat_list[d.seq].
       child_cat[i].child_cat_id
     ENDFOR
    ENDIF
   FOOT REPORT
    reply->cat_list_qual = knt, stat = alterlist(reply->cat_list,knt)
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
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SELECT INTO "nl:"
   parent_cat_id = srv_nomen_cat_list->nomen_list[d2.seq].parent_cat_id, source_string =
   srv_nomen_cat_list->nomen_list[d2.seq].src_strg
   FROM (dummyt d1  WITH seq = value(request->cat_list_qual)),
    (dummyt d2  WITH seq = value(srv_nomen_cat_list->nomen_list_qual))
   PLAN (d1
    WHERE d1.seq > 0)
    JOIN (d2
    WHERE (srv_nomen_cat_list->nomen_list[d2.seq].parent_cat_id=request->cat_list[d1.seq].cat_id))
   ORDER BY parent_cat_id, source_string
   HEAD REPORT
    knt = 0, stat = alterlist(reply->nomen_list,srv_nomen_cat_list->nomen_list_qual)
   DETAIL
    knt = (knt+ 1)
    IF (knt > size(reply->nomen_list,5))
     stat = alterlist(reply->nomen_list,(knt+ 10))
    ENDIF
    reply->nomen_list[knt].parent_cat_id = srv_nomen_cat_list->nomen_list[d2.seq].parent_cat_id,
    reply->nomen_list[knt].cat_list_id = srv_nomen_cat_list->nomen_list[d2.seq].cat_list_id, reply->
    nomen_list[knt].nomen_id = srv_nomen_cat_list->nomen_list[d2.seq].nomen_id,
    reply->nomen_list[knt].src_strg = srv_nomen_cat_list->nomen_list[d2.seq].src_strg, reply->
    nomen_list[knt].src_ident = srv_nomen_cat_list->nomen_list[d2.seq].src_ident, reply->nomen_list[
    knt].src_vocab_cd = srv_nomen_cat_list->nomen_list[d2.seq].src_vocab_cd,
    reply->nomen_list[knt].prin_type_cd = srv_nomen_cat_list->nomen_list[d2.seq].prin_type_cd
   FOOT REPORT
    reply->nomen_list_qual = knt, stat = alterlist(reply->nomen_list,knt)
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "NOMENCLATURE"
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
 CALL echo(" ")
 CALL echo("Exiting Script")
 CALL echo(" ")
END GO

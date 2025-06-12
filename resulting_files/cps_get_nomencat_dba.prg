CREATE PROGRAM cps_get_nomencat:dba
 FREE SET reply
 RECORD reply(
   1 cat_list_qual = i4
   1 cat_list[*]
     2 cat_id = f8
     2 cat_name = vc
     2 child_cat_ind = i4
   1 more_nomen = i2
   1 nomen_list_qual = i4
   1 nomen_list[*]
     2 cat_list_id = f8
     2 nomen_id = f8
     2 src_strg = vc
     2 strg_ident = vc
     2 src_ident = vc
     2 con_ident = vc
     2 con_src_cd = f8
     2 src_vocab_cd = f8
     2 strg_src_cd = f8
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
 SET true = 1
 SET false = 0
 SET stat = alterlist(reply->cat_list,10)
 SET stat = alterlist(reply->nomen_list,10)
 SET reply->cat_list_qual = 0
 SET reply->nomen_list_qual = 0
 IF ((request->max_qual > 0))
  SET max_qual = (request->max_qual+ 1)
 ELSE
  SET max_qual = 101
 ENDIF
 SET knt = 0
 SET dvar = 0
 IF (validate(context->cat_list_id,0) != 0)
  SET context->cat_id = request->cat_list[1].cat_id
 ELSE
  FREE SET context
  RECORD context(
    1 cat_id = f8
    1 cat_list_id = f8
  )
  SET context->cat_id = request->cat_list[1].cat_id
 ENDIF
 IF ((context->cat_list_id > 0))
  CALL get_items(dvar)
 ELSEIF ((request->get_ind=0))
  CALL get_top_level(dvar)
 ELSEIF ((request->get_ind=1))
  CALL get_children(dvar)
  CALL get_items(dvar)
 ELSE
  CALL get_items(dvar)
 ENDIF
 GO TO end_program
 SUBROUTINE get_top_level(lvar)
  SELECT
   IF ((request->cat_list[1].cat_id < 1))
    PLAN (d1
     WHERE d1.seq > 0)
     JOIN (nc
     WHERE (nc.nomen_category_id > request->cat_list[d1.seq].cat_id))
     JOIN (d2
     WHERE d2.seq=1)
     JOIN (nl
     WHERE nl.parent_category_id=nc.nomen_category_id)
   ELSE
    PLAN (d1
     WHERE d1.seq > 0)
     JOIN (nc
     WHERE (nc.nomen_category_id=request->cat_list[d1.seq].cat_id)
      AND nc.nomen_category_id > 0)
     JOIN (d2
     WHERE d2.seq=1)
     JOIN (nl
     WHERE nl.parent_category_id=nc.nomen_category_id)
   ENDIF
   INTO "nl:"
   nc.nomen_category_id
   FROM nomen_category nc,
    nomen_cat_list nl,
    (dummyt d1  WITH seq = value(request->cat_list_qual)),
    (dummyt d2  WITH seq = 1)
   HEAD REPORT
    knt = 0, stat = alterlist(reply->cat_list,10)
   HEAD nc.nomen_category_id
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->cat_list,(knt+ 9))
    ENDIF
    reply->cat_list[knt].cat_id = nc.nomen_category_id, reply->cat_list[knt].cat_name = nc
    .category_name
   DETAIL
    IF (nl.child_category_id > 0)
     reply->cat_list[knt].child_cat_ind = true
    ENDIF
   FOOT REPORT
    reply->cat_list_qual = knt, stat = alterlist(reply->cat_list,knt)
   WITH check, nocounter, outerjoin = d2
  ;end select
  IF (curqual < 1)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 END ;Subroutine
 SUBROUTINE get_children(lvar)
  SELECT INTO "nl:"
   nc.nomen_category_id
   FROM nomen_cat_list nl1,
    nomen_category nc,
    nomen_cat_list nl2,
    (dummyt d  WITH seq = 1)
   PLAN (nl1
    WHERE (nl1.parent_category_id=request->cat_list[1].cat_id)
     AND nl1.child_category_id > 0)
    JOIN (nc
    WHERE nc.nomen_category_id=nl1.child_category_id)
    JOIN (d
    WHERE d.seq=1)
    JOIN (nl2
    WHERE nl2.parent_category_id=nc.nomen_category_id)
   HEAD REPORT
    knt = 0, stat = alterlist(reply->cat_list,10)
   HEAD nc.nomen_category_id
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->cat_list,(knt+ 9))
    ENDIF
    reply->cat_list[knt].cat_id = nc.nomen_category_id, reply->cat_list[knt].cat_name = nc
    .category_name
   DETAIL
    IF (nl2.child_category_id > 0)
     reply->cat_list[knt].child_cat_ind = true
    ENDIF
   FOOT REPORT
    reply->cat_list_qual = knt, stat = alterlist(reply->cat_list,knt)
   WITH check, nocounter, outerjoin = d
  ;end select
  IF (curqual < 1)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 END ;Subroutine
 SUBROUTINE get_items(lvar)
  SELECT
   IF ((context->cat_list_id > 0))
    PLAN (nl
     WHERE (nl.parent_category_id=context->cat_id)
      AND (nl.nomen_cat_list_id > context->cat_list_id)
      AND nl.nomenclature_id > 0)
     JOIN (n
     WHERE n.nomenclature_id=nl.nomenclature_id
      AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   ELSE
    PLAN (nl
     WHERE (nl.parent_category_id=request->cat_list[1].cat_id)
      AND (nl.nomen_cat_list_id > request->cat_list[1].cat_list_id)
      AND nl.nomenclature_id > 0)
     JOIN (n
     WHERE n.nomenclature_id=nl.nomenclature_id
      AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   ENDIF
   INTO "nl:"
   nl.nomen_cat_list_id
   FROM nomen_cat_list nl,
    nomenclature n
   ORDER BY nl.nomen_cat_list_id
   HEAD REPORT
    knt = 0, stat = alterlist(reply->nomen_list,10)
   DETAIL
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->nomen_list,(knt+ 9))
    ENDIF
    reply->nomen_list[knt].cat_list_id = nl.nomen_cat_list_id, reply->nomen_list[knt].nomen_id = n
    .nomenclature_id, reply->nomen_list[knt].src_strg = n.source_string,
    reply->nomen_list[knt].strg_ident = n.string_identifier, reply->nomen_list[knt].src_ident = n
    .source_identifier, reply->nomen_list[knt].con_ident = n.concept_identifier,
    reply->nomen_list[knt].con_src_cd = n.concept_source_cd, reply->nomen_list[knt].src_vocab_cd = n
    .source_vocabulary_cd, reply->nomen_list[knt].strg_src_cd = n.string_source_cd,
    reply->nomen_list[knt].prin_type_cd = n.principle_type_cd
   FOOT REPORT
    IF (knt >= max_qual)
     reply->more_nomen = true, reply->nomen_list_qual = (knt - 1), stat = alterlist(reply->nomen_list,
      (knt - 1)),
     context->cat_list_id = reply->nomen_list[(knt - 1)].cat_list_id
    ELSE
     reply->more_nomen = false, reply->nomen_list_qual = knt, stat = alterlist(reply->nomen_list,knt),
     context_cat_list_id = 0
    ENDIF
   WITH check, nocounter, maxqual(nl,value(max_qual))
  ;end select
  IF ((reply->status_data.status != "S"))
   IF (curqual > 0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
  ENDIF
 END ;Subroutine
#end_program
END GO

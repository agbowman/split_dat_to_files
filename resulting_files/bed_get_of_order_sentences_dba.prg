CREATE PROGRAM bed_get_of_order_sentences:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 synonym_id = f8
     2 olist[*]
       3 order_sentence_id = f8
       3 order_sentence_display = c255
       3 order_sentence_filter
         4 order_sentence_filter_id = f8
         4 age_min_value = f8
         4 age_max_value = f8
         4 age_unit_cd
           5 code_value = f8
           5 display = vc
           5 mean = vc
           5 description = vc
         4 pma_min_value = f8
         4 pma_max_value = f8
         4 pma_unit_cd
           5 code_value = f8
           5 display = vc
           5 mean = vc
           5 description = vc
         4 weight_min_value = f8
         4 weight_max_value = f8
         4 weight_unit_cd
           5 code_value = f8
           5 display = vc
           5 mean = vc
           5 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET syn_cnt = 0
 SET syn_cnt = size(request->syn_list,5)
 SET stat = alterlist(reply->slist,10)
 SET scnt = 0
 SET alterlist_scnt = 0
 IF (syn_cnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = syn_cnt),
    order_sentence os
   PLAN (d)
    JOIN (os
    WHERE (os.parent_entity_id=request->syn_list[d.seq].synonym_id)
     AND os.parent_entity_name="ORDER_CATALOG_SYNONYM")
   ORDER BY os.parent_entity_id, os.order_sentence_id
   HEAD os.parent_entity_id
    alterlist_scnt = (alterlist_scnt+ 1)
    IF (alterlist_scnt > 10)
     stat = alterlist(reply->slist,(scnt+ 10)), alterlist_scnt = 1
    ENDIF
    scnt = (scnt+ 1), reply->slist[scnt].synonym_id = os.parent_entity_id, stat = alterlist(reply->
     slist[scnt].olist,10),
    ocnt = 0, alterlist_ocnt = 0
   HEAD os.order_sentence_id
    alterlist_ocnt = (alterlist_ocnt+ 1)
    IF (alterlist_ocnt > 10)
     stat = alterlist(reply->slist[scnt].olist,(ocnt+ 10)), alterlist_ocnt = 1
    ENDIF
    ocnt = (ocnt+ 1), reply->slist[scnt].olist[ocnt].order_sentence_id = os.order_sentence_id, reply
    ->slist[scnt].olist[ocnt].order_sentence_display = os.order_sentence_display_line
   FOOT  os.parent_entity_id
    stat = alterlist(reply->slist[scnt].olist,ocnt)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(reply->slist,5))),
   (dummyt d2  WITH seq = 1),
   order_sentence_filter osf,
   code_value cv_age,
   code_value cv_pma,
   code_value cv_weight
  PLAN (d1
   WHERE maxrec(d2,size(reply->slist[d1.seq].olist,5)))
   JOIN (d2)
   JOIN (osf
   WHERE (osf.order_sentence_id=reply->slist[d1.seq].olist[d2.seq].order_sentence_id))
   JOIN (cv_age
   WHERE outerjoin(osf.age_unit_cd)=cv_age.code_value)
   JOIN (cv_pma
   WHERE outerjoin(osf.pma_unit_cd)=cv_pma.code_value)
   JOIN (cv_weight
   WHERE outerjoin(osf.weight_unit_cd)=cv_weight.code_value)
  ORDER BY d1.seq, d2.seq, osf.order_sentence_id
  DETAIL
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.order_sentence_filter_id = osf
   .order_sentence_filter_id, reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.age_min_value
    = osf.age_min_value, reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.age_max_value = osf
   .age_max_value,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.age_unit_cd.code_value = osf.age_unit_cd,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.age_unit_cd.display = cv_age.display,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.age_unit_cd.description = cv_age
   .description,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.age_unit_cd.mean = cv_age.cdf_meaning,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.pma_min_value = osf.pma_min_value, reply
   ->slist[d1.seq].olist[d2.seq].order_sentence_filter.pma_max_value = osf.pma_max_value,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.pma_unit_cd.code_value = osf.pma_unit_cd,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.pma_unit_cd.display = cv_pma.display,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.pma_unit_cd.description = cv_pma
   .description,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.pma_unit_cd.mean = cv_pma.cdf_meaning,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.weight_min_value = osf.weight_min_value,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.weight_max_value = osf.weight_max_value,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.weight_unit_cd.code_value = osf
   .weight_unit_cd, reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.weight_unit_cd.display
    = cv_weight.display, reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.weight_unit_cd.
   description = cv_weight.description,
   reply->slist[d1.seq].olist[d2.seq].order_sentence_filter.weight_unit_cd.mean = cv_weight
   .cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->slist,scnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

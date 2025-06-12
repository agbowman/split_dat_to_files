CREATE PROGRAM bed_get_datamart_orders:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 code_value = f8
     2 description = vc
     2 orderable_type_flag = i2
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 mnemonic_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 oe_format_id = f8
       3 active_ind = i2
     2 cs_synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 mnemonic_type
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 oe_format_id = f8
     2 active_ind = i2
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ocnt = 0
 SET cnt = 0
 DECLARE ord_cd = f8
 SET ord_cd = uar_get_code_by("MEANING",6030,"ORDERABLE")
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 SET cnt = size(request->orders,5)
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    order_catalog o,
    order_catalog_synonym ocs,
    code_value c
   PLAN (d)
    JOIN (o
    WHERE (o.catalog_cd=request->orders[d.seq].code_value))
    JOIN (ocs
    WHERE ocs.catalog_cd=o.catalog_cd
     AND ((ocs.active_ind=1) OR ((request->include_inactive_ind=1))) )
    JOIN (c
    WHERE c.code_value=ocs.mnemonic_type_cd
     AND c.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    scnt = 0, ocnt = (ocnt+ 1), stat = alterlist(reply->orders,ocnt),
    reply->orders[ocnt].code_value = o.catalog_cd, reply->orders[ocnt].description = o.description,
    reply->orders[ocnt].orderable_type_flag = o.orderable_type_flag,
    reply->orders[ocnt].active_ind = o.active_ind
   DETAIL
    scnt = (scnt+ 1), stat = alterlist(reply->orders[ocnt].synonyms,scnt), reply->orders[ocnt].
    synonyms[scnt].id = ocs.synonym_id,
    reply->orders[ocnt].synonyms[scnt].mnemonic = ocs.mnemonic, reply->orders[ocnt].synonyms[scnt].
    mnemonic_type.code_value = ocs.mnemonic_type_cd, reply->orders[ocnt].synonyms[scnt].mnemonic_type
    .display = c.display,
    reply->orders[ocnt].synonyms[scnt].mnemonic_type.mean = c.cdf_meaning, reply->orders[ocnt].
    synonyms[scnt].oe_format_id = ocs.oe_format_id, reply->orders[ocnt].synonyms[scnt].active_ind =
    ocs.active_ind
   WITH nocounter
  ;end select
  IF (ocnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ocnt)),
     cs_component c,
     order_catalog_synonym o,
     code_value cv
    PLAN (d
     WHERE (reply->orders[d.seq].orderable_type_flag IN (2, 6)))
     JOIN (c
     WHERE (c.catalog_cd=reply->orders[d.seq].code_value)
      AND c.comp_type_cd=ord_cd)
     JOIN (o
     WHERE o.synonym_id=c.comp_id
      AND o.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=o.mnemonic_type_cd
      AND cv.active_ind=1)
    ORDER BY d.seq, c.comp_seq
    HEAD d.seq
     ccnt = 0
    DETAIL
     ccnt = (ccnt+ 1), stat = alterlist(reply->orders[d.seq].cs_synonyms,ccnt), reply->orders[d.seq].
     cs_synonyms[ccnt].id = o.synonym_id,
     reply->orders[d.seq].cs_synonyms[ccnt].mnemonic = o.mnemonic, reply->orders[d.seq].cs_synonyms[
     ccnt].mnemonic_type.code_value = o.mnemonic_type_cd, reply->orders[d.seq].cs_synonyms[ccnt].
     mnemonic_type.display = cv.display,
     reply->orders[d.seq].cs_synonyms[ccnt].mnemonic_type.mean = cv.cdf_meaning, reply->orders[d.seq]
     .cs_synonyms[ccnt].oe_format_id = o.oe_format_id
    WITH nocounter
   ;end select
  ENDIF
  GO TO exit_script
 ENDIF
 SET wcard = "*"
 DECLARE oc_parse = vc
 DECLARE ocs_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_string) > " ")
  IF ((request->search_type_string="S"))
   SET search_string = concat(trim(cnvtupper(request->search_string)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_string)),wcard)
  ENDIF
  SET ocs_parse = concat("ocs.mnemonic_key_cap = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET ocs_parse = concat("ocs.mnemonic_key_cap = '",search_string,"'")
 ENDIF
 SET search_string = wcard
 SET oc_parse = concat("cnvtupper(o.description) = '",search_string,"'")
 IF ((request->catalog_type_code_value > 0))
  SET oc_parse = build(oc_parse," and o.catalog_type_cd = ",request->catalog_type_code_value)
 ENDIF
 IF ((request->activity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and o.activity_type_cd = ",request->activity_type_code_value)
 ENDIF
 IF ((request->subactivity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and o.activity_subtype_cd = ",request->subactivity_type_code_value)
 ENDIF
 IF ((request->include_inactive_ind=0))
  SET oc_parse = concat(oc_parse," and o.active_ind+0 = 1")
 ENDIF
 IF ((request->orders_ind=0)
  AND (request->careset_ind=1))
  SET oc_parse = concat(oc_parse," and o.orderable_type_flag in (2,6)")
 ENDIF
 IF ((request->orders_ind=1)
  AND (request->careset_ind=0))
  SET oc_parse = concat(oc_parse," and o.orderable_type_flag not in (2,6)")
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog o,
   order_catalog_synonym ocs
  PLAN (o
   WHERE parser(oc_parse))
   JOIN (ocs
   WHERE ocs.catalog_cd=o.catalog_cd
    AND parser(ocs_parse)
    AND ((ocs.active_ind=1) OR ((request->include_inactive_ind=1))) )
  ORDER BY o.description
  HEAD o.catalog_cd
   scnt = 0, ocnt = (ocnt+ 1), stat = alterlist(reply->orders,ocnt),
   reply->orders[ocnt].code_value = o.catalog_cd, reply->orders[ocnt].description = o.description,
   reply->orders[ocnt].orderable_type_flag = o.orderable_type_flag,
   reply->orders[ocnt].active_ind = o.active_ind
  WITH nocounter
 ;end select
 IF (ocnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ocnt)),
    order_catalog_synonym ocs,
    code_value c
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.catalog_cd=reply->orders[d.seq].code_value)
     AND ((ocs.active_ind=1) OR ((request->include_inactive_ind=1))) )
    JOIN (c
    WHERE c.code_value=ocs.mnemonic_type_cd
     AND c.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    scnt = 0
   DETAIL
    scnt = (scnt+ 1), stat = alterlist(reply->orders[d.seq].synonyms,scnt), reply->orders[d.seq].
    synonyms[scnt].id = ocs.synonym_id,
    reply->orders[d.seq].synonyms[scnt].mnemonic = ocs.mnemonic, reply->orders[d.seq].synonyms[scnt].
    mnemonic_type.code_value = ocs.mnemonic_type_cd, reply->orders[d.seq].synonyms[scnt].
    mnemonic_type.display = c.display,
    reply->orders[d.seq].synonyms[scnt].mnemonic_type.mean = c.cdf_meaning, reply->orders[d.seq].
    synonyms[scnt].oe_format_id = ocs.oe_format_id, reply->orders[d.seq].synonyms[scnt].active_ind =
    ocs.active_ind
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ocnt)),
    cs_component c,
    order_catalog_synonym o,
    code_value cv
   PLAN (d
    WHERE (reply->orders[d.seq].orderable_type_flag IN (2, 6)))
    JOIN (c
    WHERE (c.catalog_cd=reply->orders[d.seq].code_value)
     AND c.comp_type_cd=ord_cd)
    JOIN (o
    WHERE o.synonym_id=c.comp_id
     AND o.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=o.mnemonic_type_cd
     AND cv.active_ind=1)
   ORDER BY d.seq, c.comp_seq
   HEAD d.seq
    ccnt = 0
   DETAIL
    ccnt = (ccnt+ 1), stat = alterlist(reply->orders[d.seq].cs_synonyms,ccnt), reply->orders[d.seq].
    cs_synonyms[ccnt].id = o.synonym_id,
    reply->orders[d.seq].cs_synonyms[ccnt].mnemonic = o.mnemonic, reply->orders[d.seq].cs_synonyms[
    ccnt].mnemonic_type.code_value = o.mnemonic_type_cd, reply->orders[d.seq].cs_synonyms[ccnt].
    mnemonic_type.display = cv.display,
    reply->orders[d.seq].cs_synonyms[ccnt].mnemonic_type.mean = cv.cdf_meaning, reply->orders[d.seq].
    cs_synonyms[ccnt].oe_format_id = o.oe_format_id
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (ocnt > max_cnt)
  SET stat = alterlist(reply->orders,max_cnt)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

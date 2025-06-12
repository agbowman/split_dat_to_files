CREATE PROGRAM bed_get_datamart_plans:dba
 FREE SET reply
 RECORD reply(
   1 plans[*]
     2 id = f8
     2 description = vc
     2 plan_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 pw_cat_synonym_id = f8
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
 SET pcnt = 0
 SET cnt = 0
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 SET cnt = size(request->plans,5)
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    pathway_catalog p
   PLAN (d)
    JOIN (p
    WHERE (p.pathway_catalog_id=request->plans[d.seq].id))
   ORDER BY p.description_key
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->plans,pcnt), reply->plans[pcnt].id = p
    .pathway_catalog_id,
    reply->plans[pcnt].description = p.description
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SET return_synonyms_ind = 0
 IF (validate(request->return_synonyms_ind))
  SET return_synonyms_ind = request->return_synonyms_ind
 ENDIF
 SET wcard = "*"
 DECLARE pathway_parse = vc
 DECLARE search_string = vc
 IF (return_synonyms_ind=0)
  IF (trim(request->search_string) > " ")
   IF ((request->search_type_string="S"))
    SET search_string = concat(trim(cnvtupper(request->search_string)),wcard)
   ELSE
    SET search_string = concat(wcard,trim(cnvtupper(request->search_string)),wcard)
   ENDIF
   SET pathway_parse = concat("p.description_key = '",search_string,"'")
  ELSE
   SET search_string = wcard
   SET pathway_parse = concat("p.description_key = '",search_string,"'")
  ENDIF
  IF ((request->type_code_value > 0))
   SET pathway_parse = build(pathway_parse," and p.pathway_type_cd+0 = ",request->type_code_value)
  ENDIF
  IF ((request->include_inactive_ind=0))
   SET pathway_parse = concat(pathway_parse," and p.active_ind+0 = 1")
  ENDIF
  SELECT INTO "nl:"
   FROM pathway_catalog p,
    code_value cv
   PLAN (p
    WHERE parser(pathway_parse)
     AND trim(p.type_mean) != "PHASE")
    JOIN (cv
    WHERE cv.code_value=p.pathway_type_cd
     AND cv.active_ind=1)
   ORDER BY p.description_key
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->plans,pcnt), reply->plans[pcnt].id = p
    .pathway_catalog_id,
    reply->plans[pcnt].description = p.description, reply->plans[pcnt].plan_type.code_value = p
    .pathway_type_cd, reply->plans[pcnt].plan_type.display = cv.display,
    reply->plans[pcnt].plan_type.mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ELSE
  DECLARE pcs_parse = vc
  IF (trim(request->search_string) > " ")
   IF ((request->search_type_string="S"))
    SET search_string = concat(trim(cnvtupper(request->search_string)),wcard)
   ELSE
    SET search_string = concat(wcard,trim(cnvtupper(request->search_string)),wcard)
   ENDIF
   SET pcs_parse = concat("pcs.synonym_name_key = '",search_string,"'")
  ELSE
   SET search_string = wcard
   SET pcs_parse = concat("pcs.synonym_name_key = '",search_string,"'")
  ENDIF
  SET pathway_parse = 'trim(p.type_mean) != "PHASE"'
  IF ((request->type_code_value > 0))
   SET pathway_parse = build(pathway_parse," and p.pathway_type_cd+0 = ",request->type_code_value)
  ENDIF
  IF ((request->include_inactive_ind=0))
   SET pathway_parse = concat(pathway_parse," and p.active_ind+0 = 1")
  ENDIF
  SELECT INTO "nl:"
   FROM pathway_catalog p,
    code_value cv,
    pw_cat_synonym pcs
   PLAN (p
    WHERE parser(pathway_parse))
    JOIN (cv
    WHERE cv.code_value=p.pathway_type_cd
     AND cv.active_ind=1)
    JOIN (pcs
    WHERE parser(pcs_parse)
     AND pcs.pathway_catalog_id=p.pathway_catalog_id)
   ORDER BY pcs.synonym_name_key
   DETAIL
    pcnt = (pcnt+ 1), stat = alterlist(reply->plans,pcnt), reply->plans[pcnt].id = p
    .pathway_catalog_id,
    reply->plans[pcnt].description = pcs.synonym_name, reply->plans[pcnt].plan_type.code_value = p
    .pathway_type_cd, reply->plans[pcnt].plan_type.display = cv.display,
    reply->plans[pcnt].plan_type.mean = cv.cdf_meaning, reply->plans[pcnt].pw_cat_synonym_id = pcs
    .pw_cat_synonym_id
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (pcnt > max_cnt)
  SET stat = alterlist(reply->plans,max_cnt)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

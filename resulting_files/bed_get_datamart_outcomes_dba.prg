CREATE PROGRAM bed_get_datamart_outcomes:dba
 FREE SET reply
 RECORD reply(
   1 plans[*]
     2 plan_id = f8
     2 description = vc
     2 outcomes[*]
       3 outcome_id = f8
       3 description = vc
       3 dta_concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = 0
 SET req_cnt = size(request->plans,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->plans,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->plans[x].plan_id = request->plans[x].plan_id
 ENDFOR
 SET outcome_code = 0.0
 SET outcome_code = uar_get_code_by("MEANING",16750,"RESULT OUTCO")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   pathway_catalog p,
   pathway_comp c,
   outcome_catalog o,
   discrete_task_assay dta,
   code_value cv
  PLAN (d)
   JOIN (p
   WHERE (p.pathway_catalog_id=request->plans[d.seq].plan_id))
   JOIN (c
   WHERE c.pathway_catalog_id=p.pathway_catalog_id
    AND c.comp_type_cd=outcome_code
    AND c.active_ind=1
    AND c.parent_entity_name="OUTCOME_CATALOG")
   JOIN (o
   WHERE o.outcome_catalog_id=c.parent_entity_id
    AND o.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=o.task_assay_cd
    AND dta.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dta.task_assay_cd
    AND cv.active_ind=1)
  ORDER BY d.seq, c.sequence, o.outcome_catalog_id
  HEAD d.seq
   ocnt = 0, otcnt = 0, stat = alterlist(reply->plans[d.seq].outcomes,10),
   reply->plans[d.seq].description = p.description
  HEAD o.outcome_catalog_id
   ocnt = (ocnt+ 1), otcnt = (otcnt+ 1)
   IF (ocnt > 10)
    stat = alterlist(reply->plans[d.seq].outcomes,(otcnt+ 10)), ocnt = 1
   ENDIF
   reply->plans[d.seq].outcomes[otcnt].outcome_id = o.outcome_catalog_id, reply->plans[d.seq].
   outcomes[otcnt].description = o.description, reply->plans[d.seq].outcomes[otcnt].dta_concept_cki
    = cv.concept_cki
  FOOT  d.seq
   stat = alterlist(reply->plans[d.seq].outcomes,otcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

CREATE PROGRAM dcp_get_plan_cat_info:dba
 SET modify = predeclare
 RECORD reply(
   1 plan_list[*]
     2 pw_cat_synonym_id = f8
     2 pathway_catalog_id = f8
     2 pathway_type_cd = f8
     2 primary_ind = i2
     2 pw_evidence_reltn_id = f8
     2 evidence_locator = vc
     2 ref_text_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD catalogs(
   1 size = i4
   1 new_size = i4
   1 loop_count = i4
   1 batch_size = i4
   1 qual[*]
     2 pathway_catalog_id = f8
 )
 DECLARE plan_cat_synonym_total = i4 WITH protect, constant(size(request->plan_cat_synonym_id_list,5)
  )
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE plancnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 SET reply->status_data.status = "F"
 IF (plan_cat_synonym_total > 0)
  SELECT INTO "nl:"
   FROM pw_cat_synonym pcs,
    pathway_catalog pwc,
    pw_evidence_reltn per
   PLAN (pcs
    WHERE expand(idx,1,plan_cat_synonym_total,pcs.pw_cat_synonym_id,request->
     plan_cat_synonym_id_list[idx].pw_cat_synonym_id))
    JOIN (pwc
    WHERE pwc.pathway_catalog_id=pcs.pathway_catalog_id)
    JOIN (per
    WHERE per.pathway_catalog_id=outerjoin(pcs.pathway_catalog_id))
   ORDER BY pcs.pw_cat_synonym_id
   HEAD REPORT
    plancnt = 0
   HEAD pcs.pw_cat_synonym_id
    plancnt = (plancnt+ 1)
    IF (plancnt > size(reply->plan_list,5))
     stat = alterlist(reply->plan_list,(plancnt+ 10))
    ENDIF
    IF (plancnt > size(catalogs->qual,5))
     stat = alterlist(catalogs->qual,(plancnt+ 10))
    ENDIF
    reply->plan_list[plancnt].pw_cat_synonym_id = pcs.pw_cat_synonym_id, reply->plan_list[plancnt].
    pathway_catalog_id = pcs.pathway_catalog_id, reply->plan_list[plancnt].pathway_type_cd = pwc
    .pathway_type_cd,
    reply->plan_list[plancnt].primary_ind = pcs.primary_ind, catalogs->qual[plancnt].
    pathway_catalog_id = pcs.pathway_catalog_id
   DETAIL
    IF (per.dcp_clin_cat_cd=0
     AND per.dcp_clin_sub_cat_cd=0
     AND per.pathway_comp_id=0)
     IF (per.type_mean="REFTEXT")
      reply->plan_list[plancnt].pw_evidence_reltn_id = per.pw_evidence_reltn_id
     ENDIF
     IF (((per.type_mean="ZYNX") OR (per.type_mean="URL")) )
      reply->plan_list[plancnt].evidence_locator = per.evidence_locator
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->plan_list,plancnt), stat = alterlist(catalogs->qual,plancnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (size(catalogs->qual,5) > 0)
  DECLARE num = i4 WITH noconstant(1)
  DECLARE lstart = i4 WITH protect, noconstant(0)
  DECLARE plantotal = i4 WITH protect, noconstant(0)
  SET num = 0
  SET lstart = 1
  SET plantotal = value(size(reply->plan_list,5))
  SET catalogs->batch_size = 20
  SET catalogs->size = plantotal
  SET catalogs->loop_count = ceil((cnvtreal(plantotal)/ catalogs->batch_size))
  SET catalogs->new_size = (catalogs->loop_count * catalogs->batch_size)
  SET stat = alterlist(catalogs->qual,catalogs->new_size)
  FOR (indx = (catalogs->size+ 1) TO catalogs->new_size)
    SET catalogs->qual[indx].pathway_catalog_id = catalogs->qual[plantotal].pathway_catalog_id
  ENDFOR
  SELECT INTO "nl:"
   rtr.parent_entity_name, rtr.parent_entity_id
   FROM (dummyt d1  WITH seq = value(catalogs->loop_count)),
    ref_text_reltn rtr
   PLAN (d1
    WHERE initarray(lstart,evaluate(d1.seq,1,1,(lstart+ catalogs->batch_size))))
    JOIN (rtr
    WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
     AND expand(num,lstart,(lstart+ (catalogs->batch_size - 1)),rtr.parent_entity_id,catalogs->qual[
     num].pathway_catalog_id)
     AND rtr.active_ind=1)
   ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
   HEAD rtr.parent_entity_id
    FOR (indx = 1 TO plantotal)
      IF ((reply->plan_list[indx].pathway_catalog_id=rtr.parent_entity_id))
       reply->plan_list[indx].ref_text_ind = 1
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 SET last_mod = "001"
 IF (size(reply->plan_list,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO

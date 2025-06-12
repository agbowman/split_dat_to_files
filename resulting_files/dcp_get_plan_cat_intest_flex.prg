CREATE PROGRAM dcp_get_plan_cat_intest_flex
 SET modify = predeclare
 RECORD reply(
   1 plan_list[*]
     2 pathway_catalog_id = f8
     2 display_description = vc
     2 pw_evidence_reltn_id = f8
     2 evidence_locator = vc
     2 ref_text_ind = i2
     2 pw_cat_synonym_id = f8
     2 primary_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nindex = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE end_dt_tm_str = vc WITH constant("31-DEC-2100"), protect
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  display_description = cnvtupper(pwc.display_description), pwc.type_mean, pwc.version,
  per.type_mean, per.evidence_locator, rtr.parent_entity_id,
  rtr.parent_entity_name, rtr.active_ind, rtr.ref_text_reltn_id
  FROM pw_cat_flex pcf,
   pathway_catalog pwc,
   pw_evidence_reltn per,
   ref_text_reltn rtr
  PLAN (pcf
   WHERE pcf.parent_entity_id IN (request->facility_cd, 0)
    AND pcf.parent_entity_name="CODE_VALUE")
   JOIN (pwc
   WHERE pwc.pathway_catalog_id=pcf.pathway_catalog_id
    AND pwc.active_ind=1
    AND pwc.beg_effective_dt_tm=cnvtdatetime(end_dt_tm_str)
    AND pwc.end_effective_dt_tm=cnvtdatetime(end_dt_tm_str))
   JOIN (per
   WHERE per.pathway_catalog_id=outerjoin(pwc.pathway_catalog_id))
   JOIN (rtr
   WHERE rtr.parent_entity_id=outerjoin(pwc.pathway_catalog_id)
    AND rtr.parent_entity_name=outerjoin("PATHWAY_CATALOG")
    AND rtr.active_ind=outerjoin(1))
  ORDER BY display_description
  HEAD REPORT
   nindex = 0, stat = alterlist(reply->plan_list,20)
  HEAD display_description
   nindex = (nindex+ 1)
   IF (nindex > size(reply->plan_list,5))
    stat = alterlist(reply->plan_list,(nindex+ 20))
   ENDIF
   reply->plan_list[nindex].pathway_catalog_id = pcf.pathway_catalog_id, reply->plan_list[nindex].
   display_description = trim(pwc.display_description)
   IF (rtr.ref_text_reltn_id > 0)
    reply->plan_list[nindex].ref_text_ind = 1
   ENDIF
  DETAIL
   IF (per.dcp_clin_cat_cd=0
    AND per.dcp_clin_sub_cat_cd=0
    AND per.pathway_comp_id=0)
    IF (per.type_mean="REFTEXT")
     reply->plan_list[nindex].pw_evidence_reltn_id = per.pw_evidence_reltn_id
    ELSEIF (((per.type_mean="ZYNX") OR (per.type_mean="URL")) )
     reply->plan_list[nindex].evidence_locator = per.evidence_locator
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->plan_list,nindex)
  WITH nocounter
 ;end select
 IF (size(reply->plan_list,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO

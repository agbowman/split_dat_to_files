CREATE PROGRAM dcp_get_suggested_plan_header
 SET modify = predeclare
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE inactiveplanind = i2 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE debug = i2 WITH constant(validate(request->debug,0))
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE l_start = i4 WITH protect, noconstant(0)
 DECLARE l_size = i4 WITH protect, noconstant(0)
 DECLARE l_batch_size = i4 WITH protect, noconstant(20)
 DECLARE l_loop_count = i4 WITH protect, noconstant(0)
 DECLARE l_new_size = i4 WITH protect, noconstant(0)
 IF (debug=1)
  CALL echorecord(request)
 ENDIF
 SELECT INTO "nl:"
  pwc.pathway_catalog_id, pwc2.pathway_catalog_id, pwc.version,
  pwc2.version
  FROM pathway_catalog pwc,
   pathway_catalog pwc2,
   (dummyt d  WITH seq = value(size(request->planlist,5)))
  PLAN (d)
   JOIN (pwc
   WHERE (pwc.pathway_catalog_id=request->planlist[d.seq].pathway_catalog_id))
   JOIN (pwc2
   WHERE pwc2.version_pw_cat_id=pwc.version_pw_cat_id
    AND pwc2.active_ind=1
    AND pwc2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pwc2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   idx = 0
  DETAIL
   idx = (idx+ 1)
   IF (idx > size(reply->planlist,5))
    stat = alterlist(reply->planlist,(idx+ 10))
   ENDIF
   reply->planlist[idx].in_pathway_catalog_id = request->planlist[d.seq].pathway_catalog_id, reply->
   planlist[idx].version_pw_cat_id = pwc2.version_pw_cat_id, reply->planlist[idx].pathway_catalog_id
    = pwc2.pathway_catalog_id,
   reply->planlist[idx].display_description = trim(pwc2.display_description), reply->planlist[idx].
   pathway_type_cd = pwc2.pathway_type_cd, reply->planlist[idx].active_ind = pwc2.active_ind
  FOOT REPORT
   stat = alterlist(reply->planlist,idx)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pw_cat_flex pcf,
   (dummyt d  WITH seq = value(size(reply->planlist,5)))
  PLAN (d)
   JOIN (pcf
   WHERE pcf.parent_entity_id IN (request->facility_cd, 0)
    AND pcf.parent_entity_name="CODE_VALUE"
    AND (pcf.pathway_catalog_id=reply->planlist[d.seq].pathway_catalog_id))
  DETAIL
   IF (pcf.pathway_catalog_id > 0)
    reply->planlist[d.seq].facility_access_ind = 1
   ELSE
    reply->planlist[d.seq].facility_access_ind = 0
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  per.pathway_catalog_id, per.type_mean
  FROM pw_evidence_reltn per,
   (dummyt d  WITH seq = value(size(reply->planlist,5)))
  PLAN (d)
   JOIN (per
   WHERE (per.pathway_catalog_id=reply->planlist[d.seq].pathway_catalog_id))
  HEAD REPORT
   evidencecnt = 0
  DETAIL
   IF (per.pathway_catalog_id > 0
    AND per.dcp_clin_cat_cd=0
    AND per.dcp_clin_sub_cat_cd=0
    AND per.pathway_comp_id=0)
    IF (per.type_mean="REFTEXT")
     reply->planlist[d.seq].pw_evidence_reltn_id = per.pw_evidence_reltn_id, reply->planlist[d.seq].
     ref_text_ind = 1
    ELSEIF (per.type_mean IN ("URL", "ZYNX"))
     reply->planlist[d.seq].evidence_locator = per.evidence_locator, reply->planlist[d.seq].
     evidence_type_mean = per.type_mean
    ENDIF
   ENDIF
  FOOT REPORT
   evidencecnt = 0
  WITH nocounter
 ;end select
 SET l_size = size(reply->planlist,5)
 SET l_loop_count = ceil((cnvtreal(l_size)/ l_batch_size))
 SET l_new_size = (l_loop_count * l_batch_size)
 SET stat = alterlist(reply->planlist,l_new_size)
 FOR (idx = (l_size+ 1) TO l_new_size)
   SET reply->planlist[idx].pathway_catalog_id = reply->planlist[l_size].pathway_catalog_id
 ENDFOR
 SET l_start = 1
 SELECT INTO "nl:"
  rtr.parent_entity_name, rtr.parent_entity_id
  FROM (dummyt d1  WITH seq = value(l_loop_count)),
   ref_text_reltn rtr
  PLAN (d1
   WHERE initarray(l_start,evaluate(d1.seq,1,1,(l_start+ l_batch_size))))
   JOIN (rtr
   WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
    AND expand(idx,l_start,(l_start+ (l_batch_size - 1)),rtr.parent_entity_id,reply->planlist[idx].
    pathway_catalog_id)
    AND rtr.active_ind=1)
  ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
  HEAD rtr.parent_entity_id
   IF (rtr.parent_entity_id > 0.0)
    idx = locateval(idx,1,l_size,rtr.parent_entity_id,reply->planlist[idx].pathway_catalog_id)
    WHILE (idx > 0)
      reply->planlist[idx].ref_text_ind = 1, idx2 = (idx+ 1), idx = locateval(idx,idx2,l_size,rtr
       .parent_entity_id,reply->planlist[idx].pathway_catalog_id)
    ENDWHILE
   ENDIF
  WITH nocounter
 ;end select
 IF (l_size > 0
  AND l_size < l_new_size)
  SET stat = alterlist(reply->planlist,l_size)
 ENDIF
#exit_script
 FREE RECORD pathway
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debug=1)
  CALL echorecord(reply)
 ENDIF
END GO

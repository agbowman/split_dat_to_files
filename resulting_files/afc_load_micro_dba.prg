CREATE PROGRAM afc_load_micro:dba
 FREE SET request
 RECORD request(
   1 nbr_of_recs = i4
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 ext_owner_cd = f8
     2 ext_description = vc
     2 ext_short_desc = c50
     2 careset_ind = i2
     2 workload_only_ind = i2
     2 price_qual = i2
     2 billcode_qual = i2
     2 child_qual = i2
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = vc
       3 ext_short_desc = c50
       3 ext_owner_cd = f8
       3 ext_sub_owner_cd = f8
     2 ext_sub_owner_cd = f8
 )
 IF (validate(reqinfo->commit_ind,9)=9)
  FREE SET reqinfo
  RECORD reqinfo(
    1 commit_ind = i2
    1 updt_id = f8
    1 position_cd = f8
    1 updt_app = i4
    1 updt_task = i4
    1 updt_req = i4
    1 updt_applctx = i4
  )
  SET reqinfo->updt_id = 1111
  SET reqinfo->updt_applctx = 12
  SET reqinfo->updt_task = 999999
 ENDIF
 DECLARE code_value = f8
 DECLARE g_dmicroactivitytypecd = f8
 DECLARE g_dordercatalogcontributorcd = f8
 DECLARE g_dtaskassaycontributorcd = f8
 DECLARE g_dtaskcontributorcd = f8
 DECLARE g_dcodevaluecontributorcd = f8
 DECLARE g_dmnemonictypecd = f8
 DECLARE g_nparentcnt = i4
 DECLARE g_nchildcnt = i4
 DECLARE g_ngrpbioflag = i2
 DECLARE g_nprocedureflag = i2
 DECLARE g_npanelflag = i2
 SET parent_ndx = 0
 SET child_ndx = 0
 SET g_ngrpbioflag = 1
 SET g_nprocedureflag = 2
 SET g_npanelflag = 3
 SET code_value = 0.0
 SET code_set = 106
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "MICROBIOLOGY"
 EXECUTE cpm_get_cd_for_cdf
 SET g_dmicroactivitytypecd = code_value
 SET code_value = 0.0
 SET code_set = 13016
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "ORD CAT"
 EXECUTE cpm_get_cd_for_cdf
 SET g_dordercatalogcontributorcd = code_value
 SET code_value = 0.0
 SET code_set = 13016
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "TASK ASSAY"
 EXECUTE cpm_get_cd_for_cdf
 SET g_dtaskassaycontributorcd = code_value
 SET code_value = 0.0
 SET code_set = 13016
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "MIC TASK"
 EXECUTE cpm_get_cd_for_cdf
 SET g_dtaskcontributorcd = code_value
 SET code_value = 0.0
 SET code_set = 13016
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "CODEVALUE"
 EXECUTE cpm_get_cd_for_cdf
 SET g_dcodevaluecontributorcd = code_value
 SET code_value = 0.0
 SET code_set = 6011
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "PRIMARY"
 EXECUTE cpm_get_cd_for_cdf
 SET g_dmnemonictypecd = code_value
 UPDATE  FROM bill_item
  SET ext_child_contributor_cd = g_dtaskassaycontributorcd
  WHERE ext_owner_cd=g_dmicroactivitytypecd
   AND ext_parent_contributor_cd=g_dordercatalogcontributorcd
   AND ext_child_contributor_cd=g_dordercatalogcontributorcd
  WITH nocounter
 ;end update
 COMMIT
 SELECT INTO "nl:"
  oc.catalog_cd, s.catalog_cd
  FROM order_catalog oc,
   order_catalog_synonym s
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.activity_type_cd=g_dmicroactivitytypecd)
   JOIN (s
   WHERE s.catalog_cd=oc.catalog_cd
    AND s.mnemonic_type_cd=g_dmnemonictypecd
    AND s.active_ind=1)
  ORDER BY oc.catalog_cd
  DETAIL
   parent_ndx += 1, stat = alterlist(request->qual,parent_ndx), request->qual[parent_ndx].action = 1,
   request->qual[parent_ndx].ext_id = oc.catalog_cd, request->qual[parent_ndx].ext_contributor_cd =
   g_dordercatalogcontributorcd, request->qual[parent_ndx].parent_qual_ind = 1,
   request->qual[parent_ndx].ext_owner_cd = g_dmicroactivitytypecd, stat = assign(validate(request->
     qual[parent_ndx].ext_sub_owner_cd),oc.activity_subtype_cd), request->qual[parent_ndx].
   ext_description = trim(oc.description),
   request->qual[parent_ndx].ext_short_desc = trim(oc.primary_mnemonic), request->qual[parent_ndx].
   child_qual = 0, request->qual[parent_ndx].careset_ind = 0,
   request->qual[parent_ndx].workload_only_ind = 0, request->qual[parent_ndx].price_qual = 0, request
   ->qual[parent_ndx].billcode_qual = g_nprocedureflag
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ptr.catalog_cd
  FROM (dummyt d  WITH seq = value(parent_ndx)),
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (d
   WHERE (request->qual[d.seq].billcode_qual=g_nprocedureflag))
   JOIN (ptr
   WHERE (ptr.catalog_cd=request->qual[d.seq].ext_id)
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE ptr.task_assay_cd=dta.task_assay_cd)
  HEAD ptr.catalog_cd
   child_ndx = 0
  DETAIL
   child_ndx += 1, stat = alterlist(request->qual[d.seq].children,child_ndx), request->qual[d.seq].
   children[child_ndx].ext_id = ptr.task_assay_cd,
   request->qual[d.seq].children[child_ndx].ext_contributor_cd = g_dtaskassaycontributorcd, request->
   qual[d.seq].children[child_ndx].ext_description = dta.description, request->qual[d.seq].children[
   child_ndx].ext_short_desc = dta.mnemonic,
   request->qual[d.seq].children[child_ndx].ext_owner_cd = g_dmicroactivitytypecd
   IF (validate(request->qual[d.seq].ext_sub_owner_cd,0))
    stat = assign(validate(request->qual[d.seq].children[child_ndx].ext_sub_owner_cd),request->qual[d
     .seq].ext_sub_owner_cd)
   ENDIF
   request->qual[d.seq].child_qual = child_ndx
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c,
   mic_task m
  PLAN (m
   WHERE m.task_type_flag=3)
   JOIN (c
   WHERE m.task_assay_cd=c.code_value
    AND c.active_ind=1)
  DETAIL
   IF (c.cdf_meaning != "ESIDEFAULT")
    parent_ndx += 1, stat = alterlist(request->qual,parent_ndx), request->qual[parent_ndx].action = 1,
    request->qual[parent_ndx].ext_id = c.code_value, request->qual[parent_ndx].ext_contributor_cd =
    g_dtaskcontributorcd, request->qual[parent_ndx].parent_qual_ind = 1,
    request->qual[parent_ndx].ext_owner_cd = g_dmicroactivitytypecd, request->qual[parent_ndx].
    ext_description = c.description, request->qual[parent_ndx].ext_short_desc = c.display,
    request->qual[parent_ndx].careset_ind = 0, request->qual[parent_ndx].workload_only_ind = 0,
    request->qual[parent_ndx].price_qual = 0,
    request->qual[parent_ndx].billcode_qual = g_ngrpbioflag
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  r.task_assay_cd
  FROM (dummyt d  WITH seq = value(parent_ndx)),
   mic_task_detail_r r,
   mic_detail_task t,
   code_value c
  PLAN (d
   WHERE (request->qual[d.seq].billcode_qual=g_ngrpbioflag))
   JOIN (r
   WHERE (request->qual[d.seq].ext_id=r.task_assay_cd))
   JOIN (t
   WHERE r.task_component_cd=t.task_component_cd)
   JOIN (c
   WHERE c.code_value=t.task_component_cd)
  HEAD d.seq
   child_ndx = 0
  DETAIL
   child_ndx += 1, stat = alterlist(request->qual[d.seq].children,child_ndx), request->qual[d.seq].
   children[child_ndx].ext_id = c.code_value,
   request->qual[d.seq].children[child_ndx].ext_contributor_cd = g_dcodevaluecontributorcd, request->
   qual[d.seq].children[child_ndx].ext_description = c.description, request->qual[d.seq].children[
   child_ndx].ext_short_desc = c.display,
   request->qual[d.seq].children[child_ndx].ext_owner_cd = g_dmicroactivitytypecd, request->qual[d
   .seq].child_qual = child_ndx
  WITH nocounter
 ;end select
 SET child_ndx = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c,
   mic_detail_task m
  PLAN (m
   WHERE m.task_type_flag=4)
   JOIN (c
   WHERE m.task_component_cd=c.code_value
    AND c.active_ind=1)
  DETAIL
   IF (c.cdf_meaning != "ESIDEFAULT")
    parent_ndx += 1, stat = alterlist(request->qual,parent_ndx), request->qual[parent_ndx].action = 1,
    request->qual[parent_ndx].ext_id = c.code_value, request->qual[parent_ndx].ext_contributor_cd =
    g_dcodevaluecontributorcd, request->qual[parent_ndx].parent_qual_ind = 1,
    request->qual[parent_ndx].ext_owner_cd = g_dmicroactivitytypecd, request->qual[parent_ndx].
    ext_description = c.description, request->qual[parent_ndx].ext_short_desc = c.display,
    request->qual[parent_ndx].careset_ind = 0, request->qual[parent_ndx].workload_only_ind = 0,
    request->qual[parent_ndx].price_qual = 0,
    request->qual[parent_ndx].billcode_qual = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c,
   mic_task m
  PLAN (m
   WHERE ((m.task_type_flag=1) OR (((m.task_type_flag=8) OR (((m.task_type_flag=9) OR (m
   .task_type_flag=10)) )) )) )
   JOIN (c
   WHERE m.task_assay_cd=c.code_value
    AND c.active_ind=1)
  DETAIL
   IF (c.cdf_meaning != "ESIDEFAULT")
    parent_ndx += 1, stat = alterlist(request->qual,parent_ndx), request->qual[parent_ndx].action = 1,
    request->qual[parent_ndx].ext_id = c.code_value, request->qual[parent_ndx].ext_contributor_cd =
    g_dtaskcontributorcd, request->qual[parent_ndx].parent_qual_ind = 1,
    request->qual[parent_ndx].ext_owner_cd = g_dmicroactivitytypecd, request->qual[parent_ndx].
    ext_description = c.description, request->qual[parent_ndx].ext_short_desc = c.display,
    request->qual[parent_ndx].child_qual = 0, request->qual[parent_ndx].careset_ind = 0, request->
    qual[parent_ndx].workload_only_ind = 0,
    request->qual[parent_ndx].price_qual = 0, request->qual[parent_ndx].billcode_qual = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  m.task_assay_cd
  FROM mic_task m,
   mic_task_detail_r r,
   code_value cv
  PLAN (m
   WHERE m.task_type_flag=11)
   JOIN (r
   WHERE m.task_assay_cd=r.task_assay_cd)
   JOIN (cv
   WHERE r.task_component_cd=cv.code_value
    AND cv.active_ind=1)
  DETAIL
   parent_ndx += 1, stat = alterlist(request->qual,parent_ndx), request->qual[parent_ndx].action = 1,
   request->qual[parent_ndx].ext_id = m.task_assay_cd, request->qual[parent_ndx].ext_contributor_cd
    = g_dtaskcontributorcd, request->qual[parent_ndx].parent_qual_ind = 1,
   request->qual[parent_ndx].ext_owner_cd = g_dmicroactivitytypecd, request->qual[parent_ndx].
   ext_description = cv.description, request->qual[parent_ndx].ext_short_desc = cv.display,
   request->qual[parent_ndx].child_qual = 0, request->qual[parent_ndx].careset_ind = 0, request->
   qual[parent_ndx].workload_only_ind = 0,
   request->qual[parent_ndx].price_qual = 0, request->qual[parent_ndx].billcode_qual = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c,
   mic_task m
  PLAN (m
   WHERE m.task_type_flag=5)
   JOIN (c
   WHERE m.task_assay_cd=c.code_value
    AND c.active_ind=1)
  DETAIL
   IF (c.cdf_meaning != "ESIDEFAULT")
    parent_ndx += 1, stat = alterlist(request->qual,parent_ndx), request->qual[parent_ndx].action = 1,
    request->qual[parent_ndx].ext_id = c.code_value, request->qual[parent_ndx].ext_contributor_cd =
    g_dtaskcontributorcd, request->qual[parent_ndx].parent_qual_ind = 1,
    request->qual[parent_ndx].ext_owner_cd = g_dmicroactivitytypecd, request->qual[parent_ndx].
    ext_description = c.description, request->qual[parent_ndx].ext_short_desc = c.display,
    request->qual[parent_ndx].child_qual = 0, request->qual[parent_ndx].careset_ind = 0, request->
    qual[parent_ndx].workload_only_ind = 0,
    request->qual[parent_ndx].price_qual = 0, request->qual[parent_ndx].billcode_qual = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c,
   mic_task m
  PLAN (m
   WHERE m.task_type_flag=12)
   JOIN (c
   WHERE m.task_assay_cd=c.code_value
    AND c.active_ind=1)
  DETAIL
   IF (c.cdf_meaning != "ESIDEFAULT")
    parent_ndx += 1, stat = alterlist(request->qual,parent_ndx), request->qual[parent_ndx].action = 1,
    request->qual[parent_ndx].ext_id = c.code_value, request->qual[parent_ndx].ext_contributor_cd =
    g_dtaskcontributorcd, request->qual[parent_ndx].parent_qual_ind = 1,
    request->qual[parent_ndx].ext_owner_cd = g_dmicroactivitytypecd, request->qual[parent_ndx].
    ext_description = c.description, request->qual[parent_ndx].ext_short_desc = c.display,
    request->qual[parent_ndx].careset_ind = 0, request->qual[parent_ndx].workload_only_ind = 0,
    request->qual[parent_ndx].price_qual = 0,
    request->qual[parent_ndx].billcode_qual = g_npanelflag
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  r.task_assay_cd
  FROM (dummyt d  WITH seq = value(parent_ndx)),
   mic_task_detail_r r,
   mic_detail_task t,
   code_value c
  PLAN (d
   WHERE (request->qual[d.seq].billcode_qual=g_npanelflag))
   JOIN (r
   WHERE (request->qual[d.seq].ext_id=r.task_assay_cd))
   JOIN (t
   WHERE r.task_component_cd=t.task_component_cd)
   JOIN (c
   WHERE c.code_value=t.task_component_cd)
  HEAD d.seq
   child_ndx = 0
  DETAIL
   child_ndx += 1, stat = alterlist(request->qual[d.seq].children,child_ndx), request->qual[d.seq].
   children[child_ndx].ext_id = c.code_value,
   request->qual[d.seq].children[child_ndx].ext_contributor_cd = g_dcodevaluecontributorcd, request->
   qual[d.seq].children[child_ndx].ext_description = c.description, request->qual[d.seq].children[
   child_ndx].ext_short_desc = c.display,
   request->qual[d.seq].children[child_ndx].ext_owner_cd = g_dmicroactivitytypecd, request->qual[d
   .seq].child_qual = child_ndx
  WITH nocounter
 ;end select
 SET child_ndx = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c,
   mic_detail_task m
  PLAN (m
   WHERE m.task_type_flag=13)
   JOIN (c
   WHERE m.task_component_cd=c.code_value
    AND c.active_ind=1)
  DETAIL
   IF (c.cdf_meaning != "ESIDEFAULT")
    parent_ndx += 1, stat = alterlist(request->qual,parent_ndx), request->qual[parent_ndx].action = 1,
    request->qual[parent_ndx].ext_id = c.code_value, request->qual[parent_ndx].ext_contributor_cd =
    g_dcodevaluecontributorcd, request->qual[parent_ndx].parent_qual_ind = 1,
    request->qual[parent_ndx].ext_owner_cd = g_dmicroactivitytypecd, request->qual[parent_ndx].
    ext_description = c.description, request->qual[parent_ndx].ext_short_desc = c.display,
    request->qual[parent_ndx].careset_ind = 0, request->qual[parent_ndx].workload_only_ind = 0,
    request->qual[parent_ndx].price_qual = 0,
    request->qual[parent_ndx].billcode_qual = 0
   ENDIF
  WITH nocounter
 ;end select
 FOR (g_nidx = 1 TO parent_ndx)
   SET request->qual[g_nidx].billcode_qual = 0
 ENDFOR
 SET request->nbr_of_recs = parent_ndx
 IF (( $1=1))
  EXECUTE afc_load_caresets g_dmicroactivitytypecd
  EXECUTE afc_add_reference_api
 ELSE
  SET g_nrptparentcnt = 0
  SET g_nrptchildcnt = 0
  SELECT
   d1.seq
   FROM (dummyt d1  WITH seq = value(parent_ndx))
   ORDER BY request->qual[d1.seq].ext_owner_cd, request->qual[d1.seq].ext_id
   HEAD REPORT
    col 1, "Date: ", curdate,
    " ", curtime, row + 1,
    col 1, "Microbiology Bill Item Report - Items to be added/modified", row + 1
   HEAD PAGE
    col 1, "Parent", col 11,
    "Child", col 21, "Description",
    row + 1, l_sdashline = fillstring(79,"-"), col 1,
    l_sdashline, row + 1
   DETAIL
    g_nrptparentcnt += 1, col 1, request->qual[d1.seq].ext_id"#########",
    col 21, request->qual[d1.seq].ext_description, l_nchildqual = request->qual[d1.seq].child_qual
    FOR (l_nidx = 1 TO l_nchildqual)
      g_nrptchildcnt += 1, row + 1, col 11,
      request->qual[d1.seq].children[l_nidx].ext_id"#########", col 21, request->qual[d1.seq].
      children[l_nidx].ext_description
    ENDFOR
    row + 2
   FOOT PAGE
    col 1, "Page: ", curpage"####"
   FOOT REPORT
    l_ntotalcnt = (g_nrptparentcnt+ g_nrptchildcnt), col 1, "Parent Count: ",
    g_nrptparentcnt"#####", col 22, "Child Count: ",
    g_nrptchildcnt"#####", col 43, "Total: ",
    l_ntotalcnt"########"
   WITH nocounter, maxcol = 90
  ;end select
 ENDIF
END GO

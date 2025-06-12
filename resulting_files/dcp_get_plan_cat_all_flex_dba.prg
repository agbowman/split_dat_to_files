CREATE PROGRAM dcp_get_plan_cat_all_flex:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
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
 RECORD catalogs(
   1 size = i4
   1 new_size = i4
   1 loop_count = i4
   1 batch_size = i4
   1 qual[*]
     2 pathway_catalog_id = f8
 )
 DECLARE ncnt = i4 WITH noconstant(0)
 DECLARE searchstring = vc
 DECLARE searchtype = vc
 DECLARE pcf_where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE pcs_where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE maxqual = i4 WITH noconstant(50)
 DECLARE contains_search = vc WITH protect, constant("CONTAINS")
 DECLARE nincludecnt = i4 WITH constant(size(request->plan_type_include_list,5))
 DECLARE nexcludecnt = i4 WITH constant(size(request->plan_type_exclude_list,5))
 DECLARE ballowplan = i2 WITH noconstant(1)
 DECLARE num = i4 WITH noconstant(1)
 DECLARE plantotal = i4 WITH noconstant(0), protect
 DECLARE lstart = i4 WITH noconstant(0), protect
 DECLARE stat = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET searchstring = cnvtupper(trim(request->description,3))
 SET searchtype = trim(request->search_type,3)
 IF (value(request->max_qual) > 0)
  SET maxqual = request->max_qual
 ENDIF
 IF (textlen(searchstring)=0)
  DECLARE i18nhandle = i4 WITH noconstant(uar_i18nalphabet_init())
  DECLARE lowcharbuffer = c20 WITH protect, noconstant(fillstring(1," "))
  CALL uar_i18nalphabet_lowchar(i18nhandle,lowcharbuffer,1)
  SET searchstring = cnvtupper(trim(lowcharbuffer))
  CALL uar_i18nalphabet_end(i18nhandle)
 ENDIF
 SET searchstring = replace(searchstring,"\","\\",0)
 SET searchstring = replace(searchstring,'"',"?",0)
 IF (((searchtype=contains_search) OR (searchtype=""
  AND size(searchstring) >= 3)) )
  SET pcs_where_clause = build('pcs.synonym_name_key like "*',searchstring,'*"')
 ELSE
  SET pcs_where_clause = build('pcs.synonym_name_key like "',searchstring,'*"')
 ENDIF
 IF ((request->facility_cd > 0))
  SET pcf_where_clause = build("pcf.parent_entity_id in (request->facility_cd,0)")
 ELSE
  SET pcf_where_clause = build("pcf.parent_entity_id >= 0")
 ENDIF
 SELECT INTO "nl:"
  pcs.synonym_name_key, pwc.type_mean, pwc.version,
  per.type_mean, per.evidence_locator, pcs.primary_ind
  FROM pw_cat_flex pcf,
   pathway_catalog pwc,
   pw_evidence_reltn per,
   pw_cat_synonym pcs
  PLAN (pcf
   WHERE parser(pcf_where_clause)
    AND pcf.parent_entity_name="CODE_VALUE")
   JOIN (pcs
   WHERE pcs.pathway_catalog_id=pcf.pathway_catalog_id
    AND parser(pcs_where_clause))
   JOIN (pwc
   WHERE pwc.pathway_catalog_id=pcf.pathway_catalog_id
    AND pwc.active_ind=1
    AND pwc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pwc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (per
   WHERE per.pathway_catalog_id=outerjoin(pwc.pathway_catalog_id))
  ORDER BY pcs.synonym_name_key
  HEAD REPORT
   ballowplan = 1, ncnt = 0, stat = alterlist(reply->qual,maxqual),
   stat = alterlist(catalogs->qual,maxqual)
  HEAD pcs.synonym_name_key
   ballowplan = 1
   IF (pwc.pathway_type_cd != 0.0)
    IF (nexcludecnt > 0)
     IF (0 < locateval(num,1,nexcludecnt,pwc.pathway_type_cd,request->plan_type_exclude_list[num].
      pathway_type_cd))
      ballowplan = 0
     ENDIF
    ELSEIF (nincludecnt > 0)
     IF (0 >= locateval(num,1,nincludecnt,pwc.pathway_type_cd,request->plan_type_include_list[num].
      pathway_type_cd))
      ballowplan = 0
     ENDIF
    ENDIF
   ENDIF
   IF (ballowplan=1)
    ncnt = (ncnt+ 1)
    IF (ncnt <= maxqual)
     reply->qual[ncnt].pathway_catalog_id = pcf.pathway_catalog_id, reply->qual[ncnt].
     display_description = trim(pcs.synonym_name), reply->qual[ncnt].pw_cat_synonym_id = pcs
     .pw_cat_synonym_id,
     reply->qual[ncnt].primary_ind = pcs.primary_ind, catalogs->qual[ncnt].pathway_catalog_id = pcf
     .pathway_catalog_id
    ENDIF
   ENDIF
  DETAIL
   IF (ballowplan=1)
    IF (ncnt <= maxqual)
     IF (per.dcp_clin_cat_cd=0
      AND per.dcp_clin_sub_cat_cd=0
      AND per.pathway_comp_id=0)
      IF (per.type_mean="REFTEXT")
       reply->qual[ncnt].pw_evidence_reltn_id = per.pw_evidence_reltn_id
      ENDIF
      IF (((per.type_mean="ZYNX") OR (per.type_mean="URL")) )
       reply->qual[ncnt].evidence_locator = per.evidence_locator
      ENDIF
     ENDIF
    ELSE
     CALL cancel(1)
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,ncnt)
  WITH nocounter
 ;end select
 SET num = 0
 SET lstart = 1
 SET plantotal = value(size(reply->qual,5))
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
     IF ((reply->qual[indx].pathway_catalog_id=rtr.parent_entity_id))
      reply->qual[indx].ref_text_ind = 1
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 IF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO

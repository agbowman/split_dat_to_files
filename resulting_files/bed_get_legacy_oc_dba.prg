CREATE PROGRAM bed_get_legacy_oc:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 catalog_code_value = f8
     2 rel_list[*]
       3 dta_id = f8
       3 facility = vc
       3 short_desc = vc
       3 long_desc = vc
       3 sequence = i4
       3 match_dta
         4 code_value = f8
         4 display = vc
         4 description = vc
         4 result_type_code_value = f8
         4 result_type_display = vc
       3 result_type = vc
       3 event
         4 code_value = f8
         4 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET oc_cnt = size(request->oc_list,5)
 SET stat = alterlist(reply->oc_list,oc_cnt)
 SET fcnt = 0
 RECORD fac(
   1 qual[*]
     2 name = vc
 )
 SET ccnt = 0
 SET ccnt = size(request->contributor_sources,5)
 DECLARE c_string = vc
 IF (ccnt > 0)
  FOR (x = 1 TO ccnt)
    IF (x=1)
     SET c_string = concat("a.contributor_source_cd in (",cnvtstring(request->contributor_sources[x].
       code_value))
    ELSE
     SET c_string = concat(trim(c_string),",",cnvtstring(request->contributor_sources[x].code_value))
    ENDIF
  ENDFOR
  SET c_string = concat(trim(c_string),")")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ccnt)),
    br_name_value b
   PLAN (d)
    JOIN (b
    WHERE b.br_nv_key1="REL_CONTRIBUTOR_FACILITY"
     AND b.br_name=cnvtstring(request->contributor_sources[d.seq].code_value))
   DETAIL
    fcnt = (fcnt+ 1), stat = alterlist(fac->qual,fcnt), fac->qual[fcnt].name = b.br_value
   WITH nocounter
  ;end select
 ENDIF
 DECLARE b_string = vc
 IF (fcnt > 0
  AND (fac->qual[1].name > " "))
  FOR (x = 1 TO fcnt)
    IF (x=1)
     SET b_string = concat(" oc.facility in ('",fac->qual[x].name,"'")
    ELSE
     SET b_string = concat(trim(b_string),",'",fac->qual[x].name,"'")
    ENDIF
  ENDFOR
  SET b_string = concat(trim(b_string),")")
 ELSE
  SET b_string = "0 = 0"
 ENDIF
 FOR (x = 1 TO oc_cnt)
  SET reply->oc_list[x].catalog_code_value = request->oc_list[x].catalog_code_value
  IF ((request->load.dta_reltn_ind=1))
   SET tot_rcnt = 0
   SET rcnt = 0
   SELECT INTO "NL:"
    FROM br_oc_work oc,
     br_dta_relationship rel,
     br_dta_work dta
    PLAN (oc
     WHERE (oc.match_orderable_cd=request->oc_list[x].catalog_code_value)
      AND parser(b_string))
     JOIN (rel
     WHERE oc.oc_id=rel.oc_id)
     JOIN (dta
     WHERE rel.dta_id=dta.dta_id)
    ORDER BY oc.oc_id, rel.sequence
    HEAD REPORT
     reply->status_data.status = "S", tot_rcnt = 0, stat = alterlist(reply->oc_list[x].rel_list,10)
    HEAD dta.dta_id
     rcnt = (rcnt+ 1), tot_rcnt = (tot_rcnt+ 1)
     IF (rcnt > 10)
      rcnt = 1, stat = alterlist(reply->oc_list[x].rel_list,(tot_rcnt+ 10))
     ENDIF
     reply->oc_list[x].rel_list[tot_rcnt].dta_id = dta.dta_id, reply->oc_list[x].rel_list[tot_rcnt].
     facility = dta.facility, reply->oc_list[x].rel_list[tot_rcnt].short_desc = dta.short_desc,
     reply->oc_list[x].rel_list[tot_rcnt].long_desc = dta.long_desc, reply->oc_list[x].rel_list[
     tot_rcnt].result_type = dta.result_type, reply->oc_list[x].rel_list[tot_rcnt].sequence = rel
     .sequence,
     reply->oc_list[x].rel_list[tot_rcnt].match_dta.code_value = dta.match_dta_cd
    FOOT REPORT
     stat = alterlist(reply->oc_list[x].rel_list,tot_rcnt)
    WITH nocounter
   ;end select
   IF (tot_rcnt=0)
    DECLARE concept_cki = vc
    SET bedrock_cd = 0.0
    SELECT INTO "nl:"
     FROM order_catalog o
     PLAN (o
      WHERE (o.catalog_cd=request->oc_list[x].catalog_code_value))
     DETAIL
      concept_cki = o.concept_cki
     WITH nocounter
    ;end select
    IF (concept_cki > " ")
     SELECT INTO "nl:"
      FROM br_auto_order_catalog b
      PLAN (b
       WHERE b.concept_cki=concept_cki)
      DETAIL
       bedrock_cd = b.catalog_cd
      WITH nocounter, skipbedrock = 1
     ;end select
    ENDIF
    IF (bedrock_cd > 0)
     SELECT INTO "NL:"
      FROM br_oc_work oc,
       br_dta_relationship rel,
       br_dta_work dta
      PLAN (oc
       WHERE oc.match_orderable_cd=bedrock_cd
        AND parser(b_string))
       JOIN (rel
       WHERE oc.oc_id=rel.oc_id)
       JOIN (dta
       WHERE rel.dta_id=dta.dta_id)
      ORDER BY oc.oc_id, rel.sequence
      HEAD REPORT
       reply->status_data.status = "S", rcnt = 0, tot_rcnt = 0,
       stat = alterlist(reply->oc_list[x].rel_list,10)
      HEAD dta.dta_id
       rcnt = (rcnt+ 1), tot_rcnt = (tot_rcnt+ 1)
       IF (rcnt > 10)
        rcnt = 1, stat = alterlist(reply->oc_list[x].rel_list,(tot_rcnt+ 10))
       ENDIF
       reply->oc_list[x].rel_list[tot_rcnt].dta_id = dta.dta_id, reply->oc_list[x].rel_list[tot_rcnt]
       .facility = dta.facility, reply->oc_list[x].rel_list[tot_rcnt].short_desc = dta.short_desc,
       reply->oc_list[x].rel_list[tot_rcnt].long_desc = dta.long_desc, reply->oc_list[x].rel_list[
       tot_rcnt].result_type = dta.result_type, reply->oc_list[x].rel_list[tot_rcnt].sequence = rel
       .sequence,
       reply->oc_list[x].rel_list[tot_rcnt].match_dta.code_value = dta.match_dta_cd
      FOOT REPORT
       stat = alterlist(reply->oc_list[x].rel_list,tot_rcnt)
      WITH nocounter
     ;end select
    ENDIF
    IF (tot_rcnt=0)
     IF (ccnt > 0)
      FOR (y = 1 TO ccnt)
        SELECT INTO "nl:"
         FROM code_value_alias a,
          br_oc_work oc,
          br_name_value b,
          br_dta_relationship rel,
          br_dta_work dta
         PLAN (a
          WHERE a.code_set=200
           AND (a.code_value=request->oc_list[x].catalog_code_value)
           AND (a.contributor_source_cd=request->contributor_sources[y].code_value))
          JOIN (oc
          WHERE ((oc.alias1=a.alias) OR (oc.alias2=a.alias)) )
          JOIN (b
          WHERE b.br_nv_key1="REL_CONTRIBUTOR_FACILITY"
           AND b.br_name=cnvtstring(request->contributor_sources[y].code_value)
           AND b.br_value=oc.facility)
          JOIN (rel
          WHERE oc.oc_id=rel.oc_id)
          JOIN (dta
          WHERE rel.dta_id=dta.dta_id)
         ORDER BY oc.oc_id, rel.sequence
         HEAD REPORT
          reply->status_data.status = "S"
         HEAD dta.dta_id
          tot_rcnt = (tot_rcnt+ 1), stat = alterlist(reply->oc_list[x].rel_list,tot_rcnt), reply->
          oc_list[x].rel_list[tot_rcnt].dta_id = dta.dta_id,
          reply->oc_list[x].rel_list[tot_rcnt].facility = dta.facility, reply->oc_list[x].rel_list[
          tot_rcnt].short_desc = dta.short_desc, reply->oc_list[x].rel_list[tot_rcnt].long_desc = dta
          .long_desc,
          reply->oc_list[x].rel_list[tot_rcnt].result_type = dta.result_type, reply->oc_list[x].
          rel_list[tot_rcnt].sequence = rel.sequence, reply->oc_list[x].rel_list[tot_rcnt].match_dta.
          code_value = dta.match_dta_cd
         WITH nocounter
        ;end select
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   IF (tot_rcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tot_rcnt)),
      br_auto_dta dta
     PLAN (d)
      JOIN (dta
      WHERE (dta.task_assay_cd=reply->oc_list[x].rel_list[d.seq].match_dta.code_value))
     ORDER BY d.seq
     HEAD d.seq
      reply->oc_list[x].rel_list[d.seq].match_dta.display = dta.mnemonic, reply->oc_list[x].rel_list[
      d.seq].match_dta.description = dta.description, reply->oc_list[x].rel_list[d.seq].match_dta.
      result_type_code_value = dta.result_type_cd
     WITH nocounter, skipbedrock = 1
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tot_rcnt)),
      discrete_task_assay dta
     PLAN (d)
      JOIN (dta
      WHERE (dta.task_assay_cd=reply->oc_list[x].rel_list[d.seq].match_dta.code_value)
       AND dta.task_assay_cd > 0)
     ORDER BY d.seq
     HEAD d.seq
      reply->oc_list[x].rel_list[d.seq].match_dta.display = dta.mnemonic, reply->oc_list[x].rel_list[
      d.seq].match_dta.description = dta.description, reply->oc_list[x].rel_list[d.seq].match_dta.
      result_type_code_value = dta.default_result_type_cd
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tot_rcnt)),
      code_value c
     PLAN (d)
      JOIN (c
      WHERE (c.code_value=reply->oc_list[x].rel_list[d.seq].match_dta.result_type_code_value))
     ORDER BY d.seq
     HEAD d.seq
      reply->oc_list[x].rel_list[d.seq].match_dta.result_type_display = c.display
     WITH nocounter
    ;end select
   ENDIF
   IF (ccnt > 0)
    IF (tot_rcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(tot_rcnt)),
       br_dta_work w,
       br_name_value b,
       code_value_alias a,
       code_value c
      PLAN (d)
       JOIN (w
       WHERE (w.dta_id=reply->oc_list[x].rel_list[d.seq].dta_id)
        AND (w.facility=reply->oc_list[x].rel_list[d.seq].facility))
       JOIN (b
       WHERE b.br_nv_key1="REL_CONTRIBUTOR_FACILITY"
        AND b.br_value=w.facility)
       JOIN (a
       WHERE a.code_set=72
        AND a.alias=w.alias
        AND a.contributor_source_cd=cnvtint(b.br_name))
       JOIN (c
       WHERE c.code_value=a.code_value)
      ORDER BY d.seq
      HEAD d.seq
       reply->oc_list[x].rel_list[d.seq].event.code_value = c.code_value, reply->oc_list[x].rel_list[
       d.seq].event.display = c.display
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 CALL echorecord(reply)
END GO

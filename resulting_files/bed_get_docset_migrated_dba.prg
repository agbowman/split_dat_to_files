CREATE PROGRAM bed_get_docset_migrated:dba
 FREE SET reply
 RECORD reply(
   1 powerforms[*]
     2 dcp_forms_ref_id = f8
     2 dcp_section_ref_id = f8
     2 doc_sets[*]
       3 doc_set_ref_id = f8
       3 name = vc
       3 description = vc
     2 sections[*]
       3 dcp_section_ref_id = f8
       3 description = vc
       3 sequence = i4
       3 doc_set_sections[*]
         4 doc_set_section_ref_id = f8
         4 name = vc
         4 description = vc
       3 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET trep
 RECORD trep(
   1 powerforms[*]
     2 dcp_forms_ref_id = vc
     2 sections[*]
       3 dcp_section_ref_id = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = size(request->powerforms,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->powerforms,cnt)
 SET stat = alterlist(trep->powerforms,cnt)
 FOR (x = 1 TO cnt)
   SET reply->powerforms[x].dcp_forms_ref_id = request->powerforms[x].dcp_forms_ref_id
   SET reply->powerforms[x].dcp_section_ref_id = request->powerforms[x].dcp_section_ref_id
   IF ((reply->powerforms[x].dcp_section_ref_id > 0))
    SET stat = alterlist(reply->powerforms[x].sections,1)
    SET stat = alterlist(trep->powerforms[x].sections,1)
    SET reply->powerforms[x].sections[1].dcp_section_ref_id = reply->powerforms[x].dcp_section_ref_id
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   dcp_forms_ref f,
   dcp_forms_def d2,
   dcp_section_ref s
  PLAN (d
   WHERE (reply->powerforms[d.seq].dcp_forms_ref_id > 0))
   JOIN (f
   WHERE (f.dcp_forms_ref_id=reply->powerforms[d.seq].dcp_forms_ref_id)
    AND f.active_ind=1)
   JOIN (d2
   WHERE d2.dcp_form_instance_id=f.dcp_form_instance_id
    AND d2.active_ind=1)
   JOIN (s
   WHERE s.dcp_section_ref_id=d2.dcp_section_ref_id
    AND s.active_ind=1)
  ORDER BY d.seq, d2.section_seq
  HEAD d.seq
   scnt = 0, stcnt = 0, stat = alterlist(reply->powerforms[d.seq].sections,10),
   stat = alterlist(trep->powerforms[d.seq].sections,10)
  HEAD s.dcp_section_ref_id
   scnt = (scnt+ 1), stcnt = (stcnt+ 1)
   IF (scnt > 10)
    stat = alterlist(reply->powerforms[d.seq].sections,(stcnt+ 10)), stat = alterlist(trep->
     powerforms[d.seq].sections,(stcnt+ 10)), scnt = 1
   ENDIF
   reply->powerforms[d.seq].sections[stcnt].dcp_section_ref_id = s.dcp_section_ref_id, reply->
   powerforms[d.seq].sections[stcnt].name = s.description, reply->powerforms[d.seq].sections[stcnt].
   description = s.definition,
   reply->powerforms[d.seq].sections[stcnt].sequence = d2.section_seq
  FOOT  d.seq
   stat = alterlist(reply->powerforms[d.seq].sections,stcnt), stat = alterlist(trep->powerforms[d.seq
    ].sections,stcnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   SET trep->powerforms[x].dcp_forms_ref_id = idtostring(reply->powerforms[x].dcp_forms_ref_id)
   SET scnt = size(reply->powerforms[x].sections,5)
   FOR (z = 1 TO scnt)
     SET trep->powerforms[x].sections[z].dcp_section_ref_id = idtostring(reply->powerforms[x].
      sections[z].dcp_section_ref_id)
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_name_value b,
   doc_set_ref r,
   doc_set_ref r2
  PLAN (d
   WHERE (reply->powerforms[d.seq].dcp_forms_ref_id > 0))
   JOIN (b
   WHERE b.br_nv_key1="DOCSETMIGRATEFORM"
    AND (b.br_name=trep->powerforms[d.seq].dcp_forms_ref_id))
   JOIN (r
   WHERE r.doc_set_ref_id=cnvtreal(trim(b.br_value)))
   JOIN (r2
   WHERE r2.doc_set_ref_id=r.prev_doc_set_ref_id
    AND r2.active_ind=1
    AND r2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND r2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, r2.doc_set_ref_id
  HEAD d.seq
   dscnt = 0
  HEAD d.seq
   dscnt = 0, dstcnt = 0, stat = alterlist(reply->powerforms[d.seq].doc_sets,10)
  HEAD r2.doc_set_ref_id
   dscnt = (dscnt+ 1), dstcnt = (dstcnt+ 1)
   IF (dscnt > 10)
    stat = alterlist(reply->powerforms[d.seq].doc_sets,(dstcnt+ 10)), dscnt = 1
   ENDIF
   reply->powerforms[d.seq].doc_sets[dstcnt].description = r2.doc_set_description, reply->powerforms[
   d.seq].doc_sets[dstcnt].doc_set_ref_id = r2.doc_set_ref_id, reply->powerforms[d.seq].doc_sets[
   dstcnt].name = r2.doc_set_name
  FOOT  d.seq
   stat = alterlist(reply->powerforms[d.seq].doc_sets,dstcnt)
  WITH nocounter
 ;end select
 CALL echorecord(trep)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   (dummyt d2  WITH seq = 1),
   br_name_value b,
   doc_set_section_ref r,
   doc_set_section_ref r2
  PLAN (d
   WHERE maxrec(d2,size(reply->powerforms[d.seq].sections,5)))
   JOIN (d2)
   JOIN (b
   WHERE b.br_nv_key1="DOCSETMIGRATE"
    AND (b.br_name=trep->powerforms[d.seq].sections[d2.seq].dcp_section_ref_id))
   JOIN (r
   WHERE r.doc_set_section_ref_id=cnvtreal(trim(b.br_value)))
   JOIN (r2
   WHERE r2.doc_set_section_ref_id=r.prev_doc_set_section_ref_id
    AND r2.active_ind=1
    AND r2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND r2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, d2.seq, r2.doc_set_section_ref_id
  HEAD d.seq
   dscnt = 0
  HEAD d2.seq
   dscnt = 0, dstcnt = 0, stat = alterlist(reply->powerforms[d.seq].sections[d2.seq].doc_set_sections,
    10)
  HEAD r2.doc_set_section_ref_id
   dscnt = (dscnt+ 1), dstcnt = (dstcnt+ 1)
   IF (dscnt > 10)
    stat = alterlist(reply->powerforms[d.seq].sections[d2.seq].doc_set_sections,(dstcnt+ 10)), dscnt
     = 1
   ENDIF
   reply->powerforms[d.seq].sections[d2.seq].doc_set_sections[dstcnt].description = r2
   .doc_set_section_description, reply->powerforms[d.seq].sections[d2.seq].doc_set_sections[dstcnt].
   doc_set_section_ref_id = r2.doc_set_section_ref_id, reply->powerforms[d.seq].sections[d2.seq].
   doc_set_sections[dstcnt].name = r2.doc_set_section_name
  FOOT  d2.seq
   stat = alterlist(reply->powerforms[d.seq].sections[d2.seq].doc_set_sections,dstcnt)
  WITH nocounter
 ;end select
 SUBROUTINE idtostring(p1)
   DECLARE string1 = vc
   DECLARE string2 = vc
   SET string1 = build(p1)
   SET y = findstring(".",string1,1,0)
   SET string2 = substring(1,(y - 1),string1)
   RETURN(string2)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

CREATE PROGRAM bed_get_os_order_sets:dba
 FREE SET reply
 RECORD reply(
   1 catalog_types[*]
     2 code_value = f8
     2 display = vc
     2 meaning = vc
     2 activity_types[*]
       3 code_value = f8
       3 display = vc
       3 meaning = vc
       3 order_sets[*]
         4 code_value = f8
         4 description = vc
         4 primary_synonym_mnemonic = vc
         4 active_ind = i2
         4 component_synonyms[*]
           5 synonym_id = f8
           5 mnemonic = vc
           5 mnemonic_type
             6 code_value = f8
             6 display = vc
             6 meaning = vc
           5 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_cnt = 0
 SET cnt2 = 0
 SET list_cnt2 = 0
 SET cnt3 = 0
 SET list_cnt3 = 0
 SET scnt3 = 0
 SET slist_cnt3 = 0
 SET orderable_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6030
    AND cv.cdf_meaning="ORDERABLE"
    AND cv.active_ind=1)
  DETAIL
   orderable_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.orderable_type_flag IN (2, 6))
  ORDER BY oc.catalog_type_cd, oc.activity_type_cd
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->catalog_types,10)
  HEAD oc.catalog_type_cd
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 10)
    stat = alterlist(reply->catalog_types,(cnt+ 10)), list_cnt = 1
   ENDIF
   reply->catalog_types[cnt].code_value = oc.catalog_type_cd, cnt2 = 0, list_cnt2 = 0,
   stat = alterlist(reply->catalog_types[cnt].activity_types,10)
  HEAD oc.activity_type_cd
   cnt2 = (cnt2+ 1), list_cnt2 = (list_cnt2+ 1)
   IF (list_cnt2 > 10)
    stat = alterlist(reply->catalog_types[cnt].activity_types,(cnt2+ 10)), list_cnt2 = 1
   ENDIF
   reply->catalog_types[cnt].activity_types[cnt2].code_value = oc.activity_type_cd, cnt3 = 0,
   list_cnt3 = 0,
   stat = alterlist(reply->catalog_types[cnt].activity_types[cnt2].order_sets,100)
  DETAIL
   cnt3 = (cnt3+ 1), list_cnt3 = (list_cnt3+ 1)
   IF (list_cnt3 > 100)
    stat = alterlist(reply->catalog_types[cnt].activity_types[cnt2].order_sets,(cnt3+ 100)),
    list_cnt3 = 1
   ENDIF
   reply->catalog_types[cnt].activity_types[cnt2].order_sets[cnt3].code_value = oc.catalog_cd, reply
   ->catalog_types[cnt].activity_types[cnt2].order_sets[cnt3].description = oc.description, reply->
   catalog_types[cnt].activity_types[cnt2].order_sets[cnt3].primary_synonym_mnemonic = oc
   .primary_mnemonic,
   reply->catalog_types[cnt].activity_types[cnt2].order_sets[cnt3].active_ind = oc.active_ind
  FOOT  oc.activity_type_cd
   stat = alterlist(reply->catalog_types[cnt].activity_types[cnt2].order_sets,cnt3)
  FOOT  oc.catalog_type_cd
   stat = alterlist(reply->catalog_types[cnt].activity_types,cnt2)
  FOOT REPORT
   stat = alterlist(reply->catalog_types,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM code_value cv,
    (dummyt d  WITH seq = cnt)
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=reply->catalog_types[d.seq].code_value))
   ORDER BY d.seq
   DETAIL
    reply->catalog_types[d.seq].display = cv.display, reply->catalog_types[d.seq].meaning = cv
    .cdf_meaning
   WITH nocounter
  ;end select
  FOR (x = 1 TO cnt)
   SET cnt2 = size(reply->catalog_types[x].activity_types,5)
   IF (cnt2 > 0)
    SELECT INTO "nl:"
     FROM code_value cv,
      (dummyt d  WITH seq = cnt2)
     PLAN (d)
      JOIN (cv
      WHERE (cv.code_value=reply->catalog_types[x].activity_types[d.seq].code_value))
     ORDER BY d.seq
     DETAIL
      reply->catalog_types[x].activity_types[d.seq].display = cv.display, reply->catalog_types[x].
      activity_types[d.seq].meaning = cv.cdf_meaning
     WITH nocounter
    ;end select
    FOR (y = 1 TO cnt2)
     SET cnt3 = size(reply->catalog_types[x].activity_types[y].order_sets,5)
     IF (cnt3 > 0)
      SELECT INTO "nl:"
       FROM cs_component cs,
        order_catalog_synonym ocs,
        code_value cv,
        (dummyt d  WITH seq = cnt3)
       PLAN (d)
        JOIN (cs
        WHERE (cs.catalog_cd=reply->catalog_types[x].activity_types[y].order_sets[d.seq].code_value)
         AND cs.comp_type_cd=orderable_code_value)
        JOIN (ocs
        WHERE ocs.synonym_id=cs.comp_id)
        JOIN (cv
        WHERE cv.code_value=ocs.mnemonic_type_cd)
       ORDER BY d.seq, ocs.synonym_id
       HEAD d.seq
        scnt = 0, slist_cnt = 0, stat = alterlist(reply->catalog_types[x].activity_types[y].
         order_sets[d.seq].component_synonyms,10)
       HEAD ocs.synonym_id
        scnt = (scnt+ 1), slist_cnt = (slist_cnt+ 1)
        IF (scnt > 10)
         stat = alterlist(reply->catalog_types[x].activity_types[y].order_sets[d.seq].
          component_synonyms,(scnt+ 10)), slist_cnt = 1
        ENDIF
        reply->catalog_types[x].activity_types[y].order_sets[d.seq].component_synonyms[scnt].
        synonym_id = ocs.synonym_id, reply->catalog_types[x].activity_types[y].order_sets[d.seq].
        component_synonyms[scnt].mnemonic = ocs.mnemonic, reply->catalog_types[x].activity_types[y].
        order_sets[d.seq].component_synonyms[scnt].mnemonic_type.code_value = cv.code_value,
        reply->catalog_types[x].activity_types[y].order_sets[d.seq].component_synonyms[scnt].
        mnemonic_type.display = cv.display, reply->catalog_types[x].activity_types[y].order_sets[d
        .seq].component_synonyms[scnt].mnemonic_type.meaning = cv.cdf_meaning, reply->catalog_types[x
        ].activity_types[y].order_sets[d.seq].component_synonyms[scnt].sequence = cs.comp_seq
       FOOT  d.seq
        stat = alterlist(reply->catalog_types[x].activity_types[y].order_sets[d.seq].
         component_synonyms,scnt)
       WITH nocounter
      ;end select
     ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO

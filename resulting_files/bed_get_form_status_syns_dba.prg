CREATE PROGRAM bed_get_form_status_syns:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 order_catalogs[*]
      2 code_value = f8
      2 description = vc
      2 synonyms[*]
        3 id = f8
        3 display = vc
        3 mnemonic_display = vc
    1 toomanyresultsind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD ordtemp(
   1 oc_list[*]
     2 catalog_cd = f8
     2 description = vc
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 mnemonic_type_display = vc
       3 fac_qual_ind = i2
 )
 RECORD factemp(
   1 oc_list[*]
     2 catalog_cd = f8
     2 description = vc
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 mnemonic_type_display = vc
       3 fac_qual_ind = i2
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET reply->toomanyresultsind = 0
 SET ocnt = 0
 SET alterlist_ocnt = 0
 SET rcnt = 0
 SET alterlist_rcnt = 0
 SET total_cnt = 0
 SET max_cnt = request->max_reply
 IF ((request->search_string < " ")
  AND (request->oe_format_id=0)
  AND size(request->mnemonic_types,5) > 1
  AND (request->include_facility=0)
  AND (request->exclude_facility=0))
  SELECT INTO "nl;"
   syncount = count(DISTINCT ocsffr.synonym_id)
   FROM ocs_facility_formulary_r ocsffr
   DETAIL
    total_cnt = syncount
   WITH nocounter
  ;end select
  IF (total_cnt > max_cnt)
   GO TO exit_script
  ELSE
   SET total_cnt = 0
  ENDIF
 ENDIF
 SET pharmacycatalogcodevalue = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharmacyactivitycodevalue = uar_get_code_by("MEANING",106,"PHARMACY")
 DECLARE search_string = vc
 DECLARE ocs_parse = vc
 SET search_string = "*"
 SET search_string = concat('"',trim(request->search_string),'*"')
 SET search_string = cnvtupper(search_string)
 SET ocs_parse = "ocs.catalog_cd = oc.catalog_cd "
 SET ocs_parse = concat(ocs_parse," and ocs.active_ind = 1 ")
 SET ocs_parse = concat(ocs_parse," and cnvtupper(ocs.mnemonic) = ",search_string)
 SET mnemonictypessize = size(request->mnemonic_types,5)
 SET ocs_parse = concat(ocs_parse," and ocs.mnemonic_type_cd in (")
 FOR (count = 1 TO mnemonictypessize)
  SET ocs_parse = concat(ocs_parse,build(request->mnemonic_types[count].mnemonic_type_code_value))
  IF (count=mnemonictypessize)
   SET ocs_parse = concat(ocs_parse,")")
  ELSE
   SET ocs_parse = concat(ocs_parse,",")
  ENDIF
 ENDFOR
 IF ((request->oe_format_id > 0))
  SET ocs_parse = build(ocs_parse," and ocs.oe_format_id = ",request->oe_format_id)
 ENDIF
 SELECT INTO "NL:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ocs_facility_formulary_r ocsffr,
   code_value cv1,
   code_value cv2
  PLAN (oc
   WHERE oc.active_ind=1
    AND  NOT (oc.orderable_type_flag IN (2, 6, 10))
    AND oc.catalog_type_cd=pharmacycatalogcodevalue
    AND oc.activity_type_cd=pharmacyactivitycodevalue)
   JOIN (ocs
   WHERE parser(ocs_parse))
   JOIN (ocsffr
   WHERE ocsffr.synonym_id=ocs.synonym_id)
   JOIN (cv1
   WHERE cv1.code_value=ocs.mnemonic_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=ocsffr.facility_cd
    AND ((cv2.code_value=0) OR (cv2.code_value > 0
    AND cv2.active_ind=1)) )
  ORDER BY oc.description, oc.catalog_cd, ocs.synonym_id
  HEAD REPORT
   stat = alterlist(ordtemp->oc_list,50), ocnt = 0, alterlist_ocnt = 0
  HEAD oc.catalog_cd
   ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
   IF (alterlist_ocnt > 50)
    stat = alterlist(ordtemp->oc_list,(ocnt+ 50)), alterlist_ocnt = 1
   ENDIF
   ordtemp->oc_list[ocnt].catalog_cd = oc.catalog_cd, ordtemp->oc_list[ocnt].description = oc
   .description, stat = alterlist(ordtemp->oc_list[ocnt].synonyms,10),
   scnt = 0, alterlist_scnt = 0
  HEAD ocs.synonym_id
   scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
   IF (alterlist_scnt > 10)
    stat = alterlist(ordtemp->oc_list[ocnt].synonyms,(scnt+ 10)), alterlist_scnt = 1
   ENDIF
   ordtemp->oc_list[ocnt].synonyms[scnt].id = ocs.synonym_id, ordtemp->oc_list[ocnt].synonyms[scnt].
   mnemonic = ocs.mnemonic, ordtemp->oc_list[ocnt].synonyms[scnt].mnemonic_type_display = cv1.display
  FOOT  oc.catalog_cd
   stat = alterlist(ordtemp->oc_list[ocnt].synonyms,scnt)
  FOOT REPORT
   stat = alterlist(ordtemp->oc_list,ocnt)
  WITH nocounter
 ;end select
 SET total_cnt = ocnt
 IF ((request->include_facility=0)
  AND (request->exclude_facility=0))
  IF (((max_cnt=0) OR (((total_cnt=max_cnt) OR (total_cnt < max_cnt)) )) )
   SET stat = alterlist(reply->order_catalogs,ocnt)
   FOR (r = 1 TO total_cnt)
     SET reply->order_catalogs[r].code_value = ordtemp->oc_list[r].catalog_cd
     SET reply->order_catalogs[r].description = ordtemp->oc_list[r].description
     SET scnt = size(ordtemp->oc_list[r].synonyms,5)
     SET total_cnt = (total_cnt+ scnt)
     SET stat = alterlist(reply->order_catalogs[r].synonyms,scnt)
     FOR (s = 1 TO scnt)
       SET reply->order_catalogs[r].synonyms[s].id = ordtemp->oc_list[r].synonyms[s].id
       SET reply->order_catalogs[r].synonyms[s].display = ordtemp->oc_list[r].synonyms[s].mnemonic
       SET reply->order_catalogs[r].synonyms[s].mnemonic_display = ordtemp->oc_list[r].synonyms[s].
       mnemonic_type_display
     ENDFOR
   ENDFOR
  ENDIF
 ELSEIF ((request->include_facility > 0)
  AND (request->exclude_facility=0))
  IF ((request->exclude_default_facility_rows=1))
   SET ofr_parse = concat("ofr.synonym_id = ocs.synonym_id and ",
    "ofr.facility_cd = request->include_facility")
  ELSE
   SET ofr_parse = concat("ofr.synonym_id = ocs.synonym_id and ",
    "(ofr.facility_cd = 0 or ofr.facility_cd = request->include_facility)")
  ENDIF
  IF (ocnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     order_catalog oc,
     order_catalog_synonym ocs,
     ocs_facility_r ofr
    PLAN (d)
     JOIN (oc
     WHERE (oc.catalog_cd=ordtemp->oc_list[d.seq].catalog_cd))
     JOIN (ocs
     WHERE ocs.catalog_cd=oc.catalog_cd)
     JOIN (ofr
     WHERE parser(ofr_parse))
    ORDER BY oc.description, oc.catalog_cd, ocs.synonym_id
    HEAD REPORT
     stat = alterlist(reply->order_catalogs,50), rcnt = 0, alterlist_rcnt = 0
    HEAD oc.catalog_cd
     rcnt = (rcnt+ 1), alterlist_rcnt = (alterlist_rcnt+ 1)
     IF (alterlist_rcnt > 50)
      stat = alterlist(reply->order_catalogs,(rcnt+ 50)), alterlist_rcnt = 1
     ENDIF
     reply->order_catalogs[rcnt].code_value = ordtemp->oc_list[d.seq].catalog_cd, reply->
     order_catalogs[rcnt].description = ordtemp->oc_list[d.seq].description, rep_syn_cnt = 0
    HEAD ocs.synonym_id
     scnt = size(ordtemp->oc_list[d.seq].synonyms,5), total_cnt = (total_cnt+ scnt)
     FOR (s = 1 TO scnt)
       IF ((ocs.synonym_id=ordtemp->oc_list[d.seq].synonyms[s].id))
        rep_syn_cnt = (rep_syn_cnt+ 1), stat = alterlist(reply->order_catalogs[rcnt].synonyms,
         rep_syn_cnt), reply->order_catalogs[rcnt].synonyms[rep_syn_cnt].id = ordtemp->oc_list[d.seq]
        .synonyms[s].id,
        reply->order_catalogs[rcnt].synonyms[rep_syn_cnt].display = ordtemp->oc_list[d.seq].synonyms[
        s].mnemonic, reply->order_catalogs[rcnt].synonyms[rep_syn_cnt].mnemonic_display = ordtemp->
        oc_list[d.seq].synonyms[s].mnemonic_type_display
       ENDIF
     ENDFOR
    FOOT  oc.catalog_cd
     IF (rep_syn_cnt=0)
      rcnt = (rcnt - 1), alterlist_rcnt = (alterlist_rcnt - 1)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->order_catalogs,rcnt)
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF ((request->include_facility=0)
  AND (request->exclude_facility > 0))
  SET ofr_parse = concat("ofr.synonym_id = ocs.synonym_id and ",
   " ofr.facility_cd in (request->exclude_facility, 0)")
  SET stat = alterlist(reply->order_catalogs,50)
  SET rcnt = 0
  SET alterlist_rcnt = 0
  FOR (o = 1 TO ocnt)
    SET row_found = 0
    SELECT INTO "NL:"
     FROM order_catalog oc,
      order_catalog_synonym ocs,
      ocs_facility_r ofr
     PLAN (oc
      WHERE (oc.catalog_cd=ordtemp->oc_list[o].catalog_cd))
      JOIN (ocs
      WHERE ocs.catalog_cd=oc.catalog_cd)
      JOIN (ofr
      WHERE parser(ofr_parse))
     ORDER BY ocs.synonym_id
     HEAD ocs.synonym_id
      scnt = size(ordtemp->oc_list[o].synonyms,5)
      FOR (s = 1 TO scnt)
        IF ((ocs.synonym_id=ordtemp->oc_list[o].synonyms[s].id))
         ordtemp->oc_list[o].synonyms[s].fac_qual_ind = 1
        ENDIF
      ENDFOR
     DETAIL
      row_found = 1
     WITH nocounter
    ;end select
    SET scnt = size(ordtemp->oc_list[o].synonyms,5)
    SET ord_load_ind = 0
    SET rep_syn_cnt = 0
    FOR (s = 1 TO scnt)
      IF ((ordtemp->oc_list[o].synonyms[s].fac_qual_ind=0))
       IF (ord_load_ind=0)
        SET rcnt = (rcnt+ 1)
        SET stat = alterlist(reply->order_catalogs,rcnt)
        SET reply->order_catalogs[rcnt].code_value = ordtemp->oc_list[o].catalog_cd
        SET reply->order_catalogs[rcnt].description = ordtemp->oc_list[o].description
       ENDIF
       SET ord_load_ind = 1
       IF ((request->load_synonyms_ind=1))
        SET rep_syn_cnt = (rep_syn_cnt+ 1)
        SET total_cnt = (total_cnt+ 1)
        SET stat = alterlist(reply->order_catalogs[rcnt].synonyms,rep_syn_cnt)
        SET reply->order_catalogs[rcnt].synonyms[rep_syn_cnt].id = ordtemp->oc_list[o].synonyms[s].id
        SET reply->order_catalogs[rcnt].synonyms[rep_syn_cnt].display = ordtemp->oc_list[o].synonyms[
        s].mnemonic
        SET reply->order_catalogs[rcnt].synonyms[rep_syn_cnt].mnemonic_display = ordtemp->oc_list[o].
        synonyms[s].mnemonic_type_display
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
  SET stat = alterlist(reply->order_catalogs,rcnt)
 ELSEIF ((request->include_facility > 0)
  AND (request->exclude_facility > 0))
  SET stat = alterlist(factemp->oc_list,50)
  SET fcnt = 0
  SET alterlist_fcnt = 0
  IF ((request->exclude_default_facility_rows=1))
   SET ofr_parse = concat("ofr.synonym_id = ocs.synonym_id and ",
    "ofr.facility_cd = request->include_facility")
  ELSE
   SET ofr_parse = build("ofr.synonym_id = ocs.synonym_id and "," ofr.facility_cd IN (0,",request->
    include_facility,")")
  ENDIF
  IF (ocnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     order_catalog oc,
     order_catalog_synonym ocs,
     ocs_facility_r ofr
    PLAN (d)
     JOIN (oc
     WHERE (oc.catalog_cd=ordtemp->oc_list[d.seq].catalog_cd))
     JOIN (ocs
     WHERE ocs.catalog_cd=oc.catalog_cd)
     JOIN (ofr
     WHERE parser(ofr_parse))
    ORDER BY oc.description, oc.catalog_cd, ocs.synonym_id
    HEAD oc.catalog_cd
     fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
     IF (alterlist_fcnt > 50)
      stat = alterlist(factemp->oc_list,(fcnt+ 50)), alterlist_fcnt = 1
     ENDIF
     factemp->oc_list[fcnt].catalog_cd = ordtemp->oc_list[d.seq].catalog_cd, factemp->oc_list[fcnt].
     description = ordtemp->oc_list[d.seq].description, f_syn_cnt = 0
    HEAD ocs.synonym_id
     scnt = size(ordtemp->oc_list[d.seq].synonyms,5), total_cnt = (total_cnt+ scnt)
     FOR (s = 1 TO scnt)
       IF ((ocs.synonym_id=ordtemp->oc_list[d.seq].synonyms[s].id))
        f_syn_cnt = (f_syn_cnt+ 1), stat = alterlist(factemp->oc_list[fcnt].synonyms,f_syn_cnt),
        factemp->oc_list[fcnt].synonyms[f_syn_cnt].id = ordtemp->oc_list[d.seq].synonyms[s].id,
        factemp->oc_list[fcnt].synonyms[f_syn_cnt].mnemonic = ordtemp->oc_list[d.seq].synonyms[s].
        mnemonic, factemp->oc_list[fcnt].synonyms[f_syn_cnt].mnemonic_type_display = ordtemp->
        oc_list[d.seq].synonyms[s].mnemonic_type_display
       ENDIF
     ENDFOR
    FOOT REPORT
     stat = alterlist(factemp->oc_list,fcnt)
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(reply->order_catalogs,50)
  SET rcnt = 0
  SET alterlist_rcnt = 0
  FOR (f = 1 TO fcnt)
    SET row_found = 0
    SELECT INTO "NL:"
     FROM order_catalog oc,
      order_catalog_synonym ocs,
      ocs_facility_r ofr
     PLAN (oc
      WHERE (oc.catalog_cd=factemp->oc_list[f].catalog_cd))
      JOIN (ocs
      WHERE ocs.catalog_cd=oc.catalog_cd)
      JOIN (ofr
      WHERE ofr.synonym_id=ocs.synonym_id
       AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->exclude_facility))) )
     ORDER BY ocs.synonym_id
     HEAD ocs.synonym_id
      scnt = size(factemp->oc_list[f].synonyms,5)
      FOR (s = 1 TO scnt)
        IF ((ocs.synonym_id=factemp->oc_list[f].synonyms[s].id))
         factemp->oc_list[f].synonyms[s].fac_qual_ind = 1
        ENDIF
      ENDFOR
     DETAIL
      row_found = 1
     WITH nocounter
    ;end select
    SET ord_load_ind = 0
    SET scnt = size(factemp->oc_list[f].synonyms,5)
    SET rep_syn_cnt = 0
    FOR (s = 1 TO scnt)
      IF ((factemp->oc_list[f].synonyms[s].fac_qual_ind=0))
       IF (ord_load_ind=0)
        SET rcnt = (rcnt+ 1)
        SET stat = alterlist(reply->order_catalogs,rcnt)
        SET reply->order_catalogs[rcnt].code_value = factemp->oc_list[f].catalog_cd
        SET reply->order_catalogs[rcnt].description = factemp->oc_list[f].description
       ENDIF
       SET ord_load_ind = 1
       SET rep_syn_cnt = (rep_syn_cnt+ 1)
       SET total_cnt = (total_cnt+ 1)
       SET stat = alterlist(reply->order_catalogs[rcnt].synonyms,rep_syn_cnt)
       SET reply->order_catalogs[rcnt].synonyms[rep_syn_cnt].id = factemp->oc_list[f].synonyms[s].id
       SET reply->order_catalogs[rcnt].synonyms[rep_syn_cnt].display = factemp->oc_list[f].synonyms[s
       ].mnemonic
       SET reply->order_catalogs[rcnt].synonyms[rep_syn_cnt].mnemonic_display = factemp->oc_list[f].
       synonyms[s].mnemonic_type_display
      ENDIF
    ENDFOR
  ENDFOR
  SET stat = alterlist(reply->order_catalogs,rcnt)
 ENDIF
#exit_script
 IF (total_cnt=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (total_cnt > 0)
  SET reply->status_data.status = "S"
 ENDIF
 IF (max_cnt > 0
  AND total_cnt > max_cnt)
  SET stat = alterlist(reply->order_catalogs,0)
  SET reply->toomanyresultsind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO

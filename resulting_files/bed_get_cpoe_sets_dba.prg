CREATE PROGRAM bed_get_cpoe_sets:dba
 FREE SET reply
 RECORD reply(
   1 sets[*]
     2 catalog_code_value = f8
     2 description = vc
     2 primary_mnemonic = vc
     2 active_ind = i2
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE ocs_parse = vc
 DECLARE oc_parse = vc
 DECLARE ocs2_parse = vc
 DECLARE cc_parse = vc
 SET pri_code = 0.0
 SET pri_code = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET cs_ord_cd = 0.0
 SET cs_ord_cd = uar_get_code_by("MEANING",6030,"ORDERABLE")
 SET intermittent_search_ind = 0
 SET field_found = 0
 SET intermittent_search_ind = 0
 RANGE OF o IS order_catalog_synonym
 SET field_found = validate(o.intermittent_ind)
 FREE RANGE o
 IF (field_found=1)
  SET intermittent_search_ind = 1
 ENDIF
 SET ocs_parse = build(ocs_parse," ocs.catalog_cd = oc.catalog_cd and ocs.mnemonic_type_cd = ",
  pri_code," and ")
 IF (intermittent_search_ind=0
  AND (request->intermittent_ind=1))
  GO TO exit_script
 ELSEIF (intermittent_search_ind=1
  AND (request->intermittent_ind=1))
  SET ocs_parse = concat(ocs_parse," ocs.intermittent_ind = 1 and ")
 ELSEIF ((request->continuous_ind=1))
  SET ocs_parse = concat(ocs_parse," ocs.intermittent_ind in (0,null) and ")
 ENDIF
 DECLARE search_parse = vc
 IF ((request->search_string > " "))
  IF ((request->search_type_flag="S"))
   SET search_parse = concat(" '",cnvtupper(request->search_string),"*'")
  ELSE
   SET search_parse = concat(" '*",cnvtupper(request->search_string),"*'")
  ENDIF
 ENDIF
 IF ((request->search_ingred_ind=0))
  IF (search_parse > " ")
   SET oc_parse = build(oc_parse," cnvtupper(oc.primary_mnemonic) = ",trim(search_parse)," and ")
  ENDIF
  SET ocs2_parse = concat(ocs2_parse,
   " ocs2.synonym_id = outerjoin(cc.comp_id) and ocs2.active_ind = outerjoin(1) ")
  SET cc_parse = "cc.catalog_cd = oc.catalog_cd"
 ELSE
  IF (search_parse > " ")
   SET ocs2_parse = concat(ocs2_parse," ocs2.mnemonic_key_cap = ",trim(search_parse)," and ")
  ENDIF
  SET ocs2_parse = concat(ocs2_parse," ocs2.synonym_id = cc.comp_id and ocs2.active_ind = 1 ")
  SET cc_parse = build("cc.catalog_cd = oc.catalog_cd and cc.comp_type_cd = ",cs_ord_cd)
 ENDIF
 IF ((request->show_inactive_ind=0))
  SET ocs_parse = concat(ocs_parse," ocs.active_ind = 1 and ")
  SET oc_parse = concat(oc_parse," oc.active_ind = 1 and ")
 ENDIF
 SET oc_parse = concat(oc_parse," oc.orderable_type_flag in (8,11) ")
 SET ocs_parse = concat(ocs_parse," ocs.orderable_type_flag in (8,11)")
 SET all_fac_ind = 0
 SET fac_cnt = 0
 SET fac_cnt = size(request->facilities,5)
 FOR (x = 1 TO fac_cnt)
   IF ((request->facilities[x].code_value=0))
    SET all_fac_ind = 1
   ENDIF
 ENDFOR
 SET tcnt = 0
 IF (fac_cnt=0)
  SELECT INTO "nl:"
   FROM order_catalog_synonym ocs,
    order_catalog oc,
    cs_component cc,
    order_catalog_synonym ocs2
   PLAN (oc
    WHERE parser(oc_parse))
    JOIN (ocs
    WHERE parser(ocs_parse))
    JOIN (cc
    WHERE parser(cc_parse))
    JOIN (ocs2
    WHERE parser(ocs2_parse))
   ORDER BY oc.catalog_cd
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(reply->sets,100)
   HEAD oc.catalog_cd
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->sets,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->sets[tcnt].catalog_code_value = oc.catalog_cd, reply->sets[tcnt].description = oc
    .description, reply->sets[tcnt].primary_mnemonic = oc.primary_mnemonic,
    reply->sets[tcnt].active_ind = oc.active_ind
   FOOT REPORT
    stat = alterlist(reply->sets,tcnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(fac_cnt)),
    order_catalog_synonym ocs,
    order_catalog oc,
    ocs_facility_r ofr,
    cs_component cc,
    order_catalog_synonym ocs2
   PLAN (d)
    JOIN (oc
    WHERE parser(oc_parse))
    JOIN (ocs
    WHERE parser(ocs_parse))
    JOIN (ofr
    WHERE ofr.synonym_id=ocs.synonym_id
     AND ofr.facility_cd IN (0, request->facilities[d.seq].code_value))
    JOIN (cc
    WHERE parser(cc_parse))
    JOIN (ocs2
    WHERE parser(ocs2_parse))
   ORDER BY oc.catalog_cd, ocs.synonym_id, ofr.facility_cd
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(reply->sets,100)
   HEAD oc.catalog_cd
    load_oc_ind = 0,
    CALL echo(oc.description)
   HEAD ocs.synonym_id
    CALL echo(ofr.synonym_id),
    CALL echo(ocs.mnemonic)
    IF (ofr.facility_cd IN (0, null))
     load_oc_ind = 1
    ENDIF
    syn_cnt = 0
   HEAD ofr.facility_cd
    syn_cnt = (syn_cnt+ 1)
    IF (syn_cnt=fac_cnt)
     load_oc_ind = 1
    ENDIF
   FOOT  oc.catalog_cd
    IF (load_oc_ind=1)
     cnt = (cnt+ 1), tcnt = (tcnt+ 1)
     IF (cnt > 100)
      stat = alterlist(reply->sets,(tcnt+ 100)), cnt = 1
     ENDIF
     reply->sets[tcnt].catalog_code_value = oc.catalog_cd, reply->sets[tcnt].description = oc
     .description, reply->sets[tcnt].primary_mnemonic = oc.primary_mnemonic,
     reply->sets[tcnt].active_ind = oc.active_ind
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->sets,tcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((tcnt > request->max_reply)
  AND (request->max_reply > 0))
  SET stat = alterlist(reply->sets,0)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 CALL echo(build("OC PARSE: ",oc_parse))
 CALL echo(build("OCS PARSE: ",ocs_parse))
 CALL echo(build("OCS2 PARSE: ",ocs2_parse))
 CALL echo(build("CC PARSE: ",cc_parse))
END GO

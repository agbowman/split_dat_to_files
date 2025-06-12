CREATE PROGRAM bed_get_cpoe_ingredients:dba
 FREE SET reply
 RECORD reply(
   1 synonyms[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 hide_flag = i2
     2 mnemonic_type
       3 code_value = f8
       3 meaning = vc
       3 display = vc
     2 rx_mask = i4
     2 catalog_code_value = f8
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
 DECLARE syn_parse = vc
 SET field_found = 0
 SET intermittent_search_ind = 0
 RANGE OF o IS order_catalog_synonym
 SET field_found = validate(o.intermittent_ind)
 FREE RANGE o
 IF (field_found=1)
  SET intermittent_search_ind = 1
 ENDIF
 IF ((request->intermittent_ind=1)
  AND intermittent_search_ind=0)
  GO TO exit_script
 ENDIF
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET primary_code_value = 0.0
 SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET brand_code_value = 0.0
 SET brand_code_value = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET dcp_code_value = 0.0
 SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
 SET c_code_value = 0.0
 SET c_code_value = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET e_code_value = 0.0
 SET e_code_value = uar_get_code_by("MEANING",6011,"IVNAME")
 SET m_code_value = 0.0
 SET m_code_value = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET n_code_value = 0.0
 SET n_code_value = uar_get_code_by("MEANING",6011,"TRADETOP")
 IF ((request->mnemonic_type_code_value > 0))
  SET syn_parse = build(" ocs.mnemonic_type_cd = ",request->mnemonic_type_code_value,
   " and ocs.active_ind = 1 ",
   " and ocs.catalog_type_cd = pharm_ct and ocs.activity_type_cd = pharm_at and ",
   " ocs.orderable_type_flag in (0,1) ")
 ELSE
  SET syn_parse = concat(
   " ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value,",
   " c_code_value, e_code_value, m_code_value, n_code_value) and ocs.active_ind = 1 ",
   " and ocs.catalog_type_cd = pharm_ct and ocs.activity_type_cd = pharm_at and ",
   " ocs.orderable_type_flag in (0,1) ")
 ENDIF
 IF ((request->hide_ind=0))
  SET syn_parse = concat(syn_parse," and ocs.hide_flag in (0,null) ")
 ENDIF
 DECLARE search_parse = vc
 IF ((request->search_string > " "))
  IF ((request->search_type_flag="S"))
   SET syn_parse = concat(syn_parse," and ocs.mnemonic_key_cap = '",cnvtupper(request->search_string),
    "*'")
  ELSE
   SET syn_parse = concat(syn_parse," and ocs.mnemonic_key_cap = '*",cnvtupper(request->search_string
     ),"*'")
  ENDIF
 ENDIF
 IF ((request->intermittent_ind=1)
  AND intermittent_search_ind=1)
  SET syn_parse = concat(syn_parse," and ocs.intermittent_ind = 1 ")
 ENDIF
 SET all_fac_ind = 0
 SET fac_cnt = 0
 SET fac_cnt = size(request->facilities,5)
 SET tcnt = 0
 IF (fac_cnt=0)
  SELECT INTO "nl:"
   FROM order_catalog_synonym ocs,
    code_value cv
   PLAN (ocs
    WHERE parser(syn_parse))
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
   ORDER BY ocs.synonym_id
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(reply->synonyms,100)
   HEAD ocs.synonym_id
    IF ((((request->intermittent_ind=1)) OR ((request->intermittent_ind=0)
     AND ((band(ocs.rx_mask,1) > 0) OR (band(ocs.rx_mask,2) > 0)) )) )
     cnt = (cnt+ 1), tcnt = (tcnt+ 1)
     IF (cnt > 100)
      stat = alterlist(reply->synonyms,(tcnt+ 100)), cnt = 1
     ENDIF
     reply->synonyms[tcnt].synonym_id = ocs.synonym_id, reply->synonyms[tcnt].mnemonic = ocs.mnemonic,
     reply->synonyms[tcnt].hide_flag = ocs.hide_flag,
     reply->synonyms[tcnt].mnemonic_type.code_value = cv.code_value, reply->synonyms[tcnt].
     mnemonic_type.display = cv.display, reply->synonyms[tcnt].mnemonic_type.meaning = cv.cdf_meaning,
     reply->synonyms[tcnt].rx_mask = ocs.rx_mask, reply->synonyms[tcnt].catalog_code_value = ocs
     .catalog_cd
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->synonyms,tcnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(fac_cnt)),
    order_catalog_synonym ocs,
    ocs_facility_r ofr,
    code_value cv
   PLAN (d)
    JOIN (ocs
    WHERE parser(syn_parse))
    JOIN (ofr
    WHERE ofr.synonym_id=ocs.synonym_id
     AND ofr.facility_cd IN (0, request->facilities[d.seq].code_value))
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
   ORDER BY ocs.synonym_id, ofr.facility_cd
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(reply->synonyms,100)
   HEAD ocs.synonym_id
    load_syn_ind = 0, load_syn_cnt = 0, load_syn_all_ind = 0
    IF ((((request->intermittent_ind=1)) OR ((request->intermittent_ind=0)
     AND ((band(ocs.rx_mask,1) > 0) OR (band(ocs.rx_mask,2) > 0)) )) )
     load_syn_ind = 1
    ENDIF
   HEAD ofr.facility_cd
    load_syn_cnt = (load_syn_cnt+ 1)
    IF (ofr.facility_cd IN (0, null))
     load_syn_all_ind = 1
    ENDIF
   FOOT  ocs.synonym_id
    IF (load_syn_ind=1
     AND ((load_syn_cnt=fac_cnt) OR (load_syn_all_ind=1)) )
     cnt = (cnt+ 1), tcnt = (tcnt+ 1)
     IF (cnt > 100)
      stat = alterlist(reply->synonyms,(tcnt+ 100)), cnt = 1
     ENDIF
     reply->synonyms[tcnt].synonym_id = ocs.synonym_id, reply->synonyms[tcnt].mnemonic = ocs.mnemonic,
     reply->synonyms[tcnt].hide_flag = ocs.hide_flag,
     reply->synonyms[tcnt].mnemonic_type.code_value = cv.code_value, reply->synonyms[tcnt].
     mnemonic_type.display = cv.display, reply->synonyms[tcnt].mnemonic_type.meaning = cv.cdf_meaning,
     reply->synonyms[tcnt].rx_mask = ocs.rx_mask, reply->synonyms[tcnt].catalog_code_value = ocs
     .catalog_cd
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->synonyms,tcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((tcnt > request->max_reply)
  AND (request->max_reply > 0))
  SET stat = alterlist(reply->synonyms,0)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 CALL echo(build("SYN PARSE: ",syn_parse))
END GO

CREATE PROGRAM bed_get_oe_filter_by_type:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 filters[*]
      2 code_value = f8
      2 display = c40
      2 desc = c60
      2 mean = c12
      2 values[*]
        3 code_value = f8
        3 display = c40
        3 mean = c12
        3 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE entity3_id = f8 WITH protect, noconstant(0.0)
 DECLARE alterlist_vcnt = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE der_parse = vc
 IF ((request->filter_flag=1))
  SET der_parse = concat("der.entity_reltn_mean = 'CT/",cnvtstring(request->code_set),"'")
 ELSEIF ((request->filter_flag=2))
  SET der_parse = concat("der.entity_reltn_mean = 'AT/",cnvtstring(request->code_set),"'")
 ELSEIF ((request->filter_flag=3))
  SET der_parse = concat("der.entity_reltn_mean = 'ORC/",cnvtstring(request->code_set),"'")
 ELSEIF ((request->filter_flag=4))
  SET der_parse = concat("der.entity_reltn_mean = 'OCS/",cnvtstring(request->code_set),"'")
 ENDIF
 CALL echo(der_parse)
 SET new_row_cnt = 0
 SELECT INTO "nl:"
  FROM dcp_entity_reltn der
  WHERE (der.entity3_id=request->oe_field_id)
   AND parser(der_parse)
  DETAIL
   new_row_cnt = (new_row_cnt+ 1)
  WITH nocounter
 ;end select
 IF (new_row_cnt > 0)
  SET entity3_id = request->oe_field_id
 ELSE
  SET entity3_id = 0.0
 ENDIF
 SET stat = alterlist(reply->filters,50)
 SET alterlist_fcnt = 0
 SET fcnt = 0
 IF ((request->filter_flag=4))
  SELECT INTO "NL:"
   FROM dcp_entity_reltn der,
    order_catalog_synonym ocs,
    code_value cv2
   PLAN (der
    WHERE parser(der_parse)
     AND der.entity3_id=entity3_id)
    JOIN (ocs
    WHERE ocs.synonym_id=der.entity1_id)
    JOIN (cv2
    WHERE cv2.code_value=der.entity2_id)
   ORDER BY der.entity1_id, der.entity2_id
   HEAD der.entity1_id
    alterlist_fcnt = (alterlist_fcnt+ 1)
    IF (alterlist_fcnt > 50)
     stat = alterlist(reply->filters,(fcnt+ 50)), alterlist_fcnt = 1
    ENDIF
    fcnt = (fcnt+ 1), reply->filters[fcnt].code_value = der.entity1_id, reply->filters[fcnt].display
     = ocs.mnemonic,
    reply->filters[fcnt].desc = ocs.mnemonic, reply->filters[fcnt].mean = ocs.mnemonic_key_cap, stat
     = alterlist(reply->filters[fcnt].values,50),
    alterlist_vcnt = 0, vcnt = 0
   HEAD der.entity2_id
    alterlist_vcnt = (alterlist_vcnt+ 1)
    IF (alterlist_vcnt > 50)
     stat = alterlist(reply->filters[fcnt].values,(vcnt+ 50)), alterlist_vcnt = 1
    ENDIF
    vcnt = (vcnt+ 1), reply->filters[fcnt].values[vcnt].code_value = der.entity2_id, reply->filters[
    fcnt].values[vcnt].display = cv2.display,
    reply->filters[fcnt].values[vcnt].mean = cv2.cdf_meaning, reply->filters[fcnt].values[vcnt].
    active_ind = cv2.active_ind
   FOOT  der.entity1_id
    stat = alterlist(reply->filters[fcnt].values,vcnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->filters,fcnt)
  SET reply->status_data.status = "S"
 ELSE
  SELECT INTO "NL:"
   FROM dcp_entity_reltn der,
    code_value cv1,
    code_value cv2
   PLAN (der
    WHERE parser(der_parse)
     AND (((der.entity3_id=request->oe_field_id)) OR (((nullind(der.entity3_id)=1) OR (der.entity3_id
    =0)) )) )
    JOIN (cv1
    WHERE cv1.code_value=der.entity1_id)
    JOIN (cv2
    WHERE cv2.code_value=der.entity2_id)
   ORDER BY der.entity1_id, der.entity2_id
   HEAD der.entity1_id
    alterlist_fcnt = (alterlist_fcnt+ 1)
    IF (alterlist_fcnt > 50)
     stat = alterlist(reply->filters,(fcnt+ 50)), alterlist_fcnt = 1
    ENDIF
    fcnt = (fcnt+ 1), reply->filters[fcnt].code_value = der.entity1_id, reply->filters[fcnt].display
     = cv1.display,
    reply->filters[fcnt].desc = cv1.description, reply->filters[fcnt].mean = cv1.cdf_meaning, stat =
    alterlist(reply->filters[fcnt].values,50),
    alterlist_vcnt = 0, vcnt = 0
   HEAD der.entity2_id
    alterlist_vcnt = (alterlist_vcnt+ 1)
    IF (alterlist_vcnt > 50)
     stat = alterlist(reply->filters[fcnt].values,(vcnt+ 50)), alterlist_vcnt = 1
    ENDIF
    vcnt = (vcnt+ 1), reply->filters[fcnt].values[vcnt].code_value = der.entity2_id, reply->filters[
    fcnt].values[vcnt].display = cv2.display,
    reply->filters[fcnt].values[vcnt].mean = cv2.cdf_meaning
   FOOT  der.entity1_id
    stat = alterlist(reply->filters[fcnt].values,vcnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->filters,fcnt)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO

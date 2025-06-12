CREATE PROGRAM bed_get_dcp_entity_reltn_fltr:dba
 FREE RECORD reply
 RECORD reply(
   1 codeset_filters[*]
     2 code_set = i4
     2 activity_type_filter_ind = i2
     2 catalog_type_filter_ind = i2
     2 orderable_filter_ind = i2
     2 synonym_filter_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE i = i2 WITH noconstant(0)
 DECLARE fcnt = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET fcnt = size(request->codesets,5)
 SET stat = alterlist(reply->codeset_filters,fcnt)
 FOR (i = 1 TO fcnt)
  SET reply->codeset_filters[i].code_set = request->codesets[i].code_set
  SELECT INTO "NL:"
   FROM dcp_entity_reltn der
   PLAN (der
    WHERE ((der.entity_reltn_mean=concat("CT/",cnvtstring(request->codesets[i].code_set))) OR (((der
    .entity_reltn_mean=concat("AT/",cnvtstring(request->codesets[i].code_set))) OR (((der
    .entity_reltn_mean=concat("ORC/",cnvtstring(request->codesets[i].code_set))) OR (der
    .entity_reltn_mean=concat("OCS/",cnvtstring(request->codesets[i].code_set)))) )) ))
     AND der.entity3_id=0.0)
   DETAIL
    IF (der.entity_reltn_mean=concat("CT/",cnvtstring(request->codesets[i].code_set)))
     reply->codeset_filters[i].catalog_type_filter_ind = 1
    ENDIF
    IF (der.entity_reltn_mean=concat("AT/",cnvtstring(request->codesets[i].code_set)))
     reply->codeset_filters[i].activity_type_filter_ind = 1
    ENDIF
    IF (der.entity_reltn_mean=concat("ORC/",cnvtstring(request->codesets[i].code_set)))
     reply->codeset_filters[i].orderable_filter_ind = 1
    ENDIF
    IF (der.entity_reltn_mean=concat("OCS/",cnvtstring(request->codesets[i].code_set)))
     reply->codeset_filters[i].synonym_filter_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

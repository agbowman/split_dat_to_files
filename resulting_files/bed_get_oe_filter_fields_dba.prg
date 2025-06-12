CREATE PROGRAM bed_get_oe_filter_fields:dba
 FREE SET reply
 RECORD reply(
   1 fields[*]
     2 id = f8
     2 name = c100
     2 code_set = i4
     2 catalog_type_filter_ind = i2
     2 activity_type_filter_ind = i2
     2 orderable_filter_ind = i2
     2 synonym_filter_ind = i2
     2 field_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->fields,100)
 SET alterlist_fcnt = 0
 SET fcnt = 0
 SELECT INTO "NL:"
  FROM order_entry_fields oef,
   oe_format_fields off
  PLAN (oef
   WHERE oef.field_type_flag IN (6, 12, 9)
    AND oef.codeset > 0)
   JOIN (off
   WHERE off.oe_field_id=oef.oe_field_id)
  ORDER BY oef.oe_field_id
  HEAD oef.oe_field_id
   alterlist_fcnt = (alterlist_fcnt+ 1)
   IF (alterlist_fcnt > 100)
    stat = alterlist(reply->fields,(fcnt+ 100)), alterlist_fcnt = 1
   ENDIF
   fcnt = (fcnt+ 1), reply->fields[fcnt].id = oef.oe_field_id, reply->fields[fcnt].name = oef
   .description,
   reply->fields[fcnt].code_set = oef.codeset, reply->fields[fcnt].field_type_flag = oef
   .field_type_flag
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->fields,fcnt)
 IF (fcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = fcnt),
    dcp_entity_reltn der
   PLAN (d)
    JOIN (der
    WHERE ((der.entity_reltn_mean=concat("CT/",cnvtstring(reply->fields[d.seq].code_set))) OR (((der
    .entity_reltn_mean=concat("AT/",cnvtstring(reply->fields[d.seq].code_set))) OR (((der
    .entity_reltn_mean=concat("ORC/",cnvtstring(reply->fields[d.seq].code_set))) OR (der
    .entity_reltn_mean=concat("OCS/",cnvtstring(reply->fields[d.seq].code_set)))) )) )) )
   DETAIL
    IF (der.entity_reltn_mean=concat("CT/",cnvtstring(reply->fields[d.seq].code_set))
     AND (((der.entity3_id=reply->fields[d.seq].id)) OR (nullind(der.entity3_id)=1)) )
     reply->fields[d.seq].catalog_type_filter_ind = 1
    ENDIF
    IF (der.entity_reltn_mean=concat("AT/",cnvtstring(reply->fields[d.seq].code_set))
     AND (((der.entity3_id=reply->fields[d.seq].id)) OR (nullind(der.entity3_id)=1)) )
     reply->fields[d.seq].activity_type_filter_ind = 1
    ENDIF
    IF (der.entity_reltn_mean=concat("ORC/",cnvtstring(reply->fields[d.seq].code_set))
     AND (((der.entity3_id=reply->fields[d.seq].id)) OR (nullind(der.entity3_id)=1)) )
     reply->fields[d.seq].orderable_filter_ind = 1
    ENDIF
    IF (der.entity_reltn_mean=concat("OCS/",cnvtstring(reply->fields[d.seq].code_set))
     AND (der.entity3_id=reply->fields[d.seq].id))
     reply->fields[d.seq].synonym_filter_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

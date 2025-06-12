CREATE PROGRAM bed_get_oe_filter_fld_ord_rel:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 associated_with_ord_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM oe_format_fields off,
   order_catalog_synonym ocs
  PLAN (off
   WHERE (off.oe_field_id=request->field_id))
   JOIN (ocs
   WHERE ocs.oe_format_id=off.oe_format_id)
  DETAIL
   reply->associated_with_ord_ind = 1
  WITH nocounter, maxqual(ocs,1)
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

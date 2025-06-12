CREATE PROGRAM afc_ct_get_nomen:dba
 DECLARE afc_ct_get_nomen_version = vc WITH private, noconstant("121604.FT.000")
 RECORD reply(
   1 source_string = vc
   1 source_identifier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM nomenclature n
  WHERE (n.nomenclature_id=request->nomenclature_id)
  DETAIL
   reply->source_string = n.source_string, reply->source_identifier = n.source_identifier
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO

CREATE PROGRAM cdi_get_all_ac_fields
 RECORD reply(
   1 docclasses[*]
     2 doc_class_name = vc
     2 fields[*]
       3 cdi_ac_field_id = f8
       3 field_name = vc
       3 alias_type_cd = f8
       3 alias_type_codeset = i4
       3 auto_search_ind = i2
       3 man_search_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE count1 = i4 WITH noconstant(0), protect
 DECLARE count2 = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM cdi_ac_field acf
  WHERE acf.cdi_ac_field_id != 0
  ORDER BY acf.doc_class_name
  HEAD acf.doc_class_name
   count1 = (count1+ 1), stat = alterlist(reply->docclasses,count1), reply->docclasses[count1].
   doc_class_name = acf.doc_class_name,
   count2 = 0
  DETAIL
   count2 = (count2+ 1), stat = alterlist(reply->docclasses[count1].fields,count2), reply->
   docclasses[count1].fields[count2].cdi_ac_field_id = acf.cdi_ac_field_id,
   reply->docclasses[count1].fields[count2].field_name = acf.field_name, reply->docclasses[count1].
   fields[count2].alias_type_cd = acf.alias_type_cd, reply->docclasses[count1].fields[count2].
   alias_type_codeset = acf.alias_type_codeset,
   reply->docclasses[count1].fields[count2].auto_search_ind = acf.auto_search_ind, reply->docclasses[
   count1].fields[count2].man_search_ind = acf.manual_search_ind
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO

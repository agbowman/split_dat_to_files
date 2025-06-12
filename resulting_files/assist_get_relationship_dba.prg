CREATE PROGRAM assist_get_relationship:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 relationship_qual = i4
    1 relationship[10]
      2 relationship_name = c30
      2 foreign_owner_name = c30
      2 foreign_table_name = c30
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET table_name = "CODE_VALUE_EXTENSION"
 SET kount = 0
 SELECT DISTINCT INTO "nl:"
  e1.field_value
  FROM code_value_extension e1,
   code_value_extension e2,
   code_value_extension e3,
   code_value_extension e4,
   code_value_extension e5
  WHERE e1.code_set=345
   AND e1.field_name="RELATIONSHIP_NAME"
   AND e2.code_value=e1.code_value
   AND e2.field_name="OWNER_NAME"
   AND (e2.field_value=request->owner)
   AND e3.code_value=e1.code_value
   AND e3.field_name="TABLE_NAME"
   AND (e3.field_value=request->table_name)
   AND e4.code_value=e1.code_value
   AND e4.field_name="FOREIGN_OWNER_NAME"
   AND e5.code_value=e1.code_value
   AND e5.field_name="FOREIGN_TABLE_NAME"
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,10)=1
    AND kount != 1)
    stat = alter(reply->relationship,(kount+ 10))
   ENDIF
   reply->relationship[kount].relationship_name = e1.field_value, reply->relationship[kount].
   foreign_owner_name = e4.field_value, reply->relationship[kount].foreign_table_name = e5
   .field_value
  WITH nocounter
 ;end select
 SET reply->relationship_qual = kount
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = false
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
 SET stat = alter(reply->relationship,reply->relationship_qual)
 GO TO end_program
#end_program
END GO

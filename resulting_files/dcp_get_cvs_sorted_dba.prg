CREATE PROGRAM dcp_get_cvs_sorted:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 primary_ind = i2
     2 display = c40
     2 description = c60
     2 collation_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  c.code_value, c.cdf_meaning, c.display,
  c.description, c.collation_seq
  FROM code_value c
  WHERE (c.code_set=request->code_set)
   AND c.active_ind=1
  ORDER BY c.display
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].code_value = c
   .code_value,
   reply->qual[count].cdf_meaning = c.cdf_meaning, reply->qual[count].display = c.display, reply->
   qual[count].description = c.description,
   reply->qual[count].collation_seq = c.collation_seq
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 ENDIF
END GO

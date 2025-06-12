CREATE PROGRAM cp_get_section_fields:dba
 RECORD reply(
   1 code_list[*]
     2 code = f8
     2 display = c40
     2 description = c60
     2 meaning = c12
     2 display_key = c40
     2 active_ind = i2
     2 definition = c100
     2 collation_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET start_fld = cnvtstring(request->start_field)
 SET end_fld = cnvtstring(request->end_field)
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=14284
   AND c.cdf_meaning BETWEEN start_fld AND end_fld
   AND c.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->code_list,count1), reply->code_list[count1].code = c
   .code_value,
   reply->code_list[count1].display = c.display, reply->code_list[count1].description = c.description,
   reply->code_list[count1].meaning = c.cdf_meaning,
   reply->code_list[count1].display_key = c.display_key, reply->code_list[count1].active_ind = c
   .active_ind, reply->code_list[count1].definition = c.definition,
   reply->code_list[count1].collation_seq = c.collation_seq
  WITH counter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

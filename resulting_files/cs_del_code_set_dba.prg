CREATE PROGRAM cs_del_code_set:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET code_value_tbl[500] = 0
 SET code_alias_type_cd = 0
 SET count1 = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE (c.code_set=request->code_set)
  DETAIL
   count1 = (count1+ 1), code_value_tbl[count1] = c.code_value
  WITH nocounter
 ;end select
 DELETE  FROM code_value_alias c,
   (dummyt d  WITH seq = value(count1))
  SET c.seq = 1
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=code_value_tbl[d.seq]))
  WITH nocounter
 ;end delete
 DELETE  FROM code_set_domain c
  WHERE (c.code_set=request->code_set)
  WITH nocounter
 ;end delete
 DELETE  FROM code_set_field_domain c
  WHERE (c.code_set=request->code_set)
  WITH nocounter
 ;end delete
 DELETE  FROM code_value_extension c
  WHERE (c.code_set=request->code_set)
  WITH nocounter
 ;end delete
 DELETE  FROM code_set_extension c
  WHERE (c.code_set=request->code_set)
  WITH nocounter
 ;end delete
 DELETE  FROM code_domain_filter_display c
  WHERE (c.code_set=request->code_set)
  WITH nocounter
 ;end delete
 DELETE  FROM code_domain_filter c
  WHERE (c.code_set=request->code_set)
  WITH nocounter
 ;end delete
 DELETE  FROM code_value c
  WHERE (c.code_set=request->code_set)
  WITH nocounter
 ;end delete
 DELETE  FROM common_data_foundation c
  WHERE (c.code_set=request->code_set)
  WITH nocounter
 ;end delete
 DELETE  FROM code_value_set c
  WHERE (c.code_set=request->code_set)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO

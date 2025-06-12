CREATE PROGRAM dm_dm_del_cv_extension:dba
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
 SET failures = 0
 SET number_to_del = size(request->qual,5)
 FREE SET r1
 RECORD r1(
   1 rdate = dq8
 )
 SET r1->rdate = 0
 SELECT INTO "NL:"
  dac.schema_date
  FROM dm_adm_code_value_extension dac,
   (dummyt d  WITH seq = value(number_to_del))
  PLAN (d)
   JOIN (dac
   WHERE (dac.code_set=request->code_set)
    AND (c.field_name=request->qual[d.seq].field_name)
    AND (c.code_value=request->qual[d.seq].code_value))
  DETAIL
   IF ((dac.schema_date > r1->rdate))
    r1->rdate = dac.schema_date
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM dm_adm_code_value_extension c,
   (dummyt d  WITH seq = value(number_to_del))
  SET c.seq = 1, c.delete_ind = 1
  PLAN (d)
   JOIN (c
   WHERE (c.code_set=request->code_set)
    AND (c.field_name=request->qual[d.seq].field_name)
    AND (c.code_value=request->qual[d.seq].code_value)
    AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate)))
  WITH nocounter
 ;end update
 COMMIT
 SET reply->status_data.status = "S"
END GO

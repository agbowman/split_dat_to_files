CREATE PROGRAM dm_dm_del_cs_extension:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD internal(
   1 qual[1]
     2 status = i1
 )
 SET reply->status_data.status = "F"
 SET failures = 0
 SET number_to_del = size(request->qual,5)
 SET stat = alter(internal->qual,number_to_del)
 SET x = 0
 FOR (x = 1 TO number_to_del)
   FREE SET r1
   RECORD r1(
     1 rdate = dq8
   )
   SET r1->rdate = 0
   SELECT INTO "NL:"
    dac.schema_date
    FROM dm_adm_code_value_extension dac
    WHERE (dac.code_set=request->code_set)
     AND c.field_name=trim(request->qual[x].field_name)
    DETAIL
     IF ((dac.schema_date > r1->rdate))
      r1->rdate = dac.schema_date
     ENDIF
    WITH nocounter
   ;end select
   UPDATE  FROM dm_adm_code_value_extension c
    SET c.delete_ind = 1
    WHERE (c.code_set=request->code_set)
     AND c.field_name=trim(request->qual[x].field_name)
     AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
    WITH nocounter
   ;end update
   FREE SET r2
   RECORD r2(
     1 rdate = dq8
   )
   SET r2->rdate = 0
   SELECT INTO "NL:"
    dac.schema_date
    FROM dm_adm_common_data_foundation dac
    WHERE (dac.code_set=request->code_set)
     AND dac.field_name=trim(request->qual[x].field_name)
    DETAIL
     IF ((dac.schema_date > r2->rdate))
      r2->rdate = dac.schema_date
     ENDIF
    WITH nocounter
   ;end select
   UPDATE  FROM dm_adm_code_set_extension c
    SET c.delete_ind = 1
    WHERE (c.code_set=request->code_set)
     AND c.field_name=trim(request->qual[x].field_name)
     AND datetimediff(c.schema_date,cnvtdatetime(r2->rdate))=0
    WITH nocounter
   ;end update
 ENDFOR
 COMMIT
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO

CREATE PROGRAM dm_dm_del_code_value:dba
 RECORD reply(
   1 qual[*]
     2 code_set = i4
     2 code_value = f8
     2 status = c2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET number_to_del = size(request->qual,5)
 SET stat = alterlist(reply->qual,number_to_del)
 SET failures = 0
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
     AND (dac.code_value=request->qual[x].code_value)
    DETAIL
     IF ((dac.schema_date > r1->rdate))
      r1->rdate = dac.schema_date
     ENDIF
    WITH nocounter
   ;end select
   UPDATE  FROM dm_adm_code_value_extension dcve
    SET dcve.delete_ind = 1
    WHERE (dcve.code_set=request->code_set)
     AND (dcve.code_value=request->qual[x].code_value)
     AND datetimediff(dcve.schema_date,cnvtdatetime(r1->rdate))=0
    WITH nocounter
   ;end update
   FREE SET r2
   RECORD r2(
     1 rdate = dq8
   )
   SET r2->rdate = 0
   SELECT INTO "NL:"
    dac.schema_date
    FROM dm_adm_code_value_alias dac
    WHERE (dac.code_set=request->code_set)
     AND (dac.code_value=request->qual[x].code_value)
    DETAIL
     IF ((dac.schema_date > r2->rdate))
      r2->rdate = dac.schema_date
     ENDIF
    WITH nocounter
   ;end select
   UPDATE  FROM dm_adm_code_value_alias dcva
    SET dcva.delete_ind = 1
    WHERE (dcva.code_set=request->code_set)
     AND (dcva.code_value=request->qual[x].code_value)
     AND datetimediff(dcva.schema_date,cnvtdatetime(r2->rdate))=0
    WITH nocounter
   ;end update
   FREE SET r4
   RECORD r4(
     1 rdate = dq8
   )
   SET r4->rdate = 0
   SELECT INTO "nl:"
    FROM dm_adm_code_value_group dg
    WHERE (dg.code_set=request->code_set)
     AND (dg.parent_code_value=request->qual[x].code_value)
    DETAIL
     IF ((dg.schema_date > r4->rdate))
      r4->rdate = dg.schema_date
     ENDIF
    WITH nocounter
   ;end select
   UPDATE  FROM dm_adm_code_value_group dg
    SET dg.delete_ind = 1
    WHERE (dg.code_set=request->code_set)
     AND (dg.parent_code_value=request->qual[x].code_value)
     AND datetimediff(dg.schema_date,cnvtdatetime(r4->rdate))=0
    WITH nocounter
   ;end update
   SET r4->rdate = 0
   SELECT INTO "nl:"
    FROM dm_adm_code_value_group dg
    WHERE (dg.child_code_set=request->code_set)
     AND (dg.child_code_value=request->qual[x].code_value)
    DETAIL
     IF ((dg.schema_date > r4->rdate))
      r4->rdate = dg.schema_date
     ENDIF
    WITH nocounter
   ;end select
   UPDATE  FROM dm_adm_code_value_group dg
    SET dg.delete_ind = 1
    WHERE (dg.child_code_set=request->code_set)
     AND (dg.child_code_value=request->qual[x].code_value)
     AND datetimediff(dg.schema_date,cnvtdatetime(r4->rdate))=0
    WITH nocounter
   ;end update
   FREE SET r3
   RECORD r3(
     1 rdate = dq8
   )
   SET r3->rdate = 0
   SELECT INTO "NL:"
    dac.schema_date
    FROM dm_adm_code_value dac
    WHERE (dac.code_set=request->code_set)
     AND (dac.code_value=request->qual[x].code_value)
    DETAIL
     IF ((dac.schema_date > r3->rdate))
      r3->rdate = dac.schema_date
     ENDIF
    WITH nocounter
   ;end select
   UPDATE  FROM dm_adm_code_value c
    SET c.delete_ind = 1
    WHERE (c.code_set=request->code_set)
     AND (c.code_value=request->qual[x].code_value)
     AND datetimediff(c.schema_date,cnvtdatetime(r3->rdate))=0
    WITH nocounter
   ;end update
   IF (curqual > 0)
    SET reply->qual[x].status = "S"
    SET reply->qual[x].code_value = request->qual[x].code_value
   ELSE
    SET reply->qual[x].status = "D"
    SET reply->qual[x].code_value = request->qual[x].code_value
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
END GO

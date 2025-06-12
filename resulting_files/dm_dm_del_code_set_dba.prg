CREATE PROGRAM dm_dm_del_code_set:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET r1
 RECORD r1(
   1 rdate = dq8
 )
 SET r1->rdate = 0
 SELECT INTO "NL:"
  dac.schema_date
  FROM dm_adm_code_value_alias dac
  WHERE (dac.code_set=request->code_set)
  DETAIL
   IF ((dac.schema_date > r1->rdate))
    r1->rdate = dac.schema_date
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM dm_adm_code_value_alias dm
  SET dm.delete_ind = 1
  WHERE (dm.code_set=request->code_set)
   AND datetimediff(dm.schema_date,cnvtdatetime(r1->rdate))=0
  WITH nocounter
 ;end update
 FREE SET r2
 RECORD r2(
   1 rdate = dq8
 )
 SET r2->rdate = 0
 SELECT INTO "NL:"
  dac.schema_date
  FROM dm_adm_code_value_extension dac
  WHERE (dac.code_set=request->code_set)
  DETAIL
   IF ((dac.schema_date > r2->rdate))
    r2->rdate = dac.schema_date
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM dm_adm_code_value_extension dm
  SET dm.delete_ind = 1
  WHERE (dm.code_set=request->code_set)
   AND datetimediff(dm.schema_date,cnvtdatetime(r2->rdate))=0
  WITH nocounter
 ;end update
 FREE SET r3
 RECORD r3(
   1 rdate = dq8
 )
 SET r3->rdate = 0
 SELECT INTO "NL:"
  dac.schema_date
  FROM dm_adm_code_set_extension dac
  WHERE (dac.code_set=request->code_set)
  DETAIL
   IF ((dac.schema_date > r3->rdate))
    r3->rdate = dac.schema_date
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM dm_adm_code_set_extension dm
  SET dm.delete_ind = 1
  WHERE (dm.code_set=request->code_set)
   AND datetimediff(dm.schema_date,cnvtdatetime(r3->rdate))=0
  WITH nocounter
 ;end update
 FREE SET r7
 RECORD r7(
   1 rdate = dq8
 )
 FREE SET r8
 RECORD r8(
   1 rdate = dq8
 )
 SELECT INTO "nl:"
  FROM dm_adm_code_value_group dg
  WHERE (((dg.code_set=request->code_set)) OR ((dg.child_code_set=request->code_set)))
  DETAIL
   IF ((dg.code_set=request->code_set))
    IF ((dg.schema_date > r7->rdate))
     r7->rdate = dg.schema_date
    ENDIF
   ELSEIF ((dg.child_code_set=request->code_set))
    IF ((dg.schema_date > r8->rdate))
     r8->rdate = dg.schema_date
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM dm_adm_code_value_group dg
   SET dg.delete_ind = 1
   WHERE (((dg.code_set=request->code_set)
    AND datetimediff(dg.schema_date,cnvtdatetime(r7->rdate))=0) OR ((dg.child_code_set=request->
   code_set)
    AND datetimediff(dg.schema_date,cnvtdatetime(r8->rdate))=0))
   WITH nocounter
  ;end update
 ENDIF
 FREE SET r4
 RECORD r4(
   1 rdate = dq8
 )
 SET r4->rdate = 0
 SELECT INTO "NL:"
  dac.schema_date
  FROM dm_adm_code_value dac
  WHERE (dac.code_set=request->code_set)
  DETAIL
   IF ((dac.schema_date > r4->rdate))
    r4->rdate = dac.schema_date
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM dm_adm_code_value dm
  SET dm.delete_ind = 1
  WHERE (dm.code_set=request->code_set)
   AND datetimediff(dm.schema_date,cnvtdatetime(r4->rdate))=0
  WITH nocounter
 ;end update
 FREE SET r5
 RECORD r5(
   1 rdate = dq8
 )
 SET r5->rdate = 0
 SELECT INTO "NL:"
  dac.schema_date
  FROM dm_adm_code_value_set dac
  WHERE (dac.code_set=request->code_set)
  DETAIL
   IF ((dac.schema_date > r5->rdate))
    r5->rdate = dac.schema_date
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM dm_adm_code_value_set dm
  SET dm.delete_ind = 1
  WHERE (dm.code_set=request->code_set)
   AND datetimediff(dm.schema_date,cnvtdatetime(r5->rdate))=0
  WITH nocounter
 ;end update
 FREE SET r6
 RECORD r6(
   1 rdate = dq8
 )
 SET r6->rdate = 0
 SELECT INTO "NL:"
  dac.schema_date
  FROM dm_adm_common_data_foundation dac
  WHERE (dac.code_set=request->code_set)
  DETAIL
   IF ((dac.schema_date > r6->rdate))
    r6->rdate = dac.schema_date
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM dm_adm_common_data_foundation dm
  SET dm.delete_ind = 1
  WHERE (dm.code_set=request->code_set)
   AND datetimediff(dm.schema_date,cnvtdatetime(r6->rdate))=0
  WITH nocounter
 ;end update
 SET reply->status_data.status = "S"
END GO

CREATE PROGRAM dm_delete_code_value:dba
 FREE RECORD dcv_trigger
 RECORD dcv_trigger(
   1 count = i4
   1 name = vc
 )
 SET dcv_trigger->count = 0
 SET dcv_trigger->name = "NOT_SET"
 SET ddcv_del_code_set = 0.0
 IF (validate(dmrequest->code_set,- (1)) > 0)
  SET ddcv_del_code_set = dmrequest->code_set
 ENDIF
 IF (ddcv_del_code_set=0)
  IF (validate(list->count,- (1)) > 0)
   IF (validate(cnt,- (1)) > 0)
    SET ddcv_del_code_set = list->qual[cnt].code_set
   ELSE
    SET ddcv_del_code_set = list->qual[1].code_set
   ENDIF
  ENDIF
 ENDIF
 IF (ddcv_del_code_set=0)
  GO TO exit_script
 ENDIF
 FREE SET arr
 RECORD arr(
   1 var[*]
     2 cki = vc
   1 kount = i4
 )
 SET arr->kount = 0
 SET stat = alterlist(arr->var,10)
 FREE SET r2
 RECORD r2(
   1 rdate = dq8
 )
 SET r2->rdate = 0
 SET cntt = 0
 IF ((validate(r1->rdate,- (1))=- (1)))
  SELECT DISTINCT INTO "nl:"
   a.schema_date
   FROM dm_adm_code_value a
   WHERE a.code_set=ddcv_del_code_set
   ORDER BY a.schema_date DESC
   DETAIL
    cntt = (cntt+ 1)
    IF (cntt=1)
     r2->rdate = a.schema_date
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET r2->rdate = r1->rdate
 ENDIF
 SELECT INTO "nl:"
  dcv.cki
  FROM dm_adm_code_value dcv
  WHERE datetimediff(dcv.schema_date,cnvtdatetime(r2->rdate))=0
   AND dcv.code_set=ddcv_del_code_set
   AND dcv.delete_ind=1
  DETAIL
   arr->kount = (arr->kount+ 1), stat = alterlist(arr->var,arr->kount), arr->var[arr->kount].cki =
   dcv.cki
  WITH nocounter
 ;end select
 IF ((arr->kount > 0))
  SELECT INTO "nl:"
   a.trigger_name
   FROM user_triggers a
   WHERE a.table_name="CODE_VALUE"
    AND ((a.trigger_name="TRG_CODE_VALUE_DELETE") OR (a.trigger_name="TRG_CODE_VALUE_DELETE$C"))
   ORDER BY a.trigger_name DESC
   DETAIL
    dcv_trigger->count = (dcv_trigger->count+ 1), dcv_trigger->name = a.trigger_name
   WITH nocounter
  ;end select
  IF ((dcv_trigger->count > 1))
   SET dcv_trigger->name = "TRG_CODE_VALUE_DELETE"
  ENDIF
  IF ((dcv_trigger->count > 0))
   CALL parser(concat("rdb alter trigger ",dcv_trigger->name," disable go"),1)
  ENDIF
  SET delcnt = 0
  FOR (delcnt = 1 TO arr->kount)
   CALL echo("In delete")
   DELETE  FROM code_value cv
    WHERE (cv.cki=arr->var[delcnt].cki)
     AND cv.code_set=ddcv_del_code_set
    WITH nocounter
   ;end delete
  ENDFOR
  COMMIT
  IF ((dcv_trigger->count > 0))
   CALL parser(concat("rdb alter trigger ",dcv_trigger->name," enable go"),1)
  ENDIF
 ENDIF
#exit_script
END GO

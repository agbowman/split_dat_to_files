CREATE PROGRAM dm_delete_cva:dba
 FREE SET arr
 RECORD arr(
   1 var[*]
     2 old_code_value = f8
     2 new_code_value = f8
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
 SELECT DISTINCT INTO "nl:"
  a.schema_date
  FROM dm_adm_code_value_alias a
  WHERE (a.code_set=dmrequest->code_set)
  ORDER BY a.schema_date DESC
  DETAIL
   cntt = (cntt+ 1)
   IF (cntt=1)
    r2->rdate = a.schema_date
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value, d.code_value
  FROM dm_adm_code_value dcv,
   dm_adm_code_value_alias d,
   code_value c
  WHERE datetimediff(d.schema_date,cnvtdatetime(r2->rdate))=0
   AND (d.code_set=dmrequest->code_set)
   AND d.delete_ind=1
   AND d.code_value=dcv.code_value
   AND d.schema_date=dcv.schema_date
   AND dcv.cki=c.cki
  DETAIL
   arr->kount = (arr->kount+ 1), stat = alterlist(arr->var,arr->kount), arr->var[arr->kount].
   old_code_value = d.code_value,
   arr->var[arr->kount].new_code_value = c.code_value
  WITH nocounter
 ;end select
 SET delcnt = 0
 FOR (delcnt = 1 TO arr->kount)
   DELETE  FROM code_value_alias cv
    WHERE (cv.code_value=arr->var[delcnt].new_code_value)
     AND (cv.code_set=dmrequest->code_set)
     AND (cv.alias=
    (SELECT
     c.alias
     FROM dm_adm_code_value_alias c
     WHERE (c.code_set=dmrequest->code_set)
      AND datetimediff(c.schema_date,cnvtdatetime(r2->rdate))=0
      AND c.delete_ind=1
      AND (c.code_value=arr->var[delcnt].old_code_value)))
    WITH nocounter
   ;end delete
 ENDFOR
END GO

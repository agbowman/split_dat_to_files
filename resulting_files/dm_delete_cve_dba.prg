CREATE PROGRAM dm_delete_cve:dba
 FREE SET arr
 RECORD arr(
   1 var[*]
     2 old_code_value = f8
     2 new_code_value = f8
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
 SELECT DISTINCT INTO "nl:"
  a.schema_date
  FROM dm_adm_code_value_extension a
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
  d.code_value
  FROM dm_adm_code_value dcv,
   dm_adm_code_value_extension d
  PLAN (d
   WHERE d.schema_date=cnvtdatetime(r2->rdate)
    AND (d.code_set=dmrequest->code_set)
    AND d.delete_ind=1)
   JOIN (dcv
   WHERE d.code_value=dcv.code_value
    AND d.schema_date=dcv.schema_date)
  DETAIL
   arr->kount = (arr->kount+ 1), stat = alterlist(arr->var,arr->kount), arr->var[arr->kount].
   old_code_value = d.code_value,
   arr->var[arr->kount].cki = dcv.cki
  WITH nocounter
 ;end select
 IF ((arr->kount > 0))
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c,
    (dummyt d  WITH seq = value(arr->kount))
   PLAN (d)
    JOIN (c
    WHERE (c.cki=arr->var[d.seq].cki))
   DETAIL
    arr->var[d.seq].new_code_value = c.code_value
   WITH nocounter
  ;end select
  SET delcnt = 0
  FOR (delcnt = 1 TO arr->kount)
    IF ((arr->var[delcnt].new_code_value > 0))
     DELETE  FROM code_value_extension cv
      WHERE (cv.code_value=arr->var[delcnt].new_code_value)
       AND (cv.code_set=dmrequest->code_set)
       AND (cv.field_name=
      (SELECT
       c.field_name
       FROM dm_adm_code_value_extension c
       WHERE (c.code_set=dmrequest->code_set)
        AND datetimediff(c.schema_date,cnvtdatetime(r2->rdate))=0
        AND c.delete_ind=1
        AND (c.code_value=arr->var[delcnt].old_code_value)))
      WITH nocounter
     ;end delete
    ENDIF
  ENDFOR
 ENDIF
END GO

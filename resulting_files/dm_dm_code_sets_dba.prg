CREATE PROGRAM dm_dm_code_sets:dba
 RECORD reply(
   1 codeset[500]
     2 code_set = i4
     2 display = c40
     2 description = c60
     2 delete_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 FREE SET list
 RECORD list(
   1 qual[*]
     2 code_set = f8
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SELECT DISTINCT INTO "nl:"
  dm.code_set
  FROM dm_adm_code_value_set dm
  WHERE dm.code_set > 0
  ORDER BY dm.code_set
  DETAIL
   list->count = (list->count+ 1)
   IF (mod(list->count,10)=1)
    stat = alterlist(list->qual,(list->count+ 9))
   ENDIF
   list->qual[list->count].code_set = dm.code_set
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (cnt = 1 TO list->count)
   FREE SET r1
   RECORD r1(
     1 rdate = dq8
   )
   SET r1->rdate = 0
   SELECT INTO "nl:"
    dcf.schema_date
    FROM dm_adm_code_value_set dcf
    WHERE (dcf.code_set=list->qual[cnt].code_set)
    DETAIL
     IF ((dcf.schema_date > r1->rdate))
      r1->rdate = dcf.schema_date
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    c.code_set, c.display, c.description,
    c.delete_ind
    FROM dm_adm_code_value_set c
    WHERE (c.code_set=list->qual[cnt].code_set)
     AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
    ORDER BY c.code_set
    DETAIL
     IF (cnt > 500)
      IF (mod(cnt,50)=1)
       stat = alter(reply->codeset,(cnt+ 50))
      ENDIF
     ENDIF
     reply->codeset[cnt].code_set = c.code_set, reply->codeset[cnt].display = c.display, reply->
     codeset[cnt].description = c.description,
     reply->codeset[cnt].delete_in = c.delete_ind
    WITH nocounter
   ;end select
 ENDFOR
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->codeset,cnt)
END GO

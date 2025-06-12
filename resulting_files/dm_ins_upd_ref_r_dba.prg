CREATE PROGRAM dm_ins_upd_ref_r:dba
 RECORD reply(
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
 SET x = size(request->qual,5)
 DELETE  FROM dm_ref_domain_r a
  WHERE a.group_name=trim(request->group_name)
  WITH nocounter
 ;end delete
 FOR (y = 1 TO x)
   INSERT  FROM dm_ref_domain_r dm
    SET dm.group_name = trim(request->group_name), dm.ref_domain_name = trim(request->qual[y].
      ref_domain_name)
    WITH nocounter
   ;end insert
 ENDFOR
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO

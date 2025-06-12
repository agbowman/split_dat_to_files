CREATE PROGRAM dm_del_trnsltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
     2 err_num = i4
     2 err_msg = c255
 )
 SET nbr_to_del = size(request->qual,5)
 SET x = 0
 SET mrg_id = 0
 SET reply->status_data.status = "F"
 FOR (x = 1 TO nbr_to_del)
   SELECT INTO "nl:"
    a.merge_id
    FROM dm_merge_translate a
    WHERE (a.from_value=request->qual[x].from_value)
     AND a.table_name=trim(request->table_name)
    DETAIL
     mrg_id = a.merge_id
    WITH nocounter
   ;end select
   DELETE  FROM dm_merge_translate b
    WHERE (b.from_value=request->qual[x].from_value)
     AND b.table_name=trim(request->table_name)
    WITH nocounter
   ;end delete
   DELETE  FROM dm_merge_action c
    WHERE c.merge_id=mrg_id
    WITH nocounter
   ;end delete
 ENDFOR
 SET reply->status_data.status = "S"
 COMMIT
END GO

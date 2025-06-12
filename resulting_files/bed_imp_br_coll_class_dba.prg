CREATE PROGRAM bed_imp_br_coll_class:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET row_cnt = size(requestin->list_0,5)
 SET default_display_name = fillstring(10," ")
 FOR (x = 1 TO row_cnt)
   INSERT  FROM br_coll_class b
    SET b.activity_type = requestin->list_0[x].activity_type, b.collection_class = requestin->list_0[
     x].collection_class, b.proposed_name_suffix = requestin->list_0[x].proposed_name_suffix,
     b.facility_id = 0.0, b.display_name = default_display_name, b.storage_tracking_ind = 0,
     b.code_value = 0.0, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

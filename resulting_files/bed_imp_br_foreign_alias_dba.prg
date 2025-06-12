CREATE PROGRAM bed_imp_br_foreign_alias:dba
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
 FOR (x = 1 TO row_cnt)
   INSERT  FROM br_foreign_alias b
    SET b.br_foreign_alias_id = seq(bedrock_seq,nextval), b.facility = requestin->list_0[x].facility,
     b.interface_name = requestin->list_0[x].interface_name,
     b.catalog_type = requestin->list_0[x].catalog_type, b.activity_type = requestin->list_0[x].
     activity_type, b.short_name = requestin->list_0[x].short_name,
     b.long_name = requestin->list_0[x].long_name, b.inbound_alias = requestin->list_0[x].
     inbound_alias, b.outbound_alias = requestin->list_0[x].outbound_alias,
     b.alias_type = requestin->list_0[x].alias_type, b.match_ind = 0, b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

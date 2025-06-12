CREATE PROGRAM bed_imp_br_type_seg_r:dba
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
   INSERT  FROM br_type_seg_r b
    SET b.br_type_seg_r_id = seq(bedrock_seq,nextval), b.interface_type = requestin->list_0[x].
     interface_type, b.inbound_ind =
     IF ((requestin->list_0[x].inbound="X")) 1
     ELSE 0
     ENDIF
     ,
     b.outbound_ind =
     IF ((requestin->list_0[x].outbound="X")) 1
     ELSE 0
     ENDIF
     , b.segment_name = requestin->list_0[x].segment, b.required_ind =
     IF ((requestin->list_0[x].required="X")) 1
     ELSE 0
     ENDIF
     ,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounterf
   ;end insert
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

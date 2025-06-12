CREATE PROGRAM bed_imp_br_seg_field_r:dba
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
   IF ((requestin->list_0[x].inbound="X"))
    SET inbound_ind = 1
   ELSE
    SET inbound_ind = 0
   ENDIF
   IF ((requestin->list_0[x].outbound="X"))
    SET outbound_ind = 1
   ELSE
    SET outbound_ind = 0
   ENDIF
   SET hold_br_type_seg_r_id = 0.0
   SELECT INTO "NL:"
    FROM br_type_seg_r b
    WHERE (b.interface_type=requestin->list_0[x].interface_type)
     AND b.inbound_ind=inbound_ind
     AND b.outbound_ind=outbound_ind
     AND (b.segment_name=requestin->list_0[x].segment)
    DETAIL
     hold_br_type_seg_r_id = b.br_type_seg_r_id
    WITH nocounter
   ;end select
   INSERT  FROM br_seg_field_r b
    SET b.br_seg_field_r_id = seq(bedrock_seq,nextval), b.br_type_seg_r_id = hold_br_type_seg_r_id, b
     .field_name = requestin->list_0[x].field,
     b.codeset = cnvtint(requestin->list_0[x].codeset), b.required_ind =
     IF ((requestin->list_0[x].required="X")) 1
     ELSE 0
     ENDIF
     , b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

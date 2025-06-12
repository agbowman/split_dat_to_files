CREATE PROGRAM bed_get_interface_segments:dba
 FREE SET reply
 RECORD reply(
   1 types[*]
     2 interface_type = vc
     2 in_out_ind = i2
     2 segments[*]
       3 segment = vc
       3 required_ind = i2
       3 code_sets_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SET tcnt = size(request->types,5)
 FOR (t = 1 TO tcnt)
  IF ((request->types[t].in_out_ind IN (1, 3)))
   SET rcnt = (rcnt+ 1)
   SET stat = alterlist(reply->types,rcnt)
   SET reply->types[rcnt].interface_type = request->types[t].interface_type
   SET reply->types[rcnt].in_out_ind = 1
   SET scnt = 0
   SET alterlist_scnt = 0
   SET stat = alterlist(reply->types[rcnt].segments,50)
   SELECT INTO "NL:"
    FROM br_type_seg_r b,
     br_seg_field_r bs
    PLAN (b
     WHERE (b.interface_type=request->types[t].interface_type)
      AND b.inbound_ind=1)
     JOIN (bs
     WHERE bs.br_type_seg_r_id=outerjoin(b.br_type_seg_r_id))
    HEAD b.segment_name
     scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
     IF (alterlist_scnt > 50)
      stat = alterlist(reply->types[rcnt].segments,(scnt+ 50)), alterlist_scnt = 1
     ENDIF
     reply->types[rcnt].segments[scnt].segment = b.segment_name, reply->types[rcnt].segments[scnt].
     required_ind = b.required_ind
    DETAIL
     IF (bs.br_seg_field_r_id > 0)
      reply->types[rcnt].segments[scnt].code_sets_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->types[rcnt].segments,scnt)
  ENDIF
  IF ((request->types[t].in_out_ind IN (2, 3)))
   SET rcnt = (rcnt+ 1)
   SET stat = alterlist(reply->types,rcnt)
   SET reply->types[rcnt].interface_type = request->types[t].interface_type
   SET reply->types[rcnt].in_out_ind = 2
   SET scnt = 0
   SET alterlist_scnt = 0
   SET stat = alterlist(reply->types[rcnt].segments,50)
   SELECT INTO "NL:"
    FROM br_type_seg_r b,
     br_seg_field_r bs
    PLAN (b
     WHERE (b.interface_type=request->types[t].interface_type)
      AND b.outbound_ind=1)
     JOIN (bs
     WHERE bs.br_type_seg_r_id=outerjoin(b.br_type_seg_r_id))
    HEAD b.segment_name
     scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
     IF (alterlist_scnt > 50)
      stat = alterlist(reply->types[rcnt].segments,(scnt+ 50)), alterlist_scnt = 1
     ENDIF
     reply->types[rcnt].segments[scnt].segment = b.segment_name, reply->types[rcnt].segments[scnt].
     required_ind = b.required_ind
    DETAIL
     IF (bs.br_seg_field_r_id > 0)
      reply->types[rcnt].segments[scnt].code_sets_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->types[rcnt].segments,scnt)
  ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO

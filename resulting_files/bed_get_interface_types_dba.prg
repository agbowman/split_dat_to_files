CREATE PROGRAM bed_get_interface_types:dba
 FREE SET reply
 RECORD reply(
   1 types[*]
     2 interface_type = vc
     2 inbound_ind = i2
     2 outbound_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SET alterlist_tcnt = 0
 SET stat = alterlist(reply->types,50)
 SELECT DISTINCT INTO "NL:"
  b.interface_type
  FROM br_type_seg_r b
  PLAN (b
   WHERE b.interface_type > " ")
  DETAIL
   tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
   IF (alterlist_tcnt > 50)
    stat = alterlist(reply->types,(tcnt+ 50)), alterlist_tcnt = 1
   ENDIF
   reply->types[tcnt].interface_type = b.interface_type
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->types,tcnt)
 IF (tcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tcnt),
    br_type_seg_r b
   PLAN (d)
    JOIN (b
    WHERE (b.interface_type=reply->types[d.seq].interface_type))
   DETAIL
    IF (b.inbound_ind=1)
     reply->types[d.seq].inbound_ind = 1
    ELSE
     reply->types[d.seq].outbound_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO

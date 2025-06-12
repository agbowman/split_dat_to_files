CREATE PROGRAM bed_get_br_coll_class:dba
 FREE SET reply
 RECORD reply(
   1 clist[*]
     2 collection_class = c20
     2 proposed_name_suffix = c6
     2 display_name = c10
     2 storage_tracking_ind = i2
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->clist,15)
 SET alterlist_cnt = 0
 SET c = 0
 SELECT INTO "NL:"
  FROM br_coll_class bcc
  WHERE (bcc.activity_type=request->activity_type)
   AND bcc.facility_id=0
  DETAIL
   alterlist_cnt = (alterlist_cnt+ 1)
   IF (alterlist_cnt > 15)
    stat = alterlist(reply->clist,(c+ 15)), alterlist_cnt = 1
   ENDIF
   c = (c+ 1), reply->clist[c].collection_class = bcc.collection_class, reply->clist[c].
   proposed_name_suffix = bcc.proposed_name_suffix,
   reply->clist[c].display_name = bcc.display_name, reply->clist[c].storage_tracking_ind = bcc
   .storage_tracking_ind, reply->clist[c].code_value = bcc.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->clist,c)
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO

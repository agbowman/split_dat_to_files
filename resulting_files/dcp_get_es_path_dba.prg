CREATE PROGRAM dcp_get_es_path:dba
 RECORD reply(
   1 qual[*]
     2 event_set_cd = f8
     2 parent_event_set_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET seg_start = 0
 SET seg_end = 1
 SET children_cnt = 0
 SET parent_cnt = 1
 SET stat = 0
 SET chil_index = 0
 SET stat = alterlist(reply->qual,1)
 SET reply->qual[1].event_set_cd = request->event_set_cd
 SET reply->qual[1].parent_event_set_cd = 0
 WHILE (parent_cnt > 0)
   SELECT INTO "nl:"
    FROM v500_event_set_canon ec,
     (dummyt d  WITH seq = value(parent_cnt))
    PLAN (d)
     JOIN (ec
     WHERE (ec.event_set_cd=reply->qual[(d.seq+ seg_start)].event_set_cd))
    HEAD REPORT
     children_cnt = 0
    DETAIL
     reply->qual[(d.seq+ seg_start)].parent_event_set_cd = ec.parent_event_set_cd, children_cnt = (
     children_cnt+ 1)
     IF (mod(children_cnt,10)=1)
      stat = alterlist(reply->qual,((seg_end+ children_cnt)+ 9))
     ENDIF
     child_index = (seg_end+ children_cnt), reply->qual[child_index].event_set_cd = ec
     .parent_event_set_cd, reply->qual[child_index].parent_event_set_cd = 0
    FOOT REPORT
     stat = alterlist(reply->qual,child_index)
    WITH nocounter
   ;end select
   SET seg_start = seg_end
   SET seg_end = (seg_end+ children_cnt)
   SET parent_cnt = children_cnt
   SET children_cnt = 0
 ENDWHILE
 IF (seg_end=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

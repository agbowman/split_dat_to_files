CREATE PROGRAM dcp_icu_get_spec_event_set:dba
 RECORD reply(
   1 qual[*]
     2 spec_event_set_cd = f8
     2 spec_event_set_disp = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp_rec(
   1 children[*]
     2 event_set_cd = f8
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET x = 0
 SELECT INTO "nl:"
  esc.event_set_cd, esc.event_set_cd_disp
  FROM v500_event_set_code es,
   v500_event_set_canon esc
  WHERE es.event_set_name_key="ALLSPECIALTYSECTIONS"
   AND esc.parent_event_set_cd=es.event_set_cd
  DETAIL
   count1 = (count1+ 1), stat = alterlist(temp_rec->children,count1), temp_rec->children[count1].
   event_set_cd = esc.event_set_cd
  WITH nocounter
 ;end select
 SET event_cnt = 0
 SELECT INTO "nl:"
  escd.event_set_cd_disp
  FROM v500_event_set_code escd,
   (dummyt d  WITH seq = value(size(temp_rec->children,5)))
  PLAN (d)
   JOIN (escd
   WHERE (escd.event_set_cd=temp_rec->children[d.seq].event_set_cd))
  DETAIL
   event_cnt = (event_cnt+ 1), stat = alterlist(reply->qual,event_cnt), reply->qual[event_cnt].
   spec_event_set_cd = escd.event_set_cd,
   reply->qual[event_cnt].spec_event_set_disp = escd.event_set_cd_disp
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

CREATE PROGRAM dcp_get_event_codes_in_set:dba
 RECORD reply(
   1 event_set_list[*]
     2 event_set_name = c40
     2 event_set_cd = f8
     2 event_set_cd_disp = c40
     2 event_cd_list[*]
       3 event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE req_cnt = i4 WITH constant(size(request->event_set_list,5))
 DECLARE code_cnt = i4 WITH noconstant(0)
 SET stat = alterlist(reply->event_set_list,req_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   v500_event_set_explode ese,
   v500_event_set_code esc
  PLAN (d)
   JOIN (esc
   WHERE (esc.event_set_name=request->event_set_list[d.seq].event_set_name))
   JOIN (ese
   WHERE ese.event_set_cd=esc.event_set_cd
    AND ese.event_cd > 0)
  ORDER BY d.seq
  HEAD d.seq
   code_cnt = 0, reply->event_set_list[d.seq].event_set_name = request->event_set_list[d.seq].
   event_set_name, reply->event_set_list[d.seq].event_set_cd = esc.event_set_cd
  DETAIL
   code_cnt = (code_cnt+ 1)
   IF (mod(code_cnt,50)=1)
    stat = alterlist(reply->event_set_list[d.seq].event_cd_list,(code_cnt+ 99))
   ENDIF
   reply->event_set_list[d.seq].event_cd_list[code_cnt].event_cd = ese.event_cd
  FOOT  d.seq
   stat = alterlist(reply->event_set_list[d.seq].event_cd_list,code_cnt)
  WITH nocounter
 ;end select
 IF (req_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

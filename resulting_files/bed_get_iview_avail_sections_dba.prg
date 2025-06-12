CREATE PROGRAM bed_get_iview_avail_sections:dba
 FREE SET reply
 RECORD reply(
   1 sections[*]
     2 code_value = f8
     2 display_name = vc
     2 event_set_name = vc
     2 items[*]
       3 code_value = f8
       3 event_set_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 SET icnt = 0
 SELECT INTO "nl:"
  FROM v500_event_set_code v1,
   v500_event_set_canon c1,
   v500_event_set_code v2,
   v500_event_set_canon c2,
   v500_event_set_code v3
  PLAN (v1
   WHERE v1.event_set_name_key="WORKINGVIEWSECTIONS")
   JOIN (c1
   WHERE c1.parent_event_set_cd=v1.event_set_cd)
   JOIN (v2
   WHERE v2.event_set_cd=c1.event_set_cd)
   JOIN (c2
   WHERE c2.parent_event_set_cd=c1.event_set_cd)
   JOIN (v3
   WHERE v3.event_set_cd=c2.event_set_cd)
  ORDER BY c1.event_set_collating_seq, c2.event_set_collating_seq
  HEAD c1.event_set_collating_seq
   icnt = 0, scnt = (scnt+ 1), stat = alterlist(reply->sections,scnt),
   reply->sections[scnt].code_value = c1.event_set_cd, reply->sections[scnt].display_name = v2
   .event_set_cd_disp, reply->sections[scnt].event_set_name = v2.event_set_name
  HEAD c2.event_set_collating_seq
   icnt = (icnt+ 1), stat = alterlist(reply->sections[scnt].items,icnt), reply->sections[scnt].items[
   icnt].code_value = c2.event_set_cd,
   reply->sections[scnt].items[icnt].event_set_name = v3.event_set_name
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO

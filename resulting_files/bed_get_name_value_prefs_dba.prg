CREATE PROGRAM bed_get_name_value_prefs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 parents[*]
      2 parent_entity_id = f8
      2 parent_entity_name = vc
      2 preferences[*]
        3 name_value_prefs_id = f8
        3 pvc_name = vc
        3 pvn_value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->parents,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->parents,req_cnt)
 FOR (x = 1 TO req_cnt)
  SET reply->parents[x].parent_entity_id = request->parents[x].parent_entity_id
  SET reply->parents[x].parent_entity_name = request->parents[x].parent_entity_name
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   name_value_prefs n
  PLAN (d)
   JOIN (n
   WHERE (n.parent_entity_id=reply->parents[d.seq].parent_entity_id)
    AND n.parent_entity_name=cnvtupper(reply->parents[d.seq].parent_entity_name)
    AND n.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   cnt = 0, tcnt = 0, stat = alterlist(reply->parents[d.seq].preferences,100)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->parents[d.seq].preferences,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->parents[d.seq].preferences[tcnt].name_value_prefs_id = n.name_value_prefs_id, reply->
   parents[d.seq].preferences[tcnt].pvc_name = n.pvc_name, reply->parents[d.seq].preferences[tcnt].
   pvn_value = n.pvc_value
  FOOT  d.seq
   stat = alterlist(reply->parents[d.seq].preferences,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

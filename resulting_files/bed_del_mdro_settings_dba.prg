CREATE PROGRAM bed_del_mdro_settings:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD delitems(
   1 cat_events[*]
     2 br_mdro_cat_event_id = f8
   1 cat_organisms[*]
     2 br_mdro_cat_organism_id = f8
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = size(request->facilities,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET evnt_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(request->facilities,5)),
   br_mdro_cat_event e
  PLAN (d)
   JOIN (e
   WHERE (e.location_cd=request->facilities[d.seq].facility_cd))
  DETAIL
   evnt_cnt = (evnt_cnt+ 1), stat = alterlist(delitems->cat_events,evnt_cnt), delitems->cat_events[
   evnt_cnt].br_mdro_cat_event_id = e.br_mdro_cat_event_id
  WITH nocounter
 ;end select
 IF (evnt_cnt > 0)
  DELETE  FROM (dummyt d  WITH seq = evnt_cnt),
    br_cat_event_normalcy cen
   SET cen.seq = 1
   PLAN (d)
    JOIN (cen
    WHERE (cen.br_mdro_cat_event_id=delitems->cat_events[d.seq].br_mdro_cat_event_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error on category normalcies deletion"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM (dummyt d  WITH seq = size(request->facilities,5)),
    br_mdro_cat_event e
   SET e.seq = 1
   PLAN (d)
    JOIN (e
    WHERE (e.location_cd=request->facilities[d.seq].facility_cd))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Error on category event deletion"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET org_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(request->facilities,5)),
   br_mdro_cat_organism o
  PLAN (d)
   JOIN (o
   WHERE (o.location_cd=request->facilities[d.seq].facility_cd))
  DETAIL
   org_cnt = (org_cnt+ 1), stat = alterlist(delitems->cat_organisms,org_cnt), delitems->
   cat_organisms[org_cnt].br_mdro_cat_organism_id = o.br_mdro_cat_organism_id
  WITH nocounter
 ;end select
 IF (org_cnt > 0)
  FOR (ocnt = 1 TO org_cnt)
    DELETE  FROM br_organism_drug_result odr
     WHERE (odr.br_drug_group_organism_id=
     (SELECT
      dgo.br_drug_group_organism_id
      FROM br_drug_group_organism dgo
      WHERE (dgo.br_mdro_cat_organism_id=delitems->cat_organisms[ocnt].br_mdro_cat_organism_id)))
    ;end delete
  ENDFOR
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Error on organism interps deletion"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM (dummyt d  WITH seq = org_cnt),
    br_drug_group_organism dgo
   SET dgo.seq = 1
   PLAN (d)
    JOIN (dgo
    WHERE (dgo.br_mdro_cat_organism_id=delitems->cat_organisms[d.seq].br_mdro_cat_organism_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error on organism drug groups deletion"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM (dummyt d  WITH seq = size(request->facilities,5)),
    br_mdro_cat_organism o
   SET o.seq = 1
   PLAN (d)
    JOIN (o
    WHERE (o.location_cd=request->facilities[d.seq].facility_cd))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Error on category organism deletion"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO

CREATE PROGRAM bed_get_iview_ref_views:dba
 FREE SET reply
 RECORD reply(
   1 views[*]
     2 working_view_id = f8
     2 name = vc
     2 active_ind = i2
     2 multiple_defined = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET vcnt = 0
 SET pos_code_value = 0.0
 SELECT INTO "nl:"
  FROM prefdir_entrydata p1,
   prefdir_entrydata p2,
   prefdir_entrydata p3,
   prefdir_entrydata p4
  PLAN (p1
   WHERE p1.dist_name_short="prefcontext=reference,prefroot=prefroot")
   JOIN (p2
   WHERE p2.parent_id=p1.entry_id)
   JOIN (p3
   WHERE p3.parent_id=p2.entry_id
    AND substring(1,21,p3.dist_name)="prefgroup=docsettypes")
   JOIN (p4
   WHERE p4.parent_id=p3.entry_id)
  HEAD REPORT
   a = 0, b = 0
  DETAIL
   vcnt = (vcnt+ 1), stat = alterlist(reply->views,vcnt), a = findstring(",",p4.dist_name),
   b = (a - 11), reply->views[vcnt].name = substring(11,b,p4.dist_name)
  WITH nocounter
 ;end select
 IF (vcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(vcnt)),
    working_view w
   PLAN (d)
    JOIN (w
    WHERE cnvtupper(w.display_name)=cnvtupper(reply->views[d.seq].name)
     AND w.active_ind=1)
   ORDER BY d.seq, w.version_num DESC
   HEAD d.seq
    reply->views[d.seq].working_view_id = w.working_view_id, reply->views[d.seq].name = w
    .display_name, reply->views[d.seq].active_ind = w.active_ind,
    reply->views[d.seq].multiple_defined = 0, pos_code_value = w.position_cd
   DETAIL
    IF (w.position_cd != pos_code_value)
     reply->views[d.seq].multiple_defined = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(vcnt)),
    working_view w
   PLAN (d
    WHERE (reply->views[d.seq].working_view_id=0))
    JOIN (w
    WHERE cnvtupper(w.display_name)=cnvtupper(reply->views[d.seq].name)
     AND w.active_ind=0)
   ORDER BY d.seq, w.version_num DESC
   HEAD d.seq
    reply->views[d.seq].working_view_id = w.working_view_id, reply->views[d.seq].name = w
    .display_name, reply->views[d.seq].active_ind = w.active_ind
   DETAIL
    IF (w.position_cd != pos_code_value)
     reply->views[d.seq].multiple_defined = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

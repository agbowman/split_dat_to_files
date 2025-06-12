CREATE PROGRAM bed_get_iview_posloc_policy:dba
 FREE SET reply
 RECORD reply(
   1 pos_loc_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET x = 0
 SELECT INTO "nl:"
  FROM prefdir_entrydata p1,
   prefdir_entrydata p2,
   prefdir_entrydata p3
  PLAN (p1
   WHERE p1.dist_name_short="prefgroup=reference,prefcontext=reference,prefroot=prefroot")
   JOIN (p2
   WHERE p2.parent_id=p1.entry_id
    AND substring(1,19,p2.dist_name)="prefgroup=component")
   JOIN (p3
   WHERE p3.parent_id=p2.entry_id
    AND substring(1,36,p3.dist_name)="prefgroup=interactiveviewglobalprefs")
  DETAIL
   x = findstring("position location",p3.entry_data)
  WITH nocounter
 ;end select
 IF (x > 0)
  SET reply->pos_loc_ind = 1
 ENDIF
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO

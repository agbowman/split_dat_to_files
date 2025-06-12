CREATE PROGRAM bed_get_iview_pref_list:dba
 FREE SET reply
 RECORD reply(
   1 preferences[*]
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET a = 0
 DECLARE viewstr = c255 WITH noconstant("")
 DECLARE dnstr = c255 WITH noconstant("")
 SET a = (textlen(request->view_name)+ 10)
 SET viewstr = concat("prefgroup=",trim(cnvtlower(request->view_name)))
 IF ((request->view_name > " "))
  SELECT INTO "nl:"
   FROM prefdir_entrydata p1,
    prefdir_entrydata p2,
    prefdir_entrydata p3,
    prefdir_entrydata p4,
    prefdir_entrydata p5
   PLAN (p1
    WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
    JOIN (p2
    WHERE p2.parent_id=p1.entry_id)
    JOIN (p3
    WHERE p3.parent_id=p2.entry_id
     AND substring(1,23,p3.dist_name)="prefgroup=working views")
    JOIN (p4
    WHERE p4.parent_id=p3.entry_id
     AND substring(1,a,p4.dist_name)=viewstr)
    JOIN (p5
    WHERE p5.parent_id=p4.entry_id)
   HEAD REPORT
    x = 0, y = 0
   DETAIL
    x = findstring(",",p5.dist_name), y = (x - 11), dnstr = substring(11,y,p5.dist_name),
    found = 0
    FOR (z = 1 TO size(reply->preferences,5))
      IF ((dnstr=reply->preferences[z].name))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     cnt = (cnt+ 1), stat = alterlist(reply->preferences,cnt), reply->preferences[cnt].name = dnstr
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM prefdir_entrydata p1,
    prefdir_entrydata p2,
    prefdir_entrydata p3,
    prefdir_entrydata p4,
    prefdir_entrydata p5
   PLAN (p1
    WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
    JOIN (p2
    WHERE p2.parent_id=p1.entry_id)
    JOIN (p3
    WHERE p3.parent_id=p2.entry_id
     AND substring(1,19,p3.dist_name)="prefgroup=component")
    JOIN (p4
    WHERE p4.parent_id=p3.entry_id
     AND ((substring(1,36,p4.dist_name)="prefgroup=interactiveviewglobalprefs") OR (substring(1,23,p4
     .dist_name)="prefgroup=resultdisplay")) )
    JOIN (p5
    WHERE p5.parent_id=p4.entry_id)
   HEAD REPORT
    x = 0, y = 0
   DETAIL
    x = findstring(",",p5.dist_name), y = (x - 11), dnstr = substring(11,y,p5.dist_name),
    found = 0
    FOR (z = 1 TO size(reply->preferences,5))
      IF ((dnstr=reply->preferences[z].name))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     cnt = (cnt+ 1), stat = alterlist(reply->preferences,cnt), reply->preferences[cnt].name = dnstr
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO

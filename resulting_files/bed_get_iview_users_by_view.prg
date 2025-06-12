CREATE PROGRAM bed_get_iview_users_by_view
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 users[*]
      2 person_id = f8
      2 first_name = vc
      2 last_name = vc
      2 position
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 values[*]
        3 setting = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp
 RECORD temp(
   1 users[*]
     2 person_id = f8
     2 first_name = vc
     2 last_name = vc
     2 position
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 values[*]
       3 setting = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET vcnt = 0
 SET rcnt = 0
 DECLARE viewstr = c255 WITH noconstant("")
 DECLARE prefstr = c255 WITH noconstant("")
 SET j = (textlen(request->view_name)+ 10)
 SET viewstr = concat("prefgroup=",trim(cnvtlower(request->view_name)))
 SET k = (textlen(request->preference_name)+ 10)
 SET prefstr = concat("prefentry=",trim(request->preference_name))
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
     AND substring(1,j,p4.dist_name)=viewstr)
    JOIN (p5
    WHERE p5.parent_id=p4.entry_id
     AND substring(1,k,p5.dist_name)=prefstr
     AND substring((k+ 1),1,p5.dist_name) != "_")
   HEAD REPORT
    a = 0, b = 0, c = 0,
    d = 0
   DETAIL
    vcnt = 0, cnt = (cnt+ 1), stat = alterlist(temp->users,cnt),
    a = findstring(",",p2.dist_name), b = (a - 11), temp->users[cnt].person_id = cnvtint(substring(11,
      b,p2.dist_name)),
    loop = 1, x = 1
    WHILE (loop=1)
      c = findstring("prefvalue:",p5.entry_data,x), x = (c+ 10)
      IF (c > 0)
       d = findstring("pref",p5.entry_data,(c+ 5)), vcnt = (vcnt+ 1), stat = alterlist(temp->users[
        cnt].values,vcnt),
       temp->users[cnt].values[vcnt].setting = substring((c+ 10),(d - (c+ 11)),p5.entry_data)
      ELSE
       loop = 0
      ENDIF
    ENDWHILE
   WITH nocounter
  ;end select
 ELSE
  IF ((request->preference_name="documentsettypes"))
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
      AND substring(1,18,p4.dist_name)="prefgroup=powerdoc")
     JOIN (p5
     WHERE p5.parent_id=p4.entry_id
      AND substring(1,k,p5.dist_name)=prefstr
      AND substring((k+ 1),1,p5.dist_name) != "_")
    HEAD REPORT
     a = 0, b = 0, c = 0,
     d = 0
    DETAIL
     vcnt = 0, cnt = (cnt+ 1), stat = alterlist(temp->users,cnt),
     a = findstring(",",p2.dist_name), b = (a - 11), temp->users[cnt].person_id = cnvtint(substring(
       11,b,p2.dist_name)),
     loop = 1, x = 1
     WHILE (loop=1)
       c = findstring("prefvalue:",p5.entry_data,x), x = (c+ 10)
       IF (c > 0)
        d = findstring("pref",p5.entry_data,(c+ 5)), vcnt = (vcnt+ 1), stat = alterlist(temp->users[
         cnt].values,vcnt),
        temp->users[cnt].values[vcnt].setting = substring((c+ 10),(d - (c+ 11)),p5.entry_data)
       ELSE
        loop = 0
       ENDIF
     ENDWHILE
    WITH nocounter
   ;end select
  ELSE
   SET type1 = build('"',prefstr,
    ',prefgroup=interactiveviewglobalprefs,prefgroup=component,prefgroup=*,prefcontext=user,prefroot=prefroot"'
    )
   SET type2 = build('"',prefstr,
    ',prefgroup=resultdisplay,prefgroup=component,prefgroup=*,prefcontext=user,prefroot=prefroot"')
   SET whereclause = build("pe.dist_name_short in (",trim(type1),",",trim(type2),")")
   SELECT INTO "nl:"
    FROM prefdir_entrydata pe
    WHERE parser(whereclause)
    HEAD REPORT
     stat = alterlist(temp->users,100), c = 0, d = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1
      AND cnt > 100)
      stat = alterlist(temp->users,(cnt+ 10))
     ENDIF
     start_pos = (30+ findstring("prefgroup=component,prefgroup=",pe.dist_name_short)), end_pos =
     findstring(",prefcontext=user,prefroot=prefroot",pe.dist_name_short), temp->users[cnt].person_id
      = cnvtint(substring(start_pos,(end_pos - start_pos),pe.dist_name_short)),
     loop = 1, x = 1, stat = alterlist(temp->users[cnt].values,100),
     vcnt = 0
     WHILE (loop=1)
       c = findstring("prefvalue:",pe.entry_data,x), x = (c+ 10)
       IF (c > 0)
        d = findstring("pref",pe.entry_data,(c+ 5)), vcnt = (vcnt+ 1)
        IF (mod(vcnt,10)=1
         AND vcnt > 100)
         stat = alterlist(temp->users[cnt].values,(vcnt+ 10))
        ENDIF
        temp->users[cnt].values[vcnt].setting = substring((c+ 10),(d - (c+ 11)),pe.entry_data)
       ELSE
        loop = 0
       ENDIF
     ENDWHILE
     stat = alterlist(temp->users[cnt].values,vcnt)
    FOOT REPORT
     stat = alterlist(temp->users,cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET idx = 0
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE expand(idx,1,size(temp->users,5),p.person_id,temp->users[idx].person_id)
    AND p.active_ind=1)
  ORDER BY p.person_id
  HEAD REPORT
   stat = alterlist(reply->users,100), rcnt = 0, indx = 1
  HEAD p.person_id
   rcnt = (rcnt+ 1)
   IF (mod(rcnt,10)=1
    AND rcnt > 100)
    stat = alterlist(reply->users,(rcnt+ 10))
   ENDIF
   reply->users[rcnt].person_id = p.person_id, reply->users[rcnt].first_name = p.name_first, reply->
   users[rcnt].last_name = p.name_last,
   reply->users[rcnt].position.code_value = p.position_cd, reply->users[rcnt].position.display =
   uar_get_code_display(p.position_cd), reply->users[rcnt].position.mean = uar_get_code_meaning(p
    .position_cd),
   pos = locateval(indx,1,size(temp->users,5),p.person_id,temp->users[indx].person_id), vcnt = size(
    temp->users[pos].values,5), stat = alterlist(reply->users[rcnt].values,vcnt)
   FOR (x = 1 TO vcnt)
     reply->users[rcnt].values[x].setting = temp->users[pos].values[x].setting
   ENDFOR
  FOOT REPORT
   stat = alterlist(reply->users,rcnt)
  WITH nocounter, expand = 1
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

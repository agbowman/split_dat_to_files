CREATE PROGRAM bed_get_iview_pos_pref:dba
 FREE SET reply
 RECORD reply(
   1 preferences[*]
     2 position
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 location
       3 code_value = f8
       3 display = vc
       3 mean = vc
       3 description = vc
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
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET vcnt = 0
 SET a = 0
 SET b = 0
 SET c = 0
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE cxtstr = c255 WITH noconstant("")
 DECLARE viewstr = c255 WITH noconstant("")
 DECLARE prefstr = c255 WITH noconstant("")
 DECLARE posstr = c255 WITH noconstant("")
 DECLARE pos = vc
 SET pos_cd = 0
 SET loc_cd = 0
 SET a = (textlen(request->view_name)+ 10)
 SET viewstr = concat("prefgroup=",trim(cnvtlower(request->view_name)))
 SET pos = trim(cnvtstring(request->position_code_value,20,2))
 SET b = (textlen(pos)+ 10)
 SET posstr = concat("prefgroup=",trim(pos))
 CALL echo(posstr)
 SET c = (textlen(request->preference_name)+ 10)
 SET prefstr = concat("prefentry=",trim(request->preference_name))
 IF ((request->view_name > " "))
  SELECT INTO "nl:"
   FROM prefdir_entrydata p1,
    prefdir_entrydata p2,
    prefdir_entrydata p3,
    prefdir_entrydata p4,
    prefdir_entrydata p5
   PLAN (p1
    WHERE p1.dist_name_short IN ("prefcontext=position,prefroot=prefroot",
    "prefcontext=position location,prefroot=prefroot"))
    JOIN (p2
    WHERE p2.parent_id=p1.entry_id
     AND substring(1,b,p2.dist_name)=posstr)
    JOIN (p3
    WHERE p3.parent_id=p2.entry_id
     AND substring(1,23,p3.dist_name)="prefgroup=working views")
    JOIN (p4
    WHERE p4.parent_id=p3.entry_id
     AND substring(1,a,p4.dist_name)=viewstr)
    JOIN (p5
    WHERE p5.parent_id=p4.entry_id
     AND substring(1,c,p5.dist_name)=prefstr
     AND substring((c+ 1),1,p5.dist_name) != "_")
   HEAD REPORT
    y = 0, z = 0, d = 0,
    e = 0
   DETAIL
    d = findstring("prefcontext=",p2.dist_name), e = findstring(",",p2.dist_name,(d+ 1)), cxtstr =
    substring((d+ 12),(e - (d+ 12)),p2.dist_name),
    d = findstring("prefgroup=",p2.dist_name), e = findstring(",",p2.dist_name,(d+ 1)), grpstr =
    substring((d+ 10),(e - (d+ 10)),p2.dist_name),
    vcnt = 0, cnt = (cnt+ 1), stat = alterlist(reply->preferences,cnt),
    loop = 1, x = 1
    WHILE (loop=1)
      y = findstring("prefvalue:",p5.entry_data,x), x = (y+ 10)
      IF (y > 0)
       z = findstring("pref",p5.entry_data,(y+ 5)), vcnt = (vcnt+ 1), stat = alterlist(reply->
        preferences[cnt].values,vcnt),
       reply->preferences[cnt].values[vcnt].setting = substring((y+ 10),(z - (y+ 11)),p5.entry_data)
      ELSE
       loop = 0
      ENDIF
    ENDWHILE
    IF (cxtstr="position")
     reply->preferences[cnt].position.code_value = cnvtreal(trim(grpstr))
    ENDIF
    IF (cxtstr="position location")
     d = findstring("^",grpstr), reply->preferences[cnt].position.code_value = cnvtreal(substring(1,(
       d - 1),grpstr)), e = textlen(grpstr),
     reply->preferences[cnt].location.code_value = cnvtreal(substring((d+ 1),((e - d) - 1),grpstr))
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
    WHERE p1.dist_name_short IN ("prefcontext=position,prefroot=prefroot",
    "prefcontext=position location,prefroot=prefroot"))
    JOIN (p2
    WHERE p2.parent_id=p1.entry_id
     AND substring(1,b,p2.dist_name)=posstr)
    JOIN (p3
    WHERE p3.parent_id=p2.entry_id
     AND substring(1,19,p3.dist_name)="prefgroup=component")
    JOIN (p4
    WHERE p4.parent_id=p3.entry_id
     AND ((substring(1,36,p4.dist_name)="prefgroup=interactiveviewglobalprefs") OR (substring(1,23,p4
     .dist_name)="prefgroup=resultdisplay")) )
    JOIN (p5
    WHERE p5.parent_id=p4.entry_id
     AND substring(1,c,p5.dist_name)=prefstr
     AND substring((c+ 1),1,p5.dist_name) != "_")
   HEAD REPORT
    y = 0, z = 0, d = 0,
    e = 0
   DETAIL
    d = findstring("prefcontext=",p2.dist_name), e = findstring(",",p2.dist_name,(d+ 1)), cxtstr =
    substring((d+ 12),(e - (d+ 12)),p2.dist_name),
    d = findstring("prefgroup=",p2.dist_name), e = findstring(",",p2.dist_name,(d+ 1)), grpstr =
    substring((d+ 10),(e - (d+ 10)),p2.dist_name),
    vcnt = 0, cnt = (cnt+ 1), stat = alterlist(reply->preferences,cnt),
    loop = 1, x = 1
    WHILE (loop=1)
      y = findstring("prefvalue:",p5.entry_data,x), x = (y+ 10)
      IF (y > 0)
       z = findstring("pref",p5.entry_data,(y+ 5)), vcnt = (vcnt+ 1), stat = alterlist(reply->
        preferences[cnt].values,vcnt),
       reply->preferences[cnt].values[vcnt].setting = substring((y+ 10),(z - (y+ 11)),p5.entry_data)
      ELSE
       loop = 0
      ENDIF
    ENDWHILE
    IF (cxtstr="position")
     reply->preferences[cnt].position.code_value = cnvtreal(trim(grpstr))
    ENDIF
    IF (cxtstr="position location")
     d = findstring("^",grpstr), reply->preferences[cnt].position.code_value = cnvtreal(substring(1,(
       d - 1),grpstr)), e = textlen(grpstr),
     reply->preferences[cnt].location.code_value = cnvtreal(substring((d+ 1),((e - d) - 1),grpstr))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=reply->preferences[d.seq].position.code_value))
   ORDER BY d.seq
   HEAD d.seq
    reply->preferences[d.seq].position.display = c.display, reply->preferences[d.seq].position.mean
     = c.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=reply->preferences[d.seq].location.code_value))
   ORDER BY d.seq
   HEAD d.seq
    reply->preferences[d.seq].location.display = c.display, reply->preferences[d.seq].location.mean
     = c.cdf_meaning, reply->preferences[d.seq].location.description = c.description
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

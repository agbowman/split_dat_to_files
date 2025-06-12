CREATE PROGRAM bed_get_iview_user_prefs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 users[*]
      2 person_id = f8
      2 first_name = vc
      2 last_name = vc
      2 position
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 views[*]
        3 id = f8
        3 name = vc
        3 preferences[*]
          4 name = vc
          4 values[*]
            5 setting = vc
      2 global_preferences[*]
        3 name = vc
        3 values[*]
          4 setting = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE prsnl_string = vc WITH protect
 DECLARE userstr = vc WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE auth_cd = i4 WITH protect
 DECLARE a = i4 WITH protect
 DECLARE rcnt = i4 WITH protect
 DECLARE vcnt = i4 WITH protect
 DECLARE scnt = i4 WITH protect
 DECLARE pcnt = i4 WITH protect
 SET auth_cd = 0
 SET cnt = 0
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET prsnl_string = "p.active_ind = 1"
 IF ((request->last_name > " "))
  SET prsnl_string = concat(prsnl_string," and p.name_last_key = '",nullterm(cnvtalphanum(cnvtupper(
      trim(request->last_name)))),"*'")
 ENDIF
 IF ((request->first_name > " "))
  SET prsnl_string = concat(prsnl_string," and p.name_first_key = '",nullterm(cnvtalphanum(cnvtupper(
      trim(request->first_name)))),"*'")
 ENDIF
 RECORD temp(
   1 qual[*]
     2 id = vc
     2 first_name = vc
     2 last_name = vc
     2 position_cd = f8
     2 position_disp = vc
     2 position_mean = vc
     2 views[*]
       3 id = f8
       3 name = vc
       3 preferences[*]
         4 name = vc
         4 values[*]
           5 setting = vc
     2 global_preferences[*]
       3 name = vc
       3 values[*]
         4 setting = vc
     2 documentsettypes_pref_values[*]
       3 setting = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE parser(prsnl_string))
  ORDER BY p.name_full_formatted, p.person_id
  HEAD p.person_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].id = cnvtstring(p.person_id,20,2
    ),
   temp->qual[cnt].first_name = p.name_first, temp->qual[cnt].last_name = p.name_last, temp->qual[cnt
   ].position_cd = p.position_cd,
   temp->qual[cnt].position_disp = uar_get_code_display(p.position_cd), temp->qual[cnt].position_mean
    = uar_get_code_meaning(p.position_cd)
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 SET rcnt = 0
 FOR (x = 1 TO cnt)
   SET a = textlen(temp->qual[x].id)
   SET userstr = concat("prefgroup=",trim(temp->qual[x].id))
   SET vcnt = 0
   SET pcnt = 0
   SET scnt = 0
   SELECT INTO "nl:"
    FROM prefdir_entrydata p1,
     prefdir_entrydata p2,
     prefdir_entrydata p3,
     prefdir_entrydata p4,
     prefdir_entrydata p5
    PLAN (p1
     WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
     JOIN (p2
     WHERE p2.parent_id=p1.entry_id
      AND substring(1,(a+ 10),p2.dist_name)=userstr)
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id
      AND substring(1,23,p3.dist_name)="prefgroup=working views")
     JOIN (p4
     WHERE p4.parent_id=p3.entry_id)
     JOIN (p5
     WHERE p5.parent_id=p4.entry_id)
    ORDER BY p4.entry_id, p5.entry_id
    HEAD REPORT
     c = 0, b = 0, y = 0,
     z = 0
    HEAD p4.entry_id
     y = findstring(",",p4.dist_name), pcnt = 0, scnt = 0,
     vcnt = (vcnt+ 1), stat = alterlist(temp->qual[x].views,vcnt), temp->qual[x].views[vcnt].name =
     substring(11,(y - 11),p4.dist_name)
    HEAD p5.entry_id
     y = findstring(",",p5.dist_name), scnt = 0, pcnt = (pcnt+ 1),
     stat = alterlist(temp->qual[x].views[vcnt].preferences,pcnt), temp->qual[x].views[vcnt].
     preferences[pcnt].name = substring(11,(y - 11),p5.dist_name), loop = 1,
     z = 1
     WHILE (loop=1)
       c = findstring("prefvalue:",p5.entry_data,z), z = (c+ 10)
       IF (c > 0)
        b = findstring("pref",p5.entry_data,(c+ 5)), scnt = (scnt+ 1), stat = alterlist(temp->qual[x]
         .views[vcnt].preferences[pcnt].values,scnt),
        temp->qual[x].views[vcnt].preferences[pcnt].values[scnt].setting = substring((c+ 10),(b - (c
         + 11)),p5.entry_data)
       ELSE
        loop = 0
       ENDIF
     ENDWHILE
    WITH nocounter
   ;end select
   SET pcnt = 0
   SET scnt = 0
   SELECT INTO "nl:"
    FROM prefdir_entrydata p1,
     prefdir_entrydata p2,
     prefdir_entrydata p3,
     prefdir_entrydata p4,
     prefdir_entrydata p5
    PLAN (p1
     WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
     JOIN (p2
     WHERE p2.parent_id=p1.entry_id
      AND substring(1,(a+ 10),p2.dist_name)=userstr)
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id
      AND substring(1,19,p3.dist_name)="prefgroup=component")
     JOIN (p4
     WHERE p4.parent_id=p3.entry_id
      AND ((substring(1,36,p4.dist_name)="prefgroup=interactiveviewglobalprefs") OR (substring(1,23,
      p4.dist_name)="prefgroup=resultdisplay")) )
     JOIN (p5
     WHERE p5.parent_id=p4.entry_id)
    ORDER BY p5.entry_id
    HEAD REPORT
     c = 0, b = 0, y = 0,
     z = 0
    HEAD p5.entry_id
     y = findstring(",",p5.dist_name), scnt = 0, pcnt = (pcnt+ 1),
     stat = alterlist(temp->qual[x].global_preferences,pcnt), temp->qual[x].global_preferences[pcnt].
     name = substring(11,(y - 11),p5.dist_name), loop = 1,
     z = 1
     WHILE (loop=1)
       c = findstring("prefvalue:",p5.entry_data,z), z = (c+ 10)
       IF (c > 0)
        b = findstring("pref",p5.entry_data,(c+ 5)), scnt = (scnt+ 1), stat = alterlist(temp->qual[x]
         .global_preferences[pcnt].values,scnt),
        temp->qual[x].global_preferences[pcnt].values[scnt].setting = substring((c+ 10),(b - (c+ 11)),
         p5.entry_data)
       ELSE
        loop = 0
       ENDIF
     ENDWHILE
    WITH nocounter
   ;end select
   SET a = textlen(temp->qual[x].id)
   SET userstr = concat("prefgroup=",trim(temp->qual[x].id))
   SET vcnt = 0
   SET pcnt = 0
   SET scnt = 0
   SELECT INTO "nl:"
    FROM prefdir_entrydata p1,
     prefdir_entrydata p2,
     prefdir_entrydata p3,
     prefdir_entrydata p,
     prefdir_entrydata p4
    PLAN (p1
     WHERE p1.dist_name_short="prefcontext=user,prefroot=prefroot")
     JOIN (p2
     WHERE p2.parent_id=p1.entry_id
      AND substring(1,(a+ 10),p2.dist_name)=userstr)
     JOIN (p3
     WHERE p3.parent_id=p2.entry_id
      AND substring(1,19,p3.dist_name)="prefgroup=component")
     JOIN (p
     WHERE p.parent_id=p3.entry_id
      AND substring(1,18,p.dist_name)="prefgroup=powerdoc")
     JOIN (p4
     WHERE p4.parent_id=p.entry_id
      AND substring(1,26,p4.dist_name)="prefentry=documentsettypes")
    HEAD REPORT
     a = 0, b = 0, c = 0,
     d = 0
    DETAIL
     vcnt = 0, loop = 1, q = 1
     WHILE (loop=1)
       c = findstring("prefvalue:",p4.entry_data,q), q = (c+ 10)
       IF (c > 0)
        d = findstring("pref",p4.entry_data,(c+ 5)), vcnt = (vcnt+ 1), stat = alterlist(temp->qual[x]
         .documentsettypes_pref_values,vcnt),
        temp->qual[x].documentsettypes_pref_values[vcnt].setting = substring((c+ 10),(d - (c+ 11)),p4
         .entry_data)
       ELSE
        loop = 0
       ENDIF
     ENDWHILE
    WITH nocounter
   ;end select
   IF (((size(temp->qual[x].views,5) > 0) OR (((size(temp->qual[x].global_preferences,5) > 0) OR (
   size(temp->qual[x].documentsettypes_pref_values,5) > 0)) )) )
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->users,rcnt)
    SET reply->users[rcnt].person_id = cnvtreal(temp->qual[x].id)
    SET reply->users[rcnt].first_name = temp->qual[x].first_name
    SET reply->users[rcnt].last_name = temp->qual[x].last_name
    SET reply->users[rcnt].position.code_value = temp->qual[x].position_cd
    SET reply->users[rcnt].position.display = temp->qual[x].position_disp
    SET reply->users[rcnt].position.mean = temp->qual[x].position_mean
    SET vcnt = size(temp->qual[x].views,5)
    SET stat = alterlist(reply->users[rcnt].views,vcnt)
    FOR (h = 1 TO vcnt)
      SET reply->users[rcnt].views[h].name = temp->qual[x].views[h].name
      SET pcnt = size(temp->qual[x].views[h].preferences,5)
      SET stat = alterlist(reply->users[rcnt].views[h].preferences,pcnt)
      FOR (i = 1 TO pcnt)
        SET reply->users[rcnt].views[h].preferences[i].name = temp->qual[x].views[h].preferences[i].
        name
        SET scnt = size(temp->qual[x].views[h].preferences[i].values,5)
        SET stat = alterlist(reply->users[rcnt].views[h].preferences[i].values,scnt)
        FOR (j = 1 TO scnt)
          SET reply->users[rcnt].views[h].preferences[i].values[j].setting = temp->qual[x].views[h].
          preferences[i].values[j].setting
        ENDFOR
      ENDFOR
    ENDFOR
    IF (vcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(vcnt)),
       working_view w
      PLAN (d)
       JOIN (w
       WHERE cnvtupper(w.display_name)=cnvtupper(reply->users[rcnt].views[d.seq].name)
        AND w.active_ind=1)
      ORDER BY d.seq
      HEAD d.seq
       reply->users[rcnt].views[d.seq].id = w.working_view_id, reply->users[rcnt].views[d.seq].name
        = w.display_name
      WITH nocounter
     ;end select
    ENDIF
    SET pcnt = size(temp->qual[x].global_preferences,5)
    SET stat = alterlist(reply->users[rcnt].global_preferences,pcnt)
    FOR (i = 1 TO pcnt)
      SET reply->users[rcnt].global_preferences[i].name = temp->qual[x].global_preferences[i].name
      SET scnt = size(temp->qual[x].global_preferences[i].values,5)
      SET stat = alterlist(reply->users[rcnt].global_preferences[i].values,scnt)
      FOR (j = 1 TO scnt)
        SET reply->users[rcnt].global_preferences[i].values[j].setting = temp->qual[x].
        global_preferences[i].values[j].setting
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO

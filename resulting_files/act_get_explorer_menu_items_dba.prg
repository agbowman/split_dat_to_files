CREATE PROGRAM act_get_explorer_menu_items:dba
 RECORD reply(
   1 qual[*]
     2 menu_id = f8
     2 menu_parent_id = f8
     2 person_id = f8
     2 item_name = vc
     2 item_desc = vc
     2 item_type = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pre_reply(
   1 qual[*]
     2 menu_id = f8
     2 menu_parent_id = f8
     2 person_id = f8
     2 item_name = vc
     2 item_desc = vc
     2 item_type = c1
 )
 SET userisdba = "N"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM prsnl p,
   application_group ag,
   code_value cv
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (ag
   WHERE ag.position_cd=p.position_cd)
   JOIN (cv
   WHERE cv.code_value=ag.app_group_cd
    AND cv.display_key="DBA")
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET userisdba = "Y"
 ENDIF
 IF (userisdba="Y")
  CALL echo('"user is dba"')
  SELECT
   IF ((request->view_type=0))
    FROM explorer_menu e
    PLAN (e
     WHERE e.item_type IN ("M", "P")
      AND e.active_ind=1)
   ELSEIF ((request->view_type=1))
    FROM explorer_menu e
    PLAN (e
     WHERE (e.person_id=request->person_id)
      AND e.item_type IN ("N", "R")
      AND e.active_ind=1)
   ELSE
   ENDIF
   INTO "nl:"
   ORDER BY e.menu_id
   HEAD e.menu_id
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].menu_id = e.menu_id,
    reply->qual[cnt].menu_parent_id = e.menu_parent_id, reply->qual[cnt].person_id = e.person_id,
    reply->qual[cnt].item_name = e.item_name,
    reply->qual[cnt].item_desc = e.item_desc, reply->qual[cnt].item_type = e.item_type
   WITH nocounter
  ;end select
 ELSE
  IF ((request->view_type=0))
   SELECT INTO "nl:"
    FROM prsnl p,
     application_group a,
     explorer_menu_security es,
     explorer_menu e
    PLAN (p
     WHERE (p.person_id=request->person_id))
     JOIN (a
     WHERE a.position_cd=p.position_cd)
     JOIN (es
     WHERE es.app_group_cd=a.app_group_cd)
     JOIN (e
     WHERE e.menu_id=es.menu_id
      AND e.active_ind=1
      AND e.item_type IN ("M", "P"))
    ORDER BY e.menu_id
    HEAD e.menu_id
     cnt = (cnt+ 1), stat = alterlist(pre_reply->qual,cnt), pre_reply->qual[cnt].menu_id = e.menu_id,
     pre_reply->qual[cnt].menu_parent_id = e.menu_parent_id, pre_reply->qual[cnt].person_id = e
     .person_id, pre_reply->qual[cnt].item_name = e.item_name,
     pre_reply->qual[cnt].item_desc = e.item_desc, pre_reply->qual[cnt].item_type = e.item_type
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM explorer_menu e
    PLAN (e
     WHERE e.item_type IN ("M", "P")
      AND e.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      es.menu_id
      FROM explorer_menu_security es
      WHERE es.menu_id=e.menu_id))))
    ORDER BY e.menu_id
    HEAD e.menu_id
     cnt = (cnt+ 1), stat = alterlist(pre_reply->qual,cnt), pre_reply->qual[cnt].menu_id = e.menu_id,
     pre_reply->qual[cnt].menu_parent_id = e.menu_parent_id, pre_reply->qual[cnt].person_id = e
     .person_id, pre_reply->qual[cnt].item_name = e.item_name,
     pre_reply->qual[cnt].item_desc = e.item_desc, pre_reply->qual[cnt].item_type = e.item_type
    WITH nocounter
   ;end select
  ELSEIF ((request->view_type=1))
   SELECT INTO "nl:"
    FROM explorer_menu e
    PLAN (e
     WHERE (e.person_id=request->person_id)
      AND e.item_type IN ("N", "R")
      AND e.active_ind=1)
    ORDER BY e.menu_id
    HEAD e.menu_id
     cnt = (cnt+ 1), stat = alterlist(pre_reply->qual,cnt), pre_reply->qual[cnt].menu_id = e.menu_id,
     pre_reply->qual[cnt].menu_parent_id = e.menu_parent_id, pre_reply->qual[cnt].person_id = e
     .person_id, pre_reply->qual[cnt].item_name = e.item_name,
     pre_reply->qual[cnt].item_desc = e.item_desc, pre_reply->qual[cnt].item_type = e.item_type
    WITH nocounter
   ;end select
  ENDIF
  CALL echo("pre_reply structure")
  SELECT INTO "nl:"
   menu_id = pre_reply->qual[d.seq].menu_id
   FROM (dummyt d  WITH seq = value(cnt))
   ORDER BY menu_id
   HEAD REPORT
    cnt2 = 0
   DETAIL
    cnt2 = (cnt2+ 1), stat = alterlist(reply->qual,cnt2), reply->qual[cnt2].menu_id = menu_id,
    reply->qual[cnt2].menu_parent_id = pre_reply->qual[d.seq].menu_parent_id, reply->qual[cnt2].
    person_id = pre_reply->qual[d.seq].person_id, reply->qual[cnt2].item_name = pre_reply->qual[d.seq
    ].item_name,
    reply->qual[cnt2].item_desc = pre_reply->qual[d.seq].item_desc, reply->qual[cnt2].item_type =
    pre_reply->qual[d.seq].item_type
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

CREATE PROGRAM ccl_menu_get_items:dba
 RECORD reply(
   1 qual[*]
     2 menu_id = f8
     2 menu_parent_id = f8
     2 item_name = c30
     2 item_desc = c40
     2 item_type = c1
     2 ccl_group = i4
     2 report_service_cd = f8
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
     2 item_name = c30
     2 item_desc = c40
     2 item_type = c1
     2 ccl_group = i4
     2 report_service_cd = f8
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cnt = 0
 SET cntseq = 0
 SET errmsg = fillstring(255," ")
 SET hadsecure = "N"
 SET userisdba = "N"
 IF ((request->menu_parent_id_f8=0))
  SET request->menu_parent_id_f8 = request->menu_parent_id
 ENDIF
 IF ((request->person_id_f8=0))
  SET request->person_id_f8 = request->person_id
 ENDIF
 SET usr_position_cd = reqinfo->position_cd
 CALL echo(concat("request->person_id_f8: ",build(request->person_id_f8)))
 CALL echo(concat("usr_position_cd: ",build(uar_get_code_display(usr_position_cd))))
 IF ((reqinfo->updt_id != request->person_id_f8))
  SELECT
   p.position_cd
   FROM prsnl p
   WHERE (p.person_id=request->person_id_f8)
   DETAIL
    usr_position_cd = p.position_cd
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "NL:"
  cv.display_key
  FROM application_group ag,
   code_value cv
  PLAN (ag
   WHERE ag.position_cd=usr_position_cd)
   JOIN (cv
   WHERE ag.app_group_cd=cv.code_value
    AND cv.display_key="DBA")
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET userisdba = "Y"
 ENDIF
 CALL echo(concat("userisdba = ",userisdba))
 IF (userisdba="Y")
  SELECT
   IF ((request->root="u"))
    WHERE (e.menu_parent_id=request->menu_parent_id_f8)
     AND (e.person_id=request->person_id_f8)
     AND e.active_ind=1
     AND e.item_type IN ("N", "R")
   ELSE
   ENDIF
   DISTINCT INTO "nl:"
   e.item_name, e.item_desc, e.item_type,
   e.menu_id
   FROM explorer_menu e
   WHERE (e.menu_parent_id=request->menu_parent_id_f8)
    AND e.active_ind=1
    AND e.item_type IN ("M", "P")
   ORDER BY e.item_desc
   HEAD REPORT
    stat = alterlist(reply->qual,10)
   DETAIL
    cnt += 1
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alterlist(reply->qual,(cnt+ 10))
    ENDIF
    reply->qual[cnt].item_name = e.item_name, reply->qual[cnt].item_desc = e.item_desc, reply->qual[
    cnt].item_type = e.item_type,
    reply->qual[cnt].menu_id = e.menu_id, reply->qual[cnt].menu_parent_id = e.menu_parent_id, reply->
    qual[cnt].ccl_group = e.ccl_group,
    reply->qual[cnt].report_service_cd = e.report_service_cd
   FOOT REPORT
    stat = alterlist(reply->qual,cnt), row + 0
   WITH nocounter
  ;end select
 ELSE
  DECLARE strsortstring = vc WITH protect
  IF ((request->root != "u"))
   SELECT DISTINCT INTO "nl:"
    e.item_name, e.item_desc, e.item_type,
    e.menu_id
    FROM prsnl p,
     application_group a,
     explorer_menu_security es,
     explorer_menu e
    PLAN (p
     WHERE (p.person_id=request->person_id_f8))
     JOIN (a
     WHERE a.position_cd=usr_position_cd)
     JOIN (es
     WHERE a.app_group_cd=es.app_group_cd)
     JOIN (e
     WHERE es.menu_id=e.menu_id
      AND (e.menu_parent_id=request->menu_parent_id_f8)
      AND e.active_ind=1
      AND e.item_type IN ("M", "P"))
    ORDER BY e.item_desc
    HEAD REPORT
     stat = alterlist(pre_reply->qual,10)
    DETAIL
     cnt += 1
     IF (mod(cnt,10)=1
      AND cnt != 1)
      stat = alterlist(pre_reply->qual,(cnt+ 10))
     ENDIF
     pre_reply->qual[cnt].item_name = e.item_name, pre_reply->qual[cnt].item_desc = e.item_desc,
     pre_reply->qual[cnt].item_type = e.item_type,
     pre_reply->qual[cnt].menu_id = e.menu_id, pre_reply->qual[cnt].menu_parent_id = e.menu_parent_id,
     pre_reply->qual[cnt].ccl_group = e.ccl_group,
     pre_reply->qual[cnt].report_service_cd = e.report_service_cd
    FOOT REPORT
     row + 0
     IF (curqual > 0)
      hadsecure = "Y"
     ENDIF
     cntseq = cnt
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    e.item_name, e.item_desc, e.item_type,
    e.menu_id, strsortstring = concat(trim(e.item_desc),trim(cnvtstring(e.menu_id)))
    FROM explorer_menu e,
     explorer_menu_security es,
     (dummyt d  WITH seq = 1)
    PLAN (e
     WHERE (e.menu_parent_id=request->menu_parent_id_f8)
      AND e.active_ind=1
      AND e.item_type IN ("M", "P"))
     JOIN (d)
     JOIN (es
     WHERE e.menu_id=es.menu_id)
    ORDER BY strsortstring
    HEAD REPORT
     IF (hadsecure="N")
      stat = alterlist(pre_reply->qual,(cnt+ 10))
     ENDIF
    DETAIL
     cnt += 1
     IF (mod(cnt,10)=1
      AND cnt != 1)
      stat = alterlist(pre_reply->qual,(cnt+ 10))
     ENDIF
     pre_reply->qual[cnt].item_name = e.item_name, pre_reply->qual[cnt].item_desc = e.item_desc,
     pre_reply->qual[cnt].item_type = e.item_type,
     pre_reply->qual[cnt].menu_id = e.menu_id, pre_reply->qual[cnt].menu_parent_id = e.menu_parent_id,
     pre_reply->qual[cnt].ccl_group = e.ccl_group,
     pre_reply->qual[cnt].report_service_cd = e.report_service_cd
    FOOT REPORT
     stat = alterlist(pre_reply->qual,cnt), cntseq = cnt
    WITH nocounter, outerjoin = d, dontexist
   ;end select
   SET stat = alterlist(pre_reply->qual,cntseq)
  ELSE
   SELECT DISTINCT INTO "nl:"
    e.item_name, e.item_desc, e.item_type,
    e.menu_id
    FROM explorer_menu e
    WHERE (e.menu_parent_id=request->menu_parent_id_f8)
     AND e.active_ind=1
     AND e.item_type IN ("N", "R")
     AND (e.person_id=request->person_id_f8)
    ORDER BY e.item_desc
    HEAD REPORT
     IF (hadsecure="N")
      stat = alterlist(pre_reply->qual,(cnt+ 10))
     ENDIF
    DETAIL
     cnt += 1
     IF (mod(cnt,10)=1
      AND cnt != 1)
      stat = alterlist(pre_reply->qual,(cnt+ 10))
     ENDIF
     pre_reply->qual[cnt].item_name = e.item_name, pre_reply->qual[cnt].item_desc = e.item_desc,
     pre_reply->qual[cnt].item_type = e.item_type,
     pre_reply->qual[cnt].menu_id = e.menu_id, pre_reply->qual[cnt].menu_parent_id = e.menu_parent_id,
     pre_reply->qual[cnt].ccl_group = e.ccl_group,
     pre_reply->qual[cnt].report_service_cd = e.report_service_cd
    FOOT REPORT
     stat = alterlist(pre_reply->qual,cnt), cntseq = cnt
   ;end select
  ENDIF
  CALL echorecord(pre_reply)
  SELECT INTO "nl:"
   item_name = pre_reply->qual[d.seq].item_name, item_desc = pre_reply->qual[d.seq].item_desc,
   item_type = pre_reply->qual[d.seq].item_type,
   menu_id = pre_reply->qual[d.seq].menu_id, menu_parent_id = pre_reply->qual[d.seq].menu_parent_id,
   ccl_group = pre_reply->qual[d.seq].ccl_group,
   report_service_cd = pre_reply->qual[d.seq].report_service_cd
   FROM (dummyt d  WITH seq = value(cntseq))
   ORDER BY item_desc
   HEAD REPORT
    row + 0, cnt = 0, stat = alterlist(reply->qual,(cnt+ 10))
   DETAIL
    cnt += 1
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alterlist(reply->qual,(cnt+ 10))
    ENDIF
    reply->qual[cnt].item_name = item_name, reply->qual[cnt].item_desc = item_desc, reply->qual[cnt].
    item_type = item_type,
    reply->qual[cnt].menu_id = menu_id, reply->qual[cnt].menu_parent_id = menu_parent_id, reply->
    qual[cnt].ccl_group = pre_reply->qual[d.seq].ccl_group,
    reply->qual[cnt].report_service_cd = pre_reply->qual[d.seq].report_service_cd
   FOOT REPORT
    stat = alterlist(reply->qual,cnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(concat("curqual=",cnvtstring(curqual)))
 IF (((curqual > 0) OR ((((request->menu_parent_id_f8 > 0)) OR ((request->root="u"))) )) )
  SET failed = "F"
  GO TO exit_script
 ELSE
  SET errcode = error(errmsg,1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_menu_get_items"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO endit
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  GO TO endit
 ENDIF
#endit
 CALL echorecord(reply)
END GO

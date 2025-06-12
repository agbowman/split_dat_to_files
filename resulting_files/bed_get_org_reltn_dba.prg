CREATE PROGRAM bed_get_org_reltn:dba
 FREE SET reply
 RECORD reply(
   01 organizations[*]
     02 organization_id = f8
     02 rlist[*]
       03 org_org_reltn_id = f8
       03 child_org_id = f8
       03 child_org_name = vc
       03 child_org_type_code_value = f8
       03 child_org_type_display = vc
       03 child_org_type_mean = vc
       03 reltn_type_code_value = f8
       03 reltn_type_display = vc
       03 reltn_type_mean = vc
       03 comment_text = vc
       03 active_ind = i2
       03 primary_ind = i2
       03 child_org_active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->organizations,5)
 SET stat = alterlist(reply->organizations,req_cnt)
 DECLARE primary_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4038010
   AND cv.cdf_meaning="CATCHPRIMFAC"
  DETAIL
   primary_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO req_cnt)
   SET reply->organizations[x].organization_id = request->organizations[x].organization_id
   SET ocnt = 0
   SET tot_cnt = 0
   SET cnt = 0
   DECLARE oor_parse_txt = vc
   DECLARE otr_parse_txt = vc
   DECLARE o_parse_txt = vc
   SET oor_parse_txt = "oor.organization_id = request->organizations[x].organization_id"
   SET otr_parse_txt = "otr.organization_id = o.organization_id and otr.active_ind = 1"
   SET o_parse_txt = "o.organization_id = oor.related_org_id"
   IF ((request->organizations[x].child_org_type_code_value > 0))
    SET otr_parse_txt = build(otr_parse_txt," and otr.org_type_cd+0 = ",request->organizations[x].
     child_org_type_code_value)
   ENDIF
   IF ((request->organizations[x].reltn_type_code_value > 0))
    SET oor_parse_txt = build(oor_parse_txt," and oor.org_org_reltn_cd+0 = ",request->organizations[x
     ].reltn_type_code_value)
   ENDIF
   IF ((request->load_inactive_ind=0))
    SET o_parse_txt = build(o_parse_txt," and o.active_ind = 1")
   ENDIF
   IF ((request->organizations[x].child_org_type_code_value > 0))
    SELECT INTO "nl:"
     FROM org_org_reltn oor,
      organization o,
      org_type_reltn otr,
      code_value cv2
     PLAN (oor
      WHERE parser(oor_parse_txt))
      JOIN (o
      WHERE parser(o_parse_txt))
      JOIN (otr
      WHERE parser(otr_parse_txt))
      JOIN (cv2
      WHERE cv2.active_ind=1
       AND cv2.code_value=otr.org_type_cd)
     ORDER BY o.org_name_key
     HEAD REPORT
      cnt = 0, tot_cnt = 0, stat = alterlist(reply->organizations[x].rlist,10)
     DETAIL
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 10)
       stat = alterlist(reply->organizations[x].rlist,(tot_cnt+ 10)), cnt = 1
      ENDIF
      reply->organizations[x].rlist[tot_cnt].org_org_reltn_id = oor.org_org_reltn_id, reply->
      organizations[x].rlist[tot_cnt].comment_text = oor.comment_text, reply->organizations[x].rlist[
      tot_cnt].child_org_id = o.organization_id,
      reply->organizations[x].rlist[tot_cnt].child_org_name = o.org_name, reply->organizations[x].
      rlist[tot_cnt].child_org_type_code_value = cv2.code_value, reply->organizations[x].rlist[
      tot_cnt].child_org_type_display = cv2.display,
      reply->organizations[x].rlist[tot_cnt].child_org_type_mean = cv2.cdf_meaning, reply->
      organizations[x].rlist[tot_cnt].reltn_type_code_value = oor.org_org_reltn_cd, reply->
      organizations[x].rlist[tot_cnt].active_ind = oor.active_ind,
      reply->organizations[x].rlist[tot_cnt].child_org_active_ind = o.active_ind
     FOOT REPORT
      stat = alterlist(reply->organizations[x].rlist,tot_cnt)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM org_org_reltn oor,
      organization o,
      org_type_reltn otr,
      code_value cv2,
      org_org_reltn_info oori
     PLAN (oor
      WHERE parser(oor_parse_txt))
      JOIN (o
      WHERE parser(o_parse_txt))
      JOIN (otr
      WHERE parser(otr_parse_txt))
      JOIN (cv2
      WHERE cv2.active_ind=1
       AND cv2.code_value=otr.org_type_cd)
      JOIN (oori
      WHERE oori.org_org_reltn_id=outerjoin(oor.org_org_reltn_id)
       AND oori.org_org_reltn_info_type_cd=outerjoin(primary_cd)
       AND oori.active_ind=outerjoin(1))
     ORDER BY oor.related_org_id, oor.org_org_reltn_cd
     HEAD REPORT
      cnt = 0, tot_cnt = 0, stat = alterlist(reply->organizations[x].rlist,10)
     HEAD oor.related_org_id
      cnt = cnt
     HEAD oor.org_org_reltn_cd
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 10)
       stat = alterlist(reply->organizations[x].rlist,(tot_cnt+ 10)), cnt = 1
      ENDIF
      reply->organizations[x].rlist[tot_cnt].org_org_reltn_id = oor.org_org_reltn_id, reply->
      organizations[x].rlist[tot_cnt].comment_text = oor.comment_text, reply->organizations[x].rlist[
      tot_cnt].child_org_id = o.organization_id,
      reply->organizations[x].rlist[tot_cnt].child_org_name = o.org_name, reply->organizations[x].
      rlist[tot_cnt].reltn_type_code_value = oor.org_org_reltn_cd, reply->organizations[x].rlist[
      tot_cnt].active_ind = oor.active_ind,
      reply->organizations[x].rlist[tot_cnt].child_org_active_ind = o.active_ind
      IF (oori.org_org_reltn_info_id > 0)
       reply->organizations[x].rlist[tot_cnt].primary_ind = 1
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->organizations[x].rlist,tot_cnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (tot_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = tot_cnt),
      code_value cv
     PLAN (d
      WHERE (reply->organizations[x].rlist[d.seq].reltn_type_code_value > 0))
      JOIN (cv
      WHERE (cv.code_value=reply->organizations[x].rlist[d.seq].reltn_type_code_value))
     ORDER BY d.seq
     DETAIL
      reply->organizations[x].rlist[d.seq].reltn_type_display = cv.display, reply->organizations[x].
      rlist[d.seq].reltn_type_mean = cv.cdf_meaning
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO

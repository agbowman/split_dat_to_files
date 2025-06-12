CREATE PROGRAM bed_get_res_sch_rad_rooms:dba
 FREE SET reply
 RECORD reply(
   1 sect_list[*]
     2 sect_code_value = f8
     2 sect_disp = vc
     2 sect_desc = vc
     2 sect_mean = vc
     2 subsect_list[*]
       3 subsect_code_value = f8
       3 subsect_disp = vc
       3 subsect_desc = vc
       3 subsect_mean = vc
       3 res_list[*]
         4 service_resource_code_value = f8
         4 sch_resource_code_value = f8
         4 res_disp = vc
         4 res_desc = vc
         4 res_mean = vc
         4 booking_limit = i4
   1 bedrock_rooms[*]
     2 sch_resource_code_value = f8
     2 mnemonic = vc
     2 booking_limit = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET rad_room_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning="RADEXAMROOM"
   AND cv.active_ind=1
  DETAIL
   rad_room_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET inst_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="INSTITUTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   inst_cd = cv.code_value
  WITH nocounter
 ;end select
 SET dept_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="DEPARTMENT")
  ORDER BY cv.code_value
  HEAD cv.code_value
   dept_cd = cv.code_value
  WITH nocounter
 ;end select
 SET sect_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="SECTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   sect_cd = cv.code_value
  WITH nocounter
 ;end select
 SET subsect_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="SUBSECTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   subsect_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM sch_resource s,
   br_name_value b,
   br_name_value b2,
   dummyt d
  PLAN (s
   WHERE s.res_type_flag=1
    AND s.active_ind=1)
   JOIN (b
   WHERE b.br_nv_key1="SCHRESGROUP"
    AND b.br_name="ROOM")
   JOIN (b2
   WHERE b2.br_nv_key1="SCHRESGROUPRES")
   JOIN (d
   WHERE cnvtint(trim(b2.br_name))=s.resource_cd
    AND cnvtint(trim(b2.br_value))=b.br_name_value_id)
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->bedrock_rooms,10)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->bedrock_rooms,(tot_cnt+ 10)), cnt = 1
   ENDIF
   reply->bedrock_rooms[tot_cnt].sch_resource_code_value = s.resource_cd, reply->bedrock_rooms[
   tot_cnt].mnemonic = s.mnemonic, reply->bedrock_rooms[tot_cnt].booking_limit = s.quota
  FOOT REPORT
   stat = alterlist(reply->bedrock_rooms,tot_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM location l,
   service_resource sr,
   resource_group rg,
   resource_group rg2,
   resource_group rg3,
   resource_group rg4,
   service_resource sr2,
   sch_resource s
  PLAN (l
   WHERE (l.location_cd=request->facility_code_value)
    AND l.active_ind=1)
   JOIN (sr
   WHERE sr.organization_id=l.organization_id
    AND sr.service_resource_type_cd=inst_cd
    AND sr.active_ind=1)
   JOIN (rg
   WHERE rg.parent_service_resource_cd=sr.service_resource_cd
    AND rg.resource_group_type_cd=inst_cd
    AND rg.active_ind=1)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=rg.child_service_resource_cd
    AND rg2.resource_group_type_cd=dept_cd
    AND rg2.active_ind=1)
   JOIN (rg3
   WHERE rg3.parent_service_resource_cd=rg2.child_service_resource_cd
    AND rg3.resource_group_type_cd=sect_cd
    AND rg3.active_ind=1)
   JOIN (rg4
   WHERE rg4.parent_service_resource_cd=rg3.child_service_resource_cd
    AND rg4.resource_group_type_cd=subsect_cd
    AND rg4.active_ind=1)
   JOIN (sr2
   WHERE sr2.service_resource_cd=rg4.child_service_resource_cd
    AND sr2.service_resource_type_cd=rad_room_code_value
    AND sr2.active_ind=1)
   JOIN (s
   WHERE s.service_resource_cd=outerjoin(sr2.service_resource_cd)
    AND s.active_ind=outerjoin(1))
  ORDER BY rg3.parent_service_resource_cd, rg4.parent_service_resource_cd
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->sect_list,10)
  HEAD rg3.parent_service_resource_cd
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->sect_list,(tot_cnt+ 10)), cnt = 1
   ENDIF
   reply->sect_list[tot_cnt].sect_code_value = rg3.parent_service_resource_cd, scnt = 0, stot_cnt = 0,
   stat = alterlist(reply->sect_list[tot_cnt].subsect_list,10)
  HEAD rg4.parent_service_resource_cd
   scnt = (scnt+ 1), stot_cnt = (stot_cnt+ 1)
   IF (scnt > 10)
    stat = alterlist(reply->sect_list[tot_cnt].subsect_list,(stot_cnt+ 10)), scnt = 1
   ENDIF
   reply->sect_list[tot_cnt].subsect_list[stot_cnt].subsect_code_value = rg4
   .parent_service_resource_cd, rcnt = 0, rtot_cnt = 0,
   stat = alterlist(reply->sect_list[tot_cnt].subsect_list[stot_cnt].res_list,10)
  DETAIL
   rcnt = (rcnt+ 1), rtot_cnt = (rtot_cnt+ 1)
   IF (rcnt > 10)
    stat = alterlist(reply->sect_list[tot_cnt].subsect_list[stot_cnt].res_list,(rtot_cnt+ 10)), rcnt
     = 1
   ENDIF
   reply->sect_list[tot_cnt].subsect_list[stot_cnt].res_list[rtot_cnt].service_resource_code_value =
   sr2.service_resource_cd, reply->sect_list[tot_cnt].subsect_list[stot_cnt].res_list[rtot_cnt].
   sch_resource_code_value = s.resource_cd, reply->sect_list[tot_cnt].subsect_list[stot_cnt].
   res_list[rtot_cnt].booking_limit = s.quota
  FOOT  rg4.parent_service_resource_cd
   stat = alterlist(reply->sect_list[tot_cnt].subsect_list[stot_cnt].res_list,rtot_cnt)
  FOOT  rg3.parent_service_resource_cd
   stat = alterlist(reply->sect_list[tot_cnt].subsect_list,stot_cnt)
  FOOT REPORT
   stat = alterlist(reply->sect_list,tot_cnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO tot_cnt)
   IF (x=1)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(reply->sect_list,5)),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE (cv.code_value=reply->sect_list[d.seq].sect_code_value)
       AND cv.active_ind=1)
     ORDER BY d.seq
     DETAIL
      reply->sect_list[d.seq].sect_desc = cv.description, reply->sect_list[d.seq].sect_disp = cv
      .display, reply->sect_list[d.seq].sect_mean = cv.cdf_meaning
     WITH nocounter
    ;end select
   ENDIF
   SET sub_size = size(reply->sect_list[x].subsect_list,5)
   FOR (y = 1 TO sub_size)
     IF (y=1)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = sub_size),
        code_value cv
       PLAN (d)
        JOIN (cv
        WHERE (cv.code_value=reply->sect_list[x].subsect_list[d.seq].subsect_code_value)
         AND cv.active_ind=1)
       ORDER BY d.seq
       DETAIL
        reply->sect_list[x].subsect_list[d.seq].subsect_desc = cv.description, reply->sect_list[x].
        subsect_list[d.seq].subsect_disp = cv.display, reply->sect_list[x].subsect_list[d.seq].
        subsect_mean = cv.cdf_meaning
       WITH nocounter
      ;end select
     ENDIF
     SET res_size = size(reply->sect_list[x].subsect_list[y].res_list,5)
     FOR (z = 1 TO res_size)
       IF (z=1)
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = res_size),
          code_value cv
         PLAN (d)
          JOIN (cv
          WHERE (cv.code_value=reply->sect_list[x].subsect_list[y].res_list[d.seq].
          service_resource_code_value)
           AND cv.active_ind=1)
         ORDER BY d.seq
         DETAIL
          reply->sect_list[x].subsect_list[y].res_list[d.seq].res_desc = cv.description, reply->
          sect_list[x].subsect_list[y].res_list[d.seq].res_disp = cv.display, reply->sect_list[x].
          subsect_list[y].res_list[d.seq].res_mean = cv.cdf_meaning
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = res_size),
          sch_resource r
         PLAN (d
          WHERE (reply->sect_list[x].subsect_list[y].res_list[d.seq].sch_resource_code_value > 0))
          JOIN (r
          WHERE (r.resource_cd=reply->sect_list[x].subsect_list[y].res_list[d.seq].
          sch_resource_code_value)
           AND r.active_ind=1)
         ORDER BY d.seq
         DETAIL
          reply->sect_list[x].subsect_list[y].res_list[d.seq].res_desc = r.description, reply->
          sect_list[x].subsect_list[y].res_list[d.seq].res_disp = r.mnemonic, reply->sect_list[x].
          subsect_list[y].res_list[d.seq].res_mean = ""
         WITH nocounter
        ;end select
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

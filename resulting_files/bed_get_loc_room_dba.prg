CREATE PROGRAM bed_get_loc_room:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    01 location_code_value = f8
    01 blist[*]
      02 location_code_value = f8
      02 ulist[*]
        03 location_code_value = f8
        03 rlist[*]
          04 location_code_value = f8
          04 location_type_code_value = f8
          04 short_description = vc
          04 full_description = vc
          04 sequence = i4
          04 area_id = vc
          04 area = vc
          04 edarea_type = vc
          04 dlist[*]
            05 location_code_value = f8
            05 location_type_code_value = f8
            05 short_description = vc
            05 full_description = vc
            05 sequence = i4
            05 location_type_mean = vc
          04 location_type_mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE nbr_rooms_cnt = i4 WITH protect, noconstant(0)
 DECLARE nbr_rooms_rec_mem_exist = i2 WITH protect, noconstant(0)
 SET reply->location_code_value = request->facility_code_value
 SET bcnt = size(request->blist,5)
 SET stat = alterlist(reply->blist,bcnt)
 FOR (x = 1 TO bcnt)
   SET reply->blist[x].location_code_value = request->blist[x].location_code_value
   SET ucnt = size(request->blist[x].ulist,5)
   SET stat = alterlist(reply->blist[x].ulist,ucnt)
   FOR (y = 1 TO ucnt)
    SET reply->blist[x].ulist[y].location_code_value = request->blist[x].ulist[y].location_code_value
    IF (validate(request->blist[x].ulist[y].nbr_rooms,0) > 0)
     SET nbr_rooms_cnt = request->blist[x].ulist[y].nbr_rooms
     SET nbr_rooms_rec_mem_exist = 1
    ENDIF
   ENDFOR
   IF (ucnt > 0)
    SET rcnt = 0
    SET dcnt = 0
    IF (((nbr_rooms_cnt > 0) OR (nbr_rooms_rec_mem_exist=0)) )
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = ucnt),
       location_group lg,
       code_value cv3,
       code_value cv4,
       location l,
       code_value cv,
       location_group lg2,
       location l2,
       code_value cv2
      PLAN (d)
       JOIN (lg
       WHERE (lg.parent_loc_cd=reply->blist[x].ulist[d.seq].location_code_value)
        AND lg.active_ind=1
        AND lg.root_loc_cd=0)
       JOIN (cv3
       WHERE cv3.code_value=lg.parent_loc_cd)
       JOIN (cv4
       WHERE cv4.code_value=lg.location_group_type_cd
        AND cv3.cdf_meaning=cv4.cdf_meaning)
       JOIN (l
       WHERE l.location_cd=lg.child_loc_cd
        AND l.active_ind=1)
       JOIN (cv
       WHERE cv.code_value=l.location_cd)
       JOIN (lg2
       WHERE lg2.parent_loc_cd=outerjoin(cv.code_value)
        AND lg2.active_ind=outerjoin(1)
        AND lg2.root_loc_cd=outerjoin(0))
       JOIN (l2
       WHERE l2.location_cd=outerjoin(lg2.child_loc_cd)
        AND l2.active_ind=outerjoin(1))
       JOIN (cv2
       WHERE cv2.code_value=outerjoin(l2.location_cd))
      ORDER BY d.seq, lg.sequence, l.location_cd,
       lg2.sequence, l2.location_cd
      HEAD REPORT
       rcnt = 0
      HEAD d.seq
       rcnt = 0
      HEAD l.location_cd
       rcnt = (rcnt+ 1), stat = alterlist(reply->blist[x].ulist[d.seq].rlist,rcnt), reply->blist[x].
       ulist[d.seq].rlist[rcnt].location_code_value = l.location_cd,
       reply->blist[x].ulist[d.seq].rlist[rcnt].location_type_code_value = l.location_type_cd, reply
       ->blist[x].ulist[d.seq].rlist[rcnt].short_description = cv.display, reply->blist[x].ulist[d
       .seq].rlist[rcnt].full_description = cv.description,
       reply->blist[x].ulist[d.seq].rlist[rcnt].sequence = lg.sequence, dcnt = 0
      DETAIL
       IF (l2.location_cd > 0)
        dcnt = (dcnt+ 1), stat = alterlist(reply->blist[x].ulist[d.seq].rlist[rcnt].dlist,dcnt),
        reply->blist[x].ulist[d.seq].rlist[rcnt].dlist[dcnt].location_code_value = l2.location_cd,
        reply->blist[x].ulist[d.seq].rlist[rcnt].dlist[dcnt].location_type_code_value = l2
        .location_type_cd, reply->blist[x].ulist[d.seq].rlist[rcnt].dlist[dcnt].short_description =
        cv2.display, reply->blist[x].ulist[d.seq].rlist[rcnt].dlist[dcnt].full_description = cv2
        .description,
        reply->blist[x].ulist[d.seq].rlist[rcnt].dlist[dcnt].sequence = lg2.sequence
       ENDIF
      WITH nocounter
     ;end select
     FOR (y = 1 TO ucnt)
       SET edunit = 0
       SELECT INTO "nl:"
        FROM br_name_value br
        PLAN (br
         WHERE br.br_nv_key1="EDUNIT"
          AND br.br_name="CVFROMCS220"
          AND br.br_value=cnvtstring(reply->blist[x].ulist[y].location_code_value))
        DETAIL
         edunit = 1
        WITH nocounter
       ;end select
       SET rcnt = size(reply->blist[x].ulist[y].rlist,5)
       IF (edunit=1
        AND rcnt > 0)
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = rcnt),
          br_name_value br
         PLAN (d)
          JOIN (br
          WHERE br.br_nv_key1="EDAREAROOMRELTN"
           AND br.br_value=cnvtstring(reply->blist[x].ulist[y].rlist[d.seq].location_code_value))
         ORDER BY d.seq
         HEAD d.seq
          reply->blist[x].ulist[y].rlist[d.seq].area_id = br.br_name
         WITH nocounter
        ;end select
       ENDIF
       IF (rcnt > 0)
        SELECT INTO "NL:"
         FROM (dummyt d  WITH seq = rcnt),
          code_value cv
         PLAN (d)
          JOIN (cv
          WHERE (cv.code_value=reply->blist[x].ulist[y].rlist[d.seq].location_type_code_value))
         DETAIL
          reply->blist[x].ulist[y].rlist[d.seq].location_type_mean = cv.cdf_meaning
         WITH nocounter
        ;end select
        FOR (z = 1 TO size(reply->blist[x].ulist[y].rlist,5))
          IF (edunit=1)
           SET area_id = cnvtint(reply->blist[x].ulist[y].rlist[z].area_id)
           IF (area_id > 0)
            SELECT INTO "nl:"
             FROM br_name_value br
             PLAN (br
              WHERE br.br_name_value_id=area_id)
             DETAIL
              reply->blist[x].ulist[y].rlist[z].area = br.br_value, reply->blist[x].ulist[y].rlist[z]
              .edarea_type = br.br_nv_key1
             WITH nocounter
            ;end select
           ENDIF
          ENDIF
          SET dcnt = size(reply->blist[x].ulist[y].rlist[z].dlist,5)
          IF (dcnt > 0)
           SELECT INTO "NL:"
            FROM (dummyt d  WITH seq = dcnt),
             code_value cv
            PLAN (d
             WHERE (reply->blist[x].ulist[y].rlist[z].dlist[d.seq].location_type_code_value > 0))
             JOIN (cv
             WHERE (cv.code_value=reply->blist[x].ulist[y].rlist[z].dlist[d.seq].
             location_type_code_value))
            DETAIL
             reply->blist[x].ulist[y].rlist[z].dlist[d.seq].location_type_mean = cv.cdf_meaning
            WITH nocounter
           ;end select
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->location_code_value > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO

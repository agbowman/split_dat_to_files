CREATE PROGRAM bed_get_rel_pos_cat:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 rel_list[*]
      2 category_id = f8
      2 description = c40
      2 mean = vc
      2 plist[*]
        3 position_code_value = f8
        3 phys_ind = i2
        3 display = c40
        3 desc = vc
        3 sequence = i4
        3 position_desc = c60
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
    1 pos_wo_cat[*]
      2 position_code_value = f8
      2 display = vc
      2 desc = vc
      2 position_desc = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET tot_count = 0
 SET count = 0
 SET ptot_count = 0
 SET pcount = 0
 IF ((request->max_reply > 0))
  SET max_reply = request->max_reply
 ELSE
  SET max_reply = 10000
 ENDIF
 SET stat = alterlist(reply->rel_list,50)
 SELECT INTO "NL:"
  FROM br_position_category bpc,
   br_position_cat_comp bpcc,
   code_value cv,
   br_long_text lt
  PLAN (bpc
   WHERE bpc.active_ind=1)
   JOIN (bpcc
   WHERE bpcc.category_id=outerjoin(bpc.category_id))
   JOIN (cv
   WHERE cv.code_set=outerjoin(88)
    AND cv.active_ind=outerjoin(1)
    AND cv.code_value=outerjoin(bpcc.position_cd))
   JOIN (lt
   WHERE lt.parent_entity_name=outerjoin("CODE_VALUE")
    AND lt.parent_entity_id=outerjoin(cv.code_value))
  ORDER BY bpc.description, bpcc.sequence, bpcc.position_cd
  HEAD bpc.description
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->rel_list,(tot_count+ 50)), count = 1
   ENDIF
   reply->rel_list[tot_count].category_id = bpc.category_id, reply->rel_list[tot_count].description
    = bpc.description, reply->rel_list[tot_count].mean = bpc.step_cat_mean,
   stat = alterlist(reply->rel_list[tot_count].plist,20), pcount = 0, ptot_count = 0
  DETAIL
   IF (bpcc.position_cd > 0
    AND cv.active_ind=1)
    ptot_count = (ptot_count+ 1), pcount = (pcount+ 1)
    IF (pcount > 20)
     stat = alterlist(reply->rel_list[tot_count].plist,(ptot_count+ 50)), pcount = 1
    ENDIF
    reply->rel_list[tot_count].plist[ptot_count].position_code_value = bpcc.position_cd, reply->
    rel_list[tot_count].plist[ptot_count].phys_ind = bpcc.physician_ind, reply->rel_list[tot_count].
    plist[ptot_count].sequence = bpcc.sequence,
    reply->rel_list[tot_count].plist[ptot_count].display = cv.display, reply->rel_list[tot_count].
    plist[ptot_count].position_desc = cv.description
    IF (lt.long_text > "     *")
     reply->rel_list[tot_count].plist[ptot_count].desc = lt.long_text
    ELSE
     reply->rel_list[tot_count].plist[ptot_count].desc = "Description not available."
    ENDIF
   ENDIF
  FOOT  bpc.category_id
   stat = alterlist(reply->rel_list[tot_count].plist,ptot_count)
  WITH maxrec = value(max_reply), nocounter
 ;end select
 SET stat = alterlist(reply->rel_list,tot_count)
 IF (validate(request->load_pos_wo_cats))
  IF ((request->load_pos_wo_cats=1))
   SELECT INTO "nl:"
    FROM code_value cv,
     br_long_text lt,
     br_position_cat_comp b
    PLAN (cv
     WHERE cv.code_set=88
      AND cv.active_ind=1)
     JOIN (lt
     WHERE lt.parent_entity_id=outerjoin(cv.code_value)
      AND lt.parent_entity_name=outerjoin("CODE_VALUE"))
     JOIN (b
     WHERE b.position_cd=outerjoin(cv.code_value))
    ORDER BY cv.code_value
    HEAD REPORT
     cnt = 0, tcnt = 0, stat = alterlist(reply->pos_wo_cat,100)
    HEAD cv.code_value
     IF (b.position_cd=0)
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 100)
       stat = alterlist(reply->pos_wo_cat,(tcnt+ 100)), cnt = 1
      ENDIF
      reply->pos_wo_cat[tcnt].position_code_value = cv.code_value, reply->pos_wo_cat[tcnt].display =
      cv.display, reply->pos_wo_cat[tcnt].position_desc = cv.description
      IF (lt.long_text > "     *")
       reply->pos_wo_cat[tcnt].desc = lt.long_text
      ELSE
       reply->pos_wo_cat[tcnt].desc = "Description not available."
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->pos_wo_cat,tcnt), tot_count = (tot_count+ tcnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#enditnow
 IF (tot_count >= max_reply)
  SET stat = alterlist(reply->rel_list,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSEIF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSEIF (tot_count=0)
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO

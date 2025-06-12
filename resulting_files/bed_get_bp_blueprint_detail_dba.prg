CREATE PROGRAM bed_get_bp_blueprint_detail:dba
 FREE SET reply
 RECORD reply(
   1 activity_groups[*]
     2 activity_group_id = f8
     2 act_group_instance_id = f8
     2 display = vc
     2 description = vc
     2 contextual_disp = vc
     2 meaning = vc
     2 type_flag = i2
     2 child_act_groups[*]
       3 activity_group_id = f8
       3 act_group_instance_id = f8
       3 display_seq = i4
     2 activities[*]
       3 activity_id = f8
       3 activity_instance_id = f8
       3 meaning = vc
       3 display = vc
       3 description = vc
       3 contextual_disp = vc
       3 display_seq = i4
       3 status = i2
       3 percent_complete = i4
       3 hide_ind = i2
       3 notes[*]
         4 note_id = f8
         4 text = vc
         4 create_dt_tm = dq8
         4 person_id = f8
         4 name_full_formated = vc
     2 instance_display = vc
     2 rslinks[*]
       3 link_text = vc
       3 link_url = vc
     2 hide_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET child_groups
 RECORD child_groups(
   1 activity_groups[*]
     2 activity_group_id = f8
     2 act_group_instance_id = f8
     2 hide_ind = i2
     2 display = vc
     2 added_ind = i2
 )
 FREE SET groups_added
 RECORD groups_added(
   1 activity_groups[*]
     2 activity_group_id = f8
     2 act_group_instance_id = f8
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET temp_cnt = 0
 SET stat = alterlist(reply->activity_groups,1)
 IF ((request->activity_group_id=0)
  AND (request->act_group_instance_id=0)
  AND (request->activity_group_meaning > " "))
  SELECT INTO "nl:"
   FROM br_bp_act_group bg
   PLAN (bg
    WHERE cnvtupper(bg.act_group_mean)=cnvtupper(request->activity_group_meaning))
   ORDER BY bg.version_nbr
   DETAIL
    request->activity_group_id = bg.br_bp_act_group_id
   WITH nocounter
  ;end select
 ENDIF
 SET x = 1
 SET stat = get_act_group(request->activity_group_id,request->act_group_instance_id,x)
 SET added_cnt = 0
 SET add_ind = 1
 WHILE (add_ind=1)
   SET add_ind = 0
   SET chld_size = size(reply->activity_groups[x].child_act_groups,5)
   IF (chld_size > 0)
    SET ga_size = size(groups_added->activity_groups,5)
    IF (ga_size > 0)
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(chld_size)),
       (dummyt d2  WITH seq = value(ga_size))
      PLAN (d1)
       JOIN (d2
       WHERE (groups_added->activity_groups[d2.seq].activity_group_id=child_groups->activity_groups[
       d1.seq].activity_group_id))
      ORDER BY d1.seq, d2.seq
      HEAD d1.seq
       child_groups->activity_groups[d1.seq].added_ind = 1
      WITH nocounter
     ;end select
    ENDIF
    FOR (y = 1 TO chld_size)
      IF ((child_groups->activity_groups[y].added_ind=0))
       SET add_ind = 1
       SET x = (x+ 1)
       SET stat = alterlist(reply->activity_groups,x)
       SET stat = get_act_group(child_groups->activity_groups[y].activity_group_id,child_groups->
        activity_groups[y].act_group_instance_id,x)
       SET added_cnt = (added_cnt+ 1)
       SET stat = alterlist(groups_added->activity_groups,added_cnt)
       SET groups_added->activity_groups[added_cnt].activity_group_id = child_groups->
       activity_groups[y].activity_group_id
       SET groups_added->activity_groups[added_cnt].act_group_instance_id = child_groups->
       activity_groups[y].act_group_instance_id
      ENDIF
    ENDFOR
   ENDIF
 ENDWHILE
 SUBROUTINE get_act_group(ag_id,ag_inst_id,x)
   SELECT INTO "nl:"
    FROM br_bp_act_group bg
    PLAN (bg
     WHERE bg.br_bp_act_group_id=ag_id)
    HEAD REPORT
     reply->activity_groups[x].activity_group_id = bg.br_bp_act_group_id, reply->activity_groups[x].
     display = bg.display, reply->activity_groups[x].contextual_disp = bg.description,
     reply->activity_groups[x].meaning = bg.act_group_mean, reply->activity_groups[x].type_flag = bg
     .type_flag
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET stat = initrec(reply)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM br_bp_rslink b
    PLAN (b
     WHERE b.bedrock_entity_name="BR_BP_ACT_GROUP"
      AND (b.bedrock_entity_mean=reply->activity_groups[x].meaning))
    HEAD REPORT
     def_rs_ind = 0, rcnt = 0, rtot_cnt = 0,
     stat = alterlist(reply->activity_groups[x].rslinks,10)
    DETAIL
     rcnt = (rcnt+ 1), rtot_cnt = (rtot_cnt+ 1)
     IF (rcnt > 10)
      stat = alterlist(reply->activity_groups[x].rslinks,(rtot_cnt+ 10)), rcnt = 1
     ENDIF
     reply->activity_groups[x].rslinks[rtot_cnt].link_text = b.rslink_text, reply->activity_groups[x]
     .rslinks[rtot_cnt].link_url = b.rslink_url
    FOOT REPORT
     stat = alterlist(reply->activity_groups[x].rslinks,rtot_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM br_bp_act_group bg,
     br_bp_act_long_desc b,
     br_long_text bl
    PLAN (bg
     WHERE (bg.br_bp_act_group_id=reply->activity_groups[x].activity_group_id))
     JOIN (b
     WHERE b.act_group_mean=bg.act_group_mean
      AND b.cat_mean=bg.cat_mean)
     JOIN (bl
     WHERE bl.long_text_id=b.br_long_text_id)
    DETAIL
     reply->activity_groups[x].description = bl.long_text
    WITH nocounter
   ;end select
   SET atot_cnt = 0
   SELECT INTO "nl:"
    FROM br_bp_act_group bag,
     br_bp_act_group_r bgr,
     br_bp_activity ba
    PLAN (bag
     WHERE (bag.br_bp_act_group_id=reply->activity_groups[x].activity_group_id))
     JOIN (bgr
     WHERE bgr.br_bp_act_group_id=bag.br_bp_act_group_id
      AND bgr.child_entity_name="BR_BP_ACTIVITY")
     JOIN (ba
     WHERE ba.br_bp_activity_id=bgr.child_entity_id)
    HEAD REPORT
     acnt = 0, atot_cnt = 0, stat = alterlist(reply->activity_groups[x].activities,10)
    DETAIL
     acnt = (acnt+ 1), atot_cnt = (atot_cnt+ 1)
     IF (acnt > 10)
      stat = alterlist(reply->activity_groups[x].activities,(atot_cnt+ 10)), acnt = 1
     ENDIF
     reply->activity_groups[x].activities[atot_cnt].activity_id = ba.br_bp_activity_id, reply->
     activity_groups[x].activities[atot_cnt].contextual_disp = ba.description, reply->
     activity_groups[x].activities[atot_cnt].display = ba.display,
     reply->activity_groups[x].activities[atot_cnt].display_seq = bgr.display_seq, reply->
     activity_groups[x].activities[atot_cnt].meaning = ba.activity_mean
    FOOT REPORT
     stat = alterlist(reply->activity_groups[x].activities,atot_cnt)
    WITH nocounter
   ;end select
   IF (atot_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(atot_cnt)),
      br_bp_act_group bg,
      br_bp_act_long_desc b,
      br_long_text bl
     PLAN (d)
      JOIN (bg
      WHERE (bg.br_bp_act_group_id=reply->activity_groups[x].activity_group_id))
      JOIN (b
      WHERE (b.activity_mean=reply->activity_groups[x].activities[d.seq].meaning)
       AND b.cat_mean=bg.cat_mean)
      JOIN (bl
      WHERE bl.long_text_id=b.br_long_text_id)
     ORDER BY d.seq
     HEAD d.seq
      reply->activity_groups[x].activities[d.seq].description = bl.long_text
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(atot_cnt)),
      br_bp_act_group bg,
      br_bp_act_long_desc b,
      br_long_text bl
     PLAN (d
      WHERE  NOT ((reply->activity_groups[x].activities[d.seq].description > " ")))
      JOIN (bg
      WHERE (bg.br_bp_act_group_id=reply->activity_groups[x].activity_group_id))
      JOIN (b
      WHERE (b.activity_mean=reply->activity_groups[x].activities[d.seq].meaning)
       AND b.cat_mean IN ("", " ", null))
      JOIN (bl
      WHERE bl.long_text_id=b.br_long_text_id)
     ORDER BY d.seq
     HEAD d.seq
      reply->activity_groups[x].activities[d.seq].description = bl.long_text
     WITH nocounter
    ;end select
   ENDIF
   SET ctot_cnt = 0
   SELECT INTO "nl:"
    FROM br_bp_act_group bag,
     br_bp_act_group_r bgr,
     br_bp_act_group bag2
    PLAN (bag
     WHERE (bag.br_bp_act_group_id=reply->activity_groups[x].activity_group_id))
     JOIN (bgr
     WHERE bgr.br_bp_act_group_id=bag.br_bp_act_group_id
      AND bgr.child_entity_name="BR_BP_ACT_GROUP")
     JOIN (bag2
     WHERE bag2.br_bp_act_group_id=bgr.child_entity_id)
    HEAD REPORT
     ccnt = 0, ctot_cnt = 0, stat = alterlist(reply->activity_groups[x].child_act_groups,10),
     stat = alterlist(child_groups->activity_groups,10)
    DETAIL
     ccnt = (ccnt+ 1), ctot_cnt = (ctot_cnt+ 1)
     IF (ccnt > 10)
      stat = alterlist(reply->activity_groups[x].child_act_groups,(ctot_cnt+ 10)), stat = alterlist(
       child_groups->activity_groups,(ctot_cnt+ 10)), ccnt = 1
     ENDIF
     reply->activity_groups[x].child_act_groups[ctot_cnt].activity_group_id = bag2.br_bp_act_group_id,
     reply->activity_groups[x].child_act_groups[ctot_cnt].display_seq = bgr.display_seq, child_groups
     ->activity_groups[ctot_cnt].activity_group_id = bag2.br_bp_act_group_id
    FOOT REPORT
     stat = alterlist(reply->activity_groups[x].child_act_groups,ctot_cnt), stat = alterlist(
      child_groups->activity_groups,ctot_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

CREATE PROGRAM bed_imp_appt_type_settings:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 appt_num = i4
   1 appts[*]
     2 appt_type_cd = f8
     2 appt_syn_cd = f8
     2 mnemonic = vc
     2 accept_format = vc
     2 accept_format_id = f8
     2 action_flag = i2
     2 error_string = vc
     2 row = i4
     2 location_num = i4
     2 locations[*]
       3 location = vc
       3 location_cd = f8
       3 location_mean = vc
       3 action_flag = i2
       3 error_string = vc
       3 row = i4
       3 rule_id = f8
       3 guideline_num = i4
       3 request_queue_num = i4
       3 guidelines[*]
         4 guideline_action = vc
         4 guideline_action_cd = f8
         4 guideline_action_mean = vc
         4 guideline_parent_id = f8
         4 guideline_num = i4
         4 action_flag = i2
         4 error_string = vc
         4 row = i4
         4 guidelines[*]
           5 guideline = vc
           5 guideline_id = f8
           5 seq = i4
           5 action_flag = i2
           5 error_string = vc
           5 row = i4
       3 request_queues[*]
         4 request_queue = vc
         4 request_queue_id = f8
         4 request_queue_action = vc
         4 request_queue_action_cd = f8
         4 request_queue_action_mean = vc
         4 seq = i4
         4 rule_id = f8
         4 action_flag = i2
         4 error_string = vc
         4 row = i4
 )
 FREE SET add_code_value
 RECORD add_code_value(
   1 code_set = f8
   1 qual[1]
     2 cdf_meaning = c12
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 collation_seq = f8
     2 active_type_cd = f8
     2 active_ind = i2
     2 authentic_ind = i2
     2 extension_cnt = f8
     2 extension_data[1]
       3 field_name = c32
       3 field_type = f8
       3 field_value = vc
 )
 FREE SET reply_code_value
 RECORD reply_code_value(
   1 qual[1]
     2 code_value = f8
     2 display_key = c40
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET active_cd = get_code_value(48,"ACTIVE")
 SET text_type_cd = get_code_value(15149,"PREAPPT")
 SET sub_text_cd = get_code_value(15589,"PREAPPT")
 SET appt_prep = get_code_value(16162,"ATPREAPPT")
 SET order_prep = get_code_value(16162,"OPREAPPT")
 SET appt_oe_type_cd = get_code_value(14232,"APPOINTMENT")
 SET guideline_type_cd = get_code_value(15149,"GUIDELINE")
 SET guideline_sub_type_cd = get_code_value(15589,"GUIDELINE")
 SET queue_type_cd = get_code_value(16146,"QUEUE")
 SET queue_sub_type_cd = get_code_value(16147,"QUEUE")
 SET required_accept_cd = get_code_value(16109,"REQUIRED")
 SET optional_recur_cd = get_code_value(16109,"OPTIONAL")
 SET appt_book_product_cd = get_code_value(23026,"APPTBOOK")
 SET location_flex_type_cd = get_code_value(16162,"ATLOC")
 SET request_list_flex_type_cd = get_code_value(16162,"ATREQLIST")
 SET numrows = size(requestin->list_0,5)
 IF (numrows=0)
  SET error_msg = "No rows to process"
  GO TO exit_script
 ENDIF
 SET title = validate(log_title_set,"Appointment Type Upload Log")
 SET name = validate(log_name_set,"bed_appt_type_settings.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 FOR (i = 1 TO numrows)
   SET rec = 0
   FOR (ii = 1 TO temp->appt_num)
     IF ((temp->appts[ii].mnemonic=requestin->list_0[i].appt_type))
      SET rec = ii
     ENDIF
   ENDFOR
   IF (rec=0)
    SET temp->appt_num = (temp->appt_num+ 1)
    SET stat = alterlist(temp->appts,temp->appt_num)
    SET rec = temp->appt_num
    SET temp->appts[rec].mnemonic = requestin->list_0[i].appt_type
    SET temp->appts[rec].action_flag = 1
    SET temp->appts[rec].row = i
    SET temp->appts[rec].accept_format = requestin->list_0[i].accept_format
    IF ((temp->appts[rec].mnemonic=" "))
     SET temp->appts[rec].action_flag = 0
     SET temp->appts[rec].error_string = "Appt Type Null!"
    ELSE
     SELECT INTO "NL:"
      FROM sch_appt_syn s
      PLAN (s
       WHERE cnvtupper(s.mnemonic)=cnvtupper(temp->appts[rec].mnemonic)
        AND s.active_ind=1
        AND s.primary_ind=1)
      DETAIL
       temp->appts[rec].appt_type_cd = s.appt_type_cd, temp->appts[rec].mnemonic = s.mnemonic, temp->
       appts[rec].action_flag = 2
      WITH nocounter
     ;end select
    ENDIF
    IF ((requestin->list_0[i].accept_format > " "))
     SELECT INTO "NL:"
      FROM order_entry_format o
      PLAN (o
       WHERE o.action_type_cd=appt_oe_type_cd
        AND cnvtupper(o.oe_format_name)=cnvtupper(requestin->list_0[i].accept_format))
      DETAIL
       temp->appts[rec].accept_format = o.oe_format_name, temp->appts[rec].accept_format_id = o
       .oe_format_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET temp->appts[rec].action_flag = 0
      SET temp->appts[rec].error_string = "Invalid Accept Format"
     ENDIF
    ENDIF
   ENDIF
   IF ((temp->appts[rec].action_flag > 0))
    SET lrec = 0
    FOR (ii = 1 TO temp->appts[rec].location_num)
      IF (cnvtupper(temp->appts[rec].locations[ii].location)=cnvtupper(requestin->list_0[i].location)
      )
       SET lrec = ii
      ENDIF
    ENDFOR
    IF (lrec=0)
     SET temp->appts[rec].location_num = (temp->appts[rec].location_num+ 1)
     SET stat = alterlist(temp->appts[rec].locations,temp->appts[rec].location_num)
     SET lrec = temp->appts[rec].location_num
     SET temp->appts[rec].locations[lrec].row = i
     SET temp->appts[rec].locations[lrec].location = requestin->list_0[i].location
     SET temp->appts[rec].locations[lrec].action_flag = 1
     IF ((temp->appts[rec].locations[lrec].location=" "))
      SET temp->appts[rec].locations[lrec].action_flag = 0
      SET temp->appts[rec].locations[lrec].error_string = "Location Null!"
     ELSE
      SELECT INTO "NL:"
       FROM code_value c
       PLAN (c
        WHERE c.code_set=220
         AND c.active_ind=1
         AND cnvtupper(c.display)=cnvtupper(temp->appts[rec].locations[lrec].location))
       DETAIL
        temp->appts[rec].locations[lrec].location = c.display, temp->appts[rec].locations[lrec].
        location_cd = c.code_value, temp->appts[rec].locations[lrec].location_mean = c.cdf_meaning
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET temp->appts[rec].locations[lrec].action_flag = 0
       SET temp->appts[rec].locations[lrec].error_string = "Disp CS 220"
      ENDIF
      IF ((requestin->list_0[i].location_rule > " "))
       SELECT INTO "NL:"
        FROM sch_flex_string s
        PLAN (s
         WHERE s.mnemonic_key=cnvtupper(requestin->list_0[i].location_rule)
          AND s.flex_type_cd=location_flex_type_cd)
        DETAIL
         temp->appts[rec].locations[lrec].rule_id = s.sch_flex_id
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET temp->appts[rec].locations[lrec].action_flag = 0
        SET temp->appts[rec].locations[lrec].error_string = "Flex Rule"
       ENDIF
      ENDIF
      IF ((temp->appts[rec].locations[lrec].action_flag > 0))
       SELECT INTO "NL:"
        FROM sch_appt_loc s
        PLAN (s
         WHERE s.active_ind=1
          AND (s.appt_type_cd=temp->appts[rec].appt_type_cd)
          AND (s.location_cd=temp->appts[rec].locations[lrec].location_cd))
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET temp->appts[rec].locations[lrec].action_flag = 2
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    SET glrec = 0
    IF ((requestin->list_0[i].guideline_action > " ")
     AND (temp->appts[rec].locations[lrec].action_flag > 0))
     FOR (ii = 1 TO temp->appts[rec].locations[lrec].guideline_num)
       IF (cnvtupper(temp->appts[rec].locations[lrec].guidelines[ii].guideline_action)=cnvtupper(
        requestin->list_0[i].guideline_action))
        SET glrec = ii
       ENDIF
     ENDFOR
     IF (glrec=0)
      SET temp->appts[rec].locations[lrec].guideline_num = (temp->appts[rec].locations[lrec].
      guideline_num+ 1)
      SET stat = alterlist(temp->appts[rec].locations[lrec].guidelines,temp->appts[rec].locations[
       lrec].guideline_num)
      SET glrec = temp->appts[rec].locations[lrec].guideline_num
      SET temp->appts[rec].locations[lrec].guidelines[glrec].row = i
      SET temp->appts[rec].locations[lrec].guidelines[glrec].action_flag = 1
      SET temp->appts[rec].locations[lrec].guidelines[glrec].guideline_action = requestin->list_0[i].
      guideline_action
      SELECT INTO "NL:"
       FROM code_value c
       PLAN (c
        WHERE c.code_set=14232
         AND c.active_ind=1
         AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].guideline_action))
       DETAIL
        temp->appts[rec].locations[lrec].guidelines[glrec].guideline_action = c.display, temp->appts[
        rec].locations[lrec].guidelines[glrec].guideline_action_cd = c.code_value, temp->appts[rec].
        locations[lrec].guidelines[glrec].guideline_action_mean = c.cdf_meaning
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET temp->appts[rec].locations[lrec].guidelines[glrec].action_flag = 0
       SET temp->appts[rec].locations[lrec].guidelines[glrec].error_string = "Disp CS 14232"
      ELSE
       SELECT INTO "NL:"
        FROM sch_text_link stl
        PLAN (stl
         WHERE stl.active_ind=1
          AND (stl.parent_id=temp->appts[rec].appt_type_cd)
          AND (stl.parent2_id=temp->appts[rec].locations[lrec].location_cd)
          AND (stl.parent3_id=temp->appts[rec].locations[lrec].guidelines[glrec].guideline_action_cd)
          AND stl.text_type_cd=guideline_type_cd
          AND stl.sub_text_cd=guideline_sub_type_cd)
        DETAIL
         temp->appts[rec].locations[lrec].guidelines[glrec].guideline_parent_id = stl.text_link_id,
         temp->appts[rec].locations[lrec].guidelines[glrec].action_flag = 2
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
    IF (glrec > 0
     AND (temp->appts[rec].locations[lrec].guidelines[glrec].action_flag > 0))
     SET temp->appts[rec].locations[lrec].guidelines[glrec].guideline_num = (temp->appts[rec].
     locations[lrec].guidelines[glrec].guideline_num+ 1)
     SET grec = temp->appts[rec].locations[lrec].guidelines[glrec].guideline_num
     SET stat = alterlist(temp->appts[rec].locations[lrec].guidelines[glrec].guidelines,grec)
     SET temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].row = i
     SET temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].action_flag = 1
     SET temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].guideline = requestin->
     list_0[i].guideline
     SET temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].seq = (grec - 1)
     FOR (ii = 1 TO (grec - 1))
       IF (cnvtupper(temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[ii].guideline)=
       cnvtupper(temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].guideline))
        SET temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].action_flag = 0
        SET temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].error_string =
        "Already Defined"
       ENDIF
     ENDFOR
     SELECT INTO "NL:"
      FROM sch_template s
      PLAN (s
       WHERE s.text_type_cd=guideline_type_cd
        AND s.active_ind=1
        AND cnvtupper(s.mnemonic)=cnvtupper(requestin->list_0[i].guideline))
      DETAIL
       temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].guideline = s.mnemonic,
       temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].guideline_id = s
       .template_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].action_flag = 0
      SET temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].error_string =
      "Invalid Guideline"
     ELSE
      IF (curqual > 0
       AND (temp->appts[rec].locations[lrec].guidelines[glrec].action_flag=2))
       SELECT INTO "NL:"
        FROM sch_sub_list ssl
        PLAN (ssl
         WHERE ssl.active_ind=1
          AND (ssl.parent_id=temp->appts[rec].locations[lrec].guidelines[glrec].guideline_parent_id)
          AND (ssl.template_id=temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].
         guideline_id))
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].error_string =
        "Already Linked"
        SET temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].action_flag = 0
       ENDIF
      ENDIF
      SELECT INTO "NL:"
       start_seq = count(*)
       FROM sch_sub_list s
       PLAN (s
        WHERE s.active_ind=1
         AND (s.parent_id=temp->appts[rec].locations[lrec].guidelines[glrec].guideline_parent_id))
       DETAIL
        temp->appts[rec].locations[lrec].guidelines[glrec].guidelines[grec].seq = (temp->appts[rec].
        locations[lrec].guidelines[glrec].guidelines[grec].seq+ start_seq)
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF ((requestin->list_0[i].request_queue > " ")
     AND (temp->appts[rec].locations[lrec].action_flag > 0))
     SET temp->appts[rec].locations[lrec].request_queue_num = (temp->appts[rec].locations[lrec].
     request_queue_num+ 1)
     SET stat = alterlist(temp->appts[rec].locations[lrec].request_queues,temp->appts[rec].locations[
      lrec].request_queue_num)
     SET rrec = temp->appts[rec].locations[lrec].request_queue_num
     SET temp->appts[rec].locations[lrec].request_queues[rrec].row = i
     SET temp->appts[rec].locations[lrec].request_queues[rrec].action_flag = 1
     FOR (ii = 1 TO rec)
       FOR (iii = 1 TO temp->appts[ii].location_num)
         FOR (iiii = 1 TO temp->appts[ii].locations[iii].request_queue_num)
           IF (cnvtupper(temp->appts[ii].locations[iii].request_queues[iiii].request_queue)=cnvtupper
           (requestin->list_0[i].request_queue)
            AND cnvtupper(temp->appts[ii].locations[iii].request_queues[iiii].request_queue_action)=
           cnvtupper(requestin->list_0[i].request_queue_action))
            SET temp->appts[rec].locations[lrec].request_queues[rrec].action_flag = 2
           ENDIF
         ENDFOR
       ENDFOR
     ENDFOR
     SET temp->appts[rec].locations[lrec].request_queues[rrec].request_queue = requestin->list_0[i].
     request_queue
     SET temp->appts[rec].locations[lrec].request_queues[rrec].request_queue_action = requestin->
     list_0[i].request_queue_action
     SET tempseq = 0
     FOR (j = 1 TO (rrec - 1))
       IF (cnvtupper(requestin->list_0[i].request_queue_action)=cnvtupper(temp->appts[rec].locations[
        lrec].request_queues[j].request_queue_action))
        SET tempseq = (tempseq+ 1)
       ENDIF
     ENDFOR
     SET temp->appts[rec].locations[lrec].request_queues[rrec].seq = tempseq
     SELECT INTO "NL:"
      FROM sch_object s
      PLAN (s
       WHERE s.active_ind=1
        AND s.object_type_cd=queue_type_cd
        AND s.object_sub_cd=queue_sub_type_cd
        AND cnvtupper(s.mnemonic)=cnvtupper(temp->appts[rec].locations[lrec].request_queues[rrec].
        request_queue))
      DETAIL
       temp->appts[rec].locations[lrec].request_queues[rrec].request_queue = s.mnemonic, temp->appts[
       rec].locations[lrec].request_queues[rrec].action_flag = 2, temp->appts[rec].locations[lrec].
       request_queues[rrec].request_queue_id = s.sch_object_id
      WITH nocounter
     ;end select
     FOR (ii = 1 TO (rrec - 1))
       IF (cnvtupper(temp->appts[rec].locations[lrec].request_queues[ii].request_queue)=cnvtupper(
        temp->appts[rec].locations[lrec].request_queues[rrec].request_queue)
        AND cnvtupper(temp->appts[rec].locations[lrec].request_queues[ii].request_queue_action)=
       cnvtupper(temp->appts[rec].locations[lrec].request_queues[rrec].request_queue_action))
        SET temp->appts[rec].locations[lrec].request_queues[rrec].action_flag = 0
        SET temp->appts[rec].locations[lrec].request_queues[rrec].error_string = "Already Defined"
       ENDIF
     ENDFOR
     IF ((requestin->list_0[i].request_queue_rule > " "))
      SELECT INTO "NL:"
       FROM sch_flex_string s
       PLAN (s
        WHERE s.mnemonic_key=cnvtupper(requestin->list_0[i].request_queue_rule)
         AND s.flex_type_cd=request_list_flex_type_cd)
       DETAIL
        temp->appts[rec].locations[lrec].request_queues[rrec].rule_id = s.sch_flex_id
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET temp->appts[rec].locations[lrec].request_queues[rrec].action_flag = 0
       SET temp->appts[rec].locations[lrec].request_queues[rrec].error_string = "Flex Rule"
      ENDIF
     ENDIF
     SELECT INTO "NL:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=14232
        AND c.active_ind=1
        AND cnvtupper(c.display)=cnvtupper(requestin->list_0[i].request_queue_action))
      DETAIL
       temp->appts[rec].locations[lrec].request_queues[rrec].request_queue_action = c.display, temp->
       appts[rec].locations[lrec].request_queues[rrec].request_queue_action_cd = c.code_value, temp->
       appts[rec].locations[lrec].request_queues[rrec].request_queue_action_mean = c.cdf_meaning
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET temp->appts[rec].locations[lrec].request_queues[rrec].action_flag = 0
      SET temp->appts[rec].locations[lrec].request_queues[rrec].error_string = "Disp CS 14232"
     ELSE
      IF ((temp->appts[rec].locations[lrec].request_queues[rrec].request_queue_id > 0))
       SELECT INTO "NL:"
        FROM sch_appt_routing s
        PLAN (s
         WHERE s.active_ind=1
          AND (s.appt_type_cd=temp->appts[rec].appt_type_cd)
          AND (s.location_cd=temp->appts[rec].locations[lrec].location_cd)
          AND (s.sch_action_cd=temp->appts[rec].locations[lrec].request_queues[rrec].
         request_queue_action_cd)
          AND (s.routing_id=temp->appts[rec].locations[lrec].request_queues[rrec].request_queue_id))
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET temp->appts[rec].locations[lrec].request_queues[rrec].action_flag = 0
        SET temp->appts[rec].locations[lrec].request_queues[rrec].error_string = "Already Linked"
       ENDIF
      ENDIF
      IF ((temp->appts[rec].locations[lrec].request_queues[rrec].action_flag > 0))
       SELECT INTO "NL:"
        start_seq = count(*)
        FROM sch_appt_routing s
        PLAN (s
         WHERE s.active_ind=1
          AND (s.appt_type_cd=temp->appts[rec].appt_type_cd)
          AND (s.location_cd=temp->appts[rec].locations[lrec].location_cd)
          AND (s.sch_action_cd=temp->appts[rec].locations[lrec].request_queues[rrec].
         request_queue_action_cd))
        DETAIL
         temp->appts[rec].locations[lrec].request_queues[rrec].seq = (temp->appts[rec].locations[lrec
         ].request_queues[rrec].seq+ start_seq)
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FOR (i = 1 TO temp->appt_num)
   IF ((temp->appts[i].location_num=0))
    SET temp->appts[i].action_flag = 0
    SET temp->appts[i].error_string = "No Valid Locations"
   ENDIF
 ENDFOR
 FOR (i = 1 TO temp->appt_num)
   FOR (j = 1 TO temp->appts[i].location_num)
     FOR (k = 1 TO temp->appts[i].locations[j].guideline_num)
       SET valid = 0
       FOR (l = 1 TO temp->appts[i].locations[j].guidelines[k].guideline_num)
         IF ((temp->appts[i].locations[j].guidelines[k].guidelines[l].action_flag > 0))
          SET valid = 1
         ENDIF
       ENDFOR
       IF (valid=0)
        SET temp->appts[i].locations[j].guidelines[k].action_flag = 0
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 IF ((tempreq->insert_ind="Y"))
  FOR (i = 1 TO temp->appt_num)
    IF ((temp->appts[i].action_flag=1))
     SET add_code_value->code_set = 14230
     SET add_code_value->qual[1].cdf_meaning = ""
     SET add_code_value->qual[1].display = temp->appts[i].mnemonic
     SET add_code_value->qual[1].display_key = trim(cnvtupper(cnvtalphanum(temp->appts[i].mnemonic)),
      4)
     SET add_code_value->qual[1].description = temp->appts[i].mnemonic
     SET add_code_value->qual[1].definition = temp->appts[i].mnemonic
     SET add_code_value->qual[1].collation_seq = 0
     SET add_code_value->qual[1].active_type_cd = active_cd
     SET add_code_value->qual[1].active_ind = 1
     SET add_code_value->qual[1].authentic_ind = 1
     SET add_code_value->qual[1].extension_cnt = 0
     SET add_code_value->qual[1].extension_data[1].field_name = ""
     SET add_code_value->qual[1].extension_data[1].field_type = 0
     SET add_code_value->qual[1].extension_data[1].field_value = ""
     EXECUTE cs_add_code  WITH replace("REQUEST",add_code_value), replace("REPLY",reply_code_value)
     SET temp->appts[i].appt_type_cd = reply_code_value->qual[1].code_value
     SET add_code_value->code_set = 14249
     SET add_code_value->qual[1].cdf_meaning = ""
     SET add_code_value->qual[1].display = temp->appts[i].mnemonic
     SET add_code_value->qual[1].display_key = trim(cnvtupper(cnvtalphanum(temp->appts[i].mnemonic)),
      4)
     SET add_code_value->qual[1].description = temp->appts[i].mnemonic
     SET add_code_value->qual[1].definition = temp->appts[i].mnemonic
     SET add_code_value->qual[1].collation_seq = 0
     SET add_code_value->qual[1].active_type_cd = active_cd
     SET add_code_value->qual[1].active_ind = 1
     SET add_code_value->qual[1].authentic_ind = 1
     SET add_code_value->qual[1].extension_cnt = 0
     SET add_code_value->qual[1].extension_data[1].field_name = ""
     SET add_code_value->qual[1].extension_data[1].field_type = 0
     SET add_code_value->qual[1].extension_data[1].field_value = ""
     EXECUTE cs_add_code  WITH replace("REQUEST",add_code_value), replace("REPLY",reply_code_value)
     SET temp->appts[i].appt_syn_cd = reply_code_value->qual[1].code_value
    ENDIF
  ENDFOR
  INSERT  FROM sch_appt_type s,
    (dummyt d  WITH seq = temp->appt_num)
   SET s.seq = 1, s.appt_type_cd = temp->appts[d.seq].appt_type_cd, s.version_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"),
    s.oe_format_id = temp->appts[d.seq].accept_format_id, s.description = temp->appts[d.seq].mnemonic,
    s.info_sch_text_id = 0.0,
    s.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), s.candidate_id = seq(sch_candidate_seq,
     nextval), s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    s.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), s.active_ind = 1, s
    .active_status_cd = active_cd,
    s.active_status_prsnl_id = reqinfo->updt_id, s.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx,
    s.updt_cnt = 0, s.person_accept_cd = required_accept_cd, s.person_accept_meaning = "REQUIRED",
    s.recur_cd = optional_recur_cd, s.recur_meaning = "OPTIONAL", s.grp_resource_cd = 0.0,
    s.grp_prompt_cd = 0.0
   PLAN (d
    WHERE (temp->appts[d.seq].action_flag=1))
    JOIN (s)
   WITH nocounter
  ;end insert
  INSERT  FROM sch_appt_syn s,
    (dummyt d  WITH seq = temp->appt_num)
   SET s.seq = 1, s.appt_synonym_cd = temp->appts[d.seq].appt_syn_cd, s.version_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"),
    s.mnemonic = temp->appts[d.seq].mnemonic, s.mnemonic_key = cnvtupper(temp->appts[d.seq].mnemonic),
    s.allow_selection_flag = 1,
    s.info_sch_text_id = 0.0, s.appt_type_cd = temp->appts[d.seq].appt_type_cd, s.oe_format_id = temp
    ->appts[d.seq].accept_format_id,
    s.primary_ind = 1, s.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), s.order_sentence_id = 0.0,
    s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm = cnvtdatetime(curdate,
     curtime3), s.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
    s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_prsnl_id = reqinfo->updt_id,
    s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), s.updt_id = reqinfo->updt_id,
    s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0,
    s.appt_type_flag = 0
   PLAN (d
    WHERE (temp->appts[d.seq].action_flag=1))
    JOIN (s)
   WITH nocounter
  ;end insert
  INSERT  FROM sch_appt_product s,
    (dummyt d  WITH seq = temp->appt_num)
   SET s.seq = 1, s.appt_type_cd = temp->appts[d.seq].appt_type_cd, s.product_cd =
    appt_book_product_cd,
    s.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), s.version_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), s.candidate_id = seq(sch_candidate_seq,nextval),
    s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), s.active_ind = 1,
    s.active_status_cd = active_cd, s.active_status_prsnl_id = reqinfo->updt_id, s
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
    reqinfo->updt_task,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.product_meaning = "APPTBOOK"
   PLAN (d
    WHERE (temp->appts[d.seq].action_flag=1))
    JOIN (s)
   WITH nocounter
  ;end insert
  FOR (i = 1 TO temp->appt_num)
    FOR (j = 1 TO temp->appts[i].location_num)
      IF ((temp->appts[i].locations[j].action_flag > 0))
       IF ((temp->appts[i].locations[j].action_flag=1))
        INSERT  FROM sch_appt_loc s
         SET s.seq = 1, s.appt_type_cd = temp->appts[i].appt_type_cd, s.location_cd = temp->appts[i].
          locations[j].location_cd,
          s.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), s.version_dt_tm = cnvtdatetime(
           "31-dec-2100 00:00:00"), s.candidate_id = seq(sch_candidate_seq,nextval),
          s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm =
          cnvtdatetime("31-dec-2100 00:00:00"), s.active_ind = 1,
          s.active_status_cd = active_cd, s.active_status_prsnl_id = reqinfo->updt_id, s
          .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
          s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
          reqinfo->updt_task,
          s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.res_list_id = 0.0,
          s.sch_flex_id = temp->appts[i].locations[j].rule_id, s.grp_res_list_id = 0.0
         WITH nocounter
        ;end insert
       ENDIF
       FOR (k = 1 TO temp->appts[i].locations[j].guideline_num)
         IF ((temp->appts[i].locations[j].guidelines[k].action_flag=1))
          SELECT INTO "NL:"
           nextseqnum = seq(sched_reference_seq,nextval)"##################;RP0"
           FROM dual
           DETAIL
            temp->appts[i].locations[j].guidelines[k].guideline_parent_id = cnvtint(nextseqnum)
           WITH nocounter, format
          ;end select
         ENDIF
       ENDFOR
       INSERT  FROM (dummyt d  WITH seq = temp->appts[i].locations[j].guideline_num),
         sch_text_link stl
        SET stl.seq = 1, stl.parent_table = "CODE_VALUE", stl.parent_id = temp->appts[i].appt_type_cd,
         stl.parent2_table = "CODE_VALUE", stl.parent2_id = temp->appts[i].locations[j].location_cd,
         stl.parent3_table = "CODE_VALUE",
         stl.parent3_id = temp->appts[i].locations[j].guidelines[d.seq].guideline_action_cd, stl
         .parent3_meaning = temp->appts[i].locations[j].guidelines[d.seq].guideline_action_mean, stl
         .text_type_cd = guideline_type_cd,
         stl.sub_text_cd = guideline_sub_type_cd, stl.version_dt_tm = cnvtdatetime(
          "31-dec-2100 00:00:00"), stl.text_type_meaning = "GUIDELINE",
         stl.sub_text_meaning = "GUIDELINE", stl.text_accept_cd = 0.0, stl.template_accept_cd = 0.0,
         stl.lapse_units = 0.0, stl.lapse_units_cd = 0.0, stl.expertise_level = 0.0,
         stl.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), stl.candidate_id = seq(
          sch_candidate_seq,nextval), stl.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         stl.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), stl.active_ind = 1, stl
         .active_status_cd = active_cd,
         stl.active_status_prsnl_id = reqinfo->updt_id, stl.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3), stl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         stl.updt_id = reqinfo->updt_id, stl.updt_task = reqinfo->updt_task, stl.updt_applctx =
         reqinfo->updt_applctx,
         stl.updt_cnt = 0, stl.text_link_id = temp->appts[i].locations[j].guidelines[d.seq].
         guideline_parent_id
        PLAN (d
         WHERE (temp->appts[i].locations[j].guidelines[d.seq].action_flag=1))
         JOIN (stl)
        WITH nocounter
       ;end insert
       FOR (k = 1 TO temp->appts[i].locations[j].guideline_num)
         INSERT  FROM (dummyt d  WITH seq = temp->appts[i].locations[j].guidelines[k].guideline_num),
           sch_sub_list ssl
          SET ssl.seq = 1, ssl.parent_table = "SCH_TEXT_LINK", ssl.parent_id = temp->appts[i].
           locations[j].guidelines[k].guideline_parent_id,
           ssl.required_ind = 0, ssl.seq_nbr = temp->appts[i].locations[j].guidelines[k].guidelines[d
           .seq].seq, ssl.template_id = temp->appts[i].locations[j].guidelines[k].guidelines[d.seq].
           guideline_id,
           ssl.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), ssl.null_dt_tm = cnvtdatetime(
            "31-dec-2100 00:00:00"), ssl.candidate_id = seq(sch_candidate_seq,nextval),
           ssl.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ssl.end_effective_dt_tm =
           cnvtdatetime("31-dec-2100 00:00:00"), ssl.active_ind = 1,
           ssl.active_status_cd = active_cd, ssl.active_status_prsnl_id = reqinfo->updt_id, ssl
           .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
           ssl.updt_dt_tm = cnvtdatetime(curdate,curtime3), ssl.updt_id = reqinfo->updt_id, ssl
           .updt_task = reqinfo->updt_task,
           ssl.updt_applctx = reqinfo->updt_applctx, ssl.updt_cnt = 0, ssl.sch_flex_id = 0.0
          PLAN (d
           WHERE (temp->appts[i].locations[j].guidelines[k].guidelines[d.seq].action_flag=1))
           JOIN (ssl)
          WITH nocounter
         ;end insert
       ENDFOR
       FOR (k = 1 TO temp->appts[i].locations[j].request_queue_num)
         IF ((temp->appts[i].locations[j].request_queues[k].action_flag=1))
          SELECT INTO "NL:"
           nextseqnum = seq(sched_reference_seq,nextval)"##################;RP0"
           FROM dual
           DETAIL
            temp->appts[i].locations[j].request_queues[k].request_queue_id = cnvtint(nextseqnum)
           WITH nocounter, format
          ;end select
         ENDIF
       ENDFOR
       INSERT  FROM sch_object s,
         (dummyt d  WITH seq = temp->appts[i].locations[j].request_queue_num)
        SET s.seq = 1, s.sch_object_id = temp->appts[i].locations[j].request_queues[d.seq].
         request_queue_id, s.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
         s.mnemonic = temp->appts[i].locations[j].request_queues[d.seq].request_queue, s.mnemonic_key
          = cnvtupper(temp->appts[i].locations[j].request_queues[d.seq].request_queue), s.description
          = temp->appts[i].locations[j].request_queues[d.seq].request_queue,
         s.info_sch_text_id = 0.0, s.object_type_cd = queue_type_cd, s.object_type_meaning = "QUEUE",
         s.object_sub_cd = queue_sub_type_cd, s.object_sub_meaning = "QUEUE", s.null_dt_tm =
         cnvtdatetime("31-dec-2100 00:00:00"),
         s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm = cnvtdatetime(
          curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
         s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_prsnl_id = reqinfo->
         updt_id,
         s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm = cnvtdatetime(curdate,
          curtime3), s.updt_id = reqinfo->updt_id,
         s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0
        PLAN (d
         WHERE (temp->appts[i].locations[j].request_queues[d.seq].action_flag=1))
         JOIN (s)
       ;end insert
       INSERT  FROM sch_appt_routing s,
         (dummyt d  WITH seq = temp->appts[i].locations[j].request_queue_num)
        SET s.seq = 1, s.appt_type_cd = temp->appts[i].appt_type_cd, s.location_cd = temp->appts[i].
         locations[j].location_cd,
         s.sch_action_cd = temp->appts[i].locations[j].request_queues[d.seq].request_queue_action_cd,
         s.seq_nbr = temp->appts[i].locations[j].request_queues[d.seq].seq, s.version_dt_tm =
         cnvtdatetime("31-dec-2100 00:00:00"),
         s.action_meaning = temp->appts[i].locations[j].request_queues[d.seq].
         request_queue_action_mean, s.beg_units = 0, s.beg_units_cd = 0.0,
         s.end_units = 0, s.end_units_cd = 0.0, s.routing_table = "SCH_OBJECT",
         s.routing_id = temp->appts[i].locations[j].request_queues[d.seq].request_queue_id, s
         .sch_flex_id = temp->appts[i].locations[j].request_queues[d.seq].rule_id, s.null_dt_tm =
         cnvtdatetime("31-dec-2100 00:00:00"),
         s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm = cnvtdatetime(
          curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
         s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_prsnl_id = reqinfo->
         updt_id,
         s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm = cnvtdatetime(curdate,
          curtime3), s.updt_id = reqinfo->updt_id,
         s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0
        PLAN (d
         WHERE (temp->appts[i].locations[j].request_queues[d.seq].action_flag > 0))
         JOIN (s)
        WITH nocounter
       ;end insert
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = temp->appt_num)
  DETAIL
   col 8, temp->appts[d.seq].row"#####", col 20,
   temp->appts[d.seq].mnemonic
   IF ((temp->appts[d.seq].action_flag=1))
    IF ((tempreq->insert_ind="Y"))
     col 95, "Added"
    ELSE
     col 95, "Verified A"
    ENDIF
   ELSEIF ((temp->appts[d.seq].action_flag=2))
    IF ((tempreq->insert_ind="Y"))
     col 95, "Updated"
    ELSE
     col 95, "Verified U"
    ENDIF
   ELSE
    col 95, "Error"
   ENDIF
   col 105, temp->appts[d.seq].error_string, row + 1
   FOR (i = 1 TO temp->appts[d.seq].location_num)
     col 8, temp->appts[d.seq].locations[i].row"#####", col 40,
     temp->appts[d.seq].locations[i].location
     IF ((temp->appts[d.seq].locations[i].action_flag=1))
      IF ((tempreq->insert_ind="Y"))
       col 95, "Added"
      ELSE
       col 95, "Verified A"
      ENDIF
     ELSEIF ((temp->appts[d.seq].locations[i].action_flag=2))
      IF ((tempreq->insert_ind="Y"))
       col 95, "Updated"
      ELSE
       col 95, "Verified U"
      ENDIF
     ELSE
      col 95, "Error"
     ENDIF
     col 105, temp->appts[d.seq].locations[i].error_string, row + 1
     FOR (j = 1 TO temp->appts[d.seq].locations[i].guideline_num)
       IF ((temp->appts[d.seq].locations[i].guidelines[j].guideline_num=0))
        row + 1, col 8, temp->appts[d.seq].locations[i].row"#####",
        col 95, "Error", col 105,
        temp->appts[d.seq].locations[i].error_string
       ELSE
        FOR (k = 1 TO temp->appts[d.seq].locations[i].guidelines[j].guideline_num)
          col 8, temp->appts[d.seq].locations[i].guidelines[j].row"#####", col 50,
          "Guideline", col 60, temp->appts[d.seq].locations[i].guidelines[j].guidelines[k].guideline,
          col 80, temp->appts[d.seq].locations[i].guidelines[j].guideline_action
          IF ((temp->appts[d.seq].locations[i].guidelines[j].guidelines[k].action_flag=1))
           IF ((tempreq->insert_ind="Y"))
            col 95, "Added"
           ELSE
            col 95, "Verified"
           ENDIF
          ELSE
           col 95, "Error"
          ENDIF
          col 105, temp->appts[d.seq].locations[i].guidelines[j].guidelines[k].error_string, row + 1
        ENDFOR
       ENDIF
     ENDFOR
     FOR (j = 1 TO temp->appts[d.seq].locations[i].request_queue_num)
       col 8, temp->appts[d.seq].locations[i].request_queues[j].row"#####", col 50,
       "Request Q", col 60, temp->appts[d.seq].locations[i].request_queues[j].request_queue,
       col 80, temp->appts[d.seq].locations[i].request_queues[j].request_queue_action
       IF ((temp->appts[d.seq].locations[i].request_queues[j].action_flag=1))
        IF ((tempreq->insert_ind="Y"))
         col 95, "Added"
        ELSE
         col 95, "Verified A"
        ENDIF
       ELSEIF ((temp->appts[d.seq].locations[i].request_queues[j].action_flag=2))
        IF ((tempreq->insert_ind="Y"))
         col 95, "Updated"
        ELSE
         col 95, "Verified U"
        ENDIF
       ELSE
        col 95, "Error"
       ENDIF
       col 105, temp->appts[d.seq].locations[i].request_queues[j].error_string, row + 1
     ENDFOR
   ENDFOR
   row + 1
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 SET error_flag2 = "N"
#exit_script
 IF (error_flag2="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 RETURN
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = "ccluserdir:"
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1
    DETAIL
     row + 2, col 10, "ROW",
     col 20, "APPOINTMENT TYPE", col 40,
     "LOCATION", col 50, "TYPE",
     col 60, "NAME", col 80,
     "ACTION", col 95, "STATUS",
     col 105, "ERROR"
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO

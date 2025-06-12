CREATE PROGRAM bed_ens_upd_ord_evnt_rels_disp:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orders[*]
      2 catalog_code_value = f8
      2 duplicate_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = size(request->orders,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->orders,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->orders[x].catalog_code_value = request->orders[x].catalog_code_value
   SET event_set_code_value = 0.0
   SELECT INTO "nl:"
    FROM v500_event_set_explode vee
    WHERE (vee.event_cd=request->orders[x].event_code_value)
     AND vee.event_set_level=0
    DETAIL
     event_set_code_value = vee.event_set_cd
    WITH nocounter
   ;end select
   IF (event_set_code_value=0.0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = build2(
     "Could not find the event set for ",request->orders[x].event_code_value)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=72
      AND cv.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
         event_code_display))))
      AND (cv.code_value != request->orders[x].event_code_value))
    DETAIL
     reply->orders[x].duplicate_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=93
      AND cv.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
         event_code_display))))
      AND cv.code_value != event_set_code_value)
    DETAIL
     reply->orders[x].duplicate_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    PLAN (v
     WHERE v.event_set_name_key=trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
         event_code_display))))
      AND trim(cnvtupper(v.event_set_name))=trim(cnvtupper(substring(1,40,request->orders[x].
        event_code_display)))
      AND v.event_set_cd != event_set_code_value)
    DETAIL
     reply->orders[x].duplicate_ind = 1
    WITH nocounter
   ;end select
   IF ((reply->orders[x].duplicate_ind=0))
    SET event_code_value = 0.0
    SET request_cv->cd_value_list[1].code_value = request->orders[x].event_code_value
    SET request_cv->cd_value_list[1].action_flag = 2
    SET request_cv->cd_value_list[1].code_set = 72
    SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->orders[x].
      event_code_display))
    SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->orders[x].
      event_code_display))
    SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->orders[x].
      event_code_display))
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET event_code_value = reply_cv->qual[1].code_value
    ELSE
     CALL echorecord(reply_cv)
     CALL echo(trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].event_code_display)))))
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on cs 72 update")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = request->orders[x].
     event_code_display
     GO TO exit_script
    ENDIF
    UPDATE  FROM v500_event_code vec
     SET vec.event_cd_definition = trim(substring(1,100,request->orders[x].event_code_display)), vec
      .event_cd_descr = trim(substring(1,60,request->orders[x].event_code_display)), vec
      .event_cd_disp = trim(substring(1,40,request->orders[x].event_code_display)),
      vec.event_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
          event_code_display)))), vec.updt_dt_tm = cnvtdatetime(curdate,curtime3), vec.updt_id =
      reqinfo->updt_id,
      vec.updt_task = reqinfo->updt_task, vec.updt_cnt = 0, vec.updt_applctx = reqinfo->updt_applctx
     WHERE vec.event_cd=event_code_value
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Error on v500_event_code update")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET request_cv->cd_value_list[1].code_value = event_set_code_value
    SET request_cv->cd_value_list[1].action_flag = 2
    SET request_cv->cd_value_list[1].code_set = 93
    SET request_cv->cd_value_list[1].description = trim(substring(1,60,request->orders[x].
      event_code_display))
    SET request_cv->cd_value_list[1].definition = trim(substring(1,100,request->orders[x].
      event_code_display))
    SET request_cv->cd_value_list[1].display = trim(substring(1,40,request->orders[x].
      event_code_display))
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     SET event_set_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on cs 93 update")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    UPDATE  FROM v500_event_set_code ves
     SET ves.event_set_cd_definition = trim(substring(1,100,request->orders[x].event_code_display)),
      ves.event_set_cd_descr = trim(substring(1,60,request->orders[x].event_code_display)), ves
      .event_set_cd_disp = trim(substring(1,40,request->orders[x].event_code_display)),
      ves.event_set_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->orders[x].
          event_code_display)))), ves.updt_dt_tm = cnvtdatetime(curdate,curtime3), ves.updt_id =
      reqinfo->updt_id,
      ves.updt_task = reqinfo->updt_task, ves.updt_cnt = 0, ves.updt_applctx = reqinfo->updt_applctx
     WHERE ves.event_set_cd=event_set_code_value
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = build(
      "Error on v500_event_set_code update")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    IF ((request->orders[x].immunization_ind=0))
     SELECT INTO "nl:"
      FROM code_value_extension c
      PLAN (c
       WHERE (c.code_value=request->orders[x].catalog_code_value)
        AND c.code_set=200
        AND c.field_name="IMMUNIZATIONIND")
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET ierrcode = 0
      UPDATE  FROM code_value_extension c
       SET c.field_value = "0", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->
        updt_id,
        c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->
        updt_applctx
       WHERE (c.code_value=request->orders[x].catalog_code_value)
        AND c.code_set=200
        AND c.field_name="IMMUNIZATIONIND"
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on extension update")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM code_value_extension c
      PLAN (c
       WHERE (c.code_value=request->orders[x].catalog_code_value)
        AND c.code_set=200
        AND c.field_name="IMMUNIZATIONIND")
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET ierrcode = 0
      INSERT  FROM code_value_extension c
       SET c.code_value = request->orders[x].catalog_code_value, c.code_set = 200, c.field_name =
        "IMMUNIZATIONIND",
        c.field_type = 1, c.field_value = "1", c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
        c.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on extension insert")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ELSE
      SET ierrcode = 0
      UPDATE  FROM code_value_extension c
       SET c.field_value = "1", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->
        updt_id,
        c.updt_task = reqinfo->updt_task, c.updt_cnt = (c.updt_cnt+ 1), c.updt_applctx = reqinfo->
        updt_applctx
       WHERE (c.code_value=request->orders[x].catalog_code_value)
        AND c.code_set=200
        AND c.field_name="IMMUNIZATIONIND"
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = build("Error on extension update")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO

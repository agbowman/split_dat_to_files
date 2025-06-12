CREATE PROGRAM dcp_upd_person_working_view:dba
 SET modify = predeclare
 RECORD reply(
   1 working_view_person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE log_status(operationname=vc,operationstatus=vc,targetobjectname=vc,targetobjectvalue=vc) =
 null
 DECLARE log_count = i4 WITH noconstant(0)
 SUBROUTINE log_status(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET log_count = size(reply->status_data.subeventstatus,5)
   IF (log_count=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET log_count = (log_count+ 1)
    ENDIF
   ELSE
    SET log_count = (log_count+ 1)
   ENDIF
   SET stat = alter(reply->status_data.subeventstatus,log_count)
   SET reply->status_data.subeventstatus[log_count].operationname = operationname
   SET reply->status_data.subeventstatus[log_count].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[log_count].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[log_count].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 DECLARE updatepersonworkingview(p1=f8(ref)) = null
 DECLARE insertnewpersonworkingview(p1=i2(ref)) = null
 DECLARE insertnewpersonworkingviewsection(p1=i4(ref)) = null
 DECLARE insertnewpersonworkingviewitem(p1=i4(ref)) = null
 SET reply->status_data.status = "F"
 DECLARE err_msg = vc
 DECLARE dummy_val = i2 WITH noconstant(0)
 DECLARE wvp_id = f8 WITH noconstant(0.0)
 DECLARE sections_to_add = i4 WITH noconstant(0)
 DECLARE sect_idx = i4 WITH noconstant(0)
 DECLARE items_to_add = i4 WITH noconstant(0)
 DECLARE item_idx = i4 WITH noconstant(0)
 DECLARE wvps_id = f8 WITH noconstant(0.0)
 DECLARE wvpi_id = f8 WITH noconstant(0.0)
 DECLARE failed = c1 WITH noconstant("F")
 SELECT INTO "nl:"
  FROM working_view_person wvp
  WHERE (wvp.working_view_id=request->working_view_id)
   AND (wvp.encntr_id=request->encntr_id)
  DETAIL
   wvp_id = wvp.working_view_person_id
  WITH nocounter, forupdate(wvp)
 ;end select
 IF (curqual=0)
  CALL insertnewpersonworkingview(dummy_val)
 ELSE
  CALL updatepersonworkingview(wvp_id)
 ENDIF
 SET reply->working_view_person_id = wvp_id
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SUBROUTINE updatepersonworkingview(wvp_id)
   UPDATE  FROM working_view_person wvp
    SET wvp.updt_id = reqinfo->updt_id, wvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), wvp
     .updt_task = reqinfo->updt_task,
     wvp.updt_applctx = reqinfo->updt_applctx, wvp.updt_cnt = (wvp.updt_cnt+ 1)
    WHERE wvp.working_view_person_id=wvp_id
    WITH nocounter
   ;end update
   SET sections_to_add = size(request->working_view_person_sections,5)
   FOR (sect_idx = 1 TO sections_to_add)
    SELECT INTO "nl:"
     FROM working_view_person_sect wvps
     WHERE wvps.working_view_person_id=wvp_id
      AND (wvps.event_set_name=request->working_view_person_sections[sect_idx].event_set_name)
     DETAIL
      wvps_id = wvps.working_view_person_sect_id
     WITH nocounter, forupdate(wvps)
    ;end select
    IF (curqual=0)
     CALL insertnewpersonworkingviewsection(sect_idx)
    ELSE
     UPDATE  FROM working_view_person_sect wvps
      SET wvps.included_ind = request->working_view_person_sections[sect_idx].included_ind, wvps
       .updt_applctx = reqinfo->updt_applctx, wvps.updt_cnt = (wvps.updt_cnt+ 1),
       wvps.updt_dt_tm = cnvtdatetime(curdate,curtime3), wvps.updt_id = reqinfo->updt_id, wvps
       .updt_task = reqinfo->updt_task
      WHERE wvps.working_view_person_sect_id=wvps_id
      WITH nocounter
     ;end update
     SET items_to_add = size(request->working_view_person_sections[sect_idx].
      working_view_person_items,5)
     FOR (item_idx = 1 TO items_to_add)
      SELECT INTO "nl:"
       FROM working_view_personitem wvpi
       WHERE wvpi.working_view_person_sect_id=wvps_id
        AND (wvpi.parent_event_set_name=request->working_view_person_sections[sect_idx].
       working_view_person_items[item_idx].parent_event_set_name)
        AND (wvpi.primitive_event_set_name=request->working_view_person_sections[sect_idx].
       working_view_person_items[item_idx].primitive_event_set_name)
       DETAIL
        wvpi_id = wvpi.working_view_personitem_id
       WITH nocounter, forupdate(wvpi)
      ;end select
      IF (curqual=0)
       CALL insertnewpersonworkingviewitem(item_idx)
      ELSE
       UPDATE  FROM working_view_personitem wvpi
        SET wvpi.included_ind = request->working_view_person_sections[sect_idx].
         working_view_person_items[item_idx].included_ind, wvpi.updt_applctx = reqinfo->updt_applctx,
         wvpi.updt_cnt = (wvpi.updt_cnt+ 1),
         wvpi.updt_dt_tm = cnvtdatetime(curdate,curtime3), wvpi.updt_id = reqinfo->updt_id, wvpi
         .updt_task = reqinfo->updt_task,
         wvpi.last_action_dt_tm = cnvtdatetime(curdate,curtime3)
        WHERE wvpi.working_view_personitem_id=wvpi_id
        WITH nocounter
       ;end update
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE insertnewpersonworkingview(dummy_val)
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     wvp_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   IF (error(err_msg,1) != 0)
    SET failed = "T"
    CALL log_status("SEQUENCE","F","WORKING_VIEW_PERSON",err_msg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET err_msg = "unable to generate sequence for working_view_person table"
    SET failed = "T"
    CALL log_status("SEQUENCE","F","WORKING_VIEW_PERSON",err_msg)
    GO TO exit_script
   ENDIF
   INSERT  FROM working_view_person wvp
    SET wvp.working_view_person_id = wvp_id, wvp.working_view_id = request->working_view_id, wvp
     .person_id = request->person_id,
     wvp.encntr_id = request->encntr_id, wvp.updt_id = reqinfo->updt_id, wvp.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     wvp.updt_task = reqinfo->updt_task, wvp.updt_applctx = reqinfo->updt_applctx, wvp.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (error(err_msg,1) != 0)
    SET failed = "T"
    CALL log_status("INSERT","F","WORKING_VIEW_PERSON",err_msg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET err_msg = "unable to insert into working_view_person table"
    SET failed = "T"
    CALL log_status("INSERT","F","WORKING_VIEW_PERSON",err_msg)
    GO TO exit_script
   ENDIF
   SET sections_to_add = size(request->working_view_person_sections,5)
   FOR (sect_idx = 1 TO sections_to_add)
     CALL insertnewpersonworkingviewsection(sect_idx)
   ENDFOR
 END ;Subroutine
 SUBROUTINE insertnewpersonworkingviewsection(sect_idx)
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     wvps_id = nextseqnum
    WITH nocounter
   ;end select
   IF (error(err_msg,1) != 0)
    SET failed = "T"
    CALL log_status("SEQUENCE","F","WORKING_VIEW_PERSON_SECT",err_msg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET err_msg = "unable to generate sequence for working_view_person_sect table"
    SET failed = "T"
    CALL log_status("SEQUENCE","F","WORKING_VIEW_PERSON_SECT",err_msg)
    GO TO exit_script
   ENDIF
   INSERT  FROM working_view_person_sect wvps
    SET wvps.working_view_person_sect_id = wvps_id, wvps.working_view_person_id = wvp_id, wvps
     .event_set_name = request->working_view_person_sections[sect_idx].event_set_name,
     wvps.included_ind = request->working_view_person_sections[sect_idx].included_ind, wvps
     .section_type_flag = request->working_view_person_sections[sect_idx].section_type_flag, wvps
     .updt_id = reqinfo->updt_id,
     wvps.updt_dt_tm = cnvtdatetime(curdate,curtime3), wvps.updt_task = reqinfo->updt_task, wvps
     .updt_applctx = reqinfo->updt_applctx,
     wvps.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (error(err_msg,1) != 0)
    SET failed = "T"
    CALL log_status("INSERT","F","WORKING_VIEW_PERSON_SECT",err_msg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET err_msg = "unable to insert into working_view_person_sect table"
    SET failed = "T"
    CALL log_status("INSERT","F","WORKING_VIEW_PERSON_SECT",err_msg)
    GO TO exit_script
   ENDIF
   SET items_to_add = size(request->working_view_person_sections[sect_idx].working_view_person_items,
    5)
   FOR (item_idx = 1 TO items_to_add)
     CALL insertnewpersonworkingviewitem(item_idx)
   ENDFOR
 END ;Subroutine
 SUBROUTINE insertnewpersonworkingviewitem(item_idx)
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     wvpi_id = nextseqnum
    WITH nocounter
   ;end select
   IF (error(err_msg,1) != 0)
    SET failed = "T"
    CALL log_status("SEQUENCE","F","WORKING_VIEW_PERSONITEM",err_msg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET err_msg = "unable to generate sequence for working_view_personitem table"
    SET failed = "T"
    CALL log_status("SEQUENCE","F","WORKING_VIEW_PERSONITEM",err_msg)
    GO TO exit_script
   ENDIF
   INSERT  FROM working_view_personitem wvpi
    SET wvpi.working_view_personitem_id = wvpi_id, wvpi.working_view_person_sect_id = wvps_id, wvpi
     .primitive_event_set_name = request->working_view_person_sections[sect_idx].
     working_view_person_items[item_idx].primitive_event_set_name,
     wvpi.parent_event_set_name = request->working_view_person_sections[sect_idx].
     working_view_person_items[item_idx].parent_event_set_name, wvpi.included_ind = request->
     working_view_person_sections[sect_idx].working_view_person_items[item_idx].included_ind, wvpi
     .updt_id = reqinfo->updt_id,
     wvpi.updt_dt_tm = cnvtdatetime(curdate,curtime3), wvpi.updt_task = reqinfo->updt_task, wvpi
     .updt_applctx = reqinfo->updt_applctx,
     wvpi.updt_cnt = 0, wvpi.last_action_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (error(err_msg,1) != 0)
    SET failed = "T"
    CALL log_status("INSERT","F","WORKING_VIEW_PERSONITEM",err_msg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET err_msg = "unable to insert into working_view_personitem table"
    SET failed = "T"
    CALL log_status("INSERT","F","WORKING_VIEW_PERSONITEM",err_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
END GO

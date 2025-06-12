CREATE PROGRAM bed_imp_him_locs
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
   1 list_0[*]
     2 action_flag = i2
     2 error_string = vc
     2 organization_id = f8
     2 location_cd = f8
     2 building_cd = f8
     2 facility_cd = f8
     2 parent_view_cd = f8
     2 sequence = i4
     2 phone[3]
       3 phone_number = vc
       3 phone_ext = vc
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
     2 rec_status = vc
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
#1000_initialize
 SET write_mode = 0
 IF ((tempreq->insert_ind="Y"))
  SET write_mode = 1
 ENDIF
 SET reply->status_data.status = "F"
 SET error_flag = "Y"
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET active_cd = get_code_value(48,"ACTIVE")
 SET inactive_cd = get_code_value(48,"INACTIVE")
 SET auth_cd = get_code_value(8,"AUTH")
 SET him_cd = get_code_value(222,"HIM")
 SET building_cd = get_code_value(222,"BUILDING")
 SET business_phone_cd = get_code_value(43,"BUSINESS")
 SET freetext_cd = get_code_value(281,"FREETEXT")
 SET numrows = size(requestin->list_0,5)
 IF (numrows=0)
  SET error_msg = "No rows to process"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp->list_0,numrows)
 SET title = validate(log_title_set,"HIM Chart Location and Phone Number Import")
 SET name = validate(log_name_set,"bed_him_locs.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 SET i = 0
#next_rec
 SET i = (i+ 1)
 IF (i > numrows)
  GO TO end_loop
 ENDIF
 SET temp->list_0[i].parent_view_cd = get_cv_by_disp_cdf(220,cnvtupper(requestin->list_0[i].himview),
  "HIMROOT")
 IF ((temp->list_0[i].parent_view_cd=0))
  SET temp->list_0[i].error_string = "Invalid HIM View"
  GO TO next_rec
 ENDIF
 SELECT INTO "NL:"
  FROM location_group l,
   code_value c
  PLAN (c
   WHERE cnvtupper(c.display)=cnvtupper(requestin->list_0[i].facility)
    AND cnvtupper(c.cdf_meaning)="FACILITY"
    AND c.active_ind=1)
   JOIN (l
   WHERE (l.root_loc_cd=temp->list_0[i].parent_view_cd)
    AND l.child_loc_cd=c.code_value
    AND l.active_ind=1)
  DETAIL
   temp->list_0[i].facility_cd = c.code_value
  WITH nocounter
 ;end select
 IF ((temp->list_0[i].facility_cd=0))
  SET temp->list_0[i].error_string = "Invalid Facility for View"
  GO TO next_rec
 ENDIF
 SELECT INTO "NL:"
  FROM location l
  PLAN (l
   WHERE (l.location_cd=temp->list_0[i].facility_cd)
    AND l.active_ind=1)
  DETAIL
   temp->list_0[i].organization_id = l.organization_id
  WITH nocounter
 ;end select
 IF ((temp->list_0[i].organization_id=0))
  SET temp->list_0[i].error_string = "Facility not Linked to Org"
  GO TO next_rec
 ENDIF
 SELECT INTO "NL:"
  FROM location_group l,
   code_value c
  PLAN (c
   WHERE cnvtupper(c.display)=cnvtupper(requestin->list_0[i].building)
    AND cnvtupper(c.cdf_meaning)="BUILDING"
    AND c.active_ind=1)
   JOIN (l
   WHERE (l.parent_loc_cd=temp->list_0[i].facility_cd)
    AND (l.root_loc_cd=temp->list_0[i].parent_view_cd)
    AND l.child_loc_cd=c.code_value
    AND l.active_ind=1)
  DETAIL
   temp->list_0[i].building_cd = c.code_value
  WITH nocounter
 ;end select
 IF ((temp->list_0[i].building_cd=0))
  SET temp->list_0[i].error_string = "Invalid Building for View"
  GO TO next_rec
 ENDIF
 SELECT INTO "NL:"
  FROM location_group l,
   code_value c
  PLAN (c
   WHERE cnvtupper(c.display)=cnvtupper(requestin->list_0[i].display)
    AND c.active_ind=1)
   JOIN (l
   WHERE (l.parent_loc_cd=temp->list_0[i].building_cd)
    AND (l.root_loc_cd=temp->list_0[i].parent_view_cd)
    AND l.child_loc_cd=c.code_value
    AND l.active_ind=1)
  DETAIL
   temp->list_0[i].location_cd = c.code_value
   IF (c.cdf_meaning="HIM")
    temp->list_0[i].action_flag = 3
   ELSE
    temp->list_0[i].action_flag = 2
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "NL:"
   FROM location_group l,
    code_value c
   PLAN (c
    WHERE cnvtupper(c.display)=cnvtupper(requestin->list_0[i].display)
     AND c.active_ind=1)
    JOIN (l
    WHERE (l.parent_loc_cd=temp->list_0[i].building_cd)
     AND l.root_loc_cd=0
     AND l.child_loc_cd=c.code_value
     AND l.active_ind=1)
   DETAIL
    temp->list_0[i].location_cd = c.code_value, temp->list_0[i].action_flag = 1
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF ((requestin->list_0[i].description > " "))
    SET temp->list_0[i].action_flag = 4
   ELSE
    SET temp->list_0[i].error_string = "Blank Description"
   ENDIF
  ENDIF
 ENDIF
 SET temp->list_0[i].phone[1].phone_number = requestin->list_0[i].phone_number1
 SET temp->list_0[i].phone[1].phone_ext = requestin->list_0[i].phone_ext1
 SET temp->list_0[i].phone[2].phone_number = requestin->list_0[i].phone_number2
 SET temp->list_0[i].phone[2].phone_ext = requestin->list_0[i].phone_ext2
 SET temp->list_0[i].phone[3].phone_number = requestin->list_0[i].phone_number3
 SET temp->list_0[i].phone[3].phone_ext = requestin->list_0[i].phone_ext3
 GO TO next_rec
#end_loop
 IF (write_mode=1)
  FOR (i = 1 TO numrows)
    IF ((temp->list_0[i].action_flag=4))
     SET add_code_value->code_set = 220
     SET add_code_value->qual[1].cdf_meaning = "HIM"
     SET add_code_value->qual[1].display = requestin->list_0[i].display
     SET add_code_value->qual[1].display_key = trim(cnvtupper(cnvtalphanum(requestin->list_0[i].
        display)),4)
     SET add_code_value->qual[1].description = requestin->list_0[i].description
     SET add_code_value->qual[1].definition = " "
     SET add_code_value->qual[1].collation_seq = 0
     IF (cnvtint(requestin->list_0[i].active)=1)
      SET add_code_value->qual[1].active_type_cd = active_cd
      SET add_code_value->qual[1].active_ind = 1
     ELSE
      SET add_code_value->qual[1].active_type_cd = inactive_cd
      SET add_code_value->qual[1].active_ind = 0
     ENDIF
     SET add_code_value->qual[1].authentic_ind = 1
     SET add_code_value->qual[1].extension_cnt = 0
     SET add_code_value->qual[1].extension_data[1].field_name = ""
     SET add_code_value->qual[1].extension_data[1].field_type = 0
     SET add_code_value->qual[1].extension_data[1].field_value = ""
     EXECUTE cs_add_code  WITH replace("REQUEST",add_code_value), replace("REPLY",reply_code_value)
     SET temp->list_0[i].location_cd = reply_code_value->qual[1].code_value
     INSERT  FROM location l
      SET l.seq = 1, l.active_ind = 1, l.active_status_cd = active_cd,
       l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = reqinfo->
       updt_id, l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       l.census_ind = 0, l.chart_format_id = 0, l.contributor_source_cd = 0,
       l.contributor_system_cd = 0, l.data_status_cd = auth_cd, l.data_status_dt_tm = cnvtdatetime(
        curdate,curtime3),
       l.data_status_prsnl_id = reqinfo->updt_id, l.discipline_type_cd = 0, l.end_effective_dt_tm =
       cnvtdatetime("31-dec-2100 00:00:00"),
       l.location_cd = temp->list_0[i].location_cd, l.location_type_cd = him_cd, l.organization_id =
       temp->list_0[i].organization_id,
       l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_task =
       reqinfo->updt_task,
       l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0
      WITH nocounter
     ;end insert
    ENDIF
    IF ((temp->list_0[i].action_flag=3))
     SET display = requestin->list_0[i].newdisplay
     SET display_key = trim(cnvtupper(cnvtalphanum(requestin->list_0[i].newdisplay)),4)
     UPDATE  FROM code_value c
      SET c.seq = 1, c.display =
       IF ((requestin->list_0[i].newdisplay > " ")) display
       ELSE c.display
       ENDIF
       , c.display_key =
       IF ((requestin->list_0[i].newdisplay > " ")) display_key
       ELSE c.display_key
       ENDIF
       ,
       c.description = requestin->list_0[i].description, c.updt_dt_tm = cnvtdatetime(curdate,curtime3
        ), c.active_ind = cnvtint(requestin->list_0[i].active),
       c.updt_id = reqinfo->updt_id, c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = reqinfo->updt_task,
       c.updt_applctx = reqinfo->updt_applctx
      WHERE (c.code_value=temp->list_0[i].location_cd)
     ;end update
    ENDIF
    IF ((((temp->list_0[i].action_flag=3)) OR ((temp->list_0[i].action_flag=2)))
     AND cnvtint(requestin->list_0[i].active)=0)
     UPDATE  FROM location_group l
      SET l.seq = 1, l.active_ind = 0, l.active_status_cd = inactive_cd
      WHERE (l.child_loc_cd=temp->list_0[i].location_cd)
       AND (l.parent_loc_cd=temp->list_0[i].building_cd)
       AND (l.root_loc_cd=temp->list_0[i].parent_view_cd)
     ;end update
    ENDIF
    IF ((((temp->list_0[i].action_flag=1)) OR ((temp->list_0[i].action_flag=4))) )
     SELECT INTO "NL:"
      cur_max = max(l.sequence)
      FROM location_group l
      WHERE (l.parent_loc_cd=temp->list_0[i].building_cd)
       AND l.location_group_type_cd=building_cd
       AND (l.root_loc_cd=temp->list_0[i].parent_view_cd)
      FOOT REPORT
       temp->list_0[i].sequence = (cur_max+ 1)
      WITH nocounter
     ;end select
     INSERT  FROM location_group l
      SET l.seq = 1, l.active_ind = 1, l.active_status_cd = active_cd,
       l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = reqinfo->
       updt_id, l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       l.child_loc_cd = temp->list_0[i].location_cd, l.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00"), l.location_group_type_cd = building_cd,
       l.parent_loc_cd = temp->list_0[i].building_cd, l.root_loc_cd = temp->list_0[i].parent_view_cd,
       l.sequence = temp->list_0[i].sequence,
       l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_cnt = 0,
       l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    IF ((temp->list_0[i].action_flag > 0))
     DELETE  FROM him_loc_extension h
      WHERE (h.location_cd=temp->list_0[i].location_cd)
      WITH nocounter
     ;end delete
     INSERT  FROM him_loc_extension h
      SET h.seq = 1, h.location_cd = temp->list_0[i].location_cd, h.medical_records_loc_ind = cnvtint
       (requestin->list_0[i].internal),
       h.permanent_loc_ind = cnvtint(requestin->list_0[i].permanent), h.auto_request_ind = cnvtint(
        requestin->list_0[i].autorequest), h.record_available_ind = cnvtint(requestin->list_0[i].
        recordavailable),
       h.active_ind = 1, h.active_status_cd = active_cd, h.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       h.active_status_prsnl_id = reqinfo->updt_id, h.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), h.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
       h.updt_dt_tm = cnvtdatetime(curdate,curtime3), h.updt_id = reqinfo->updt_id, h.updt_cnt = 0,
       h.updt_task = reqinfo->updt_task, h.updt_applctx = reqinfo->updt_applctx, h.auto_hold_ind =
       cnvtint(requestin->list_0[i].autohold),
       h.chartloan_days = cnvtreal(requestin->list_0[i].chartloandays), h.microfilm_ind = cnvtint(
        requestin->list_0[i].microfilm)
      WITH nocounter
     ;end insert
     DELETE  FROM phone p
      WHERE p.parent_entity_name="LOCATION"
       AND (p.parent_entity_id=temp->list_0[i].location_cd)
       AND p.phone_type_cd=business_phone_cd
      WITH nocounter
     ;end delete
     FOR (ii = 1 TO 3)
       IF ((temp->list_0[i].phone[ii].phone_number > " "))
        INSERT  FROM phone p
         SET p.seq = 1, p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "LOCATION",
          p.parent_entity_id = temp->list_0[i].location_cd, p.phone_type_cd = business_phone_cd, p
          .active_ind = 1,
          p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
          .active_status_prsnl_id = reqinfo->updt_id,
          p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_cnt = 0,
          p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.phone_format_cd
           = freetext_cd,
          p.phone_num = temp->list_0[i].phone[ii].phone_number, p.phone_type_seq = ii, p.extension =
          temp->list_0[i].phone[ii].phone_ext,
          p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm =
          cnvtdatetime("31-dec-2100 00:00:00"), p.data_status_cd = auth_cd,
          p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->
          updt_id
         WITH nocounter
        ;end insert
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = numrows)
  DETAIL
   col 1, d.seq"####", col 10,
   requestin->list_0[d.seq].himview, col 30, requestin->list_0[d.seq].facility,
   col 50, requestin->list_0[d.seq].building, col 70,
   requestin->list_0[d.seq].display
   IF ((temp->list_0[d.seq].action_flag=1))
    col 90, "Core Location Added to View"
   ELSEIF ((temp->list_0[d.seq].action_flag=2))
    col 90, "HIM Flags Updated"
   ELSEIF ((temp->list_0[d.seq].action_flag=3))
    col 90, "Location Updated"
   ELSEIF ((temp->list_0[d.seq].action_flag=4))
    col 90, "HIM Location Added"
   ELSE
    col 90, "ERROR -", col 98,
    temp->list_0[d.seq].error_string
   ENDIF
   row + 1
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
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
     IF (write_mode=0)
      col 30, "AUDIT MODE: NO CHANGES HAVE BEEN MADE TO THE DATABASE"
     ELSE
      col 30, "COMMIT MODE: CHANGES HAVE BEEN MADE TO THE DATABASE"
     ENDIF
    DETAIL
     row + 2, col 2, "ROW",
     col 10, "VIEW", col 30,
     "FACILITY", col 50, "BUILDING",
     col 70, "LOCATION", col 90,
     "STATUS"
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
 SUBROUTINE get_cv_by_disp(xcodeset,xdisp)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND cnvtupper(c.display)=trim(cnvtupper(xdisp))
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SUBROUTINE get_cv_by_disp_cdf(xcodeset,xdisp,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND cnvtupper(c.display)=trim(cnvtupper(xdisp))
      AND cnvtupper(c.cdf_meaning)=trim(cnvtupper(xcdf))
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO

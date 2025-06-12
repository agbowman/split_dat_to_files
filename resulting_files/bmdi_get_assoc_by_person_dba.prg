CREATE PROGRAM bmdi_get_assoc_by_person:dba
 RECORD reply(
   1 assoc_list[*]
     2 association_id = f8
     2 association_dt_tm = dq8
     2 device_id = f8
     2 device_cd = f8
     2 device_disp = c40
     2 device_desc = c60
     2 device_mean = c12
     2 device_alias = c40
     2 device_category_cd = f8
     2 device_category_disp = c40
     2 device_category_desc = c60
     2 device_category_mean = c12
     2 device_category_type_cd = f8
     2 device_category_type_disp = c40
     2 device_category_type_desc = c60
     2 device_category_type_mean = c12
     2 person_alias_type_cd = f8
     2 person_alias_type_disp = c40
     2 person_alias_type_desc = c60
     2 person_alias_type_mean = c12
     2 person_alias = vc
     2 encntr_id = f8
     2 encntr_alias_type_cd = f8
     2 encntr_alias_type_disp = c40
     2 encntr_alias_type_desc = c60
     2 encntr_alias_type_mean = c12
     2 encntr_alias = vc
     2 person_weight = vc
     2 weight_units_cd = f8
     2 weight_units_disp = c40
     2 weight_units_desc = c60
     2 weight_units_mean = c12
     2 person_height = vc
     2 height_units_cd = f8
     2 height_units_disp = c40
     2 height_units_desc = c60
     2 height_units_mean = c12
     2 person_gender_cd = f8
     2 person_gender_disp = c40
     2 person_gender_desc = c60
     2 person_gender_mean = c12
     2 person_birth_dt_tm = dq8
     2 mobile_ind = i2
     2 association_limit_cnt = i4
     2 status_flag = i4
     2 status_message = vc
     2 association_prsnl_id = f8
     2 dis_association_prsnl_id = f8
     2 device_settings_match_ind = i2
     2 active_ind = i2
     2 loc_list[*]
       3 hierarchy = i4
       3 location_cd = f8
       3 location_disp = c40
       3 location_desc = c60
       3 location_mean = c12
       3 codeset = i4
       3 location_type_cd = f8
       3 location_type_disp = c40
       3 location_type_desc = c60
       3 location_type_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET sfailed = "S"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = 0
 DECLARE resource_codeset = i4 WITH private, constant(221)
 DECLARE location_codeset = i4 WITH private, constant(220)
 DECLARE exitwhile = i2 WITH private, noconstant(0)
 DECLARE indexwhile = i2 WITH private, noconstant(1)
 DECLARE current_location_cd = f8 WITH noconstant(0.0)
 DECLARE i = i2 WITH noconstant(0)
 DECLARE hierarchy = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM bmdi_acquired_data_track badt,
   bmdi_adt_person_r bapr,
   bmdi_monitored_device bmd,
   strt_model sm
  PLAN (badt
   WHERE (badt.person_id=request->person_id)
    AND badt.active_ind=1)
   JOIN (bapr
   WHERE bapr.association_id=badt.association_id
    AND bapr.active_ind=1
    AND ((bapr.encntr_id=0) OR ((bapr.encntr_id=request->encntr_id))) )
   JOIN (bmd
   WHERE bmd.device_cd=badt.device_cd
    AND bmd.location_cd=badt.location_cd)
   JOIN (sm
   WHERE sm.strt_model_id=bmd.strt_model_child_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->assoc_list,(cnt+ 9))
   ENDIF
   reply->assoc_list[cnt].association_id = bapr.association_id, reply->assoc_list[cnt].
   association_dt_tm = badt.association_dt_tm, reply->assoc_list[cnt].device_id = bmd
   .monitored_device_id,
   reply->assoc_list[cnt].device_alias = bmd.device_alias, reply->assoc_list[cnt].device_cd = badt
   .device_cd, reply->assoc_list[cnt].device_disp = uar_get_code_display(bmd.device_cd),
   reply->assoc_list[cnt].device_desc = uar_get_code_description(bmd.device_cd), reply->assoc_list[
   cnt].device_mean = uar_get_code_meaning(bmd.device_cd), reply->assoc_list[cnt].device_category_cd
    = sm.device_category_cd,
   reply->assoc_list[cnt].device_category_disp = uar_get_code_display(sm.device_category_cd), reply->
   assoc_list[cnt].device_category_desc = uar_get_code_description(sm.device_category_cd), reply->
   assoc_list[cnt].device_category_mean = uar_get_code_meaning(sm.device_category_cd),
   reply->assoc_list[cnt].device_category_type_cd = sm.device_category_type_cd, reply->assoc_list[cnt
   ].device_category_type_disp = uar_get_code_display(sm.device_category_type_cd), reply->assoc_list[
   cnt].device_category_type_desc = uar_get_code_description(sm.device_category_type_cd),
   reply->assoc_list[cnt].device_category_type_mean = uar_get_code_meaning(sm.device_category_type_cd
    ), reply->assoc_list[cnt].person_alias_type_cd = bapr.person_alias_type_cd, reply->assoc_list[cnt
   ].person_alias_type_disp = uar_get_code_display(bapr.person_alias_type_cd),
   reply->assoc_list[cnt].person_alias_type_desc = uar_get_code_description(bapr.person_alias_type_cd
    ), reply->assoc_list[cnt].person_alias_type_mean = uar_get_code_meaning(bapr.person_alias_type_cd
    ), reply->assoc_list[cnt].person_alias = bapr.person_alias,
   reply->assoc_list[cnt].encntr_id = bapr.encntr_id, reply->assoc_list[cnt].encntr_alias_type_cd =
   bapr.encntr_alias_type_cd, reply->assoc_list[cnt].encntr_alias_type_disp = uar_get_code_display(
    bapr.encntr_alias_type_cd),
   reply->assoc_list[cnt].encntr_alias_type_desc = uar_get_code_description(bapr.encntr_alias_type_cd
    ), reply->assoc_list[cnt].encntr_alias_type_mean = uar_get_code_meaning(bapr.encntr_alias_type_cd
    ), reply->assoc_list[cnt].encntr_alias = bapr.encntr_alias,
   reply->assoc_list[cnt].person_weight = bapr.person_weight, reply->assoc_list[cnt].weight_units_cd
    = bapr.weight_units_cd, reply->assoc_list[cnt].weight_units_disp = uar_get_code_display(bapr
    .weight_units_cd),
   reply->assoc_list[cnt].weight_units_desc = uar_get_code_description(bapr.weight_units_cd), reply->
   assoc_list[cnt].weight_units_mean = uar_get_code_meaning(bapr.weight_units_cd), reply->assoc_list[
   cnt].person_height = bapr.person_height,
   reply->assoc_list[cnt].height_units_cd = bapr.height_units_cd, reply->assoc_list[cnt].
   height_units_disp = uar_get_code_display(bapr.height_units_cd), reply->assoc_list[cnt].
   height_units_desc = uar_get_code_description(bapr.height_units_cd),
   reply->assoc_list[cnt].height_units_mean = uar_get_code_meaning(bapr.height_units_cd), reply->
   assoc_list[cnt].person_gender_cd = bapr.person_gender_cd, reply->assoc_list[cnt].
   person_gender_disp = uar_get_code_display(bapr.person_gender_cd),
   reply->assoc_list[cnt].person_gender_desc = uar_get_code_description(bapr.person_gender_cd), reply
   ->assoc_list[cnt].person_gender_mean = uar_get_code_meaning(bapr.person_gender_cd), reply->
   assoc_list[cnt].person_birth_dt_tm = bapr.person_birth_dt_tm,
   reply->assoc_list[cnt].mobile_ind = bmd.mobile_ind, reply->assoc_list[cnt].association_limit_cnt
    = bmd.association_limit_cnt, reply->assoc_list[cnt].status_flag = bapr.status_flag,
   reply->assoc_list[cnt].status_message = bapr.status_message, reply->assoc_list[cnt].
   association_prsnl_id = bapr.association_prsnl_id, reply->assoc_list[cnt].dis_association_prsnl_id
    = bapr.dis_association_prsnl_id
   IF ((reply->assoc_list[cnt].encntr_id > 0))
    reply->assoc_list[cnt].device_settings_match_ind = 1
   ENDIF
   stat = alterlist(reply->assoc_list[cnt].loc_list,1), reply->assoc_list[cnt].loc_list[1].
   location_cd = badt.location_cd, reply->assoc_list[cnt].loc_list[1].location_disp =
   uar_get_code_display(badt.location_cd),
   reply->assoc_list[cnt].loc_list[1].location_desc = uar_get_code_description(badt.location_cd),
   reply->assoc_list[cnt].loc_list[1].location_mean = uar_get_code_meaning(badt.location_cd), reply->
   assoc_list[cnt].loc_list[1].codeset = uar_get_code_set(badt.location_cd,reply->assoc_list[cnt].
    loc_list[1].location_disp,reply->assoc_list[cnt].loc_list[1].location_mean,reply->assoc_list[cnt]
    .loc_list[1].location_desc),
   reply->assoc_list[cnt].loc_list[1].hierarchy = 1
  FOOT REPORT
   stat = alterlist(reply->assoc_list,cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO set_exit_status
 ENDIF
 FOR (i = 1 TO size(reply->assoc_list,5))
   IF ((reply->assoc_list[i].loc_list[1].codeset=resource_codeset))
    SET current_location_cd = reply->assoc_list[i].loc_list[1].location_cd
    SELECT INTO "nl:"
     FROM service_resource sr
     WHERE (sr.service_resource_cd=reply->assoc_list[i].loc_list[1].location_cd)
     DETAIL
      reply->assoc_list[i].loc_list[1].location_type_cd = sr.service_resource_type_cd, reply->
      assoc_list[i].loc_list[1].location_type_disp = uar_get_code_display(sr.service_resource_type_cd
       ), reply->assoc_list[i].loc_list[1].location_type_desc = uar_get_code_description(sr
       .service_resource_type_cd),
      reply->assoc_list[i].loc_list[1].location_type_mean = uar_get_code_meaning(sr
       .service_resource_type_cd)
     WITH nocounter
    ;end select
    SET exitwhile = 0
    SET indexwhile = 1
    WHILE (exitwhile=0)
     SELECT INTO "nl:"
      FROM resource_group rg
      WHERE rg.child_service_resource_cd=current_location_cd
       AND rg.resource_group_type_cd > 0
       AND ((rg.root_service_resource_cd+ 0)=0.0)
       AND rg.active_ind=1
      HEAD REPORT
       indexwhile = value(size(reply->assoc_list[i].loc_list,5)), hierarchy = (hierarchy+ 1)
      DETAIL
       indexwhile = (indexwhile+ 1), stat = alterlist(reply->assoc_list[i].loc_list,indexwhile),
       reply->assoc_list[i].loc_list[indexwhile].location_cd = rg.parent_service_resource_cd,
       reply->assoc_list[i].loc_list[indexwhile].location_disp = uar_get_code_display(rg
        .parent_service_resource_cd), reply->assoc_list[i].loc_list[indexwhile].location_desc =
       uar_get_code_description(rg.parent_service_resource_cd), reply->assoc_list[i].loc_list[
       indexwhile].location_mean = uar_get_code_meaning(rg.parent_service_resource_cd),
       reply->assoc_list[i].loc_list[indexwhile].codeset = uar_get_code_set(lg.parent_loc_cd,reply->
        assoc_list[i].loc_list[indexwhile].location_disp,reply->assoc_list[i].loc_list[indexwhile].
        location_mean,reply->assoc_list[i].loc_list[indexwhile].location_desc), reply->assoc_list[i].
       loc_list[indexwhile].location_type_cd = rg.resource_group_type_cd, reply->assoc_list[i].
       loc_list[indexwhile].location_type_disp = uar_get_code_display(rg.resource_group_type_cd),
       reply->assoc_list[i].loc_list[indexwhile].location_type_desc = uar_get_code_description(rg
        .resource_group_type_cd), reply->assoc_list[i].loc_list[indexwhile].location_type_mean =
       uar_get_code_meaning(rg.resource_group_type_cd), reply->assoc_list[i].loc_list[indexwhile].
       hierarchy = hierarchy
      FOOT REPORT
       current_location_cd = rg.parent_service_resource_cd
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET exitwhile = 1
     ENDIF
    ENDWHILE
   ELSEIF ((reply->assoc_list[i].loc_list[1].codeset=location_codeset))
    SET current_location_cd = reply->assoc_list[i].loc_list[1].location_cd
    SELECT INTO "nl:"
     FROM location loc
     WHERE loc.location_cd=current_location_cd
     DETAIL
      reply->assoc_list[i].loc_list[1].location_type_cd = loc.location_type_cd, reply->assoc_list[i].
      loc_list[1].location_type_disp = uar_get_code_display(loc.location_type_cd), reply->assoc_list[
      i].loc_list[1].location_type_desc = uar_get_code_description(loc.location_type_cd),
      reply->assoc_list[i].loc_list[1].location_type_mean = uar_get_code_meaning(loc.location_type_cd
       )
     WITH nocounter
    ;end select
    SET exitwhile = 0
    SET indexwhile = 1
    SET hierarchy = 1
    WHILE (exitwhile=0)
     SELECT INTO "nl:"
      FROM location_group lg
      WHERE lg.child_loc_cd=current_location_cd
       AND lg.location_group_type_cd > 0
       AND ((lg.root_loc_cd+ 0)=0.0)
       AND lg.active_ind=1
      HEAD REPORT
       indexwhile = value(size(reply->assoc_list[i].loc_list,5)), hierarchy = (hierarchy+ 1)
      DETAIL
       indexwhile = (indexwhile+ 1), stat = alterlist(reply->assoc_list[i].loc_list,indexwhile),
       reply->assoc_list[i].loc_list[indexwhile].location_cd = lg.parent_loc_cd,
       reply->assoc_list[i].loc_list[indexwhile].location_disp = uar_get_code_display(lg
        .parent_loc_cd), reply->assoc_list[i].loc_list[indexwhile].location_desc =
       uar_get_code_description(lg.parent_loc_cd), reply->assoc_list[i].loc_list[indexwhile].
       location_mean = uar_get_code_meaning(lg.parent_loc_cd),
       reply->assoc_list[i].loc_list[indexwhile].codeset = uar_get_code_set(lg.parent_loc_cd,reply->
        assoc_list[i].loc_list[indexwhile].location_disp,reply->assoc_list[i].loc_list[indexwhile].
        location_mean,reply->assoc_list[i].loc_list[indexwhile].location_desc), reply->assoc_list[i].
       loc_list[indexwhile].location_type_cd = lg.location_group_type_cd, reply->assoc_list[i].
       loc_list[indexwhile].location_type_disp = uar_get_code_display(lg.location_group_type_cd),
       reply->assoc_list[i].loc_list[indexwhile].location_type_desc = uar_get_code_description(lg
        .location_group_type_cd), reply->assoc_list[i].loc_list[indexwhile].location_type_mean =
       uar_get_code_meaning(lg.location_group_type_cd), reply->assoc_list[i].loc_list[indexwhile].
       hierarchy = hierarchy
      FOOT REPORT
       current_location_cd = lg.parent_loc_cd
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET exitwhile = 1
     ENDIF
    ENDWHILE
   ENDIF
 ENDFOR
#set_exit_status
 IF (i < 1)
  SET ierrcode = error(serrmsg,1)
  SET sfailed = "T"
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,2)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Retrieval failed!"
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "No data matching request"
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_assoc_by_person"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "SELECT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_get_assoc_by_person"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
 GO TO exit_script
#no_valid_ids
 IF (sfailed="I")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_assoc_by_person"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid identifier in request"
  GO TO exit_script
 ENDIF
#exit_script
 IF (sfailed="T")
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSEIF (sfailed="I")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO

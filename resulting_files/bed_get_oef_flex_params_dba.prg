CREATE PROGRAM bed_get_oef_flex_params:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 olist[*]
      2 oe_format_id = f8
      2 action_type_cd = f8
      2 action_type_display = c40
      2 action_type_mean = c12
      2 format_exists_ind = i2
      2 tlist[*]
        3 flex_type_flag = i2
        3 plist[*]
          4 flex_param_code_value = f8
          4 flex_param_display = c40
          4 flex_param_mean = c12
          4 building_desc = c40
          4 facility_desc = c40
          4 building_disp = c40
          4 facility_disp = c40
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
 DECLARE facility_cd = f8 WITH noconstant(0.0)
 DECLARE building_cd = f8 WITH noconstant(0.0)
 DECLARE bldg_code_value = f8 WITH noconstant(0.0)
 DECLARE oef_cnt = i4
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning IN ("FACILITY", "BUILDING")
  DETAIL
   IF (cv.cdf_meaning="FACILITY")
    facility_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BUILDING")
    building_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET oef_cnt = size(request->oef_list,5)
 IF (oef_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->olist,oef_cnt)
 FOR (o = 1 TO oef_cnt)
   SET reply->olist[o].oe_format_id = request->oef_list[o].oe_format_id
   SET reply->olist[o].action_type_cd = request->oef_list[o].action_type_cd
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=6003
     AND (cv.code_value=request->oef_list[o].action_type_cd)
    DETAIL
     reply->olist[o].action_type_display = cv.display, reply->olist[o].action_type_mean = cv
     .cdf_meaning
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM oe_format_fields off
    WHERE (off.oe_format_id=request->oef_list[o].oe_format_id)
     AND (off.action_type_cd=request->oef_list[o].action_type_cd)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->olist[o].format_exists_ind = 0
   ELSE
    SET reply->olist[o].format_exists_ind = 1
   ENDIF
   IF ((reply->olist[o].format_exists_ind=1))
    SELECT INTO "nl:"
     FROM accept_format_flexing aff,
      code_value cv
     PLAN (aff
      WHERE (aff.oe_format_id=request->oef_list[o].oe_format_id)
       AND (aff.action_type_cd=request->oef_list[o].action_type_cd))
      JOIN (cv
      WHERE aff.flex_cd=cv.code_value)
     ORDER BY aff.oe_format_id, aff.action_type_cd, aff.flex_type_flag,
      aff.flex_cd
     HEAD REPORT
      tlist_cnt = 0
     HEAD aff.flex_type_flag
      tlist_cnt = (tlist_cnt+ 1), stat = alterlist(reply->olist[o].tlist,tlist_cnt), reply->olist[o].
      tlist[tlist_cnt].flex_type_flag = aff.flex_type_flag,
      plist_cnt = 0
     HEAD aff.flex_cd
      plist_cnt = (plist_cnt+ 1), stat = alterlist(reply->olist[o].tlist[tlist_cnt].plist,plist_cnt),
      reply->olist[o].tlist[tlist_cnt].plist[plist_cnt].flex_param_code_value = aff.flex_cd
      IF ((((reply->olist[o].tlist[tlist_cnt].flex_type_flag=0)) OR ((reply->olist[o].tlist[tlist_cnt
      ].flex_type_flag=1))) )
       reply->olist[o].tlist[tlist_cnt].plist[plist_cnt].flex_param_display = cv.description
      ELSE
       reply->olist[o].tlist[tlist_cnt].plist[plist_cnt].flex_param_display = cv.display
      ENDIF
      reply->olist[o].tlist[tlist_cnt].plist[plist_cnt].flex_param_mean = cv.cdf_meaning
     WITH nocounter
    ;end select
    SET tlist_cnt = size(reply->olist[o].tlist,5)
    FOR (t = 1 TO tlist_cnt)
      IF ((((reply->olist[o].tlist[t].flex_type_flag=0)) OR ((reply->olist[o].tlist[t].flex_type_flag
      =1))) )
       SET plist_cnt = size(reply->olist[o].tlist[t].plist,5)
       FOR (p = 1 TO plist_cnt)
         SET bldg_code_value = 0.0
         SELECT INTO "nl:"
          FROM location_group lg,
           code_value cv
          PLAN (lg
           WHERE lg.active_ind=1
            AND (lg.child_loc_cd=reply->olist[o].tlist[t].plist[p].flex_param_code_value)
            AND lg.location_group_type_cd=building_cd)
           JOIN (cv
           WHERE cv.code_value=lg.parent_loc_cd)
          DETAIL
           bldg_code_value = lg.parent_loc_cd, reply->olist[o].tlist[t].plist[p].building_desc = cv
           .description, reply->olist[o].tlist[t].plist[p].building_disp = cv.display
          WITH nocounter
         ;end select
         SET fac_code_value = 0.0
         IF (bldg_code_value > 0.0)
          SELECT INTO "nl:"
           FROM location_group lg,
            code_value cv
           PLAN (lg
            WHERE lg.active_ind=1
             AND lg.child_loc_cd=bldg_code_value
             AND lg.location_group_type_cd=facility_cd)
            JOIN (cv
            WHERE cv.code_value=lg.parent_loc_cd)
           DETAIL
            fac_code_value = lg.parent_loc_cd, reply->olist[o].tlist[t].plist[p].facility_desc = cv
            .description, reply->olist[o].tlist[t].plist[p].facility_disp = cv.display
           WITH nocounter
          ;end select
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (oef_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO

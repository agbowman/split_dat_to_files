CREATE PROGRAM dcp_get_pip_def:dba
 RECORD reply(
   1 pip_id = f8
   1 position_cd = f8
   1 location_cd = f8
   1 properties[*]
     2 pref_id = f8
     2 prsnl_id = f8
     2 name = vc
     2 value = vc
     2 merge_name = vc
     2 merge_id = f8
     2 sequence = i4
     2 updt_cnt = i4
   1 sections[*]
     2 section_id = f8
     2 section_type_cd = f8
     2 properties[*]
       3 pref_id = f8
       3 prsnl_id = f8
       3 name = vc
       3 value = vc
       3 merge_name = vc
       3 merge_id = f8
       3 sequence = i4
       3 updt_cnt = i4
     2 columns[*]
       3 column_id = f8
       3 prsnl_id = f8
       3 column_type_cd = f8
       3 sequence = i4
       3 properties[*]
         4 pref_id = f8
         4 prsnl_id = f8
         4 name = vc
         4 value = vc
         4 merge_name = vc
         4 merge_id = f8
         4 sequence = i4
         4 updt_cnt = i4
   1 status_data
     2 status = vc
     2 subeventstatus[*]
     2 operationname = c15
     2 operationstatus = c1
     2 targetobjectname = c15
     2 targetobjectvalue = vc
 )
 RECORD temp(
   1 location_cnt = i4
   1 locations[*]
     2 location_cd = f8
 )
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE z = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE sect_cnt = i4 WITH noconstant(0)
 DECLARE property_cnt = i4 WITH noconstant(0)
 DECLARE sect_property_cnt = i4 WITH noconstant(0)
 DECLARE col_property_cnt = i4 WITH noconstant(0)
 DECLARE entity_cnt = i4 WITH noconstant(0)
 DECLARE expand_idx = i4 WITH noconstant(0), protect
 DECLARE expand_start = i4 WITH noconstant(1), protect
 DECLARE expand_max_cnt = i4 WITH constant(10), protect
 DECLARE identifylocations(loccd=f8) = null
 DECLARE identifypip(null) = null
 DECLARE identifypersonalpip(null) = null
 DECLARE identifypositionpip(null) = null
 DECLARE identifysystempip(null) = null
 SET reply->status_data.status = "F"
 CALL identifypip(null)
 IF ((reply->pip_id=0.0))
  GO TO finish
 ENDIF
 SELECT INTO "nl:"
  FROM pip_prefs pr
  PLAN (pr
   WHERE (pr.parent_entity_id=reply->pip_id)
    AND ((pr.prsnl_id+ 0)=0.0)
    AND pr.parent_entity_name="PIP")
  DETAIL
   property_cnt = (property_cnt+ 1)
   IF (mod(property_cnt,10)=1)
    stat = alterlist(reply->properties,(property_cnt+ 9))
   ENDIF
   reply->properties[property_cnt].pref_id = pr.pip_prefs_id, reply->properties[property_cnt].
   prsnl_id = pr.prsnl_id, reply->properties[property_cnt].name = pr.pref_name,
   reply->properties[property_cnt].value = pr.pref_value, reply->properties[property_cnt].merge_name
    = pr.merge_name, reply->properties[property_cnt].merge_id = pr.merge_id,
   reply->properties[property_cnt].sequence = pr.sequence, reply->properties[property_cnt].updt_cnt
    = pr.updt_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pip_section s,
   pip_prefs pr
  PLAN (s
   WHERE (s.pip_id=reply->pip_id))
   JOIN (pr
   WHERE pr.parent_entity_id=s.pip_section_id
    AND ((pr.prsnl_id+ 0) IN (0.0, request->prsnl_id))
    AND pr.parent_entity_name="PIP_SECTION")
  ORDER BY s.sequence, pr.pref_name, pr.sequence,
   pr.prsnl_id
  HEAD REPORT
   sect_cnt = 0
  HEAD s.pip_section_id
   col_cnt = 0, sect_property_cnt = 0, sect_cnt = (sect_cnt+ 1)
   IF (mod(sect_cnt,10)=1)
    stat = alterlist(reply->sections,(sect_cnt+ 9))
   ENDIF
   stat = alterlist(reply->sections[sect_cnt].properties,100), reply->sections[sect_cnt].section_id
    = s.pip_section_id, reply->sections[sect_cnt].section_type_cd = s.section_type_cd
  HEAD pr.pref_name
   dummy = 0
  HEAD pr.sequence
   IF (pr.pip_prefs_id != 0.0)
    sect_property_cnt = (sect_property_cnt+ 1)
    IF (mod(sect_property_cnt,10)=1)
     stat = alterlist(reply->sections[sect_cnt].properties,(sect_property_cnt+ 9))
    ENDIF
   ENDIF
  HEAD pr.prsnl_id
   IF (pr.pip_prefs_id != 0.0)
    reply->sections[sect_cnt].properties[sect_property_cnt].pref_id = pr.pip_prefs_id, reply->
    sections[sect_cnt].properties[sect_property_cnt].prsnl_id = pr.prsnl_id, reply->sections[sect_cnt
    ].properties[sect_property_cnt].name = pr.pref_name,
    reply->sections[sect_cnt].properties[sect_property_cnt].value = pr.pref_value, reply->sections[
    sect_cnt].properties[sect_property_cnt].merge_name = pr.merge_name, reply->sections[sect_cnt].
    properties[sect_property_cnt].merge_id = pr.merge_id,
    reply->sections[sect_cnt].properties[sect_property_cnt].sequence = pr.sequence, reply->sections[
    sect_cnt].properties[sect_property_cnt].updt_cnt = pr.updt_cnt
   ENDIF
  FOOT  s.pip_section_id
   stat = alterlist(reply->sections[sect_cnt].properties,sect_property_cnt)
  FOOT REPORT
   stat = alterlist(reply->sections,sect_cnt)
  WITH nocounter
 ;end select
 DECLARE sect_entity_cnt = i4 WITH noconstant(size(reply->sections,5))
 DECLARE expand_index = i4 WITH noconstant(0), protect
 DECLARE expand_srt = i4 WITH noconstant(1), protect
 DECLARE expand_max = i4 WITH constant(100), protect
 DECLARE expand_chunk_cnt = i4 WITH constant(ceil(((sect_entity_cnt * 1.0)/ expand_max))), protect
 DECLARE expand_max_size = i4 WITH constant((expand_chunk_cnt * expand_max)), protect
 SET stat = alterlist(reply->sections,expand_max_size)
 FOR (x = (sect_entity_cnt+ 1) TO expand_max_size)
   SET reply->sections[x].section_id = reply->sections[sect_entity_cnt].section_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(expand_chunk_cnt)),
   pip_column c,
   pip_prefs pr
  PLAN (d1
   WHERE assign(expand_srt,evaluate(d1.seq,1,1,(expand_srt+ expand_max))))
   JOIN (c
   WHERE expand(expand_index,expand_srt,((expand_srt+ expand_max) - 1),c.pip_section_id,reply->
    sections[expand_index].section_id)
    AND ((c.prsnl_id+ 0) IN (0.0, request->prsnl_id)))
   JOIN (pr
   WHERE pr.parent_entity_id=c.pip_column_id
    AND ((pr.prsnl_id+ 0) IN (0.0, request->prsnl_id))
    AND pr.parent_entity_name="PIP_COLUMN")
  ORDER BY c.pip_section_id, c.prsnl_id, c.sequence,
   c.pip_column_id, pr.pref_name, pr.sequence,
   pr.prsnl_id
  HEAD c.pip_section_id
   col_cnt = 0, si = 0, sidx = locateval(si,1,sect_cnt,c.pip_section_id,reply->sections[si].
    section_id)
  HEAD c.pip_column_id
   prop_cnt = 0, col_cnt = (col_cnt+ 1), col_property_cnt = 0
   IF (mod(col_cnt,10)=1)
    stat = alterlist(reply->sections[sidx].columns,(col_cnt+ 9))
   ENDIF
   stat = alterlist(reply->sections[sidx].columns[col_cnt].properties,100), reply->sections[sidx].
   columns[col_cnt].column_id = c.pip_column_id, reply->sections[sidx].columns[col_cnt].
   column_type_cd = c.column_type_cd,
   reply->sections[sidx].columns[col_cnt].prsnl_id = c.prsnl_id, reply->sections[sidx].columns[
   col_cnt].sequence = c.sequence
  HEAD pr.pref_name
   dummy = 0
  HEAD pr.sequence
   IF (pr.pip_prefs_id != 0.0)
    col_property_cnt = (col_property_cnt+ 1)
    IF (mod(col_property_cnt,10)=1)
     stat = alterlist(reply->sections[sidx].columns[col_cnt].properties,(col_property_cnt+ 9))
    ENDIF
   ENDIF
  HEAD pr.prsnl_id
   IF (pr.pip_prefs_id != 0.0)
    reply->sections[sidx].columns[col_cnt].properties[col_property_cnt].pref_id = pr.pip_prefs_id,
    reply->sections[sidx].columns[col_cnt].properties[col_property_cnt].prsnl_id = pr.prsnl_id, reply
    ->sections[sidx].columns[col_cnt].properties[col_property_cnt].name = pr.pref_name,
    reply->sections[sidx].columns[col_cnt].properties[col_property_cnt].value = pr.pref_value, reply
    ->sections[sidx].columns[col_cnt].properties[col_property_cnt].merge_name = pr.merge_name, reply
    ->sections[sidx].columns[col_cnt].properties[col_property_cnt].merge_id = pr.merge_id,
    reply->sections[sidx].columns[col_cnt].properties[col_property_cnt].sequence = pr.sequence, reply
    ->sections[sidx].columns[col_cnt].properties[col_property_cnt].updt_cnt = pr.updt_cnt
   ENDIF
  FOOT  c.pip_column_id
   stat = alterlist(reply->sections[sidx].columns[col_cnt].properties,col_property_cnt)
  FOOT  c.pip_section_id
   stat = alterlist(reply->sections[sidx].columns,col_cnt), stat = alterlist(reply->sections,sect_cnt
    )
  WITH nocounter
 ;end select
#finish
 IF ((reply->pip_id=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE identifylocations(loccd)
   DECLARE meaning = vc WITH constant(uar_get_code_meaning(loccd)), private
   DECLARE typecd = f8 WITH noconstant(0.0), protect
   SET temp->location_cnt = 0
   SET stat = alterlist(temp->locations,6)
   IF (meaning="BED")
    SELECT INTO "nl:"
     FROM bed b,
      room r,
      nurse_unit n
     PLAN (b
      WHERE b.location_cd=loccd)
      JOIN (r
      WHERE r.location_cd=b.loc_room_cd)
      JOIN (n
      WHERE n.location_cd=r.loc_nurse_unit_cd)
     DETAIL
      IF (b.location_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = b.location_cd
      ENDIF
      IF (r.location_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = r.location_cd
      ENDIF
      IF (n.location_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = n.location_cd
      ENDIF
      IF (n.loc_building_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = n.loc_building_cd
      ENDIF
      IF (n.loc_facility_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = n.loc_facility_cd
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (meaning="ROOM")
    SELECT INTO "nl:"
     FROM room r,
      nurse_unit n
     PLAN (r
      WHERE r.location_cd=loccd)
      JOIN (n
      WHERE n.location_cd=r.loc_nurse_unit_cd)
     DETAIL
      IF (r.location_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = r.location_cd
      ENDIF
      IF (n.location_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = n.location_cd
      ENDIF
      IF (n.loc_building_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = n.loc_building_cd
      ENDIF
      IF (n.loc_facility_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = n.loc_facility_cd
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (meaning="NURSEUNIT")
    SELECT INTO "nl:"
     FROM nurse_unit n
     PLAN (n
      WHERE n.location_cd=loccd)
     DETAIL
      IF (n.location_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = n.location_cd
      ENDIF
      IF (n.loc_building_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = n.loc_building_cd
      ENDIF
      IF (n.loc_facility_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = n.loc_facility_cd
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (meaning="BUILDING")
    SET typecd = uar_get_code_by("MEANING",222,"FACILITY")
    SELECT INTO "nl:"
     FROM location_group lg
     WHERE lg.child_loc_cd=loccd
      AND root_loc_cd=0
      AND lg.location_group_type_cd=typecd
     DETAIL
      IF (lg.child_loc_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = lg.child_loc_cd
      ENDIF
      IF (lg.parent_loc_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = lg.parent_loc_cd
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (meaning="FACILITY")
    SET temp->location_cnt = (temp->location_cnt+ 1)
    SET temp->locations[temp->location_cnt].location_cd = loccd
   ELSE
    DECLARE typecdfacility = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
    DECLARE typecdbuilding = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
    SELECT INTO "nl:"
     FROM location_group lg
     PLAN (lg
      WHERE lg.child_loc_cd=loccd
       AND lg.location_group_type_cd IN (typecdbuilding, typecdfacility)
       AND lg.root_loc_cd=0)
     DETAIL
      IF (lg.child_loc_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = lg.child_loc_cd
      ENDIF
      IF (lg.parent_loc_cd > 0.0)
       temp->location_cnt = (temp->location_cnt+ 1), temp->locations[temp->location_cnt].location_cd
        = lg.parent_loc_cd
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   SET temp->location_cnt = (temp->location_cnt+ 1)
   SET temp->locations[temp->location_cnt].location_cd = 0.0
 END ;Subroutine
 SUBROUTINE identifypip(null)
   CALL identifylocations(request->location_cd)
   SET reply->pip_id = 0.0
   SET entity_cnt = size(temp->locations,5)
   SET stat = alterlist(temp->locations,expand_max_cnt)
   FOR (x = (entity_cnt+ 1) TO expand_max_cnt)
     SET temp->locations[x].location_cd = temp->locations[entity_cnt].location_cd
   ENDFOR
   IF ((request->prsnl_id > 0.0))
    CALL identifypersonalpip(null)
   ENDIF
   IF ((request->position_cd > 0.0)
    AND (reply->pip_id=0.0))
    CALL identifypositionpip(null)
   ENDIF
   IF ((reply->pip_id=0.0))
    CALL identifysystempip(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE identifypersonalpip(null)
   SELECT INTO "nl:"
    FROM pip p
    PLAN (p
     WHERE (p.prsnl_id=request->prsnl_id)
      AND expand(expand_idx,expand_start,((expand_start+ expand_max_cnt) - 1),p.location_cd,temp->
      locations[expand_idx].location_cd))
    HEAD REPORT
     best_idx = 100, si = 0
    DETAIL
     cidx = locateval(si,1,temp->location_cnt,p.location_cd,request->location_cd)
     IF (cidx < best_idx)
      reply->pip_id = p.pip_id, reply->location_cd = p.location_cd, reply->position_cd = p
      .position_cd
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE identifypositionpip(null)
   SELECT INTO "nl:"
    FROM pip p
    PLAN (p
     WHERE (p.position_cd=request->position_cd)
      AND expand(expand_idx,expand_start,((expand_start+ expand_max_cnt) - 1),p.location_cd,temp->
      locations[expand_idx].location_cd)
      AND ((p.prsnl_id+ 0)=0))
    ORDER BY p.location_cd
    HEAD REPORT
     best_idx = 100, si = 0
    DETAIL
     cidx = locateval(si,1,temp->location_cnt,p.location_cd,request->location_cd)
     IF (cidx < best_idx)
      reply->pip_id = p.pip_id, reply->location_cd = p.location_cd, reply->position_cd = p
      .position_cd
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE identifysystempip(null)
   SELECT INTO "nl:"
    FROM pip p
    PLAN (p
     WHERE p.position_cd=0.0
      AND expand(expand_idx,expand_start,((expand_start+ expand_max_cnt) - 1),p.location_cd,temp->
      locations[expand_idx].location_cd)
      AND ((p.prsnl_id+ 0)=0))
    HEAD REPORT
     best_idx = 100, si = 0
    DETAIL
     cidx = locateval(si,1,temp->location_cnt,p.location_cd,request->location_cd)
     IF (cidx < best_idx)
      reply->pip_id = p.pip_id, reply->location_cd = p.location_cd, reply->position_cd = p
      .position_cd
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
END GO

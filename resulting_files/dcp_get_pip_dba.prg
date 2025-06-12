CREATE PROGRAM dcp_get_pip:dba
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
   1 status_data
     2 status = vc
     2 subeventstatus[*]
     2 operationname = c15
     2 operationstatus = c1
     2 targetobjectname = c15
     2 targetobjectvalue = vc
 )
 DECLARE loc_cd = f8
 SET reply->status_data.status = "S"
 SET pip_id = 0.0
 SET pos_cd = 0.0
 SET loc_cd = 0.0
 SET stat = 0
 CALL echo(build("prsnl_id = ",request->prsnl_id))
 IF ((request->prsnl_id != 0))
  SET loc_cd = request->location_cd
  SET break_ind = 0
  WHILE (pip_id=0
   AND break_ind=0)
   SELECT INTO "nl:"
    FROM pip p
    WHERE (p.prsnl_id=request->prsnl_id)
     AND p.location_cd=loc_cd
    DETAIL
     pip_id = p.pip_id
    WITH nocounter
   ;end select
   IF (pip_id=0)
    IF (loc_cd=0)
     SET break_ind = 1
    ELSE
     CALL getnextlocation(loc_cd)
    ENDIF
   ENDIF
  ENDWHILE
 ENDIF
 IF (pip_id=0)
  SET pos_cd = request->position_cd
  SET loc_cd = request->location_cd
  SET break_ind = 0
  SELECT INTO "nl:"
   FROM pip p
   WHERE (p.position_cd=request->position_cd)
    AND p.location_cd=loc_cd
    AND p.prsnl_id=0
   DETAIL
    pip_id = p.pip_id
   WITH nocounter
  ;end select
 ENDIF
 IF (pip_id=0)
  SET pos_cd = 0.0
  SET loc_cd = request->location_cd
  SET break_ind = 0
  SELECT INTO "nl:"
   FROM pip p
   WHERE p.position_cd=0
    AND p.location_cd=loc_cd
    AND p.prsnl_id=0
    AND p.pip_id > 0
   DETAIL
    pip_id = p.pip_id
   WITH nocounter
  ;end select
 ENDIF
 IF (pip_id=0)
  GO TO finish
 ENDIF
 SET reply->pip_id = pip_id
 SET reply->location_cd = loc_cd
 SET reply->position_cd = pos_cd
 SET prsnl_id = request->prsnl_id
 SET sect_cnt = 0
 SET col_cnt = 0
 SET prop_cnt = 0
 SELECT INTO "nl:"
  FROM pip p,
   pip_prefs p1
  PLAN (p
   WHERE p.pip_id=pip_id)
   JOIN (p1
   WHERE p1.parent_entity_name="PIP"
    AND p1.parent_entity_id=p.pip_id
    AND ((p1.prsnl_id=0) OR (p1.prsnl_id=prsnl_id)) )
  ORDER BY p1.pref_name, p1.sequence, p1.prsnl_id DESC
  HEAD p.pip_id
   reply->pip_id = pip_id, reply->position_cd = pos_cd, reply->location_cd = loc_cd,
   sect_cnt = 0, prop1_cnt = 0
  HEAD p1.sequence
   prop1_cnt = (prop1_cnt+ 1), stat = alterlist(reply->properties,prop1_cnt), reply->properties[
   prop1_cnt].pref_id = p1.pip_prefs_id,
   reply->properties[prop1_cnt].prsnl_id = p1.prsnl_id, reply->properties[prop1_cnt].name = p1
   .pref_name, reply->properties[prop1_cnt].value = p1.pref_value,
   reply->properties[prop1_cnt].merge_name = p1.merge_name, reply->properties[prop1_cnt].merge_id =
   p1.merge_id, reply->properties[prop1_cnt].sequence = p1.sequence
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pip_section s,
   pip_prefs p
  PLAN (s
   WHERE s.pip_id=pip_id)
   JOIN (p
   WHERE p.parent_entity_name="PIP_SECTION"
    AND p.parent_entity_id=s.pip_section_id
    AND ((p.prsnl_id=0) OR (p.prsnl_id=prsnl_id)) )
  ORDER BY s.sequence, p.pref_name, p.sequence,
   p.prsnl_id DESC
  HEAD REPORT
   sect_cnt = 0, prop_cnt = 0
  HEAD s.pip_section_id
   prop_cnt = 0, sect_cnt = (sect_cnt+ 1), stat = alterlist(reply->sections,sect_cnt),
   reply->sections[sect_cnt].section_id = s.pip_section_id, reply->sections[sect_cnt].section_type_cd
    = s.section_type_cd
  HEAD p.pref_name
   id = p.prsnl_id, sect_id = s.pip_section_id
  DETAIL
   IF (s.pip_section_id != sect_id)
    sect_id = s.pip_section_id, id = p.prsnl_id
   ENDIF
   IF (id=p.prsnl_id)
    prop_cnt = (prop_cnt+ 1), stat = alterlist(reply->sections[sect_cnt].properties,prop_cnt), reply
    ->sections[sect_cnt].properties[prop_cnt].pref_id = p.pip_prefs_id,
    reply->sections[sect_cnt].properties[prop_cnt].prsnl_id = p.prsnl_id, reply->sections[sect_cnt].
    properties[prop_cnt].name = p.pref_name, reply->sections[sect_cnt].properties[prop_cnt].value = p
    .pref_value,
    reply->sections[sect_cnt].properties[prop_cnt].merge_name = p.merge_name, reply->sections[
    sect_cnt].properties[prop_cnt].merge_id = p.merge_id, reply->sections[sect_cnt].properties[
    prop_cnt].sequence = p.sequence
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(sect_cnt)),
   pip_column c,
   pip_prefs p
  PLAN (d)
   JOIN (c
   WHERE (c.pip_section_id=reply->sections[d.seq].section_id)
    AND ((c.prsnl_id=0) OR (c.prsnl_id > 0)) )
   JOIN (p
   WHERE p.parent_entity_name="PIP_COLUMN"
    AND p.parent_entity_id=c.pip_column_id
    AND ((p.prsnl_id=0) OR (p.prsnl_id > 0)) )
  ORDER BY d.seq, c.sequence, p.sequence
  HEAD d.seq
   col_cnt = 0
  HEAD c.pip_column_id
   prop_cnt = 0, col_cnt = (col_cnt+ 1), stat = alterlist(reply->sections[d.seq].columns,col_cnt),
   reply->sections[d.seq].columns[col_cnt].column_id = c.pip_column_id, reply->sections[d.seq].
   columns[col_cnt].column_type_cd = c.column_type_cd, reply->sections[d.seq].columns[col_cnt].
   prsnl_id = c.prsnl_id,
   reply->sections[d.seq].columns[col_cnt].sequence = c.sequence
  HEAD p.pref_name
   id = p.prsnl_id, col_id = c.pip_column_id
  DETAIL
   IF (c.pip_column_id != col_id)
    col_id = c.pip_column_id, id = p.prsnl_id
   ENDIF
   IF (id=p.prsnl_id)
    prop_cnt = (prop_cnt+ 1), stat = alterlist(reply->sections[d.seq].columns[col_cnt].properties,
     prop_cnt), reply->sections[d.seq].columns[col_cnt].properties[prop_cnt].pref_id = p.pip_prefs_id,
    reply->sections[d.seq].columns[col_cnt].properties[prop_cnt].prsnl_id = p.prsnl_id, reply->
    sections[d.seq].columns[col_cnt].properties[prop_cnt].name = p.pref_name, reply->sections[d.seq].
    columns[col_cnt].properties[prop_cnt].value = p.pref_value,
    reply->sections[d.seq].columns[col_cnt].properties[prop_cnt].merge_name = p.merge_name, reply->
    sections[d.seq].columns[col_cnt].properties[prop_cnt].merge_id = p.merge_id, reply->sections[d
    .seq].columns[col_cnt].properties[prop_cnt].sequence = p.sequence
   ENDIF
  WITH nocounter
 ;end select
#finish
 CALL echorecord(reply)
 SET reply->status_data.status = "S"
END GO

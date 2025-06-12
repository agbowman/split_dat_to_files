CREATE PROGRAM dcp_get_calculator_equations:dba
 RECORD internal(
   1 temp[*]
     2 dcp_equation_id = f8
 )
 RECORD reply(
   1 qual[*]
     2 dcp_equation_id = f8
     2 description = vc
     2 begin_age_nbr = f8
     2 begin_age_flag = i2
     2 end_age_nbr = f8
     2 end_age_flag = i2
     2 gender_cd = f8
     2 equation_display = vc
     2 equation_meaning = c12
     2 equation_code = vc
     2 active_ind = i2
     2 calcvalue_description = vc
     2 number_components = i2
     2 components[*]
       3 dcp_component_id = f8
       3 component_flag = i2
       3 constant_value = f8
       3 component_label = c50
       3 component_description = c50
       3 event_cd = f8
       3 required_ind = i2
       3 corresponding_equation_id = f8
       3 component_code = c5
       3 duplicate_component_name = c50
       3 number_units = i2
       3 unit_measure[*]
         4 unit_measure_cd = f8
         4 default_ind = i2
         4 equation_dependent_unit_ind = i2
   1 more_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET equa_cnt = 0
 SET comp_cnt = 0
 SET unit_cnt = 0
 SET tot_equa_cnt = 0
 SET junk_ptr = 0
 SET temp_cnt = 0
 IF ((request->position_cd=0.0))
  GO TO no_position
 ENDIF
 SELECT INTO "nl:"
  de.dcp_equation_id
  FROM dcp_equation de
  WHERE de.dcp_equation_id > 0.0
   AND de.active_ind=1
  DETAIL
   tot_equa_cnt = (tot_equa_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dep.position_cd
  FROM dcp_equa_position dep
  WHERE (dep.position_cd=request->position_cd)
  ORDER BY dep.dcp_equation_id
  DETAIL
   temp_cnt = (temp_cnt+ 1)
   IF (temp_cnt > size(internal->temp,5))
    stat = alterlist(internal->temp,(temp_cnt+ 10))
   ENDIF
   internal->temp[temp_cnt].dcp_equation_id = dep.dcp_equation_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  de.dcp_equation_id
  FROM (dummyt d1  WITH seq = value(temp_cnt)),
   dcp_equation de
  PLAN (d1)
   JOIN (de
   WHERE (de.dcp_equation_id=internal->temp[d1.seq].dcp_equation_id))
  DETAIL
   IF (de.active_ind=1)
    equa_cnt = (equa_cnt+ 1)
    IF (equa_cnt > size(reply->qual,5))
     stat = alterlist(reply->qual,(equa_cnt+ 10))
    ENDIF
    reply->qual[equa_cnt].dcp_equation_id = de.dcp_equation_id, reply->qual[equa_cnt].description =
    de.description, reply->qual[equa_cnt].begin_age_nbr = de.begin_age_nbr,
    reply->qual[equa_cnt].begin_age_flag = de.begin_age_flag, reply->qual[equa_cnt].end_age_nbr = de
    .end_age_nbr, reply->qual[equa_cnt].end_age_flag = de.end_age_flag,
    reply->qual[equa_cnt].gender_cd = de.gender_cd, reply->qual[equa_cnt].equation_display = de
    .equation_display, reply->qual[equa_cnt].equation_meaning = de.equation_meaning,
    reply->qual[equa_cnt].equation_code = de.equation_code, reply->qual[equa_cnt].active_ind = de
    .active_ind, reply->qual[equa_cnt].calcvalue_description = de.calcvalue_description
   ENDIF
  WITH outerjoin = d1
 ;end select
 SET stat = alterlist(reply->qual,equa_cnt)
 IF (equa_cnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO equa_cnt)
   SELECT INTO "nl:"
    dec.dcp_component_id, dum.unit_measure_cd, check = decode(dum.seq,"dum",dec.seq,"dec","z")
    FROM dcp_equa_component dec,
     (dummyt d2  WITH seq = 1),
     dcp_unit_measure dum
    PLAN (dec
     WHERE (dec.dcp_equation_id=reply->qual[x].dcp_equation_id)
      AND dec.component_flag != 3)
     JOIN (d2)
     JOIN (dum
     WHERE dum.dcp_component_id=dec.dcp_component_id)
    ORDER BY dec.dcp_component_id
    HEAD REPORT
     comp_cnt = 0
    HEAD dec.dcp_component_id
     comp_cnt = (comp_cnt+ 1)
     IF (comp_cnt > size(reply->qual[x].components,5))
      stat = alterlist(reply->qual[x].components,(comp_cnt+ 10))
     ENDIF
     reply->qual[x].components[comp_cnt].dcp_component_id = dec.dcp_component_id, reply->qual[x].
     components[comp_cnt].component_flag = dec.component_flag, reply->qual[x].components[comp_cnt].
     constant_value = dec.constant_value,
     reply->qual[x].components[comp_cnt].component_label = dec.component_label, reply->qual[x].
     components[comp_cnt].component_description = dec.component_description, reply->qual[x].
     components[comp_cnt].event_cd = dec.event_cd,
     reply->qual[x].components[comp_cnt].required_ind = dec.required_ind, reply->qual[x].components[
     comp_cnt].corresponding_equation_id = dec.corresponding_equation_id, reply->qual[x].components[
     comp_cnt].component_code = dec.component_code,
     reply->qual[x].components[comp_cnt].duplicate_component_name = dec.duplicate_component_name,
     unit_cnt = 0
    DETAIL
     IF (check="dum")
      unit_cnt = (unit_cnt+ 1)
      IF (unit_cnt > size(reply->qual[x].components[comp_cnt].unit_measure,5))
       stat = alterlist(reply->qual[x].components[comp_cnt].unit_measure,(unit_cnt+ 10))
      ENDIF
      reply->qual[x].components[comp_cnt].unit_measure[unit_cnt].unit_measure_cd = dum
      .unit_measure_cd, reply->qual[x].components[comp_cnt].unit_measure[unit_cnt].default_ind = dum
      .default_ind, reply->qual[x].components[comp_cnt].unit_measure[unit_cnt].
      equation_dependent_unit_ind = dum.equation_dependent_unit_ind
     ENDIF
    FOOT  dec.dcp_component_id
     stat = alterlist(reply->qual[x].components[comp_cnt].unit_measure,unit_cnt), reply->qual[x].
     components[comp_cnt].number_units = unit_cnt
    FOOT REPORT
     stat = alterlist(reply->qual[x].components[comp_cnt],comp_cnt), reply->qual[x].number_components
      = comp_cnt
    WITH check, outerjoin = d2
   ;end select
 ENDFOR
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (equa_cnt=tot_equa_cnt)
  SET reply->more_ind = 0
 ELSE
  SET reply->more_ind = 1
 ENDIF
 GO TO exit_script
#no_position
 SELECT INTO "nl:"
  de.dcp_equation_id, dec.dcp_component_id, dum.unit_measure_cd,
  check = decode(dum.seq,"dum",dec.seq,"dec",de.seq,
   "de","z")
  FROM dcp_equation de,
   (dummyt d1  WITH seq = 1),
   dcp_equa_component dec,
   (dummyt d2  WITH seq = 1),
   dcp_unit_measure dum
  PLAN (de
   WHERE de.dcp_equation_id > 0.0)
   JOIN (d1)
   JOIN (dec
   WHERE dec.dcp_equation_id=de.dcp_equation_id
    AND dec.component_flag != 3)
   JOIN (d2)
   JOIN (dum
   WHERE dum.dcp_component_id=dec.dcp_component_id)
  ORDER BY de.dcp_equation_id, dec.dcp_component_id
  HEAD REPORT
   equa_cnt = 0
  HEAD de.dcp_equation_id
   equa_cnt = (equa_cnt+ 1)
   IF (equa_cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(equa_cnt+ 10))
   ENDIF
   reply->qual[equa_cnt].dcp_equation_id = de.dcp_equation_id, reply->qual[equa_cnt].description = de
   .description, reply->qual[equa_cnt].begin_age_nbr = de.begin_age_nbr,
   reply->qual[equa_cnt].begin_age_flag = de.begin_age_flag, reply->qual[equa_cnt].end_age_nbr = de
   .end_age_nbr, reply->qual[equa_cnt].end_age_flag = de.end_age_flag,
   reply->qual[equa_cnt].gender_cd = de.gender_cd, reply->qual[equa_cnt].equation_display = de
   .equation_display, reply->qual[equa_cnt].equation_meaning = de.equation_meaning,
   reply->qual[equa_cnt].equation_code = de.equation_code, reply->qual[equa_cnt].active_ind = de
   .active_ind, reply->qual[equa_cnt].calcvalue_description = de.calcvalue_description,
   comp_cnt = 0
  HEAD dec.dcp_component_id
   comp_cnt = (comp_cnt+ 1)
   IF (comp_cnt > size(reply->qual[equa_cnt].components,5))
    stat = alterlist(reply->qual[equa_cnt].components,(comp_cnt+ 10))
   ENDIF
   reply->qual[equa_cnt].components[comp_cnt].dcp_component_id = dec.dcp_component_id, reply->qual[
   equa_cnt].components[comp_cnt].component_flag = dec.component_flag, reply->qual[equa_cnt].
   components[comp_cnt].constant_value = dec.constant_value,
   reply->qual[equa_cnt].components[comp_cnt].component_label = dec.component_label, reply->qual[
   equa_cnt].components[comp_cnt].component_description = dec.component_description, reply->qual[
   equa_cnt].components[comp_cnt].event_cd = dec.event_cd,
   reply->qual[equa_cnt].components[comp_cnt].required_ind = dec.required_ind, reply->qual[equa_cnt].
   components[comp_cnt].corresponding_equation_id = dec.corresponding_equation_id, reply->qual[
   equa_cnt].components[comp_cnt].component_code = dec.component_code,
   unit_cnt = 0
  DETAIL
   IF (check="dum")
    unit_cnt = (unit_cnt+ 1)
    IF (unit_cnt > size(reply->qual[equa_cnt].components[comp_cnt].unit_measure,5))
     stat = alterlist(reply->qual[equa_cnt].components[comp_cnt].unit_measure,(unit_cnt+ 10))
    ENDIF
    reply->qual[equa_cnt].components[comp_cnt].unit_measure[unit_cnt].unit_measure_cd = dum
    .unit_measure_cd, reply->qual[equa_cnt].components[comp_cnt].unit_measure[unit_cnt].default_ind
     = dum.default_ind, reply->qual[equa_cnt].components[comp_cnt].unit_measure[unit_cnt].
    equation_dependent_unit_ind = dum.equation_dependent_unit_ind
   ENDIF
  FOOT  dec.dcp_component_id
   stat = alterlist(reply->qual[equa_cnt].components[comp_cnt].unit_measure,unit_cnt), reply->qual[
   equa_cnt].components[comp_cnt].number_units = unit_cnt
  FOOT  de.dcp_equation_id
   stat = alterlist(reply->qual[equa_cnt].components[comp_cnt],comp_cnt), reply->qual[equa_cnt].
   number_components = comp_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,equa_cnt)
  WITH check, outerjoin = d1, outerjoin = d2
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET reply->more_ind = 0
 GO TO exit_script
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP CLINICAL EQUATION TABLES"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO READ"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

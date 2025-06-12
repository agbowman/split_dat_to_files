CREATE PROGRAM ajt_get_pl_location:dba
 RECORD orgs(
   1 qual[*]
     2 org_id = f8
     2 confid_level = i4
 )
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 DECLARE dminfo_ok = i2 WITH noconstant(0)
 SET dminfo_ok = validate(ccldminfo->mode,0)
 CALL echo(concat("Ccldminfo exists= ",build(dminfo_ok)))
 IF (dminfo_ok=1)
  SET encntr_org_sec_ind = ccldminfo->sec_org_reltn
  SET confid_ind = ccldminfo->sec_confid
 ELSE
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_ind = 1
    ELSEIF (di.info_name="SEC_CONFID"
     AND di.info_number=1)
     confid_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (((encntr_org_sec_ind=1) OR (confid_ind=1)) )
  DECLARE org_cnt = i2 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM prsnl_org_reltn por
   WHERE (por.person_id=reqinfo->updt_id)
    AND por.active_ind=1
    AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   HEAD REPORT
    org_cnt = 0
   DETAIL
    org_cnt = (org_cnt+ 1)
    IF (mod(org_cnt,10)=1)
     stat = alterlist(orgs->qual,(org_cnt+ 9))
    ENDIF
    orgs->qual[org_cnt].org_id = por.organization_id
    IF (por.confid_level_cd > 0)
     orgs->qual[org_cnt].confid_level = uar_get_collation_seq(por.confid_level_cd)
    ELSE
     orgs->qual[org_cnt].confid_level = 0
    ENDIF
   FOOT REPORT
    stat = alterlist(orgs->qual,org_cnt)
   WITH nocounter
  ;end select
 ENDIF
 DECLARE ed_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE census_type_cd = f8 WITH noconstant(0.0)
 DECLARE cdf_meaning = vc WITH noconstant(fillstring(12,""))
 DECLARE fac_cd = f8 WITH noconstant(0.0)
 DECLARE bldg_cd = f8 WITH noconstant(0.0)
 DECLARE nu_cd = f8 WITH noconstant(0.0)
 DECLARE ambu_cd = f8 WITH noconstant(0.0)
 DECLARE room_cd = f8 WITH noconstant(0.0)
 DECLARE bed_cd = f8 WITH noconstant(0.0)
 DECLARE parser_fac_cd = f8 WITH noconstant(0.0)
 DECLARE parser_bldg_cd = f8 WITH noconstant(0.0)
 DECLARE parser_nu_cd = f8 WITH noconstant(0.0)
 DECLARE parser_ambu_cd = f8 WITH noconstant(0.0)
 DECLARE parser_room_cd = f8 WITH noconstant(0.0)
 DECLARE parser_bed_cd = f8 WITH noconstant(0.0)
 DECLARE code_value = f8 WITH noconstant(0.0)
 DECLARE filterind = i2 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE encntr_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE nbr_to_get = i4 WITH noconstant(cnvtint(size(request->encntr_type_filters,5)))
 DECLARE encntr_filter_ind = i4 WITH noconstant(0)
 DECLARE arg_nbr = i4 WITH noconstant(cnvtint(size(request->arguments,5)))
 DECLARE counter = i4 WITH noconstant(1)
 DECLARE location_cd = f8
 DECLARE lag_minutes = i4
 DECLARE patient_status_flag = i4 WITH noconstant(0)
 DECLARE patient_status_minutes = i4 WITH noconstant(0)
 SET target_dt_tm = cnvtdatetime(curdate,curtime3)
 DECLARE interval = vc
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE failed = c1
 SET failed = "F"
 SET fac_cd = uar_get_code_by("MEANING",222,"FACILITY")
 SET bldg_cd = uar_get_code_by("MEANING",222,"BUILDING")
 SET nu_cd = uar_get_code_by("MEANING",222,"NURSEUNIT")
 SET ambu_cd = uar_get_code_by("MEANING",222,"AMBULATORY")
 SET room_cd = uar_get_code_by("MEANING",222,"ROOM")
 SET bed_cd = uar_get_code_by("MEANING",222,"BED")
 SET census_type_cd = uar_get_code_by("MEANING",339,"CENSUS")
 FOR (counter = 1 TO arg_nbr)
   CASE (request->arguments[counter].argument_name)
    OF "location":
     SET location_cd = request->arguments[counter].parent_entity_id
    OF "lag_minutes":
     SET lag_minutes = cnvtint(request->arguments[counter].argument_value)
    OF "patient_status_flag":
     SET patient_status_flag = cnvtint(request->arguments[counter].argument_value)
    OF "patient_status_minutes":
     SET patient_status_minutes = cnvtint(request->arguments[counter].argument_value)
   ENDCASE
 ENDFOR
 IF (lag_minutes > 0)
  SET interval = build(abs(lag_minutes),"min")
  SET target_dt_tm = cnvtlookbehind(interval,cnvtdatetime(curdate,curtime3))
 ENDIF
 SET temp_dt_tm = cnvtdatetime(curdate,curtime3)
 SET temp_dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),- ((patient_status_minutes/ 1440.0)))
 CALL determineencntrselect(location_cd)
 CALL formatencounterselect(null)
 CALL formatencounterfilter(null)
 IF (((confid_ind=1) OR (encntr_org_sec_ind=1)) )
  SET filterind = 1
 ELSE
  SET filterind = 0
 ENDIF
 CALL echo(ed_where)
 CALL echo(encntr_where)
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   person p,
   dcp_pl_prioritization pr
  PLAN (ed
   WHERE parser(trim(ed_where)))
   JOIN (e
   WHERE parser(trim(encntr_where)))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (pr
   WHERE pr.patient_list_id=outerjoin(request->patient_list_id)
    AND pr.person_id=outerjoin(p.person_id))
  ORDER BY p.person_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->patients,(cnt+ 9))
   ENDIF
   reply->patients[cnt].person_id = p.person_id, reply->patients[cnt].person_name = p
   .name_full_formatted, reply->patients[cnt].encntr_id = e.encntr_id,
   reply->patients[cnt].organization_id = e.organization_id, reply->patients[cnt].confid_level_cd = e
   .confid_level_cd, reply->patients[cnt].confid_level = uar_get_collation_seq(e.confid_level_cd)
   IF ((reply->patients[cnt].confid_level < 0))
    reply->patients[cnt].confid_level = 0
   ENDIF
   reply->patients[cnt].priority = pr.priority
   IF (ed.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    reply->patients[cnt].active_ind = 1
   ELSE
    reply->patients[cnt].active_ind = 0
   ENDIF
   reply->patients[cnt].filter_ind = filterind
  FOOT REPORT
   stat = alterlist(reply->patients,cnt)
  WITH nocounter
 ;end select
 IF (((confid_ind=1) OR (encntr_org_sec_ind=1))
  AND cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    person_prsnl_reltn ppr,
    code_value_extension cve
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=1))
    JOIN (ppr
    WHERE (ppr.person_id=reply->patients[d.seq].person_id)
     AND (ppr.prsnl_person_id=reqinfo->updt_id)
     AND ppr.active_ind=1)
    JOIN (cve
    WHERE cve.code_value=ppr.person_prsnl_r_cd
     AND cve.field_name="Override"
     AND cve.code_set=331)
   DETAIL
    IF (((cve.field_value="2") OR (cve.field_value="1"
     AND ((confid_ind=0) OR ((reply->patients[d.seq].confid_level=0))) )) )
     reply->patients[d.seq].filter_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    (dummyt d2  WITH seq = value(org_cnt))
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=1))
    JOIN (d2
    WHERE (orgs->qual[d2.seq].org_id=reply->patients[d.seq].organization_id))
   DETAIL
    IF (((confid_ind=0) OR ((orgs->qual[d2.seq].confid_level >= reply->patients[d.seq].confid_level)
    )) )
     reply->patients[d.seq].filter_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    encntr_prsnl_reltn epr
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=1))
    JOIN (epr
    WHERE (epr.encntr_id=reply->patients[d.seq].encntr_id)
     AND (epr.prsnl_person_id=reqinfo->updt_id)
     AND epr.expiration_ind=0
     AND epr.active_ind=1
     AND epr.encntr_prsnl_r_cd > 0
     AND epr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    reply->patients[d.seq].filter_ind = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt))
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=0))
   HEAD REPORT
    actual_cnt = 0
   DETAIL
    actual_cnt = (actual_cnt+ 1), reply->patients[actual_cnt].person_id = reply->patients[d.seq].
    person_id, reply->patients[actual_cnt].person_name = reply->patients[d.seq].person_name,
    reply->patients[actual_cnt].encntr_id = reply->patients[d.seq].encntr_id, reply->patients[
    actual_cnt].priority = reply->patients[d.seq].priority, reply->patients[actual_cnt].active_ind =
    reply->patients[d.seq].active_ind,
    reply->patients[actual_cnt].organization_id = reply->patients[d.seq].organization_id, reply->
    patients[actual_cnt].confid_level_cd = reply->patients[d.seq].confid_level_cd, reply->patients[
    actual_cnt].confid_level = reply->patients[d.seq].confid_level,
    reply->patients[actual_cnt].filter_ind = reply->patients[d.seq].filter_ind
   FOOT REPORT
    cnt = actual_cnt, stat = alterlist(reply->patients,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cnt = 0
   SET stat = alterlist(reply->patients,cnt)
  ENDIF
 ENDIF
#finish
 IF (failed="F")
  IF (cnt=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 SUBROUTINE formatencounterselect(null)
   IF (patient_status_flag=0)
    SET encntr_where = "e.encntr_id = ed.encntr_id and e.active_ind = 1"
   ELSEIF (patient_status_flag=1)
    SET encntr_where = concat("e.encntr_id = ed.encntr_id and e.active_ind = 1 and e.reg_dt_tm",
     " between cnvtdatetime(temp_dt_tm) and cnvtdatetime(curdate,curtime)")
   ELSEIF (patient_status_flag=2)
    SET encntr_where = concat("e.encntr_id = ed.encntr_id and e.active_ind = 1 and e.disch_dt_tm",
     " between cnvtdatetime(temp_dt_tm) and cnvtdatetime(curdate,curtime)")
   ELSEIF (patient_status_flag=3)
    SET encntr_where = "e.encntr_id=ed.encntr_id and e.active_ind=1 and nullind(e.disch_dt_tm)=1"
   ELSE
    SET encntr_where = "e.encntr_id = ed.encntr_id and e.active_ind = 1"
   ENDIF
 END ;Subroutine
 SUBROUTINE formatencounterfilter(null)
   DECLARE nbr_to_get = i4 WITH noconstant(cnvtint(size(request->encntr_type_filters,5)))
   DECLARE encntr_cds = vc WITH noconstant(fillstring(1000," "))
   DECLARE counter = i2 WITH noconstant(0)
   IF (nbr_to_get > 0)
    IF ((request->encntr_type_filters[1].encntr_type_cd=0))
     SET encntr_cds =
     " and expand(counter, 1, nbr_to_get, e.encntr_class_cd, request->encntr_type_filters[counter].encntr_class_cd)"
    ELSE
     SET encntr_cds =
     " and expand(counter, 1, nbr_to_get, e.encntr_type_cd, request->encntr_type_filters[counter].encntr_type_cd)"
    ENDIF
    SET encntr_where = concat(encntr_where,encntr_cds)
   ENDIF
 END ;Subroutine
 SUBROUTINE determineencntrselect(loccd)
   DECLARE location_meaning = vc WITH noconstant(fillstring(50," "))
   SET location_meaning = uar_get_code_meaning(loccd)
   IF (location_meaning="FACILITY")
    SET parser_fac_cd = loccd
    SET ed_where = concat(" ed.encntr_domain_type_cd = ",format(census_type_cd,""),
     " and ed.loc_facility_Cd = ",format(parser_fac_cd,"")," and ed.active_ind = 1",
     " and ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
     " and ed.end_effective_dt_tm >= cnvtdatetime(temp_dt_tm)")
   ELSEIF (location_meaning="BUILDING")
    SET parser_bldg_cd = loccd
    SELECT INTO "nl:"
     FROM location_group lg
     WHERE lg.child_loc_cd=loccd
      AND ((lg.root_loc_cd+ 0)=0)
      AND lg.active_ind=1
      AND lg.location_group_type_cd IN (fac_cd, bldg_cd, nu_cd, ambu_cd, room_cd,
     bed_cd)
     DETAIL
      parser_fac_cd = lg.parent_loc_cd, parser_bldg_cd = lg.child_loc_cd
     WITH nocounter
    ;end select
    SET ed_where = concat(" ed.encntr_domain_type_cd = ",format(census_type_cd,""),
     " and ed.loc_facility_cd = ",format(parser_fac_cd,"")," and ed.loc_building_Cd = ",
     format(parser_bldg_cd,"")," and ed.active_ind = 1",
     " and ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
     " and ed.end_effective_dt_tm >= cnvtdatetime(temp_dt_tm)")
   ELSEIF (((location_meaning="NURSEUNIT") OR (location_meaning="AMBULATORY")) )
    SET parser_nu_cd = loccd
    SET ed_where = concat(" ed.loc_nurse_unit_Cd = ",format(parser_nu_cd,""),
     " and ed.end_effective_dt_tm >= cnvtdatetime(temp_dt_tm)",
     " and ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"," and ed.active_ind = 1",
     " and ed.encntr_domain_type_cd = ",format(census_type_cd,""))
   ELSEIF (location_meaning="ROOM")
    SET parser_room_cd = loccd
    SELECT INTO "nl:"
     FROM location_group lg
     PLAN (lg
      WHERE lg.child_loc_cd=loccd
       AND ((lg.root_loc_cd+ 0)=0)
       AND lg.active_ind=1
       AND lg.location_group_type_cd IN (fac_cd, bldg_cd, nu_cd, ambu_cd, room_cd,
      bed_cd))
     DETAIL
      parser_nu_cd = lg.parent_loc_cd, parser_room_cd = lg.child_loc_cd
     WITH nocounter
    ;end select
    SET ed_where = concat(" ed.encntr_domain_type_cd = ",format(census_type_cd,""),
     " and ed.loc_nurse_unit_Cd = ",format(parser_nu_cd,"")," and ed.loc_room_cd = ",
     format(parser_room_cd,"")," and ed.active_ind = 1",
     " and (ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))",
     " and (ed.end_effective_dt_tm >= cnvtdatetime(temp_dt_tm))")
   ELSEIF (location_meaning="BED")
    SET parser_bed_cd = loccd
    SELECT INTO "nl:"
     FROM location_group lg,
      location_group lg2
     PLAN (lg
      WHERE lg.child_loc_cd=loccd
       AND ((lg.root_loc_cd+ 0)=0)
       AND lg.active_ind=1
       AND lg.location_group_type_cd IN (fac_cd, bldg_cd, nu_cd, ambu_cd, room_cd,
      bed_cd))
      JOIN (lg2
      WHERE lg2.child_loc_cd=lg.parent_loc_cd
       AND ((lg2.root_loc_cd+ 0)=0)
       AND lg2.active_ind=1
       AND lg2.location_group_type_cd IN (fac_cd, bldg_cd, nu_cd, ambu_cd, room_cd,
      bed_cd))
     DETAIL
      parser_room_cd = lg.parent_loc_cd, parser_nu_cd = lg2.parent_loc_cd
     WITH nocounter
    ;end select
    SET ed_where = concat(" ed.encntr_domain_type_cd = ",format(census_type_cd,""),
     " and ed.loc_nurse_unit_Cd = ",format(parser_nu_cd,"")," and ed.loc_room_cd = ",
     format(parser_room_cd,"")," and ed.loc_bed_cd = ",format(parser_bed_cd,""),
     " and ed.active_ind = 1"," and (ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))",
     " and (ed.end_effective_dt_tm >= cnvtdatetime(temp_dt_tm))")
   ELSE
    SET failed = "T"
    SET reply->targetobjectname = "ScriptMessage"
    SET reply->targetobjectvalue = build("The location code ",loccd," is an invalid value.")
    GO TO finish
   ENDIF
 END ;Subroutine
END GO

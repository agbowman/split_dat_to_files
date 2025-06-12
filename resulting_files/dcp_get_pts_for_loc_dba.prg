CREATE PROGRAM dcp_get_pts_for_loc:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 name_full_formatted = vc
     2 active_ind = i2
     2 priority_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 location
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
   1 org_cnt = i2
   1 orglist[*]
     2 org_id = f8
     2 confid_level = i4
 )
 SET reply->status_data.status = "F"
 SET cur_dt_tm = cnvtdatetime(curdate,curtime3)
 SET location_type = fillstring(12," ")
 SET location_type = uar_get_code_meaning(request->location_cd)
 IF ((request->lag_minutes > 0))
  SET interval = build(abs(request->lag_minutes),"min")
  SET target_dt_tm = cnvtlookbehind(interval,cnvtdatetime(curdate,curtime3))
 ELSE
  SET target_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 SET cnt = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12,"")
 SET fac_cd = 0
 SET bldg_cd = 0
 SET nu_cd = 0
 SET ambu_cd = 0
 SET room_cd = 0
 SET bed_cd = 0
 SET code_set = 222
 SET cdf_meaning = "FACILITY"
 EXECUTE cpm_get_cd_for_cdf
 SET fac_cd = code_value
 SET code_set = 222
 SET cdf_meaning = "BUILDING"
 EXECUTE cpm_get_cd_for_cdf
 SET bldg_cd = code_value
 SET code_set = 222
 SET cdf_meaning = "NURSEUNIT  "
 EXECUTE cpm_get_cd_for_cdf
 SET nu_cd = code_value
 SET code_set = 222
 SET cdf_meaning = "AMBULATORY"
 EXECUTE cpm_get_cd_for_cdf
 SET ambu_cd = code_value
 SET code_set = 222
 SET cdf_meaning = "ROOM"
 EXECUTE cpm_get_cd_for_cdf
 SET room_cd = code_value
 SET code_set = 222
 SET cdf_meaning = "BED"
 EXECUTE cpm_get_cd_for_cdf
 SET bed_cd = code_value
 SET child_cd_hold = request->location_cd
 SET doneflag = 0
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
 WHILE ((temp->location.loc_facility_cd=0)
  AND doneflag=0)
  SELECT INTO "nl:"
   lg.parent_loc_cd, lg.child_loc_cd, lg.location_group_type_cd,
   lg.root_loc_cd, cv.code_value, cv.cdf_meaning
   FROM location_group lg,
    code_value cv
   PLAN (lg
    WHERE lg.child_loc_cd=child_cd_hold
     AND ((lg.root_loc_cd+ 0)=0)
     AND lg.active_ind=1
     AND lg.location_group_type_cd IN (fac_cd, bldg_cd, nu_cd, ambu_cd, room_cd,
    bed_cd))
    JOIN (cv
    WHERE cv.code_value=lg.parent_loc_cd
     AND cv.active_ind=1)
   HEAD REPORT
    rec_qual = 0, child_cd_hold = 0
   DETAIL
    CASE (cv.cdf_meaning)
     OF "FACILITY":
      temp->location.loc_facility_cd = lg.parent_loc_cd,temp->location.loc_building_cd = lg
      .child_loc_cd
     OF "BUILDING":
      temp->location.loc_building_cd = lg.parent_loc_cd,temp->location.loc_unit_cd = lg.child_loc_cd
     OF "NURSEUNIT":
      temp->location.loc_unit_cd = lg.parent_loc_cd,temp->location.loc_room_cd = lg.child_loc_cd
     OF "AMBULATORY":
      temp->location.loc_unit_cd = lg.parent_loc_cd,temp->location.loc_room_cd = lg.child_loc_cd
     OF "ROOM":
      temp->location.loc_room_cd = lg.parent_loc_cd,temp->location.loc_bed_cd = lg.child_loc_cd
     OF "BED":
      temp->location.loc_bed_cd = lg.parent_loc_cd
    ENDCASE
    child_cd_hold = lg.parent_loc_cd
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET doneflag = 1
  ENDIF
 ENDWHILE
 IF ((temp->location.loc_facility_cd=0))
  SET reply->status_data.status = "Z"
  GO TO finish
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (((encntr_org_sec_ind=1) OR (confid_ind=1)) )
  SET temp->org_cnt = 0
  SELECT INTO "nl:"
   c.collation_seq
   FROM prsnl_org_reltn por,
    (dummyt d  WITH seq = 1),
    code_value c
   PLAN (por
    WHERE (por.person_id=request->prsnl_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d)
    JOIN (c
    WHERE c.code_value=por.confid_level_cd)
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), stat = alterlist(temp->orglist,count), temp->orglist[count].org_id = por
    .organization_id
    IF (confid_ind=1)
     IF (c.collation_seq > 0)
      temp->orglist[count].confid_level = c.collation_seq
     ELSE
      temp->orglist[count].confid_level = 0
     ENDIF
    ELSE
     temp->orglist[count].confid_level = 9999
    ENDIF
   FOOT REPORT
    temp->org_cnt = count
   WITH nocounter, outerjoin = d
  ;end select
 ENDIF
 IF (((encntr_org_sec_ind=1) OR (confid_ind=1)) )
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh,
    encounter e,
    code_value c1,
    (dummyt d  WITH seq = value(temp->org_cnt)),
    person p
   PLAN (elh
    WHERE elh.end_effective_dt_tm >= cnvtdatetime(target_dt_tm)
     AND (elh.loc_facility_cd=temp->location.loc_facility_cd)
     AND (((elh.loc_building_cd=temp->location.loc_building_cd)) OR ((temp->location.loc_building_cd=
    0)))
     AND (((elh.loc_nurse_unit_cd=temp->location.loc_unit_cd)) OR ((temp->location.loc_unit_cd=0)))
     AND (((elh.loc_room_cd=temp->location.loc_room_cd)) OR ((temp->location.loc_room_cd=0)))
     AND (((elh.loc_bed_cd=temp->location.loc_bed_cd)) OR ((temp->location.loc_bed_cd=0)))
     AND elh.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=elh.encntr_id)
    JOIN (c1
    WHERE c1.code_value=e.confid_level_cd)
    JOIN (d
    WHERE (e.organization_id=temp->orglist[d.seq].org_id)
     AND (c1.collation_seq <= temp->orglist[d.seq].confid_level))
    JOIN (p
    WHERE p.person_id=e.person_id)
   ORDER BY elh.encntr_id, elh.updt_dt_tm DESC
   HEAD elh.encntr_id
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].person_id = p.person_id,
    reply->qual[cnt].encntr_id = e.encntr_id, reply->qual[cnt].name_full_formatted = p
    .name_full_formatted, reply->qual[cnt].priority_flag = 0
    IF (elh.end_effective_dt_tm > cnvtdatetime(cur_dt_tm))
     reply->qual[cnt].active_ind = 1
    ELSE
     reply->qual[cnt].active_ind = 0
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh,
    encounter e,
    person p
   PLAN (elh
    WHERE elh.end_effective_dt_tm >= cnvtdatetime(target_dt_tm)
     AND (elh.loc_facility_cd=temp->location.loc_facility_cd)
     AND (((elh.loc_building_cd=temp->location.loc_building_cd)) OR ((temp->location.loc_building_cd=
    0)))
     AND (((elh.loc_nurse_unit_cd=temp->location.loc_unit_cd)) OR ((temp->location.loc_unit_cd=0)))
     AND (((elh.loc_room_cd=temp->location.loc_room_cd)) OR ((temp->location.loc_room_cd=0)))
     AND (((elh.loc_bed_cd=temp->location.loc_bed_cd)) OR ((temp->location.loc_bed_cd=0)))
     AND elh.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=elh.encntr_id)
    JOIN (p
    WHERE p.person_id=e.person_id)
   ORDER BY elh.encntr_id, elh.updt_dt_tm DESC
   HEAD elh.encntr_id
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].person_id = p.person_id,
    reply->qual[cnt].encntr_id = e.encntr_id, reply->qual[cnt].name_full_formatted = p
    .name_full_formatted, reply->qual[cnt].priority_flag = 0
    IF (elh.end_effective_dt_tm > cnvtdatetime(cur_dt_tm))
     reply->qual[cnt].active_ind = 1
    ELSE
     reply->qual[cnt].active_ind = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#finish
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

CREATE PROGRAM dcp_migrate_shift_asgmts:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 migrate[*]
     2 assignment_id = f8
     2 careteam_name = vc
     2 prsnl_id = f8
     2 prsnl_pos_cd = f8
     2 assigmt_group_cd = f8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 person_id = f8
     2 encntr_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 pct_care_team_id = f8
 )
 DECLARE migrate_count = i4 WITH public, noconstant(0)
 DECLARE migrate_cnt = i4 WITH public, noconstant(0)
 DECLARE g_failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  dpctcareteamid = validate(sa.pct_care_team_id,0.0)
  FROM dcp_shift_assignment sa,
   dcp_care_team ct,
   dcp_care_team_prsnl ctp,
   prsnl p,
   prsnl p2
  PLAN (sa
   WHERE sa.end_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND sa.assignment_id > 0
    AND sa.purge_ind=0)
   JOIN (ct
   WHERE ct.careteam_id=outerjoin(sa.careteam_id))
   JOIN (ctp
   WHERE ctp.careteam_id=outerjoin(ct.careteam_id))
   JOIN (p
   WHERE p.person_id=sa.prsnl_id)
   JOIN (p2
   WHERE p2.person_id=outerjoin(ctp.prsnl_id))
  HEAD REPORT
   migrate_count = 0
  DETAIL
   migrate_count = (migrate_count+ 1), stat = alterlist(temp->migrate,migrate_count), temp->migrate[
   migrate_count].assignment_id = sa.assignment_id
   IF (sa.prsnl_id > 0)
    temp->migrate[migrate_count].careteam_name = "", temp->migrate[migrate_count].prsnl_id = sa
    .prsnl_id, temp->migrate[migrate_count].prsnl_pos_cd = p.position_cd
   ELSE
    temp->migrate[migrate_count].careteam_name = ct.name, temp->migrate[migrate_count].prsnl_id = ctp
    .prsnl_id, temp->migrate[migrate_count].prsnl_pos_cd = p2.position_cd
   ENDIF
   temp->migrate[migrate_count].assigmt_group_cd = sa.assignment_group_cd, temp->migrate[
   migrate_count].loc_facility_cd = sa.loc_facility_cd, temp->migrate[migrate_count].loc_building_cd
    = sa.loc_building_cd,
   temp->migrate[migrate_count].loc_unit_cd = sa.loc_unit_cd, temp->migrate[migrate_count].
   loc_room_cd = sa.loc_room_cd, temp->migrate[migrate_count].loc_bed_cd = sa.loc_bed_cd,
   temp->migrate[migrate_count].person_id = sa.person_id, temp->migrate[migrate_count].encntr_id = sa
   .encntr_id, temp->migrate[migrate_count].pct_care_team_id = dpctcareteamid
   IF (sa.careteam_id=0)
    temp->migrate[migrate_count].beg_effective_dt_tm = cnvtdatetime(sa.beg_effective_dt_tm), temp->
    migrate[migrate_count].end_effective_dt_tm = cnvtdatetime(sa.end_effective_dt_tm)
   ELSE
    IF (sa.beg_effective_dt_tm > ctp.beg_effective_dt_tm)
     temp->migrate[migrate_count].beg_effective_dt_tm = cnvtdatetime(sa.beg_effective_dt_tm)
    ELSE
     temp->migrate[migrate_count].beg_effective_dt_tm = cnvtdatetime(ctp.beg_effective_dt_tm)
    ENDIF
    IF (sa.end_effective_dt_tm < ctp.end_effective_dt_tm)
     temp->migrate[migrate_count].end_effective_dt_tm = cnvtdatetime(sa.end_effective_dt_tm)
    ELSE
     temp->migrate[migrate_count].end_effective_dt_tm = cnvtdatetime(ctp.end_effective_dt_tm)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 DECLARE dsast_pct_field_fnd = i2 WITH public, noconstant(0)
 RANGE OF dsast IS cn_dcp_shift_assignment_st
 SET dsast_pct_field_fnd = validate(dsast.pct_care_team_id)
 FREE RANGE dsast
 FOR (migrate_cnt = 1 TO migrate_count)
   IF (dsast_pct_field_fnd=1)
    INSERT  FROM cn_dcp_shift_assignment_st sast
     SET sast.cn_dcp_shift_assignment_st_id = seq(dcp_assignment_seq,nextval), sast.careteam_name =
      temp->migrate[migrate_cnt].careteam_name, sast.prsnl_id = temp->migrate[migrate_cnt].prsnl_id,
      sast.prsnl_pos_cd = temp->migrate[migrate_cnt].prsnl_pos_cd, sast.assignment_group_cd = temp->
      migrate[migrate_cnt].assigmt_group_cd, sast.loc_facility_cd = temp->migrate[migrate_cnt].
      loc_facility_cd,
      sast.loc_building_cd = temp->migrate[migrate_cnt].loc_building_cd, sast.loc_unit_cd = temp->
      migrate[migrate_cnt].loc_unit_cd, sast.loc_room_cd = temp->migrate[migrate_cnt].loc_room_cd,
      sast.loc_bed_cd = temp->migrate[migrate_cnt].loc_bed_cd, sast.person_id = temp->migrate[
      migrate_cnt].person_id, sast.encntr_id = temp->migrate[migrate_cnt].encntr_id,
      sast.beg_effective_dt_tm = cnvtdatetime(temp->migrate[migrate_cnt].beg_effective_dt_tm), sast
      .end_effective_dt_tm = cnvtdatetime(temp->migrate[migrate_cnt].end_effective_dt_tm), sast
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      sast.updt_id = reqinfo->updt_id, sast.updt_applctx = reqinfo->updt_applctx, sast.updt_cnt = 0,
      sast.updt_task = reqinfo->updt_task, sast.pct_care_team_id = temp->migrate[migrate_cnt].
      pct_care_team_id
     WITH nocounter
    ;end insert
   ELSE
    INSERT  FROM cn_dcp_shift_assignment_st sast
     SET sast.cn_dcp_shift_assignment_st_id = seq(dcp_assignment_seq,nextval), sast.careteam_name =
      temp->migrate[migrate_cnt].careteam_name, sast.prsnl_id = temp->migrate[migrate_cnt].prsnl_id,
      sast.prsnl_pos_cd = temp->migrate[migrate_cnt].prsnl_pos_cd, sast.assignment_group_cd = temp->
      migrate[migrate_cnt].assigmt_group_cd, sast.loc_facility_cd = temp->migrate[migrate_cnt].
      loc_facility_cd,
      sast.loc_building_cd = temp->migrate[migrate_cnt].loc_building_cd, sast.loc_unit_cd = temp->
      migrate[migrate_cnt].loc_unit_cd, sast.loc_room_cd = temp->migrate[migrate_cnt].loc_room_cd,
      sast.loc_bed_cd = temp->migrate[migrate_cnt].loc_bed_cd, sast.person_id = temp->migrate[
      migrate_cnt].person_id, sast.encntr_id = temp->migrate[migrate_cnt].encntr_id,
      sast.beg_effective_dt_tm = cnvtdatetime(temp->migrate[migrate_cnt].beg_effective_dt_tm), sast
      .end_effective_dt_tm = cnvtdatetime(temp->migrate[migrate_cnt].end_effective_dt_tm), sast
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      sast.updt_id = reqinfo->updt_id, sast.updt_applctx = reqinfo->updt_applctx, sast.updt_cnt = 0,
      sast.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 FOR (migrate_cnt = 1 TO migrate_count)
   SELECT INTO "nl:"
    sa.assignment_id
    FROM dcp_shift_assignment sa
    WHERE (sa.assignment_id=temp->migrate[migrate_cnt].assignment_id)
    DETAIL
     cur_updt_cnt = sa.updt_cnt
    WITH nocounter, forupdate(sa)
   ;end select
   IF (curqual=0)
    CALL echo("Lock row for update failed since curqual = 0")
    SET g_failed = "T"
    GO TO exit_script
   ENDIF
   UPDATE  FROM dcp_shift_assignment sa
    SET sa.purge_ind = 1
    WHERE (sa.assignment_id=temp->migrate[migrate_cnt].assignment_id)
    WITH nocounter
   ;end update
 ENDFOR
#exit_script
 IF (g_failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

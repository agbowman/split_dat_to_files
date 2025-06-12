CREATE PROGRAM dcp_get_assign_aprsnl:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 active_ind = i2
     2 priority_flag = i2
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 org_cnt = i2
   1 orglist[*]
     2 org_id = f8
     2 confid_level = i4
   1 cd_list[*]
     2 task_type_cd = f8
 )
 SET reply->status_data.status = "F"
 SET separator = fillstring(25,"=")
 SET separator2 = fillstring(25,"*")
 SET cd_cnt = 0
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 SET confid_level = 0
 SET collation_seq = 0
 SET person_cnt = 0
 SET encntr_cnt = 0
 SET prsnl_position_cd = 0.0
 SET count = 0
 SET flag = 0
 SET cur_dt_tm = cnvtdatetime(curdate,curtime3)
 SET overdue_cd = 0.0
 SET junk = uar_get_meaning_by_codeset(79,"OVERDUE",1,overdue_cd)
 IF ((request->lag_time_min > 0))
  SET interval = build(abs(request->lag_time_min),"min")
  SET e_dt_tm = cnvtlookahead(interval,cnvtdatetime(curdate,curtime3))
  SET b_dt_tm = cnvtlookbehind(interval,cnvtdatetime(curdate,curtime3))
 ELSE
  SET e_dt_tm = cnvtdatetime(curdate,curtime3)
  SET b_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl pr
  WHERE (pr.person_id=request->prsnl_id)
  DETAIL
   prsnl_position_cd = pr.position_cd
  WITH nocounter
 ;end select
 IF (validate(ccldminfo->mode,0))
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
   WITH nocounter
  ;end select
 ENDIF
 SELECT DISTINCT INTO "nl:"
  elh.encntr_id
  FROM dcp_care_team_prsnl ctp,
   dcp_shift_assignment sa,
   encntr_loc_hist elh,
   person p,
   encounter e,
   order_task ot,
   dummyt d1,
   task_activity ta,
   code_value c1,
   order_task_position_xref otpx
  PLAN (ctp
   WHERE (((ctp.prsnl_id=request->prsnl_id)
    AND ((ctp.beg_effective_dt_tm <= cnvtdatetime(b_dt_tm)
    AND ctp.end_effective_dt_tm >= cnvtdatetime(b_dt_tm)) OR (ctp.beg_effective_dt_tm >= cnvtdatetime
   (b_dt_tm)
    AND ctp.beg_effective_dt_tm <= cnvtdatetime(e_dt_tm))) ) OR (ctp.prsnl_id=0)) )
   JOIN (sa
   WHERE sa.careteam_id=ctp.careteam_id
    AND ((sa.prsnl_id=0) OR ((sa.prsnl_id=request->prsnl_id)))
    AND ((sa.beg_effective_dt_tm <= cnvtdatetime(b_dt_tm)
    AND sa.end_effective_dt_tm >= cnvtdatetime(b_dt_tm)) OR (sa.beg_effective_dt_tm >= cnvtdatetime(
    b_dt_tm)
    AND sa.beg_effective_dt_tm <= cnvtdatetime(e_dt_tm))) )
   JOIN (elh
   WHERE ((elh.loc_facility_cd=sa.loc_facility_cd
    AND ((elh.loc_building_cd=sa.loc_building_cd) OR (sa.loc_building_cd=0))
    AND ((elh.loc_nurse_unit_cd=sa.loc_unit_cd) OR (sa.loc_unit_cd=0))
    AND ((elh.loc_room_cd=sa.loc_room_cd) OR (sa.loc_room_cd=0))
    AND ((elh.loc_bed_cd=sa.loc_bed_cd) OR (sa.loc_bed_cd=0))
    AND sa.encntr_id=0
    AND elh.active_ind=1
    AND elh.end_effective_dt_tm > cnvtdatetime(b_dt_tm)) OR (elh.loc_facility_cd=sa.loc_facility_cd
    AND ((elh.loc_building_cd=sa.loc_building_cd) OR (sa.loc_building_cd=0))
    AND ((elh.loc_nurse_unit_cd=sa.loc_unit_cd) OR (sa.loc_unit_cd=0))
    AND elh.encntr_id=sa.encntr_id
    AND elh.active_ind=1
    AND elh.end_effective_dt_tm > cnvtdatetime(b_dt_tm))) )
   JOIN (e
   WHERE elh.encntr_id=e.encntr_id)
   JOIN (c1
   WHERE c1.code_value=e.confid_level_cd)
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (ta
   WHERE ta.encntr_id=e.encntr_id
    AND ((ta.task_dt_tm >= sa.beg_effective_dt_tm
    AND ta.task_dt_tm <= sa.end_effective_dt_tm) OR (ta.task_status_cd=overdue_cd)) )
   JOIN (ot
   WHERE ot.reference_task_id=ta.reference_task_id)
   JOIN (d1)
   JOIN (otpx
   WHERE ot.allpositionchart_ind=0
    AND otpx.reference_task_id=ot.reference_task_id
    AND otpx.position_cd=prsnl_position_cd)
  ORDER BY p.person_id, e.encntr_id, sa.updt_dt_tm DESC
  HEAD REPORT
   person_cnt = 0
  HEAD p.person_id
   encntr_cnt = 0, person_added = 0
  HEAD e.encntr_id
   CALL checkforsecurity(e.organization_id,c1.collation_seq)
   IF (flag=1)
    IF (person_added=0)
     person_cnt = (person_cnt+ 1), stat = alterlist(reply->qual,person_cnt), reply->qual[person_cnt].
     person_id = p.person_id,
     reply->qual[person_cnt].name_full_formatted = p.name_full_formatted, reply->qual[person_cnt].
     priority_flag = 0
     IF (elh.end_effective_dt_tm > cnvtdatetime(cur_dt_tm)
      AND sa.end_effective_dt_tm > cnvtdatetime(cur_dt_tm))
      IF (((ctp.careteam_id=0) OR (ctp.end_effective_dt_tm > cnvtdatetime(cur_dt_tm))) )
       reply->qual[person_cnt].active_ind = 1
      ELSE
       reply->qual[person_cnt].active_ind = 0
      ENDIF
     ELSE
      reply->qual[person_cnt].active_ind = 0
     ENDIF
     person_added = (person_added+ 1)
    ENDIF
    encntr_cnt = (encntr_cnt+ 1)
    IF (encntr_cnt=1)
     reply->qual[person_cnt].encntr_id = e.encntr_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (person_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE checkforsecurity(organization_id,collation_seq)
   IF (encntr_org_sec_ind=0
    AND confid_ind=0)
    SET flag = 1
   ELSE
    SET count = size(temp->orglist,5)
    FOR (x = 1 TO count)
      IF ((((temp->orglist[x].org_id=organization_id)
       AND confid_ind=0) OR (confid_ind=1
       AND (temp->orglist[x].org_id=organization_id)
       AND (temp->orglist[x].confid_level >= collation_seq))) )
       SET flag = 1
       SET x = count
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
END GO

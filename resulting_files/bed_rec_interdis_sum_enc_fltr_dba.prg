CREATE PROGRAM bed_rec_interdis_sum_enc_fltr:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->run_status_flag = 1
 DECLARE powerchart_value = vc
 DECLARE surginet_value = vc
 DECLARE firstnet_value = vc
 SET powerchart_failed = 0
 SET surginet_failed = 0
 SET firstnet_failed = 0
 SET powerchart_exists = 0
 SET surginet_exists = 0
 SET firstnet_exists = 0
 SELECT INTO "nl:"
  FROM view_prefs a,
   view_comp_prefs vcp,
   detail_prefs dp,
   name_value_prefs nvp
  PLAN (a
   WHERE a.application_number IN (600005, 820000, 4250111)
    AND a.view_name="INT_DIS_SUM"
    AND a.position_cd=0
    AND a.prsnl_id=0
    AND a.active_ind=1)
   JOIN (vcp
   WHERE vcp.application_number=a.application_number
    AND vcp.view_name="INT_DIS_SUM"
    AND vcp.comp_name="INT_DIS_SUM"
    AND vcp.position_cd=0
    AND vcp.prsnl_id=0
    AND vcp.active_ind=1
    AND vcp.view_seq=a.view_seq)
   JOIN (dp
   WHERE dp.application_number=outerjoin(vcp.application_number)
    AND dp.view_name=outerjoin(vcp.view_name)
    AND dp.comp_name=outerjoin(vcp.comp_name)
    AND dp.position_cd=outerjoin(vcp.position_cd)
    AND dp.prsnl_id=outerjoin(vcp.prsnl_id)
    AND dp.active_ind=outerjoin(1)
    AND dp.view_seq=outerjoin(vcp.view_seq)
    AND dp.comp_seq=outerjoin(vcp.comp_seq))
   JOIN (nvp
   WHERE nvp.parent_entity_name=outerjoin("DETAIL_PREFS")
    AND nvp.parent_entity_id=outerjoin(dp.detail_prefs_id)
    AND trim(nvp.pvc_name)=outerjoin("INTERDIS_SUM_ENCNTR_SPECIFIC")
    AND nvp.active_ind=outerjoin(1))
  DETAIL
   IF (vcp.application_number=600005)
    powerchart_exists = 1, powerchart_value = nvp.pvc_value
    IF (nvp.pvc_value != "1")
     powerchart_failed = 1
    ENDIF
   ELSEIF (vcp.application_number=820000)
    surginet_exists = 1, surginet_value = nvp.pvc_value
    IF (nvp.pvc_value != "1")
     surginet_failed = 1
    ENDIF
   ELSEIF (vcp.application_number=4250111)
    firstnet_exists = 1, firstnet_value = nvp.pvc_value
    IF (nvp.pvc_value != "1")
     firstnet_failed = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (((powerchart_failed=1) OR (((surginet_failed=1) OR (firstnet_failed=1)) )) )
  SET reply->run_status_flag = 3
 ENDIF
 IF ((reply->run_status_flag=1))
  FREE SET temp_dis
  RECORD temp_dis(
    1 pos[*]
      2 app = i4
      2 code = f8
      2 global_ind = i2
      2 tab = i2
  )
  SET dis_cnt = 0
  SELECT INTO "nl:"
   FROM code_value cv,
    view_comp_prefs a,
    prsnl p
   PLAN (cv
    WHERE cv.code_set=88
     AND cv.active_ind=1)
    JOIN (p
    WHERE p.position_cd=cv.code_value
     AND p.active_ind=1)
    JOIN (a
    WHERE a.application_number > outerjoin(0)
     AND a.position_cd=outerjoin(p.position_cd)
     AND a.prsnl_id=outerjoin(0)
     AND a.active_ind=outerjoin(1))
   ORDER BY cv.code_value, a.application_number
   HEAD REPORT
    dis_cnt = 0
   HEAD cv.code_value
    dis_cnt = (dis_cnt+ 3), stat = alterlist(temp_dis->pos,dis_cnt), temp_dis->pos[(dis_cnt - 2)].
    code = cv.code_value,
    temp_dis->pos[(dis_cnt - 2)].app = 600005, temp_dis->pos[(dis_cnt - 2)].global_ind = 1, temp_dis
    ->pos[(dis_cnt - 1)].code = cv.code_value,
    temp_dis->pos[(dis_cnt - 1)].app = 820000, temp_dis->pos[(dis_cnt - 1)].global_ind = 1, temp_dis
    ->pos[dis_cnt].code = cv.code_value,
    temp_dis->pos[dis_cnt].app = 4250111, temp_dis->pos[dis_cnt].global_ind = 1
   HEAD a.application_number
    IF (a.application_number=600005)
     temp_dis->pos[(dis_cnt - 2)].global_ind = 0
    ENDIF
    IF (a.application_number=820000)
     temp_dis->pos[(dis_cnt - 1)].global_ind = 0
    ENDIF
    IF (a.application_number=4250111)
     temp_dis->pos[dis_cnt].global_ind = 0
    ENDIF
   DETAIL
    IF (a.view_name="INT_DIS_SUM"
     AND a.comp_name="INT_DIS_SUM")
     IF (a.application_number=600005)
      temp_dis->pos[(dis_cnt - 2)].tab = 1
     ENDIF
     IF (a.application_number=820000)
      temp_dis->pos[(dis_cnt - 1)].tab = 1
     ENDIF
     IF (a.application_number=4250111)
      temp_dis->pos[dis_cnt].tab = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (dis_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dis_cnt)),
     code_value cv,
     detail_prefs dp,
     name_value_prefs nvp
    PLAN (d)
     JOIN (cv
     WHERE (cv.code_value=temp_dis->pos[d.seq].code))
     JOIN (dp
     WHERE dp.application_number=outerjoin(temp_dis->pos[d.seq].app)
      AND dp.view_name=outerjoin("INT_DIS_SUM")
      AND dp.comp_name=outerjoin("INT_DIS_SUM")
      AND dp.position_cd=outerjoin(cv.code_value)
      AND dp.prsnl_id=outerjoin(0)
      AND dp.active_ind=outerjoin(1))
     JOIN (nvp
     WHERE nvp.parent_entity_name=outerjoin("DETAIL_PREFS")
      AND nvp.parent_entity_id=outerjoin(dp.detail_prefs_id)
      AND trim(nvp.pvc_name)=outerjoin("INTERDIS_SUM_ENCNTR_SPECIFIC")
      AND nvp.active_ind=outerjoin(1))
    ORDER BY cv.display, cv.code_value, dp.application_number
    HEAD cv.code_value
     pc = 0, sn = 0, fn = 0
    DETAIL
     IF (dp.application_number=600005
      AND (((temp_dis->pos[d.seq].global_ind=1)
      AND powerchart_exists=1) OR ((temp_dis->pos[d.seq].tab=1))) )
      pc = 1
      IF (((nvp.name_value_prefs_id > 0
       AND nvp.pvc_value != "1") OR (nvp.name_value_prefs_id=0
       AND ((powerchart_exists=1
       AND powerchart_failed=1) OR (powerchart_exists=0)) )) )
       reply->run_status_flag = 3
      ENDIF
     ELSEIF (dp.application_number=820000
      AND (((temp_dis->pos[d.seq].global_ind=1)
      AND surginet_exists=1) OR ((temp_dis->pos[d.seq].tab=1))) )
      sn = 1
      IF (((nvp.name_value_prefs_id > 0
       AND nvp.pvc_value != "1") OR (nvp.name_value_prefs_id=0
       AND ((surginet_exists=1
       AND surginet_failed=1) OR (surginet_exists=0)) )) )
       reply->run_status_flag = 3
      ENDIF
     ELSEIF (dp.application_number=4250111
      AND (((temp_dis->pos[d.seq].global_ind=1)
      AND firstnet_exists=1) OR ((temp_dis->pos[d.seq].tab=1))) )
      fn = 1
      IF (((nvp.name_value_prefs_id > 0
       AND nvp.pvc_value != "1") OR (nvp.name_value_prefs_id=0
       AND ((firstnet_exists=1
       AND firstnet_failed=1) OR (firstnet_exists=0)) )) )
       reply->run_status_flag = 3
      ENDIF
     ENDIF
     IF (dp.detail_prefs_id=0
      AND (temp_dis->pos[d.seq].global_ind=0)
      AND (temp_dis->pos[d.seq].tab=1)
      AND (((temp_dis->pos[d.seq].app=600005)
      AND ((powerchart_failed=1) OR (powerchart_exists=0)) ) OR ((((temp_dis->pos[d.seq].app=820000)
      AND ((surginet_failed=1) OR (surginet_exists=0)) ) OR ((temp_dis->pos[d.seq].app=4250111)
      AND ((firstnet_failed=1) OR (firstnet_exists=0)) )) )) )
      reply->run_status_flag = 3
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO

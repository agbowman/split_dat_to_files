CREATE PROGRAM bed_aud_sch_rad_int:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE SET appt
 RECORD appt(
   1 appt[*]
     2 appt_cd = f8
     2 rad = i2
     2 rad_opt = i2
     2 description = vc
     2 locs[*]
       3 loc_cd = f8
       3 display = vc
     2 roles[*]
       3 role_id = f8
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM sch_appt_type sat,
    sch_order_appt soa,
    sch_order_role sor
   PLAN (sat
    WHERE sat.active_ind=1)
    JOIN (soa
    WHERE soa.appt_type_cd=sat.appt_type_cd
     AND soa.active_ind=1)
    JOIN (sor
    WHERE sor.catalog_cd=soa.catalog_cd)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = "Appointment Type Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Ambulatory Location"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Orderable"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Order Role"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Resource Name"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Associated Radiology Room Display"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Radiology Room Meaning"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Resource Role"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Resource Role Meaning"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET appt_cnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM sch_appt_type sat,
   sch_appt_option sao,
   sch_appt_loc sal,
   sch_order_appt soa,
   sch_order_role sor,
   sch_order_loc sol,
   sch_list_role slr,
   sch_list_res slr2,
   sch_resource sr,
   sch_res_role srr
  PLAN (sat
   WHERE sat.active_ind=1)
   JOIN (sal
   WHERE sal.appt_type_cd=sat.appt_type_cd
    AND sal.active_ind=1)
   JOIN (soa
   WHERE soa.appt_type_cd=sal.appt_type_cd
    AND soa.active_ind=1)
   JOIN (sol
   WHERE sol.catalog_cd=soa.catalog_cd
    AND sol.location_cd=sal.location_cd
    AND sol.active_ind=1)
   JOIN (sor
   WHERE sor.catalog_cd=soa.catalog_cd
    AND sor.location_cd=sol.location_cd
    AND sor.active_ind=1)
   JOIN (slr
   WHERE slr.list_role_id=sor.list_role_id
    AND slr.version_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
    AND slr.active_ind=1)
   JOIN (slr2
   WHERE slr2.list_role_id=slr.list_role_id
    AND slr2.active_ind=1)
   JOIN (sr
   WHERE sr.resource_cd=outerjoin(slr2.resource_cd)
    AND sr.res_type_flag=outerjoin(3)
    AND sr.active_ind=outerjoin(1))
   JOIN (srr
   WHERE srr.sch_role_cd=outerjoin(slr.sch_role_cd)
    AND srr.role_meaning=outerjoin("EXAMROOM")
    AND srr.active_ind=outerjoin(1))
   JOIN (sao
   WHERE sao.active_ind=outerjoin(1)
    AND sao.appt_type_cd=outerjoin(sat.appt_type_cd)
    AND sao.option_meaning=outerjoin("RADSRVES"))
  ORDER BY sat.description, sat.appt_type_cd, sol.location_cd,
   sor.list_role_id
  HEAD sat.appt_type_cd
   appt_cnt = (appt_cnt+ 1), stat = alterlist(appt->appt,appt_cnt), appt->appt[appt_cnt].appt_cd =
   sat.appt_type_cd,
   appt->appt[appt_cnt].description = sat.description, fcnt = 0, cnt = 0,
   stat = alterlist(appt->appt[appt_cnt].locs,10), rtcnt = 0, rcnt = 0,
   stat = alterlist(appt->appt[appt_cnt].roles,10)
  HEAD sol.location_cd
   loaded_ind = 0
  DETAIL
   IF (sao.option_meaning > " ")
    appt->appt[appt_cnt].rad_opt = 1, appt->appt[appt_cnt].rad = 1
   ENDIF
   IF (((sr.res_type_flag > 0) OR (srr.role_meaning > " ")) )
    appt->appt[appt_cnt].rad = 1
    IF (loaded_ind=0)
     loaded_ind = 1, fcnt = (fcnt+ 1), cnt = (cnt+ 1)
     IF (cnt > 10)
      stat = alterlist(appt->appt[appt_cnt].locs,(fcnt+ 10)), cnt = 1
     ENDIF
     appt->appt[appt_cnt].locs[fcnt].loc_cd = sol.location_cd, appt->appt[appt_cnt].locs[fcnt].
     display = uar_get_code_display(sol.location_cd), rcnt = (rcnt+ 1),
     rtcnt = (rtcnt+ 1)
     IF (rcnt > 10)
      stat = alterlist(appt->appt[appt_cnt].roles,(rtcnt+ 10)), rcnt = 1
     ENDIF
     appt->appt[appt_cnt].roles[rtcnt].role_id = sor.list_role_id
    ENDIF
   ENDIF
  FOOT  sat.appt_type_cd
   stat = alterlist(appt->appt[appt_cnt].locs,fcnt), stat = alterlist(appt->appt[appt_cnt].roles,
    rtcnt)
  WITH nocounter
 ;end select
 CALL echorecord(appt)
 IF (appt_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = appt_cnt),
   sch_appt_loc s,
   code_value cv
  PLAN (d
   WHERE (appt->appt[d.seq].rad_opt=1))
   JOIN (s
   WHERE (s.appt_type_cd=appt->appt[d.seq].appt_cd)
    AND s.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=s.location_cd
    AND cv.active_ind=1)
  ORDER BY d.seq, cv.display
  HEAD d.seq
   fcnt = 0, cnt = 0, stat = alterlist(appt->appt[d.seq].locs,10)
  DETAIL
   fcnt = (fcnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(appt->appt[d.seq].locs,(fcnt+ 10)), cnt = 1
   ENDIF
   appt->appt[d.seq].locs[fcnt].loc_cd = cv.code_value, appt->appt[d.seq].locs[fcnt].display = cv
   .display
  FOOT  d.seq
   stat = alterlist(appt->appt[d.seq].locs,fcnt)
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (x = 1 TO appt_cnt)
   SET fsize = size(appt->appt[x].locs,5)
   SET rsize = size(appt->appt[x].roles,5)
   IF (fsize > 0)
    SELECT DISTINCT INTO "NL:"
     FROM (dummyt d  WITH seq = fsize),
      sch_appt_type sat,
      sch_order_appt soa,
      sch_order_loc sol,
      sch_order_role sor,
      sch_list_role slr,
      sch_list_res slr2,
      sch_resource sr,
      sch_res_role srr
     PLAN (d
      WHERE (appt->appt[x].rad=1)
       AND (appt->appt[x].rad_opt=0))
      JOIN (sat
      WHERE (sat.appt_type_cd=appt->appt[x].appt_cd)
       AND sat.active_ind=1)
      JOIN (soa
      WHERE soa.appt_type_cd=sat.appt_type_cd
       AND soa.active_ind=1)
      JOIN (sol
      WHERE sol.catalog_cd=soa.catalog_cd
       AND (sol.location_cd=appt->appt[x].locs[d.seq].loc_cd)
       AND sol.active_ind=1)
      JOIN (sor
      WHERE sor.catalog_cd=sol.catalog_cd
       AND sor.location_cd=sol.location_cd)
      JOIN (slr
      WHERE slr.list_role_id=outerjoin(sor.list_role_id)
       AND slr.version_dt_tm=outerjoin(cnvtdatetime("31-dec-2100 00:00:00.00")))
      JOIN (slr2
      WHERE slr2.list_role_id=outerjoin(slr.list_role_id))
      JOIN (sr
      WHERE sr.resource_cd=outerjoin(slr2.resource_cd))
      JOIN (srr
      WHERE srr.sch_role_cd=outerjoin(slr.sch_role_cd))
     ORDER BY d.seq, uar_get_code_description(soa.catalog_cd), sr.mnemonic
     HEAD REPORT
      cnt = size(reply->rowlist,5)
     DETAIL
      num = 0, tindex = 0, tindex = locateval(num,1,rsize,sor.list_role_id,appt->appt[x].roles[num].
       role_id)
      IF (tindex > 0)
       cnt = (cnt+ 1), stat = alterlist(reply->rowlist,cnt), stat = alterlist(reply->rowlist[cnt].
        celllist,9),
       reply->rowlist[cnt].celllist[1].string_value = appt->appt[x].description, reply->rowlist[cnt].
       celllist[3].string_value = uar_get_code_description(sol.catalog_cd), reply->rowlist[cnt].
       celllist[4].string_value = slr.mnemonic,
       reply->rowlist[cnt].celllist[5].string_value = sr.mnemonic, reply->rowlist[cnt].celllist[6].
       string_value = uar_get_code_display(sr.service_resource_cd), reply->rowlist[cnt].celllist[7].
       string_value = uar_get_code_meaning(sr.service_resource_cd),
       reply->rowlist[cnt].celllist[8].string_value = uar_get_code_display(slr.sch_role_cd), reply->
       rowlist[cnt].celllist[9].string_value = srr.role_meaning, reply->rowlist[cnt].celllist[2].
       string_value = appt->appt[x].locs[d.seq].display
      ENDIF
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "NL:"
     FROM (dummyt d  WITH seq = fsize),
      sch_appt_type sat,
      sch_order_appt soa,
      sch_order_loc sol,
      sch_order_role sor,
      sch_list_role slr,
      sch_list_res slr2,
      sch_resource sr,
      sch_res_role srr
     PLAN (d
      WHERE (appt->appt[x].rad=1)
       AND (appt->appt[x].rad_opt=1))
      JOIN (sat
      WHERE (sat.appt_type_cd=appt->appt[x].appt_cd)
       AND sat.active_ind=1)
      JOIN (soa
      WHERE soa.appt_type_cd=sat.appt_type_cd
       AND soa.active_ind=1)
      JOIN (sol
      WHERE sol.catalog_cd=soa.catalog_cd
       AND (sol.location_cd=appt->appt[x].locs[d.seq].loc_cd)
       AND sol.active_ind=1)
      JOIN (sor
      WHERE sor.catalog_cd=outerjoin(sol.catalog_cd)
       AND sor.location_cd=outerjoin(sol.location_cd))
      JOIN (slr
      WHERE slr.list_role_id=outerjoin(sor.list_role_id)
       AND slr.version_dt_tm=outerjoin(cnvtdatetime("31-dec-2100 00:00:00.00")))
      JOIN (slr2
      WHERE slr2.list_role_id=outerjoin(slr.list_role_id))
      JOIN (sr
      WHERE sr.resource_cd=outerjoin(slr2.resource_cd))
      JOIN (srr
      WHERE srr.sch_role_cd=outerjoin(slr.sch_role_cd))
     ORDER BY d.seq, uar_get_code_description(soa.catalog_cd), sr.mnemonic
     HEAD REPORT
      cnt = size(reply->rowlist,5)
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(reply->rowlist,cnt), stat = alterlist(reply->rowlist[cnt].
       celllist,9),
      reply->rowlist[cnt].celllist[1].string_value = appt->appt[x].description, reply->rowlist[cnt].
      celllist[3].string_value = uar_get_code_description(sol.catalog_cd), reply->rowlist[cnt].
      celllist[4].string_value = slr.mnemonic,
      reply->rowlist[cnt].celllist[5].string_value = sr.mnemonic, reply->rowlist[cnt].celllist[6].
      string_value = uar_get_code_display(sr.service_resource_cd), reply->rowlist[cnt].celllist[7].
      string_value = uar_get_code_meaning(sr.service_resource_cd),
      reply->rowlist[cnt].celllist[8].string_value = uar_get_code_display(slr.sch_role_cd), reply->
      rowlist[cnt].celllist[9].string_value = srr.role_meaning, reply->rowlist[cnt].celllist[2].
      string_value = appt->appt[x].locs[d.seq].display
     WITH nocounter
    ;end select
   ELSEIF ((appt->appt[x].rad=1))
    SELECT INTO "nl:"
     FROM sch_appt_type sat,
      sch_order_appt soa,
      order_catalog oc
     PLAN (sat
      WHERE (sat.appt_type_cd=appt->appt[x].appt_cd))
      JOIN (soa
      WHERE soa.appt_type_cd=outerjoin(sat.appt_type_cd)
       AND soa.active_ind=outerjoin(1))
      JOIN (oc
      WHERE oc.catalog_cd=outerjoin(soa.catalog_cd)
       AND oc.active_ind=outerjoin(1))
     ORDER BY oc.description
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(reply->rowlist,cnt), stat = alterlist(reply->rowlist[cnt].
       celllist,9),
      reply->rowlist[cnt].celllist[1].string_value = appt->appt[x].description, reply->rowlist[cnt].
      celllist[3].string_value = oc.description
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("scheduling_radiology_integration.csv")
 ENDIF
 CALL echorecord(reply)
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(appt)
END GO

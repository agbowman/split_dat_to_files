CREATE PROGRAM bed_aud_sch_appt_types
 FREE RECORD app_types
 RECORD appt_types(
   1 qual[*]
     2 appt_type_cd = f8
     2 appt_type_mnemonic = vc
     2 booking_med_nec = c1
     2 modify_med_nec = c1
     2 checkin_med_nec = c1
     2 resch_med_nec = c1
     2 order_res_role = c1
     2 res_duration_flex = c1
     2 orders[*]
       3 order_name = vc
       3 catalog_cd = f8
       3 flex_ind = i2
       3 locs[*]
         4 location_cd = f8
         4 location_display = vc
         4 list_role_id = f8
         4 res_list_id = f8
         4 res_role_disp = vc
         4 seq_nbr = i4
         4 order_role_flexing = vc
         4 rl_or_mnemonic = vc
         4 resource_role = vc
         4 catalog_cd = f8
         4 resources[*]
           5 resource_display = vc
           5 resource_cd = f8
           5 slots[*]
             6 slot_name = vc
             6 offset_role_id = f8
             6 duration[*]
               7 flex_display = vc
               7 pat_pre_arive = vc
               7 res_setup = vc
               7 proc_duration = vc
               7 res_cleanup = vc
               7 pat_recovery = vc
               7 tot_pt_duration = vc
               7 tot_res_duration = vc
               7 resource_offset_tm = vc
               7 off_from = vc
         4 post_inst[*]
           5 post_inst_display = vc
         4 person_preps[*]
           5 prep_display = vc
 )
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
    1 appt_types[*]
      2 appt_code_value = f8
    1 locations[*]
      2 loc_code_value = f8
  )
 ENDIF
 DECLARE ftime = vc
 DECLARE shr = vc
 DECLARE smin = vc
 DECLARE unit_mean = vc
 DECLARE temp_time = i4
 DECLARE beg_str = vc
 DECLARE end_str = vc
 DECLARE aparse = vc
 DECLARE alparse = vc
 DECLARE olparse = vc
 DECLARE num = i4
 DECLARE appt_size = i4
 SET cmin = uar_get_code_by("MEANING",54,"MINUTES")
 SET aparse = "sap.active_ind = 1"
 IF (validate(request->appt_types))
  SET appt_size = size(request->appt_types,5)
 ELSE
  SET appt_size = 0
 ENDIF
 SET alparse = "sal.active_ind = 1 "
 SET olparse = "sol.active_ind = 1 "
 IF (validate(request->locations))
  SET loc_size = size(request->locations,5)
  IF (loc_size > 0)
   FOR (x = 1 TO loc_size)
     IF (x=1)
      SET alparse = build(alparse," and sal.location_cd in (",request->locations[x].loc_code_value)
      SET olparse = build(olparse," and sol.location_cd in (",request->locations[x].loc_code_value)
     ELSE
      SET alparse = build(alparse," , ",request->locations[x].loc_code_value)
      SET olparse = build(olparse," , ",request->locations[x].loc_code_value)
     ENDIF
   ENDFOR
   SET alparse = build(alparse," ) ")
   SET olparse = build(olparse," ) ")
  ENDIF
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SET tcnt = 0
  SELECT DISTINCT INTO "nl:"
   sap.appt_type_cd, sap.description
   FROM sch_appt_type sap
   PLAN (sap
    WHERE expand(num,1,appt_size,sap.appt_type_cd,request->appt_types[num].appt_code_value)
     AND sap.active_ind=1
     AND sap.version_dt_tm=cnvtdatetime("31-DEC-2100")
     AND sap.appt_type_flag=0
     AND sap.appt_type_cd != 1
     AND  NOT ( EXISTS (
    (SELECT
     sac.comp_appt_type_cd
     FROM sch_appt_comp sac
     WHERE sac.comp_appt_type_cd=sap.appt_type_cd))))
   ORDER BY sap.description
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(appt_types->qual,50)
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 50)
     stat = alterlist(appt_types->qual,(50+ tcnt)), cnt = 1
    ENDIF
    appt_types->qual[tcnt].appt_type_cd = sap.appt_type_cd
   FOOT REPORT
    stat = alterlist(appt_types->qual,tcnt), high_volume_cnt = tcnt
   WITH nocounter, noheading, expand = 1
  ;end select
  IF (tcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
     sch_appt_loc sal,
     sch_resource_list srl,
     sch_list_role slr,
     dummyt d2,
     sch_order_appt soa,
     dummyt d3
    PLAN (d)
     JOIN (sal
     WHERE (sal.appt_type_cd=appt_types->qual[d.seq].appt_type_cd)
      AND sal.res_list_id > 0
      AND parser(alparse)
      AND sal.version_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (srl
     WHERE srl.res_list_id=sal.res_list_id
      AND srl.active_ind=1
      AND srl.version_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (d2)
     JOIN (slr
     WHERE slr.res_list_id=sal.res_list_id
      AND slr.version_dt_tm=cnvtdatetime("31-DEC-2100")
      AND slr.active_ind=1)
     JOIN (d3)
     JOIN (soa
     WHERE soa.appt_type_cd=sal.appt_type_cd
      AND soa.active_ind=1)
    ORDER BY d.seq, slr.role_seq
    HEAD d.seq
     order_cnt = 0, order_tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders,5),
     appt_types->qual[d.seq].order_res_role = "R"
    HEAD soa.catalog_cd
     order_cnt = (order_cnt+ 1), order_tcnt = (order_tcnt+ 1)
     IF (order_cnt > 5)
      stat = alterlist(appt_types->qual[d.seq].orders,(5+ order_tcnt)), order_cnt = 1
     ENDIF
     loc_cnt = 0, loc_tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders[order_tcnt].locs,5)
    DETAIL
     loc_cnt = (loc_cnt+ 1), loc_tcnt = (loc_tcnt+ 1)
     IF (loc_cnt > 5)
      stat = alterlist(appt_types->qual[d.seq].orders[order_tcnt].locs,(5+ loc_tcnt)), loc_cnt = 1
     ENDIF
     appt_types->qual[d.seq].orders[order_tcnt].locs[loc_tcnt].list_role_id = slr.list_role_id
    FOOT  soa.catalog_cd
     stat = alterlist(appt_types->qual[d.seq].orders[order_tcnt].locs,loc_tcnt)
    FOOT  d.seq
     stat = alterlist(appt_types->qual[d.seq].orders,order_tcnt)
    WITH noheading, nocounter, outerjoin = d2,
     outerjoin = d3
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
     sch_order_appt soa,
     sch_order_loc sol,
     sch_order_role sor,
     sch_list_role slr
    PLAN (d)
     JOIN (soa
     WHERE (soa.appt_type_cd=appt_types->qual[d.seq].appt_type_cd)
      AND soa.active_ind=1
      AND soa.version_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (sol
     WHERE sol.catalog_cd=soa.catalog_cd
      AND parser(olparse)
      AND sol.version_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (sor
     WHERE sor.catalog_cd=outerjoin(sol.catalog_cd)
      AND sor.location_cd=outerjoin(sol.location_cd)
      AND sor.active_ind=outerjoin(1)
      AND sor.version_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100")))
     JOIN (slr
     WHERE slr.list_role_id=outerjoin(sor.list_role_id))
    ORDER BY d.seq
    HEAD d.seq
     order_cnt = 0, order_tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders,5),
     appt_types->qual[d.seq].order_res_role = "O"
    HEAD soa.catalog_cd
     order_cnt = (order_cnt+ 1), order_tcnt = (order_tcnt+ 1)
     IF (order_cnt > 5)
      stat = alterlist(appt_types->qual[d.seq].orders,(5+ order_tcnt)), order_cnt = 1
     ENDIF
     loc_cnt = 0, loc_tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders[order_tcnt].locs,5)
    DETAIL
     loc_cnt = (loc_cnt+ 1), loc_tcnt = (loc_tcnt+ 1)
     IF (loc_cnt > 5)
      stat = alterlist(appt_types->qual[d.seq].orders[order_tcnt].locs,(5+ loc_tcnt)), loc_cnt = 1
     ENDIF
     appt_types->qual[d.seq].orders[order_tcnt].locs[loc_tcnt].list_role_id = sor.list_role_id
    FOOT  soa.catalog_cd
     stat = alterlist(appt_types->qual[d.seq].orders[order_tcnt].locs,loc_tcnt)
    FOOT  d.seq
     stat = alterlist(appt_types->qual[d.seq].orders,order_tcnt)
    WITH noheading, nocounter
   ;end select
   SELECT INTO "nl:"
    cur_row = concat(cnvtstring(d.seq),cnvtstring(d2.seq),cnvtstring(d3.seq))
    FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1),
     sch_list_res sl
    PLAN (d
     WHERE maxrec(d2,size(appt_types->qual[d.seq].orders,5)))
     JOIN (d2
     WHERE maxrec(d3,size(appt_types->qual[d.seq].orders[d2.seq].locs,5)))
     JOIN (d3)
     JOIN (sl
     WHERE (sl.list_role_id=appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].list_role_id)
      AND sl.version_dt_tm=cnvtdatetime("31-DEC-2100")
      AND sl.active_ind=1)
    ORDER BY d.seq, d2.seq, d3.seq
    HEAD cur_row
     cnt = 0, tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].
      resources,5)
    DETAIL
     cnt = (cnt+ 1), tcnt = (tcnt+ 1)
     IF (cnt > 5)
      stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources,(5+ tcnt)), cnt
       = 1
     ENDIF
     appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[tcnt].resource_cd = sl.resource_cd
    FOOT  cur_row
     stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources,tcnt)
    WITH noheading, nocounter
   ;end select
   SELECT INTO "nl:"
    cur_row = concat(cnvtstring(d.seq),cnvtstring(d2.seq),cnvtstring(d3.seq),cnvtstring(d4.seq)),
    hv_cnt = count(*)
    FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1),
     (dummyt d4  WITH seq = 1),
     sch_list_slot sls,
     sch_slot_type sst,
     sch_list_role slr,
     sch_list_role slr2
    PLAN (d
     WHERE maxrec(d2,size(appt_types->qual[d.seq].orders,5)))
     JOIN (d2
     WHERE maxrec(d3,size(appt_types->qual[d.seq].orders[d2.seq].locs,5)))
     JOIN (d3
     WHERE maxrec(d4,size(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources,5)))
     JOIN (d4)
     JOIN (sls
     WHERE (sls.list_role_id=appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].list_role_id)
      AND sls.version_dt_tm=cnvtdatetime("31-DEC-2100")
      AND sls.active_ind=1
      AND (((sls.resource_cd=appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].
     resource_cd)) OR (sls.resource_cd=0)) )
     JOIN (sst
     WHERE sst.slot_type_id=sls.slot_type_id)
     JOIN (slr
     WHERE slr.list_role_id=sls.list_role_id)
     JOIN (slr2
     WHERE slr2.list_role_id=sls.duration_role_id)
    ORDER BY d.seq, d2.seq, d3.seq,
     d4.seq, sst.description
    HEAD cur_row
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
    FOOT  cur_row
     high_volume_cnt = (high_volume_cnt+ cnt)
    WITH nocounter, noheading, outerjoin = d5
   ;end select
  ENDIF
  CALL echo(build("High Volume Count:",high_volume_cnt))
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   SET reply->status_data.status = "S"
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE num_col = i2 WITH constant(23)
 DECLARE new_row_ind = i2
 DECLARE app_loc_flx_cd = f8
 SET ord_loc_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16162
   AND cv.cdf_meaning="ODUR"
   AND cv.active_ind=1
  DETAIL
   ord_loc_code = cv.code_value
  WITH nocounter
 ;end select
 SET infix_code = 0.0
 SET postfix_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16163
   AND cv.cdf_meaning IN ("INFIX", "POSTFIX")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="INFIX")
    infix_code = cv.code_value
   ELSEIF (cv.cdf_meaning="POSTFIX")
    postfix_code = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET tapptloc_code = 0.0
 SET dapptloc_code = 0.0
 SET equal_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16160
   AND cv.cdf_meaning IN ("T_APPTLOC", "EQUAL", "D_APPTLOC")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="T_APPTLOC")
    tapptloc_code = cv.code_value
   ELSEIF (cv.cdf_meaning="EQUAL")
    equal_code = cv.code_value
   ELSEIF (cv.cdf_meaning="D_APPTLOC")
    dapptloc_code = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET dtasource_code = 0.0
 SET operand_code = 0.0
 SET operator_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16161
   AND cv.cdf_meaning IN ("DATASOURCE", "OPERAND", "OPERATOR")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="DATASOURCE")
    dtasource_code = cv.code_value
   ELSEIF (cv.cdf_meaning="OPERAND")
    operand_code = cv.code_value
   ELSEIF (cv.cdf_meaning="OPERATOR")
    operator_code = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET hc_code = 0.0
 SET ds_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16164
   AND cv.cdf_meaning IN ("DATASOURCE", "HARDCODED")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="DATASOURCE")
    ds_code = cv.code_value
   ELSEIF (cv.cdf_meaning="HARDCODED")
    hc_code = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET location_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16149
   AND cv.cdf_meaning="LOCATION"
   AND cv.active_ind=1
  DETAIL
   location_code = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,num_col)
 SET reply->collist[1].header_text = "Appointment Type Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Ambulatory Location"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Medical Necessity Checking - Booking"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Medical Necessity Checking - Check-in"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Medical Necessity Checking - Reschedule"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Medical Necessity Checking - Modify"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Orderable (Primary Synonym)"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Resource List / Order Role"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "RL or OR Mnemonic"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Order-Duration Flexing"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Resource Role"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Resources Available"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Slot Name"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Patient Pre-Arrival Time"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Resource Setup Time"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Procedure Duration Time"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Resource Cleanup Time"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Patient Recovery Time"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Total Patient Duration Time"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Total Resource Duration Time"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Resource Offset Time"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Resource Offset From"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Person Prep Name"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 CALL echo("Get Appointment Types")
 SET stat = initrec(appt_types)
 SELECT DISTINCT INTO "nl:"
  sap.appt_type_cd, sap.description
  FROM sch_appt_type sap
  PLAN (sap
   WHERE expand(num,1,appt_size,sap.appt_type_cd,request->appt_types[num].appt_code_value)
    AND sap.active_ind=1
    AND sap.version_dt_tm=cnvtdatetime("31-DEC-2100")
    AND sap.appt_type_flag=0
    AND sap.appt_type_cd != 1
    AND  NOT ( EXISTS (
   (SELECT
    sac.comp_appt_type_cd
    FROM sch_appt_comp sac
    WHERE sac.comp_appt_type_cd=sap.appt_type_cd))))
  ORDER BY sap.description
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(appt_types->qual,50)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (tcnt > 50)
    stat = alterlist(appt_types->qual,(50+ cnt)), tcnt = 1
   ENDIF
   appt_types->qual[cnt].appt_type_cd = sap.appt_type_cd, appt_types->qual[cnt].appt_type_mnemonic =
   sap.description
  FOOT REPORT
   stat = alterlist(appt_types->qual,cnt)
  WITH nocounter, noheading, expand = 1
 ;end select
 CALL echo("Get Medical Necessity Checking")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
   code_value cv,
   sch_appt_option sao
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=16127
    AND cv.cdf_meaning IN ("ABNCHECKIN", "ABNMODIFY", "ABNRESCH", "ABNSCH"))
   JOIN (sao
   WHERE sao.sch_option_cd=cv.code_value
    AND (sao.appt_type_cd=appt_types->qual[d.seq].appt_type_cd))
  ORDER BY d.seq
  DETAIL
   CASE (cv.cdf_meaning)
    OF "ABNCHECKIN":
     appt_types->qual[d.seq].booking_med_nec = "X"
    OF "ABNMODIFY":
     appt_types->qual[d.seq].modify_med_nec = "X"
    OF "ABNRESCH":
     appt_types->qual[d.seq].resch_med_nec = "X"
    OF "ABNSCH":
     appt_types->qual[d.seq].checkin_med_nec = "X"
   ENDCASE
  WITH nocounter, noheading
 ;end select
 CALL echo("Get Resource List")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
   sch_appt_loc sal,
   code_value cv,
   sch_resource_list srl,
   sch_list_role slr,
   code_value cv2,
   dummyt d2,
   sch_order_appt soa,
   order_catalog oc,
   dummyt d3
  PLAN (d)
   JOIN (sal
   WHERE (sal.appt_type_cd=appt_types->qual[d.seq].appt_type_cd)
    AND sal.res_list_id > 0
    AND parser(alparse)
    AND sal.version_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (cv
   WHERE cv.code_value=sal.location_cd
    AND cv.active_ind=1)
   JOIN (srl
   WHERE srl.res_list_id=sal.res_list_id
    AND srl.active_ind=1
    AND srl.version_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (d2)
   JOIN (slr
   WHERE slr.res_list_id=sal.res_list_id
    AND slr.version_dt_tm=cnvtdatetime("31-DEC-2100")
    AND slr.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=slr.sch_role_cd)
   JOIN (d3)
   JOIN (soa
   WHERE soa.appt_type_cd=sal.appt_type_cd
    AND soa.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=soa.catalog_cd
    AND oc.active_ind=1)
  ORDER BY d.seq, cv.display, slr.role_seq
  HEAD d.seq
   order_cnt = 0, order_tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders,5),
   appt_types->qual[d.seq].order_res_role = "R"
  HEAD oc.primary_mnemonic
   order_cnt = (order_cnt+ 1), order_tcnt = (order_tcnt+ 1)
   IF (order_tcnt > 5)
    stat = alterlist(appt_types->qual[d.seq].orders,(5+ order_cnt)), order_tcnt = 1
   ENDIF
   appt_types->qual[d.seq].orders[order_cnt].order_name = oc.primary_mnemonic, appt_types->qual[d.seq
   ].orders[order_cnt].catalog_cd = oc.catalog_cd, loc_cnt = 0,
   loc_tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders[order_cnt].locs,5)
  DETAIL
   loc_cnt = (loc_cnt+ 1), loc_tcnt = (loc_tcnt+ 1)
   IF (loc_tcnt > 5)
    stat = alterlist(appt_types->qual[d.seq].orders[order_cnt].locs,(5+ loc_cnt)), loc_tcnt = 1
   ENDIF
   appt_types->qual[d.seq].orders[order_cnt].locs[loc_cnt].location_cd = cv.code_value, appt_types->
   qual[d.seq].orders[order_cnt].locs[loc_cnt].location_display = cv.display, appt_types->qual[d.seq]
   .orders[order_cnt].locs[loc_cnt].list_role_id = slr.list_role_id,
   appt_types->qual[d.seq].orders[order_cnt].locs[loc_cnt].res_role_disp = cv2.display, appt_types->
   qual[d.seq].orders[order_cnt].locs[loc_cnt].res_list_id = slr.res_list_id
  FOOT  oc.primary_mnemonic
   stat = alterlist(appt_types->qual[d.seq].orders[order_cnt].locs,loc_cnt)
  FOOT  d.seq
   stat = alterlist(appt_types->qual[d.seq].orders,order_cnt)
  WITH noheading, nocounter, outerjoin = d2,
   outerjoin = d3
 ;end select
 CALL echo("Get Order Role Appointment Types")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
   sch_order_appt soa,
   order_catalog oc,
   sch_order_loc sol,
   code_value cv,
   sch_order_role sor,
   sch_list_role slr,
   code_value cv2
  PLAN (d)
   JOIN (soa
   WHERE (soa.appt_type_cd=appt_types->qual[d.seq].appt_type_cd)
    AND soa.active_ind=1
    AND soa.version_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (oc
   WHERE oc.catalog_cd=soa.catalog_cd
    AND oc.active_ind=1)
   JOIN (sol
   WHERE sol.catalog_cd=oc.catalog_cd
    AND parser(olparse)
    AND sol.version_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (cv
   WHERE cv.code_value=sol.location_cd
    AND cv.active_ind=1)
   JOIN (sor
   WHERE sor.catalog_cd=outerjoin(sol.catalog_cd)
    AND sor.location_cd=outerjoin(sol.location_cd)
    AND sor.active_ind=outerjoin(1)
    AND sor.version_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100")))
   JOIN (slr
   WHERE slr.list_role_id=outerjoin(sor.list_role_id))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(slr.sch_role_cd)
    AND cv2.active_ind=outerjoin(1))
  ORDER BY d.seq, oc.primary_mnemonic, cv.display
  HEAD d.seq
   order_cnt = 0, order_tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders,5),
   appt_types->qual[d.seq].order_res_role = "O"
  HEAD oc.primary_mnemonic
   order_cnt = (order_cnt+ 1), order_tcnt = (order_tcnt+ 1)
   IF (order_tcnt > 5)
    stat = alterlist(appt_types->qual[d.seq].orders,(5+ order_cnt)), order_tcnt = 1
   ENDIF
   appt_types->qual[d.seq].orders[order_cnt].order_name = oc.primary_mnemonic, appt_types->qual[d.seq
   ].orders[order_cnt].catalog_cd = oc.catalog_cd, loc_cnt = 0,
   loc_tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders[order_cnt].locs,5)
  DETAIL
   loc_cnt = (loc_cnt+ 1), loc_tcnt = (loc_tcnt+ 1)
   IF (loc_tcnt > 5)
    stat = alterlist(appt_types->qual[d.seq].orders[order_cnt].locs,(5+ loc_cnt)), loc_tcnt = 1
   ENDIF
   appt_types->qual[d.seq].orders[order_cnt].locs[loc_cnt].location_cd = cv.code_value, appt_types->
   qual[d.seq].orders[order_cnt].locs[loc_cnt].location_display = cv.display, appt_types->qual[d.seq]
   .orders[order_cnt].locs[loc_cnt].list_role_id = sor.list_role_id,
   appt_types->qual[d.seq].orders[order_cnt].locs[loc_cnt].res_role_disp = cv2.display, appt_types->
   qual[d.seq].orders[order_cnt].locs[loc_cnt].seq_nbr = sor.seq_nbr, appt_types->qual[d.seq].orders[
   order_cnt].locs[loc_cnt].catalog_cd = oc.catalog_cd
  FOOT  oc.primary_mnemonic
   stat = alterlist(appt_types->qual[d.seq].orders[order_cnt].locs,loc_cnt)
  FOOT  d.seq
   stat = alterlist(appt_types->qual[d.seq].orders,order_cnt)
  WITH noheading, nocounter
 ;end select
 CALL echo("Get Mnemonic Name")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   sch_list_role slr,
   sch_resource_list srl
  PLAN (d
   WHERE maxrec(d2,size(appt_types->qual[d.seq].orders,5)))
   JOIN (d2
   WHERE maxrec(d3,size(appt_types->qual[d.seq].orders[d2.seq].locs,5)))
   JOIN (d3)
   JOIN (slr
   WHERE (slr.list_role_id=appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].list_role_id))
   JOIN (srl
   WHERE srl.res_list_id=slr.res_list_id)
  ORDER BY d.seq, d2.seq, d3.seq,
   slr.description
  DETAIL
   IF (srl.description=" ")
    appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].rl_or_mnemonic = slr.description
   ELSE
    appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].rl_or_mnemonic = srl.description
   ENDIF
  WITH noheading, nocounter
 ;end select
 CALL echo("Get Resources")
 SELECT INTO "nl:"
  cur_row = concat(cnvtstring(d.seq),cnvtstring(d2.seq),cnvtstring(d3.seq))
  FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   sch_list_res sl,
   code_value cv
  PLAN (d
   WHERE maxrec(d2,size(appt_types->qual[d.seq].orders,5)))
   JOIN (d2
   WHERE maxrec(d3,size(appt_types->qual[d.seq].orders[d2.seq].locs,5)))
   JOIN (d3)
   JOIN (sl
   WHERE (sl.list_role_id=appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].list_role_id)
    AND sl.version_dt_tm=cnvtdatetime("31-DEC-2100")
    AND sl.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=outerjoin(sl.resource_cd)
    AND cv.active_ind=outerjoin(1))
  ORDER BY d.seq, d2.seq, d3.seq,
   cv.display
  HEAD cur_row
   cnt = 0, tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources,
    5)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (tcnt > 5)
    stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources,(5+ cnt)), tcnt =
    1
   ENDIF
   appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[cnt].resource_display = cv.display,
   appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[cnt].resource_cd = cv.code_value
  FOOT  cur_row
   stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources,cnt)
  WITH noheading, nocounter
 ;end select
 CALL echo("Get Slots")
 DECLARE off_beg_str = vc
 DECLARE off_end_str = vc
 SELECT INTO "nl:"
  cur_row = concat(cnvtstring(d.seq),cnvtstring(d2.seq),cnvtstring(d3.seq),cnvtstring(d4.seq))
  FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   sch_list_slot sls,
   sch_slot_type sst,
   sch_list_role slr,
   sch_list_role slr2,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4,
   code_value cv5
  PLAN (d
   WHERE maxrec(d2,size(appt_types->qual[d.seq].orders,5)))
   JOIN (d2
   WHERE maxrec(d3,size(appt_types->qual[d.seq].orders[d2.seq].locs,5)))
   JOIN (d3
   WHERE maxrec(d4,size(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources,5)))
   JOIN (d4)
   JOIN (sls
   WHERE (sls.list_role_id=appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].list_role_id)
    AND sls.version_dt_tm=cnvtdatetime("31-DEC-2100")
    AND sls.active_ind=1
    AND (((sls.resource_cd=appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].
   resource_cd)) OR (sls.resource_cd=0)) )
   JOIN (sst
   WHERE sst.slot_type_id=sls.slot_type_id)
   JOIN (slr
   WHERE slr.list_role_id=sls.list_role_id)
   JOIN (slr2
   WHERE slr2.list_role_id=sls.duration_role_id)
   JOIN (cv1
   WHERE cv1.code_value=sls.cleanup_units_cd)
   JOIN (cv2
   WHERE cv2.code_value=sls.setup_units_cd)
   JOIN (cv3
   WHERE cv3.code_value=sls.duration_units_cd)
   JOIN (cv4
   WHERE cv4.code_value=sls.offset_beg_units_cd)
   JOIN (cv5
   WHERE cv5.code_value=sls.offset_end_units_cd)
  ORDER BY d.seq, d2.seq, d3.seq,
   d4.seq, sst.description
  HEAD cur_row
   cnt = 0, tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[
    d4.seq].slots,5)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (tcnt > 5)
    stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots,(5+
     cnt)), tcnt = 1
   ENDIF
   appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[cnt].slot_name = sst
   .description, stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4
    .seq].slots[cnt].duration,1)
   IF ((appt_types->qual[d.seq].order_res_role="R"))
    IF (((sls.offset_beg_units > 0) OR (sls.offset_end_units > 0)) )
     stat = build_time(sls.offset_beg_units,sls.offset_beg_units_cd), beg_str = ftime, stat =
     build_time(sls.offset_end_units,sls.offset_end_units_cd),
     end_str = ftime, appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[cnt
     ].duration[1].resource_offset_tm = concat(beg_str," - ",end_str), appt_types->qual[d.seq].
     orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].off_from = concat(
      "Offset from ",slr.description)
    ENDIF
    IF (sls.duration_role_id > 0)
     appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].
     proc_duration = concat("Inhert from ",slr2.description)
     IF (sls.resource_cd=0)
      t1 = build_time(sls.setup_units,sls.setup_units_cd), t2 = build_time(sls.cleanup_units,sls
       .cleanup_units_cd), t3 = (t1+ t2),
      stat = build_time(t3,cmin), appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4
      .seq].slots[cnt].duration[1].tot_pt_duration = concat(ftime," + Inherited"), stat = build_time(
       sls.setup_units,sls.setup_units_cd),
      appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].
      pat_pre_arive = ftime, stat = build_time(sls.cleanup_units,sls.cleanup_units_cd), appt_types->
      qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].pat_recovery
       = ftime,
      appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].resource_display =
      "Patient"
     ELSE
      stat = build_time(sls.setup_units,sls.setup_units_cd), appt_types->qual[d.seq].orders[d2.seq].
      locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].res_setup = ftime, stat = build_time(sls
       .cleanup_units,sls.cleanup_units_cd),
      appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].
      res_cleanup = ftime, t1 = build_time(sls.setup_units,sls.setup_units_cd), t2 = build_time(sls
       .cleanup_units,sls.cleanup_units_cd),
      t3 = (t1+ t2), stat = build_time(t3,cmin), appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].
      resources[d4.seq].slots[cnt].duration[1].tot_res_duration = concat(ftime," + Inherited")
     ENDIF
    ELSE
     stat = build_time(sls.duration_units,sls.duration_units_cd), appt_types->qual[d.seq].orders[d2
     .seq].locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].proc_duration = ftime
     IF (sls.resource_cd=0)
      t1 = build_time(sls.setup_units,sls.setup_units_cd), t2 = build_time(sls.cleanup_units,sls
       .cleanup_units_cd), t3 = build_time(sls.duration_units,sls.duration_units_cd),
      t4 = ((t1+ t2)+ t3), stat = build_time(t4,cmin), appt_types->qual[d.seq].orders[d2.seq].locs[d3
      .seq].resources[d4.seq].slots[cnt].duration[1].tot_pt_duration = ftime,
      stat = build_time(sls.setup_units,sls.setup_units_cd), appt_types->qual[d.seq].orders[d2.seq].
      locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].pat_pre_arive = ftime, stat = build_time(
       sls.cleanup_units,sls.cleanup_units_cd),
      appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].
      pat_recovery = ftime, appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].
      resource_display = "Patient"
     ELSE
      stat = build_time(sls.setup_units,sls.setup_units_cd), appt_types->qual[d.seq].orders[d2.seq].
      locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].res_setup = ftime, stat = build_time(sls
       .cleanup_units,sls.cleanup_units_cd),
      appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].
      res_cleanup = ftime, t1 = build_time(sls.setup_units,sls.setup_units_cd), t2 = build_time(sls
       .cleanup_units,sls.cleanup_units_cd),
      t3 = build_time(sls.duration_units,sls.duration_units_cd), t4 = ((t1+ t2)+ t3), stat =
      build_time(t4,cmin),
      appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[cnt].duration[1].
      tot_res_duration = ftime
     ENDIF
    ENDIF
   ENDIF
  FOOT  cur_row
   stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots,cnt)
  WITH nocounter, noheading, outerjoin = d5
 ;end select
 CALL echo("Get Order Duration Flexing")
 SET flex_ind = 0
 SELECT INTO "nl:"
  cur_row = concat(cnvtstring(d.seq),cnvtstring(d2.seq),cnvtstring(d3.seq),cnvtstring(d4.seq),
   cnvtstring(d5.seq))
  FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   (dummyt d5  WITH seq = 1),
   sch_order_duration sod,
   sch_flex_string sfs,
   sch_flex_list sfl,
   sch_flex_list sfl2,
   sch_flex_list sfl3
  PLAN (d
   WHERE maxrec(d2,size(appt_types->qual[d.seq].orders,5))
    AND (appt_types->qual[d.seq].order_res_role="O"))
   JOIN (d2
   WHERE maxrec(d3,size(appt_types->qual[d.seq].orders[d2.seq].locs,5)))
   JOIN (d3
   WHERE maxrec(d4,size(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources,5)))
   JOIN (d4
   WHERE maxrec(d5,size(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots,5
     )))
   JOIN (d5)
   JOIN (sod
   WHERE (sod.catalog_cd=appt_types->qual[d.seq].orders[d2.seq].catalog_cd)
    AND sod.sch_flex_id > 0
    AND sod.location_cd=0
    AND sod.seq_nbr=0
    AND sod.active_ind=1)
   JOIN (sfs
   WHERE sfs.sch_flex_id=sod.sch_flex_id
    AND sfs.flex_type_cd=ord_loc_code
    AND sfs.active_ind=1)
   JOIN (sfl
   WHERE sfl.sch_flex_id=sfs.sch_flex_id
    AND sfl.flex_orient_cd=infix_code
    AND sfl.flex_token_cd=tapptloc_code
    AND sfl.flex_eval_cd=hc_code)
   JOIN (sfl2
   WHERE sfl2.sch_flex_id=sfl.sch_flex_id
    AND (sfl2.seq_nbr=(sfl.seq_nbr+ 1))
    AND sfl2.flex_orient_cd=infix_code
    AND sfl2.flex_token_cd=equal_code
    AND sfl2.active_ind=1)
   JOIN (sfl3
   WHERE sfl3.sch_flex_id=sfs.sch_flex_id
    AND (sfl3.seq_nbr=(sfl2.seq_nbr+ 1))
    AND sfl3.flex_orient_cd=infix_code
    AND sfl3.flex_token_cd=dapptloc_code
    AND sfl3.flex_eval_cd=ds_code
    AND sfl3.data_source_cd=location_code
    AND (sfl3.parent_id=appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].location_cd))
  ORDER BY cur_row
  HEAD cur_row
   stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5
    .seq].duration,1), appt_types->qual[d.seq].orders[d2.seq].flex_ind = 1, stat = build_time(sod
    .arrival_units,sod.arrival_units_cd),
   appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].
   pat_pre_arive = ftime, stat = build_time(sod.duration_units,sod.duration_units_cd), appt_types->
   qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].proc_duration
    = ftime,
   stat = build_time(sod.setup_units,sod.setup_units_cd), appt_types->qual[d.seq].orders[d2.seq].
   locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].res_setup = ftime, stat = build_time(sod
    .cleanup_units,sod.cleanup_units_cd),
   appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].
   res_cleanup = ftime, stat = build_time(sod.recovery_units,sod.recovery_units_cd), appt_types->
   qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].pat_recovery
    = ftime,
   stat = build_time(sod.offset_beg_units,sod.offset_beg_units_cd), appt_types->qual[d.seq].orders[d2
   .seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].resource_offset_tm = ftime, t1 =
   build_time(sod.setup_units,sod.setup_units_cd),
   t2 = build_time(sod.cleanup_units,sod.cleanup_units_cd), t3 = build_time(sod.duration_units,sod
    .duration_units_cd), t4 = ((t1+ t2)+ t3),
   stat = build_time(t4,cmin), appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].
   slots[d5.seq].duration[1].tot_res_duration = ftime, t1 = build_time(sod.arrival_units,sod
    .arrival_units_cd),
   t2 = build_time(sod.recovery_units,sod.recovery_units_cd), t3 = build_time(sod.duration_units,sod
    .duration_units_cd), t4 = ((t1+ t2)+ t3),
   stat = build_time(t4,cmin), appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].
   slots[d5.seq].duration[1].tot_pt_duration = ftime, appt_types->qual[d.seq].orders[d2.seq].locs[d3
   .seq].resources[d4.seq].slots[d5.seq].duration[1].flex_display = sfs.description,
   appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].
   off_from = "Inherit from Order", appt_types->qual[d.seq].orders[d2.seq].flex_ind = 1
  WITH nocounter
 ;end select
 CALL echo("Get Non-Flexed Order Durations")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   (dummyt d5  WITH seq = 1),
   sch_order_duration sod,
   sch_order_duration sod2
  PLAN (d
   WHERE maxrec(d2,size(appt_types->qual[d.seq].orders,5))
    AND (appt_types->qual[d.seq].order_res_role="O"))
   JOIN (d2
   WHERE maxrec(d3,size(appt_types->qual[d.seq].orders[d2.seq].locs,5))
    AND (appt_types->qual[d.seq].orders[d2.seq].flex_ind=0))
   JOIN (d3
   WHERE maxrec(d4,size(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources,5)))
   JOIN (d4
   WHERE maxrec(d5,size(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots,5
     )))
   JOIN (d5)
   JOIN (sod
   WHERE (sod.catalog_cd=appt_types->qual[d.seq].orders[d2.seq].catalog_cd)
    AND sod.sch_flex_id=0
    AND sod.location_cd=0
    AND sod.seq_nbr=0
    AND sod.active_ind=1)
   JOIN (sod2
   WHERE sod2.catalog_cd=outerjoin(sod.catalog_cd)
    AND sod2.location_cd=outerjoin(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].location_cd)
    AND sod2.sch_flex_id=outerjoin(0)
    AND sod2.active_ind=outerjoin(1)
    AND sod2.offset_type_meaning=outerjoin("OVERRIDE")
    AND sod2.seq_nbr=outerjoin(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].seq_nbr))
  DETAIL
   stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5
    .seq].duration,1), stat = build_time(sod.arrival_units,sod.arrival_units_cd), appt_types->qual[d
   .seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].pat_pre_arive =
   ftime,
   stat = build_time(sod.recovery_units,sod.recovery_units_cd), appt_types->qual[d.seq].orders[d2.seq
   ].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].pat_recovery = ftime, t1 = build_time(
    sod.arrival_units,sod.arrival_units_cd),
   t2 = build_time(sod.recovery_units,sod.recovery_units_cd), t3 = build_time(sod.duration_units,sod
    .duration_units_cd), t4 = ((t1+ t2)+ t3),
   stat = build_time(t4,cmin), appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].
   slots[d5.seq].duration[1].tot_pt_duration = ftime
   IF (sod2.offset_type_meaning="OVERRIDE")
    stat = build_time(sod2.duration_units,sod2.duration_units_cd), appt_types->qual[d.seq].orders[d2
    .seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].proc_duration = ftime, stat =
    build_time(sod2.setup_units,sod2.setup_units_cd),
    appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].
    res_setup = ftime, stat = build_time(sod2.cleanup_units,sod2.cleanup_units_cd), appt_types->qual[
    d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].res_cleanup =
    ftime,
    stat = build_time(sod2.offset_beg_units,sod2.offset_beg_units_cd), appt_types->qual[d.seq].
    orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].resource_offset_tm =
    ftime, t1 = build_time(sod2.setup_units,sod2.setup_units_cd),
    t2 = build_time(sod2.cleanup_units,sod2.cleanup_units_cd), t3 = build_time(sod2.duration_units,
     sod2.duration_units_cd), t4 = ((t1+ t2)+ t3),
    stat = build_time(t4,cmin), appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq]
    .slots[d5.seq].duration[1].tot_res_duration = ftime, appt_types->qual[d.seq].orders[d2.seq].locs[
    d3.seq].resources[d4.seq].slots[d5.seq].duration[1].off_from = "Override"
   ELSE
    stat = build_time(sod.duration_units,sod.duration_units_cd), appt_types->qual[d.seq].orders[d2
    .seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].proc_duration = ftime, stat =
    build_time(sod.setup_units,sod.setup_units_cd),
    appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].
    res_setup = ftime, stat = build_time(sod.cleanup_units,sod.cleanup_units_cd), appt_types->qual[d
    .seq].orders[d2.seq].locs[d3.seq].resources[d4.seq].slots[d5.seq].duration[1].res_cleanup = ftime,
    t1 = build_time(sod.setup_units,sod.setup_units_cd), t2 = build_time(sod.cleanup_units,sod
     .cleanup_units_cd), t3 = build_time(sod.duration_units,sod.duration_units_cd),
    t4 = ((t1+ t2)+ t3), stat = build_time(t4,cmin), appt_types->qual[d.seq].orders[d2.seq].locs[d3
    .seq].resources[d4.seq].slots[d5.seq].duration[1].tot_res_duration = ftime
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Get Person Preps & Post Appointment Instructions")
 SELECT DISTINCT INTO "nl:"
  ste1.description, cur_row = concat(cnvtstring(d.seq),cnvtstring(d2.seq),cnvtstring(d3.seq))
  FROM (dummyt d  WITH seq = value(size(appt_types->qual,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   sch_text_link st,
   sch_sub_list ss,
   sch_template ste1
  PLAN (d
   WHERE maxrec(d2,size(appt_types->qual[d.seq].orders,5)))
   JOIN (d2
   WHERE maxrec(d3,size(appt_types->qual[d.seq].orders[d2.seq].locs,5)))
   JOIN (d3)
   JOIN (st
   WHERE (st.parent2_id=appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].location_cd)
    AND (((st.parent_id=appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].catalog_cd)) OR ((st
   .parent_id=appt_types->qual[d.seq].appt_type_cd)))
    AND st.text_type_meaning IN ("PREAPPT", "POSTAPPT")
    AND st.active_ind=1)
   JOIN (ss
   WHERE ss.parent_table="SCH_TEXT_LINK"
    AND ss.parent_id=st.text_link_id
    AND ss.active_ind=1)
   JOIN (ste1
   WHERE ss.template_id=ste1.template_id)
  ORDER BY d.seq, d2.seq, d3.seq,
   ste1.template_id
  HEAD cur_row
   prep_cnt = 0, prep_tcnt = 0, post_cnt = 0,
   post_tcnt = 0, stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].post_inst,5),
   stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].person_preps,5)
  HEAD ste1.template_id
   CASE (st.text_type_meaning)
    OF "PREAPPT":
     prep_cnt = (prep_cnt+ 1),prep_tcnt = (prep_tcnt+ 1),
     IF (prep_tcnt > 5)
      stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].person_preps,(5+ prep_cnt)
       ), prep_tcnt = 1
     ENDIF
     ,appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].person_preps[prep_cnt].prep_display = ste1
     .description
    OF "POSTAPPT":
     post_cnt = (post_cnt+ 1),post_tcnt = (post_tcnt+ 1),
     IF (post_tcnt > 5)
      stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].post_inst,(5+ post_cnt)),
      post_tcnt = 1
     ENDIF
     ,appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].post_inst[post_cnt].post_inst_display =
     ste1.description
   ENDCASE
  FOOT  cur_row
   stat = alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].post_inst,post_cnt), stat =
   alterlist(appt_types->qual[d.seq].orders[d2.seq].locs[d3.seq].person_preps,prep_cnt)
  WITH noheading, nocounter
 ;end select
 CALL echo("End Queries")
 SET row_cnt = 0
 SET temp_row_cnt = 0
 SET appt_cnt = size(appt_types->qual,5)
 SET stat = alterlist(reply->rowlist,100)
 FOR (a = 1 TO appt_cnt)
  SET order_cnt = size(appt_types->qual[a].orders,5)
  FOR (o = 1 TO order_cnt)
   SET loc_cnt = size(appt_types->qual[a].orders[o].locs,5)
   FOR (l = 1 TO loc_cnt)
     SET res_beg_cnt = row_cnt
     SET res_row_cnt = 0
     SET res_cnt = size(appt_types->qual[a].orders[o].locs[l].resources,5)
     FOR (r = 1 TO res_cnt)
       SET slot_cnt = size(appt_types->qual[a].orders[o].locs[l].resources[r].slots,5)
       FOR (s = 1 TO slot_cnt)
         SET dur_cnt = size(appt_types->qual[a].orders[o].locs[l].resources[r].slots[s].duration,5)
         FOR (d = 1 TO dur_cnt)
           SET res_row_cnt = (res_row_cnt+ 1)
           SET row_cnt = (row_cnt+ 1)
           SET temp_row_cnt = (temp_row_cnt+ 1)
           IF (temp_row_cnt > 100)
            SET stat = alterlist(reply->rowlist,(row_cnt+ 100))
            SET temp_row_cnt = 1
           ENDIF
           SET stat = alterlist(reply->rowlist[row_cnt].celllist,num_col)
           SET reply->rowlist[row_cnt].celllist[1].string_value = appt_types->qual[a].
           appt_type_mnemonic
           SET reply->rowlist[row_cnt].celllist[2].string_value = appt_types->qual[a].orders[o].locs[
           l].location_display
           SET reply->rowlist[row_cnt].celllist[3].string_value = appt_types->qual[a].booking_med_nec
           SET reply->rowlist[row_cnt].celllist[4].string_value = appt_types->qual[a].checkin_med_nec
           SET reply->rowlist[row_cnt].celllist[5].string_value = appt_types->qual[a].modify_med_nec
           SET reply->rowlist[row_cnt].celllist[6].string_value = appt_types->qual[a].resch_med_nec
           SET reply->rowlist[row_cnt].celllist[11].string_value = appt_types->qual[a].orders[o].
           locs[l].res_role_disp
           SET reply->rowlist[row_cnt].celllist[12].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].resource_display
           SET reply->rowlist[row_cnt].celllist[7].string_value = appt_types->qual[a].orders[o].
           order_name
           CASE (appt_types->qual[a].order_res_role)
            OF "O":
             SET reply->rowlist[row_cnt].celllist[8].string_value = "Order Role"
            OF "R":
             SET reply->rowlist[row_cnt].celllist[8].string_value = "Resource List"
            ELSE
             SET reply->rowlist[row_cnt].celllist[8].string_value = "Undefined"
           ENDCASE
           SET reply->rowlist[row_cnt].celllist[9].string_value = appt_types->qual[a].orders[o].locs[
           l].rl_or_mnemonic
           SET reply->rowlist[row_cnt].celllist[10].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].duration[d].flex_display
           SET reply->rowlist[row_cnt].celllist[13].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].slot_name
           SET reply->rowlist[row_cnt].celllist[14].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].duration[d].pat_pre_arive
           SET reply->rowlist[row_cnt].celllist[15].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].duration[d].res_setup
           SET reply->rowlist[row_cnt].celllist[16].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].duration[d].proc_duration
           SET reply->rowlist[row_cnt].celllist[17].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].duration[d].res_cleanup
           SET reply->rowlist[row_cnt].celllist[18].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].duration[d].pat_recovery
           SET reply->rowlist[row_cnt].celllist[19].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].duration[d].tot_pt_duration
           SET reply->rowlist[row_cnt].celllist[20].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].duration[d].tot_res_duration
           SET reply->rowlist[row_cnt].celllist[21].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].duration[d].resource_offset_tm
           SET reply->rowlist[row_cnt].celllist[22].string_value = appt_types->qual[a].orders[o].
           locs[l].resources[r].slots[s].duration[d].off_from
         ENDFOR
         IF (dur_cnt=0)
          SET res_row_cnt = (res_row_cnt+ 1)
          SET row_cnt = (row_cnt+ 1)
          SET temp_row_cnt = (temp_row_cnt+ 1)
          IF (temp_row_cnt > 100)
           SET stat = alterlist(reply->rowlist,(row_cnt+ 100))
           SET temp_row_cnt = 1
          ENDIF
          SET stat = alterlist(reply->rowlist[row_cnt].celllist,num_col)
          SET reply->rowlist[row_cnt].celllist[1].string_value = appt_types->qual[a].
          appt_type_mnemonic
          SET reply->rowlist[row_cnt].celllist[2].string_value = appt_types->qual[a].orders[o].locs[l
          ].location_display
          SET reply->rowlist[row_cnt].celllist[3].string_value = appt_types->qual[a].booking_med_nec
          SET reply->rowlist[row_cnt].celllist[4].string_value = appt_types->qual[a].checkin_med_nec
          SET reply->rowlist[row_cnt].celllist[5].string_value = appt_types->qual[a].modify_med_nec
          SET reply->rowlist[row_cnt].celllist[6].string_value = appt_types->qual[a].resch_med_nec
          SET reply->rowlist[row_cnt].celllist[11].string_value = appt_types->qual[a].orders[o].locs[
          l].res_role_disp
          SET reply->rowlist[row_cnt].celllist[12].string_value = appt_types->qual[a].orders[o].locs[
          l].resources[r].resource_display
          SET reply->rowlist[row_cnt].celllist[7].string_value = appt_types->qual[a].orders[o].
          order_name
          CASE (appt_types->qual[a].order_res_role)
           OF "O":
            SET reply->rowlist[row_cnt].celllist[8].string_value = "Order Role"
           OF "R":
            SET reply->rowlist[row_cnt].celllist[8].string_value = "Resource List"
           ELSE
            SET reply->rowlist[row_cnt].celllist[8].string_value = "Undefined"
          ENDCASE
          SET reply->rowlist[row_cnt].celllist[9].string_value = appt_types->qual[a].orders[o].locs[l
          ].rl_or_mnemonic
          SET reply->rowlist[row_cnt].celllist[13].string_value = appt_types->qual[a].orders[o].locs[
          l].resources[r].slots[s].slot_name
         ENDIF
       ENDFOR
       IF (slot_cnt=0)
        SET res_row_cnt = (res_row_cnt+ 1)
        SET row_cnt = (row_cnt+ 1)
        SET temp_row_cnt = (temp_row_cnt+ 1)
        IF (temp_row_cnt > 100)
         SET stat = alterlist(reply->rowlist,(row_cnt+ 100))
         SET temp_row_cnt = 1
        ENDIF
        SET stat = alterlist(reply->rowlist[row_cnt].celllist,num_col)
        SET reply->rowlist[row_cnt].celllist[1].string_value = appt_types->qual[a].appt_type_mnemonic
        SET reply->rowlist[row_cnt].celllist[2].string_value = appt_types->qual[a].orders[o].locs[l].
        location_display
        SET reply->rowlist[row_cnt].celllist[3].string_value = appt_types->qual[a].booking_med_nec
        SET reply->rowlist[row_cnt].celllist[4].string_value = appt_types->qual[a].checkin_med_nec
        SET reply->rowlist[row_cnt].celllist[5].string_value = appt_types->qual[a].modify_med_nec
        SET reply->rowlist[row_cnt].celllist[6].string_value = appt_types->qual[a].resch_med_nec
        SET reply->rowlist[row_cnt].celllist[11].string_value = appt_types->qual[a].orders[o].locs[l]
        .res_role_disp
        SET reply->rowlist[row_cnt].celllist[12].string_value = appt_types->qual[a].orders[o].locs[l]
        .resources[r].resource_display
        SET reply->rowlist[row_cnt].celllist[7].string_value = appt_types->qual[a].orders[o].
        order_name
        CASE (appt_types->qual[a].order_res_role)
         OF "O":
          SET reply->rowlist[row_cnt].celllist[8].string_value = "Order Role"
         OF "R":
          SET reply->rowlist[row_cnt].celllist[8].string_value = "Resource List"
         ELSE
          SET reply->rowlist[row_cnt].celllist[8].string_value = "Undefined"
        ENDCASE
        SET reply->rowlist[row_cnt].celllist[9].string_value = appt_types->qual[a].orders[o].locs[l].
        rl_or_mnemonic
       ENDIF
     ENDFOR
     IF (res_cnt=0)
      SET res_row_cnt = (res_row_cnt+ 1)
      SET row_cnt = (row_cnt+ 1)
      SET temp_row_cnt = (temp_row_cnt+ 1)
      IF (temp_row_cnt > 100)
       SET stat = alterlist(reply->rowlist,(row_cnt+ 100))
       SET temp_row_cnt = 1
      ENDIF
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,num_col)
      SET reply->rowlist[row_cnt].celllist[1].string_value = appt_types->qual[a].appt_type_mnemonic
      SET reply->rowlist[row_cnt].celllist[2].string_value = appt_types->qual[a].orders[o].locs[l].
      location_display
      SET reply->rowlist[row_cnt].celllist[3].string_value = appt_types->qual[a].booking_med_nec
      SET reply->rowlist[row_cnt].celllist[4].string_value = appt_types->qual[a].checkin_med_nec
      SET reply->rowlist[row_cnt].celllist[5].string_value = appt_types->qual[a].modify_med_nec
      SET reply->rowlist[row_cnt].celllist[6].string_value = appt_types->qual[a].resch_med_nec
      SET reply->rowlist[row_cnt].celllist[7].string_value = appt_types->qual[a].orders[o].order_name
      CASE (appt_types->qual[a].order_res_role)
       OF "O":
        SET reply->rowlist[row_cnt].celllist[8].string_value = "Order Role"
       OF "R":
        SET reply->rowlist[row_cnt].celllist[8].string_value = "Resource List"
       ELSE
        SET reply->rowlist[row_cnt].celllist[8].string_value = "Undefined"
      ENDCASE
      SET reply->rowlist[row_cnt].celllist[9].string_value = appt_types->qual[a].orders[o].locs[l].
      rl_or_mnemonic
     ENDIF
     IF ((appt_types->qual[a].orders[o].locs[l].res_role_disp != "Patient"))
      SET per_cnt = size(appt_types->qual[a].orders[o].locs[l].person_preps,5)
      SET per_idx = res_beg_cnt
      FOR (p = 1 TO per_cnt)
        SET per_idx = (per_idx+ 1)
        IF (p > res_row_cnt)
         SET res_row_cnt = (res_row_cnt+ 1)
         SET row_cnt = (row_cnt+ 1)
         SET temp_row_cnt = (temp_row_cnt+ 1)
         IF (temp_row_cnt > 100)
          SET stat = alterlist(reply->rowlist,(row_cnt+ 100))
          SET temp_row_cnt = 1
         ENDIF
         SET stat = alterlist(reply->rowlist[per_idx].celllist,num_col)
         SET reply->rowlist[per_idx].celllist[1].string_value = appt_types->qual[a].
         appt_type_mnemonic
         SET reply->rowlist[per_idx].celllist[2].string_value = appt_types->qual[a].orders[o].locs[l]
         .location_display
         SET reply->rowlist[per_idx].celllist[3].string_value = appt_types->qual[a].booking_med_nec
         SET reply->rowlist[per_idx].celllist[7].string_value = appt_types->qual[a].orders[o].
         order_name
        ENDIF
        SET reply->rowlist[per_idx].celllist[23].string_value = appt_types->qual[a].orders[o].locs[l]
        .person_preps[p].prep_display
      ENDFOR
      SET post_cnt = size(appt_types->qual[a].orders[o].locs[l].post_inst,5)
      SET post_idx = res_beg_cnt
      FOR (p = 1 TO post_cnt)
       SET post_idx = (post_idx+ 1)
       IF (p > res_row_cnt)
        SET res_row_cnt = (res_row_cnt+ 1)
        SET row_cnt = (row_cnt+ 1)
        SET temp_row_cnt = (temp_row_cnt+ 1)
        IF (temp_row_cnt > 100)
         SET stat = alterlist(reply->rowlist,(row_cnt+ 100))
         SET temp_row_cnt = 1
        ENDIF
        SET stat = alterlist(reply->rowlist[row_cnt].celllist,num_col)
        SET reply->rowlist[post_idx].celllist[1].string_value = appt_types->qual[a].
        appt_type_mnemonic
        SET reply->rowlist[post_idx].celllist[2].string_value = appt_types->qual[a].orders[o].locs[l]
        .location_display
        SET reply->rowlist[post_idx].celllist[3].string_value = appt_types->qual[a].booking_med_nec
        SET reply->rowlist[post_idx].celllist[7].string_value = appt_types->qual[a].orders[o].
        order_name
       ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDFOR
 ENDFOR
 SET stat = alterlist(reply->rowlist,row_cnt)
 SET reply->status_data.status = "S"
 SUBROUTINE build_time(t,unit)
   SET ftime = ""
   SET unit_mean = uar_get_code_meaning(unit)
   SET temp_time = 0
   IF (unit_mean="HOURS")
    SET temp_time = (t * 60)
   ELSEIF (unit_mean="DAYS")
    SET temp_time = ((t * 24) * 60)
   ELSEIF (unit_mean="WEEKS")
    SET temp_time = (((t * 7) * 24) * 60)
   ELSE
    SET temp_time = t
   ENDIF
   SET hr = (temp_time/ 60)
   IF (hr < 10)
    SET shr = concat("0",trim(cnvtstring(hr)))
   ELSE
    SET shr = trim(cnvtstring(hr))
   ENDIF
   SET min = mod(temp_time,60)
   IF (min < 10)
    SET smin = concat("0",trim(cnvtstring(min)))
   ELSE
    SET smin = trim(cnvtstring(min))
   ENDIF
   SET ftime = concat(shr,":",smin)
   RETURN(temp_time)
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("esm_appt_types.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO

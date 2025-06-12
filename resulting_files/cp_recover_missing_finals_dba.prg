CREATE PROGRAM cp_recover_missing_finals:dba
 SET message = window
 SET begin_lookback_date = cnvtdatetime("01-dec-2000")
 SET end_lookback_date = cnvtdatetime(curdate,curtime3)
 SET input_string1 = fillstring(40," ")
 SET input_string2 = fillstring(40," ")
 CALL clear(1,1)
 CALL text(1,2,"ENTER BEGIN LOOKBACK DATE/TIME >>")
 CALL text(1,60,"Ex:  25-dec-2000")
 CALL accept(1,37,"P(20);Cf"," ")
 SET input_string1 = curaccept
 SET begin_lookback_date = cnvtdatetime(input_string1)
 IF (input_string1 > " ")
  SET do_nothing = 0
 ELSE
  SET begin_lookback_date = cnvtdatetime("01-dec-2000")
 ENDIF
 CALL text(2,2,"ENTER END LOOKBACK DATE/TIME >>")
 CALL text(2,60,"Ex:  25-dec-2000")
 CALL accept(2,37,"P(20);Cf"," ")
 SET input_string2 = curaccept
 SET end_lookback_date = cnvtdatetime(input_string2)
 IF (input_string2 > " ")
  SET do_nothing = 0
 ELSE
  SET end_lookback_date = cnvtdatetime(curdate,curtime3)
 ENDIF
 CALL clear(1,1)
 CALL echo(build("begin_lookback_date = ",format(cnvtdatetime(begin_lookback_date),
    "mm/dd/yyyy hh:mm:ss;;d")))
 CALL echo(build("end_lookback_date = ",format(cnvtdatetime(end_lookback_date),
    "mm/dd/yyyy hh:mm:ss;;d")))
 FREE RECORD encntr_rec
 RECORD encntr_rec(
   1 qual[*]
     2 encntr_id = f8
     2 patient_name = vc
     2 disch_dt_tm = dq8
     2 encntr_type_cd = f8
     2 organization_id = f8
     2 providers[*]
       3 provider_id = f8
       3 reltn_type_cd = f8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 med_service_cd = f8
     2 dist_list[*]
       3 distribution_id = f8
       3 distribution_name = vc
       3 reader_group = vc
       3 printed_ind = i2
       3 qualify_ind = i2
 )
 SELECT DISTINCT INTO "nl:"
  e.encntr_id
  FROM clinical_event ce,
   encounter e,
   person p
  PLAN (e
   WHERE e.disch_dt_tm >= cnvtdatetime(begin_lookback_date)
    AND e.disch_dt_tm <= cnvtdatetime(end_lookback_date))
   JOIN (ce
   WHERE ce.person_id=e.person_id)
   JOIN (p
   WHERE p.person_id=ce.person_id)
  ORDER BY e.encntr_id
  HEAD REPORT
   encntr_cnt = 0
  DETAIL
   encntr_cnt = (encntr_cnt+ 1), stat = alterlist(encntr_rec->qual,encntr_cnt), encntr_rec->qual[
   encntr_cnt].encntr_id = e.encntr_id,
   encntr_rec->qual[encntr_cnt].patient_name = p.name_full_formatted, encntr_rec->qual[encntr_cnt].
   disch_dt_tm = e.disch_dt_tm, encntr_rec->qual[encntr_cnt].encntr_type_cd = e.encntr_type_cd,
   encntr_rec->qual[encntr_cnt].organization_id = e.organization_id, encntr_rec->qual[encntr_cnt].
   loc_facility_cd = e.loc_facility_cd, encntr_rec->qual[encntr_cnt].loc_building_cd = e
   .loc_building_cd,
   encntr_rec->qual[encntr_cnt].loc_nurse_unit_cd = e.loc_nurse_unit_cd, encntr_rec->qual[encntr_cnt]
   .loc_room_cd = e.loc_room_cd, encntr_rec->qual[encntr_cnt].loc_bed_cd = e.loc_bed_cd,
   encntr_rec->qual[encntr_cnt].med_service_cd = e.med_service_cd
  WITH nocounter
 ;end select
 SET size_encntr = 0
 SET size_encntr = size(encntr_rec->qual,5)
 SET final_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=22550
   AND cv.cdf_meaning="FINAL"
  HEAD REPORT
   final_cd = 0.0
  DETAIL
   final_cd = cv.code_value
  WITH nocounter
 ;end select
 FREE RECORD co_rec
 RECORD co_rec(
   1 qual[*]
     2 charting_operations_id = f8
 )
 FREE RECORD final_dist_rec
 RECORD final_dist_rec(
   1 qual[*]
     2 distribution_id = f8
     2 distribution_name = vc
     2 reader_group = vc
 )
 SELECT INTO "nl:"
  co.charting_operations_id
  FROM charting_operations co
  WHERE co.active_ind=1
   AND co.param_type_flag=3
   AND co.param=cnvtstring(final_cd)
  HEAD REPORT
   co_cnt = 0
  DETAIL
   co_cnt = (co_cnt+ 1), stat = alterlist(co_rec->qual,co_cnt), co_rec->qual[co_cnt].
   charting_operations_id = co.charting_operations_id
  WITH nocounter
 ;end select
 SET size_co = 0
 SET size_co = size(co_rec->qual,5)
 SET x = 0
 SET dist_count = 0
 FOR (x = 1 TO size_co)
   SELECT INTO "nl:"
    distr_id = cd.distribution_id
    FROM charting_operations co,
     chart_distribution cd
    PLAN (co
     WHERE co.active_ind=1
      AND (co.charting_operations_id=co_rec->qual[x].charting_operations_id)
      AND co.param_type_flag=2)
     JOIN (cd
     WHERE cd.distribution_id=cnvtreal(co.param)
      AND cd.active_ind=1)
    ORDER BY cd.distribution_id
    HEAD REPORT
     do_nothing = 0, found = 0, y = 0
    DETAIL
     FOR (y = 1 TO dist_count)
       IF ((distr_id=final_dist_rec->qual[y].distribution_id))
        found = 1
       ENDIF
     ENDFOR
     IF (found=0)
      dist_count = (dist_count+ 1), stat = alterlist(final_dist_rec->qual,dist_count), final_dist_rec
      ->qual[dist_count].distribution_id = distr_id,
      final_dist_rec->qual[dist_count].distribution_name = trim(cd.dist_descr), final_dist_rec->qual[
      dist_count].reader_group = trim(cd.reader_group)
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SET size_encntr = 0
 SET size_encntr = size(encntr_rec->qual,5)
 SET size_dist = 0
 SET size_dist = size(final_dist_rec->qual,5)
 SET y = 0
 FOR (x = 1 TO size_encntr)
  SET stat = alterlist(encntr_rec->qual[x].dist_list,size_dist)
  FOR (y = 1 TO size_dist)
    SET encntr_rec->qual[x].dist_list[y].distribution_id = final_dist_rec->qual[y].distribution_id
    SET encntr_rec->qual[x].dist_list[y].distribution_name = final_dist_rec->qual[y].
    distribution_name
    SET encntr_rec->qual[x].dist_list[y].reader_group = trim(final_dist_rec->qual[y].reader_group)
    SET encntr_rec->qual[x].dist_list[y].printed_ind = 0
  ENDFOR
 ENDFOR
 SET dist_count = 0
 SET dist_count = size(final_dist_rec->qual,5)
 FREE RECORD dist_params_rec
 RECORD dist_params_rec(
   1 qual[*]
     2 distribution_id = f8
     2 include_0 = i2
     2 include_1 = i2
     2 include_2 = i2
     2 include_3 = i2
     2 include_4 = i2
     2 encntr_types[*]
       3 encntr_type_cd = f8
     2 organizations[*]
       3 organization_id = f8
     2 providers[*]
       3 provider_id = f8
       3 reltn_type_cd = f8
     2 locations[*]
       3 location_cd = f8
     2 med_services[*]
       3 med_service_cd = f8
 )
 SET providers_used_flag = 0
 SELECT INTO "nl:"
  cdf.distribution_id
  FROM chart_dist_filter cdf,
   chart_dist_filter_value cdfv,
   (dummyt d  WITH seq = value(dist_count))
  PLAN (d)
   JOIN (cdf
   WHERE (cdf.distribution_id=final_dist_rec->qual[d.seq].distribution_id))
   JOIN (cdfv
   WHERE cdfv.distribution_id=cdf.distribution_id
    AND cdfv.type_flag=cdf.type_flag)
  ORDER BY cdf.distribution_id, cdf.type_flag, cdfv.parent_entity_id,
   cdfv.reltn_type_cd
  HEAD REPORT
   do_nothing = 0, dist_cnt = 0
  HEAD cdf.distribution_id
   dist_cnt = (dist_cnt+ 1), stat = alterlist(dist_params_rec->qual,dist_cnt), dist_params_rec->qual[
   dist_cnt].distribution_id = cdf.distribution_id,
   type_cnt = 0, 0_cnt = 0, 1_cnt = 0,
   2_cnt = 0, 3_cnt = 0, 4_cnt = 0
  HEAD cdf.type_flag
   type_cnt = (type_cnt+ 1)
   IF (cdf.type_flag=0)
    IF (cdf.included_flag=0)
     dist_params_rec->qual[dist_cnt].include_0 = 5
    ELSEIF (cdf.included_flag=1)
     dist_params_rec->qual[dist_cnt].include_0 = 7
    ENDIF
   ELSEIF (cdf.type_flag=1)
    IF (cdf.included_flag=0)
     dist_params_rec->qual[dist_cnt].include_1 = 5
    ELSEIF (cdf.included_flag=1)
     dist_params_rec->qual[dist_cnt].include_1 = 7
    ENDIF
   ELSEIF (cdf.type_flag=2)
    providers_used_flag = 1
    IF (cdf.included_flag=0)
     dist_params_rec->qual[dist_cnt].include_2 = 5
    ELSEIF (cdf.included_flag=1)
     dist_params_rec->qual[dist_cnt].include_2 = 7
    ENDIF
   ELSEIF (cdf.type_flag=3)
    IF (cdf.included_flag=0)
     dist_params_rec->qual[dist_cnt].include_3 = 5
    ELSEIF (cdf.included_flag=1)
     dist_params_rec->qual[dist_cnt].include_3 = 7
    ENDIF
   ELSEIF (cdf.type_flag=4)
    IF (cdf.included_flag=0)
     dist_params_rec->qual[dist_cnt].include_4 = 5
    ELSEIF (cdf.included_flag=1)
     dist_params_rec->qual[dist_cnt].include_4 = 7
    ENDIF
   ENDIF
  HEAD cdfv.parent_entity_id
   IF (cdfv.type_flag=0)
    0_cnt = (0_cnt+ 1), stat = alterlist(dist_params_rec->qual[dist_cnt].encntr_types,0_cnt),
    dist_params_rec->qual[dist_cnt].encntr_types[0_cnt].encntr_type_cd = cdfv.parent_entity_id
   ELSEIF (cdfv.type_flag=1)
    1_cnt = (1_cnt+ 1), stat = alterlist(dist_params_rec->qual[dist_cnt].organizations,1_cnt),
    dist_params_rec->qual[dist_cnt].organizations[1_cnt].organization_id = cdfv.parent_entity_id
   ELSEIF (cdfv.type_flag=2)
    2_cnt = (2_cnt+ 1), stat = alterlist(dist_params_rec->qual[dist_cnt].providers,2_cnt),
    dist_params_rec->qual[dist_cnt].providers[2_cnt].provider_id = cdfv.parent_entity_id,
    dist_params_rec->qual[dist_cnt].providers[2_cnt].reltn_type_cd = cdfv.reltn_type_cd
   ELSEIF (cdfv.type_flag=3)
    3_cnt = (3_cnt+ 1), stat = alterlist(dist_params_rec->qual[dist_cnt].locations,3_cnt),
    dist_params_rec->qual[dist_cnt].locations[3_cnt].location_cd = cdfv.parent_entity_id
   ELSEIF (cdfv.type_flag=4)
    4_cnt = (4_cnt+ 1), stat = alterlist(dist_params_rec->qual[dist_cnt].med_services,4_cnt),
    dist_params_rec->qual[dist_cnt].med_services[4_cnt].med_service_cd = cdfv.parent_entity_id
   ENDIF
  WITH nocounter
 ;end select
 IF (providers_used_flag > 0)
  SET size_encntr = 0
  SET size_encntr = size(encntr_rec->qual,5)
  SET x = 0
  FOR (x = 1 TO size_encntr)
    SELECT INTO "nl:"
     e.encntr_id
     FROM encounter e,
      person_prsnl_reltn ppr
     PLAN (e
      WHERE (e.encntr_id=encntr_rec->qual[x].encntr_id))
      JOIN (ppr
      WHERE ppr.person_id=e.person_id
       AND ppr.active_ind=1)
     HEAD REPORT
      size_providers = size(encntr_rec->qual[x].providers,5)
     DETAIL
      size_providers = (size_providers+ 1), stat = alterlist(encntr_rec->qual[x].providers,
       size_providers), encntr_rec->qual[x].providers[size_providers].provider_id = ppr
      .prsnl_person_id,
      encntr_rec->qual[x].providers[size_providers].reltn_type_cd = ppr.person_prsnl_r_cd
     WITH nocounter
    ;end select
  ENDFOR
  SET size_encntr = 0
  SET size_encntr = size(encntr_rec->qual,5)
  SET x = 0
  FOR (x = 1 TO size_encntr)
    SELECT INTO "nl:"
     epr.encntr_id
     FROM encntr_prsnl_reltn epr
     WHERE (epr.encntr_id=encntr_rec->qual[x].encntr_id)
      AND epr.active_ind=1
     HEAD REPORT
      size_providers = size(encntr_rec->qual[x].providers,5)
     DETAIL
      size_providers = (size_providers+ 1), stat = alterlist(encntr_rec->qual[x].providers,
       size_providers), encntr_rec->qual[x].providers[size_providers].provider_id = epr
      .prsnl_person_id,
      encntr_rec->qual[x].providers[size_providers].reltn_type_cd = epr.encntr_prsnl_r_cd
     WITH nocounter
    ;end select
  ENDFOR
  SET size_encntr = 0
  SET size_encntr = size(encntr_rec->qual,5)
  SET x = 0
  FOR (x = 1 TO size_encntr)
    SELECT INTO "nl:"
     opr.encntr_id
     FROM order_prsnl_reltn opr
     WHERE (opr.encntr_id=encntr_rec->qual[x].encntr_id)
     HEAD REPORT
      size_providers = size(encntr_rec->qual[x].providers,5)
     DETAIL
      size_providers = (size_providers+ 1), stat = alterlist(encntr_rec->qual[x].providers,
       size_providers), encntr_rec->qual[x].providers[size_providers].provider_id = opr
      .prsnl_person_id,
      encntr_rec->qual[x].providers[size_providers].reltn_type_cd = opr.chart_prsnl_r_type_cd
     WITH nocounter
    ;end select
  ENDFOR
 ELSE
  CALL echo("no providers used - good!")
 ENDIF
 SET size_dist = 0
 SET size_dist = size(final_dist_rec->qual,5)
 SET y = 0
 SET chart_req_qual = fillstring(200," ")
 FOR (x = 1 TO size_encntr)
   FOR (y = 1 TO dist_count)
     IF (trim(final_dist_rec->qual[y].reader_group) > " ")
      SET chart_req_qual = " cr.reader_group = trim(final_dist_rec->qual[y]->reader_group)"
     ELSE
      SET chart_req_qual = " cr.distribution_id = final_dist_rec->qual[y]->distribution_id"
     ENDIF
     SELECT INTO "nl:"
      cr.chart_request_id
      FROM chart_request cr
      WHERE cr.dist_run_type_cd=final_cd
       AND parser(chart_req_qual)
       AND (cr.encntr_id=encntr_rec->qual[x].encntr_id)
      HEAD REPORT
       found_ind = 0
      DETAIL
       encntr_rec->qual[x].dist_list[y].printed_ind = 1
      WITH nocounter
     ;end select
     SET pass_all_criteria = 0
     IF ((encntr_rec->qual[x].dist_list[y].printed_ind=0))
      CALL check_criteria(encntr_rec->qual[x].dist_list[y].distribution_id,encntr_rec->qual[x].
       encntr_id)
      SET do_nothing = 0
      IF (pass_all_criteria=1)
       SET do_nothing = 0
       SET encntr_rec->qual[x].dist_list[y].qualify_ind = 1
      ELSE
       SET do_nothing = 0
       SET encntr_rec->qual[x].dist_list[y].qualify_ind = 0
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 SET size_encntr = 0
 SET size_encntr = size(encntr_rec->qual,5)
 FREE SELECT all
 FREE SELECT de_test
 SET with_clause = fillstring(50," ")
 SET count_add = 0
 FOR (x = 1 TO size_encntr)
   FOR (y = 1 TO dist_count)
     IF ((encntr_rec->qual[x].dist_list[y].printed_ind=0)
      AND (encntr_rec->qual[x].dist_list[y].qualify_ind=1))
      SET count_add = (count_add+ 1)
      CALL echo(build("incrementing count_add = ",count_add))
      IF (count_add > 1)
       SET with_clause = "  append"
      ELSE
       SET with_clause = "  nocounter"
      ENDIF
      SELECT INTO TABLE de_test
       encntr_id = encntr_rec->qual[x].encntr_id, disch_dt_tm = encntr_rec->qual[x].disch_dt_tm,
       distribution_id = encntr_rec->qual[x].dist_list[y].distribution_id,
       distribution_name = substring(1,100,encntr_rec->qual[x].dist_list[y].distribution_name),
       patient_name = substring(1,100,encntr_rec->qual[x].patient_name)
       WITH parser(with_clause), organization = work
      ;end select
     ENDIF
   ENDFOR
 ENDFOR
 CALL echo(build("count_add = ",count_add))
 IF (count_add > 0)
  SET do_nothing = 0
 ELSE
  CALL echo("nothing to add")
  GO TO exit_script
 ENDIF
 SET mrn_code = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=319
   AND cv.cdf_meaning="MRN"
  HEAD REPORT
   mrn_code = 0.0
  DETAIL
   mrn_code = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "mine"
  d.*, dischg_date = format(d.disch_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), beg_date = format(
   begin_lookback_date,"mm/dd/yyyy hh:mm:ss;;d"),
  end_date = format(end_lookback_date,"mm/dd/yyyy hh:mm:ss;;d"), e_mrn = substring(1,30,format(
    cnvtalphanum(ea.alias),"##############################"))
  FROM de_test d,
   encntr_alias ea,
   dummyt d1
  PLAN (d)
   JOIN (d1)
   JOIN (ea
   WHERE ea.encntr_id=d.encntr_id
    AND ea.encntr_alias_type_cd=mrn_code
    AND ea.active_ind=1)
  ORDER BY d.distribution_name, d.disch_dt_tm, d.patient_name,
   d.encntr_id
  HEAD REPORT
   row + 2, col 10, "* * * MISSING FINALS REPORT * * *",
   row + 2, col 2, "BEGIN DATE:",
   col 18, beg_date, row + 1,
   col 2, "END DATE:", col 18,
   end_date, row + 1
  HEAD d.distribution_id
   row + 2, col 2, "DISTRIBUTION:",
   col 19, d.distribution_name, col 56,
   "(", col 57, d.distribution_id,
   col 73, ")", row + 1,
   col 2, "____________________________________________________________________________________", row
    + 2,
   col 12, "Patient Name", col 50,
   "Discharge Date/Time", col 72, "Encounter ID",
   col 90, "MRN #", row + 1,
   col 12, "------------", col 50,
   "-------------------", col 72, "------------",
   col 90, "-----"
  DETAIL
   row + 1, col 12, d.patient_name,
   col 50, dischg_date, col 70,
   d.encntr_id, col 90, e_mrn
  WITH nocounter, outerjoin = d1
 ;end select
 SUBROUTINE check_criteria(distribution_id,encntr_id)
   SET pass_all_criteria = 0
   SET pass_0 = 99
   SET pass_1 = 99
   SET pass_2 = 99
   SET pass_3 = 99
   SET pass_4 = 99
   SET d = 0
   SET e = 0
   SET dist_index = 0
   SET encntr_ind = 0
   SET encntr_cnt = 0
   SET encntr_cnt = size(encntr_rec->qual,5)
   FOR (d = 1 TO dist_count)
     IF ((final_dist_rec->qual[d].distribution_id != distribution_id))
      SET do_nothing = 0
     ELSEIF ((final_dist_rec->qual[d].distribution_id=distribution_id))
      SET dist_index = d
      FOR (e = 1 TO encntr_cnt)
        IF ((encntr_rec->qual[e].encntr_id=encntr_id))
         SET encntr_index = e
        ENDIF
      ENDFOR
      IF (encntr_index=0)
       CALL echo("exiting here1")
       GO TO exit_script
      ENDIF
      SET w = 0
      SET pass_0 = 99
      SET pass_1 = 99
      SET pass_2 = 99
      SET pass_3 = 99
      SET pass_4 = 99
      IF ((dist_params_rec->qual[dist_index].include_0=5))
       FOR (w = 1 TO size(dist_params_rec->qual[dist_index].encntr_types,5))
         IF ((encntr_rec->qual[encntr_index].encntr_type_cd=dist_params_rec->qual[dist_index].
         encntr_types[w].encntr_type_cd))
          SET pass_0 = 9
         ENDIF
       ENDFOR
      ELSEIF ((dist_params_rec->qual[dist_index].include_0=7))
       FOR (w = 1 TO size(dist_params_rec->qual[dist_index].encntr_types,5))
         IF ((encntr_rec->qual[encntr_index].encntr_type_cd=dist_params_rec->qual[dist_index].
         encntr_types[w].encntr_type_cd))
          SET pass_0 = 1
         ENDIF
       ENDFOR
       IF (pass_0 != 1)
        SET pass_0 = 9
       ENDIF
      ELSE
       IF ( NOT (pass_0 IN (9, 1)))
        SET pass_0 = 1
       ENDIF
      ENDIF
      IF ((dist_params_rec->qual[dist_index].include_1=5))
       FOR (w = 1 TO size(dist_params_rec->qual[dist_index].organizations,5))
         IF ((encntr_rec->qual[encntr_index].organization_id=dist_params_rec->qual[dist_index].
         organizations[w].organization_id))
          SET pass_1 = 9
         ENDIF
       ENDFOR
      ELSEIF ((dist_params_rec->qual[dist_index].include_1=7))
       FOR (w = 1 TO size(dist_params_rec->qual[dist_index].organizations,5))
         IF ((encntr_rec->qual[encntr_index].organization_id=dist_params_rec->qual[dist_index].
         organizations[w].organization_id))
          SET pass_1 = 1
         ENDIF
       ENDFOR
       IF (pass_1 != 1)
        SET pass_1 = 9
       ENDIF
      ELSE
       IF ( NOT (pass_1 IN (9, 1)))
        SET pass_1 = 1
       ENDIF
      ENDIF
      IF ((dist_params_rec->qual[dist_index].include_4=5))
       FOR (w = 1 TO size(dist_params_rec->qual[dist_index].med_services,5))
         IF ((encntr_rec->qual[encntr_index].med_service_cd=dist_params_rec->qual[dist_index].
         med_services[w].med_service_cd))
          SET pass_4 = 9
         ENDIF
       ENDFOR
      ELSEIF ((dist_params_rec->qual[dist_index].include_4=7))
       FOR (w = 1 TO size(dist_params_rec->qual[dist_index].med_services,5))
         IF ((encntr_rec->qual[encntr_index].med_service_cd=dist_params_rec->qual[dist_index].
         med_services[w].med_service_cd))
          SET pass_4 = 1
         ENDIF
       ENDFOR
       IF (pass_4 != 1)
        SET pass_4 = 9
       ENDIF
      ELSE
       IF ( NOT (pass_4 IN (9, 1)))
        SET pass_4 = 1
       ENDIF
      ENDIF
      IF ((dist_params_rec->qual[dist_index].include_3=5))
       FOR (w = 1 TO size(dist_params_rec->qual[dist_index].locations,5))
         IF ((((encntr_rec->qual[encntr_index].loc_facility_cd=dist_params_rec->qual[dist_index].
         locations[w].location_cd)) OR ((((encntr_rec->qual[encntr_index].loc_building_cd=
         dist_params_rec->qual[dist_index].locations[w].location_cd)) OR ((((encntr_rec->qual[
         encntr_index].loc_nurse_unit_cd=dist_params_rec->qual[dist_index].locations[w].location_cd))
          OR ((((encntr_rec->qual[encntr_index].loc_room_cd=dist_params_rec->qual[dist_index].
         locations[w].location_cd)) OR ((encntr_rec->qual[encntr_index].loc_bed_cd=dist_params_rec->
         qual[dist_index].locations[w].location_cd))) )) )) )) )
          SET pass_3 = 9
         ENDIF
       ENDFOR
      ELSEIF ((dist_params_rec->qual[dist_index].include_3=7))
       FOR (w = 1 TO size(dist_params_rec->qual[dist_index].locations,5))
         IF ((((encntr_rec->qual[encntr_index].loc_facility_cd=dist_params_rec->qual[dist_index].
         locations[w].location_cd)) OR ((((encntr_rec->qual[encntr_index].loc_building_cd=
         dist_params_rec->qual[dist_index].locations[w].location_cd)) OR ((((encntr_rec->qual[
         encntr_index].loc_nurse_unit_cd=dist_params_rec->qual[dist_index].locations[w].location_cd))
          OR ((((encntr_rec->qual[encntr_index].loc_room_cd=dist_params_rec->qual[dist_index].
         locations[w].location_cd)) OR ((encntr_rec->qual[encntr_index].loc_bed_cd=dist_params_rec->
         qual[dist_index].locations[w].location_cd))) )) )) )) )
          SET pass_3 = 1
         ENDIF
       ENDFOR
       IF (pass_3 != 1)
        SET pass_3 = 9
       ENDIF
      ELSE
       IF ( NOT (pass_3 IN (9, 1)))
        SET pass_3 = 1
       ENDIF
      ENDIF
      IF ((dist_params_rec->qual[dist_index].include_2=5))
       FOR (w = 1 TO size(dist_params_rec->qual[dist_index].providers,5))
        SET a = 0
        FOR (a = 1 TO size(encntr_rec->qual[encntr_index].providers,5))
          IF ((encntr_rec->qual[encntr_index].providers[a].provider_id=dist_params_rec->qual[
          dist_index].providers[w].provider_id)
           AND (encntr_rec->qual[encntr_index].providers[a].reltn_type_cd=dist_params_rec->qual[
          dist_index].providers[w].reltn_type_cd))
           SET pass_2 = 9
          ENDIF
        ENDFOR
       ENDFOR
      ELSEIF ((dist_params_rec->qual[dist_index].include_2=7))
       FOR (w = 1 TO size(dist_params_rec->qual[dist_index].providers,5))
        SET a = 0
        FOR (a = 1 TO size(encntr_rec->qual[encntr_index].providers,5))
          IF ((encntr_rec->qual[encntr_index].providers[a].provider_id=dist_params_rec->qual[
          dist_index].providers[w].provider_id)
           AND (encntr_rec->qual[encntr_index].providers[a].reltn_type_cd=dist_params_rec->qual[
          dist_index].providers[w].reltn_type_cd))
           SET pass_2 = 1
          ENDIF
        ENDFOR
       ENDFOR
       IF (pass_2 != 1)
        SET pass_2 = 9
       ENDIF
      ELSE
       IF ( NOT (pass_2 IN (9, 1)))
        SET pass_2 = 1
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (pass_0 != 9
    AND pass_1 != 9
    AND pass_2 != 9
    AND pass_3 != 9
    AND pass_4 != 9)
    SET pass_all_criteria = 1
   ELSE
    SET pass_all_criteria = 0
   ENDIF
 END ;Subroutine
#exit_script
 CALL echo("* * * END OF PROGRAM * * *")
END GO

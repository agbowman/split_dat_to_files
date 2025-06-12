CREATE PROGRAM dm_test_combine_triggers:dba
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_test TO 2999_test_exit
 GO TO 9999_exit_program
 SUBROUTINE verify_ocd(dummy)
   SET cur_env_id = 0
   SET combine_ocd_nbr = 6475
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_name="DM_ENV_ID"
     AND di.info_domain="DATA MANAGEMENT"
    DETAIL
     cur_env_id = di.info_number
    WITH nocounter
   ;end select
   IF (cur_env_id > 0)
    SELECT INTO "nl:"
     FROM dm_environment de
     WHERE de.environment_id=cur_env_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET cur_env_id = 0
    ENDIF
   ENDIF
   IF (cur_env_id)
    SELECT INTO "nl:"
     FROM dm_alpha_features daf,
      dm_alpha_features_env dafe
     PLAN (daf
      WHERE daf.product_area_number=8
       AND daf.alpha_feature_nbr >= combine_ocd_nbr)
      JOIN (dafe
      WHERE dafe.alpha_feature_nbr=daf.alpha_feature_nbr)
     ORDER BY daf.alpha_feature_nbr DESC
     WITH nocounter
    ;end select
    IF (curqual)
     SET ocd_exist_flag = 1
     CALL echo("*****************************************")
     CALL echo(build("ocd_exist_flag=",ocd_exist_flag))
     CALL echo("Execute Building the Triggers")
     CALL echo("*****************************************")
    ELSE
     CALL echo("*****************************************")
     CALL echo(build("ocd_exist_flag=",ocd_exist_flag))
     CALL echo("OCD 6475 or higer does not exist")
     CALL echo("*****************************************")
    ENDIF
   ELSE
    CALL echo("***********************************************************")
    CALL echo("No Valid Environment ID Found")
    CALL echo("***********************************************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE add_address(aa_id)
  INSERT  FROM address
   SET address_id = seq(address_seq,nextval), parent_entity_name = "PERSON", parent_entity_id = aa_id,
    address_type_cd = 0, updt_cnt = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3),
    updt_id = 0, updt_task = 0, updt_applctx = 0,
    active_ind = 1, active_status_cd = 0, active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    active_status_prsnl_id = 0, address_format_cd = 0, beg_effective_dt_tm = cnvtdatetime(curdate,
     curtime3),
    end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), contact_name = "", residence_type_cd = 0,
    comment_txt = "", street_addr = "", street_addr2 = "",
    street_addr3 = "", street_addr4 = "", city = "",
    state = "", state_cd = 0, zipcode = "",
    zip_code_group_cd = 0, postal_barcode_info = "", county = "",
    county_cd = 0, country = "", country_cd = 0,
    residence_cd = 0, mail_stop = "", data_status_cd = 0,
    data_status_dt_tm = cnvtdatetime(curdate,curtime3), data_status_prsnl_id = 0, address_type_seq =
    0,
    beg_effective_mm_dd = 0, end_effective_mm_dd = 0, contributor_system_cd = 0,
    long_text_id = 0
   WITH nocounter
  ;end insert
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE add_chart_request_audit(acra_id)
  INSERT  FROM chart_request_audit
   SET chart_request_id = seq(chart_seq,nextval), dest_pe_id = acra_id, dest_pe_name = "PERSON",
    dest_txt = "", requestor_pe_id = acra_id, requestor_pe_name = "PERSON",
    requestor_txt = "", reason_cd = 0, comments = "",
    patconobt_ind = 0, input_device = "", active_ind = 1,
    active_status_cd = 0, active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    active_status_prsnl_id = 0,
    updt_cnt = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 0,
    updt_task = 0, updt_applctx = 0
   WITH nocounter
  ;end insert
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE add_domain(ad_encntr_id,ad_person_id)
  INSERT  FROM encntr_domain d
   SET d.encntr_domain_id = seq(encounter_seq,nextval), d.person_id = ad_person_id, d.encntr_id =
    ad_encntr_id,
    d.encntr_domain_type_cd = 0, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    d.updt_id = 0, d.updt_task = 0, d.updt_applctx = 0,
    d.active_ind = 1, d.active_status_cd = 0, d.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    d.active_status_prsnl_id = 0, d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), d
    .end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    d.loc_facility_cd = 0, d.loc_building_cd = 0, d.loc_nurse_unit_cd = 0,
    d.loc_room_cd = 0, d.loc_bed_cd = 0, d.med_service_cd = 0
   WITH nocounter
  ;end insert
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE add_iclass(ai_id)
  INSERT  FROM iclass_person_reltn r
   SET r.seq_object_id = 10000000, r.person_id = ai_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    r.updt_id = 0, r.updt_task = 0, r.updt_cnt = 0,
    r.updt_applctx = 0
   WITH nocounter
  ;end insert
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE update_address(ua_good_id,ua_bad_id)
  UPDATE  FROM address a
   SET a.parent_entity_id = ua_bad_id
   WHERE a.parent_entity_id=ua_good_id
    AND a.parent_entity_name="PERSON"
   WITH nocounter
  ;end update
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE update_patient(up_id,up_from_id,up_to_id)
   DELETE  FROM person_patient p
    WHERE p.person_id=up_to_id
    WITH nocounter
   ;end delete
   UPDATE  FROM person_patient p
    SET p.person_id = up_from_id
    WHERE p.person_id=up_id
    WITH nocounter
   ;end update
   IF (curqual)
    SELECT INTO "nl:"
     p.person_id
     FROM person_patient p
     WHERE p.person_id=up_to_id
     WITH nocounter
    ;end select
    IF (curqual)
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#1000_initialize
 CALL echo("-")
 SET trace = nocost
 SET message = noinformation
 SET person_id = 0.0
 SET from_person_id = 0.0
 SET to_person_id = 0.0
 SET encntr_id = 0.0
 SET encntr_person_id = 0.0
 SET from_encntr_id = 0.0
 SET from_encntr_person_id = 0.0
 SET to_encntr_id = 0.0
 SET moved_encntr_id = 0.0
 SET moved_encntr_person_id = 0.0
#1999_initialize_exit
#2000_test
 SET ocd_exist_flag = 0
 CALL verify_ocd(0)
 SELECT INTO "nl:"
  p.person_id
  FROM person p
  WHERE p.person_id > 0
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND trim(p.name_full_formatted) > " "
   AND  NOT (cnvtupper(p.name_full_formatted)="*SYS*")
   AND  NOT ( EXISTS (
  (SELECT
   c.from_person_id
   FROM person_combine c
   WHERE c.from_person_id=p.person_id)))
   AND  EXISTS (
  (SELECT
   x.person_id
   FROM person_patient x
   WHERE x.person_id=p.person_id))
  DETAIL
   person_id = p.person_id
  WITH nocounter, maxqual(p,1)
 ;end select
 SELECT INTO "nl:"
  p.person_id
  FROM person p,
   person_combine c
  PLAN (c
   WHERE c.from_person_id > 0.0
    AND c.to_person_id > 0.0
    AND c.encntr_id <= 0.0
    AND  NOT ( EXISTS (
   (SELECT
    x.from_person_id
    FROM person_combine x
    WHERE x.from_person_id=c.to_person_id)))
    AND  NOT ( EXISTS (
   (SELECT
    x.from_person_id
    FROM person_combine x
    WHERE x.person_combine_id != c.person_combine_id
     AND x.from_person_id=c.from_person_id))))
   JOIN (p
   WHERE p.person_id=c.from_person_id
    AND trim(p.name_full_formatted) > " "
    AND  NOT (cnvtupper(p.name_full_formatted)="*SYS*"))
  DETAIL
   from_person_id = c.from_person_id, to_person_id = c.to_person_id
  WITH nocounter, maxqual(c,1)
 ;end select
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e
  WHERE e.encntr_id > 0
   AND e.active_ind=1
   AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND ((e.person_id+ 0) > 0.0)
   AND  NOT ( EXISTS (
  (SELECT
   c.from_encntr_id
   FROM encntr_combine c
   WHERE c.from_encntr_id=e.encntr_id)))
   AND  NOT ( EXISTS (
  (SELECT
   c.from_person_id
   FROM person_combine c
   WHERE c.from_person_id=e.person_id)))
  DETAIL
   encntr_id = e.encntr_id, encntr_person_id = e.person_id
  WITH nocounter, maxqual(e,1)
 ;end select
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e,
   encntr_combine c
  PLAN (c
   WHERE c.from_encntr_id > 0.0
    AND c.to_encntr_id > 0.0
    AND  NOT ( EXISTS (
   (SELECT
    x.from_encntr_id
    FROM encntr_combine x
    WHERE x.from_encntr_id=c.to_encntr_id)))
    AND  NOT ( EXISTS (
   (SELECT
    x.from_encntr_id
    FROM encntr_combine x
    WHERE x.encntr_combine_id != c.encntr_combine_id
     AND x.from_encntr_id=c.from_encntr_id))))
   JOIN (e
   WHERE e.encntr_id=c.from_encntr_id
    AND  EXISTS (
   (SELECT
    p.person_id
    FROM person p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND trim(p.name_full_formatted) > " "
     AND  NOT (cnvtupper(p.name_full_formatted)="*SYS*")
     AND  NOT ( EXISTS (
    (SELECT
     c.from_person_id
     FROM person_combine c
     WHERE c.from_person_id=p.person_id))))))
  DETAIL
   from_encntr_id = c.from_encntr_id, from_encntr_person_id = e.person_id, to_encntr_id = c
   .to_encntr_id
  WITH nocounter, maxqual(c,1)
 ;end select
 SELECT INTO "nl:"
  c.encntr_id
  FROM person_combine c
  WHERE c.from_person_id > 0.0
   AND c.to_person_id > 0.0
   AND c.encntr_id > 0.0
   AND  EXISTS (
  (SELECT
   e.encntr_id
   FROM encounter e
   WHERE e.encntr_id=c.encntr_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)))
   AND  NOT ( EXISTS (
  (SELECT
   x.encntr_id
   FROM person_combine x
   WHERE x.encntr_id=c.encntr_id
    AND x.person_combine_id != c.person_combine_id)))
   AND  NOT ( EXISTS (
  (SELECT
   x.from_person_id
   FROM person_combine x
   WHERE x.from_person_id=c.to_person_id)))
  DETAIL
   moved_encntr_id = c.encntr_id, moved_encntr_person_id = c.to_person_id
  WITH nocounter
 ;end select
 CALL echo(concat("          Normal Person ID: ",trim(cnvtstring(person_id),3)))
 CALL echo(concat("   Combined From Person ID: ",trim(cnvtstring(from_person_id),3)))
 CALL echo(concat("     Combined To Person ID: ",trim(cnvtstring(to_person_id),3)))
 CALL echo(concat("       Normal Encounter ID: ",trim(cnvtstring(encntr_id),3)))
 CALL echo(concat("Combined From Encounter ID: ",trim(cnvtstring(from_encntr_id),3)))
 CALL echo(concat("  Combined To Encounter ID: ",trim(cnvtstring(to_encntr_id),3)))
 CALL echo(concat("        Moved Encounter ID: ",trim(cnvtstring(moved_encntr_id),3)))
 IF (add_address(person_id))
  CALL echo("Insert for normal person successful in ADDRESS.")
 ELSE
  CALL echo("ERROR: Unable to insert ADDRESS row for normal person.")
 ENDIF
 IF (add_address(from_person_id))
  CALL echo("ERROR: Insert of ADDRESS for combined away person should have failed.")
 ELSE
  CALL echo("Insert for combined away person failed as expected in ADDRESS.")
 ENDIF
 IF (add_chart_request_audit(person_id))
  CALL echo("Insert for normal person successful in CHART_REQUEST_AUDIT.")
 ELSE
  CALL echo("ERROR: Unable to insert CHART_REQUEST_AUDIT row for normal person.")
 ENDIF
 IF (add_chart_request_audit(from_person_id))
  CALL echo("ERROR: Insert of CHART_REQUEST_AUDIT for combined away person should have failed.")
 ELSE
  CALL echo("Insert for combined away person failed as expected in CHART_REQUEST_AUDIT.")
 ENDIF
 IF (add_domain(encntr_id,encntr_person_id))
  CALL echo("Insert for normal encounter successful.")
 ELSE
  CALL echo("ERROR: Unable to insert ENCNTR_DOMAIN row for normal encounter.")
 ENDIF
 IF (add_domain(from_encntr_id,from_encntr_person_id))
  CALL echo("ERROR: Insert of ENCNTR_DOMAIN for combined away encounter should have failed.")
 ELSE
  CALL echo("Insert for combined away encounter failed as expected.")
 ENDIF
 IF (update_address(person_id,to_person_id))
  CALL echo("Update for normal person successful.")
 ELSE
  CALL echo("ERROR: Unable to update ADDRESS row for normal person.")
 ENDIF
 IF (update_address(to_person_id,from_person_id))
  CALL echo("ERROR: Update for combined away person should have failed.")
 ELSE
  CALL echo("Update for combined away person failed as expected.")
 ENDIF
 IF (add_iclass(from_person_id))
  CALL echo("Insert for combined away person on null trigger table successful.")
 ELSE
  CALL echo(
   "ERROR: Unable to insert ICLASS_PERSON_RELTN row for combined away person (null trigger).")
 ENDIF
 IF (add_domain(moved_encntr_id,moved_encntr_person_id))
  CALL echo("Insert for moved encounter successful.")
 ELSE
  CALL echo("ERROR: Insert of ENCNTR_DOMAIN for moved encounter failed.")
 ENDIF
 IF (add_domain(moved_encntr_id,1.0))
  CALL echo(
   "ERROR: Insert of ENCNTR_DOMAIN for moved encounter with wrong person ID should have failed.")
 ELSE
  CALL echo("Insert for moved encounter with wrong person ID failed as expected.")
 ENDIF
 IF (update_patient(person_id,from_person_id,to_person_id))
  CALL echo("Update for person with auto trigger successful.")
 ELSE
  CALL echo("ERROR: Update for person with auto trigger failed.")
 ENDIF
#2999_test_exit
#9999_exit_program
 CALL echo("Done.")
 CALL echo("-")
 SET trace = cost
 SET message = information
 ROLLBACK
END GO

CREATE PROGRAM bed_imp_org_work:dba
 FREE SET reply
 RECORD reply(
   1 org_list[*]
     2 org_id = f8
     2 loc_list[*]
       3 loc_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET reply_count = 0
 SET list_count = 0
 SET row_cnt = size(requestin->list_0,5)
 SET stat = alterlist(reply->org_list,10)
 SET new_org_id = 0.0
 SET new_loc_id = 0.0
 SET seq_cnt = 0
 SET seq_total = 0
 SET org_cnt = 0
 SET org_total = 0
 SET last_country = fillstring(40," ")
 SET last_county = fillstring(40," ")
 SET last_state = fillstring(60," ")
 SET last_org = fillstring(60," ")
 SET last_time_zone = fillstring(40," ")
 SET upper_state = fillstring(60," ")
 SET upper_country = fillstring(40," ")
 SET upper_county = fillstring(40," ")
 SET time_zone = fillstring(100," ")
 SET country_code_value = 0.0
 SET county_code_value = 0.0
 SET state_code_value = 0.0
 SET time_zone_id = 0.0
 SET org_start_ind = 0
 SET first_org = 0
 SET out_reach_ind = 0
 SET lab_ind = 0
 SET region = fillstring(100," ")
 SELECT INTO "NL:"
  FROM br_client b
  DETAIL
   region = b.region
  WITH nocounter
 ;end select
 IF (region="    *")
  SET region = "USA"
 ENDIF
 FOR (x = 1 TO row_cnt)
   SET error_flag = "N"
   SET upper_state = cnvtupper(requestin->list_0[x].state)
   IF (last_state != upper_state)
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.active_ind=1
      AND cv.code_set=62
      AND ((cnvtupper(cv.display)=upper_state) OR (cnvtupper(cv.description)=upper_state))
     DETAIL
      state_code_value = cv.code_value, last_state = upper_state
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET state_code_value = 0.0
     SET last_state = fillstring(60," ")
    ENDIF
   ENDIF
   SET upper_county = cnvtupper(requestin->list_0[x].county)
   IF ((last_county != requestin->list_0[x].county))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.active_ind=1
      AND cv.code_set=74
      AND cnvtupper(cv.display)=upper_county
     DETAIL
      county_code_value = cv.code_value, last_county = upper_county
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET county_code_value = 0.0
     SET last_county = fillstring(40," ")
    ENDIF
   ENDIF
   SET upper_country = cnvtupper(requestin->list_0[x].country)
   IF (last_country != upper_country)
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.active_ind=1
      AND cv.code_set=15
      AND cnvtupper(cv.display)=upper_country
     DETAIL
      country_code_value = cv.code_value, last_country = upper_country
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET country_code_value = 0.0
     SET last_country = fillstring(40," ")
    ENDIF
   ENDIF
   IF ((last_org != requestin->list_0[x].org_name)
    AND (requestin->list_0[x].org_name > "  "))
    IF (x > 1)
     SET stat = alterlist(reply->org_list[org_total].loc_list,seq_total)
    ENDIF
    SET org_total = (org_total+ 1)
    SET org_cnt = (org_cnt+ 1)
    IF (org_cnt > 10)
     SET stat = alterlist(reply->org_list,(org_total+ 10))
     SET org_cnt = 0
    ENDIF
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_org_id = cnvtreal(j)
     WITH format, counter
    ;end select
    IF (first_org=0
     AND (((requestin->list_0[x].start_org_ind="1")) OR ((((requestin->list_0[x].start_org_ind="Y*"))
     OR ((requestin->list_0[x].start_org_ind="y*"))) )) )
     SET org_start_ind = 1
     SET first_org = 1
    ELSE
     SET org_start_ind = 0
    ENDIF
    SET reply->org_list[org_total].org_id = new_org_id
    SET stat = alterlist(reply->org_list[org_total].loc_list,5)
    SET seq_total = 0
    SET seq_cnt = 0
    SET time_zone = cnvtupper(requestin->list_0[x].time_zone)
    IF (((time_zone_id=0) OR (time_zone != last_time_zone)) )
     SELECT INTO "NL:"
      FROM br_time_zone b
      WHERE b.active_ind=1
       AND cnvtupper(b.description)=time_zone
       AND b.region=region
      DETAIL
       time_zone_id = b.time_zone_id, last_time_zone = cnvtupper(requestin->list_0[x].time_zone)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET time_zone_id = 0.0
      SET last_time_zone = fillstring(40," ")
     ENDIF
    ENDIF
    IF ((((requestin->list_0[x].lab_ind="1")) OR ((((requestin->list_0[x].lab_ind="Y*")) OR ((
    requestin->list_0[x].lab_ind="y*"))) )) )
     SET lab_ind = 1
    ELSE
     SET lab_ind = 0
    ENDIF
    INSERT  FROM br_org_work b
     SET b.organization_id = new_org_id, b.tax_id_nbr = requestin->list_0[x].tax_id, b.name =
      requestin->list_0[x].org_name,
      b.prefix = requestin->list_0[x].org_short, b.org_display = requestin->list_0[x].org_display, b
      .time_zone_id = time_zone_id,
      b.start_ind = org_start_ind, b.lab_ind = lab_ind, b.status_ind = 0,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].org_name),
      " into the br_org_work table.")
     GO TO exit_script
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_loc_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET seq_total = (seq_total+ 1)
   SET seq_cnt = (seq_cnt+ 1)
   IF (seq_cnt > 5)
    SET stat = alterlist(reply->org_list[org_total].loc_list,(seq_total+ 5))
   ENDIF
   SET reply->org_list[org_total].loc_list[seq_total].loc_id = new_loc_id
   IF ((((requestin->list_0[x].outreach_ind="1")) OR ((((requestin->list_0[x].outreach_ind="Y*")) OR
   ((requestin->list_0[x].outreach_ind="y*"))) )) )
    SET out_reach_ind = 1
   ELSE
    SET out_reach_ind = 0
   ENDIF
   INSERT  FROM br_loc_work b
    SET b.location_id = new_loc_id, b.organization_id = new_org_id, b.type = requestin->list_0[x].
     loc_type,
     b.sequence = seq_cnt, b.prefix = requestin->list_0[x].loc_short, b.loc_display = requestin->
     list_0[x].loc_display,
     b.name =
     IF (trim(requestin->list_0[x].loc_type)="Acute Care"
      AND (requestin->list_0[x].location_name="     *")) "Inpatient Acute Care Areas"
     ELSE requestin->list_0[x].location_name
     ENDIF
     , b.address1 = requestin->list_0[x].address1, b.address2 = requestin->list_0[x].address2,
     b.city = requestin->list_0[x].city, b.state_cd = state_code_value, b.county_cd =
     county_code_value,
     b.country_cd = country_code_value, b.zip = requestin->list_0[x].zip, b.phone = requestin->
     list_0[x].phone,
     b.extension = requestin->list_0[x].extension, b.outreach_ind = out_reach_ind, b.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
     b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].location_name),
     " into the br_loc_work table.")
    GO TO exit_script
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->org_list[org_total].loc_list,seq_total)
 SET stat = alterlist(reply->org_list,org_total)
 GO TO exit_script
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
  CALL echo("*                                                            *")
  CALL echo("*             ORGANIZATION FILE IMPORTED SUCCESSFULLY        *")
  CALL echo("*                                                            *")
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_ORG_WORK","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
  CALL echo("*                                                            *")
  CALL echo("*            ORGANIZATION FILE IMPORT HAS FAILED             *")
  CALL echo("*  Do not run additional imports, contact the BEDROCK team   *")
  CALL echo("*                                                            *")
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
 ENDIF
END GO

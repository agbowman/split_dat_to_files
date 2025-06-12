CREATE PROGRAM dm_dwn_abs_tz_fields:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failure: starting dm_dwn_abs_tz_fields.prg script"
 FREE RECORD tmppersontz
 RECORD tmppersontz(
   1 qual[*]
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 abs_birth_dt_tm = dq8
     2 birth_tz = i4
     2 update_ind = i2
 )
 IF (curcclrev < 8.1)
  SET readme_data->status = "S"
  SET readme_data->message = "AUTO-SUCCESS.  Readme should not run in less than 8.1 environment."
  GO TO end_program
 ENDIF
 DECLARE perscount = i4
 DECLARE errperson_id = f8
 DECLARE time_zone_empty_ind = i2
 DECLARE mrn_code_val = f8
 DECLARE max_reg_dt_tm = f8
 DECLARE max_updt_dt_tm = f8
 DECLARE maxperson_id = i4
 DECLARE gettimezone(inperson_id=f8) = i4
 SUBROUTINE gettimezone(inperson_id)
   DECLARE tmptimezone = i4 WITH private
   SET tmptimezone = - (999)
   SELECT INTO "nl:"
    cs.time_zone
    FROM contributor_system cs,
     person p
    WHERE ((p.contributor_system_cd+ 0) > 0)
     AND ((p.contributor_system_cd+ 0)=cs.contributor_system_cd)
     AND p.person_id=inperson_id
    DETAIL
     tmptimezone = datetimezonebyname(trim(cs.time_zone,3))
    WITH nocounter
   ;end select
   IF (time_zone_empty_ind=0)
    IF ((tmptimezone=- (999)))
     SELECT INTO "nl:"
      FROM encounter e
      WHERE e.person_id=inperson_id
      HEAD REPORT
       col + 0
      FOOT REPORT
       max_reg_dt_tm = max(e.reg_dt_tm)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      tz.time_zone
      FROM time_zone_r tz,
       encounter e
      WHERE e.person_id=inperson_id
       AND e.reg_dt_tm=cnvtdatetime(max_reg_dt_tm)
       AND ((e.loc_facility_cd+ 0) > 0)
       AND ((e.loc_facility_cd+ 0)=tz.parent_entity_id)
       AND tz.parent_entity_name="LOCATION"
      DETAIL
       tmptimezone = datetimezonebyname(trim(tz.time_zone,3))
      WITH nocounter
     ;end select
    ENDIF
    IF ((tmptimezone=- (999)))
     SELECT INTO "nl:"
      FROM person_alias pa
      WHERE pa.person_id=inperson_id
       AND pa.person_alias_type_cd=mrn_code_val
      HEAD REPORT
       col + 0
      FOOT REPORT
       max_updt_dt_tm = max(pa.updt_dt_tm)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      tz.time_zone
      FROM time_zone_r tz,
       org_alias_pool_reltn oap,
       person_alias pa
      WHERE pa.person_id=inperson_id
       AND pa.updt_dt_tm=cnvtdatetime(max_updt_dt_tm)
       AND pa.person_alias_type_cd=mrn_code_val
       AND ((pa.alias_pool_cd+ 0)=oap.alias_pool_cd)
       AND ((pa.alias_pool_cd+ 0) > 0)
       AND ((oap.organization_id+ 0)=tz.parent_entity_id)
       AND ((oap.organization_id+ 0) > 0)
       AND tz.parent_entity_name="ORGANIZATION"
      DETAIL
       tmptimezone = datetimezonebyname(trim(tz.time_zone,3))
      WITH nocounter, maxqual(tz,1)
     ;end select
    ENDIF
   ENDIF
   IF ((tmptimezone=- (999)))
    SET tmptimezone = curtimezonesys
   ENDIF
   RETURN(tmptimezone)
 END ;Subroutine
 SET perscount = 0
 CALL echo("start time:")
 CALL echo(format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET message = noinformation
 SET trace = nocost
 SELECT INTO "nl:"
  max_id = max(p.person_id)
  FROM person p
  DETAIL
   maxperson_id = (max_id - 1)
  WITH nocounter
 ;end select
 CALL echo("*****Finding rows that need updates*****")
 SET stat = alterlist(tmppersontz->qual,1)
 SELECT INTO "nl:"
  p.person_id, p.birth_dt_tm, p.abs_birth_dt_tm
  FROM person p
  WHERE p.birth_dt_tm != null
   AND ((p.abs_birth_dt_tm=null) OR (p.birth_tz=null))
  ORDER BY p.person_id
  DETAIL
   perscount = (perscount+ 1)
   IF (perscount > size(tmppersontz->qual,5))
    stat = alterlist(tmppersontz->qual,(perscount+ 1000))
   ENDIF
   tmppersontz->qual[perscount].person_id = p.person_id, tmppersontz->qual[perscount].birth_dt_tm = p
   .birth_dt_tm, tmppersontz->qual[perscount].abs_birth_dt_tm = p.abs_birth_dt_tm,
   tmppersontz->qual[perscount].birth_tz = p.birth_tz
  WITH nocounter
 ;end select
 SET stat = alterlist(tmppersontz->qual,perscount)
 CALL echo("*****Finished finding rows that need updates*****")
 CALL echo("**********************************************")
 CALL echo(build("Number of rows to update:",perscount))
 CALL echo("**********************************************")
 SET time_zone_empty_ind = 1
 SELECT INTO "NL:"
  FROM time_zone_r t
  WHERE t.parent_entity_id != 0
   AND t.parent_entity_name IN ("LOCATION", "ORGANIZATION")
   AND t.time_zone IS NOT null
  DETAIL
   time_zone_empty_ind = 0
  WITH nocounter, maxqual(t,10)
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=4
   AND cv.cdf_meaning="MRN"
  DETAIL
   mrn_code_val = cv.code_value
  WITH nocounter
 ;end select
 FOR (xx = 1 TO size(tmppersontz->qual,5))
   SET tmppersontz->qual[xx].birth_tz = gettimezone(tmppersontz->qual[xx].person_id)
   SET tmppersontz->qual[xx].abs_birth_dt_tm = datetimezone(tmppersontz->qual[xx].birth_dt_tm,
    tmppersontz->qual[xx].birth_tz)
   UPDATE  FROM person p
    SET p.abs_birth_dt_tm = cnvtdatetime(tmppersontz->qual[xx].abs_birth_dt_tm), p.birth_tz =
     tmppersontz->qual[xx].birth_tz
    WHERE (p.person_id=tmppersontz->qual[xx].person_id)
    WITH nocounter
   ;end update
   UPDATE  FROM person_matches pm
    SET pm.a_birth_tz = tmppersontz->qual[xx].birth_tz, pm.b_birth_tz = tmppersontz->qual[xx].
     birth_tz
    WHERE (pm.a_person_id=tmppersontz->qual[xx].person_id)
     AND pm.active_ind=1
    WITH nocounter
   ;end update
   UPDATE  FROM hna_except_audit hea
    SET hea.dob_tz = tmppersontz->qual[xx].birth_tz
    WHERE (hea.person_id=tmppersontz->qual[xx].person_id)
    WITH nocounter
   ;end update
   IF (mod(xx,1000)=0)
    CALL echo(build("Rows Finished: ",xx))
    COMMIT
   ENDIF
 ENDFOR
 COMMIT
 SET errperson_id = 0
 SELECT INTO "nl:"
  p.*
  FROM person p
  WHERE p.person_id != 0
   AND p.person_id < maxperson_id
   AND p.birth_dt_tm != null
   AND p.abs_birth_dt_tm=null
  DETAIL
   errperson_id = p.person_id
  WITH nocounter, maxqual(p,1)
 ;end select
 IF (errperson_id=0)
  SET readme_data->message = build("- Readme SUCCESS. DM_UPT_DWN_TZ_FIELDS.")
  SET readme_data->status = "S"
 ELSE
  SET readme_data->message = build("- Readme FAILURE. DM_UPT_DWN_TZ_FIELDS. Person id -",trim(
    cnvtstring(errperson_id),3),"- has not been updated.")
  SET readme_data->status = "F"
 ENDIF
 EXECUTE dm_readme_status
 CALL echo(readme_data->message)
 FREE RECORD tmppersontz
#end_program
 SET message = information
 SET trace = cost
 CALL echo("end time:")
 CALL echo(format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
END GO

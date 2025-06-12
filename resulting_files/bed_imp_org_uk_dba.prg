CREATE PROGRAM bed_imp_org_uk:dba
#1000_initialize
 SET reqinfo->updt_id = 12758
 SET reqinfo->updt_task = 1
 SET reqinfo->commit_ind = 1
 SET auth_status_cd = 0.0
 SET active_status_cd = 0.0
 SET inactive_status_cd = 0.0
 SET org_cd = 0.0
 SET addr_bus_cd = 0.0
 SET phone_bus_cd = 0.0
 SET loc_facility_cd = 0.0
 SET client_cd = 0.0
 SET employer_cd = 0.0
 SET facility_cd = 0.0
 SET hospital_cd = 0.0
 SET insco_cd = 0.0
 SET comment_cd = 0.0
 SET nhsorgalias_cd = 0.0
 SET org_cnt = 0
 SET org_class_cd = 0.0
 SET location_cd = 0.0
 SET alias_pool_cd = 0.0
 SET state_cd = 0.0
 SET country_cd = 0.0
 SET file_name = "org_load.csv"
 SET line_sze = 0
 SET pstn = 0
 SET start_pstn = 0
 SET new_org = 0.0
 SET new_org_alias = 0.0
 SET new_addr = 0.0
 SET new_phone = 0.0
 SET new_long_text = 0.0
 SET new_org_info = 0.0
 SET ii = 0
 SET type_cnt = 0
 SET type_string = fillstring(300," ")
 SET type_start_pstn = 0
 SET type_pstn = 0
 SET type_cd = 0.0
 SET org_error = "N"
 SET fmt_alias_type = fillstring(40," ")
 SET org_alias_type_cd = 0.0
 SET phone_number = fillstring(100," ")
 DECLARE pct_mean_val = vc
 DECLARE dha_mean_val = vc
 DECLARE nhstrust_val = vc
 DECLARE practice_val = vc
 DECLARE pct_ind_val = vc
 DECLARE beg_date_val = vc
 DECLARE end_date_val = vc
 DECLARE parent_alias_val = vc
 DECLARE active_row = i2
 DECLARE msg = vc
 DECLARE column_exists(stable,scolumn) = i4
 DECLARE nhstrust_org_type_cd = f8
 DECLARE practice_org_type_cd = f8
 DECLARE pct_org_type_cd = f8
 DECLARE dha_cd = f8
 DECLARE pct_cd = f8
 SET rvar = 0
 SELECT INTO "ccluserdir:bed_org_uk_error.log"
  rvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "Bedrock UK Organization Load Error Log"
  DETAIL
   row + 2, col 2, " "
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 DECLARE baliaskey = i4 WITH noconstant(0)
 SET baliaskey = column_exists("ORGANIZATION_ALIAS","ALIAS_KEY")
 CALL echo(build("bAliasKey = ",baliaskey))
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=278
   AND c.cdf_meaning="PCT"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   pct_org_type_cd = c.code_value
  WITH nocounter
 ;end select
 IF (pct_org_type_cd=0.0)
  SET msg = "No org type code for PCT on code set 278"
  CALL logerrormessage(msg)
  GO TO 9999_end
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=278
   AND c.cdf_meaning="NHSTRUST"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   nhstrust_org_type_cd = c.code_value
  WITH nocounter
 ;end select
 IF (nhstrust_org_type_cd=0.0)
  SET msg = "No org type code for NHSTRUST on code set 278"
  CALL logerrormessage(msg)
  GO TO 9999_end
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=278
   AND c.cdf_meaning="PRACTICE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   practice_org_type_cd = c.code_value
  WITH nocounter
 ;end select
 IF (practice_org_type_cd=0.0)
  SET msg = "No org type code for PRACTICE on code set 278"
  CALL logerrormessage(msg)
  GO TO 9999_end
 ENDIF
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,auth_status_cd)
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_status_cd)
 SET stat = uar_get_meaning_by_codeset(48,"INACTIVE",1,inactive_status_cd)
 SET stat = uar_get_meaning_by_codeset(396,"ORG",1,org_cd)
 SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",1,addr_bus_cd)
 SET stat = uar_get_meaning_by_codeset(43,"BUSINESS",1,phone_bus_cd)
 SET stat = uar_get_meaning_by_codeset(222,"FACILITY",1,loc_facility_cd)
 SET stat = uar_get_meaning_by_codeset(278,"CLIENT",1,client_cd)
 SET stat = uar_get_meaning_by_codeset(278,"EMPLOYER",1,employer_cd)
 SET stat = uar_get_meaning_by_codeset(278,"FACILITY",1,facility_cd)
 SET stat = uar_get_meaning_by_codeset(278,"HOSPITAL",1,hospital_cd)
 SET stat = uar_get_meaning_by_codeset(278,"INSCO",1,insco_cd)
 SET stat = uar_get_meaning_by_codeset(355,"COMMENT",1,comment_cd)
 SET stat = uar_get_meaning_by_codeset(334,"NHSORGALIAS",1,nhsorgalias_cd)
 SET phone_format = uar_get_code_by("DISPLAYKEY",281,"UK")
 SET org_alias_type_cd = nhsorgalias_cd
 RECORD types(
   1 list[*]
     2 misc_type_qual = i2
     2 misc_types[*]
       3 cdf_meaning = c12
 )
#2000_main
 SET numrows = size(requestin->list_0,5)
 SET loopvar = 1
 WHILE (loopvar <= numrows)
   SET org_cnt = (org_cnt+ 1)
   SET stat = alterlist(types->list,org_cnt)
   IF ((requestin->list_0[org_cnt].misc_org_types > " "))
    SET type_cnt = 0
    SET type_string = requestin->list_0[org_cnt].misc_org_types
    SET type_start_pstn = 0
    SET type_pstn = findstring(";",type_string,type_start_pstn)
    WHILE (type_pstn != 0)
      SET type_cnt = (type_cnt+ 1)
      SET stat = alterlist(types->list[org_cnt].misc_types,type_cnt)
      IF (type_cnt=1)
       SET types->list[org_cnt].misc_types[type_cnt].cdf_meaning = substring(type_start_pstn,(
        type_pstn - 1),type_string)
      ELSE
       SET types->list[org_cnt].misc_types[type_cnt].cdf_meaning = substring(type_start_pstn,(
        type_pstn - type_start_pstn),type_string)
      ENDIF
      SET type_start_pstn = (type_pstn+ 1)
      SET type_pstn = findstring(";",type_string,type_start_pstn)
    ENDWHILE
   ENDIF
   SET types->list[org_cnt].misc_type_qual = type_cnt
   SET loopvar = (loopvar+ 1)
 ENDWHILE
 FOR (mio_x = 1 TO org_cnt)
   SET pct_mean_val = 0.0
   SET dha_mean_val = 0.0
   SET nhstrust_val = 0.0
   SET practice_val = 0.0
   SET pct_ind_val = 0.0
   SET beg_date_val = 0.0
   SET end_date_val = 0.0
   SET parent_alias_val = 0.0
   SET alias_pool_cd = 0.0
   SELECT INTO "nl:"
    c.seq
    FROM code_value c
    WHERE c.code_set=263
     AND c.display_key=cnvtupper(cnvtalphanum(requestin->list_0[mio_x].alias_pool_disp1))
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     alias_pool_cd = c.code_value
    WITH nocounter
   ;end select
   IF (alias_pool_cd=0)
    SET msg = concat("No alias pool found for ",trim(requestin->list_0[mio_x].alias_pool_disp1),
     " on code set 263 for org ",trim(requestin->list_0[mio_x].org_name))
    CALL logerrormessage(msg)
   ENDIF
   FREE SET alias_pool_holder
   RECORD alias_pool_holder(
     1 alias_pool_count = i4
     1 alias_pol_cd = f8
     1 alias_entity_alias_type_cd = f8
     1 alias_pool_reltn[*]
       2 alias_entity_name = vc
       2 alias_entity_cs = f8
       2 alias_entity_alias_type = vc
       2 alias_pool = vc
   )
   SET alias_pool_holder->alias_pool_count = 0
   SET current_nvp_val = 0
   IF ((requestin->list_0[mio_x].nvp_name1 != " "))
    SET current_nvp_val = 1
    SET nvp_val_count = 1
   ENDIF
   WHILE (current_nvp_val=1)
     SET nvp_name = cnvtupper(trim(parser(build("requestin->list_0[",mio_x,"].nvp_name",nvp_val_count
         ))))
     SET nvp_val = cnvtupper(trim(parser(build("requestin->list_0[",mio_x,"].nvp_val",nvp_val_count))
       ))
     SET nvp_ext = cnvtupper(trim(parser(build("requestin->list_0[",mio_x,"].nvp_ext",nvp_val_count))
       ))
     IF (nvp_name="PCT_MEAN")
      SET pct_mean_val = nvp_val
     ELSEIF (nvp_name="DHA_MEAN")
      SET dha_mean_val = nvp_val
     ELSEIF (nvp_name="NHSTRUST")
      SET nhstrust_val = nvp_val
     ELSEIF (nvp_name="PRACTICE")
      SET practice_val = nvp_val
     ELSEIF (nvp_name="PCT_IND")
      SET pct_ind_val = nvp_val
     ELSEIF (nvp_name="BEG_EFFECTIVE_DT_TM")
      SET beg_date_val = nvp_val
     ELSEIF (nvp_name="END_EFFECTIVE_DT_TM")
      SET end_date_val = nvp_val
     ELSEIF (nvp_name="PARENT_ORG_ALIAS")
      SET parent_alias_val = nvp_val
     ELSEIF (nvp_name="PERSON_ALIAS")
      SET alias_pool_holder->alias_pool_count = (alias_pool_holder->alias_pool_count+ 1)
      SET stat = alterlist(alias_pool_holder->alias_pool_reltn,alias_pool_holder->alias_pool_count)
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_name = "PERSON_ALIAS"
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_cs = 4
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_alias_type = nvp_val
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_pool = nvp_ext
     ELSEIF (nvp_name="ENCOUNTER_ALIAS")
      SET alias_pool_holder->alias_pool_count = (alias_pool_holder->alias_pool_count+ 1)
      SET stat = alterlist(alias_pool_holder->alias_pool_reltn,alias_pool_holder->alias_pool_count)
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_name = "ENCOUNTER_ALIAS"
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_cs = 319
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_alias_type = nvp_val
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_pool = nvp_ext
     ELSEIF (nvp_name="PERSONNEL_ALIAS")
      SET alias_pool_holder->alias_pool_count = (alias_pool_holder->alias_pool_count+ 1)
      SET stat = alterlist(alias_pool_holder->alias_pool_reltn,alias_pool_holder->alias_pool_count)
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_name = "PERSONNEL_ALIAS"
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_cs = 320
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_alias_type = nvp_val
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_pool = nvp_ext
     ELSEIF (nvp_name="ORDER_ALIAS")
      SET alias_pool_holder->alias_pool_count = (alias_pool_holder->alias_pool_count+ 1)
      SET stat = alterlist(alias_pool_holder->alias_pool_reltn,alias_pool_holder->alias_pool_count)
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_name = "ORDER_ALIAS"
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_cs = 754
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_alias_type = nvp_val
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_pool = nvp_ext
     ELSEIF (nvp_name="ORGANIZATION_ALIAS")
      SET alias_pool_holder->alias_pool_count = (alias_pool_holder->alias_pool_count+ 1)
      SET stat = alterlist(alias_pool_holder->alias_pool_reltn,alias_pool_holder->alias_pool_count)
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_name =
      "ORGANIZATION_ALIAS"
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_cs = 334
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_alias_type = nvp_val
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_pool = nvp_ext
     ELSEIF (nvp_name="MEDIA ALIAS")
      SET alias_pool_holder->alias_pool_count = (alias_pool_holder->alias_pool_count+ 1)
      SET stat = alterlist(alias_pool_holder->alias_pool_reltn,alias_pool_holder->alias_pool_count)
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_name = "Media Alias"
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_cs = 3542
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_alias_type = nvp_val
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_pool = nvp_ext
     ELSEIF (nvp_name="PROFIT BILL ALIAS")
      SET alias_pool_holder->alias_pool_count = (alias_pool_holder->alias_pool_count+ 1)
      SET stat = alterlist(alias_pool_holder->alias_pool_reltn,alias_pool_holder->alias_pool_count)
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_name = "ProFit Bill Alias"
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_cs = 28200
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_alias_type = nvp_val
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_pool = nvp_ext
     ELSEIF (nvp_name="HEALTH PLAN ALIAS")
      SET alias_pool_holder->alias_pool_count = (alias_pool_holder->alias_pool_count+ 1)
      SET stat = alterlist(alias_pool_holder->alias_pool_reltn,alias_pool_holder->alias_pool_count)
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_name = "HEALTH_PLAN_ALIAS"
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_cs = 27121
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_alias_type = nvp_val
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_pool = nvp_ext
     ELSEIF (nvp_name="SCH EVENT ALIAS")
      SET alias_pool_holder->alias_pool_count = (alias_pool_holder->alias_pool_count+ 1)
      SET stat = alterlist(alias_pool_holder->alias_pool_reltn,alias_pool_holder->alias_pool_count)
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_name = "SCH_EVENT_ALIAS"
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_cs = 26881
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_entity_alias_type = nvp_val
      SET alias_pool_holder->alias_pool_reltn[alias_pool_cnt].alias_pool = nvp_ext
     ENDIF
     SET current_nvp_val = 0
     SET nvp_val_count = (nvp_val_count+ 1)
     IF (parser(build("requestin->list_0[",mio_x,"].nvp_name",nvp_val_count)) != " ")
      SET current_nvp_val = 1
     ENDIF
   ENDWHILE
   SET org_id = 0.0
   SELECT INTO "nl:"
    FROM organization_alias oa
    PLAN (oa
     WHERE (oa.alias=requestin->list_0[mio_x].alias1)
      AND oa.org_alias_type_cd=nhsorgalias_cd
      AND oa.alias_pool_cd=alias_pool_cd)
    DETAIL
     org_id = oa.organization_id
    WITH nocounter
   ;end select
   CALL echo(build("org_id = ",org_id))
   IF (org_id=0.0)
    SELECT INTO "nl:"
     o.seq
     FROM organization o
     WHERE (o.org_name=requestin->list_0[mio_x].org_name)
      AND o.active_ind=1
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET new_org = 0.0
     SELECT INTO "nl:"
      y = seq(organization_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_org = cnvtreal(y)
      WITH format, nocounter
     ;end select
     IF (beg_date_val > " ")
      SET beg_date = cnvtdatetime(beg_date_val)
     ENDIF
     IF (end_date_val > " ")
      SET end_date = cnvtdatetime(end_date_val)
     ENDIF
     INSERT  FROM organization o
      SET o.organization_id = new_org, o.contributor_system_cd = 0, o.org_name = requestin->list_0[
       mio_x].org_name,
       o.org_name_key = cnvtupper(cnvtalphanum(requestin->list_0[mio_x].org_name)), o
       .federal_tax_id_nbr = "", o.org_status_cd = 0,
       o.ft_entity_id = 0, o.ft_entity_name = "", o.org_class_cd = org_cd,
       o.data_status_cd = auth_status_cd, o.data_status_dt_tm = cnvtdatetime(curdate,curtime3), o
       .data_status_prsnl_id = reqinfo->updt_id,
       o.beg_effective_dt_tm =
       IF (beg_date_val <= " ") cnvtdatetime(curdate,curtime3)
       ELSE cnvtdatetime(beg_date_val)
       ENDIF
       , o.end_effective_dt_tm =
       IF (end_date_val <= " ") cnvtdatetime("31-DEC-2100")
       ELSE cnvtdatetime(end_date_val)
       ENDIF
       , o.active_ind = 1,
       o.active_status_cd = active_status_cd, o.active_status_prsnl_id = reqinfo->updt_id, o
       .active_status_dt_tm = cnvtdatetime(curdate,curtime),
       o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
       o.updt_applctx = 12758, o.updt_task = 12758
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET msg = concat("Error adding org: ",trim(requestin->list_0[mio_x].org_name))
      CALL logerrormessage(msg)
     ENDIF
     SET state_cd = 0
     IF ((requestin->list_0[mio_x].state_disp > " "))
      SELECT INTO "nl:"
       c.code_value
       FROM code_value c
       WHERE c.code_set=62
        AND (c.display=requestin->list_0[mio_x].state_disp)
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       DETAIL
        state_cd = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     SET country_cd = 0
     IF ((requestin->list_0[mio_x].country_disp > " "))
      SELECT INTO "nl:"
       c.code_value
       FROM code_value c
       WHERE c.code_set=15
        AND (c.display=requestin->list_0[mio_x].country_disp)
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       DETAIL
        country_cd = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     SET dha_cd = 0.0
     SELECT INTO "nl:"
      FROM code_value c
      WHERE c.code_set=29881
       AND c.cdf_meaning=trim(dha_mean_val)
       AND c.active_ind=1
       AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      DETAIL
       dha_cd = c.code_value
      WITH nocounter
     ;end select
     IF (dha_cd=0
      AND trim(dha_mean_val) != "")
      SET msg = concat("DHA code '",dha_mean_val,"' not found on code set 29881 for org ",trim(
        requestin->list_0[mio_x].org_name))
      CALL logerrormessage(msg)
     ENDIF
     SELECT INTO "nl:"
      FROM code_value c
      WHERE c.code_set=29880
       AND c.cdf_meaning=trim(pct_mean_val)
       AND c.active_ind=1
       AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      DETAIL
       pct_cd = c.code_value
      WITH nocounter
     ;end select
     IF (pct_cd=0
      AND trim(pct_mean_val) != "")
      SET msg = concat("PCT code '",pct_mean_val,"' not found on code set 29880 for org ",trim(
        requestin->list_0[mio_x].org_name))
      CALL logerrormessage(msg)
     ENDIF
     IF ((((requestin->list_0[mio_x].street_addr > " ")) OR ((((requestin->list_0[mio_x].street_addr2
      > " ")) OR ((((requestin->list_0[mio_x].city > " ")) OR ((((requestin->list_0[mio_x].state >
     " ")) OR (((state_cd > 0) OR ((((requestin->list_0[mio_x].zipcode > " ")) OR ((((requestin->
     list_0[mio_x].country > " ")) OR (country_cd > 0)) )) )) )) )) )) )) )
      SET new_addr = 0.0
      SELECT INTO "nl:"
       y = seq(address_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_addr = cnvtreal(y)
       WITH format, nocounter
      ;end select
      INSERT  FROM address a
       SET a.address_id = new_addr, a.parent_entity_name = "ORGANIZATION", a.parent_entity_id =
        new_org,
        a.address_type_cd = addr_bus_cd, a.address_format_cd = 0, a.contact_name = "",
        a.residence_type_cd = 0, a.comment_txt = "", a.street_addr = requestin->list_0[mio_x].
        street_addr,
        a.street_addr2 = requestin->list_0[mio_x].street_addr2, a.street_addr3 = requestin->list_0[
        mio_x].street_addr3, a.street_addr4 = requestin->list_0[mio_x].street_addr4,
        a.city = requestin->list_0[mio_x].city, a.state = requestin->list_0[mio_x].state, a.state_cd
         = state_cd,
        a.zipcode = requestin->list_0[mio_x].zipcode, a.zip_code_group_cd = 0, a.postal_barcode_info
         = "",
        a.county = "", a.county_cd = 0, a.country = requestin->list_0[mio_x].country,
        a.country_cd = country_cd, a.district_health_cd = dha_cd, a.primary_care_cd = pct_cd,
        a.residence_cd = 0, a.mail_stop = "", a.address_type_seq = 0,
        a.beg_effective_mm_dd = 0, a.end_effective_mm_dd = 0, a.contributor_system_cd = 0,
        a.data_status_cd = auth_status_cd, a.data_status_dt_tm = cnvtdatetime(curdate,curtime3), a
        .data_status_prsnl_id = reqinfo->updt_id,
        a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100"), a.active_ind = 1,
        a.active_status_cd = active_status_cd, a.active_status_prsnl_id = reqinfo->updt_id, a
        .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
        a.updt_applctx = 12758, a.updt_task = 12758
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error adding address for new org: ",trim(requestin->list_0[mio_x].org_name))
       CALL logerrormessage(msg)
      ENDIF
     ENDIF
     IF ((((requestin->list_0[mio_x].phone_num > " ")) OR ((requestin->list_0[mio_x].contact > " ")
     )) )
      SET new_phone = 0
      IF ((requestin->list_0[mio_x].phone_num > " "))
       SET phone_number = requestin->list_0[mio_x].phone_num
      ELSE
       SET phone_number = "0"
      ENDIF
      SELECT INTO "nl:"
       y = seq(phone_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_phone = cnvtreal(y)
       WITH format, nocounter
      ;end select
      INSERT  FROM phone p
       SET p.phone_id = new_phone, p.parent_entity_name = "ORGANIZATION", p.parent_entity_id =
        new_org,
        p.phone_type_cd = phone_bus_cd, p.phone_format_cd = 0.0, p.phone_num = phone_number,
        p.phone_type_seq = 1, p.description = "", p.contact = requestin->list_0[mio_x].contact,
        p.call_instruction = "", p.modem_capability_cd = 0, p.extension = "",
        p.paging_code = "", p.beg_effective_mm_dd = 0, p.end_effective_mm_dd = 0,
        p.contributor_system_cd = 0, p.data_status_cd = auth_status_cd, p.data_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        p.data_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        p.active_ind = 1, p.active_status_cd = active_status_cd, p.active_status_prsnl_id = reqinfo->
        updt_id,
        p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = 0, p.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        p.updt_id = reqinfo->updt_id, p.updt_applctx = 12758, p.updt_task = 12758
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error adding phone for new org: ",trim(requestin->list_0[mio_x].org_name))
       CALL logerrormessage(msg)
      ENDIF
     ENDIF
     IF (cnvtupper(trim(requestin->list_0[mio_x].client))="X")
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = client_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting client org type for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
     ENDIF
     IF (cnvtupper(trim(requestin->list_0[mio_x].employer))="X")
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = employer_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting employer org type for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
     ENDIF
     IF (cnvtupper(trim(requestin->list_0[mio_x].facility))="X")
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = facility_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting facility org type for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
      SET location_cd = 0.0
      SELECT INTO "nl:"
       y = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        location_cd = cnvtreal(y)
       WITH format, nocounter
      ;end select
      INSERT  FROM code_value c
       SET c.code_value = location_cd, c.code_set = 220, c.cdf_meaning = "FACILITY",
        c.display = requestin->list_0[mio_x].org_name, c.display_key = cnvtupper(cnvtalphanum(
          requestin->list_0[mio_x].org_name)), c.description = requestin->list_0[mio_x].org_name,
        c.definition = "", c.collation_seq = 0, c.active_type_cd = active_status_cd,
        c.active_ind = 1, c.active_dt_tm = cnvtdatetime(curdate,curtime3), c.inactive_dt_tm = null,
        c.active_status_prsnl_id = reqinfo->updt_id, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        c.updt_id = reqinfo->updt_id, c.updt_task = 12758, c.updt_applctx = 12758,
        c.active_ind = 1, c.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), c
        .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        c.data_status_cd = auth_status_cd, c.data_status_dt_tm = cnvtdatetime(curdate,curtime3), c
        .data_status_prsnl_id = reqinfo->updt_id
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error adding location code for org: ",trim(requestin->list_0[mio_x].org_name
         ))
       CALL logerrormessage(msg)
      ELSE
       INSERT  FROM location l
        SET l.location_cd = location_cd, l.location_type_cd = loc_facility_cd, l.organization_id =
         new_org,
         l.resource_ind = 0, l.active_ind = 1, l.active_status_cd = active_status_cd,
         l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = reqinfo->
         updt_id, l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         l.census_ind = 0, l.contributor_system_cd = 0, l.data_status_cd = auth_status_cd,
         l.data_status_dt_tm = cnvtdatetime(curdate,curtime3), l.data_status_prsnl_id = reqinfo->
         updt_id, l.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id,
         l.updt_task = 12758, l.updt_applctx = 12758, l.facility_accn_prefix_cd = 0,
         l.discipline_type_cd = 0, l.view_type_cd = 0, l.exp_lvl_cd = 0,
         l.chart_format_id = 0
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
     IF (cnvtupper(trim(requestin->list_0[mio_x].hospital))="X")
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = hospital_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting hospital org type for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
     ENDIF
     IF (cnvtupper(trim(requestin->list_0[mio_x].insco))="X")
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = insco_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting insco org type for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
     ENDIF
     IF (cnvtupper(trim(practice_val))="X"
      AND practice_org_type_cd > 0.0)
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = practice_org_type_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = 12758, o.updt_task = 12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = auth_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = 12758, o
        .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting practice org type for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
     ENDIF
     IF (cnvtupper(trim(nhstrust_val))="X"
      AND nhstrust_org_type_cd > 0.0)
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = nhstrust_org_type_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = 12758, o.updt_task = 12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = auth_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = 12758, o
        .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting nhstrust org type for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
     ENDIF
     IF (cnvtupper(trim(pct_ind_val))="X"
      AND pct_org_type_cd > 0.0)
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = pct_org_type_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = 12758, o.updt_task = 12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = auth_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = 12758, o
        .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting pct_ind org type for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
     ENDIF
     FOR (ii = 1 TO types->list[mio_x].misc_type_qual)
      SELECT INTO "nl:"
       c.code_value
       FROM code_value c
       WHERE c.code_set=278
        AND (c.cdf_meaning=types->list[mio_x].misc_types[ii].cdf_meaning)
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       DETAIL
        type_cd = c.code_value
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SELECT INTO "nl:"
        FROM org_type_reltn o
        WHERE o.org_type_cd=type_cd
         AND o.organization_id=new_org
        WITH nocounter
       ;end select
       IF (curqual=0)
        INSERT  FROM org_type_reltn o
         SET o.organization_id = new_org, o.org_type_cd = type_cd, o.updt_cnt = 0,
          o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
          12758,
          o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
          o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo
          ->updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
          o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
         WITH nocounter
        ;end insert
       ENDIF
      ENDIF
     ENDFOR
     FOR (ii = 1 TO alias_pool_holder->alias_pool_count)
      SELECT INTO "nl:"
       c.code_value
       FROM code_value c
       WHERE (c.code_set=alias_pool_holder->alias_pool_reltn[ii].alias_entity_cs)
        AND cnvtupper(c.display)=cnvtupper(alias_pool_holder->alias_pool_reltn[ii].
        alias_entity_alias_type)
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       DETAIL
        alias_pool_holder->alias_entity_alias_type_cd = c.code_value
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SELECT INTO "nl:"
        c.code_value
        FROM code_value c
        WHERE c.code_set=263
         AND cnvtupper(c.display)=cnvtupper(alias_pool_holder->alias_pool_reltn[ii].alias_pool)
         AND c.active_ind=1
         AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        DETAIL
         alias_pool_holder->alias_pool_cd = c.code_value
        WITH nocounter
       ;end select
       IF (curqual > 0)
        INSERT  FROM org_alias_pool_reltn o
         SET o.organization_id = new_org, o.alias_entity_name = alias_pool_holder->alias_pool_reltn[
          ii].alias_entity_name, o.alias_entity_alias_type_cd = alias_pool_holder->
          alias_entity_alias_type_cd,
          o.alias_pool_cd = alias_pool_holder->alias_pool_cd, o.updt_id = 12758, o.updt_cnt = 0,
          o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_task = 12758, o.updt_applctx = 12758,
          o.active_ind = 1, o.active_status_cd = auth_status_cd, o.active_status_dt_tm = cnvtdatetime
          (curdate,curtime3),
          o.active_status_prsnl_id = 12758, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o
          .end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
         WITH nocounter
        ;end insert
       ENDIF
      ENDIF
     ENDFOR
     SET parent_org_id = 0.0
     IF (parent_alias_val != 0.0)
      SELECT DISTINCT INTO "NL:"
       o.organization_id
       FROM organization o,
        organization_alias oa
       PLAN (oa
        WHERE oa.alias=parent_alias_val
         AND oa.alias_pool_cd=3769751)
        JOIN (o
        WHERE o.organization_id=oa.organization_id)
       DETAIL
        parent_org_id = o.organization_id
       WITH nocounter
      ;end select
     ENDIF
     IF (parent_org_id > 0.0)
      SELECT INTO "NL:"
       FROM org_org_reltn oor
       WHERE oor.organization_id=parent_org_id
        AND oor.org_org_reltn_cd=3606131
        AND oor.related_org_id=new_org
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET new_nbr = 0
       SELECT INTO "nl:"
        y = seq(organization_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_nbr = cnvtreal(y)
        WITH format, counter
       ;end select
       INSERT  FROM org_org_reltn oor
        SET oor.org_org_reltn_id = new_nbr, oor.organization_id = parent_org_id, oor.org_org_reltn_cd
          = 3606131,
         oor.related_org_id = new_org, oor.updt_cnt = 0, oor.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         oor.updt_id = 0.0, oor.updt_task = - (10101), oor.updt_applctx = 0.0,
         oor.active_ind = 1, oor.active_status_cd = active_code, oor.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         oor.active_status_prsnl_id = 0.0, oor.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         oor.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
         oor.comment_text = "", oor.data_status_cd = data_status_code, oor.data_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         oor.data_status_prsnl_id = 0.0, oor.contributor_system_cd = 0.0
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
     IF ((requestin->list_0[mio_x].alias_pool_disp1 > " "))
      SET alias_pool_cd = 0
      SELECT INTO "nl:"
       c.seq
       FROM code_value c
       WHERE c.code_set=263
        AND c.display_key=cnvtupper(cnvtalphanum(requestin->list_0[mio_x].alias_pool_disp1))
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       DETAIL
        alias_pool_cd = c.code_value
       WITH nocounter
      ;end select
      SET new_org_alias = 0.0
      SELECT INTO "nl:"
       y = seq(organization_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_org_alias = cnvtreal(y)
       WITH format, nocounter
      ;end select
      CALL echo(build("Alias = ",requestin->list_0[mio_x].alias1))
      INSERT  FROM org_alias_pool_reltn oapr
       SET oapr.alias_pool_cd = alias_pool_cd, oapr.organization_id = new_org, oapr.alias_entity_name
         = "ORGANIZATION_ALIAS",
        oapr.alias_entity_alias_type_cd = nhsorgalias_cd, oapr.active_ind = 1, oapr.active_status_cd
         = active_status_cd,
        oapr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), oapr.active_status_prsnl_id =
        reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), oapr.updt_cnt = 0, oapr
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        oapr.updt_id = reqinfo->updt_id, oapr.updt_applctx = reqinfo->updt_applctx, oapr.updt_task =
        reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting alias pool relation for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
      IF (baliaskey)
       INSERT  FROM organization_alias o
        SET o.organization_alias_id = new_org_alias, o.organization_id = new_org, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         12758,
         o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
         o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
         updt_id, o.alias_pool_cd = alias_pool_cd,
         o.org_alias_type_cd = org_alias_type_cd, o.alias = requestin->list_0[mio_x].alias1, o
         .alias_key = cnvtupper(trim(requestin->list_0[mio_x].alias1,3)),
         o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3),
         o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), o.data_status_cd = auth_status_cd, o
         .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
         o.data_status_prsnl_id = reqinfo->updt_id, o.contributor_system_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET msg = concat("Error adding alias ",trim(requestin->list_0[mio_x].alias1)," for org: ",
         trim(requestin->list_0[mio_x].org_name))
        CALL logerrormessage(msg)
       ENDIF
      ELSE
       INSERT  FROM organization_alias o
        SET o.organization_alias_id = new_org_alias, o.organization_id = new_org, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         12758,
         o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
         o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
         updt_id, o.alias_pool_cd = alias_pool_cd,
         o.org_alias_type_cd = org_alias_type_cd, o.alias = requestin->list_0[mio_x].alias1, o
         .check_digit = 0,
         o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o
         .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         o.data_status_cd = auth_status_cd, o.data_status_dt_tm = cnvtdatetime(curdate,curtime3), o
         .data_status_prsnl_id = reqinfo->updt_id,
         o.contributor_system_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET msg = concat("Error adding alias ",trim(requestin->list_0[mio_x].alias1)," for org: ",
         trim(requestin->list_0[mio_x].org_name))
        CALL logerrormessage(msg)
       ENDIF
      ENDIF
     ENDIF
     IF ((requestin->list_0[mio_x].alias_pool_disp2 > " "))
      SET alias_pool_cd = 0
      SELECT INTO "nl:"
       c.seq
       FROM code_value c
       WHERE c.code_set=263
        AND c.display_key=cnvtupper(cnvtalphanum(requestin->list_0[mio_x].alias_pool_disp2))
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       DETAIL
        alias_pool_cd = c.code_value
       WITH nocounter
      ;end select
      SET org_alias_type_cd = 0
      SET new_org_alias = 0.0
      SELECT INTO "nl:"
       y = seq(organization_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_org_alias = cnvtreal(y)
       WITH format, nocounter
      ;end select
      INSERT  FROM org_alias_pool_reltn oapr
       SET oapr.alias_pool_cd = alias_pool_cd, oapr.organization_id = new_org, oapr.alias_entity_name
         = "ORGANIZATION_ALIAS",
        oapr.alias_entity_alias_type_cd = nhsorgalias_cd, oapr.active_ind = 1, oapr.active_status_cd
         = active_status_cd,
        oapr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), oapr.active_status_prsnl_id =
        reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), oapr.updt_cnt = 0, oapr
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        oapr.updt_id = reqinfo->updt_id, oapr.updt_applctx = reqinfo->updt_applctx, oapr.updt_task =
        reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting alias pool relation for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
      IF (baliaskey)
       INSERT  FROM organization_alias o
        SET o.organization_alias_id = new_org_alias, o.organization_id = new_org, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         12758,
         o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
         o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
         updt_id, o.alias_pool_cd = alias_pool_cd,
         o.org_alias_type_cd = org_alias_type_cd, o.alias = requestin->list_0[mio_x].alias2, o
         .alias_key = cnvtupper(trim(requestin->list_0[mio_x].alias2,3)),
         o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3),
         o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), o.data_status_cd = auth_status_cd, o
         .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
         o.data_status_prsnl_id = reqinfo->updt_id, o.contributor_system_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET msg = concat("Error adding alias ",trim(requestin->list_0[mio_x].alias2)," for org: ",
         trim(requestin->list_0[mio_x].org_name))
        CALL logerrormessage(msg)
       ENDIF
      ELSE
       INSERT  FROM organization_alias o
        SET o.organization_alias_id = new_org_alias, o.organization_id = new_org, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         12758,
         o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
         o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
         updt_id, o.alias_pool_cd = alias_pool_cd,
         o.org_alias_type_cd = org_alias_type_cd, o.alias = requestin->list_0[mio_x].alias2, o
         .check_digit = 0,
         o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o
         .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         o.data_status_cd = auth_status_cd, o.data_status_dt_tm = cnvtdatetime(curdate,curtime3), o
         .data_status_prsnl_id = reqinfo->updt_id,
         o.contributor_system_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET msg = concat("Error adding alias ",trim(requestin->list_0[mio_x].alias2)," for org: ",
         trim(requestin->list_0[mio_x].org_name))
        CALL logerrormessage(msg)
       ENDIF
      ENDIF
     ENDIF
     IF ((requestin->list_0[mio_x].alias_pool_disp3 > " "))
      SET alias_pool_cd = 0
      SELECT INTO "nl:"
       c.seq
       FROM code_value c
       WHERE c.code_set=263
        AND c.display_key=cnvtupper(cnvtalphanum(requestin->list_0[mio_x].alias_pool_disp3))
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       DETAIL
        alias_pool_cd = c.code_value
       WITH nocounter
      ;end select
      SET new_org_alias = 0.0
      SELECT INTO "nl:"
       y = seq(organization_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_org_alias = cnvtreal(y)
       WITH format, nocounter
      ;end select
      INSERT  FROM org_alias_pool_reltn oapr
       SET oapr.alias_pool_cd = alias_pool_cd, oapr.organization_id = new_org, oapr.alias_entity_name
         = "ORGANIZATION_ALIAS",
        oapr.alias_entity_alias_type_cd = nhsorgalias_cd, oapr.active_ind = 1, oapr.active_status_cd
         = active_status_cd,
        oapr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), oapr.active_status_prsnl_id =
        reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), oapr.updt_cnt = 0, oapr
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        oapr.updt_id = reqinfo->updt_id, oapr.updt_applctx = reqinfo->updt_applctx, oapr.updt_task =
        reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting alias pool relation for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
      IF (baliaskey)
       INSERT  FROM organization_alias o
        SET o.organization_alias_id = new_org_alias, o.organization_id = new_org, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         12758,
         o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
         o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
         updt_id, o.alias_pool_cd = alias_pool_cd,
         o.org_alias_type_cd = org_alias_type_cd, o.alias = requestin->list_0[mio_x].alias3, o
         .alias_key = cnvtupper(trim(requestin->list_0[mio_x].alias3,3)),
         o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3),
         o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), o.data_status_cd = auth_status_cd, o
         .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
         o.data_status_prsnl_id = reqinfo->updt_id, o.contributor_system_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET msg = concat("Error adding alias ",trim(requestin->list_0[mio_x].alias3)," for org: ",
         trim(requestin->list_0[mio_x].org_name))
        CALL logerrormessage(msg)
       ENDIF
      ELSE
       INSERT  FROM organization_alias o
        SET o.organization_alias_id = new_org_alias, o.organization_id = new_org, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         12758,
         o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
         o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
         updt_id, o.alias_pool_cd = alias_pool_cd,
         o.org_alias_type_cd = org_alias_type_cd, o.alias = requestin->list_0[mio_x].alias3, o
         .check_digit = 0,
         o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o
         .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         o.data_status_cd = auth_status_cd, o.data_status_dt_tm = cnvtdatetime(curdate,curtime3), o
         .data_status_prsnl_id = reqinfo->updt_id,
         o.contributor_system_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET msg = concat("Error adding alias ",trim(requestin->list_0[mio_x].alias3)," for org: ",
         trim(requestin->list_0[mio_x].org_name))
        CALL logerrormessage(msg)
       ENDIF
      ENDIF
     ENDIF
     IF ((requestin->list_0[mio_x].alias_pool_disp4 > " "))
      SET alias_pool_cd = 0
      SELECT INTO "nl:"
       c.seq
       FROM code_value c
       WHERE c.code_set=263
        AND c.display_key=cnvtupper(cnvtalphanum(requestin->list_0[mio_x].alias_pool_disp4))
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       DETAIL
        alias_pool_cd = c.code_value
       WITH nocounter
      ;end select
      SET new_org_alias = 0.0
      SELECT INTO "nl:"
       y = seq(organization_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_org_alias = cnvtreal(y)
       WITH format, nocounter
      ;end select
      INSERT  FROM org_alias_pool_reltn oapr
       SET oapr.alias_pool_cd = alias_pool_cd, oapr.organization_id = new_org, oapr.alias_entity_name
         = "ORGANIZATION_ALIAS",
        oapr.alias_entity_alias_type_cd = nhsorgalias_cd, oapr.active_ind = 1, oapr.active_status_cd
         = active_status_cd,
        oapr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), oapr.active_status_prsnl_id =
        reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), oapr.updt_cnt = 0, oapr
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        oapr.updt_id = reqinfo->updt_id, oapr.updt_applctx = reqinfo->updt_applctx, oapr.updt_task =
        reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting alias pool relation for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
      IF (baliaskey)
       INSERT  FROM organization_alias o
        SET o.organization_alias_id = new_org_alias, o.organization_id = new_org, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         12758,
         o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
         o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
         updt_id, o.alias_pool_cd = alias_pool_cd,
         o.org_alias_type_cd = org_alias_type_cd, o.alias = requestin->list_0[mio_x].alias4, o
         .alias_key = cnvtupper(trim(requestin->list_0[mio_x].alias4,3)),
         o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3),
         o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), o.data_status_cd = auth_status_cd, o
         .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
         o.data_status_prsnl_id = reqinfo->updt_id, o.contributor_system_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET msg = concat("Error adding alias ",trim(requestin->list_0[mio_x].alias4)," for org: ",
         trim(requestin->list_0[mio_x].org_name))
        CALL logerrormessage(msg)
       ENDIF
      ELSE
       INSERT  FROM organization_alias o
        SET o.organization_alias_id = new_org_alias, o.organization_id = new_org, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         12758,
         o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
         o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
         updt_id, o.alias_pool_cd = alias_pool_cd,
         o.org_alias_type_cd = org_alias_type_cd, o.alias = requestin->list_0[mio_x].alias4, o
         .check_digit = 0,
         o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o
         .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         o.data_status_cd = auth_status_cd, o.data_status_dt_tm = cnvtdatetime(curdate,curtime3), o
         .data_status_prsnl_id = reqinfo->updt_id,
         o.contributor_system_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET msg = concat("Error adding alias ",trim(requestin->list_0[mio_x].alias4)," for org: ",
         trim(requestin->list_0[mio_x].org_name))
        CALL logerrormessage(msg)
       ENDIF
      ENDIF
     ENDIF
     IF ((requestin->list_0[mio_x].alias_pool_disp5 > " "))
      SET alias_pool_cd = 0
      SELECT INTO "nl:"
       c.seq
       FROM code_value c
       WHERE c.code_set=263
        AND c.display_key=cnvtupper(cnvtalphanum(requestin->list_0[mio_x].alias_pool_disp5))
        AND c.active_ind=1
        AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       DETAIL
        alias_pool_cd = c.code_value
       WITH nocounter
      ;end select
      SET new_org_alias = 0.0
      SELECT INTO "nl:"
       y = seq(organization_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_org_alias = cnvtreal(y)
       WITH format, nocounter
      ;end select
      INSERT  FROM org_alias_pool_reltn oapr
       SET oapr.alias_pool_cd = alias_pool_cd, oapr.organization_id = new_org, oapr.alias_entity_name
         = "ORGANIZATION_ALIAS",
        oapr.alias_entity_alias_type_cd = nhsorgalias_cd, oapr.active_ind = 1, oapr.active_status_cd
         = active_status_cd,
        oapr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), oapr.active_status_prsnl_id =
        reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), oapr.updt_cnt = 0, oapr
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        oapr.updt_id = reqinfo->updt_id, oapr.updt_applctx = reqinfo->updt_applctx, oapr.updt_task =
        reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET msg = concat("Error setting alias pool relation for org: ",trim(requestin->list_0[mio_x].
         org_name))
       CALL logerrormessage(msg)
      ENDIF
      IF (baliaskey)
       INSERT  FROM organization_alias o
        SET o.organization_alias_id = new_org_alias, o.organization_id = new_org, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         12758,
         o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
         o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
         updt_id, o.alias_pool_cd = alias_pool_cd,
         o.org_alias_type_cd = org_alias_type_cd, o.alias = requestin->list_0[mio_x].alias5, o
         .alias_key = cnvtupper(trim(requestin->list_0[mio_x].alias5,3)),
         o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3),
         o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), o.data_status_cd = auth_status_cd, o
         .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
         o.data_status_prsnl_id = reqinfo->updt_id, o.contributor_system_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET msg = concat("Error adding alias ",trim(requestin->list_0[mio_x].alias5)," for org: ",
         trim(requestin->list_0[mio_x].org_name))
        CALL logerrormessage(msg)
       ENDIF
      ELSE
       INSERT  FROM organization_alias o
        SET o.organization_alias_id = new_org_alias, o.organization_id = new_org, o.updt_cnt = 0,
         o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
         12758,
         o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
         o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
         updt_id, o.alias_pool_cd = alias_pool_cd,
         o.org_alias_type_cd = org_alias_type_cd, o.alias = requestin->list_0[mio_x].alias5, o
         .check_digit = 0,
         o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o
         .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         o.data_status_cd = auth_status_cd, o.data_status_dt_tm = cnvtdatetime(curdate,curtime3), o
         .data_status_prsnl_id = reqinfo->updt_id,
         o.contributor_system_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET msg = concat("Error adding alias ",trim(requestin->list_0[mio_x].alias5)," for org: ",
         trim(requestin->list_0[mio_x].org_name))
        CALL logerrormessage(msg)
       ENDIF
      ENDIF
     ENDIF
     IF ((requestin->list_0[mio_x].comments > " "))
      SET new_org_info = 0.0
      SET new_long_text = 0.0
      SELECT INTO "nl:"
       y = seq(organization_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_org_info = cnvtreal(y)
       WITH format, nocounter
      ;end select
      SELECT INTO "nl:"
       y = seq(long_data_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_long_text = cnvtreal(y)
       WITH format, nocounter
      ;end select
      INSERT  FROM org_info o
       SET o.org_info_id = new_org_info, o.organization_id = new_org, o.info_type_cd = comment_cd,
        o.info_sub_type_cd = 0, o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        o.updt_id = reqinfo->updt_id, o.updt_task = 12758, o.updt_applctx = 12758,
        o.active_ind = 1, o.active_status_cd = active_status_cd, o.active_status_dt_tm = cnvtdatetime
        (curdate,curtime3),
        o.active_status_prsnl_id = reqinfo->updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3), o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        o.long_text_id = new_long_text, o.value_numeric = 0, o.value_dt_tm = null,
        o.chartable_ind = 0, o.contributor_system_cd = 0
       WITH nocounter
      ;end insert
      IF (long_text_reference_ind)
       INSERT  FROM long_text_reference l
        SET l.long_text_id = new_long_text, l.parent_entity_name = "ORG_INFO", l.parent_entity_id =
         new_org_info,
         l.long_text = requestin->list_0[mio_x].comments, l.active_ind = 1, l.active_status_cd =
         active_status_cd,
         l.active_status_prsnl_id = reqinfo->updt_id, l.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), l.updt_cnt = 0,
         l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_applctx
          = 12758,
         l.updt_task = 12758
        WITH nocounter
       ;end insert
      ELSE
       INSERT  FROM long_text l
        SET l.long_text_id = new_long_text, l.parent_entity_name = "ORG_INFO", l.parent_entity_id =
         new_org_info,
         l.long_text = requestin->list_0[mio_x].comments, l.active_ind = 1, l.active_status_cd =
         active_status_cd,
         l.active_status_prsnl_id = reqinfo->updt_id, l.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), l.updt_cnt = 0,
         l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_applctx
          = 12758,
         l.updt_task = 12758
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
    ENDIF
   ELSE
    UPDATE  FROM organization o
     SET o.org_name = requestin->list_0[mio_x].org_name, o.org_name_key = cnvtupper(cnvtalphanum(
        requestin->list_0[mio_x].org_name)), o.beg_effective_dt_tm =
      IF (beg_date_val <= " ") o.beg_effective_dt_tm
      ELSE cnvtdatetime(beg_date_val)
      ENDIF
      ,
      o.end_effective_dt_tm =
      IF (end_date_val <= " ") o.end_effective_dt_tm
      ELSE cnvtdatetime(end_date_val)
      ENDIF
      , o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt+ 1),
      o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_id = reqinfo->updt_id, o.updt_task =
      reqinfo->updt_task
     WHERE o.organization_id=org_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET msg = concat("Error updating org ",trim(requestin->list_0[mio_x].org_name)," with org id = ",
      org_id)
     CALL logerrormessage(msg)
    ENDIF
    SET dha_cd = 0.0
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=29881
      AND c.cdf_meaning=trim(dha_mean_val)
      AND c.active_ind=1
      AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     DETAIL
      dha_cd = c.code_value
     WITH nocounter
    ;end select
    IF (dha_cd=0.0
     AND trim(dha_mean_val) != "")
     SET msg = concat("dha code '",trim(dha_mean_val),"'not found on code set 29881 to update org: ",
      trim(requestin->list_0[mio_x].org_name),".  DHA code: ",
      dha_mean_val)
     CALL logerrormessage(msg)
    ENDIF
    SET pct_cd = 0.0
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=29880
      AND c.cdf_meaning=trim(pct_mean_val)
      AND c.active_ind=1
      AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     DETAIL
      pct_cd = c.code_value
     WITH nocounter
    ;end select
    IF (pct_cd=0.0
     AND trim(pct_mean_val) != "")
     SET msg = concat("dha code '",trim(pct_mean_val),"'not found on code set 29880 to update org: ",
      trim(requestin->list_0[mio_x].org_name),".  PCT code: ",
      pct_mean_val)
     CALL logerrormessage(msg)
    ENDIF
    UPDATE  FROM address a
     SET a.street_addr = requestin->list_0[mio_x].street_addr, a.street_addr2 = requestin->list_0[
      mio_x].street_addr2, a.street_addr3 = requestin->list_0[mio_x].street_addr3,
      a.street_addr4 = requestin->list_0[mio_x].street_addr4, a.city = requestin->list_0[mio_x].city,
      a.state = requestin->list_0[mio_x].state_disp,
      a.zipcode = requestin->list_0[mio_x].zipcode, a.district_health_cd = dha_cd, a.primary_care_cd
       = pct_cd,
      a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task
     WHERE a.parent_entity_name="ORGANIZATION"
      AND a.parent_entity_id=org_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET new_addr = 0.0
     SELECT INTO "nl:"
      y = seq(address_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_addr = cnvtreal(y)
      WITH format, nocounter
     ;end select
     INSERT  FROM address a
      SET a.address_id = new_addr, a.parent_entity_name = "ORGANIZATION", a.parent_entity_id = org_id,
       a.address_type_cd = addr_bus_cd, a.address_format_cd = 0, a.contact_name = "",
       a.residence_type_cd = 0, a.comment_txt = "", a.street_addr = requestin->list_0[mio_x].
       street_addr,
       a.street_addr2 = requestin->list_0[mio_x].street_addr2, a.street_addr3 = requestin->list_0[
       mio_x].street_addr3, a.street_addr4 = requestin->list_0[mio_x].street_addr4,
       a.city = requestin->list_0[mio_x].city, a.state = requestin->list_0[mio_x].state, a.state_cd
        = state_cd,
       a.zipcode = requestin->list_0[mio_x].zipcode, a.zip_code_group_cd = 0, a.postal_barcode_info
        = "",
       a.county = "", a.county_cd = 0, a.country = requestin->list_0[mio_x].country,
       a.country_cd = country_cd, a.district_health_cd = dha_cd, a.primary_care_cd = pct_cd,
       a.residence_cd = 0, a.mail_stop = "", a.address_type_seq = 0,
       a.beg_effective_mm_dd = 0, a.end_effective_mm_dd = 0, a.contributor_system_cd = 0,
       a.data_status_cd = auth_status_cd, a.data_status_dt_tm = cnvtdatetime(curdate,curtime3), a
       .data_status_prsnl_id = reqinfo->updt_id,
       a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100"), a.active_ind = 1,
       a.active_status_cd = active_status_cd, a.active_status_prsnl_id = reqinfo->updt_id, a
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
       a.updt_applctx = 12758, a.updt_task = 12758
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET msg = concat("Error adding address for new org: ",trim(requestin->list_0[mio_x].org_name))
      CALL logerrormessage(msg)
     ENDIF
    ENDIF
    UPDATE  FROM phone p
     SET p.phone_num = requestin->list_0[mio_x].phone_num, p.updt_applctx = reqinfo->updt_applctx, p
      .updt_cnt = (p.updt_cnt+ 1),
      p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = reqinfo->updt_id, p.updt_task =
      reqinfo->updt_task
     WHERE p.parent_entity_name="ORGANIZATION"
      AND p.parent_entity_id=org_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET new_phone = 0
     IF ((requestin->list_0[mio_x].phone_num > " "))
      SET phone_number = requestin->list_0[mio_x].phone_num
     ELSE
      SET phone_number = "0"
     ENDIF
     SELECT INTO "nl:"
      y = seq(phone_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_phone = cnvtreal(y)
      WITH format, nocounter
     ;end select
     INSERT  FROM phone p
      SET p.phone_id = new_phone, p.parent_entity_name = "ORGANIZATION", p.parent_entity_id = org_id,
       p.phone_type_cd = phone_bus_cd, p.phone_format_cd = 0.0, p.phone_num = phone_number,
       p.phone_type_seq = 1, p.description = "", p.contact = requestin->list_0[mio_x].contact,
       p.call_instruction = "", p.modem_capability_cd = 0, p.extension = "",
       p.paging_code = "", p.beg_effective_mm_dd = 0, p.end_effective_mm_dd = 0,
       p.contributor_system_cd = 0, p.data_status_cd = auth_status_cd, p.data_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.data_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       p.active_ind = 1, p.active_status_cd = active_status_cd, p.active_status_prsnl_id = reqinfo->
       updt_id,
       p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = 0, p.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.updt_id = reqinfo->updt_id, p.updt_applctx = 12758, p.updt_task = 12758
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET msg = concat("Error adding phone for updated org: ",trim(requestin->list_0[mio_x].org_name)
       )
      CALL logerrormessage(msg)
     ENDIF
    ENDIF
    IF ((requestin->list_0[mio_x].client=" "))
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      WHERE otr.organization_id=org_id
       AND otr.org_type_cd=client_cd
       AND otr.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      UPDATE  FROM org_type_reltn otr
       SET otr.active_ind = 0, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
        .updt_cnt = (otr.updt_cnt+ 1),
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr.updt_task
         = reqinfo->updt_task
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=client_cd
        AND otr.active_ind=1
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    IF (cnvtupper(trim(requestin->list_0[mio_x].client))="X")
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      PLAN (otr
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=client_cd)
      DETAIL
       active_row = otr.active_ind
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = client_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
     ELSE
      IF (active_row=0)
       UPDATE  FROM org_type_reltn otr
        SET otr.active_ind = 1, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
         cnvtdatetime(curdate,curtime),
         otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
         .updt_cnt = (otr.updt_cnt+ 1),
         otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr
         .updt_task = reqinfo->updt_task
        WHERE otr.organization_id=org_id
         AND otr.org_type_cd=client_cd
         AND otr.active_ind=1
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
    ENDIF
    IF ((requestin->list_0[mio_x].employer=" "))
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      WHERE otr.organization_id=org_id
       AND otr.org_type_cd=employer_cd
       AND otr.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      UPDATE  FROM org_type_reltn otr
       SET otr.active_ind = 0, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
        .updt_cnt = (otr.updt_cnt+ 1),
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr.updt_task
         = reqinfo->updt_task
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=employer_cd
        AND otr.active_ind=1
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    IF (cnvtupper(trim(requestin->list_0[mio_x].employer))="X")
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      PLAN (otr
       WHERE otr.organization_id_id=org_id
        AND otr.org_type_cd=employer_cd)
      DETAIL
       active_row = otr.active_ind
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = employer_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
     ELSE
      IF (active_row=0)
       UPDATE  FROM org_type_reltn otr
        SET otr.active_ind = 1, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
         cnvtdatetime(curdate,curtime),
         otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
         .updt_cnt = (otr.updt_cnt+ 1),
         otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr
         .updt_task = reqinfo->updt_task
        WHERE otr.organization_id=org_id
         AND otr.org_type_cd=employer_cd
         AND otr.active_ind=1
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
    ENDIF
    IF ((requestin->list_0[mio_x].hospital=" "))
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      WHERE otr.organization_id=org_id
       AND otr.org_type_cd=hospital_cd
       AND otr.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      UPDATE  FROM org_type_reltn otr
       SET otr.active_ind = 0, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
        .updt_cnt = (otr.updt_cnt+ 1),
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr.updt_task
         = reqinfo->updt_task
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=hospital_cd
        AND otr.active_ind=1
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    IF (cnvtupper(trim(requestin->list_0[mio_x].hospital))="X")
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      PLAN (otr
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=hospital_cd)
      DETAIL
       active_row = otr.active_ind
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = hospital_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
     ELSE
      IF (active_row=0)
       UPDATE  FROM org_type_reltn otr
        SET otr.active_ind = 1, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
         cnvtdatetime(curdate,curtime),
         otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
         .updt_cnt = (otr.updt_cnt+ 1),
         otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr
         .updt_task = reqinfo->updt_task
        WHERE otr.organization_id=org_id
         AND otr.org_type_cd=hospital_cd
         AND otr.active_ind=1
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
    ENDIF
    IF ((requestin->list_0[mio_x].insco=" "))
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      WHERE otr.organization_id=org_id
       AND otr.org_type_cd=insco_cd
       AND otr.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      UPDATE  FROM org_type_reltn otr
       SET otr.active_ind = 0, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
        .updt_cnt = (otr.updt_cnt+ 1),
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr.updt_task
         = reqinfo->updt_task
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=insco_cd
        AND otr.active_ind=1
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    IF (cnvtupper(trim(requestin->list_0[mio_x].insco))="X")
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      PLAN (otr
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=insco_cd)
      DETAIL
       active_row = otr.active_ind
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = insco_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
     ELSE
      IF (active_row=0)
       UPDATE  FROM org_type_reltn otr
        SET otr.active_ind = 1, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
         cnvtdatetime(curdate,curtime),
         otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
         .updt_cnt = (otr.updt_cnt+ 1),
         otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr
         .updt_task = reqinfo->updt_task
        WHERE otr.organization_id=org_id
         AND otr.org_type_cd=insco_cd
         AND otr.active_ind=1
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
    ENDIF
    IF (nhstrust_val=" ")
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      WHERE otr.organization_id=org_id
       AND otr.org_type_cd=nhstrust_org_type_cd
       AND otr.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      UPDATE  FROM org_type_reltn otr
       SET otr.active_ind = 0, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
        .updt_cnt = (otr.updt_cnt+ 1),
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr.updt_task
         = reqinfo->updt_task
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=nhstrust_org_type_cd
        AND otr.active_ind=1
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    IF (cnvtupper(trim(nhstrust_val))="X")
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      PLAN (otr
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=nhstrust_org_type_cd)
      DETAIL
       active_row = otr.active_ind
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = nhstrust_org_type_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
     ELSE
      IF (active_row=0)
       UPDATE  FROM org_type_reltn otr
        SET otr.active_ind = 1, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
         cnvtdatetime(curdate,curtime),
         otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
         .updt_cnt = (otr.updt_cnt+ 1),
         otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr
         .updt_task = reqinfo->updt_task
        WHERE otr.organization_id=org_id
         AND otr.org_type_cd=nhstrust_org_type_cd
         AND otr.active_ind=1
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
    ENDIF
    IF (practice_val=" ")
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      WHERE otr.organization_id=org_id
       AND otr.org_type_cd=practice_org_type_cd
       AND otr.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      UPDATE  FROM org_type_reltn otr
       SET otr.active_ind = 0, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
        .updt_cnt = (otr.updt_cnt+ 1),
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr.updt_task
         = reqinfo->updt_task
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=practice_org_type_cd
        AND otr.active_ind=1
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    IF (cnvtupper(trim(practice_val))="X")
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      PLAN (otr
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=practice_org_type_cd)
      DETAIL
       active_row = otr.active_ind
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = practice_org_type_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
     ELSE
      IF (active_row=0)
       UPDATE  FROM org_type_reltn otr
        SET otr.active_ind = 1, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
         cnvtdatetime(curdate,curtime),
         otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
         .updt_cnt = (otr.updt_cnt+ 1),
         otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr
         .updt_task = reqinfo->updt_task
        WHERE otr.organization_id=org_id
         AND otr.org_type_cd=practice_org_type_cd
         AND otr.active_ind=1
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
    ENDIF
    IF (pct_ind_val=" ")
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      WHERE otr.organization_id=org_id
       AND otr.org_type_cd=pct_org_type_cd
       AND otr.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      UPDATE  FROM org_type_reltn otr
       SET otr.active_ind = 0, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
        .updt_cnt = (otr.updt_cnt+ 1),
        otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr.updt_task
         = reqinfo->updt_task
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=pct_org_type_cd
        AND otr.active_ind=1
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    IF (cnvtupper(trim(pct_ind_val))="X")
     SELECT INTO "nl:"
      FROM org_type_reltn otr
      PLAN (otr
       WHERE otr.organization_id=org_id
        AND otr.org_type_cd=pct_org_type_cd)
      DETAIL
       active_row = otr.active_ind
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM org_type_reltn o
       SET o.organization_id = new_org, o.org_type_cd = pct_org_type_cd, o.updt_cnt = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
        12758,
        o.updt_applctx = 12758, o.active_ind = 1, o.active_status_cd = active_status_cd,
        o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
        updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
     ELSE
      IF (active_row=0)
       UPDATE  FROM org_type_reltn otr
        SET otr.active_ind = 1, otr.active_status_cd = inactive_status_cd, otr.active_status_dt_tm =
         cnvtdatetime(curdate,curtime),
         otr.active_status_prsnl_id = reqinfo->updt_id, otr.updt_applctx = reqinfo->updt_applctx, otr
         .updt_cnt = (otr.updt_cnt+ 1),
         otr.updt_dt_tm = cnvtdatetime(curdate,curtime), otr.updt_id = reqinfo->updt_id, otr
         .updt_task = reqinfo->updt_task
        WHERE otr.organization_id=org_id
         AND otr.org_type_cd=pct_org_type_cd
         AND otr.active_ind=1
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 GO TO 9999_end
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE ce_flag = i4
   SET ce_flag = 0
   DECLARE ce_temp = vc WITH noconstant("")
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET ce_flag = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(ce_flag)
 END ;Subroutine
 SUBROUTINE logerrormessage(msg)
   SELECT INTO "ccluserdir:bed_org_uk_error.log"
    rvar
    DETAIL
     row + 1, col 0, msg
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 300, maxrow = 1
   ;end select
 END ;Subroutine
#9999_end
END GO

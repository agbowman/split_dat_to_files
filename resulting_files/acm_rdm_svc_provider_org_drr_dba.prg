CREATE PROGRAM acm_rdm_svc_provider_org_drr:dba
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
 DECLARE drr_table_and_ccldef_exists(null) = i2
 IF (validate(drr_validate_table->table_name,"X")="X"
  AND validate(drr_validate_table->table_name,"Z")="Z")
  FREE RECORD drr_validate_table
  RECORD drr_validate_table(
    1 msg_returned = vc
    1 list[*]
      2 table_name = vc
      2 status = i2
  )
 ENDIF
 SUBROUTINE drr_table_and_ccldef_exists(null)
   DECLARE dtc_table_num = i4 WITH protect, noconstant(0)
   DECLARE dtc_table_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_ccldef_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_no_ccldef = vc WITH protect, noconstant("")
   DECLARE dtc_no_table = vc WITH protect, noconstant("")
   DECLARE dtc_errmsg = vc WITH protect, noconstant("")
   SET dtc_table_num = size(drr_validate_table->list,5)
   IF (dtc_table_num=0)
    SET drr_validate_table->msg_returned = concat(
     "No table specified in DRR_VALIDATE_TABLE record structure.")
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut,
     (dummyt d  WITH seq = value(dtc_table_num))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (ut
     WHERE ut.table_name=trim(cnvtupper(drr_validate_table->list[d.seq].table_name)))
    DETAIL
     dtc_table_cnt += 1, drr_validate_table->list[d.seq].status = 1
    WITH nocounter
   ;end select
   IF (error(dtc_errmsg,0) != 0)
    SET drr_validate_table->msg_returned = concat("Select for table existence failed: ",dtc_errmsg)
    RETURN(- (1))
   ELSEIF (dtc_table_cnt=0)
    SET drr_validate_table->msg_returned = concat("No DRR tables found")
    RETURN(0)
   ENDIF
   IF (dtc_table_cnt < dtc_table_num)
    FOR (i = 1 TO dtc_table_num)
      IF ((drr_validate_table->list[i].status=0))
       SET dtc_no_table = concat(dtc_no_table," ",drr_validate_table->list[i].table_name)
      ENDIF
    ENDFOR
    SET drr_validate_table->msg_returned = concat("Missing table",dtc_no_table)
    RETURN(dtc_table_cnt)
   ENDIF
   FOR (i = 1 TO dtc_table_num)
     IF (checkdic(cnvtupper(drr_validate_table->list[i].table_name),"T",0) != 2)
      SET dtc_no_ccldef = concat(dtc_no_ccldef," ",drr_validate_table->list[i].table_name)
      SET drr_validate_table->list[i].status = 0
     ELSE
      SET dtc_ccldef_cnt += 1
     ENDIF
   ENDFOR
   IF (dtc_ccldef_cnt < dtc_table_num)
    SET drr_validate_table->msg_returned = concat("CCL definition missing for ",dtc_no_ccldef)
    RETURN(dtc_ccldef_cnt)
   ENDIF
   RETURN(dtc_table_cnt)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = concat("FAILED STARTING README ",cnvtstring(readme_data->readme_id))
 DECLARE ms_errmsg = vc WITH protect, noconstant("")
 DECLARE dcareunitcd = f8 WITH protect, noconstant(0.0)
 CALL echo("Processing... ACM_RDM_SVC_PROVIDER_ORG_DRR")
 CALL echo("")
 SET stat = alterlist(drr_validate_table->list,1)
 SET drr_validate_table->list[1].table_name = "ENCOUNTER0077DRR"
 IF (drr_table_and_ccldef_exists(null) != 0
  AND drr_table_and_ccldef_exists(null) != 1)
  SET readme_data->status = "F"
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_program
 ELSEIF (drr_table_and_ccldef_exists(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="CAREUNIT"
   AND cv.code_set=278
   AND cv.active_ind=1
  ORDER BY cv.begin_effective_dt_tm
  DETAIL
   dcareunitcd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Error selecting the CDF_MEANING from CODE_VALUE table for CODE_SET 278: ",ms_errmsg)
  GO TO exit_program
 ENDIF
 SET cmd = concat(" rdb update encounter0077drr e "," set e.service_provider_org_id = "," case ",
  " when e.chart_access_organization_id > 0 and ",cnvtstring(dcareunitcd),
  " in "," (select org_type_cd from org_type_reltn o where ",
  " o.organization_id = e.chart_access_organization_id and o.active_ind = 1 ",
  " and exists (select 1 from organization org "," where org.organization_id = o.organization_id)) ",
  " then e.chart_access_organization_id ",
  " when e.loc_facility_cd > 0 and (select organization_id from location l where ",
  " l.location_cd = e.loc_facility_cd and l.active_ind = 1 ",
  " and exists (select 1 from organization org ",
  " where org.organization_id = l.organization_id)) > 0 ",
  " then (select l.organization_id from location l where ",
  " l.location_cd = e.loc_facility_cd and l.active_ind = 1) "," when e.organization_id > 0 ",
  " and exists (select 1 from organization org "," where org.organization_id = e.organization_id) ",
  " then e.organization_id "," else 0 "," asis(^ end ^) "," where ",
  " e.service_provider_org_id <= 0 or e.service_provider_org_id is null go")
 CALL parser(cmd)
 IF (error(ms_errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error occured when updating encounter0077drr.",ms_errmsg)
  GO TO exit_program
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme completed successfully"
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

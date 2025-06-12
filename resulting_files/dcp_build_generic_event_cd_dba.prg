CREATE PROGRAM dcp_build_generic_event_cd:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET child_failed = "F"
 SET description = "DCP Generic Code"
 SET tmp_cdfmeaning = "DCPGENERIC"
 SET count1 = 0
 SET count = 0
 SET count2 = 0
 SET next_code_value = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET alias = "DCPGENERIC"
 SET tmp_dispcdkey = "DCPGENERICCODE"
 SET activecd = 0.0
 SET authorizecd = 0.0
 SET unknown23 = 0.0
 SET unknown25 = 0.0
 SET unknown53 = 0.0
 SET unknown102 = 0.0
 SET routeclinical = 0.0
 SET contributor = 0.0
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.alias=alias
   AND cva.code_set=72
  DETAIL
   count = (count+ 1)
  WITH nocounter
 ;end select
 IF (count=0)
  SET code_set = 8
  SET cdf_meaning = "AUTH"
  EXECUTE cpm_get_cd_for_cdf
  SET authorizecd = code_value
  SET code_set = 48
  SET cdf_meaning = "ACTIVE"
  EXECUTE cpm_get_cd_for_cdf
  SET activecd = code_value
  SET code_set = 23
  SET cdf_meaning = "UNKNOWN"
  EXECUTE cpm_get_cd_for_cdf
  SET unknown23 = code_value
  SET code_set = 25
  SET cdf_meaning = "UNKNOWN"
  EXECUTE cpm_get_cd_for_cdf
  SET unknown25 = code_value
  SET code_set = 53
  SET cdf_meaning = "UNKNOWN"
  EXECUTE cpm_get_cd_for_cdf
  SET unknown53 = code_value
  SET code_set = 102
  SET cdf_meaning = "UNKNOWN"
  EXECUTE cpm_get_cd_for_cdf
  SET unknown102 = code_value
  SET code_set = 87
  SET cdf_meaning = "ROUTCLINICAL"
  EXECUTE cpm_get_cd_for_cdf
  SET routeclinical = code_value
  SET code_set = 73
  SET cdf_meaning = "POWERCHART"
  EXECUTE cpm_get_cd_for_cdf
  SET contributor = code_value
  SELECT INTO "nl:"
   cdf.cdf_meaning
   FROM common_data_foundation cdf
   WHERE cdf.cdf_meaning=tmp_cdfmeaning
    AND cdf.code_set=72
   DETAIL
    count1 = (count1+ 1)
   WITH nocounter
  ;end select
  IF (count1=0)
   INSERT  FROM common_data_foundation c
    SET c.code_set = 72, c.cdf_meaning = tmp_cdfmeaning, c.display = tmp_cdfmeaning,
     c.definition = tmp_cdfmeaning, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = 1,
     c.updt_task = 0, c.updt_applctx = 0, c.updt_cnt = 0
    WITH nocounter
   ;end insert
  ENDIF
  SET count1 = 0
  SELECT INTO "nl:"
   cv.code_set, cv.cdf_meaning, cv.definition,
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=72
    AND cv.cdf_meaning=tmp_cdfmeaning
   DETAIL
    count1 = (count1+ 1), next_code_value = cv.code_value
   WITH nocounter
  ;end select
  IF (count1=0)
   SET count1 = 0
   SELECT INTO "nl:"
    v.event_cd
    FROM v500_event_code v
    WHERE v.event_cd_disp_key=tmp_dispcdkey
    DETAIL
     count1 = (count1+ 1), next_code_value = v.event_cd
    WITH nocounter
   ;end select
  ENDIF
  IF (count1=0)
   SELECT INTO "nl:"
    newseq_ec = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     next_code_value = cnvtint(newseq_ec)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET readme_data->status = "F"
    SET readme_data->message = build("PVReadMe 1104:select on dual failed!")
    EXECUTE dm_readme_status
    COMMIT
    SET child_failed = "T"
    GO TO exit_script
   ENDIF
   INSERT  FROM code_value cv
    SET cv.code_set = 72, cv.code_value = next_code_value, cv.cdf_meaning = tmp_cdfmeaning,
     cv.display = description, cv.description = cnvtupper(description), cv.display_key = cnvtalphanum
     (cnvtupper(description)),
     cv.definition = cnvtupper(description), cv.collation_seq = 0, cv.active_type_cd = activecd,
     cv.active_dt_tm = null, cv.inactive_dt_tm = null, cv.active_status_prsnl_id = 0,
     cv.active_ind = 1, cv.data_status_prsnl_id = 0, cv.updt_cnt = 0,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id = 0, cv.updt_task = 0,
     cv.updt_applctx = 0, cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime), cv
     .end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
     cv.data_status_cd = authorizecd, cv.data_status_dt_tm = null, cv.data_status_prsnl_id = 0
    WITH counter
   ;end insert
   IF (curqual=0)
    SET child_failed = "T"
    SET readme_data->status = "F"
    SET readme_data->message = build("PVReadMe 1104:Can't insert into code_set 72!")
    EXECUTE dm_readme_status
    COMMIT
    GO TO exit_script
   ENDIF
   INSERT  FROM v500_event_code v
    SET v.event_cd = next_code_value, v.event_cd_definition = description, v.event_cd_descr =
     cnvtupper(description),
     v.event_cd_disp = cnvtupper(description), v.event_cd_disp_key = cnvtalphanum(cnvtupper(
       tmp_dispcdkey)), v.code_status_cd = activecd,
     v.def_docmnt_attributes = " ", v.def_docmnt_format_cd = unknown23, v.def_docmnt_storage_cd =
     unknown25,
     v.def_event_class_cd = unknown53, v.def_event_confid_level_cd = routeclinical, v.def_event_level
      = 0,
     v.event_add_access_ind = 0, v.event_cd_subclass_cd = unknown102, v.event_chg_access_ind = 0,
     v.event_set_name = null, v.retention_days = 0, v.updt_applctx = 0,
     v.updt_cnt = 0, v.updt_dt_tm = cnvtdatetime(curdate,curtime), v.updt_id = 0,
     v.updt_task = 0, v.event_code_status_cd = authorizecd
    WITH counter
   ;end insert
   IF (curqual=0)
    SET child_failed = "T"
    SET readme_data->status = "F"
    SET readme_data->message = build("PVReadMe 1104:Failed inserting into v_500_event_code!")
    EXECUTE dm_readme_status
    COMMIT
    GO TO exit_script
   ENDIF
  ENDIF
  INSERT  FROM code_value_alias cva
   SET cva.code_set = 72, cva.code_value = next_code_value, cva.alias = alias,
    cva.contributor_source_cd = contributor, cva.primary_ind = 1, cva.updt_dt_tm = cnvtdatetime(
     curdate,curtime),
    cva.updt_id = 0, cva.updt_task = 0, cva.updt_cnt = 1,
    cva.updt_applctx = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET child_failed = "T"
   SET readme_data->status = "F"
   SET readme_data->message = build("PVReadMe 1104:Unable to add DCPGENERIC code set!")
   EXECUTE dm_readme_status
   COMMIT
   GO TO exit_script
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = build("PVReadMe 1104:DCPGENERIC cd added.")
   EXECUTE dm_readme_status
   COMMIT
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = build("PVReadMe 1104:DCPGENERIC cd already exists, no update needed.")
  EXECUTE dm_readme_status
  COMMIT
 ENDIF
#exit_script
 IF (child_failed="T")
  SET readme_data->status = "F"
  SET readme_data->message = build("PVReadMe 1104:Unable to add DCPGENERIC code set!")
  EXECUTE dm_readme_status
  COMMIT
 ELSE
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  COMMIT
 ENDIF
END GO

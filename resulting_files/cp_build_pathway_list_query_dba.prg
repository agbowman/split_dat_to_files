CREATE PROGRAM cp_build_pathway_list_query:dba
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
 RECORD bldrequest(
   1 name = vc
   1 definition = vc
   1 query_script = vc
   1 parameters[*]
     2 name = vc
     2 description = vc
     2 parameter_type_cd = f8
     2 required_ind = i2
     2 multiplicity_ind = i2
     2 metadata[*]
       3 name = vc
       3 sequence = i4
       3 value_string = vc
       3 value_dt = dq8
       3 value_id = f8
       3 value_entity = vc
 )
 RECORD bldreply(
   1 query_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE rdm_errcode = i4 WITH noconstant(0)
 DECLARE rdm_errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE readme_status = c1 WITH noconstant("S")
 DECLARE maxrecs = i4 WITH constant(100)
 DECLARE iteration_count = i4 WITH noconstant(1)
 DECLARE providercd = f8 WITH noconstant(0.0)
 DECLARE entitycd = f8 WITH noconstant(0.0)
 DECLARE daterangecd = f8 WITH noconstant(0.0)
 DECLARE pathwaystatuscdactive = f8 WITH noconstant(0.0)
 SET rdm_errcode = error(rdm_errmsg,1)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=29803
  DETAIL
   IF (cv.cdf_meaning="PROVIDER")
    providercd = cv.code_value
   ELSEIF (cv.cdf_meaning="ENTITY")
    entitycd = cv.code_value
   ELSEIF (cv.cdf_meaning="DATERANGE")
    daterangecd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=4003198
   AND cv.cdf_meaning="ACTIVE"
  DETAIL
   pathwaystatuscdactive = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_name="Build Pathways Patient List Query Type"
 ;end select
 IF (curqual > 0)
  DELETE  FROM dm_info di
   WHERE di.info_name="Build Pathways Patient List Query Type"
  ;end delete
 ENDIF
 INSERT  FROM dm_info di
  SET di.info_name = "Build Pathways Patient List Query Type", di.info_date = cnvtdatetime(curdate,
    curtime3), di.updt_applctx = 0,
   di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0,
   di.updt_task = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET readme_status = "F"
  SET rdm_errmsg = "Could not set readme run date on DM_INFO table"
  GO TO exit_readme
 ENDIF
 SET bldrequest->name = "Pathways Patient List Query"
 SET bldrequest->definition = "Pathways Patient List Query"
 SET bldrequest->query_script = "cp_query_pl_pathway_list"
 SET stat = alterlist(bldrequest->parameters,3)
 SET bldrequest->parameters[1].name = "Pathways"
 SET bldrequest->parameters[1].description =
 "Please specify the Pathway(s) you wish to qualify patients for."
 SET bldrequest->parameters[1].parameter_type_cd = entitycd
 SET bldrequest->parameters[1].required_ind = 1
 SET bldrequest->parameters[1].multiplicity_ind = 1
 SET stat = alterlist(bldrequest->parameters[1].metadata,4)
 SET bldrequest->parameters[1].metadata[1].name = "M_TABLE"
 SET bldrequest->parameters[1].metadata[1].sequence = 1
 SET bldrequest->parameters[1].metadata[1].value_string = "CP_PATHWAY"
 SET bldrequest->parameters[1].metadata[1].value_dt = null
 SET bldrequest->parameters[1].metadata[1].value_id = 0
 SET bldrequest->parameters[1].metadata[1].value_entity = ""
 SET bldrequest->parameters[1].metadata[2].name = "M_DISPLAY_FIELD"
 SET bldrequest->parameters[1].metadata[2].sequence = 1
 SET bldrequest->parameters[1].metadata[2].value_string = "pathway_name"
 SET bldrequest->parameters[1].metadata[2].value_dt = null
 SET bldrequest->parameters[1].metadata[2].value_id = 0
 SET bldrequest->parameters[1].metadata[2].value_entity = ""
 SET bldrequest->parameters[1].metadata[3].name = "M_IDENTIFICATION_FIELD"
 SET bldrequest->parameters[1].metadata[3].sequence = 1
 SET bldrequest->parameters[1].metadata[3].value_string = "cp_pathway_id"
 SET bldrequest->parameters[1].metadata[3].value_dt = null
 SET bldrequest->parameters[1].metadata[3].value_id = 0
 SET bldrequest->parameters[1].metadata[3].value_entity = ""
 SET bldrequest->parameters[1].metadata[4].name = "M_CRITERIA"
 SET bldrequest->parameters[1].metadata[4].sequence = 1
 SET bldrequest->parameters[1].metadata[4].value_string = build("pathway_status_cd = ",cnvtstring(
   pathwaystatuscdactive,16,3))
 SET bldrequest->parameters[1].metadata[4].value_dt = null
 SET bldrequest->parameters[1].metadata[4].value_id = 0
 SET bldrequest->parameters[1].metadata[4].value_entity = ""
 SET bldrequest->parameters[2].name = "Provider"
 SET bldrequest->parameters[2].description =
 "Please specify the provider for which to qualify Pathways for."
 SET bldrequest->parameters[2].parameter_type_cd = entitycd
 SET bldrequest->parameters[2].required_ind = 1
 SET bldrequest->parameters[2].multiplicity_ind = 1
 SET stat = alterlist(bldrequest->parameters[2].metadata,4)
 SET bldrequest->parameters[2].metadata[1].name = "M_TABLE"
 SET bldrequest->parameters[2].metadata[1].sequence = 1
 SET bldrequest->parameters[2].metadata[1].value_string = "PRSNL"
 SET bldrequest->parameters[2].metadata[1].value_dt = null
 SET bldrequest->parameters[2].metadata[1].value_id = 0
 SET bldrequest->parameters[2].metadata[1].value_entity = ""
 SET bldrequest->parameters[2].metadata[2].name = "M_DISPLAY_FIELD"
 SET bldrequest->parameters[2].metadata[2].sequence = 1
 SET bldrequest->parameters[2].metadata[2].value_string = "name_full_formatted"
 SET bldrequest->parameters[2].metadata[2].value_dt = null
 SET bldrequest->parameters[2].metadata[2].value_id = 0
 SET bldrequest->parameters[2].metadata[2].value_entity = ""
 SET bldrequest->parameters[2].metadata[3].name = "M_IDENTIFICATION_FIELD"
 SET bldrequest->parameters[2].metadata[3].sequence = 1
 SET bldrequest->parameters[2].metadata[3].value_string = "person_id"
 SET bldrequest->parameters[2].metadata[3].value_dt = null
 SET bldrequest->parameters[2].metadata[3].value_id = 0
 SET bldrequest->parameters[2].metadata[3].value_entity = ""
 SET bldrequest->parameters[2].metadata[4].name = "M_CRITERIA"
 SET bldrequest->parameters[2].metadata[4].sequence = 1
 SET bldrequest->parameters[2].metadata[4].value_string =
 "active_ind = 1 and person_id = reqinfo->updt_id"
 SET bldrequest->parameters[2].metadata[4].value_dt = null
 SET bldrequest->parameters[2].metadata[4].value_id = 0
 SET bldrequest->parameters[2].metadata[4].value_entity = ""
 SET bldrequest->parameters[3].name = "Relationship Types"
 SET bldrequest->parameters[3].description =
 "Please specify the type of visit relationships you wish to qualify patients for."
 SET bldrequest->parameters[3].parameter_type_cd = entitycd
 SET bldrequest->parameters[3].required_ind = 1
 SET bldrequest->parameters[3].multiplicity_ind = 1
 SET stat = alterlist(bldrequest->parameters[3].metadata,4)
 SET bldrequest->parameters[3].metadata[1].name = "M_TABLE"
 SET bldrequest->parameters[3].metadata[1].sequence = 1
 SET bldrequest->parameters[3].metadata[1].value_string = "CODE_VALUE"
 SET bldrequest->parameters[3].metadata[1].value_dt = null
 SET bldrequest->parameters[3].metadata[1].value_id = 0
 SET bldrequest->parameters[3].metadata[1].value_entity = ""
 SET bldrequest->parameters[3].metadata[2].name = "M_DISPLAY_FIELD"
 SET bldrequest->parameters[3].metadata[2].sequence = 1
 SET bldrequest->parameters[3].metadata[2].value_string = "display"
 SET bldrequest->parameters[3].metadata[2].value_dt = null
 SET bldrequest->parameters[3].metadata[2].value_id = 0
 SET bldrequest->parameters[3].metadata[2].value_entity = ""
 SET bldrequest->parameters[3].metadata[3].name = "M_IDENTIFICATION_FIELD"
 SET bldrequest->parameters[3].metadata[3].sequence = 1
 SET bldrequest->parameters[3].metadata[3].value_string = "code_value"
 SET bldrequest->parameters[3].metadata[3].value_dt = null
 SET bldrequest->parameters[3].metadata[3].value_id = 0
 SET bldrequest->parameters[3].metadata[3].value_entity = ""
 SET bldrequest->parameters[3].metadata[4].name = "M_CRITERIA"
 SET bldrequest->parameters[3].metadata[4].sequence = 1
 SET bldrequest->parameters[3].metadata[4].value_string = "code_set = 333 and active_ind = 1"
 SET bldrequest->parameters[3].metadata[4].value_dt = null
 SET bldrequest->parameters[3].metadata[4].value_id = 0
 SET bldrequest->parameters[3].metadata[4].value_entity = ""
 EXECUTE dcp_bld_query_type  WITH replace(request,bldrequest), replace(reply,bldreply)
 IF ((bldreply->status_data.status="F"))
  SET readme_status = "F"
  SET rdm_errmsg = "dcp_bld_query_type script failed"
  GO TO exit_readme
 ELSEIF ((bldreply->status_data.status="Z"))
  SET readme_status = "Q"
 ENDIF
#exit_readme
 FREE RECORD bldrequest
 FREE RECORD bldreply
 IF (validate(readme_data->readme_id,0) > 0)
  IF (readme_status="F")
   SET readme_data->status = "F"
   SET readme_data->message = rdm_errmsg
   ROLLBACK
  ELSEIF (readme_status="S")
   SET readme_data->status = "S"
   SET readme_data->message = "Successfully created provider group query type."
   COMMIT
  ELSEIF (readme_status="Q")
   SET readme_data->status = "S"
   SET readme_data->message = "The query type code already existed."
   ROLLBACK
  ENDIF
  EXECUTE dm_readme_status
 ELSE
  IF (((readme_status="F") OR (readme_status="Q")) )
   ROLLBACK
  ELSEIF (readme_status="S")
   COMMIT
  ENDIF
 ENDIF
END GO

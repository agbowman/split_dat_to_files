CREATE PROGRAM copy_bedrock_filters_mu:dba
 DECLARE from_measure = i2 WITH noconstant(0)
 DECLARE to_measure = i2 WITH noconstant(0)
 DECLARE num = i2 WITH noconstant(0)
 DECLARE par = i2 WITH noconstant(0)
 DECLARE val = i2 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE include_all_5_filters = i2 WITH noconstant(0)
 DECLARE copy_filter = vc WITH noconstant("")
 DECLARE from_measure_name = vc WITH noconstant("")
 DECLARE to_measure_name = vc WITH noconstant("")
 DECLARE from_filter_mean_stmt = vc WITH noconstant("")
 DECLARE to_filter_mean_stmt = vc WITH noconstant("")
 DECLARE logical_domain_id = f8 WITH noconstant(0)
 DECLARE errcode = i4 WITH noconstant(0)
 DECLARE errmsg = vc WITH noconstant("")
 DECLARE deletebedrockvalues(null) = null
 DECLARE insertbedrockvalues(null) = null
 DECLARE selectfrombedrockvalues(null) = null
 DECLARE selectbedrockfilters(null) = null
 DECLARE updatebedrockvalues(null) = null
 FREE RECORD from_measure_filter_values
 RECORD from_measure_filter_values(
   1 qual[*]
     2 br_datamart_category_id = f8
     2 br_datamart_filter_id = f8
     2 br_datamart_filter_mean = vc
     2 br_datamart_value_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 value_dt_tm = dq8
     2 freetext_desc = vc
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 update_id = f8
     2 update_task = f8
     2 update_application_task = f8
     2 value_seq = i4
     2 value_type_flag = i2
     2 qualifier_flag = i2
     2 group_seq = i4
     2 mpage_param_mean = vc
     2 mpage_param_value = vc
     2 parent_entity_name2 = vc
     2 parent_entity_id2 = f8
     2 logical_domain_id = f8
     2 br_datamart_flex_id = f8
     2 map_datatype_cd = f8
     2 txn_id_text = vc
     2 inst_id = f8
     2 filter_text = vc
     2 write_ind = i2
 )
 FREE RECORD measure_filter_values
 RECORD measure_filter_values(
   1 qual[*]
     2 br_datamart_filter_id = f8
     2 br_datamart_filter_mean = vc
     2 filter_text = vc
 )
 IF (reflect(parameter(1,0))="I*"
  AND reflect(parameter(2,0))="I*"
  AND parameter(1,0) > 0
  AND parameter(2,0) > 0)
  SET from_measure = parameter(1,0)
  SET to_measure = parameter(2,0)
 ELSE
  CALL echo("Invalid Parameters")
  GO TO exit_script
 ENDIF
 IF (from_measure=to_measure)
  CALL echo("From Measure and To Measure should not be the same")
  GO TO exit_script
 ENDIF
 IF (((from_measure > 6) OR (to_measure > 6)) )
  CALL echo("From or To Measure cannot be greater than 6")
  GO TO exit_script
 ENDIF
 IF (reflect(parameter(3,0))="")
  CALL echo("logical domain id cant be blank")
  GO TO exit_script
 ELSE
  IF (reflect(parameter(3,0))="F*")
   SET logical_domain_id = parameter(3,0)
  ELSE
   CALL echo("logical domain id invalid")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (reflect(parameter(4,0))=" ")
  SET include_all_5_filters = 1
  CALL echo("Copying all the 5 common filters")
 ELSE
  IF (reflect(parameter(4,0))="C*")
   SET copy_filter = parameter(4,0)
   IF ( NOT (copy_filter IN ("FACILITY_FILTER", "NURSE_FILTER", "SERVICE_FILTER", "MEDICAL_FILTER",
   "APPOINTMENT_FILTER")))
    CALL echo("Invalid Filter Details!")
    GO TO exit_script
   ENDIF
   CALL echo(concat("Copying :",copy_filter))
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 IF (from_measure=1)
  SET from_measure_name = "PI_PAT_ACCESS"
 ELSEIF (from_measure=2)
  SET from_measure_name = "PI_RL_IN"
 ELSEIF (from_measure=3)
  SET from_measure_name = "PI_RL_OUT"
 ELSEIF (from_measure=4)
  SET from_measure_name = "PI_PDMP"
 ELSEIF (from_measure=5)
  SET from_measure_name = "PI_OPIOID"
 ELSEIF (from_measure=6)
  SET from_measure_name = "MU3_ERX"
 ENDIF
 CALL echo(concat("From Measure Name:",from_measure_name))
 IF (to_measure=1)
  SET to_measure_name = "PI_PAT_ACCESS"
 ELSEIF (to_measure=2)
  SET to_measure_name = "PI_RL_IN"
 ELSEIF (to_measure=3)
  SET to_measure_name = "PI_RL_OUT"
 ELSEIF (to_measure=4)
  SET to_measure_name = "PI_PDMP"
 ELSEIF (to_measure=5)
  SET to_measure_name = "PI_OPIOID"
 ELSEIF (to_measure=6)
  SET to_measure_name = "MU3_ERX"
 ENDIF
 CALL echo(concat("To Measure Name : ",to_measure_name))
 IF (from_measure=1)
  IF (include_all_5_filters=1)
   SET from_filter_mean_stmt =
"bdf.filter_mean in ('PI_FACILITY_UNIQUE_EP','PI_LAB_RAD_EXCL_UNIQUE_EP',                                'PI_UNITS_EXCL_UNI\
QUE_EP','PI_EXCL_BLANK_NU_UNIQUE_EP','SERVICE_TYPE_PI_UNIQUE',                                'HOSP_SERV_CDS_PI_UNIQUE','A\
PPOINTMENT_TYPE_PI_UNIQUE_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET from_filter_mean_stmt =
    "bdf.filter_mean in ('PI_FACILITY_UNIQUE_EP','PI_LAB_RAD_EXCL_UNIQUE_EP','PI_UNITS_EXCL_UNIQUE_EP')"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('PI_EXCL_BLANK_NU_UNIQUE_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_PI_UNIQUE')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_PI_UNIQUE')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_PI_UNIQUE_EP')"
   ENDIF
  ENDIF
 ELSEIF (from_measure=2)
  IF (include_all_5_filters=1)
   SET from_filter_mean_stmt =
"bdf.filter_mean in ('MU3_FACILITY_PI_RL_IN_EP','MU3_LAB_RAD_EXCL_PI_RL_IN_EP',                                'MU3_UNITS_E\
XCL_PI_RL_IN_EP','MU3_EXCL_BLANK_NU_PI_RL_IN_EP','SERVICE_TYPE_PI_RL_IN',                                'HOSP_SERV_CDS_PI\
_RL_IN','APPOINTMENT_TYPE_PI_RL_IN_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET from_filter_mean_stmt =
"bdf.filter_mean in ('MU3_FACILITY_PI_RL_IN_EP','MU3_LAB_RAD_EXCL_PI_RL_IN_EP',                                  'MU3_UNITS\
_EXCL_PI_RL_IN_EP')\
"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('MU3_EXCL_BLANK_NU_PI_RL_IN_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_PI_RL_IN')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_PI_RL_IN')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_PI_RL_IN_EP')"
   ENDIF
  ENDIF
 ELSEIF (from_measure=3)
  IF (include_all_5_filters=1)
   SET from_filter_mean_stmt =
"bdf.filter_mean in ('PI_FACILITY_RL_OUT_EP','PI_LAB_RAD_EXCL_RL_OUT_EP',    							'PI_UNITS_EXCL_RL_OUT_EP','PI_EXCL_BLAN\
K_NU_RL_OUT_EP','SERVICE_TYPE_PI_RL_OUT',                                'HOSP_SERV_CDS_PI_RL_OUT','APPOINTMENT_TYPE_PI_RL\
_OUT_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET from_filter_mean_stmt =
"bdf.filter_mean in ('PI_FACILITY_RL_OUT_EP','PI_LAB_RAD_EXCL_RL_OUT_EP',                                  'PI_UNITS_EXCL_R\
L_OUT_EP')\
"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('PI_EXCL_BLANK_NU_RL_OUT_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_PI_RL_OUT')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_PI_RL_OUT')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_PI_RL_OUT_EP')"
   ENDIF
  ENDIF
 ELSEIF (from_measure=4)
  IF (include_all_5_filters=1)
   SET from_filter_mean_stmt =
"bdf.filter_mean in ('PI_FACILITY_PDMP_EP','PI_LAB_RAD_EXCL_PDMP_EP','PI_UNITS_EXCL_PDMP_EP',                              \
  'PI_EXCL_BLANK_NU_PDMP_EP','SERVICE_TYPE_PI_PDMP','HOSP_SERV_CDS_PI_PDMP',                                'APPOINTMENT_T\
YPE_PI_PDMP_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET from_filter_mean_stmt =
    "bdf.filter_mean in ('PI_FACILITY_PDMP_EP','PI_LAB_RAD_EXCL_PDMP_EP','PI_UNITS_EXCL_PDMP_EP')"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('PI_EXCL_BLANK_NU_PDMP_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_PI_PDMP')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_PI_PDMP')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_PI_PDMP_EP')"
   ENDIF
  ENDIF
 ELSEIF (from_measure=5)
  IF (include_all_5_filters=1)
   SET from_filter_mean_stmt =
"bdf.filter_mean in ('PI_FACILITY_OPIOID_EP','PI_LAB_RAD_EXCL_OPIOID_EP',                                'PI_UNITS_EXCL_OPI\
OID_EP','PI_EXCL_BLANK_NU_OPIOID_EP','SERVICE_TYPE_PI_OPIOID',                                'HOSP_SERV_CDS_PI_OPIOID','A\
PPOINTMENT_TYPE_PI_OPIOID_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET from_filter_mean_stmt =
"bdf.filter_mean in ('PI_FACILITY_OPIOID_EP','PI_LAB_RAD_EXCL_OPIOID_EP',                                  'PI_UNITS_EXCL_O\
PIOID_EP')\
"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('PI_EXCL_BLANK_NU_OPIOID_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_PI_OPIOID')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_PI_OPIOID')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_PI_OPIOID_EP')"
   ENDIF
  ENDIF
 ELSEIF (from_measure=6)
  IF (include_all_5_filters=1)
   SET from_filter_mean_stmt =
"bdf.filter_mean in ('MU3_FACILITY_ERX_EP','MU3_LAB_RAD_EXCL_ERX_EP','MU3_UNITS_EXCL_ERX_EP',                              \
  'MU3_EXCL_BLANK_NU_ERX_EP','SERVICE_TYPE_ERX','HOSP_SERV_CDS_ERX','APPOINTMENT_TYPE_ERX_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET from_filter_mean_stmt =
    "bdf.filter_mean in ('MU3_FACILITY_ERX_EP','MU3_LAB_RAD_EXCL_ERX_EP','MU3_UNITS_EXCL_ERX_EP')"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('MU3_EXCL_BLANK_NU_ERX_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_ERX')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_ERX')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET from_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_ERX_EP')"
   ENDIF
  ENDIF
 ENDIF
 CALL echo("From Measure filters parser statement")
 CALL echo(from_filter_mean_stmt)
 IF (to_measure=1)
  IF (include_all_5_filters=1)
   SET to_filter_mean_stmt =
"bdf.filter_mean in ('PI_FACILITY_UNIQUE_EP','PI_LAB_RAD_EXCL_UNIQUE_EP','PI_UNITS_EXCL_UNIQUE_EP',                        \
      'PI_EXCL_BLANK_NU_UNIQUE_EP','SERVICE_TYPE_PI_UNIQUE','HOSP_SERV_CDS_PI_UNIQUE',                              'APPOI\
NTMENT_TYPE_PI_UNIQUE_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET to_filter_mean_stmt =
    "bdf.filter_mean in ('PI_FACILITY_UNIQUE_EP','PI_LAB_RAD_EXCL_UNIQUE_EP',								  'PI_UNITS_EXCL_UNIQUE_EP')"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('PI_EXCL_BLANK_NU_UNIQUE_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_PI_UNIQUE')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_PI_UNIQUE')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_PI_UNIQUE_EP')"
   ENDIF
  ENDIF
 ELSEIF (to_measure=2)
  IF (include_all_5_filters=1)
   SET to_filter_mean_stmt =
"bdf.filter_mean in ('MU3_FACILITY_PI_RL_IN_EP','MU3_LAB_RAD_EXCL_PI_RL_IN_EP',                                'MU3_UNITS_E\
XCL_PI_RL_IN_EP','MU3_EXCL_BLANK_NU_PI_RL_IN_EP','SERVICE_TYPE_PI_RL_IN',                                'HOSP_SERV_CDS_PI\
_RL_IN','APPOINTMENT_TYPE_PI_RL_IN_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET to_filter_mean_stmt =
"bdf.filter_mean in ('MU3_FACILITY_PI_RL_IN_EP','MU3_LAB_RAD_EXCL_PI_RL_IN_EP',                                  'MU3_UNITS\
_EXCL_PI_RL_IN_EP')\
"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('MU3_EXCL_BLANK_NU_PI_RL_IN_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_PI_RL_IN')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_PI_RL_IN')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_PI_RL_IN_EP')"
   ENDIF
  ENDIF
 ELSEIF (to_measure=3)
  IF (include_all_5_filters=1)
   SET to_filter_mean_stmt =
"bdf.filter_mean in ('PI_FACILITY_RL_OUT_EP','PI_LAB_RAD_EXCL_RL_OUT_EP','PI_UNITS_EXCL_RL_OUT_EP',                        \
        'PI_EXCL_BLANK_NU_RL_OUT_EP','SERVICE_TYPE_PI_RL_OUT','HOSP_SERV_CDS_PI_RL_OUT',                                'A\
PPOINTMENT_TYPE_PI_RL_OUT_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET to_filter_mean_stmt =
    "bdf.filter_mean in ('PI_FACILITY_RL_OUT_EP','PI_LAB_RAD_EXCL_RL_OUT_EP',								'PI_UNITS_EXCL_RL_OUT_EP')"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('PI_EXCL_BLANK_NU_RL_OUT_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_PI_RL_OUT')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_PI_RL_OUT')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_PI_RL_OUT_EP')"
   ENDIF
  ENDIF
 ELSEIF (to_measure=4)
  IF (include_all_5_filters=1)
   SET to_filter_mean_stmt =
"bdf.filter_mean in ('PI_FACILITY_PDMP_EP','PI_LAB_RAD_EXCL_PDMP_EP','PI_UNITS_EXCL_PDMP_EP',                              \
'PI_EXCL_BLANK_NU_PDMP_EP','SERVICE_TYPE_PI_PDMP','HOSP_SERV_CDS_PI_PDMP',                              'APPOINTMENT_TYPE_\
PI_PDMP_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET to_filter_mean_stmt =
    "bdf.filter_mean in ('PI_FACILITY_PDMP_EP','PI_LAB_RAD_EXCL_PDMP_EP','PI_UNITS_EXCL_PDMP_EP')"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('PI_EXCL_BLANK_NU_PDMP_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_PI_PDMP')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_PI_PDMP')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_PI_PDMP_EP')"
   ENDIF
  ENDIF
 ELSEIF (to_measure=5)
  IF (include_all_5_filters=1)
   SET to_filter_mean_stmt =
"bdf.filter_mean in ('PI_FACILITY_OPIOID_EP','PI_LAB_RAD_EXCL_OPIOID_EP','PI_UNITS_EXCL_OPIOID_EP',                        \
        'PI_EXCL_BLANK_NU_OPIOID_EP','SERVICE_TYPE_PI_OPIOID','HOSP_SERV_CDS_PI_OPIOID',                                'A\
PPOINTMENT_TYPE_PI_OPIOID_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET to_filter_mean_stmt =
    "bdf.filter_mean in ('PI_FACILITY_OPIOID_EP','PI_LAB_RAD_EXCL_OPIOID_EP',								  'PI_UNITS_EXCL_OPIOID_EP')"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('PI_EXCL_BLANK_NU_OPIOID_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_PI_OPIOID')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_PI_OPIOID')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_PI_OPIOID_EP')"
   ENDIF
  ENDIF
 ELSEIF (to_measure=6)
  IF (include_all_5_filters=1)
   SET to_filter_mean_stmt =
"bdf.filter_mean in ('MU3_FACILITY_ERX_EP','MU3_LAB_RAD_EXCL_ERX_EP','MU3_UNITS_EXCL_ERX_EP',								'MU3_EXCL_BLANK_NU_ERX\
_EP','SERVICE_TYPE_ERX','HOSP_SERV_CDS_ERX','APPOINTMENT_TYPE_ERX_EP')\
"
  ELSE
   IF (copy_filter="FACILITY_FILTER")
    SET to_filter_mean_stmt =
    "bdf.filter_mean in ('MU3_FACILITY_ERX_EP','MU3_LAB_RAD_EXCL_ERX_EP','MU3_UNITS_EXCL_ERX_EP')"
   ELSEIF (copy_filter="NURSE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('MU3_EXCL_BLANK_NU_ERX_EP')"
   ELSEIF (copy_filter="SERVICE_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('SERVICE_TYPE_ERX')"
   ELSEIF (copy_filter="MEDICAL_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('HOSP_SERV_CDS_ERX')"
   ELSEIF (copy_filter="APPOINTMENT_FILTER")
    SET to_filter_mean_stmt = "bdf.filter_mean in ('APPOINTMENT_TYPE_ERX_EP')"
   ENDIF
  ENDIF
 ENDIF
 CALL echo("To Measure filters parser statement")
 CALL echo(to_filter_mean_stmt)
 CALL selectfrombedrockvalues(null)
 CALL selectbedrockfilters(null)
 CALL updatebedrockvalues(null)
 CALL deletebedrockvalues(null)
 CALL insertbedrockvalues(null)
 SUBROUTINE selectfrombedrockvalues(null)
  SELECT INTO "NL:"
   FROM br_datamart_filter bdf,
    br_datamart_category bdc,
    br_datamart_value bdv
   WHERE bdf.br_datamart_category_id=bdc.br_datamart_category_id
    AND bdc.category_mean="MUSE_FUNCTIONAL_3"
    AND bdf.br_datamart_filter_id=bdv.br_datamart_filter_id
    AND parser(from_filter_mean_stmt)
    AND bdv.logical_domain_id=logical_domain_id
   ORDER BY bdf.br_datamart_filter_id, bdv.br_datamart_value_id DESC
   HEAD REPORT
    cnt = 0
   HEAD bdv.br_datamart_value_id
    cnt = (cnt+ 1), stat = alterlist(from_measure_filter_values->qual,cnt),
    from_measure_filter_values->qual[cnt].br_datamart_category_id = bdv.br_datamart_category_id,
    from_measure_filter_values->qual[cnt].br_datamart_filter_id = bdv.br_datamart_filter_id,
    from_measure_filter_values->qual[cnt].br_datamart_filter_mean = bdf.filter_mean,
    from_measure_filter_values->qual[cnt].br_datamart_value_id = bdv.br_datamart_value_id,
    from_measure_filter_values->qual[cnt].parent_entity_name = bdv.parent_entity_name,
    from_measure_filter_values->qual[cnt].parent_entity_id = bdv.parent_entity_id,
    from_measure_filter_values->qual[cnt].value_dt_tm = bdv.value_dt_tm,
    from_measure_filter_values->qual[cnt].freetext_desc = bdv.freetext_desc,
    from_measure_filter_values->qual[cnt].updt_cnt = bdv.updt_cnt, from_measure_filter_values->qual[
    cnt].updt_dt_tm = bdv.updt_dt_tm,
    from_measure_filter_values->qual[cnt].update_id = bdv.updt_id, from_measure_filter_values->qual[
    cnt].update_task = bdv.updt_task, from_measure_filter_values->qual[cnt].update_application_task
     = bdv.updt_applctx,
    from_measure_filter_values->qual[cnt].value_seq = bdv.value_seq, from_measure_filter_values->
    qual[cnt].value_type_flag = bdv.value_type_flag, from_measure_filter_values->qual[cnt].
    qualifier_flag = bdv.qualifier_flag,
    from_measure_filter_values->qual[cnt].group_seq = bdv.group_seq, from_measure_filter_values->
    qual[cnt].mpage_param_mean = bdv.mpage_param_mean, from_measure_filter_values->qual[cnt].
    mpage_param_value = bdv.mpage_param_value,
    from_measure_filter_values->qual[cnt].parent_entity_name2 = bdv.parent_entity_name2,
    from_measure_filter_values->qual[cnt].parent_entity_id2 = bdv.parent_entity_id2,
    from_measure_filter_values->qual[cnt].logical_domain_id = bdv.logical_domain_id,
    from_measure_filter_values->qual[cnt].br_datamart_flex_id = bdv.br_datamart_flex_id,
    from_measure_filter_values->qual[cnt].map_datatype_cd = bdv.map_data_type_cd,
    from_measure_filter_values->qual[cnt].txn_id_text = bdv.txn_id_text,
    from_measure_filter_values->qual[cnt].inst_id = bdv.inst_id, from_measure_filter_values->qual[cnt
    ].write_ind = 0
    IF (bdf.filter_mean IN ("PI_FACILITY_UNIQUE_EP", "MU3_FACILITY_PI_RL_IN_EP",
    "PI_FACILITY_RL_OUT_EP", "PI_FACILITY_PDMP_EP", "PI_FACILITY_OPIOID_EP",
    "MU3_FACILITY_ERX_EP"))
     from_measure_filter_values->qual[cnt].filter_text = "FACILITY_FILTER"
    ELSEIF (bdf.filter_mean IN ("PI_LAB_RAD_EXCL_UNIQUE_EP", "MU3_LAB_RAD_EXCL_PI_RL_IN_EP",
    "PI_LAB_RAD_EXCL_RL_OUT_EP", "PI_LAB_RAD_EXCL_PDMP_EP", "PI_LAB_RAD_EXCL_OPIOID_EP",
    "MU3_LAB_RAD_EXCL_ERX_EP"))
     from_measure_filter_values->qual[cnt].filter_text = "FACILITY_SUB_FILTER_RAD"
    ELSEIF (bdf.filter_mean IN ("PI_UNITS_EXCL_UNIQUE_EP", "MU3_UNITS_EXCL_PI_RL_IN_EP",
    "PI_UNITS_EXCL_RL_OUT_EP", "PI_UNITS_EXCL_PDMP_EP", "PI_UNITS_EXCL_OPIOID_EP",
    "MU3_UNITS_EXCL_ERX_EP"))
     from_measure_filter_values->qual[cnt].filter_text = "FACILITY_SUB_FILTER_AMB"
    ELSEIF (bdf.filter_mean IN ("PI_EXCL_BLANK_NU_UNIQUE_EP", "MU3_EXCL_BLANK_NU_PI_RL_IN_EP",
    "PI_EXCL_BLANK_NU_RL_OUT_EP", "PI_EXCL_BLANK_NU_PDMP_EP", "PI_EXCL_BLANK_NU_OPIOID_EP",
    "MU3_EXCL_BLANK_NU_ERX_EP"))
     from_measure_filter_values->qual[cnt].filter_text = "NURSE_FILTER"
    ELSEIF (bdf.filter_mean IN ("SERVICE_TYPE_PI_UNIQUE", "SERVICE_TYPE_PI_RL_IN",
    "SERVICE_TYPE_PI_RL_OUT", "SERVICE_TYPE_PI_PDMP", "SERVICE_TYPE_PI_OPIOID",
    "SERVICE_TYPE_ERX"))
     from_measure_filter_values->qual[cnt].filter_text = "SERVICE_FILTER"
    ELSEIF (bdf.filter_mean IN ("HOSP_SERV_CDS_PI_UNIQUE", "HOSP_SERV_CDS_PI_RL_IN",
    "HOSP_SERV_CDS_PI_RL_OUT", "HOSP_SERV_CDS_PI_PDMP", "HOSP_SERV_CDS_PI_OPIOID",
    "HOSP_SERV_CDS_ERX"))
     from_measure_filter_values->qual[cnt].filter_text = "MEDICAL_FILTER"
    ELSEIF (bdf.filter_mean IN ("APPOINTMENT_TYPE_PI_UNIQUE_EP", "APPOINTMENT_TYPE_PI_RL_IN_EP",
    "APPOINTMENT_TYPE_PI_RL_OUT_EP", "APPOINTMENT_TYPE_PI_PDMP_EP", "APPOINTMENT_TYPE_PI_OPIOID_EP",
    "APPOINTMENT_TYPE_ERX_EP"))
     from_measure_filter_values->qual[cnt].filter_text = "APPOINTMENT_FILTER"
    ENDIF
   WITH nocounter
  ;end select
  CALL echorecord(from_measure_filter_values)
 END ;Subroutine
 SUBROUTINE selectbedrockfilters(null)
   SELECT INTO "NL:"
    FROM br_datamart_filter bdf
    WHERE parser(to_filter_mean_stmt)
    ORDER BY bdf.br_datamart_filter_id
    HEAD REPORT
     f_cnt = 0
    HEAD bdf.br_datamart_filter_id
     f_cnt = (f_cnt+ 1), stat = alterlist(measure_filter_values->qual,f_cnt), measure_filter_values->
     qual[f_cnt].br_datamart_filter_id = bdf.br_datamart_filter_id,
     measure_filter_values->qual[f_cnt].br_datamart_filter_mean = bdf.filter_mean
     IF (bdf.filter_mean IN ("PI_FACILITY_UNIQUE_EP", "MU3_FACILITY_PI_RL_IN_EP",
     "PI_FACILITY_RL_OUT_EP", "PI_FACILITY_PDMP_EP", "PI_FACILITY_OPIOID_EP",
     "MU3_FACILITY_ERX_EP"))
      measure_filter_values->qual[f_cnt].filter_text = "FACILITY_FILTER"
     ELSEIF (bdf.filter_mean IN ("PI_LAB_RAD_EXCL_UNIQUE_EP", "MU3_LAB_RAD_EXCL_PI_RL_IN_EP",
     "PI_LAB_RAD_EXCL_RL_OUT_EP", "PI_LAB_RAD_EXCL_PDMP_EP", "PI_LAB_RAD_EXCL_OPIOID_EP",
     "MU3_LAB_RAD_EXCL_ERX_EP"))
      measure_filter_values->qual[f_cnt].filter_text = "FACILITY_SUB_FILTER_RAD"
     ELSEIF (bdf.filter_mean IN ("PI_UNITS_EXCL_UNIQUE_EP", "MU3_UNITS_EXCL_PI_RL_IN_EP",
     "PI_UNITS_EXCL_RL_OUT_EP", "PI_UNITS_EXCL_PDMP_EP", "PI_UNITS_EXCL_OPIOID_EP",
     "MU3_UNITS_EXCL_ERX_EP"))
      measure_filter_values->qual[f_cnt].filter_text = "FACILITY_SUB_FILTER_AMB"
     ELSEIF (bdf.filter_mean IN ("PI_EXCL_BLANK_NU_UNIQUE_EP", "MU3_EXCL_BLANK_NU_PI_RL_IN_EP",
     "PI_EXCL_BLANK_NU_RL_OUT_EP", "PI_EXCL_BLANK_NU_PDMP_EP", "PI_EXCL_BLANK_NU_OPIOID_EP",
     "MU3_EXCL_BLANK_NU_ERX_EP"))
      measure_filter_values->qual[f_cnt].filter_text = "NURSE_FILTER"
     ELSEIF (bdf.filter_mean IN ("SERVICE_TYPE_PI_UNIQUE", "SERVICE_TYPE_PI_RL_IN",
     "SERVICE_TYPE_PI_RL_OUT", "SERVICE_TYPE_PI_PDMP", "SERVICE_TYPE_PI_OPIOID",
     "SERVICE_TYPE_ERX"))
      measure_filter_values->qual[f_cnt].filter_text = "SERVICE_FILTER"
     ELSEIF (bdf.filter_mean IN ("HOSP_SERV_CDS_PI_UNIQUE", "HOSP_SERV_CDS_PI_RL_IN",
     "HOSP_SERV_CDS_PI_RL_OUT", "HOSP_SERV_CDS_PI_PDMP", "HOSP_SERV_CDS_PI_OPIOID",
     "HOSP_SERV_CDS_ERX"))
      measure_filter_values->qual[f_cnt].filter_text = "MEDICAL_FILTER"
     ELSEIF (bdf.filter_mean IN ("APPOINTMENT_TYPE_PI_UNIQUE_EP", "APPOINTMENT_TYPE_PI_RL_IN_EP",
     "APPOINTMENT_TYPE_PI_RL_OUT_EP", "APPOINTMENT_TYPE_PI_PDMP_EP", "APPOINTMENT_TYPE_PI_OPIOID_EP",
     "APPOINTMENT_TYPE_ERX_EP"))
      measure_filter_values->qual[f_cnt].filter_text = "APPOINTMENT_FILTER"
     ENDIF
    WITH nocounter
   ;end select
   CALL echo("To Measure filters")
   CALL echorecord(measure_filter_values)
 END ;Subroutine
 SUBROUTINE updatebedrockvalues(null)
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(size(from_measure_filter_values->qual,5)))
    PLAN (d1
     WHERE size(from_measure_filter_values->qual,5) != 0
      AND (from_measure_filter_values->qual[d1.seq].br_datamart_filter_id > 0))
    ORDER BY d1.seq
    HEAD d1.seq
     uf_idx = locateval(num,1,size(measure_filter_values->qual,5),from_measure_filter_values->qual[d1
      .seq].filter_text,measure_filter_values->qual[num].filter_text)
     IF (uf_idx > 0)
      from_measure_filter_values->qual[d1.seq].write_ind = 1, from_measure_filter_values->qual[d1.seq
      ].br_datamart_filter_id = measure_filter_values->qual[uf_idx].br_datamart_filter_id
     ENDIF
    WITH nocounter
   ;end select
   CALL echo("Updated to measure filters to from measure filters")
   CALL echorecord(from_measure_filter_values)
 END ;Subroutine
 SUBROUTINE deletebedrockvalues(null)
   DELETE  FROM br_datamart_value bdv
    WHERE bdv.br_datamart_filter_id IN (
    (SELECT
     br_datamart_filter_id
     FROM br_datamart_filter bdf,
      br_datamart_category bdc
     WHERE bdc.category_mean="MUSE_FUNCTIONAL_3"
      AND bdc.br_datamart_category_id=bdf.br_datamart_category_id
      AND parser(to_filter_mean_stmt)))
     AND bdv.logical_domain_id=logical_domain_id
    WITH nocounter, maxcommit = 10000
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    ROLLBACK
    CALL echo("Deletion Rollbacked")
   ELSE
    COMMIT
    CALL echo("Deletion Commited")
   ENDIF
 END ;Subroutine
 SUBROUTINE insertbedrockvalues(null)
   INSERT  FROM br_datamart_value bdv,
     (dummyt d1  WITH seq = value(size(from_measure_filter_values->qual,5)))
    SET bdv.br_datamart_value_id = seq(bedrock_seq,nextval), bdv.br_datamart_filter_id =
     from_measure_filter_values->qual[d1.seq].br_datamart_filter_id, bdv.parent_entity_name =
     from_measure_filter_values->qual[d1.seq].parent_entity_name,
     bdv.parent_entity_id = from_measure_filter_values->qual[d1.seq].parent_entity_id, bdv
     .value_dt_tm = cnvtdatetime(curdate,curtime3), bdv.freetext_desc = from_measure_filter_values->
     qual[d1.seq].freetext_desc,
     bdv.updt_cnt = from_measure_filter_values->qual[d1.seq].updt_cnt, bdv.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), bdv.updt_id = from_measure_filter_values->qual[d1.seq].update_id,
     bdv.updt_task = from_measure_filter_values->qual[d1.seq].update_task, bdv.updt_applctx =
     from_measure_filter_values->qual[d1.seq].update_application_task, bdv.beg_effective_dt_tm =
     cnvtdatetime(curdate,curtime3),
     bdv.end_effective_dt_tm = cnvtdatetime("31-Decc-2100"), bdv.br_datamart_category_id =
     from_measure_filter_values->qual[d1.seq].br_datamart_category_id, bdv.value_seq =
     from_measure_filter_values->qual[d1.seq].value_seq,
     bdv.value_type_flag = from_measure_filter_values->qual[d1.seq].value_type_flag, bdv
     .qualifier_flag = from_measure_filter_values->qual[d1.seq].qualifier_flag, bdv.group_seq =
     from_measure_filter_values->qual[d1.seq].group_seq,
     bdv.mpage_param_mean = from_measure_filter_values->qual[d1.seq].mpage_param_mean, bdv
     .mpage_param_value = from_measure_filter_values->qual[d1.seq].mpage_param_value, bdv
     .parent_entity_name2 = from_measure_filter_values->qual[d1.seq].parent_entity_name2,
     bdv.parent_entity_id2 = from_measure_filter_values->qual[d1.seq].parent_entity_id2, bdv
     .logical_domain_id = from_measure_filter_values->qual[d1.seq].logical_domain_id, bdv
     .br_datamart_flex_id = from_measure_filter_values->qual[d1.seq].br_datamart_flex_id,
     bdv.map_data_type_cd = from_measure_filter_values->qual[d1.seq].map_datatype_cd, bdv.last_utc_ts
      = cnvtdatetime(curdate,curtime3), bdv.txn_id_text = from_measure_filter_values->qual[d1.seq].
     txn_id_text,
     bdv.inst_id = from_measure_filter_values->qual[d1.seq].inst_id
    PLAN (d1
     WHERE size(from_measure_filter_values->qual,5) > 0)
     JOIN (bdv)
    WITH nocounter, maxcommit = 1000
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    ROLLBACK
    CALL echo("Insertion Rollbacked")
   ELSE
    COMMIT
    CALL echo("Insertion commited")
   ENDIF
 END ;Subroutine
#exit_script
END GO

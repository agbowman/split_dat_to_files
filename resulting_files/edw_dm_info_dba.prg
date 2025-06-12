CREATE PROGRAM edw_dm_info:dba
 PROMPT
  "HEALTH SYSTEM ID:  >" = "00000",
  "HEALTH SYSTEM SOURCE ID:  >" = "00000",
  "CLIENT TYPE IND:  >" = "B",
  "ACT EXT FROM DT TM:  >" = "",
  "ACT EXT TO DT TM:  >" = "",
  "HISTORIC EXTRACT IND:  >" = "N",
  "HISTORIC START DT TM:  >" = "",
  "HISTORIC DAYS TO EXTRACT:  >" = 0,
  "INSTITUTION LIST:  >" = "",
  "ENCOUNTER NK:  >" = "CNVTINT(ENCOUNTER.ENCNTR_ID),HEALTH_SYSTEM_SOURCE_ID",
  "ADMIT DT TM:  >" = "ENCOUNTER.REG_DT_TM",
  "DISCHARGE DT TM:  >" = "ENCOUNTER.DISCH_DT_TM",
  "FILTER FIELD 1:  >" = "",
  "FILTER FIELD 2:  >" = "",
  "FILTER FIELD 3:  >" = "",
  "FILTER VALUE 1:  >" = "",
  "FILTER VALUE 2:  >" = "",
  "FILTER VALUE 3:  >" = "",
  "Extract Type (G = global, E = enterprise):  >" = "G",
  "Initial Enterprise Pull:  >" = "N",
  "TIME ZONE:  >" = "",
  "CODE_VALUE_IND:  >" = "Y",
  "DIAGNOSIS_IND:  >" = "Y",
  "ENCNTR_COMBINE_IND:  >" = "Y",
  "ENCNTR_GROUP_IND:  >" = "Y",
  "ENCNTR_HISTORY_IND:  >" = "Y",
  "ENCNTR_PERSONNEL_IND:  >" = "Y",
  "ENCOUNTER_IND:  >" = "Y",
  "LOCATION_HIERARCHY_IND:  >" = "Y",
  "NOMENCLATURE_IND:  >" = "Y",
  "ORGANIZATION_IND:  >" = "Y",
  "PERSON_PERSONNEL_IND:  >" = "Y",
  "PROCEDURE_IND:  >" = "Y",
  "ALERT_IND:  >" = "Y",
  "ALLERGY_IND:  >" = "Y",
  "MEDICATION_PROD_IND:  >" = "Y",
  "MEDICATION_ITEM_IND:  >" = "Y",
  "PATHWAY_PHASE_IND:  >" = "Y",
  "CLINICAL_EVNT_IND:  >" = "Y",
  "EVNT_CODE_RSLT_IND:  >" = "Y",
  "INTAKE_OUTPUT_RSLT_IND:  >" = "Y",
  "RAW_EVENT_PRSNL_IND:  >" = "Y",
  "GET_ES_HIER_IND:  >" = "Y",
  "GEN_LAB_IND:  >" = "Y",
  "GEN_LAB_RAW_IND:  >" = "Y",
  "CONCEPT_IND:  >" = "Y",
  "EVNT_MOD_IND:  >" = "Y",
  "PROBLEM_IND:  >" = "Y",
  "PHA_ORDER_IND:  >" = "Y",
  "PHA_INGREDIENT_IND:  >" = "Y",
  "PHA_DISPENSE_IND:  >" = "Y",
  "PHA_RETAIL_IND:  >" = "Y",
  "ALPHA_RESPONSE_IND:  >" = "Y",
  "DOCUMENTATION_INPUT_IND:  >" = "Y",
  "DOCUMENTATION_RESPONSE_IND:  >" = "Y",
  "ENCNTR_INSURANCE_IND:  >" = "Y",
  "FILL_CYCLE_HIST_IND:  >" = "Y",
  "HEALTH_PLAN_IND:  >" = "Y",
  "LOCATION_GROUP_IND:  >" = "Y",
  "LOCATION_IND:  >" = "Y",
  "MEDICATION_ADMINISTRATION_IND:  >" = "Y",
  "REFERENCE_RANGE_FACTOR_IND:  >" = "Y",
  "RESOURCE_GROUP_IND:  >" = "Y",
  "SERVICE_RESOURCE_IND:  >" = "Y",
  "TASK_ASSAY_IND:  >" = "Y",
  "SURGERY_IND:  >" = "Y",
  "Output to File/Printer/MINE " = "MINE"
 EXECUTE gm_dm_info2388_def "I"
 DECLARE gm_i_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_dm_info2388_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_number":
     SET gm_i_dm_info2388_req->qual[iqual].info_number = ival
     SET gm_i_dm_info2388_req->info_numberi = 1
    OF "info_long_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_dm_info2388_req->qual[iqual].info_long_id = ival
     SET gm_i_dm_info2388_req->info_long_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_dm_info2388_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_date":
     SET gm_i_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
     SET gm_i_dm_info2388_req->info_datei = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_dm_info2388_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_dm_info2388_vc(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_domain":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_dm_info2388_req->qual[iqual].info_domain = ival
     SET gm_i_dm_info2388_req->info_domaini = 1
    OF "info_name":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_dm_info2388_req->qual[iqual].info_name = ival
     SET gm_i_dm_info2388_req->info_namei = 1
    OF "info_char":
     SET gm_i_dm_info2388_req->qual[iqual].info_char = ival
     SET gm_i_dm_info2388_req->info_chari = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SET stat = alterlist(gm_i_dm_info2388_req->qual,1)
 SET gm_i_dm_info2388_req->info_domaini = 1
 SET gm_i_dm_info2388_req->info_namei = 1
 SET gm_i_dm_info2388_req->info_datei = 1
 SET gm_i_dm_info2388_req->info_chari = 1
 SET gm_i_dm_info2388_req->info_numberi = 1
 SET gm_i_dm_info2388_req->info_long_idi = 0
 SET cntr = 1
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HEALTH_SYSTEM_ID"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $1
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HEALTH_SYSTEM_SOURCE_ID"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $2
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "CLIENT_TYPE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $3
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ACT_EXT_FROM_DT_TM"
 SET gm_i_dm_info2388_req->qual[cntr].info_date = cnvtdatetime( $4)
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ACT_EXT_TO_DT_TM"
 SET gm_i_dm_info2388_req->qual[cntr].info_date = cnvtdatetime( $5)
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HISTORIC_EXTRACT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $6
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HISTORIC_START_DT_TM"
 SET gm_i_dm_info2388_req->qual[cntr].info_date = cnvtdatetime( $7)
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HISTORIC_DAYS_TO_EXTRACT"
 SET gm_i_dm_info2388_req->qual[cntr].info_number =  $8
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "INSTITUTION_LIST"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $9
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENCOUNTER_NK"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $10
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ADMIT_DT_TM"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $11
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "DISCHARGE_DT_TM"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $12
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "FILTER_FIELD_1"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $13
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "FILTER_FIELD_2"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $14
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "FILTER_FIELD_3"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $15
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "FILTER_VALUE_1"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $16
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "FILTER_VALUE_2"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $17
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "FILTER_VALUE_3"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $18
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "EXTRACT_TYPE"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $19
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "INITIAL_ENTERPRISE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $20
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "TIME_ZONE"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $21
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "DEBUG_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "CODE_VALUE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $22
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "DIAGNOSIS_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $23
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENCNTR_COMBINE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $24
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENCNTR_GROUP_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $25
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENCNTR_HISTORY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $26
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENCNTR_PERSONNEL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $27
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENCOUNTER_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $28
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "LOCATION_HIERARCHY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $29
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "NOMENCLATURE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $30
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ORGANIZATION_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $31
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PERSON_PERSONNEL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $32
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PROCEDURE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $33
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ALERT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $34
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ALLERGY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $35
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MEDICATION_PROD_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $36
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MEDICATION_ITEM_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $37
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PATHWAY_PHASE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $38
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "CLINICAL_EVNT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $39
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "EVNT_CODE_RSLT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $40
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "INTAKE_OUTPUT_RSLT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $41
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "RAW_EVENT_PRSNL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $42
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "GET_ES_HIER_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $43
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "GEN_LAB_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $44
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "GEN_LAB_RAW_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $45
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "CONCEPT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $46
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "EVNT_MOD_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $47
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PROBLEM_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $48
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PHARMACY_ORDER_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $49
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PHARMACY_INGREDIENT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $50
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PHARMACY_DISPENSE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $51
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PHARMACY_RETAIL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $52
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_CODE_VALUE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $22
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_DIAGNOSIS_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $23
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ENCOUNTER_COMBINE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $24
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ENCOUNTER_GROUP_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $25
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ENCOUNTER_HISTORY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $26
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ENCOUNTER_PERSONNEL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $27
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ENCOUNTER_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $28
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_LOCATION_HIERARCHY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $29
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_NOMENCLATURE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $30
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ORGANIZATION_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $31
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_PERSON_PERSONNEL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $32
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_PROCEDURE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $33
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ALERT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $34
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ALLERGY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $35
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_MEDICATION_PROD_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $36
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_MEDICATION_ITEM_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $37
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_PATHWAY_PHASE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $38
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_CLINICAL_EVNT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $39
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_EVNT_CODE_RSLT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $40
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_INTAKE_OUTPUT_RSLT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $41
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_RAW_EVENT_PRSNL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $42
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_GET_ES_HIER_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $43
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_GEN_LAB_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $44
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_GEN_LAB_RAW_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $45
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_CONCEPT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $46
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_EVNT_MOD_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $47
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_PROBLEM_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $48
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_PHARMACY_ORDER_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $49
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_PHARMACY_INGREDIENT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $50
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_PHARMACY_DISPENSE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $51
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_PHARMACY_RETAIL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $52
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "GET_ORPHAN_FILES"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ALTERNATE1_ID"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ALTERNATE2_ID"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ALTERNATE3_ID"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ALTERNATE4_ID"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ALTERNATE5_ID"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_ALT_IDENT_1"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_ALT_IDENT_2"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_ALT_IDENT_3"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_ALT_IDENT_4"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_ALT_IDENT_5"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENC_ALT_IDENT_1"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENC_ALT_IDENT_2"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENC_ALT_IDENT_3"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENC_ALT_IDENT_4"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENC_ALT_IDENT_5"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ORDER_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ORDER_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ORDRBL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ORDRBL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ORDRBL_DETAIL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ORDRBL_DETAIL_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MICRO_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_MICRO_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = ""
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "SMALL_BATCH_SIZE"
 SET gm_i_dm_info2388_req->qual[cntr].info_number = 6000.0
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MEDIUM_BATCH_SIZE"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = 24000.0
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "LARGE_BATCH_SIZE"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = 48000.0
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ALPHA_RESPONSE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $53
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "DOCUMENTATION_INPUT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $54
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "DOCUMENTATION_RESPONSE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $55
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENCNTR_INSURANCE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $56
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "FILL_CYCLE_HIST_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $57
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HEALTH_PLAN_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $58
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "LOCATION_GROUP_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $59
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "LOCATION_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $60
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MEDICATION_ADMINISTRATION_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $61
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "REFERENCE_RANGE_FACTOR_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $62
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "RESOURCE_GROUP_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $63
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "SERVICE_RESOURCE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $64
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "TASK_ASSAY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $65
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ALPHA_RESPONSE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $53
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_DOCUMENTATION_INPUT_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $54
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_DOCUMENTATION_RESPONSE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $55
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_ENCOUNTER_INSURANCE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $56
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_FILL_CYCLE_HIST_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $57
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_HEALTH_PLAN_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $58
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_LOCATION_GROUP_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $59
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_LOCATION_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $60
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_MEDICATION_ADMINISTRATION_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $61
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_REFERENCE_RANGE_FACTOR_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $62
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_RESOURCE_GROUP_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $63
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_SERVICE_RESOURCE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $64
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_TASK_ASSAY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $65
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "SURGERY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $66
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HIST_SURGERY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char =  $66
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PERIOP_DOC_DAYS_BACK"
 SET gm_i_dm_info2388_req->qual[cntr].info_number = 14
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_ADDRESS"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_ENCNTR_ALIAS"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_ENCNTR_PERSON_RELTN"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_PERSON_PERSON_RELTN"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_PERSON_PRSNL_RELTN"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_PERSON_ALIAS"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_PERSON_NAME"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_PERSON_ORG_RELTN"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_PERSON_PATIENT"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_PHONE"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_PRSNL_ALIAS"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENC_GRP_DRG_ENCOUNTER_EXTENSION"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "NOMEN_DRG_EXTENSION"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "NOMEN_ICD9_EXTENSION"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PROC_PRSNL_RLTN"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "DIAG_ENCOUNTER"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ORG_ADDRESS"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ORG_PHONE"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ORG_LOCATION"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENC_ALIAS"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENC_PFT_ENCNTR_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HP_ORG_PLAN_RELTN"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HP_ENCNTR_PLAN_RELTN"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "HP_PERSON_PLAN_RELTN"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ORDER_CATALOG_SYNONYM"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ORDER_CODE_VALUE_EXTENSION"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MIC_CONTAINER"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MIC_OSRC"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MIC_V500_SPECIMEN"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MIC_ORDER_LABORATORY"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MIC_LONG_TEXT"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MP_ITEM_MASTER_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MP_OBJ_IDNT_IDX_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MP_SCHD_TIME_OF_DAY_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MP_SCHD_DAY_OF_WEEK_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PW_PATHWAY_ACTION_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PD_GLB_ORD_DETL"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PD_GLB_OSRC"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PD_GLB_CONTAINER"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PD_GLB_V500_SPEC"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PD_GLB_LONG_TEXT"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "N"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PD_GLB_RESULT_EVENT"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PO_ORDER_DISPENSE"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "POD_TEMPLATE_NONFORMULARY"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PD_ORDER_ACTION"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "EI_PERSON_PLAN_RELTN"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "ENC_CODING"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "FC_FILL_BATCH_HX"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "LOC_CODE_VALUE_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "LOC_LOCATION_IND"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MA_ORDER_RADIOLOGY"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "MA_RAD_MED_DETAILS"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PER_CODING"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "SR_CODE_VALUE"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "SR_SERVICE_RESOURCE"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PD_EQUIP_MASTER"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PD_ITEM_CLASS_NODE"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET cntr = (cntr+ 1)
 IF (mod(cntr,10)=1)
  SET stat = alterlist(gm_i_dm_info2388_req->qual,(cntr+ 9))
 ENDIF
 SET gm_i_dm_info2388_req->qual[cntr].info_domain = "PI EDW DRIVER TABLES"
 SET gm_i_dm_info2388_req->qual[cntr].info_name = "PD_SEG_HEADER"
 SET gm_i_dm_info2388_req->qual[cntr].info_char = "Y"
 SET stat = alterlist(gm_i_dm_info2388_req->qual,cntr)
 EXECUTE gm_i_dm_info2388  WITH replace(request,gm_i_dm_info2388_req), replace(reply,
  gm_i_dm_info2388_rep)
 FREE RECORD gm_i_dm_info2388_req
 FREE RECORD gm_i_dm_info2388_rep
 COMMIT
 SELECT INTO  $67
  di.info_domain, di.info_name, di.info_date";;Q",
  di.info_char, di.info_number, di.info_long_id,
  di.updt_applctx, di.updt_cnt, di.updt_dt_tm";;Q",
  di.updt_id, di.updt_task
  FROM dm_info di
  WHERE di.info_domain="PI EDW"
  WITH nocounter, format, separator = " "
 ;end select
 SET script_version = "010 10/06/06  MG010594"
END GO

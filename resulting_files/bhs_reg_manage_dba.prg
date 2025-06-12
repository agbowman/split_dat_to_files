CREATE PROGRAM bhs_reg_manage:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter the Practice's Password" = "",
  "Choose a physician" = 0,
  "Choose the patient you wish to change" = 0,
  "Choose the registry type" = "",
  "New Active Indicator" = "",
  "Please enter a reason" = ""
  WITH outdev, practice_pwd, pcp_id,
  person_id, registry_type, active_ind,
  reason
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE ml_param_reg_type = i4 WITH protect, constant(5)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_param_list_size = i4 WITH protect, noconstant(0)
 DECLARE ml_rows_updated = i4 WITH protect, noconstant(0)
 DECLARE mn_invalid_input_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_param_datatype = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 IF (validate(mc_status)=0)
  DECLARE mc_status = c1 WITH protect, noconstant("Z")
 ENDIF
 IF (validate(mc_error_msg)=0)
  DECLARE ms_error_msg = vc WITH protect, noconstant(" ")
 ENDIF
 IF (validate(mc_error_reason)=0)
  DECLARE ms_failure_reason = vc WITH protect, noconstant(" ")
 ENDIF
 SET mc_status = "F"
 SET ms_error_msg = " "
 SET ms_failure_reason = " "
 FREE RECORD m_reg_types
 RECORD m_reg_types(
   1 types[*]
     2 s_type = vc
 )
 IF (validate(reqinfo->updt_id)=0)
  IF (mn_invalid_input_ind=0)
   SET mn_invalid_input_ind = 1
   SET ms_failure_reason = "Reqinfo->updt_id is undefined"
  ENDIF
 ENDIF
 IF (( $PERSON_ID <= 0))
  IF (mn_invalid_input_ind=0)
   SET mn_invalid_input_ind = 1
   SET ms_failure_reason = build("Invalid person_id:", $PERSON_ID)
  ENDIF
 ENDIF
 SET ms_param_datatype = reflect(parameter(ml_param_reg_type,0))
 IF (ml_debug_flag >= 1)
  CALL echo(build("Registry type datatype:",ms_param_datatype))
 ENDIF
 CASE (substring(1,1,ms_param_datatype))
  OF "C":
   IF ((( NOT (( $REGISTRY_TYPE IN ("", " ", null)))) OR (( $REGISTRY_TYPE="A")
    AND ( $REGISTRY_TYPE="B"))) )
    SET stat = alterlist(m_reg_types->types,1)
    SET m_reg_types->types[1].s_type = parameter(ml_param_reg_type,0)
   ELSE
    SET stat = alterlist(m_reg_types->types,1)
    SET m_reg_types->types[1].s_type = "<none selected>"
    SET mn_invalid_input_ind = 1
    SET ms_failure_reason = build(ms_param_datatype,"> Unselected registry type")
   ENDIF
  OF "L":
   SET ml_param_list_size = cnvtint(substring(2,(textlen(ms_param_datatype) - 1),ms_param_datatype))
   FOR (ml_loop = 1 TO ml_param_list_size)
    SET stat = alterlist(m_reg_types->types,ml_loop)
    SET m_reg_types->types[ml_loop].s_type = parameter(ml_param_reg_type,ml_loop)
   ENDFOR
  OF " ":
   IF (mn_invalid_input_ind=0)
    SET mn_invalid_input_ind = 1
    SET ms_failure_reason = build(ms_param_datatype,"> Registry type parameter not found")
   ENDIF
  OF "G":
   IF (mn_invalid_input_ind=0)
    SET mn_invalid_input_ind = 1
    SET ms_failure_reason = build(ms_param_datatype,"> NULL registry type")
   ENDIF
  ELSE
   IF (mn_invalid_input_ind=0)
    SET mn_invalid_input_ind = 1
    SET ms_failure_reason = build(ms_param_datatype,"> Registry type cannot be numeric")
   ENDIF
 ENDCASE
 IF ( NOT (( $ACTIVE_IND IN ("Y", "N"))))
  IF (mn_invalid_input_ind=0)
   SET mn_invalid_input_ind = 1
   SET ms_failure_reason = build("Unselected active indicator (Active/Inactive)")
  ENDIF
 ENDIF
 IF (mn_invalid_input_ind=1)
  GO TO exit_script
 ENDIF
 IF (size(m_reg_types->types,5)=1)
  UPDATE  FROM bhs_tmp_reg_backflow
   SET active_ind = cnvtupper( $ACTIVE_IND), active_ind_dt_tm = sysdate, active_ind_reason =  $REASON,
    active_ind_prsnl_id = reqinfo->updt_id
   WHERE (person_id= $PERSON_ID)
    AND registry_type=patstring(m_reg_types->types[1].s_type)
   WITH nocounter
  ;end update
 ELSE
  UPDATE  FROM bhs_tmp_reg_backflow reg
   SET reg.active_ind = cnvtupper( $ACTIVE_IND), reg.active_ind_dt_tm = sysdate, reg
    .active_ind_reason =  $REASON,
    reg.active_ind_prsnl_id = reqinfo->updt_id
   WHERE (reg.person_id= $PERSON_ID)
    AND expand(ml_idx,1,size(m_reg_types->types,5),reg.registry_type,m_reg_types->types[ml_idx].
    s_type)
   WITH nocounter
  ;end update
 ENDIF
 SET ml_rows_updated = curqual
 IF (error(ms_error_msg,1) != 0)
  SET ms_failure_reason = "Error encountered while updating BHS_TMP_REG_BACKFLOW"
  GO TO exit_script
 ENDIF
 SET mc_status = "S"
#exit_script
 IF (mc_status="S")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 SELECT INTO value( $OUTDEV)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   ms_line = concat("Script Name:     ",curprog), row 0, col 0,
   ms_line
   IF (mc_status="S")
    ms_line = concat("Status:          SUCCESS"), row + 1, col 0,
    ms_line, ms_line = concat("Registry entries sucessfully updated: ",cnvtstring(ml_rows_updated)),
    row + 1,
    col 0, ms_line, ms_line = concat(
     "All updates will be reflected in the next registry report refresh."),
    row + 1, col 0, ms_line
   ELSE
    ms_line = concat("Status:          FAILURE"), row + 1, col 0,
    ms_line, ms_line = concat("Failure Reason:  ",ms_failure_reason), row + 1,
    col 0, ms_line, ms_line = concat("Error Message:   ",ms_error_msg),
    row + 1, col 0, ms_line
   ENDIF
   ms_line = concat("Person ID:      ",cnvtstring( $PERSON_ID)), row + 2, col 0,
   ms_line, ms_line = concat("Registry Type:  ",evaluate(m_reg_types->types[1].s_type,"*","* <all>",
     m_reg_types->types[1].s_type)), row + 1,
   col 0, ms_line
   FOR (ml_loop = 2 TO size(m_reg_types->types,5))
     row + 1, col 16, m_reg_types->types[ml_loop].s_type
   ENDFOR
   ms_line = concat("Active ind:     ",cnvtupper( $ACTIVE_IND)), row + 1, col 0,
   ms_line, ms_line = concat("Reason:         ", $REASON), row + 1,
   col 0, ms_line
  WITH nocounter, formfeed = none, format = variable
 ;end select
END GO

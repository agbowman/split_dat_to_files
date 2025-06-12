CREATE PROGRAM bhs_eks_prev_nurse_loc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Previous Location Nurse Unit CD:" = "",
  "Semicolon delimited list of Nurse Unit Display Keys:" = ""
  WITH outdev, prev_nurse_unit_cd, nurse_unit_disp_keys
 SET retval = 0
 DECLARE mn_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE ms_nurse_unit_disp_keys = vc WITH protect, noconstant(" ")
 DECLARE ms_nurse_unit_disp_key = vc WITH protect, noconstant(" ")
 DECLARE mn_input_end = i4 WITH protect, noconstant(0)
 DECLARE mn_input_start = i4 WITH protect, noconstant(1)
 DECLARE mn_idx = i4 WITH protect, noconstant(1)
 DECLARE mf_prev_nurse_unit_cd = f8 WITH protect, noconstant(1.0)
 FREE RECORD nurse_units
 RECORD nurse_units(
   1 qual[*]
     2 s_nurse_unit_disp_key = vc
     2 f_nurse_unit_cd = f8
 )
 IF (validate(bhs_nurse_units)=1)
  SET ms_nurse_unit_disp_keys = trim(bhs_nurse_units,4)
 ELSE
  SET ms_nurse_unit_disp_keys = trim( $NURSE_UNIT_DISP_KEYS,4)
 ENDIF
 IF (validate(request->o_loc_nurse_unit_cd))
  SET mf_prev_nurse_unit_cd = request->o_loc_nurse_unit_cd
 ELSE
  SET mf_prev_nurse_unit_cd = cnvtint( $PREV_NURSE_UNIT_CD)
 ENDIF
 SET mn_input_start = 1
 SET mn_input_end = (findstring(";",ms_nurse_unit_disp_keys) - 1)
 IF ((mn_input_end=- (1)))
  SET mn_input_end = textlen(ms_nurse_unit_disp_keys)
 ENDIF
 WHILE (mn_input_end > mn_input_start)
   SET stat = alterlist(nurse_units->qual,(size(nurse_units->qual,5)+ 1))
   SET ms_nurse_unit_disp_key = cnvtupper(substring(mn_input_start,((mn_input_end - mn_input_start)+
     1),ms_nurse_unit_disp_keys))
   SET nurse_units->qual[size(nurse_units->qual,5)].s_nurse_unit_disp_key = ms_nurse_unit_disp_key
   SET nurse_units->qual[size(nurse_units->qual,5)].f_nurse_unit_cd = uar_get_code_by("DISPLAYKEY",
    220,ms_nurse_unit_disp_key)
   SET mn_input_start = (mn_input_end+ 2)
   SET mn_input_end = (findstring(";",ms_nurse_unit_disp_keys,mn_input_start) - 1)
   IF ((mn_input_end=- (1)))
    SET mn_input_end = textlen(ms_nurse_unit_disp_keys)
   ENDIF
 ENDWHILE
 IF (mn_debug_flag > 1)
  CALL echo("############################################")
  CALL echo(build("mf_prev_nurse_unit_cd:",mf_prev_nurse_unit_cd))
  CALL echo(build("ms_nurse_unit_disp_keys:",ms_nurse_unit_disp_keys))
  CALL echorecord(nurse_units)
  CALL echo("############################################")
 ENDIF
 IF (size(nurse_units->qual,5)=0)
  CALL echo("No nurse unit display keys found in the input")
  CALL echo(build("ms_nurse_unit_disp_keys:",ms_nurse_unit_disp_keys))
  GO TO exit_script
 ENDIF
 FOR (mn_idx = 1 TO size(nurse_units->qual,5))
   IF ((nurse_units->qual[mn_idx].f_nurse_unit_cd <= 0))
    CALL echo(build("!!!WARNING!!!  Invalid nurse unit found! [",nurse_units->qual[mn_idx].
      s_nurse_unit_disp_key,"]"))
   ENDIF
 ENDFOR
 IF (expand(mn_idx,1,size(nurse_units->qual,5),mf_prev_nurse_unit_cd,nurse_units->qual[mn_idx].
  f_nurse_unit_cd))
  SET retval = 100
 ENDIF
#exit_script
 CALL echo(build("retval:",retval))
END GO

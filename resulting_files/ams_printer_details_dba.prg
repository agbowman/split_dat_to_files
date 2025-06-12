CREATE PROGRAM ams_printer_details:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Printer Name" = ""
  WITH outdev, pname
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SELECT INTO  $1
  name = d.name, printer_type = uar_get_code_display(p.printer_type_cd), label_prefix = od
  .label_prefix,
  lable_program_name = od.label_program_name, device_code = uar_get_code_display(od.device_cd),
  location = uar_get_code_display(d.location_cd),
  device_type = uar_get_code_display(d.device_type_cd)
  FROM printer p,
   device d,
   output_dest od
  PLAN (p)
   JOIN (d
   WHERE p.device_cd=d.device_cd
    AND (cnvtupper(d.name)= $PNAME))
   JOIN (od
   WHERE od.device_cd=d.device_cd)
  WITH time = 1000, format, nocounter
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO

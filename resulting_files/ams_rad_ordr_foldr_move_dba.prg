CREATE PROGRAM ams_rad_ordr_foldr_move:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "ACT_TY" = 0,
  "Ordereables" = 0,
  "Folders" = 0,
  "Sub Folders" = 0
  WITH outdev, at, ord,
  fd, sf
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
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE prompt_reflect = vc WITH noconstant(reflect(parameter(3,0))), private
 DECLARE count = i2
 IF (prompt_reflect="F8")
  SET count = 1
 ELSE
  SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
 ENDIF
 CALL echo(prompt_reflect)
 CALL echo(count)
 DECLARE i = i4 WITH protect
 DECLARE r_val = vc WITH protect
 IF (count > 0)
  SET rval = "("
  FOR (i = 1 TO count)
   IF (mod(i,100)=1
    AND i > 1)
    SET r_val = replace(r_val,",",")",2)
   ENDIF
   IF (substring(1,1,reflect(parameter(3,i)))="F")
    SET r_val = build(r_val,value(parameter(3,i)),",")
   ENDIF
  ENDFOR
 ENDIF
 FREE RECORD request_data
 RECORD request_data(
   1 qual[*]
     2 catalog_cd = f8
     2 lib_group_cd = f8
     2 image_class_type_cd = f8
     2 required_ind = i2
 )
 SET stat = alterlist(request_data->qual,count)
 FOR (i = 1 TO count)
   SET request_data->qual[i].catalog_cd = cnvtreal(piece(r_val,",",i,"",1))
   SET request_data->qual[i].lib_group_cd =  $FD
   SET request_data->qual[i].image_class_type_cd =  $SF
   SET request_data->qual[i].required_ind = 1
 ENDFOR
 CALL echorecord(request_data)
 EXECUTE rad_add_exam_folder  WITH replace(request,request_data)
 SELECT INTO  $OUTDEV
  status = "Succesfully Moved"
  FROM dummyt d1
 ;end select
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO

CREATE PROGRAM bhs_get_bed_mgmt_assgmnt:dba
 EXECUTE bhs_hlp_csv
 DECLARE unit_param = vc WITH protect, noconstant(" ")
 DECLARE remove_status = vc WITH protect, noconstant(" ")
 DECLARE room_param = vc WITH procect, noconstant(" ")
 DECLARE bed_param = vc WITH procect, noconstant(" ")
 DECLARE temp_status = vc WITH protect, noconstant(" ")
 DECLARE bed_status_result = vc WITH protect, noconstant(" ")
 DECLARE fac_param = vc WITH protect, noconstant(" ")
 DECLARE bed_status_cd = vc WITH protect, noconstant(" ")
 DECLARE group_display = vc WITH protect, noconstant(" ")
 DECLARE trigger_personid = f8 WITH protect, noconstant(0.0)
 DECLARE full_display = vc WITH protect, noconstant("N")
 DECLARE unit_display = vc WITH protect, noconstant("Y")
 DECLARE room_display = vc WITH protect, noconstant("Y")
 DECLARE bed_display = vc WITH protect, noconstant("Y")
 DECLARE unit = vc WITH protect, noconstant("")
 DECLARE room = vc WITH protect, noconstant("")
 DECLARE bed = vc WITH protect, noconstant("")
 SET retval = 0
 CALL echo(build("***** getting bed data ******* "))
 SET temp_status =  $1
 SET remove_status = substring(1,13, $1)
 SET stat = getcsvcolumnatindex(temp_status,2,unit_param,"~",'"')
 IF (unit_param="")
  SET unit_display = "N"
 ENDIF
 SET stat = getcsvcolumnatindex(temp_status,3,room_param,"~",'"')
 IF (room_param="")
  SET room_display = "N"
 ENDIF
 SET stat = getcsvcolumnatindex(temp_status,4,bed_param,"~",'"')
 IF (bed_param="")
  SET bed_display = "N"
 ENDIF
 SET stat = getcsvcolumnatindex(temp_status,5,fac_param,"~",'"')
 SET stat = getcsvcolumnatindex(temp_status,6,bed_status_cd,"~",'"')
 IF (bed_status_cd != "")
  SET full_display = "Y"
  IF (bed_status_cd="A")
   SET bed_status_result = "Available"
  ENDIF
  IF (bed_status_cd="I")
   SET bed_status_result = "InProgress"
  ENDIF
  IF (((bed_status_cd="C") OR (((bed_status_cd="D") OR (((bed_status_cd="S") OR (((bed_status_cd="N")
   OR (bed_status_cd="L")) )) )) )) )
   SET bed_status_result = "Dirty"
  ENDIF
  IF (bed_status_cd="O")
   SET bed_status_result = "Occupied"
  ENDIF
  IF (bed_status_cd="U")
   SET bed_status_result = "Unoccupied"
  ENDIF
 ELSE
  SET bed_status_result = "            "
 ENDIF
 IF (unit_display != "N")
  SET group_display = unit_param
 ENDIF
 IF (room_display != "N")
  SET group_display = build(unit_param,"-",room_param)
 ENDIF
 IF (bed_display != "N")
  SET group_display = build(unit_param,"-",room_param,"-",bed_param)
 ENDIF
 IF (full_display="Y")
  SET group_display = build(unit_param,"-",room_param,"-",bed_param,
   " :",bed_status_result)
 ENDIF
 IF (unit_display="N"
  AND room_display="N"
  AND bed_display="N"
  AND full_display="N")
  SET group_display = " "
 ENDIF
 IF (remove_status="REMOVEUNITBED")
  SET group_display = "No Longer Assigned to Unit/Bed"
 ENDIF
 SET log_misc1 = group_display
 CALL echo(build("log_misc1 ",log_misc1))
 SET log_message = log_misc1
 CALL echo(build("***** exit_success ******* "))
 SET retval = 100
 CALL echorecord(request)
 CALL echorecord(reqinfo)
 COMMIT
END GO

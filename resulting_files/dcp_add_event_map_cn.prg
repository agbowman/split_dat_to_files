CREATE PROGRAM dcp_add_event_map_cn
 DECLARE correspondance_type = f8 WITH noconstant(0.0)
 DECLARE event_set_name = vc WITH noconstant(" ")
 DECLARE mapped_event_set_name = vc WITH noconstant(" ")
 DECLARE inherit_flag = i2 WITH noconstant(0)
 DECLARE scripttocall = vc WITH constant("DCP_ADD_RESULT_TO_EVENT_MAP")
 RECORD req_to_fill(
   1 correspond_type_cd = f8
   1 eventstomap[*]
     2 event_set_name = c255
     2 mapped_event_set_name = c255
     2 inherit_flag = i2
 )
 RECORD rep_status(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#main_app
 IF (prompt_user_for_corrtype(null)=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(req_to_fill->eventstomap,1)
 SET req_to_fill->correspond_type_cd = correspondance_type
 SET req_to_fill->eventstomap[1].event_set_name = event_set_name
 SET req_to_fill->eventstomap[1].mapped_event_set_name = mapped_event_set_name
 SET req_to_fill->eventstomap[1].inherit_flag = inherit_flag
 CALL echo("#########################  HERE WE ARE ####################")
 SELECT INTO "nl:"
  FROM corr_event_set_mapping cesm
  WHERE (cesm.correspondence_type_cd=req_to_fill->correspond_type_cd)
   AND (cesm.event_set_name=req_to_fill->eventstomap[1].event_set_name)
   AND (cesm.mapped_event_set_name=req_to_fill->eventstomap[1].mapped_event_set_name)
   AND (cesm.inheritance_flag=req_to_fill->eventstomap[1].inherit_flag)
  WITH nocounter
 ;end select
 IF ( NOT (curqual=0))
  EXECUTE prompt_error_msg null
  GO TO exit_script
 ENDIF
 CALL echo("#########################  HERE@2 WE ARE ####################")
 EXECUTE value(scripttocall)  WITH replace("REQUEST",req_to_fill), replace("REPLY",rep_status)
 CALL echo(build(" HERE@2 WE ARE ",rep_status->status_data.status))
 IF ((rep_status->status_data.status="S"))
  SET status = prompt_success(null)
  IF (status=1)
   GO TO main_app
  ENDIF
  IF (status=0)
   SET rep_status->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF (status=2)
   GO TO exit_script
  ENDIF
 ELSE
  IF (prompt_failed(null))
   GO TO main_app
  ENDIF
  GO TO exit_script
 ENDIF
 SUBROUTINE prompt_success(null)
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(5,1,"Row(s) added for table: ",w)
   CALL text(10,1,">>> Enter 'Q' to quit, 'C' to add another row or 'A' to commit the add:")
   CALL accept(10,75,"A;cu","Q"
    WHERE curaccept IN ("Q", "C", "A"))
   SET choice = curaccept
   SET message = nowindow
   IF (choice="Q")
    RETURN(0)
   ENDIF
   IF (choice="C")
    RETURN(1)
   ELSE
    RETURN(2)
   ENDIF
   SET message = nowindow
 END ;Subroutine
 SUBROUTINE prompt_failed(null)
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(5,1,"FAILED to add Row to table: ",w)
   CALL text(10,1,">>> Enter 'Q' to quit or 'C' to add another row:")
   CALL accept(10,53,"A;cu","Q"
    WHERE curaccept IN ("Q", "C"))
   SET choice = curaccept
   SET message = nowindow
   IF (choice="Q")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE prompt_error_msg(null)
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(5,1,"Row already exists on table: ",w)
   CALL text(10,1,">>> Enter 'Q' to quit or 'C' to add another row:")
   CALL accept(10,70,"A;cu","Q"
    WHERE curaccept IN ("Q", "C"))
   SET choice = curaccept
   SET message = nowindow
   IF (choice="Q")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE prompt_user_for_corrtype(null)
   DECLARE choice = vc WITH private, noconstant(" ")
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(2,1,"Add result to the event map: ",w)
   CALL text(4,1,">>> Enter a Correspondence_type_cd:")
   CALL accept(4,36,"99999999999999999;C"," "
    WHERE  NOT (curaccept=" "))
   SET correspondance_type = cnvtreal(curaccept)
   SET curaccept = " "
   CALL text(5,1,">>> Enter a event_set_name:")
   CALL accept(5,28,"P(132);C"," "
    WHERE  NOT (curaccept=" "))
   SET event_set_name = curaccept
   SET curaccept = " "
   CALL text(6,1,">>> Enter a mapped_event_set_name:")
   CALL accept(6,35,"P(132);C"," "
    WHERE  NOT (curaccept=" "))
   SET mapped_event_set_name = curaccept
   SET inherit_flag = 0
   SET curaccept = " "
   CALL text(10,1,">>> Enter 'Q' to quit or 'C' to Continue:")
   CALL accept(10,53,"A;cu","C"
    WHERE curaccept IN ("Q", "C"))
   SET choice = curaccept
   SET message = nowindow
   IF (choice="Q")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
#exit_script
END GO

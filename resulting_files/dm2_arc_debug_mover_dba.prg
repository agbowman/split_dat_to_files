CREATE PROGRAM dm2_arc_debug_mover:dba
 IF ((validate(damp_request->restore,- (1))=- (1)))
  RECORD damp_request(
    1 restore[*]
      2 person_id = f8
      2 archive_env_id = f8
      2 all_tab_ind = i2
    1 archive[*]
      2 person_id = f8
      2 archive_env_id = f8
    1 mover_name = vc
  )
 ENDIF
 IF (validate(damp_reply->status_data.status,"X")="X")
  RECORD damp_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE dadm_direction = vc
 SET dadm_direction = cnvtupper( $1)
 FREE RECORD debug_mover
 RECORD debug_mover(
   1 debug_level = i2
 )
 SET debug_mover->debug_level =  $4
 IF (dadm_direction="R")
  SET stat = alterlist(damp_request->restore,1)
  SET damp_request->restore[1].person_id =  $2
  SELECT INTO "nl:"
   p.archive_env_id
   FROM person p
   WHERE (person_id=damp_request->restore[1].person_id)
   DETAIL
    damp_request->restore[1].archive_env_id = p.archive_env_id
   WITH nocounter
  ;end select
  SET damp_request->restore[1].all_tab_ind =  $3
 ELSEIF (dadm_direction="A")
  SET stat = alterlist(damp_request->archive,1)
  SET damp_request->archive[1].person_id =  $2
  SELECT INTO "nl:"
   di.info_number
   FROM dm_arc_info di
   WHERE di.info_domain="ARCHIVE-PERSON"
    AND info_name="ACTIVE ARCHIVE"
    AND cnvtdatetime(curdate,curtime3) BETWEEN beg_effective_dt_tm AND end_effective_dt_tm
   DETAIL
    damp_request->archive[1].archive_env_id = di.info_number
   WITH nocounter
  ;end select
 ELSE
  CALL echo("Invalid Direction: please choose either (R)estore or (A)rchive")
  GO TO get_out
 ENDIF
 EXECUTE dm2_arc_move_person  WITH replace("REQUEST","DAMP_REQUEST"), replace("REPLY","DAMP_REPLY")
#get_out
 CALL echorecord(damp_reply)
END GO

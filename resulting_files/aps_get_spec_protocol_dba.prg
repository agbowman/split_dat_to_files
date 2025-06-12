CREATE PROGRAM aps_get_spec_protocol:dba
 RECORD reply(
   1 qual[*]
     2 protocol_id = f8
     2 spec_cd = f8
     2 spec_disp = c40
     2 prefix_id = f8
     2 prefix_name = c4
     2 site_cd = f8
     2 site_disp = c40
     2 path_id = f8
     2 path_disp = c40
     2 path_disc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SELECT INTO "nl:"
  asp.prefix_id
  FROM ap_specimen_protocol asp,
   dummyt d1,
   ap_prefix ap,
   dummyt d2,
   prsnl p
  PLAN (asp
   WHERE parser(
    IF ((request->spec_cd > 0)) "request->spec_cd         = asp.specimen_cd"
    ELSE "0                        = 0"
    ENDIF
    )
    AND parser(
    IF ((request->prefix_cd > 0)) "request->prefix_cd       = asp.prefix_id"
    ELSE "0                        = 0"
    ENDIF
    )
    AND parser(
    IF ((request->path_id > 0)) "request->path_id         = asp.pathologist_id"
    ELSE "0                        = 0"
    ENDIF
    )
    AND asp.protocol_id != 0)
   JOIN (d1)
   JOIN (ap
   WHERE asp.prefix_id=ap.prefix_id)
   JOIN (d2)
   JOIN (p
   WHERE asp.pathologist_id=p.person_id)
  HEAD REPORT
   ncnt = 0
  DETAIL
   ncnt = (ncnt+ 1), stat = alterlist(reply->qual,ncnt), reply->qual[ncnt].protocol_id = asp
   .protocol_id,
   reply->qual[ncnt].spec_cd = asp.specimen_cd, reply->qual[ncnt].prefix_id = asp.prefix_id, reply->
   qual[ncnt].prefix_name = ap.prefix_name,
   reply->qual[ncnt].site_cd = ap.site_cd, reply->qual[ncnt].path_id = asp.pathologist_id, reply->
   qual[ncnt].path_disp = p.name_full_formatted,
   reply->qual[ncnt].path_disc = p.name_full_formatted
  WITH outerjoin = d1, dontcare = ap, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL handle_errors("SELECT","Z","TABLE","AP_SPECIMEN_PROTOCOL")
 ENDIF
 GO TO exit_script
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  CALL echo("<<<<< ROLLBACK <<<<<")
  CALL echo(error_cnt)
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
END GO

CREATE PROGRAM dm2_arc_upd_pers_last_acc_c:dba
 SET stat = error(reply->err_msg,1)
 SET reply->err_num = 0
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id=request->person_id)
  WITH forupdate(p)
 ;end select
 IF (curqual=0)
  SET reply->err_num = 0
  GO TO exit_program
 ENDIF
 UPDATE  FROM person p
  SET p.last_accessed_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE (p.person_id=request->person_id)
  WITH nocounter
 ;end update
 SET reply->err_num = error(reply->err_msg,0)
#exit_program
 IF ((reply->err_num=0))
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO

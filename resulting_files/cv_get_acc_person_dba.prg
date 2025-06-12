CREATE PROGRAM cv_get_acc_person:dba
 RECORD reply(
   1 person_rec_cnt = i2
   1 person_rec[*]
     2 last_name = vc
     2 first_name = vc
     2 middle_init = c4
     2 ssn = c15
     2 birth_dt = dq8
     2 gender = c6
     2 person_id = f8
     2 encntr_id = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET person_size = size(reply->person_rec,5)
 SET failed = "F"
 SET active_ind = 0
 SET person_id = 0
 SET encntr_id = 0
 SET tot_cnt = 0
 SET inx0 = 0
 SET prsn_cnt = 0
 SET tot_rec = value(size(request->get_rec,5))
 FOR (inx0 = 1 TO tot_rec)
   SELECT
    IF ((((request->get_rec[inx0].active_ind=1)) OR ((request->get_rec[inx0].active_ind=0)))
     AND (request->get_rec[inx0].person_id > 0)
     AND (request->get_rec[inx0].encntr_id > 0))
     WHERE (per.person_id=request->get_rec[inx0].person_id)
      AND (per.encntr_id=request->get_rec[inx0].encntr_id)
      AND (per.active_ind=request->get_rec[inx0].active_ind)
    ELSEIF ((((request->get_rec[inx0].active_ind=1)) OR ((request->get_rec[inx0].active_ind=0)))
     AND (request->get_rec[inx0].encntr_id=0)
     AND (request->get_rec[inx0].person_id > 0))
     WHERE (per.person_id=request->get_rec[inx0].person_id)
      AND (per.active_ind=request->get_rec[inx0].active_ind)
      AND (per.encntr_id != request->get_rec[inx0].encntr_id)
    ELSEIF ((((request->get_rec[inx0].active_ind=1)) OR ((request->get_rec[inx0].active_ind=0)))
     AND (request->get_rec[inx0].person_id=0)
     AND (request->get_rec[inx0].encntr_id > 0))
     WHERE (per.encntr_id=request->get_rec[inx0].encntr_id)
      AND (per.active_ind=request->get_rec[inx0].active_ind)
      AND (per.person_id != request->get_rec[inx0].person_id)
    ELSEIF ((request->get_rec[inx0].active_ind > 1)
     AND (request->get_rec[inx0].person_id > 0)
     AND (request->get_rec[inx0].encntr_id > 0))
     WHERE (per.person_id=request->get_rec[inx0].person_id)
      AND (per.encntr_id=request->get_rec[inx0].encntr_id)
    ELSEIF ((request->get_rec[inx0].active_ind > 1)
     AND (request->get_rec[inx0].person_id > 0)
     AND (request->get_rec[inx0].encntr_id=0))
     WHERE (per.person_id=request->get_rec[inx0].person_id)
    ELSEIF ((request->get_rec[inx0].active_ind > 1)
     AND (request->get_rec[inx0].person_id=0)
     AND (request->get_rec[inx0].encntr_id > 0))
     WHERE (per.encntr_id=request->get_rec[inx0].encntr_id)
    ELSE
     WHERE per.person_id=0
      AND per.encntr_id=0
    ENDIF
    INTO "nl:"
    per.last_name, per.first_name, per.middle_init,
    per.ssn, per.birth_dt, per.gender,
    per.person_id, per.encntr_id, per.active_ind
    FROM cv_acc_person per
    DETAIL
     prsn_cnt = (prsn_cnt+ 1), stat = alterlist(reply->person_rec,prsn_cnt), reply->person_rec[
     prsn_cnt].last_name = per.last_name,
     reply->person_rec[prsn_cnt].first_name = per.first_name, reply->person_rec[prsn_cnt].middle_init
      = per.middle_init, reply->person_rec[prsn_cnt].ssn = per.ssn,
     reply->person_rec[prsn_cnt].birth_dt = per.birth_dt, reply->person_rec[prsn_cnt].gender = per
     .gender, reply->person_rec[prsn_cnt].active_ind = per.active_ind,
     reply->person_rec[prsn_cnt].person_id = per.person_id, reply->person_rec[prsn_cnt].encntr_id =
     per.encntr_id
    FOOT REPORT
     reply->person_rec_cnt = prsn_cnt
    WITH nocounter
   ;end select
 ENDFOR
 IF (curqual=0)
  SET failed = "T"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_GET_ACC_PERSON"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

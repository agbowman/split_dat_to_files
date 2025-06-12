CREATE PROGRAM dcp_chk_active_preg
 RECORD reply(
   1 pregnancy_id = f8
   1 pregnancy_instance_id = f8
   1 onset_dt_tm = dq8
   1 onset_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 RECORD temprequest(
   1 patient_list[*]
     2 patient_id = f8
     2 encntr_id = f8
   1 org_sec_override = i2
 )
 DECLARE stat = i4
 SET stat = alterlist(temprequest->patient_list,1)
 SET temprequest->patient_list[1].patient_id = request->patient_id
 IF (validate(request->encntr_id)=0)
  SET temprequest->patient_list[1].encntr_id = 0
 ELSE
  SET temprequest->patient_list[1].encntr_id = request->encntr_id
 ENDIF
 IF (validate(request->org_sec_override)=0)
  SET temprequest->org_sec_override = 0
 ELSE
  SET temprequest->org_sec_override = request->org_sec_override
 ENDIF
 SET reply->status_data.status = "F"
 IF ((request->patient_id=0.0))
  SET reply->status_data.status = "Z"
  GO TO script_end
 ENDIF
 EXECUTE dcp_chk_active_preg_list  WITH replace("REQUEST",temprequest), replace("REPLY",tempreply)
 IF ((tempreply->status_data.status="F"))
  CALL echo("[FAIL]: DCP_CHK_ACTIVE_PREG_LIST failed")
  SET reply->status_data.status = "F"
  GO TO script_end
 ELSEIF ((tempreply->status_data.status="Z"))
  CALL echo("[ZERO]: Active pregnancy could not be found")
  SET reply->status_data.status = "Z"
  GO TO script_end
  GO TO script_end
 ENDIF
 IF ((tempreply->patient_list[1].pregnancy_id >= 0))
  SET reply->pregnancy_id = tempreply->patient_list[1].pregnancy_id
  SET reply->pregnancy_instance_id = tempreply->patient_list[1].pregnancy_instance_id
  SET reply->status_data.status = "S"
  SELECT INTO "nl:"
   pb.onset_dt_tm, p.person_id, pi.problem_id,
   pi.person_id, pb.person_id, pb.onset_tz
   FROM person p,
    pregnancy_instance pi,
    problem pb
   PLAN (p
    WHERE (p.person_id=request->patient_id))
    JOIN (pi
    WHERE p.person_id=pi.person_id
     AND (pi.pregnancy_id=reply->pregnancy_id)
     AND pi.active_ind=1
     AND pi.historical_ind=0)
    JOIN (pb
    WHERE p.person_id=pb.person_id
     AND pi.problem_id=pb.problem_id
     AND pb.problem_type_flag=2
     AND pb.active_ind=1)
   HEAD REPORT
    reply->onset_dt_tm = cnvtdatetime(cnvtdate(pb.onset_dt_tm),0), reply->onset_tz = pb.onset_tz
   WITH nocounter
  ;end select
 ENDIF
#script_end
END GO

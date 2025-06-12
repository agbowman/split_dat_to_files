CREATE PROGRAM co_get_patients_for_beds:dba
 RECORD reply(
   1 bedlist[*]
     2 unit_cd = f8
     2 room_cd = f8
     2 bed_cd = f8
     2 person_id = f8
     2 encntr_id = f8
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE sfailed = c2 WITH private, noconstant("S")
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE req_size = i4 WITH public, noconstant(size(request->bedlist,5))
 DECLARE inpatienttypeclasscd = f8 WITH noconstant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE expand_size = i4 WITH public, noconstant(40)
 DECLARE actual_size = i4 WITH public, noconstant(size(request->bedlist,5))
 DECLARE expand_total = i4 WITH public, noconstant((actual_size+ (expand_size - mod(actual_size,
   expand_size))))
 DECLARE expand_start = i4 WITH public, noconstant(1)
 DECLARE expand_stop = i4 WITH public, noconstant(40)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE censustypecd = f8 WITH public, constant(uar_get_code_by("MEANING",339,"CENSUS"))
 IF (size(request->bedlist,5) <= 0)
  SET sfailed = "E"
  GO TO failure_called_script
 ENDIF
 SET stat = alterlist(reply->bedlist,actual_size)
 FOR (i = 1 TO actual_size)
   SET reply->bedlist[i].unit_cd = request->bedlist[i].unit_cd
   SET reply->bedlist[i].room_cd = request->bedlist[i].room_cd
   SET reply->bedlist[i].bed_cd = request->bedlist[i].bed_cd
 ENDFOR
 SET stat = alterlist(reply->bedlist,expand_total)
 FOR (i = (actual_size+ 1) TO expand_total)
   SET reply->bedlist[i].unit_cd = request->bedlist[actual_size].unit_cd
   SET reply->bedlist[i].room_cd = request->bedlist[actual_size].room_cd
   SET reply->bedlist[i].bed_cd = request->bedlist[actual_size].bed_cd
 ENDFOR
 SELECT INTO "nl:"
  e.encntr_id
  FROM encntr_domain ed,
   encounter e,
   person p,
   (dummyt d  WITH seq = value((expand_total/ expand_size)))
  PLAN (d
   WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
    AND assign(expand_stop,(expand_start+ (expand_size - 1))))
   JOIN (ed
   WHERE expand(num,expand_start,expand_stop,ed.loc_nurse_unit_cd,reply->bedlist[num].unit_cd,
    ed.loc_room_cd,reply->bedlist[num].room_cd,ed.loc_bed_cd,reply->bedlist[num].bed_cd)
    AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ed.encntr_domain_type_cd=censustypecd
    AND ((ed.active_ind+ 0)=1)
    AND ((ed.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3)))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.loc_nurse_unit_cd=ed.loc_nurse_unit_cd
    AND ((e.loc_room_cd+ 0)=ed.loc_room_cd)
    AND ((e.loc_bed_cd+ 0)=ed.loc_bed_cd)
    AND ((e.active_ind+ 0)=1)
    AND ((e.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((e.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
    AND ((e.encntr_type_class_cd+ 0)=inpatienttypeclasscd))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND ((p.active_ind+ 0)=1)
    AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((p.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
  ORDER BY ed.encntr_id, cnvtdatetime(e.reg_dt_tm) DESC
  HEAD REPORT
   stat = alterlist(reply->bedlist,actual_size), count = 0
  HEAD ed.encntr_id
   index = locateval(num,1,actual_size,ed.loc_room_cd,reply->bedlist[num].room_cd,
    ed.loc_bed_cd,reply->bedlist[num].bed_cd), count = (count+ 1), reply->bedlist[index].person_id =
   p.person_id,
   reply->bedlist[index].encntr_id = e.encntr_id, reply->bedlist[index].reg_dt_tm = e.reg_dt_tm,
   reply->bedlist[index].disch_dt_tm = e.disch_dt_tm
  FOOT REPORT
   CALL echo(build("count = ",count))
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->bedlist,actual_size)
#failure_called_script
 IF (sfailed="E")
  SET reply->status_data.subeventstatus[1].operationname = "Execute co_get_patients_for_beds"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "co_get_patients_for_beds"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Empty request"
  GO TO exit_script
 ELSEIF (sfailed="C")
  SET reply->status_data.subeventstatus[1].operationname = "Execute co_get_patients_for_beds"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "co_get_patients_for_beds"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failure - co_get_patients_for_beds"
  GO TO exit_script
 ENDIF
#no_valid_ids
 IF (sfailed="I")
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "co_get_patients_for_beds"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid identifier in request"
  GO TO exit_script
 ELSEIF (sfailed="N")
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "co_get_patients_for_beds"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unit code in request is NOT a nurseunit"
  GO TO exit_script
 ENDIF
#unsupported_option
 IF (sfailed="U")
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "co_get_patients_for_beds"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Combination of Request Attribute values unsupported"
  GO TO exit_script
 ENDIF
#exit_script
 IF (sfailed="T")
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSEIF (((sfailed="I") OR (((sfailed="U") OR (sfailed="N")) )) )
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO

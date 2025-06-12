CREATE PROGRAM dcp_get_patients_in_unit:dba
 RECORD reply(
   1 patient_cnt = i2
   1 patient_list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 name_full_formatted = vc
     2 room_cd = f8
     2 bed_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET census_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 339
 SET cdf_meaning = "CENSUS"
 EXECUTE cpm_get_cd_for_cdf
 SET census_type_cd = code_value
 SELECT INTO "nl:"
  ed.encntr_id, p.name_full_formatted
  FROM encntr_domain ed,
   person p
  PLAN (ed
   WHERE ed.encntr_domain_type_cd=census_type_cd
    AND (ed.loc_nurse_unit_cd=request->unit_cd)
    AND ed.active_ind=1
    AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE ed.person_id=p.person_id)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->patient_list,5))
    stat = alterlist(reply->patient_list,(count1+ 20))
   ENDIF
   reply->patient_list[count1].person_id = ed.person_id, reply->patient_list[count1].encntr_id = ed
   .encntr_id, reply->patient_list[count1].name_full_formatted = p.name_full_formatted,
   reply->patient_list[count1].room_cd = ed.loc_room_cd, reply->patient_list[count1].bed_cd = ed
   .loc_bed_cd
  FOOT REPORT
   reply->patient_cnt = count1, stat = alterlist(reply->patient_list,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("patient cnt:",reply->patient_cnt))
 FOR (x = 1 TO count1)
   CALL echo(build("Patient:",reply->patient_list[x].name_full_formatted))
 ENDFOR
END GO

CREATE PROGRAM cps_get_assessment:dba
 RECORD reply(
   1 qual[*]
     2 dsm_assessment_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 diag_prsnl_id = f8
     2 diag_dt_tm = dq8
     2 status_ind = i2
     2 cgi1_cd = f8
     2 cgi2_cd = f8
     2 name_full_formatted = vc
     2 qual[*]
       3 dsm_component_id = f8
       3 axis_flag = i2
       3 nomenclature_id = f8
       3 component_desc1 = vc
       3 component_desc2 = vc
       3 component_seq = i2
       3 primary_diag_ind = i2
       3 assessment_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SELECT INTO "nl:"
  da.dsm_assessment_id, p.name_full_formatted
  FROM dsm_assessment da,
   prsnl p
  PLAN (da
   WHERE (da.encntr_id=request->encntr_id))
   JOIN (p
   WHERE p.person_id=da.diag_prsnl_id)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].dsm_assessment_id = da.dsm_assessment_id, reply->qual[count1].person_id = da
   .person_id, reply->qual[count1].encntr_id = da.encntr_id,
   reply->qual[count1].diag_prsnl_id = da.diag_prsnl_id, reply->qual[count1].diag_dt_tm = da
   .diag_dt_tm
   IF (da.active_ind=1
    AND da.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND da.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    reply->qual[count1].status_ind = 1
   ELSE
    reply->qual[count1].status_ind = 0
   ENDIF
   reply->qual[count1].cgi1_cd = da.cgi1_cd, reply->qual[count1].cgi2_cd = da.cgi2_cd, reply->qual[
   count1].name_full_formatted = p.name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dc.dsm_component_id
  FROM dsm_component dc,
   (dummyt d  WITH seq = value(count1))
  PLAN (d)
   JOIN (dc
   WHERE (dc.dsm_assessment_id=reply->qual[d.seq].dsm_assessment_id))
  ORDER BY dc.dsm_assessment_id
  HEAD dc.dsm_assessment_id
   count2 = 0
  DETAIL
   count2 = (count2+ 1)
   IF (mod(count2,10)=1)
    stat = alterlist(reply->qual[d.seq].qual,(count2+ 9))
   ENDIF
   reply->qual[d.seq].qual[count2].dsm_component_id = dc.dsm_component_id, reply->qual[d.seq].qual[
   count2].axis_flag = dc.axis_flag, reply->qual[d.seq].qual[count2].nomenclature_id = dc
   .nomenclature_id,
   reply->qual[d.seq].qual[count2].component_desc1 = dc.component_desc1, reply->qual[d.seq].qual[
   count2].component_desc2 = dc.component_desc2, reply->qual[d.seq].qual[count2].component_seq = dc
   .component_seq,
   reply->qual[d.seq].qual[count2].primary_diag_ind = dc.primary_diag_ind, reply->qual[d.seq].qual[
   count2].assessment_type_cd = dc.assessment_type_cd
  FOOT  dc.dsm_assessment_id
   stat = alterlist(reply->qual[d.seq].qual,count2)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

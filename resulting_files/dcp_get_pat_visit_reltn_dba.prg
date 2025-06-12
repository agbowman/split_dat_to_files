CREATE PROGRAM dcp_get_pat_visit_reltn:dba
 RECORD reply(
   1 data[*]
     2 reltn_disp = vc
     2 reltn_id = f8
     2 reltn_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count1 = i4
 DECLARE stat = i4
 DECLARE encntrcnt = i4
 SET encntrcnt = size(request->encntr_list,5)
 SET count1 = 0
 SET stat = 0.0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(encntrcnt)),
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (d1)
   JOIN (epr
   WHERE (epr.encntr_id=request->encntr_id)
    AND (((epr.encntr_prsnl_r_cd=request->encntr_list[d1.seq].encntr_prsnl_reltn_cd)) OR ((request->
   all_reltn_ind=1)))
    AND epr.expiration_ind=0
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id
    AND (pr.person_id=request->prsnl_id)
    AND pr.active_ind=1)
  ORDER BY epr.encntr_id DESC
  HEAD REPORT
   stat = alterlist(reply->data,10)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alterlist(reply->data,(count1+ 9))
   ENDIF
   reply->data[count1].reltn_disp = uar_get_code_display(epr.encntr_prsnl_r_cd), reply->data[count1].
   reltn_id = epr.encntr_prsnl_reltn_id, reply->data[count1].reltn_cd = epr.encntr_prsnl_r_cd
   IF (count1=0)
    reply->status_data.status = "Z"
   ELSE
    reply->status_data.status = "S"
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->data,count1)
 ;end select
END GO

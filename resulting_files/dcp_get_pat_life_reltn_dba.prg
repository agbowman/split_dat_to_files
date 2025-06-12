CREATE PROGRAM dcp_get_pat_life_reltn:dba
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
 DECLARE pprcnt = i4
 SET count1 = 0
 SET stat = 0.0
 SET pprcnt = size(request->ppr_list,5)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pprcnt)),
   person_prsnl_reltn ppr,
   prsnl pr
  PLAN (d1)
   JOIN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND (((ppr.person_prsnl_r_cd=request->ppr_list[d1.seq].person_prsnl_reltn_cd)) OR ((request->
   all_reltn_ind=1)))
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE (pr.person_id=request->prsnl_id)
    AND pr.person_id=ppr.prsnl_person_id
    AND pr.active_ind=1)
  ORDER BY cnvtupper(trim(pr.name_full_formatted,3))
  HEAD REPORT
   stat = alterlist(reply->data,10)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alterlist(reply->data,(count1+ 9))
   ENDIF
   reply->data[count1].reltn_disp = uar_get_code_display(ppr.person_prsnl_r_cd), reply->data[count1].
   reltn_id = ppr.person_prsnl_reltn_id, reply->data[count1].reltn_cd = ppr.person_prsnl_r_cd
   IF (count1=0)
    reply->status_data.status = "Z"
   ELSE
    reply->status_data.status = "S"
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->data,count1)
 ;end select
END GO

CREATE PROGRAM afc_get_bill_org:dba
 RECORD reply(
   1 bill_org_payor_qual = i4
   1 qual[*]
     2 org_payor_id = f8
     2 organization_id = f8
     2 bill_org_type_cd = f8
     2 bill_org_type_disp = c40
     2 bill_org_type_desc = c40
     2 bill_org_type_mean = c12
     2 bill_org_type_id = f8
     2 interface_file_cd = f8
     2 priority = i4
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
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
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SELECT INTO "nl:"
  b.interface_file_cd, b.organization_id, b.bill_org_type_cd,
  b.bill_org_type_id, b.priority, b.active_ind,
  b.beg_effective_dt_tm
  FROM bill_org_payor b
  WHERE (b.organization_id=request->organization_id)
   AND b.active_ind=1
  ORDER BY b.organization_id
  HEAD REPORT
   stat = alterlist(reply->qual,10)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].org_payor_id = b.org_payor_id, reply->qual[count1].organization_id = b
   .organization_id, reply->qual[count1].bill_org_type_cd = b.bill_org_type_cd,
   reply->qual[count1].bill_org_type_id = b.bill_org_type_id, reply->qual[count1].interface_file_cd
    = b.interface_file_cd, reply->qual[count1].priority = b.priority,
   reply->qual[count1].active_ind = b.active_ind, reply->qual[count1].beg_effective_dt_tm = b
   .beg_effective_dt_tm
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count1)
 SET reply->bill_org_payor_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ORG"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

CREATE PROGRAM ct_get_role_access:dba
 RECORD reply(
   1 qual[*]
     2 functionality_cd = f8
     2 access_mask = c5
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->status_data.status = "F"
 SET count1 = 0
 CALL echo("before select")
 SELECT INTO "nl:"
  p.functionality_cd, p.access_mask, p.updt_cnt
  FROM prot_role_access p
  WHERE (request->prot_role_cd=p.prot_role_cd)
   AND p.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   AND (p.logical_domain_id=domain_reply->logical_domain_id)
  DETAIL
   count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].functionality_cd = p
   .functionality_cd,
   reply->qual[count1].access_mask = p.access_mask, reply->qual[count1].updt_cnt = p.updt_cnt,
   CALL echo(p.functionality_cd),
   CALL echo(p.access_mask)
  WITH nocounter
 ;end select
 CALL echo("after select")
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "002"
 SET mod_date = "February 8, 2019"
END GO

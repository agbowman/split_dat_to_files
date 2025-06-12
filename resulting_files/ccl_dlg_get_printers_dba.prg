CREATE PROGRAM ccl_dlg_get_printers:dba
 EXECUTE ccl_prompt_api_dataset "autoset"
 RECORD sys_get_ques_request(
   1 qcontext
     2 name = c31
     2 node = c6
     2 dev_name = c31
     2 desc = c255
     2 status = i4
 )
 RECORD sys_get_ques_reply(
   1 sts = i4
   1 count = i4
   1 qual[3]
     2 name = c31
     2 node = c6
     2 dev_name = c31
     2 desc = c255
     2 status = i4
   1 qcontext
     2 name = c31
     2 node = c6
     2 dev_name = c31
     2 desc = c255
     2 status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SELECT INTO "nl:"
  dev_description = d.description, dev_name = d.name
  FROM org_set o,
   org_set_prsnl_r os,
   org_set_org_r oso,
   organization org,
   location l,
   device d,
   printer pr,
   output_dest od
  PLAN (os
   WHERE (os.prsnl_id=reqinfo->updt_id)
    AND os.active_ind=1
    AND os.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND os.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE o.org_set_id=os.org_set_id)
   JOIN (oso
   WHERE oso.org_set_id=o.org_set_id)
   JOIN (org
   WHERE org.organization_id=oso.organization_id)
   JOIN (l
   WHERE l.organization_id=org.organization_id
    AND l.active_ind=1)
   JOIN (d
   WHERE d.location_cd=l.location_cd)
   JOIN (pr
   WHERE pr.device_cd=d.device_cd)
   JOIN (od
   WHERE ((od.device_cd=d.device_cd) UNION (
   (SELECT
    dev_description = d.description, dev_name = d.name
    FROM prsnl_org_reltn p,
     organization o,
     location l,
     device d,
     printer pr,
     output_dest od
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND o.organization_id=p.organization_id
     AND o.organization_id > 0
     AND o.active_ind=1
     AND l.organization_id=o.organization_id
     AND l.active_ind=1
     AND d.location_cd=l.location_cd
     AND pr.device_cd=d.device_cd
     AND od.device_cd=d.device_cd))) )
  HEAD REPORT
   stat = makedataset(10)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH nocounter, separator = " ", format,
   check
 ;end select
END GO

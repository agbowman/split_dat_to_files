CREATE PROGRAM aps_get_organizations:dba
 RECORD reply(
   1 qual[*]
     2 org_id = f8
     2 org_name = vc
     2 org_name_key = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE ssearchtext = c100 WITH public, noconstant(fillstring(100," "))
 DECLARE sorgname = c100 WITH public, noconstant(fillstring(100," "))
 DECLARE istat = i4 WITH public, noconstant(0)
 DECLARE ihitcount = i4 WITH public, noconstant(0)
 DECLARE imaxqual = i4 WITH public, noconstant(0)
 IF (textlen(trim(request->search_text)) > 0)
  SET ssearchtext = build('o.org_name_key = "')
  SET ssearchtext = build(ssearchtext,cnvtupper(cnvtalphanum(request->search_text)))
  SET ssearchtext = build(ssearchtext,'*"')
 ELSE
  SET ssearchtext = build('o.org_name_key = "*"')
 ENDIF
 SELECT
  IF ((request->include_inactives_ind=1))
   WHERE parser(ssearchtext)
  ELSE
   WHERE parser(ssearchtext)
    AND o.active_ind=1
    AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ENDIF
  INTO "nl:"
  o.organization_id, o.org_name, o.org_name_key
  FROM organization o
  ORDER BY cnvtupper(o.org_name)
  HEAD REPORT
   ihitcount = 0, imaxqual = request->max_qual
  DETAIL
   ihitcount = (ihitcount+ 1)
   IF (mod(ihitcount,10)=1)
    istat = alterlist(reply->qual,(ihitcount+ 9))
   ENDIF
   reply->qual[ihitcount].org_id = o.organization_id, reply->qual[ihitcount].org_name = o.org_name,
   reply->qual[ihitcount].org_name_key = o.org_name_key,
   CALL echo(build("Name: ",o.org_name))
  FOOT REPORT
   istat = alterlist(reply->qual,ihitcount)
  WITH nocounter, maxqual(o,101)
 ;end select
 IF (ihitcount=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORGANIZATION"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO

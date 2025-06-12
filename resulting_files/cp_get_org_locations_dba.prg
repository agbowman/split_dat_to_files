CREATE PROGRAM cp_get_org_locations:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 org_qual[*]
      2 organization_id = f8
      2 loc_qual[*]
        3 location_cd = f8
        3 location_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE building_cd = f8 WITH public, noconstant(0.0)
 DECLARE nurseunit_cd = f8 WITH public, noconstant(0.0)
 DECLARE ambulatory_cd = f8 WITH public, noconstant(0.0)
 DECLARE lab_cd = f8 WITH public, noconstant(0.0)
 DECLARE pharmacy_cd = f8 WITH public, noconstant(0.0)
 DECLARE appointment_cd = f8 WITH public, noconstant(0.0)
 DECLARE radiology_cd = f8 WITH public, noconstant(0.0)
 DECLARE surgery_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  cv = code_value, cdf = cdf_meaning
  FROM code_value
  WHERE code_set=222
   AND active_ind=1
  DETAIL
   CASE (cdf)
    OF "BUILDING":
     building_cd = cv
    OF "NURSEUNIT":
     nurseunit_cd = cv
    OF "AMBULATORY":
     ambulatory_cd = cv
    OF "LAB":
     lab_cd = cv
    OF "PHARM":
     pharmacy_cd = cv
    OF "APPTLOC":
     appointment_cd = cv
    OF "RAD":
     radiology_cd = cv
    OF "ANCILSURG":
     surgery_cd = cv
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  l.organization_id, location_name = uar_get_code_description(l.location_cd)
  FROM (dummyt d  WITH seq = value(size(request->qual,5))),
   location l
  PLAN (d)
   JOIN (l
   WHERE (l.organization_id=request->qual[d.seq].organization_id)
    AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND l.active_ind=1
    AND l.location_type_cd IN (building_cd, nurseunit_cd, ambulatory_cd, lab_cd, pharmacy_cd,
   appointment_cd, radiology_cd, surgery_cd))
  ORDER BY l.organization_id, l.location_cd
  HEAD REPORT
   x = 0
  HEAD l.organization_id
   y = 0, x = (x+ 1)
   IF (x > size(reply->org_qual,5))
    stat = alterlist(reply->org_qual,(x+ 9))
   ENDIF
   reply->org_qual[x].organization_id = l.organization_id
  HEAD l.location_cd
   y = (y+ 1)
   IF (y > size(reply->org_qual[x].loc_qual,5))
    stat = alterlist(reply->org_qual[x].loc_qual,(y+ 9))
   ENDIF
   reply->org_qual[x].loc_qual[y].location_cd = l.location_cd, reply->org_qual[x].loc_qual[y].
   location_name = location_name
  FOOT  l.organization_id
   IF (y > 0)
    stat = alterlist(reply->org_qual[x].loc_qual,y)
   ENDIF
  FOOT REPORT
   IF (x > 0)
    stat = alterlist(reply->org_qual,x)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO

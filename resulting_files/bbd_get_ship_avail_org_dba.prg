CREATE PROGRAM bbd_get_ship_avail_org:dba
 RECORD reply(
   1 qual[*]
     2 org_name = c100
     2 org_id = f8
     2 cdf_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 RECORD ownertemp(
   1 owner[*]
     2 owner_cd = f8
     2 area[*]
       3 area_cd = f8
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET count = 0
 SET cdf_meaning = fillstring(12," ")
 SET bbmanuf_cd = 0.0
 SET bbsuppl_cd = 0.0
 SET bbclient_cd = 0.0
 SET display = fillstring(40," ")
 SET cv_cnt2 = 0
 SET i = 1
 SET areacount = 1
 SET ownercount = 1
 DECLARE bbownerroot_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BBOWNERROOT"))
 DECLARE j = i2 WITH protect, noconstant(0)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(278,"BBMANUF",cv_cnt,bbmanuf_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(278,"BBSUPPL",cv_cnt,bbsuppl_cd)
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(278,"BBCLIENT",cv_cnt,bbclient_cd)
 IF (((bbmanuf_cd=0.0) OR (((bbsuppl_cd=0.0) OR (((bbclient_cd=0.0) OR (bbownerroot_cd=0.0)) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  IF (bbmanuf_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read bbmanuf code value"
  ELSEIF (bbsuppl_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read bbsuppl code value"
  ELSEIF (bbownerroot_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Unable to read bbownerroot code value"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to read bbclient code value"
  ENDIF
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  l.location_cd, lg.location_group_type_cd, cv.code_value
  FROM location l,
   location_group lg,
   code_value cv
  PLAN (l
   WHERE l.location_type_cd=bbownerroot_cd
    AND l.active_ind=1
    AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (lg
   WHERE lg.parent_loc_cd=l.location_cd
    AND lg.active_ind=1
    AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cv
   WHERE lg.child_loc_cd=cv.code_value
    AND cv.cdf_meaning="BBINVAREA"
    AND cv.active_ind=1)
  ORDER BY lg.parent_loc_cd, lg.child_loc_cd
  HEAD REPORT
   nownercnt = 0, stat = alterlist(ownertemp->owner,10)
  HEAD lg.parent_loc_cd
   nownercnt = (nownercnt+ 1)
   IF (mod(nownercnt,10)=1
    AND nownercnt != 1)
    stat = alterlist(ownertemp->owner,(nownercnt+ 9))
   ENDIF
   ninvcnt = 0, stat = alterlist(ownertemp->owner[nownercnt].area,5), ownertemp->owner[nownercnt].
   owner_cd = lg.parent_loc_cd
  HEAD lg.child_loc_cd
   ninvcnt = (ninvcnt+ 1)
   IF (mod(ninvcnt,5)=1
    AND ninvcnt != 1)
    stat = alterlist(ownertemp->owner[nownercnt].area,(ninvcnt+ 4))
   ENDIF
   ownertemp->owner[nownercnt].area[ninvcnt].area_cd = lg.child_loc_cd
  FOOT  lg.parent_loc_cd
   stat = alterlist(ownertemp->owner[nownercnt].area,ninvcnt)
  FOOT REPORT
   stat = alterlist(ownertemp->owner,nownercnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  o.org_name
  FROM organization o,
   org_type_reltn ot
  PLAN (ot
   WHERE ot.org_type_cd IN (bbmanuf_cd, bbsuppl_cd, bbclient_cd)
    AND ot.active_ind=1)
   JOIN (o
   WHERE o.organization_id=ot.organization_id
    AND o.organization_id > 0
    AND o.active_ind=1)
  ORDER BY o.org_name, o.organization_id
  HEAD o.organization_id
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].org_name = o.org_name,
   reply->qual[count].org_id = o.organization_id
  FOOT  o.organization_id
   row + 0
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(ownertemp->owner,5))
  SET display = uar_get_code_display(ownertemp->owner[i].owner_cd)
  IF (size(trim(display)) > 0)
   SET count = (count+ 1)
   SET stat = alterlist(reply->qual,count)
   SET reply->qual[count].org_name = display
   SET reply->qual[count].org_id = ownertemp->owner[i].owner_cd
   SET reply->qual[count].cdf_mean = uar_get_code_meaning(ownertemp->owner[i].owner_cd)
   FOR (j = 1 TO size(ownertemp->owner[i].area,5))
    SET display = uar_get_code_display(ownertemp->owner[i].area[j].area_cd)
    IF (size(trim(display)) > 0)
     SET count = (count+ 1)
     SET stat = alterlist(reply->qual,count)
     SET reply->qual[count].org_name = display
     SET reply->qual[count].org_id = ownertemp->owner[i].area[j].area_cd
     SET reply->qual[count].cdf_mean = uar_get_code_meaning(ownertemp->owner[i].area[j].area_cd)
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO

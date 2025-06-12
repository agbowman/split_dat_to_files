CREATE PROGRAM ams_get_product_pharms:dba
 PROMPT
  "item_id" = "",
  "user's facility_cd" = ""
  WITH itemid, userfaccd
 DECLARE active_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE fac_group_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE building_group_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE subsection_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"SUBSECTION"))
 DECLARE pharm_device_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"PHARMDEVICE"
   ))
 DECLARE recordpos = i4 WITH protect
 DECLARE pharmpos = i4 WITH protect
 DECLARE locationcdpos = i4 WITH protect
 DECLARE flexind = i2 WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SELECT INTO "nl:"
  cv.code_value, cv.display, sa.item_id,
  flex_ind = evaluate(sa.item_id,0.0,0,1)
  FROM location_group fac,
   location_group build,
   code_value cv,
   service_resource sr,
   serv_res_ext_pharm srp,
   stored_at sa
  PLAN (fac
   WHERE (fac.parent_loc_cd= $USERFACCD)
    AND fac.root_loc_cd=0.0
    AND fac.location_group_type_cd=fac_group_cd
    AND fac.active_ind=1
    AND fac.active_status_cd=active_type_cd
    AND fac.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND fac.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (build
   WHERE build.parent_loc_cd=fac.child_loc_cd
    AND build.root_loc_cd=0.0
    AND build.location_group_type_cd=building_group_cd
    AND build.active_ind=1
    AND build.active_status_cd=active_type_cd
    AND build.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND build.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cv
   WHERE cv.code_value=build.child_loc_cd
    AND cv.cdf_meaning="PHARM"
    AND cv.active_ind=1
    AND cv.active_type_cd=active_type_cd)
   JOIN (sr
   WHERE sr.location_cd=cv.code_value
    AND sr.active_ind=1
    AND sr.active_status_cd=active_type_cd
    AND sr.service_resource_type_cd IN (subsection_type_cd, pharm_device_type_cd))
   JOIN (srp
   WHERE srp.service_resource_cd=sr.service_resource_cd
    AND srp.pat_care_loc_ind=0)
   JOIN (sa
   WHERE sa.item_id=outerjoin( $ITEMID)
    AND sa.location_cd=outerjoin(cv.code_value))
  ORDER BY flex_ind DESC, cv.display_key, cv.code_value
  HEAD REPORT
   stat = makedataset(20), pharmpos = addstringfield("PHARM","Pharmacy Location",visibile_ind,40),
   locationcdpos = addrealfield("LOCATION_CD","location_cd",invisibile_ind),
   stat = setkeyfield(locationcdpos,1)
  DETAIL
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,pharmpos,trim(cv.display)), stat =
   setrealfield(recordpos,locationcdpos,cv.code_value)
   IF (sa.location_cd > 0.0)
    stat = adddefaultkey(cnvtstring(cv.code_value))
   ENDIF
  FOOT REPORT
   stat = closedataset(0), stat = alterlist(reply->default_key_list,recordpos)
  WITH maxrec = 50, nocounter, reporthelp,
   check
 ;end select
 SET last_mod = "001"
END GO

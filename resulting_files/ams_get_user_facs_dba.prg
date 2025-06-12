CREATE PROGRAM ams_get_user_facs:dba
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE recordpos = i4 WITH protect
 DECLARE facdisppos = i4 WITH protect
 DECLARE faccdpos = i4 WITH protect
 DECLARE singlefaccd = f8 WITH protect
 DECLARE i = i4 WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SELECT INTO "nl:"
  cv.display
  FROM code_value cv,
   location l,
   prsnl_org_reltn por
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.cdf_meaning="FACILITY"
    AND cv.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    dm.pref_cd
    FROM dm_prefs dm
    WHERE dm.pref_domain="AMS_TOOLKIT"
     AND dm.pref_section="AMS_PHARM_FLEXING_UTILITY"
     AND dm.pref_name="DUMMY_ORG"
     AND dm.pref_cd=cv.code_value))))
   JOIN (l
   WHERE l.location_cd=cv.code_value)
   JOIN (por
   WHERE por.organization_id=l.organization_id
    AND (por.person_id=reqinfo->updt_id)
    AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND por.active_ind=1)
  ORDER BY cv.display_key
  HEAD REPORT
   i = 0, stat = makedataset(10), facdisppos = addstringfield("DISPLAY","Facility Display",
    visibile_ind,40),
   faccdpos = addrealfield("FACILITY_CD","facility_cd",invisibile_ind), stat = setkeyfield(faccdpos,1
    )
  DETAIL
   i = (i+ 1), singlefaccd = cv.code_value
   IF (i > 1)
    singlefaccd = 0
   ENDIF
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,facdisppos,cv.display), stat =
   setrealfield(recordpos,faccdpos,cv.code_value)
  FOOT REPORT
   IF (singlefaccd > 0)
    stat = adddefaultkey(cnvtstring(singlefaccd))
   ENDIF
   stat = closedataset(0), stat = alterlist(reply->default_key_list,recordpos)
  WITH nocounter, reporthelp, check
 ;end select
END GO

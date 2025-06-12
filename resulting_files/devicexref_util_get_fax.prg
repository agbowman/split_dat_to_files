CREATE PROGRAM devicexref_util_get_fax
 PROMPT
  "ENTER PERSON ID" = ""
  WITH pid
 DECLARE maxdatasetsize = i2 WITH constant(1000)
 DECLARE 3000_fax_usagetypecd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",3000,"FAX")), protect
 DECLARE 222_locfacilitycd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",222,"FACILITYS")), protect
 DECLARE 278_facilitycd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",278,"FACILITY")), protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SELECT INTO "nl:"
  device = trim(d.name), fax_number = concat(trim(rd.country_access),"-",trim(rd.area_code),"-",trim(
    rd.exchange),
   "-",trim(rd.phone_suffix)), d.device_cd
  FROM prsnl p,
   location l,
   device d,
   organization o,
   org_type_reltn otr,
   remote_device rd
  PLAN (p
   WHERE (p.person_id= $PID)
    AND p.active_ind=1)
   JOIN (o
   WHERE o.logical_domain_id=p.logical_domain_id
    AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND o.active_ind=1)
   JOIN (otr
   WHERE otr.organization_id=o.organization_id
    AND ((otr.org_type_cd+ 0)=278_facilitycd)
    AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND otr.active_ind=1)
   JOIN (l
   WHERE l.organization_id=otr.organization_id
    AND l.location_type_cd=222_locfacilitycd
    AND l.patcare_node_ind=1
    AND l.active_ind=1
    AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND l.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d
   WHERE d.location_cd=l.location_cd
    AND d.device_type_cd=3000_fax_usagetypecd)
   JOIN (rd
   WHERE rd.device_cd=d.device_cd)
  ORDER BY cnvtlower(d.name)
  HEAD REPORT
   stat = makedataset(maxdatasetsize)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH maxrec = maxdatasetsize, nocounter, reporthelp
 ;end select
END GO

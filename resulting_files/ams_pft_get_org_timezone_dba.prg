CREATE PROGRAM ams_pft_get_org_timezone:dba
 PROMPT
  "country_cd" = "",
  "org_id" = ""
  WITH tzcountrycd, orgid
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE cki_usa = vc WITH protect, constant("CKI.CODEVALUE!15329")
 DECLARE cki_uk = vc WITH protect, constant("CKI.CODEVALUE!24032")
 DECLARE cki_canada = vc WITH protect, constant("CKI.CODEVALUE!23836")
 DECLARE facility_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE last_mod = vc WITH protect
 DECLARE disppos = i4 WITH protect
 DECLARE valuepos = i4 WITH protect
 DECLARE recordpos = i4 WITH protect
 DECLARE brtimezoneid = f8 WITH protect
 DECLARE region = vc WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SET stat = makedataset(10)
 SET disppos = addstringfield("DISP","Display",visibile_ind,100)
 SET valuepos = addrealfield("VALUE","Value",invisibile_ind)
 SET stat = setkeyfield(valuepos,1)
 IF (( $TZCOUNTRYCD=uar_get_code_by_cki(cki_usa)))
  SET region = "USA"
 ELSEIF (( $TZCOUNTRYCD=uar_get_code_by_cki(cki_uk)))
  SET region = "UK"
 ELSEIF (( $TZCOUNTRYCD=uar_get_code_by_cki(cki_canada)))
  SET region = "CANADA"
 ENDIF
 SELECT INTO "nl:"
  btz.time_zone_id
  FROM location l,
   time_zone_r tzr,
   br_time_zone btz
  PLAN (l
   WHERE (l.organization_id= $ORGID)
    AND l.location_type_cd=facility_type_cd
    AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND l.active_ind=1)
   JOIN (tzr
   WHERE tzr.parent_entity_id=l.location_cd
    AND tzr.parent_entity_name="LOCATION")
   JOIN (btz
   WHERE btz.time_zone=tzr.time_zone
    AND ((btz.region=region) OR (textlen(trim(region))=0)) )
  DETAIL
   brtimezoneid = btz.time_zone_id, recordpos = getnextrecord(0), stat = setstringfield(recordpos,
    disppos,btz.description),
   stat = setrealfield(recordpos,valuepos,brtimezoneid), stat = adddefaultkey(cnvtstring(brtimezoneid
     ))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_time_zone btz
  PLAN (btz
   WHERE ((btz.region=region) OR (textlen(trim(region))=0))
    AND btz.time_zone_id != brtimezoneid)
  ORDER BY btz.sequence
  DETAIL
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,disppos,btz.description), stat =
   setrealfield(recordpos,valuepos,btz.time_zone_id)
  WITH nocounter
 ;end select
 SET stat = closedataset(0)
 SET stat = alterlist(reply->default_key_list,recordpos)
 SET last_mod = "000"
END GO

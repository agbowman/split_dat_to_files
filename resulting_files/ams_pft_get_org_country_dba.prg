CREATE PROGRAM ams_pft_get_org_country:dba
 PROMPT
  "org_id" = ""
  WITH orgid
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE address_bussiness_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,
   "BUSINESS"))
 DECLARE last_mod = vc WITH protect
 DECLARE disppos = i4 WITH protect
 DECLARE valuepos = i4 WITH protect
 DECLARE defaultcountrycd = f8 WITH protect
 DECLARE recordpos = i4 WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SET stat = makedataset(10)
 SET disppos = addstringfield("DISP","Display",visibile_ind,100)
 SET valuepos = addrealfield("VALUE","Value",invisibile_ind)
 SET stat = setkeyfield(valuepos,1)
 SELECT INTO "nl:"
  a.country_cd
  FROM address a
  WHERE a.parent_entity_id=cnvtreal( $ORGID)
   AND a.parent_entity_name="ORGANIZATION"
   AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND a.active_ind=1
   AND a.address_type_cd=address_bussiness_type_cd
   AND a.address_type_seq=0
  DETAIL
   defaultcountrycd = a.country_cd, recordpos = getnextrecord(0), stat = setstringfield(recordpos,
    disppos,trim(uar_get_code_display(defaultcountrycd))),
   stat = setrealfield(recordpos,valuepos,defaultcountrycd), stat = adddefaultkey(cnvtstring(
     defaultcountrycd))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display, cv.code_value
  FROM code_value cv
  WHERE cv.code_set=15
   AND cv.active_ind=1
   AND cv.code_value != defaultcountrycd
  ORDER BY cv.display_key
  DETAIL
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,disppos,cv.display), stat =
   setrealfield(recordpos,valuepos,cv.code_value)
  WITH nocounter
 ;end select
 SET stat = closedataset(0)
 SET stat = alterlist(reply->default_key_list,recordpos)
 SET last_mod = "000"
END GO

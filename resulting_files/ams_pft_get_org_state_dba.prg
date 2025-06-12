CREATE PROGRAM ams_pft_get_org_state:dba
 PROMPT
  "country_cd" = "",
  "org_id" = ""
  WITH statecountrycd, orgid
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE address_bussiness_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,
   "BUSINESS"))
 DECLARE last_mod = vc WITH protect
 DECLARE disppos = i4 WITH protect
 DECLARE valuepos = i4 WITH protect
 DECLARE defaultstatecd = f8 WITH protect
 DECLARE recordpos = i4 WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SET stat = makedataset(10)
 SET disppos = addstringfield("DISP","Display",visibile_ind,100)
 SET valuepos = addrealfield("VALUE","Value",invisibile_ind)
 SET stat = setkeyfield(valuepos,1)
 SELECT INTO "nl:"
  a.state_cd
  FROM address a
  WHERE (a.parent_entity_id= $ORGID)
   AND a.country_cd=cnvtreal( $STATECOUNTRYCD)
   AND a.parent_entity_name="ORGANIZATION"
   AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND a.active_ind=1
   AND a.address_type_cd=address_bussiness_type_cd
   AND a.address_type_seq=0
  DETAIL
   defaultstatecd = a.state_cd, recordpos = getnextrecord(0), stat = setstringfield(recordpos,disppos,
    trim(uar_get_code_display(defaultstatecd))),
   stat = setrealfield(recordpos,valuepos,defaultstatecd), stat = adddefaultkey(cnvtstring(
     defaultstatecd))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display, cv.code_value
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE cvg.parent_code_value=cnvtreal( $STATECOUNTRYCD))
   JOIN (cv
   WHERE cv.code_value=cvg.child_code_value
    AND cv.code_set=62
    AND cv.active_ind=1
    AND cv.code_value != defaultstatecd)
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

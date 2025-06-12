CREATE PROGRAM ams_get_product_flexing:dba
 PROMPT
  "item_id" = "",
  "user's facility_cd" = ""
  WITH itemid, userfaccd
 DECLARE active_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE orderable_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,"ORDERABLE"))
 DECLARE sys_pkg_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE inpatient_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE recordpos = i4 WITH protect
 DECLARE disppos = i4 WITH protect
 DECLARE indpos = i4 WITH protect
 DECLARE flexind = i2 WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SELECT INTO "nl:"
  mfoi.parent_entity_id
  FROM medication_definition md,
   med_def_flex mdf,
   med_flex_object_idx mfoi
  PLAN (md
   WHERE (md.item_id= $ITEMID)
    AND md.med_type_flag IN (0, 2))
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.active_status_cd=active_type_cd
    AND mdf.pharmacy_type_cd=inpatient_type_cd
    AND mdf.flex_type_cd=sys_pkg_type_cd)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=outerjoin(mdf.med_def_flex_id)
    AND mfoi.flex_object_type_cd=outerjoin(orderable_type_cd)
    AND mfoi.parent_entity_id=outerjoin( $USERFACCD)
    AND mfoi.parent_entity_name=outerjoin("CODE_VALUE"))
  HEAD REPORT
   stat = makedataset(2), disppos = addstringfield("DISPLAY","On/Off",visibile_ind,10), indpos =
   addintegerfield("INDICATOR","indicator",invisibile_ind),
   stat = setkeyfield(indpos,1), recordpos = getnextrecord(0), stat = setstringfield(recordpos,
    disppos,"On"),
   stat = setintegerfield(recordpos,indpos,1), recordpos = getnextrecord(0), stat = setstringfield(
    recordpos,disppos,"Off"),
   stat = setintegerfield(recordpos,indpos,0)
  DETAIL
   IF (( $USERFACCD=mfoi.parent_entity_id))
    flexind = 1
   ELSE
    flexind = 0
   ENDIF
  FOOT REPORT
   stat = adddefaultkey(cnvtstring(flexind)), stat = closedataset(0), stat = alterlist(reply->
    default_key_list,recordpos)
  WITH maxrec = 50, nocounter, reporthelp,
   check
 ;end select
END GO

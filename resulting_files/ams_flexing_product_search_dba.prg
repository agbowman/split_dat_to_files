CREATE PROGRAM ams_flexing_product_search:dba
 PROMPT
  "search string" = "",
  "user's facility_cd" = ""
  WITH searchstr, userfaccd
 DECLARE getdummyorg(null) = f8 WITH protect
 DECLARE getcrosswalkprefs(null) = null WITH protect
 DECLARE active_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE orderable_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,"ORDERABLE"))
 DECLARE sys_pkg_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE inpatient_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE desc_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE pyxis_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"PYXIS"))
 DECLARE cdm_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"CDM"))
 DECLARE dummy_org_cd = f8 WITH protect, constant(getdummyorg(null))
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE crosswalktypecd = f8 WITH protect
 DECLARE recordpos = i4 WITH protect
 DECLARE descpos = i4 WITH protect
 DECLARE pyxisidpos = i4 WITH protect
 DECLARE cdmpos = i4 WITH protect
 DECLARE itemidpos = i4 WITH protect
 DECLARE flexind = i2 WITH protect
 DECLARE modsearchstr = vc WITH protect
 DECLARE i = i4 WITH protect
 DECLARE wherestr = vc WITH protect, noconstant("mi3.active_ind = -1")
 SET modsearchstr = cnvtupper(cnvtalphanum( $SEARCHSTR))
 RECORD excludes(
   1 list[*]
     2 str = vc
 ) WITH protect
 CALL getcrosswalkprefs(null)
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SELECT DISTINCT INTO "nl:"
  mi2.value, mi2.item_id, mfoi.parent_entity_id
  FROM med_identifier mi,
   medication_definition md,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_identifier mi2,
   med_identifier mi4,
   med_identifier mi5
  PLAN (mi
   WHERE mi.value_key=patstring(concat(modsearchstr,"*"))
    AND mi.active_ind=1
    AND (( NOT ( EXISTS (
   (SELECT
    mi3.item_id
    FROM med_identifier mi3
    WHERE mi3.item_id=mi.item_id
     AND mi3.med_identifier_type_cd=crosswalktypecd
     AND mi3.med_product_id=0
     AND mi3.active_ind=1
     AND parser(wherestr))))) OR ( EXISTS (
   (SELECT
    mdf2.item_id
    FROM med_def_flex mdf2,
     med_flex_object_idx mfoi3
    WHERE mdf2.item_id=mi.item_id
     AND mdf2.active_status_cd=active_type_cd
     AND mdf2.pharmacy_type_cd=inpatient_type_cd
     AND mdf2.flex_type_cd=sys_pkg_type_cd
     AND mfoi3.med_def_flex_id=mdf.med_def_flex_id
     AND mfoi3.flex_object_type_cd=orderable_type_cd
     AND (mfoi3.parent_entity_id= $USERFACCD)
     AND mfoi3.parent_entity_name="CODE_VALUE")))) )
   JOIN (md
   WHERE md.item_id=mi.item_id
    AND md.med_type_flag IN (0, 2))
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.active_status_cd=active_type_cd
    AND mdf.pharmacy_type_cd=inpatient_type_cd
    AND mdf.flex_type_cd=sys_pkg_type_cd)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=orderable_type_cd
    AND  EXISTS (
   (SELECT
    mfoi2.med_def_flex_id
    FROM med_flex_object_idx mfoi2
    WHERE mfoi2.med_def_flex_id=mdf.med_def_flex_id
     AND mfoi2.flex_object_type_cd=orderable_type_cd
     AND mfoi2.parent_entity_id=dummy_org_cd
     AND mfoi2.parent_entity_name="CODE_VALUE")))
   JOIN (mi2
   WHERE mi2.item_id=mi.item_id
    AND mi2.med_identifier_type_cd=desc_type_cd
    AND mi2.med_product_id=0
    AND mi2.primary_ind=1
    AND mi2.active_ind=1)
   JOIN (mi4
   WHERE mi4.item_id=outerjoin(mi.item_id)
    AND mi4.med_identifier_type_cd=outerjoin(pyxis_type_cd)
    AND mi4.med_product_id=outerjoin(0)
    AND mi4.primary_ind=outerjoin(1)
    AND mi4.active_ind=outerjoin(1))
   JOIN (mi5
   WHERE mi5.item_id=outerjoin(mi.item_id)
    AND mi5.med_identifier_type_cd=outerjoin(cdm_type_cd)
    AND mi5.med_product_id=outerjoin(0)
    AND mi5.primary_ind=outerjoin(1)
    AND mi5.active_ind=outerjoin(1))
  ORDER BY mi2.value_key, mi2.item_id, mfoi.parent_entity_id,
   mi4.value_key, mi5.value_key
  HEAD REPORT
   stat = makedataset(20), descpos = addstringfield("DESC","Product Description",visibile_ind,200),
   pyxisidpos = addstringfield("PYXIS_ID",uar_get_code_display(pyxis_type_cd),visibile_ind,40),
   cdmpos = addstringfield("CDM",uar_get_code_display(cdm_type_cd),visibile_ind,40), itemidpos =
   addrealfield("ITEM_ID","item_id",invisibile_ind), stat = setkeyfield(itemidpos,1)
  HEAD mi2.item_id
   flexind = 0
  DETAIL
   IF (( $USERFACCD=mfoi.parent_entity_id))
    flexind = 1
   ENDIF
  FOOT  mi2.item_id
   recordpos = getnextrecord(0)
   IF (flexind=0)
    desc = build2("OFF - ",trim(mi2.value))
   ELSE
    desc = trim(mi2.value)
   ENDIF
   stat = setstringfield(recordpos,descpos,desc), stat = setstringfield(recordpos,pyxisidpos,mi4
    .value), stat = setstringfield(recordpos,cdmpos,mi5.value),
   stat = setrealfield(recordpos,itemidpos,mi2.item_id)
  FOOT REPORT
   stat = closedataset(0), stat = alterlist(reply->default_key_list,recordpos)
  WITH nocounter, reporthelp, check
 ;end select
 SUBROUTINE getdummyorg(null)
   DECLARE retval = f8 WITH protect
   SELECT INTO "nl:"
    dm.pref_cd
    FROM dm_prefs dm
    PLAN (dm
     WHERE dm.pref_domain="AMS_TOOLKIT"
      AND dm.pref_section="AMS_PHARM_FLEXING_UTILITY"
      AND dm.pref_name="DUMMY_ORG")
    DETAIL
     retval = dm.pref_cd
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getcrosswalkprefs(null)
   DECLARE i = i4 WITH protect
   DECLARE notfnd = vc WITH protect, constant("-1")
   DECLARE str = vc WITH protect
   SELECT INTO "nl:"
    dm.pref_cd
    FROM dm_prefs dm
    PLAN (dm
     WHERE dm.pref_domain="AMS_TOOLKIT"
      AND dm.pref_section="AMS_PHARM_FLEXING_UTILITY"
      AND dm.pref_name="CROSSWALK_IDENTIFIER_CD")
    DETAIL
     crosswalktypecd = dm.pref_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    dm.pref_cd
    FROM dm_prefs dm
    PLAN (dm
     WHERE dm.pref_domain="AMS_TOOLKIT"
      AND dm.pref_section="AMS_PHARM_FLEXING_UTILITY"
      AND dm.pref_name="CROSSWALK_EXCLUDE_VALUE")
    HEAD REPORT
     wherestr = "mi3.value_key in ("
    DETAIL
     i = 1
     WHILE (str != notfnd)
       str = piece(dm.pref_str,",",i,notfnd)
       IF (str != notfnd)
        IF (i > 1)
         wherestr = concat(wherestr,",")
        ENDIF
        wherestr = concat(wherestr,"'",trim(str,3),"*'")
       ELSE
        wherestr = concat(wherestr,")")
       ENDIF
       i = (i+ 1)
     ENDWHILE
    WITH nocounter
   ;end select
 END ;Subroutine
 SET last_mod = "001"
END GO

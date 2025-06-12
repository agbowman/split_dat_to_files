CREATE PROGRAM ccl_ds_getlochierarchy:dba
 PROMPT
  "Display value or initial state command ('INIT' or '%LIST%')" = "INIT",
  "Search item locataion code" = 1.0,
  "Item terminal selection state (1 or 0)" = 1,
  "Item expanded icon number" = 0,
  "Item collapsed icon number" = 0,
  "Item expandable (1=expandable)" = 1,
  "Location meaning value" = "",
  "Location path string" = ""
  WITH item_display, item_keyvalue, item_terminal_flag,
  item_icon_opened, item_icon_closed, item_expand_flag,
  item_meaning, item_path
 EXECUTE ccl_prompt_api_dataset "dataset", "parameter"
 RECORD requestorg(
   1 org_name_key = vc
   1 org_type_cd = f8
 )
 RECORD replyorg(
   1 qual[*]
     2 organization_id = f8
     2 org_name = vc
     2 org_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD locrequest(
   1 location_cd = f8
   1 cdf_meaning = c12
   1 root_loc_cd = f8
   1 get_all_flag = i2
   1 get_master_flag = i2
 )
 RECORD locreply(
   1 qual[*]
     2 child_loc_cd = f8
     2 child_loc_disp = c40
     2 child_loc_desc = c60
     2 child_loc_mean = c12
     2 cv_updt_cnt = i4
     2 collation_seq = i4
     2 child_ind = i2
     2 loc_status_ind = i2
     2 loc_active_ind = i2
     2 lg_status_ind = i2
     2 lg_active_ind = i2
     2 lg_updt_cnt = i4
     2 sequence = i4
     2 location_type_mean = c12
     2 data_status_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE themeaning = c12
 DECLARE nodevalue = f8 WITH noconstant(0.0)
 DECLARE mapcdftoicon(cdf=vc) = i4
 RECORD paramlist(
   1 parameters[*]
     2 param = vc
 )
 DECLARE chkbox = i2
 SET chkbox = 0
 SET paramcount = 0
 SET pc = getparametercount(0)
 SET x = alterlist(paramlist->parameters,pc)
 FOR (j = 1 TO pc)
   IF ( NOT (isparameterreserved(j)))
    SET paramcount = (paramcount+ 1)
    SET paramlist->parameters[paramcount].param = getparameterno(j)
   ENDIF
 ENDFOR
 IF (( $ITEM_DISPLAY="INIT")
  AND cnvtint( $ITEM_KEYVALUE)=1)
  SET stat = makedataset(1)
  SET fdisplay = addstringfield("ITEM_DISPLAY","DISPLAY",1,40)
  SET fkey = addstringfield("ITEM_KEYVALUE","KEYVALUE",1,15)
  SET fterminal = addintegerfield("ITEM_TERMINAL_FLAG","TERMINAL",true)
  SET fopened = addintegerfield("ITEM_ICON_OPENED","ICON",true)
  SET fclosed = addintegerfield("ITEM_ICON_CLOSED","ICON",true)
  SET fexpand = addintegerfield("ITEM_EXPAND_FLAG","EXPAND",true)
  SET fmeaning = addstringfield("ITEM_MEANING","MEANING",1,15)
  SET fpath = addstringfield("ITEM_PATH","PATH",1,128)
  SET imn = 3
  SET rc = getnextrecord(0)
  SET stat = setstringfield(rc,fdisplay,"Facilities")
  SET stat = setstringfield(rc,fkey,"1")
  SET stat = setintegerfield(rc,fterminal,0)
  SET stat = setintegerfield(rc,fclosed,imn)
  SET stat = setintegerfield(rc,fopened,imn)
  SET stat = setintegerfield(rc,fexpand,1)
  SET stat = setstringfield(rc,fmeaning,"1")
  SET stat = setstringfield(rc,fpath,"")
  SET stat = closedataset(0)
 ELSE
  SET nodevalue = cnvtreal( $ITEM_KEYVALUE)
  SET themeaning =  $ITEM_MEANING
  SET iconno = 0
  IF (themeaning="1")
   SET requestorg->org_name_key = ""
   SET requestorg->org_type_cd = 0.0
   DECLARE faccode = f8
   DECLARE count = i2
   SET stat = uar_get_meaning_by_codeset(222,"FACILITY",1,faccode)
   SET iconno = mapcdftoicon("FACILITY")
   SELECT DISTINCT INTO "NL:"
    item_display = f.display, item_keyvalue = f.code_value, item_terminal = 1,
    item_icon_opened = iconno, item_icon_closed = iconno, item_expand_flag = 1,
    item_meaning = f.cdf_meaning, item_path = build( $ITEM_PATH,"/",f.display)
    FROM code_value f,
     location_group lg
    PLAN (lg
     WHERE lg.location_group_type_cd=faccode
      AND lg.active_ind=1)
     JOIN (f
     WHERE f.code_value=lg.parent_loc_cd
      AND f.cdf_meaning="FACILITY"
      AND f.active_ind=1)
    ORDER BY cnvtupper(f.display)
    HEAD REPORT
     stat = makedataset(1000)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH maxrow = 1, reporthelp, check
   ;end select
  ELSEIF (( $ITEM_DISPLAY="%LIST%"))
   SET locrequest->location_cd = nodevalue
   SET locrequest->cdf_meaning = uar_get_code_meaning(cnvtreal(nodevalue))
   SET locrequest->root_loc_cd = 0
   SET locrequest->get_all_flag = 0
   SET locrequest->get_master_flag = 0
   EXECUTE loc_get_children_for_location  WITH replace(request,locrequest), replace(reply,locreply)
   SELECT
    item_keyvalue = locreply->qual[d.seq].child_loc_cd, item_display = uar_get_code_display(locreply
     ->qual[d.seq].child_loc_cd), item_description = uar_get_code_description(locreply->qual[d.seq].
     child_loc_cd),
    item_meaning = uar_get_code_meaning(locreply->qual[d.seq].child_loc_cd), item_path = build(
      $ITEM_PATH,"/",uar_get_code_display(locreply->qual[d.seq].child_loc_cd))
    FROM (dummyt d  WITH seq = size(locreply->qual,5))
    WHERE (locreply->qual[d.seq].child_loc_cd > 0)
     AND (locreply->qual[d.seq].loc_active_ind=1)
    ORDER BY item_display
    HEAD REPORT
     stat = makedataset(1000)
    DETAIL
     rc = writerecord(0)
    FOOT REPORT
     stat = setfieldtitleno(1,"Code Value"), stat = setfieldtitleno(2,"Display"), stat =
     setfieldtitleno(3,"Description"),
     stat = setfieldtitleno(4,"CDF Meaning"), stat = setfieldtitleno(5,"Path"), stat = closedataset(0
      )
    WITH maxrow = 1, reporthelp, check
   ;end select
  ELSE
   SET locrequest->location_cd = nodevalue
   SET locrequest->cdf_meaning =  $ITEM_MEANING
   SET locrequest->root_loc_cd = 0
   SET locrequest->get_all_flag = 0
   SET locrequest->get_master_flag = 0
   EXECUTE loc_get_children_for_location  WITH replace(request,locrequest), replace(reply,locreply)
   SELECT
    item_display = uar_get_code_description(locreply->qual[d.seq].child_loc_cd), item_keyvalue =
    locreply->qual[d.seq].child_loc_cd, item_terminal_flag = 1,
    item_icon_opened = 0, item_icon_closed = 0, item_expand_flag = locreply->qual[d.seq].child_ind,
    item_meaning = uar_get_code_meaning(locreply->qual[d.seq].child_loc_cd), item_path = build(
      $ITEM_PATH,"/",uar_get_code_display(locreply->qual[d.seq].child_loc_cd))
    FROM (dummyt d  WITH seq = size(locreply->qual,5))
    WHERE (locreply->qual[d.seq].child_loc_cd > 0)
     AND (locreply->qual[d.seq].loc_active_ind=1)
    ORDER BY item_display
    HEAD REPORT
     stat = makedataset(1000)
    DETAIL
     rc = writerecord(0), icn = trim(cnvtstring(mapcdftoicon(item_meaning))), stat = setfield(rc,
      "ITEM_ICON_OPENED",icn),
     stat = setfield(rc,"ITEM_ICON_CLOSED",icn)
    FOOT REPORT
     stat = closedataset(0)
    WITH maxrow = 1, reporthelp, check
   ;end select
  ENDIF
 ENDIF
 SUBROUTINE mapcdftoicon(cdf)
   DECLARE img = i2 WITH protect, noconstant(0)
   CASE (trim(cdf))
    OF "ACTASGNROOT":
     SET img = 16
    OF "AMBULATORY":
     SET img = 5
    OF "ANCILSURG":
     SET img = 17
    OF "APPTLOC":
     SET img = 15
    OF "APPTROOT":
     SET img = 18
    OF "BBDRAW":
     SET img = 19
    OF "BBINVAREA":
     SET img = 20
    OF "BBOWNERROOT":
     SET img = 19
    OF "BED":
     SET img = 8
    OF "BUILDING":
     SET img = 4
    OF "CHECKOUT":
     SET img = 21
    OF "CLINIC":
     SET img = 22
    OF "COLLROOT":
     SET img = 23
    OF "COLLRTE":
     SET img = 24
    OF "COLLRUN":
     SET img = 25
    OF "CSLOGIN":
     SET img = 26
    OF "CSTRACK":
     SET img = 27
    OF "FACILITY":
     SET img = 2
    OF "FOLLOWUPAMB":
     SET img = 28
    OF "HIM":
     SET img = 29
    OF "HIMROOT":
     SET img = 30
    OF "HIS":
     SET img = 29
    OF "INVGRP":
     SET img = 31
    OF "INVLOC":
     SET img = 14
    OF "INVLOCATOR":
     SET img = 33
    OF "INVVIEW":
     SET img = 32
    OF "LAB":
     SET img = 9
    OF "MICRO STATIS":
     SET img = 34
    OF "MMGRPROOT":
     SET img = 35
    OF "NURSEUNIT":
     SET img = 6
    OF "PATLISTROOT":
     SET img = 36
    OF "PHARM":
     SET img = 11
    OF "PLREMOTE":
     SET img = 0
    OF "PTRECYCLE":
     SET img = 0
    OF "PTTRACK":
     SET img = 0
    OF "PTTRACKROOT":
     SET img = 0
    OF "PTTRACKVIEW":
     SET img = 0
    OF "RAD":
     SET img = 12
    OF "ROOM":
     SET img = 7
    OF "ROUNDSROOT":
     SET img = 0
    OF "RXLOCGROUP":
     SET img = 0
    OF "SHFTASGNROOT":
     SET img = 0
    OF "SPECCOLLROOT":
     SET img = 0
    OF "SPECTRKROOT":
     SET img = 0
    OF "SRVAREA":
     SET img = 34
    OF "STORAGERACK":
     SET img = 0
    OF "STORAGEROOT":
     SET img = 0
    OF "STORAGESHELF":
     SET img = 0
    OF "STORAGETRAY":
     SET img = 0
    OF "STORAGEUNIT":
     SET img = 0
    OF "STORTRKROOT":
     SET img = 0
    OF "STORTRKROOT":
     SET img = 0
    OF "SURGFILL":
     SET img = 6
    OF "TRANSPORT":
     SET img = 0
    OF "TSKGRPROOT":
     SET img = 0
    OF "WAITROOM":
     SET img = 13
    ELSE
     SET img = 0
   ENDCASE
   RETURN(img)
 END ;Subroutine
END GO

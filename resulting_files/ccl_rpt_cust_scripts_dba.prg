CREATE PROGRAM ccl_rpt_cust_scripts:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter script object name:" = "*"
  WITH outdev, scriptname
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",0.0)
 DECLARE scustomscript = vc
 DECLARE customscriptdate = vc
 DECLARE scustomscriptpref = vc
 SET i18nenabled = uar_i18ngetmessage(i18nhandle,"kEnabled","Enabled")
 SET i18ndisabled = uar_i18ngetmessage(i18nhandle,"kDisabled","Disabled")
 SET i18nunknown = uar_i18ngetmessage(i18nhandle,"kUnknown","Unknown")
 SET i18ncustobjs = uar_i18ngetmessage(i18nhandle,"kCustobjs",
  "Discern Explorer Custom Script Objects")
 SET i18nroutings = uar_i18ngetmessage(i18nhandle,"kRoutingS","Custom Script Routing Status")
 SET i18ndatemod = uar_i18ngetmessage(i18nhandle,"kDateMod","Date Modified")
 SET i18ncustdis = uar_i18ngetmessage(i18nhandle,"kCustDis",
  " No custom scripts will be routed to dedicated servers ")
 SET i18nscriptname = uar_i18ngetmessage(i18nhandle,"kSName","Script Name")
 SET i18ngroup = uar_i18ngetmessage(i18nhandle,"kGroup","Group")
 SET i18ndtupdated = uar_i18nbuildmessage(i18nhandle,"kDTUpdated","Date %1 Time Updated","c","/")
 SET scustomscript = cnvtupper(trim( $SCRIPTNAME))
 SET customsciptpref = i18nenabled
 SET customscriptdate = " "
 SELECT INTO "NL:"
  nvp.parent_entity_name, nvp.parent_entity_id, nvp.pvc_name,
  nvp.updt_dt_tm, nvp.pvc_value
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="DISCERN_CUSTOM_CACHE"
  DETAIL
   IF (nvp.pvc_value="1")
    scustomscriptpref = i18nenabled
   ELSEIF (nvp.pvc_value="0")
    scustomscriptpref = i18ndisabled
   ELSE
    scustomscriptpref = i18nunknown
   ENDIF
   customscriptdate = format(nvp.updt_dt_tm,"@MEDIUMDATETIME")
  WITH nocounter
 ;end select
 IF (scustomscriptpref=i18ndisabled)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    row 1, col 2, i18ncustobjs,
    ":", row 3, col 5,
    i18nroutings, ":", row 3,
    col 37, scustomscriptpref, row 4,
    col 5, i18ndatemod, ":",
    row 4, col 37, customscriptdate,
    row 6, col 5, "***",
    i18ncustdis, "***", row + 2
   WITH format = variable
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   c.object_name, c.group_number, c.active_ind,
   c.updt_dt_tm"@MEDIUMDATETIME", c.updt_id
   FROM ccl_cust_script_objects c
   WHERE cnvtupper(c.object_name)=patstring(scustomscript)
   ORDER BY c.object_name, c.group_number
   HEAD REPORT
    row 1, col 2, i18ncustobjs,
    ":", row 3, col 5,
    i18nroutings, ":", row 3,
    col 37, scustomscriptpref, row 4,
    col 5, i18ndatemod, ":",
    row 4, col 37, customscriptdate,
    row + 2
   HEAD PAGE
    col 2, i18nscriptname, ":",
    col 41, i18ngroup, ":",
    col 61, i18ndtupdated, ":",
    row + 2
   DETAIL
    col 2, c.object_name, col 41,
    c.group_number, col 61, c.updt_dt_tm,
    row + 1
   WITH format = variable
  ;end select
 ENDIF
END GO

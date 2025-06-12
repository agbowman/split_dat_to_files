CREATE PROGRAM ams_imp_menu_items:dba
 PROMPT
  "Enter Package Number: " = "0"
  WITH packagenbr
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script ams_rdm_imp_em_toolkit_items..."
 DECLARE sformattedpackagenbr = vc WITH protect, constant(format(cnvtint( $PACKAGENBR),"######;rp0"))
 DECLARE smenuitemfile = vc WITH protect, constant(concat("em_imp_menu_item_",trim( $PACKAGENBR,3),
   ".csv"))
 DECLARE slogicalinstalldirectory = vc WITH public, noconstant("")
 DECLARE smenuitemimportfile = vc WITH public, noconstant("")
 DECLARE sitemfilelogical = vc WITH public, constant("sItemFileLogical")
 DECLARE cscriptstatus = c1 WITH public, noconstant("F")
 DECLARE sscriptmsg = vc WITH public, noconstant("")
 DECLARE ipos = i4 WITH protect, noconstant(0)
 DECLARE irownbr = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 FREE RECORD rprgmsg
 RECORD rprgmsg(
   1 qual_knt = i4
   1 qual[*]
     2 message = vc
 )
 SET slogicalinstalldirectory = logical("cer_install")
 IF (cursys="AIX")
  IF (substring(size(trim(slogicalinstalldirectory,3)),1,slogicalinstalldirectory)="/")
   SET slogicalinstalldirectory = trim(slogicalinstalldirectory,3)
  ELSE
   SET slogicalinstalldirectory = build(slogicalinstalldirectory,"/")
  ENDIF
 ENDIF
 SET smenuitemimportfile = concat(trim(slogicalinstalldirectory),cnvtlower(smenuitemfile))
 IF (findfile(smenuitemimportfile))
  SET irownbr = 0
  CALL parser(concat("set logical ",trim(value(sitemfilelogical),3),' "',trim(smenuitemimportfile,3),
    '" go'))
  FREE DEFINE rtl3
  DEFINE rtl3 value(sitemfilelogical)
  SELECT INTO "NL:"
   FROM rtl3t t
   DETAIL
    irownbr = (irownbr+ 1)
   WITH nocounter
  ;end select
  IF (error(errmsg,0) != 0)
   SET readme_data->status = "S"
   SET readme_data->status = concat("Unable to read file:",errmsg)
   GO TO exit_script
  ENDIF
  FREE DEFINE rtl3
  IF (irownbr > 1)
   EXECUTE dm_dbimport value(smenuitemimportfile), "ams_ens_menu_items", 1000
   IF ((readme_data->status="F"))
    SET readme_data->status = "F"
    SET readme_data->message = trim(substring(1,255,concat(trim(readme_data->message,3),
       "- ams_ens_menu_items")),3)
   ELSE
    SET readme_data->status = "S"
    SET sscriptmsg = concat("SUCCESS Import Menu Items: ",smenuitemimportfile)
    SET readme_data->message = trim(substring(1,255,sscriptmsg),3)
   ENDIF
  ELSE
   SET readme_data->status = "S"
   SET sscriptmsg = concat("The ",trim(smenuitemimportfile,3),
    " File Contains No Explorer Menu Items to Import")
   SET readme_data->message = trim(substring(1,255,sscriptmsg),3)
   GO TO exit_script
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET sscriptmsg = concat("Unable to find file ",trim(smenuitemfile,3),
   " in the cer_install directory")
  SET readme_data->message = trim(substring(1,255,sscriptmsg),3)
 ENDIF
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 FREE RECORD rprgmsg
 CALL echorecord(readme_data)
 SET script_ver = "003 03/24/15 SF3151 Redone and Renamed for readme process"
END GO

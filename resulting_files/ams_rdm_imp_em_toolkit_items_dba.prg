CREATE PROGRAM ams_rdm_imp_em_toolkit_items:dba
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
 DECLARE smenuitemfile = vc WITH protect, constant("ams_rdm_em_toolkit_item_build.csv")
 DECLARE sitemfilelogical = vc WITH public, constant("sItemFileLogical")
 DECLARE slogicalinstalldirectory = vc WITH public, noconstant("")
 DECLARE smenuitemimportfile = vc WITH public, noconstant("")
 DECLARE cscriptstatus = c1 WITH public, noconstant("F")
 DECLARE sscriptmsg = vc WITH public, noconstant("")
 DECLARE ipos = i4 WITH protect, noconstant(0)
 DECLARE irownbr = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
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
  EXECUTE dm_dbimport value(smenuitemimportfile), "ams_rdm_ens_menu_items", 1000
  IF ((readme_data->status="F"))
   SET readme_data->status = "F"
   SET readme_data->message = trim(substring(1,255,concat(trim(readme_data->message,3),
      "- ams_rdm_ens_menu_items")),3)
  ELSE
   SET readme_data->status = "S"
   SET sscriptmsg = concat("SUCCESS Import Menu Items: ",smenuitemimportfile)
   SET readme_data->message = trim(substring(1,255,sscriptmsg),3)
  ENDIF
 ELSE
  SET readme_data->status = "F"
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
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 SET script_ver = "003 03/24/15 SF3151 Redone and Renamed for readme process"
END GO

CREATE PROGRAM dm_load_coalesce_indicators:dba
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
 SET readme_data->message = "Failed starting dm_load_coalesce_indicators..."
 FREE RECORD dlci_purgelist
 RECORD dlci_purgelist(
   1 list_0[*]
     2 templatenumber = i4
     2 dminfoname = vc
     2 realtemplatenbr = f8
 )
 DECLARE dlci_templatecnt = i4 WITH protect, noconstant(0)
 DECLARE dlci_errmsg = vc WITH protect, noconstant("")
 DECLARE dlci_infodomain = vc WITH protect, constant("DM PURGE COALESCE")
 DECLARE dlci_infonameprefix = vc WITH protect, constant("Coalesce indicator for")
 DECLARE dlci_infochar = vc WITH protect, constant(concat(
   "Coalesce indicator for a purge template. Set INFO_NUMBER to ",
   "1 to enable coalescing; set INFO_NUMBER to 0 to turn off ",
   "coalescing after a purge template runs."))
 SELECT DISTINCT INTO "nl:"
  dpt.template_nbr
  FROM dm_purge_template dpt
  WHERE  NOT (cnvtreal(dpt.template_nbr) IN (
  (SELECT
   di.info_long_id
   FROM dm_info di
   WHERE di.info_domain=dlci_infodomain)))
  HEAD REPORT
   dlci_templatecnt = 0
  DETAIL
   dlci_templatecnt = (dlci_templatecnt+ 1)
   IF (mod(dlci_templatecnt,10)=1)
    stat = alterlist(dlci_purgelist->list_0,(dlci_templatecnt+ 9))
   ENDIF
   dlci_purgelist->list_0[dlci_templatecnt].templatenumber = dpt.template_nbr, dlci_purgelist->
   list_0[dlci_templatecnt].dminfoname = concat(dlci_infonameprefix," ",build(dpt.template_nbr)),
   dlci_purgelist->list_0[dlci_templatecnt].realtemplatenbr = cnvtreal(dpt.template_nbr)
  FOOT REPORT
   stat = alterlist(dlci_purgelist->list_0,dlci_templatecnt)
  WITH nocounter
 ;end select
 IF (error(dlci_errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to build list of purge template numbers: ",dlci_errmsg)
  GO TO exit_script
 ENDIF
 IF (dlci_templatecnt=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success; no templates exist on DM_PURGE_TEMPLATE that do not have coalesce indicators."
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_info di,
   (dummyt d  WITH seq = value(dlci_templatecnt))
  SET di.info_domain = dlci_infodomain, di.info_name = dlci_purgelist->list_0[d.seq].dminfoname, di
   .info_char = dlci_infochar,
   di.info_number = 1, di.info_long_id = dlci_purgelist->list_0[d.seq].realtemplatenbr
  PLAN (d)
   JOIN (di)
  WITH nocounter
 ;end insert
 IF (error(dlci_errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert list of coalesce indicators: ",dlci_errmsg)
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Successfully loaded all coalesce indicators"
#exit_script
 FREE RECORD dlci_purgelist
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO

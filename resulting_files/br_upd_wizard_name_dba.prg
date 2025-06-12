CREATE PROGRAM br_upd_wizard_name:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_upd_wizard_name.prg> script"
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE meanings = vc WITH protect
 SET meanings = concat("'ORDWIZAP',","'ORDCATWIZBBT',","'ORDCATWIZGL',","'ORDCATWIZHLA',",
  "'ORDCATWIZMICRO',",
  "'ORDCATWIZRAD'")
 CALL brupdatewizarddisplay("Order Catalog Initial Design and Build (new projects only)",meanings)
 SET meanings = "'ORDCATWIZSL'"
 CALL brupdatewizarddisplay("Order Catalog Compare (extension projects)",meanings)
 SET meanings = concat("'ORDCATPARAMWIZAP',","'ORDCATPARAMWIZBBT',","'ORDCATPARAMWIZGL',",
  "'ORDCATPARAMWIZHLA',","'ORDCATPARAMWIZMIC',",
  "'ORDCATPARAMWIZ'")
 CALL brupdatewizarddisplay("Order Catalog Parameters (maintenance of existing orderable items)",
  meanings)
 SET meanings = "'ORDCATWIZPC'"
 CALL brupdatewizarddisplay("Patient Care Order Catalog Initial Design and Build (new projects only)",
  meanings)
 SET meanings = "'SURGPREFCARD'"
 CALL brupdatewizarddisplay("Preference Cards",meanings)
 SET meanings = "'OEFFIELDFILTER'"
 CALL brupdatewizarddisplay("Order Entry Field Value (Code Set) Filtering",meanings)
 SET meanings = "'ORDCATWIZSURG'"
 CALL brupdatewizarddisplay("Procedure Catalog Initial Design and Build (new projects only)",meanings
  )
 SET meanings = "'VOCABSYNONYM'"
 CALL brupdatewizarddisplay("Terminology Synonyms",meanings)
 SUBROUTINE brupdatewizarddisplay(wizarddisplay,meanings)
   SET bcirqualifier = concat("bcir.item_mean in (",meanings,")")
   UPDATE  FROM br_client_item_reltn bcir
    SET bcir.item_display = wizarddisplay, bcir.updt_dt_tm = cnvtdatetime(curdate,curtime), bcir
     .updt_id = reqinfo->updt_id,
     bcir.updt_task = reqinfo->updt_task, bcir.updt_applctx = reqinfo->updt_applctx, bcir.updt_cnt =
     (bcir.updt_cnt+ 1)
    WHERE parser(bcirqualifier)
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Updating br_client_item_reltn row: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   SET brsqualifier = concat("brs.step_mean in (",meanings,")")
   UPDATE  FROM br_step brs
    SET brs.step_disp = wizarddisplay, brs.updt_dt_tm = cnvtdatetime(curdate,curtime), brs.updt_id =
     reqinfo->updt_id,
     brs.updt_task = reqinfo->updt_task, brs.updt_applctx = reqinfo->updt_applctx, brs.updt_cnt = (
     brs.updt_cnt+ 1)
    WHERE parser(brsqualifier)
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Updating br_step row: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = ""
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO

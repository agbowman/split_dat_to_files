CREATE PROGRAM dm_rxs_add_reusable_ind_cd:dba
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
 SET readme_data->message = "Readme Failed: starting script dm_rxs_add_reusable_ind_cd..."
 FREE RECORD reusableitems
 RECORD reusableitems(
   1 items[*]
     2 med_dispense_id = f8
     2 med_def_flex_id = f8
   1 cluster_active_ind = i2
 )
 DECLARE scode_value = vc WITH protect, constant("CODE_VALUE")
 DECLARE block_size = i4 WITH protect, constant(500)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE errormsg = vc WITH protect, noconstant("")
 DECLARE allowtoreturnstock_cd = f8 WITH protect, noconstant(0.0)
 DECLARE inpatient_cd = f8 WITH protect, noconstant(0.0)
 DECLARE rxscatalog_cd = f8 WITH protect, noconstant(0.0)
 DECLARE syspacktype_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dispense_cd = f8 WITH protect, noconstant(0.0)
 DECLARE admcluster_cd = f8 WITH protect, noconstant(0.0)
 DECLARE system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE insertcodevalue(null) = null
 DECLARE getcodevalues(null) = null
 DECLARE getreusableitems(null) = null
 DECLARE hascluster(null) = null
 CALL getcodevalues(null)
 CALL hascluster(null)
 IF ((reusableitems->cluster_active_ind=0))
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: Readme did not update any data, because there is not a active cluster."
  GO TO exit_script
 ENDIF
 CALL getreusableitems(null)
 IF (size(reusableitems->items,5) > 0)
  CALL insertcodevalue(null)
 ENDIF
 SUBROUTINE getcodevalues(null)
   DECLARE _allowretstoc = vc WITH protect, constant("ALLOWRETSTOC")
   DECLARE _rxstncatalog = vc WITH protect, constant("RXSTNCATALOG")
   DECLARE _syspkgtyp = vc WITH protect, constant("SYSPKGTYP")
   DECLARE _system = vc WITH protect, constant("SYSTEM")
   DECLARE _inpatient = vc WITH protect, constant("INPATIENT")
   DECLARE _dispense = vc WITH protect, constant("DISPENSE")
   DECLARE _admcluster = vc WITH protect, constant("ADMCLUSTER")
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.cdf_meaning IN (_allowretstoc, _rxstncatalog, _syspkgtyp, _inpatient, _dispense,
    _admcluster, _system)
     AND cv.code_set IN (4062, 4500, 4063, 4908, 222)
    ORDER BY cv.code_value
    HEAD cv.code_value
     CASE (cv.cdf_meaning)
      OF _allowretstoc:
       allowtoreturnstock_cd = cv.code_value
      OF _rxstncatalog:
       rxscatalog_cd = cv.code_value
      OF _syspkgtyp:
       syspacktype_cd = cv.code_value
      OF _inpatient:
       inpatient_cd = cv.code_value
      OF _dispense:
       dispense_cd = cv.code_value
      OF _admcluster:
       admcluster_cd = cv.code_value
      OF _system:
       system_cd = cv.code_value
     ENDCASE
    WITH nocounter
   ;end select
   IF (error(errormsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("getCodeValues(): ",errormsg)
    GO TO exit_script
   ENDIF
   IF (allowtoreturnstock_cd=0.0)
    SET readme_data->status = "F"
    SET readme_data->message =
    "getCodeValues(): RxStation Allow To Return Stock Code Value not Exist"
    GO TO exit_script
   ELSEIF (rxscatalog_cd=0.0)
    SET readme_data->status = "F"
    SET readme_data->message = "getCodeValues(): RxStation Catalog Code Value not Exist"
    GO TO exit_script
   ELSEIF (syspacktype_cd=0.0)
    SET readme_data->status = "F"
    SET readme_data->message = "getCodeValues(): RxStation System Pack Code Value not Exist"
    GO TO exit_script
   ELSEIF (inpatient_cd=0.0)
    SET readme_data->status = "F"
    SET readme_data->message = "getCodeValues(): RxStation Pharmacy Type Code Value not Exist"
    GO TO exit_script
   ELSEIF (dispense_cd=0.0)
    SET readme_data->status = "F"
    SET readme_data->message = "getCodeValues(): RxStation Object Type Code Value not Exist"
    GO TO exit_script
   ELSEIF (admcluster_cd=0.0)
    SET readme_data->status = "F"
    SET readme_data->message = "getCodeValues(): RxStation Location Type Code Value not Exist"
    GO TO exit_script
   ELSEIF (system_cd=0.0)
    SET readme_data->status = "F"
    SET readme_data->message = "getCodeVaules(): RxStation System Type Code Value not Exist"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getreusableitems(null)
   DECLARE _itemcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_dispense mdp,
     med_def_flex mdf2
    PLAN (mdf
     WHERE mdf.sequence=0
      AND mdf.flex_type_cd=syspacktype_cd
      AND mdf.pharmacy_type_cd=inpatient_cd
      AND mdf.active_ind=1)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.active_ind=1
      AND mfoi.sequence >= 0
      AND mfoi.flex_object_type_cd=dispense_cd)
     JOIN (mdp
     WHERE mdp.med_dispense_id=mfoi.parent_entity_id
      AND mdp.reusable_ind=1)
     JOIN (mdf2
     WHERE mdf2.item_id=mdp.item_id
      AND mdf2.flex_type_cd=system_cd
      AND mdf2.sequence=0
      AND mdf2.pharmacy_type_cd=inpatient_cd
      AND mdf2.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      mfoiallowtostock.med_def_flex_id
      FROM med_flex_object_idx mfoiallowtostock
      WHERE mfoiallowtostock.med_def_flex_id=mdf2.med_def_flex_id
       AND mfoiallowtostock.sequence >= 0
       AND mfoiallowtostock.flex_object_type_cd=rxscatalog_cd
       AND mfoiallowtostock.parent_entity_id=allowtoreturnstock_cd))))
    ORDER BY mdf2.med_def_flex_id
    HEAD mdf2.med_def_flex_id
     _itemcnt = (_itemcnt+ 1)
     IF (mod(_itemcnt,block_size)=1)
      altstat = alterlist(reusableitems->items,((_itemcnt+ block_size) - 1))
     ENDIF
     reusableitems->items[_itemcnt].med_dispense_id = mdp.med_dispense_id, reusableitems->items[
     _itemcnt].med_def_flex_id = mdf2.med_def_flex_id
    WITH nocounter
   ;end select
   IF (error(errormsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("getReusableItems(): ",errormsg)
    GO TO exit_script
   ENDIF
   IF (size(reusableitems->items,5) > 0
    AND size(reusableitems->items,5) != _itemcnt)
    SET altstat = alterlist(reusableitems->items,_itemcnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE insertcodevalue(null)
  INSERT  FROM med_flex_object_idx mfoi,
    (dummyt d  WITH seq = value(size(reusableitems->items,5)))
   SET mfoi.med_flex_object_id = seq(medflex_seq,nextval), mfoi.med_def_flex_id = reusableitems->
    items[d.seq].med_def_flex_id, mfoi.parent_entity_id = allowtoreturnstock_cd,
    mfoi.parent_entity_name = scode_value, mfoi.flex_object_type_cd = rxscatalog_cd, mfoi.active_ind
     = 1,
    mfoi.updt_dt_tm = cnvtdatetime(curdate,curtime3), mfoi.updt_id = reqinfo->updt_id, mfoi.updt_cnt
     = 0,
    mfoi.updt_task = reqinfo->updt_task, mfoi.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (mfoi)
   WITH nocounter
  ;end insert
  IF (error(errormsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("insertCodeValue(): ",errormsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE hascluster(null)
  SELECT INTO "nl:"
   FROM location l
   WHERE l.location_type_cd=admcluster_cd
    AND l.active_ind=1
   DETAIL
    reusableitems->cluster_active_ind = 1
   WITH nocounter, maxrec = 1
  ;end select
  IF (error(errormsg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("hasCluster(): ",errormsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme perfomed all required tasks"
#exit_script
 CALL echo(build("allowToReturnStock_cd: ",allowtoreturnstock_cd))
 CALL echo(build("rxsCatalog_cd: ",rxscatalog_cd))
 CALL echo(build("sysPackType_cd: ",syspacktype_cd))
 CALL echo(build("inpatient_cd: ",inpatient_cd))
 CALL echo(build("dispense_cd: ",dispense_cd))
 CALL echo(build("admCluster_cd: ",admcluster_cd))
 CALL echorecord(reusableitems)
 FREE RECORD reusableitems
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 CALL echo("Mod Date: 02/06/2015 Last Mod: 000")
END GO

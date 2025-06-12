CREATE PROGRAM br_turn_on_muse3_for_eprs:dba
 CALL echo("***********************************************************")
 CALL echo("** Check if MUSE3 service is already turned on ... **")
 CALL echo("***********************************************************")
 DECLARE brnamevalueid = f8 WITH protect, noconstant(0)
 DECLARE needtoupdate = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="EPRESCRIBINGSERVICES"
    AND bnv.br_name="MUSE3")
  DETAIL
   brnamevalueid = bnv.br_name_value_id
   IF (bnv.br_value != "1")
    needtoupdate = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (needtoupdate=1
  AND brnamevalueid > 0)
  CALL echo("***********************************************************")
  CALL echo("** Turning MUSE3 service on ... **")
  CALL echo("***********************************************************")
  UPDATE  FROM br_name_value bnv
   SET br_value = "1"
   WHERE br_name_value_id=brnamevalueid
   WITH nocounter
  ;end update
  CALL echo("***********************************************************")
  CALL echo("** Success. Data NOT committed. Issue manual commit go.**")
  CALL echo("***********************************************************")
 ENDIF
 IF (brnamevalueid=0)
  CALL echo("***********************************************************")
  CALL echo("** Inserting row on BR_NAME_VALUE with br_vn_key1 = EPRESCRIBINGSERVICES **")
  CALL echo("***********************************************************")
  INSERT  FROM br_name_value bnv
   SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "EPRESCRIBINGSERVICES", bnv
    .br_name = "MUSE3",
    bnv.br_value = "1", bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task,
    bnv.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL echo("Insering into BR_NAME_VALUE failed.")
  ELSE
   CALL echo("***********************************************************")
   CALL echo("** Success. Data NOT committed. Issue manual commit go.**")
   CALL echo("***********************************************************")
  ENDIF
 ENDIF
 IF (needtoupdate=0
  AND brnamevalueid > 0)
  CALL echo("***********************************************************")
  CALL echo("** MUSE3 service is already on. No furhter action reqired. **")
  CALL echo("***********************************************************")
 ENDIF
END GO

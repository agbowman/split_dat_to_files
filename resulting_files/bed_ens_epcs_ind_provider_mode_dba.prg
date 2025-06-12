CREATE PROGRAM bed_ens_epcs_ind_provider_mode:dba
 PROMPT
  "Individual Provider Mode (Yes/No):" = ""
  WITH prompt1
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE mode = vc WITH protect, noconstant("")
 DECLARE participantid = f8 WITH protect, noconstant(0)
 DECLARE participantname = vc WITH protect, noconstant("")
 DECLARE updatesetting(modeind=i2) = i2
 SET mode =  $1
 SET mode = cnvtupper(mode)
 IF (((mode="YES") OR (((mode="Y") OR (mode="1")) )) )
  CALL updatesetting(1)
 ELSEIF (((mode="NO") OR (((mode="N") OR (mode="0")) )) )
  CALL updatesetting(0)
 ELSE
  CALL echo("Invalid Individual Provider Mode, Please use Yes or No")
 ENDIF
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   participantid = p.person_id, participantname = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 EXECUTE cclaudit 0, nullterm("EPCS Individual Provider Mode"), nullterm("Modify"),
 nullterm("System Object"), nullterm("Resource"), nullterm("Individual Provider Mode"),
 nullterm("Access/Use"), participantid, nullterm(participantname)
 SUBROUTINE updatesetting(modeind)
   DECLARE brnamevalueid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_name_value bnv
    WHERE bnv.br_client_id=0
     AND bnv.br_nv_key1="EPCSAPPROVALPATH"
     AND bnv.br_name="INDIVIDUALPROVIDERMODE"
    DETAIL
     brnamevalueid = bnv.br_name_value_id
    WITH nocounter
   ;end select
   IF (brnamevalueid=0
    AND modeind=1)
    INSERT  FROM br_name_value bnv
     SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_client_id = 0, bnv.br_nv_key1 =
      "EPCSAPPROVALPATH",
      bnv.br_name = "INDIVIDUALPROVIDERMODE", bnv.br_value = "1", bnv.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bnv.updt_cnt = 0, bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task,
      bnv.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ELSEIF (brnamevalueid > 0
    AND modeind=0)
    UPDATE  FROM br_name_value bnv
     SET bnv.br_value = "0", bnv.updt_dt_tm = cnvtdatetime(curdate,curtime), bnv.updt_cnt = (bnv
      .updt_cnt+ 1),
      bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo
      ->updt_applctx
     WHERE bnv.br_name_value_id=brnamevalueid
     WITH nocounter
    ;end update
   ELSEIF (brnamevalueid > 0
    AND modeind=1)
    UPDATE  FROM br_name_value bnv
     SET bnv.br_value = "1", bnv.updt_dt_tm = cnvtdatetime(curdate,curtime), bnv.updt_cnt = (bnv
      .updt_cnt+ 1),
      bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo
      ->updt_applctx
     WHERE bnv.br_name_value_id=brnamevalueid
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
END GO

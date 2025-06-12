CREATE PROGRAM bed_ens_mdro_drug_groups:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 drug_groups[*]
      2 drg_grp_id = f8
      2 name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD tempadddruggroup(
   1 drug_groups[*]
     2 id = f8
     2 name = vc
 )
 RECORD tempupdatedruggroup(
   1 drug_groups[*]
     2 id = f8
     2 name = vc
 )
 RECORD tempadddrug(
   1 drugs[*]
     2 drug_group_id = f8
     2 drug_code_value = f8
 )
 RECORD tempdeletedrug(
   1 drugs[*]
     2 drug_group_id = f8
     2 drug_code_value = f8
 )
 RECORD tempupdatedruggroupcount(
   1 drug_groups[*]
     2 id = f8
     2 max_drug_count = i4
 )
 RECORD tempupdateantibiotictext(
   1 organism[*]
     2 id = f8
     2 antibiotic_text = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE populatedrugs(i=i4,druggroupid=f8) = null
 SET adddruggroupcount = 0
 SET updatedruggroupcount = 0
 SET adddrugcount = 0
 SET deletedrugcount = 0
 SET updatedruggroupcountcount = 0
 SET updateantibiotictextcount = 0
 SET druggroupcount = size(request->drug_groups,5)
 IF (druggroupcount > 0)
  FOR (i = 1 TO druggroupcount)
    SET druggroupid = request->drug_groups[i].drg_grp_id
    IF ((request->drug_groups[i].drug_group_action_flag=1))
     SELECT INTO "nl:"
      temp = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       druggroupid = cnvtreal(temp)
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error selecting new drug group id.")
     SET adddruggroupcount = (adddruggroupcount+ 1)
     SET stat = alterlist(tempadddruggroup->drug_groups,adddruggroupcount)
     SET tempadddruggroup->drug_groups[adddruggroupcount].id = druggroupid
     SET tempadddruggroup->drug_groups[adddruggroupcount].name = request->drug_groups[i].name
     SET stat = alterlist(reply->drug_groups,adddruggroupcount)
     SET reply->drug_groups[adddruggroupcount].drg_grp_id = druggroupid
     SET reply->drug_groups[adddruggroupcount].name = request->drug_groups[i].name
    ELSEIF ((request->drug_groups[i].drug_group_action_flag=2))
     SET updatedruggroupcount = (updatedruggroupcount+ 1)
     SET stat = alterlist(tempupdatedruggroup->drug_groups,updatedruggroupcount)
     SET tempupdatedruggroup->drug_groups[updatedruggroupcount].id = request->drug_groups[i].
     drg_grp_id
     SET tempupdatedruggroup->drug_groups[updatedruggroupcount].name = request->drug_groups[i].name
    ENDIF
    CALL populatedrugs(i,druggroupid)
  ENDFOR
 ENDIF
 SUBROUTINE populatedrugs(i,druggroupid)
  SET drugcount = size(request->drug_groups[i].drugs,5)
  FOR (j = 1 TO drugcount)
   SET drugcodevalue = request->drug_groups[i].drugs[j].drug_code_value
   IF ((request->drug_groups[i].drugs[j].drug_action_flag=1))
    SET adddrugcount = (adddrugcount+ 1)
    SET stat = alterlist(tempadddrug->drugs,adddrugcount)
    SET tempadddrug->drugs[adddrugcount].drug_group_id = druggroupid
    SET tempadddrug->drugs[adddrugcount].drug_code_value = request->drug_groups[i].drugs[j].
    drug_code_value
   ELSEIF ((request->drug_groups[i].drugs[j].drug_action_flag=3))
    SET deletedrugcount = (deletedrugcount+ 1)
    SET stat = alterlist(tempdeletedrug->drugs,deletedrugcount)
    SET tempdeletedrug->drugs[deletedrugcount].drug_group_id = druggroupid
    SET tempdeletedrug->drugs[deletedrugcount].drug_code_value = request->drug_groups[i].drugs[j].
    drug_code_value
    SET updatedruggroupcountcount = (updatedruggroupcountcount+ 1)
    SET stat = alterlist(tempupdatedruggroupcount->drug_groups,deletedrugcount)
    SET tempupdatedruggroupcount->drug_groups[updatedruggroupcountcount].id = druggroupid
   ENDIF
  ENDFOR
 END ;Subroutine
 IF (updatedruggroupcount > 0)
  UPDATE  FROM br_drug_group dg,
    (dummyt d  WITH seq = updatedruggroupcount)
   SET dg.drug_group_name = tempupdatedruggroup->drug_groups[d.seq].name, dg.updt_cnt = (dg.updt_cnt
    + 1), dg.updt_id = reqinfo->updt_id,
    dg.updt_dt_tm = cnvtdatetime(curdate,curtime), dg.updt_task = reqinfo->updt_task, dg.updt_applctx
     = reqinfo->updt_applctx
   PLAN (d)
    JOIN (dg
    WHERE (dg.br_drug_group_id=tempupdatedruggroup->drug_groups[d.seq].id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating into br_drug_group.")
 ENDIF
 IF (deletedrugcount > 0)
  DELETE  FROM br_organism_drug_result odr,
    (dummyt d  WITH seq = deletedrugcount)
   SET odr.seq = 1
   PLAN (d)
    JOIN (odr
    WHERE odr.br_drug_group_organism_id IN (
    (SELECT
     dgo.br_drug_group_organism_id
     FROM br_drug_group_organism dgo
     WHERE (dgo.br_drug_group_id=tempdeletedrug->drugs[d.seq].drug_group_id)))
     AND odr.br_drug_group_antibiotic_id IN (
    (SELECT
     dga.br_drug_group_antibiotic_id
     FROM br_drug_group_antibiotic dga
     WHERE (dga.antibiotic_cd=tempdeletedrug->drugs[d.seq].drug_code_value)
      AND (dga.br_drug_group_id=tempdeletedrug->drugs[d.seq].drug_group_id))))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting from br_organism_drug_result.")
  SELECT INTO "nl:"
   FROM br_drug_group_organism dgo,
    (dummyt d  WITH seq = deletedrugcount)
   PLAN (d)
    JOIN (dgo
    WHERE (dgo.br_drug_group_id=tempdeletedrug->drugs[d.seq].drug_group_id))
   ORDER BY dgo.br_mdro_cat_organism_id
   HEAD dgo.br_mdro_cat_organism_id
    updateantibiotictextcount = (updateantibiotictextcount+ 1), stat = alterlist(
     tempupdateantibiotictext->organism,updateantibiotictextcount), tempupdateantibiotictext->
    organism[updateantibiotictextcount].id = dgo.br_mdro_cat_organism_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error selecting organisms to update antibiotics for.")
  DELETE  FROM br_drug_group_antibiotic dga,
    (dummyt d  WITH seq = deletedrugcount)
   SET dga.seq = 1
   PLAN (d)
    JOIN (dga
    WHERE (dga.antibiotic_cd=tempdeletedrug->drugs[d.seq].drug_code_value)
     AND (dga.br_drug_group_id=tempdeletedrug->drugs[d.seq].drug_group_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting from br_drug_group_antibiotic.")
 ENDIF
 IF (adddruggroupcount > 0)
  INSERT  FROM br_drug_group dg,
    (dummyt d  WITH seq = adddruggroupcount)
   SET dg.br_drug_group_id = tempadddruggroup->drug_groups[d.seq].id, dg.drug_group_name =
    tempadddruggroup->drug_groups[d.seq].name, dg.updt_cnt = 0,
    dg.updt_id = reqinfo->updt_id, dg.updt_dt_tm = cnvtdatetime(curdate,curtime), dg.updt_task =
    reqinfo->updt_task,
    dg.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (dg)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into br_drug_group.")
 ENDIF
 IF (adddrugcount > 0)
  INSERT  FROM br_drug_group_antibiotic dga,
    (dummyt d  WITH seq = adddrugcount)
   SET dga.br_drug_group_antibiotic_id = cnvtreal(seq(bedrock_seq,nextval)), dga.br_drug_group_id =
    tempadddrug->drugs[d.seq].drug_group_id, dga.antibiotic_cd = tempadddrug->drugs[d.seq].
    drug_code_value,
    dga.updt_cnt = 0, dga.updt_id = reqinfo->updt_id, dga.updt_dt_tm = cnvtdatetime(curdate,curtime),
    dga.updt_task = reqinfo->updt_task, dga.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (dga)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into br_drug_group_antibiotic.")
  SELECT INTO "nl:"
   FROM br_drug_group_organism dgo,
    (dummyt d  WITH seq = adddrugcount)
   PLAN (d)
    JOIN (dgo
    WHERE (dgo.br_drug_group_id=tempadddrug->drugs[d.seq].drug_group_id))
   ORDER BY dgo.br_mdro_cat_organism_id
   HEAD dgo.br_mdro_cat_organism_id
    updateantibiotictextcount = (updateantibiotictextcount+ 1), stat = alterlist(
     tempupdateantibiotictext->organism,updateantibiotictextcount), tempupdateantibiotictext->
    organism[updateantibiotictextcount].id = dgo.br_mdro_cat_organism_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error selecting organisms to update antibiotics for added drugs.")
 ENDIF
 IF (updatedruggroupcountcount > 0)
  SELECT INTO "nl:"
   FROM br_drug_group_antibiotic dga,
    (dummyt d  WITH seq = updatedruggroupcountcount)
   PLAN (d)
    JOIN (dga
    WHERE (dga.br_drug_group_id=tempupdatedruggroupcount->drug_groups[d.seq].id)
     AND dga.antibiotic_cd > 0)
   DETAIL
    tempupdatedruggroupcount->drug_groups[d.seq].max_drug_count = (tempupdatedruggroupcount->
    drug_groups[d.seq].max_drug_count+ 1)
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error selecting the number of rows from br_drug_group_antibiotic.")
  UPDATE  FROM br_drug_group_organism dgo,
    (dummyt d  WITH seq = updatedruggroupcountcount)
   SET dgo.drug_resistant_cnt = tempupdatedruggroupcount->drug_groups[d.seq].max_drug_count, dgo
    .updt_cnt = (dgo.updt_cnt+ 1), dgo.updt_id = reqinfo->updt_id,
    dgo.updt_dt_tm = cnvtdatetime(curdate,curtime), dgo.updt_task = reqinfo->updt_task, dgo
    .updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (dgo
    WHERE (dgo.br_drug_group_id=tempupdatedruggroupcount->drug_groups[d.seq].id)
     AND (dgo.drug_resistant_cnt > tempupdatedruggroupcount->drug_groups[d.seq].max_drug_count))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating the new max drugs into br_drug_group_organism.")
 ENDIF
 IF (updateantibiotictextcount > 0)
  DECLARE tempstring = vc
  SELECT INTO "nl:"
   FROM br_drug_group_organism dgo,
    br_drug_group_antibiotic dga,
    code_value cv,
    (dummyt d  WITH seq = updateantibiotictextcount)
   PLAN (d)
    JOIN (dgo
    WHERE (dgo.br_mdro_cat_organism_id=tempupdateantibiotictext->organism[d.seq].id))
    JOIN (dga
    WHERE dga.br_drug_group_id=dgo.br_drug_group_id)
    JOIN (cv
    WHERE cv.code_value=dga.antibiotic_cd)
   ORDER BY dgo.br_mdro_cat_organism_id, cnvtupper(cv.display)
   HEAD dgo.br_mdro_cat_organism_id
    tempupdateantibiotictext->organism[d.seq].antibiotic_text = ""
   HEAD cv.code_value
    tempstring = concat(trim(cv.display,3),"|"), tempstring = concat(tempupdateantibiotictext->
     organism[d.seq].antibiotic_text,tempstring), tempupdateantibiotictext->organism[d.seq].
    antibiotic_text = tempstring
   FOOT  dgo.br_mdro_cat_organism_id
    tempstring = substring(1,(size(tempupdateantibiotictext->organism[d.seq].antibiotic_text,1) - 1),
     tempupdateantibiotictext->organism[d.seq].antibiotic_text), tempupdateantibiotictext->organism[d
    .seq].antibiotic_text = trim(tempstring,3)
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error generating new antibiotic text.")
  UPDATE  FROM br_mdro_cat_organism mco,
    (dummyt d  WITH seq = updateantibiotictextcount)
   SET mco.antibiotics_txt = tempupdateantibiotictext->organism[d.seq].antibiotic_text, mco.updt_cnt
     = (mco.updt_cnt+ 1), mco.updt_id = reqinfo->updt_id,
    mco.updt_dt_tm = cnvtdatetime(curdate,curtime), mco.updt_task = reqinfo->updt_task, mco
    .updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (mco
    WHERE (mco.br_mdro_cat_organism_id=tempupdateantibiotictext->organism[d.seq].id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating antibiotic text.")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 CALL echorecord(reply)
END GO

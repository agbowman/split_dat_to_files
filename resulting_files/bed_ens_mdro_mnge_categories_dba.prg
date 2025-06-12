CREATE PROGRAM bed_ens_mdro_mnge_categories:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 category[*]
      2 category_type_ind = i2
      2 category_id = f8
      2 category_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 SET ccnt = size(request->category,5)
 IF (ccnt > 0)
  FOR (x = 1 TO ccnt)
    SET cat_id = 0.0
    SELECT INTO "nl:"
     FROM br_mdro_cat cat
     PLAN (cat
      WHERE (cat.cat_type_flag=request->category[x].category_type_ind)
       AND (cat.mdro_cat_name=request->category[x].category_name))
     DETAIL
      cat_id = cat.br_mdro_cat_id
     WITH nocounter
    ;end select
    IF (cat_id=0)
     SELECT INTO "nl:"
      temp = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       cat_id = cnvtreal(temp)
      WITH nocounter
     ;end select
     SET ierrcode = 0
     INSERT  FROM br_mdro_cat cat
      SET cat.br_mdro_cat_id = cat_id, cat.mdro_cat_name = request->category[x].category_name, cat
       .cat_type_flag = request->category[x].category_type_ind,
       cat.updt_cnt = 0, cat.updt_id = reqinfo->updt_id, cat.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       cat.updt_task = reqinfo->updt_task, cat.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     CALL bederrorcheck("Error on Inserting New Category")
     SET stat = alterlist(reply->category,x)
     SET reply->category[x].category_id = cat_id
     SET reply->category[x].category_name = request->category[x].category_name
     SET reply->category[x].category_type_ind = request->category[x].category_type_ind
    ENDIF
    SET icnt = size(request->category[x].mdro,5)
    IF (icnt > 0)
     FOR (y = 1 TO icnt)
       IF ((request->category[x].mdro[y].mdro_type_ind=1))
        SET ierrcode = 0
        UPDATE  FROM br_mdro_cat_event cat_e
         SET cat_e.br_mdro_cat_id = cat_id, cat_e.lookback_time_span_nbr = request->category[x].mdro[
          y].lookback_time_span_nbr, cat_e.lookback_time_span_unit_cd = request->category[x].mdro[y].
          lookback_time_span_unit_cd,
          cat_e.updt_cnt = (cat_e.updt_cnt+ 1), cat_e.updt_id = reqinfo->updt_id, cat_e.updt_dt_tm =
          cnvtdatetime(curdate,curtime),
          cat_e.updt_task = reqinfo->updt_task, cat_e.updt_applctx = reqinfo->updt_applctx
         WHERE (cat_e.br_mdro_cat_event_id=request->category[x].mdro[y].mdro_code_value)
          AND cat_e.br_mdro_cat_event_id > 0
         WITH nocounter
        ;end update
        CALL bederrorcheck("Error on updating Category for the Serology Result")
       ELSEIF ((request->category[x].mdro[y].mdro_type_ind=2))
        SET ierrcode = 0
        UPDATE  FROM br_mdro_cat_organism cat_o
         SET cat_o.br_mdro_cat_id = cat_id, cat_o.lookback_time_span_nbr = request->category[x].mdro[
          y].lookback_time_span_nbr, cat_o.lookback_time_span_unit_cd = request->category[x].mdro[y].
          lookback_time_span_unit_cd,
          cat_o.updt_cnt = (cat_o.updt_cnt+ 1), cat_o.updt_id = reqinfo->updt_id, cat_o.updt_dt_tm =
          cnvtdatetime(curdate,curtime),
          cat_o.updt_task = reqinfo->updt_task, cat_o.updt_applctx = reqinfo->updt_applctx
         WHERE (cat_o.br_mdro_cat_organism_id=request->category[x].mdro[y].mdro_code_value)
          AND cat_o.br_mdro_cat_organism_id > 0
         WITH nocounter
        ;end update
        CALL bederrorcheck("Error on updating Category for the Organism")
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SET dcnt = size(request->del_category,5)
 IF (dcnt > 0)
  FOR (d = 1 TO dcnt)
    SET o_ind = 0.0
    SELECT INTO "nl:"
     FROM br_mdro_cat_organism cato
     PLAN (cato
      WHERE (cato.br_mdro_cat_id=request->del_category[d].category_id))
     DETAIL
      o_ind = 1
     WITH nocounter
    ;end select
    SET e_ind = 0.0
    SELECT INTO "nl:"
     FROM br_mdro_cat_event cate
     PLAN (cate
      WHERE (cate.br_mdro_cat_id=request->del_category[d].category_id))
     DETAIL
      e_ind = 1
     WITH nocounter
    ;end select
    IF (o_ind=0.0
     AND e_ind=0.0)
     SET ierrcode = 0
     DELETE  FROM br_mdro_cat cat
      PLAN (cat
       WHERE (cat.br_mdro_cat_id=request->del_category[d].category_id)
        AND (cat.cat_type_flag=request->del_category[d].category_type_ind)
        AND (cat.mdro_cat_name=request->del_category[d].category_name))
      WITH nocounter
     ;end delete
     CALL bederrorcheck("Error on deleting from br_mdro_cat")
    ENDIF
  ENDFOR
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
END GO

CREATE PROGRAM cnt_imp_dta_ref_text:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE ttype_uid = vc WITH public, noconstant("")
 DECLARE ttype_cd = f8 WITH public, noconstant(0.0)
 DECLARE ta_uid = vc WITH public, noconstant("")
 DECLARE tmp_dta_key_id = f8 WITH public, noconstant(0.0)
 DECLARE ttype_column_ind = i2 WITH public, noconstant(0)
 RANGE OF c IS cnt_ref_text
 SET ttype_column_ind = validate(c.text_type_cd)
 FREE RANGE c
 SELECT INTO "jl2501.log"
  FROM dual
  DETAIL
   col 0, "running cnt_imp_dta_ref_text", row + 1
  WITH append
 ;end select
 FOR (i = 1 TO value(size(request->list_0,5)))
   SELECT INTO "nl:"
    FROM cnt_code_value_key c
    PLAN (c
     WHERE c.code_set=6009
      AND (c.cdf_meaning=request->list_0[i].text_type_mean))
    DETAIL
     ttype_uid = c.code_value_uid, ttype_cd = c.code_value
    WITH check
   ;end select
   IF ((request->list_0[i].task_assay_guid > " "))
    SET ta_uid = request->list_0[i].task_assay_guid
    SET ta_uid = replace(ta_uid,"UNKNOWN!","CERNER!",1)
   ELSE
    SET ta_uid = concat("TEMP!",request->list_0[i].dta_mnemonic)
    SELECT INTO "nl:"
     FROM cnt_dta_key2 c
     PLAN (c
      WHERE (c.task_assay_disp=request->list_0[i].dta_mnemonic))
     ORDER BY c.updt_dt_tm DESC
     HEAD c.task_assay_disp
      ta_uid = c.task_assay_uid
     WITH check
    ;end select
   ENDIF
   IF (ttype_uid > "")
    DELETE  FROM cnt_ref_text c
     WHERE c.task_assay_uid=ta_uid
      AND c.text_type_cduid=ttype_uid
     WITH nocounter
    ;end delete
    SET tmp_dta_key_id = 0.0
    SELECT INTO "nl:"
     FROM cnt_dta_key2 c
     PLAN (c
      WHERE c.task_assay_uid=ta_uid)
     DETAIL
      tmp_dta_key_id = c.cnt_dta_key_id
     WITH check
    ;end select
    IF (ttype_column_ind=1)
     INSERT  FROM cnt_ref_text c
      SET c.cnt_dta_key_id = tmp_dta_key_id, c.cnt_ref_blob = request->list_0[i].long_blob, c
       .cnt_ref_text_id = seq(reference_seq,nextval),
       c.cnt_ref_text_uid = concat("TEMP!",ta_uid,":",request->list_0[i].text_type_mean), c
       .task_assay_uid = ta_uid, c.text_type_cd = 0.0,
       c.text_type_cduid = ttype_uid, c.updt_cnt = 0, c.updt_task = reqinfo->updt_task,
       c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_applctx =
       reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM cnt_ref_text c
      SET c.cnt_dta_key_id = tmp_dta_key_id, c.cnt_ref_blob = request->list_0[i].long_blob, c
       .cnt_ref_text_id = seq(reference_seq,nextval),
       c.cnt_ref_text_uid = concat("TEMP!",ta_uid,":",request->list_0[i].text_type_mean), c
       .task_assay_uid = ta_uid, c.text_type_cduid = ttype_uid,
       c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.updt_dt_tm = cnvtdatetime(curdate,curtime3
        ),
       c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ELSE
    SELECT INTO "cnt_imp_dta_ref_text.log"
     FROM dual
     DETAIL
      col 0, "Text Type NOT found for:", col 30,
      request->list_0[i].text_type_mean, row + 1
     WITH append
    ;end select
   ENDIF
 ENDFOR
 IF (ttype_column_ind=1)
  UPDATE  FROM cnt_ref_text c
   SET c.text_type_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.text_type_cduid)
   WHERE c.text_type_cd=0.0
    AND c.text_type_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.text_type_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
 SET reply->status_data = "S"
#exit_script
END GO

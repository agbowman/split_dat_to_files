CREATE PROGRAM bed_ens_orgstandardpool_nvp
 DECLARE bnvid = f8
 DECLARE val = vc
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET val = fillstring(1," ")
 SET error_flag = "N"
 IF ((request->pool_ind=0))
  SET val = "0"
 ELSEIF ((request->pool_ind=1))
  SET val = "1"
 ELSE
  SET error_flag = "T"
  SET error_msg = "Invalid parameter in request - must be 0 or 1"
  GO TO exit_script
 ENDIF
 SET bnvid = 0.0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="SYSTEMPARAM"
    AND bnv.br_name="ORGSTANDARDPOOL")
  DETAIL
   bnvid = bnv.br_name_value_id
  WITH nocounter
 ;end select
 IF (bnvid=0)
  CALL add_nvp(1)
 ELSE
  UPDATE  FROM br_name_value bnv
   SET bnv.br_value = val
   WHERE bnv.br_name_value_id=bnvid
  ;end update
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = "Error updating br_name_value for br_name: ORGSTANDARDPOOL"
  ENDIF
 ENDIF
 GO TO exitscript
 SUBROUTINE add_nvp(x)
   SET name_value_id = 0.0
   SELECT INTO "nl:"
    y = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_id = cnvtreal(y)
    WITH format, counter
   ;end select
   IF (name_value_id=0)
    SET error_flag = "Y"
    SET error_msg = "Error generating new name_value_id"
   ELSE
    INSERT  FROM br_name_value br
     SET br.br_name_value_id = name_value_id, br.br_nv_key1 = "SYSTEMPARAM", br.br_name =
      "ORGSTANDARDPOOL",
      br.br_value = val, br.updt_cnt = 0, br.updt_dt_tm = cnvtdatetime(curdate,curtime),
      br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = "Error adding br_name_value row for br_name ORGSTANDARDPOOL"
    ENDIF
   ENDIF
 END ;Subroutine
#exitscript
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->error_msg = concat("  >>PROGRAM NAME: BED_ENS_ORGSTANDARDPOOL_NVP","  >>ERROR MSG: ",
   error_msg)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO

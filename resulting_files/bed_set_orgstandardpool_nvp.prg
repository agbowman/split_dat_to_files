CREATE PROGRAM bed_set_orgstandardpool_nvp
 PROMPT
  "Should new facilities be automatically related to the nine standard alias pools? (Yes or No) " =
  "Yes"
  WITH response
 DECLARE val = i4
 DECLARE bnvid = f8
 DECLARE resp = vc
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 FREE SET bnv_request
 RECORD bnv_request(
   1 br_name = vc
   1 br_value = vc
   1 br_nv_key1 = vc
 )
 FREE SET bnv_reply
 RECORD bnv_reply(
   1 br_name_value_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET resp =  $RESPONSE
 CALL echo(build("resp = ",resp))
 CASE (resp)
  OF "Yes":
   SET val = 1
  OF "Y":
   SET val = 1
  OF "yes":
   SET val = 1
  OF "YES":
   SET val = 1
  OF "y":
   SET val = 1
  OF "No":
   SET val = 0
  OF "N":
   SET val = 0
  OF "no":
   SET val = 0
  OF "NO":
   SET val = 0
  OF "n":
   SET val = 0
  ELSE
   SET val = 99
 ENDCASE
 IF (val=99)
  SET error_flag = "Y"
  SET error_msg = "Invalid entry - program terminating"
  GO TO exitscript
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
   SET bnv.br_value = cnvtstring(val)
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
      br.br_value = cnvtstring(val), br.updt_cnt = 0, br.updt_dt_tm = cnvtdatetime(curdate,curtime),
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
  CALL echo(build(error_msg))
 ELSE
  COMMIT
 ENDIF
END GO

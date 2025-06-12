CREATE PROGRAM cs_upt_interface_charge_flg:dba
 RECORD reply(
   1 interface_charge[*]
     2 interface_charge_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_process TO 2999_process_exit
 GO TO 9999_end
#1000_initialize
 SET reply->status_data.status = "F"
 IF (validate(reqinfo->commit_ind,"!!")="!!")
  RECORD reqinfo(
    1 updt_id = i4
    1 updt_task = i4
    1 updt_applctx = i4
    1 commit_ind = i2
  )
  SET reqinfo->updt_id = 1
  SET reqinfo->updt_task = 1
  SET reqinfo->updt_applctx = 1
 ENDIF
 SET reqinfo->commit_ind = 0
#1999_initialize_exit
#2000_process
 SET total = size(request->qual,5)
 SET stat = alterlist(reply->interface_charge,total)
 FOR (i = 1 TO total)
   SELECT INTO "nl:"
    c.seq
    FROM interface_charge c
    WHERE (c.interface_charge_id=request->qual[i].interface_charge_id)
    WITH forupdate(c)
   ;end select
   UPDATE  FROM interface_charge c
    SET c.process_flg = 999, c.updt_cnt = (c.updt_cnt+ 1), c.updt_id = reqinfo->updt_id,
     c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    PLAN (c
     WHERE (c.interface_charge_id=request->qual[i].interface_charge_id))
    WITH nocounter
   ;end update
   IF (curqual > 0)
    SET reply->status_data.status = "S"
    SET reply->interface_charge[i].interface_charge_id = request->qual[i].interface_charge_id
   ELSE
    SET reply->status_data.status = "F"
    SET i = total
   ENDIF
 ENDFOR
#2999_process_exit
#9999_end
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ENDIF
END GO

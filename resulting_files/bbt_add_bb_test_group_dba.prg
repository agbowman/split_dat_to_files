CREATE PROGRAM bbt_add_bb_test_group:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE new_bb_test_group_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_bb_grp_cmpnt_id = f8 WITH protect, noconstant(0.0)
 SET count1 = 0
 SET group_cnt = size(request->grouplist,5)
 FOR (grp = 1 TO group_cnt)
   SET new_bb_test_group_id = 0.0
   SELECT INTO "nl:"
    nextseqnum = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_bb_test_group_id = nextseqnum
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","get next pathnet_seq",
     "could not get next pathnet_seq for bb_test_group")
    GO TO exit_script
   ENDIF
   INSERT  FROM bb_test_group btg
    SET btg.bb_test_group_id = new_bb_test_group_id, btg.test_group_display = request->grouplist[grp]
     .test_group_display, btg.test_group_description = request->grouplist[grp].test_group_description,
     btg.active_ind = 1, btg.active_status_dt_tm = cnvtdatetime(curdate,curtime3), btg
     .active_status_prsnl_id = reqinfo->updt_id,
     btg.updt_cnt = 0, btg.updt_dt_tm = cnvtdatetime(curdate,curtime3), btg.updt_id = reqinfo->
     updt_id,
     btg.updt_task = reqinfo->updt_task, btg.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL load_process_status("F","add bb_test_group","error inserting row in bb_test_group")
    GO TO exit_script
   ENDIF
   SET cmpnt_cnt = size(request->grouplist[grp].cmpntlist,5)
   FOR (cmpnt = 1 TO cmpnt_cnt)
     SET new_bb_grp_cmpnt_id = 0.0
     SELECT INTO "nl:"
      nextseqnum = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       new_bb_grp_cmpnt_id = nextseqnum
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      CALL load_process_status("F","get next pathnet_seq",
       "could not get next pathnet_seq for bb_group_component")
      GO TO exit_script
     ENDIF
     INSERT  FROM bb_group_component bgc
      SET bgc.bb_group_component_id = new_bb_grp_cmpnt_id, bgc.bb_test_group_id =
       new_bb_test_group_id, bgc.catalog_cd = request->grouplist[grp].cmpntlist[cmpnt].catalog_cd,
       bgc.active_ind = 1, bgc.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bgc
       .active_status_prsnl_id = reqinfo->updt_id,
       bgc.updt_cnt = 0, bgc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bgc.updt_id = reqinfo->
       updt_id,
       bgc.updt_task = reqinfo->updt_task, bgc.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL load_process_status("F","add bb_group_component",
       "error inserting row in bb_group_component")
      GO TO exit_script
     ENDIF
   ENDFOR
 ENDFOR
 GO TO exit_script
 CALL load_process_status("S","SUCCESS","SUCCESS")
 GO TO exit_script
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 = (size(reply->status_data.subeventstatus,5)+ 1)
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_bb_test_group"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO

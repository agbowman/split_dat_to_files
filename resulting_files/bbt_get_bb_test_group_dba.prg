CREATE PROGRAM bbt_get_bb_test_group:dba
 RECORD reply(
   1 grouplist[*]
     2 bb_test_group_id = f8
     2 test_group_display = c15
     2 test_group_description = vc
     2 active_ind = i2
     2 updt_cnt = i4
     2 cmpntlist[*]
       3 bb_group_component_id = f8
       3 catalog_cd = f8
       3 catalog_disp = c40
       3 catalog_mean = c12
       3 catalog_desc = c60
       3 sequence = i4
       3 active_ind = i2
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET select_ok_ind = 0
 SET group_cnt = 0
 SET cmpnt_cnt = 0
 SELECT INTO "nl:"
  btg.bb_test_group_id, btg.test_group_display, btg.test_group_description,
  btg.active_ind, btg.updt_cnt, bgc.bb_group_component_id,
  bgc.catalog_cd, bgc.active_ind, bgc.updt_cnt
  FROM bb_test_group btg,
   (dummyt d_bgc  WITH seq = 1),
   bb_group_component bgc
  PLAN (btg
   WHERE btg.bb_test_group_id != null
    AND btg.bb_test_group_id > 0
    AND (((request->return_inactive_ind != 1)
    AND btg.active_ind=1) OR ((request->return_inactive_ind=1))) )
   JOIN (d_bgc
   WHERE d_bgc.seq=1)
   JOIN (bgc
   WHERE bgc.bb_test_group_id=btg.bb_test_group_id
    AND bgc.bb_group_component_id != null
    AND bgc.bb_group_component_id > 0
    AND bgc.active_ind=1)
  ORDER BY btg.bb_test_group_id, bgc.bb_group_component_id
  HEAD REPORT
   group_cnt = 0, stat = alterlist(reply->grouplist,10)
  HEAD btg.bb_test_group_id
   group_cnt = (group_cnt+ 1)
   IF (mod(group_cnt,10)=1
    AND group_cnt != 1)
    stat = alterlist(reply->grouplist,(group_cnt+ 9))
   ENDIF
   reply->grouplist[group_cnt].bb_test_group_id = btg.bb_test_group_id, reply->grouplist[group_cnt].
   test_group_display = btg.test_group_display, reply->grouplist[group_cnt].test_group_description =
   btg.test_group_description,
   reply->grouplist[group_cnt].active_ind = btg.active_ind, reply->grouplist[group_cnt].updt_cnt =
   btg.updt_cnt, cmpnt_cnt = 0,
   stat = alterlist(reply->grouplist[group_cnt].cmpntlist,10)
  HEAD bgc.bb_group_component_id
   IF (bgc.bb_group_component_id > 0)
    cmpnt_cnt = (cmpnt_cnt+ 1)
    IF (mod(cmpnt_cnt,10)=1
     AND cmpnt_cnt != 1)
     stat = alterlist(reply->grouplist[group_cnt].cmpntlist,(cmpnt_cnt+ 9))
    ENDIF
    reply->grouplist[group_cnt].cmpntlist[cmpnt_cnt].bb_group_component_id = bgc
    .bb_group_component_id, reply->grouplist[group_cnt].cmpntlist[cmpnt_cnt].catalog_cd = bgc
    .catalog_cd, reply->grouplist[group_cnt].cmpntlist[cmpnt_cnt].sequence = bgc.sequence,
    reply->grouplist[group_cnt].cmpntlist[cmpnt_cnt].active_ind = bgc.active_ind, reply->grouplist[
    group_cnt].cmpntlist[cmpnt_cnt].updt_cnt = bgc.updt_cnt
   ENDIF
  FOOT  btg.bb_test_group_id
   stat = alterlist(reply->grouplist[group_cnt].cmpntlist,cmpnt_cnt)
  FOOT REPORT
   stat = alterlist(reply->grouplist,group_cnt), select_ok_ind = 1
  WITH nocounter, outerjoin(d_bgc), nullreport
 ;end select
 IF (select_ok_ind=1)
  IF (curqual=0)
   CALL load_process_status("Z","select bb_test_group/bb_group_component",
    "ZERO rows found on bb_test_group/bb_group_component")
  ELSE
   CALL load_process_status("S","select bb_test_group/bb_group_component","SUCCESS")
  ENDIF
 ELSE
  CALL load_process_status("F","select bb_test_group/bb_group_component",
   "Select on bb_test_group/bb_group_component FAILED")
 ENDIF
 GO TO exit_script
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_bb_test_group"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
 CALL echo(build("status_data->status =",reply->status_data.status))
 FOR (x = 1 TO count1)
   CALL echo(reply->status_data.subeventstatus[x].operationname)
   CALL echo(reply->status_data.subeventstatus[x].operationstatus)
   CALL echo(reply->status_data.subeventstatus[x].targetobjectname)
   CALL echo(reply->status_data.subeventstatus[x].targetobjectvalue)
 ENDFOR
 FOR (grp = 1 TO group_cnt)
  CALL echo(build(grp,">",reply->grouplist[grp].bb_test_group_id,"/",reply->grouplist[grp].
    test_group_display,
    "/",reply->grouplist[grp].test_group_description,"/",reply->grouplist[grp].active_ind,"/",
    reply->grouplist[grp].updt_cnt))
  FOR (cmpnt = 1 TO cnvtint(size(reply->grouplist[grp].cmpntlist,5)))
    CALL echo(build(".....",cmpnt,">",reply->grouplist[grp].cmpntlist[cmpnt].bb_group_component_id,
      "/",
      reply->grouplist[grp].cmpntlist[cmpnt].catalog_cd,"/",reply->grouplist[grp].cmpntlist[cmpnt].
      active_ind,"/",reply->grouplist[grp].cmpntlist[cmpnt].updt_cnt))
  ENDFOR
 ENDFOR
END GO

CREATE PROGRAM br_get_clinfo:dba
 FREE SET reply
 RECORD reply(
   1 item_list[*]
     2 active_ind = i2
     2 br_client_id = f8
     2 br_client_name = vc
     2 start_version_number = i4
     2 operating_system = vc
     2 client_mnemonic = vc
     2 site_ready_ind = i2
     2 data_move_ready_ind = i2
     2 autobuild_client_id = f8
     2 franchise_flag = i2
     2 franchise_client_id = f8
     2 region = vc
     2 unknown_age_ind = i2
     2 unknown_sex_ind = i2
     2 suplist[*]
       3 supplier_flag = i2
       3 supplier_name = vc
       3 default_selected = i2
     2 prsnl_list[*]
       3 br_prsnl_id = f8
       3 active_ind = i2
       3 name_full_formatted = vc
       3 email = vc
       3 position_cd = f8
       3 position_mean = vc
       3 position_disp = vc
       3 name_last = vc
       3 name_first = vc
       3 username = vc
       3 user_type_flag = i2
       3 user_sclist[*]
         4 item_mean = vc
         4 item_type = vc
         4 item_disp = vc
         4 item_lead_ind = i2
         4 item_selected_ind = i2
         4 slist[*]
           5 item_mean = vc
           5 item_type = vc
           5 item_disp = vc
           5 item_lead_ind = i2
           5 item_selected_ind = i2
     2 sol_list[*]
       3 sol_display = vc
       3 sol_mean = vc
       3 status_flag = i2
       3 sequence = i4
       3 step_list[*]
         4 step_mean = vc
         4 step_disp = vc
         4 step_type = vc
         4 status_flag = i2
         4 sequence = i4
         4 lead_username = vc
         4 est_min_to_complete = i2
         4 step_cat_mean = vc
         4 step_cat_disp = vc
         4 availability_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE active_ind1 = i2
 DECLARE active_ind2 = i2
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE cloop = i4
 DECLARE cloop2 = i4
 DECLARE repcnt = i4
 DECLARE repcnt2 = i4
 DECLARE parser_str = vc
 SET repcnt = 0
 SET repcnt2 = 0
 SET count1 = 0
 SET count2 = 0
 SET active_ind1 = 1
 SET active_ind2 = 1
 SET cnt = 0
 SET cnt2 = 0
 SET cnt3 = 0
 SET reply->status_data.status = "F"
 SET count1 = size(request->item_list,5)
 SET stat = alterlist(reply->status_data.subeventstatus,count1)
 IF ((request->get_item_ind=0)
  AND (request->get_prsnl_ind=0)
  AND (request->get_sol_ind=0)
  AND (request->get_prsnl_step_ind=0))
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BR_CLIENT_ID"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "All get indicators set to zero, invalid script call."
  GO TO exit_script
 ENDIF
 FOR (cloop = 1 TO count1)
   SET stat = alterlist(reply->item_list,cloop)
   IF ((request->get_item_ind=1))
    SELECT INTO "nl:"
     FROM br_client b
     WHERE (b.br_client_id=request->item_list[cloop].br_client_id)
     DETAIL
      repcnt = (repcnt+ 1), reply->item_list[cloop].br_client_name = b.br_client_name, reply->
      item_list[cloop].start_version_number = b.start_version_nbr,
      reply->item_list[cloop].operating_system = b.operating_system, reply->item_list[cloop].
      br_client_id = b.br_client_id, reply->item_list[cloop].active_ind = b.active_ind,
      reply->item_list[cloop].client_mnemonic = b.client_mnemonic, reply->item_list[cloop].
      site_ready_ind = b.site_ready_ind, reply->item_list[cloop].data_move_ready_ind = b
      .data_move_ready_ind,
      reply->item_list[cloop].autobuild_client_id = b.autobuild_client_id, reply->item_list[cloop].
      franchise_flag = b.franchise_flag, reply->item_list[cloop].franchise_client_id = b
      .franchise_client_id,
      reply->item_list[cloop].region = b.region
     WITH counter, skipbedrock = 1
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM br_client b
     WHERE (b.br_client_id=request->item_list[cloop].br_client_id)
     DETAIL
      reply->item_list[cloop].br_client_id = b.br_client_id, reply->item_list[cloop].active_ind = b
      .active_ind
     WITH counter, skipbedrock = 1
    ;end select
   ENDIF
   IF (curqual < 1)
    SET reply->status_data.subeventstatus[cloop].operationname = "select"
    SET reply->status_data.subeventstatus[cloop].operationstatus = "F"
    SET reply->status_data.subeventstatus[cloop].targetobjectname = "BR_CLIENT_ID"
    SET reply->status_data.subeventstatus[cloop].targetobjectvalue = build("BR_CLIENT_ID not found: ",
     request->item_list[cloop].br_client_id)
    GO TO exit_script
   ELSE
    IF ((request->get_item_ind=1))
     SELECT INTO "nl:"
      FROM br_name_value bnv
      PLAN (bnv
       WHERE bnv.br_nv_key1="SYSTEMPARAM"
        AND (bnv.br_client_id=request->item_list[cloop].br_client_id))
      DETAIL
       IF (bnv.br_name="UNKNOWNAGEIND")
        reply->item_list[cloop].unknown_age_ind = cnvtint(bnv.br_value)
       ELSEIF (bnv.br_name="UNKNOWNSEXIND")
        reply->item_list[cloop].unknown_sex_ind = cnvtint(bnv.br_value)
       ENDIF
      WITH nocounter, skipbedrock = 1
     ;end select
     SET supcnt = 0
     SELECT INTO "nl:"
      FROM br_rli_supplier brs
      PLAN (brs
       WHERE brs.supplier_flag > 0
        AND (brs.br_client_id=request->item_list[cloop].br_client_id))
      ORDER BY brs.supplier_name
      DETAIL
       supcnt = (supcnt+ 1), stat = alterlist(reply->item_list[cloop].suplist,supcnt), reply->
       item_list[cloop].suplist[supcnt].supplier_flag = brs.supplier_flag,
       reply->item_list[cloop].suplist[supcnt].supplier_name = brs.supplier_name, reply->item_list[
       cloop].suplist[supcnt].default_selected = brs.default_selected_ind
      WITH nocounter, skipbedrock = 1
     ;end select
    ENDIF
    SET repcnt2 = 0
    IF ((request->get_prsnl_ind=1))
     SET active_ind2 = 1
     IF ((request->include_inactive_child_ind=1))
      SET active_ind2 = 0
     ENDIF
     SELECT INTO "nl:"
      p.name_full_formatted, p.br_prsnl_id, p.username
      FROM br_client_prsnl_reltn bcpr,
       br_prsnl p
      PLAN (bcpr
       WHERE value(request->item_list[cloop].br_client_id)=bcpr.br_client_id
        AND bcpr.active_ind IN (active_ind1, active_ind2))
       JOIN (p
       WHERE p.br_prsnl_id=bcpr.br_prsnl_id)
      HEAD REPORT
       repcnt2 = 0
      DETAIL
       repcnt2 = (repcnt2+ 1), stat = alterlist(reply->item_list[cloop].prsnl_list,repcnt2), reply->
       item_list[cloop].prsnl_list[repcnt2].br_prsnl_id = p.br_prsnl_id,
       reply->item_list[cloop].prsnl_list[repcnt2].name_full_formatted = p.name_full_formatted, reply
       ->item_list[cloop].prsnl_list[repcnt2].username = p.username, reply->item_list[cloop].
       prsnl_list[repcnt2].active_ind = bcpr.active_ind,
       reply->item_list[cloop].prsnl_list[repcnt2].name_last = p.name_last, reply->item_list[cloop].
       prsnl_list[repcnt2].name_first = p.name_first, reply->item_list[cloop].prsnl_list[repcnt2].
       position_cd = 441,
       reply->item_list[cloop].prsnl_list[repcnt2].email = p.email
      WITH counter, skipbedrock = 1
     ;end select
    ENDIF
    IF (repcnt2 < 1
     AND (request->get_prsnl_ind=1))
     SET reply->status_data.subeventstatus[cloop].operationname = "select"
     SET reply->status_data.subeventstatus[cloop].operationstatus = "Z"
     SET reply->status_data.subeventstatus[cloop].targetobjectname = "BR_PRSNL"
     SET reply->status_data.subeventstatus[cloop].targetobjectvalue =
     "No BR_CLIENT_PRSNL_RELTN records found"
    ELSE
     IF (repcnt2 > 0
      AND (request->get_prsnl_step_ind=1))
      FOR (x = 1 TO repcnt2)
        SET cnt = 0
        SELECT INTO "nl:"
         FROM br_name_value bnv
         PLAN (bnv
          WHERE bnv.br_nv_key1="STEP_CAT_MEAN"
           AND (bnv.br_client_id=request->item_list[cloop].br_client_id))
         DETAIL
          cnt = (cnt+ 1), stat = alterlist(reply->item_list[cloop].prsnl_list[x].user_sclist,cnt),
          reply->item_list[cloop].prsnl_list[x].user_sclist[cnt].item_mean = bnv.br_name,
          reply->item_list[cloop].prsnl_list[x].user_sclist[cnt].item_disp = bnv.br_value
         WITH nocounter, skipbedrock = 1
        ;end select
        FOR (z = 1 TO cnt)
          SET scscnt = 0
          SELECT INTO "nl:"
           FROM br_step bs
           PLAN (bs
            WHERE (bs.step_cat_mean=reply->item_list[cloop].prsnl_list[x].user_sclist[z].item_mean))
           ORDER BY bs.step_disp
           HEAD REPORT
            scscnt = 0
           DETAIL
            scscnt = (scscnt+ 1), stat = alterlist(reply->item_list[cloop].prsnl_list[x].user_sclist[
             z].slist,scscnt), reply->item_list[cloop].prsnl_list[x].user_sclist[z].slist[scscnt].
            item_mean = bs.step_mean,
            reply->item_list[cloop].prsnl_list[x].user_sclist[z].slist[scscnt].item_disp = bs
            .step_disp
           WITH nocounter, skipbedrock = 1
          ;end select
          SELECT INTO "nl:"
           FROM br_prsnl_item_reltn b
           PLAN (b
            WHERE (b.br_prsnl_id=reply->item_list[cloop].prsnl_list[x].br_prsnl_id)
             AND b.item_type="STEPCAT"
             AND (b.br_client_id=request->item_list[cloop].br_client_id)
             AND (b.item_mean=reply->item_list[cloop].prsnl_list[x].user_sclist[z].item_mean))
           DETAIL
            reply->item_list[cloop].prsnl_list[x].user_sclist[z].item_selected_ind = 1, reply->
            item_list[cloop].prsnl_list[x].user_sclist[z].item_lead_ind = b.item_lead_ind
           WITH nocounter, skipbedrock = 1
          ;end select
          IF (curqual=0)
           FOR (zz = 1 TO scscnt)
             SELECT INTO "nl:"
              FROM br_prsnl_item_reltn b
              PLAN (b
               WHERE (b.br_prsnl_id=reply->item_list[cloop].prsnl_list[x].br_prsnl_id)
                AND b.item_type="STEP"
                AND (b.br_client_id=request->item_list[cloop].br_client_id)
                AND (b.item_mean=reply->item_list[cloop].prsnl_list[x].user_sclist[z].slist[zz].
               item_mean))
              DETAIL
               reply->item_list[cloop].prsnl_list[x].user_sclist[z].slist[zz].item_selected_ind = 1,
               reply->item_list[cloop].prsnl_list[x].user_sclist[z].slist[zz].item_lead_ind = b
               .item_lead_ind
              WITH nocounter, skipbedrock = 1
             ;end select
           ENDFOR
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   IF ((request->get_sol_ind=1))
    SET sol_cnt = 0
    SELECT INTO "nl:"
     FROM br_client_item_reltn b,
      br_client_sol_step bcss,
      br_client_item_reltn bcir,
      br_step bs
     PLAN (b
      WHERE b.br_client_id=value(request->item_list[cloop].br_client_id)
       AND b.item_type="SOLUTION")
      JOIN (bcss
      WHERE bcss.br_client_id=outerjoin(b.br_client_id)
       AND bcss.solution_mean=outerjoin(b.item_mean))
      JOIN (bcir
      WHERE bcir.br_client_id=outerjoin(bcss.br_client_id)
       AND bcir.item_type=outerjoin("STEP")
       AND bcir.item_mean=outerjoin(bcss.step_mean))
      JOIN (bs
      WHERE bs.step_mean=outerjoin(bcir.item_mean))
     ORDER BY b.solution_seq, bcss.sequence
     HEAD REPORT
      cnt = 0, status0_ind = 0, status1_ind = 0,
      status2_ind = 0
     HEAD b.br_client_item_reltn_id
      cnt = (cnt+ 1), stat = alterlist(reply->item_list[cloop].sol_list,cnt), reply->item_list[cloop]
      .sol_list[cnt].sol_mean = b.item_mean,
      reply->item_list[cloop].sol_list[cnt].sol_display = b.item_display
      IF (b.solution_seq > 0)
       reply->item_list[cloop].sol_list[cnt].sequence = b.solution_seq
      ELSE
       reply->item_list[cloop].sol_list[cnt].sequence = cnt
      ENDIF
      status0_ind = 0, status1_ind = 0, status2_ind = 0,
      cnt2 = 0
     DETAIL
      IF (bcss.step_mean > " ")
       cnt2 = (cnt2+ 1), stat = alterlist(reply->item_list[cloop].sol_list[cnt].step_list,cnt2),
       reply->item_list[cloop].sol_list[cnt].step_list[cnt2].step_mean = bcss.step_mean,
       reply->item_list[cloop].sol_list[cnt].step_list[cnt2].step_type = bs.step_type, reply->
       item_list[cloop].sol_list[cnt].step_list[cnt2].step_disp = bcir.item_display, reply->
       item_list[cloop].sol_list[cnt].step_list[cnt2].status_flag = bcir.status_flag,
       reply->item_list[cloop].sol_list[cnt].step_list[cnt2].sequence = bcss.sequence, reply->
       item_list[cloop].sol_list[cnt].step_list[cnt2].step_cat_mean = bcir.step_cat_mean, reply->
       item_list[cloop].sol_list[cnt].step_list[cnt2].step_cat_disp = bcir.step_cat_disp,
       reply->item_list[cloop].sol_list[cnt].step_list[cnt2].est_min_to_complete = bs
       .est_min_to_complete, reply->item_list[cloop].sol_list[cnt].step_list[cnt2].availability_flag
        = 3
       IF (bcir.status_flag=0)
        status0_ind = 1
       ELSEIF (bcir.status_flag=1)
        status1_ind = 1
       ELSEIF (bcir.status_flag=2)
        status2_ind = 1
       ENDIF
      ENDIF
     FOOT  b.br_client_item_reltn_id
      IF (status0_ind=1
       AND status1_ind=0
       AND status2_ind=0)
       reply->item_list[cloop].sol_list[cnt].status_flag = 0
      ELSEIF (status2_ind=1
       AND status1_ind=0
       AND status0_ind=0)
       reply->item_list[cloop].sol_list[cnt].status_flag = 2
      ELSE
       reply->item_list[cloop].sol_list[cnt].status_flag = 1
      ENDIF
     FOOT REPORT
      sol_cnt = cnt
     WITH nocounter, skipbedrock = 1
    ;end select
    FOR (x = 1 TO sol_cnt)
     SET step_cnt = size(reply->item_list[cloop].sol_list[x].step_list,5)
     FOR (y = 1 TO step_cnt)
       SELECT INTO "nl:"
        FROM br_prsnl_item_reltn bpir,
         br_prsnl bp
        PLAN (bpir
         WHERE (bpir.br_client_id=request->item_list[cloop].br_client_id)
          AND ((bpir.item_type="STEP"
          AND (bpir.item_mean=reply->item_list[cloop].sol_list[x].step_list[y].step_mean)) OR (bpir
         .item_type="STEPCAT"
          AND (bpir.item_mean=reply->item_list[cloop].sol_list[x].step_list[y].step_cat_mean)))
          AND bpir.item_lead_ind=1)
         JOIN (bp
         WHERE bp.br_prsnl_id=bpir.br_prsnl_id)
        ORDER BY bpir.item_type DESC
        DETAIL
         reply->item_list[cloop].sol_list[x].step_list[y].lead_username = bp.username
         IF ((bp.br_prsnl_id=reqinfo->updt_id)
          AND (reply->item_list[cloop].sol_list[x].step_list[y].availability_flag != 4))
          reply->item_list[cloop].sol_list[x].step_list[y].availability_flag = 1
         ENDIF
        WITH nocounter, skipbedrock = 1
       ;end select
       IF ((reply->item_list[cloop].sol_list[x].step_list[y].availability_flag != 1))
        SELECT INTO "nl:"
         FROM br_prsnl_item_reltn bpir
         PLAN (bpir
          WHERE (bpir.br_client_id=request->item_list[cloop].br_client_id)
           AND ((bpir.item_type="STEP"
           AND (bpir.item_mean=reply->item_list[cloop].sol_list[x].step_list[y].step_mean)) OR (bpir
          .item_type="STEPCAT"
           AND (bpir.item_mean=reply->item_list[cloop].sol_list[x].step_list[y].step_cat_mean)))
           AND (bpir.br_prsnl_id=reqinfo->updt_id))
         ORDER BY bpir.item_type
         DETAIL
          reply->item_list[cloop].sol_list[x].step_list[y].availability_flag = 1
         WITH nocounter, skipbedrock = 1
        ;end select
       ENDIF
       IF ((reply->item_list[cloop].sol_list[x].step_list[y].availability_flag=1))
        SELECT INTO "nl:"
         FROM br_step_dep bsd,
          br_client_item_reltn bcir
         PLAN (bsd
          WHERE (bsd.step_mean=reply->item_list[cloop].sol_list[x].step_list[y].step_mean))
          JOIN (bcir
          WHERE (bcir.br_client_id=request->item_list[cloop].br_client_id)
           AND bcir.item_type="STEP"
           AND bcir.item_mean=bsd.dep_step_mean
           AND bcir.status_flag != 2)
         DETAIL
          reply->item_list[cloop].sol_list[x].step_list[y].availability_flag = 2
         WITH nocounter, skipbedrock = 1
        ;end select
       ENDIF
     ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO

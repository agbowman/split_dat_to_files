CREATE PROGRAM ct_build_ruleset_tier:dba
 PAINT
 IF ("Z"=validate(ct_build_ruleset_tier_vrsn,"Z"))
  DECLARE ct_build_ruleset_tier_vrsn = vc WITH noconstant("45958.004")
 ENDIF
 SET ct_build_ruleset_tier_vrsn = "45958.004"
 DECLARE v_exclude_encntrtype_cd = f8 WITH public, noconstant(0.0)
 DECLARE norgind = i2 WITH public, noconstant(0)
 DECLARE ninsorgind = i2 WITH public, noconstant(0)
 DECLARE nhealthind = i2 WITH public, noconstant(0)
 DECLARE nfinind = i2 WITH public, noconstant(0)
 DECLARE nencntrind = i2 WITH public, noconstant(0)
 DECLARE nruleind = i2 WITH public, noconstant(0)
 DECLARE nbegind = i2 WITH public, noconstant(0)
 DECLARE nendind = i2 WITH public, noconstant(0)
 DECLARE npriorityind = i2 WITH public, noconstant(0)
 DECLARE nexcludeind = i2 WITH public, noconstant(0)
 RECORD request(
   1 ct_ruleset_tier_qual = i2
   1 ct_ruleset_tier[10]
     2 action_type = c3
     2 priority = i4
     2 ct_ruleset_tier_id = f8
     2 organization_id = f8
     2 insurance_organization_id = f8
     2 health_plan_id = f8
     2 fin_class_cd = f8
     2 encntr_type_cd = f8
     2 exclude_encntr_type_cd = f8
     2 ct_ruleset_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
 )
 RECORD tier(
   1 tier_list[*]
     2 ct_ins_org_id = f8
     2 ct_ins_org_name = vc
     2 ct_org_id = f8
     2 ct_org_name = vc
     2 ct_healthplan_id = f8
     2 ct_healthplan_name = vc
     2 ct_finclass_cd = f8
     2 ct_finclass_name = vc
     2 ct_encntrtype_cd = f8
     2 ct_encntrtype_name = vc
     2 ct_exclude_encntrtype_cd = f8
     2 ct_exclude_encntrtype_name = vc
     2 ct_ruleset_cd = f8
     2 ct_ruleset_name = vc
     2 ct_beg_date = dq8
     2 ct_end_date = dq8
     2 ct_priority = f8
     2 ct_ruleset_id = f8
 )
 RECORD response(
   1 yes_ind = i2
   1 no_ind = i2
 )
 SET v_ruleset_id = 0
 SET v_beg_date = cnvtdatetime(curdate,curtime)
 SET v_end_date = cnvtdatetime("31-dec-2100 23:59:59")
 CALL clear(1,1)
 EXECUTE FROM display_tier TO display_tier_end
 GO TO the_prompt
#insert_tier
 SET cur_pri = tier->tier_list[cur_rec].ct_priority
 SET insert_rec = 1
#add_tier
 IF (cur_pri=0)
  SET cur_pri = (tier->tier_list[max_rec].ct_priority+ 1)
 ENDIF
 CALL clear(1,1)
 CALL box(1,1,24,80)
 CALL text(24,50,"Help Available < Shift F5 >")
 CALL text(2,2,"Tier")
 CALL line(3,1,80,xhor)
 CALL text(5,4,"Organization:  ")
 CALL text(7,4,"Insurance Organization: ")
 CALL text(9,4,"Health Plan:  ")
 CALL text(11,4,"Financial Class:  ")
 CALL text(13,4,"Encounter Type:  ")
 CALL text(15,4,"Encounter Type to exclude: ")
 CALL text(17,4,"Ruleset:  ")
 CALL text(19,4,"Beg Date:  ")
 CALL text(21,4,"End Date:  ")
 CALL text(23,4,concat("Priority: ",cnvtstring(cur_pri)))
 SET help =
 SELECT
  organization = o.organization_id"########################################;l", o.org_name
  FROM organization o
  WHERE o.active_ind=1
  ORDER BY o.organization_id
  WITH nocounter
 ;end select
 CALL accept(5,19,"9(40);c")
 SET v_org_id = cnvtreal(curaccept)
 SET request->ct_ruleset_tier[1].organization_id = v_org_id
 SET help = off
 SET help =
 SELECT
  organization = o.organization_id"########################################;l", o.org_name
  FROM organization o
  WHERE o.active_ind=1
  ORDER BY o.organization_id
  WITH nocounter
 ;end select
 CALL accept(7,28,"9(40);c")
 SET v_ins_org_id = cnvtint(curaccept)
 SET request->ct_ruleset_tier[1].insurance_organization_id = v_ins_org_id
 SET help = off
 SET help =
 SELECT
  health_plan = h.health_plan_id"########################################;l", h.plan_name
  FROM health_plan h
  WHERE h.active_ind=1
  ORDER BY h.health_plan_id
  WITH nocounter
 ;end select
 CALL accept(9,18,"9(40);c")
 SET v_healthplan_id = cnvtreal(curaccept)
 SET request->ct_ruleset_tier[1].health_plan_id = v_healthplan_id
 SET help = off
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=354
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(11,22,"9(40);c")
 SET v_finclass_cd = cnvtreal(curaccept)
 SET request->ct_ruleset_tier[1].fin_class_cd = v_finclass_cd
 SET help = off
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=71
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(13,21,"9(40);c")
 SET v_encntrtype_cd = cnvtreal(curaccept)
 SET request->ct_ruleset_tier[1].encntr_type_cd = v_encntrtype_cd
 IF (v_encntrtype_cd > 0.0)
  SET v_exclude_encntrtype_cd = 0.0
  SET request->ct_ruleset_tier[1].exclude_encntr_type_cd = v_exclude_encntrtype_cd
 ELSE
  CALL accept(15,31,"9(38);c")
  SET v_exclude_encntrtype_cd = cnvtreal(curaccept)
  SET request->ct_ruleset_tier[1].exclude_encntr_type_cd = v_exclude_encntrtype_cd
 ENDIF
 SET help = off
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=18829
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(17,14,"9(40);c")
 SET v_ruleset_cd = cnvtreal(curaccept)
 SET request->ct_ruleset_tier[1].ct_ruleset_cd = v_ruleset_cd
 SET help = off
 CALL text(19,15,format(curdate,"DD-MMM-YYYY;;D"))
 CALL accept(19,15,"xx-xxx-xxxx;ucs",format(curdate,"DD-MMM-YYYY;;D"))
 SET v_beg_date = cnvtdatetime(curaccept)
 SET request->ct_ruleset_tier[1].beg_effective_dt_tm = v_beg_date
 CALL text(21,15,format(v_end_date,"DD-MMM-YYYY;;D"))
 CALL accept(21,15,"xx-xxx-xxxx;ucs",format(v_end_date,"DD-MMM-YYYY;;D"))
 SET v_end_date = cnvtdatetime(curaccept)
 SET request->ct_ruleset_tier[1].end_effective_dt_tm = v_end_date
 SET v_priority = cur_pri
 SET request->ct_ruleset_tier[1].priority = v_priority
 SET request->ct_ruleset_tier_qual = 1
 SET request->ct_ruleset_tier[1].action_type = "ADD"
 EXECUTE ct_ens_ruleset_tier
 COMMIT
 IF (insert_rec=1)
  SET new_pri = v_priority
  FOR (xrec = cur_rec TO max_rec)
    SET new_pri = (new_pri+ 1)
    SET request->ct_ruleset_tier_qual = 1
    SET request->ct_ruleset_tier.action_type = "UPT"
    SET request->ct_ruleset_tier.ct_ruleset_tier_id = tier->tier_list[xrec].ct_ruleset_id
    SET request->ct_ruleset_tier.ct_ruleset_cd = tier->tier_list[xrec].ct_ruleset_cd
    SET request->ct_ruleset_tier.organization_id = tier->tier_list[xrec].ct_org_id
    SET request->ct_ruleset_tier.insurance_organization_id = tier->tier_list[xrec].ct_ins_org_id
    SET request->ct_ruleset_tier.health_plan_id = tier->tier_list[xrec].ct_healthplan_id
    SET request->ct_ruleset_tier.fin_class_cd = tier->tier_list[xrec].ct_finclass_cd
    SET request->ct_ruleset_tier.encntr_type_cd = tier->tier_list[xrec].ct_encntrtype_cd
    SET request->ct_ruleset_tier.exclude_encntr_type_cd = tier->tier_list[xrec].
    ct_exclude_encntrtype_cd
    SET request->ct_ruleset_tier.beg_effective_dt_tm = tier->tier_list[xrec].ct_beg_date
    SET request->ct_ruleset_tier.end_effective_dt_tm = tier->tier_list[xrec].ct_end_date
    SET request->ct_ruleset_tier.priority = new_pri
    EXECUTE ct_ens_ruleset_tier
    COMMIT
    CALL text(24,89,cnvtstring(new_pri))
  ENDFOR
 ENDIF
 EXECUTE FROM display_tier TO display_tier_end
 GO TO the_prompt
#display_tier
 SET min_row = 2
 SET row_cnt = 20
 SET max_row = (min_row+ (row_cnt - 1))
#top
 SET cur_rec = 0
 SET top_rec = 0
 SET max_rec = 0
 SET bot_rec = row_cnt
 SET count1 = 0
 CALL clear(1,1)
 SELECT INTO "nl:"
  FROM ct_ruleset_tier r
  WHERE r.active_ind=1
  ORDER BY r.priority
  DETAIL
   count1 = (count1+ 1), stat = alterlist(tier->tier_list,count1), tier->tier_list[count1].
   ct_ruleset_cd = r.ct_ruleset_cd,
   tier->tier_list[count1].ct_priority = r.priority, tier->tier_list[count1].ct_beg_date = r
   .beg_effective_dt_tm, tier->tier_list[count1].ct_end_date = r.end_effective_dt_tm,
   tier->tier_list[count1].ct_ruleset_id = r.ct_ruleset_tier_id, tier->tier_list[count1].
   ct_ins_org_id = r.ins_org_id, tier->tier_list[count1].ct_org_id = r.organization_id,
   tier->tier_list[count1].ct_healthplan_id = r.health_plan_id, tier->tier_list[count1].
   ct_finclass_cd = r.fin_class_cd, tier->tier_list[count1].ct_encntrtype_cd = r.encntr_type_cd,
   tier->tier_list[count1].ct_exclude_encntrtype_cd = r.exclude_encntr_type_cd, tier->tier_list[
   count1].ct_ruleset_cd = r.ct_ruleset_cd
  WITH nocounter
 ;end select
 SET max_rec = count1
 IF (max_rec > 0)
  SELECT INTO "nl:"
   o.org_name
   FROM organization o,
    (dummyt d1  WITH seq = value(size(tier->tier_list,5)))
   PLAN (d1)
    JOIN (o
    WHERE (o.organization_id=tier->tier_list[d1.seq].ct_ins_org_id)
     AND o.active_ind=1)
   DETAIL
    tier->tier_list[d1.seq].ct_ins_org_name = o.org_name
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   o.org_name
   FROM organization o,
    (dummyt d1  WITH seq = value(size(tier->tier_list,5)))
   PLAN (d1)
    JOIN (o
    WHERE (o.organization_id=tier->tier_list[d1.seq].ct_org_id)
     AND o.active_ind=1)
   DETAIL
    tier->tier_list[d1.seq].ct_org_name = o.org_name
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   h.plan_name
   FROM health_plan h,
    (dummyt d1  WITH seq = value(size(tier->tier_list,5)))
   PLAN (d1)
    JOIN (h
    WHERE (h.health_plan_id=tier->tier_list[d1.seq].ct_healthplan_id))
   DETAIL
    tier->tier_list[d1.seq].ct_healthplan_name = h.plan_name
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(size(tier->tier_list,5)))
   PLAN (d1)
    JOIN (c
    WHERE (c.code_value=tier->tier_list[d1.seq].ct_finclass_cd))
   DETAIL
    tier->tier_list[d1.seq].ct_finclass_name = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(size(tier->tier_list,5)))
   PLAN (d1)
    JOIN (c
    WHERE (c.code_value=tier->tier_list[d1.seq].ct_encntrtype_cd))
   DETAIL
    tier->tier_list[d1.seq].ct_encntrtype_name = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(size(tier->tier_list,5)))
   PLAN (d1)
    JOIN (c
    WHERE (c.code_value=tier->tier_list[d1.seq].ct_exclude_encntrtype_cd))
   DETAIL
    tier->tier_list[d1.seq].ct_exclude_encntrtype_name = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(size(tier->tier_list,5)))
   PLAN (d1)
    JOIN (c
    WHERE (c.code_value=tier->tier_list[d1.seq].ct_ruleset_cd))
   DETAIL
    tier->tier_list[d1.seq].ct_ruleset_name = c.display
   WITH nocounter
  ;end select
 ENDIF
 CALL display_rows(0)
#display_tier_end
#the_prompt
 SET cur_pri = 0
 SET insert_rec = 0
 CALL text(24,3,"Add/Insert/Modify/Delete/Quit (A/I/M/D/Q):  ")
 CALL accept(24,50,"x;cus","Q")
 CALL clear(24,1)
 CASE (curscroll)
  OF 0:
   CASE (curaccept)
    OF "A":
     GO TO add_tier
    OF "I":
     GO TO insert_tier
    OF "D":
     GO TO delete_tier
    OF "M":
     CALL text(24,3,"Field Number: ")
     CALL accept(24,17,"99;",0
      WHERE curaccept IN (1, 2, 3, 4, 5,
      6, 7, 8, 9, 10))
     CASE (curaccept)
      OF 1:
       GO TO line1
      OF 2:
       GO TO line2
      OF 3:
       GO TO line3
      OF 4:
       GO TO line4
      OF 5:
       GO TO line5
      OF 6:
       GO TO line6
      OF 7:
       GO TO line7
      OF 8:
       GO TO line8
      OF 9:
       GO TO line9
      OF 10:
       GO TO line10
     ENDCASE
     GO TO the_end
    OF "Q":
     GO TO the_end
   ENDCASE
  ELSE
   CALL display_rows(curscroll)
 ENDCASE
 GO TO the_prompt
 SUBROUTINE display_rows(scrolltype)
   CASE (scrolltype)
    OF 0:
     SET cur_rec = 1
     SET top_rec = 1
     SET bot_rec = row_cnt
    OF 1:
     IF (cur_rec < max_rec)
      SET cur_rec = (cur_rec+ 1)
     ENDIF
     IF (cur_rec > bot_rec)
      SET bot_rec = (top_rec+ 1)
      SET bot_rec = (top_rec+ (row_cnt - 1))
     ENDIF
    OF 2:
     IF (cur_rec > 1)
      SET cur_rec = (cur_rec - 1)
     ENDIF
     IF (cur_rec < top_rec)
      SET top_rec = cur_rec
      SET bot_rec = (cur_rec+ (row_cnt - 1))
     ENDIF
    OF 5:
     IF (cur_rec <= row_cnt)
      SET cur_rec = 1
     ELSE
      SET cur_rec = (cur_rec - row_cnt)
     ENDIF
     SET top_rec = cur_rec
     SET bot_rec = (cur_rec+ (row_cnt - 1))
    OF 6:
     IF (((cur_rec+ row_cnt) <= max_rec))
      SET cur_rec = (cur_rec+ row_cnt)
     ENDIF
     SET top_rec = cur_rec
     SET bot_rec = (top_rec+ (row_cnt - 1))
   ENDCASE
   CALL clear(1,1)
   CALL text(1,03,"Organization ")
   CALL text(1,20,"Ins Organization")
   CALL text(1,42,"Health Plan")
   CALL text(1,60,"Financial Class")
   CALL text(1,81,"Encntr Type")
   CALL text(1,97,"Ruleset")
   CALL text(1,112,"Encntr Type Exclude")
   SET x_qual = top_rec
   FOR (x = min_row TO max_row)
     CALL clear(x,1,132)
     IF (x_qual=cur_rec)
      CALL video(r)
      SET v_ruleset_id = tier->tier_list[x_qual].ct_ruleset_id
     ELSE
      CALL video(n)
     ENDIF
     IF (x_qual <= max_rec)
      CALL text(x,1,trim(cnvtstring(x_qual),3))
      CALL text(x,03,substring(1,15,tier->tier_list[x_qual].ct_org_name))
      CALL text(x,20,substring(1,20,tier->tier_list[x_qual].ct_ins_org_name))
      CALL text(x,42,substring(1,16,tier->tier_list[x_qual].ct_healthplan_name))
      CALL text(x,60,substring(1,19,tier->tier_list[x_qual].ct_finclass_name))
      CALL text(x,81,substring(1,14,tier->tier_list[x_qual].ct_encntrtype_name))
      CALL text(x,97,substring(1,13,tier->tier_list[x_qual].ct_ruleset_name))
      CALL text(x,112,substring(1,19,tier->tier_list[x_qual].ct_exclude_encntrtype_name))
     ELSE
      CALL clear(x,1,132)
     ENDIF
     CALL video(n)
     SET x_qual = (x_qual+ 1)
   ENDFOR
   CALL draw_box(cur_rec)
 END ;Subroutine
 SUBROUTINE draw_box(rec_idx)
   CALL box(16,1,23,132)
   CALL text(23,50,"Help Available < Shift F5 >")
   CALL text(17,3,"1) Organization: ")
   CALL text(17,20,cnvtstring(tier->tier_list[rec_idx].ct_org_id))
   CALL text(18,3,"2) Insurance Org: ")
   CALL text(18,21,cnvtstring(tier->tier_list[rec_idx].ct_ins_org_id))
   CALL text(19,3,"3) Health_Plan:  ")
   CALL text(19,20,cnvtstring(tier->tier_list[rec_idx].ct_healthplan_id))
   CALL text(20,3,"4) Fin_Class:  ")
   CALL text(20,18,cnvtstring(tier->tier_list[rec_idx].ct_finclass_cd))
   CALL text(21,3,"5) Encntr_type: ")
   CALL text(21,19,cnvtstring(tier->tier_list[rec_idx].ct_encntrtype_cd))
   CALL text(17,65,"6) Ruleset:  ")
   CALL text(17,78,cnvtstring(tier->tier_list[rec_idx].ct_ruleset_cd))
   CALL text(18,65,"7) Beg Date: ")
   CALL text(18,78,format(tier->tier_list[rec_idx].ct_beg_date,"dd-mmm-yyyy;;d"))
   CALL text(19,65,"8) End Date:  ")
   CALL text(19,79,format(tier->tier_list[rec_idx].ct_end_date,"dd-mmm-yyyy;;d"))
   CALL text(20,65,"9) Priority:  ")
   CALL text(20,79,cnvtstring(tier->tier_list[rec_idx].ct_priority))
   CALL text(21,65,"10) Encntr_type to exclude:  ")
   CALL text(21,94,cnvtstring(tier->tier_list[rec_idx].ct_exclude_encntrtype_cd))
 END ;Subroutine
#line1
 SET help =
 SELECT
  organization = o.organization_id"########################################;l", o.org_name
  FROM organization o
  WHERE o.active_ind=1
  ORDER BY o.organization_id
  WITH nocounter
 ;end select
 CALL accept(17,20,"9(40);c",tier->tier_list[cur_rec].ct_org_id)
 SET v_org_id = cnvtreal(curaccept)
 SET norgind = 1
 SET help = off
#line2
 SET help =
 SELECT
  organization = o.organization_id"########################################;l", o.org_name
  FROM organization o
  WHERE o.active_ind=1
  ORDER BY o.organization_id
  WITH nocounter
 ;end select
 CALL accept(18,21,"x(40);c",tier->tier_list[cur_rec].ct_ins_org_id)
 SET v_ins_org_id = cnvtreal(curaccept)
 SET ninsorgind = 1
 SET help = off
#line3
 SET help =
 SELECT
  health_plan = h.health_plan_id"########################################;l", h.plan_name
  FROM health_plan h
  WHERE h.active_ind=1
  ORDER BY h.health_plan_id
  WITH nocounter
 ;end select
 CALL accept(19,20,"9(40);c",tier->tier_list[cur_rec].ct_healthplan_id)
 SET v_healthplan_id = cnvtreal(curaccept)
 SET nhealthind = 1
 SET help = off
#line4
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=354
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(20,18,"9(40);c",tier->tier_list[cur_rec].ct_finclass_cd)
 SET v_finclass_cd = cnvtreal(curaccept)
 SET nfinind = 1
 SET help = off
#line5
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=71
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(21,19,"9(40);c",tier->tier_list[cur_rec].ct_encntrtype_cd)
 SET v_encntrtype_cd = cnvtreal(curaccept)
 IF (v_encntrtype_cd > 0.0)
  SET v_exclude_encntrtype_cd = 0.0
 ENDIF
 SET nencntrind = 1
 SET help = off
#line6
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=18829
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(17,78,"9(40);c",tier->tier_list[cur_rec].ct_ruleset_cd)
 SET v_ruleset_cd = cnvtreal(curaccept)
 SET nruleind = 1
 SET help = off
#line7
 CALL text(18,78,format(tier->tier_list.ct_beg_date,"DD-MMM-YYYY;;D"))
 CALL accept(18,78,"xx-xxx-xxxx;ucs",format(tier->tier_list[cur_rec].ct_beg_date,"DD-MMM-YYYY;;D"))
 SET v_beg_date = cnvtdatetime(curaccept)
 SET nbegind = 1
#line8
 CALL text(19,79,format(tier->tier_list[cur_rec].ct_end_date,"DD-MMM-YYYY;;D"))
 CALL accept(19,79,"xx-xxx-xxxx;ucs",format(tier->tier_list[cur_rec].ct_end_date,"DD-MMM-YYYY;;D"))
 SET v_end_date = cnvtdatetime(curaccept)
 SET nendind = 1
#line9
 CALL accept(20,79,"n(3);c",tier->tier_list[cur_rec].ct_priority)
 SET v_priority = cnvtint(curaccept)
 SET npriorityind = 1
#line10
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=71
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(21,94,"9(38);c",tier->tier_list[cur_rec].ct_exclude_encntrtype_cd)
 SET v_exclude_encntrtype_cd = cnvtreal(curaccept)
 IF (v_exclude_encntrtype_cd > 0.0)
  SET v_encntrtype_cd = 0.0
  SET nencntrind = 1
 ENDIF
 SET nexcludeind = 1
 SET help = off
 GO TO modify_question
#modify_question
 EXECUTE afc_ccl_msgbox "Are you sure you want to modify the Tier?", "Tier", "YN"
 IF ((response->yes_ind=1))
  GO TO update_tier
 ELSEIF ((response->no_ind=1))
  GO TO top
 ELSE
  CALL text(16,5,"test")
  GO TO the_end
 ENDIF
#update_tier
 SET request->ct_ruleset_tier_qual = 1
 SET request->ct_ruleset_tier.action_type = "UPT"
 SET request->ct_ruleset_tier.ct_ruleset_tier_id = v_ruleset_id
 IF (norgind=1)
  SET request->ct_ruleset_tier.organization_id = v_org_id
 ELSE
  SET request->ct_ruleset_tier.organization_id = tier->tier_list[cur_rec].ct_org_id
 ENDIF
 SET norgind = 0
 IF (ninsorgind=1)
  SET request->ct_ruleset_tier.insurance_organization_id = v_ins_org_id
 ELSE
  SET request->ct_ruleset_tier.insurance_organization_id = tier->tier_list[cur_rec].ct_ins_org_id
 ENDIF
 SET ninsorgind = 0
 IF (nhealthind=1)
  SET request->ct_ruleset_tier.health_plan_id = v_healthplan_id
 ELSE
  SET request->ct_ruleset_tier.health_plan_id = tier->tier_list[cur_rec].ct_healthplan_id
 ENDIF
 SET nhealthind = 0
 IF (nfinind=1)
  SET request->ct_ruleset_tier.fin_class_cd = v_finclass_cd
 ELSE
  SET request->ct_ruleset_tier.fin_class_cd = tier->tier_list[cur_rec].ct_finclass_cd
 ENDIF
 SET nfinind = 0
 IF (nencntrind=1)
  SET request->ct_ruleset_tier.encntr_type_cd = v_encntrtype_cd
 ELSE
  SET request->ct_ruleset_tier.encntr_type_cd = tier->tier_list[cur_rec].ct_encntrtype_cd
 ENDIF
 SET nencntrind = 0
 IF (nruleind=1)
  SET request->ct_ruleset_tier.ct_ruleset_cd = v_ruleset_cd
 ELSE
  SET request->ct_ruleset_tier.ct_ruleset_cd = tier->tier_list[cur_rec].ct_encntrtype_cd
 ENDIF
 SET nruleind = 0
 IF (nbegind=1)
  SET request->ct_ruleset_tier.beg_effective_dt_tm = v_beg_date
 ELSE
  SET request->ct_ruleset_tier.beg_effective_dt_tm = tier->tier_list[cur_rec].ct_beg_date
 ENDIF
 SET nbegind = 0
 IF (nendind=1)
  SET request->ct_ruleset_tier.end_effective_dt_tm = v_end_date
 ELSE
  SET request->ct_ruleset_tier.end_effective_dt_tm = tier->tier_list[cur_rec].ct_end_date
 ENDIF
 SET endind = 0
 IF (npriorityind=1)
  SET request->ct_ruleset_tier.priority = v_priority
 ELSE
  SET request->ct_ruleset_tier.priority = tier->tier_list[cur_rec].ct_priority
 ENDIF
 SET npriorityind = 0
 IF (nexcludeind=1)
  SET request->ct_ruleset_tier.exclude_encntr_type_cd = v_exclude_encntrtype_cd
 ELSE
  SET request->ct_ruleset_tier.exclude_encntr_type_cd = tier->tier_list[cur_rec].
  ct_exclude_encntrtype_cd
 ENDIF
 SET nexcludeind = 0
 EXECUTE ct_ens_ruleset_tier
 COMMIT
 GO TO top
#delete_tier
 EXECUTE afc_ccl_msgbox "Are you sure you want to delete the Tier?", "Tier", "YN"
 IF ((response->yes_ind=1))
  DELETE  FROM ct_ruleset_tier t
   WHERE t.ct_ruleset_tier_id=v_ruleset_id
  ;end delete
  COMMIT
  SET cur_pri = tier->tier_list[cur_rec].ct_priority
  FOR (xrec = (cur_rec+ 1) TO max_rec)
    SET request->ct_ruleset_tier_qual = 1
    SET request->ct_ruleset_tier.action_type = "UPT"
    SET request->ct_ruleset_tier.ct_ruleset_tier_id = tier->tier_list[xrec].ct_ruleset_id
    SET request->ct_ruleset_tier.ct_ruleset_cd = tier->tier_list[xrec].ct_ruleset_cd
    SET request->ct_ruleset_tier.organization_id = tier->tier_list[xrec].ct_org_id
    SET request->ct_ruleset_tier.insurance_organization_id = tier->tier_list[xrec].ct_ins_org_id
    SET request->ct_ruleset_tier.health_plan_id = tier->tier_list[xrec].ct_healthplan_id
    SET request->ct_ruleset_tier.fin_class_cd = tier->tier_list[xrec].ct_finclass_cd
    SET request->ct_ruleset_tier.encntr_type_cd = tier->tier_list[xrec].ct_encntrtype_cd
    SET request->ct_ruleset_tier.exclude_encntr_type_cd = tier->tier_list[xrec].
    ct_exclude_encntrtype_cd
    SET request->ct_ruleset_tier.beg_effective_dt_tm = tier->tier_list[xrec].ct_beg_date
    SET request->ct_ruleset_tier.end_effective_dt_tm = tier->tier_list[xrec].ct_end_date
    SET request->ct_ruleset_tier.priority = cur_pri
    EXECUTE ct_ens_ruleset_tier
    COMMIT
    SET cur_pri = (cur_pri+ 1)
    CALL text(24,89,cnvtstring(cur_pri))
  ENDFOR
  GO TO top
 ELSEIF ((response->no_ind=1))
  GO TO top
 ENDIF
#the_end
 FREE SET request
 FREE SET tier_list
END GO

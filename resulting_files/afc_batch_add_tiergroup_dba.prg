CREATE PROGRAM afc_batch_add_tiergroup:dba
 PAINT
 EXECUTE cclseclogin
 RECORD org(
   1 org_list[*]
     2 org_value = f8
 )
 DECLARE org_seq_num = i4
 DECLARE code_set = i4
 DECLARE cnt = i4
 DECLARE cdf_meaning = c12
 DECLARE active = f8
 DECLARE client = f8
 DECLARE uar_get_code_display(p_code_value) = c40
 DECLARE tiercolumn_cd = f8
 DECLARE tiergroup_cd = f8
 SET codeset = 48
 SET cdf_meaning = "ACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,active)
 CALL echo(build("the ACTIVE code value is: ",active))
 SET codeset = 278
 SET cdf_meaning = "CLIENT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,client)
 CALL echo(build("the CLIENT code value is: ",client))
 CALL text(4,6,"1)Tier Column:  ")
 CALL text(7,6,"2)Tier Group:   ")
 SET help =
 SELECT
  code_value = cv.code_value"#################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=13031
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("TIERGROUP", "CLTTIERGROUP")
  WITH nocounter
 ;end select
 CALL accept(4,23,"p(17);cf",0)
 SET tiercolumn_cd = cnvtreal(curaccept)
 SET tiercolumndisp = uar_get_code_display(tiercolumn_cd)
 CALL echo(tiercolumndisp)
 CALL text(5,12,trim(tiercolumndisp))
 SET help =
 SELECT
  code_value = cv.code_value"#################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=13035
   AND cv.active_ind=1
  WITH nocounter
 ;end select
 CALL accept(7,23,"p(17);cf",0)
 SET tiergroup_cd = cnvtreal(curaccept)
 SET tiergroupdisp = uar_get_code_display(tiergroup_cd)
 CALL text(8,12,trim(tiergroupdisp))
 SET help = off
#the_prompt
 SET cur_pri = 0
 SET insert_rec = 0
 CALL text(15,3,"Update/Exit (U/E):  ")
 CALL accept(15,20,"x;cus","E"
  WHERE curaccept IN ("U", "E"))
 CALL clear(15,1)
 CASE (curscroll)
  OF 0:
   CASE (curaccept)
    OF "U":
     GO TO add_tier
    OF "E":
     GO TO end_prog
   ENDCASE
 ENDCASE
 GO TO the_prompt
#add_tier
 DELETE  FROM bill_org_payor bp
  WHERE bp.bill_org_type_cd=tiercolumn_cd
  WITH nocounter
 ;end delete
 SET count2 = 0
 SELECT INTO "nl:"
  o.organization_id
  FROM organization o,
   org_type_reltn otr
  PLAN (o
   WHERE o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND o.active_ind=1)
   JOIN (otr
   WHERE otr.organization_id=o.organization_id
    AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND otr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND otr.active_ind=1
    AND otr.org_type_cd=client)
  DETAIL
   count2 = (count2+ 1), stat = alterlist(org->org_list,count2), org->org_list[count2].org_value = o
   .organization_id
  WITH nocounter
 ;end select
 CALL echo(build("The Count is ",count2))
 SET fuser = 0.0
 SET cuser = curuser
 SELECT INTO "NL:"
  p.person_id
  FROM prsnl p
  WHERE p.username=cuser
  DETAIL
   fuser = p.person_id
  WITH nocounter
 ;end select
 SET cur_org = 1
 WHILE (cur_org <= count2)
  INSERT  FROM bill_org_payor bp
   SET bp.org_payor_id = cnvtreal(seq(price_sched_seq,nextval)), bp.organization_id = org->org_list[
    cur_org].org_value, bp.bill_org_type_cd = tiercolumn_cd,
    bp.bill_org_type_id = tiergroup_cd, bp.updt_cnt = 0, bp.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    bp.updt_id = fuser, bp.updt_task = 0, bp.updt_applctx = 0,
    bp.active_ind = 1, bp.active_status_cd = active, bp.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3),
    bp.active_status_prsnl_id = fuser, bp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bp
    .end_effective_dt_tm = cnvtdatetime("31-dec-2100 23:59:59.99"),
    bp.parent_entity_name = "CODE_VALUE", bp.bill_org_type_string = "", bp.bill_org_type_ind = 0
   WITH nocounter
  ;end insert
  SET cur_org = (cur_org+ 1)
 ENDWHILE
 COMMIT
#end_prog
END GO

CREATE PROGRAM afc_rpt_psa:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 file_name = vc
    1 page_count = i4
    1 status_data
      2 status = c1
      2 subeventstatus[3]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD bill_items(
   1 bill_item_qual = i2
   1 bill_item[*]
     2 bill_item_id = f8
     2 ext_owner_cd = f8
     2 ext_owner_disp = c40
     2 ext_owner_mean = c12
     2 sched_item_count = i2
     2 sched_item[*]
       3 price_sched_id = f8
       3 price_sched_desc = c60
       3 bill_item_id = f8
       3 ext_parent_reference_id = f8
       3 ext_parent_contributor_cd = f8
       3 ext_child_reference_id = f8
       3 ext_child_contributor_cd = f8
       3 ext_description = c60
       3 ext_owner_cd = f8
       3 ext_owner_disp = c40
       3 ext_owner_mean = c12
       3 charge_point_cd = f8
       3 charge_point_disp = c40
       3 charge_point_mean = c12
       3 price_sched_items_id = f8
       3 price = f8
       3 percent_revenue = i4
       3 charge_level_cd = f8
       3 charge_level_disp = c40
       3 charge_level_mean = c12
       3 detail_charge_ind = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 tpa_cd = c8
       3 gl_cd = c8
       3 cpt4_cd = c8
       3 child_sched_beg_index = i2
       3 child_sched_qual = i2
       3 default_ind = f8
       3 level = f8
 )
 IF (validate(scheds->sched_item_count,0)=0)
  RECORD scheds(
    1 sched_item_count = i2
    1 sched_item_size = i2
    1 parent_item_limit = f8
    1 sched_item[*]
      2 price_sched_id = f8
      2 price_sched_desc = c60
      2 bill_item_id = f8
      2 ext_parent_reference_id = f8
      2 ext_parent_contributor_cd = f8
      2 ext_child_reference_id = f8
      2 ext_child_contributor_cd = f8
      2 ext_description = c60
      2 ext_owner_cd = f8
      2 ext_owner_disp = c40
      2 ext_owner_mean = c12
      2 charge_point_cd = f8
      2 charge_point_disp = c40
      2 charge_point_mean = c12
      2 price_sched_items_id = f8
      2 price = f8
      2 percent_revenue = i4
      2 charge_level_cd = f8
      2 charge_level_disp = c40
      2 charge_level_mean = c12
      2 detail_charge_ind = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 tpa_cd = c8
      2 gl_cd = c8
      2 cpt4_cd = c8
      2 child_sched_beg_index = i2
      2 child_sched_qual = i2
      2 default_ind = f8
      2 level = f8
    1 item_index[*]
      2 index = i2
  )
 ENDIF
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET g_bill_item_size = 0
 SET g_display_count = 0
 SET g_code_value = 0
 SET g_status_code_active = 0
 SET g_bill_item_type_cd_billcode = 0
 SET ext_owner_codeset = 106
 SET bill_item_type_code_set = 13019
 SET bill_item_type_mean_billcode = "BILL CODE"
#main
 SET bi_index = 0
 SET scheds->sched_item_count = 0
 IF (failed=false)
  CALL get_code_value(bill_item_type_code_set,bill_item_type_mean_billcode)
  SET g_bill_item_type_cd_billcode = g_code_value
 ENDIF
 IF (failed=false)
  CALL get_bill_items(0)
 ENDIF
 CALL echo(build("bill_items->bill_item_qual: ",bill_items->bill_item_qual))
 IF (failed=false)
  FOR (bi_index = 1 TO bill_items->bill_item_qual)
    CALL echo(build("BI_index : ",bi_index))
    CALL echo(build("bill_items->bill_item[BI_index]->bill_item_id : ",bill_items->bill_item[bi_index
      ].bill_item_id))
    IF (failed=false)
     SET request->bill_item_id = bill_items->bill_item[bi_index].bill_item_id
     EXECUTE afc_get_expanded_bill_item
    ELSE
     SET bi_index = (bill_items->bill_item_qual+ 1)
    ENDIF
    IF (failed=false)
     CALL fill_bi_scheds(bi_index)
    ELSE
     SET bi_index = (bill_items->bill_item_qual+ 1)
    ENDIF
    IF (failed=false)
     CALL get_bill_codes(bi_index)
    ELSE
     SET bi_index = (bill_items->bill_item_qual+ 1)
    ENDIF
  ENDFOR
 ENDIF
 IF (failed=false)
  CALL write_report(0)
 ELSE
  SET bi_index = (bill_items->bill_item_qual+ 1)
 ENDIF
 IF (failed=true)
  CALL echo("failed is equal TRUE")
 ENDIF
#main_exit
 GO TO end_program
 SUBROUTINE get_code_value(l_code_set,l_cdf_meaning)
   SET g_code_value = 0.0
   SET table_name = "code_value"
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=l_code_set
     AND cv.cdf_meaning=l_cdf_meaning
     AND cv.active_ind=true
    DETAIL
     g_code_value = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = select_error
   ENDIF
 END ;Subroutine
 SUBROUTINE get_bill_items(l_dummy)
   CALL echo("inside GET_BILL_ITEMS")
   SET bill_item_count = 0
   SET table_name = "bill_item"
   CALL echo(build("request->ext_owner_mean = ",request->ext_owner_mean))
   SELECT INTO "nl:"
    cv_eo.code_value, cv_eo.display, cv_eo.cdf_meaning,
    b.bill_item_id
    FROM code_value cv_eo,
     bill_item b
    WHERE cv_eo.active_ind=true
     AND cv_eo.code_set=ext_owner_codeset
     AND (cv_eo.cdf_meaning=request->ext_owner_mean)
     AND b.ext_owner_cd=cv_eo.code_value
     AND b.active_ind=true
     AND b.ext_parent_reference_id != 0
     AND b.ext_parent_contributor_cd != 0
     AND b.ext_child_reference_id=0
     AND b.ext_child_contributor_cd=0
    ORDER BY cnvtupper(trim(cv_eo.display,3)), cnvtupper(trim(cv_eo.cdf_meaning,3)), cnvtupper(trim(b
       .ext_description,3))
    DETAIL
     bill_item_count += 1
     IF (bill_item_count > g_bill_item_size)
      g_bill_item_size += 500, stat = alterlist(bill_items->bill_item,g_bill_item_size)
     ENDIF
     bill_items->bill_item[bill_item_count].bill_item_id = b.bill_item_id, bill_items->bill_item[
     bill_item_count].ext_owner_cd = b.ext_owner_cd, bill_items->bill_item[bill_item_count].
     ext_owner_disp = cv_eo.display,
     bill_items->bill_item[bill_item_count].ext_owner_mean = cv_eo.cdf_meaning,
     CALL echo(build(" ext_owner_disp = ",bill_items->bill_item[bill_item_count].ext_owner_disp,
      " ext_owner_mean = ",bill_items->bill_item[bill_item_count].ext_owner_mean))
    WITH orahint(" ordered index(b xie5bill_item) index(cv_eo xif28code_value)"), nocounter, check
   ;end select
   SET bill_items->bill_item_qual = bill_item_count
   CALL echo(build("g_bill_item_size: ",g_bill_item_size))
   CALL echo(concat("bill_item_qual: ",cnvtstring(bill_items->bill_item_qual)))
 END ;Subroutine
 SUBROUTINE fill_bi_scheds(x)
   CALL echo("inside FILL_BI_SCHEDS")
   SET index_index = 1
   SET item_index = 1
   SET sched_count = 0
   WHILE ((index_index <= scheds->sched_item_count))
     CALL echo("Inside while Loop")
     SET item_index = scheds->item_index[index_index].index
     IF ((scheds->sched_item[item_index].beg_effective_dt_tm < request->control_dt_tm)
      AND (((scheds->sched_item[item_index].end_effective_dt_tm > request->control_dt_tm)) OR ((
     scheds->sched_item[item_index].end_effective_dt_tm=0.0))) )
      SET sched_count += 1
      SET stat = alterlist(bill_items->bill_item[x].sched_item,sched_count)
      SET bill_items->bill_item[x].sched_item[sched_count].price_sched_id = scheds->sched_item[
      item_index].price_sched_id
      SET bill_items->bill_item[x].sched_item[sched_count].price_sched_desc = scheds->sched_item[
      item_index].price_sched_desc
      SET bill_items->bill_item[x].sched_item[sched_count].bill_item_id = scheds->sched_item[
      item_index].bill_item_id
      SET bill_items->bill_item[x].sched_item[sched_count].ext_parent_reference_id = scheds->
      sched_item[item_index].ext_parent_reference_id
      SET bill_items->bill_item[x].sched_item[sched_count].ext_parent_contributor_cd = scheds->
      sched_item[item_index].ext_parent_contributor_cd
      SET bill_items->bill_item[x].sched_item[sched_count].ext_child_reference_id = scheds->
      sched_item[item_index].ext_child_reference_id
      SET bill_items->bill_item[x].sched_item[sched_count].ext_child_contributor_cd = scheds->
      sched_item[item_index].ext_child_contributor_cd
      SET bill_items->bill_item[x].sched_item[sched_count].ext_description = scheds->sched_item[
      item_index].ext_description
      SET bill_items->bill_item[x].sched_item[sched_count].ext_owner_cd = scheds->sched_item[
      item_index].ext_owner_cd
      SET bill_items->bill_item[x].sched_item[sched_count].ext_owner_disp = scheds->sched_item[
      item_index].ext_owner_disp
      SET bill_items->bill_item[x].sched_item[sched_count].ext_owner_mean = scheds->sched_item[
      item_index].ext_owner_mean
      SET bill_items->bill_item[x].sched_item[sched_count].charge_point_cd = scheds->sched_item[
      item_index].charge_point_cd
      SET bill_items->bill_item[x].sched_item[sched_count].charge_point_disp = scheds->sched_item[
      item_index].charge_point_disp
      SET bill_items->bill_item[x].sched_item[sched_count].charge_point_mean = scheds->sched_item[
      item_index].charge_point_mean
      SET bill_items->bill_item[x].sched_item[sched_count].price_sched_items_id = scheds->sched_item[
      item_index].price_sched_items_id
      SET bill_items->bill_item[x].sched_item[sched_count].price = scheds->sched_item[item_index].
      price
      SET bill_items->bill_item[x].sched_item[sched_count].charge_level_cd = scheds->sched_item[
      item_index].charge_level_cd
      SET bill_items->bill_item[x].sched_item[sched_count].charge_level_disp = scheds->sched_item[
      item_index].charge_level_disp
      SET bill_items->bill_item[x].sched_item[sched_count].charge_level_mean = scheds->sched_item[
      item_index].charge_level_mean
      SET bill_items->bill_item[x].sched_item[sched_count].detail_charge_ind = scheds->sched_item[
      item_index].detail_charge_ind
      SET bill_items->bill_item[x].sched_item[sched_count].beg_effective_dt_tm = scheds->sched_item[
      item_index].beg_effective_dt_tm
      SET bill_items->bill_item[x].sched_item[sched_count].end_effective_dt_tm = scheds->sched_item[
      item_index].end_effective_dt_tm
      SET bill_items->bill_item[x].sched_item[sched_count].default_ind = scheds->sched_item[
      item_index].default_ind
      SET bill_items->bill_item[x].sched_item[sched_count].level = scheds->sched_item[item_index].
      level
     ENDIF
     SET index_index += 1
   ENDWHILE
   SET bill_items->bill_item[x].sched_item_count = sched_count
 END ;Subroutine
 SUBROUTINE get_bill_codes(x)
   CALL echo("inside GET_BILL_CODES")
   SET table_name = "bill_item_modifier"
   SET index_index = 1
   SET sched_index = 1
   WHILE ((sched_index <= bill_items->bill_item[x].sched_item_count))
     SET bill_items->bill_item[x].sched_item[sched_index].tpa_cd = ""
     SET bill_items->bill_item[x].sched_item[sched_index].gl_cd = ""
     SET bill_items->bill_item[x].sched_item[sched_index].cpt4_cd = ""
     SELECT INTO "nl:"
      bim.key1_id, bim.key2_id
      FROM bill_item_modifier bim
      WHERE (bim.bill_item_id=bill_items->bill_item[x].sched_item[sched_index].bill_item_id)
       AND bim.bill_item_type_cd=g_bill_item_type_cd_billcode
      DETAIL
       IF ((cnvtreal(bim.key1_id)=request->tpa_cd))
        bill_items->bill_item[x].sched_item[sched_index].tpa_cd = trim(bim.key2)
       ENDIF
       IF ((cnvtreal(bim.key1_id)=request->gl_cd))
        bill_items->bill_item[x].sched_item[sched_index].gl_cd = trim(bim.key2)
       ENDIF
       IF ((cnvtreal(bim.key1_id)=request->cpt4_cd))
        bill_items->bill_item[x].sched_item[sched_index].cpt4_cd = trim(bim.key2)
       ENDIF
      WITH nocounter
     ;end select
     SET sched_index += 1
   ENDWHILE
 END ;Subroutine
 SUBROUTINE write_report(bill_item_index)
   CALL echo("inside WRITE_REPORT")
   SET item_index = 1
   SET total_price = 0.00
   SET count = 1
   SET x = 1
   SET pagecount = 0
   IF (trim(request->file_name,3)="")
    SET request->file_name = "MINE"
    SET filename = "MINE"
   ELSEIF (cnvtupper(trim(request->file_name))="MINE")
    SET filename = "MINE"
   ELSE
    SET filename = concat("CER_DATA:[TEMP]",trim(request->file_name,3))
    SET dclcom = concat("delete ",trim(filename,3),".dat;* ")
    SET len = size(trim(dclcom))
    SET status = 0
    CALL dcl(dclcom,len,status)
   ENDIF
   CALL echo(concat("filename = '",filename,"'"))
   SELECT INTO value(filename)
    d.seq
    FROM dummyt d
    HEAD REPORT
     team_name = "Account For Care", report_name = "Price Schedule Audit Report", line130 =
     fillstring(130,"-"),
     eqline130 = fillstring(130,"="), x = 1
    HEAD PAGE
     col 01, team_name, col 22,
     report_name, col 54, "Department: ",
     col 66, request->ext_owner_mean"#############", col 120,
     "Page: ", col 127, curpage"###",
     row + 1, col 01, eqline130,
     row + 1, col 01, "Schedule  ",
     col 12, "Area                ", col 33,
     "SIM#  ", col 40, "Bill Items          ",
     col 61, "InsCat", col 68,
     "CPT-4 ", col 76, "Chrg Point",
     col 87, "Chrg Level", col 98,
     "Price     ", col 109, "Chg",
     col 113, "Beginning", col 123,
     "Ending  ", row + 1, col 01,
     "----------", col 12, "--------------------",
     col 33, "------", col 40,
     "--------------------", col 61, "------",
     col 68, "------", col 76,
     "----------", col 87, "----------",
     col 98, "----------", col 109,
     "---", col 113, "---------",
     col 123, "--------", pagecount = curpage
    DETAIL
     x = 1
     WHILE ((x <= bill_items->bill_item_qual))
       total_price = 0.00
       IF ((bill_items->bill_item[x].sched_item_count > 0))
        item_index = 1
        WHILE ((item_index <= bill_items->bill_item[x].sched_item_count))
          IF (((row+ 4) > maxrow))
           BREAK
          ENDIF
          row + 1
          IF ((bill_items->bill_item[x].sched_item[item_index].level=1))
           col 01, bill_items->bill_item[x].sched_item[item_index].price_sched_desc"##########"
          ELSE
           col 01, ' "        '
          ENDIF
          col 12, bill_items->bill_item[x].sched_item[item_index].ext_owner_disp
          "####################", col 33,
          bill_items->bill_item[x].sched_item[item_index].tpa_cd"######"
          CASE (bill_items->bill_item[x].sched_item[item_index].level)
           OF 1:
            col 40,bill_items->bill_item[x].sched_item[item_index].ext_description
            "####################"
           OF 2:
            col 41,bill_items->bill_item[x].sched_item[item_index].ext_description
            "###################"
           OF 3:
            col 42,bill_items->bill_item[x].sched_item[item_index].ext_description
            "##################"
           OF 4:
            col 43,bill_items->bill_item[x].sched_item[item_index].ext_description"#################"
           OF 5:
            col 44,bill_items->bill_item[x].sched_item[item_index].ext_description"################"
           ELSE
            col 45,bill_items->bill_item[x].sched_item[item_index].ext_description">##############"
          ENDCASE
          IF (bill_items->bill_item[x].sched_item[item_index].default_ind)
           col 60, "*"
          ENDIF
          col 61, bill_items->bill_item[x].sched_item[item_index].gl_cd"######", col 68,
          bill_items->bill_item[x].sched_item[item_index].cpt4_cd"######", col 76, bill_items->
          bill_item[x].sched_item[item_index].charge_point_disp"##########",
          col 87, bill_items->bill_item[x].sched_item[item_index].charge_level_disp"##########", col
          98,
          bill_items->bill_item[x].sched_item[item_index].price"$######.##", total_price +=
          bill_items->bill_item[x].sched_item[item_index].price
          IF (bill_items->bill_item[x].sched_item[item_index].detail_charge_ind)
           col 109, "Yes"
          ELSE
           col 109, "No"
          ENDIF
          col 113, bill_items->bill_item[x].sched_item[item_index].beg_effective_dt_tm"MM/DD/YY;;D",
          col 123,
          bill_items->bill_item[x].sched_item[item_index].end_effective_dt_tm"MM/DD/YY;;D"
          IF ((request->debug_flag="Y"))
           IF (((row+ 4) > maxrow))
            BREAK
           ENDIF
           row + 1, col 29, "BI Id: ",
           col 36, bill_items->bill_item[x].sched_item[item_index].bill_item_id"##########", col 47,
           "P Id: ", col 53, bill_items->bill_item[x].sched_item[item_index].ext_parent_reference_id
           "##########",
           col 64, "P Cd: ", col 70,
           bill_items->bill_item[x].sched_item[item_index].ext_parent_contributor_cd"##########", col
            81, "C Id: ",
           col 87, bill_items->bill_item[x].sched_item[item_index].ext_child_reference_id"##########",
           col 99,
           "C Cd: ", col 105, bill_items->bill_item[x].sched_item[item_index].
           ext_child_contributor_cd"##########"
          ENDIF
          item_index += 1
          IF ((item_index > bill_items->bill_item[x].sched_item_count))
           IF ((bill_items->bill_item[x].sched_item[(item_index - 1)].level > 1))
            row + 1, col 87, "Total====>",
            col 98, total_price"$######.##"
           ENDIF
           total_price = 0.00, row + 1
          ELSEIF ((bill_items->bill_item[x].sched_item[item_index].level=1))
           IF (((row+ 4) > maxrow))
            BREAK
           ENDIF
           IF ((bill_items->bill_item[x].sched_item[(item_index - 1)].level > 1))
            row + 1, col 87, "Total====>",
            col 98, total_price"$######.##"
           ENDIF
           total_price = 0.00
          ENDIF
        ENDWHILE
       ENDIF
       x += 1
     ENDWHILE
    WITH check, nocounter
   ;end select
   SET reply->page_count = pagecount
   CALL echo(build("page_count = ",reply->page_count))
 END ;Subroutine
#end_program
 FREE SET bill_items
 FREE SET scheds
END GO

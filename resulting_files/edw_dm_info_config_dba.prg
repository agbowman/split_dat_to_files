CREATE PROGRAM edw_dm_info_config:dba
 SET message = window
 SET c_title = "E D W   D M   I N F O   C O N F I G   M E N U"
 SET c_msg1 = "Select the action:"
 SET c_exit = "<F10> to Exit"
 SET c_prev = "<F10> for Previous Menu"
 SET home = end_program
 SET help = off
 SET width = 132
 SET change_val_ind = 0
#1000_housekeeping
 DECLARE user_mode = c1
 DECLARE menu_part1 = c39
 DECLARE v_select = vc
 DECLARE dd = i2
 DECLARE mmm = c3
 DECLARE yyyy = i4
 DECLARE hh = i2
 DECLARE mi = i2
 DECLARE ss = i2
 DECLARE upd_info_char = vc
 DECLARE upd_info_number = i2
 DECLARE dm_info_cnt = i4 WITH public, noconstant[0]
 SET correct = 0
 SET continue = 0
 SET lower_bound = 0
 SET upper_bound = 0
 SET menu_nbr = 0
 SET prev_menu_nbr = 0
 SET hold_menu_nbr = 0
 SET curr_line_num = 0
 SET prev_line_num = 0
 SET valid_date_ind = 1
 SET array_length = 0
 FREE SET edw_menu
 RECORD edw_menu(
   1 nbr[*]
     2 arow = i4
     2 cnt = i4
     2 scroll_row = i4
     2 scroll_col = i4
     2 num_scroll_row = i4
     2 num_scroll_col = i4
     2 menu_nbr = i2
     2 data[*]
       3 menu_item = c110
       3 info_domain = c80
       3 info_name = c80
       3 menu_nbr = i2
       3 prev_menu_nbr = i2
       3 next_menu_nbr = i2
       3 execute_str = vc
       3 line_nbr = i2
       3 prev_line_nbr = i2
       3 accept_input_flag = i2
       3 help_str = c130
       3 mode = c1
       3 curr_val = c80
       3 new_val = c80
 )
 SET v_rptcnt = 0
 SET menu_item = fillstring(110," ")
 SET user_mode = "T"
 SET stand_by_ind = 0
 SET first_pass = fillstring(130," ")
 EXECUTE gm_dm_info2388_def "U"
 DECLARE gm_u_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_dm_info2388_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_dm_info2388_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_number":
     IF (null_ind=1)
      SET gm_u_dm_info2388_req->info_numberf = 2
     ELSE
      SET gm_u_dm_info2388_req->info_numberf = 1
     ENDIF
     SET gm_u_dm_info2388_req->qual[iqual].info_number = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_numberw = 1
     ENDIF
    OF "info_long_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_dm_info2388_req->info_long_idf = 1
     SET gm_u_dm_info2388_req->qual[iqual].info_long_id = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_long_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_dm_info2388_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_dm_info2388_req->updt_cntf = 1
     SET gm_u_dm_info2388_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_dm_info2388_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_date":
     IF (null_ind=1)
      SET gm_u_dm_info2388_req->info_datef = 2
     ELSE
      SET gm_u_dm_info2388_req->info_datef = 1
     ENDIF
     SET gm_u_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_datew = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_dm_info2388_req->updt_dt_tmf = 1
     SET gm_u_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_dm_info2388_vc(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_domain":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_dm_info2388_req->info_domainf = 1
     SET gm_u_dm_info2388_req->qual[iqual].info_domain = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_domainw = 1
     ENDIF
    OF "info_name":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_dm_info2388_req->info_namef = 1
     SET gm_u_dm_info2388_req->qual[iqual].info_name = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_namew = 1
     ENDIF
    OF "info_char":
     IF (null_ind=1)
      SET gm_u_dm_info2388_req->info_charf = 2
     ELSE
      SET gm_u_dm_info2388_req->info_charf = 1
     ENDIF
     SET gm_u_dm_info2388_req->qual[iqual].info_char = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_charw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SET gm_u_dm_info2388_req->force_updt_ind = 1
 SET gm_u_dm_info2388_req->allow_partial_ind = 1
 SET gm_u_dm_info2388_req->info_domainw = 1
 SET gm_u_dm_info2388_req->info_namew = 1
 SET gm_u_dm_info2388_req->info_charf = 1
 CALL clear(1,1)
 CALL clear(24,1,132)
 CALL video(nw)
 CALL box(1,1,22,132)
 CALL text(3,43,c_title)
 CALL line(5,1,132,xhor)
 CALL text(7,3,c_msg1)
#accept_mode
 SET accept = noscroll
 CALL text(23,1,"Select whether Advanced or Typical installation options shall be displayed.")
 CALL text(9,5,"(A)dvanced or (T)ypical?  (A/T)  ")
 CALL accept(9,39,"P;CU",user_mode
  WHERE curaccept IN ("A", "T"))
 SET user_mode = cnvtupper(curaccept)
 SET accept = scroll
 SET menu_nbr = 1
 SET stat = alterlist(edw_menu->nbr,menu_nbr)
 SELECT INTO "nl"
  FROM dm_info dm
  WHERE dm.info_domain="PI EDW HEADER*"
   AND cnvtint(substring(1,1,cnvtstring(dm.info_number)))=1
  ORDER BY dm.info_name
  HEAD REPORT
   cnt = 0, pos = 0, menu_nbr = 0,
   next_menu_nbr = 0, mode = " ", menu_item = fillstring(80," "),
   info_domain = fillstring(80," ")
  DETAIL
   pos = 0, menu_nbr = cnvtint(substring(1,1,cnvtstring(dm.info_number))), next_menu_nbr = cnvtint(
    substring(2,1,cnvtstring(dm.info_number))),
   pos = findstring("|",dm.info_name,(pos+ 1)), mode = substring((pos+ 1),1,dm.info_name), menu_item
    = substring(1,(pos - 1),dm.info_name)
   IF (((user_mode="A") OR (user_mode="T"
    AND mode="T")) )
    cnt = (cnt+ 1), stat = alterlist(edw_menu->nbr[1].data,cnt), edw_menu->nbr[1].data[cnt].menu_item
     = menu_item,
    edw_menu->nbr[1].data[cnt].info_domain = dm.info_domain, edw_menu->nbr[1].data[cnt].info_name =
    dm.info_name, edw_menu->nbr[1].data[cnt].menu_nbr = menu_nbr,
    edw_menu->nbr[1].data[cnt].prev_menu_nbr = 0, edw_menu->nbr[1].data[cnt].next_menu_nbr =
    next_menu_nbr, edw_menu->nbr[1].data[cnt].execute_str = " ",
    edw_menu->nbr[1].data[cnt].line_nbr = cnt, edw_menu->nbr[1].data[cnt].prev_line_nbr = 0, edw_menu
    ->nbr[1].data[cnt].accept_input_flag = 0,
    edw_menu->nbr[1].data[cnt].help_str = dm.info_char, edw_menu->nbr[1].data[cnt].mode = mode
   ENDIF
  WITH nocounter
 ;end select
 SET prev_menu_nbr = menu_nbr
 SELECT INTO "nl"
  dm.*, s_info_domain = substring(1,(findstring("^",dm.info_domain) - 1),dm.info_domain)
  FROM dm_info dm,
   (dummyt d1  WITH seq = value(size(edw_menu->nbr[1].data,5)))
  PLAN (d1)
   JOIN (dm
   WHERE dm.info_domain="PI EDW HEADER*"
    AND dm.info_number IS NOT null
    AND (edw_menu->nbr[1].data[d1.seq].next_menu_nbr=cnvtint(substring(1,1,cnvtstring(dm.info_number)
     ))))
  ORDER BY s_info_domain, dm.info_domain, dm.info_name
  HEAD REPORT
   cnt = 0, pos = 0, menu_nbr = 0,
   info_domain = fillstring(72," "), mode = " ", menu_item = fillstring(80," "),
   max_menu_nbr = 0
  HEAD s_info_domain
   cnt = 0, pos = 0, menu_nbr = cnvtint(substring(1,1,cnvtstring(dm.info_number)))
   IF (menu_nbr > max_menu_nbr)
    stat = alterlist(edw_menu->nbr,menu_nbr), max_menu_nbr = menu_nbr
   ENDIF
  HEAD dm.info_domain
   pos = findstring("|",dm.info_domain), info_domain = concat("PI EDW ",substring((pos+ 1),(size(trim
      (dm.info_domain,3)) - pos),dm.info_domain))
  DETAIL
   pos = findstring("|",dm.info_name), menu_item = substring(1,(pos - 1),dm.info_name), mode =
   substring((pos+ 1),1,dm.info_name)
   IF (((user_mode="A") OR (user_mode="T"
    AND mode="T")) )
    cnt = (cnt+ 1), stat = alterlist(edw_menu->nbr[menu_nbr].data,cnt), edw_menu->nbr[menu_nbr].data[
    cnt].menu_item = menu_item,
    edw_menu->nbr[menu_nbr].data[cnt].info_domain = replace(info_domain,"^","|"), edw_menu->nbr[
    menu_nbr].data[cnt].info_name = dm.info_name, edw_menu->nbr[menu_nbr].data[cnt].prev_menu_nbr =
    prev_menu_nbr,
    edw_menu->nbr[menu_nbr].data[cnt].execute_str = " ", edw_menu->nbr[menu_nbr].data[cnt].
    prev_line_nbr = d1.seq, edw_menu->nbr[menu_nbr].data[cnt].accept_input_flag = 0,
    edw_menu->nbr[menu_nbr].data[cnt].help_str = dm.info_char, edw_menu->nbr[menu_nbr].data[cnt].
    line_nbr = cnt, edw_menu->nbr[prev_menu_nbr].data[d1.seq].next_menu_nbr = menu_nbr
   ENDIF
  WITH nocounter
 ;end select
 SET max_menu_nbr = size(edw_menu->nbr,5)
 FOR (lp_menu_nbr = 1 TO size(edw_menu->nbr,5))
  SET prev_menu_nbr = lp_menu_nbr
  IF (size(edw_menu->nbr[lp_menu_nbr].data,5) > 0)
   SELECT INTO "nl"
    dm.*, q_menu_item = edw_menu->nbr[lp_menu_nbr].data[d1.seq].menu_item
    FROM dm_info dm,
     (dummyt d1  WITH seq = value(size(edw_menu->nbr[lp_menu_nbr].data,5)))
    PLAN (d1)
     JOIN (dm
     WHERE ((cnvtupper(edw_menu->nbr[lp_menu_nbr].data[d1.seq].info_domain)=cnvtupper(dm.info_domain)
      AND lp_menu_nbr > 1) OR (lp_menu_nbr=1
      AND (edw_menu->nbr[lp_menu_nbr].data[d1.seq].next_menu_nbr=0)
      AND cnvtupper(dm.info_domain)=cnvtupper(replace(edw_menu->nbr[lp_menu_nbr].data[d1.seq].
       info_domain,"HEADER|","")))) )
    ORDER BY dm.info_domain, q_menu_item, dm.info_name
    HEAD REPORT
     cnt = 0, pos = 0, menu_item = fillstring(110," "),
     accept_input_flag = 0, data_type = fillstring(40," "), help_str = fillstring(130," "),
     first_pass = fillstring(130," ")
    HEAD dm.info_domain
     cnt = 0
    HEAD q_menu_item
     cnt = 0, pos = 0, menu_nbr = (max_menu_nbr+ 1),
     stat = alterlist(edw_menu->nbr,menu_nbr)
    DETAIL
     menu_part1 = fillstring(39," "), pos = findstring("|",dm.info_name), menu_part1 = substring(1,(
      pos - 1),dm.info_name),
     data_type = substring((pos+ 1),40,dm.info_name), pos = findstring("|",dm.info_char)
     IF (pos > 1)
      curr_val = substring(1,(pos - 1),dm.info_char)
     ELSE
      curr_val = " "
     ENDIF
     first_pass = substring((pos+ 1),((size(trim(dm.info_char,3)) - pos)+ 1),dm.info_char), pos =
     findstring("|",first_pass), help_str = substring((pos+ 1),((size(trim(first_pass,3)) - pos)+ 1),
      first_pass)
     IF (data_type="BOOLEAN")
      accept_input_flag = 1
     ELSEIF (data_type="DATE")
      accept_input_flag = 2
     ELSEIF (data_type="FT")
      accept_input_flag = 3
     ELSE
      accept_input_flag = 0
     ENDIF
     cnt = (cnt+ 1), stat = alterlist(edw_menu->nbr[menu_nbr].data,cnt), menu_item = concat(
      menu_part1,substring(1,71,curr_val)),
     edw_menu->nbr[menu_nbr].data[cnt].menu_item = menu_item, edw_menu->nbr[menu_nbr].data[cnt].
     info_domain = dm.info_domain, edw_menu->nbr[menu_nbr].data[cnt].info_name = dm.info_name,
     edw_menu->nbr[menu_nbr].data[cnt].prev_menu_nbr = prev_menu_nbr, edw_menu->nbr[menu_nbr].data[
     cnt].execute_str = " ", edw_menu->nbr[menu_nbr].data[cnt].prev_line_nbr = d1.seq,
     edw_menu->nbr[menu_nbr].data[cnt].accept_input_flag = accept_input_flag, edw_menu->nbr[menu_nbr]
     .data[cnt].help_str = help_str, edw_menu->nbr[menu_nbr].data[cnt].line_nbr = cnt,
     edw_menu->nbr[menu_nbr].data[cnt].curr_val = curr_val, edw_menu->nbr[prev_menu_nbr].data[d1.seq]
     .next_menu_nbr = menu_nbr
    FOOT  q_menu_item
     max_menu_nbr = menu_nbr
    FOOT  dm.info_domain
     x = 0
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 SET menu_nbr = 1
 SET v_rptcnt = size(edw_menu->nbr[menu_nbr].data,5)
 SET edw_menu->nbr[1].arow = 0
 SET edw_menu->nbr[1].cnt = 0
 SET edw_menu->nbr[1].scroll_row = 7
 SET edw_menu->nbr[1].scroll_col = 5
 SET edw_menu->nbr[1].num_scroll_row = 13
 SET edw_menu->nbr[1].num_scroll_col = 110
 EXECUTE FROM 9000_display_screen TO 9099_display_screen_exit
 SET edw_menu->nbr[menu_nbr].cnt = 1
 SET edw_menu->nbr[menu_nbr].arow = 1
 SET pick = 0
 SET array_length = v_rptcnt
 SET accept_input_row = 1
 SET accept = scroll
 WHILE (pick=0)
   SET curr_line_num = 0
   CALL clear(24,1,132)
   IF (menu_nbr > 1)
    CALL text(24,107,c_prev)
   ELSE
    CALL text(24,117,c_exit)
   ENDIF
   EXECUTE FROM 9000_end_of_data_line TO 9099_end_of_data_line_exit
   SET accept = nochange
   IF (size(trim(edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].help_str,3)) > 0)
    CALL text(23,1,edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].help_str)
   ENDIF
   IF ((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].accept_input_flag=0))
    CALL text(24,1,"Select:  ")
    CALL accept(24,10,"P(39);CS",substring(1,39,edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].
      cnt].menu_item))
   ELSEIF ((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].accept_input_flag=1))
    CALL text(24,1,"(Y)es/(N)o:  ")
    IF (size(trim(edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].new_val,3)) > 0)
     CALL accept(24,13,"P;CS",edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].new_val)
    ELSE
     CALL accept(24,13,"P;CS",edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].curr_val)
    ENDIF
   ELSEIF ((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].accept_input_flag=2))
    IF (valid_date_ind=1)
     CALL text(24,1,"Date/Time: ")
     IF (size(trim(edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].new_val,3)) > 0)
      CALL accept(24,13,"99daaad9999d99d99d99;CS",edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr
       ].cnt].new_val)
     ELSEIF (size(trim(edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].curr_val,3)) > 0)
      CALL accept(24,13,"99daaad9999d99d99d99;CS",edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr
       ].cnt].curr_val)
     ELSE
      CALL accept(24,13,"99daaad9999d99d99d99;CS","dd-mmm-yyyy hh:mi:ss")
     ENDIF
    ELSE
     CALL text(24,1,"NOT A VALID DATE.  Date/Time: ")
     IF (size(trim(edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].new_val,3)) > 0)
      CALL accept(24,32,"99daaad9999d99d99d99;CS",edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr
       ].cnt].new_val)
     ELSEIF (size(trim(edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].curr_val,3)) > 0)
      CALL accept(24,32,"99daaad9999d99d99d99;CS",edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr
       ].cnt].curr_val)
     ELSE
      CALL accept(24,32,"99daaad9999d99d99d99;CS","dd-mmm-yyyy hh:mi:ss")
     ENDIF
    ENDIF
   ELSEIF ((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].accept_input_flag=3))
    CALL text(24,1,"Value:  ")
    IF (size(trim(edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].new_val,3)) > 0)
     CALL accept(24,9,"P(85);CS",edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].new_val)
    ELSE
     CALL accept(24,9,"P(85);CS",edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].curr_val)
    ENDIF
   ENDIF
   CASE (curscroll)
    OF 0:
     SET v_select = curaccept
     SET curr_line_num = edw_menu->nbr[menu_nbr].cnt
     IF ((((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].accept_input_flag=0)
      AND v_select=trim(substring(1,39,edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].
       menu_item))) OR ((((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].
     accept_input_flag=1)
      AND v_select IN ("Y", "N", "y", "n")) OR ((((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[
     menu_nbr].cnt].accept_input_flag=2)) OR ((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].
     cnt].accept_input_flag=3))) )) )) )
      IF (size(trim(edw_menu->nbr[menu_nbr].data[curr_line_num].execute_str)) > 0)
       CALL parser(edw_menu->nbr[menu_nbr].data[curr_line_num].execute_str)
       EXECUTE FROM 9000_display_screen TO 9099_display_screen_exit
       SET edw_menu->nbr[menu_nbr].cnt = 1
       SET edw_menu->nbr[menu_nbr].arow = 1
       IF (menu_nbr > 1)
        CALL text(24,107,c_prev)
       ENDIF
       CALL box(edw_menu->nbr[menu_nbr].scroll_row,(edw_menu->nbr[menu_nbr].scroll_col - 1),edw_menu
        ->nbr[menu_nbr].scroll_row,(edw_menu->nbr[menu_nbr].num_scroll_row+ 1),edw_menu->nbr[menu_nbr
        ].scroll_col,
        (edw_menu->nbr[menu_nbr].num_scroll_col+ 1))
       IF (nbr > 1)
        CALL text((edw_menu->nbr[menu_nbr].scroll_row - 1),(edw_menu->nbr[menu_nbr].scroll_col - 1),
         edw_menu->nbr[prev_menu_nbr].data[prev_line_num].menu_item)
       ENDIF
      ELSEIF ((edw_menu->nbr[menu_nbr].data[curr_line_num].next_menu_nbr > 0))
       SET prev_menu_nbr = menu_nbr
       SET menu_nbr = edw_menu->nbr[menu_nbr].data[curr_line_num].next_menu_nbr
       SET edw_menu->nbr[menu_nbr].arow = 0
       SET edw_menu->nbr[menu_nbr].cnt = 0
       IF (prev_menu_nbr=1)
        SET edw_menu->nbr[menu_nbr].scroll_row = (edw_menu->nbr[prev_menu_nbr].scroll_row+ 3)
        SET edw_menu->nbr[menu_nbr].scroll_col = (edw_menu->nbr[prev_menu_nbr].scroll_col+ 3)
        SET edw_menu->nbr[menu_nbr].num_scroll_row = (edw_menu->nbr[prev_menu_nbr].num_scroll_row - 3
        )
        SET edw_menu->nbr[menu_nbr].num_scroll_col = (edw_menu->nbr[prev_menu_nbr].num_scroll_col - 6
        )
       ELSE
        SET edw_menu->nbr[menu_nbr].scroll_row = edw_menu->nbr[prev_menu_nbr].scroll_row
        SET edw_menu->nbr[menu_nbr].scroll_col = edw_menu->nbr[prev_menu_nbr].scroll_col
        SET edw_menu->nbr[menu_nbr].num_scroll_row = edw_menu->nbr[prev_menu_nbr].num_scroll_row
        SET edw_menu->nbr[menu_nbr].num_scroll_col = edw_menu->nbr[prev_menu_nbr].num_scroll_col
       ENDIF
       SET v_rptcnt = size(edw_menu->nbr[menu_nbr].data,5)
       SET array_length = v_rptcnt
       EXECUTE FROM 9000_display_screen TO 9099_display_screen_exit
       SET edw_menu->nbr[menu_nbr].cnt = 1
       SET edw_menu->nbr[menu_nbr].arow = 1
       IF (menu_nbr > 1)
        CALL text(24,107,c_prev)
       ENDIF
       CALL box(edw_menu->nbr[menu_nbr].scroll_row,(edw_menu->nbr[menu_nbr].scroll_col - 1),edw_menu
        ->nbr[menu_nbr].scroll_row,(edw_menu->nbr[menu_nbr].num_scroll_row+ 1),edw_menu->nbr[menu_nbr
        ].scroll_col,
        (edw_menu->nbr[menu_nbr].num_scroll_col+ 1))
       CALL text((edw_menu->nbr[menu_nbr].scroll_row - 1),(edw_menu->nbr[menu_nbr].scroll_col - 1),
        edw_menu->nbr[prev_menu_nbr].data[curr_line_num].menu_item)
       SET prev_line_num = curr_line_num
      ELSE
       IF ((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].accept_input_flag=1))
        SET v_select = cnvtupper(v_select)
       ELSEIF ((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].accept_input_flag=2))
        SET valid_date_ind = 0
        SET dd = cnvtint(substring(1,2,v_select))
        SET mmm = cnvtupper(substring(4,3,v_select))
        SET yyyy = cnvtint(substring(8,4,v_select))
        SET hh = cnvtint(substring(13,2,v_select))
        SET mi = cnvtint(substring(16,2,v_select))
        SET ss = cnvtint(substring(19,2,v_select))
        IF (yyyy BETWEEN 1900 AND 2100
         AND hh BETWEEN 0 AND 23
         AND mi BETWEEN 0 AND 59
         AND ss BETWEEN 0 AND 59)
         IF (((mmm IN ("JAN", "MAR", "MAY", "JUL", "AUG",
         "OCT", "DEC")
          AND dd BETWEEN 1 AND 31) OR (((mmm IN ("APR", "JUN", "SEP", "NOV")
          AND dd BETWEEN 1 AND 30) OR (((mmm="FEB"
          AND mod(yyyy,4)=0
          AND dd BETWEEN 1 AND 29) OR (mmm="FEB"
          AND mod(yyyy,4) > 0
          AND dd BETWEEN 1 AND 28)) )) )) )
          SET valid_date_ind = 1
         ENDIF
        ENDIF
       ENDIF
       IF ((((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].accept_input_flag=2)
        AND valid_date_ind=1) OR ((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].
       accept_input_flag != 2))) )
        SET edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].new_val = v_select
        IF (size(trim(v_select,3)) > 65)
         SET edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].menu_item = concat(substring(1,
           39,edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].menu_item),substring(1,62,
           v_select),"...")
        ELSE
         SET edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].menu_item = concat(substring(1,
           39,edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].menu_item),v_select)
        ENDIF
        IF ((edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].new_val != edw_menu->nbr[
        menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].curr_val)
         AND size(trim(edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].new_val,3)) > 0
         AND change_val_ind=0)
         SET change_val_ind = 1
        ENDIF
        CALL scrolltext(edw_menu->nbr[menu_nbr].arow,substring(1,edw_menu->nbr[menu_nbr].
          num_scroll_col,edw_menu->nbr[menu_nbr].data[edw_menu->nbr[menu_nbr].cnt].menu_item))
        IF ((edw_menu->nbr[menu_nbr].cnt < v_rptcnt))
         EXECUTE FROM 9000_down_arrow TO 9099_down_arrow_exit
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    OF 1:
     EXECUTE FROM 9000_down_arrow TO 9099_down_arrow_exit
    OF 2:
     EXECUTE FROM 9000_up_arrow TO 9099_up_arrow_exit
    OF 3:
     EXECUTE FROM 9000_pf1 TO 9099_pf1_exit
    OF 4:
     EXECUTE FROM 9000_pf2 TO 9099_pf2_exit
    OF 5:
     EXECUTE FROM 9000_pf2 TO 9099_pf2_exit
    OF 6:
     EXECUTE FROM 9000_pf1 TO 9099_pf1_exit
    OF 10:
     EXECUTE FROM 9000_prev_menu TO 9099_prev_menu_exit
    ELSE
     SET pick = 0
   ENDCASE
 ENDWHILE
 GO TO end_program
#9000_display_screen
 CALL clear(1,1)
 CALL clear(24,1,132)
 CALL video(nw)
 CALL box(1,1,22,132)
 CALL text(3,43,c_title)
 CALL line(5,1,132,xhor)
 CALL text(7,3,c_msg1)
 CALL text(24,117,c_exit)
 CALL scrollinit((edw_menu->nbr[menu_nbr].scroll_row+ 1),(edw_menu->nbr[menu_nbr].scroll_col+ 1),(
  edw_menu->nbr[menu_nbr].scroll_row+ edw_menu->nbr[menu_nbr].num_scroll_row),(edw_menu->nbr[menu_nbr
  ].scroll_col+ edw_menu->nbr[menu_nbr].num_scroll_col))
 SET cnt = 1
 IF ((v_rptcnt > edw_menu->nbr[menu_nbr].num_scroll_row))
  WHILE ((cnt <= edw_menu->nbr[menu_nbr].num_scroll_row))
   CALL scrolltext(cnt,edw_menu->nbr[menu_nbr].data[cnt].menu_item)
   SET cnt = (cnt+ 1)
  ENDWHILE
 ELSE
  WHILE (cnt <= v_rptcnt)
   CALL scrolltext(cnt,edw_menu->nbr[menu_nbr].data[cnt].menu_item)
   SET cnt = (cnt+ 1)
  ENDWHILE
 ENDIF
#9099_display_screen_exit
#9000_down_arrow
 IF ((edw_menu->nbr[menu_nbr].cnt < v_rptcnt))
  SET edw_menu->nbr[menu_nbr].cnt = (edw_menu->nbr[menu_nbr].cnt+ 1)
  SET cnt = edw_menu->nbr[menu_nbr].cnt
  SET arow = edw_menu->nbr[menu_nbr].arow
  IF ((arow=edw_menu->nbr[menu_nbr].num_scroll_row))
   CALL scrolldown(arow,arow,edw_menu->nbr[menu_nbr].data[cnt].menu_item)
  ELSE
   SET edw_menu->nbr[menu_nbr].arow = (edw_menu->nbr[menu_nbr].arow+ 1)
   SET arow = edw_menu->nbr[menu_nbr].arow
   CALL scrolldown((arow - 1),arow,edw_menu->nbr[menu_nbr].data[cnt].menu_item)
  ENDIF
 ENDIF
#9099_down_arrow_exit
#9000_pf1
 SET arow = edw_menu->nbr[menu_nbr].arow
 SET cnt = edw_menu->nbr[menu_nbr].cnt
 IF ((arow=edw_menu->nbr[menu_nbr].num_scroll_row))
  SET lower_bound = ((cnt - edw_menu->nbr[menu_nbr].num_scroll_row)+ 1)
  SET upper_bound = cnt
 ELSEIF (arow=1)
  SET lower_bound = cnt
  SET upper_bound = ((cnt+ edw_menu->nbr[menu_nbr].num_scroll_row) - 1)
 ELSE
  SET upper_bound = ((edw_menu->nbr[menu_nbr].num_scroll_row - arow)+ cnt)
  SET lower_bound = ((upper_bound - edw_menu->nbr[menu_nbr].num_scroll_row)+ 1)
 ENDIF
 IF (upper_bound < v_rptcnt)
  IF (arow > 1)
   CALL text((arow+ edw_menu->nbr[menu_nbr].scroll_row),11,edw_menu->nbr[menu_nbr].data[cnt].
    menu_item)
  ENDIF
  SET cnt = lower_bound
  SET cnt = ((cnt+ edw_menu->nbr[menu_nbr].num_scroll_row) - 1)
  IF (((cnt+ edw_menu->nbr[menu_nbr].num_scroll_row) > v_rptcnt))
   SET cnt = (v_rptcnt - edw_menu->nbr[menu_nbr].num_scroll_row)
  ENDIF
  SET arow = 1
  WHILE ((arow <= edw_menu->nbr[menu_nbr].num_scroll_row))
    SET cnt = (cnt+ 1)
    CALL scrolltext(arow,edw_menu->nbr[menu_nbr].data[cnt].menu_item)
    SET arow = (arow+ 1)
  ENDWHILE
  SET arow = 1
  SET cnt = ((cnt - edw_menu->nbr[menu_nbr].num_scroll_row)+ 1)
 ENDIF
 SET edw_menu->nbr[menu_nbr].cnt = cnt
 SET edw_menu->nbr[menu_nbr].arow = arow
#9099_pf1_exit
#9000_pf2
 SET cnt = edw_menu->nbr[menu_nbr].cnt
 SET arow = edw_menu->nbr[menu_nbr].arow
 IF (cnt > 1)
  IF ((cnt >= (edw_menu->nbr[menu_nbr].num_scroll_row+ edw_menu->nbr[menu_nbr].num_scroll_row)))
   SET cnt = (((cnt - arow) - edw_menu->nbr[menu_nbr].num_scroll_row)+ 1)
   SET x = 1
   WHILE ((x <= edw_menu->nbr[menu_nbr].num_scroll_row))
     CALL scrolltext(x,edw_menu->nbr[menu_nbr].data[cnt].menu_item)
     SET cnt = (cnt+ 1)
     SET x = (x+ 1)
   ENDWHILE
   SET cnt = (((edw_menu->nbr[menu_nbr].cnt - edw_menu->nbr[menu_nbr].arow) - edw_menu->nbr[menu_nbr]
   .num_scroll_row)+ 1)
   SET arow = 1
  ELSE
   SET cnt = 1
   IF ((size(edw_menu->nbr[menu_nbr].data,5) >= edw_menu->nbr[menu_nbr].num_scroll_row))
    WHILE ((cnt <= edw_menu->nbr[menu_nbr].num_scroll_row))
     CALL scrolltext(cnt,edw_menu->nbr[menu_nbr].data[cnt].menu_item)
     SET cnt = (cnt+ 1)
    ENDWHILE
   ELSE
    WHILE (cnt <= size(edw_menu->nbr[menu_nbr].data,5))
     CALL scrolltext(cnt,edw_menu->nbr[menu_nbr].data[cnt].menu_item)
     SET cnt = (cnt+ 1)
    ENDWHILE
   ENDIF
   SET cnt = 1
   SET arow = 1
  ENDIF
 ENDIF
 SET edw_menu->nbr[menu_nbr].cnt = cnt
 SET edw_menu->nbr[menu_nbr].arow = arow
#9099_pf2_exit
#9000_up_arrow
 SET cnt = edw_menu->nbr[menu_nbr].cnt
 SET arow = edw_menu->nbr[menu_nbr].arow
 IF (cnt > 1)
  SET cnt = (cnt - 1)
  IF (arow=1)
   CALL scrollup(arow,arow,edw_menu->nbr[menu_nbr].data[cnt].menu_item)
  ELSE
   SET arow = (arow - 1)
   CALL scrollup((arow+ 1),arow,edw_menu->nbr[menu_nbr].data[cnt].menu_item)
  ENDIF
 ENDIF
 SET edw_menu->nbr[menu_nbr].cnt = cnt
 SET edw_menu->nbr[menu_nbr].arow = arow
#9099_up_arrow_exit
#9000_end_of_data_line
 SET end_of_data_line = (edw_menu->nbr[menu_nbr].num_scroll_row+ edw_menu->nbr[menu_nbr].scroll_row)
 IF ((edw_menu->nbr[menu_nbr].arow=edw_menu->nbr[menu_nbr].num_scroll_row))
  SET end_of_data = edw_menu->nbr[menu_nbr].cnt
 ELSEIF ((edw_menu->nbr[menu_nbr].arow=1))
  SET end_of_data = ((edw_menu->nbr[menu_nbr].cnt+ edw_menu->nbr[menu_nbr].num_scroll_row) - 1)
 ELSE
  SET end_of_data = ((edw_menu->nbr[menu_nbr].num_scroll_row - edw_menu->nbr[menu_nbr].arow)+
  edw_menu->nbr[menu_nbr].cnt)
 ENDIF
 IF (end_of_data <= size(edw_menu->nbr[menu_nbr].data,5))
  IF (end_of_data >= array_length)
   CALL clear(21,55,23)
   CALL text(21,55,"* * * end of data * * *")
  ELSE
   CALL clear(((edw_menu->nbr[menu_nbr].num_scroll_row+ edw_menu->nbr[menu_nbr].scroll_row)+ 1),55,23
    )
   CALL text(((edw_menu->nbr[menu_nbr].num_scroll_row+ edw_menu->nbr[menu_nbr].scroll_row)+ 1),55,
    "* * *  continued  * * *")
  ENDIF
 ELSE
  WHILE (end_of_data > 0
   AND end_of_data > size(edw_menu->nbr[menu_nbr].data,5))
   SET end_of_data = (end_of_data - 1)
   SET end_of_data_line = (end_of_data_line - 1)
  ENDWHILE
  SET end_of_data_line = (end_of_data_line+ 1)
  CALL clear(end_of_data_line,55,23)
  CALL text(end_of_data_line,55,"* * * end of data * * *")
 ENDIF
#9099_end_of_data_line_exit
#9000_prev_menu
 IF (menu_nbr=1)
  GO TO end_program
 ELSE
  SET valid_date_ind = 1
  SET hold_menu_nbr = menu_nbr
  SET menu_nbr = prev_menu_nbr
  SET prev_menu_nbr = hold_menu_nbr
  SET edw_menu->nbr[menu_nbr].arow = 0
  SET edw_menu->nbr[menu_nbr].cnt = 0
  IF ((edw_menu->nbr[prev_menu_nbr].data[1].prev_menu_nbr=1))
   SET edw_menu->nbr[menu_nbr].scroll_row = (edw_menu->nbr[prev_menu_nbr].scroll_row - 3)
   SET edw_menu->nbr[menu_nbr].scroll_col = (edw_menu->nbr[prev_menu_nbr].scroll_col - 3)
   SET edw_menu->nbr[menu_nbr].num_scroll_row = (edw_menu->nbr[prev_menu_nbr].num_scroll_row+ 3)
   SET edw_menu->nbr[menu_nbr].num_scroll_col = (edw_menu->nbr[prev_menu_nbr].num_scroll_col+ 6)
  ELSE
   SET edw_menu->nbr[menu_nbr].scroll_row = edw_menu->nbr[prev_menu_nbr].scroll_row
   SET edw_menu->nbr[menu_nbr].scroll_col = edw_menu->nbr[prev_menu_nbr].scroll_col
   SET edw_menu->nbr[menu_nbr].num_scroll_row = edw_menu->nbr[prev_menu_nbr].num_scroll_row
   SET edw_menu->nbr[menu_nbr].num_scroll_col = edw_menu->nbr[prev_menu_nbr].num_scroll_col
  ENDIF
  SET v_rptcnt = size(edw_menu->nbr[menu_nbr].data,5)
  SET array_length = v_rptcnt
  EXECUTE FROM 9000_display_screen TO 9099_display_screen_exit
  SET edw_menu->nbr[menu_nbr].cnt = 1
  SET edw_menu->nbr[menu_nbr].arow = 1
  IF (menu_nbr > 1)
   CALL text(24,107,c_prev)
   CALL box(edw_menu->nbr[menu_nbr].scroll_row,(edw_menu->nbr[menu_nbr].scroll_col - 1),edw_menu->
    nbr[menu_nbr].scroll_row,(edw_menu->nbr[menu_nbr].num_scroll_row+ 1),edw_menu->nbr[menu_nbr].
    scroll_col,
    (edw_menu->nbr[menu_nbr].num_scroll_col+ 1))
   CALL text((edw_menu->nbr[menu_nbr].scroll_row - 1),(edw_menu->nbr[menu_nbr].scroll_col - 1),
    edw_menu->nbr[edw_menu->nbr[menu_nbr].data[prev_line_num].prev_menu_nbr].data[edw_menu->nbr[
    menu_nbr].data[prev_line_num].prev_line_nbr].menu_item)
  ENDIF
  SET prev_menu_nbr = edw_menu->nbr[menu_nbr].data[prev_line_num].prev_menu_nbr
  SET prev_line_num = edw_menu->nbr[menu_nbr].data[prev_line_num].prev_line_nbr
 ENDIF
#9099_prev_menu_exit
#9000_save_changes
 FOR (menu_nbr = 1 TO size(edw_menu->nbr,5))
   FOR (line_num = 1 TO size(edw_menu->nbr[menu_nbr].data,5))
     IF (size(trim(edw_menu->nbr[menu_nbr].data[line_num].new_val,3)) > 0)
      SET dm_info_cnt = (dm_info_cnt+ 1)
      SET stat = alterlist(gm_u_dm_info2388_req->qual,dm_info_cnt)
      SET gm_u_dm_info2388_req->qual[dm_info_cnt].info_domain = edw_menu->nbr[menu_nbr].data[line_num
      ].info_domain
      SET gm_u_dm_info2388_req->qual[dm_info_cnt].info_name = edw_menu->nbr[menu_nbr].data[line_num].
      info_name
      SET gm_u_dm_info2388_req->qual[dm_info_cnt].info_char = concat(trim(edw_menu->nbr[menu_nbr].
        data[line_num].new_val,3),"|",trim(edw_menu->nbr[menu_nbr].data[line_num].help_str,3))
     ENDIF
   ENDFOR
 ENDFOR
 EXECUTE gm_u_dm_info2388  WITH replace(request,gm_u_dm_info2388_req), replace(reply,
  gm_u_dm_info2388_rep)
 FREE RECORD gm_i_dm_info2388_req
 FREE RECORD gm_i_dm_info2388_rep
 COMMIT
#9099_save_changes_exit
#end_program
 IF (change_val_ind=1)
  CALL clear(1,1)
  CALL clear(24,1,132)
  CALL video(nw)
  CALL box(1,1,22,132)
  CALL text(3,43,c_title)
  CALL line(5,1,132,xhor)
  CALL text(24,1,"Save changes? (Y/N)")
  CALL accept(24,22,"P;CU","Y"
   WHERE curaccept IN ("Y", "N"))
  IF (curaccept="Y")
   EXECUTE FROM 9000_save_changes TO 9099_save_changes_exit
  ENDIF
 ENDIF
 CALL clear(1,1)
END GO

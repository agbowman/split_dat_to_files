CREATE PROGRAM ec_copy_pos_info:dba
 PAINT
 SET width = 132
 SET modify = system
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dtoposition = f8 WITH noconstant(0.0)
 DECLARE dfromposition = f8 WITH noconstant(0.0)
 DECLARE bkeepfrompos = i2 WITH noconstant(0)
 DECLARE sactionprompt = vc WITH noconstant("")
 DECLARE icnt = i4 WITH noconstant(0)
 DECLARE icnt2 = i4 WITH noconstant(0)
 DECLARE forcnt = i4 WITH noconstant(0)
 DECLARE imainoption = i4 WITH noconstant(0)
 DECLARE bfilefound = i2 WITH noconstant(1)
 DECLARE sloadfile = vc WITH noconstant("")
 DECLARE iexp = i4 WITH noconstant(0)
 DECLARE slogfile = vc WITH constant("ec_copy_pos_log.csv")
 DECLARE stemp = vc WITH noconstant("")
 DECLARE irowcnt = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE ipos = i4 WITH noconstant(0)
 DECLARE ipos2 = i4 WITH noconstant(0)
 DECLARE ichangeflg = i2 WITH noconstant(0)
 DECLARE icur_list_size = i4 WITH noconstant(0)
 DECLARE iloop_cnt = i4 WITH noconstant(0)
 DECLARE inew_list_size = i4 WITH noconstant(0)
 DECLARE istart = i4 WITH noconstant(0)
 DECLARE iexpandidx = i4 WITH noconstant(0)
 DECLARE ibatch_size = i4 WITH constant(50)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE ifor_idx = i4 WITH noconstant(0)
 DECLARE choose_to_and_from(dummy=null) = null
 DECLARE upd_oef_flex(dummy=null) = null
 DECLARE upd_oef_flx_file(dummy=null) = null
 DECLARE write_oef_flx_log(dummy=null) = null
 DECLARE upd_clin_equa(dummy=null) = null
 DECLARE upd_clin_equa_file(dummy=null) = null
 DECLARE write_clin_equa_log(dummy=null) = null
 DECLARE upd_mrp(dummy=null) = null
 DECLARE upd_mrp_file(dummy=null) = null
 DECLARE write_mrp_log(dummy=null) = null
 DECLARE load_csv(dummy=null) = null
 FREE RECORD add_flx_request
 RECORD add_flx_request(
   1 oe_format_id = f8
   1 oe_field_id = f8
   1 action_type_cd = f8
   1 flex_type_flag = i2
   1 flex_cd = f8
   1 accept_flag = i2
   1 default_value = c100
   1 lock_on_modify_flag = i2
 )
 FREE RECORD del_flx_request
 RECORD del_flx_request(
   1 oe_format_id = f8
   1 oe_field_id = f8
   1 action_type_cd = f8
   1 flex_type_flag = i2
   1 flex_cd = f8
 )
 FREE RECORD oef_hold
 RECORD oef_hold(
   1 qual_cnt = i4
   1 qual[*]
     2 oe_format_id = f8
     2 oe_format_name = vc
     2 oe_field_id = f8
     2 oe_field_name = vc
     2 action_type_cd = f8
     2 flex_type_flag = i2
     2 flex_cd = f8
     2 accept_flag = i2
     2 default_value = c100
     2 lock_on_modify_flag = i2
     2 error_ind = i2
 )
 FREE RECORD equa_hold
 RECORD equa_hold(
   1 qual_cnt = i4
   1 qual[*]
     2 dcp_equation_id = f8
     2 dcp_equa_name = vc
     2 trgt_position = f8
     2 dup_flag = i2
     2 posqual[*]
       3 position_cd = f8
 )
 FREE RECORD mrp_hold
 RECORD mrp_hold(
   1 qual_cnt = i4
   1 qual[*]
     2 chart_section_id = f8
     2 chart_section_name = vc
     2 chart_format_id = f8
     2 chart_format_name = vc
     2 position_cnt = i4
     2 position_qual[*]
       3 organization_id = f8
       3 position_cd = f8
       3 dup_ind = i2
 )
 FREE RECORD file_hold
 RECORD file_hold(
   1 trgt_cnt = i4
   1 target[*]
     2 trgt_pos = f8
     2 src_pos = f8
 )
 DECLARE header_string = vc WITH noconstant(" ")
 DECLARE cell_value = vc WITH noconstant(" ")
 DECLARE row_string = vc WITH noconstant(" ")
 DECLARE write_log(swritelogfile=vc) = null
 FREE RECORD logrec
 RECORD logrec(
   1 collist[*]
     2 header_text = vc
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
 )
 SUBROUTINE write_log(swritelogfile)
   FOR (x = 1 TO size(logrec->collist,5))
     IF (x=1)
      SET header_string = build('"',logrec->collist[x].header_text,'"')
     ELSE
      SET header_string = build(header_string,',"',logrec->collist[x].header_text,'"')
     ENDIF
   ENDFOR
   SELECT INTO value(swritelogfile)
    FROM dummyt d
    PLAN (d)
    DETAIL
     col 0, header_string, row + 1
     FOR (x = 1 TO size(logrec->rowlist,5))
       FOR (y = 1 TO size(logrec->rowlist[x].celllist,5))
         cell_value = " "
         IF ((logrec->rowlist[x].celllist[y].string_value > " "))
          cell_value = logrec->rowlist[x].celllist[y].string_value
         ELSEIF ((logrec->rowlist[x].celllist[y].double_value > 0))
          cell_value = cnvtstring(logrec->rowlist[x].celllist[y].double_value)
         ELSEIF ((logrec->rowlist[x].celllist[y].nbr_value > 0))
          cell_value = cnvtstring(logrec->rowlist[x].celllist[y].nbr_value)
         ELSEIF ((logrec->rowlist[x].celllist[y].date_value > 0))
          cell_value = format(logrec->rowlist[x].celllist[y].date_value,"mm/dd/yyyy hh:mm;;d")
         ENDIF
         IF (y=1)
          row_string = build('"',cell_value,'"')
         ELSE
          row_string = build(row_string,',"',cell_value,'"')
         ENDIF
       ENDFOR
       col 0, row_string, row + 1
     ENDFOR
    WITH nocounter, append, pcformat('"',",",1),
     format = stream, maxcol = 10000, formfeed = none
   ;end select
   SET stat = alterlist(logrec->collist,0)
   SET stat = alterlist(logrec->rowlist,0)
 END ;Subroutine
#menu
 SET reqinfo->updt_task = 10705
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,11,132)
 CALL text(2,1,"Exp Center Position Copy Tool",w)
 CALL text(5,20," 1)  Order Entry Format Flexing")
 CALL text(6,20," 2)  Clinical Equations")
 CALL text(7,20," 3)  MRP")
 CALL text(8,20," 4)  Exit")
 CALL text(24,2,"Select Option (1,2,3,4...):")
 CALL accept(24,30,"9;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CALL clear(24,1)
 SET imainoption = curaccept
 CASE (imainoption)
  OF 1:
   SET sactionprompt = "Copy Order Entry Format Flexing"
  OF 2:
   SET sactionprompt = "Copy Clinical Equations"
  OF 3:
   SET sactionprompt = "Copy MRP"
  OF 4:
   GO TO quit
  ELSE
   GO TO quit
 ENDCASE
 CALL clear(1,1)
 CALL box(3,1,11,132)
 CALL text(2,1,sactionprompt,w)
 CALL text(5,20," 1)  Load positions from CSV")
 CALL text(6,20," 2)  Choose positions manually")
 CALL text(7,20," 3)  Main Menu")
 CALL text(24,2,"Select Option (1,2,3...):")
 CALL accept(24,28,"9;",3
  WHERE curaccept IN (1, 2, 3))
 CALL clear(24,1)
 CASE (imainoption)
  OF 1:
   IF (curaccept=1)
    SET bfilefound = 1
    GO TO oef_flx_file
   ELSEIF (curaccept=2)
    GO TO oef_flexing
   ELSE
    GO TO menu
   ENDIF
  OF 2:
   IF (curaccept=1)
    SET bfilefound = 1
    GO TO clin_equa_file
   ELSEIF (curaccept=2)
    GO TO clin_equa
   ELSE
    GO TO menu
   ENDIF
  OF 3:
   IF (curaccept=1)
    SET bfilefound = 1
    GO TO mrp_copy_file
   ELSEIF (curaccept=2)
    GO TO mrp_copy
   ELSE
    GO TO menu
   ENDIF
  OF 4:
   GO TO menu
  ELSE
   GO TO quit
 ENDCASE
 GO TO menu
#oef_flexing
 CALL choose_to_and_from(null)
 IF (dtoposition > 0.0
  AND dfromposition > 0.0)
  SET sactionprompt = build2("Copy OEF flexing from ",trim(uar_get_code_display(dfromposition),3),
   " to ",trim(uar_get_code_display(dtoposition),3))
  CALL video(n)
  CALL clear(1,1)
  CALL text(2,1,"Position Copy - Order Entry Format Flexing",w)
  CALL box(3,1,7,132)
  CALL text(4,4,sactionprompt)
  IF (bkeepfrompos=1)
   CALL text(6,4,"The from position rows WILL NOT be removed")
  ELSE
   CALL text(6,4,"The from position rows WILL be removed")
  ENDIF
  CALL text(24,02,"Is this correct?  Y, N, or M for Main Menu:")
  CALL video(n)
  CALL video(ul)
  CALL accept(24,46,"A;CU","N"
   WHERE curaccept IN ("Y", "N", "M"))
  IF (curaccept="Y")
   CALL upd_oef_flex(null)
   GO TO oef_flexing
  ELSEIF (curaccept="N")
   GO TO oef_flexing
  ELSEIF (curaccept="M")
   GO TO menu
  ELSE
   GO TO menu
  ENDIF
 ELSE
  GO TO quit
 ENDIF
#oef_flx_file
 CALL video(n)
 CALL clear(1,1)
 CALL text(2,1,"Position Copy - Clinical Equation Copy - Load from File",w)
 CALL box(3,1,7,132)
 CALL text(4,4,"Enter the location and name of the CSV file (ccluserdir:example.csv or M for menu) :"
  )
 IF (bfilefound=0)
  CALL text(6,4,"File was not found")
 ENDIF
 CALL accept(4,90,"P(40);C")
 IF (findfile(curaccept)=1)
  SET bkeepfrompos = 1
  SET sloadfile = curaccept
  CALL load_csv(null)
  CALL upd_oef_flx_file(null)
 ELSEIF (cnvtupper(curaccept)="M")
  GO TO menu
 ELSE
  SET bfilefound = 0
  GO TO oef_flx_file
 ENDIF
#clin_equa
 CALL choose_to_and_from(null)
 IF (dtoposition > 0.0
  AND dfromposition > 0.0)
  SET sactionprompt = build2("Copy clinical equations from ",trim(uar_get_code_display(dfromposition),
    3)," to ",trim(uar_get_code_display(dtoposition),3))
  CALL video(n)
  CALL clear(1,1)
  CALL text(2,1,"Position Copy - Clinical Equation Copy",w)
  CALL box(3,1,7,132)
  CALL text(4,4,sactionprompt)
  IF (bkeepfrompos=1)
   CALL text(6,4,"The from position rows WILL NOT be removed")
  ELSE
   CALL text(6,4,"The from position rows WILL be removed")
  ENDIF
  CALL text(24,02,"Is this correct?  Y, N, or M for Main Menu:")
  CALL video(n)
  CALL video(ul)
  CALL accept(24,46,"A;CU","N"
   WHERE curaccept IN ("Y", "N", "M"))
  IF (curaccept="Y")
   CALL upd_clin_equa(null)
   GO TO oef_flexing
  ELSEIF (curaccept="N")
   GO TO oef_flexing
  ELSEIF (curaccept="M")
   GO TO menu
  ELSE
   GO TO menu
  ENDIF
 ENDIF
#clin_equa_file
 CALL video(n)
 CALL clear(1,1)
 CALL text(2,1,"Position Copy - Clinical Equation Copy - Load From File",w)
 CALL box(3,1,7,132)
 CALL text(4,4,"Enter the location and name of the CSV file (ccluserdir:example.csv or M for menu) :"
  )
 IF (bfilefound=0)
  CALL text(6,4,"File was not found")
 ENDIF
 CALL accept(4,88,"P(40);C")
 IF (findfile(curaccept)=1)
  SET bkeepfrompos = 1
  SET sloadfile = curaccept
  CALL load_csv(null)
  CALL upd_clin_equa_file(null)
 ELSEIF (cnvtupper(curaccept)="M")
  GO TO menu
 ELSE
  SET bfilefound = 0
  GO TO clin_equa_file
 ENDIF
#mrp_copy
 CALL choose_to_and_from(null)
 IF (dtoposition > 0.0
  AND dfromposition > 0.0)
  SET sactionprompt = build2("Copy MRP from ",trim(uar_get_code_display(dfromposition),3)," to ",trim
   (uar_get_code_display(dtoposition),3))
  CALL video(n)
  CALL clear(1,1)
  CALL text(2,1,"Position Copy - MRP",w)
  CALL box(3,1,7,132)
  CALL text(4,4,sactionprompt)
  IF (bkeepfrompos=1)
   CALL text(6,4,"The from position rows WILL NOT be removed")
  ELSE
   CALL text(6,4,"The from position rows WILL be removed")
  ENDIF
  CALL text(24,02,"Is this correct?  Y, N, or M for Main Menu:")
  CALL video(n)
  CALL video(ul)
  CALL accept(24,46,"A;CU","N"
   WHERE curaccept IN ("Y", "N", "M"))
  IF (curaccept="Y")
   CALL upd_mrp(null)
   GO TO mrp_copy
  ELSEIF (curaccept="N")
   GO TO mrp_copy
  ELSEIF (curaccept="M")
   GO TO menu
  ELSE
   GO TO menu
  ENDIF
 ENDIF
#mrp_copy_file
 CALL video(n)
 CALL clear(1,1)
 CALL text(2,1,"Position Copy - MRP - Load from File",w)
 CALL box(3,1,7,132)
 CALL text(4,4,"Enter the location and name of the CSV file (ccluserdir:example.csv or M for menu) :"
  )
 IF (bfilefound=0)
  CALL text(6,4,"File was not found")
 ENDIF
 CALL accept(4,88,"P(40);C")
 IF (findfile(curaccept)=1)
  SET bkeepfrompos = 1
  SET sloadfile = curaccept
  CALL load_csv(null)
  CALL upd_mrp_file(null)
 ELSEIF (cnvtupper(curaccept)="M")
  GO TO menu
 ELSE
  SET bfilefound = 0
  GO TO mrp_copy_file
 ENDIF
 SUBROUTINE choose_to_and_from(dummy)
   CALL video(n)
   CALL clear(1,1)
   CALL text(2,1,"Choose the source position",w)
   CALL box(3,1,5,132)
   CALL text(4,4,"Position : ")
   CALL text(7,1,"Choose the target position",w)
   CALL box(8,1,10,132)
   CALL text(9,4,"Position : ")
   CALL text(12,1,"Would you like to keep the source position rows? (Y/N):")
   CALL text(24,2,"Enter <0> for Main Menu, <HELP> is Available")
   SET accept = nochange
   SET help =
   SELECT INTO "NL:"
    c.code_value, c.display
    FROM code_value c
    WHERE c.code_set=88
    ORDER BY c.display
    WITH nocounter
   ;end select
   CALL accept(4,15,"9(11);d")
   SET help = off
   IF (curaccept=0)
    GO TO menu
   ELSE
    SET dfromposition = curaccept
    SET accept = nochange
    SET help =
    SELECT INTO "NL:"
     c.code_value, c.display
     FROM code_value c
     WHERE c.code_set=88
      AND c.code_value != dfromposition
     ORDER BY c.display
     WITH nocounter
    ;end select
    CALL accept(9,15,"9(11);d")
    SET help = off
    IF (curaccept=0)
     GO TO menu
    ELSE
     CALL clear(24,2,57)
     SET dtoposition = curaccept
     SET accept = nochange
     CALL accept(12,57,"A;CU","Y"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept > "")
      IF (curaccept="Y")
       SET bkeepfrompos = 1
      ELSE
       SET bkeepfrompos = 0
      ENDIF
     ELSE
      SET bkeepfrompost = 1
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE upd_oef_flex(dummy)
   CALL video(n)
   CALL clear(1,1)
   CALL box(3,1,8,132)
   CALL text(2,1,"Inserting rows",w)
   SELECT INTO "nl:"
    FROM accept_format_flexing a,
     order_entry_format fmt,
     order_entry_fields oef
    PLAN (a
     WHERE a.flex_type_flag=3
      AND a.flex_cd=dfromposition)
     JOIN (fmt
     WHERE fmt.oe_format_id=a.oe_format_id)
     JOIN (oef
     WHERE oef.oe_field_id=a.oe_field_id)
    HEAD REPORT
     icnt = 0
    DETAIL
     icnt = (icnt+ 1), oef_hold->qual_cnt = icnt
     IF (mod(icnt,10)=1)
      stat = alterlist(oef_hold->qual,(icnt+ 9))
     ENDIF
     IF (((oef.field_type_flag IN (0, 1, 2, 3, 5,
     7, 11, 14, 15)) OR (oef.field_type_flag=null)) )
      oef_hold->qual[icnt].default_value = a.default_value
     ELSE
      oef_hold->qual[icnt].default_value = cnvtstring(a.default_parent_entity_id)
     ENDIF
     oef_hold->qual[icnt].oe_format_id = a.oe_format_id, oef_hold->qual[icnt].oe_format_name = fmt
     .oe_format_name, oef_hold->qual[icnt].oe_field_id = a.oe_field_id,
     oef_hold->qual[icnt].oe_field_name = oef.description, oef_hold->qual[icnt].action_type_cd = a
     .action_type_cd, oef_hold->qual[icnt].flex_cd = dtoposition,
     oef_hold->qual[icnt].accept_flag = a.accept_flag, oef_hold->qual[icnt].lock_on_modify_flag = a
     .lock_on_modify_flag
    FOOT REPORT
     stat = alterlist(oef_hold->qual,icnt)
    WITH nocounter
   ;end select
   FOR (icnt = 1 TO size(oef_hold->qual,5))
     SET add_flx_request->oe_format_id = oef_hold->qual[icnt].oe_format_id
     SET add_flx_request->oe_field_id = oef_hold->qual[icnt].oe_field_id
     SET add_flx_request->action_type_cd = oef_hold->qual[icnt].action_type_cd
     SET add_flx_request->flex_type_flag = oef_hold->qual[icnt].flex_type_flag
     SET add_flx_request->flex_cd = oef_hold->qual[icnt].flex_cd
     SET add_flx_request->accept_flag = oef_hold->qual[icnt].accept_flag
     SET add_flx_request->default_value = cnvtstring(oef_hold->qual[icnt].default_value)
     SET add_flx_request->lock_on_modify_flag = oef_hold->qual[icnt].lock_on_modify_flag
     EXECUTE orm_add_oeflex  WITH replace("REQUEST","ADD_FLX_REQUEST")
   ENDFOR
   IF (bkeepfrompos=0)
    CALL text(2,1,"Removing rows",w)
    SET forcnt = 0
    FOR (forcnt = 1 TO size(oef_hold->qual,5))
      SET del_flx_request->oe_format_id = oef_hold->qual[forcnt].oe_format_id
      SET del_flx_request->oe_field_id = oef_hold->qual[forcnt].oe_field_id
      SET del_flx_request->action_type_cd = oef_hold->qual[forcnt].action_type_cd
      SET del_flx_request->flex_type_flag = oef_hold->qual[forcnt].flex_type_flag
      SET del_flx_request->flex_cd = dfromposition
      EXECUTE orm_del_oeflex  WITH replace("REQUEST","DEL_FLX_REQUEST")
    ENDFOR
   ENDIF
   CALL write_oef_flx_log(null)
   SET stat = alterlist(oef_hold->qual,0)
   CALL text(2,1,"Copy completed",w)
   CALL text(5,20," 1)  Copy OEF flexing for another position")
   CALL text(6,20," 2)  Return to main menu")
   CALL text(24,2,"Select Option (1,2):")
   CALL accept(24,23,"9;",2
    WHERE curaccept IN (1, 2))
   CALL clear(24,1)
   CASE (curaccept)
    OF 1:
     GO TO oef_flexing
    OF 2:
     GO TO menu
    ELSE
     GO TO menu
   ENDCASE
   GO TO menu
 END ;Subroutine
 SUBROUTINE upd_oef_flx_file(dummy)
   CALL video(n)
   CALL clear(1,1)
   CALL box(3,1,11,132)
   CALL text(2,1,"Inserting rows",w)
   SET iexp = 0
   SELECT INTO "nl:"
    FROM accept_format_flexing a,
     order_entry_fields oef,
     order_entry_format fmt,
     (dummyt d  WITH seq = value(iloop_cnt))
    PLAN (d
     WHERE initarray(istart,evaluate(d.seq,1,1,(istart+ ibatch_size))))
     JOIN (a
     WHERE expand(iexpandidx,istart,(istart+ (ibatch_size - 1)),a.flex_cd,file_hold->target[
      iexpandidx].src_pos)
      AND a.flex_type_flag=3)
     JOIN (oef
     WHERE oef.oe_field_id=a.oe_field_id)
     JOIN (fmt
     WHERE fmt.oe_format_id=a.oe_format_id)
    ORDER BY a.flex_cd, a.oe_format_id, a.oe_field_id,
     a.action_type_cd
    HEAD REPORT
     icnt = 0
    HEAD a.flex_cd
     pos = locateval(idx,1,icur_list_size,a.flex_cd,file_hold->target[idx].src_pos), ichangeflg = 1
    HEAD a.oe_format_id
     ichangeflg = 1
    HEAD a.oe_field_id
     ichangeflg = 1
    HEAD a.action_type_cd
     ichangeflg = 1
    DETAIL
     IF (pos > 0
      AND ichangeflg=1)
      icnt = (icnt+ 1), oef_hold->qual_cnt = icnt
      IF (mod(icnt,10)=1)
       stat = alterlist(oef_hold->qual,(icnt+ 9))
      ENDIF
      IF (((oef.field_type_flag IN (0, 1, 2, 3, 5,
      7, 11, 14, 15)) OR (oef.field_type_flag=null)) )
       oef_hold->qual[icnt].default_value = a.default_value
      ELSE
       oef_hold->qual[icnt].default_value = cnvtstring(a.default_parent_entity_id)
      ENDIF
      oef_hold->qual[icnt].oe_format_id = a.oe_format_id, oef_hold->qual[icnt].oe_format_name = fmt
      .oe_format_name, oef_hold->qual[icnt].oe_field_id = a.oe_field_id,
      oef_hold->qual[icnt].oe_field_name = oef.description, oef_hold->qual[icnt].action_type_cd = a
      .action_type_cd, oef_hold->qual[icnt].flex_type_flag = a.flex_type_flag,
      oef_hold->qual[icnt].flex_cd = file_hold->target[pos].trgt_pos, oef_hold->qual[icnt].
      accept_flag = a.accept_flag, oef_hold->qual[icnt].lock_on_modify_flag = a.lock_on_modify_flag,
      ichangeflg = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(oef_hold->qual,icnt)
    WITH nocounter
   ;end select
   FOR (icnt = 1 TO size(oef_hold->qual,5))
     IF ((oef_hold->qual[icnt].error_ind=0))
      SET add_flx_request->oe_format_id = oef_hold->qual[icnt].oe_format_id
      SET add_flx_request->oe_field_id = oef_hold->qual[icnt].oe_field_id
      SET add_flx_request->action_type_cd = oef_hold->qual[icnt].action_type_cd
      SET add_flx_request->flex_type_flag = oef_hold->qual[icnt].flex_type_flag
      SET add_flx_request->flex_cd = oef_hold->qual[icnt].flex_cd
      SET add_flx_request->accept_flag = oef_hold->qual[icnt].accept_flag
      SET add_flx_request->default_value = cnvtstring(oef_hold->qual[icnt].default_value)
      SET add_flx_request->lock_on_modify_flag = oef_hold->qual[icnt].lock_on_modify_flag
      EXECUTE orm_add_oeflex  WITH replace("REQUEST","ADD_FLX_REQUEST")
     ENDIF
   ENDFOR
   CALL write_oef_flx_log(null)
   SET stat = alterlist(oef_hold->qual,0)
   SET stat = alterlist(file_hold->target,0)
   CALL text(2,1,"Copy completed",w)
   CALL text(5,20," 1)  Return to main menu")
   CALL text(6,20," 2)  Exit")
   CALL text(24,2,"Select Option (1,2): ")
   CALL accept(24,23,"9;",2
    WHERE curaccept IN (1, 2))
   CALL clear(24,1)
   CASE (curaccept)
    OF 1:
     GO TO menu
    OF 2:
     GO TO quit
    ELSE
     GO TO quit
   ENDCASE
 END ;Subroutine
 SUBROUTINE write_oef_flx_log(dummy)
   SELECT INTO value(slogfile)
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     stemp = build2("OEF Flexing was copied on ",format(cnvtdatetime(curdate,curtime3),
       "@SHORTDATETIME")), row + 3, col 0,
     stemp, row + 2, col 0,
     "Rows added:", row + 1
    WITH nocounter, append, pcformat('"',",",1),
     format = stream, maxcol = 10000
   ;end select
   SET stat = alterlist(logrec->collist,7)
   SET logrec->collist[1].header_text = "Position"
   SET logrec->collist[2].header_text = "OE Format Id"
   SET logrec->collist[3].header_text = "OE Format"
   SET logrec->collist[4].header_text = "OE Field Id"
   SET logrec->collist[5].header_text = "OE Field"
   SET logrec->collist[6].header_text = "Action Type"
   SET logrec->collist[7].header_text = "Default Value"
   SET irowcnt = 0
   FOR (icnt = 1 TO size(oef_hold->qual,5))
     IF ((oef_hold->qual[icnt].error_ind != 1))
      SET irowcnt = (irowcnt+ 1)
      IF (mod(irowcnt,10)=1)
       SET stat = alterlist(logrec->rowlist,(irowcnt+ 9))
      ENDIF
      SET stat = alterlist(logrec->rowlist[irowcnt].celllist,7)
      SET logrec->rowlist[irowcnt].celllist[1].string_value = uar_get_code_display(oef_hold->qual[
       icnt].flex_cd)
      SET logrec->rowlist[irowcnt].celllist[2].double_value = oef_hold->qual[icnt].oe_format_id
      SET logrec->rowlist[irowcnt].celllist[3].string_value = oef_hold->qual[icnt].oe_format_name
      SET logrec->rowlist[irowcnt].celllist[4].double_value = oef_hold->qual[icnt].oe_field_id
      SET logrec->rowlist[irowcnt].celllist[5].string_value = oef_hold->qual[icnt].oe_field_name
      SET logrec->rowlist[irowcnt].celllist[6].string_value = uar_get_code_display(oef_hold->qual[
       icnt].action_type_cd)
      SET logrec->rowlist[irowcnt].celllist[7].string_value = cnvtstring(oef_hold->qual[icnt].
       default_value)
     ENDIF
   ENDFOR
   SET stat = alterlist(logrec->rowlist,irowcnt)
   CALL write_log(value(slogfile))
   SELECT INTO value(slogfile)
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     row + 2, col 0, "Rows that could not be written because of conflicts",
     row + 1
    WITH nocounter, append, pcformat('"',",",1),
     format = stream, maxcol = 10000
   ;end select
   SET stat = alterlist(logrec->collist,7)
   SET logrec->collist[1].header_text = "Source Position(s)"
   SET logrec->collist[2].header_text = "Target Position"
   SET logrec->collist[3].header_text = "OE Format Id"
   SET logrec->collist[4].header_text = "OE Format"
   SET logrec->collist[5].header_text = "OE Field Id"
   SET logrec->collist[6].header_text = "OE Field"
   SET logrec->collist[7].header_text = "Action Type"
   SET irowcnt = 0
   FOR (icnt = 1 TO size(oef_hold->qual,5))
     IF ((oef_hold->qual[icnt].error_ind=1))
      SET ipos = locateval(idx,1,size(file_hold->target,5),oef_hold->qual[icnt].flex_cd,file_hold->
       target[idx].trgt_pos)
      IF (ipos > 0)
       SET irowcnt = (irowcnt+ 1)
       IF (mod(irowcnt,10)=1)
        SET stat = alterlist(logrec->rowlist,(irowcnt+ 9))
       ENDIF
       SET stat = alterlist(logrec->rowlist[irowcnt].celllist,7)
       SET logrec->rowlist[irowcnt].celllist[1].string_value = uar_get_code_display(file_hold->
        target[ipos].src_pos)
       SET logrec->rowlist[irowcnt].celllist[2].string_value = uar_get_code_display(oef_hold->qual[
        icnt].flex_cd)
       SET logrec->rowlist[irowcnt].celllist[3].double_value = oef_hold->qual[icnt].oe_format_id
       SET logrec->rowlist[irowcnt].celllist[4].double_value = oef_hold->qual[icnt].oe_format_name
       SET logrec->rowlist[irowcnt].celllist[5].double_value = oef_hold->qual[icnt].oe_field_id
       SET logrec->rowlist[irowcnt].celllist[6].double_value = oef_hold->qual[icnt].oe_field_name
       SET logrec->rowlist[irowcnt].celllist[7].string_value = uar_get_code_display(oef_hold->qual[
        icnt].action_type_cd)
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(logrec->rowlist,irowcnt)
   CALL write_log(value(slogfile))
   IF (bkeepfrompos=0)
    SELECT INTO value(slogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      row + 2, col 0, "Source Position OEF Flexing rows that were removed",
      row + 1
     WITH nocounter, append, pcformat('"',",",1),
      format = stream, maxcol = 10000
    ;end select
    SET stat = alterlist(logrec->collist,7)
    SET logrec->collist[1].header_text = "Position"
    SET logrec->collist[2].header_text = "OE Format Id"
    SET logrec->collist[3].header_text = "OE Format"
    SET logrec->collist[4].header_text = "OE Field Id"
    SET logrec->collist[5].header_text = "OE Field"
    SET logrec->collist[6].header_text = "Action Type"
    SET logrec->collist[7].header_text = "Default Value"
    SET irowcnt = 0
    FOR (icnt = 1 TO size(oef_hold->qual,5))
      IF ((oef_hold->qual[icnt].error_ind != 1))
       SET irowcnt = (irowcnt+ 1)
       IF (mod(irowcnt,10)=1)
        SET stat = alterlist(logrec->rowlist,(irowcnt+ 9))
       ENDIF
       SET stat = alterlist(logrec->rowlist[irowcnt].celllist,7)
       SET logrec->rowlist[irowcnt].celllist[1].string_value = uar_get_code_display(dfromposition)
       SET logrec->rowlist[irowcnt].celllist[2].double_value = oef_hold->qual[icnt].oe_format_id
       SET logrec->rowlist[irowcnt].celllist[3].double_value = oef_hold->qual[icnt].oe_format_name
       SET logrec->rowlist[irowcnt].celllist[4].double_value = oef_hold->qual[icnt].oe_field_id
       SET logrec->rowlist[irowcnt].celllist[5].double_value = oef_hold->qual[icnt].oe_field_name
       SET logrec->rowlist[irowcnt].celllist[6].string_value = uar_get_code_display(oef_hold->qual[
        icnt].action_type_cd)
       SET logrec->rowlist[irowcnt].celllist[7].string_value = cnvtstring(oef_hold->qual[icnt].
        default_value)
      ENDIF
    ENDFOR
    SET stat = alterlist(logrec->rowlist,irowcnt)
    CALL write_log(value(slogfile))
   ELSE
    SELECT INTO value(slogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      row + 2, col 0, "Source Position OEF Flexing rows were not removed",
      row + 1
     WITH nocounter, append, pcformat('"',",",1),
      format = stream, maxcol = 10000
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE upd_clin_equa(dummy)
   CALL video(n)
   CALL clear(1,1)
   CALL box(3,1,11,132)
   CALL text(2,1,"Inserting rows",w)
   SELECT INTO "nl:"
    FROM dcp_equa_position d,
     dcp_equation e
    PLAN (d
     WHERE d.position_cd=dfromposition
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM dcp_equa_position d1
      WHERE d1.dcp_equation_id=d.dcp_equation_id
       AND d1.position_cd=dtoposition))))
     JOIN (e
     WHERE e.dcp_equation_id=d.dcp_equation_id)
    ORDER BY d.dcp_equation_id
    HEAD REPORT
     icnt = 0
    HEAD d.dcp_equation_id
     icnt2 = 0, icnt = (icnt+ 1), equa_hold->qual_cnt = icnt
     IF (mod(icnt,10)=1)
      stat = alterlist(equa_hold->qual,(icnt+ 9))
     ENDIF
     equa_hold->qual[icnt].dcp_equation_id = d.dcp_equation_id, equa_hold->qual[icnt].dcp_equa_name
      = e.description
    DETAIL
     icnt2 = (icnt2+ 1)
     IF (mod(icnt2,10)=1)
      stat = alterlist(equa_hold->qual[icnt].posqual,(icnt2+ 9))
     ENDIF
     equa_hold->qual[icnt].posqual[icnt2].position_cd = d.position_cd
    FOOT  d.dcp_equation_id
     stat = alterlist(equa_hold->qual[icnt].posqual,icnt2)
    FOOT REPORT
     stat = alterlist(equa_hold->qual,icnt)
    WITH nocounter
   ;end select
   IF (size(equa_hold->qual,5) > 0)
    INSERT  FROM dcp_equa_position d,
      (dummyt d1  WITH seq = value(size(equa_hold->qual,5)))
     SET d1.seq = 1, d.dcp_equation_id = equa_hold->qual[d1.seq].dcp_equation_id, d.position_cd =
      dtoposition,
      d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id = 10705, d.updt_task = 10705,
      d.updt_applctx = 0, d.updt_cnt = 0
     PLAN (d1)
      JOIN (d)
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   IF (bkeepfrompos=0
    AND size(equa_hold->qual,5) > 0)
    CALL text(2,1,"Removing rows",w)
    DELETE  FROM dcp_equa_position d,
      (dummyt d1  WITH seq = value(size(equa_hold->qual,5)))
     SET d1.seq = 1
     PLAN (d
      WHERE (d.dcp_equation_id=equa_hold->qual[d1.seq].dcp_equation_id)
       AND d.position_cd=dfromposition)
      JOIN (d1
      WHERE (equa_hold->qual[d1.seq].dcp_equation_id > 0.0))
     WITH nocounter
    ;end delete
   ENDIF
   COMMIT
   CALL write_clin_equa_log(null)
   CALL text(2,1,"Copy completed",w)
   CALL text(5,20," 1)  Copy clinical equations for another position")
   CALL text(6,20," 2)  Return to main menu")
   CALL text(24,2,"Select Option (1,2): ")
   CALL accept(24,23,"9;",2
    WHERE curaccept IN (1, 2))
   CALL clear(24,1)
   CASE (curaccept)
    OF 1:
     GO TO clin_equa
    OF 2:
     GO TO menu
    ELSE
     GO TO menu
   ENDCASE
   GO TO menu
 END ;Subroutine
 SUBROUTINE upd_clin_equa_file(dummy)
   CALL video(n)
   CALL clear(1,1)
   CALL box(3,1,11,132)
   CALL text(2,1,"Inserting rows",w)
   SET iexp = 0
   IF (size(file_hold->target,5) > 0)
    SELECT INTO "nl:"
     FROM dcp_equa_position p,
      dcp_equation e,
      (dummyt d  WITH seq = value(iloop_cnt))
     PLAN (d
      WHERE initarray(istart,evaluate(d.seq,1,1,(istart+ ibatch_size))))
      JOIN (p
      WHERE expand(iexpandidx,istart,(istart+ (ibatch_size - 1)),p.position_cd,file_hold->target[
       iexpandidx].src_pos))
      JOIN (e
      WHERE e.dcp_equation_id=p.dcp_equation_id)
     ORDER BY p.position_cd, p.dcp_equation_id
     HEAD REPORT
      icnt = 0
     HEAD p.position_cd
      pos = locateval(idx,1,icur_list_size,p.position_cd,file_hold->target[idx].src_pos)
     HEAD p.dcp_equation_id
      IF (pos > 0)
       icnt = (icnt+ 1), equa_hold->qual_cnt = icnt
       IF (mod(icnt,10)=1)
        stat = alterlist(equa_hold->qual,(icnt+ 9))
       ENDIF
       equa_hold->qual[icnt].dcp_equation_id = p.dcp_equation_id, equa_hold->qual[icnt].dcp_equa_name
        = e.description, equa_hold->qual[icnt].trgt_position = file_hold->target[pos].trgt_pos,
       stat = alterlist(equa_hold->qual[icnt].posqual,1), equa_hold->qual[icnt].posqual[1].
       position_cd = file_hold->target[pos].src_pos
      ENDIF
     FOOT REPORT
      stat = alterlist(equa_hold->qual,icnt)
     WITH nocounter
    ;end select
    FOR (icnt = 1 TO size(equa_hold->qual,5))
     SELECT INTO "nl:"
      FROM dcp_equa_position d
      WHERE (d.dcp_equation_id=equa_hold->qual[icnt].dcp_equation_id)
       AND (d.position_cd=equa_hold->qual[icnt].trgt_position)
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM dcp_equa_position d
       SET d.dcp_equation_id = equa_hold->qual[icnt].dcp_equation_id, d.position_cd = equa_hold->
        qual[icnt].trgt_position, d.updt_dt_tm = cnvtdatetime(curdate,curtime),
        d.updt_id = 10705, d.updt_task = 10705, d.updt_applctx = 0,
        d.updt_cnt = 0
       WITH nocounter
      ;end insert
      COMMIT
     ELSE
      SET equa_hold->qual[icnt].dup_flag = 1
     ENDIF
    ENDFOR
   ENDIF
   CALL write_clin_equa_log(null)
   CALL text(2,1,"Copy completed",w)
   CALL text(5,20," 1)  Return to main menu")
   CALL text(6,20," 2)  Exit")
   CALL text(24,2,"Select Option (1,2): ")
   CALL accept(24,23,"9;",2
    WHERE curaccept IN (1, 2))
   CALL clear(24,1)
   CASE (curaccept)
    OF 1:
     GO TO menu
    OF 2:
     GO TO quit
    ELSE
     GO TO quit
   ENDCASE
 END ;Subroutine
 SUBROUTINE write_clin_equa_log(dummy)
   SELECT INTO value(slogfile)
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     stemp = build2("Clinical Equations were copied on ",format(cnvtdatetime(curdate,curtime3),
       "@SHORTDATETIME")), row + 3, col 0,
     stemp, row + 2, col 0,
     "Rows added:", row + 1
    WITH nocounter, append, pcformat('"',",",1),
     format = stream, maxcol = 10000
   ;end select
   SET stat = alterlist(logrec->collist,3)
   SET logrec->collist[1].header_text = "Position"
   SET logrec->collist[2].header_text = "DCP Equation Id"
   SET logrec->collist[3].header_text = "DCP Equation"
   SET irowcnt = 0
   FOR (icnt = 1 TO size(equa_hold->qual,5))
     IF ((equa_hold->qual[icnt].dup_flag=0))
      SET irowcnt = (irowcnt+ 1)
      IF (mod(irowcnt,10)=1)
       SET stat = alterlist(logrec->rowlist,(irowcnt+ 9))
      ENDIF
      SET stat = alterlist(logrec->rowlist[irowcnt].celllist,3)
      SET logrec->rowlist[irowcnt].celllist[1].string_value = uar_get_code_display(equa_hold->qual[
       icnt].trgt_position)
      SET logrec->rowlist[irowcnt].celllist[2].double_value = equa_hold->qual[icnt].dcp_equation_id
      SET logrec->rowlist[irowcnt].celllist[3].string_value = equa_hold->qual[icnt].dcp_equa_name
     ENDIF
   ENDFOR
   SET stat = alterlist(logrec->rowlist,irowcnt)
   CALL write_log(value(slogfile))
   IF (bkeepfrompos=0)
    SELECT INTO value(slogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      row + 2, col 0, "Source Position Clinical Equation rows that were removed",
      row + 1
     WITH nocounter, append, pcformat('"',",",1),
      format = stream, maxcol = 10000
    ;end select
    SET stat = alterlist(logrec->collist,3)
    SET logrec->collist[1].header_text = "Position"
    SET logrec->collist[2].header_text = "DCP Equation Id"
    SET logrec->collist[3].header_text = "DCP Equation"
    SET irowcnt = 0
    FOR (icnt = 1 TO size(equa_hold->qual,5))
      FOR (icnt2 = 1 TO size(equa_hold->qual[icnt].posqual,5))
        SET irowcnt = (irowcnt+ 1)
        IF (mod(irowcnt,10)=1)
         SET stat = alterlist(logrec->rowlist,(irowcnt+ 9))
        ENDIF
        SET stat = alterlist(logrec->rowlist[irowcnt].celllist,3)
        SET logrec->rowlist[irowcnt].celllist[1].string_value = uar_get_code_display(equa_hold->qual[
         icnt].posqual[icnt2].position_cd)
        SET logrec->rowlist[irowcnt].celllist[2].double_value = equa_hold->qual[icnt].dcp_equation_id
        SET logrec->rowlist[irowcnt].celllist[3].string_value = equa_hold->qual[icnt].dcp_equa_name
      ENDFOR
    ENDFOR
    SET stat = alterlist(logrec->rowlist,irowcnt)
    CALL write_log(value(slogfile))
   ELSE
    SELECT INTO value(slogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      row + 2, col 0, "Source Position Clinical Equation rows were not removed",
      row + 1
     WITH nocounter, append, pcformat('"',",",1),
      format = stream, maxcol = 10000
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE upd_mrp(dummy)
   CALL video(n)
   CALL clear(1,1)
   CALL box(3,1,11,132)
   CALL text(2,1,"Inserting rows",w)
   SELECT INTO "nl"
    FROM sect_position_reltn spr,
     chart_format cf,
     chart_section cs
    PLAN (spr
     WHERE spr.position_cd=dfromposition
      AND spr.active_ind=1)
     JOIN (cf
     WHERE cf.chart_format_id=spr.chart_format_id)
     JOIN (cs
     WHERE cs.chart_section_id=spr.chart_section_id)
    ORDER BY spr.chart_format_id, spr.chart_section_id, spr.position_cd
    HEAD REPORT
     icnt = 0
    HEAD spr.chart_section_id
     icnt2 = 0, icnt = (icnt+ 1)
     IF (mod(icnt,10)=1)
      stat = alterlist(mrp_hold->qual,(icnt+ 9))
     ENDIF
     mrp_hold->qual[icnt].chart_section_id = spr.chart_section_id, mrp_hold->qual[icnt].
     chart_section_name = cs.chart_section_desc, mrp_hold->qual[icnt].chart_format_id = spr
     .chart_format_id,
     mrp_hold->qual[icnt].chart_format_name = cf.chart_format_desc, mrp_hold->qual[icnt].position_cnt
      = 1, stat = alterlist(mrp_hold->qual[icnt].position_qual,1),
     mrp_hold->qual[icnt].position_qual[1].organization_id = spr.organization_id, mrp_hold->qual[icnt
     ].position_qual[1].position_cd = dtoposition
    FOOT REPORT
     stat = alterlist(mrp_hold->qual,icnt), mrp_hold->qual_cnt = icnt
    WITH nocounter
   ;end select
   IF (size(mrp_hold->qual,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(mrp_hold->qual,5))),
      sect_position_reltn s
     PLAN (d
      WHERE (mrp_hold->qual[d.seq].chart_format_id > 0.0))
      JOIN (s
      WHERE (s.chart_format_id=mrp_hold->qual[d.seq].chart_format_id)
       AND (s.chart_section_id=mrp_hold->qual[d.seq].chart_section_id)
       AND (s.position_cd=mrp_hold->qual[d.seq].position_qual[1].position_cd)
       AND (s.organization_id=mrp_hold->qual[d.seq].position_qual[1].organization_id)
       AND s.active_ind=1)
     DETAIL
      pos = locateval(idx,1,mrp_hold->qual_cnt,s.chart_format_id,mrp_hold->qual[idx].chart_format_id,
       s.chart_section_id,mrp_hold->qual[idx].chart_section_id)
      IF (pos > 0)
       mrp_hold->qual[pos].position_qual[1].dup_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    INSERT  FROM (dummyt d  WITH seq = value(size(mrp_hold->qual,5))),
      sect_position_reltn s
     SET s.seq = 1, s.position_cd = mrp_hold->qual[d.seq].position_qual[1].position_cd, s
      .chart_format_id = mrp_hold->qual[d.seq].chart_format_id,
      s.chart_section_id = mrp_hold->qual[d.seq].chart_section_id, s.organization_id = mrp_hold->
      qual[d.seq].position_qual[1].organization_id, s.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3),
      s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), s.updt_id = reqinfo->updt_id,
      s.updt_cnt = 0, s.updt_applctx = reqinfo->updt_applctx, s.updt_task = reqinfo->updt_task,
      s.active_ind = 1, s.active_status_cd = reqdata->active_status_cd, s.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      s.active_status_prsnl_id = reqinfo->updt_id
     PLAN (d
      WHERE (mrp_hold->qual[d.seq].position_qual[1].dup_ind != 1))
      JOIN (s)
     WITH nocounter
    ;end insert
   ENDIF
   IF (bkeepfrompos=0
    AND size(mrp_hold->qual,5) > 0)
    CALL text(2,1,"Removing rows",w)
    DELETE  FROM (dummyt d  WITH seq = value(size(mrp_hold->qual,5))),
      sect_position_reltn s
     PLAN (d
      WHERE (mrp_hold->qual[d.seq].chart_format_id > 0.0))
      JOIN (s
      WHERE (s.chart_format_id=mrp_hold->qual[d.seq].chart_format_id)
       AND (s.chart_section_id=mrp_hold->qual[d.seq].chart_section_id)
       AND (s.organization_id=mrp_hold->qual[d.seq].position_qual[1].organization_id)
       AND d.position_cd=dfromposition)
     WITH nocounter
    ;end delete
   ENDIF
   CALL write_mrp_log(null)
   CALL clear(4,1)
   CALL text(2,1,"Copy completed",w)
   CALL text(5,20," 1)  Copy MRP for another position")
   CALL text(6,20," 2)  Return to main menu")
   CALL text(24,2,"Select Option (1,2): ")
   CALL accept(24,23,"9;",2
    WHERE curaccept IN (1, 2))
   CALL clear(24,1)
   CASE (curaccept)
    OF 1:
     GO TO mrp_copy
    OF 2:
     GO TO menu
    ELSE
     GO TO menu
   ENDCASE
   GO TO menu
   GO TO quit
 END ;Subroutine
 SUBROUTINE upd_mrp_file(dummy)
   SELECT INTO "nl"
    FROM sect_position_reltn spr,
     chart_format cf,
     chart_section cs,
     (dummyt d  WITH seq = value(iloop_cnt))
    PLAN (d
     WHERE initarray(istart,evaluate(d.seq,1,1,(istart+ ibatch_size))))
     JOIN (spr
     WHERE expand(iexpandidx,istart,(istart+ (ibatch_size - 1)),spr.position_cd,file_hold->target[
      iexpandidx].src_pos)
      AND spr.active_ind=1)
     JOIN (cf
     WHERE cf.chart_format_id=spr.chart_format_id)
     JOIN (cs
     WHERE cs.chart_section_id=spr.chart_section_id)
    ORDER BY spr.chart_format_id, spr.chart_section_id, spr.position_cd
    HEAD REPORT
     icnt = 0
    HEAD spr.chart_section_id
     icnt2 = 0, icnt = (icnt+ 1)
     IF (mod(icnt,10)=1)
      stat = alterlist(mrp_hold->qual,(icnt+ 9))
     ENDIF
     mrp_hold->qual[icnt].chart_section_id = spr.chart_section_id, mrp_hold->qual[icnt].
     chart_section_name = cs.chart_section_desc, mrp_hold->qual[icnt].chart_format_id = spr
     .chart_format_id,
     mrp_hold->qual[icnt].chart_format_name = cf.chart_format_desc
    HEAD spr.position_cd
     pos = locateval(idx,1,icur_list_size,spr.position_cd,file_hold->target[idx].src_pos)
     IF (pos > 0)
      IF (icnt2=0)
       icnt2 = (icnt2+ 1), mrp_hold->qual[icnt].position_cnt = icnt2, stat = alterlist(mrp_hold->
        qual[icnt].position_qual,icnt2),
       mrp_hold->qual[icnt].position_qual[icnt2].organization_id = spr.organization_id, mrp_hold->
       qual[icnt].position_qual[icnt2].position_cd = file_hold->target[pos].trgt_pos
      ELSE
       ipos2 = locateval(idx,1,size(mrp_hold->qual[icnt].position_qual,5),file_hold->target[pos].
        trgt_pos,mrp_hold->qual[icnt].position_qual[idx].position_cd)
       IF (ipos2=0)
        icnt2 = (icnt2+ 1), mrp_hold->qual[icnt].position_cnt = icnt2, stat = alterlist(mrp_hold->
         qual[icnt].position_qual,icnt2),
        mrp_hold->qual[icnt].position_qual[icnt2].organization_id = spr.organization_id, mrp_hold->
        qual[icnt].position_qual[icnt2].position_cd = file_hold->target[pos].trgt_pos
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(mrp_hold->qual,icnt)
    WITH nocounter
   ;end select
   IF (size(mrp_hold->qual,5) > 0)
    FOR (icnt = 1 TO size(mrp_hold->qual,5))
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(size(mrp_hold->qual[icnt].position_qual,5))),
        sect_position_reltn s
       PLAN (d
        WHERE (mrp_hold->qual[icnt].position_qual[d.seq].position_cd > 0.0))
        JOIN (s
        WHERE (s.chart_format_id=mrp_hold->qual[icnt].chart_format_id)
         AND (s.chart_section_id=mrp_hold->qual[icnt].chart_section_id)
         AND expand(iexpandidx,istart,(istart+ (ibatch_size - 1)),s.position_cd,mrp_hold->qual[icnt].
         position_qual[d.seq].position_cd,
         s.organization_id,mrp_hold->qual[icnt].position_qual[d.seq].organization_id)
         AND s.active_ind=1)
       DETAIL
        pos = locateval(idx,1,mrp_hold->qual[icnt].position_cnt,s.position_cd,mrp_hold->qual[icnt].
         position_qual[idx].position_cd,
         s.organization_id,mrp_hold->qual[icnt].position_qual[idx].organization_id)
        IF (pos > 0)
         mrp_hold->qual[icnt].position_qual[pos].dup_ind = 1
        ENDIF
       WITH nocounter
      ;end select
    ENDFOR
    FOR (icnt = 1 TO size(mrp_hold->qual,5))
      INSERT  FROM (dummyt d  WITH seq = value(size(mrp_hold->qual[icnt].position_qual,5))),
        sect_position_reltn s
       SET s.seq = 1, s.position_cd = mrp_hold->qual[icnt].position_qual[d.seq].position_cd, s
        .chart_format_id = mrp_hold->qual[icnt].chart_format_id,
        s.chart_section_id = mrp_hold->qual[icnt].chart_section_id, s.organization_id = mrp_hold->
        qual[icnt].position_qual[d.seq].organization_id, s.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3),
        s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), s.updt_id = reqinfo->updt_id,
        s.updt_cnt = 0, s.updt_applctx = reqinfo->updt_applctx, s.updt_task = reqinfo->updt_task,
        s.active_ind = 1, s.active_status_cd = reqdata->active_status_cd, s.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        s.active_status_prsnl_id = reqinfo->updt_id
       PLAN (d
        WHERE (mrp_hold->qual[icnt].position_qual[d.seq].dup_ind != 1))
        JOIN (s)
       WITH nocounter
      ;end insert
    ENDFOR
   ENDIF
   CALL write_mrp_log(null)
   CALL clear(4,1)
   CALL text(2,1,"Copy completed",w)
   CALL text(5,20," 1)  Return to main menu")
   CALL text(6,20," 2)  Exit")
   CALL text(24,2,"Select Option (1,2): ")
   CALL accept(24,23,"9;",2
    WHERE curaccept IN (1, 2))
   CALL clear(24,1)
   CASE (curaccept)
    OF 1:
     GO TO menu
    OF 2:
     GO TO quit
    ELSE
     GO TO quit
   ENDCASE
   GO TO menu
 END ;Subroutine
 SUBROUTINE write_mrp_log(dummy)
   SELECT INTO value(slogfile)
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     stemp = build2("MRP sections were copied on ",format(cnvtdatetime(curdate,curtime3),
       "@SHORTDATETIME")), row + 3, col 0,
     stemp, row + 2, col 0,
     "Rows added:", row + 1
    WITH nocounter, append, pcformat('"',",",1),
     format = stream, maxcol = 10000
   ;end select
   SET stat = alterlist(logrec->collist,5)
   SET logrec->collist[1].header_text = "Position"
   SET logrec->collist[2].header_text = "Chart Format Id"
   SET logrec->collist[3].header_text = "Chart Format Desc"
   SET logrec->collist[4].header_text = "Chart Section Id"
   SET logrec->collist[5].header_text = "Chart Section Desc"
   SET irowcnt = 0
   FOR (icnt = 1 TO value(size(mrp_hold->qual,5)))
     FOR (icnt2 = 1 TO value(size(mrp_hold->qual[icnt].position_qual,5)))
       IF ((mrp_hold->qual[icnt].position_qual[icnt2].dup_ind=0))
        SET irowcnt = (irowcnt+ 1)
        IF (mod(irowcnt,10)=1)
         SET stat = alterlist(logrec->rowlist,(irowcnt+ 9))
        ENDIF
        SET stat = alterlist(logrec->rowlist[irowcnt].celllist,5)
        SET logrec->rowlist[irowcnt].celllist[1].string_value = uar_get_code_display(mrp_hold->qual[
         icnt].position_qual[icnt2].position_cd)
        SET logrec->rowlist[irowcnt].celllist[2].double_value = mrp_hold->qual[icnt].chart_format_id
        SET logrec->rowlist[irowcnt].celllist[3].string_value = mrp_hold->qual[icnt].
        chart_format_name
        SET logrec->rowlist[irowcnt].celllist[4].double_value = mrp_hold->qual[icnt].chart_section_id
        SET logrec->rowlist[irowcnt].celllist[5].string_value = mrp_hold->qual[icnt].
        chart_section_name
       ENDIF
     ENDFOR
   ENDFOR
   SET stat = alterlist(logrec->rowlist,irowcnt)
   CALL write_log(value(slogfile))
   IF (bkeepfrompos=0)
    SELECT INTO value(slogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      row + 2, col 0, "Source Position MRP sections that were removed",
      row + 1
     WITH nocounter, append, pcformat('"',",",1),
      format = stream, maxcol = 10000
    ;end select
    SET stat = alterlist(logrec->collist,3)
    SET logrec->collist[1].header_text = "Position"
    SET logrec->collist[2].header_text = "Chart Format Id"
    SET logrec->collist[3].header_text = "Chart Section Id"
    SET irowcnt = 0
    FOR (icnt = 1 TO size(mrp_hold->qual,5))
      SET irowcnt = (irowcnt+ 1)
      IF (mod(irowcnt,10)=1)
       SET stat = alterlist(logrec->rowlist,(irowcnt+ 9))
      ENDIF
      SET stat = alterlist(logrec->rowlist[irowcnt].celllist,5)
      SET logrec->rowlist[irowcnt].celllist[1].string_value = uar_get_code_display(dfromposition)
      SET logrec->rowlist[irowcnt].celllist[2].double_value = mrp_hold->qual[icnt].chart_format_id
      SET logrec->rowlist[irowcnt].celllist[3].string_value = mrp_hold->qual[icnt].chart_format_name
      SET logrec->rowlist[irowcnt].celllist[4].double_value = mrp_hold->qual[icnt].chart_section_id
      SET logrec->rowlist[irowcnt].celllist[5].string_value = mrp_hold->qual[icnt].chart_section_name
    ENDFOR
    SET stat = alterlist(logrec->rowlist,irowcnt)
    CALL write_log(value(slogfile))
   ELSE
    SELECT INTO value(slogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      row + 2, col 0, "Source Position Clinical Equation rows were not removed",
      row + 1
     WITH nocounter, append, pcformat('"',",",1),
      format = stream, maxcol = 10000
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE load_csv(dummy)
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc sloadfile
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    target = trim(substring(1,(findstring(",",r.line,1,0) - 1),r.line),3), source = trim(substring((
      findstring(",",r.line,1,0)+ 1),size(r.line,1),r.line),3)
    FROM rtlt r
    HEAD REPORT
     trgtcnt = - (1), srccnt = 0
    DETAIL
     IF (textlen(trim(target)) > 0)
      trgtcnt = (trgtcnt+ 1)
      IF (trgtcnt > 0)
       file_hold->trgt_cnt = trgtcnt
       IF (mod(trgtcnt,10)=1)
        stat = alterlist(file_hold->target,(trgtcnt+ 9))
       ENDIF
       file_hold->target[trgtcnt].trgt_pos = cnvtreal(target), file_hold->target[trgtcnt].src_pos =
       cnvtreal(source)
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(file_hold->target,trgtcnt)
    WITH nocounter
   ;end select
   SET icur_list_size = size(file_hold->target,5)
   SET iloop_cnt = ceil((cnvtreal(icur_list_size)/ ibatch_size))
   SET inew_list_size = (iloop_cnt * ibatch_size)
   SET stat = alterlist(file_hold->target,inew_list_size)
   FOR (ifor_idx = (icur_list_size+ 1) TO inew_list_size)
    SET file_hold->target[ifor_idx].trgt_pos = file_hold->target[icur_list_size].trgt_pos
    SET file_hold->target[ifor_idx].src_pos = file_hold->target[icur_list_size].src_pos
   ENDFOR
   SET istart = 1
   SET iexpandidx = 0
 END ;Subroutine
#quit
END GO

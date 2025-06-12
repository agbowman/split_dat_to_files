CREATE PROGRAM dm_arc_check:dba
 PROMPT
  "Enter Person_ID: " = 0,
  "Enter DB Link: " = " "
 IF (((( $1=0)) OR (( $2=" "))) )
  CALL echo("*** Invalid Input ***")
  GO TO exit_program
 ENDIF
 RECORD request(
   1 archive_entity_name = vc
   1 archive_entity_id = f8
   1 child_env_id = f8
 )
 SET request->archive_entity_name = "PERSON"
 SET request->archive_entity_id =  $1
 SET v_post_link_name =  $2
 SET v_pre_link_name = ""
 RECORD reply(
   1 tabs[*]
     2 table_name = vc
     2 arc_num_rows = i4
     2 rest_num_rows = i4
     2 arc_cnt_str = vc
     2 rest_cnt_str = vc
     2 found_ind = i2
 )
 RECORD ap(
   1 tabs[*]
     2 parent_table = vc
     2 parent_table_db = vc
     2 parent_column = vc
     2 child_table = vc
     2 child_table_db = vc
     2 child_column = vc
     2 child_where = vc
     2 from_str = vc
     2 from_str_db = vc
     2 where_str = vc
     2 where_str_db = vc
     2 select_str = vc
     2 select_str_db = vc
     2 found_ind = i2
     2 exclude_ind = i2
 )
 RECORD curtab(
   1 tab[*]
     2 parent_table = vc
     2 parent_table_db = vc
     2 parent_column = vc
     2 child_table = vc
     2 child_table_db = vc
     2 child_column = vc
     2 child_where = vc
     2 from_str = vc
     2 from_str_db = vc
     2 where_str = vc
     2 where_str_db = vc
     2 select_str = vc
     2 select_str_db = vc
 )
 DECLARE binsearch(i_key=vc) = i4
 DECLARE req_search(i_table_name=vc) = i2
 DECLARE v_found_ndx = i4 WITH noconstant(0)
 DECLARE v_end_paren = vc
 DECLARE v_reply_cnt = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "nl:"
  dac.parent_table, dac.parent_column, dac.child_table,
  dac.child_column, dac.exclude_ind
  FROM dm_arc_constraints dac
  WHERE  EXISTS (
  (SELECT
   "x"
   FROM dm2_user_tables
   WHERE table_name=dac.child_table))
  ORDER BY dac.child_table
  HEAD REPORT
   row_cnt = 0
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1)
    stat = alterlist(ap->tabs,(row_cnt+ 49))
   ENDIF
   ap->tabs[row_cnt].parent_table = trim(dac.parent_table,3), ap->tabs[row_cnt].parent_column = trim(
    dac.parent_column,3), ap->tabs[row_cnt].child_table = trim(dac.child_table,3),
   ap->tabs[row_cnt].child_column = trim(dac.child_column,3), ap->tabs[row_cnt].exclude_ind = dac
   .exclude_ind
   IF (dac.exclude_ind=1)
    ap->tabs[row_cnt].child_table_db = ap->tabs[row_cnt].child_table
   ELSE
    ap->tabs[row_cnt].child_table_db = build(":pre_link:",dac.child_table,":post_link:")
   ENDIF
   IF (trim(dac.child_where,3)="")
    ap->tabs[row_cnt].child_where = " "
   ELSE
    ap->tabs[row_cnt].child_where = trim(dac.child_where,3)
   ENDIF
  FOOT REPORT
   stat = alterlist(ap->tabs,row_cnt)
  WITH nocounter
 ;end select
 FOR (ap_ndx = 1 TO size(ap->tabs,5))
  SET v_found_ndx = binsearch(ap->tabs[ap_ndx].parent_table)
  IF ((ap->tabs[v_found_ndx].exclude_ind=1))
   SET ap->tabs[ap_ndx].parent_table_db = ap->tabs[ap_ndx].parent_table
  ELSE
   SET ap->tabs[ap_ndx].parent_table_db = build(":pre_link:",ap->tabs[ap_ndx].parent_table,
    ":post_link:")
  ENDIF
 ENDFOR
 FOR (t_ndx = 1 TO size(ap->tabs,5))
   SET v_reply_cnt = (v_reply_cnt+ 1)
   IF (mod(v_reply_cnt,30)=1)
    SET stat = alterlist(reply->tabs,(v_reply_cnt+ 29))
   ENDIF
   SET reply->tabs[v_reply_cnt].table_name = ap->tabs[t_ndx].child_table
   CALL echo(build("t_ndx=",t_ndx,".of.",size(ap->tabs,5)))
   SET stat = alterlist(curtab->tab,1)
   SET curtab->tab[1].child_table = ap->tabs[t_ndx].child_table
   SET curtab->tab[1].child_table_db = ap->tabs[t_ndx].child_table_db
   SET curtab->tab[1].child_column = ap->tabs[t_ndx].child_column
   SET curtab->tab[1].child_where = ap->tabs[t_ndx].child_where
   SET curtab->tab[1].parent_table = ap->tabs[t_ndx].parent_table
   SET curtab->tab[1].parent_table_db = ap->tabs[t_ndx].parent_table_db
   SET curtab->tab[1].parent_column = ap->tabs[t_ndx].parent_column
   SET curtab->tab[1].from_str = ap->tabs[t_ndx].child_table
   SET curtab->tab[1].from_str_db = ap->tabs[t_ndx].child_table_db
   SET curtab->tab[1].where_str = " "
   SET curtab->tab[1].where_str_db = " "
   SET cur_ndx = 1
   SET cur_count = 1
   SET v_end_paren = ""
   WHILE (cur_ndx <= cur_count)
    IF (cur_count > 10)
     SET cur_ndx = (cur_count+ 2)
    ELSE
     IF ((curtab->tab[cur_ndx].parent_table=request->archive_entity_name))
      SET ap->tabs[t_ndx].found_ind = 1
      SET ap->tabs[t_ndx].from_str = curtab->tab[cur_ndx].from_str
      SET ap->tabs[t_ndx].from_str_db = curtab->tab[cur_ndx].from_str_db
      IF (cur_ndx=1)
       SET ap->tabs[t_ndx].select_str = concat(trim(curtab->tab[cur_ndx].child_table,3)," where ",
        evaluate(curtab->tab[cur_ndx].child_where," "," ",concat(trim(curtab->tab[cur_ndx].
           child_table,3),".",trim(substring(6,10000,curtab->tab[cur_ndx].child_where),3)," and ")),
        curtab->tab[cur_ndx].child_column,"=request->archive_entity_id")
       SET ap->tabs[t_ndx].select_str_db = concat(trim(curtab->tab[cur_ndx].child_table_db,3),
        " where ",evaluate(curtab->tab[cur_ndx].child_where," "," ",concat(trim(curtab->tab[cur_ndx].
           child_table_db,3),".",trim(substring(6,10000,curtab->tab[cur_ndx].child_where),3)," and ")
         ),curtab->tab[cur_ndx].child_column,"=request->archive_entity_id")
      ELSE
       SET ap->tabs[t_ndx].select_str = concat(curtab->tab[cur_ndx].select_str," where ",evaluate(
         curtab->tab[cur_ndx].child_where," "," ",concat(trim(curtab->tab[cur_ndx].child_table,3),".",
          trim(substring(6,10000,curtab->tab[cur_ndx].child_where),3)," and ")),curtab->tab[cur_ndx].
        child_column,"=request->archive_entity_id",
        trim(v_end_paren,3))
       SET ap->tabs[t_ndx].select_str_db = concat(curtab->tab[cur_ndx].select_str_db," where ",
        evaluate(curtab->tab[cur_ndx].child_where," "," ",concat(trim(curtab->tab[cur_ndx].
           child_table_db,3),".",trim(substring(6,10000,curtab->tab[cur_ndx].child_where),3)," and ")
         ),curtab->tab[cur_ndx].child_column,"=request->archive_entity_id",
        trim(v_end_paren,3))
      ENDIF
     ELSE
      SET v_found_ndx = binsearch(curtab->tab[cur_ndx].parent_table)
      IF ((v_found_ndx != - (1)))
       SET found = 0
       FOR (ct_ndx = 1 TO size(curtab->tab,5))
         IF ((curtab->tab[ct_ndx].child_table=ap->tabs[cur_ndx].parent_table))
          SET found = (found+ 1)
         ENDIF
       ENDFOR
       IF (found=0)
        SET cur_count = (cur_count+ 1)
        SET stat = alterlist(curtab->tab,cur_count)
        SET curtab->tab[cur_count].parent_table = ap->tabs[v_found_ndx].parent_table
        SET curtab->tab[cur_count].parent_table_db = ap->tabs[v_found_ndx].parent_table_db
        SET curtab->tab[cur_count].parent_column = ap->tabs[v_found_ndx].parent_column
        SET curtab->tab[cur_count].child_table = ap->tabs[v_found_ndx].child_table
        SET curtab->tab[cur_count].child_table_db = ap->tabs[v_found_ndx].child_table_db
        SET curtab->tab[cur_count].child_column = ap->tabs[v_found_ndx].child_column
        SET curtab->tab[cur_count].child_where = ap->tabs[v_found_ndx].child_where
        SET curtab->tab[cur_count].from_str = concat(curtab->tab[cur_ndx].from_str,",",ap->tabs[
         v_found_ndx].child_table)
        SET curtab->tab[cur_count].from_str_db = concat(curtab->tab[cur_ndx].from_str_db,",",ap->
         tabs[v_found_ndx].child_table_db)
        SET curtab->tab[cur_count].where_str = concat(evaluate(curtab->tab[cur_ndx].child_where," ",
          " ",concat(curtab->tab[cur_ndx].child_table,".",trim(substring(6,10000,curtab->tab[cur_ndx]
             .child_where),3)," and ")),"list (",curtab->tab[cur_ndx].child_column,")")
        SET curtab->tab[cur_count].where_str_db = concat(evaluate(curtab->tab[cur_ndx].child_where,
          " "," ",concat(curtab->tab[cur_ndx].child_table_db,".",trim(substring(6,10000,curtab->tab[
             cur_ndx].child_where),3)," and ")),"list (",curtab->tab[cur_ndx].child_column,")")
        IF (cur_ndx=1)
         SET curtab->tab[cur_count].select_str = concat(trim(curtab->tab[cur_ndx].child_table,3),
          " where ",curtab->tab[cur_count].where_str," in (select ",curtab->tab[cur_ndx].
          parent_column,
          " from  ",trim(curtab->tab[cur_ndx].parent_table,3))
         SET curtab->tab[cur_count].select_str_db = concat(trim(curtab->tab[cur_ndx].child_table_db,3
           )," where ",curtab->tab[cur_count].where_str_db," in (select ",curtab->tab[cur_ndx].
          parent_column,
          " from  ",trim(curtab->tab[cur_ndx].parent_table_db,3))
        ELSE
         SET curtab->tab[cur_count].select_str = concat(curtab->tab[cur_ndx].select_str," where ",
          curtab->tab[cur_count].where_str," in (select ",curtab->tab[cur_ndx].parent_column,
          " from  ",trim(curtab->tab[cur_ndx].parent_table,3))
         SET curtab->tab[cur_count].select_str_db = concat(curtab->tab[cur_ndx].select_str_db,
          " where ",curtab->tab[cur_count].where_str_db," in (select ",curtab->tab[cur_ndx].
          parent_column,
          " from  ",trim(curtab->tab[cur_ndx].parent_table_db,3))
        ENDIF
        SET v_end_paren = build(")",v_end_paren)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    SET cur_ndx = (cur_ndx+ 1)
   ENDWHILE
   SET reply->tabs[v_reply_cnt].found_ind = ap->tabs[t_ndx].found_ind
   IF ((reply->tabs[v_reply_cnt].found_ind=1))
    SET reply->tabs[v_reply_cnt].rest_cnt_str = concat('select into "nl:" num_rows = count(*) from ',
     replace(replace(ap->tabs[t_ndx].select_str,'"',"'"),"^",'"'),
     " detail reply->tabs[v_reply_cnt].rest_num_rows = num_rows with nocounter go")
    SET reply->tabs[v_reply_cnt].arc_cnt_str = concat('select into "nl:" num_rows = count(*) from ',
     replace(replace(ap->tabs[t_ndx].select_str_db,'"',"'"),"^",'"'),
     " detail reply->tabs[v_reply_cnt].arc_num_rows = num_rows with nocounter go")
    SET reply->tabs[v_reply_cnt].arc_cnt_str = replace(replace(reply->tabs[v_reply_cnt].arc_cnt_str,
      ":pre_link:",v_pre_link_name),":post_link:",v_post_link_name)
    CALL echo(build("arc_cnt_str=",reply->tabs[v_reply_cnt].arc_cnt_str))
    CALL echo(build("rest_cnt_str=",reply->tabs[v_reply_cnt].rest_cnt_str))
    CALL parser(reply->tabs[v_reply_cnt].arc_cnt_str)
    CALL parser(reply->tabs[v_reply_cnt].rest_cnt_str)
   ELSE
    CALL echo(concat(request->archive_entity_name," was not found"))
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->tabs,v_reply_cnt)
 FOR (i = 1 TO size(reply->tabs,5))
   IF ((((reply->tabs[i].arc_num_rows > 0)) OR ((reply->tabs[i].rest_num_rows > 0))) )
    CALL echo(build(" Arc: ",reply->tabs[i].table_name,"=",reply->tabs[i].arc_num_rows))
    CALL echo(build("Clin: ",reply->tabs[i].table_name,"=",reply->tabs[i].rest_num_rows))
    CALL echo(".........................................................................")
   ENDIF
 ENDFOR
 SUBROUTINE binsearch(i_key)
   DECLARE v_low = i4 WITH noconstant(0)
   DECLARE v_mid = i4 WITH noconstant(0)
   DECLARE v_high = i4
   SET v_high = size(ap->tabs,5)
   SET v_num_passes = 0
   WHILE (((v_high - v_low) > 1))
     SET v_num_passes = (v_num_passes+ 1)
     SET v_mid = cnvtint(((v_high+ v_low)/ 2))
     IF ((i_key <= ap->tabs[v_mid].child_table))
      SET v_high = v_mid
     ELSE
      SET v_low = v_mid
     ENDIF
   ENDWHILE
   IF (trim(i_key,3)=trim(ap->tabs[v_high].child_table,3))
    RETURN(v_high)
   ELSE
    RETURN(- (1))
   ENDIF
 END ;Subroutine
 SUBROUTINE req_search(i_table_name)
   DECLARE v_found = i2 WITH noconstant(0)
   FOR (tn_ndx = 1 TO size(request->tabs,5))
     IF ((request->tabs[tn_ndx].table_name=i_table_name))
      SET v_found = 1
      SET tn_ndx = (size(request->tabs,5)+ 1)
     ENDIF
   ENDFOR
   RETURN(v_found)
 END ;Subroutine
#end_program
 FREE RECORD ap
 FREE RECORD curtab
#exit_program
END GO

CREATE PROGRAM ctp_pha_rec_list_sort_cls:dba
 CREATE CLASS rec_list_sort_cls
 init
 SUBROUTINE (_::sortrecord(in_record=vc(ref),list_items=vc,out_record=vc) =i4)
   RECORD query_rec(
     1 tot_item_cnt = i4
     1 lvl[*]
       2 name = vc
       2 item[*]
         3 name = vc
         3 dtype = vc
     1 select_list = vc
     1 from_list = vc
     1 plan_join = vc
     1 order_list = vc
     1 head_list = vc
     1 save_list = vc
     1 det_save_list = vc
     1 foot_list = vc
   ) WITH protect
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE field_list = vc WITH protect, noconstant(" ")
   DECLARE query_str = vc WITH protect, noconstant(" ")
   DECLARE out_rec_size = i4 WITH protect, noconstant(0)
   CALL PRIVATE::parsereclist(list_items,query_rec)
   CALL PRIVATE::buildoutrecord(query_rec)
   CALL PRIVATE::buildselectlist(query_rec)
   CALL PRIVATE::buildfromlist(query_rec)
   CALL PRIVATE::buildplanjoinlist(query_rec)
   CALL PRIVATE::buildorderlist(query_rec)
   CALL PRIVATE::buildheadlist(query_rec)
   CALL PRIVATE::buildsavelist(query_rec)
   CALL PRIVATE::builddetailsavelist(query_rec)
   CALL PRIVATE::buildfootlist(query_rec)
   SET query_str = concat("SELECT INTO 'NL:'",lf,query_rec->select_list,lf,"FROM",
    lf,query_rec->from_list,lf,query_rec->plan_join,lf,
    "ORDER",lf,query_rec->order_list,lf,"HEAD REPORT",
    lf,"cnt = 0",lf,query_rec->head_list,lf,
    "cnt = cnt + 1",lf,"if (mod(cnt, 5000) = 1)",lf,concat("stat = alterlist(",out_record,
     "->qual, cnt + 4999)"),
    lf,"endif",lf,query_rec->save_list,lf,
    "ptr_idx = 0",lf,"DETAIL",lf,"ptr_idx = ptr_idx + 1",
    lf,"if(mod(ptr_idx, 1000) = 1)",lf,concat("stat = alterlist(",out_record,
     "->qual[cnt].ptr, ptr_idx + 999)"),lf,
    "endif",lf,query_rec->det_save_list,lf,query_rec->foot_list,
    lf,"FOOT REPORT",lf,concat("stat = alterlist(",out_record,"->qual, cnt)"),lf,
    "WITH NOCOUNTER GO")
   CALL parser(query_str)
   SET out_rec_size = size(parser(build(out_record,"->qual")),5)
   RETURN(out_rec_size)
 END ;Subroutine
 SUBROUTINE (PRIVATE::parsereclist(list=vc,query=vc(ref)) =null)
   DECLARE level_delim = c1 WITH protect, constant("|")
   DECLARE begin_item_delim = c1 WITH protect, constant(";")
   DECLARE level_cnt = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE remainder = vc WITH protect, noconstant(" ")
   DECLARE level = vc WITH protect, noconstant(" ")
   DECLARE item_list = vc WITH protect, noconstant(" ")
   DECLARE list_part = vc WITH protect, noconstant(list)
   SET pos = findstring(level_delim,list)
   IF (pos > 0)
    SET list_part = substring(1,(pos - 1),list)
    SET remainder = substring((pos+ 1),size(list),list)
   ENDIF
   SET pos = findstring(begin_item_delim,list_part)
   IF (pos > 0)
    SET level = substring(1,(pos - 1),list_part)
    SET item_list = substring((pos+ 1),size(list_part),list_part)
   ELSE
    SET level = list_part
   ENDIF
   SET level_cnt = (size(query->lvl,5)+ 1)
   SET stat = alterlist(query->lvl,level_cnt)
   SET query->lvl[level_cnt].name = level
   CALL PRIVATE::parserecitems(item_list,query)
   IF (size(trim(remainder)) > 0)
    CALL PRIVATE::parsereclist(remainder,query)
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::parserecitems(list=vc,query=vc(ref)) =null)
   DECLARE item_delim = c1 WITH protect, constant(",")
   DECLARE type_delim = c1 WITH protect, constant("-")
   DECLARE item_cnt = i4 WITH protect, noconstant(0)
   DECLARE level_cnt = i4 WITH protect, noconstant(0)
   DECLARE item_pos = i4 WITH protect, noconstant(0)
   DECLARE type_pos = i4 WITH protect, noconstant(0)
   DECLARE remainder = vc WITH protect, noconstant(" ")
   DECLARE item = vc WITH protect, noconstant(" ")
   DECLARE type = vc WITH protect, noconstant(" ")
   SET item_pos = findstring(item_delim,list)
   SET type_pos = findstring(type_delim,list,1,0)
   IF (item_pos > 0)
    SET item = substring(1,(type_pos - 1),list)
    SET type = substring((type_pos+ 1),((item_pos - type_pos) - 1),list)
    SET remainder = substring((item_pos+ 1),size(list),list)
   ELSE
    SET item = substring(1,(type_pos - 1),list)
    SET type = substring((type_pos+ 1),size(list),list)
   ENDIF
   IF (size(trim(item)) > 0)
    SET level_cnt = size(query->lvl,5)
    SET item_cnt = (size(query->lvl[level_cnt].item,5)+ 1)
    SET query->tot_item_cnt += 1
    SET stat = alterlist(query->lvl[level_cnt].item,item_cnt)
    SET query->lvl[level_cnt].item[item_cnt].name = item
    SET query->lvl[level_cnt].item[item_cnt].dtype = type
   ENDIF
   IF (size(trim(remainder)) > 0)
    CALL PRIVATE::parserecitems(remainder,query)
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildoutrecord(query=vc(ref)) =null)
   DECLARE lf = c2 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE item_cnt = i4 WITH protect, noconstant(0)
   DECLARE rec_var = vc WITH protect, noconstant(" ")
   IF (validate(parser(out_record)))
    CALL parser(concat("free record ",out_record," go"))
   ENDIF
   SET rec_var = concat("record ",out_record," (",sub)
   SET rec_var = concat(rec_var," 1 qual[*]",sub)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET item_cnt += 1
      SET rec_var = build(rec_var," 2 id_",item_cnt," = ",query->lvl[lvl_idx].item[item_idx].dtype)
     ENDFOR
   ENDFOR
   SET rec_var = concat(rec_var," 2 ptr[*]",sub)
   SET item_cnt = 0
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET item_cnt += 1
      SET rec_var = build(rec_var," 3 id_",item_cnt,"_idx = i4")
     ENDFOR
   ENDFOR
   SET rec_var = build(rec_var,") with persistscript go",sub)
   SET rec_var = replace(rec_var,sub,lf)
   CALL parser(rec_var)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildselectlist(query=vc(ref)) =null)
   DECLARE lfc = c2 WITH protect, constant(concat(char(10),","))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE record_path = vc WITH protect, noconstant(" ")
   DECLARE select_var = vc WITH protect, noconstant(" ")
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE select_cnt = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
    SET record_path = trim(build(record_path,sub,query->lvl[lvl_idx].name,"[d",lvl_idx,
      ".seq]"),3)
    FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET select_cnt += 1
      SET select_var = build("in_record->",record_path,".",query->lvl[lvl_idx].item[item_idx].name)
      IF ((query->lvl[lvl_idx].item[item_idx].dtype="f8"))
       SET select_var = concat("cnvtreal(",select_var,")")
      ELSEIF ((query->lvl[lvl_idx].item[item_idx].dtype IN ("i2", "i4")))
       SET select_var = concat("cnvtint(",select_var,")")
      ELSE
       SET select_var = concat("substring(1, 255, cnvtupper(",select_var,"))")
      ENDIF
      SET select_var = build("id_",select_cnt," = ",select_var)
      SET select_var = replace(select_var,sub,".")
      SET query->select_list = trim(build(query->select_list,sub,select_var),3)
    ENDFOR
   ENDFOR
   SET query->select_list = replace(query->select_list,sub,lfc)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildfromlist(query=vc(ref)) =null)
   DECLARE lfc = c2 WITH protect, constant(concat(char(10),","))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     SET query->from_list = trim(build(query->from_list,sub,"(dummyt d",lvl_idx),3)
     IF (lvl_idx=1)
      SET query->from_list = concat(query->from_list," with seq = value(size(in_record->",query->lvl[
       lvl_idx].name,",5))")
     ENDIF
     SET query->from_list = build(query->from_list,")")
   ENDFOR
   SET query->from_list = replace(query->from_list,sub,lfc)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildplanjoinlist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE tmp_path = vc WITH protect, noconstant(" ")
   DECLARE tbl = vc WITH protect, noconstant(" ")
   DECLARE keyword = vc WITH protect, noconstant(" ")
   DECLARE record_path = vc WITH protect, noconstant(" ")
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE where_used = i2 WITH protect, noconstant(0)
   DECLARE item = vc WITH protect, noconstant(" ")
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     SET where_used = 0
     SET record_path = trim(build(record_path,sub,query->lvl[lvl_idx].name,"[d",lvl_idx,
       ".seq]"),3)
     SET record_path = replace(record_path,sub,".")
     IF (lvl_idx < size(query->lvl,5))
      SET tmp_path = build(record_path,".",query->lvl[(lvl_idx+ 1)].name)
     ENDIF
     IF (lvl_idx=1)
      SET tbl = "PLAN"
     ELSE
      SET tbl = "JOIN"
     ENDIF
     SET tbl = concat(tbl," d",build(lvl_idx))
     IF (lvl_idx < size(query->lvl,5))
      SET tbl = concat(tbl," where maxrec(d",build((lvl_idx+ 1)),", size(in_record->",tmp_path,
       ",5))",sub)
      SET where_used = 1
     ENDIF
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
       SET item = build("in_record->",record_path,".",query->lvl[lvl_idx].item[item_idx].name)
       IF (item_idx=1
        AND where_used=0)
        SET keyword = " WHERE"
       ELSE
        SET keyword = "AND"
       ENDIF
       IF ((query->lvl[lvl_idx].item[item_idx].dtype="f8"))
        SET tbl = concat(tbl,keyword," cnvtreal(",item,") > 0",
         sub)
       ELSEIF ((query->lvl[lvl_idx].item[item_idx].dtype IN ("i2", "i4")))
        SET tbl = concat(tbl,keyword," cnvtint(",item,") > 0",
         sub)
       ELSE
        SET tbl = concat(tbl,keyword," textlen(trim(",item,", 3)) > 0",
         sub)
       ENDIF
     ENDFOR
     SET query->plan_join = build(query->plan_join,sub,tbl)
   ENDFOR
   SET query->plan_join = replace(query->plan_join,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildorderlist(query=vc(ref)) =null)
   DECLARE lfc = c2 WITH protect, constant(concat(char(10),","))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE order_cnt = i4 WITH protect, noconstant(0)
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET order_cnt += 1
      SET query->order_list = trim(build(query->order_list,sub,"id_",order_cnt),3)
     ENDFOR
   ENDFOR
   SET query->order_list = replace(query->order_list,sub,lfc)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildheadlist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE head_cnt = i4 WITH protect, noconstant(0)
   IF ((query->tot_item_cnt > 1))
    FOR (idx = 1 TO (query->tot_item_cnt - 1))
     SET head_cnt += 1
     SET query->head_list = trim(build(query->head_list,sub,"head id_",head_cnt,sub,
       "null"),3)
    ENDFOR
   ENDIF
   SET query->head_list = trim(build(query->head_list,sub,"head id_",query->tot_item_cnt),3)
   SET query->head_list = replace(query->head_list,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildsavelist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE save_cnt = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET save_cnt += 1
      SET query->save_list = trim(build(query->save_list,sub,out_record,"->qual[cnt].id_",save_cnt,
        " = id_",save_cnt),3)
     ENDFOR
   ENDFOR
   SET query->save_list = replace(query->save_list,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::builddetailsavelist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE save_cnt = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET save_cnt += 1
      SET query->det_save_list = trim(build(query->det_save_list,sub,out_record,
        "->qual[cnt].ptr[ptr_idx].id_",save_cnt,
        "_idx = d",lvl_idx,".seq"),3)
     ENDFOR
   ENDFOR
   SET query->det_save_list = replace(query->det_save_list,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildfootlist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE foot_cnt = i4 WITH protect, noconstant(0)
   SET query->foot_list = trim(build(sub,"foot id_",query->tot_item_cnt,sub,"stat = alterlist(",
     out_record,"->qual[cnt].ptr, ptr_idx)"),3)
   IF ((query->tot_item_cnt > 1))
    SET foot_cnt = query->tot_item_cnt
    FOR (idx = 1 TO (query->tot_item_cnt - 1))
     SET foot_cnt -= 1
     SET query->foot_list = trim(build(query->foot_list,sub,"foot id_",foot_cnt,sub,
       "null"),3)
    ENDFOR
   ENDIF
   SET query->foot_list = replace(query->foot_list,sub,lf)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
#exit_script
END GO

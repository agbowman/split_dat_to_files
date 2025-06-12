CREATE PROGRAM ctp_edcw_common_components:dba
 CREATE CLASS edcw_file_output FROM ctp_file_output
 init
 DECLARE PRIVATE::date_format = vc WITH constant("YYYY-MM-DD HH:MM:SS;;q")
 DECLARE CLASS::file_id = vc
 SUBROUTINE (_::initialize(file_prefix=vc) =null)
   SET PRIVATE::file_name = build(logical("cer_temp"),"/",file_prefix,"_",CLASS::file_id,
    ".csv")
 END ;Subroutine
 DECLARE _::writefile(null) = null
 SUBROUTINE _::writefile(null)
   CALL _::delimitedoutput(",")
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS edcw_get_data_cls
 init
 RECORD _::data(
   1 list[*]
     2 id = f8
     2 display = vc
 )
 DECLARE _::this = i1 WITH noconstant(0)
 DECLARE PRIVATE::err_msg = vc WITH noconstant(" ")
 DECLARE PRIVATE::instance = vc WITH constant(piece(class(_::this,2,0),".",1,"{::}"))
 DECLARE _::geterror(null) = vc
 SUBROUTINE _::geterror(null)
  IF (size(trim(PRIVATE::err_msg))=0)
   SET PRIVATE::err_msg = concat(PRIVATE::instance," unknown error")
  ENDIF
  RETURN(PRIVATE::err_msg)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS edcw_get_data_code_set_cls FROM edcw_get_data_cls
 init
 RECORD PRIVATE::code_set_data(
   1 list[*]
     2 code = f8
     2 display = vc
     2 active_ind = i2
 )
 IF ( NOT (validate(PRIVATE::cdf_list)))
  DECLARE PRIVATE::cdf_list = vc WITH constant(" ")
 ENDIF
 IF ( NOT (validate(PRIVATE::exclude)))
  DECLARE PRIVATE::exclude = i2 WITH constant(0)
 ENDIF
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE CS::instance = null WITH protect, class(edcw_get_code_set)
   CALL CS::instance.get(PRIVATE::codeset,PRIVATE::code_set_data,PRIVATE::cdf_list,PRIVATE::exclude)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(private::code_set_data->list,5))
   FOR (idx = 1 TO size(_::data->list,5))
    SET _::data->list[idx].id = private::code_set_data->list[idx].code
    SET _::data->list[idx].display = private::code_set_data->list[idx].display
   ENDFOR
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS edcw_get_code_set
 init
 DECLARE _::get(code_set=i4,reply_record=vc(ref),filter_list=vc(value," "),exclude_ind=i2(value,0),
  active_ind=i2(value,1)) = i2 WITH protect
 SUBROUTINE _::get(code_set,reply_record,filter_list,exclude_ind,active_ind)
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   DECLARE sep = c1 WITH protect, constant(char(26))
   DECLARE dynamic_filter = vc WITH protect, noconstant("1=1")
   DECLARE field = vc WITH protect, noconstant(" ")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET stat = initrec(reply_record)
   IF (size(trim(filter_list)) > 0)
    SET dynamic_filter = " "
    SET cnt = 1
    SET field = piece(filter_list,"|",cnt,not_found)
    WHILE (field != not_found)
      SET dynamic_filter = build(dynamic_filter,sep,"'",field,"'")
      SET cnt += 1
      SET field = piece(filter_list,"|",cnt,not_found)
    ENDWHILE
    SET dynamic_filter = replace(trim(dynamic_filter,2),sep,",")
    IF (exclude_ind)
     SET dynamic_filter = build("cv.cdf_meaning not in (",dynamic_filter,")")
     SET dynamic_filter = build("(",dynamic_filter,"or cv.cdf_meaning = NULL",")")
    ELSE
     SET dynamic_filter = build("cv.cdf_meaning in (",dynamic_filter,")")
    ENDIF
   ENDIF
   SELECT
    IF (active_ind)
     PLAN (cv
      WHERE cv.code_set=code_set
       AND cv.active_ind=1
       AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND parser(dynamic_filter))
    ELSE
     PLAN (cv
      WHERE cv.code_set=code_set
       AND parser(dynamic_filter))
    ENDIF
    INTO "nl:"
    FROM code_value cv
    ORDER BY cv.code_value
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(reply_record->list,(cnt+ 9999))
     ENDIF
     reply_record->list[cnt].code = cv.code_value
     IF (cv.active_ind
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))
      reply_record->list[cnt].active_ind = true
     ENDIF
     CALL PRIVATE::optionalitems(reply_record,cnt)
    FOOT REPORT
     stat = alterlist(reply_record->list,cnt)
    WITH nocounter
   ;end select
   IF (size(reply_record->list,5) > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::optionalitems(reply_record=vc(ref),pos=i4) =null WITH protect)
   IF (validate(reply_record->list[1].display))
    SET reply_record->list[pos].display = cv.display
   ENDIF
   IF (validate(reply_record->list[1].description))
    SET reply_record->list[pos].description = cv.description
   ENDIF
   IF (validate(reply_record->list[1].definition))
    SET reply_record->list[pos].definition = cv.definition
   ENDIF
   IF (validate(reply_record->list[1].cki))
    SET reply_record->list[pos].cki = cv.cki
   ENDIF
   IF (validate(reply_record->list[1].concept_cki))
    SET reply_record->list[pos].concept_cki = cv.concept_cki
   ENDIF
   IF (validate(reply_record->list[1].cdf_meaning))
    SET reply_record->list[pos].cdf_meaning = cv.cdf_meaning
   ENDIF
   IF (validate(reply_record->list[1].collation_seq))
    SET reply_record->list[pos].collation_seq = cv.collation_seq
   ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS edcw_hash_map_pair
 init
 SUBROUTINE (_::add(pair_list=vc(ref),value=vc,name=vc) =null WITH protect)
  DECLARE pair = vc WITH protect, noconstant(build(value,",",name))
  IF (size(trim(pair_list))=0)
   SET pair_list = pair
  ELSE
   SET pair_list = build(pair_list,"|",pair)
  ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS edcw_hash_map
 init
 DECLARE _::key_left = i1 WITH constant(1)
 DECLARE _::key_right = i1 WITH constant(2)
 SUBROUTINE (_::add(map_key=vc,map_val=vc) =i1)
   DECLARE status = i1 WITH protect, noconstant(- (1))
   SET status = PRIVATE::perform("ADD",map_key,map_val)
   RETURN(status)
 END ;Subroutine
 DECLARE _::_print(null) = i1
 SUBROUTINE _::_print(null)
   DECLARE status = i1 WITH protect, noconstant(- (1))
   SET status = PRIVATE::map("PRINT")
   RETURN(status)
 END ;Subroutine
 SUBROUTINE (_::export(rec=vc(ref)) =null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET stat = initrec(rec)
   CALL alterlist(rec->list,PRIVATE::map("COUNT"))
   FOR (idx = 1 TO size(rec->list,5))
     SET stat = PRIVATE::map("LOC",idx,rec->list[idx].key_val,rec->list[idx].val)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (_::import(string=vc,key_location=i1) =null)
   DECLARE notfound = vc WITH protect, constant("%NOTFOUND%")
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE pair = vc WITH protect, noconstant(" ")
   SET cnt = 1
   SET pair = piece(string,"|",cnt,notfound)
   WHILE (pair != notfound)
     SET pos = findstring(",",pair)
     CASE (key_location)
      OF _::key_left:
       CALL _::add(substring(1,(pos - 1),pair),substring((pos+ 1),size(pair),pair))
      OF _::key_right:
       CALL _::add(substring((pos+ 1),size(pair),pair),substring(1,(pos - 1),pair))
     ENDCASE
     SET cnt += 1
     SET pair = piece(string,"|",cnt,notfound)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (PRIVATE::perform(mode=vc,map_key=vc,map_val=vc(ref)) =i1)
   DECLARE status = i1 WITH protect, noconstant(- (1))
   CASE (substring(1,1,reflect(map_key)))
    OF "C":
     SET map_key = cnvtupper(map_key)
     SET status = PRIVATE::map(value(trim(cnvtupper(mode),3)),trim(map_key),map_val)
    ELSE
     SET status = PRIVATE::map(value(trim(cnvtupper(mode),3)),map_key,map_val)
   ENDCASE
   RETURN(status)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS edcw_hash_map_i4 FROM edcw_hash_map
 init
 DECLARE PRIVATE::map(mode=vc,map_key=vc,map_val=i4) = i4 WITH map = "HASH"
 DECLARE _::notfound = i4 WITH constant(- (999))
 SUBROUTINE (_::find(map_key=vc) =i4)
   DECLARE status = i1 WITH protect, noconstant(- (1))
   DECLARE map_val = i4 WITH protect, noconstant(_::notfound)
   SET status = PRIVATE::perform("FIND",map_key,map_val)
   RETURN(map_val)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS edcw_hash_map_vc FROM edcw_hash_map
 init
 DECLARE PRIVATE::map(mode=vc,map_key=vc,map_val=vc) = i4 WITH map = "HASH"
 DECLARE _::notfound = vc WITH constant(" ")
 SUBROUTINE (_::find(map_key=vc) =vc)
   DECLARE status = i1 WITH protect, noconstant(- (1))
   DECLARE map_val = vc WITH protect, noconstant(_::notfound)
   SET status = PRIVATE::perform("FIND",map_key,map_val)
   RETURN(map_val)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS edcw_hash_map_f8 FROM edcw_hash_map
 init
 DECLARE PRIVATE::map(mode=vc,map_key=vc,map_val=f8) = i4 WITH map = "HASH"
 DECLARE _::notfound = f8 WITH constant(- (999.0))
 SUBROUTINE (_::find(map_key=vc) =f8)
   DECLARE status = i1 WITH protect, noconstant(- (1))
   DECLARE map_val = f8 WITH protect, noconstant(_::notfound)
   SET status = PRIVATE::perform("FIND",map_key,map_val)
   RETURN(map_val)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS edcw_updt_prsnl
 init
 DECLARE PRIVATE::field_list = vc WITH noconstant(" ")
 DECLARE PRIVATE::table_name = vc WITH noconstant(" ")
 DECLARE PRIVATE::err_msg = vc WITH noconstant(" ")
 SUBROUTINE (_::settable(table_name=vc,reverse_ind=i2(value,0),exclude_field=vc(value," "),
  exclude_index=vc(value," ")) =i2)
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE field = vc WITH protect, noconstant(" ")
   DECLARE column_exclusion = vc WITH protect, noconstant(" ")
   DECLARE index_exclusion = vc WITH protect, noconstant(" ")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET PRIVATE::table_name = cnvtupper(trim(table_name,3))
   IF (size(trim(exclude_field)) > 0)
    SET cnt = 1
    SET field = piece(exclude_field,"|",cnt,not_found)
    WHILE (field != not_found)
      SET column_exclusion = build(column_exclusion,sub,'"',field,'"')
      SET cnt += 1
      SET field = piece(exclude_field,"|",cnt,not_found)
    ENDWHILE
    SET column_exclusion = replace(trim(column_exclusion,3),sub,",")
    SET column_exclusion = build("dic.column_name NOT IN (",cnvtupper(trim(column_exclusion,3)),")")
   ELSE
    SET column_exclusion = "1=1"
   ENDIF
   IF (size(trim(exclude_index)) > 0)
    SET cnt = 1
    SET field = piece(exclude_index,"|",cnt,not_found)
    WHILE (field != not_found)
      SET index_exclusion = build(index_exclusion,sub,'"',field,'"')
      SET cnt += 1
      SET field = piece(exclude_index,"|",cnt,not_found)
    ENDWHILE
    SET index_exclusion = replace(trim(index_exclusion,3),sub,",")
    SET index_exclusion = build("di.index_name NOT IN (",cnvtupper(trim(index_exclusion,3)),")")
   ELSE
    SET index_exclusion = "1=1"
   ENDIF
   SET cnt = 0
   SELECT
    IF (reverse_ind)
     ORDER BY di.index_name, dic.column_position DESC
    ELSE
     ORDER BY di.index_name, dic.column_position
    ENDIF
    INTO "nl:"
    FROM dba_indexes di,
     dba_ind_columns dic
    PLAN (di
     WHERE (di.table_name=PRIVATE::table_name)
      AND di.table_owner="V500"
      AND di.uniqueness="UNIQUE"
      AND di.index_name="XPK*"
      AND parser(index_exclusion))
     JOIN (dic
     WHERE dic.index_name=di.index_name
      AND dic.table_name=di.table_name
      AND dic.table_owner=di.table_owner
      AND parser(column_exclusion))
    ORDER BY di.index_name, dic.column_position
    HEAD REPORT
     null
    HEAD di.index_name
     cnt += 1
    DETAIL
     PRIVATE::field_list = trim(build(PRIVATE::field_list,sub,dic.column_name),3)
    FOOT  di.index_name
     null
    FOOT REPORT
     PRIVATE::field_list = replace(PRIVATE::field_list,sub,"|")
    WITH nocounter
   ;end select
   IF (cnt > 1)
    SET PRIVATE::error_msg = build("Duplicate XPK:",PRIVATE::table_name)
    RETURN(0)
   ENDIF
   IF (size(trim(PRIVATE::field_list))=0)
    SET PRIVATE::error_msg = build("Could not find XPK:",PRIVATE::table_name)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (_::querytable(in_record=vc(ref),list_items=vc,out_record=vc(ref)) =i2)
   RECORD query_rec(
     1 lvl[*]
       2 name = vc
       2 item[*]
         3 name = vc
         3 data_type = vc
     1 data_min_loop = vc
     1 data_type_loop = vc
     1 minimum_data_ind = i2
     1 select_list = vc
     1 from_list = vc
     1 plan_join = vc
     1 order_list = vc
     1 save_list = vc
   ) WITH protect
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE field_list = vc WITH protect, noconstant(" ")
   DECLARE query_str = vc WITH protect, noconstant(" ")
   CALL PRIVATE::parsereclist(list_items,query_rec)
   IF (PRIVATE::isrecempty(query_rec))
    RETURN(1)
   ENDIF
   CALL PRIVATE::getdatatype(query_rec)
   CALL PRIVATE::buildselectlist(query_rec)
   CALL PRIVATE::buildfromlist(query_rec)
   CALL PRIVATE::buildplanjoinlist(query_rec)
   CALL PRIVATE::buildorderlist(query_rec)
   CALL PRIVATE::buildsavelist(query_rec)
   SET query_str = concat("SELECT INTO 'NL:'",lf,query_rec->select_list,lf,"FROM",
    lf,query_rec->from_list,lf,query_rec->plan_join,lf,
    "ORDER",lf,query_rec->order_list,lf,"HEAD REPORT",
    lf,"cnt = 0",lf,"DETAIL",lf,
    "cnt = cnt + 1",lf,"if(mod(cnt, 10000) = 1)",lf,"stat = alterlist(out_record->list, cnt + 9999)",
    lf,"endif",lf,query_rec->save_list,lf,
    "FOOT REPORT",lf,"stat = alterlist(out_record->list, cnt)",lf,"WITH NOCOUNTER GO")
   CALL parser(query_str)
   IF (size(out_record->list,5)=0)
    RETURN(true)
   ENDIF
   IF ( NOT (PRIVATE::performupdtprsnlquery(out_record)))
    RETURN(false)
   ENDIF
   FOR (idx = 1 TO size(out_record->list,5))
     SET out_record->list[idx].updt_username = PRIVATE::formatusername(out_record->list[idx].
      updt_username,out_record->list[idx].updt_id,out_record->list[idx].updt_dt_tm)
   ENDFOR
   RETURN(true)
 END ;Subroutine
 DECLARE _::geterror(null) = vc
 SUBROUTINE _::geterror(null)
  IF (size(trim(PRIVATE::err_msg))=0)
   SET PRIVATE::err_msg = concat("UpdatePrsnl(",PRIVATE::table_name,") unknown error")
  ENDIF
  RETURN(PRIVATE::err_msg)
 END ;Subroutine
 SUBROUTINE (PRIVATE::getdatatype(query=vc(ref)) =i2)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE lvl_1 = i4 WITH protect, noconstant(0)
   DECLARE lvl_2 = i4 WITH protect, noconstant(0)
   DECLARE record_path = vc WITH protect, noconstant(" ")
   DECLARE for_struct = vc WITH protect, noconstant(" ")
   FOR (lvl_1 = 1 TO size(query->lvl,5))
     IF (lvl_1=1)
      SET record_path = query->lvl[lvl_1].name
     ELSE
      SET record_path = build(record_path,"[idx_",(lvl_1 - 1),"].",query->lvl[lvl_1].name)
     ENDIF
     IF (lvl_1=size(query->lvl,5))
      SET for_struct = trim(build(for_struct,lf,"for(idx_",lvl_1,"= 1 to minval(size(in_record->",
        record_path,",5),1))"),3)
     ELSE
      SET for_struct = trim(build(for_struct,lf,"for(idx_",lvl_1,"= 1 to size(in_record->",
        record_path,",5))"),3)
     ENDIF
     FOR (lvl_2 = 1 TO size(query->lvl[lvl_1].item,5))
       SET for_struct = build(for_struct,lf,"query->lvl[",lvl_1,"].item[",
        lvl_2,"].data_type = reflect(","in_record->",record_path,"[idx_",
        lvl_1,"].",query->lvl[lvl_1].item[lvl_2].name,")")
     ENDFOR
   ENDFOR
   FOR (idx = 1 TO size(query->lvl,5))
     SET for_struct = build(for_struct,lf,"endfor")
   ENDFOR
   SET for_struct = concat("SELECT INTO 'NL:'",lf,"FROM DUMMYT",lf,"detail",
    lf,for_struct," WITH NOCOUNTER GO")
   SET query->data_type_loop = for_struct
   CALL parser(query->data_type_loop)
 END ;Subroutine
 SUBROUTINE (PRIVATE::isrecempty(query=vc(ref)) =i2)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE record_path = vc WITH protect, noconstant(" ")
   DECLARE for_struct = vc WITH protect, noconstant(" ")
   FOR (lvl_idx = 1 TO size(query->lvl,5))
    IF (lvl_idx=1)
     SET record_path = query->lvl[lvl_idx].name
    ELSE
     SET record_path = build(record_path,"[idx_",(lvl_idx - 1),"].",query->lvl[lvl_idx].name)
    ENDIF
    SET for_struct = trim(build(for_struct,lf,"for(idx_",lvl_idx,"= 1 to size(in_record->",
      record_path,",5))"),3)
   ENDFOR
   SET for_struct = build(for_struct,lf,"query->minimum_data_ind = TRUE")
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     SET for_struct = build(for_struct,lf,"endfor")
   ENDFOR
   SET for_struct = concat("SELECT INTO 'NL:'",lf,"FROM DUMMYT",lf,"detail",
    lf,for_struct," WITH NOCOUNTER GO")
   SET query->data_min_loop = for_struct
   CALL parser(query->data_min_loop)
   RETURN(negate(query->minimum_data_ind))
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
   DECLARE item_cnt = i4 WITH protect, noconstant(0)
   DECLARE level_cnt = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE remainder = vc WITH protect, noconstant(" ")
   DECLARE item = vc WITH protect, noconstant(list)
   SET pos = findstring(item_delim,list)
   IF (pos > 0)
    SET item = substring(1,(pos - 1),list)
    SET remainder = substring((pos+ 1),size(list),list)
   ENDIF
   IF (size(trim(item)) > 0)
    SET level_cnt = size(query->lvl,5)
    SET item_cnt = (size(query->lvl[level_cnt].item,5)+ 1)
    SET stat = alterlist(query->lvl[level_cnt].item,item_cnt)
    SET query->lvl[level_cnt].item[item_cnt].name = item
   ENDIF
   IF (size(trim(remainder)) > 0)
    CALL PRIVATE::parserecitems(remainder,query)
   ELSE
    RETURN
   ENDIF
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
      IF (substring(1,1,query->lvl[lvl_idx].item[item_idx].data_type)="C")
       SET select_var = build("id_",select_cnt,"= substring(1,100,in_record->",record_path,".",
        query->lvl[lvl_idx].item[item_idx].name,")")
      ELSE
       SET select_var = build("id_",select_cnt,"= in_record->",record_path,".",
        query->lvl[lvl_idx].item[item_idx].name)
      ENDIF
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
   DECLARE record_path = vc WITH protect, noconstant(" ")
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
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
       ",5))")
     ENDIF
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
 SUBROUTINE (PRIVATE::buildsavelist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE save_cnt = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET save_cnt += 1
      SET query->save_list = trim(build(query->save_list,sub,"out_record->list[cnt].id_",save_cnt,
        " = id_",
        save_cnt),3)
     ENDFOR
   ENDFOR
   SET query->save_list = replace(query->save_list,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::performupdtprsnlquery(out_record=vc(ref)) =i2)
   RECORD fields_rec(
     1 list[*]
       2 name = vc
   ) WITH protect
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE table_alias = vc WITH protect, constant("edcw_tmp_tbl")
   DECLARE function_parameters = vc WITH protect, noconstant(" ")
   DECLARE query_str = vc WITH protect, noconstant(" ")
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE field = vc WITH protect, noconstant(" ")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET cnt = 1
   SET field = piece(PRIVATE::field_list,"|",cnt,not_found)
   WHILE (field != not_found)
     SET stat = alterlist(fields_rec->list,cnt)
     SET fields_rec->list[cnt].name = field
     SET cnt += 1
     SET field = piece(PRIVATE::field_list,"|",cnt,not_found)
   ENDWHILE
   SET function_parameters = build("(idx, 1, size(out_record->list,5)")
   FOR (cnt = 1 TO size(fields_rec->list,5))
     SET function_parameters = build(function_parameters,lf,",",table_alias,".",
      fields_rec->list[cnt].name,", out_record->list[idx].id_",cnt)
   ENDFOR
   SET function_parameters = build(function_parameters,")")
   SET query_str = concat('SELECT INTO "NL:"',lf,"FROM",lf,PRIVATE::table_name,
    " ",table_alias,lf,", PRSNL p",lf,
    "PLAN ",table_alias,lf,"WHERE expand",function_parameters,
    lf,"JOIN p",lf,"WHERE p.person_id = outerjoin(",table_alias,
    ".updt_id)",lf,"ORDER BY",lf,table_alias,
    ".updt_dt_tm ASC",lf,"DETAIL",lf,"pos = locatevalsort",
    function_parameters,lf,"if(pos > 0)",lf,"out_record->list[pos].updt_dt_tm = ",
    table_alias,".updt_dt_tm",lf,"out_record->list[pos].updt_username = p.username",lf,
    "out_record->list[pos].updt_id = ",table_alias,".updt_id",lf,"endif",
    lf,"WITH EXPAND = 2 GO")
   CALL parser(query_str)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::formatusername(username=vc,person_id=f8(value,0.0),dt_tm=vc(value,0.0)) =vc)
   IF (size(trim(username)) > 0)
    RETURN(username)
   ELSEIF (dt_tm <= 0.0)
    RETURN(" ")
   ELSE
    RETURN(concat("(N/A) - ID: ",cnvtstring(person_id,17,0)))
   ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
END GO

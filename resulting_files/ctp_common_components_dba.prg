CREATE PROGRAM ctp_common_components:dba
 CREATE CLASS ctp_message_log
 init
 RECORD PRIVATE::colmap(
   1 cnt = i4
   1 data[*]
     2 field = vc
     2 col = i4
 )
 RECORD PRIVATE::msgdef(
   1 cnt = i4
   1 list[*]
     2 name = vc
     2 msg = vc
     2 col_cnt = i4
     2 col[*]
       3 val = i4
 )
 RECORD _::msg(
   1 cnt = i4
   1 list[*]
     2 full_msg = vc
     2 msg_cnt = i4
     2 msg[*]
       3 txt = vc
     2 entity_id = f8
     2 entity_name = vc
     2 full_cell = vc
     2 cell_cnt = i4
     2 cell[*]
       3 cellref = vc
     2 success_ind = i2
   1 layout_error = i2
   1 general_system_error = i2
 )
 DECLARE PRIVATE::rows_processed = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::rows_with_errors = i4 WITH protect, noconstant(0)
 SUBROUTINE (_::errormsg(r=i4,enum_name=vc,addl_msg=vc(value," ")) =null)
   DECLARE name_key = vc WITH protect, noconstant(cnvtupper(enum_name))
   DECLARE msg_cnt = i4 WITH protect, noconstant(_::msg->list[r].msg_cnt)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   SET pos = locatevalsort(index,1,private::msgdef->cnt,name_key,private::msgdef->list[index].name)
   IF (pos > 0)
    SET msg_cnt += 1
    SET _::msg->list[r].msg_cnt = msg_cnt
    SET stat = alterlist(_::msg->list[r].msg,msg_cnt)
    SET _::msg->list[r].msg[msg_cnt].txt = private::msgdef->list[pos].msg
    IF (textlen(trim(addl_msg)) != 0)
     SET _::msg->list[r].msg[msg_cnt].txt = build(_::msg->list[r].msg[msg_cnt].txt,"::",addl_msg)
    ENDIF
    FOR (index = 1 TO private::msgdef->list[pos].col_cnt)
      CALL PRIVATE::errorcellref(r,private::msgdef->list[pos].col[index].val)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::definemsg(enum_name=vc,error_msg=vc,columns=vc) =null)
   DECLARE name_key = vc WITH protect, constant(cnvtupper(enum_name))
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   DECLARE enumpos = i4 WITH protect, noconstant(0)
   DECLARE colpos = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   SET enumpos = locatevalsort(index,1,private::msgdef->cnt,name_key,private::msgdef->list[index].
    name)
   IF (enumpos <= 0)
    SET enumpos = abs(enumpos)
    SET private::msgdef->cnt += 1
    SET stat = alterlist(private::msgdef->list,private::msgdef->cnt,enumpos)
    SET enumpos += 1
    SET private::msgdef->list[enumpos].name = name_key
    SET private::msgdef->list[enumpos].msg = error_msg
    SET piece_cnt = 1
    SET column = cnvtupper(piece(columns,"|",piece_cnt,not_found,3))
    WHILE (column != not_found)
      IF (column != "ALL")
       SET col_cnt += 1
       SET stat = alterlist(private::msgdef->list[enumpos].col,col_cnt)
       SET colpos = locateval(index,1,private::colmap->cnt,column,private::colmap->data[index].field)
       IF (colpos > 0)
        SET private::msgdef->list[enumpos].col[col_cnt].val = private::colmap->data[colpos].col
       ENDIF
       SET piece_cnt += 1
       SET column = cnvtupper(piece(columns,"|",piece_cnt,not_found,3))
      ELSE
       SET col_cnt = private::colmap->cnt
       SET stat = alterlist(private::msgdef->list[enumpos].col,col_cnt)
       FOR (index = 1 TO col_cnt)
         SET private::msgdef->list[enumpos].col[index].val = private::colmap->data[index].col
       ENDFOR
       SET column = not_found
      ENDIF
    ENDWHILE
    SET private::msgdef->list[enumpos].col_cnt = col_cnt
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::parseerrorcolumn(map_persist=vc(ref)) =null)
   DECLARE piece_cnt = i4 WITH protect, noconstant(1)
   DECLARE errmapparse = vc WITH protect, noconstant(" ")
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   IF (size(trim(requestin->list_0[1].errorcolumnmap))=0)
    SET requestin->list_0[1].errorcolumnmap = map_persist
   ELSE
    SET map_persist = requestin->list_0[1].errorcolumnmap
   ENDIF
   SET errmapparse = piece(requestin->list_0[1].errorcolumnmap,"|",piece_cnt,not_found,3)
   WHILE (errmapparse != not_found)
     SET private::colmap->cnt = piece_cnt
     SET stat = alterlist(private::colmap->data,piece_cnt)
     SET private::colmap->data[piece_cnt].field = cnvtupper(piece(errmapparse,":",1,not_found,3))
     SET private::colmap->data[piece_cnt].col = cnvtint(piece(errmapparse,":",2,not_found,3))
     SET piece_cnt += 1
     SET errmapparse = piece(requestin->list_0[1].errorcolumnmap,"|",piece_cnt,not_found,3)
   ENDWHILE
 END ;Subroutine
 DECLARE _::datavalidationsuccess(null) = i2
 SUBROUTINE _::datavalidationsuccess(null)
   DECLARE list_size = i4 WITH protect, constant(size(_::msg->list,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE success_ind = i2 WITH protect, noconstant(false)
   FOR (idx = 1 TO list_size)
     IF ((_::msg->list[idx].msg_cnt=0))
      SET cnt += 1
     ELSE
      SET idx = list_size
     ENDIF
   ENDFOR
   IF (cnt=list_size)
    SET success_ind = true
   ENDIF
   RETURN(success_ind)
 END ;Subroutine
 SUBROUTINE (_::createstatusmessages(audit_ind=i2) =null)
   DECLARE csv_row = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET PRIVATE::rows_processed = 0
   SET PRIVATE::rows_with_errors = 0
   FOR (csv_row = 1 TO size(_::msg->list,5))
    SET PRIVATE::rows_processed += 1
    IF ((_::msg->list[csv_row].msg_cnt > 0))
     SET PRIVATE::rows_with_errors += 1
     FOR (idx = 1 TO _::msg->list[csv_row].msg_cnt)
       IF (idx=1)
        SET _::msg->list[csv_row].full_msg = _::msg->list[csv_row].msg[idx].txt
       ELSE
        SET _::msg->list[csv_row].full_msg = build(_::msg->list[csv_row].full_msg,"|",_::msg->list[
         csv_row].msg[idx].txt)
       ENDIF
     ENDFOR
     FOR (idx = 1 TO _::msg->list[csv_row].cell_cnt)
       IF (idx=1)
        SET _::msg->list[csv_row].full_cell = _::msg->list[csv_row].cell[idx].cellref
       ELSE
        SET _::msg->list[csv_row].full_cell = build(_::msg->list[csv_row].full_cell,"|",_::msg->list[
         csv_row].cell[idx].cellref)
       ENDIF
     ENDFOR
    ELSEIF ((((_::msg->layout_error=true)) OR ((_::msg->general_system_error=true))) )
     SET PRIVATE::rows_with_errors += 1
     SET _::msg->list[csv_row].full_msg = " "
    ELSEIF (audit_ind=false)
     IF (size(trim(_::msg->list[csv_row].full_msg))=0)
      SET _::msg->list[csv_row].full_msg = "Audited Successfully"
     ELSE
      SET _::msg->list[csv_row].full_msg = build("Audited Successfully|",_::msg->list[csv_row].
       full_msg)
     ENDIF
    ELSEIF ((_::msg->list[csv_row].success_ind=true))
     IF (size(trim(_::msg->list[csv_row].full_msg))=0)
      SET _::msg->list[csv_row].full_msg = "Uploaded Successfully"
     ELSE
      SET _::msg->list[csv_row].full_msg = build("Uploaded Successfully|",_::msg->list[csv_row].
       full_msg)
     ENDIF
    ELSE
     SET PRIVATE::rows_with_errors += 1
     IF (size(trim(_::msg->list[csv_row].full_msg))=0)
      SET _::msg->list[csv_row].full_msg = "Skipped due to unexpected error"
     ELSE
      SET _::msg->list[csv_row].full_msg = build("Skipped due to unexpected error|",_::msg->list[
       csv_row].full_msg)
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
 DECLARE _::rowsprocessed(null) = i4
 SUBROUTINE _::rowsprocessed(null)
   RETURN(PRIVATE::rows_processed)
 END ;Subroutine
 DECLARE _::rowswitherrors(null) = i4
 SUBROUTINE _::rowswitherrors(null)
   RETURN(PRIVATE::rows_with_errors)
 END ;Subroutine
 SUBROUTINE (PRIVATE::errorcellref(r=i4,c=i4) =null)
   DECLARE cell_cnt = i4 WITH protect, noconstant(_::msg->list[r].cell_cnt)
   DECLARE row_ref = i4 WITH protect, noconstant(r)
   SET cell_cnt += 1
   SET _::msg->list[r].cell_cnt = cell_cnt
   SET stat = alterlist(_::msg->list[r].cell,cell_cnt)
   IF (dm_dbi_start_row > 1)
    SET row_ref += (dm_dbi_start_row - 1)
   ENDIF
   SET _::msg->list[r].cell[cell_cnt].cellref = build(row_ref,",",c)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS ctp_file_output
 init
 RECORD PRIVATE::grid(
   1 row[*]
     2 col[*]
       3 txt = vc
 )
 DECLARE PRIVATE::by_column = i2 WITH constant(0)
 DECLARE PRIVATE::by_row = i2 WITH constant(1)
 DECLARE PRIVATE::start_column = i4 WITH constant(0)
 DECLARE PRIVATE::start_row = i4 WITH constant(0)
 DECLARE PRIVATE::file_name = vc WITH noconstant(" ")
 DECLARE PRIVATE::current_column = i4 WITH noconstant(PRIVATE::start_column)
 DECLARE PRIVATE::current_row = i4 WITH noconstant(PRIVATE::start_row)
 DECLARE PRIVATE::batch_size = i4 WITH noconstant(10000)
 DECLARE PRIVATE::max_columns = i4 WITH noconstant(0)
 DECLARE PRIVATE::max_rows = i4 WITH noconstant(0)
 IF ( NOT (validate(PRIVATE::date_format)))
  DECLARE PRIVATE::date_format = vc WITH constant("DD-MMM-YYYY HH:MM:SS;;q")
 ENDIF
 SUBROUTINE (_::initialize(file_name=vc,batch_size=i4(value,0)) =null)
  SET PRIVATE::file_name = file_name
  IF (batch_size > 0)
   SET PRIVATE::batch_size = batch_size
  ENDIF
 END ;Subroutine
 DECLARE _::getfilename(null) = vc
 SUBROUTINE _::getfilename(null)
   RETURN(PRIVATE::file_name)
 END ;Subroutine
 SUBROUTINE (_::addheader(txt=vc) =null)
   SET PRIVATE::current_row = PRIVATE::start_row
   CALL PRIVATE::increment(PRIVATE::by_column)
   CALL PRIVATE::increment(PRIVATE::by_row)
   IF (size(private::grid->row,5)=0)
    SET stat = alterlist(private::grid->row,1)
   ENDIF
   SET stat = alterlist(private::grid->row[PRIVATE::current_row].col,PRIVATE::current_column)
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = cnvtupper(trim(txt,
     3))
   SET PRIVATE::max_columns = PRIVATE::current_column
 END ;Subroutine
 SUBROUTINE (_::setrowsizeif(row_size=i4,batch_ind=i2(value,0)) =null)
  DECLARE new_size = i4 WITH protect, noconstant(0)
  IF (row_size > size(private::grid->row,5))
   IF (batch_ind)
    SET new_size = (row_size+ PRIVATE::batch_size)
   ELSE
    SET new_size = row_size
   ENDIF
   SET stat = alterlist(private::grid->row,new_size)
  ENDIF
 END ;Subroutine
 SUBROUTINE (_::setcolumnsize(row_number=i4) =null)
   SET stat = alterlist(private::grid->row[row_number].col,PRIVATE::max_columns)
 END ;Subroutine
 DECLARE _::nextrow(null) = null
 SUBROUTINE _::nextrow(null)
   DECLARE increment_by_batchsize = i2 WITH protect, constant(1)
   CALL PRIVATE::increment(PRIVATE::by_row)
   SET PRIVATE::current_column = PRIVATE::start_column
   CALL _::setrowsizeif(PRIVATE::current_row,increment_by_batchsize)
   CALL _::setcolumnsize(PRIVATE::current_row)
 END ;Subroutine
 SUBROUTINE (_::addvalue(value=vc,direction=i2(value,0)) =null)
  DECLARE data_type = c1 WITH protect, noconstant(cnvtupper(reflect(value)))
  CASE (data_type)
   OF "C":
    CALL _::addtxt(value,direction)
   OF "G":
    CALL _::addtxt(" ",direction)
   OF "I":
    CALL _::addint(value,direction)
   OF "F":
    CALL _::addreal(value,0,direction)
   ELSE
    CALL cclexception(900,"E","REFLECT(unknown data type)")
  ENDCASE
 END ;Subroutine
 SUBROUTINE (_::addtxt(txt=vc,direction=i2(value,0)) =null)
  CALL PRIVATE::increment(direction)
  SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = check(txt)
 END ;Subroutine
 SUBROUTINE (_::addcomment(txt=vc,direction=i2(value,0)) =null)
   DECLARE cr = c1 WITH protect, constant(char(13))
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE subt = vc WITH protect, constant("%\l%")
   CALL PRIVATE::increment(direction)
   IF (check(txt) != txt)
    SET txt = replace(txt,cr,"")
    SET txt = check(replace(txt,lf,subt))
    SET txt = replace(txt,subt,lf)
   ENDIF
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = txt
 END ;Subroutine
 SUBROUTINE (_::addreal(real=f8,option=i2(value,0),direction=i2(value,0)) =null)
   DECLARE formatted = vc WITH protect, noconstant(" ")
   CASE (option)
    OF 0:
    OF 1:
     SET formatted = trim(format(real,"############.#####;T(1)"),3)
    OF 2:
     SET formatted = trim(format(real,"############.#####;T(2)"),3)
    OF 3:
     SET formatted = cnvtstring(real,19,2)
    ELSE
     SET formatted = trim(format(real,"############.#####;T(1)"),3)
   ENDCASE
   CALL PRIVATE::increment(direction)
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = formatted
 END ;Subroutine
 SUBROUTINE (_::addrealblank(real=f8,option=i2(value,0),direction=i2(value,0)) =null)
   IF (real=0.0)
    CALL PRIVATE::increment(direction)
    SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = " "
   ELSE
    CALL _::addreal(real,option,direction)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::addint(int=i4,direction=i2(value,0)) =null)
  CALL PRIVATE::increment(direction)
  SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = cnvtstring(int,19)
 END ;Subroutine
 SUBROUTINE (_::addintblank(int=i4,direction=i2(value,0)) =null)
  CALL PRIVATE::increment(direction)
  IF (int=0)
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = " "
  ELSE
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = cnvtstring(int,19)
  ENDIF
 END ;Subroutine
 SUBROUTINE (_::adddttm(dttm=dq8,date_format=vc(value," "),direction=i2(value,0)) =null)
   DECLARE mask = vc WITH protect, noconstant(" ")
   CALL PRIVATE::increment(direction)
   IF (size(trim(date_format))=0)
    SET mask = PRIVATE::date_format
   ELSE
    SET mask = date_format
   ENDIF
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = format(dttm,mask)
 END ;Subroutine
 SUBROUTINE (_::addind(ind=i2,direction=i2(value,0)) =null)
  CALL PRIVATE::increment(direction)
  SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = evaluate(ind,1,"X",
   " ")
 END ;Subroutine
 SUBROUTINE (_::addlist(rec_name=vc,list_name=vc,item_name=vc) =null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE full_item_path = vc WITH protect, noconstant(" ")
   DECLARE list_size = i4 WITH protect, noconstant(size(parser(build(rec_name,"->",list_name)),5))
   SET full_item_path = build(rec_name,"->",list_name,"[idx].",item_name)
   CALL _::setrowsizeif((list_size+ 1))
   FOR (idx = 1 TO list_size)
     CALL _::addsingle(parser(full_item_path))
   ENDFOR
 END ;Subroutine
 SUBROUTINE (_::addsingle(value=vc) =null WITH protect)
   DECLARE next_row = i4 WITH protect, noconstant((PRIVATE::current_row+ 1))
   CALL _::setrowsizeif(next_row)
   CALL _::setcolumnsize(next_row)
   CALL _::addvalue(value,PRIVATE::by_row)
 END ;Subroutine
 SUBROUTINE (PRIVATE::increment(direction=i2) =null)
   IF ((direction=PRIVATE::by_row))
    SET PRIVATE::current_row += 1
    IF ((PRIVATE::current_row > PRIVATE::max_rows))
     SET PRIVATE::max_rows = PRIVATE::current_row
    ENDIF
   ELSE
    SET PRIVATE::current_column += 1
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::delimitedoutput(delim=vc,append_ind=i2(value,0),skip_q_chk=i2(value,0)) =i2)
   RECORD out_file(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   ) WITH protect
   DECLARE enq = c1 WITH protect, constant(char(5))
   DECLARE cr = c1 WITH protect, constant(char(13))
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE q = c1 WITH protect, constant(char(34))
   DECLARE start_row = i4 WITH protect, noconstant(1)
   DECLARE r = i4 WITH protect, noconstant(0)
   DECLARE c = i4 WITH protect, noconstant(0)
   DECLARE line = vc WITH protect, noconstant(" ")
   DECLARE str = vc WITH protect, noconstant(" ")
   DECLARE q_ind = i2 WITH protect, noconstant(0)
   SET stat = alterlist(private::grid->row,PRIVATE::max_rows)
   SET out_file->file_name = PRIVATE::file_name
   SET out_file->file_buf = evaluate(append_ind,1,"a","w")
   SET stat = cclio("OPEN",out_file)
   IF (stat=1)
    FOR (r = start_row TO size(private::grid->row,5))
      SET line = " "
      FOR (c = 1 TO size(private::grid->row[r].col,5))
        SET str = private::grid->row[r].col[c].txt
        SET q_ind = false
        IF (skip_q_chk=0)
         IF (findstring(q,str) > 0)
          SET str = replace(str,q,fillstring(2,q))
          SET q_ind = true
         ENDIF
        ENDIF
        IF (((findstring(delim,str) > 0) OR (((q_ind) OR (check(str) != str)) )) )
         IF (c=1)
          SET line = build(q,str,q)
         ELSE
          SET line = build(line,enq,q,str,q)
         ENDIF
        ELSE
         IF (c=1)
          SET line = str
         ELSE
          SET line = build(line,enq,str)
         ENDIF
        ENDIF
      ENDFOR
      SET line = trim(line)
      IF (size(line) > 0)
       SET line = replace(line,enq,delim)
       SET out_file->file_buf = build(line,cr,lf)
       SET stat = cclio("WRITE",out_file)
       IF (stat=0)
        CALL cclexception(900,"E","CCLIO:Could not write to the file!")
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    CALL cclexception(900,"E","CCLIO:Could not open file!")
    RETURN(0)
   ENDIF
   SET stat = cclio("CLOSE",out_file)
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS ctp_ip_script_ccl
 init
 RECORD _::request(
   1 dynamic = i1
 )
 RECORD _::reply(
   1 dynamic = i1
 )
 DECLARE PRIVATE::success_map(mode=vc,mapkey=vc,mapval=i1) = i4 WITH map = "hash"
 DECLARE PRIVATE::err_msg = vc WITH noconstant(" ")
 DECLARE PRIVATE::enabled_options = i2 WITH noconstant(0)
 DECLARE PRIVATE::first_enable_check = i2 WITH noconstant(true)
 IF ( NOT (validate(PRIVATE::free_reply)))
  DECLARE PRIVATE::free_reply = i2 WITH constant(0)
 ENDIF
 IF ( NOT (validate(PRIVATE::success_status)))
  DECLARE PRIVATE::success_status = vc WITH constant("S|Z")
 ENDIF
 IF ( NOT (validate(PRIVATE::commit_ind_check)))
  DECLARE PRIVATE::commit_ind_check = i2 WITH constant(0)
 ENDIF
 IF ( NOT (validate(PRIVATE::skip_commit_ind_check)))
  DECLARE PRIVATE::skip_commit_ind_check = i2 WITH constant(0)
 ENDIF
 DECLARE _::initialize(null) = null
 SUBROUTINE _::initialize(null)
   SET stat = initrec(_::request)
   SET stat = initrec(_::reply)
   SET PRIVATE::err_msg = " "
 END ;Subroutine
 DECLARE _::geterror(null) = vc
 SUBROUTINE _::geterror(null)
  IF (size(trim(PRIVATE::err_msg))=0)
   SET PRIVATE::err_msg = concat(PRIVATE::object_name," unknown error")
  ENDIF
  RETURN(PRIVATE::err_msg)
 END ;Subroutine
 DECLARE _::perform(null) = i2
 SUBROUTINE _::perform(null)
   DECLARE _status = i2 WITH protect, noconstant(0)
   SET _status = PRIVATE::performwrapper(0)
   RETURN(_status)
 END ;Subroutine
 DECLARE PRIVATE::performwrapper(null) = i2
 SUBROUTINE PRIVATE::performwrapper(null)
   SET reqinfo->commit_ind = false
   IF (error(PRIVATE::err_msg,0))
    RETURN(0)
   ENDIF
   CALL PRIVATE::enableobjectoptions(0)
   CALL PRIVATE::executewithreplace(_::request,_::reply)
   CALL PRIVATE::disableobjectoptions(0)
   DECLARE success = i1 WITH protect, noconstant(0)
   IF (error(PRIVATE::err_msg,0)=0)
    SET success = true
   ENDIF
   IF (success)
    IF (validate(_::reply->status_data.status))
     IF (PRIVATE::successful(_::reply->status_data.status))
      SET success = true
     ELSE
      SET PRIVATE::err_msg = PRIVATE::buildstatusblockmsg(0)
      SET success = false
     ENDIF
    ELSEIF (validate(_::reply->status_block.status_ind))
     IF ((_::reply->status_block.status_ind=1))
      SET success = true
     ELSE
      SET PRIVATE::err_msg = PRIVATE::buildstatusmsg(_::reply->status_block.status_code)
      SET success = false
     ENDIF
    ELSE
     SET PRIVATE::err_msg = concat(PRIVATE::object_name," unknown reply status method")
     SET success = false
    ENDIF
   ENDIF
   IF (success)
    IF ( NOT (PRIVATE::skip_commit_ind_check))
     IF (((PRIVATE::commit_ind_check
      AND (reqinfo->commit_ind=true)) OR ( NOT (PRIVATE::commit_ind_check)
      AND (reqinfo->commit_ind=false))) )
      SET success = true
     ELSE
      SET PRIVATE::err_msg = concat(PRIVATE::object_name," COMMIT_IND returned '",build(reqinfo->
        commit_ind),"'")
      SET success = false
     ENDIF
    ENDIF
   ENDIF
   SET reqinfo->commit_ind = false
   IF (success)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::executewithreplace(request=vc(ref),reply=vc(ref)) =null)
  IF (PRIVATE::free_reply)
   RECORD reply(
     1 dummy = i1
   ) WITH protect
  ENDIF
  EXECUTE value(PRIVATE::object_name)
 END ;Subroutine
 DECLARE PRIVATE::enableobjectoptions(null) = null
 SUBROUTINE PRIVATE::enableobjectoptions(null)
   IF (((PRIVATE::first_enable_check) OR (PRIVATE::enabled_options)) )
    IF (PRIVATE::ctrlobjectoptions(1))
     SET PRIVATE::enabled_options = true
    ELSE
     SET PRIVATE::first_enable_check = false
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE PRIVATE::disableobjectoptions(null) = null
 SUBROUTINE PRIVATE::disableobjectoptions(null)
   IF (PRIVATE::enabled_options)
    CALL PRIVATE::ctrlobjectoptions(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::ctrlobjectoptions(_enable_ind=i2(value,0)) =i2)
   DECLARE _exists_ind = i2 WITH protect, noconstant(0)
   IF (validate(_set_trace_nocallecho_))
    IF (_enable_ind)
     SET trace = nocallecho
    ELSE
     SET trace = callecho
    ENDIF
    SET _exists_ind = true
   ENDIF
   IF (validate(_set_message_noinformation_))
    IF (_enable_ind)
     SET message = noinformation
    ELSE
     SET message = information
    ENDIF
    SET _exists_ind = true
   ENDIF
   IF (validate(_set_trace_nowarning_))
    IF (_enable_ind)
     SET trace = nowarning
    ELSE
     SET trace = warning
    ENDIF
    SET _exists_ind = true
   ENDIF
   IF (validate(_set_trace_nowarning2_))
    IF (_enable_ind)
     SET trace = nowarning2
    ELSE
     SET trace = warning2
    ENDIF
    SET _exists_ind = true
   ENDIF
   IF (validate(_set_trace_noechosub_))
    IF (_enable_ind)
     SET trace = noechosub
    ELSE
     SET trace = echosub
    ENDIF
    SET _exists_ind = true
   ENDIF
   IF (validate(_set_trace_noechoprog_))
    IF (_enable_ind)
     SET trace = noechoprog
    ELSE
     SET trace = echoprog
    ENDIF
    SET _exists_ind = true
   ENDIF
   IF (validate(_set_trace_echosub_))
    IF (_enable_ind)
     SET trace = echosub
    ELSE
     SET trace = noechosub
    ENDIF
    SET _exists_ind = true
   ENDIF
   IF (validate(_set_trace_echoprog_))
    IF (_enable_ind)
     SET trace = echoprog
    ELSE
     SET trace = noechoprog
    ENDIF
    SET _exists_ind = true
   ENDIF
   IF (validate(_set_trace_rdbdebug_))
    IF (_enable_ind)
     SET trace = rdbdebug
    ELSE
     SET trace = nordbdebug
    ENDIF
    SET _exists_ind = true
   ENDIF
   IF (validate(_set_trace_rdbbind_))
    IF (_enable_ind)
     SET trace = rdbbind
    ELSE
     SET trace = nordbbind
    ENDIF
    SET _exists_ind = true
   ENDIF
   IF (_enable_ind
    AND _exists_ind)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::successful(return_status=vc) =i2)
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE item = vc WITH protect, noconstant(" ")
   DECLARE mapkey = i1 WITH protect, noconstant(0)
   DECLARE status = i1 WITH protect, noconstant(0)
   IF (PRIVATE::success_map("Count")=0)
    SET cnt = 1
    SET item = piece(PRIVATE::success_status,"|",cnt,not_found)
    WHILE (item != not_found)
      SET status = PRIVATE::success_map("Add",cnvtupper(trim(item,3)),1)
      SET cnt += 1
      SET item = piece(PRIVATE::success_status,"|",cnt,not_found)
    ENDWHILE
   ENDIF
   IF (PRIVATE::success_map("Find",cnvtupper(trim(return_status,3)),mapkey))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE PRIVATE::buildstatusblockmsg(null) = vc
 SUBROUTINE PRIVATE::buildstatusblockmsg(null)
   DECLARE status_msg = vc WITH protect, noconstant(" ")
   DECLARE sub_status_msg = vc WITH protect, noconstant(" ")
   SET status_msg = PRIVATE::buildstatusmsg(_::reply->status_data.status)
   SET sub_status_msg = PRIVATE::buildsubstatusmsg(0)
   IF (size(trim(sub_status_msg)) > 0)
    SET status_msg = concat(status_msg," (",sub_status_msg,")")
   ENDIF
   RETURN(status_msg)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildstatusmsg(status_varient=vc) =vc)
   DECLARE msg = vc WITH protect, noconstant(" ")
   SET msg = concat(PRIVATE::object_name," returned '",trim(build(status_varient),3),"'")
   RETURN(msg)
 END ;Subroutine
 DECLARE PRIVATE::buildsubstatusmsg(null) = vc
 SUBROUTINE PRIVATE::buildsubstatusmsg(null)
   DECLARE enq = c1 WITH protect, constant(char(5))
   DECLARE sub_status_msg = vc WITH protect, noconstant(" ")
   IF (validate(_::reply->status_data.subeventstatus))
    IF (size(_::reply->status_data.subeventstatus,5) > 0)
     SET sub_status_msg = build(_::reply->status_data.subeventstatus[1].operationname,enq,_::reply->
      status_data.subeventstatus[1].operationstatus,enq,_::reply->status_data.subeventstatus[1].
      targetobjectname,
      enq,_::reply->status_data.subeventstatus[1].targetobjectvalue)
     IF (size(trim(sub_status_msg)) > 0)
      SET sub_status_msg = replace(trim(sub_status_msg,3),enq,":")
     ELSE
      SET sub_status_msg = " "
     ENDIF
    ENDIF
   ENDIF
   RETURN(sub_status_msg)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS ctp_scp
 init
 DECLARE _::backend = i1 WITH constant(- (1))
 DECLARE _::unknown = i1 WITH constant(0)
 DECLARE _::inactive = i1 WITH constant(1)
 DECLARE _::initialized = i1 WITH constant(2)
 DECLARE _::starting = i1 WITH constant(3)
 DECLARE _::running = i1 WITH constant(4)
 DECLARE _::stopping = i1 WITH constant(5)
 DECLARE _::stopped = i1 WITH constant(6)
 DECLARE _::aborted = i1 WITH constant(7)
 DECLARE _::registered = i1 WITH constant(8)
 DECLARE _::unregistered = i1 WITH constant(9)
 DECLARE _::queryprocess = i1 WITH protect, constant(31)
 DECLARE PRIVATE::uar_scpcreate(p1=vc(ref)) = i4 WITH image_axp = "dpsrtl", image_aix =
 "libdps.a(libdps.o)", uar = "ScpCreate"
 DECLARE PRIVATE::uar_scpdestroy(p1=i4(value)) = null WITH image_axp = "dpsrtl", image_aix =
 "libdps.a(libdps.o)", uar = "ScpDestroy"
 DECLARE PRIVATE::uar_scpselect(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dpsrtl", image_aix
  = "libdps.a(libdps.o)", uar = "ScpSelect"
 DECLARE PRIVATE::pid = vc WITH noconstant(" ")
 RECORD PRIVATE::handles(
   1 scp = i4
   1 msg = i4
   1 req = i4
   1 rep = i4
 )
 DECLARE _::getpid(null) = vc
 SUBROUTINE _::getpid(null)
   DECLARE pid = vc WITH protect, noconstant(" ")
   IF (curserver > 0)
    SELECT INTO "nl:"
     FROM v$session vs
     PLAN (vs
      WHERE vs.audsid=cnvtreal(currdbhandle))
     DETAIL
      pid = vs.process
     WITH nocounter
    ;end select
   ENDIF
   RETURN(pid)
 END ;Subroutine
 SUBROUTINE (PRIVATE::scpcreate(operation=i4) =i1)
   SET stat = initrec(PRIVATE::handles)
   SET private::handles->scp = PRIVATE::uar_scpcreate(nullterm(curnode))
   SET private::handles->msg = PRIVATE::uar_scpselect(private::handles->scp,operation)
   SET private::handles->req = uar_srvcreaterequest(private::handles->msg)
   SET private::handles->rep = uar_srvcreatereply(private::handles->msg)
   IF ((private::handles->rep > 0))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE PRIVATE::scpdestroy(null) = null
 SUBROUTINE PRIVATE::scpdestroy(null)
   CALL uar_srvdestroyinstance(private::handles->rep)
   CALL uar_srvdestroyinstance(private::handles->req)
   CALL uar_srvdestroymessage(private::handles->msg)
   CALL PRIVATE::uar_scpdestroy(private::handles->scp)
 END ;Subroutine
 DECLARE PRIVATE::scpexecute(null) = i4
 SUBROUTINE PRIVATE::scpexecute(null)
  SET stat = uar_srvexecute(private::handles->msg,private::handles->req,private::handles->rep)
  RETURN(stat)
 END ;Subroutine
 DECLARE _::state(null) = i1
 SUBROUTINE _::state(null)
   DECLARE server_state = i1 WITH protect, noconstant(_::unknown)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   IF (curserver=0)
    RETURN(_::backend)
   ENDIF
   IF (size(trim(PRIVATE::pid))=0)
    SET PRIVATE::pid = _::getpid(0)
   ENDIF
   CALL PRIVATE::scpcreate(_::queryprocess)
   SET hitem = uar_srvadditem(private::handles->req,"pidList")
   SET stat = uar_srvsetstring(hitem,"processId",nullterm(PRIVATE::pid))
   CALL PRIVATE::scpexecute(0)
   IF (uar_srvgetitemcount(private::handles->rep,"serverList")=1)
    SET hitem = uar_srvgetitem(private::handles->rep,"serverList",0)
    SET server_state = uar_srvgetulong(hitem,"state")
   ENDIF
   CALL PRIVATE::scpdestroy(0)
   RETURN(server_state)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS emailvalidation
 init
 SUBROUTINE (_::validation(emailtxt=vc) =i2)
   DECLARE PRIVATE::regexpattern = vc WITH protect, constant(
    "^[A-Za-z0-9._%+-]*@{1}[A-Za-z0-9.-]*.{1}[A-Za-z]{2,}$")
   SET stat = 0
   SET stat = operator(emailtxt,"REGEXPLIKE",PRIVATE::regexpattern)
   IF (stat=1)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS datetimevalidation
 init
 SUBROUTINE (_::validation(date_str=vc) =i2)
   DECLARE date_format_yyyy = vc WITH protect, noconstant(" ")
   DECLARE date_format_yy = vc WITH protect, noconstant(" ")
   DECLARE date_str_11 = c11 WITH protect, noconstant(date_str)
   IF (size(trim(date_str,3)) BETWEEN 8 AND 11
    AND cnvtdatetime(date_str_11) > 0)
    SET date_format_yyyy = format(cnvtdatetime(date_str_11),"DD-MMM-YYYY;;d")
    SET date_format_yy = format(cnvtdatetime(date_str_11),"DD-MMM-YY;;d")
    IF (substring(1,1,date_format_yyyy)="0")
     SET date_format_yyyy = trim(substring(2,textlen(date_format_yyyy),date_format_yyyy))
    ENDIF
    IF (substring(1,1,date_format_yy)="0")
     SET date_format_yy = trim(substring(2,textlen(date_format_yy),date_format_yy))
    ENDIF
    IF (((format(cnvtdatetime(date_str_11),"DD-MMM-YYYY;;d")=cnvtupper(trim(date_str,3))) OR (((
    format(cnvtdatetime(date_str_11),"DD-MMM-YY;;d")=cnvtupper(trim(date_str,3))) OR (((
    date_format_yyyy=cnvtupper(trim(date_str,3))) OR (date_format_yy=cnvtupper(trim(date_str,3))))
    )) )) )
     RETURN(true)
    ELSE
     RETURN(false)
    ENDIF
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS ctp_function_checks
 init
 SUBROUTINE (_::isempty(value=vc) =i2 WITH protect)
   IF (size(trim(value)) > 0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::isinteger(value=vc) =i2 WITH protect)
   IF ( NOT (_::isempty(value))
    AND isnumeric(value)=1)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::isreal(value=vc) =i2 WITH protect)
   IF ( NOT (_::isempty(value))
    AND isnumeric(value) >= 1)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::ischeckbox(value=vc) =i2 WITH protect)
   IF (((size(trim(value))=0) OR (cnvtupper(trim(value,3))="X")) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::cnvtcheckbox(value=vc) =i2 WITH protect)
   IF (cnvtupper(trim(value,3))="X")
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS ctpdbg
 init
 RECORD PRIVATE::cache(
   1 cnt = i4
   1 list[*]
     2 txt = vc
 )
 DECLARE PRIVATE::enabled = i1 WITH noconstant(0)
 DECLARE PRIVATE::file_id = vc WITH constant(trim(cnvtstring(currdbhandle),3))
 DECLARE PRIVATE::timestamp = dm12 WITH constant(systimestamp)
 DECLARE PRIVATE::dir = vc WITH constant(logical("cer_temp"))
 DECLARE _::file_path_rec = vc WITH noconstant(" ")
 DECLARE _::file_path = vc WITH noconstant(" ")
 DECLARE _::cache_ind = i1 WITH noconstant(0)
 SET _::file_path = concat(PRIVATE::dir,"/ctpdbg",concat(PRIVATE::file_id,"_",format(PRIVATE::
    timestamp,"HHMMSS;;q")),".txt")
 SET _::file_path_rec = concat(PRIVATE::dir,"/ctpdbgrec",concat(PRIVATE::file_id,"_",format(PRIVATE::
    timestamp,"HHMMSS;;q")),".txt")
 DECLARE _::enable(null) = null
 SUBROUTINE _::enable(null)
   SET PRIVATE::enabled = true
 END ;Subroutine
 DECLARE _::finalize(null) = null
 SUBROUTINE _::finalize(null)
   IF ( NOT (PRIVATE::enabled))
    RETURN
   ENDIF
   IF ( NOT (_::cache_ind))
    RETURN
   ENDIF
   SET stat = alterlist(private::cache->list,private::cache->cnt)
   RECORD file(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   ) WITH protect
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET file->file_name = _::file_path
   SET file->file_buf = "a"
   SET stat = cclio("OPEN",file)
   FOR (idx = 1 TO private::cache->cnt)
    SET file->file_buf = notrim(concat(private::cache->list[idx].txt,lf))
    SET stat = cclio("WRITE",file)
   ENDFOR
   SET stat = cclio("CLOSE",file)
 END ;Subroutine
 SUBROUTINE (_::put(msg=vc,p2=vc(value," ")) =null)
   IF ( NOT (PRIVATE::enabled))
    RETURN
   ENDIF
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE full_msg = vc WITH protect, noconstant(" ")
   DECLARE timestamp = dm12 WITH protect, noconstant(systimestamp)
   DECLARE diff = f8 WITH protect, noconstant(timestampdiff(timestamp,PRIVATE::timestamp))
   CASE (cnvtupper(trim(msg)))
    OF "_CURMEM_":
     SET full_msg = concat("CURMEM!",cnvtstring(curmem))
    OF "_TIMESTAMP_":
     SET full_msg = concat("TIMESTAMP|",format(timestamp,"dd-mmm-yyyy hh:mm:ss.cccccc;;d"),"|",
      cnvtstring(diff,17,6))
    OF "_=_":
     SET full_msg = fillstring(40,"=")
    ELSE
     SET full_msg = msg
   ENDCASE
   CASE (cnvtupper(trim(p2)))
    OF "_CURMEM_":
     SET full_msg = concat(full_msg,"!CURMEM!",cnvtstring(curmem))
    OF "_TIMESTAMP_":
     SET full_msg = concat(full_msg,"|TIMESTAMP|",format(timestamp,"dd-mmm-yyyy hh:mm:ss.cccccc;;d"),
      "|",cnvtstring(diff,17,6))
   ENDCASE
   IF (_::cache_ind)
    SET private::cache->cnt += 1
    IF (mod(private::cache->cnt,100000)=1)
     SET stat = alterlist(private::cache->list,(private::cache->cnt+ 99999))
    ENDIF
    SET private::cache->list[private::cache->cnt].txt = full_msg
    RETURN
   ENDIF
   RECORD file(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   ) WITH protect
   SET file->file_name = _::file_path
   SET file->file_buf = "a"
   SET stat = cclio("OPEN",file)
   SET file->file_buf = notrim(concat(full_msg,lf))
   SET stat = cclio("WRITE",file)
   SET stat = cclio("CLOSE",file)
 END ;Subroutine
 SUBROUTINE (_::putrec(rec=vc(ref)) =null)
   CALL echoxml(rec,_::file_path_rec,1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS hybrid_time_zones
 init
 CALL echo("+++ hybrid_time_zones instantiated")
 RECORD _::allzones(
   1 zone[*]
     2 time_zone = vc
     2 time_zone_idx = i4
     2 time_zone_id = f8
     2 region = vc
 ) WITH protect
 RECORD _::filterzones(
   1 zone[*]
     2 time_zone = vc
     2 time_zone_idx = i4
     2 time_zone_id = f8
     2 region = vc
 ) WITH protect
 RECORD _::hybridzones(
   1 zone[*]
     2 time_zone = vc
     2 time_zone_idx = i4
     2 time_zone_id = f8
     2 region = vc
 ) WITH protect
 DECLARE _::this = i1 WITH noconstant(0), protect
 DECLARE _::ld = f8 WITH noconstant(0.0), protect
 DECLARE _::offset = i4 WITH noconstant(0), protect
 DECLARE _::daylight = i4 WITH noconstant(0), protect
 DECLARE _::mode = i4 WITH noconstant(0), protect
 DECLARE _::tidx = i4 WITH noconstant(0), protect
 DECLARE PRIVATE::instance_name = vc WITH constant(piece(class(_::this,2,0),".",1,"{::}"))
 DECLARE _::full = i2 WITH constant(1), protect
 DECLARE _::filtered = i2 WITH constant(2), protect
 DECLARE _::ld_mode_0 = i4 WITH constant(0), protect
 DECLARE _::sd_mode_1 = i4 WITH constant(1), protect
 DECLARE _::ls_mode_2 = i4 WITH constant(2), protect
 DECLARE _::ss_mode_3 = i4 WITH constant(3), protect
 DECLARE _::l_day_mode_4 = i4 WITH constant(4), protect
 DECLARE _::s_day_mode_5 = i4 WITH constant(5), protect
 DECLARE _::l_day_or_ls_mode_6 = i4 WITH constant(6), protect
 DECLARE _::s_day_or_ls_mode_7 = i4 WITH constant(7), protect
 DECLARE _::default_mode_8 = i4 WITH constant(8), protect
 SUBROUTINE (_::getall(oset=i4,dlight=i4,zmode=i4) =i4)
   DECLARE no_zone = vc WITH constant(""), protect
   DECLARE tz_name = vc WITH noconstant(" "), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(1), protect
   SET tz_name = datetimezonebyindex(idx,oset,dlight,zmode)
   IF (tz_name != no_zone)
    WHILE (tz_name != no_zone)
      SET cnt += 1
      SET stat = alterlist(_::allzones->zone,cnt)
      SET _::allzones->zone[cnt].time_zone = tz_name
      SET _::allzones->zone[cnt].time_zone_idx = idx
      SET idx += 1
      SET tz_name = datetimezonebyindex(idx,oset,dlight,zmode)
    ENDWHILE
   ELSE
    RETURN(0)
   ENDIF
   RETURN(cnt)
 END ;Subroutine
 DECLARE _::getelement(null) = i2
 SUBROUTINE _::getelement(null)
   DECLARE ensorgreq = i4 WITH constant(4410824)
   DECLARE hmsg = i4 WITH noconstant(0), protect
   DECLARE hreq = i4 WITH noconstant(0), protect
   DECLARE horg = i4 WITH noconstant(0), protect
   DECLARE hfac = i4 WITH noconstant(0), protect
   DECLARE hext = i2 WITH noconstant(0), protect
   SET hmsg = uar_srvselectmessage(ensorgreq)
   SET hreq = uar_srvcreaterequest(hmsg)
   SET horg = uar_srvadditem(hreq,"org")
   SET hfac = uar_srvgetstruct(horg,"facility")
   SET hext = uar_srvfieldexists(hfac,"time_zone_display")
   CALL uar_srvdestroyinstance(hreq)
   CALL uar_srvdestroymessage(hmsg)
   RETURN(hext)
 END ;Subroutine
 DECLARE _::getfiltered(null) = i2
 SUBROUTINE _::getfiltered(null)
   DECLARE cnt = i4 WITH noconstant(0), protect
   IF (size(_::allzones->zone,5) > 0
    AND size(_::filterzones->zone,5) > 0)
    SELECT INTO "nl:"
     allzone = substring(1,100,_::allzones->zone[d1.seq].time_zone), allidx = _::allzones->zone[d1
     .seq].time_zone_idx, filtzone = substring(1,100,_::filterzones->zone[d2.seq].time_zone)
     FROM (dummyt d1  WITH seq = size(_::allzones->zone,5)),
      (dummyt d2  WITH seq = size(_::filterzones->zone,5))
     PLAN (d1)
      JOIN (d2
      WHERE (_::filterzones->zone[d2.seq].time_zone=_::allzones->zone[d1.seq].time_zone))
     ORDER BY allidx
     DETAIL
      cnt += 1
      IF (mod(cnt,100)=1)
       stat = alterlist(_::hybridzones->zone,(cnt+ 99))
      ENDIF
      _::hybridzones->zone[cnt].time_zone = allzone, _::hybridzones->zone[cnt].time_zone_idx = allidx
     FOOT REPORT
      stat = alterlist(_::hybridzones->zone,cnt)
     WITH nocounter
    ;end select
   ELSE
    RETURN(0)
   ENDIF
   IF (cnt > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::getzoneids(type=i2) =i2)
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE pos = i4 WITH noconstant(0), protect
   DECLARE pstring = vc WITH noconstant("1=1"), protect
   CASE (type)
    OF _::full:
     SET pstring = concat("expand(","idx",",1,size(",PRIVATE::instance_name,".allzones->zone,5),",
      "btz.time_zone",",",PRIVATE::instance_name,".allzones->zone[idx].time_zone)")
    OF _::filtered:
     SET pstring = concat("expand(","idx",",1,size(",PRIVATE::instance_name,".hybridZones->zone,5),",
      "btz.time_zone",",",PRIVATE::instance_name,".hybridZones->zone[idx].time_zone)")
   ENDCASE
   SELECT INTO "nl:"
    FROM br_time_zone btz,
     br_client bc
    PLAN (btz
     WHERE parser(pstring)
      AND btz.active_ind=1)
     JOIN (bc
     WHERE bc.region=btz.region)
    DETAIL
     CASE (type)
      OF _::full:
       pos = locateval(idx,1,size(_::allzones->zone,5),btz.time_zone,_::allzones->zone[idx].time_zone
        ),
       IF (pos > 0)
        _::allzones->zone[pos].time_zone_id = btz.time_zone_id, _::allzones->zone[pos].region = bc
        .region
       ENDIF
      OF _::filtered:
       pos = locateval(idx,1,size(_::hybridzones->zone,5),btz.time_zone,_::hybridzones->zone[idx].
        time_zone),
       IF (pos > 0)
        _::hybridzones->zone[pos].time_zone_id = btz.time_zone_id, _::hybridzones->zone[pos].region
         = bc.region
       ENDIF
     ENDCASE
    WITH expand = 2
   ;end select
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- hybrid_time_zones out of scope")
 END; class scope:final
 WITH copy = 1
END GO

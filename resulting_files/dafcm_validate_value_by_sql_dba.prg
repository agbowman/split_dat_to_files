CREATE PROGRAM dafcm_validate_value_by_sql:dba
 DECLARE display_data_type = i2 WITH private
 DECLARE first_select_column = vc WITH private
 DECLARE key_data_type = i2 WITH private
 DECLARE second_select_column = vc WITH private
 DECLARE rec_count = f8 WITH private
 DECLARE select_construct = vc WITH private
 DECLARE from_construct = vc WITH private
 DECLARE where_construct = vc WITH private
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE select_statement = vc WITH private
 DECLARE rec_exist = vc WITH noconstant("")
 SET rec_exist = validate(reply->display_list,"N")
 IF (rec_exist="N")
  FREE SET reply
  RECORD reply(
    1 display_list[*]
      2 display = vc
      2 display_key = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "S"
 CALL checkinput(0," ",request->display_column_table)
 IF ((reply->status_data.status="S"))
  CALL checkinput(0," ",request->key_column_table)
  IF ((reply->status_data.status="S"))
   CALL checkinput(1,request->display_column_name,request->display_column_table)
   IF ((reply->status_data.status="S"))
    CALL checkinput(1,request->key_column_name,request->key_column_table)
    IF ((reply->status_data.status="S"))
     SET display_data_type = findcolumndatatype(request->display_column_table,request->
      display_column_name)
     SET first_select_column = formatcolumn(0,request->display_column_name,1,display_data_type)
     SET key_data_type = findcolumndatatype(request->key_column_table,request->key_column_name)
     SET second_select_column = formatcolumn(1,request->key_column_name,2,key_data_type)
     SET select_construct = build2(first_select_column," ,",second_select_column)
     SET from_construct = build2(" from"," ",request->table_name)
     SET where_construct = build2(" where"," ",request->where_statement)
     CALL parser('select distinct into "NL:"',0)
     CALL parser(select_construct,0)
     CALL parser(from_construct,0)
     CALL parser(where_construct,0)
     CALL parser("head report",0)
     CALL parser("   rec_count = 0",0)
     CALL parser("   stat = ALTERLIST(reply->display_list, 10)",0)
     CALL parser("detail",0)
     CALL parser("   rec_count = rec_count + 1",0)
     CALL parser("   IF (MOD(rec_count,10) = 0)",0)
     CALL parser("     STAT = ALTERLIST(reply->display_list, rec_count + 10)",0)
     CALL parser("   ENDIF",0)
     CALL parser("   reply->display_list[rec_count].display = mydisplay",0)
     CALL parser("   reply->display_list[rec_count].display_key = displaykey",0)
     CALL parser("foot report",0)
     CALL parser("   STAT = ALTERLIST(reply->display_list,rec_count)",0)
     CALL parser("   row+1",0)
     CALL parser("with nocounter, SEPARATOR=' ' ,FORMAT ,format(date,'dd-mmm-yyyy hh:mm:ss;;d') go",1
      )
     IF (error(err_msg,1) > 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "dafcm_validate_value_by_sql"
      SET select_statement = build2("Failed to retrieve data:"," ",err_msg," Select"," ",
       select_construct," ",from_construct," ",where_construct)
      IF (textlen(select_statement) > 236)
       SET select_statement = substring(1,235,select_statement)
      ENDIF
      SET reply->status_data.subeventstatus.targetobjectvalue = build2(textlen(select_statement)," ",
       select_statement)
     ENDIF
     IF ((reply->status_data.status="S"))
      IF (curqual=0)
       SET reply->status_data.status = "Z"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "No Record Found."
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE (formatcolumn(fc_column_order=i2,fc_column_name=vc,fc_column_type=i2,fc_data_type=i2) =vc
   WITH protect)
   DECLARE fc_formated_name = vc WITH private
   IF (fc_column_type=1)
    SET fc_formated_name = " mydisplay ="
   ELSE
    SET fc_formated_name = " displaykey ="
   ENDIF
   IF (fc_data_type=0)
    SET fc_formated_name = build2(fc_formated_name," ",fc_column_name)
   ELSE
    IF (fc_data_type=1)
     SET fc_formated_name = build2(fc_formated_name," cnvtstring(",fc_column_name,", 20, 2)")
    ELSE
     IF (fc_data_type=2)
      IF (fc_column_order=0)
       SET fc_formated_name = build2(fc_formated_name," format(",fc_column_name,', "MM/DD/YYYY")')
      ELSE
       SET fc_formated_name = build2(fc_formated_name," format(",fc_column_name,
        ', "yyyymmddhhmmss000000")')
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(fc_formated_name)
 END ;Subroutine
 SUBROUTINE (stripalias(sa_column_name=vc) =vc WITH protect)
   DECLARE sa_return_value = vc WITH private
   DECLARE pos = i4 WITH private
   SET pos = findstring(".",sa_column_name)
   IF (pos=0)
    SET sa_return_value = sa_column_name
   ELSE
    SET sa_return_value = substring((pos+ 1),(textlen(sa_column_name) - 1),sa_column_name)
   ENDIF
   RETURN(sa_return_value)
 END ;Subroutine
 SUBROUTINE (findcolumndatatype(fct_table_name=vc,fct_column_name=vc) =i2 WITH protect)
   DECLARE fct_column_data_type = i2 WITH noconstant(3)
   DECLARE fct_formatted_name = vc
   SET fct_formatted_name = stripalias(fct_column_name)
   IF (textlen(fct_column_name) > 0)
    IF (textlen(fct_table_name) > 0)
     SELECT INTO "NL:"
      dt = data_type
      FROM user_tab_columns
      WHERE table_name=cnvtupper(fct_table_name)
       AND cnvtupper(column_name)=cnvtupper(fct_formatted_name)
      DETAIL
       IF (dt="VARCHAR2")
        fct_column_data_type = 0
       ELSE
        IF (dt="NUMBER")
         fct_column_data_type = 1
        ELSE
         IF (dt="DATE")
          fct_column_data_type = 2
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (error(err_msg,1) > 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
      SET reply->status_data.subeventstatus[1].targetobjectname = "findcolumndatatype"
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   RETURN(fct_column_data_type)
 END ;Subroutine
 SUBROUTINE (checkinput(ci_check_type=i2,ci_check_column_name=vc,ci_check_table_name=vc) =null WITH
  protect)
   DECLARE ci_check_table_name_upper = vc WITH protect
   DECLARE ci_formatted_column_name_upper = vc WITH protect
   DECLARE ci_row_count = i4 WITH protect
   SET ci_check_table_name_upper = cnvtupper(ci_check_table_name)
   IF (ci_check_type=1)
    SET ci_formatted_column_name_upper = cnvtupper(stripalias(ci_check_column_name))
   ENDIF
   SELECT
    IF (ci_check_type=0)
     WHERE table_name=ci_check_table_name_upper
    ELSE
     WHERE table_name=ci_check_table_name_upper
      AND column_name=ci_formatted_column_name_upper
    ENDIF
    INTO "NL:"
    cnt = count(*)
    FROM user_tab_columns
    DETAIL
     ci_row_count = cnt
    WITH nocounter
   ;end select
   IF (error(err_msg,1) > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
    SET reply->status_data.subeventstatus[1].targetobjectname = "checkinput"
    GO TO exit_program
   ELSEIF (ci_row_count=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid"
    IF (ci_check_type=0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = build2(reply->status_data.
      subeventstatus[1].targetobjectvalue," Table Name"," ",cnvtupper(ci_check_table_name))
    ELSE
     IF (ci_check_type=1)
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build2(reply->status_data.
       subeventstatus[1].targetobjectvalue," Column Name"," ",cnvtupper(ci_check_column_name))
     ENDIF
    ENDIF
    GO TO exit_program
   ENDIF
 END ;Subroutine
#exit_program
END GO

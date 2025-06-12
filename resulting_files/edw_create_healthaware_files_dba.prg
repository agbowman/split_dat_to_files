CREATE PROGRAM edw_create_healthaware_files:dba
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE indx = i4 WITH protect, noconstant(0)
 DECLARE file_type = vc WITH protect, noconstant("")
 DECLARE rec_cnt = i4 WITH protect, noconstant(0)
 SET indx = locateval(num,1,size(h1n1_reply->category_list,5),"METRICS_QUERY",h1n1_reply->
  category_list[num].category)
 IF (indx > 0)
  FOR (i = 1 TO size(h1n1_reply->category_list[indx].qual,5))
    SET rec_cnt = 0
    SET file_type = ""
    CALL printdebugstatement("HealthAware Query: ")
    CALL printdebugstatement(h1n1_reply->category_list[indx].qual[i].value_alpha)
    CALL parser(h1n1_reply->category_list[indx].qual[i].value_alpha)
    CALL parser("GO")
    IF (rec_cnt > 0)
     CALL echo(concat("FILE_TYPE: ",file_type))
     CALL echo(concat("REC_CNT: ",build(rec_cnt)))
     CALL edwcreatescriptstatus(cnvtupper(file_type))
     CALL edwupdatescriptstatus(cnvtupper(file_type),rec_cnt,"1","1")
     CALL edwupdatestats(cnvtupper(file_type),script_start_dt_tm,0)
     SET list_size = (size(hf_list->qual,5)+ 1)
     SET stat = alterlist(hf_list->qual,list_size)
     SET hf_list->qual[list_size].file_list = cnvtupper(file_type)
    ENDIF
  ENDFOR
 ENDIF
 SET script_version = "001 08/24/09 MG010594"
END GO

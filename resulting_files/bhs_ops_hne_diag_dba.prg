CREATE PROGRAM bhs_ops_hne_diag:dba
 DECLARE gs_need_header = vc WITH public, noconstant("Y")
 DECLARE gs_output_file = vc WITH public, noconstant("")
 DECLARE ms_source_file = vc WITH protect, noconstant("")
 DECLARE ms_current_date = vc WITH protect, constant(format(cnvtdatetime(curdate,curtime3),
   "YYYYMMDDHHMMSS;;d"))
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_file_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_files_loc = vc WITH protect, constant(concat(trim(logical("bhscust"),3),"/hne/"))
 DECLARE ms_read_file = vc WITH protect, constant(concat("file_list_",ms_current_date,".txt"))
 FREE RECORD bohd_person
 RECORD bohd_person(
   1 l_cnt = i4
   1 qual[*]
     2 f_pid = f8
 ) WITH protect
 FREE RECORD hne_in
 RECORD hne_in(
   1 l_cnt = i4
   1 qual[*]
     2 s_filename = vc
 )
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 SET ms_dclcom = concat("ls ",ms_files_loc,"*.csv | xargs -n 1 basename "," > ",ms_files_loc,
  ms_read_file)
 CALL echo(build("DCL:",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET ms_dclcom = concat("chmod 777 ",ms_files_loc,ms_read_file)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET logical hne_in_ls value(build(ms_files_loc,ms_read_file))
 FREE DEFINE rtl2
 DEFINE rtl2 "hne_in_ls"
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE  NOT (r.line IN ("", " ", null))
   AND r.line != "total *"
   AND r.line != "d*"
  HEAD REPORT
   hne_in->l_cnt = 0
  DETAIL
   hne_in->l_cnt = (hne_in->l_cnt+ 1), stat = alterlist(hne_in->qual,hne_in->l_cnt), hne_in->qual[
   hne_in->l_cnt].s_filename = trim(r.line,3)
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 CALL echorecord(hne_in)
 SET ms_dclcom = concat("mkdir ",ms_files_loc,"archive/",ms_current_date)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET ms_dclcom = concat("chmod 777 ",ms_files_loc,"archive/",ms_current_date)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET ms_dclcom = concat("mv ",ms_files_loc,ms_read_file," ",ms_files_loc,
  "archive/",ms_current_date,"/",ms_read_file)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 IF ((hne_in->l_cnt > 0))
  FOR (ml_file_loop = 1 TO hne_in->l_cnt)
    SET gs_output_file = ""
    SET ms_source_file = ""
    SET gs_need_header = "Y"
    SET bohd_person->l_cnt = 0
    SET stat = alterlist(bohd_person->qual,bohd_person->l_cnt)
    IF (findstring("SMS",cnvtupper(hne_in->qual[ml_file_loop].s_filename),1) > 0)
     SET gs_output_file = concat("cerdiagsms_",format(cnvtdatetime(curdate,curtime3),
       "YYYYMMDDHHMMSS;;d"),".txt")
    ELSEIF (findstring("CEN",cnvtupper(hne_in->qual[ml_file_loop].s_filename),1) > 0)
     SET gs_output_file = concat("cerdiagcen_",format(cnvtdatetime(curdate,curtime3),
       "YYYYMMDDHHMMSS;;d"),".txt")
    ENDIF
    IF (size(trim(gs_output_file,3)) > 0)
     SET ms_source_file = concat(trim(logical("bhscust"),3),"/hne/",hne_in->qual[ml_file_loop].
      s_filename)
     CALL echo(ms_source_file)
     CALL echo(gs_output_file)
     SET ms_dclcom = concat("chmod 777 ",ms_source_file)
     CALL echo(ms_dclcom)
     CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
     EXECUTE kia_dm_dbimport value(ms_source_file), "bhs_extract_hne_diag", 1000,
     0
     SET ms_dclcom = concat("chmod 777 ",gs_output_file)
     CALL echo(ms_dclcom)
     CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
     SET ms_dclcom = concat("$cust_script/bhs_sftp_file.ksh mpsftp@10.94.55.12:/HNE ",gs_output_file)
     CALL echo(ms_dclcom)
     CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
     SET ms_dclcom = concat("mv ",ms_source_file," ",ms_files_loc,"archive/",
      ms_current_date,"/",hne_in->qual[ml_file_loop].s_filename)
     CALL echo(ms_dclcom)
     CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
     SET ms_dclcom = concat("mv ",gs_output_file," ",ms_files_loc,"archive/",
      ms_current_date,"/",gs_output_file)
     CALL echo(ms_dclcom)
     CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
    ENDIF
  ENDFOR
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 FREE DEFINE rtl2
END GO

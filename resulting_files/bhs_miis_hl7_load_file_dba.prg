CREATE PROGRAM bhs_miis_hl7_load_file:dba
 EXECUTE bhs_hlp_csv
 CALL echo(build("Declaring variables..."))
 DECLARE tmp_str = vc WITH protect, noconstant(" ")
 DECLARE file_str = vc WITH protect, noconstant(" ")
 DECLARE loc_str = vc WITH protect, noconstant(" ")
 DECLARE f_cnt = i4 WITH protect, noconstant(0)
 DECLARE x_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD prov_input
 RECORD prov_input(
   1 qual[*]
     2 provnum = f8
     2 person_id = f8
     2 location = vc
 )
 SET logical prov_file "prov_input_locations.csv"
 FREE DEFINE rtl
 DEFINE rtl "prov_file"
 CALL echo(build("Querying Provider/Encounter from File..."))
 SELECT
  r.line
  FROM rtlt r
  HEAD REPORT
   f_cnt = 0, x_cnt = 84
  DETAIL
   f_cnt = (f_cnt+ 1), stat = alterlist(prov_input->qual,f_cnt), stat = getcsvcolumnatindex(r.line,1,
    file_str,",",'"'),
   stat = getcsvcolumnatindex(r.line,2,tmp_str,",",'"'), stat = getcsvcolumnatindex(r.line,3,loc_str,
    ",",'"'), prov_input->qual[f_cnt].person_id = cnvtreal(tmp_str),
   prov_input->qual[f_cnt].provnum = cnvtreal(file_str), prov_input->qual[f_cnt].location = loc_str
  FOOT REPORT
   stat = 0
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(prov_input->qual,5))
   CALL echo(build("process Provider id ",prov_input->qual[x].provnum))
   EXECUTE bhs_miis_hl7_transfer prov_input->qual[x].provnum, prov_input->qual[x].person_id,
   prov_input->qual[x].location,
   x_cnt
   SET x_cnt = (x_cnt+ 1)
 ENDFOR
#exit_program
 CALL echo(build2("Exiting script ",curprog))
END GO

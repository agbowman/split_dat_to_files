CREATE PROGRAM dm_ocd_env_info:dba
 PAINT
 SET width = 132
#menu_screen1
 FREE RECORD doc
 RECORD doc(
   1 source_env_name = vc
   1 source_env_id = f8
   1 ocd_cnt = i4
   1 mig_ind_one = i4
   1 mig_ind_zero = i4
   1 product_area_name = vc
   1 product_area_number = i4
 )
 SET log_file = fillstring(30," ")
 SET log_file = "MINE"
 SET cont_screen = " "
 SET max_dsize = 0
 SET maxcolsize = 132
 SET header_str = fillstring(131,"-")
 SET message = window
 CALL clear(1,1)
 CALL box(1,1,20,132)
 CALL text(2,50,"DM OCD ENVIRONMENT INFORMATION")
 CALL text(3,22,
  "Report to generate list of installed OCDs in an Environment for a given Product Area Name")
 CALL line(4,1,132,xhor)
 CALL line(18,1,132,xhor)
 CALL text(6,5,"MINE/FILE/PRINTER")
 CALL text(8,5,"Product Area Name:")
 CALL text(10,5,"Enter Environment Name:")
 CALL accept(6,25,"p(30);cu",log_file)
 SET log_file = curaccept
 SET doc->product_area_name = "*"
 CALL text(24,2,"HELP: Press <SHIFT><F5> ")
 SET help =
 SELECT DISTINCT INTO "nl:"
  daf.product_area_name
  FROM dm_alpha_features daf
  WHERE daf.product_area_number > 0
  ORDER BY daf.product_area_name
  WITH nocounter
 ;end select
 SET validate =
 SELECT DISTINCT INTO "nl:"
  daf.product_area_number
  FROM dm_alpha_features daf
  WHERE cnvtupper(daf.product_area_name)=trim(cnvtupper(curaccept))
  WITH nocounter
 ;end select
 SET validate = 1
 CALL accept(8,25,"p(60);cu",doc->product_area_name)
 SET validate = 0
 SET help = off
 CALL clear(24,1)
 SELECT DISTINCT INTO "nl:"
  daf.product_area_number
  FROM dm_alpha_features daf
  WHERE cnvtupper(daf.product_area_name)=trim(cnvtupper(curaccept))
  DETAIL
   doc->product_area_name = daf.product_area_name, doc->product_area_number = daf.product_area_number
  WITH nocounter
 ;end select
 SET help =
 SELECT INTO "nl:"
  e.environment_name, description = substring(1,35,e.description)
  FROM dm_environment e
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  e.environment_name
  FROM dm_environment e
  WHERE e.environment_name=trim(cnvtupper(curaccept))
  WITH nocounter
 ;end select
 SET validate = 1
 CALL accept(10,30,"P(20);CUSF")
 SET validate = 0
 SET help = off
 CALL clear(24,1)
 SET doc->source_env_name = curaccept
 CALL text(19,5,"Continue (Y/N):")
 CALL accept(19,21,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 SET cont_screen = curaccept
 IF (cont_screen="N")
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  e.*
  FROM dm_environment e
  WHERE (e.environment_name=doc->source_env_name)
  DETAIL
   doc->source_env_id = e.environment_id
  WITH nocounter
 ;end select
 DECLARE parea = vc
 SET temp_status = fillstring(51," ")
 SELECT
  IF ((doc->product_area_name != "")
   AND (doc->product_area_name != "\*"))
   FROM dm_alpha_features df,
    dm_alpha_features_env dafe
   PLAN (df
    WHERE (df.product_area_number=doc->product_area_number))
    JOIN (dafe
    WHERE dafe.alpha_feature_nbr=df.alpha_feature_nbr
     AND (dafe.environment_id=doc->source_env_id))
   ORDER BY df.product_area_name, dafe.alpha_feature_nbr DESC
  ELSE
   FROM dm_alpha_features df,
    dm_alpha_features_env dafe
   PLAN (df)
    JOIN (dafe
    WHERE outerjoin(dafe.alpha_feature_nbr)=df.alpha_feature_nbr
     AND (dafe.environment_id=doc->source_env_id))
   ORDER BY df.product_area_name, dafe.alpha_feature_nbr DESC
  ENDIF
  INTO value(log_file)
  df.product_area_name, df.product_area_number, dafe.alpha_feature_nbr,
  dafe.start_dt_tm, dafe.end_dt_tm, minutes = datetimediff(dafe.end_dt_tm,dafe.start_dt_tm,4)
  HEAD REPORT
   sdate = format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME"), sid = build("(",cnvtint(doc->
     source_env_id),")"), row 0,
   header_str, row + 1, "Ocd Environment Report for ",
   doc->source_env_name, " ", sid,
   col 55, "User: ", curuser,
   col 70, "Current Date & Time: ", sdate";l",
   row + 1, header_str, doc->ocd_cnt = 0,
   doc->mig_ind_one = 0, doc->mig_ind_zero = 0
  HEAD df.product_area_name
   pan = build("(",df.product_area_number,")"), parea = build(df.product_area_name), row + 1
   IF (df.product_area_number=0)
    col 1, "- Possible Non-Cumulative OCDs"
   ELSE
    col 1, "- Product Area Name: ", parea,
    " ", pan
   ENDIF
   row + 2, col 1, "Ocd #",
   col 7, "Status", col 59,
   "MgInd", col 65, "InstMode",
   col 76, "Start Date", col 94,
   "End Date", col 112, "Total Time(Min)",
   row + 1, col 0, "------",
   col 7, "---------------------------------------------------", col 59,
   "-----", col 65, "----------",
   col 76, "-----------------", col 94,
   "-----------------", col 112, "---------------",
   row + 1
  DETAIL
   doc->ocd_cnt = (doc->ocd_cnt+ 1)
   IF (dafe.curr_migration_ind=1)
    doc->mig_ind_one = (doc->mig_ind_one+ 1)
   ELSE
    doc->mig_ind_zero = (doc->mig_ind_zero+ 1)
   ENDIF
   temp_status = substring(1,51,dafe.status), col 0, dafe.alpha_feature_nbr"######",
   col 7, temp_status, col 59,
   dafe.curr_migration_ind"###", col 65, dafe.inst_mode,
   col 76, dafe.start_dt_tm"MM/DD/YY HH:MM:SS", col 94,
   dafe.end_dt_tm"MM/DD/YY HH:MM:SS", col 112, minutes,
   row + 1
  FOOT REPORT
   IF ((doc->product_area_name != "")
    AND (doc->product_area_name != "\*")
    AND (doc->ocd_cnt=0))
    row + 2, "There are no OCDs installed in this Environment for Product Area: ", doc->
    product_area_name,
    row + 1
   ELSEIF ((doc->ocd_cnt=0))
    row + 2, "There are no OCDs installed in this Environment for any Product Area.", row + 1
   ENDIF
   row + 1, header_str, row + 1,
   "Ocd Environment Report for ", doc->source_env_name, " ",
   sid, col 55, "Tot. Ocd Count: ",
   doc->ocd_cnt"####;l", col 76, "Mig Ind (1): ",
   doc->mig_ind_one"####;l", col 96, "Mig Ind (0): ",
   doc->mig_ind_zero"####;l", row + 1, header_str
  WITH nocounter, formfeed = none, format = streamm,
   maxcol = value(maxcolsize), nullreport
 ;end select
#end_script
END GO

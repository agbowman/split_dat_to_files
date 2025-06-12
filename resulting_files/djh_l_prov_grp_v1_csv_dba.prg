CREATE PROGRAM djh_l_prov_grp_v1_csv:dba
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@baystatehealth.org"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 DECLARE ms_domain = vc WITH protect, noconstant("")
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 DECLARE date_qual = dq8
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 DECLARE pgrp = f8
 SET pgrp = uar_get_code_by("display",19189,"Provider Group")
 RECORD temp_alias(
   1 qual[*]
     2 fld1 = vc
     2 fld2 = vc
     2 fld3 = f8
     2 fld4 = dq8
     2 fld5 = vc
 )
 SELECT INTO "nl:"
  FROM prsnl_group pg
  PLAN (pg)
  ORDER BY pg.prsnl_group_name
  HEAD REPORT
   cnt1 = 0
  HEAD pg.prsnl_group_class_cd
   cnt1 = (cnt1+ 1), stat = alterlist(temp_alias->qual,cnt1), temp_alias->qual[cnt1].fld1 = pg
   .prsnl_group_name,
   temp_alias->qual[cnt1].fld2 = pg.prsnl_group_desc, temp_alias->qual[cnt1].fld3 = pg
   .prsnl_group_class_cd, temp_alias->qual[cnt1].fld4 = pg.updt_dt_tm
  WITH nocounter, time = 90
 ;end select
 SELECT INTO value(output_dest)
  temp_alias->qual[d.seq].fld1
  FROM (dummyt d  WITH seq = size(temp_alias->qual,5))
  WHERE d.seq > 0
  HEAD REPORT
   col 1, ",", "fld1",
   ",", "fld2", ",",
   "fld3", ",", "fld4",
   ",", row + 1, display_line = build(temp_alias->qual[d.seq].fld1)
   FOR (y = 1 TO size(temp_alias->qual[d.seq],5))
     output_string = build(y,',"',temp_alias->qual[y].fld1,'","',temp_alias->qual[y].fld2,
      '","',format(temp_alias->qual[y].fld3,"########"),'","',format(temp_alias->qual[y].fld4,
       "yyyy-mm-dd;;d"),'",'), col 1, output_string
     IF ( NOT (curendreport))
      row + 1
     ENDIF
   ENDFOR
   IF (gl_bhs_prod_flag=1)
    ms_domain = "PROD"
   ELSEIF (curnode="casdtest")
    ms_domain = "BUILD"
   ELSEIF (curnode="casetest")
    ms_domain = "TEST"
   ELSE
    ms_domain = "??"
   ENDIF
  FOOT REPORT
   row + 1, col 1, ",",
   "Prog: ", curprog, ",",
   "Run Date: ", curdate, row + 1,
   col 1, ",", "Node: ",
   curnode, "- ", ms_domain
  WITH format = variable, formfeed = none, maxcol = 550
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_Provider_GRP.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.x - Provider Group List ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO

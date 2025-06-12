CREATE PROGRAM bbt_rpt_trans_req_r:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_trans_req_r", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  trr.requirement_cd, trr.special_testing_cd, trr.warn_ind,
  trr.allow_override_ind, trr.active_ind, tr.requirement_cd,
  tr.codeset, tr.anti_d_ind, trans_req_disp = uar_get_code_display(tr.requirement_cd)
  "###############",
  special_tsting_disp = uar_get_code_display(trr.special_testing_cd)"###############",
  excld_prod_cat_disp = uar_get_code_display(etp.product_cat_cd)"###############"
  FROM trans_req_r trr,
   transfusion_requirements tr,
   excld_trans_req_prod_cat_r etp
  PLAN (trr
   WHERE trr.active_ind=1)
   JOIN (tr
   WHERE trr.requirement_cd=tr.requirement_cd)
   JOIN (etp
   WHERE etp.requirement_cd=outerjoin(trr.requirement_cd)
    AND etp.active_ind=outerjoin(1))
  ORDER BY trr.requirement_cd, trr.relationship_id, etp.product_cat_cd
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, "AS OF DATE:  ", col 14,
   curdate"DDMMMYY;;DATE", col 52, "DATABASE AUDIT",
   col 108, "PAGE NO:  ", col 120,
   curpage"##", row + 1, col 7,
   "TIME:  ", col 14, curtime"HH:MM;;MTIME",
   col 45, "ANTIGEN-ANTIBODY RELATIONSHIP TOOL", row + 1,
   col 26, "Antibody-Antigen & Transfusion Requirement-Attribute Relationships", row + 1,
   col 50, "ACTIVE VALUES ONLY", row + 1,
   line = fillstring(122,"-"), line, row + 1,
   col 4, "ANTIBODY/REQUIREMENT", col 30,
   "ANTIGEN/ATTRIBUTE", col 50, "WARNING?/",
   col 68, "EXCLUDED PRODUCT", row + 1,
   col 50, "ALLOW OVERRIDE?", col 68,
   "CATEGORIES", row + 1, line,
   row + 1
  HEAD trr.relationship_id
   IF (row=58)
    BREAK
   ENDIF
   col 4, trans_req_disp, col 30,
   special_tsting_disp
   IF (trr.warn_ind=0)
    IF (trr.allow_override_ind=0)
     col 52, "NO/NO"
    ELSEIF (trr.allow_override_ind=1)
     col 52, "NO/YES"
    ENDIF
   ELSEIF (trr.warn_ind=1)
    IF (trr.allow_override_ind=0)
     col 52, "YES/NO"
    ELSEIF (trr.allow_override_ind=1)
     col 52, "YES/YES"
    ENDIF
   ENDIF
   IF (tr.codeset != 1611)
    col 70, "N/A"
   ENDIF
   excluded_prod_cat_cnt = 0
  DETAIL
   IF (tr.codeset=1611
    AND etp.excld_trans_req_prod_cat_r_id > 0)
    excluded_prod_cat_cnt = (excluded_prod_cat_cnt+ 1)
    IF (excluded_prod_cat_cnt > 1)
     row + 1
    ENDIF
    col 70, excld_prod_cat_disp
   ENDIF
  FOOT  trr.relationship_id
   row + 1
  FOOT REPORT
   row + 3, col 49, " * * * E N D  O F  R E P O R T * * * ",
   select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO

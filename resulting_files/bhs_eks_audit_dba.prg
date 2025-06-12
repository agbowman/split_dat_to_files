CREATE PROGRAM bhs_eks_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE disp_line = vc
 DECLARE description = vc
 DECLARE count = i4
 IF (findstring("@", $OUTDEV) > 0)
  SET email_ind = 1
  SET output_dest = trim("bhseksaudit")
 ELSE
  SET email_ind = 0
  SET output_dest =  $OUTDEV
 ENDIF
 SET day = day(curdate)
 IF (day <= 16
  AND day > 2)
  SET beg_date_qual = cnvtdatetime((curdate - 15),000000)
 ELSE
  SET beg_date_qual = datetimeadd(datetimefind(cnvtdatetime((curdate - 20),0),"M","B","B"),15)
 ENDIF
 SET end_date_qual = cnvtdatetime((curdate - 1),235959)
 SET beg_date_disp = format(beg_date_qual,"MM/DD/YYYY HH:MM:SS;;q")
 SET end_date_disp = format(end_date_qual,"MM/DD/YYYY HH:MM:SS;;q")
 CALL echo(beg_date_disp)
 CALL echo(end_date_disp)
 FREE RECORD ekslist
 RECORD ekslist(
   1 list[*]
     2 modname = vc
     2 moddes = vc
     2 cnt = i4
     2 true = i4
     2 false = i4
     2 actions[*]
       3 retval = cv
 )
 CALL echo("test1")
 SELECT INTO "nl:"
  FROM eks_module_audit e
  PLAN (e
   WHERE e.module_name IN ("BHS_ADE_HIGH_K_AND_DRUG", "BHS_ADE_PROPHYLACTIC_DRUG",
   "BHS_ADE_RENAL_DECR_CREAT", "BHS_ADE_RENAL_DRUG_CREAT", "BHS_ADE_RENAL_NO_CREAT",
   "BHS_ADE_RENAL_NO_CREAT2", "BHS_ADE_WARF", "BHS_ASY_HEPARIN_NOPLT2", "BHS_ASY_IMMUN_INFLUENZA",
   "BHS_ASY_IMMUN_PNEUMO",
   "BHS_SYN_DUP_IMMUN_ALERT", "BHS_ASY_PLT_CNT", "BHS_SYN_DVT", "BHS_SYN_DVT1_B", "BHS_SYN_DVT2",
   "BHS_SYN_DVT2_B", "BHS_SYN_DVT3_B", "PHA_DRC_DEV2", "BHS_SYN_HXHIT", "BHS_SYN_NO_ADMIT_DX2",
   "BHS_ASY_ADT_ADM_PCP_NOTC", "BHS_ASY_DEATH_NOTICE")
    AND e.begin_dt_tm >= cnvtdatetime(beg_date_qual)
    AND e.end_dt_tm <= cnvtdatetime(end_date_qual)
    AND e.conclude=2
    AND  EXISTS (
   (SELECT
    em.module_name
    FROM eks_module em
    WHERE em.module_name=e.module_name
     AND em.active_flag="A"
     AND em.maint_validation="PRODUCTION")))
  ORDER BY e.module_name
  HEAD REPORT
   cnt = 0, c = 0, s = 0,
   xx = 0, i = 0, stat = alterlist(ekslist->list,20)
  HEAD e.module_name
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ekslist->list,(cnt+ 9))
   ENDIF
   ekslist->list[cnt].modname = trim(e.module_name), c = 0, s = 0,
   i = 0
  DETAIL
   c = (c+ 1), stat = alterlist(ekslist->list[cnt].actions,c), s = textlen(e.action_return),
   ekslist->list[cnt].actions[c].retval = e.action_return, ekslist->list[cnt].cnt = c
  FOOT  e.module_name
   c = 0
  FOOT REPORT
   stat = alterlist(ekslist->list,cnt)
  WITH nocounter, separator = " ", format
 ;end select
 CALL echo("test2")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(ekslist->list,5))),
   eks_modulestorage emo
  PLAN (d)
   JOIN (emo
   WHERE (emo.module_name=ekslist->list[d.seq].modname)
    AND emo.data_type=1)
  ORDER BY emo.version
  DETAIL
   ekslist->list[d.seq].moddes = build2(emo.ekm_info)
  WITH nocounter
 ;end select
 CALL echo("test3")
 FOR (l = 1 TO size(ekslist->list,5))
   CASE (ekslist->list[l].modname)
    OF "BHS_ADE_HIGH_K_AND_DRUG":
     FOR (ii = 1 TO size(ekslist->list[l].actions,5))
       IF (substring(1,3,ekslist->list[l].actions[ii].retval)="100")
        SET ekslist->list[l].true = (ekslist->list[l].true+ 1)
       ENDIF
     ENDFOR
    OF "BHS_ADE_WARF":
     FOR (ii = 1 TO size(ekslist->list[l].actions,5))
       IF (((substring(7,3,ekslist->list[l].actions[ii].retval)="100") OR (((substring(10,3,ekslist->
        list[l].actions[ii].retval)="100") OR (substring(13,3,ekslist->list[l].actions[ii].retval)=
       "100")) )) )
        SET ekslist->list[l].true = (ekslist->list[l].true+ 1)
       ENDIF
     ENDFOR
    OF "BHS_ASY_HEPARIN_NOPLT2":
     FOR (ii = 1 TO size(ekslist->list[l].actions,5))
       IF (substring(1,3,ekslist->list[l].actions[ii].retval)="100")
        SET ekslist->list[l].true = (ekslist->list[l].true+ 1)
       ENDIF
     ENDFOR
    OF "BHS_ASY_IMMUN_INFLUENZA":
     FOR (ii = 1 TO size(ekslist->list[l].actions,5))
       IF (((substring(1,3,ekslist->list[l].actions[ii].retval)="100") OR (substring(4,3,ekslist->
        list[l].actions[ii].retval)="100")) )
        SET ekslist->list[l].true = (ekslist->list[l].true+ 1)
       ENDIF
     ENDFOR
    OF "BHS_ASY_IMMUN_PNEUMO":
     FOR (ii = 1 TO size(ekslist->list[l].actions,5))
       IF (((substring(1,3,ekslist->list[l].actions[ii].retval)="100") OR (substring(4,3,ekslist->
        list[l].actions[ii].retval)="100")) )
        SET ekslist->list[l].true = (ekslist->list[l].true+ 1)
       ENDIF
     ENDFOR
    ELSE
     SET ekslist->list[l].true = ekslist->list[l].cnt
   ENDCASE
 ENDFOR
 CALL echo("test4")
 SELECT INTO value(output_dest)
  FROM (dummyt d  WITH seq = value(size(ekslist->list,5)))
  PLAN (d
   WHERE d.seq > 0)
  HEAD REPORT
   col 0, ',"Expert System Audit",', row + 1,
   col 0, ',"Beginning Date: ', beg_date_disp,
   '",', row + 1, col 0,
   ',"Ending Date: ', end_date_disp, '",',
   row + 1, disp_line = build(',"',"Rule",'","',"Logic Count",'","',
    "Action Count",'","',"Description",'",'), col 0,
   disp_line, row + 1
  DETAIL
   rule = ekslist->list[d.seq].modname, cnt = ekslist->list[d.seq].cnt, act = ekslist->list[d.seq].
   true,
   description = trim(ekslist->list[d.seq].moddes), disp_line = build(',"',rule,'","',cnt,'","',
    act,'","',description,'",'), col 0,
   disp_line, row + 1
  WITH maxcol = 10000, formfeed = none, maxrow = 10,
   format = variable
 ;end select
 CALL echo("test5")
 IF (email_ind=1)
  SET filename_in = concat(output_dest,".dat")
  SET filename_out = "expertaudit.csv"
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Discern Expert Audit ",beg_date_disp," to ",end_date_disp)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,0)
 ENDIF
END GO

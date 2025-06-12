CREATE PROGRAM ams_lh_sup_util
 DECLARE menudisp(mufx_menu=vc(ref),start_idx=i4(value,1)) = null
 DECLARE menudisplay(null) = null
 DECLARE addmenuitem(menu_rec=vc(ref),menu_id=i2,menu_item=vc,parent_id=i2(value,0),child_id=i2(value,
   0),
  menu_type_flg=i2(value,0)) = null
 DECLARE menuprompt(prompt_str=vc,prompt_flg=i2) = null
 FREE RECORD menu_ret
 RECORD menu_ret(
   1 lvl = i2
   1 val = i4
   1 num = f8
   1 str = c39
 )
 FREE RECORD prompt_menu
 RECORD prompt_menu(
   1 menu[*]
     2 menu_id = i2
     2 parent_id = i2
     2 data[*]
       3 menu_item = c126
       3 child_id = i2
     2 menu_type_flg = i2
     2 header_str = c126
 )
 DECLARE getencntr(null) = f8
 DECLARE getorderid(null) = f8
 DECLARE geteventid(null) = f8
 DECLARE getbedrockfilters(rec=vc(ref),cat_name=vc) = null
 DECLARE s2cpoe(null) = null
 DECLARE s2cpoe_dispdata(ord_id=f8) = null
 DECLARE s2cpoe_dispnum(ord_id=f8,sub_type=vc(value,"")) = null
 DECLARE s2inclab(null) = null
 DECLARE s2inclab_dispnum(lab_id=f8,sub_type=vc(value,"")) = null
 DECLARE num = i4
 DECLARE encntr_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",261,"CANCELLED"))
 DECLARE order_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE delete_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"DELETE"))
 DECLARE planned_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"PLANNED"))
 DECLARE logparse(file_str=vc) = null
 DECLARE filestr = vc
 FREE RECORD main_menu
 RECORD main_menu(
   1 menu[*]
     2 menu_id = i2
     2 parent_id = i2
     2 data[*]
       3 menu_item = c29
       3 child_id = i2
     2 menu_type_flg = i2
 )
 IF ((xxcclseclogin->loggedin=0))
  EXECUTE cclseclogin
  IF ((xxcclseclogin->loggedin=0))
   CALL menuprompt("Not securely logged in.  Some functions rely on UAR and will not work correctly.",
    3)
  ENDIF
 ENDIF
 ROLLBACK
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("SUP_MUFX_UTIL")
 CALL updtdminfo(script_name)
 COMMIT
 CALL addmenuitem(main_menu,1,"Stage 2",0,2,
  0)
 CALL addmenuitem(main_menu,2,"CPOE 2",1,0,
  0)
 CALL addmenuitem(main_menu,2,"Incorporate Lab Results 2",1,0,
  0)
 CALL addmenuitem(main_menu,1,"Logging",0,3,
  0)
 CALL addmenuitem(main_menu,3,"MUFX",1,0,
  0)
 CALL addmenuitem(main_menu,3,"MUFX2",1,0,
  0)
 CALL addmenuitem(main_menu,3,"eCQMs 2014",1,4,
  0)
 CALL addmenuitem(main_menu,3,"eCQMs 2015",1,5,
  0)
 CALL addmenuitem(main_menu,3,"Aggregate",1,6,
  0)
 CALL addmenuitem(main_menu,4,"VTE",3,0,
  0)
 CALL addmenuitem(main_menu,4,"ED",3,0,
  0)
 CALL addmenuitem(main_menu,4,"SCIP",3,0,
  0)
 CALL addmenuitem(main_menu,4,"STROKE",3,0,
  0)
 CALL addmenuitem(main_menu,4,"AMI",3,0,
  0)
 CALL addmenuitem(main_menu,4,"CAC",3,0,
  0)
 CALL addmenuitem(main_menu,4,"HEARING_SCREEN",3,0,
  0)
 CALL addmenuitem(main_menu,4,"PC",3,0,
  0)
 CALL addmenuitem(main_menu,4,"PN",3,0,
  0)
 CALL addmenuitem(main_menu,5,"VTE",3,0,
  0)
 CALL addmenuitem(main_menu,5,"ED",3,0,
  0)
 CALL addmenuitem(main_menu,5,"SCIP",3,0,
  0)
 CALL addmenuitem(main_menu,5,"STROKE",3,0,
  0)
 CALL addmenuitem(main_menu,5,"AMI",3,0,
  0)
 CALL addmenuitem(main_menu,5,"CAC",3,0,
  0)
 CALL addmenuitem(main_menu,5,"HEARING_SCREEN",3,0,
  0)
 CALL addmenuitem(main_menu,5,"PC",3,0,
  0)
 CALL addmenuitem(main_menu,5,"PN",3,0,
  0)
 CALL addmenuitem(main_menu,6,"Aggregate MUFX 2",3,0,
  0)
 FREE RECORD br_muse_filters
 RECORD br_muse_filters(
   1 name = vc
   1 cnt = i4
   1 qual[*]
     2 filter_mean = vc
     2 val_cnt = i4
     2 vals[*]
       3 value = f8
       3 text = vc
 )
 SET br_muse_filters->name = "BR_MUSE_FILTERS"
 CALL getbedrockfilters(br_muse_filters,"MUSE_FUNCTIONAL_2")
 DECLARE mainlvl = i2 WITH noconstant(1), protect
 SET quit = 0
 WHILE (quit=0)
   CALL menudisp(main_menu,mainlvl)
   SET mainlvl = menu_ret->lvl
   CASE (menu_ret->lvl)
    OF 2:
     IF ((menu_ret->val=1))
      CALL s2cpoe(null)
     ELSEIF ((menu_ret->val=2))
      CALL s2inclab(null)
     ELSE
      CALL echo("Unhandled menu_ret->val returned.")
     ENDIF
    OF 3:
    OF 4:
    OF 5:
    OF 6:
     IF ((menu_ret->lvl=3))
      IF ((menu_ret->val=1))
       CALL logparse("lh_mu_fx_load")
      ELSEIF ((menu_ret->val=2))
       CALL logparse("lh_mu_fx_2_load")
      ENDIF
     ELSEIF ((menu_ret->lvl IN (4, 5)))
      SET filestr = concat("lh_e_",trim(cnvtlower(main_menu->menu[menu_ret->lvl].data[menu_ret->val].
         menu_item),3),"_",evaluate(menu_ret->lvl,5,"2015_audit","audit"))
      CALL logparse(filestr)
     ELSEIF ((menu_ret->lvl=6))
      IF ((menu_ret->val=1))
       CALL logparse("lh_mu_aggregate2_audit")
      ENDIF
     ENDIF
    ELSE
     CALL echo("Unhandled menu_ret->lvl returned.")
     SET quit = 1
   ENDCASE
 ENDWHILE
 CALL clear(1,1)
 CALL clear(24,1,132)
 CALL echo(build("Returned ",menu_ret->lvl,"-",menu_ret->val))
 SUBROUTINE logparse(file_str)
   DECLARE dclcom = vc WITH protect
   IF (validate(tmp_file)=0)
    DECLARE tmp_file = vc WITH persistscript, noconstant(concat("lh_sup_util_temp_",format(sysdate,
       "MMDDYYYY_HHMMSS;;Q"),".dat"))
   ENDIF
   FREE RECORD flist
   RECORD flist(
     1 qual[*]
       2 fname = vc
       2 range_start = dq8
       2 range_end = dq8
       2 start_time = dq8
       2 end_time = dq8
       2 elapsed_mins = f8
       2 vol_cnt = f8
       2 complete_ind = i2
       2 flgs = vc
       2 mod = i2
       2 logical_domains = vc
       2 period_nbrs = vc
   )
   DECLARE range_start_str = vc WITH noconstant, protect
   DECLARE range_end_str = vc WITH noconstant, protect
   DECLARE range_date_format = vc WITH noconstant, protect
   DECLARE range_time_format = vc WITH noconstant, protect
   DECLARE volume_str = vc WITH noconstant, protect
   DECLARE end_str = vc WITH noconstant, protect
   DECLARE hist_str = vc WITH noconstant, protect
   DECLARE err_str = vc WITH noconstant, protect
   DECLARE spec_str = vc WITH noconstant, protect
   DECLARE logical_domain_str = vc WITH noconstant, protect
   DECLARE mod_str = vc WITH noconstant, protect
   DECLARE hc_query_str = vc WITH noconstant, protect
   DECLARE query_str = vc WITH noconstant, protect
   IF (file_str="lh_mu_fx_2_load")
    SET range_start_str = concat("awk '/Loading for the following range:/{print FILENAME ",
     '"|RANGE_START|" $6 "_" $7}',"' ",file_str,"*")
    SET range_end_str = concat("awk '/Loading for the following range:/{print FILENAME ",
     '"|RANGE_END|" $9 "_" $10}',"' ",file_str,"*")
    SET range_date_format = "DD-MMM-YYYY"
    SET range_time_format = "HH:MM:SS"
    SET volume_str = concat("awk '/Main population size:/{print FILENAME ",'"|VOLUME|" $4}',"' ",
     file_str,"*")
    SET end_str = concat("awk '/End of lh_mu_fx_2_load.prg/{print FILENAME ",'"|END_IND|" $0}',"' ",
     file_str,"*")
    SET hist_str = concat("awk '/Historical_ind=/{print FILENAME ",'"|HIST_IND|" $2}',"' ",file_str,
     "*")
    SET err_str = concat("awk '/CCL-E/{print FILENAME ",'"|CCL_ERR|" $0}',"' ",file_str,"*")
    SET spec_str = concat("awk '/Specific_measure_ind=/{print FILENAME ",'"|SPEC_IND|" $2}',"' ",
     file_str,"*")
    SET logical_domain_str = concat("awk '/Logical Domain Id =/{print FILENAME ",'"|LD_IND|" $0}',
     "' ",file_str,"*")
    SET mod_str = concat("awk '/MOD VERSION =/{print FILENAME ",'"|MOD|" $3}',"' ",file_str,"*")
    SET hc_query_str = "\*\*Hardcode : \*"
    SET query_str = "\*Query statement for "
   ELSEIF (file_str="lh_mu_fx_load")
    SET range_start_str = concat("awk '/EXTRACT date range/{getline; print FILENAME ",
     '"|RANGE_START|" $1 "_"$2}',"' ",file_str,"*")
    SET range_end_str = concat("awk '/EXTRACT date range/{getline; print FILENAME ",
     '"|RANGE_END|" $4 "_"$5}',"' ",file_str,"*")
    SET range_date_format = "MM/DD/YYYY"
    SET range_time_format = "HH:MM:SS"
    SET volume_str = concat("awk '/Number of encounters in load population:/{print FILENAME ",
     '"|VOLUME|" $7}',"' ",file_str,"*")
    SET end_str = concat("awk '/End of lh_mu_fx_load.prg/{print FILENAME ",'"|END_IND|" $0}',"' ",
     file_str,"*")
    SET hist_str = concat("awk '/Historical_ind=/{print FILENAME ",'"|HIST_IND|" $2}',"' ",file_str,
     "*")
    SET err_str = concat("awk '/CCL-E/{print FILENAME ",'"|CCL_ERR|" $0}',"' ",file_str,"*")
    SET spec_str = concat("awk '/Specific_measure_ind=/{print FILENAME ",'"|SPEC_IND|" $2}',"' ",
     file_str,"*")
    SET logical_domain_str = concat("awk '/Logical Domain ID =/{print FILENAME ",'"|LD_IND|" $0}',
     "' ",file_str,"*")
    SET mod_str = concat("awk '/MOD VERSION =/{print FILENAME ",'"|MOD|" $0}',"' ",file_str,"*")
    SET hc_query_str = "\*\*Hardcode : \*"
    SET query_str = "\*Query statement for "
   ELSEIF (file_str="lh_e_*")
    SET range_start_str = concat("awk '/EXTRACT date range/{getline; print FILENAME ",
     '"|RANGE_START|" $1 "_"$2}',"' ",file_str,"*")
    SET range_end_str = concat("awk '/EXTRACT date range/{getline; print FILENAME ",
     '"|RANGE_END|" $4 "_"$5}',"' ",file_str,"*")
    SET range_date_format = "MM/DD/YYYY"
    SET range_time_format = "HH:MM:SS"
    SET volume_str = concat("awk '/[Nn]umber of encounter_ids in LH_REPLY/{print FILENAME ",
     '"|VOLUME|" $NF}',"' ",file_str,"*")
    SET end_str = concat("awk '/End of ",trim(cnvtlower(replace(file_str,"_audit","")),3),
     ".prg/{print FILENAME ",'"|END_IND|" $0}',"' ",
     file_str,"*")
    SET hist_str = concat("awk '/Historical_ind=/{print FILENAME ",'"|HIST_IND|" $2}',"' ",file_str,
     "*")
    SET err_str = concat("awk '/CCL-E/{print FILENAME ",'"|CCL_ERR|" $0}',"' ",file_str,"*")
    SET spec_str = " "
    SET logical_domain_str = concat("awk '/Logical Domain= /{print FILENAME ",'"|LD_IND|" $0}',"' ",
     file_str,"*")
    SET mod_str = concat("awk '/MOD #/{print FILENAME ",'"|MOD|" $3}',"' ",file_str,"*")
    SET hc_query_str = "\*\*Hardcode : \*"
    SET query_str = "\*Query statement for "
   ELSEIF (file_str="lh_mu_aggregate2_audit")
    SET range_start_str = concat("awk -F'[*:]' '/PERIOD_NUMBER :/{print FILENAME ",
     '"|PERIOD_NBRS|" $30}',"' ",file_str,"*")
    SET range_end_str = " "
    SET range_date_format = " "
    SET range_time_format = " "
    SET volume_str = " "
    SET end_str = concat("awk '/End of lh_mu_aggregate2.prg/{print FILENAME ",'"|END_IND|" $0}',"' ",
     file_str,"*")
    SET hist_str = " "
    SET err_str = concat("awk '/CCL-E/{print FILENAME ",'"|CCL_ERR|" $0}',"' ",file_str,"*")
    SET spec_str = " "
    SET logical_domain_str = concat("awk '/\*\* logical_domain_id :/{print FILENAME ",
     '"|LD_IND|" $0}',"' ",file_str,"*")
    SET mod_str = " "
    SET hc_query_str = "\*\*Hardcode : \*"
    SET query_str = "\*Query statement for "
   ENDIF
   SET dclcom = concat("ls -lt ",file_str,"*.dat| awk '{print $6,$7,$8,$9}' > $CCLUSERDIR/",tmp_file)
   SET len = size(trim(dclcom))
   SET status = 0
   CALL dcl(dclcom,len,status)
   FREE DEFINE rtl2
   DEFINE rtl2 concat("CCLUSERDIR:",tmp_file)
   SELECT INTO "nl:"
    FROM rtl2t r
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(flist->qual,(cnt+ 99))
     ENDIF
     flist->qual[cnt].fname = substring(findstring(file_str,r.line),((textlen(r.line) - findstring(
       file_str,r.line))+ 1),r.line), flist->qual[cnt].start_time = cnvtdatetime(cnvtdate2(substring(
        (findstring(file_str,r.line,1)+ (textlen(file_str)+ 1)),8,r.line),"mmddyyyy"),cnvttime2(
       substring((findstring(file_str,r.line,1)+ (textlen(file_str)+ 10)),6,r.line),"hhmmss")),
     vmonth = substring(1,(findstring(" ",r.line,1) - 1),r.line),
     dstart_pos = (findstring(" ",r.line,1)+ 1), dend_pos = (findstring(" ",r.line,dstart_pos) - 1),
     vdate = format(substring(dstart_pos,dend_pos,r.line),"##;P0"),
     time_pos = (dend_pos+ 2), vtime = substring(time_pos,(findstring(" ",r.line,time_pos) - time_pos
      ),r.line), vyear = format(cnvtdatetime(curdate,curtime3),"YYYY;;q")
     IF (findstring(":",r.line,1)=0)
      vyear = vtime, vtime = "00:00"
     ENDIF
     flist->qual[cnt].end_time = cnvtdatetime(concat(trim(vdate,3),"-",trim(vmonth,3),"-",trim(vyear,
        3),
       " ",trim(vtime,3),":00")), flist->qual[cnt].elapsed_mins = datetimediff(flist->qual[cnt].
      end_time,flist->qual[cnt].start_time,4)
     IF ((flist->qual[cnt].elapsed_mins < 0))
      flist->qual[cnt].elapsed_mins = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(flist->qual,cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL menuprompt("No logfiles found.  Press enter to continue.",3)
    RETURN
   ENDIF
   FREE RECORD dcl_coms
   RECORD dcl_coms(
     1 qual[*]
       2 com = vc
   )
   SET stat = alterlist(dcl_coms->qual,9)
   SET dcl_coms->qual[1].com = range_start_str
   SET dcl_coms->qual[2].com = range_end_str
   SET dcl_coms->qual[3].com = volume_str
   SET dcl_coms->qual[4].com = end_str
   SET dcl_coms->qual[5].com = hist_str
   SET dcl_coms->qual[6].com = err_str
   SET dcl_coms->qual[7].com = spec_str
   SET dcl_coms->qual[8].com = logical_domain_str
   SET dcl_coms->qual[9].com = mod_str
   FOR (i = 1 TO size(dcl_coms->qual,5))
     IF (i=1)
      SET dclcom = concat(dcl_coms->qual[i].com," > $CCLUSERDIR/",tmp_file)
     ELSE
      SET dclcom = concat(dcl_coms->qual[i].com," >> $CCLUSERDIR/",tmp_file)
     ENDIF
     SET len = size(trim(dclcom))
     SET status = 0
     CALL dcl(dclcom,len,status)
   ENDFOR
   FREE RECORD dcl_coms
   DECLARE num = i4
   SELECT INTO "nl:"
    fname = substring(1,(findstring("|",r.line) - 1),r.line)
    FROM rtl2t r
    ORDER BY fname DESC
    HEAD fname
     idx = locateval(num,1,size(flist->qual,5),fname,flist->qual[num].fname)
    DETAIL
     IF (idx > 0)
      IF (r.line="*|RANGE_START|*")
       flist->qual[idx].range_start = cnvtdatetime(cnvtdate2(substring((findstring("|",r.line,1,1)+ 1
          ),(findstring("_",r.line,1,1) - 1),r.line),range_date_format),cnvttime2(substring((
          findstring("_",r.line,1,1)+ 1),textlen(r.line),r.line),range_time_format))
      ELSEIF (r.line="*|RANGE_END|*")
       flist->qual[idx].range_end = cnvtdatetime(cnvtdate2(substring((findstring("|",r.line,1,1)+ 1),
          (findstring("_",r.line,1,1) - 1),r.line),range_date_format),cnvttime2(substring((findstring
          ("_",r.line,1,1)+ 1),textlen(r.line),r.line),range_time_format))
      ELSEIF (r.line="*|VOLUME|*")
       flist->qual[idx].vol_cnt = cnvtint(substring((findstring("|",r.line,1,1)+ 1),((textlen(r.line)
          - findstring("|",r.line,1,1))+ 1),r.line))
      ELSEIF (r.line="*|END_IND|*")
       flist->qual[idx].complete_ind = 1
      ELSEIF (r.line="*|HIST_IND|*")
       IF (cnvtint(substring((findstring("|",r.line,1,1)+ 1),((textlen(r.line) - findstring("|",r
          .line,1,1))+ 1),r.line))=1)
        flist->qual[idx].flgs = concat(flist->qual[idx].flgs,"H")
       ENDIF
      ELSEIF (r.line="*|CCL_ERR|*")
       flist->qual[idx].flgs = concat(flist->qual[idx].flgs,"E")
      ELSEIF (r.line="*|SPEC_IND|*")
       IF (cnvtint(substring((findstring("|",r.line,1,1)+ 1),((textlen(r.line) - findstring("|",r
          .line,1,1))+ 1),r.line))=1)
        flist->qual[idx].flgs = concat(flist->qual[idx].flgs,"S")
       ENDIF
      ELSEIF (r.line="*|LD_IND|*")
       IF (cnvtreal(substring((findstring("|",r.line,1,1)+ 1),((textlen(r.line) - findstring("|",r
          .line,1,1))+ 1),r.line)) != 0)
        flist->qual[idx].flgs = concat(flist->qual[idx].flgs,"L")
       ENDIF
      ELSEIF (r.line="*|MOD|*")
       flist->qual[idx].mod = cnvtint(substring(50,textlen(r.line),r.line))
      ELSEIF (r.line="*|PERIOD_NBRS|*")
       prd = substring((findstring("|",r.line,1,1)+ 1),((textlen(r.line) - findstring("|",r.line,1,1)
        )+ 1),r.line), flist->qual[idx].period_nbrs = evaluate(flist->qual[idx].period_nbrs,"",prd,
        concat(flist->qual[idx].period_nbrs,",",prd))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   FREE RECORD flist_disp
   RECORD flist_disp(
     1 menu[*]
       2 menu_id = i2
       2 parent_id = i2
       2 data[*]
         3 menu_item = c126
         3 child_id = i2
         3 sub_type = vc
       2 menu_type_flg = i2
       2 header_str = c126
       2 select_str = c126
   )
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(flist->qual,5))
    WHERE size(flist->qual,5) > 0
    HEAD REPORT
     stat = alterlist(flist_disp->menu,1), flist_disp->menu.select_str =
     "Current logfiles in $CCLUSERDIR:"
     IF (file_str="lh_mu_aggregate2_audit")
      flist_disp->menu.header_str =
      "Logfile                                     Runtime hrs:  Completed:  Flags:  Periods run thus far:"
     ELSE
      flist_disp->menu.header_str =
"Logfile                                Range Start         Range End         Days:  #Encs:   Runtime hrs:  Completed:  Fla\
gs:\
"
     ENDIF
     fcnt = 0
    DETAIL
     fcnt = (fcnt+ 1)
     IF (mod(fcnt,100)=1)
      stat = alterlist(flist_disp->menu[1].data,(fcnt+ 99))
     ENDIF
     IF (file_str="lh_mu_aggregate2_audit")
      flist_disp->menu[1].data[fcnt].menu_item = concat(format(flist->qual[d.seq].fname,
        "##########################################")," ",format(round((flist->qual[d.seq].
         elapsed_mins/ 60),2),"##########.##;R"),"  ",format(evaluate(flist->qual[d.seq].complete_ind,
         1,"Yes","No"),"##########;R"),
       "  ",format(flist->qual[d.seq].flgs,"######;R"),"  ",format(flist->qual[d.seq].period_nbrs,
        "#################################################;L"))
     ELSE
      flist_disp->menu[1].data[fcnt].menu_item = concat(format(flist->qual[d.seq].fname,
        "######################################")," ",format(flist->qual[d.seq].range_start,
        "@SHORTDATETIME")," - ",format(flist->qual[d.seq].range_end,"@SHORTDATETIME"),
       " ",format(cnvtstring(datetimediff(flist->qual[d.seq].range_end,flist->qual[d.seq].range_start,
          1)),"#####;R"),"  ",format(flist->qual[d.seq].vol_cnt,"######;R"),"  ",
       format(round((flist->qual[d.seq].elapsed_mins/ 60),2),"##########.##;R"),"  ",format(evaluate(
         flist->qual[d.seq].complete_ind,1,"Yes","No"),"##########;R"),"  ",format(flist->qual[d.seq]
        .flgs,"######;R"))
     ENDIF
    FOOT REPORT
     stat = alterlist(flist_disp->menu[1].data,fcnt)
    WITH nocounter
   ;end select
   FREE RECORD qlist
   RECORD qlist(
     1 qry[*]
       2 qname = vc
       2 qstart = dq8
       2 qend = dq8
       2 qelapsed = f8
   )
   FREE RECORD qlist_disp
   RECORD qlist_disp(
     1 menu[*]
       2 menu_id = i2
       2 parent_id = i2
       2 data[*]
         3 menu_item = c126
         3 child_id = i2
         3 total_elapsed = f8
         3 incomplete_flg = i2
         3 qname = vc
       2 menu_type_flg = i2
       2 header_str = c126
       2 select_str = c126
   )
   SET cont_flg = 1
   WHILE (cont_flg=1)
    CALL menudisp(flist_disp)
    IF ((menu_ret->lvl=- (1)))
     SET cont_flg = 0
    ELSEIF ((menu_ret->lvl > 0))
     SET stat = alterlist(qlist->qry,0)
     SET stat = alterlist(qlist_disp->menu,0)
     SET fileidx = menu_ret->val
     FREE DEFINE rtl2
     DEFINE rtl2 concat("CCLUSERDIR:",flist->qual[fileidx].fname)
     DECLARE ccn_ep_txt = vc
     IF (file_str="lh_mu_aggregate2_audit")
      SELECT INTO "nl:"
       FROM rtl2t r
       HEAD REPORT
        mcnt = 0, get_start = 0, get_end = 0,
        ccn_ep_txt = " "
       DETAIL
        IF (get_start=0
         AND get_end=0)
         IF (r.line="*Calling Function : getSummarydata for*")
          IF (r.line="*Calling Function : getSummarydata for EP_REPORT*")
           ccn_ep_txt = "EP"
          ELSEIF (r.line="*Calling Function : getSummarydata for CCN_REPORT*")
           ccn_ep_txt = "CCN"
          ENDIF
         ELSEIF (r.line="*Running Measure :*")
          mcnt = (mcnt+ 1)
          IF (mod(mcnt,100)=1)
           stat = alterlist(qlist->qry,(mcnt+ 99))
          ENDIF
          qlist->qry[mcnt].qname = concat(substring(29,((size(trim(r.line,3)) - 29)+ 1),r.line)," ",
           ccn_ep_txt), get_start = 1
         ENDIF
        ELSEIF (get_start=1)
         IF (r.line="*Period_Number                             :*")
          qlist->qry[mcnt].qname = concat(qlist->qry[mcnt].qname,"-",substring(48,((textlen(r.line)
             - 48)+ 1),r.line))
         ELSEIF (r.line=";Start Time   :*")
          qlist->qry[mcnt].qstart = cnvtdatetime(cnvtdate2(substring(16,10,r.line),"mm/dd/yyyy"),
           cnvttime2(substring(27,8,r.line),"hh:mm:ss")), get_start = 0, get_end = 1,
          s_cnt = 0
         ENDIF
        ELSEIF (get_end=1)
         IF (r.line=";Start Time   :*")
          s_cnt = (s_cnt+ 1)
         ELSEIF (r.line=";End Time   :*")
          IF (s_cnt=0)
           qlist->qry[mcnt].qend = cnvtdatetime(cnvtdate2(substring(14,10,r.line),"mm/dd/yyyy"),
            cnvttime2(substring(25,8,r.line),"hh:mm:ss")), qlist->qry[mcnt].qelapsed = datetimediff(
            qlist->qry[mcnt].qend,qlist->qry[mcnt].qstart,5), get_end = 0
          ELSE
           s_cnt = (s_cnt - 1)
          ENDIF
         ELSEIF (r.line=";Getting EP Unique Patients - Query for Secure Msg")
          s_cnt = (s_cnt - 1)
         ENDIF
        ENDIF
       FOOT REPORT
        stat = alterlist(qlist->qry,mcnt)
       WITH nocounter
      ;end select
     ELSE
      SELECT INTO "nl:"
       FROM rtl2t r
       HEAD REPORT
        qcnt = 0, get_start = 0, get_end = 0
       DETAIL
        IF (get_start=0
         AND get_end=0)
         IF (operator(r.line,"REGEXPLIKE","Hardcode : *"))
          qcnt = (qcnt+ 1)
          IF (mod(qcnt,100)=1)
           stat = alterlist(qlist->qry,(qcnt+ 99))
          ENDIF
          qlist->qry[qcnt].qname = substring(14,((size(trim(r.line,3)) - 13) - 2),r.line), get_start
           = 1
         ELSEIF (operator(r.line,"REGEXPLIKE","Query [Ss]tateme[mn]t for *"))
          qcnt = (qcnt+ 1)
          IF (mod(qcnt,100)=1)
           stat = alterlist(qlist->qry,(qcnt+ 99))
          ENDIF
          qlist->qry[qcnt].qname = substring(22,(size(trim(r.line,3)) - 21),r.line), get_start = 1
         ENDIF
        ELSEIF (get_start=1)
         IF (r.line=";Start time: *")
          qlist->qry[qcnt].qstart = cnvtdatetime(cnvtdate2(substring(14,10,r.line),"mm/dd/yyyy"),
           cnvttime2(substring(25,8,r.line),"hh:mm:ss")), get_start = 0, get_end = 1
         ENDIF
        ELSEIF (get_end=1)
         IF (r.line=";End time: *")
          qlist->qry[qcnt].qend = cnvtdatetime(cnvtdate2(substring(12,10,r.line),"mm/dd/yyyy"),
           cnvttime2(substring(23,8,r.line),"hh:mm:ss")), qlist->qry[qcnt].qelapsed = datetimediff(
           qlist->qry[qcnt].qend,qlist->qry[qcnt].qstart,5), get_end = 0
         ENDIF
        ENDIF
       FOOT REPORT
        stat = alterlist(qlist->qry,qcnt)
       WITH nocounter
      ;end select
     ENDIF
     SELECT INTO "nl:"
      qname = substring(1,200,qlist->qry[d.seq].qname), qelapsed = qlist->qry[d.seq].qelapsed
      FROM (dummyt d  WITH seq = size(qlist->qry,5))
      ORDER BY qname, qelapsed
      HEAD REPORT
       stat = alterlist(qlist_disp->menu,1), qlist_disp->menu[1].select_str = concat(
        "Logfile details for ",flist->qual[fileidx].fname," sorted by total elapsed runtime:"),
       qlist_disp->menu[1].header_str =
"Query Name:                                                 Cnt:  Average:  Elapsed(s):  Longest start/end:        Incompl\
ete?\
", qlistcnt = 0
      HEAD qname
       curcnt = 0, total_elapsed = 0, incomplete_flg = 0
      DETAIL
       curcnt = (curcnt+ 1), total_elapsed = (total_elapsed+ qlist->qry[d.seq].qelapsed)
       IF ((qlist->qry[d.seq].qend=0))
        incomplete_flg = 1
       ENDIF
      FOOT  qname
       qlistcnt = (qlistcnt+ 1)
       IF (mod(qlistcnt,100)=1)
        stat = alterlist(qlist_disp->menu[1].data,(qlistcnt+ 99))
       ENDIF
       qlist_disp->menu[1].data[qlistcnt].incomplete_flg = incomplete_flg, qlist_disp->menu[1].data[
       qlistcnt].total_elapsed = total_elapsed
       IF ((qlist->qry[d.seq].qend=0))
        qlist_disp->menu[1].data[qlistcnt].incomplete_flg = 1
       ENDIF
       qlist_disp->menu[1].data[qlistcnt].qname = trim(qname,3), qlist_disp->menu[1].data[qlistcnt].
       menu_item = concat(format(qname,"#########################################################;L"),
        "   ",format(curcnt,"####;R"),"  ",format((total_elapsed/ curcnt),"########;R"),
        "  ",format(total_elapsed,"###########;R"),"  ",format(qlist->qry[d.seq].qstart,
         "mm/dd hh:mm;;D")," - ",
        format(qlist->qry[d.seq].qend,"mm/dd hh:mm;;D")," ",format(evaluate(qlist_disp->menu[1].data[
          qlistcnt].incomplete_flg,1,"x"," "),"###########;R"))
      FOOT REPORT
       stat = alterlist(qlist_disp->menu[1].data,qlistcnt)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      incomplete_flg = qlist_disp->menu[1].data[d.seq].incomplete_flg, total_elapsed = qlist_disp->
      menu[1].data[d.seq].total_elapsed, menu_item = substring(1,126,qlist_disp->menu[1].data[d.seq].
       menu_item),
      child_id = qlist_disp->menu[1].data[d.seq].child_id, qname = substring(1,200,qlist_disp->menu[1
       ].data[d.seq].qname), menu_id = qlist_disp->menu[1].menu_id,
      parent_id = qlist_disp->menu[1].parent_id, menu_type_flg = qlist_disp->menu[1].menu_type_flg,
      header_str = qlist_disp->menu[1].header_str,
      select_str = qlist_disp->menu[1].select_str
      FROM (dummyt d  WITH seq = size(qlist_disp->menu[1].data,5))
      WHERE size(qlist_disp->menu[1].data,5) > 0
      ORDER BY incomplete_flg DESC, total_elapsed DESC
      HEAD REPORT
       cnt = 0
      DETAIL
       cnt = (cnt+ 1), qlist_disp->menu[1].menu_id = menu_id, qlist_disp->menu[1].parent_id =
       parent_id,
       qlist_disp->menu[1].menu_type_flg = menu_type_flg, qlist_disp->menu[1].header_str = header_str,
       qlist_disp->menu[1].select_str = select_str,
       qlist_disp->menu[1].data[cnt].menu_item = menu_item, qlist_disp->menu[1].data[cnt].qname =
       trim(qname,3), qlist_disp->menu[1].data[cnt].child_id = child_id,
       qlist_disp->menu[1].data[cnt].total_elapsed = total_elapsed, qlist_disp->menu[1].data[cnt].
       incomplete_flg = incomplete_flg
      WITH nocounter
     ;end select
     SET q_cont = 1
     DECLARE qlist_qname = vc
     WHILE (q_cont=1)
      CALL menudisp(qlist_disp)
      IF ((menu_ret->lvl=- (1)))
       SET q_cont = 0
      ELSEIF ((menu_ret->lvl > 0))
       IF (file_str="lh_mu_aggregate2_audit")
        SET qlist_qname = qlist_disp->menu[1].data[menu_ret->val].qname
        SELECT INTO mine
         FROM rtl2t r
         HEAD REPORT
          measure_str = concat("*Running Measure :",substring(1,(findstring(" ",qlist_qname) - 1),
            qlist_qname)), ccn_ep_str = evaluate(findstring("CCN",qlist_qname),0,
           "*getSummarydata for EP_REPORT*","*getSummarydata for CCN_REPORT*"), period_str = concat(
           "; \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\* PERIOD_NUMBER :",substring((
            findstring("-",qlist_qname)+ 1),(textlen(qlist_qname) - findstring("-",qlist_qname)),
            qlist_qname),"\*"),
          get_period_ind = 1, get_ccn_ep_ind = 0, get_meas_ind = 0,
          print_log_ind = 0, s_cnt = 0
         DETAIL
          IF (get_period_ind=1
           AND operator(r.line,"REGEXPLIKE",trim(period_str,3)))
           get_period_ind = 0, get_ccn_ep_ind = 1
          ELSEIF (get_ccn_ep_ind=1
           AND r.line=patstring(ccn_ep_str,0))
           get_ccn_ep_ind = 0, get_meas_ind = 1
          ELSEIF (get_meas_ind=1
           AND r.line=patstring(measure_str,0))
           get_meas_ind = 0, print_log_ind = 1, row + 1,
           CALL print(trim(substring(1,400,r.line),3))
          ELSEIF (print_log_ind=1)
           row + 1,
           CALL print(trim(substring(1,400,r.line),3))
           IF (r.line=";Start Time   :*")
            s_cnt = (s_cnt+ 1)
           ELSEIF (r.line=";End Time   :*")
            IF (s_cnt=1)
             print_log_ind = 0, get_period_ind = 1
            ELSE
             s_cnt = (s_cnt - 1)
            ENDIF
           ELSEIF (r.line=";Getting EP Unique Patients - Query for Secure Msg")
            s_cnt = (s_cnt - 1)
           ENDIF
          ENDIF
         WITH nocounter, noformfeed, maxcol = 400
        ;end select
       ELSE
        DECLARE hc_measure_str = vc
        DECLARE hc_measure_str_space = vc
        DECLARE dyn_measure_str = vc
        DECLARE dyn_measure_str_misspell = vc
        DECLARE dyn_measure_str_eqcm = vc
        SELECT INTO mine
         FROM rtl2t r
         HEAD REPORT
          hc_measure_str = concat("**Hardcode : ",qlist_disp->menu[1].data[menu_ret->val].qname,"**"),
          hc_measure_str_space = concat("**Hardcode : ",qlist_disp->menu[1].data[menu_ret->val].qname,
           " **"), dyn_measure_str = concat("*Query statement for ",qlist_disp->menu[1].data[menu_ret
           ->val].qname),
          dyn_measure_str_misspell = concat("*Query statememt for ",qlist_disp->menu[1].data[menu_ret
           ->val].qname), dyn_measure_str_eqcm = concat("* Query Statement for ",qlist_disp->menu[1].
           data[menu_ret->val].qname), get_meas_ind = 1,
          print_log_ind = 0,
          CALL echo(hc_measure_str),
          CALL echo(hc_measure_str_space),
          CALL echo(dyn_measure_str),
          CALL echo(dyn_measure_str_misspell),
          CALL echo(dyn_measure_str_eqcm)
         DETAIL
          IF (get_meas_ind=1
           AND ((r.line=hc_measure_str) OR (((r.line=dyn_measure_str) OR (((r.line=
          dyn_measure_str_misspell) OR (((r.line=dyn_measure_str_eqcm) OR (r.line=
          hc_measure_str_space)) )) )) )) )
           get_meas_ind = 0, print_log_ind = 1, row + 1,
           CALL print(trim(substring(1,400,r.line),3))
          ELSEIF (print_log_ind=1)
           row + 1,
           CALL print(trim(substring(1,400,r.line),3))
           IF (r.line=";Elapsed Time in seconds*")
            print_log_ind = 0, get_meas_ind = 1
           ENDIF
          ENDIF
         WITH nocounter, noformfeed, maxcol = 400
        ;end select
       ENDIF
      ENDIF
     ENDWHILE
    ELSE
     CALL echo("Unhandled menu_ret->lvl returned.")
     SET cont_flg = 0
    ENDIF
   ENDWHILE
   FREE RECORD flist
   FREE RECORD flist_disp
   FREE RECORD qlist
   FREE RECORD qlist_disp
 END ;Subroutine
 SUBROUTINE s2cpoe(null)
   FREE RECORD cpoe_menu
   RECORD cpoe_menu(
     1 menu[*]
       2 menu_id = i2
       2 parent_id = i2
       2 data[*]
         3 menu_item = c100
         3 child_id = i2
       2 menu_type_flg = i2
   )
   FREE RECORD ord_list
   RECORD ord_list(
     1 menu[*]
       2 menu_id = i2
       2 parent_id = i2
       2 data[*]
         3 menu_item = c126
         3 child_id = i2
         3 order_id = f8
         3 sub_type = vc
       2 menu_type_flg = i2
       2 header_str = c126
       2 select_str = c126
   )
   DECLARE cat_filter = vc
   SET prot_idx = locateval(num,1,br_muse_filters->cnt,"MUSE_PROTOCOL",br_muse_filters->qual[num].
    filter_mean)
   SET service_idx = locateval(num,1,br_muse_filters->cnt,"SERVICE_TYPE",br_muse_filters->qual[num].
    filter_mean)
   SET hosp_idx = locateval(num,1,br_muse_filters->cnt,"HOSP_SERV_CDS",br_muse_filters->qual[num].
    filter_mean)
   SET lab_doe_idx = locateval(num,1,br_muse_filters->cnt,"MU2_LAB_DOE_IND",br_muse_filters->qual[num
    ].filter_mean)
   SET lab_int_idx = locateval(num,1,br_muse_filters->cnt,"MU2_LAB_INT_IND",br_muse_filters->qual[num
    ].filter_mean)
   SET lab_ordex_idx = locateval(num,1,br_muse_filters->cnt,"MU2_LAB_ORD_EXCL",br_muse_filters->qual[
    num].filter_mean)
   SET lab_act_idx = locateval(num,1,br_muse_filters->cnt,"MU2_LAB_ACT_TYPE",br_muse_filters->qual[
    num].filter_mean)
   SET rad_doe_idx = locateval(num,1,br_muse_filters->cnt,"MU2_RAD_DOE_IND",br_muse_filters->qual[num
    ].filter_mean)
   SET rad_ordex_idx = locateval(num,1,br_muse_filters->cnt,"MU2_RAD_ORD_EXCL",br_muse_filters->qual[
    num].filter_mean)
   SET rad_act_idx = locateval(num,1,br_muse_filters->cnt,"MU2_RAD_ACT_TYPE",br_muse_filters->qual[
    num].filter_mean)
   SET lab_contri_idx = locateval(num,1,br_muse_filters->cnt,"MU2_LAB_CONTRIBUTOR",br_muse_filters->
    qual[num].filter_mean)
   IF (lab_doe_idx > 0
    AND (br_muse_filters->qual[lab_doe_idx].vals[1].value > 0))
    SET lab_app_stmt = "oa.order_app_nbr NOT in ( 120000, 1030112) "
   ELSE
    SET lab_app_stmt = "1=1"
   ENDIF
   IF (lab_int_idx > 0
    AND lab_contri_idx > 0
    AND (br_muse_filters->qual[lab_int_idx].vals[1].value > 0))
    SET lab_contri_stmt = concat(
     "NOT expand(num,1,br_muse_filters->qual[lab_contri_idx]->val_cnt, oa.contributor_system_cd,",
     "br_muse_filters->qual[lab_contri_idx]->vals[num].value)")
   ELSE
    SET lab_contri_stmt = "1=1"
   ENDIF
   IF (rad_doe_idx > 0
    AND (br_muse_filters->qual[rad_doe_idx].vals[1].value > 0))
    SET rad_app_stmt = "oa.order_app_nbr != 120000 "
   ELSE
    SET rad_app_stmt = "1=1"
   ENDIF
   CALL addmenuitem(cpoe_menu,1,"CPOE 2 Denominator",0,2,
    0)
   CALL addmenuitem(cpoe_menu,1,"CPOE 2 Numerator (displays based on details table).",0,3,
    0)
   CALL addmenuitem(cpoe_menu,2,"Display orders by encounter",1,0,
    0)
   CALL addmenuitem(cpoe_menu,2,"Enter specific order_id",1,0,
    0)
   CALL addmenuitem(cpoe_menu,3,"Display orders by encounter",1,0,
    0)
   CALL addmenuitem(cpoe_menu,3,"Enter specific order_id",1,0,
    0)
   SET cur_lvl = 1
   SET cpoe_cont = 1
   WHILE (cpoe_cont=1)
     CALL menudisp(cpoe_menu,cur_lvl)
     SET cur_lvl = menu_ret->lvl
     IF ((menu_ret->lvl=2)
      AND (menu_ret->val=1))
      SET enc_id = getencntr(null)
      CALL echo(build("ENC_ID :",enc_id))
      IF ((enc_id > - (1)))
       CALL menuprompt(
        "Enter order catalog display or leave blank for no filtering.  For example, 'aspirin' can be *AS*.",
        2)
       IF ((menu_ret->str=""))
        SET ord_cat_filter = "1=1"
       ELSE
        SET ord_cat_filter = concat("cnvtupper(cv.display) = '",trim(menu_ret->str),"'")
       ENDIF
       CALL echo(build("ord_cat_filter :",ord_cat_filter))
       SET stat = alterlist(ord_list->menu,0)
       SELECT INTO "nl:"
        FROM orders o,
         code_value cv
        WHERE o.encntr_id=enc_id
         AND cv.code_value=o.catalog_cd
         AND parser(ord_cat_filter)
        ORDER BY cnvtupper(cv.display)
        HEAD REPORT
         ocnt = 0, stat = alterlist(ord_list->menu,1), ord_list->menu[1].menu_id = 1,
         ord_list->menu[1].header_str = concat("     ORDER_ID   CATALOG_CD_DISPLAY                ",
          "                                  ORIG_ORDER_DT_TM")
        DETAIL
         ocnt = (ocnt+ 1)
         IF (mod(ocnt,10)=1)
          stat = alterlist(ord_list->menu[1].data,(ocnt+ 9))
         ENDIF
         ord_list->menu[1].data[ocnt].menu_item = concat(substring(1,5,cnvtstring(ocnt)),cnvtstring(o
           .order_id),substring(1,68,cv.display),format(cnvtdatetime(o.orig_order_dt_tm),";;q")),
         ord_list->menu[1].data[ocnt].order_id = o.order_id
        FOOT REPORT
         stat = alterlist(ord_list->menu[1].data,ocnt), ord_list->menu[1].select_str = concat(
          "Select an order.  ",trim(cnvtstring(ocnt))," orders returned.")
        WITH nocounter
       ;end select
       IF (curqual > 0)
        WHILE ((menu_ret->lvl != - (1)))
         CALL menudisp(ord_list)
         IF ((menu_ret->lvl != - (1)))
          CALL s2cpoe_dispdata(ord_list->menu[1].data[menu_ret->lvl].order_id)
         ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     ELSEIF ((menu_ret->lvl=2)
      AND (menu_ret->val=2))
      SET cpoe_order_id = getorderid(null)
      IF ((cpoe_order_id != - (1)))
       CALL s2cpoe_dispdata(cpoe_order_id)
      ENDIF
     ELSEIF ((menu_ret->lvl=3)
      AND (menu_ret->val=1))
      SET enc_id = getencntr(null)
      IF ((enc_id > - (1)))
       CALL echo(build("ENC_ID :",enc_id))
       SET stat = alterlist(ord_list->menu,0)
       SELECT INTO "nl:"
        FROM lh_mu_fx_2_metrics m,
         lh_mu_fx_2_details d
        WHERE m.encntr_id=enc_id
         AND m.lh_mu_fx_2_metrics_id=d.lh_mu_fx_2_metrics_id
         AND d.metric_type="MUSE_CPOE"
         AND d.parent_entity_name="ORDERS"
        ORDER BY d.parent_entity_id
        HEAD REPORT
         ocnt = 0, stat = alterlist(ord_list->menu,1), ord_list->menu[1].menu_id = 1,
         ord_list->menu[1].header_str = concat("ORDER_ID   ORDER_MNEMONIC                        ",
          "                       ORIG_ORDER_DT_TM         LOADED_NUM  TYPE")
        DETAIL
         ocnt = (ocnt+ 1)
         IF (mod(ocnt,10)=1)
          stat = alterlist(ord_list->menu[1].data,(ocnt+ 9))
         ENDIF
         ord_list->menu[1].data[ocnt].menu_item = concat(cnvtstring(d.parent_entity_id),substring(1,
           61,d.event_description),format(cnvtdatetime(d.event_dt_tm),";;q"),"  ",evaluate(d
           .numerator_ind,0,"NOT MET",1,"MET    "),
          "     ",d.sub_metric_type), ord_list->menu[1].data[ocnt].order_id = d.parent_entity_id,
         ord_list->menu[1].data[ocnt].sub_type = d.sub_metric_type
        FOOT REPORT
         stat = alterlist(ord_list->menu[1].data,ocnt), ord_list->menu[1].select_str = concat(
          "Select an order.  ",trim(cnvtstring(ocnt)),
          " orders returned from lh_mu_fx_2_details table.")
        WITH nocounter
       ;end select
       IF (curqual > 0)
        WHILE ((menu_ret->lvl != - (1)))
         CALL menudisp(ord_list)
         IF ((menu_ret->lvl != - (1)))
          CALL s2cpoe_dispnum(ord_list->menu[1].data[menu_ret->val].order_id,ord_list->menu[1].data[
           menu_ret->val].sub_type)
         ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     ELSEIF ((menu_ret->lvl=3)
      AND (menu_ret->val=2))
      SET cpoe_order_id = getorderid(null)
      IF ((cpoe_order_id != - (1)))
       CALL s2cpoe_dispnum(cpoe_order_id,"RAD")
      ENDIF
     ELSE
      CALL echo("Unhandled menu_ret->lvl returned.")
      SET cpoe_cont = 0
     ENDIF
   ENDWHILE
   FREE RECORD cpoe_menu
   FREE RECORD ord_list
 END ;Subroutine
 SUBROUTINE s2cpoe_dispdata(ord_id)
   FREE RECORD cpoe_data
   RECORD cpoe_data(
     1 qual[*]
       2 order_id = f8
       2 data[*]
         3 field_desc = vc
         3 field_val = vc
         3 field_expected = vc
         3 qual_ind = i2
         3 sub_metric_type = vc
   )
   SELECT INTO "nl:"
    FROM encounter e,
     orders o,
     order_action oa,
     order_action oa2
    WHERE o.order_id=ord_id
     AND e.encntr_id=o.encntr_id
     AND o.encntr_id=e.encntr_id
     AND oa.order_id=outerjoin(o.order_id)
     AND oa.action_type_cd=outerjoin(order_cd)
     AND oa2.order_id=outerjoin(oa.order_id)
     AND oa2.order_action_id=outerjoin(oa.order_action_id)
     AND oa2.action_type_cd=outerjoin(delete_cd)
    ORDER BY o.order_id, oa.order_action_id, oa2.order_action_id
    HEAD REPORT
     ord_cnt = 0, stat = alterlist(cpoe_data->qual,0)
    HEAD o.order_id
     ord_cnt = (ord_cnt+ 1)
     IF (mod(ord_cnt,100)=1)
      stat = alterlist(cpoe_data->qual,(ord_cnt+ 99))
     ENDIF
     stat = alterlist(cpoe_data->qual[ord_cnt].data,18), cpoe_data->qual[ord_cnt].order_id = o
     .order_id, cpoe_data->qual[ord_cnt].data[1].field_desc = "ENCNTR_STATUS_CD",
     cpoe_data->qual[ord_cnt].data[1].field_val = uar_get_code_display(e.encntr_status_cd), cpoe_data
     ->qual[ord_cnt].data[1].field_expected = concat("NOT ",uar_get_code_display(encntr_canceled_cd)),
     cpoe_data->qual[ord_cnt].data[1].qual_ind = evaluate(e.encntr_status_cd,encntr_canceled_cd,0,1),
     cpoe_data->qual[ord_cnt].data[2].field_desc = "ENCNTR_TYPE_CLASS_CD (BR)", cpoe_data->qual[
     ord_cnt].data[2].field_val = uar_get_code_display(e.encntr_type_class_cd), cpoe_data->qual[
     ord_cnt].data[2].field_expected = "NOT BR filter for 'SERVICE_TYPE'",
     cpoe_data->qual[ord_cnt].data[2].qual_ind = evaluate(locateval(num,1,size(br_muse_filters->qual[
        service_idx].vals,5),e.encntr_type_class_cd,br_muse_filters->qual[service_idx].vals[num].
       value),0,1,0), cpoe_data->qual[ord_cnt].data[3].field_desc = "MED_SERVICE_CD", cpoe_data->
     qual[ord_cnt].data[3].field_val = uar_get_code_display(e.med_service_cd),
     cpoe_data->qual[ord_cnt].data[3].field_expected = "NOT BR filter for 'MED_SERVICE_CD'",
     cpoe_data->qual[ord_cnt].data[3].qual_ind = evaluate(locateval(num,1,size(br_muse_filters->qual[
        hosp_idx].vals,5),e.med_service_cd,br_muse_filters->qual[hosp_idx].vals[num].value),0,1,0),
     cpoe_data->qual[ord_cnt].data[4].field_desc = "TEMPLATE_ORDER_FLAG",
     cpoe_data->qual[ord_cnt].data[4].field_val = cnvtstring(o.template_order_flag), cpoe_data->qual[
     ord_cnt].data[4].field_expected = "in(0, 1, or 5)", cpoe_data->qual[ord_cnt].data[4].qual_ind =
     evaluate(o.template_order_flag,0,1,1,1,
      5,1,0),
     cpoe_data->qual[ord_cnt].data[5].field_desc = "0", cpoe_data->qual[ord_cnt].data[5].field_val =
     cnvtstring(o.template_order_id), cpoe_data->qual[ord_cnt].data[5].field_expected = "0",
     cpoe_data->qual[ord_cnt].data[5].qual_ind = evaluate(o.template_order_id,0,1,0), cpoe_data->
     qual[ord_cnt].data[6].field_desc = "CS_FLAG", cpoe_data->qual[ord_cnt].data[6].field_val =
     cnvtstring(o.cs_flag),
     cpoe_data->qual[ord_cnt].data[6].field_expected = "NOT = 1", cpoe_data->qual[ord_cnt].data[6].
     qual_ind = evaluate(o.cs_flag,1,0,1), cpoe_data->qual[ord_cnt].data[7].field_desc =
     "ACTION order_action row exists?",
     cpoe_data->qual[ord_cnt].data[7].field_val = evaluate(nullind(oa.order_action_id),1,"no row",
      "row exists"), cpoe_data->qual[ord_cnt].data[7].field_expected = "row exists", cpoe_data->qual[
     ord_cnt].data[7].qual_ind = evaluate(nullind(oa.order_action_id),1,0,1),
     cpoe_data->qual[ord_cnt].data[8].field_desc = "COMMUNICATION_TYPE_CD of protocol", cpoe_data->
     qual[ord_cnt].data[8].field_val = uar_get_code_display(oa.communication_type_cd), cpoe_data->
     qual[ord_cnt].data[8].field_expected = "NOT BR filter for 'MUSE_PROTOCOL'",
     cpoe_data->qual[ord_cnt].data[8].qual_ind = evaluate(locateval(num,1,size(br_muse_filters->qual[
        prot_idx].vals,5),e.med_service_cd,br_muse_filters->qual[prot_idx].vals[num].value),0,1,0),
     cpoe_data->qual[ord_cnt].data[9].field_desc = "DELETE_CD order_action exists?", cpoe_data->qual[
     ord_cnt].data[9].field_val = evaluate(nullind(oa2.order_action_id),1,"no row","row exists"),
     cpoe_data->qual[ord_cnt].data[9].field_expected = "row does not exist", cpoe_data->qual[ord_cnt]
     .data[9].qual_ind = evaluate(nullind(oa.order_action_id),1,1,0), cpoe_data->qual[ord_cnt].data[
     10].field_desc = "CATALOG_TYPE_CD",
     cpoe_data->qual[ord_cnt].data[10].field_val = uar_get_code_display(o.catalog_type_cd), cpoe_data
     ->qual[ord_cnt].data[10].field_expected = uar_get_code_display(pharmacy_cd), cpoe_data->qual[
     ord_cnt].data[10].sub_metric_type = "MED",
     cpoe_data->qual[ord_cnt].data[10].qual_ind = evaluate(o.catalog_type_cd,pharmacy_cd,1,0),
     cpoe_data->qual[ord_cnt].data[11].field_desc = "ORIG_ORD_AS_FLAG", cpoe_data->qual[ord_cnt].
     data[11].field_val = cnvtstring(o.orig_ord_as_flag),
     cpoe_data->qual[ord_cnt].data[11].field_expected = "0, 1, or 5", cpoe_data->qual[ord_cnt].data[
     11].sub_metric_type = "MED", cpoe_data->qual[ord_cnt].data[11].qual_ind = evaluate(o
      .orig_ord_as_flag,0,1,1,1,
      5,1,0),
     cpoe_data->qual[ord_cnt].data[12].field_desc = "ENCNTR_TYPE_CLASS_CD (BR)", cpoe_data->qual[
     ord_cnt].data[12].field_val = uar_get_code_display(e.encntr_type_class_cd), cpoe_data->qual[
     ord_cnt].data[12].field_expected = "NOT BR filter for 'SERVICE_TYPE'",
     cpoe_data->qual[ord_cnt].data[12].sub_metric_type = "LAB"
    FOOT REPORT
     stat = alterlist(cpoe_data->qual,ord_cnt)
    WITH nocounter
   ;end select
   SELECT
    field_desc = cpoe_data->qual[1].data[d.seq].field_desc"###############################",
    current_value = cpoe_data->qual[1].data[d.seq].field_val"###############################",
    expected_value = cpoe_data->qual[1].data[d.seq].field_expected"###############################",
    matched_flg = cpoe_data->qual[1].data[d.seq].qual_ind, sub_metric = cpoe_data->qual[1].data[d.seq
    ].sub_metric_type, order_id = cpoe_data->qual[1].order_id
    FROM (dummyt d  WITH seq = size(cpoe_data->qual[1].data,5))
    WITH nocounter
   ;end select
   FREE RECORD cpoe_data
 END ;Subroutine
 SUBROUTINE s2cpoe_dispnum(ord_id,sub_type)
   DECLARE ord_prsnl_id = f8
   DECLARE ord_prsnl_name = vc
   DECLARE pos_cd = f8
   DECLARE comm_cd = f8
   DECLARE pw_pos_cd = f8
   DECLARE sub_type_idx = i2
   IF (sub_type != "")
    SET sub_type_filter = concat("md.sub_metric_type = '",sub_type,"'")
   ELSE
    SET sub_type_filter = "1=1"
   ENDIF
   CALL echo(build("SUB_TYPE_FILTER :",sub_type_filter))
   SELECT INTO "nl:"
    FROM lh_mu_fx_2_details md,
     order_action oa,
     prsnl pr
    WHERE oa.order_id=ord_id
     AND oa.action_type_cd=order_cd
     AND md.parent_entity_id=outerjoin(oa.order_id)
     AND md.metric_type=outerjoin("MUSE_CPOE")
     AND md.parent_entity_name=outerjoin("ORDERS")
     AND pr.person_id=oa.action_personnel_id
     AND parser(sub_type_filter)
    DETAIL
     ord_prsnl_id = oa.action_personnel_id, ord_prsnl_name = pr.name_full_formatted, pos_cd = pr
     .position_cd,
     comm_cd = oa.communication_type_cd, sub_type = md.sub_metric_type, sub_type_idx = evaluate(
      sub_type,"MEDS",1,"LAB",2,
      "RAD",3)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM act_pw_comp apc,
     pathway_action pa,
     prsnl pr
    WHERE apc.parent_entity_id=ord_id
     AND apc.parent_entity_name="ORDERS"
     AND apc.active_ind=1
     AND pa.pathway_id=apc.pathway_id
     AND pa.pw_action_seq > 0
     AND pa.pw_status_cd=planned_cd
     AND pr.person_id=pa.action_prsnl_id
    DETAIL
     pw_pos_cd = pr.position_cd
    WITH nocounter
   ;end select
   FREE RECORD cpoe_num_data
   RECORD cpoe_num_data(
     1 qual[3]
       2 comm[5]
         3 met_ind = i2
       2 pos[5]
         3 met_ind = i2
       2 type_met_ind = i2
   )
   SELECT INTO "nl:"
    FROM br_datamart_category bdc,
     br_datamart_filter bdf,
     br_datamart_value bdv
    WHERE bdc.category_mean="MUSE_FUNCTIONAL_2"
     AND bdf.br_datamart_category_id=bdc.br_datamart_category_id
     AND bdv.br_datamart_filter_id=bdf.br_datamart_filter_id
     AND bdv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ((bdv.parent_entity_id IN (pos_cd, pw_pos_cd)
     AND bdf.filter_mean IN ("MUSE_MED_POSITION_1", "MUSE_MED_POSITION_2", "MUSE_MED_POSITION_3",
    "MUSE_MED_POSITION_4", "MUSE_MED_POSITION_5",
    "MU2_LAB_POSITION_1", "MU2_LAB_POSITION_2", "MU2_LAB_POSITION_3", "MU2_LAB_POSITION_4",
    "MU2_LAB_POSITION_5",
    "MU2_RAD_POSITION_1", "MU2_RAD_POSITION_2", "MU2_RAD_POSITION_3", "MU2_RAD_POSITION_4",
    "MU2_RAD_POSITION_5")) OR (bdv.parent_entity_id=comm_cd
     AND bdf.filter_mean IN ("MUSE_MED_COMM_1", "MUSE_MED_COMM_2", "MUSE_MED_COMM_3",
    "MUSE_MED_COMM_4", "MUSE_MED_COMM_5",
    "MU2_LAB_COMM_1", "MU2_LAB_COMM_2", "MU2_LAB_COMM_3", "MU2_LAB_COMM_4", "MU2_LAB_COMM_5",
    "MU2_RAD_COMM_1", "MU2_RAD_COMM_2", "MU2_RAD_COMM_3", "MU2_RAD_COMM_4", "MU2_RAD_COMM_5")))
    DETAIL
     br_sub_type = substring((findstring("_",bdf.filter_mean,1)+ 1),3,bdf.filter_mean), filter_type
      = evaluate(findstring("COMM",bdf.filter_mean,1),0,"POS","COMM"), filter_num = cnvtint(substring
      (textlen(trim(bdf.filter_mean)),1,bdf.filter_mean))
     IF (br_sub_type="MED")
      type_idx = 1
     ELSEIF (br_sub_type="LAB")
      type_idx = 2
     ELSEIF (br_sub_type="RAD")
      type_idx = 3
     ENDIF
     CALL echo(build("br_sub_type :",br_sub_type,"_type_idx :",type_idx,"_filter_type :",
      filter_type))
     IF (filter_type="COMM")
      cpoe_num_data->qual[type_idx].comm[filter_num].met_ind = 1
     ELSEIF (filter_type="POS")
      cpoe_num_data->qual[type_idx].pos[filter_num].met_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   FOR (i = 1 TO 3)
    SET cpoe_num_data->qual[i].type_met_ind = 0
    FOR (j = 1 TO 5)
      IF ((cpoe_num_data->qual[i].comm[j].met_ind=1)
       AND (cpoe_num_data->qual[i].pos[j].met_ind=1))
       SET cpoe_num_data->qual[i].type_met_ind = 1
      ENDIF
    ENDFOR
   ENDFOR
   SELECT INTO mine
    FROM dual
    DETAIL
     row + 1,
     CALL print(concat(" Order_id: ",cnvtstring(ord_id))), row + 1,
     CALL print(concat(" Order action personnel: ",trim(cnvtstring(ord_prsnl_id))," ",ord_prsnl_name)
     ), row + 1,
     CALL print(concat(" Order action position : ",trim(cnvtstring(pos_cd))," ",uar_get_code_display(
       pos_cd))),
     row + 1,
     CALL print(concat(" Pathway position      : ",trim(cnvtstring(pw_pos_cd))," ",
      uar_get_code_display(pw_pos_cd))), row + 1,
     CALL print(concat(" Communication type    : ",trim(cnvtstring(comm_cd))," ",uar_get_code_display
      (comm_cd))), row + 2,
     CALL print(concat(" Order type: ",sub_type)),
     row + 1,
     CALL print(concat(" MET for ",sub_type,"? ",evaluate(cpoe_num_data->qual[sub_type_idx].
       type_met_ind,1,"Yes","No"))), row + 4,
     CALL print(" Detailed position/communication type filter qualifications (x = met):"), row + 2
     FOR (i = 1 TO 3)
       CALL print(concat("  ------------------- ",evaluate(i,1,"MEDS",2,"LAB ",
         3,"RAD ")," ---------------------")), row + 1,
       CALL print("  |     Group1  Group2  Group3  Group4  Group5 |"),
       row + 1,
       CALL print("  |Comm")
       FOR (j = 1 TO 5)
         CALL print(evaluate(cpoe_num_data->qual[i].comm[j].met_ind,1,"   x    ","        "))
       ENDFOR
       CALL print("|"), row + 1,
       CALL print("  |Pos ")
       FOR (j = 1 TO 5)
         CALL print(evaluate(cpoe_num_data->qual[i].pos[j].met_ind,1,"   x    ","        "))
       ENDFOR
       CALL print("|"), row + 1,
       CALL print("  ----------------------------------------------"),
       row + 2
     ENDFOR
    WITH nocounter, noformfeed
   ;end select
   FREE RECORD cpoe_num_data
 END ;Subroutine
 SUBROUTINE s2inclab(null)
   DECLARE enc_id = f8 WITH noconstant, protect
   DECLARE ord_id = f8 WITH noconstant, protect
   DECLARE evt_id = f8 WITH noconstant, protect
   DECLARE cur_lvl = i2 WITH noconstant, protect
   DECLARE lab_cont = i2 WITH noconstant, protect
   FREE RECORD lab_menu
   RECORD lab_menu(
     1 menu[*]
       2 menu_id = i2
       2 parent_id = i2
       2 data[*]
         3 menu_item = c100
         3 child_id = i2
       2 menu_type_flg = i2
   )
   FREE RECORD lab_list
   RECORD lab_list(
     1 menu[*]
       2 menu_id = i2
       2 parent_id = i2
       2 data[*]
         3 menu_item = c126
         3 child_id = i2
         3 lab_id = f8
         3 sub_type = vc
       2 menu_type_flg = i2
       2 header_str = c126
       2 select_str = c126
   )
   CALL addmenuitem(lab_menu,1,"Incorporate Lab 2 Numerator",0,2,
    0)
   CALL addmenuitem(lab_menu,2,"Enter by encounter (displays data from details table).",1,0,
    0)
   CALL addmenuitem(lab_menu,2,"Enter by order_id (order-based result).",1,0,
    0)
   CALL addmenuitem(lab_menu,2,"Enter by event_id (result with no order).",1,0,
    0)
   SET cur_lvl = 1
   SET lab_cont = 1
   WHILE (lab_cont=1)
     CALL menudisp(lab_menu,cur_lvl)
     SET cur_lvl = menu_ret->lvl
     IF ((menu_ret->lvl=2)
      AND (menu_ret->val=1))
      SET enc_id = getencntr(null)
      IF ((enc_id > - (1)))
       CALL echo(build("ENC_ID :",enc_id))
       SET stat = alterlist(lab_list->menu,0)
       SELECT INTO "nl:"
        FROM lh_mu_fx_2_metrics m,
         lh_mu_fx_2_details d
        WHERE m.encntr_id=enc_id
         AND m.lh_mu_fx_2_metrics_id=d.lh_mu_fx_2_metrics_id
         AND d.metric_type="MU2_LABORATORY_RESULTS"
        ORDER BY d.parent_entity_id
        HEAD REPORT
         labcnt = 0, stat = alterlist(lab_list->menu,1), lab_list->menu[1].menu_id = 1,
         lab_list->menu[1].header_str = concat(
          "PARENT_ENTITY_ID PARENT_ENTITY_NAME EVENT_DESCRIPTION",
          "                   EVENT_DT_TM              LOADED_NUM")
        DETAIL
         labcnt = (labcnt+ 1)
         IF (mod(labcnt,10)=1)
          stat = alterlist(lab_list->menu[1].data,(labcnt+ 9))
         ENDIF
         lab_list->menu[1].data[labcnt].menu_item = concat(cnvtstring(d.parent_entity_id,16)," ",
          substring(1,18,d.parent_entity_name)," ",substring(1,35,d.event_description),
          " ",format(cnvtdatetime(d.event_dt_tm),";;q"),"  ",evaluate(d.numerator_ind,0,"NOT MET",1,
           "MET    ")), lab_list->menu[1].data[labcnt].lab_id = d.parent_entity_id, lab_list->menu[1]
         .data[labcnt].sub_type = d.sub_metric_type
        FOOT REPORT
         stat = alterlist(lab_list->menu[1].data,labcnt), lab_list->menu[1].select_str = concat(
          "Select an order.  ",trim(cnvtstring(labcnt)),
          " events returned from lh_mu_fx_2_details table.")
        WITH nocounter
       ;end select
       IF (curqual > 0)
        WHILE ((menu_ret->lvl != - (1)))
         CALL menudisp(lab_list)
         IF ((menu_ret->lvl != - (1)))
          CALL s2inclab_dispnum(lab_list->menu[1].data[menu_ret->val].lab_id,lab_list->menu[1].data[
           menu_ret->val].sub_type)
         ENDIF
        ENDWHILE
       ELSE
        CALL menuprompt(
         "No results found on details table for this encntr_id.  Press enter to continue.",3)
       ENDIF
      ENDIF
     ELSEIF ((menu_ret->lvl=2)
      AND (menu_ret->val=2))
      SET ord_id = getorderid(null)
      IF ((ord_id != - (1)))
       CALL s2inclab_dispnum(ord_id,1)
      ENDIF
     ELSEIF ((menu_ret->lvl=2)
      AND (menu_ret->val=3))
      SET evt_id = geteventid(null)
      IF ((evt_id != - (1)))
       CALL s2inclab_dispnum(evt_id,3)
      ENDIF
     ELSE
      CALL echo("Unhandled menu_ret->lvl returned.")
      SET lab_cont = 0
     ENDIF
   ENDWHILE
   FREE RECORD lab_menu
   FREE RECORD lab_list
 END ;Subroutine
 SUBROUTINE s2inclab_dispnum(lab_id,sub_type)
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE count_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"COUNT")), protect
   DECLARE num_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"NUM")), protect
   DECLARE txt_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"TXT")), protect
   DECLARE interp_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"INTERP")), protect
   DECLARE mbo_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MBO")), protect
   DECLARE powerchart_cd = f8 WITH constant(uar_get_code_by("MEANING",89,"POWERCHART")), protect
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
   DECLARE modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
   DECLARE altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
   DECLARE rli_idx = i4 WITH protect, noconstant
   DECLARE result_cont_sys_idx = i4 WITH noconstant, protect
   SET rli_idx = locateval(num,1,br_muse_filters->cnt,"MUSE_LAB_RLI_BENCH",br_muse_filters->qual[num]
    .filter_mean)
   SET result_cont_sys_idx = locateval(num,1,br_muse_filters->cnt,"MUSE_LAB_RESULT_CONT_SRC",
    br_muse_filters->qual[num].filter_mean)
   DECLARE lab_result_idx = i4 WITH noconstant(locateval(num,1,br_muse_filters->cnt,
     "MUSE_LAB_RESULTS",br_muse_filters->qual[num].filter_mean))
   DECLARE ce_result_filter = vc WITH protect, noconstant
   FREE RECORD lab_events
   RECORD lab_events(
     1 order_id = f8
     1 met_ind = i2
     1 qual[*]
       2 met_ind = i2
       2 event_id = f8
       2 event_cd = f8
       2 event_tag = vc
       2 disq_txt_ind = i2
       2 event_class_cd = f8
       2 struct_res_ind = i2
       2 contrib_sys_cd = f8
       2 freetext_nonpc_ind = i2
       2 freetext_pc_ind = i2
       2 resource_cd = f8
       2 rli_ind = i2
       2 ccr_ind = i2
   )
   IF (cnvtint(sub_type)=1)
    SET lab_events->order_id = lab_id
    SET ce_result_filter = "ce.order_id = lab_events->order_id"
   ELSEIF (cnvtint(sub_type)=2)
    SET lab_events->order_id = 0
    SET ce_result_filter = "ce.clinical_event_id = lab_id"
   ELSEIF (cnvtint(sub_type)=3)
    SET lab_events->order_id = 0
    SET ce_result_filter = "ce.event_id = lab_id"
   ENDIF
   SELECT INTO "nl:"
    FROM clinical_event ce,
     v500_event_set_explode vese
    WHERE parser(ce_result_filter)
     AND ce.event_cd=vese.event_cd
     AND expand(num,1,br_muse_filters->qual[lab_result_idx].val_cnt,vese.event_set_cd,br_muse_filters
     ->qual[lab_result_idx].vals[num].value)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce.result_status_cd IN (auth_cd, modified_cd, altered_cd)
     AND ce.view_level=1
    ORDER BY ce.event_id
    HEAD REPORT
     cnt = 0
    HEAD ce.event_id
     cnt = (cnt+ 1), stat = alterlist(lab_events->qual,cnt), lab_events->qual[cnt].event_id = ce
     .event_id,
     lab_events->qual[cnt].event_cd = ce.event_cd, lab_events->qual[cnt].event_tag = ce.event_tag,
     lab_events->qual[cnt].event_class_cd = ce.event_class_cd,
     lab_events->qual[cnt].contrib_sys_cd = ce.contributor_system_cd, lab_events->qual[cnt].
     resource_cd = ce.resource_cd
    WITH nocounter, expand = 1
   ;end select
   FOR (i = 1 TO size(lab_events->qual,5))
     FOR (j = 1 TO br_muse_filters->cnt)
       IF ((br_muse_filters->qual[j].filter_mean="MUSE_LAB_DISQUALIFIED_TEXT_*"))
        IF ((lab_events->qual[i].event_tag=br_muse_filters->qual[j].vals[1].text))
         SET lab_events->qual[i].disq_txt_ind = 1
        ENDIF
       ENDIF
     ENDFOR
     IF ((lab_events->qual[i].event_class_cd IN (count_cd, num_cd, interp_cd, mbo_cd)))
      SET lab_events->qual[i].struct_res_ind = 1
     ENDIF
     IF ((lab_events->qual[i].event_class_cd=txt_cd)
      AND (lab_events->qual[i].contrib_sys_cd != powerchart_cd))
      SET lab_events->qual[i].freetext_nonpc_ind = 1
     ENDIF
     IF ((lab_events->qual[i].event_class_cd=txt_cd)
      AND (lab_events->qual[i].contrib_sys_cd=powerchart_cd))
      SET lab_events->qual[i].freetext_pc_ind = 1
      IF (rli_idx != 0
       AND locateval(num,1,br_muse_filters->qual[rli_idx].val_cnt,lab_events->qual[i].resource_cd,
       br_muse_filters->qual[rli_idx].vals[num].value) != 0)
       SET lab_events->qual[i].rli_ind = 1
      ELSE
       SELECT INTO "nl:"
        FROM ce_coded_result ccr
        WHERE (ccr.event_id=lab_events->qual[i].event_id)
         AND ccr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
        DETAIL
         lab_events->qual[i].ccr_ind = 1
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
     IF ((lab_events->qual[i].disq_txt_ind=0)
      AND (((lab_events->qual[i].struct_res_ind=1)) OR ((((lab_events->qual[i].freetext_nonpc_ind=1))
      OR ((lab_events->qual[i].freetext_pc_ind=1)
      AND (((lab_events->qual[i].rli_ind=1)) OR ((lab_events->qual[i].ccr_ind=1))) )) )) )
      SET lab_events->qual[i].met_ind = 1
     ENDIF
   ENDFOR
   IF (size(lab_events->qual,5) > 0
    AND locateval(num,1,size(lab_events->qual,5),0,lab_events->qual[num].met_ind)=0)
    SET lab_events->met_ind = 1
   ENDIF
   SELECT INTO mine
    FROM dual
    DETAIL
     row + 1,
     CALL print(concat("  Lab-only or order-based? ",evaluate(lab_events->order_id,0,"Lab-only",
       "Order-based"))), row + 1
     IF ((lab_events->order_id != 0))
      CALL print(concat("    Order_id: ",cnvtstring(lab_events->order_id)))
     ELSE
      CALL print(concat("  Clinical_event_id: ",cnvtstring(lab_id)))
     ENDIF
     row + 1,
     CALL print(concat("  All events met? ",evaluate(lab_events->met_ind,1,"Yes",0,"No"))), row + 2,
     CALL print(
     "-------------------------------------------- EVENTS ---------------------------------------------"
     )
     IF (size(lab_events->qual,5)=0)
      row + 2,
      CALL print("    No events exist on order.")
     ELSE
      FOR (i = 1 TO size(lab_events->qual,5))
        row + 2,
        CALL print(concat("    Event_id: ",trim(cnvtstring(lab_events->qual[i].event_id)))), row + 1,
        CALL print(concat("    Event code: ",trim(cnvtstring(lab_events->qual[i].event_cd))," ",
         uar_get_code_display(lab_events->qual[i].event_cd))), row + 1,
        CALL print(concat("    Met? ",evaluate(lab_events->qual[i].met_ind,1,"Yes",0,"No"))),
        row + 2,
        CALL print(concat("    Event class code: ",trim(cnvtstring(lab_events->qual[i].event_class_cd
           ))," ",uar_get_code_display(lab_events->qual[i].event_class_cd))), row + 1,
        CALL print(concat("    Contributor system code: ",trim(cnvtstring(lab_events->qual[i].
           contrib_sys_cd))," ",uar_get_code_display(lab_events->qual[i].contrib_sys_cd))), row + 1,
        CALL print(concat("    Resource code: ",trim(cnvtstring(lab_events->qual[i].resource_cd))," ",
         uar_get_code_display(lab_events->qual[i].resource_cd))),
        row + 2,
        CALL print(concat("      Disqualifited text? ",evaluate(lab_events->qual[i].disq_txt_ind,1,
          "Yes",0,"No"))), row + 2,
        CALL print("      Event must be one of the following:"), row + 1,
        CALL print(concat("        1) Event class code NUM, COUNT, INTERP, or MBO? ",evaluate(
          lab_events->qual[i].struct_res_ind,1,"Yes",0,"No"))),
        row + 2,
        CALL print(concat("        2) Event class code TXT and contributor system NOT POWERCHART? ",
         evaluate(lab_events->qual[i].freetext_nonpc_ind,1,"Yes",0,"No"))), row + 2,
        CALL print(concat("        3) Event class code TXT and contributor system POWERCHART? ",
         evaluate(lab_events->qual[i].freetext_pc_ind,1,"Yes",0,"No"))), row + 1,
        CALL print("             AND one of the following:"),
        row + 1,
        CALL print(concat(
         "               a) Resource filters populated and resource_cd of event included in filters? ",
         evaluate(lab_events->qual[i].rli_ind,1,"Yes",0,"No"))), row + 1,
        CALL print(concat(
         "               b) Is the TXT result codified (event code exists on ce_coded_result)? ",
         evaluate(lab_events->qual[i].ccr_ind,1,"Yes",0,"No"))), row + 2,
        CALL print(
        "-------------------------------------------------------------------------------------------------"
        )
      ENDFOR
     ENDIF
    WITH nocounter, noformfeed
   ;end select
   FREE RECORD lab_events
 END ;Subroutine
 SUBROUTINE getencntr(null)
   DECLARE r_encntr_id = f8 WITH noconstant(- (1))
   FREE RECORD enc_id_menu
   RECORD enc_id_menu(
     1 menu[*]
       2 menu_id = i2
       2 parent_id = i2
       2 data[*]
         3 menu_item = c29
         3 child_id = i2
       2 menu_type_flg = i2
   )
   CALL addmenuitem(enc_id_menu,1,"Enter by FIN",0,2,
    0)
   CALL addmenuitem(enc_id_menu,1,"Enter by ENCNTR_ID",0,3,
    0)
   CALL addmenuitem(enc_id_menu,2,"Enter FIN",1,0,
    2)
   CALL addmenuitem(enc_id_menu,3,"Enter ENCNTR_ID",1,0,
    1)
   SET menu_ret->lvl = 1
   WHILE ((r_encntr_id=- (1)))
     CALL menudisp(enc_id_menu,menu_ret->lvl)
     CALL echo(build("menu_ret->num :",menu_ret->num))
     CALL echo(build("menu_ret->str :",menu_ret->str))
     IF ((menu_ret->lvl=- (1)))
      RETURN(- (1))
     ELSEIF ((menu_ret->lvl=3)
      AND (menu_ret->num <= 0))
      CALL echo("ENCNTR_ID 0 or blank not valid.")
      CALL menuprompt("ENCNTR_ID 0 or blank not valid.  Press enter to continue.",3)
     ELSEIF ((menu_ret->lvl=2)
      AND (menu_ret->str=""))
      CALL echo("Blank FIN not valid.")
      CALL menuprompt("Blank FIN not valid.  Press enter to continue.",3)
     ELSE
      SELECT
       IF ((menu_ret->lvl=3))
        FROM encounter e
        WHERE (e.encntr_id=menu_ret->num)
       ELSEIF ((menu_ret->lvl=2))
        FROM encounter e,
         encntr_alias ea,
         code_value cv
        WHERE (ea.alias=menu_ret->str)
         AND e.encntr_id=ea.encntr_id
         AND cv.code_value=ea.encntr_alias_type_cd
         AND cv.code_set=319
         AND cv.cdf_meaning="FIN NBR"
       ELSE
       ENDIF
       DISTINCT INTO "nl:"
       e.encntr_id
       DETAIL
        r_encntr_id = e.encntr_id
       WITH nocounter
      ;end select
      IF (curqual=0)
       CALL echo("ENCNTR_ID or FIN not found.")
       CALL menuprompt("ENCNTR_ID or FIN not found.  Press enter to continue.",3)
      ELSE
       CALL echo(build("RETURNING ENCNTR_ID :",r_encntr_id))
       RETURN(r_encntr_id)
      ENDIF
     ENDIF
   ENDWHILE
   FREE RECORD enc_id_menu
 END ;Subroutine
 SUBROUTINE getorderid(null)
   DECLARE r_order_id = f8 WITH noconstant(- (1))
   FREE RECORD ord_id_menu
   RECORD ord_id_menu(
     1 menu[*]
       2 menu_id = i2
       2 parent_id = i2
       2 data[*]
         3 menu_item = c29
         3 child_id = i2
       2 menu_type_flg = i2
   )
   CALL addmenuitem(ord_id_menu,1,"Enter ORDER_ID",0,0,
    1)
   WHILE ((r_order_id=- (1)))
     CALL menudisp(ord_id_menu)
     CALL echo(build("menu_ret->num :",menu_ret->num))
     CALL echo(build("menu_ret->str :",menu_ret->str))
     IF ((menu_ret->lvl=- (1)))
      RETURN(- (1))
     ELSEIF ((menu_ret->lvl=1)
      AND (menu_ret->num <= 0))
      CALL echo("ORDER_ID 0 or blank not valid.")
      CALL menuprompt("ORDER_ID 0 or blank not valid.  Press enter to continue.",3)
     ELSE
      SELECT INTO "nl:"
       o.order_id
       FROM orders o
       WHERE (o.order_id=menu_ret->num)
       DETAIL
        r_order_id = o.order_id
       WITH nocounter
      ;end select
      IF (curqual=0)
       CALL echo("ORDER_ID not found.")
       CALL menuprompt("ORDER_ID not found.  Press enter to continue.",3)
      ELSE
       CALL echo(build("RETURNING ORDER_ID :",r_order_id))
       RETURN(r_order_id)
      ENDIF
     ENDIF
   ENDWHILE
   FREE RECORD ord_id_menu
 END ;Subroutine
 SUBROUTINE geteventid(null)
   DECLARE r_event_id = f8 WITH noconstant(- (1)), protect
   FREE RECORD event_id_menu
   RECORD event_id_menu(
     1 menu[*]
       2 menu_id = i2
       2 parent_id = i2
       2 data[*]
         3 menu_item = c29
         3 child_id = i2
       2 menu_type_flg = i2
   )
   CALL addmenuitem(event_id_menu,1,"Enter EVENT_ID",0,0,
    1)
   WHILE ((r_event_id=- (1)))
     CALL menudisp(event_id_menu)
     CALL echo(build("menu_ret->num :",menu_ret->num))
     CALL echo(build("menu_ret->str :",menu_ret->str))
     IF ((menu_ret->lvl=- (1)))
      RETURN(- (1))
     ELSEIF ((menu_ret->lvl=1)
      AND (menu_ret->num <= 0))
      CALL echo("EVENT_ID 0 or blank not valid.")
      CALL menuprompt("EVENT_ID 0 or blank not valid.  Press enter to continue.",3)
     ELSE
      SELECT INTO "nl:"
       ce.event_id
       FROM clinical_event ce
       WHERE (ce.event_id=menu_ret->num)
       DETAIL
        r_event_id = ce.event_id
       WITH nocounter
      ;end select
      IF (curqual=0)
       CALL echo("EVENT_ID not found.")
       CALL menuprompt("EVENT_ID not found.  Press enter to continue.",3)
      ELSE
       CALL echo(build("RETURNING EVENT_ID :",r_event_id))
       RETURN(r_event_id)
      ENDIF
     ENDIF
   ENDWHILE
   FREE RECORD event_id_menu
 END ;Subroutine
 SUBROUTINE getbedrockfilters(rec,cat_name)
   DECLARE f_idx = i4 WITH noconstant(0), protect
   DECLARE num = i2 WITH noconstant(0), protect
   DECLARE service_type = vc WITH noconstant("SERVICE_TYPE"), protect
   DECLARE hosp_type = vc WITH noconstant("HOSP_SERV_CDS"), protect
   SELECT INTO "NL:"
    FROM br_datamart_category cat,
     br_datamart_filter fil,
     br_datamart_value val
    WHERE cat.category_mean=cat_name
     AND cat.br_datamart_category_id=fil.br_datamart_category_id
     AND fil.br_datamart_category_id=cat.br_datamart_category_id
     AND fil.br_datamart_filter_id=val.br_datamart_filter_id
     AND val.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    ORDER BY fil.br_datamart_filter_id
    HEAD REPORT
     batch_size = 50, filter_cnt = size(br_muse_filters->qual,5), stat = alterlist(br_muse_filters->
      qual,(filter_cnt+ batch_size))
    HEAD fil.br_datamart_filter_id
     filter_cnt = (filter_cnt+ 1)
     IF (filter_cnt > size(br_muse_filters->qual,5))
      stat = alterlist(br_muse_filters->qual,(filter_cnt+ batch_size))
     ENDIF
     br_muse_filters->qual[filter_cnt].filter_mean = fil.filter_mean, cnt = 0, stat = alterlist(
      br_muse_filters->qual[filter_cnt].vals,batch_size)
    HEAD val.br_datamart_value_id
     cnt = (cnt+ 1)
     IF (cnt > size(br_muse_filters->qual[filter_cnt].vals,5))
      stat = alterlist(br_muse_filters->qual[filter_cnt].vals,(cnt+ batch_size))
     ENDIF
     IF (val.parent_entity_id > 0)
      br_muse_filters->qual[filter_cnt].vals[cnt].value = val.parent_entity_id
     ELSEIF (fil.filter_category_mean IN ("LINK_ENTRY", "MESSAGE_TYPE"))
      br_muse_filters->qual[filter_cnt].vals[cnt].text = trim(val.freetext_desc,3)
     ELSE
      br_muse_filters->qual[filter_cnt].vals[cnt].value = cnvtreal(val.freetext_desc)
     ENDIF
    FOOT  fil.br_datamart_filter_id
     stat = alterlist(br_muse_filters->qual[filter_cnt].vals,cnt), br_muse_filters->qual[filter_cnt].
     val_cnt = cnt
    FOOT REPORT
     stat = alterlist(br_muse_filters->qual,filter_cnt), br_muse_filters->cnt = filter_cnt
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE addmenuitem(menu_rec,menu_id,menu_item,parent_id,child_id,menu_type_flg)
   SET num = 0
   SET menu_cnt = size(menu_rec->menu,5)
   SET menu_pos = locateval(num,1,menu_cnt,menu_id,menu_rec->menu[num].menu_id)
   IF (((menu_cnt=0) OR (menu_pos=0)) )
    SET menu_cnt = (menu_cnt+ 1)
    SET menu_pos = menu_cnt
    SET stat = alterlist(menu_rec->menu,menu_cnt)
    SET stat = alterlist(menu_rec->menu[menu_cnt].data,1)
    SET data_pos = 1
   ELSE
    SET data_pos = (size(menu_rec->menu[menu_pos].data,5)+ 1)
    SET stat = alterlist(menu_rec->menu[menu_pos].data,data_pos)
   ENDIF
   SET menu_rec->menu[menu_pos].menu_id = menu_id
   SET menu_rec->menu[menu_pos].parent_id = parent_id
   SET menu_rec->menu[menu_pos].menu_type_flg = menu_type_flg
   SET menu_rec->menu[menu_pos].data[data_pos].menu_item = menu_item
   SET menu_rec->menu[menu_pos].data[data_pos].child_id = child_id
 END ;Subroutine
 SUBROUTINE menudisplay(null)
   CALL clear(1,1)
   CALL clear(24,1,132)
   CALL video(nw)
   CALL box(1,1,22,132)
   CALL text(3,43,c_title)
   CALL line(5,1,132,xhor)
   IF (validate(mufx_menu->menu[curlvl].select_str)=1)
    SET c_msg1 = mufx_menu->menu[curlvl].select_str
   ENDIF
   CALL text(7,3,c_msg1)
   CALL text(23,103,c_scroll)
   CALL text(24,107,c_prev)
   IF ( NOT ((mufx_menu->menu[curlvl].menu_type_flg IN (0, 3))))
    CALL text(24,1,"Enter :  ")
   ENDIF
   IF (validate(mufx_menu->menu[curlvl].header_str)=1)
    CALL text(8,5,mufx_menu->menu[curlvl].header_str)
   ENDIF
   SET maxcnt = size(mufx_menu->menu[curlvl].data,5)
   SET srowoff = 9
   SET scoloff = 5
   SET numsrow = 10
   SET numscol = 29
   FOR (i = 1 TO size(mufx_menu->menu[curlvl].data,5))
     IF (numscol < textlen(trim(mufx_menu->menu[curlvl].data[i].menu_item)))
      SET numscol = textlen(trim(mufx_menu->menu[curlvl].data[i].menu_item))
     ENDIF
   ENDFOR
   CALL scrollinit(srowoff,scoloff,((srowoff+ numsrow) - 1),((scoloff+ numscol) - 1))
   SET k = 1
   WHILE (k <= numsrow
    AND k <= maxcnt)
    CALL scrolltext(k,mufx_menu->menu[curlvl].data[k].menu_item)
    SET k = (k+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
 END ;Subroutine
 SUBROUTINE menudisp(mufx_menu,start_idx)
   SET c_title = " ************ MUFX Troubleshooting ************ "
   DECLARE c_msg1 = vc
   SET c_msg1 = "Select an option:"
   SET c_exit = "<F10> to Exit"
   SET c_scroll = "<pgup> or <pgdwn> to scroll"
   SET c_prev = "<F10> for Previous Menu"
   SET home = end_program
   SET help = off
   SET change_val_ind = 0
   SET key_down = 1
   SET key_up = 2
   SET key_return = 0
   SET key_f10 = 10
   SET key_pgup = 5
   SET key_pgdn = 6
   DECLARE acc_str = vc WITH protect
   DECLARE picmod_str = vc WITH protect
   DECLARE i = i4 WITH protect
   SET curlvl = start_idx WITH protect
   DECLARE cnt = i2
   DECLARE arow = i2
   DECLARE maxcnt = i4
   DECLARE srowoff = i2
   DECLARE scoloff = i2
   DECLARE numsrow = i2
   DECLARE numscol = i2
   CALL menudisplay(null)
   SET menu_ret->lvl = - (1)
   SET menu_ret->lvl = - (1)
   SET menu_ret->num = - (1)
   SET menu_ret->str = ""
   SET cont = 1
   WHILE (cont=1)
     IF ((mufx_menu->menu[curlvl].menu_type_flg=1))
      SET acc_str = ""
      SET picmod_str = "N(16);S"
      SET acc_col = 10
     ELSEIF ((mufx_menu->menu[curlvl].menu_type_flg=2))
      SET acc_str = ""
      SET picmod_str = "P(39);CSU"
      SET acc_col = 10
     ELSEIF ((mufx_menu->menu[curlvl].menu_type_flg=3))
      SET acc_str = ""
      SET picmod_str = ";D"
      SET acc_col = 1
     ELSE
      SET acc_str = ""
      SET picmod_str = ";S"
      SET acc_col = 1
     ENDIF
     CALL accept(24,acc_col,picmod_str,acc_str)
     CASE (curscroll)
      OF key_down:
       IF (cnt < maxcnt)
        SET cnt = (cnt+ 1)
        IF (arow=numsrow)
         CALL scrolldown(arow,arow,mufx_menu->menu[curlvl].data[cnt])
        ELSE
         SET arow = (arow+ 1)
         CALL scrolldown((arow - 1),arow,mufx_menu->menu[curlvl].data[cnt])
        ENDIF
       ENDIF
      OF key_up:
       IF (cnt != 1)
        SET cnt = (cnt - 1)
        IF (arow=1)
         CALL scrollup(arow,arow,mufx_menu->menu[curlvl].data[cnt])
        ELSE
         SET arow = (arow - 1)
         CALL scrollup((arow+ 1),arow,mufx_menu->menu[curlvl].data[cnt])
        ENDIF
       ENDIF
      OF key_pgdn:
       FOR (i = 1 TO numsrow)
         IF (cnt < maxcnt)
          SET cnt = (cnt+ 1)
          IF (arow=numsrow)
           CALL scrolldown(arow,arow,mufx_menu->menu[curlvl].data[cnt])
          ELSE
           SET arow = (arow+ 1)
           CALL scrolldown((arow - 1),arow,mufx_menu->menu[curlvl].data[cnt])
          ENDIF
         ENDIF
       ENDFOR
      OF 23:
      OF key_pgup:
       FOR (i = 1 TO numsrow)
         IF (cnt != 1)
          SET cnt = (cnt - 1)
          IF (arow=1)
           CALL scrollup(arow,arow,mufx_menu->menu[curlvl].data[cnt])
          ELSE
           SET arow = (arow - 1)
           CALL scrollup((arow+ 1),arow,mufx_menu->menu[curlvl].data[cnt])
          ENDIF
         ENDIF
       ENDFOR
      OF key_return:
       IF ((mufx_menu->menu[curlvl].data[cnt].child_id=0))
        SET cont = 0
        SET menu_ret->lvl = curlvl
        SET menu_ret->val = cnt
        IF ((mufx_menu->menu[curlvl].menu_type_flg=1))
         SET menu_ret->num = curaccept
        ELSEIF ((mufx_menu->menu[curlvl].menu_type_flg=2))
         SET menu_ret->str = curaccept
        ENDIF
        RETURN
       ELSE
        SET curlvl = mufx_menu->menu[curlvl].data[cnt].child_id
        CALL menudisplay(null)
       ENDIF
      OF key_f10:
       IF ((mufx_menu->menu[curlvl].parent_id=0))
        SET cont = 0
       ELSE
        SET curlvl = mufx_menu->menu[curlvl].parent_id
        CALL menudisplay(null)
       ENDIF
      ELSE
       SET cont = 1
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE menuprompt(prompt_str,prompt_flg)
   SET stat = alterlist(prompt_menu->menu,0)
   CALL addmenuitem(prompt_menu,1,prompt_str,0,0,
    prompt_flg)
   CALL menudisp(prompt_menu,1)
 END ;Subroutine
#end_program
 FREE RECORD menu_ret
 FREE RECORD prompt_menu
 FREE RECORD main_menu
 FREE RECORD br_muse_filters
END GO

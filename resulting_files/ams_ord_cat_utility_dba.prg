CREATE PROGRAM ams_ord_cat_utility:dba
 PAINT
 SET modify = predeclare
 DECLARE clearscreen(null) = null WITH protect
 DECLARE drawscrollbox(begrow=i4,begcol=i4,endrow=i4,endcol=i4) = null WITH protect
 DECLARE downarrow(newrow=c75) = null WITH protect
 DECLARE uparrow(newrow=c75) = null WITH protect
 DECLARE buildactionrowstr(i=i4) = c75 WITH protect
 DECLARE buildprimaryrowstr(i=i4) = c75 WITH protect
 DECLARE lookupprsnlid(susername=vc) = f8 WITH protect
 DECLARE getcopycatalog(null) = null WITH protect
 DECLARE getcatalogsbydate(null) = null WITH protect
 DECLARE displaycatalogsettings(null) = null WITH protect
 DECLARE displaycatalogstoupdate(null) = null WITH protect
 DECLARE determineupdates(null) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE incrementprimarycount(inccnt=i4) = i2 WITH protect
 FREE RECORD catalogs
 RECORD catalogs(
   1 list_sz = i4
   1 list[*]
     2 catalog_cd = f8
     2 primary = vc
     2 cosigs[*]
       3 action_flag = i4
       3 action_type_cd = f8
       3 physician = i2
       3 nurse = i2
       3 pharm = i2
 )
 FREE RECORD copy_cat
 RECORD copy_cat(
   1 catalog_cd = f8
   1 dc_disp_days = i4
   1 dc_interact_days = i4
   1 stop_duration = i4
   1 stop_duraction_unit_cd = f8
   1 stop_type_cd = f8
   1 print_req_ind = i2
   1 req_format_cd = f8
   1 req_route_cd = f8
   1 consent_form_format_cd = f8
   1 consent_form_ind = i2
   1 consent_form_routing_cd = f8
   1 complete_on_order_ind = i2
   1 cancel_on_discharge_ind = i2
   1 disable_ord_cmnt_ind = i2
   1 bill_only_ind = i2
   1 discern_av_flag = i2
   1 ic_av_flag = i2
   1 cosigs[*]
     2 action_type_cd = f8
     2 physician = i2
     2 nurse = i2
     2 pharm = i2
 )
 DECLARE last_mod = vc WITH protect
 DECLARE debugind = i2 WITH protect
 DECLARE errorind = i2 WITH protect
 DECLARE errorstr = vc WITH protect
 DECLARE numrows = i4 WITH constant(20), protect
 DECLARE numcols = i4 WITH constant(75), protect
 DECLARE soffrow = i4 WITH constant(6), protect
 DECLARE soffcol = i4 WITH constant(3), protect
 DECLARE searchdttm = dq8 WITH protect
 DECLARE i = i4 WITH protect
 DECLARE j = i4 WITH protect
 DECLARE micheckallusers = i2 WITH protect
 DECLARE micopyavsettings = i2 WITH protect
 DECLARE mfuserprsnlid = f8 WITH protect
 DECLARE cdpharm = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE copycat = vc WITH protect
 DECLARE script_name = c19 WITH protect, constant("AMS_ORD_CAT_UTILITY")
 EXECUTE cclseclogin
 IF ((xxcclseclogin->loggedin != 1))
  SET errorind = 1
  SET errorstr = "You must be logged in securely. Please run the program again."
  GO TO exit_script
 ENDIF
 IF (validate(debug,0)=1)
  CALL echo("Debug Mode Enabled")
  SET debugind = 1
 ELSE
  SET trace = callecho
  SET trace = notest
  SET trace = noechoinput
  SET trace = noechoinput2
  SET trace = noechorecord
  SET trace = noshowuar
  SET message = noinformation
  SET trace = nocost
 ENDIF
#main_menu
 SET stat = initrec(catalogs)
 SET stat = initrec(copy_cat)
 CALL clear(1,1)
 CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
 CALL video(r)
 CALL text((soffrow - 4),soffcol,
  "                         AMS Order Catalog Utility                         ")
 CALL text((soffrow - 3),soffcol,
  "        Copy Settings From One Pharmacy Primary To Selected Others         ")
 CALL video(n)
 CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
 CALL text((soffrow+ 4),(soffcol+ 4),"Search for primaries by:")
 CALL text((soffrow+ 5),(soffcol+ 28),"1 Date Range")
 CALL text((soffrow+ 6),(soffcol+ 28),"2 Specific Primaries")
 CALL text((soffrow+ 7),(soffcol+ 28),"3 Exit")
 CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
 CALL text((soffrow+ 16),soffcol,"Choose mode:")
 CALL accept((soffrow+ 16),(soffcol+ 13),"9;",3
  WHERE curaccept IN (1, 2, 3))
 CASE (curaccept)
  OF 1:
   CALL clearscreen(null)
   EXECUTE FROM date TO end_date
  OF 2:
   CALL clearscreen(null)
   EXECUTE FROM pick TO end_pick
  OF 3:
   GO TO exit_script
 ENDCASE
#date
 CALL getcopycatalog(null)
 CALL text((soffrow+ 2),soffcol,"Enter date of when primaries were last updated:")
 CALL accept((soffrow+ 2),(soffcol+ 48),"NNDNNDNNNN;C",format(curdate,"MM/DD/YYYY;;D")
  WHERE format(cnvtdate(cnvtalphanum(curaccept)),"MM/DD/YYYY;;D")=curaccept)
 SET searchdttm = cnvtdatetime(cnvtdate(cnvtalphanum(curaccept)),0000)
#invalid_user
 CALL text((soffrow+ 3),soffcol,"Enter username who updated the primaries last (or ALL):")
 CALL accept((soffrow+ 3),(soffcol+ 56),"P(19);CU","ALL")
 IF (curaccept="ALL")
  SET micheckallusers = 1
 ELSE
  SET mfuserprsnlid = lookupprsnlid(curaccept)
 ENDIF
 CALL clear((soffrow+ 4),soffcol,numcols)
 CALL text((soffrow+ 4),soffcol,"Do you want to copy auto verify settings (use with caution):")
 CALL accept((soffrow+ 4),(soffcol+ 61),"A;CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET micopyavsettings = 1
 ELSE
  SET micopyavsettings = 0
 ENDIF
 CALL displaycatalogsettings(null)
 CALL getcatalogsbydate(null)
 CALL displaycatalogstoupdate(null)
 GO TO main_menu
#end_date
#pick
 CALL getcopycatalog(null)
#next_primary
 CALL text((soffrow+ 2),soffcol,"Enter primary to copy to (Shift+F5 to select):")
 SET help = promptmsg("Primary starts with:")
 SET help =
 SELECT INTO "nl:"
  primary = cnvtupper(oc.primary_mnemonic)
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.catalog_type_cd=cdpharm
    AND oc.active_ind=1
    AND cnvtupper(oc.primary_mnemonic) >= cnvtupper(curaccept))
  ORDER BY cnvtupper(oc.primary_mnemonic)
 ;end select
 CALL accept((soffrow+ 3),(soffcol+ 3),"P(70);CUP")
 SET copycat = trim(cnvtupper(curaccept))
 SET help = off
 SELECT INTO "nl:"
  oc.primary_mnemonic, oc.catalog_cd, action = uar_get_code_display(ocr.action_type_cd)
  FROM order_catalog oc,
   order_catalog_review ocr
  PLAN (oc
   WHERE oc.catalog_type_cd=cdpharm
    AND oc.active_ind=1
    AND cnvtupper(oc.primary_mnemonic)=copycat)
   JOIN (ocr
   WHERE ocr.catalog_cd=outerjoin(oc.catalog_cd))
  ORDER BY oc.catalog_cd, action
  HEAD REPORT
   i = catalogs->list_sz, j = 0
  HEAD oc.catalog_cd
   i = (i+ 1), stat = alterlist(catalogs->list,i), catalogs->list[i].catalog_cd = oc.catalog_cd,
   catalogs->list[i].primary = oc.primary_mnemonic
  DETAIL
   j = (j+ 1), stat = alterlist(catalogs->list[i].cosigs,j), catalogs->list[i].cosigs[j].action_flag
    = 0,
   catalogs->list[i].cosigs[j].action_type_cd = ocr.action_type_cd, catalogs->list[i].cosigs[j].nurse
    = ocr.nurse_review_flag, catalogs->list[i].cosigs[j].pharm = ocr.rx_verify_flag,
   catalogs->list[i].cosigs[j].physician = ocr.doctor_cosign_flag
  FOOT  oc.catalog_cd
   j = 0
  FOOT REPORT
   catalogs->list_sz = i
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text((soffrow+ 4),soffcol,"No primary found! Enter valid primary")
  GO TO next_primary
 ENDIF
 CALL clear((soffrow+ 4),soffcol,numcols)
 CALL text((soffrow+ 4),soffcol,"Enter another primary?:")
 CALL accept((soffrow+ 4),(soffcol+ 24),"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  GO TO next_primary
 ENDIF
 CALL text((soffrow+ 5),soffcol,"Do you want to copy auto verify settings (use with caution):")
 CALL accept((soffrow+ 5),(soffcol+ 61),"A;CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET micopyavsettings = 1
 ELSE
  SET micopyavsettings = 0
 ENDIF
 IF (debugind=1)
  CALL echo("catalogs rec after being populated")
  CALL echorecord(catalogs)
 ENDIF
 CALL displaycatalogsettings(null)
 CALL displaycatalogstoupdate(null)
 GO TO main_menu
#end_pick
 SUBROUTINE getcopycatalog(null)
   DECLARE i = i4
   SET stat = initrec(catalogs)
   CALL text(soffrow,soffcol,"Enter primary to copy from (Shift+F5 to select):")
   SET help = promptmsg("Primary starts with:")
   SET help =
   SELECT INTO "nl:"
    primary = cnvtupper(oc.primary_mnemonic)
    FROM order_catalog oc
    PLAN (oc
     WHERE oc.catalog_type_cd=cdpharm
      AND oc.active_ind=1
      AND cnvtupper(oc.primary_mnemonic) >= cnvtupper(curaccept))
    ORDER BY cnvtupper(oc.primary_mnemonic)
   ;end select
   CALL accept((soffrow+ 1),(soffcol+ 3),"P(70);CUP","MLTMAUTOTEST")
   SET copycat = trim(cnvtupper(curaccept))
   SET help = off
   SELECT INTO "nl:"
    oc.primary_mnemonic, oc.catalog_cd, action = uar_get_code_display(ocr.action_type_cd)
    FROM order_catalog oc,
     order_catalog_review ocr
    PLAN (oc
     WHERE oc.catalog_type_cd=cdpharm
      AND oc.active_ind=1
      AND cnvtupper(oc.primary_mnemonic)=copycat)
     JOIN (ocr
     WHERE ocr.catalog_cd=outerjoin(oc.catalog_cd))
    ORDER BY oc.catalog_cd, action
    HEAD REPORT
     i = 0
    HEAD oc.catalog_cd
     copy_cat->catalog_cd = oc.catalog_cd, copy_cat->dc_disp_days = oc.dc_display_days, copy_cat->
     dc_interact_days = oc.dc_interaction_days,
     copy_cat->stop_duration = oc.stop_duration, copy_cat->stop_duraction_unit_cd = oc
     .stop_duration_unit_cd, copy_cat->stop_type_cd = oc.stop_type_cd,
     copy_cat->print_req_ind = oc.print_req_ind, copy_cat->req_format_cd = oc.requisition_format_cd,
     copy_cat->req_route_cd = oc.requisition_routing_cd,
     copy_cat->consent_form_routing_cd = oc.consent_form_routing_cd, copy_cat->consent_form_ind = oc
     .consent_form_ind, copy_cat->consent_form_format_cd = oc.consent_form_format_cd,
     copy_cat->complete_on_order_ind = oc.complete_upon_order_ind, copy_cat->cancel_on_discharge_ind
      = oc.auto_cancel_ind, copy_cat->disable_ord_cmnt_ind = oc.disable_order_comment_ind,
     copy_cat->bill_only_ind = oc.bill_only_ind, copy_cat->discern_av_flag = oc
     .discern_auto_verify_flag, copy_cat->ic_av_flag = oc.ic_auto_verify_flag
    DETAIL
     IF (ocr.action_type_cd > 0)
      i = (i+ 1)
      IF (mod(i,10)=1)
       stat = alterlist(copy_cat->cosigs,(i+ 9))
      ENDIF
      copy_cat->cosigs[i].action_type_cd = ocr.action_type_cd, copy_cat->cosigs[i].nurse = ocr
      .nurse_review_flag, copy_cat->cosigs[i].pharm = ocr.rx_verify_flag,
      copy_cat->cosigs[i].physician = ocr.doctor_cosign_flag
     ENDIF
    FOOT REPORT
     IF (mod(i,10) != 0)
      stat = alterlist(copy_cat->cosigs,i)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL text((soffrow+ 2),soffcol,"No primary found! Enter valid order catalog primary")
    CALL getcopycatalog(null)
   ENDIF
   IF (debugind=1)
    CALL echo("copy_cat rec after being populated")
    CALL echorecord(copy_cat)
   ENDIF
   CALL clear((soffrow+ 2),soffcol,numcols)
 END ;Subroutine
 SUBROUTINE getcatalogsbydate(null)
   DECLARE i = i4
   DECLARE j = i4
   SELECT INTO "nl:"
    oc.catalog_cd, oc.primary_mnemonic
    FROM order_catalog oc,
     order_catalog_review ocr
    PLAN (oc
     WHERE oc.catalog_type_cd=cdpharm
      AND oc.active_ind=1
      AND oc.updt_dt_tm >= cnvtdatetime(searchdttm)
      AND ((oc.updt_id=mfuserprsnlid) OR (micheckallusers=1))
      AND (oc.catalog_cd != copy_cat->catalog_cd))
     JOIN (ocr
     WHERE ocr.catalog_cd=outerjoin(oc.catalog_cd))
    ORDER BY cnvtupper(oc.primary_mnemonic)
    HEAD REPORT
     i = 0, j = 0
    HEAD oc.primary_mnemonic
     i = (i+ 1)
     IF (mod(i,10)=1)
      stat = alterlist(catalogs->list,(i+ 9))
     ENDIF
     catalogs->list_sz = i, catalogs->list[i].catalog_cd = oc.catalog_cd, catalogs->list[i].primary
      = oc.primary_mnemonic
    DETAIL
     IF (ocr.catalog_cd > 0)
      j = (j+ 1)
      IF (mod(j,10)=1)
       stat = alterlist(catalogs->list[i].cosigs,(j+ 9))
      ENDIF
      catalogs->list[i].cosigs[j].action_flag = 0, catalogs->list[i].cosigs[j].action_type_cd = ocr
      .action_type_cd, catalogs->list[i].cosigs[j].nurse = ocr.nurse_review_flag,
      catalogs->list[i].cosigs[j].pharm = ocr.rx_verify_flag, catalogs->list[i].cosigs[j].physician
       = ocr.doctor_cosign_flag
     ENDIF
    FOOT  oc.primary_mnemonic
     IF (mod(j,10) != 0)
      stat = alterlist(catalogs->list[i].cosigs,j)
     ENDIF
     j = 0
    FOOT REPORT
     IF (mod(i,10) != 0)
      stat = alterlist(catalogs->list,i)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL text((soffrow+ 14),soffcol,"No primaries found using search parameters")
    CALL text((soffrow+ 16),soffcol,"Search again? (Y)es (N)o:")
    CALL accept((soffrow+ 16),(soffcol+ 26),"A;CU","Y"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="N")
     GO TO main_menu
    ELSEIF (curaccept="Y")
     CALL clearscreen(null)
     GO TO date
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE displaycatalogsettings(null)
   DECLARE maxrows = i4 WITH noconstant(5), protect
   DECLARE cnt = i4 WITH protect
   DECLARE arow = i4 WITH protect
   DECLARE str = c75 WITH protect
   CALL clearscreen(null)
   CALL text((soffrow+ 0),(soffcol+ 4),"Miscellaneous")
   CALL line((soffrow+ 1),(soffcol+ 1),19)
   CALL text((soffrow+ 2),soffcol,build2("DC Display Days: ",cnvtstring(copy_cat->dc_disp_days)))
   CALL text((soffrow+ 3),soffcol,build2("DC Interaction Days: ",cnvtstring(copy_cat->
      dc_interact_days)))
   CALL text((soffrow+ 4),soffcol,build2("Stop Type: ",trim(uar_get_code_display(copy_cat->
       stop_type_cd))))
   CALL text((soffrow+ 5),soffcol,build2("Stop Duration: ",trim(cnvtstring(copy_cat->stop_duration)),
     " ",trim(uar_get_code_display(copy_cat->stop_duraction_unit_cd))))
   IF (micopyavsettings=1)
    CALL text((soffrow+ 6),soffcol,build2("AV Multum: ",evaluate(copy_cat->ic_av_flag,1,"No",2,
       "No w/Clinical Checking",
       3,"Yes w/Reason",4,"Yes","No setting")))
    CALL text((soffrow+ 7),soffcol,build2("AV Discern: ",evaluate(copy_cat->discern_av_flag,1,"No",2,
       "No w/Clinical Checking",
       3,"Yes w/Reason",4,"Yes","No setting")))
   ENDIF
   CALL text((soffrow+ 0),(soffcol+ 45),"Print/Misc")
   CALL line((soffrow+ 1),(soffcol+ 26),48)
   CALL text((soffrow+ 2),(soffcol+ 25),build2("Print Reqs: ",evaluate(copy_cat->print_req_ind,1,
      "Yes","No")))
   CALL text((soffrow+ 3),(soffcol+ 25),build2("Req Format: ",trim(uar_get_code_display(copy_cat->
       req_format_cd))))
   CALL text((soffrow+ 4),(soffcol+ 25),build2("Req Routing: ",trim(uar_get_code_display(copy_cat->
       req_route_cd))))
   CALL text((soffrow+ 5),(soffcol+ 25),build2("Print Consent: ",evaluate(copy_cat->consent_form_ind,
      1,"Yes","No")))
   CALL text((soffrow+ 6),(soffcol+ 25),build2("Consent Format: ",trim(uar_get_code_display(copy_cat
       ->consent_form_format_cd))))
   CALL text((soffrow+ 7),(soffcol+ 25),build2("Consent Routing: ",trim(uar_get_code_display(copy_cat
       ->consent_form_routing_cd))))
   CALL text((soffrow+ 2),(soffcol+ 51),build2("Complete on order: ",evaluate(copy_cat->
      complete_on_order_ind,1,"Yes","No")))
   CALL text((soffrow+ 3),(soffcol+ 51),build2("Cancel on discharge: ",evaluate(copy_cat->
      cancel_on_discharge_ind,1,"Yes","No")))
   CALL text((soffrow+ 4),(soffcol+ 51),build2("Disable order cmnt: ",evaluate(copy_cat->
      disable_ord_cmnt_ind,1,"Yes","No")))
   CALL text((soffrow+ 5),(soffcol+ 51),build2("Bill only orderable: ",evaluate(copy_cat->
      bill_only_ind,1,"Yes","No")))
   CALL drawscrollbox((soffrow+ 8),(soffcol+ 1),numrows,(numcols+ 1))
   CALL text((soffrow+ 8),(soffcol+ 2),"Action")
   CALL text((soffrow+ 8),(soffcol+ 22),"Nurse Review")
   CALL text((soffrow+ 8),(soffcol+ 43),"Physician Cosign")
   CALL text((soffrow+ 8),(soffcol+ 64),"Rx Verify")
   WHILE (cnt < maxrows
    AND cnt < value(size(copy_cat->cosigs,5)))
     SET cnt = (cnt+ 1)
     SET str = buildactionrowstr(cnt)
     CALL scrolltext(cnt,str)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   SET pick = 0
   WHILE (pick=0)
     CALL text((soffrow+ 16),soffcol,"Continue? (Y)es (N)o:")
     CALL accept((soffrow+ 16),(soffcol+ 22),"A;CUS","Y"
      WHERE curaccept IN ("Y", "N"))
     CASE (curscroll)
      OF 0:
       IF (curaccept="Y")
        CALL clearscreen(null)
       ELSEIF (curaccept="N")
        GO TO main_menu
       ENDIF
       SET pick = 1
      OF 1:
       IF (cnt < value(size(copy_cat->cosigs,5)))
        SET cnt = (cnt+ 1)
        SET str = buildactionrowstr(cnt)
        CALL downarrow(str)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET str = buildactionrowstr(cnt)
        CALL uparrow(str)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE displaycatalogstoupdate(null)
   DECLARE maxrows = i4 WITH noconstant(13), protect
   DECLARE cnt = i4 WITH protect
   DECLARE arow = i4 WITH protect
   DECLARE str = c75 WITH protect
   CALL clearscreen(null)
   CALL drawscrollbox(soffrow,(soffcol+ 1),numrows,(numcols+ 1))
   CALL text(soffrow,(soffcol+ 7),"Primary")
   CALL text(soffrow,(soffcol+ 60),"Total:")
   CALL text(soffrow,(soffcol+ 67),trim(cnvtstring(catalogs->list_sz,4,0)))
   WHILE (cnt < maxrows
    AND (cnt < catalogs->list_sz))
     SET cnt = (cnt+ 1)
     SET str = buildprimaryrowstr(cnt)
     CALL scrolltext(cnt,str)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   SET pick = 0
   WHILE (pick=0)
     CALL text((soffrow+ 16),soffcol,"Update all? (Y)es (N)o:")
     CALL accept((soffrow+ 16),(soffcol+ 24),"A;CUS","Y"
      WHERE curaccept IN ("Y", "N"))
     CASE (curscroll)
      OF 0:
       IF (curaccept="Y")
        IF ((catalogs->list_sz > 0))
         CALL performupdates(null)
        ENDIF
       ELSEIF (curaccept="N")
        SET stat = initrec(catalogs)
        CALL clearscreen(null)
        CALL text(soffrow,soffcol,"Primaries were not updated")
        CALL text((soffrow+ 16),soffcol,"Continue?:")
        CALL accept((soffrow+ 16),(soffcol+ 11),"A;CU","Y"
         WHERE curaccept IN ("Y"))
        GO TO main_menu
       ENDIF
       SET pick = 1
      OF 1:
       IF ((cnt < catalogs->list_sz))
        SET cnt = (cnt+ 1)
        SET str = buildprimaryrowstr(cnt)
        CALL downarrow(str)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET str = buildprimaryrowstr(cnt)
        CALL uparrow(str)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE determineupdates(null)
   DECLARE i = i4
   DECLARE j = i4
   DECLARE k = i4
   DECLARE cnt = i4
   DECLARE pos = i4
   FOR (i = 1 TO value(size(copy_cat->cosigs,5)))
     FOR (j = 1 TO catalogs->list_sz)
      SET pos = locateval(k,1,size(catalogs->list[j].cosigs,5),copy_cat->cosigs[i].action_type_cd,
       catalogs->list[j].cosigs[k].action_type_cd)
      IF (pos > 0)
       IF ((copy_cat->cosigs[i].nurse=catalogs->list[j].cosigs[pos].nurse)
        AND (copy_cat->cosigs[i].pharm=catalogs->list[j].cosigs[pos].pharm)
        AND (copy_cat->cosigs[i].physician=catalogs->list[j].cosigs[pos].physician))
        SET catalogs->list[j].cosigs[pos].action_flag = 0
       ELSE
        SET catalogs->list[j].cosigs[pos].action_flag = 2
        SET catalogs->list[j].cosigs[pos].action_type_cd = copy_cat->cosigs[i].action_type_cd
        SET catalogs->list[j].cosigs[pos].nurse = copy_cat->cosigs[i].nurse
        SET catalogs->list[j].cosigs[pos].pharm = copy_cat->cosigs[i].pharm
        SET catalogs->list[j].cosigs[pos].physician = copy_cat->cosigs[i].physician
       ENDIF
      ELSE
       SET cnt = (size(catalogs->list[j].cosigs,5)+ 1)
       SET stat = alterlist(catalogs->list[j].cosigs,cnt)
       SET catalogs->list[j].cosigs[cnt].action_flag = 1
       SET catalogs->list[j].cosigs[cnt].action_type_cd = copy_cat->cosigs[i].action_type_cd
       SET catalogs->list[j].cosigs[cnt].nurse = copy_cat->cosigs[i].nurse
       SET catalogs->list[j].cosigs[cnt].pharm = copy_cat->cosigs[i].pharm
       SET catalogs->list[j].cosigs[cnt].physician = copy_cat->cosigs[i].physician
      ENDIF
     ENDFOR
   ENDFOR
   FOR (i = 1 TO catalogs->list_sz)
     FOR (j = 1 TO size(catalogs->list[i].cosigs,5))
      SET pos = locateval(k,1,size(copy_cat->cosigs,5),catalogs->list[i].cosigs[j].action_type_cd,
       copy_cat->cosigs[k].action_type_cd)
      IF (pos=0)
       SET catalogs->list[i].cosigs[j].action_flag = 3
      ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE performupdates(null)
   DECLARE i = i4 WITH protect
   DECLARE j = i4 WITH protect
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"Performing updates")
   CALL determineupdates(null)
   SELECT INTO "nl:"
    oc.catalog_cd
    FROM order_catalog oc
    PLAN (oc
     WHERE expand(i,1,catalogs->list_sz,oc.catalog_cd,catalogs->list[i].catalog_cd))
    WITH nocounter, forupdate(oc)
   ;end select
   SELECT INTO "nl:"
    ocr.catalog_cd, ocr.action_type_cd
    FROM (dummyt d1  WITH seq = catalogs->list_sz),
     (dummyt d2  WITH seq = 1),
     order_catalog_review ocr
    PLAN (d1
     WHERE maxrec(d2,size(catalogs->list[d1.seq].cosigs,5)))
     JOIN (d2
     WHERE (catalogs->list[d1.seq].cosigs[d2.seq].action_flag > 0))
     JOIN (ocr
     WHERE (ocr.catalog_cd=catalogs->list[d1.seq].catalog_cd)
      AND (ocr.action_type_cd=catalogs->list[d1.seq].cosigs[d2.seq].action_type_cd))
    WITH nocounter, forupdate(ocr)
   ;end select
   IF (micopyavsettings=1)
    UPDATE  FROM order_catalog oc
     SET oc.dc_display_days = copy_cat->dc_disp_days, oc.dc_interaction_days = copy_cat->
      dc_interact_days, oc.stop_duration = copy_cat->stop_duration,
      oc.stop_duration_unit_cd = copy_cat->stop_duraction_unit_cd, oc.stop_type_cd = copy_cat->
      stop_type_cd, oc.print_req_ind = copy_cat->print_req_ind,
      oc.requisition_format_cd = copy_cat->req_format_cd, oc.requisition_routing_cd = copy_cat->
      req_route_cd, oc.consent_form_format_cd = copy_cat->consent_form_format_cd,
      oc.consent_form_ind = copy_cat->consent_form_ind, oc.consent_form_routing_cd = copy_cat->
      consent_form_routing_cd, oc.complete_upon_order_ind = copy_cat->complete_on_order_ind,
      oc.auto_cancel_ind = copy_cat->cancel_on_discharge_ind, oc.disable_order_comment_ind = copy_cat
      ->disable_ord_cmnt_ind, oc.bill_only_ind = copy_cat->bill_only_ind,
      oc.discern_auto_verify_flag = copy_cat->discern_av_flag, oc.ic_auto_verify_flag = copy_cat->
      ic_av_flag, oc.updt_applctx = 0,
      oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id =
      reqinfo->updt_id,
      oc.updt_task = - (267)
     WHERE expand(i,1,catalogs->list_sz,oc.catalog_cd,catalogs->list[i].catalog_cd)
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM order_catalog oc
     SET oc.dc_display_days = copy_cat->dc_disp_days, oc.dc_interaction_days = copy_cat->
      dc_interact_days, oc.stop_duration = copy_cat->stop_duration,
      oc.stop_duration_unit_cd = copy_cat->stop_duraction_unit_cd, oc.stop_type_cd = copy_cat->
      stop_type_cd, oc.print_req_ind = copy_cat->print_req_ind,
      oc.requisition_format_cd = copy_cat->req_format_cd, oc.requisition_routing_cd = copy_cat->
      req_route_cd, oc.consent_form_format_cd = copy_cat->consent_form_format_cd,
      oc.consent_form_ind = copy_cat->consent_form_ind, oc.consent_form_routing_cd = copy_cat->
      consent_form_routing_cd, oc.complete_upon_order_ind = copy_cat->complete_on_order_ind,
      oc.auto_cancel_ind = copy_cat->cancel_on_discharge_ind, oc.disable_order_comment_ind = copy_cat
      ->disable_ord_cmnt_ind, oc.bill_only_ind = copy_cat->bill_only_ind,
      oc.updt_applctx = 0, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      oc.updt_id = reqinfo->updt_id, oc.updt_task = - (267)
     WHERE expand(i,1,catalogs->list_sz,oc.catalog_cd,catalogs->list[i].catalog_cd)
     WITH nocounter
    ;end update
   ENDIF
   INSERT  FROM (dummyt d1  WITH seq = catalogs->list_sz),
     (dummyt d2  WITH seq = 1),
     order_catalog_review ocr
    SET ocr.action_type_cd = catalogs->list[d1.seq].cosigs[d2.seq].action_type_cd, ocr.catalog_cd =
     catalogs->list[d1.seq].catalog_cd, ocr.doctor_cosign_flag = catalogs->list[d1.seq].cosigs[d2.seq
     ].physician,
     ocr.nurse_review_flag = catalogs->list[d1.seq].cosigs[d2.seq].nurse, ocr.rx_verify_flag =
     catalogs->list[d1.seq].cosigs[d2.seq].pharm, ocr.updt_applctx = 0,
     ocr.updt_cnt = 0, ocr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocr.updt_id = reqinfo->
     updt_id,
     ocr.updt_task = - (267)
    PLAN (d1
     WHERE maxrec(d2,size(catalogs->list[d1.seq].cosigs,5)))
     JOIN (d2
     WHERE (catalogs->list[d1.seq].cosigs[d2.seq].action_flag=1))
     JOIN (ocr)
    WITH nocounter
   ;end insert
   UPDATE  FROM order_catalog_review ocr,
     (dummyt d1  WITH seq = catalogs->list_sz),
     (dummyt d2  WITH seq = 1)
    SET ocr.action_type_cd = catalogs->list[d1.seq].cosigs[d2.seq].action_type_cd, ocr.catalog_cd =
     catalogs->list[d1.seq].catalog_cd, ocr.doctor_cosign_flag = catalogs->list[d1.seq].cosigs[d2.seq
     ].physician,
     ocr.nurse_review_flag = catalogs->list[d1.seq].cosigs[d2.seq].nurse, ocr.rx_verify_flag =
     catalogs->list[d1.seq].cosigs[d2.seq].pharm, ocr.updt_applctx = 0,
     ocr.updt_cnt = (ocr.updt_cnt+ 1), ocr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocr.updt_id
      = reqinfo->updt_id,
     ocr.updt_task = - (267)
    PLAN (d1
     WHERE maxrec(d2,size(catalogs->list[d1.seq].cosigs,5)))
     JOIN (d2
     WHERE (catalogs->list[d1.seq].cosigs[d2.seq].action_flag=2))
     JOIN (ocr
     WHERE (ocr.catalog_cd=catalogs->list[d1.seq].catalog_cd)
      AND (ocr.action_type_cd=catalogs->list[d1.seq].cosigs[d2.seq].action_type_cd))
    WITH nocounter
   ;end update
   DELETE  FROM order_catalog_review ocr,
     (dummyt d1  WITH seq = catalogs->list_sz),
     (dummyt d2  WITH seq = 1)
    SET ocr.seq = 1
    PLAN (d1
     WHERE maxrec(d2,size(catalogs->list[d1.seq].cosigs,5)))
     JOIN (d2
     WHERE (catalogs->list[d1.seq].cosigs[d2.seq].action_flag=3))
     JOIN (ocr
     WHERE (ocr.catalog_cd=catalogs->list[d1.seq].catalog_cd)
      AND (ocr.action_type_cd=catalogs->list[d1.seq].cosigs[d2.seq].action_type_cd))
    WITH nocounter
   ;end delete
   SET stat = incrementprimarycount(catalogs->list_sz)
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"Updates complete")
   CALL text((soffrow+ 16),soffcol,"Commit?:")
   CALL accept((soffrow+ 16),(soffcol+ 9),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    COMMIT
   ELSE
    ROLLBACK
   ENDIF
 END ;Subroutine
 SUBROUTINE drawscrollbox(begrow,begcol,endrow,endcol)
  CALL box(begrow,begcol,endrow,endcol)
  CALL scrollinit((begrow+ 1),(begcol+ 1),(endrow - 1),(endcol - 1))
 END ;Subroutine
 SUBROUTINE downarrow(newrow)
   IF (arow=maxrows)
    CALL scrolldown(maxrows,maxrows,newrow)
   ELSE
    SET arow = (arow+ 1)
    CALL scrolldown((arow - 1),arow,newrow)
   ENDIF
 END ;Subroutine
 SUBROUTINE uparrow(newrow)
   IF (arow=1)
    CALL scrollup(arow,arow,str)
   ELSE
    SET arow = (arow - 1)
    CALL scrollup((arow+ 1),arow,str)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildactionrowstr(i)
   DECLARE rstr = c75 WITH protect
   DECLARE action = c20 WITH protect
   DECLARE physician = c27 WITH protect
   DECLARE nurse = c21 WITH protect
   DECLARE rx = c3 WITH protect
   SET action = substring(1,20,build2(trim(uar_get_code_display(copy_cat->cosigs[i].action_type_cd)))
    )
   SET nurse = build2(evaluate(copy_cat->cosigs[i].nurse,0,"None",1,"Ordering Location",
     2,"Patient Location",3,"Order Detail Provider",4,
     "Order Detail Location"))
   SET physician = build2(evaluate(copy_cat->cosigs[i].physician,0,"None",1,"Ordering Physician",
     2,"Attending Physician",3,"Order Detail Physician"))
   SET rx = build2(evaluate(copy_cat->cosigs[i].pharm,0,"No",1,"Yes"))
   SET rstr = build2(action,nurse,physician,rx)
   RETURN(rstr)
 END ;Subroutine
 SUBROUTINE buildprimaryrowstr(i)
   DECLARE rstr = c75 WITH protect
   SET rstr = build2(cnvtstring(i,4,0,r)," ",substring(1,70,catalogs->list[i].primary))
   RETURN(rstr)
 END ;Subroutine
 SUBROUTINE clearscreen(null)
   DECLARE i = i4 WITH protect
   SET i = soffrow
   WHILE (i <= numrows)
    CALL clear(i,soffcol,numcols)
    SET i = (i+ 1)
   ENDWHILE
   CALL clear((numrows+ 2),soffcol,numcols)
 END ;Subroutine
 SUBROUTINE lookupprsnlid(susername)
   DECLARE iprsnlid = f8 WITH protect
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.username=cnvtupper(trim(susername,3))
     AND ((p.active_ind+ 0)=1)
    DETAIL
     iprsnlid = p.person_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL text((soffrow+ 4),soffcol,"User not found. Please enter valid, active username.")
    GO TO invalid_user
   ENDIF
   RETURN(iprsnlid)
 END ;Subroutine
 SUBROUTINE incrementprimarycount(inccnt)
   DECLARE pref_domain = c11 WITH protect, constant("AMS_TOOLKIT")
   DECLARE retval = i2 WITH noconstant(0), protect
   DECLARE found = i2 WITH noconstant(0), protect
   DECLARE infonbr = i4 WITH protect
   DECLARE lastupdt = dq8 WITH protect
   DECLARE infodetail = vc WITH protect, constant("Total number of primaries that have been updated:"
    )
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=pref_domain
     AND d.info_name=script_name
    DETAIL
     found = 1, infonbr = (d.info_number+ inccnt), lastupdt = d.updt_dt_tm
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = pref_domain, d.info_name = script_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = inccnt, d.info_char = trim(infodetail), d.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WITH nocounter
    ;end insert
    IF (curqual=1)
     SET retval = 1
    ENDIF
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = infonbr, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WHERE d.info_domain=pref_domain
      AND d.info_name=script_name
     WITH nocounter
    ;end update
    IF (curqual=1)
     SET retval = 1
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 IF (errorind=1)
  SET message = nowindow
  CALL echo(errorstr)
 ENDIF
 SET last_mod = "002"
END GO

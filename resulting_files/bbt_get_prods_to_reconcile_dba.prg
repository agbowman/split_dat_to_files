CREATE PROGRAM bbt_get_prods_to_reconcile:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Owner Area CD" = "0",
  "Lookback Days" = "30",
  "EDN Product ID" = "0",
  "Product ID" = "0",
  "Contributor System CD" = "0",
  "Product Type Identifier" = "0",
  "Debug Flag" = 0
  WITH outdev, owner_area_cd, lookback_days,
  edn_product_id, product_id, contrib_sys_cd,
  product_type_ident, debug_flag
 DECLARE buildhead(null) = null
 DECLARE buildbody(null) = null
 DECLARE loaddata(null) = null
 DECLARE loadpage(null) = null
 DECLARE showpage(spage=vc,swhere=vc) = null
 DECLARE updateproduct(null) = null
 DECLARE loadownerareas(null) = null
 DECLARE findproducttypeidentsuggestions(null) = null
 DECLARE findcontributorsystemsuggestions(null) = null
 DECLARE findedndatawithoutproducttypeidents(null) = null
 DECLARE findmanuallyreceiveddatatoreconcile(null) = null
 DECLARE getpathnetseq(null) = f8
 DECLARE generatecsv(null) = null
 DECLARE loadmockdata(null) = null
 DECLARE mockdata(null) = null
 DECLARE mockownerareas(null) = null
 DECLARE debugflag = i2 WITH protect, constant( $DEBUG_FLAG)
 DECLARE selectedownercd = f8 WITH protect, constant(cnvtreal( $OWNER_AREA_CD))
 DECLARE lookbackdays = vc WITH protect, constant( $LOOKBACK_DAYS)
 DECLARE lookbackinterval = vc WITH protect, constant(concat(trim( $LOOKBACK_DAYS),",","D"))
 DECLARE ednproductid = f8 WITH protect, constant(cnvtreal( $EDN_PRODUCT_ID))
 DECLARE productid = f8 WITH protect, constant(cnvtreal( $PRODUCT_ID))
 DECLARE contribsyscd = f8 WITH protect, constant(cnvtreal( $CONTRIB_SYS_CD))
 DECLARE producttypeident = vc WITH protect, constant(notrim(substring(1,40, $PRODUCT_TYPE_IDENT)))
 DECLARE dtcur = dq8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE receivedeventtypecd = f8 WITH protect, constant(uar_get_code_by("MEANING",1610,"13"))
 DECLARE transferedfromeventtypecd = f8 WITH protect, constant(uar_get_code_by("MEANING",1610,"26"))
 DECLARE usemockdataind = i2 WITH noconstant(0)
 DECLARE gencsvind = i2 WITH noconstant(0)
 DECLARE updateproductonlyind = i2 WITH noconstant(0)
 DECLARE spage = vc WITH protect, noconstant("")
 DECLARE sjs = vc WITH protect, noconstant("")
 DECLARE scss = vc WITH protect, noconstant("")
 DECLARE spagehead = vc WITH protect, noconstant("")
 DECLARE spagebody = vc WITH protect, noconstant("")
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 title = vc
   1 missing_data = vc
   1 owner_area = vc
   1 lookback = vc
   1 in_days = vc
   1 reload_page = vc
   1 contrib_sys = vc
   1 no_suggest = vc
   1 save = vc
   1 prod_type_label = vc
   1 see_raw = vc
   1 all = vc
 )
 SET captions->title = uar_i18ngetmessage(i18nhandle,"title","Product Reconciliation")
 SET captions->missing_data = uar_i18ngetmessage(i18nhandle,"missing_data",
  "Looks like we're missing some information for this product.")
 SET captions->owner_area = uar_i18ngetmessage(i18nhandle,"owner_area","Owner Area")
 SET captions->lookback = uar_i18ngetmessage(i18nhandle,"loookback","Lookback")
 SET captions->in_days = uar_i18ngetmessage(i18nhandle,"in_days","(in days)")
 SET captions->reload_page = uar_i18ngetmessage(i18nhandle,"reload_page","Reload Page")
 SET captions->contrib_sys = uar_i18ngetmessage(i18nhandle,"contrib_sys","Contributor System Code:")
 SET captions->no_suggest = uar_i18ngetmessage(i18nhandle,"no_suggest","No Suggestions")
 SET captions->save = uar_i18ngetmessage(i18nhandle,"save","Save")
 SET captions->prod_type_label = uar_i18ngetmessage(i18nhandle,"prod_type_label",
  "Product/Component ID:")
 SET captions->see_raw = uar_i18ngetmessage(i18nhandle,"see_raw","Raw Data")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 RECORD data(
   1 product[*]
     2 fix_type_flag = i2
     2 edn_product_id = f8
     2 product_id = f8
     2 product_nbr = vc
     2 product_cd = f8
     2 cur_owner_area_cd = f8
     2 product_type_disp = vc
     2 contrib_sys_cd = f8
     2 product_type_ident = vc
   1 type_suggest[*]
     2 product_cd = f8
     2 suggestions[*]
       3 product_type_ident = vc
   1 contrib_suggest[*]
     2 owner_area_cd = f8
     2 suggestions[*]
       3 contrib_sys_cd = f8
       3 contrib_sys_disp = vc
 )
 RECORD owner_areas(
   1 owner_area[*]
     2 owner_area_cd = f8
     2 owner_area_disp = vc
 )
 IF (debugflag=2)
  SET gencsvind = 1
 ELSEIF (debugflag=3)
  SET updateproductonlyind = 1
 ELSEIF (debugflag=4)
  SET usemockdataind = 1
 ELSEIF (debugflag=5)
  SET usemockdataind = 1
  SET gencsvind = 1
 ENDIF
 CALL updateproduct(null)
 IF (updateproductonlyind=1)
  GO TO exit_script
 ENDIF
 IF (usemockdataind=1)
  CALL loadmockdata(null)
 ELSE
  CALL loaddata(null)
 ENDIF
 IF (gencsvind=1)
  CALL generatecsv(null)
 ELSE
  CALL loadpage(null)
 ENDIF
 FREE RECORD owner_areas
 FREE RECORD data
 SUBROUTINE loadpage(null)
   CALL buildhead(null)
   CALL buildbody(null)
   SET spage = concat('<!DOCTYPE HTML"><html>',spagehead,spagebody,"</html>")
   IF (debugflag > 0)
    CALL echo("It's supposedly built.........")
    CALL echo(spage)
   ENDIF
   CALL showpage(spage, $OUTDEV)
 END ;Subroutine
 SUBROUTINE generatecsv(null)
  DECLARE sfilename = vc WITH noconstant("")
  IF (size(data->product,5) > 0)
   SET sfilename = concat("cer_print:bbt_interface_recon",format(dtcur,"YYMMDDHHMMSSCC;;d"),".csv")
   SELECT INTO  $OUTDEV
    product_id = data->product[d.seq].product_id, edn_product_id = data->product[d.seq].
    edn_product_id, product_nbr = format(data->product[d.seq].product_nbr,"#########################"
     ),
    product_cd = data->product[d.seq].product_cd, product_type_disp = format(data->product[d.seq].
     product_type_disp,"#########################"), contrib_sys_cd = data->product[d.seq].
    contrib_sys_cd,
    contrib_sys_disp = format(uar_get_code_display(data->product[d.seq].contrib_sys_cd),
     "#########################"), owner_area_cd = data->product[d.seq].cur_owner_area_cd,
    owner_area_disp = format(uar_get_code_display(data->product[d.seq].cur_owner_area_cd),
     "#######################")
    FROM (dummyt d  WITH seq = value(size(data->product,5)))
    WITH nocounter, format, separator = " ",
     heading, formfeed = none
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE loaddata(null)
   CALL loadownerareas(null)
   IF (receivedeventtypecd > 0)
    CALL findmanuallyreceiveddatatoreconcile(null)
    IF (gencsvind=0)
     CALL findcontributorsystemsuggestions(null)
    ENDIF
    CALL findedndatawithoutproducttypeidents(null)
    IF (gencsvind=0)
     CALL findproducttypeidentsuggestions(null)
    ENDIF
   ELSE
    CALL echo("Receive Event Type Code did not load correctly")
   ENDIF
   IF (debugflag > 0)
    CALL echorecord(data)
   ENDIF
 END ;Subroutine
 SUBROUTINE updateproduct(null)
   IF (ednproductid > 0)
    UPDATE  FROM bb_edn_product
     SET product_type_ident = notrim(producttypeident), updt_dt_tm = cnvtdatetime(curdate,curtime3),
      updt_id = reqinfo->updt_id
     WHERE bb_edn_product_id=ednproductid
     WITH nocounter
    ;end update
   ELSEIF (productid > 0)
    CALL writeednrows(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE writeednrows(null)
   RECORD prod(
     1 product_id = f8
     1 edn_admin_id = f8
     1 edn_product_id = f8
     1 product_cd = f8
     1 product_nbr = vc
     1 expiration_dt_tm = dq8
     1 contrib_sys_cd = f8
     1 product_type_ident = vc
     1 product_type_txt = vc
     1 owner_area_cd = f8
     1 inv_area_cd = f8
   )
   SELECT
    p.cur_expiration_dt_tm, p.product_cd, p.product_type_barcode
    FROM product p
    WHERE p.product_id=productid
    DETAIL
     prod->product_id = p.product_id, prod->product_cd = p.product_cd, prod->product_nbr = p
     .product_nbr,
     prod->expiration_dt_tm = p.cur_expire_dt_tm, prod->product_type_txt = p.product_type_barcode,
     prod->product_type_ident = notrim(producttypeident),
     prod->owner_area_cd = p.cur_owner_area_cd, prod->inv_area_cd = p.cur_inv_area_cd
    WITH nocounter
   ;end select
   SET prod->edn_admin_id = getpathnetseq(null)
   SET prod->edn_product_id = getpathnetseq(null)
   IF ((((prod->edn_admin_id <= 0)) OR ((prod->edn_product_id <= 0))) )
    EXECUTE echo "EDN IDs were not generated correctly"
    RETURN(0)
   ENDIF
   INSERT  FROM bb_edn_admin bea
    SET bea.bb_edn_admin_id = prod->edn_admin_id, bea.order_nbr_ident = "RECON-ENTRY", bea
     .dispatch_nbr_txt = "RECON-ENTRY",
     bea.admin_dt_tm = cnvtdatetime(curdate,curtime3), bea.destination_loc_cd = prod->owner_area_cd,
     bea.destination_inv_area_cd = prod->inv_area_cd,
     bea.protocol_nbr = 7, bea.edn_complete_ind = 1, bea.contributor_system_cd = contribsyscd,
     bea.updt_applctx = reqinfo->updt_applctx, bea.updt_dt_tm = cnvtdatetime(curdate,curtime3), bea
     .updt_id = reqinfo->updt_id,
     bea.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   INSERT  FROM bb_edn_product bep
    SET bep.bb_edn_product_id = prod->edn_product_id, bep.bb_edn_admin_id = prod->edn_admin_id, bep
     .product_id = prod->product_id,
     bep.product_cd = prod->product_cd, bep.expiration_dt_tm = cnvtdatetime(prod->expiration_dt_tm),
     bep.product_type_txt = prod->product_type_txt,
     bep.product_type_ident = notrim(prod->product_type_ident), bep.edn_product_nbr_ident = prod->
     product_nbr, bep.product_complete_ind = 1,
     bep.updt_applctx = reqinfo->updt_applctx, bep.updt_dt_tm = cnvtdatetime(curdate,curtime3), bep
     .updt_id = reqinfo->updt_id,
     bep.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   FREE RECORD prod
 END ;Subroutine
 SUBROUTINE findproducttypeidentsuggestions(null)
  DECLARE prod_cnt = i4 WITH protect, noconstant(0)
  SELECT DISTINCT INTO "nl:"
   trim(bep.product_type_ident,1), bep.product_cd
   FROM bb_edn_product bep
   WHERE bep.product_complete_ind=1
    AND bep.product_cd > 0
    AND  NOT (((bep.product_type_ident=null) OR (((bep.product_type_ident="") OR (((bep
   .product_type_ident=" ") OR (bep.product_type_ident="0")) )) )) )
    AND expand(prod_cnt,1,size(data->product,5),bep.product_cd,data->product[prod_cnt].product_cd)
   ORDER BY bep.product_cd
   HEAD REPORT
    ntypecnt = 0
   HEAD bep.product_cd
    nsuggestcnt = 0, ntypecnt = (ntypecnt+ 1)
    IF (mod(ntypecnt,10)=1)
     stat = alterlist(data->type_suggest,(ntypecnt+ 9))
    ENDIF
    data->type_suggest[ntypecnt].product_cd = bep.product_cd
   DETAIL
    nsuggestcnt = (nsuggestcnt+ 1)
    IF (mod(nsuggestcnt,2)=1)
     stat = alterlist(data->type_suggest[ntypecnt].suggestions,(nsuggestcnt+ 1))
    ENDIF
    data->type_suggest[ntypecnt].suggestions[nsuggestcnt].product_type_ident = bep.product_type_ident
   FOOT  bep.product_cd
    stat = alterlist(data->type_suggest[ntypecnt].suggestions,nsuggestcnt)
   FOOT REPORT
    stat = alterlist(data->type_suggest,ntypecnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE findcontributorsystemsuggestions(null)
  DECLARE prod_cnt = i4 WITH protect, noconstant(0)
  SELECT DISTINCT INTO "nl:"
   bea.destination_loc_cd, bea.contributor_system_cd
   FROM bb_edn_admin bea
   WHERE bea.edn_complete_ind=1
    AND bea.destination_loc_cd > 0
    AND bea.contributor_system_cd > 0
    AND expand(prod_cnt,1,size(data->product,5),bea.destination_loc_cd,data->product[prod_cnt].
    cur_owner_area_cd)
   ORDER BY bea.destination_loc_cd
   HEAD REPORT
    nownercnt = 0
   HEAD bea.destination_loc_cd
    nsuggestcnt = 0, nownercnt = (nownercnt+ 1)
    IF (mod(nownercnt,10)=1)
     stat = alterlist(data->contrib_suggest,(nownercnt+ 9))
    ENDIF
    data->contrib_suggest[nownercnt].owner_area_cd = bea.destination_loc_cd
   DETAIL
    nsuggestcnt = (nsuggestcnt+ 1)
    IF (mod(nsuggestcnt,2)=1)
     stat = alterlist(data->contrib_suggest[nownercnt].suggestions,(nsuggestcnt+ 1))
    ENDIF
    data->contrib_suggest[nownercnt].suggestions[nsuggestcnt].contrib_sys_cd = bea
    .contributor_system_cd, data->contrib_suggest[nownercnt].suggestions[nsuggestcnt].
    contrib_sys_disp = uar_get_code_display(bea.contributor_system_cd)
   FOOT  bea.destination_loc_cd
    stat = alterlist(data->contrib_suggest[nownercnt].suggestions,nsuggestcnt)
   FOOT REPORT
    stat = alterlist(data->contrib_suggest,nownercnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE findedndatawithoutproducttypeidents(null)
  DECLARE ownerlocationtypecd = f8 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM product_event pe,
    product p,
    bb_edn_product bep,
    bb_edn_admin bea
   PLAN (pe
    WHERE pe.event_type_cd=receivedeventtypecd
     AND pe.event_dt_tm BETWEEN cnvtlookbehind(lookbackinterval,cnvtdatetime(curdate,curtime3)) AND
    cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.product_id=pe.product_id
     AND ((selectedownercd=0) OR (selectedownercd > 0
     AND p.cur_owner_area_cd=selectedownercd)) )
    JOIN (bep
    WHERE bep.product_id=p.product_id
     AND bep.product_complete_ind=1
     AND ((bep.product_type_ident=null) OR (((bep.product_type_ident="") OR (((bep.product_type_ident
    =" ") OR (bep.product_type_ident="0")) )) )) )
    JOIN (bea
    WHERE bea.bb_edn_admin_id=bep.bb_edn_admin_id)
   ORDER BY p.product_id
   HEAD REPORT
    nprodcnt = size(data->product,5), stat = alterlist(data->product,(nprodcnt+ 9))
   HEAD p.product_id
    nprodcnt = (nprodcnt+ 1)
    IF (mod(nprodcnt,10)=1)
     stat = alterlist(data->product,(nprodcnt+ 9))
    ENDIF
    data->product[nprodcnt].product_cd = p.product_cd, data->product[nprodcnt].product_type_disp =
    uar_get_code_display(p.product_cd), data->product[nprodcnt].product_id = p.product_id,
    data->product[nprodcnt].edn_product_id = bep.bb_edn_product_id, data->product[nprodcnt].
    contrib_sys_cd = bea.contributor_system_cd, data->product[nprodcnt].product_nbr = concat(trim(p
      .product_nbr)," ",trim(p.product_sub_nbr)),
    data->product[nprodcnt].cur_owner_area_cd = p.cur_owner_area_cd
   FOOT REPORT
    stat = alterlist(data->product,nprodcnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE findmanuallyreceiveddatatoreconcile(null)
   SELECT INTO "nl:"
    FROM product_event pe,
     product p
    PLAN (pe
     WHERE pe.event_type_cd IN (receivedeventtypecd, transferedfromeventtypecd)
      AND pe.event_dt_tm BETWEEN cnvtlookbehind(lookbackinterval,cnvtdatetime(curdate,curtime3)) AND
     cnvtdatetime(curdate,curtime3))
     JOIN (p
     WHERE p.product_id=pe.product_id
      AND ((selectedownercd=0) OR (selectedownercd > 0
      AND p.cur_owner_area_cd=selectedownercd))
      AND  NOT (p.product_id IN (
     (SELECT
      bep.product_id
      FROM bb_edn_product bep
      WHERE bep.product_id=p.product_id
       AND bep.product_complete_ind=1))))
    ORDER BY p.product_id
    HEAD REPORT
     nprodcnt = 0
    HEAD p.product_id
     nprodcnt = (nprodcnt+ 1)
     IF (mod(nprodcnt,10)=1)
      stat = alterlist(data->product,(nprodcnt+ 9))
     ENDIF
     data->product[nprodcnt].product_cd = p.product_cd, data->product[nprodcnt].product_type_disp =
     uar_get_code_display(p.product_cd), data->product[nprodcnt].product_id = p.product_id,
     data->product[nprodcnt].product_nbr = concat(trim(p.product_nbr)," ",trim(p.product_sub_nbr)),
     data->product[nprodcnt].cur_owner_area_cd = p.cur_owner_area_cd
    FOOT REPORT
     stat = alterlist(data->product,nprodcnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadownerareas(null)
   DECLARE ownerlocationtypecd = f8 WITH protect, noconstant(0)
   SET stat = uar_get_meaning_by_codeset(222,"BBOWNERROOT",1,ownerlocationtypecd)
   SELECT INTO "nl:"
    FROM location l
    WHERE l.location_type_cd=ownerlocationtypecd
     AND l.active_ind=1
     AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    ORDER BY l.location_cd
    HEAD REPORT
     nownercnt = 1, stat = alterlist(owner_areas->owner_area,10), owner_areas->owner_area[nownercnt].
     owner_area_cd = 0,
     owner_areas->owner_area[nownercnt].owner_area_disp = captions->all
    HEAD l.location_cd
     nownercnt = (nownercnt+ 1)
     IF (mod(nownercnt,10)=1)
      stat = alterlist(owner_areas->owner_area,(nownercnt+ 9))
     ENDIF
     owner_areas->owner_area[nownercnt].owner_area_cd = l.location_cd, owner_areas->owner_area[
     nownercnt].owner_area_disp = uar_get_code_display(l.location_cd)
    FOOT REPORT
     stat = alterlist(owner_areas->owner_area,nownercnt)
    WITH nocounter
   ;end select
   IF (debugflag > 0)
    CALL echorecord(owner_areas)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadmockdata(null)
   CALL mockownerareas(null)
   CALL mockdata(null)
   CALL echorecord(data)
 END ;Subroutine
 SUBROUTINE mockownerareas(null)
   SET i0 = 0
   SET i0 = (i0+ 1)
   SET stat = alterlist(owner_areas->owner_area,i0)
   SET owner_areas->owner_area[i0].owner_area_cd = 0
   SET owner_areas->owner_area[i0].owner_area_disp = "(All)"
   SET i0 = (i0+ 1)
   SET stat = alterlist(owner_areas->owner_area,i0)
   SET owner_areas->owner_area[i0].owner_area_cd = 34
   SET owner_areas->owner_area[i0].owner_area_disp = "L BBANK"
   SET i0 = (i0+ 1)
   SET stat = alterlist(owner_areas->owner_area,i0)
   SET owner_areas->owner_area[i0].owner_area_cd = 33.0
   SET owner_areas->owner_area[i0].owner_area_disp = "Yet Another Owner Area"
   SET i0 = (i0+ 1)
   SET stat = alterlist(owner_areas->owner_area,i0)
   SET owner_areas->owner_area[i0].owner_area_cd = 234
   SET owner_areas->owner_area[i0].owner_area_disp = "Blood Owner Area"
 END ;Subroutine
 SUBROUTINE mockdata(null)
   SET i0 = 0
   SET i0 = (i0+ 1)
   SET stat = alterlist(data->product,i0)
   SET data->product[i0].fix_type_flag = 0
   SET data->product[i0].edn_product_id = 0
   SET data->product[i0].product_id = 1
   SET data->product[i0].product_nbr = "AG17021401 A0"
   SET data->product[i0].cur_owner_area_cd = 61
   SET data->product[i0].product_cd = 2
   SET data->product[i0].product_type_disp = "RBC - AS1 IRR La La"
   SET data->product[i0].contrib_sys_cd = 0
   SET data->product[i0].product_type_ident = ""
   SET i1 = 0
   SET i1 = (i1+ 1)
   SET stat = alterlist(data->type_suggest,i1)
   SET data->type_suggest[i1].product_cd = data->product[i0].product_cd
   SET i3 = 0
   SET i3 = (i3+ 1)
   SET stat = alterlist(data->type_suggest[i1].suggestions,i3)
   SET data->type_suggest[i1].suggestions[i3].product_type_ident = "28"
   SET i2 = 0
   SET i2 = (i2+ 1)
   SET stat = alterlist(data->contrib_suggest,i2)
   SET data->contrib_suggest[i2].owner_area_cd = data->product[i0].cur_owner_area_cd
   SET i4 = 0
   SET i4 = (i4+ 1)
   SET stat = alterlist(data->contrib_suggest[i2].suggestions,i4)
   SET data->contrib_suggest[i2].suggestions[i4].contrib_sys_cd = 3
   SET data->contrib_suggest[i2].suggestions[i4].contrib_sys_disp = "BLOODNET"
   SET i0 = (i0+ 1)
   SET stat = alterlist(data->product,i0)
   SET data->product[i0].fix_type_flag = 0
   SET data->product[i0].edn_product_id = 0
   SET data->product[i0].product_id = 1
   SET data->product[i0].product_nbr = "AG17021406"
   SET data->product[i0].product_cd = 3
   SET data->product[i0].product_type_disp = "RBC - AS1 IRR"
   SET data->product[i0].cur_owner_area_cd = 62
   SET data->product[i0].contrib_sys_cd = 0
   SET data->product[i0].product_type_ident = ""
   SET i1 = (i1+ 1)
   SET stat = alterlist(data->type_suggest,i1)
   SET data->type_suggest[i1].product_cd = data->product[i0].product_cd
   SET i3 = 0
   SET i3 = (i3+ 1)
   SET stat = alterlist(data->type_suggest[i1].suggestions,i3)
   SET data->type_suggest[i1].suggestions[i3].product_type_ident = "28"
   SET i3 = (i3+ 1)
   SET stat = alterlist(data->type_suggest[i1].suggestions,i3)
   SET data->type_suggest[i1].suggestions[i3].product_type_ident = "84"
   SET i2 = (i2+ 1)
   SET stat = alterlist(data->contrib_suggest,i2)
   SET data->contrib_suggest[i2].owner_area_cd = data->product[i0].cur_owner_area_cd
   SET i4 = 0
   SET i4 = (i4+ 1)
   SET stat = alterlist(data->contrib_suggest[i2].suggestions,i4)
   SET data->contrib_suggest[i2].suggestions[i4].contrib_sys_cd = 3
   SET data->contrib_suggest[i2].suggestions[i4].contrib_sys_disp = "BLOODNET"
   SET i4 = (i4+ 1)
   SET stat = alterlist(data->contrib_suggest[i2].suggestions,i4)
   SET data->contrib_suggest[i2].suggestions[i4].contrib_sys_cd = 4
   SET data->contrib_suggest[i2].suggestions[i4].contrib_sys_disp = "BBT"
   SET i0 = (i0+ 1)
   SET stat = alterlist(data->product,i0)
   SET data->product[i0].fix_type_flag = 0
   SET data->product[i0].edn_product_id = 0
   SET data->product[i0].product_id = 1
   SET data->product[i0].product_nbr = "AG17021402"
   SET data->product[i0].product_cd = 7
   SET data->product[i0].product_type_disp = "RBC - AS1"
   SET data->product[i0].contrib_sys_cd = 0
   SET data->product[i0].product_type_ident = ""
   SET i0 = (i0+ 1)
   SET stat = alterlist(data->product,i0)
   SET data->product[i0].fix_type_flag = 1
   SET data->product[i0].edn_product_id = 5
   SET data->product[i0].product_id = 8693795
   SET data->product[i0].product_nbr = "AG17021403"
   SET data->product[i0].product_cd = 3407323127.0000
   SET data->product[i0].product_type_disp = "RBC - AS1"
   SET data->product[i0].contrib_sys_cd = 1234
   SET data->product[i0].product_type_ident = ""
   SET i0 = (i0+ 1)
   SET stat = alterlist(data->product,i0)
   SET data->product[i0].fix_type_flag = 1
   SET data->product[i0].edn_product_id = 3456
   SET data->product[i0].product_id = 1
   SET data->product[i0].product_nbr = "AG170214042819182828"
   SET data->product[i0].product_cd = 4
   SET data->product[i0].product_type_disp = "RBC - AS1 IRR La La Yay"
   SET data->product[i0].contrib_sys_cd = 1234
   SET data->product[i0].product_type_ident = ""
   SET i1 = (i1+ 1)
   SET stat = alterlist(data->type_suggest,i1)
   SET data->type_suggest[i1].product_cd = data->product[i0].product_cd
   SET i3 = 0
   SET i3 = (i3+ 1)
   SET stat = alterlist(data->type_suggest[i1].suggestions,i3)
   SET data->type_suggest[i1].suggestions[i3].product_type_ident = "28"
   SET i3 = (i3+ 1)
   SET stat = alterlist(data->type_suggest[i1].suggestions,i3)
   SET data->type_suggest[i1].suggestions[i3].product_type_ident = "71"
   SET i0 = (i0+ 1)
   SET stat = alterlist(data->product,i0)
   SET data->product[i0].fix_type_flag = 1
   SET data->product[i0].edn_product_id = 3456
   SET data->product[i0].product_id = 1
   SET data->product[i0].product_nbr = "AG17021405"
   SET data->product[i0].product_cd = 5
   SET data->product[i0].product_type_disp = "PLT Conc"
   SET data->product[i0].contrib_sys_cd = 1234
   SET data->product[i0].product_type_ident = ""
   SET i1 = (i1+ 1)
   SET stat = alterlist(data->type_suggest,i1)
   SET data->type_suggest[i1].product_cd = data->product[i0].product_cd
   SET i3 = 0
   SET i3 = (i3+ 1)
   SET stat = alterlist(data->type_suggest[i1].suggestions,i3)
   SET data->type_suggest[i1].suggestions[i3].product_type_ident = "71"
 END ;Subroutine
 SUBROUTINE buildhead(null)
   SET sjs = concat("<script>",
    'function go(form){var ownerCd=document.getElementById("owner-areas").value;',
    'var lookbackDays=document.getElementsByName("lookback-days")[0].value;',"if(form==0)",
    "{loadPage(ownerCd,lookbackDays,0,0,0,0,0);return;}if(form==2){loadPage(ownerCd,lookbackDays,0,0,0,0,2);return;}",
    "var ednProdId=parseInt(form.edn_prod_id.value);var prodId=parseInt(form.prod_id.value);",
    "var bn_prod_type=parseInt(form.bn_type.value);var contrib_sys_cd=parseInt(form.contrib_sys.value);",
    "if(prodId>0&&bn_prod_type>0&&contrib_sys_cd>0){",
    "loadPage(ownerCd,lookbackDays,ednProdId,prodId,contrib_sys_cd,bn_prod_type,0);}else{",'alert("',
    captions->missing_data,'");}}',
    "function loadPage(ownerCd,lbDays,ednProdId,productId,contribSysCd,prodTypeIdent,dF){",
    ^var params="'MINE','"+ownerCd+"','"+lbDays+"','"+ednProdId+"','"+productId+"','"+contribSysCd+"','"+prodTypeIdent+"',"+dF^,
    ';var scriptName="bbt_get_prods_to_reconcile";CCLLINK(scriptName,params,1);}',
    "function popType(form,val){form.bn_type.value=val;}",
    "function popContrib(form,val){form.contrib_sys.value=val;}","</script>")
   SET scss = concat("<style>.product-div{height:80px;border:1px #000 solid;padding:10px;}",
    "ul.suggest{margin:0;padding:0;list-style-type:none;}","ul.suggest li{display:inline;}",
    'ul.suggest input[type="button"]{background:none;!important',
    "font:inherit;cursor:pointer;border:0;color:blue;text-align:left;}.prodnum{font-weight:bold;}",
    ".col{display:inline;float:left;width:23%;}.col0{width:23%;}",
    ".col1,.col2{width:33%;}.col3{width:5%;padding-top:25px;}",
    "div.select{padding: 15px;}.config-lb, .config-r, .config-d{margin-left:30px;}select{ padding:10px;}</style>"
    )
   SET spagehead = concat("<head><META content='CCLLINK'name='discern'><title>",captions->title,
    "</title>",sjs,scss,
    "</head>")
 END ;Subroutine
 SUBROUTINE buildbody(null)
   DECLARE sproduct = vc WITH protect, noconstant("")
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE start = i4 WITH protect, noconstant(1)
   SET spagebody = concat("<body><h1>",captions->title,"</h1><hr />")
   SET spagebody = concat(spagebody,'<div class="select"><span class="config config-owner">',captions
    ->owner_area,' <select id="owner-areas">')
   FOR (nowneridx = 1 TO size(owner_areas->owner_area,5))
     SET spagebody = concat(spagebody,'<option value="',cnvtstring(owner_areas->owner_area[nowneridx]
       .owner_area_cd),'"')
     IF ((selectedownercd=owner_areas->owner_area[nowneridx].owner_area_cd))
      SET spagebody = concat(spagebody," selected")
     ENDIF
     SET spagebody = concat(spagebody,">",owner_areas->owner_area[nowneridx].owner_area_disp,
      "</option>")
   ENDFOR
   SET spagebody = concat(spagebody,"</select></span>",'<span class="config config-lb">',captions->
    lookback,"<i>",
    captions->in_days,'</i>  <input type="text" name="lookback-days" ','value="',lookbackdays,
    '"></span><span class="config-r">',
    '<input type="button" value="',captions->reload_page,'" onClick="javascript:go(0)"></span>',
    '<span class="config-d">','<input type="button" value="',
    captions->see_raw,'" onClick="javascript:go(2)"></span></div><hr />')
   FOR (nprodidx = 1 TO size(data->product,5))
     SET sproduct = concat("<div class='product-div'><form action=''>",
      "<div class='prod-info col col0'><div class='prodnum play-span'>",data->product[nprodidx].
      product_nbr,'</div><br><span class="type">',data->product[nprodidx].product_type_disp,
      "</span>",'</div><div class="contrib-sys col col1"><span>',captions->contrib_sys,
      '<ul class="suggest">')
     SET pos = 0
     SET num = 0
     IF ((data->product[nprodidx].fix_type_flag=0)
      AND (data->product[nprodidx].contrib_sys_cd=0))
      SET pos = locateval(num,start,size(data->contrib_suggest,5),data->product[nprodidx].
       cur_owner_area_cd,data->contrib_suggest[num].owner_area_cd)
     ENDIF
     IF (pos > 0
      AND size(data->contrib_suggest[pos].suggestions,5) > 0)
      CALL echo("trace 1")
      FOR (ncontribidx = 1 TO size(data->contrib_suggest[pos].suggestions,5))
        SET sproduct = concat(sproduct,"<li>",'<input type="button" value="',data->contrib_suggest[
         pos].suggestions[ncontribidx].contrib_sys_disp,'" onClick="javascript:popContrib(this.form,',
         cnvtstring(data->contrib_suggest[pos].suggestions[ncontribidx].contrib_sys_cd),')"></li>')
      ENDFOR
     ELSE
      CALL echo("trace 2")
      SET sproduct = concat(sproduct,"<li><i>",captions->no_suggest,"</i></li>")
     ENDIF
     CALL echo("trace 3")
     SET sproduct = concat(sproduct,'</ul><input type="text" name="contrib_sys" value="',cnvtstring(
       data->product[nprodidx].contrib_sys_cd),'"')
     IF ((data->product[nprodidx].contrib_sys_cd > 0))
      SET sproduct = concat(sproduct," disabled")
     ENDIF
     SET sproduct = concat(sproduct,"></span></div>")
     SET sproduct = concat(sproduct,'<div class="bn-prod-type col col2"><span>',captions->
      prod_type_label,'<ul class="suggest">')
     SET pos = 0
     SET num = 0
     SET pos = locateval(num,start,size(data->type_suggest,5),data->product[nprodidx].product_cd,data
      ->type_suggest[num].product_cd)
     IF (pos > 0
      AND size(data->type_suggest[pos].suggestions,5) > 0)
      FOR (ntypeidx = 1 TO size(data->type_suggest[pos].suggestions,5))
        SET sproduct = concat(sproduct,"<li>",'<input type="button" value="',data->type_suggest[pos].
         suggestions[ntypeidx].product_type_ident,'" onClick="javascript:popType(this.form,',
         data->type_suggest[pos].suggestions[ntypeidx].product_type_ident,')"></li>')
      ENDFOR
     ELSE
      CALL echo("trace 4")
      SET sproduct = concat(sproduct,"<li><i>",captions->no_suggest,"</i></li>")
     ENDIF
     CALL echo("trace 5")
     SET sproduct = concat(sproduct,'</ul><input type="text"name="bn_type"value="0">',
      '<input type="hidden" name="prod_id" value="',cnvtstring(data->product[nprodidx].product_id),
      '"><input type="hidden" name="prod_cd" value="',
      cnvtstring(data->product[nprodidx].product_cd),
      '"><input type="hidden" name="edn_prod_id" value="',cnvtstring(data->product[nprodidx].
       edn_product_id),
      '"></span></div><div class="save col col3"><input type="button"onClick="javascript:go(this.form)"value="',
      captions->save,
      '">',"</div></form></div>")
     CALL echo("trace 6")
     SET spagebody = concat(spagebody,sproduct)
   ENDFOR
   SET spagebody = concat(spagebody,"</body>")
   CALL echo(spagebody)
 END ;Subroutine
 SUBROUTINE showpage(spage,swhere)
   RECORD putrequest(
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line[*]
       2 linedata = vc
     1 overflowpage[*]
       2 ofr_qual[*]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
   )
   SET putrequest->source_dir = swhere
   SET putrequest->isblob = "1"
   SET putrequest->document = spage
   SET putrequest->document_size = size(putrequest->document)
   EXECUTE eks_put_source  WITH replace(request,putrequest)
   FREE RECORD putrequest
 END ;Subroutine
 SUBROUTINE getpathnetseq(null)
   SET new_id = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_id = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO exit_script
   ELSE
    RETURN(new_id)
   ENDIF
 END ;Subroutine
#exit_script
 CALL echo("Exiting Script")
END GO

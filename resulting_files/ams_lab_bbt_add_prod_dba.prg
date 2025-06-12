CREATE PROGRAM ams_lab_bbt_add_prod:dba
 PROMPT
  "Save your Inputs in any CSV file which is saved in any of the below directories then click EXECUTE"
   = "MINE",
  "Directory" = "",
  "Pass Input File Name Here" = ""
  WITH outdev, directory, inputfile
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE i = i4 WITH public
 DECLARE j = i4 WITH public
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 DECLARE category = vc
 DECLARE bgroup = c10
 DECLARE bgrps[50] = c50
 DECLARE wwobg[50] = c50
 DECLARE rscnt = i4
 RECORD orig_content(
   1 rec_cnt = i4
   1 rec[*]
     2 product_name = vc
     2 products[*]
       3 bgrp1 = c50
       3 aborh_ind = vc
       3 crossmatch = vc
       3 autologus = vc
       3 groups[*]
         4 grpcnt = i4
         4 warn[*]
           5 warn_group = vc
         4 wowarn[*]
           5 wowarn_group = vc
 )
 SELECT INTO "nl:"
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   j = 0, bgcount = 0, wwwoc = 0
  HEAD r.line
   line1 = r.line
   IF (count=0)
    j = ((textlen(trim(line1)) - textlen(trim(replace(line1,",",""),3))) - 2)
    FOR (gcn = 1 TO j)
      bgrps[gcn] = piece(line1,",",(gcn+ 3),"not found")
    ENDFOR
   ENDIF
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (i < 1)
     IF (count > 1
      AND i < 1)
      category = piece(line1,",",2,"Not Found")
      IF (trim(category) > "")
       row_count = (row_count+ 1), stat = alterlist(orig_content->rec,row_count)
      ENDIF
      IF (trim(category) > "")
       orig_content->rec[row_count].product_name = piece(line1,",",2,"Not Found"), rscnt = (rscnt+ 1),
       cnt = 0
       FOR (cnt = 1 TO j)
        stat = alterlist(orig_content->rec[row_count].products,cnt),orig_content->rec[row_count].
        products[cnt].bgrp1 = bgrps[cnt]
       ENDFOR
      ENDIF
      IF (trim(category)="")
       i = (i+ 1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->rec,row_count), orig_content->rec_cnt = row_count
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   j = 0, bgcount = 0, wwwoc = 0
  HEAD r.line
   line1 = r.line
   IF (count=0)
    j = ((textlen(trim(line1)) - textlen(trim(replace(line1,",",""),3))) - 2)
    FOR (gcn = 1 TO j)
      bgrps[gcn] = piece(line1,",",(gcn+ 3),"not found")
    ENDFOR
   ENDIF
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (i < 1)
     IF (count > 1
      AND i < 1)
      category = piece(line1,",",2,"Not Found")
      IF (trim(category) > "")
       row_count = (row_count+ 1)
      ENDIF
      stat = alterlist(orig_content->rec,row_count)
      IF (trim(category) > "")
       orig_content->rec[row_count].product_name = piece(line1,",",2,"Not Found"), str = cnvtupper(
        trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(orig_content->rec[row_count].product_name," ","",0),
                                       ",","",0),"~","",0),"`","",0),"!","",0),"@","",0),"#","",0),
                                 "$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",
                           0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),
                   "\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),
           "/","",0),"?","",0),8)), orig_content->rec[row_count].product_name = str,
       rscnt = (rscnt+ 1), cnt = 0
       FOR (cnt = 1 TO j)
         stat = alterlist(orig_content->rec[row_count].products,cnt), orig_content->rec[row_count].
         products[cnt].bgrp1 = bgrps[cnt], str = cnvtupper(trim(replace(replace(replace(replace(
               replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                         replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                  replace(replace(replace(replace(replace(replace(replace(replace(
                                          orig_content->rec[row_count].products[cnt].bgrp1," ","",0),
                                         ",","",0),"~","",0),"`","",0),"!","",0),"@","",0),"#","",0),
                                   "$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(","",0),")",
                             "",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",
                      0),"\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",
              0),"/","",0),"?","",0),8)),
         orig_content->rec[row_count].products[cnt].bgrp1 = str
       ENDFOR
      ENDIF
      IF (trim(category)="")
       i = (i+ 1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->rec,row_count)
  WITH nocounter
 ;end select
 FOR (reccnt = 1 TO size(orig_content->rec,5))
   FOR (prdcnt = 1 TO size(orig_content->rec[reccnt].products,5))
     SELECT
      r.line
      FROM rtl2t r
      HEAD REPORT
       cc = 0
      HEAD r.line
       line1 = r.line
       IF (size(trim(line1),1) > 0)
        varaborh = piece(line1,",",3,"notfound")
        IF (trim(varaborh)=
        "Can this product be crossmatched or dispensed for patients with no group or type recorded?")
         CALL echo(line1)
         IF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="A")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",4,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ANEG")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",5,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="APOS")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",6,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ARHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",7,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBBNEGATIVE")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",8,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBBPOSITIVE")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",9,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBNEGATIVE")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",10,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBPOSITIVE")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",11,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="AB")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",12,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ABNEG")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",13,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ABPOS")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",14,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ABRHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",15,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="B")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",16,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="BNEG")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",17,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="BPOS")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",18,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="BRHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",19,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="NA")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",20,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="O")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",21,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ONEG")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",22,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="OPOS")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",23,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ORHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",24,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="POOLEDABOPOOLEDRH")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",25,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="POOLEDABORHNEGATIVE")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",26,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="POOLEDABORHPOSITIVE")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",27,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="UND")
          orig_content->rec[reccnt].products[prdcnt].crossmatch = piece(line1,",",28,"not found")
         ENDIF
        ENDIF
        varauto = piece(line1,",",3,"notfound")
        IF (trim(varauto)=
"Can autologous or directed products be associated to patients with no group or type recorded at the time the unit is recei\
ved in the blood bank?\
")
         CALL echo(line1)
         IF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="A")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",4,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ANEG")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",5,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="APOS")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",6,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ARHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",7,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBBNEGATIVE")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",8,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBBPOSITIVE")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",9,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBNEGATIVE")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",10,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBPOSITIVE")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",11,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="AB")
          orig_content->rec[reccnt].products[prdcnt].autologus = trim(piece(line1,",",12,"not found")
           )
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ABNEG")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",13,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ABPOS")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",14,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ABRHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",15,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="B")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",16,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="BNEG")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",17,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="BPOS")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",18,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="BRHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",19,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="NA")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",20,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="O")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",21,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ONEG")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",22,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="OPOS")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",23,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ORHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",24,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="POOLEDABOPOOLEDRH")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",25,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="POOLEDABORHNEGATIVE")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",26,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="POOLEDABORHPOSITIVE")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",27,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="UND")
          orig_content->rec[reccnt].products[prdcnt].autologus = piece(line1,",",28,"not found")
         ENDIF
        ENDIF
        aborhind = piece(line1,",",3,"notfound")
        IF (trim(aborhind)="Validate compatibility against the patient's ABO/Rh or Rh")
         IF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="A")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",4,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ANEG")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",5,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="APOS")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",6,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ARHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",7,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBBNEGATIVE")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",8,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBBPOSITIVE")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",9,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBNEGATIVE")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",10,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ASUBPOSITIVE")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",11,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="AB")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",12,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ABNEG")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",13,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ABPOS")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",14,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ABRHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",15,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="B")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",16,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="BNEG")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",17,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="BPOS")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",18,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="BRHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",19,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="NA")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",20,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="O")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",21,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ONEG")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",22,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="OPOS")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",23,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="ORHPOOLED")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",24,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="POOLEDABOPOOLEDRH")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",25,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="POOLEDABORHNEGATIVE")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",26,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="POOLEDABORHPOSITIVE")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",27,"not found")
         ELSEIF (trim(orig_content->rec[reccnt].products[prdcnt].bgrp1)="UND")
          orig_content->rec[reccnt].products[prdcnt].aborh_ind = piece(line1,",",28,"not found")
         ENDIF
        ENDIF
       ENDIF
     ;end select
   ENDFOR
 ENDFOR
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   count = 0, yc = 0, ywc = 0,
   gcnt = 0, linenum = 0
  HEAD r.line
   line1 = r.line
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1
     AND count < 27)
     linenum = (linenum+ 1), var1 = piece(line1,",",4,"not found"), var2 = piece(line1,",",5,
      "not found"),
     var3 = piece(line1,",",6,"not found"), var4 = piece(line1,",",7,"not found"), var5 = piece(line1,
      ",",8,"not found"),
     var6 = piece(line1,",",9,"not found"), var7 = piece(line1,",",10,"not found"), var8 = piece(
      line1,",",11,"not found"),
     var9 = piece(line1,",",12,"not found"), var10 = piece(line1,",",13,"not found"), var11 = piece(
      line1,",",14,"not found"),
     var12 = piece(line1,",",15,"not found"), var13 = piece(line1,",",16,"not found"), var14 = piece(
      line1,",",17,"not found"),
     var15 = piece(line1,",",18,"not found"), var16 = piece(line1,",",19,"not found"), var17 = piece(
      line1,",",20,"not found"),
     var18 = piece(line1,",",21,"not found"), var19 = piece(line1,",",22,"not found"), var20 = piece(
      line1,",",23,"not found"),
     var21 = piece(line1,",",24,"not found"), var22 = piece(line1,",",25,"not found"), var23 = piece(
      line1,",",26,"not found"),
     var24 = piece(line1,",",27,"not found"), var25 = piece(line1,",",28,"not found")
     IF (((var1="Y") OR (var1="Y (warn)")) )
      IF (var1="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "A"
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "A"
       ENDFOR
      ENDIF
     ENDIF
     IF (((var2="Y") OR (var2="Y (warn)")) )
      IF (var2="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "A NEG", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "A NEG", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var3="Y") OR (var3="Y (warn)")) )
      IF (var3="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "A POS", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "A POS", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var4="Y") OR (var4="Y (warn)")) )
      IF (var4="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "A Rh Pooled",
         str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
                   (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "A Rh Pooled", str
          = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var5="Y") OR (var5="Y (warn)")) )
      IF (var5="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group =
         "A Sub B Negative", str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(
                 replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                           replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                    replace(replace(replace(replace(replace(replace(orig_content->
                                          rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group,
                                          " ","",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),
                                    "#","",0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(",
                              "",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}",
                       "",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),
               ">","",0),".","",0),"/","",0),"?","",0),8)), orig_content->rec[i].products[linenum].
         groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "A Sub B Negative",
         str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
                   (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var6="Y") OR (var6="Y (warn)")) )
      IF (var6="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group =
         "A Sub B Positive", str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(
                 replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                           replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                    replace(replace(replace(replace(replace(replace(orig_content->
                                          rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group,
                                          " ","",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),
                                    "#","",0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(",
                              "",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}",
                       "",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),
               ">","",0),".","",0),"/","",0),"?","",0),8)), orig_content->rec[i].products[linenum].
         groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "A Sub B Positive",
         str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
                   (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var7="Y") OR (var7="Y (warn)")) )
      IF (var7="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "A Sub Negative",
         str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
                   (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "A Sub Negative",
         str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
                   (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var8="Y") OR (var8="Y (warn)")) )
      IF (var8="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "A Sub Positive",
         str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
                   (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "A Sub Positive",
         str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
                   (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var9="Y") OR (var9="Y (warn)")) )
      IF (var9="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "AB", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "AB", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var10="Y") OR (var10="Y (warn)")) )
      IF (var10="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "AB NEG", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "AB NEG", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var11="Y") OR (var11="Y (warn)")) )
      IF (var11="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "AB POS", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "AB POS", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var12="Y") OR (var12="Y (warn)")) )
      IF (var12="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "AB Rh Pooled",
         str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
                   (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "AB Rh Pooled", str
          = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var13="Y") OR (var13="Y (warn)")) )
      IF (var13="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "B", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "B", str = cnvtupper
         (trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                     replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                               replace(replace(replace(replace(replace(replace(replace(replace(
                                       replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var14="Y") OR (var14="Y (warn)")) )
      IF (var14="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "B NEG", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "B NEG", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var15="Y") OR (var15="Y (warn)")) )
      IF (var15="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "B POS", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "B POS", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var16="Y") OR (var16="Y (warn)")) )
      IF (var16="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "B Rh Pooled",
         str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
                   (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "B Rh Pooled", str
          = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var17="Y") OR (var17="Y (warn)")) )
      IF (var17="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "NA", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "NA", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var18="Y") OR (var18="Y (warn)")) )
      IF (var18="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "O", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "O", str = cnvtupper
         (trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                     replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                               replace(replace(replace(replace(replace(replace(replace(replace(
                                       replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var19="Y") OR (var19="Y (warn)")) )
      IF (var19="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "O NEG", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "O NEG", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var20="Y") OR (var20="Y (warn)")) )
      IF (var20="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "O POS", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "O POS", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var21="Y") OR (var21="Y (warn)")) )
      IF (var21="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "O Rh Pooled",
         str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
                   (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "O Rh Pooled", str
          = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var22="Y") OR (var22="Y (warn)")) )
      IF (var22="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group =
         "Pooled ABO Pooled Rh", str = cnvtupper(trim(replace(replace(replace(replace(replace(replace
                (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                           replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                    replace(replace(replace(replace(replace(replace(orig_content->
                                          rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group,
                                          " ","",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),
                                    "#","",0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(",
                              "",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}",
                       "",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),
               ">","",0),".","",0),"/","",0),"?","",0),8)), orig_content->rec[i].products[linenum].
         groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group =
         "Pooled ABO Pooled Rh", str = cnvtupper(trim(replace(replace(replace(replace(replace(replace
                (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                           replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                    replace(replace(replace(replace(replace(replace(orig_content->
                                          rec[i].products[linenum].groups[1].warn[ywc].warn_group," ",
                                          "",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),"#",
                                    "",0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(","",0
                              ),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",0),
                      "|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),
              ".","",0),"/","",0),"?","",0),8)), orig_content->rec[i].products[linenum].groups[1].
         warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var23="Y") OR (var23="Y (warn)")) )
      IF (var23="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group =
         "Pooled ABO Rh Negative", str = cnvtupper(trim(replace(replace(replace(replace(replace(
                replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(replace(replace(replace(replace(replace(
                                          orig_content->rec[i].products[linenum].groups[1].wowarn[yc]
                                          .wowarn_group," ","",0),",","",0),"~","",0),"`","",0),"!",
                                      "",0),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),"&","",
                                0),"*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",
                         0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'",
                 "",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),8)), orig_content->rec[i].
         products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group =
         "Pooled ABO Rh Negative", str = cnvtupper(trim(replace(replace(replace(replace(replace(
                replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(replace(replace(replace(replace(replace(
                                          orig_content->rec[i].products[linenum].groups[1].warn[ywc].
                                          warn_group," ","",0),",","",0),"~","",0),"`","",0),"!","",0
                                      ),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),"&","",0),
                               "*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),
                        "{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",
                 0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),8)), orig_content->rec[i].
         products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var24="Y") OR (var24="Y (warn)")) )
      IF (var24="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group =
         "Pooled ABO Rh Positive", str = cnvtupper(trim(replace(replace(replace(replace(replace(
                replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(replace(replace(replace(replace(replace(
                                          orig_content->rec[i].products[linenum].groups[1].wowarn[yc]
                                          .wowarn_group," ","",0),",","",0),"~","",0),"`","",0),"!",
                                      "",0),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),"&","",
                                0),"*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",
                         0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'",
                 "",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),8)), orig_content->rec[i].
         products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group =
         "Pooled ABO Rh Positive", str = cnvtupper(trim(replace(replace(replace(replace(replace(
                replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(replace(replace(replace(replace(replace(
                                          orig_content->rec[i].products[linenum].groups[1].warn[ywc].
                                          warn_group," ","",0),",","",0),"~","",0),"`","",0),"!","",0
                                      ),"@","",0),"#","",0),"$","",0),"%","",0),"^","",0),"&","",0),
                               "*","",0),"(","",0),")","",0),"-","",0),"_","",0),"+","",0),"=","",0),
                        "{","",0),"}","",0),"|","",0),"\","",0),":","",0),";","",0),'"',"",0),"'","",
                 0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),8)), orig_content->rec[i].
         products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     IF (((var25="Y") OR (var25="Y (warn)")) )
      IF (var25="Y")
       yc = (yc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].wowarn,yc),
         orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = "UND", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].wowarn[yc].wowarn_group," ","",0),",","",0),"~",
                                        "",0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%",
                                  "",0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),
                           "_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":",
                    "",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?",
            "",0),8)), orig_content->rec[i].products[linenum].groups[1].wowarn[yc].wowarn_group = str
       ENDFOR
      ELSE
       ywc = (ywc+ 1)
       FOR (i = 1 TO orig_content->rec_cnt)
         stat = alterlist(orig_content->rec[i].products[linenum].groups,1), orig_content->rec[i].
         products[linenum].groups[1].grpcnt = 10, stat = alterlist(orig_content->rec[i].products[
          linenum].groups[1].warn,ywc),
         orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = "UND", str =
         cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                    replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                              replace(replace(replace(replace(replace(replace(replace(replace(replace
                                      (replace(replace(replace(orig_content->rec[i].products[linenum]
                                          .groups[1].warn[ywc].warn_group," ","",0),",","",0),"~","",
                                        0),"`","",0),"!","",0),"@","",0),"#","",0),"$","",0),"%","",
                                  0),"^","",0),"&","",0),"*","",0),"(","",0),")","",0),"-","",0),"_",
                           "",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),"\","",0),":","",0
                    ),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/","",0),"?","",0),
           8)), orig_content->rec[i].products[linenum].groups[1].warn[ywc].warn_group = str
       ENDFOR
      ENDIF
     ENDIF
     yc = 0, ywc = 0
    ENDIF
   ENDIF
  FOOT REPORT
   row + 1
  WITH nocounter
 ;end select
 SET var1 = 0
 FOR (var1 = 1 TO size(orig_content->rec,5))
   FREE RECORD request
   RECORD request(
     1 bbd_prod_qual_cnt = i4
     1 product_cd = f8
     1 product_aborh_cd = f8
     1 no_gt_on_prsn_flag = i4
     1 no_ad_on_prsn_flag = i4
     1 disp_no_curraborh_prsn_flag = i4
     1 bbd_no_gt_dir_prsn_flag = i4
     1 prod_active_ind = i4
     1 prod_sequence_nbr = f8
     1 product_status = i4
     1 aborh_indicator = i2
     1 person_aborh_cnt = i4
     1 person_aborh_data[*]
       2 person_aborh_cd = f8
       2 prsn_sequence_nbr = f8
       2 warn_indicator = i2
   )
   SET request->bbd_prod_qual_cnt = size(orig_content->rec,5)
   SELECT
    cv.code_value, cv.display, cv.display_key,
    cv.code_set
    FROM code_value cv
    PLAN (cv
     WHERE (cv.display_key=orig_content->rec[var1].product_name)
      AND cv.code_set=1604
      AND cv.active_ind=1)
    HEAD cv.code_value
     request->product_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request->prod_active_ind = 1
   SET request->no_gt_on_prsn_flag = 0
   SET request->no_ad_on_prsn_flag = 0
   SET request->bbd_no_gt_dir_prsn_flag = 0
   SET request->disp_no_curraborh_prsn_flag = 0
   SET request->prod_sequence_nbr = 1
   SET request->product_status = 1
   SET var2 = 0
   FOR (var2 = 1 TO size(orig_content->rec[var1].products,5))
     SELECT
      cv.code_value, cv.display, cv.display_key,
      cv.code_set
      FROM code_value cv
      PLAN (cv
       WHERE (cv.display_key=orig_content->rec[var1].products[var2].bgrp1)
        AND cv.code_set=1640)
      HEAD cv.code_value
       request->product_aborh_cd = cv.code_value
      WITH nocounter
     ;end select
     IF ((orig_content->rec[var1].products[var2].aborh_ind="ABO/Rh"))
      SET request->aborh_indicator = 1
     ELSE
      SET request->aborh_indicator = 0
     ENDIF
     IF (trim(orig_content->rec[var1].products[var2].crossmatch)="Yes with warning")
      SET request->no_gt_on_prsn_flag = 2
     ELSEIF (trim(orig_content->rec[var1].products[var2].crossmatch)="Yes")
      CALL echo("first value Yes")
      SET request->no_gt_on_prsn_flag = 1
      CALL echo(request->no_gt_on_prsn_flag)
     ELSE
      CALL echo("first value No")
      SET request->no_gt_on_prsn_flag = 0
      CALL echo(request->no_gt_on_prsn_flag)
     ENDIF
     IF (trim(orig_content->rec[var1].products[var2].autologus)="Yes with warning")
      SET request->no_ad_on_prsn_flag = 2
      CALL echo(request->no_gt_on_prsn_flag)
     ELSEIF (trim(orig_content->rec[var1].products[var2].autologus)="Yes")
      CALL echo("second value Yes")
      SET request->no_ad_on_prsn_flag = 1
      CALL echo(request->no_gt_on_prsn_flag)
     ELSE
      SET request->no_ad_on_prsn_flag = 0
     ENDIF
     SET var3 = 0
     FOR (var3 = 1 TO size(orig_content->rec[var1].products[var2].groups,5))
       SET request->person_aborh_cnt = (size(orig_content->rec[var1].products[var2].groups[var3].warn,
        5)+ size(orig_content->rec[var1].products[var2].groups[var3].wowarn,5))
       SET i = 0
       SET j = 0
       IF (size(orig_content->rec[var1].products[var2].groups[var3].warn,5) > 0)
        SET grp_cnt = size(orig_content->rec[var1].products[var2].groups[var3].warn,5)
        FOR (i = 1 TO grp_cnt)
          SET stat = alterlist(request->person_aborh_data,i)
          SET request->person_aborh_data[i].warn_indicator = 1
          SET request->person_aborh_data[i].prsn_sequence_nbr = 1
          SELECT
           cv.code_value, cv.display, cv.display_key,
           cv.code_set
           FROM code_value cv
           PLAN (cv
            WHERE (cv.display_key=orig_content->rec[var1].products[var2].groups[var3].warn[i].
            warn_group)
             AND cv.code_set=1640)
           HEAD cv.code_value
            request->person_aborh_data[i].person_aborh_cd = cv.code_value
           WITH nocounter
          ;end select
        ENDFOR
       ENDIF
       IF (size(orig_content->rec[var1].products[var2].groups[var3].wowarn,5) > 0)
        SET grp_cnt = (size(orig_content->rec[var1].products[var2].groups[var3].warn,5)+ size(
         orig_content->rec[var1].products[var2].groups[var3].wowarn,5))
        SET k = 0
        FOR (j = i TO grp_cnt)
          SET k = (k+ 1)
          SET stat = alterlist(request->person_aborh_data,j)
          SET request->person_aborh_data[j].warn_indicator = 0
          SET request->person_aborh_data[j].prsn_sequence_nbr = 1
          SELECT
           cv.code_value, cv.display, cv.display_key,
           cv.code_set
           FROM code_value cv
           PLAN (cv
            WHERE (cv.display_key=orig_content->rec[var1].products[var2].groups[var3].wowarn[k].
            wowarn_group)
             AND cv.code_set=1640)
           HEAD cv.code_value
            request->person_aborh_data[j].person_aborh_cd = cv.code_value
           WITH nocounter
          ;end select
        ENDFOR
       ENDIF
       FREE RECORD reply
       RECORD reply(
         1 person_aborh_data_qual = i4
         1 person_aborh_data[1]
           2 person_aborh_cd = f8
         1 status_data
           2 status = c1
           2 subeventstatus[2]
             3 operationname = c25
             3 operationstatus = c1
             3 targetobjectname = c25
             3 targetobjectvalue = vc
       )
       EXECUTE bbt_add_product_patient_comp:dba  WITH replace("REQUEST",request), replace("REPLY",
        reply)
     ENDFOR
   ENDFOR
 ENDFOR
 SELECT INTO  $OUTDEV
  status =
  IF ((reply->status_data[d1.seq].status="S"))
   "Successfully Associated Products with the Blood Groups into the tool"
  ELSE "Failed"
  ENDIF
  FROM (dummyt d1  WITH seq = size(reply->status_data,5))
  WITH nocounter, format
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO

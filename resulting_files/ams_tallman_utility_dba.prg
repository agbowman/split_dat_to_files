CREATE PROGRAM ams_tallman_utility:dba
 PAINT
 DECLARE clearscreen(null) = null WITH protect
 DECLARE errorind = i2 WITH protect
 DECLARE errorstr = vc WITH protect
 DECLARE numrows = i4 WITH constant(20), protect
 DECLARE numcols = i4 WITH constant(75), protect
 DECLARE soffrow = i4 WITH constant(6), protect
 DECLARE soffcol = i4 WITH constant(3), protect
 DECLARE last_mod = vc WITH protect
 EXECUTE cclseclogin
 IF ((xxcclseclogin->loggedin != 1))
  SET errorind = 1
  SET errorstr = "You must be logged in securely. Please run the program again."
  GO TO exit_script
 ENDIF
#main_menu
 CALL clear(1,1)
 CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
 CALL video(r)
 CALL text((soffrow - 4),soffcol,
  "                            AMS Tallman Utility                            ")
 CALL video(n)
 CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
 IF (validate(ignore_mismatch,0)=1)
  IF (ignore_mismatch=1)
   CALL video(b)
   CALL text((soffrow - 2),soffcol,
    "                    WARNING: MISMATCHES WILL BE IGNORED                    ")
   CALL video(n)
  ENDIF
 ENDIF
 CALL text((soffrow+ 4),(soffcol+ 27),"1 Multum Update")
 CALL text((soffrow+ 5),(soffcol+ 27),"2 Batch Synonyms")
 CALL text((soffrow+ 6),(soffcol+ 27),"3 Batch Pharmacy Products")
 CALL text((soffrow+ 7),(soffcol+ 27),"4 Exit")
 CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
 CALL text((soffrow+ 16),soffcol,"Choose mode:")
 CALL accept((soffrow+ 16),(soffcol+ 13),"9;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CASE (curaccept)
  OF 1:
   EXECUTE FROM multum TO end_multum
  OF 2:
   EXECUTE FROM cpoe TO end_cpoe
  OF 3:
   EXECUTE FROM products TO end_products
  OF 4:
   GO TO exit_script
 ENDCASE
#multum
 FREE RECORD request
 RECORD request(
   1 prsnl_id = f8
   1 check_all_ind = i2
   1 begin_dt_tm = dq8
   1 combo_ind = i2
   1 ignore_mismatch_ind = i2
   1 regex_chars = vc
   1 tman_filename = vc
   1 debug_ind = i2
 )
 CALL clearscreen(null)
 CALL video(r)
 CALL text((soffrow - 3),soffcol,
  " Update Synonyms, Tasks, Event Sets and Event Codes Created By Multum Load ")
 CALL video(n)
#mltm_input
 CALL text(soffrow,soffcol,"Enter filename to READ tallmans from:")
 CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);CU","CER_INSTALL:TALLMAN.CSV")
 IF (curaccept="*.CSV")
  IF (findfile(curaccept))
   SET request->tman_filename = trim(curaccept)
  ELSE
   CALL clear((soffrow+ 2),soffcol,numcols)
   CALL text((soffrow+ 2),soffcol,
    "Input file not found. Include logical if file is not in CCLUSERDIR")
   GO TO mltm_input
  ENDIF
 ELSE
  CALL clear((soffrow+ 2),soffcol,numcols)
  CALL text((soffrow+ 2),soffcol,"Input file must have .csv extension")
  GO TO mltm_input
 ENDIF
 CALL clear((soffrow+ 2),soffcol,numcols)
 CALL text((soffrow+ 2),soffcol,"Enter username who performed the Multum load (or ALL):")
 CALL accept((soffrow+ 2),(soffcol+ 55),"P(20);CU","ALL")
 IF (curaccept="ALL")
  SET request->prsnl_id = 0
  SET request->check_all_ind = 1
 ELSE
  SET request->check_all_ind = 0
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE cnvtupper(p.username)=cnvtupper(trim(curaccept,3))
    AND ((p.active_ind+ 0)=1)
   DETAIL
    request->prsnl_id = p.person_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL text((soffrow+ 3),soffcol,"User not found. Please enter valid, active username.")
   GO TO mltm_input
  ENDIF
 ENDIF
 CALL clear((soffrow+ 3),soffcol,numcols)
 CALL text((soffrow+ 3),soffcol,"Enter date of Bedrock Multum load steps:")
 CALL accept((soffrow+ 3),(soffcol+ 41),"NNDNNDNNNN;C",format(curdate,"MM/DD/YYYY;;D")
  WHERE format(cnvtdate(cnvtalphanum(curaccept)),"MM/DD/YYYY;;D")=curaccept)
 SET request->begin_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum(curaccept)),0000)
 CALL text((soffrow+ 4),soffcol,"Should combination drugs be included? (Y)es (N)o:")
 CALL accept((soffrow+ 4),(soffcol+ 50),"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET request->combo_ind = 1
 ELSE
  SET request->combo_ind = 0
 ENDIF
 IF (validate(regex_chars,0)=1)
  SET request->regex_chars = regex_chars
 ELSE
  SET request->regex_chars = "[-/]"
 ENDIF
 IF (validate(debug,0)=1)
  SET request->debug_ind = 1
 ELSE
  SET request->debug_ind = 0
 ENDIF
 CALL text((soffrow+ 16),soffcol,"Correct? (Y)es (N)o (M)ain Menu:")
 CALL accept((soffrow+ 16),(soffcol+ 33),"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "M"))
 IF (curaccept="Y")
  CALL clearscreen(null)
  EXECUTE ams_tallman_multum
 ELSEIF (curaccept="N")
  GO TO multum
 ELSEIF (curaccept="M")
  GO TO main_menu
 ENDIF
 GO TO main_menu
#end_multum
#cpoe
 FREE RECORD request
 RECORD request(
   1 mode = i2
   1 tman_filename = vc
   1 filename = vc
   1 combo_ind = i2
   1 commit_ind = i2
   1 ignore_mismatch_ind = i2
   1 regex_chars = vc
   1 debug_ind = i2
 )
 CALL clearscreen(null)
 CALL video(r)
 CALL text((soffrow - 3),soffcol,
  "          Batch Update Synonyms, Tasks, Event Sets and Event Codes         ")
 CALL video(n)
#syns_mode
 CALL text(soffrow,soffcol,"Which mode?: (1)Export  (2)Update:")
 CALL accept(soffrow,(soffcol+ 35),"9;"
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   SET request->mode = 1
   CALL text((soffrow+ 1),soffcol,"Enter filename to READ tallmans from:")
   CALL accept((soffrow+ 2),(soffcol+ 1),"P(74);CU","CER_INSTALL:TALLMAN.CSV")
   IF (curaccept="*.CSV")
    IF (findfile(curaccept))
     SET request->tman_filename = trim(curaccept)
    ELSE
     CALL clear((soffrow+ 3),soffcol,numcols)
     CALL text((soffrow+ 3),soffcol,
      "Input file not found. Include logical if file is not in CCLUSERDIR")
     GO TO syns_mode
    ENDIF
   ELSE
    CALL clear((soffrow+ 3),soffcol,numcols)
    CALL text((soffrow+ 3),soffcol,"Input file must have .csv extension")
    GO TO syns_mode
   ENDIF
   CALL clear((soffrow+ 3),soffcol,numcols)
   CALL text((soffrow+ 3),soffcol,"Enter filename to CREATE in CCLUSERDIR:")
   CALL accept((soffrow+ 3),(soffcol+ 40),"P(20);CU")
   IF (((curaccept="*.CSV*") OR (curaccept="MINE")) )
    SET request->filename = curaccept
   ELSE
    CALL clear((soffrow+ 1),soffcol,numcols)
    CALL clear((soffrow+ 2),soffcol,numcols)
    CALL clear((soffrow+ 3),soffcol,numcols)
    CALL text((soffrow+ 4),soffcol,"Output file must be MINE or have .csv extension")
    GO TO syns_mode
   ENDIF
   CALL clear((soffrow+ 4),soffcol,numcols)
   CALL text((soffrow+ 4),soffcol,"Should combination drugs be included? (Y/N):")
   CALL accept((soffrow+ 4),(soffcol+ 45),"A;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    SET request->combo_ind = 1
   ELSE
    SET request->combo_ind = 0
   ENDIF
   IF (validate(regex_chars,0)=1)
    SET request->regex_chars = regex_chars
   ELSE
    SET request->regex_chars = "[-/]"
   ENDIF
  OF 2:
   SET request->mode = 2
   CALL text((soffrow+ 1),soffcol,"Enter filename in CCLUSERDIR to READ from:")
   CALL accept((soffrow+ 1),(soffcol+ 43),"P(20);CU")
   IF (curaccept="*.CSV*")
    SET request->filename = concat("ccluserdir:",curaccept)
   ELSE
    CALL clear((soffrow+ 1),soffcol,numcols)
    CALL text((soffrow+ 2),soffcol,"Input file must have .csv extension")
    GO TO syns_mode
   ENDIF
   CALL text((soffrow+ 2),soffcol,"Should changes be committed to the database? (Y/N):")
   CALL accept((soffrow+ 2),(soffcol+ 52),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    SET request->commit_ind = 1
   ELSE
    SET request->commit_ind = 0
   ENDIF
   IF (validate(ignore_mismatch,0)=1)
    IF (ignore_mismatch=1)
     SET request->ignore_mismatch_ind = 1
    ENDIF
   ELSE
    SET request->ignore_mismatch_ind = 0
   ENDIF
 ENDCASE
 IF (validate(debug,0)=1)
  SET request->debug_ind = 1
 ELSE
  SET request->debug_ind = 0
 ENDIF
 CALL text((soffrow+ 16),soffcol,"Correct? (Y)es (N)o (M)ain Menu:")
 CALL accept((soffrow+ 16),(soffcol+ 33),"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "M"))
 IF (curaccept="Y")
  CALL clear(1,1)
  SET message = nowindow
  EXECUTE ams_batch_tallman_syns
 ELSEIF (curaccept="N")
  GO TO cpoe
 ELSEIF (curaccept="M")
  GO TO main_menu
 ENDIF
 GO TO exit_script
#end_cpoe
#products
 FREE RECORD request
 RECORD request(
   1 mode = i2
   1 tman_filename = vc
   1 filename = vc
   1 combo_ind = i2
   1 commit_ind = i2
   1 ignore_mismatch_ind = i2
   1 regex_chars = vc
   1 debug_ind = i2
 )
 CALL clearscreen(null)
 CALL video(r)
 CALL text((soffrow - 3),soffcol,
  "                      Batch Update Pharmacy Products                       ")
 CALL video(n)
#product_mode
 CALL text(soffrow,soffcol,"Which mode?: (1)Export  (2)Update:")
 CALL accept(soffrow,38,"9;"
  WHERE curaccept IN (1, 2))
 CASE (curaccept)
  OF 1:
   SET request->mode = 1
   CALL text((soffrow+ 1),soffcol,"Enter filename to READ tallmans from:")
   CALL accept((soffrow+ 2),(soffcol+ 1),"P(74);CU","CER_INSTALL:TALLMAN.CSV")
   IF (curaccept="*.CSV")
    IF (findfile(curaccept))
     SET request->tman_filename = trim(curaccept)
    ELSE
     CALL clear((soffrow+ 3),soffcol,numcols)
     CALL text((soffrow+ 3),soffcol,
      "Input file not found. Include logical if file is not in CCLUSERDIR")
     GO TO product_mode
    ENDIF
   ELSE
    CALL clear((soffrow+ 2),soffcol,numcols)
    CALL text((soffrow+ 3),soffcol,"Input file must have .csv extension")
    GO TO product_mode
   ENDIF
   CALL clear((soffrow+ 3),soffcol,numcols)
   CALL text((soffrow+ 3),soffcol,"Enter filename to CREATE in CCLUSERDIR:")
   CALL accept((soffrow+ 3),(soffcol+ 40),"P(20);CU")
   IF (((curaccept="*.CSV*") OR (curaccept="MINE")) )
    SET request->filename = curaccept
   ELSE
    CALL clear((soffrow+ 1),soffcol,numcols)
    CALL clear((soffrow+ 2),soffcol,numcols)
    CALL clear((soffrow+ 3),soffcol,numcols)
    CALL text((soffrow+ 4),soffcol,"Output file must be MINE or have .csv extension")
    GO TO product_mode
   ENDIF
   CALL clear((soffrow+ 4),soffcol,numcols)
   CALL text((soffrow+ 4),soffcol,"Should combination drugs be included? (Y/N):")
   CALL accept((soffrow+ 4),(soffcol+ 45),"A;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    SET request->combo_ind = 1
   ELSE
    SET request->combo_ind = 0
   ENDIF
   IF (validate(regex_chars,0)=1)
    SET request->regex_chars = regex_chars
   ELSE
    SET request->regex_chars = "[-/]"
   ENDIF
  OF 2:
   SET request->mode = 2
   CALL text((soffrow+ 1),soffcol,"Enter filename in CCLUSERDIR to READ from:")
   CALL accept((soffrow+ 1),(soffcol+ 43),"P(20);CU")
   IF (curaccept="*.CSV")
    SET request->filename = concat("ccluserdir:",curaccept)
   ELSE
    CALL clear((soffrow+ 1),soffcol,numcols)
    CALL text((soffrow+ 2),soffcol,"Input file must have .csv extension")
    GO TO product_mode
   ENDIF
   CALL text((soffrow+ 2),soffcol,"Should changes be committed to the database? (Y/N):")
   CALL accept((soffrow+ 2),(soffcol+ 52),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    SET request->commit_ind = 1
   ELSE
    SET request->commit_ind = 0
   ENDIF
   IF (validate(ignore_mismatch,0)=1)
    IF (ignore_mismatch=1)
     SET request->ignore_mismatch_ind = 1
    ENDIF
   ELSE
    SET request->ignore_mismatch_ind = 0
   ENDIF
 ENDCASE
 IF (validate(debug,0)=1)
  SET request->debug_ind = 1
 ELSE
  SET request->debug_ind = 0
 ENDIF
 CALL text((soffrow+ 16),soffcol,"Correct? (Y)es (N)o (M)ain Menu:")
 CALL accept((soffrow+ 16),(soffcol+ 33),"A;CU","Y"
  WHERE curaccept IN ("Y", "N", "M"))
 IF (curaccept="Y")
  CALL clear(1,1)
  SET message = nowindow
  EXECUTE ams_batch_tallman_products
 ELSEIF (curaccept="N")
  GO TO products
 ELSEIF (curaccept="M")
  GO TO main_menu
 ENDIF
 GO TO exit_script
#end_products
 SUBROUTINE clearscreen(null)
   DECLARE i = i4 WITH protect
   SET i = soffrow
   WHILE (i <= numrows)
    CALL clear(i,soffcol,numcols)
    SET i = (i+ 1)
   ENDWHILE
   CALL clear((numrows+ 2),soffcol,numcols)
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 IF (errorind=1)
  SET message = nowindow
  CALL echo(errorstr)
 ENDIF
 SET last_mod = "001"
END GO

CREATE PROGRAM bbt_get_next_sub_nbr:dba
 RECORD reply(
   1 highest_sub_nbr = c5
   1 status_data
     2 status = c1
 )
 DECLARE highest_sub_nbr = c5
 DECLARE highest_alpha_sub_nbr = c5 WITH protect
 DECLARE highest_numeric_sub_nbr = c5 WITH protect
 DECLARE highest_alpha_sub_lvl = c5 WITH protect
 DECLARE highest_numeric_sub_lvl = c5 WITH protect
 DECLARE sub_id_level1 = vc WITH protect
 DECLARE sub_id_level2 = vc WITH protect
 DECLARE level1_size = i2 WITH protect, noconstant(0)
 SET highest_sub_nbr = ""
 SET product_nbr = cnvtupper(request->product_nbr)
 IF ((request->isbt_ind=1))
  SELECT INTO "nl:"
   p.product_id
   FROM product p
   PLAN (p
    WHERE p.product_nbr=product_nbr
     AND ((p.cur_supplier_id+ 0)=request->cur_supplier_id)
     AND (p.product_cd=request->product_cd)
     AND (((request->division_level=1)
     AND substring(2,1,p.product_sub_nbr)="0") OR ((request->division_level=2)
     AND substring(1,1,p.product_sub_nbr)=substring(1,1,request->division_unit))) )
   ORDER BY p.product_sub_nbr
   DETAIL
    IF (trim(p.product_sub_nbr) != "00")
     IF (trim(p.product_sub_nbr) > highest_sub_nbr)
      highest_sub_nbr = trim(p.product_sub_nbr)
     ENDIF
    ENDIF
   WITH counter
  ;end select
  GO TO build_reply
 ENDIF
 IF (validate(request->product_sub_nbr,"^") != "^"
  AND (request->division_level BETWEEN 1 AND 2))
  SET sub_id_level1 = getsubidlevel1(request->product_sub_nbr)
  SET sub_id_level2 = getsubidlevel2(request->product_sub_nbr)
  IF (build(sub_id_level1,sub_id_level2) != build(request->product_sub_nbr))
   GO TO process_user_defined
  ENDIF
  SET level1_size = size(sub_id_level1,1)
  SELECT INTO "nl:"
   FROM product p
   PLAN (p
    WHERE p.product_nbr=product_nbr
     AND ((p.cur_supplier_id+ 0)=request->cur_supplier_id)
     AND (p.product_cd=request->product_cd)
     AND (((request->division_level=1)) OR ((request->division_level=2)
     AND substring(1,level1_size,p.product_sub_nbr)=substring(1,level1_size,request->product_sub_nbr)
    )) )
   ORDER BY p.product_sub_nbr
   HEAD REPORT
    ascii = 0, ptr = 0, parse_size = 0,
    subid_size = 0, numeric_found_ind = 0
   DETAIL
    IF ((request->division_level=1))
     sub_id_level1 = " ", numeric_found_ind = 0, ascii = ichar(substring(1,1,p.product_sub_nbr))
     IF (ascii >= 48
      AND ascii <= 57)
      parse_size = 1
      FOR (ptr = 2 TO size(p.product_sub_nbr,1))
       ascii = ichar(substring(ptr,1,p.product_sub_nbr)),
       IF (ascii >= 48
        AND ascii <= 57)
        parse_size = (parse_size+ 1)
       ELSE
        ptr = size(p.product_sub_nbr,1)
       ENDIF
      ENDFOR
      sub_id_level1 = substring(1,parse_size,p.product_sub_nbr), numeric_found_ind = 1
     ELSEIF ((request->default_sub_id_flag=1)
      AND ascii >= 65
      AND ascii <= 90)
      sub_id_level1 = substring(1,1,p.product_sub_nbr)
     ELSEIF ((request->default_sub_id_flag=2)
      AND ascii >= 97
      AND ascii <= 122)
      sub_id_level1 = substring(1,1,p.product_sub_nbr)
     ELSE
      sub_id_level1 = " "
     ENDIF
     IF (sub_id_level1 > " ")
      IF (numeric_found_ind=1)
       IF (cnvtint(sub_id_level1) > cnvtint(highest_numeric_sub_lvl))
        highest_numeric_sub_lvl = sub_id_level1, highest_numeric_sub_nbr = trim(p.product_sub_nbr)
       ENDIF
      ELSE
       IF (trim(sub_id_level1) > trim(highest_alpha_sub_lvl))
        highest_alpha_sub_lvl = sub_id_level1, highest_alpha_sub_nbr = trim(p.product_sub_nbr)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((request->division_level=2))
     sub_id_level2 = " ", numeric_found_ind = 0, subid_size = 0
     FOR (ptr = 1 TO size(p.product_sub_nbr,1))
       IF (substring(ptr,1,p.product_sub_nbr) > " ")
        subid_size = (subid_size+ 1)
       ENDIF
     ENDFOR
     IF (subid_size > 1)
      ascii = ichar(substring(subid_size,1,p.product_sub_nbr))
     ELSE
      ascii = 32
     ENDIF
     IF (ascii >= 48
      AND ascii <= 57)
      parse_size = 1, ptr = (subid_size - 1)
      WHILE (ptr > 0)
        ascii = ichar(substring(ptr,1,p.product_sub_nbr))
        IF (ascii >= 48
         AND ascii <= 57)
         parse_size = (parse_size+ 1)
        ELSE
         ptr = 0
        ENDIF
        ptr = (ptr - 1)
      ENDWHILE
      IF (parse_size=subid_size)
       sub_id_level2 = " "
      ELSE
       ptr = ((subid_size - parse_size)+ 1), sub_id_level2 = substring(ptr,parse_size,p
        .product_sub_nbr), numeric_found_ind = 1
      ENDIF
     ELSEIF ((request->default_sub_id_flag=1)
      AND ascii >= 65
      AND ascii <= 90)
      sub_id_level2 = substring(subid_size,1,p.product_sub_nbr)
     ELSEIF ((request->default_sub_id_flag=2)
      AND ascii >= 97
      AND ascii <= 122)
      sub_id_level2 = substring(subid_size,1,p.product_sub_nbr)
     ELSE
      sub_id_level2 = " "
     ENDIF
     IF (build(sub_id_level1,sub_id_level2) != build(p.product_sub_nbr))
      sub_id_level2 = " "
     ENDIF
     IF (sub_id_level2 > " ")
      IF (numeric_found_ind=1)
       IF (cnvtint(sub_id_level2) > cnvtint(highest_numeric_sub_lvl))
        highest_numeric_sub_lvl = sub_id_level2, highest_numeric_sub_nbr = trim(p.product_sub_nbr)
       ENDIF
      ELSE
       IF (trim(sub_id_level2) > trim(highest_alpha_sub_lvl))
        highest_alpha_sub_lvl = sub_id_level2, highest_alpha_sub_nbr = trim(p.product_sub_nbr)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    IF ((request->default_sub_id_flag=1))
     ascii = ichar(substring(1,1,highest_alpha_sub_nbr))
     IF (ascii=90)
      IF (trim(highest_numeric_sub_nbr) > " ")
       highest_sub_nbr = highest_numeric_sub_nbr
      ELSE
       highest_sub_nbr = highest_alpha_sub_nbr
      ENDIF
     ELSE
      highest_sub_nbr = highest_alpha_sub_nbr
     ENDIF
    ENDIF
    IF ((request->default_sub_id_flag=2))
     ascii = ichar(substring(1,1,highest_alpha_sub_nbr))
     IF (ascii=122)
      IF (trim(highest_numeric_sub_nbr) > " ")
       highest_sub_nbr = highest_numeric_sub_nbr
      ELSE
       highest_sub_nbr = highest_alpha_sub_nbr
      ENDIF
     ELSE
      highest_sub_nbr = highest_alpha_sub_nbr
     ENDIF
    ENDIF
    IF ((request->default_sub_id_flag=3))
     highest_sub_nbr = highest_numeric_sub_nbr
    ENDIF
   WITH counter
  ;end select
  GO TO build_reply
 ENDIF
#process_user_defined
 SELECT INTO "nl:"
  p.product_id
  FROM product p
  PLAN (p
   WHERE p.product_nbr=product_nbr
    AND ((p.cur_supplier_id+ 0)=request->cur_supplier_id)
    AND (p.product_cd=request->product_cd))
  ORDER BY p.product_sub_nbr
  DETAIL
   IF (trim(p.product_sub_nbr) > highest_sub_nbr)
    highest_sub_nbr = trim(p.product_sub_nbr)
   ENDIF
  WITH counter
 ;end select
#build_reply
 IF (curqual=0)
  SET reply->highest_sub_nbr = ""
 ELSE
  SET reply->highest_sub_nbr = highest_sub_nbr
 ENDIF
 SET reply->status_data.status = "S"
 GO TO exit_script
 DECLARE getsubidlevel1(subidnbr=vc) = vc
 SUBROUTINE getsubidlevel1(subidnbr)
   DECLARE ascii = i2 WITH protect, noconstant(0)
   DECLARE ptr = i2 WITH protect, noconstant(0)
   DECLARE parse_size = i2 WITH protect, noconstant(0)
   IF (((subidnbr=" ") OR (subidnbr="")) )
    RETURN(" ")
   ENDIF
   SET ascii = ichar(substring(1,1,subidnbr))
   IF (ascii >= 48
    AND ascii <= 57)
    SET parse_size = 1
    FOR (ptr = 2 TO size(subidnbr,1))
     SET ascii = ichar(substring(ptr,1,subidnbr))
     IF (ascii >= 48
      AND ascii <= 57)
      SET parse_size = (parse_size+ 1)
     ELSE
      SET ptr = size(subidnbr,1)
     ENDIF
    ENDFOR
    RETURN(substring(1,parse_size,subidnbr))
   ENDIF
   IF (((ascii >= 65
    AND ascii <= 90) OR (ascii >= 97
    AND ascii <= 122)) )
    RETURN(substring(1,1,subidnbr))
   ENDIF
 END ;Subroutine
 DECLARE getsubidlevel2(subidnbr=vc) = vc
 SUBROUTINE getsubidlevel2(subidnbr)
   DECLARE ascii = i2 WITH protect, noconstant(0)
   DECLARE ptr = i2 WITH protect, noconstant(0)
   DECLARE subid_size = i2 WITH protect, noconstant(0)
   DECLARE parse_size = i2 WITH protect, noconstant(0)
   SET subid_size = size(subidnbr,1)
   IF (subid_size < 2)
    RETURN(" ")
   ENDIF
   SET ascii = ichar(substring(subid_size,1,subidnbr))
   IF (ascii >= 48
    AND ascii <= 57)
    SET parse_size = 1
    SET ptr = (subid_size - 1)
    WHILE (ptr > 0)
      SET ascii = ichar(substring(ptr,1,subidnbr))
      IF (ascii >= 48
       AND ascii <= 57)
       SET parse_size = (parse_size+ 1)
      ELSE
       SET ptr = 0
      ENDIF
      SET ptr = (ptr - 1)
    ENDWHILE
    IF (parse_size=subid_size)
     RETURN(" ")
    ENDIF
    SET ptr = ((subid_size - parse_size)+ 1)
    RETURN(substring(ptr,parse_size,subidnbr))
   ENDIF
   IF (((ascii >= 65
    AND ascii <= 90) OR (ascii >= 97
    AND ascii <= 122)) )
    RETURN(substring(subid_size,1,subidnbr))
   ENDIF
 END ;Subroutine
#exit_script
END GO

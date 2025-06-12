CREATE PROGRAM csa_create:dba
 PAINT
  video(r), box(1,1,10,80), box(1,1,4,80),
  clear(2,2,78), text(02,28," CSA BUILDING TOOL"), clear(3,2,78),
  video(n), text(05,05,"Beginning Script Name:  "), text(06,05,"Ending Script Name:  "),
  accept(05,29,"P(34);CU"), accept(06,29,"P(34);CU")
#2000_main
 EXECUTE FROM 1000_housekeeping TO 1099_housekeeping_exit
 FOR (z = 1 TO nbr_of_scripts)
   EXECUTE FROM 3000_init_variables TO 3099_init_variables_exit
   EXECUTE FROM 3000_load_arrays TO 3099_load_arrays_exit
   IF (error_flag != "Y")
    EXECUTE FROM 3000_display_status TO 3099_display_status_exit
    EXECUTE FROM 3000_csa_create TO 3099_csa_create_exit
   ENDIF
 ENDFOR
 GO TO end_program
#2000_main_exit
#1000_housekeeping
 SET subs[20] = fillstring(60," ")
 SET subs_type[20] = fillstring(03," ")
 SET request_number[20] = fillstring(06," ")
 SET parent_name[20] = fillstring(30," ")
 SET elem_name[20,10] = fillstring(31," ")
 SET attr_name[20,100] = fillstring(31," ")
 SET attr_type[20,100] = fillstring(10," ")
 SET attr_key_type[20,100] = fillstring(03," ")
 SET script_name[999] = fillstring(34," ")
 SET code_value[999] = 0.0
 SET display = fillstring(03," ")
 SET script_name_begin =  $1
 SET script_name_end =  $2
 SET nbr_of_scripts = 0
 SELECT INTO "nl:"
  c.description, c.code_value
  FROM code_value c
  WHERE c.code_set=290
   AND ((substring(4,3,c.display)="ENS") OR (substring(5,3,c.display)="ENS"))
   AND (c.display >=  $1)
   AND (c.display <=  $2)
  ORDER BY c.display
  DETAIL
   nbr_of_scripts += 1, script_name[nbr_of_scripts] = c.display, code_value[nbr_of_scripts] = c
   .code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET fname = "REQ_ERROR.PRG"
  SET error_msg = "%ERROR - NO SCRIPTS FOUND IN RANGE"
  EXECUTE FROM 4000_error TO 4099_error_exit
  GO TO end_program
 ENDIF
#1099_housekeeping_exit
#3000_init_variables
 SET error_flag = "N"
 SET error_msg = fillstring(50," ")
 SET nxt_lne = fillstring(92," ")
 SET program_name = script_name[z]
 SET nbr_of_subs = 0
 SET column_name = fillstring(32," ")
 SET dummy = initarray(subs,fillstring(60," "))
 SET dummy = initarray(subs_type,fillstring(03," "))
 SET dummy = initarray(request_number,fillstring(06," "))
 SET dummy = initarray(parent_name,fillstring(30," "))
 SET dummy = initarray(elem_name,fillstring(31," "))
 SET dummy = initarray(attr_name,fillstring(31," "))
 SET dummy = initarray(attr_type,fillstring(10," "))
 SET dummy = initarray(attr_key_type,fillstring(03," "))
#3099_init_variables_exit
#3000_load_arrays
 SET nbr_of_subs = 0
 SELECT INTO "nl:"
  c.field_value
  FROM code_value_extension c
  WHERE (c.code_value=code_value[z])
   AND c.field_name="REQUEST_NUMBER"
  DETAIL
   nbr_of_subs += 1, request_number[nbr_of_subs] = c.field_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = "%ERROR - REQUEST_NUMBER NOT FOND ON CODE_VALUE_EXTENSION TABLE"
  EXECUTE FROM 4000_error TO 4099_error_exit
 ENDIF
 SET nbr_of_subs = 0
 SELECT INTO "nl:"
  c.field_value
  FROM code_value_extension c
  WHERE (c.code_value=code_value[z])
   AND c.field_name="TABLE_NAME"
  DETAIL
   nbr_of_subs += 1, subs[nbr_of_subs] = c.field_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = "%ERROR - TABLE_NAME NOT FOND ON CODE_VALUE_EXTENSION TABLE"
  EXECUTE FROM 4000_error TO 4099_error_exit
 ENDIF
 SET nbr_of_subs = 0
 SELECT INTO "nl:"
  c.field_value
  FROM code_value_extension c
  WHERE (c.code_value=code_value[z])
   AND c.field_name="SCRIPT_TYPE"
  DETAIL
   nbr_of_subs += 1, subs_type[nbr_of_subs] = c.field_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = "%ERROR - SCRIPT_TYPE NOT FOND ON CODE_VALUE_EXTENSION TABLE"
  EXECUTE FROM 4000_error TO 4099_error_exit
 ENDIF
 FOR (i = 1 TO nbr_of_subs)
   SET nbr_of_attrs = 0
   SET nbr_of_elems = 0
   SELECT INTO "nl:"
    t.file_name, t.table_name, t.num_attr,
    t.table_level, l.attr_id, l.attr_name,
    l.type, l.stat, l.offset,
    type =
    IF (btest(l.stat,6)=1) concat("D",l.type,trim(cnvtstring(l.len)),".",cnvtstring(l.precision))
    ELSEIF (btest(l.stat,5)=1) concat("T",l.type,trim(cnvtstring(l.len)),".",cnvtstring(l.precision))
    ELSE concat(" ",l.type,trim(cnvtstring(l.len)),".",cnvtstring(l.precision))
    ENDIF
    FROM dtable t,
     dtableattr a,
     dtableattrl l
    PLAN (t
     WHERE (t.table_name=subs[i]))
     JOIN (a
     WHERE t.table_name=a.table_name)
     JOIN (l)
    DETAIL
     IF (l.attr_name != "DATAREC"
      AND l.attr_name != "ROWID")
      nbr_of_attrs += 1, attr_name[i,nbr_of_attrs] = l.attr_name, attr_type[i,nbr_of_attrs] = type
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = "%ERROR - 290 CODESET HAS INVALID TABLE NAME"
    EXECUTE FROM 4000_error TO 4099_error_exit
   ENDIF
   SELECT INTO "nl:"
    ai.table_name, ai.index_name, ai.uniqueness,
    aic.column_name, aic.column_position, aic.column_length
    FROM all_indexes ai,
     all_ind_columns aic
    PLAN (ai
     WHERE (ai.table_name=subs[i])
      AND substring(1,3,ai.index_name)="XPK")
     JOIN (aic
     WHERE aic.index_name=ai.index_name)
    ORDER BY ai.table_name, ai.index_name, aic.column_position
    DETAIL
     nbr_of_elems += 1, elem_name[i,nbr_of_elems] = aic.column_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    a.r_constraint_name, a2.table_name, a4.column_name
    FROM all_constraints a,
     all_constraints a2,
     all_cons_columns a4
    WHERE (a.table_name=subs[i])
     AND a.r_constraint_name=a2.constraint_name
     AND a2.constraint_name=a4.constraint_name
    DETAIL
     parent_name[i] = substring(4,27,a.r_constraint_name), column_name = a4.column_name
    WITH nocounter
   ;end select
   FOR (x = 1 TO nbr_of_attrs)
    FOR (y = 1 TO nbr_of_elems)
      IF ((attr_name[i,x]=elem_name[i,y]))
       IF (substring((size(trim(attr_name[i,y],1),1) - 2),3,attr_name[i,y])="_ID")
        SET attr_key_type[i,x] = "SEQ"
       ELSE
        SET attr_key_type[i,x] = "OTH"
       ENDIF
      ENDIF
    ENDFOR
    IF ((attr_name[i,x]=column_name))
     IF ((attr_key_type[i,x] > " "))
      SET attr_key_type[i,x] = "FKP"
     ELSE
      SET attr_key_type[i,x] = "FK"
     ENDIF
    ENDIF
   ENDFOR
 ENDFOR
#3099_load_arrays_exit
#3000_csa_create
 SET fname = build("REQ",request_number[1],".CSA")
 SELECT INTO value(fname)
  d.seq
  FROM dummyt d
  FOOT REPORT
   row + 0, "/*", row + 1,
   "** File Name: ", col 15, fname,
   row + 1, "**", row + 1,
   "** Description: ", col 17, script_name[z],
   row + 1, "**", row + 1,
   "** Modifications: ", row + 1, "**",
   row + 1, "**", row + 1,
   "*/", row + 1
   FOR (i = 1 TO nbr_of_subs)
     nxt_lne = concat("struct ",cnvtupper(substring(1,1,subs[i])),cnvtlower(substring(2,58,subs[i]))),
     row + 1, nxt_lne,
     row + 1, "{"
     CASE (subs_type[i])
      OF "ENS":
       row + 1,"  string  (3) action_type;",row + 1,
       "  string  (1) new_person;",inx = 1,
       WHILE ((attr_name[i,inx] > " "))
        IF (substring(1,6,attr_name[i,inx]) != "CREATE"
         AND substring(1,4,attr_name[i,inx]) != "UPDT")
         CASE (attr_type[i,inx])
          OF " I4*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  long    ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " I2*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " F8*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  long    ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  double  ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF "DQ8*":
           nxt_lne = concat("  date    ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " C*":
           FOR (x = 3 TO 10)
             IF (substring(x,1,attr_type[i,inx])=".")
              length = substring(3,(x - 3),attr_type[i,inx]), x = 10
             ENDIF
           ENDFOR
           ,nxt_lne = concat("  string  ","(",trim(length,1),") ",trim(cnvtlower(attr_name[i,inx]),1),
            ";"),row + 1,nxt_lne
         ENDCASE
        ENDIF
        ,inx += 1
       ENDWHILE
      OF "ADD":
       inx = 1,
       WHILE ((attr_name[i,inx] > " "))
        IF (substring(1,6,attr_name[i,inx]) != "CREATE"
         AND substring(1,4,attr_name[i,inx]) != "UPDT"
         AND substring(1,8,attr_name[i,inx]) != "ACTIVITY")
         CASE (attr_type[i,inx])
          OF " I4*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  long    ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " I2*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " F8*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  long    ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  double  ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF "DQ8*":
           nxt_lne = concat("  date    ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " C*":
           FOR (x = 3 TO 10)
             IF (substring(x,1,attr_type[i,inx])=".")
              length = substring(3,(x - 3),attr_type[i,inx]), x = 10
             ENDIF
           ENDFOR
           ,nxt_lne = concat("  string  ","(",trim(length,1),") ",trim(cnvtlower(attr_name[i,inx]),1),
            ";"),row + 1,nxt_lne
         ENDCASE
        ENDIF
        ,inx += 1
       ENDWHILE
      OF "UPT":
       inx = 1,
       WHILE ((attr_name[i,inx] > " "))
        IF (substring(1,6,attr_name[i,inx]) != "CREATE"
         AND substring(1,4,attr_name[i,inx]) != "UPDT")
         CASE (attr_type[i,inx])
          OF " I4*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  long    ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " I2*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " F8*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  long    ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  double  ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF "DQ8*":
           nxt_lne = concat("  date    ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " C*":
           FOR (x = 3 TO 10)
             IF (substring(x,1,attr_type[i,inx])=".")
              length = substring(3,(x - 3),attr_type[i,inx]), x = 10
             ENDIF
           ENDFOR
           ,nxt_lne = concat("  string  ","(",trim(length,1),") ",trim(cnvtlower(attr_name[i,inx]),1),
            ";"),row + 1,nxt_lne
         ENDCASE
        ENDIF
        ,inx += 1
       ENDWHILE
      OF "RPL":
       inx = 1,
       WHILE ((attr_name[i,inx] > " "))
        IF (substring(1,6,attr_name[i,inx]) != "CREATE"
         AND substring(1,4,attr_name[i,inx]) != "UPDT"
         AND substring(1,8,attr_name[i,inx]) != "ACTIVITY")
         CASE (attr_type[i,inx])
          OF " I4*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  long    ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " I2*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  short   ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " F8*":
           IF (substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_ID"
            AND substring((size(trim(attr_name[i,inx],1),1) - 2),3,attr_name[i,inx]) != "_CD")
            nxt_lne = concat("  long    ",trim(cnvtlower(attr_name[i,inx]),1),"_ind;"), row + 1,
            nxt_lne
           ENDIF
           ,nxt_lne = concat("  double  ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF "DQ8*":
           nxt_lne = concat("  date    ",trim(cnvtlower(attr_name[i,inx]),1),";"),row + 1,nxt_lne
          OF " C*":
           FOR (x = 3 TO 10)
             IF (substring(x,1,attr_type[i,inx])=".")
              length = substring(3,(x - 3),attr_type[i,inx]), x = 10
             ENDIF
           ENDFOR
           ,nxt_lne = concat("  string  ","(",trim(length,1),") ",trim(cnvtlower(attr_name[i,inx]),1),
            ";"),row + 1,nxt_lne
         ENDCASE
        ENDIF
        ,inx += 1
       ENDWHILE
     ENDCASE
     row + 1, "  long    updt_cnt;", row + 1,
     "}", row + 1, row + 1,
     "struct Request", row + 1, "{",
     nxt_lne = concat("  long ",trim(cnvtlower(subs[i]),1),"_qual;"), row + 1, nxt_lne,
     row + 1, "  string (3)  esi_ensure_type;", nxt_lne = concat("  list(",cnvtupper(substring(1,1,
        subs[i])),trim(cnvtlower(substring(2,58,subs[i])),1),") ",trim(cnvtlower(subs[i]),1),
      ";"),
     row + 1, nxt_lne, row + 1,
     "}", row + 1
   ENDFOR
   row + 1, row + 1, "defmsg Req",
   col 10, request_number[1], nxt_lne = concat("  name = ",'"',trim(script_name[z],1),'"'),
   row + 1, nxt_lne, nxt_lne = concat("  id = ",trim(request_number[1],1)),
   row + 1, nxt_lne, row + 1,
   "  protocol = rr", row + 1, "  request = Request",
   row + 1, "  reply = dynamic;", row + 1,
   row + 1, "exportmsg Req", col 13,
   request_number[1], nxt_lne = concat("  service = ",'"',"CpmScript",'"'), row + 1,
   nxt_lne, nxt_lne = concat("  filename = ",'"',"Req",trim(request_number[1],1),'";'), row + 1,
   nxt_lne
  WITH noformfeed, format = variable, nocounter,
   maxrow = 1, noheading
 ;end select
#3099_csa_create_exit
#3000_display_status
 CALL video(r)
 CALL clear(4,10,60)
 CALL clear(5,10,60)
 CALL clear(6,10,60)
 CALL clear(7,10,60)
 CALL clear(8,10,60)
 CALL clear(9,10,60)
 CALL clear(10,10,60)
 CALL box(4,10,10,70)
 CALL text(04,28," CSA BUILDING TOOL ")
 CALL text(06,26,"GENERATING ")
 SET program_name = build("REQ",request_number[1],".CSA")
 CALL text(06,37,program_name)
 SET display = cnvtstring(z)
 CALL text(09,54,display)
 CALL text(09,58,"OF")
 SET display = cnvtstring(nbr_of_scripts)
 CALL text(09,61,display)
 CALL video(n)
 CALL text(23,01," ")
#3099_display_status_exit
#4000_error
 SET fname = build("REQ",request_number[1],".CSA")
 SELECT INTO value(fname)
  d.seq
  FROM dummyt d
  FOOT REPORT
   col 00, "/****************************************************************", row + 1,
   "*", col 5, error_msg,
   col 63, "*", row + 1,
   col 00, "****************************************************************/"
  WITH noformfeed, format = variable, nocounter
 ;end select
#4099_error_exit
#end_program
END GO

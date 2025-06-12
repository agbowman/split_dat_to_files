CREATE PROGRAM cclsql_declare:dba
 IF (currdb="ORACLE")
  RDB asis ( "  create or replace function sql_get_code_meaning(cvalue integer) " ) asis (
  "    return      varchar2 " ) asis ( "    is resultout   varchar2(12); " ) asis ( "  begin " ) asis
   ( "    select cdf_meaning " ) asis (
  "    into   resultout from code_value where code_value = cvalue; " ) asis (
  "    return (resultout); " ) asis ( "  end; " )
  END ;Rdb
  RDB asis ( "  create or replace function sql_get_code_display(cvalue integer) " ) asis (
  "    return      varchar2 " ) asis ( "    is resultout   varchar2(40); " ) asis ( "  begin " ) asis
   ( "    select display " ) asis (
  "    into   resultout from code_value where code_value = cvalue; " ) asis (
  "    return (resultout); " ) asis ( "  end; " )
  END ;Rdb
  RDB asis ( "  create or replace function sql_get_code_displaykey(cvalue integer) " ) asis (
  "    return      varchar2 " ) asis ( "    is resultout   varchar2(40); " ) asis ( "  begin " ) asis
   ( "    select display_key " ) asis (
  "    into   resultout from code_value where code_value = cvalue; " ) asis (
  "    return (resultout); " ) asis ( "  end; " )
  END ;Rdb
  RDB asis ( "  create or replace function sql_get_code_description(cvalue integer) " ) asis (
  "    return      varchar2 " ) asis ( "    is resultout   varchar2(60); " ) asis ( "  begin " ) asis
   ( "    select description " ) asis (
  "    into   resultout from code_value where code_value = cvalue; " ) asis (
  "    return (resultout); " ) asis ( "  end; " )
  END ;Rdb
  RDB asis ( "  create or replace function sql_get_code_set(cvalue integer) " ) asis (
  "    return      varchar2" ) asis ( "    is resultout   varchar2(12); " ) asis ( "  begin " ) asis
  ( "    select code_set " ) asis (
  "    into   resultout from code_value where code_value = cvalue; " ) asis (
  "    return (resultout); " ) asis ( "  end; " )
  END ;Rdb
  RDB asis ( "  create or replace function sql_jcm1(cvalue integer) " ) asis (
  "    return      integer" ) asis ( "    is resultout   integer; " ) asis ( "  begin " ) asis (
  "    select code_set" ) asis ( "    into   resultout from code_value where code_value = cvalue; " )
   asis ( "    return (resultout); " ) asis ( "  end; " )
  END ;Rdb
 ENDIF
END GO

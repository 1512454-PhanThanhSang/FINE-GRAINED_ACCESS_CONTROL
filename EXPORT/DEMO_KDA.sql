create user kda identified by 123456;
grant dba to kda with admin option;
grant create session, create any context, create procedure,
    create trigger, administer database trigger to kda;
grant execute on dbms_session to kda;
grant execute on dbms_rls to kda;

conn kda/123456
create or replace context global_kda_ctx using kda_ctx_pkg ACCESSED GLOBALLY;
CREATE OR REPLACE PACKAGE kda_ctx_pkg 
  AS  
    PROCEDURE set_kda_ctx(sec_level IN VARCHAR2); 
    PROCEDURE clear_kda_context;
  END;  
/
CREATE OR REPLACE PACKAGE BODY kda_ctx_pkg 
  AS                                            
  PROCEDURE set_kda_ctx(sec_level IN VARCHAR2)      
    AS   
    BEGIN  
      DBMS_SESSION.SET_CONTEXT(  
      namespace  => 'global_kda_ctx', 
      attribute  => 'job_role', 
      value      => sec_level);
    END set_kda_ctx;
  PROCEDURE clear_kda_context  
    AS
    BEGIN  
      DBMS_SESSION.CLEAR_CONTEXT(
       namespace         => 'global_kda_ctx',
       attribute         => 'job_role');
    END clear_kda_context;  
END; 
/


BEGIN
  kda_ctx_pkg.set_kda_ctx('NHANVIEN');
END;
/

BEGIN
  kda_ctx_pkg.set_kda_ctx('KHACHHANG');
END;
/
BEGIN
  kda_ctx_pkg.clear_kda_context;
END;
/

EXEC kda_ctx_pkg.clear_kda_context; 

CONN NV01/PWNV01
SELECT SYS_CONTEXT('global_kda_ctx', 'job_role') job_role FROM DUAL;
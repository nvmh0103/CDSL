CREATE DATABASE DETN01
CREATE TABLE THISINH(
    SOBD VARCHAR(5) PRIMARY KEY,
    HOTEN CHAR(30),
    NGSINH SMALLDATETIME,
    CAPDO INT,
)
CREATE TABLE CAUHOI(
    MACH VARCHAR(10) PRIMARY KEY,
    NOIDUNGCH CHAR(30),
    DIEM INT,
    DOKHO INT,
)
CREATE TABLE PHUONGAN(
    MAPA VARCHAR(10) PRIMARY KEY,
    NOIDUNGPA CHAR(30),
    MACH VARCHAR(10),
    LADAPAN INT,
    CONSTRAINT FK_MACH FOREIGN KEY (MACH) REFERENCES CAUHOI(MACH)
)
CREATE TABLE TRALOI(
    SOBD VARCHAR(5),
    MACH VARCHAR(10),
    MAPA VARCHAR(10),
    CONSTRAINT PK_SOBD_MACH PRIMARY KEY (SOBD,MACH),
    CONSTRAINT FK_SOBD FOREIGN KEY (SOBD) REFERENCES THISINH(SOBD),
    CONSTRAINT FK_MACH1 FOREIGN KEY (MACH) REFERENCES CAUHOI(MACH),
    CONSTRAINT FK_MAPA FOREIGN KEY (MAPA) REFERENCES PHUONGAN(MAPA)
)

-- DATA

INSERT INTO THISINH(SOBD,HOTEN,NGSINH,CAPDO) VALUES('TS001','NGUYEN VAN HOANG ANH','02/10/2000',2)
INSERT INTO THISINH(SOBD,HOTEN,NGSINH,CAPDO) VALUES('TS002','TRAN HUONG GIANG','17/03/1999',3)
INSERT INTO THISINH(SOBD,HOTEN,NGSINH,CAPDO) VALUES('TS003','PHAM THI NHU Y','08/03/2001',5)

INSERT INTO CAUHOI(MACH,NOIDUNGCH,DIEM,DOKHO) VALUES('CHDKA','O VIET NAM,.....',25,1)
INSERT INTO CAUHOI(MACH,NOIDUNGCH,DIEM,DOKHO) VALUES('CHOWQ','BENH GI BAC SY BO TAY',15,3)
INSERT INTO CAUHOI(MACH,NOIDUNGCH,DIEM,DOKHO) VALUES('CHDJSA','NG DEP MONALISA KO CO GI?',5,5)

INSERT INTO PHUONGAN(MAPA,NOIDUNGPA,MACH,LADAPAN) VALUES('PA01DAF','THANG LONG VA HA LONG','CHDKA',1)
INSERT INTO PHUONGAN(MAPA,NOIDUNGPA,MACH,LADAPAN) VALUES('PA01DAG','HN VA TPHCM','CHDKA',0)
INSERT INTO PHUONGAN(MAPA,NOIDUNGPA,MACH,LADAPAN) VALUES('PA01DJV','CHONG','CHDJSA',0)

INSERT INTO TRALOI(SOBD,MACH,MAPA) VALUES('TS001','CHDKA','PA01DAF')
INSERT INTO TRALOI(SOBD,MACH,MAPA) VALUES('TS001','CHDJSA','PA01DJV')
INSERT INTO TRALOI(SOBD,MACH,MAPA) VALUES('TS002','CHDKA','PA01DAG')

--TRIGGER
GO
ALTER TRIGGER TRG_CAUHOI ON CAUHOI
FOR INSERT,UPDATE
AS
BEGIN
    DECLARE @DOKHO INT, @DIEM INT
    SELECT @DOKHO=DOKHO,@DIEM=DIEM
    FROM INSERTED
    IF (@DOKHO<3)
        IF (@DIEM<20)
            BEGIN
                PRINT 'LOI: DIEM PHAI LON HON 20!'
                ROLLBACK TRANSACTION
            END
        ELSE
            PRINT 'NHAP CAU HOI THANH CONG'
    ELSE
        PRINT 'NHAP CAU HOI THANH CONG'
END

--TRIGGER 2
GO
CREATE TRIGGER TRG_PA ON PHUONGAN
FOR INSERT,UPDATE
AS
BEGIN
    DECLARE @MACH VARCHAR(10)
    SELECT @MACH=MACH
    FROM inserted
    IF EXISTS(
        SELECT *
        FROM PHUONGAN
        WHERE (SELECT COUNT(MAPA) FROM PHUONGAN 
                WHERE MACH=@MACH AND LADAPAN=1) != 1
    )
    BEGIN
        PRINT 'LOI: MOI CAU HOI CHI CO 1 DAP AN DUY NHAT!!!'
        ROLLBACK TRANSACTION
    END
    ELSE
        PRINT 'THEM PHUONG AN THANH CONG'
END

--SQL
-- CAU 5
SELECT HOTEN
FROM THISINH,TRALOI,PHUONGAN,CAUHOI
WHERE TRALOI.SOBD=THISINH.SOBD AND TRALOI.MACH=CAUHOI.MACH 
    AND TRALOI.MAPA=PHUONGAN.MAPA AND LADAPAN=1 AND DOKHO=1
ORDER BY CAPDO

--CAU 6
SELECT TOP 1 WITH TIES NOIDUNGCH,COUNT(MAPA) AS SOLUONG
FROM CAUHOI,TRALOI,THISINH
WHERE TRALOI.SOBD=THISINH.SOBD AND TRALOI.MACH=CAUHOI.MACH 
    AND (CAPDO>=3)
GROUP BY NOIDUNGCH
ORDER BY SOLUONG 

--CAU 7
SELECT NOIDUNGCH
FROM CAUHOI,TRALOI,THISINH
WHERE TRALOI.MACH=CAUHOI.MACH AND TRALOI.SOBD=THISINH.SOBD AND CAPDO=5
EXCEPT
SELECT NOIDUNGCH
FROM CAUHOI,TRALOI,THISINH
WHERE TRALOI.MACH=CAUHOI.MACH AND TRALOI.SOBD=THISINH.SOBD AND CAPDO<3

--CAU 8
SELECT HOTEN
FROM THISINH
WHERE NOT EXISTS(
    SELECT *
    FROM CAUHOI
    WHERE DOKHO=1 AND NOT EXISTS(
        SELECT *
        FROM TRALOI
        WHERE TRALOI.MACH=CAUHOI.MACH AND TRALOI.SOBD=THISINH.SOBD
    )
)
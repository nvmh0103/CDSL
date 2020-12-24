CREATE DATABASE QLydatphong

CREATE TABLE Loaiphong(
    maloaiphong char(4) primary key,
    tenloaiphong varchar(20),
)
CREATE TABLE Phong(
    maphong char(4) primary key,
    tenphong varchar(20),
    maloaiphong char(4),
    CONSTRAINT FK_MALP FOREIGN KEY (maloaiphong) REFERENCES Loaiphong(maloaiphong),
)
CREATE TABLE Khachhang(
    makh char(4) primary key,
    hoten varchar(20),
    sdt varchar(10),
    ngsinh smalldatetime,
    gioitinh varchar(3),
)
CREATE TABLE Trangthaidatcho(
    matrangthai char(4) PRIMARY key,
    tentrangthai varchar(50),
)
CREATE TABLE Datphong(
    madatphong char(10) PRIMARY key,
    makh char(4),
    maphong char(4),
    tungay smalldatetime,
    denngay smalldatetime,
    matrangthai char(4),
    ghichu varchar(50),
    ngaydat smalldatetime,
    CONSTRAINT FK_MAKH FOREIGN KEY (makh) REFERENCES Khachhang(makh),
    CONSTRAINT FK_MATT FOREIGN KEY (matrangthai) REFERENCES Trangthaidatcho(matrangthai),
    CONSTRAINT FK_MAPH FOREIGN KEY (maphong) REFERENCES Phong(maphong),
    
)
-- 1.2
ALTER TABLE Phong
ADD ghichu varchar(50)

--1.3

ALTER TABLE Phong
ALTER COLUMN ghichu varchar(100)

--2 
--2.1
GO
CREATE TRIGGER TRG1 ON Trangthaidatcho
FOR INSERT,UPDATE
AS
BEGIN
    DECLARE @tentrangthai varchar(50)
    select @tentrangthai=tentrangthai
    from inserted
    if (@tentrangthai='hoan tat' or @tentrangthai='khong thanh cong')
        print 'Nhap trang thai dat cho thanh cong'
    else 
    begin
        print 'Loi: trang thai dat cho chi co the la hoan tat hoac khong thanh cong!'
        rollback TRANSACTION
    end
END

--2.2
GO
CREATE TRIGGER TRG2 on Datphong
for insert
as
begin
    declare @makh char(4),@ngaydat smalldatetime,@ngsinh smalldatetime
    select @makh=makh,@ngaydat=ngaydat
    from inserted
    select @ngsinh=ngsinh
    from Khachhang
    where makh=@makh
    if (@ngsinh=@ngaydat)
    begin
        update Datphong
        set ghichu='sinh nhat cua khach hang'
        where makh=@makh
    end
END

--3
--3.1
select madatphong,tungay,denngay,tentrangthai
from Trangthaidatcho th,Datphong dp
where th.matrangthai=dp.matrangthai

--3.2
select Phong.maphong,tenphong,count(ngaydat) as soluongdatphong
from Datphong,Phong
where Datphong.maphong=Phong.maphong and year(ngaydat)=2020 and month(ngaydat)=5
group by Phong.maphong,tenphong

--3.3
select top 1 with ties month(ngaydat) as thang,count(madatphong) as Soluongdatphong
from Datphong
where year(ngaydat)=2019
group by month(ngaydat)
order by Soluongdatphong desc

--3.4
select Khachhang.makh,hoten
from Khachhang,Datphong
where Khachhang.makh=Datphong.makh and year(ngaydat)=2020
and month(ngaydat) > 6 and month(ngaydat) < 9 and day(ngaydat) > 6 and day(ngaydat) <9

--3.5
select maphong,tenphong
from Phong
where not exists(
    select *
    from Khachhang
    where not exists(
        select *
        from Datphong
        where Phong.maphong=Datphong.maphong and Khachhang.makh=Datphong.makh
            and year(ngaydat)=2020 and month(ngaydat)=2
    )
)

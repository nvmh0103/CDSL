USE QLBH
SELECT MASP,TENSP
FROM SANPHAM
WHERE NUOCSX='TRUNGQUOC'

SELECT MASP,TENSP
FROM SANPHAM
WHERE (NUOCSX='THAILAN' OR NUOCSX='TRUNGQUOC') AND (GIA<40000 AND GIA>30000)

SELECT SANPHAM.MASP, TENSP
FROM SANPHAM,CTHD,HOADON,KHACHHANG
WHERE HOADON.SOHD=CTHD.SOHD AND CTHD.MASP=SANPHAM.MASP AND HOADON.MAKH=KHACHHANG.MAKH 
AND HOTEN='NGUYEN VAN A' AND YEAR(NGHD)=2006 AND MONTH(NGHD)=10

SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP NOT IN(
    SELECT SANPHAM.MASP
    FROM SANPHAM,CTHD
    WHERE SANPHAM.MASP=CTHD.MASP
)


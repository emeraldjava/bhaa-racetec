select * from RaceTec.dbo.ChipTime where RaceId=50

select DISTINCT(RaceId) from RaceTec.dbo.ChipTime where RaceId=50

select COUNT(TimeId) from RaceTec.dbo.ChipTime where RaceId=52
select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=1 and AntennaNo=1 and RaceId=52
select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=1 and AntennaNo=2 and RaceId=52
select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=1 and AntennaNo=3 and RaceId=52
select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=2 and AntennaNo=1 and RaceId=52
select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=2 and AntennaNo=2 and RaceId=52
select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=2 and AntennaNo=3 and RaceId=52

select
COUNT(TimeId) as total,
(select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=1 and AntennaNo=1) as R1A1,
(select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=1 and AntennaNo=2) as R1A2,
(select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=1 and AntennaNo=3) as R1A3,
(select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=2 and AntennaNo=1) as R2A1,
(select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=2 and AntennaNo=2) as R2A2,
(select COUNT(TimeId) from RaceTec.dbo.ChipTime where UHFReaderNo=2 and AntennaNo=3) as R2A3
from RaceTec.dbo.ChipTime 
where RaceId=52

total	R1A1	R1A2	R1A3	R2A1	R2A1	R2A1
437	11	4	191	0	4	227
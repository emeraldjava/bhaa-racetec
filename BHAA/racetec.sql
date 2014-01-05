-- race
select * from [RTSys].[dbo].[Race]
select * from [RTSys].[dbo].[Race] where RaceId=48;

select * from RaceTec.dbo.Athlete where AthleteId=11822

select * from raceTec.dbo.EventAthlete where RaceId = 48 and ChipNo='M' order by ChipNo
select distinct(ChipNo) from raceTec.dbo.EventAthlete where RaceId = 48

Update raceTec.dbo.EventAthlete set ChipNo = null where RaceId = 48 and AthleteId=11822

-- team types for race
SELECT * FROM [RaceTec].[dbo].[EventTeamType] where RaceId=10;

-- update the team count to three
UPDATE [RaceTec].[dbo].[EventTeamType] set MaxAthleteCount=3, ResultAthleteCount=3 where RaceId=10;
   
-- call the populate sp
exec RTSYs.dbo.[spComputeTeamFinishPositionsType3] 'RaceTec', 'RTSys',  38 ,  2, 0 

select * from [RaceTec].[dbo].[RaceEvent]

select * from [RaceTec].dbo.EventTeamResultType2 where RaceId=38 and EventId=2 

-- select men's team results for ncf2012
SELECT *,NTILE(4) over (order by TotalStd) as class FROM [RaceTec].[dbo].[EventTeamResultType2] 
where RaceId=38 and EventId=2 
order by class, TotalPos;

SELECT *,
case NTILE(4) over (order by TotalStd) when 1 then 'A' when 2 then 'B' when 3 then 'C' else 'D' end as class FROM [RaceTec].[dbo].[EventTeamResultType2] 
where RaceId=38 and EventId=2 
order by class, TotalPos;

select top 25 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd;
select top 50 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd;
select top 75 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd;
select top 25 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd;


SELECT *,NTILE(4) over (order by TotalStd) as class FROM [RaceTec].[dbo].[EventTeamResultType2] 
where RaceId=12 and EventId=2 
order by class, TotalPos;

-- list the a,b and c max values
Select max(a.TotalStd) as Amax FROM (select top 25 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd ) a
Select max(b.TotalStd) as Bmax FROM (select top 50 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd ) b
Select max(c.TotalStd) as Cmax FROM (select top 75 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd ) c

-- list the mix, max of the four quartiles
Select MIN(x.TotalStd) as min
 , avg(x.TotalStd) as avgAmount
 , max(x.TotalStd) as maxAmount
FROM (select top 25 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd ) x

Select MIN(x.TotalStd) as min
 , avg(x.TotalStd) as avgAmount
 , max(x.TotalStd) as maxAmount
FROM (select top 50 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd ) x

Select MIN(x.TotalStd) as min
 , avg(x.TotalStd) as avgAmount
 , max(x.TotalStd) as maxAmount
FROM (select top 75 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd ) x

Select MIN(x.TotalStd) as min
 , avg(x.TotalStd) as avgAmount
 , max(x.TotalStd) as maxAmount
FROM (select top 25 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd desc) x

Select MIN(x.TotalStd) as min
 , avg(x.TotalStd) as avgAmount
 , max(x.TotalStd) as maxAmount
FROM (select top 25 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd desc) x
 
select top 25 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd;

select top 25 PERCENT * FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 order by TotalStd desc;

# populate team results
exec RTSYs.dbo.[spComputeTeamFinishPositionsType3] 'RaceTec', 'RTSys',  25 ,  1 , 0;
select * from [RaceTec].[dbo].[EventTeamResultType2] where RaceId=25 and EventId=1 order by FinishPosition


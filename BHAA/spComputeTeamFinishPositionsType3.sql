USE [RTSys]
GO
/****** Object:  StoredProcedure [dbo].[spComputeTeamFinishPositionsType3]    Script Date: 05/04/2012 09:40:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
[spComputeTeamFinishPositionsType3] 'RaceTec', 'RTSys', 23, 2, 1
select * from ##TeamPosition where AthleteId = 6497
select * from ##teamtimes
*/

ALTER procedure [dbo].[spComputeTeamFinishPositionsType3] @DBName varchar(50), @SysDBName varchar(100),
  @RaceId int, @EventId int, @RoundingType int
--with encryption
AS 
BEGIN
  set nocount on
  exec spDropTempTable ##TeamPosition
  exec spDropTempTable ##TeamTimes
  exec spDropTempTable ##t

  declare @TeamResultTypeId int
  declare @s varchar(100)
  exec ('
    select TeamResultTypeId
    into ##t
    from ' + @DBName + '.dbo.RaceEvent
    where
      RaceId = ' + @RaceId + '
      and EventId = ' + @EventId)
                
   
  select @s = case
                when IsNull(TeamResultTypeId, 2) = 2 then 'TotalPos'
                when IsNull(TeamResultTypeId, 2) in (3, 5) then 'TeamTime'
              end,
         @TeamResultTypeId = TeamResultTypeId 
  from ##t
  exec spDropTempTable ##t

  exec ('
  update ' + @DBName + '.dbo.EventAthlete
  set
    TeamFinishPosition = 0,
    Type2TeamId = -1
  where
    RaceId = ' + @RaceId + '
    and EventId = ' + @EventId)
  
  exec ('
  update ' + @DBName + '.dbo.EventAthlete
  set
    ChipNo = 0
  where
    RaceId = ' + @RaceId + '
    and EventId = ' + @EventId + '
    and ChipNo = ''null''')

  exec ('
  update ' + @DBName + '.dbo.EventTeam 
  set     
    FinishTime = null,
    FinishPosition = null
  where
    RaceId = ' + @RaceId + '
    and EventId = ' + @EventId + '
    and FinishTime is not null')

  exec ('
  delete ' + @DBName + '.dbo.EventTeamResultType2
  where
    RaceId = ' + @RaceId + '
    and EventId = ' + @EventId)

  CREATE TABLE ##TeamPosition (TeamTypeId int, TeamId int, FinishTime DateTime, AthleteId int, AthletePos int, 
    TeamPos int, TeamMembers int , TempTeamId int, TeamResultTypeId int, TeamRounding int, AthleteStd int,
    CONSTRAINT PK_TeamPos PRIMARY KEY (TeamTypeId, TeamId, FinishTime, AthleteId))

  exec('
  insert ##TeamPosition (TeamTypeId, TeamId, FinishTime, AthleteId, AthletePos, AthleteStd, TeamMembers, TempTeamId, TeamResultTypeId, TeamRounding)
  select b.TeamTypeId, b.TeamId, 
    case
      when IsNull(c.TeamTimeType, 0) = 0 then a.FinishTime
      else IsNull(a.NetTime, 0)
    end,
    a.AthleteId, 
    case
      when IsNull(c.TeamTimeType, 0) = 0 then a.OverallFinishPosition
      when IsNull(c.TeamTimeType, 0) = 1 then a.CategoryFinishPosition
      else a.GenderFinishPosition
    end,
    ChipNo,
    IsNull(ett.ResultAthleteCount, 3), 0, c.TeamResultTypeId, c.TeamRounding
  from 
  ' + @DBName + '.dbo.EventAthlete a 
  join ' + @DBName + '.dbo.Athlete ath 
    on a.AthleteId = ath.AthleteId
  join ' + @DBName + '.dbo.EventTeam b 
    on a.RaceId = b.RaceId
    and a.EventId = b.EventId
    and a.TeamId = b.TeamId
  join ' + @DBName + '.dbo.EventTeamType ett
    on b.RaceId = ett.RaceId
    and b.EventId = ett.EventId
    and b.TeamTypeId = ett.TeamTypeId
  join ' + @DBName + '.dbo.RaceEvent c
    on a.RaceId = c.RaceId
    and a.EventId = c.EventId
  where
    a.RaceId = ' + @RaceId + '
    and a.EventId = ' + @EventId + '
    and a.FinishStatusId = 4
    and ath.GenderId = 2
    and a.Type2TeamId = -1
    and IsNull(a.ChipNo, 0) >= 1
    and a.FinishTime > 0')

  exec ('
  declare @TeamTypeId int, @TeamId int, @p int, @ResultAthleteCount int, @TempId int, @i int
  set @p = 0
  set @TeamTypeId = -1
  set @TeamId = -1
  set @ResultAthleteCount = 0
  set @TempId = 0
  update ##TeamPosition
  set 
    @p = case 
           when (TeamTypeId <> @TeamTypeId) or (TeamId <> @TeamId) or (@p >= @ResultAthleteCount) then 1
           else @p + 1 
         end,
    @TempId = case
                when (TeamTypeId <> @TeamTypeId) or (TeamId <> @TeamId) then 1 
                when (@i >= @ResultAthleteCount) then -1
                else @TempId
              end,
    @TeamTypeId = TeamTypeId,
    @TeamId = TeamId, 
    @ResultAthleteCount = TeamMembers,
    TeamPos = @p,
    TempTeamId = @TempId,
    @i = @p')


  exec ('
  update ' + @DBName + '.dbo.EventAthlete
  set
    TeamFinishPosition = b.TeamPos,
    Type2TeamId = TempTeamId,
    ReplStatus = 0
  from
  ' + @DBName + '.dbo.EventAthlete a 
  join ##TeamPosition b
    on a.RaceId = ' + @RaceId + '
    and a.EventId = ' + @EventId + '
    and a.TeamId = b.TeamId
    and a.AthleteId = b.AthleteId
  where
    (
		IsNull(a.TeamFinishPosition, -1) <> IsNull(b.TeamPos, 0)
		or IsNull(Type2TeamId, 0) <> IsNull(TempTeamId, 0)
	)
	and b.TempTeamId = 1
    ')

  exec ('CREATE TABLE ##TeamTimes (TeamTypeId int, TeamId int, TempTeamId int, TeamTime DateTime, Pos int, TotalPos int, TotalStd int,
         CONSTRAINT PK_TeamTime PRIMARY KEY (TeamTypeId, ' + @s + ', TeamId))')

  if (@TeamResultTypeId = 5) -- Average of times
	  exec ('
		  insert ##TeamTimes (TeamTypeId, TeamId, TempTeamId, TeamTime, TotalPos, TotalStd)
		  select TeamTypeId, TeamId, TempTeamId,
				 Convert(DateTime, avg(Convert(float, ' + @SysDBName + '.dbo.RoundTime(FinishTime, TeamRounding)))) as TeamTime,
				 sum(IsNull(AthletePos, 0)) as TotalPos,
				 sum(IsNull(AthleteStd, 0)) as TotalStd
		  from ##TeamPosition
		  where
		    case 
		      when TeamMembers = 0 then 0
		      else TeamPos
		    end <= TeamMembers
		  group by TeamTypeId, TeamId, TempTeamId, TeamMembers, TeamResultTypeId
		  having count(*) >= TeamMembers'
		  )
  else
	  exec ('
	  insert ##TeamTimes (TeamTypeId, TeamId, TempTeamId, TeamTime, TotalPos, TotalStd)
	  select TeamTypeId, TeamId, TempTeamId, 
			 ' + @SysDBName + '.dbo.RoundTime(Convert(DateTime, Sum(Convert(float, FinishTime))), 1) as TeamTime,
			 sum(IsNull(AthletePos, 0)) as TotalPos,
			 sum(IsNull(AthleteStd, 0)) as TotalStd
	  from ##TeamPosition
	  where
		TeamPos <= TeamMembers  
	  group by TeamTypeId, TeamId, TempTeamId, TeamMembers, TeamResultTypeId
	  having count(*) = TeamMembers')

  exec ('
  declare @TeamTypeId int, @TempTeamId int, @Time DateTime, @p int
  set @p = 0
  set @TeamTypeId = -1
  update ##TeamTimes 
  set 
    @p = case when (TeamTypeId <> @TeamTypeId) then 1
         else @p + 1
         end,
    @TeamTypeId = TeamTypeId,
    @TempTeamId = TempTeamId,
    Pos = @p')

  exec ('
  insert ' + @DBName + '.dbo.EventTeamResultType2 (RaceId, EventId, TeamTypeId, TeamId, TempTeamId, FinishPosition,
    FinishTime, TotalPos, TotalStd, GenderId)
  select ' +
    @RaceId + ',' +
    @EventId + ',
    TeamTypeId, TeamId, TempTeamId, Pos, TeamTime, TotalPos, TotalStd, 2
  from
  ##TeamTimes')
  
    -- Reset Type2TeamId for any women who are in a team that didn't make up the 'TeamMembers for a results' amount
  exec ('
  update ' + @DBName + '.dbo.EventAthlete
  set
    TeamFinishPosition = null,
    Type2TeamId = -1
  from
	' + @DBName + '.dbo.EventAthlete ea
	left join ' + @DBName + '.dbo.EventTeamResultType2 t
		on ea.RaceId = t.RaceId
		and ea.EventId = t.EventId
		and ea.TeamId = t.TeamId
		and ea.Type2TeamId = t.TempTeamId
  where
    ea.RaceId = ' + @RaceId + '
    and ea.EventId = ' + @EventId + '
    and t.RaceId is null')


  /*
      End of part 1
  */

	truncate table ##TeamPosition
	truncate table ##TeamTimes

  exec('
  insert ##TeamPosition (TeamTypeId, TeamId, FinishTime, AthleteId, AthletePos, AthleteStd, TeamMembers, TempTeamId, TeamResultTypeId, TeamRounding)
  select b.TeamTypeId, b.TeamId, 
    case
      when IsNull(c.TeamTimeType, 0) = 0 then a.FinishTime
      else IsNull(a.NetTime, 0)
    end,
    a.AthleteId, 
    case
      when IsNull(c.TeamTimeType, 0) = 0 then a.OverallFinishPosition
      when IsNull(c.TeamTimeType, 0) = 1 then a.CategoryFinishPosition
      else a.GenderFinishPosition
    end,
    a.ChipNo,
    ett.ResultAthleteCount, 0, c.TeamResultTypeId, c.TeamRounding
  from 
  ' + @DBName + '.dbo.EventAthlete a 
  join ' + @DBName + '.dbo.Athlete ath 
    on a.AthleteId = ath.AthleteId
  join ' + @DBName + '.dbo.EventTeam b 
    on a.RaceId = b.RaceId
    and a.EventId = b.EventId
    and a.TeamId = b.TeamId
  join ' + @DBName + '.dbo.EventTeamType ett
    on b.RaceId = ett.RaceId
    and b.EventId = ett.EventId
    and b.TeamTypeId = ett.TeamTypeId
  join ' + @DBName + '.dbo.RaceEvent c
    on a.RaceId = c.RaceId
    and a.EventId = c.EventId
  where
    a.RaceId = ' + @RaceId + '
    and a.EventId = ' + @EventId + '
    and a.FinishStatusId = 4
    and a.Type2TeamId = -1
    and IsNull(a.ChipNo, 0) >= 1
    and a.FinishTime > 0')

  exec ('
  declare @TeamTypeId int, @TeamId int, @p int, @ResultAthleteCount int, @TempId int, @i int
  set @p = 0
  set @TeamTypeId = -1
  set @TeamId = -1
  set @ResultAthleteCount = 0
  set @TempId = 1
  update ##TeamPosition
  set 
    @p = case 
           when (TeamTypeId <> @TeamTypeId) or (TeamId <> @TeamId) or (@p >= @ResultAthleteCount) then 1
           else @p + 1 
         end,
    @TempId = case
                when (TeamTypeId <> @TeamTypeId) or (TeamId <> @TeamId) then 2 
                when (@i >= @ResultAthleteCount) then @TempId + 1
                else @TempId
              end,
    @TeamTypeId = TeamTypeId,
    @TeamId = TeamId, 
    @ResultAthleteCount = TeamMembers,
    TeamPos = @p,
    TempTeamId = @TempId,
    @i = @p')

  exec ('
  update ' + @DBName + '.dbo.EventAthlete
  set
    TeamFinishPosition = b.TeamPos,
    Type2TeamId = TempTeamId,
    ReplStatus = 0
  from
  ' + @DBName + '.dbo.EventAthlete a 
  join ##TeamPosition b
    on a.RaceId = ' + @RaceId + '
    and a.EventId = ' + @EventId + '
    and a.TeamId = b.TeamId
    and a.AthleteId = b.AthleteId
  where
    (
		IsNull(a.TeamFinishPosition, -1) <> IsNull(b.TeamPos, 0)
		or IsNull(Type2TeamId, 0) <> IsNull(TempTeamId, 0)
	)
    ')

  if (@TeamResultTypeId = 5) -- Average of times
	  exec ('
		  insert ##TeamTimes (TeamTypeId, TeamId, TempTeamId, TeamTime, TotalPos, TotalStd)
		  select TeamTypeId, TeamId, TempTeamId,
				 Convert(DateTime, avg(Convert(float, ' + @SysDBName + '.dbo.RoundTime(FinishTime, TeamRounding)))) as TeamTime,
				 sum(IsNull(AthletePos, 0)) as TotalPos,
				 sum(IsNull(AthleteStd, 0)) as TotalStd
		  from ##TeamPosition
		  where
		    case 
		      when TeamMembers = 0 then 0
		      else TeamPos
		    end <= TeamMembers
		  group by TeamTypeId, TeamId, TempTeamId, TeamMembers, TeamResultTypeId
		  having count(*) >= TeamMembers'
		  )
  else
	  exec ('
	  insert ##TeamTimes (TeamTypeId, TeamId, TempTeamId, TeamTime, TotalPos, TotalStd)
	  select TeamTypeId, TeamId, TempTeamId, 
			 ' + @SysDBName + '.dbo.RoundTime(Convert(DateTime, Sum(Convert(float, FinishTime))), 1) as TeamTime,
			 sum(IsNull(AthletePos, 0)) as TotalPos,
			 sum(IsNull(AthleteStd, 0)) as TotalStd
	  from ##TeamPosition
	  where
		TeamPos <= TeamMembers  
	  group by TeamTypeId, TeamId, TempTeamId, TeamMembers, TeamResultTypeId
	  having count(*) = TeamMembers')

  exec ('
  declare @TeamTypeId int, @TempTeamId int, @Time DateTime, @p int
  set @p = 0
  set @TeamTypeId = -1
  update ##TeamTimes 
  set 
    @p = case when (TeamTypeId <> @TeamTypeId) then 1
         else @p + 1
         end,
    @TeamTypeId = TeamTypeId,
    @TempTeamId = TempTeamId,
    Pos = @p')

  exec ('
  insert ' + @DBName + '.dbo.EventTeamResultType2 (RaceId, EventId, TeamTypeId, TeamId, TempTeamId, FinishPosition,
    FinishTime, TotalPos, TotalStd, GenderId)
  select ' +
    @RaceId + ',' +
    @EventId + ',
    TeamTypeId, TeamId, TempTeamId, Pos, TeamTime, TotalPos, TotalStd, 1
  from
  ##TeamTimes')

  exec spDropTempTable ##TeamPosCalc
  
  exec ('select Row_Number() over (partition by GenderId order by GenderId, TotalPos ) as Pos,
		RaceId, EventId, TeamTypeId, TeamId, TempTeamId
		into ##TeamPosCalc
		from ' + @DBName + '.dbo.EventTeamResultType2
		where
			RaceId = ' + @RaceId + '
			and EventId = ' + @EventId)
			
  exec ('
		update ' + @DBName + '.dbo.EventTeamResultType2
		set
			FinishPosition = t.Pos
		from
			##TeamPosCalc t
			join ' + @DBName + '.dbo.EventTeamResultType2 et
				on t.RaceId = et.RaceId
				and t.EventId = et.EventId
				and t.TeamTypeId = et.TeamTypeId
				and t.TeamId = et.TeamId
				and t.TempTeamId = et.TempTeamId')
  
  exec spDropTempTable ##TeamPosition
  exec spDropTempTable ##TeamTimes
  
END

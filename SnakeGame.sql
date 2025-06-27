create database game_
use game_
create table ludogameplay (
    baari_no int identity(1,1) primary key,
    player int,
    dice_roll int,
    position int
)
create table snakesladders (
    start_pos int primary key,
    end_pos int
)
insert into snakesladders (start_pos, end_pos) values (4,14),(9,31),(17,7),(20,38),(28,84),(40,59),(51,67),(54,34),(62,19),(64,60),(71,91),(87,24),(93,73),(95,75),(99,78)
create function calculatenewposition(@current_position int, @dice_roll int)
returns int
as
begin
    declare @new_position int
    set @new_position = @current_position + @dice_roll
    if @new_position > 100
        set @new_position = 100
    return @new_position
end;
create trigger trg_updateposition
on ludogameplay
after insert
as
begin
    declare @baari_no int, @player int, @dice_roll int
    declare @last_position int = 0, @temp_position int, @final_position int
    select top 1 @baari_no = baari_no, @player = player, @dice_roll = dice_roll
    from inserted
    select top 1 @last_position = position
    from ludogameplay
    where player = @player and baari_no < @baari_no
    order by baari_no desc
    set @temp_position = dbo.calculatenewposition(@last_position, @dice_roll)
    select @final_position = end_pos
    from snakesladders
    where start_pos = @temp_position
    if @final_position is null
        set @final_position = @temp_position
    update ludogameplay
    set position = @final_position
    where baari_no = @baari_no
end
create procedure simulateturn
as
begin
    declare @next_player int, @turn_count int;
    select @turn_count = count(*)
	from ludogameplay;
    if @turn_count % 2 = 0
        set @next_player = 1
    else
        set @next_player = 2
    insert into ludogameplay(player, dice_roll, position) values (@next_player, cast(rand() * 6 + 1 as int), 0 )
end

declare @game_ongoing int = 1
while @game_ongoing = 1
begin
    exec simulateturn
    if exists( select 1 from ludogameplay where player = 1 and position = 100)
    begin
        print 'player 1 has won!'
        set @game_ongoing = 0
    end
    if exists( select 1 from ludogameplay where player = 2 and position = 100)
    begin
        print 'player 2 has won!'
        set @game_ongoing = 0
    end
end
select * from ludogameplay

truncate table ludogameplay

--THIS IS TO SEE TURN BY TURN EXECUTE FIRST LINE TWICE THEN SELECT
exec simulateturn;
select * from ludogameplay
truncate table ludogameplay
# 🎲 Snakes & Ladders – SQL Edition 🐍🪜

Welcome to a fun and interactive **Snakes & Ladders** simulation — built entirely using **T-SQL**! This project showcases how SQL can be used to create logic-driven games with triggers, stored procedures, and control loops — all inside your database. 🧠

---

## 🛠 Features

- 🎲 Dice rolling logic via `RAND()`
- 🔄 Turn-based simulation with alternating players
- 🐍 Snakes and 🪜 Ladders dynamic movement
- 🎯 Win condition at position 100
- 📜 Uses:
  - Triggers
  - Stored Procedures
  - User-Defined Functions
  - Looping with control logic

---

## 📂 Database Structure

### 🎮 `ludogameplay` – Game Turns
```sql
CREATE TABLE ludogameplay (
  baari_no INT IDENTITY(1,1) PRIMARY KEY,
  player INT,
  dice_roll INT,
  position INT
);
```

### 🪜 `snakesladders` – Snake & Ladder Mapping
```sql
CREATE TABLE snakesladders (
  start_pos INT PRIMARY KEY,
  end_pos INT
);

INSERT INTO snakesladders (start_pos, end_pos)
VALUES 
  (4,14), (9,31), (17,7), (20,38), (28,84), (40,59),
  (51,67), (54,34), (62,19), (64,60), (71,91), (87,24),
  (93,73), (95,75), (99,78);
```

---

## ⚙️ Core Logic

### 🎯 `calculatenewposition` – UDF to calculate post-roll position
```sql
CREATE FUNCTION calculatenewposition(@current_position INT, @dice_roll INT)
RETURNS INT
AS
BEGIN
    DECLARE @new_position INT;
    SET @new_position = @current_position + @dice_roll;
    IF @new_position > 100
        SET @new_position = 100;
    RETURN @new_position;
END;
```

### 🔁 `trg_updateposition` – Trigger to auto-update position with ladders/snakes
```sql
CREATE TRIGGER trg_updateposition
ON ludogameplay
AFTER INSERT
AS
BEGIN
    DECLARE @baari_no INT, @player INT, @dice_roll INT;
    DECLARE @last_position INT = 0, @temp_position INT, @final_position INT;

    SELECT TOP 1 @baari_no = baari_no, @player = player, @dice_roll = dice_roll
    FROM inserted;

    SELECT TOP 1 @last_position = position
    FROM ludogameplay
    WHERE player = @player AND baari_no < @baari_no
    ORDER BY baari_no DESC;

    SET @temp_position = dbo.calculatenewposition(@last_position, @dice_roll);

    SELECT @final_position = end_pos
    FROM snakesladders
    WHERE start_pos = @temp_position;

    IF @final_position IS NULL
        SET @final_position = @temp_position;

    UPDATE ludogameplay
    SET position = @final_position
    WHERE baari_no = @baari_no;
END;
```

### 🎮 `simulateturn` – Stored procedure to play the next move
```sql
CREATE PROCEDURE simulateturn
AS
BEGIN
    DECLARE @next_player INT, @turn_count INT;

    SELECT @turn_count = COUNT(*) FROM ludogameplay;

    IF @turn_count % 2 = 0
        SET @next_player = 1;
    ELSE
        SET @next_player = 2;

    INSERT INTO ludogameplay(player, dice_roll, position)
    VALUES (@next_player, CAST(RAND() * 6 + 1 AS INT), 0);
END;
```

---

## 🚀 Game Simulation Loop
```sql
DECLARE @game_ongoing INT = 1;

WHILE @game_ongoing = 1
BEGIN
    EXEC simulateturn;

    IF EXISTS (SELECT 1 FROM ludogameplay WHERE player = 1 AND position = 100)
    BEGIN
        PRINT 'Player 1 has won!';
        SET @game_ongoing = 0;
    END;

    IF EXISTS (SELECT 1 FROM ludogameplay WHERE player = 2 AND position = 100)
    BEGIN
        PRINT 'Player 2 has won!';
        SET @game_ongoing = 0;
    END;
END;
```

---

## 🧪 Manual Play for Testing

Use these commands to test the game turn by turn:
```sql
EXEC simulateturn;
SELECT * FROM ludogameplay;
```

Clear the gameplay table:
```sql
TRUNCATE TABLE ludogameplay;
```

---

## 👨‍💻 Author

**Azib Naeem**  
📍 Lahore, Pakistan  
📧 [azibnaeem17official@gmail.com](mailto:azibnaeem17official@gmail.com)  
🔗 [GitHub Profile](https://github.com/AzibNaeem)

---

## ⭐ Give it a Star!

If you liked this project, consider giving it a ⭐ to support and share with fellow developers!

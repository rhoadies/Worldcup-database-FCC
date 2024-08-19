#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "TRUNCATE TABLE games, teams;")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

do
	if [[ $WINNER != "winner" ]]
	then
		#Get the ID of the winning team
		WINNING_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
		#Get the ID of the losing team
		LOSING_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
		
		
		# IF not found then
		if test -z $WINNING_TEAM_ID && test -z $LOSING_TEAM_ID
		then
			INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER'), ('$OPPONENT');")
			echo "Inserted two teams : $WINNER, $OPPONENT"
	        	LOSING_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")	
	        	WINNING_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
		
		elif test -z $WINNING_TEAM_ID 
		then 
			INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
			echo "Inserted one team : $WINNER"
	        	WINNING_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
		elif test -z $LOSING_TEAM_ID 
		then 
			INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
			echo "Inserted one team : $OPPONENT"
	        	LOSING_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
		fi
		
		INSERT_GAMES_TABLE=$($PSQL "INSERT INTO games(year, winner_id, opponent_id, winner_goals, opponent_goals,round) VALUES ($YEAR, $WINNING_TEAM_ID, $LOSING_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS, '$ROUND');")

	fi

done

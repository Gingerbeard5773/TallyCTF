//Rules timer!

// Requires game_end_time set originally

void onInit(CRules@ this)
{
	if (!this.exists("no timer"))
		this.set_bool("no timer", false);
	if (!this.exists("game_end_time"))
		this.set_u32("game_end_time", 0);
	if (!this.exists("end_in"))
		this.set_s32("end_in", 0);
}

void onTick(CRules@ this)
{
	if (!getNet().isServer() || !this.isMatchRunning() || this.get_bool("no timer"))
	{
		return;
	}
	
	u32 gameEndTime = this.get_u32("game_end_time");
	if (gameEndTime == 0) return; //-------------------- early out if no time.

	this.set_s32("end_in", (s32(gameEndTime) - s32(getGameTime())) / 30);
	this.Sync("end_in", true);

	if (getGameTime() > gameEndTime)
	{
		u8 winnerTeam = -1;
		
		if (this.get_s32("flag_cap_count_0") > this.get_s32("flag_cap_count_1"))
			winnerTeam = 0;
		else if (this.get_s32("flag_cap_count_0") < this.get_s32("flag_cap_count_1"))
			winnerTeam = 1;

		if (winnerTeam >= 0 && winnerTeam < this.getTeamsNum())
		{
			//ends the game and sets the winning team
			this.SetTeamWon(winnerTeam);
			
			// add winning team coins
			CBlob@[] players;
			getBlobsByTag("player", @players);
			for (uint i = 0; i < players.length; i++)
			{
				CPlayer@ player = players[i].getPlayer();
				if (player !is null && players[i].getTeamNum() == winnerTeam)
				{
					player.server_setCoins(player.getCoins() + 150);
				}
			}
		}
		else
		{
			this.SetGlobalMessage("Time is up!\nIt's a tie!");
		}

		//GAME OVER
		this.SetCurrentState(3);
	}
}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	if (!this.isMatchRunning() || this.get_bool("no timer") || !this.exists("end_in")) return;

	s32 end_in = this.get_s32("end_in");

	if (end_in > 0)
	{
		s32 timeToEnd = end_in;

		s32 secondsToEnd = timeToEnd % 60;
		s32 MinutesToEnd = timeToEnd / 60;
		drawRulesFont(getTranslatedString("Time left: {MIN}:{SEC}")
						.replace("{MIN}", "" + ((MinutesToEnd < 10) ? "0" + MinutesToEnd : "" + MinutesToEnd))
						.replace("{SEC}", "" + ((secondsToEnd < 10) ? "0" + secondsToEnd : "" + secondsToEnd)),
		              SColor(255, 255, 255, 255), Vec2f(10, 140), Vec2f(getScreenWidth() - 20, 180), true, false);
	}
}

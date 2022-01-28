//TALLY CTF by GingerBeard

const SColor TEAM0COLOR(255, 25, 94, 157);
const SColor TEAM1COLOR(255, 192, 36, 36);
const u8 FONT_SIZE = 30;
bool keepScores = false;

void onInit(CRules@ this)
{
	print("--- INITIALIZING TALLYCTF ---");
	// set config prop to use appropriate config file
	this.set_string("ctfconfig", "tallyctf_vars.cfg");
	
	//score rendering font
	if (!GUI::isFontLoaded("big score font"))
	{
        GUI::LoadFont("big score font", "GUI/Fonts/AveriaSerif-Bold.ttf", FONT_SIZE, true);
    }
}

void onRestart(CRules@ this)
{
	if (!keepScores)
	{
		this.set_s32("flag_cap_count_0", 0);
		this.set_s32("flag_cap_count_1", 0);
	}
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null) return true;

	if (sv_test || player.isMod())
	{
		if (text_in.substr(0,1) == "!" )
		{
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!gametime")
				{
					//sets the game time for next map (IN MINUTES)
					this.set_s32("custom_game_time", parseInt(tokens[1]));
					return true;
				}
				else if (tokens[0] == "!warmuptime")
				{
					//sets the warmup time for next map
					this.set_s32("custom_warmup_time", parseInt(tokens[1]));
					return true;
				}
				else if (tokens[0] == "!setscore" && tokens.length > 2)
				{
					// !setscore (team) (score)
					this.set_s32("flag_cap_count_"+tokens[1], parseInt(tokens[2]));
					this.Sync("flag_cap_count_"+tokens[1], true);
					return true;
				}
			}
			else
			{
				if (tokens[0] == "!keepscores")
				{
					//toggle on/off score keeping throughout matches
					keepScores = !keepScores;
					return true;
				}
				else if (tokens[0] == "!resetscores")
				{
					//reset all scores
					this.set_s32("flag_cap_count_0", 0);
					this.set_s32("flag_cap_count_1", 0);
					this.Sync("flag_cap_count_0", true);
					this.Sync("flag_cap_count_1", true);
					return true;
				}
			}
		}
	}
	return true;
}

void onRender(CRules@ this)
{
	if (!this.isMatchRunning() && !keepScores) return;
	
    GUI::SetFont("big score font");
    u8 team0Score = this.get_s32("flag_cap_count_0");
    u8 team1Score = this.get_s32("flag_cap_count_1");
    //log("onRender", "" + team0Score + ", " + team1Score);
    Vec2f team0ScoreDims;
    Vec2f team1ScoreDims;
    Vec2f scoreSeperatorDims;
    GUI::GetTextDimensions("" + team0Score, team0ScoreDims);
    GUI::GetTextDimensions("" + team1Score, team1ScoreDims);
    GUI::GetTextDimensions("-", scoreSeperatorDims);

    Vec2f scoreDisplayCentre(getScreenWidth()/2, getScreenHeight() / 6.0);
    int scoreSpacing = 24;

    Vec2f topLeft0(scoreDisplayCentre.x - scoreSpacing - team0ScoreDims.x, scoreDisplayCentre.y);
    Vec2f topLeft1(scoreDisplayCentre.x + scoreSpacing, scoreDisplayCentre.y);
    GUI::DrawText("" + team0Score, topLeft0, TEAM0COLOR);
    GUI::DrawText("-", Vec2f(scoreDisplayCentre.x - scoreSeperatorDims.x/2.0, scoreDisplayCentre.y), color_black);
    GUI::DrawText("" + team1Score, topLeft1, TEAM1COLOR);
}
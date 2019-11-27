'**********
' MKE 2019
'**********

'Define general variables

Dim BIP					'Number of balls currently on the table, not counting locked or captive balls
BIP = 0
Dim Saver				'If true, the ball saver is lit: A ball down the drain is returned
Saver = False			'to the player without advancing ball number
Dim FlipperControl		'If true, the player has control over the flippers
FlipperControl = False
Dim TableState 			'1 = Init, 2 = Attract, 3 = Ingame, 4 = Tilt
Dim Credits				'Number of credits in the machine
Dim FreePlay			'If true, the player pays no credits to play

Dim PlayerNr			'Number of players currently in the game
PlayerNr = 0
Dim PlayerUp			'Current player (1-4) up to play
PlayerUp = 0

Dim Score					'Array with player scores
Dim BallNr					'Array with player ball number
Dim ExtraBall				'Array with number of extra balls each player has
Dim BonusHeld				'Array with bonus carried over into the next ball
Dim MultHeld				'Array with multipliers carried over into the next ball
Score = array(0,0,0,0,0)
BallNr = array(0,0,0,0,0)
ExtraBall = array(0,0,0,0,0)
BonusHeld = array(0,0,0,0,0)
MultHeld = array(1,1,1,1,1)

'Configurable values

Dim BallsPerGame		'Number of balls every player gets for one game
Dim SaverTime			'Time in tics after the start of a ball it takes for the ball saver to be unlit
Dim MoneyValue			'Number of credits a player gets for every quarter inserted
Dim MatchEnabled		'Enable a match prize
Dim MatchChance			'Probability of getting the match prize in percentages

Sub Table1_Init()		'Initialize at the start of the table (when it is switched on)
	Initialize()
End Sub

Dim HoldAttract

Sub Initialize()		'Set all default values of variables and load adjustments and highscores from file
	TableState = 1
	PutDMDText "MARBALL" & chr(10) & "EPROM V0.1A"
	BallsPerGame = 1
	SaverTime = 10
	MoneyValue = 1
	MatchEnabled = True
	MatchChance = 50
	Credits = 0
	FreePlay = False
	HoldAttract = False
	vpmTimer.AddTimer 4000,"PlaySound ""ding"" '"
	vpmTimer.AddTimer 5000,"Attract '"	
End Sub

Dim AttractFrame		'Number of the current frame during attract slideshow
AttractFrame = 0
Dim TotalFrames			'Total number of frames in attract slideshow
TotalFrames = 4

Sub Attract()
	PutDMDText ""
	HoldAttract = False
	TableState = 2
	NewAttractFrame()
End Sub

Sub NewAttractFrame()
	Dim AttractTime
	If TableState <> 2 Or HoldAttract Then
		Exit Sub
	End If
	Select Case AttractFrame	'Every time a frame runs out of time, a new frame is loaded
		Case 0
			PutDMDText "Welcome To"
			AttractTime = 2000
		Case 1
			PutDMDText "Marball" & chr(10) & "Alpha"
			AttractTime = 2000
		Case 2
			FlashCredits 10, 250
		Case 3
			PutDMDText "Game Over"
			AttractTime = 2000
	End Select
	AttractFrame = (AttractFrame + 1) Mod TotalFrames
	If Not HoldAttract Then
		vpmTimer.AddTimer AttractTime,"NewAttractFrame '"
	End If
End Sub

Dim DMDText
Dim FlashText
Dim FlashTimes
FlashTimes = 0
Dim FlashToggle


Sub FlashTimer_Timer()
	If FlashTimes = 0 Then
		FlashTimer.Enabled = False
		If TableState = 2 Then
			HoldAttract = False
			NewAttractFrame()
		End If
		Exit Sub
	Elseif FlashToggle Then
		TextDMD.Text = FlashText
	Else
		TextDMD.Text = DMDText
	End If
	FlashToggle = (FlashToggle + 1) Mod 2
	FlashTimes = FlashTimes - 1
End Sub

Sub FlashFor(times, speed, flashtext)
	FlashToggle = 1
	FlashText = flashtext
	FlashTimes = times
	FlashTimer.Interval = speed
	FlashTimer.Enabled = True
End Sub

Sub FlashCredits(times, speed)
	Dim credtext
	Dim cflashtext
	HoldAttract = True
	If FreePlay Then
		credtext = "Free Play" & chr(10) & "Press Start"
		cflashtext = "Free Play"
	Else 
		If Credits > 0 Then
		credtext = Credits & " Credits" & chr(10) & "Press Start"
		Else 
		credtext = Credits & " Credits" & chr(10) & "Insert Coin"
		End If
		cflashtext = Credits & " Credits"
	End If
	PutDMDText credtext
	FlashFor times, speed, cflashtext
End Sub

Sub AddQuarter(n)
	PlaySound SoundFX("coin",DOFContactors)
	vpmTimer.AddTimer 1500,"Quarter " & n & " '"
End Sub

Sub Quarter(n)
	Credits = Credits + n
	If TableState = 2 Then
		FlashCredits 15,250
	End If
End Sub

Sub StartGame()		'Checks if it's okay to start the game, then starts it
	If TableState = 1 Then
		Exit Sub
	End If
	If Credits >= 1 Or FreePlay Then
		If PlayerNr = 0 Then
			PutDMDText ""
			TableState = 3
			FlashTimer.Enabled = False
			PlayerNr = 1
			BallNr(1) = 1
			UpPlayer(1)
		Elseif PlayerNr < 4 Then		'Also adds new players
			PlayerNr = PlayerNr + 1
			BallNr(PlayerNr) = 1
			PutDMDScore()
		End If
		If Not FreePlay Then
			Credits = Credits - 1
		End If
	Elseif Credits < 1 And TableState = 2 And Not HoldAttract Then
		FlashCredits 10, 250
	End If
End Sub

Dim ReplayPrize
ReplayPrize = "Replay"
Dim ReplayGoal
ReplayGoal = 10000

Sub UpPlayer(pl)
	PlayerUp = pl
	FlipperControl = True
'	PlaySound SoundFX("song-0", DOFContactors),-1,0.5
	Saver = True
	NewBall()
	If BallNr(pl) = BallsPerGame Then
		PutDMDText ReplayPrize & " At" & chr(10) & ReplayGoal
		vpmTimer.AddTimer 2000,"PutDMDScore '"
	Else	
		PutDMDScore()
	End If
End Sub

Sub EndBall()	'After the ball has been drained, end ball
	If BIP = 0 Then
		If ShootAgainLite.State = 2 Then
			BallSaved()
		Else
'			StopSound "song-0"
			FlipperControl = False
			EOBB()
		End If
	Elseif BIP = 1 Then		'...or multiball
	
	End If
End Sub

Sub ShootAgainLite_Timer()
	Saver = False
	ShootAgainLite.State = 0
	ShootAgainLite.TimerEnabled = False
End Sub

Sub BallSaved()
	PutDMDText "Ball Saved"
	DMDResetTimer.Interval = 2000
	DMDResetTimer.Enabled = 1
	ShootAgainLite_Timer()
	NewBall()
End Sub

Dim Bonus
Bonus = 0
Dim Mult
Mult = 1
Dim EOBBStage
EOBBStage = 0

Sub EOBB()
	Dim StageTime
	StageTime = 1000
	Select Case EOBBStage
		Case 0
			PlaySound SoundFX("ding",DOFContactors)
			PutDMDText "BONUS"
			EOBBStage = 1
		Case 1
			PutDMDText Bonus
			If Mult > 1 Then
				EOBBStage = 2
			Else
				EOBBStage = 4
			End If
		Case 2
			PutDMDText Bonus & chr(10) & "X " & Mult
			EOBBStage = 3
		Case 3
			EOBBStage = 4
			PutDMDText Mult*Bonus & chr(10) & "X " & Mult
		Case 4
			PutDMDText Mult*Bonus & chr(10) & "TOTAL BONUS"
			EOBBStage = 5
		Case 5
			PutDMDText Mult*Bonus & chr(10) & Score(PlayerUp)
			EOBBStage = 6
		Case 6
			AddScore(Mult*Bonus)
			Bonus = 0
			Mult = 1
			PutDMDText "0" & chr(10) & Score(PlayerUp)
			EOBBStage = 7
		Case 7
			EOBBStage = 0
			PutDMDText ""
			If BallNr(PlayerUp) = BallsPerGame And ExtraBall(PlayerUp) = 0 And PlayerUp = PlayerNr Then
				PutDMDScore
				vpmTimer.AddTimer 1000, "Match '"
			Else
				BallNr(PlayerUp) = BallNr(PlayerUp) + 1
				UpPlayer((PlayerUp Mod PlayerNr) + 1)
			End If
			StageTime = 0
	End Select
	If StageTime <> 0 Then
		vpmTimer.AddTimer StageTime,"EOBB '"
	End If
End Sub

Dim MatchStage
MatchStage = 0
Dim MatchLine

Sub Match()
	Dim rand
	rand = Int(Rnd*10)*10
	If MatchStage = 0 Then
		vpmTimer.AddTimer 1000,"Match '"
		Select Case PlayerNr
			Case 1
				MatchLine = (Score(1) Mod 100)
			Case 2
				MatchLine = (Score(1) Mod 100) & chr(32) & (Score(2) Mod 100)
			Case 3
				MatchLine = (Score(1) Mod 100) & chr(32) & (Score(2) Mod 100) _
					& chr(32) & (Score(3) Mod 100)
			Case 4
				MatchLine = (Score(1) Mod 100) & chr(32) & (Score(2) Mod 100) _
					& chr(32) & (Score(3) Mod 100) & chr(32) & (Score(4) Mod 100)
		End Select
		PutDMDText "MATCH" & chr(10) & MatchLine
		Matchstage = 1
	Elseif MatchStage = 4 Then
		vpmTimer.AddTimer 2000,"GameOver '"
		Dim win
		win = Int(Rnd*100)
		If win < MatchChance Then
			rand = (Score(PlayerUp) Mod 100)
			vpmTimer.AddTimer 500,"FreeGame '"
		Else
			If rand = (Score(PlayerUp) Mod 100) Then
				rand = (rand + 10) Mod 100
			End If
		End If
		PutDMDText rand & chr(10) & MatchLine
		FlashFor 20, 100, chr(10) & MatchLine
		Matchstage = 0
	Else
		vpmTimer.AddTimer 1000,"Match '"
		PutDMDText rand & chr(10) & MatchLine
		Matchstage = Matchstage + 1
	End If
End Sub

Sub GameOver()
	PutDMDText ""
	HoldAttract = False
	TableState = 2
	AttractFrame = 3
End Sub

Sub FreeGame()
	PlaySound SoundFX("knocker",DOFContactors)
	If Not FreePlay Then
		Credits = Credits + 1
	End If
End Sub

Sub PutDMDText(text)		'Write a message in the textbox
	DMDText = text
	TextDMD.Text = DMDText
End Sub

Sub PutDMDScore()			'Display the score in the textbox
	If PlayerNr = 1 Then
		TextDMD.Text = Score(1) & chr(10) & "Ball " & BallNr(PlayerUp)
	Elseif PlayerNr = 2 Then
		TextDMD.Text = Score(2) & "   " & Score(1) & chr(10) & "Ball " & BallNr(PlayerUp)
	Elseif PlayerNr = 3 Then
		TextDMD.Text = Score(3) & "  " & Score(2) & "  " & Score(1) & chr(10) & "Ball " & BallNr(PlayerUp)
	Elseif PlayerNr = 4 Then
		TextDMD.Text = Score(3) & "  " & Score(2) & "  " & Score(1) & chr(10) & Score(4) & "   " & "Ball " & BallNr(PlayerUp)
	End If
End Sub

Sub AddScore(amt)			'Add an amount of points
	Score(PlayerUp) = Score(PlayerUp) + amt
	If Not DMDResetTimer.Enabled Then
		PutDMDScore()
	End If
End Sub

'**********

Sub Drain_Hit()
	PlaySound "drain",0,1,AudioPan(Drain),0.25,0,0,1,AudioFade(Drain)
	Drain.DestroyBall
	BIP = BIP - 1
	EndBall()
End Sub

Sub Newball()
	PlaySound SoundFX("ballrelease",DOFContactors), 0,1,AudioPan(BallRelease),0.25,0,0,1,AudioFade(BallRelease)
	'Plunger.CreateBall
	BallRelease.CreateBall
	BallRelease.Kick 90, 7
	BIP = BIP + 1
End Sub

Sub Gate_Hit()
	If Saver Then
		ShootAgainLite.State = 2
		ShootAgainLite.TimerEnabled = True
	End If
End Sub

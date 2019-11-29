'Table Vars

Dim Credits
Dim FlipperControl
Dim State
'0 = Init, 1 = Attract, 2 = Prelaunch, 3 = Mainplay, 4 = EOB, 5 = Match, 6 = Tilt, 7 = Slam Tilt 

Dim PlayerNr
Dim PlayerUp

'Config Vars

Dim BallsPP
Dim CreditValue
Dim FreePlay
Dim MatchChance
Dim SaverTime

'Player Vars

Dim P_Ball
Dim P_EBCount
Dim P_Score

'__________

'Var Init

Sub InitTable()
	Credits = 0
	FlipperControl = 0
	PlayerNr = 0
	PlayerUp = 0
	State = 0
	InitPlayers()
	FacReset()
	vpmTimer.AddTimer 2000,"Attract '"
End Sub

Sub InitPlayers()
	P_Ball = Array(0,0,0,0)
	P_EBCount = Array(0,0,0,0)
	P_Score = Array(0,0,0,0)
End Sub

Sub FacReset()
	BallsPP = 2
	CreditValue = 1
	MatchChance = 10
	SaverTime = 5
End Sub

'__________

'Game Control

Sub Attract()
	Debug.Print "Attract Mode"
	State = 1
End Sub

Sub PressStart()
	Debug.Print "Credits: " & Credits
	If State = 1 Then
		If FreePlay Then
			StartGame()
		ElseIf Credits > 0 Then
			Credits = Credits - 1
			StartGame()
		Else
'			AskForCredits()
		End If
	ElseIf State = 2 And P_Ball(PlayerUp) = 1 Then
		AddPlayer()
	End If
End Sub

Sub AddCredit(n)
	Credits = Credits + n
	Debug.Print "Credits: " & Credits
End Sub

Sub AddPlayer()
	If PlayerNr < 4 Then
		PlayerNr = PlayerNr + 1
		P_Ball(PlayerNr) = 1
	End If
End Sub

Sub NextBall()
	If P_EBCount(PlayerUp) > 0 Then
		P_EBCount(PlayerUp) = P_EBCount(PlayerUp) - 1
		Newball()
		FlipperControl = True
	ElseIf P_Ball(PlayerNr - 1) = BallsPP And PlayerUp = PlayerNr - 1 Then
		GameOver()
	Else
		P_Ball(PlayerUp) = P_Ball(PlayerUp) + 1
		PlayerUp = (PlayerUp + 1) Mod PlayerNr
		FlipperControl = True
		Newball()
	End If
End Sub

Sub StartGame()
	State = 2
	AddPlayer()
	PlayerUp = 0
	P_Ball(0) = 1
	FlipperControl = True
	Newball()
End Sub

Sub EndBall
	FlipperControl = False
	NextBall()
End Sub

Sub	GameOver()
	State = 1
	InitPlayers()
	PlayerUp = 0
	PlayerNr = 0
End Sub

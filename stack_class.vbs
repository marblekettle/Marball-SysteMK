Class c_Stack
	Private a_content
	Private a_size

	Private Sub Class_Initialize
		a_content = Array(0)
		a_size = 0
	End Sub

	Public Sub SetArr(arr)
		a_size = UBound(arr) + 1
		Redim Preserve a_content(a_size)
		Dim i
		For i = 0 To a_size - 1
			a_content(i) = arr(i)
		Next
	End Sub

	Public Sub SetOne(n, cont)
		If n < a_size Then
			a_content(n) = cont
		End If
	End Sub

	Public Function GetOne(n)
		If n < a_size Then
			GetOne = a_content(n)
		Else
			GetOne = 0
		End If
	End Function

	Public Sub Push_Front(ByVal cont)
		Dim temp()
		a_size = a_size + 1
		Redim Preserve temp(a_size)
		Dim i
		For i = 1 To a_size - 1
			temp(i) = a_content(i - 1)
		Next
		a_content = temp
	End Sub

	Public Function Pop_Front()
		If a_size > 0 Then
			Dim temp()
			a_size = a_size - 1
			Redim Preserve temp(a_size)
			Dim i
			For i = 1 To a_size - 1
				temp(i - 1) = a_content(i)
			Next
			Pop_Front = a_content(0)
			a_content = temp
		End If
	End Function
End Class